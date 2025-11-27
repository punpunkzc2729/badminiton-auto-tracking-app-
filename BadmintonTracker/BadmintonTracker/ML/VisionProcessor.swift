//
//  VisionProcessor.swift
//  BadmintonTracker
//
//  Vision Framework integration for player and shuttlecock detection
//

import Foundation
import Vision
import CoreImage
import BadmintonCore

#if os(iOS)
import UIKit
typealias PlatformImage = UIImage
#elseif os(macOS)
import AppKit
typealias PlatformImage = NSImage
#endif

class VisionProcessor {
    
    // MARK: - Properties
    
    var onRallyDetected: ((AISuggestion) -> Void)?
    
    private var isProcessing = false
    private var frameCount = 0
    private let processingQueue = DispatchQueue(label: "com.badminton.vision", qos: .userInitiated)
    
    // Vision requests
    private lazy var bodyPoseRequest: VNDetectHumanBodyPoseRequest = {
        let request = VNDetectHumanBodyPoseRequest()
        request.revision = VNDetectHumanBodyPoseRequestRevision1
        return request
    }()
    
    // Rally detection state
    private var lastShuttlecockY: CGFloat? = nil
    private var consecutiveDownFrames = 0
    private let downFramesThreshold = 5  // Frames needed to confirm shuttlecock is going down
    
    // MARK: - Public Methods
    
    func startProcessing() {
        isProcessing = true
        frameCount = 0
        resetDetectionState()
    }
    
    func stopProcessing() {
        isProcessing = false
        resetDetectionState()
    }
    
    func processFrame(_ frameData: Data) {
        guard isProcessing else { return }
        
        // Process every 3rd frame to reduce CPU load (20fps effective from 60fps)
        frameCount += 1
        guard frameCount % 3 == 0 else { return }
        
        processingQueue.async { [weak self] in
            self?.analyzeFrame(frameData)
        }
    }
    
    // MARK: - Private Methods
    
    private func analyzeFrame(_ frameData: Data) {
        #if os(iOS)
        guard let image = UIImage(data: frameData),
              let cgImage = image.cgImage else { return }
        #elseif os(macOS)
        guard let image = NSImage(data: frameData),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }
        #endif
        
        // Run vision requests
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([bodyPoseRequest])
            processVisionResults()
        } catch {
            print("Vision error: \(error)")
        }
    }
    
    private func processVisionResults() {
        // Detect players
        guard let observations = bodyPoseRequest.results, !observations.isEmpty else {
            return
        }
        
        // For now, we'll use a simplified rally detection:
        // - Detect if players are in position
        // - Use simple heuristics to determine rally end
        
        // Since we don't have a shuttlecock detection model yet,
        // we'll simulate rally detection based on player movement patterns
        
        // This is a PLACEHOLDER - in production, you would:
        // 1. Use a custom Core ML model to detect shuttlecock
        // 2. Track shuttlecock trajectory
        // 3. Detect when it hits ground or goes out
        
        simulateRallyDetection(playerCount: observations.count)
    }
    
    private func simulateRallyDetection(playerCount: Int) {
        // Simple simulation: randomly detect rally end every 5-10 seconds
        // In production, this would be based on actual shuttlecock tracking
        
        let shouldTrigger = Int.random(in: 0...300) == 0  // ~1% chance per frame
        
        guard shouldTrigger else { return }
        
        // Generate random suggestion
        let winner: Side = Bool.random() ? .A : .B
        let reasons: [EndReason] = [.in, .out, .net]
        let reason = reasons.randomElement() ?? .in
        
        let notes = [
            "Shuttlecock landed near the baseline",
            "Player movement suggests a smash",
            "Shuttlecock trajectory was steep",
            "Player appeared off-balance",
            "Fast net exchange detected"
        ]
        
        let suggestion = AISuggestion(
            winnerSide: winner,
            endReason: reason,
            playerTrackingNote: notes.randomElement(),
            confidence: Double.random(in: 0.6...0.95)
        )
        
        DispatchQueue.main.async { [weak self] in
            self?.onRallyDetected?(suggestion)
        }
        
        resetDetectionState()
    }
    
    private func resetDetectionState() {
        lastShuttlecockY = nil
        consecutiveDownFrames = 0
    }
}

// MARK: - Future Enhancement: Shuttlecock Detection
/*
 To implement actual shuttlecock detection:
 
 1. Train or find a Core ML model for shuttlecock detection
    - Could use YOLOv8 or similar object detection model
    - Train on badminton match footage
    - Export to Core ML format
 
 2. Add Core ML model to project:
    let model = try VNCoreMLModel(for: ShuttlecockDetector().model)
    let request = VNCoreMLRequest(model: model) { request, error in
        guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
        // Process results
    }
 
 3. Track shuttlecock position over frames:
    - Build trajectory
    - Detect downward velocity
    - Identify ground contact
    - Determine in/out based on court boundaries
 
 4. Court detection:
    - Use VNDetectRectanglesRequest to find court lines
    - Establish court boundaries
    - Map shuttlecock position to court coordinates
 */
