//
//  CameraViewModel.swift
//  BadmintonCamera
//
//  ViewModel for camera functionality
//

import SwiftUI
import AVFoundation
import BadmintonCore
import MultipeerConnectivity

@MainActor
class CameraViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isConnected = false
    @Published var isStreaming = false
    @Published var discoveredPeers: [MCPeerID] = []
    @Published var connectionStatus = "Looking for devices..."
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private var cameraManager: CameraManager?
    private var multipeerService: MultipeerService?
    private let deviceName = UIDevice.current.name
    
    // MARK: - Setup
    
    func setup() {
        setupMultipeer()
        requestCameraPermission()
    }
    
    private func setupMultipeer() {
        multipeerService = MultipeerService(displayName: deviceName, role: .camera)
        multipeerService?.delegate = self
        multipeerService?.startAdvertising()
        multipeerService?.startBrowsing()
        connectionStatus = "Advertising as camera..."
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            Task { @MainActor in
                if granted {
                    self?.setupCamera()
                } else {
                    self?.errorMessage = "Camera permission denied"
                }
            }
        }
    }
    
    private func setupCamera() {
        cameraManager = CameraManager()
        cameraManager?.onFrameCaptured = { [weak self] frameData in
            self?.sendFrame(frameData)
        }
    }
    
    // MARK: - Camera Controls
    
    func startStreaming() {
        guard let cameraManager = cameraManager else { return }
        cameraManager.startCapture()
        isStreaming = true
    }
    
    func stopStreaming() {
        guard let cameraManager = cameraManager else { return }
        cameraManager.stopCapture()
        isStreaming = false
    }
    
    // MARK: - Connection
    
    func connectToPeer(_ peerID: MCPeerID) {
        multipeerService?.invitePeer(peerID)
        connectionStatus = "Connecting to \(peerID.displayName)..."
    }
    
    func disconnect() {
        stopStreaming()
        multipeerService?.disconnect()
        isConnected = false
        connectionStatus = "Disconnected"
    }
    
    // MARK: - Streaming
    
    private func sendFrame(_ frameData: Data) {
        guard isConnected, let multipeer = multipeerService else { return }
        
        do {
            try multipeer.sendDataUnreliable(frameData)
        } catch {
            print("Failed to send frame: \(error)")
        }
    }
    
    // MARK: - Preview Layer
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        cameraManager?.previewLayer
    }
}

// MARK: - MultipeerServiceDelegate

extension CameraViewModel: MultipeerServiceDelegate {
    
    func multipeerService(_ service: MultipeerService, didReceiveMessage message: NetworkMessage) {
        // Handle control commands from processing device
        if message.type == .controlCommand {
            do {
                let command = try message.decode(as: ControlCommandPayload.self)
                handleControlCommand(command.command)
            } catch {
                print("Failed to decode command: \(error)")
            }
        }
    }
    
    func multipeerService(_ service: MultipeerService, didConnectToPeer peerID: MCPeerID) {
        isConnected = true
        connectionStatus = "Connected to \(peerID.displayName)"
        
        // Auto-start streaming when connected
        startStreaming()
    }
    
    func multipeerService(_ service: MultipeerService, didDisconnectFromPeer peerID: MCPeerID) {
        isConnected = false
        connectionStatus = "Disconnected from \(peerID.displayName)"
        stopStreaming()
    }
    
    func multipeerService(_ service: MultipeerService, didDiscoverPeer peerID: MCPeerID, withInfo info: [String: String]?) {
        // Only show processor devices
        if let role = info?["role"], role == DeviceRole.processor.rawValue {
            if !discoveredPeers.contains(peerID) {
                discoveredPeers.append(peerID)
            }
        }
    }
    
    private func handleControlCommand(_ command: ControlCommand) {
        switch command {
        case .startTracking:
            startStreaming()
        case .stopTracking, .pauseTracking:
            stopStreaming()
        case .resumeTracking:
            startStreaming()
        default:
            break
        }
    }
}
