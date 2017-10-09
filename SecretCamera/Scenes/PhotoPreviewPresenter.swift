//
//  PhotoPreviewPresenter.swift
//  SecretCamera
//
//  Created by Hung on 8/30/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import Foundation
import AVFoundation

// MARK: Session Management
enum SessionSetupResult {
    case success
    case notAuthorized
    case configurationFailed
}

protocol PhotoPreviewView: class {
    // Camera View
    func setUpVideoPreview(session: AVCaptureSession)
    func setCameraPreview(_ videoOrientation: AVCaptureVideoOrientation)
    func showAnimationCaptureOnPreview()
    
    // Cover View
    func setUpCoverView()
    func setUpCaptureButton(_ hidden: Bool)
    func setUpNavigationBarForWebCoverView()
    func applicationDidEnterBackground()
}

protocol PhotoPreviewPresenter {
    var router: PhotoPreviewRouter { get }
    func viewDidLoad()
    func viewWillAppear(coverViewType: CoverViewType)
    func viewWillDisappear()
    
    // Cover View Events
    func captureButtonTapped()
    
    func dismissView()
}

final class PhotoPreviewPresenterImplementation: NSObject, PhotoPreviewPresenter {
    // Variables
    weak fileprivate var view:      PhotoPreviewView?
    internal let router:            PhotoPreviewRouter
    fileprivate let action:         Action
    
    fileprivate let session =           AVCaptureSession()
    fileprivate var videoDeviceInput:   AVCaptureDeviceInput!
    fileprivate var videoOrientation:   AVCaptureVideoOrientation?
    // Communicate with the session and other session objects on this queue.
    fileprivate var isSessionRunning = false
    fileprivate let sessionQueue =      DispatchQueue(label: "session queue", attributes: [], target: nil)
    fileprivate var setupResult: SessionSetupResult = .success
    // Photo
    fileprivate let photoOutput =       AVCapturePhotoOutput()
    fileprivate var inProgressPhotoCaptureDelegates = [Int64: PhotoCaptureProcessor]()
    
    // Observers
    fileprivate var sessionRunningObserveContext = 0
    
    fileprivate var timer: Timer?
    
    // MARK: - Constructions
    init(view: PhotoPreviewView, router: PhotoPreviewRouter, action: Action) {
        self.view = view
        self.router = router
        self.action = action
        super.init()
    }
    
    // MARK: - CameraPreviewPresenter
    func viewDidLoad() {
        view?.setUpVideoPreview(session: session)
        /*
            Check video authorization status. Video access is required and audio
            access is optional. If audio access is denied, audio is not recorded
            during movie recording.
         */
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
        case .authorized:
            // The user has previously granted access to the camera.
            break
            
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. We suspend the session queue to delay session
             setup until the access request has completed.
             
             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
             */
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { [unowned self] granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            
        default:
            // The user has previously denied access.
            setupResult = .notAuthorized
        }
        /*
            Setup the capture session.
            In general it is not safe to mutate an AVCaptureSession or any of its
            inputs, outputs, or connections from multiple threads at the same time.
         
            Why not do all of this on the main queue?
            Because AVCaptureSession.startRunning() is a blocking call which can
            take a long time. We dispatch session setup to the sessionQueue so
            that the main queue isn't blocked, which keeps the UI responsive.
         */
        sessionQueue.async { [weak self] in
            self?.configureSession()
        }
        addObservers()
    }
    
    func viewWillAppear(coverViewType: CoverViewType) {
        sessionQueue.async {
            if self.setupResult == .success {
                // Only setup observers and start the session running if setup succeeded.
                self.addObservers()
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
            }
        }
        if coverViewType == .Web {
            view?.setUpNavigationBarForWebCoverView()
        }
        fillUI()
    }
    
    func viewWillDisappear() {
        sessionQueue.async { [weak self] in
            if self?.setupResult == .success {
                self?.session.stopRunning()
                self?.isSessionRunning = self?.session.isRunning ?? false
            }
        }
        timer?.invalidate()
        removeObservers()
    }
    
    func dismissView() {
        router.dismissView()
    }
    
    func setUpNavigationBarForWebCoverView() {
        
    }
}

// MARK: - Cover View Events
extension PhotoPreviewPresenterImplementation {
    
    func captureButtonTapped() {
        capturePhoto()
    }
    
}

// MARK: - objc methods
extension PhotoPreviewPresenterImplementation {
    @objc
    func capturePhoto() {
        if let videoOrientation = videoOrientation {
            sessionQueue.async {
                // Update the photo output's connection to match the video orientation of the video preview layer.
                if let photoOutputConnection = self.photoOutput.connection(withMediaType: AVMediaTypeVideo) {
                    photoOutputConnection.videoOrientation = videoOrientation
                }
                
                let photoSettings = AVCapturePhotoSettings()
                photoSettings.isHighResolutionPhotoEnabled = true
                photoSettings.flashMode = .off
                
                // Use a separate object for the photo capture delegate to isolate each capture life cycle.
                let photoCaptureProcessor = PhotoCaptureProcessor(with: photoSettings, willCapturePhotoAnimation: {
                    DispatchQueue.main.async { [weak self] in
                        self?.view?.showAnimationCaptureOnPreview()
                    }
                }, completionHandler: { [weak self] photoCaptureProcessor in
                    // When the capture is complete, remove a reference to the photo capture delegate so it can be deallocated.
                    self?.sessionQueue.async { [weak self] in
                        self?.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = nil
                    }
                })
                /*
                 The Photo Output keeps a weak reference to the photo capture delegate so
                 we store it in an array to maintain a strong reference to this object
                 until the capture is completed.
                 */
                self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = photoCaptureProcessor
                self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
            }
        }
    }
    
    @objc
    func applicationDidEnterBackground() {
        sessionQueue.async { [weak self] in
            if self?.isSessionRunning == true {
                self?.session.stopRunning()
                self?.isSessionRunning = self?.session.isRunning ?? false
            }
        }
        timer?.invalidate()
        view?.applicationDidEnterBackground()
    }
    
    @objc
    func applicationWillEnterForeground() {
        sessionQueue.async { [weak self] in
            /*
             The session might fail to start running, e.g., if a phone or FaceTime call is still
             using audio or video. A failure to start the session running will be communicated via
             a session runtime error notification. To avoid repeatedly failing to start the session
             running, we only try to restart the session running in the session runtime error handler
             if we aren't trying to resume the session running.
             */
            if self?.isSessionRunning == false {
                self?.session.startRunning()
                self?.isSessionRunning = self?.session.isRunning ?? true
            }
        }
        // Auto Repeat Photo Settings
        if let autoRepeatPhotoSetting = action.settings.first as? SettingLogoWithSwitch {
            if autoRepeatPhotoSetting.isSelected, let timePhotoSetting = action.settings.last as? PhotoTimeSetting {
                // Time option 3s, 5s and 10s
                addCaptureTimer(timePhotoSetting.index == 0 ? 3 : (timePhotoSetting.index == 1 ? 5 : 10))
            }
        }
    }
}

// MARK: - Private 
private extension PhotoPreviewPresenterImplementation {
    
    /// Configure Session 
    /// NOTE: Call this on the session queue
    func configureSession() {
        if setupResult != .success {
            return
        }
        
        session.beginConfiguration()
        /*
         We do not create an AVCaptureMovieFileOutput when setting up the session because the
         AVCaptureMovieFileOutput does not support movie recording with AVCaptureSessionPresetPhoto.
         */
        session.sessionPreset = AVCaptureSessionPresetPhoto
        // Add Video Input
        do {
            var defaultVideoDevice: AVCaptureDevice?
            defaultVideoDevice = setUpCameraPosition()
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice!)
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                DispatchQueue.main.async {
                    /*
                     Why are we dispatching this to the main queue?
                     Because AVCaptureVideoPreviewLayer is the backing layer for PreviewView and UIView
                     can only be manipulated on the main thread.
                     Note: As an exception to the above rule, it is not necessary to serialize video orientation changes
                     on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                     
                     Use the status bar orientation as the initial video orientation. Subsequent orientation changes are
                     handled by CameraViewController.viewWillTransition(to:with:).
                     */
                    let statusBarOrientation = UIApplication.shared.statusBarOrientation
                    var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                    if statusBarOrientation != .unknown {
                        if let videoOrientation = statusBarOrientation.videoOrientation {
                            initialVideoOrientation = videoOrientation
                        }
                    }
                    self.videoOrientation = initialVideoOrientation
                    self.view?.setCameraPreview(initialVideoOrientation)
                }
                
            } else {
                print("Could not add video device input to the session")
                session.commitConfiguration()
                return
            }
            
        } catch {
            print("Could not create video device input: \(error)")
            session.commitConfiguration()
            return
        }
        
        // Add photo output.
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            
            photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported
        } else {
            print("Could not add photo output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
    }
    
    /// Add Observers
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIApplicationDidEnterBackground, object: nil)
    }
    
    /// Set Auto Capture Timer
    ///
    /// - Parameter timeInterval: Seconds
    func addCaptureTimer(_ timeInterval: TimeInterval) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(capturePhoto), userInfo: nil, repeats: true)
    }
    
    /// Setup Camera Position
    ///
    /// - Returns: AVCaptureDevice
    func setUpCameraPosition() -> AVCaptureDevice? {
        var defaultVideoDevice: AVCaptureDevice?
        if let cameraPositionSetting = action.cameraSettings.first as? CameraPositionSetting {
            if cameraPositionSetting.index == 0 {
                // Back Camera
                // Choose the back dual camera if available, otherwise default to a wide angle camera.
                if let dualCameraDevice =
                    AVCaptureDevice.defaultDevice(withDeviceType: .builtInDualCamera, mediaType: AVMediaTypeVideo, position: .back) {
                    defaultVideoDevice = dualCameraDevice
                } else if let backCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back) {
                    // If the back dual camera is not available, default to the back wide angle camera.
                    defaultVideoDevice = backCameraDevice
                } else if let frontCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front) {
                    /*
                     In some cases where users break their phones, the back wide angle camera is not available.
                     In this case, we should default to the front wide angle camera.
                     */
                    defaultVideoDevice = frontCameraDevice
                }
            } else {
                // Front Camera
                if let frontCameraDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front) {
                    defaultVideoDevice = frontCameraDevice
                }
            }
        }
        return defaultVideoDevice
    }
    
    func fillUI() {
        view?.setUpCoverView()
        // Auto Repeat Photo Settings
        if let autoRepeatPhotoSetting = action.settings.first as? SettingLogoWithSwitch {
            if autoRepeatPhotoSetting.isSelected, let timePhotoSetting = action.settings.last as? PhotoTimeSetting {
                // Time option 3s, 5s and 10s
                addCaptureTimer(timePhotoSetting.index == 0 ? 3 : (timePhotoSetting.index == 1 ? 5 : 10))
            }
        }
        
        // Capture Button Setting
        if let hideCaptureButtonSetting = action.cameraSettings.last as? SettingWithSwitch {
            view?.setUpCaptureButton(hideCaptureButtonSetting.isSelected)
        }
    }
}
