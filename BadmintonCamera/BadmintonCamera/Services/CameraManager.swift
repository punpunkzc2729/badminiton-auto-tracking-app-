//
//  CameraManager.swift
//  BadmintonCamera
//
//  AVFoundation camera capture manager
//

import AVFoundation
import UIKit

class CameraManager: NSObject {
    
    // MARK: - Properties
    
    var onFrameCaptured: ((Data) -> Void)?
    
    private let captureSession = AVCaptureSession()
    private var videoOutput: AVCaptureVideoDataOutput?
    private let videoQueue = DispatchQueue(label: "com.badminton.camera.video")
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    private var frameCounter = 0
    private var isCapturing = false
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupCamera()
    }
    
    // MARK: - Setup
    
    private func setupCamera() {
        captureSession.sessionPreset = .hd1920x1080  // 1080p
        
        // Get back camera
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get camera device")
            return
        }
        
        // Configure camera for high performance
        do {
            try camera.lockForConfiguration()
            
            // Set frame rate to 60fps if supported
            if let format = getBestFormat(for: camera) {
                camera.activeFormat = format
                camera.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 60)
                camera.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 60)
            }
            
            // Enable auto-focus
            if camera.isFocusModeSupported(.continuousAutoFocus) {
                camera.focusMode = .continuousAutoFocus
            }
            
            // Enable auto-exposure
            if camera.isExposureModeSupported(.continuousAutoExposure) {
                camera.exposureMode = .continuousAutoExposure
            }
            
            camera.unlockForConfiguration()
        } catch {
            print("Failed to configure camera: \(error)")
        }
        
        // Add camera input
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("Failed to create camera input: \(error)")
            return
        }
        
        // Add video output
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: videoQueue)
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        output.alwaysDiscardsLateVideoFrames = true
        
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
            videoOutput = output
        }
        
        // Setup preview layer
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.videoGravity = .resizeAspectFill
        previewLayer = layer
    }
    
    /// Get best camera format for 1080p 60fps
    private func getBestFormat(for device: AVCaptureDevice) -> AVCaptureDevice.Format? {
        let formats = device.formats
        
        // Find 1080p 60fps format
        for format in formats {
            let desc = format.formatDescription
            let dimensions = CMVideoFormatDescriptionGetDimensions(desc)
            
            if dimensions.width == 1920 && dimensions.height == 1080 {
                for range in format.videoSupportedFrameRateRanges {
                    if range.maxFrameRate >= 60 {
                        return format
                    }
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Capture Control
    
    func startCapture() {
        guard !isCapturing else { return }
        
        videoQueue.async { [weak self] in
            self?.captureSession.startRunning()
        }
        isCapturing = true
    }
    
    func stopCapture() {
        guard isCapturing else { return }
        
        videoQueue.async { [weak self] in
            self?.captureSession.stopRunning()
        }
        isCapturing = false
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // Sample every other frame to reduce bandwidth (30fps effective)
        frameCounter += 1
        guard frameCounter % 2 == 0 else { return }
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // Convert to UIImage
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        let image = UIImage(cgImage: cgImage)
        
        // Compress to JPEG (quality 0.6 for good balance)
        guard let jpegData = image.jpegData(compressionQuality: 0.6) else { return }
        
        // Send frame
        onFrameCaptured?(jpegData)
    }
}
