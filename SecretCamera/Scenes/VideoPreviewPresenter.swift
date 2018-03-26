//
//  VideoPreviewPresenter.swift
//  SecretCamera
//
//  Created by Hung on 9/23/17.
//  Copyright © 2017 Hung. All rights reserved.
//

import Foundation
import AVFoundation
import Photos

protocol VideoPreviewView: class {
    // Camera View
    func setUpVideoPreview(session: AVCaptureSession)
    func setCameraPreview(_ videoOrientation: AVCaptureVideoOrientation)
    
    func setUpNavigationBarForWebCoverView()
    func showAnimationStartRecordOnPreview()
    // Cover View
    func setUpCoverView()
    func applicationWillResignActive()
}

protocol VideoPreviewPresenter {
    var router: VideoPreviewRouter { get }
    
    // Life cycles
    func viewDidLoad()
    func viewWillAppear(coverViewType: CoverViewType)
    func viewWillDisappear()
    
    func dismissView()
}

final class VideoPreviewPresenterImplementation: NSObject, VideoPreviewPresenter {
    // Variables
    weak fileprivate var view:      VideoPreviewView?
    internal let router:            VideoPreviewRouter
    fileprivate let action:         Action
    
    fileprivate let session =           AVCaptureSession()
    fileprivate var videoDeviceInput:   AVCaptureDeviceInput!
    fileprivate var videoOrientation:   AVCaptureVideoOrientation?
    // Communicate with the session and other session objects on this queue.
    fileprivate var isSessionRunning = false
    fileprivate let sessionQueue =      DispatchQueue(label: "session queue", attributes: [], target: nil)
    fileprivate var setupResult: SessionSetupResult = .success
    
    // Video
    fileprivate var movieFileOutput: AVCaptureMovieFileOutput?
    fileprivate var backgroundRecordingID: UIBackgroundTaskIdentifier?
    
    // MARK: - Constructions
    init(view: VideoPreviewView, router: VideoPreviewRouter, action: Action) {
        self.view = view
        self.router = router
        self.action = action
        super.init()
    }
    
    // MARK: - VideoPreviewView
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
        sessionQueue.async { [unowned self] in
            self.configureSession()
        }
        view?.setUpCoverView()
    }
    
    func viewWillAppear(coverViewType: CoverViewType) {
        sessionQueue.async {
            if self.setupResult == .success {
                // Only setup observers and start the session running if setup succeeded.
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
                self.fillUI()
                self.addObservers()
            }
        }
        if coverViewType == .Web {
            view?.setUpNavigationBarForWebCoverView()
        }
    }
    
    func viewWillDisappear() {
        sessionQueue.async { [weak self] in
            if self?.setupResult == .success && self?.isSessionRunning == true {
                self?.session.stopRunning()
                self?.isSessionRunning = self?.session.isRunning ?? false
                self?.removeObservers()
            }
        }
    }
    
    func dismissView() {
        
        movieFileOutput?.stopRecording()
        router.dismissView()
    }
}

// MARK: - Private
private extension VideoPreviewPresenterImplementation {
    
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
        
        // Add audio input.
        do {
            let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
            
            if session.canAddInput(audioDeviceInput) {
                session.addInput(audioDeviceInput)
            } else {
                print("Could not add audio device input to the session")
            }
        } catch {
            print("Could not create audio device input: \(error)")
        }
        session.commitConfiguration()
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: .UIApplicationWillResignActive, object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillResignActive, object: nil)
    }
    
    func setUpCameraPosition() -> AVCaptureDevice? {
        var defaultVideoDevice: AVCaptureDevice?
        if let cameraPositionSetting = action.cameraSettings.last as? CameraPositionSetting {
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
        sessionQueue.async { [unowned self] in
            let movieFileOutput = AVCaptureMovieFileOutput()
            if self.session.canAddOutput(movieFileOutput) {
                self.session.beginConfiguration()
                self.session.addOutput(movieFileOutput)
                self.session.sessionPreset = self.getQualitySetting()
                if let connection = movieFileOutput.connection(withMediaType: AVMediaTypeVideo) {
                    if connection.isVideoStabilizationSupported {
                        connection.preferredVideoStabilizationMode = .auto
                    }
                }
                self.session.commitConfiguration()
                self.movieFileOutput = movieFileOutput
            }
        }
        
        if let autoStartRecordSetting = action.settings.first as? VideoStartRecordSetting {
            // 3s, 5s or 10s
            let autoStartSeconds: TimeInterval = autoStartRecordSetting.index == 0 ? 3 : (autoStartRecordSetting.index == 1 ? 5 : 10)
            sessionQueue.asyncAfter(deadline: DispatchTime.now() + autoStartSeconds, execute: { [weak self] in
                self?.startRecord()
            })
        }
    }
    
    func getQualitySetting() -> String {
        if let cameraQualitySetting = action.cameraSettings.first as? CameraQualitySetting {
            return cameraQualitySetting.index == 0 ? AVCaptureSessionPresetLow : (cameraQualitySetting.index == 1 ? AVCaptureSessionPresetMedium : AVCaptureSessionPresetHigh)
        }
        return AVCaptureSessionPresetLow
    }
    
    func startRecord() {
        guard let movieFileOutput = self.movieFileOutput else {
            return
        }
        
        sessionQueue.async { [unowned self] in
            if !movieFileOutput.isRecording {
                if UIDevice.current.isMultitaskingSupported {
                    /*
                     Setup background task.
                     This is needed because the `capture(_:, didFinishRecordingToOutputFileAt:, fromConnections:, error:)`
                     callback is not received until AVCam returns to the foreground unless you request background execution time.
                     This also ensures that there will be time to write the file to the photo library when AVCam is backgrounded.
                     To conclude this background execution, endBackgroundTask(_:) is called in
                     `capture(_:, didFinishRecordingToOutputFileAt:, fromConnections:, error:)` after the recorded file has been saved.
                     */
                    self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                }
                
                // Update the orientation on the movie file output video connection before starting recording.
                let movieFileOutputConnection = self.movieFileOutput?.connection(withMediaType: AVMediaTypeVideo)
                movieFileOutputConnection?.videoOrientation = self.videoOrientation!
                
                if #available(iOS 11.0, *) {
                    let availableVideoCodecTypes = movieFileOutput.availableVideoCodecTypes as! [AVVideoCodecType]
                    if availableVideoCodecTypes.contains(.hevc) {
                        movieFileOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc], for: movieFileOutputConnection!)
                    }
                }
                // Start recording to a temporary file.
                let outputFileName = NSUUID().uuidString
                let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
                movieFileOutput.startRecording(toOutputFileURL: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
            } else {
                movieFileOutput.stopRecording()
            }
        }
    }
}

// MARK: - @objc methods
extension VideoPreviewPresenterImplementation {
    @objc
    func applicationWillResignActive() {
        view?.applicationWillResignActive()
        sessionQueue.async { [unowned self] in
            if self.isSessionRunning {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
            }
        }
        if let currentBackgroundRecordingID = backgroundRecordingID {
            backgroundRecordingID = UIBackgroundTaskInvalid
            
            if currentBackgroundRecordingID != UIBackgroundTaskInvalid {
                UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
            }
        }
        movieFileOutput?.stopRecording()
        router.dismissView()
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension VideoPreviewPresenterImplementation: AVCaptureFileOutputRecordingDelegate {
    
    func capture(_ output: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        DispatchQueue.main.async { [weak self] in
            self?.view?.showAnimationStartRecordOnPreview()
        }
    }
    
    func capture(_ output: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        /*
         Note that currentBackgroundRecordingID is used to end the background task
         associated with this recording. This allows a new recording to be started,
         associated with a new UIBackgroundTaskIdentifier, once the movie file output's
         `isRecording` property is back to false — which happens sometime after this method
         returns.
         
         Note: Since we use a unique file path for each recording, a new recording will
         not overwrite a recording currently being saved.
         */
        func cleanup() {
            let path = outputFileURL.path
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    print("Could not remove file at url: \(outputFileURL)")
                }
            }
            
            if let currentBackgroundRecordingID = backgroundRecordingID {
                backgroundRecordingID = UIBackgroundTaskInvalid
                
                if currentBackgroundRecordingID != UIBackgroundTaskInvalid {
                    UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
                }
            }
        }
        
        var success = true
        
        if error != nil {
            print("Movie file finishing error: \(String(describing: error))")
            success = (((error! as NSError).userInfo[AVErrorRecordingSuccessfullyFinishedKey] as AnyObject).boolValue)!
        }
        
        if success {
            // Check authorization status.
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    // Save the movie file to the photo library and cleanup.
                    PHPhotoLibrary.shared().performChanges({
                        let options = PHAssetResourceCreationOptions()
                        options.shouldMoveFile = true
                        let creationRequest = PHAssetCreationRequest.forAsset()
                        creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
                    }, completionHandler: { success, error in
                        if !success {
                            print("Could not save movie to photo library: \(String(describing: error))")
                        }
//                        cleanup()
                    }
                    )
                } else {
                    cleanup()
                }
            }
        } else {
            cleanup()
        }
    }
}
