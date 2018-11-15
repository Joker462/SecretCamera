//
//  VideoViewModel.swift
//  SecretCamera
//
//  Created by MMI001 on 11/7/18.
//  Copyright (c) 2018 Hung. All rights reserved.
//

import Foundation
import AVFoundation
import Photos

// MARK: - Session Management -
enum SessionSetupResult {
    case success
    case notAuthorized
    case configurationFailed
}

// MARK: - Input -
protocol VideoViewInput {
    // View cycle triggers
    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func applicationWillResignActive()
    
    func prefersStatusBarHidden() -> Bool
    func dimiss()
}

// MARK: - Output -
protocol VideoViewOutput: class {
    func setupBlackCover()
    func setupWebCover()
    func setupGameCover()
    
    func setNavigationBar(isHidden: Bool)
    func setupVideoPreview(session: AVCaptureSession)
    func setCameraPreview(videoOrientation: AVCaptureVideoOrientation)
    func showStartRecordAnimation()
}

final class VideoViewModel: NSObject, VideoViewInput {
    
    // MARK: - Output protocol
    weak var output: VideoViewOutput?
    
    // MARK: - Properties
    fileprivate let action: Action
    fileprivate let navigator: VideoNavigator
    fileprivate let session = AVCaptureSession()
    fileprivate var videoDeviceInput: AVCaptureDeviceInput!
    fileprivate var videoOrientation: AVCaptureVideoOrientation?
    // Communicate with the session and other session objects on this queue.
    fileprivate var isSessionRunning = false
    fileprivate let sessionQueue = DispatchQueue(label: "session queue", attributes: [], target: nil)
    fileprivate var sessionResult: SessionSetupResult = .success
    fileprivate var movieFileOutput: AVCaptureMovieFileOutput?
    fileprivate var backgroundRecordingID: UIBackgroundTaskIdentifier?
    
    // MARK: - Construction
    init(navigator: VideoNavigator, output: VideoViewOutput) {
        self.navigator = navigator
        self.output = output
        action = Database.shared.coverSelected.actions[Database.shared.coverSelected.actionIndex!]
        super.init()
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
                strong.prepareToPlay()
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
    
    func applicationWillResignActive() {
        sessionQueue.async { [weak self] in
            guard let strong = self else { return }
            if strong.isSessionRunning {
                strong.session.stopRunning()
                strong.isSessionRunning = strong.session.isRunning
            }
        }
        if let currentBackgroundRecordingID = backgroundRecordingID {
            if currentBackgroundRecordingID != UIBackgroundTaskInvalid {
                UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
                backgroundRecordingID = UIBackgroundTaskInvalid
            }
        }
        movieFileOutput?.stopRecording()
        navigator.navigate(option: .dismiss)
    }
    
    func prefersStatusBarHidden() -> Bool {
        return Database.shared.coverIndexSelected == 1
    }
    
    func dimiss() {
        navigator.navigate(option: .dismiss)
    }
}

// MARK: - Private methods -
private extension VideoViewModel {
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
    
    func configureSession() {
        guard sessionResult == .success else { return }
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
            videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice)
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
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
        
        // Add audio input.
        do {
            let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
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
    
    func prepareToPlay() {
        let movieFileOutput = AVCaptureMovieFileOutput()
        guard session.canAddOutput(movieFileOutput),
            let autoStartRecordSetting = action.settings.first as? VideoStartRecordSetting else { return }
        session.beginConfiguration()
        session.addOutput(movieFileOutput)
        session.sessionPreset = AVCaptureSession.Preset(rawValue: getCameraQualitySetting())
        if let connection = movieFileOutput.connection(with: .video),
            connection.isVideoStabilizationSupported {
            connection.preferredVideoStabilizationMode = .auto
        }
        session.commitConfiguration()
        self.movieFileOutput = movieFileOutput
        
        let autoStartSeconds: TimeInterval = autoStartRecordSetting.index == 0 ? 3 : (autoStartRecordSetting.index == 1 ? 5 : 10)
        sessionQueue.asyncAfter(deadline: .now()+autoStartSeconds) { [weak self] in
            self?.startRecord()
        }
    }
    
    private func getCameraQualitySetting() -> String {
        if let cameraQualitySetting = action.cameraSettings.first as? CameraQualitySetting {
            return cameraQualitySetting.index == 0 ? AVCaptureSession.Preset.low.rawValue : (cameraQualitySetting.index == 1 ? AVCaptureSession.Preset.medium.rawValue : AVCaptureSession.Preset.high.rawValue)
        }
        return AVCaptureSession.Preset.low.rawValue
    }
    
    private func startRecord() {
        if !movieFileOutput!.isRecording {
            if UIDevice.current.isMultitaskingSupported {
                /*
                 Setup background task.
                 This is needed because the `capture(_:, didFinishRecordingToOutputFileAt:, fromConnections:, error:)`
                 callback is not received until AVCam returns to the foreground unless you request background execution time.
                 This also ensures that there will be time to write the file to the photo library when AVCam is backgrounded.
                 To conclude this background execution, endBackgroundTask(_:) is called in
                 `capture(_:, didFinishRecordingToOutputFileAt:, fromConnections:, error:)` after the recorded file has been saved.
                 */
                backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
            }
            
            // Update the orientation on the movie file output video connection before starting recording.
            let movieFileOutputConnection = movieFileOutput?.connection(with: AVMediaType.video)
            movieFileOutputConnection?.videoOrientation = videoOrientation!
            
            if #available(iOS 11.0, *) {
                let availableVideoCodecTypes = movieFileOutput!.availableVideoCodecTypes
                if availableVideoCodecTypes.contains(.hevc) {
                    movieFileOutput!.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc], for: movieFileOutputConnection!)
                }
            }
            // Start recording to a temporary file.
            let outputFileName = NSUUID().uuidString
            let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
            movieFileOutput!.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
        } else {
            movieFileOutput!.stopRecording()
        }
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension VideoViewModel: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async { [weak self] in
            self?.output?.showStartRecordAnimation()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
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
            
            if let currentBackgroundRecordingID = backgroundRecordingID,
                currentBackgroundRecordingID != UIBackgroundTaskInvalid {
                UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
                backgroundRecordingID = UIBackgroundTaskInvalid
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
                        cleanup()
                    })
                } else {
                    cleanup()
                }
            }
        } else {
            cleanup()
        }
    }
}
