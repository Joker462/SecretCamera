//
//  PhotoViewModel.swift
//  SecretCamera
//
//  Created by MMI001 on 11/12/18.
//  Copyright (c) 2018 Hung. All rights reserved.
//

import Foundation
import AVFoundation
import Photos

// MARK: - Input -
protocol PhotoViewInput {
    // View cycle triggers
    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func prefersStatusBarHidden() -> Bool
    func applicationWillEnterForeground()
    func applicationDidEnterBackground()
    
    // Events
    func capture()
    
    // Router
    func dismiss()
}

// MARK: - Output -
protocol PhotoViewOutput: class {
    func setupBlackCover()
    func setupWebCover()
    func setupGameCover()
    
    func setNavigationBar(isHidden: Bool)
    func setupVideoPreview(session: AVCaptureSession)
    func setCameraPreview(videoOrientation: AVCaptureVideoOrientation)
    func setupCaptureButton(_ hidden: Bool)
    func showAnimationCaptureOnPreview()
}

final class PhotoViewModel: PhotoViewInput {
    
    // MARK: - Output protocol
    weak var output: PhotoViewOutput?
    
    // MARK: - Properties
    fileprivate let navigator: PhotoNavigator
    fileprivate let action: Action
    fileprivate let session = AVCaptureSession()
    fileprivate var videoDeviceInput: AVCaptureDeviceInput!
    fileprivate var videoOrientation: AVCaptureVideoOrientation?
    // Communicate with the session and other session objects on this queue.
    fileprivate var isSessionRunning = false
    fileprivate let sessionQueue = DispatchQueue(label: "session queue", attributes: [], target: nil)
    fileprivate var sessionResult: SessionSetupResult = .success
    // Photo
    fileprivate let photoOutput = AVCapturePhotoOutput()
    fileprivate var inProgressPhotoCaptureDelegates = [Int64: PhotoCaptureProcessor]()
    // Observers
    fileprivate var sessionRunningObserveContext = 0
    fileprivate var timer: Timer?
    
    // MARK: - Construction
    init(navigator: PhotoNavigator, output: PhotoViewOutput) {
        self.navigator = navigator
        self.output = output
        action = Database.shared.coverSelected.actions[Database.shared.coverSelected.actionIndex!]
    }
    
    // MARK: - View cycle triggers
    func viewDidLoad() {
        output?.setupVideoPreview(session: session)
        checkMediaAuthorization()
        sessionQueue.async { [weak self] in
            self?.configureSession()
        }
        setupCover()
    }
    
    func viewWillAppear() {
        sessionQueue.async { [weak self] in
            if self?.sessionResult == .success {
                guard let strong = self else { return }
                strong.session.startRunning()
                strong.isSessionRunning = strong.session.isRunning
                strong.fillUI()
            }
        }
        
        if Database.shared.coverIndexSelected == 1 {
            output?.setNavigationBar(isHidden: false)
        } else {
            output?.setNavigationBar(isHidden: true)
        }
    }
    
    func viewWillDisappear() {
        output?.setNavigationBar(isHidden: false)
    }
    
    func prefersStatusBarHidden() -> Bool {
        return Database.shared.coverIndexSelected == 1
    }
    
    func applicationDidEnterBackground() {
        // Disable auto capture
        sessionQueue.async { [weak self] in
            if self?.isSessionRunning == true {
                self?.isSessionRunning = false
                self?.session.stopRunning()
            }
        }
        timer?.invalidate()
    }
    
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
                self?.isSessionRunning = true
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

// MARK: - Private methods -
private extension PhotoViewModel {
    func setupCover() {
        switch Database.shared.coverIndexSelected {
        case 0:
            // Black
            output?.setupBlackCover()
            break
        case 1:
            // Web
            output?.setupWebCover()
            break
        default:
            // Game
            output?.setupGameCover()
            break
        }
    }
    
    func checkMediaAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. We suspend the session queue to delay session
             setup until the access request has completed.
             
             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
             */
            sessionQueue.suspend()
            // Request again
            AVCaptureDevice.requestAccess(for: .video) { [weak self] (granted) in
                self?.sessionResult = granted ? .success : .notAuthorized
                self?.sessionQueue.resume()
            }
            break
        case .authorized:
            // The user has previously granted access to the camera.
            break
        default:
            // The user has previously denied access.
            sessionResult = .notAuthorized
            break
        }
    }
    
    /// Configure Session
    /// NOTE: Call this on the session queue
    func configureSession() {
        if sessionResult != .success { return }
        
        session.beginConfiguration()
        /*
         We do not create an AVCaptureMovieFileOutput when setting up the session because the
         AVCaptureMovieFileOutput does not support movie recording with AVCaptureSessionPresetPhoto.
         */
        session.sessionPreset = AVCaptureSession.Preset.photo
        // Add Video Input
        do {
            guard let defaultVideoDevice = setupCameraPosition() else {
                sessionResult = .configurationFailed
                return
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice)
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                DispatchQueue.main.async { [weak self] in
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
                    self?.videoOrientation = initialVideoOrientation
                    self?.output?.setCameraPreview(videoOrientation: initialVideoOrientation)
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
            sessionResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
    }
    
    func setupCameraPosition() -> AVCaptureDevice? {
        var defaultVideoDevice: AVCaptureDevice?
        if let cameraPositionSetting = action.cameraSettings.last as? CameraPositionSetting {
            if cameraPositionSetting.index == 0 {
                // Back Camera
                // Choose the back dual camera if available, otherwise default to a wide angle camera.
                if let dualCameraDevice =
                    AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInDualCamera, for: AVMediaType.video, position: .back) {
                    defaultVideoDevice = dualCameraDevice
                } else if let backCameraDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .back) {
                    // If the back dual camera is not available, default to the back wide angle camera.
                    defaultVideoDevice = backCameraDevice
                } else if let frontCameraDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .front) {
                    /*
                     In some cases where users break their phones, the back wide angle camera is not available.
                     In this case, we should default to the front wide angle camera.
                     */
                    defaultVideoDevice = frontCameraDevice
                }
            } else {
                // Front Camera
                if let frontCameraDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: .front) {
                    defaultVideoDevice = frontCameraDevice
                }
            }
        }
        return defaultVideoDevice
    }
    
    func fillUI() {
        // Auto Repeat Photo Settings
        if let autoRepeatPhotoSetting = action.settings.first as? SettingLogoWithSwitch {
            if autoRepeatPhotoSetting.isSelected, let timePhotoSetting = action.settings.last as? PhotoTimeSetting {
                // Time option 3s, 5s and 10s
                addCaptureTimer(timePhotoSetting.index == 0 ? 3 : (timePhotoSetting.index == 1 ? 5 : 10))
            }
        }
        
        // Capture Button Setting
        if let hideCaptureButtonSetting = action.cameraSettings.last as? SettingWithSwitch {
            output?.setupCaptureButton(hideCaptureButtonSetting.isSelected)
        }
    }
    
    /// Set Auto Capture Timer
    ///
    /// - Parameter timeInterval: Seconds
    func addCaptureTimer(_ timeInterval: TimeInterval) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(capturePhoto), userInfo: nil, repeats: true)
    }
}

// MARK: - Events -
extension PhotoViewModel {
    func capture() {
        if let videoOrientation = videoOrientation {
            sessionQueue.async {
                // Update the photo output's connection to match the video orientation of the video preview layer.
                if let photoOutputConnection = self.photoOutput.connection(with: AVMediaType.video) {
                    photoOutputConnection.videoOrientation = videoOrientation
                }
                
                let photoSettings = AVCapturePhotoSettings()
                photoSettings.isHighResolutionPhotoEnabled = true
                photoSettings.flashMode = .off
                
                // Use a separate object for the photo capture delegate to isolate each capture life cycle.
                let photoCaptureProcessor = PhotoCaptureProcessor(with: photoSettings, willCapturePhotoAnimation: {
                    DispatchQueue.main.async { [weak self] in
                        self?.output?.showAnimationCaptureOnPreview()
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
    private func capturePhoto() {
        capture()
    }
}

// MARK: - Router -
extension PhotoViewModel {
    func dismiss() {
        navigator.navigate(option: .dismiss)
    }
}
