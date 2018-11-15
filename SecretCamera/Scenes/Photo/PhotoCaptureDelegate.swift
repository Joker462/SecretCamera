/*
See LICENSE.txt for this sample’s licensing information.

Abstract:
Photo capture delegate.
*/

import AVFoundation
import Photos

class PhotoCaptureProcessor: NSObject {
	fileprivate(set) var requestedPhotoSettings: AVCapturePhotoSettings
	
	fileprivate let willCapturePhotoAnimation: () -> Void
	
	fileprivate let completionHandler: (PhotoCaptureProcessor) -> Void
	
	fileprivate var photoData: Data?

	init(with requestedPhotoSettings: AVCapturePhotoSettings,
	     willCapturePhotoAnimation: @escaping () -> Void,
	     completionHandler: @escaping (PhotoCaptureProcessor) -> Void) {
		self.requestedPhotoSettings = requestedPhotoSettings
		self.willCapturePhotoAnimation = willCapturePhotoAnimation
		self.completionHandler = completionHandler
	}
	
	fileprivate func didFinish() {
		completionHandler(self)
	}
    
}

extension PhotoCaptureProcessor: AVCapturePhotoCaptureDelegate {
    /*
     This extension includes all the delegate callbacks for AVCapturePhotoCaptureDelegate protocol
    */
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        // Live Setup
    }
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        // Animation Setup
        willCapturePhotoAnimation()
    }
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let photoSampleBuffer = photoSampleBuffer {
            photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
        } else if let error = error {
            print("Error capturing photo: \(error)")
        }
    }
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            didFinish()
            return
        }
        
        guard let photoData = photoData else {
            print("No photo data resource")
            didFinish()
            return
        }
        
        PHPhotoLibrary.requestAuthorization { [unowned self] status in
            if status == .authorized {
                PHPhotoLibrary.shared().performChanges({
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    creationRequest.addResource(with: .photo, data: photoData, options: nil)
                }, completionHandler: { [unowned self] _, error in
                    if let error = error {
                        print("Error occurered while saving photo to photo library: \(error)")
                    }
                    self.didFinish()
                    }
                )
            } else {
                self.didFinish()
            }
        }
    }
}
