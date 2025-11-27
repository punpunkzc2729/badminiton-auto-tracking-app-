//
//  MatchViewModel.swift
//  BadmintonTracker
//
//  Main ViewModel for match state management
//

import SwiftUI
import BadmintonCore
import MultipeerConnectivity

@MainActor
class MatchViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var match: Match?
    @Published var aiSuggestion: AISuggestion?
    @Published var isLoadingAI = false
    @Published var isManualOverride = false
    @Published var errorMessage: String?
    
    // Connection to camera
    @Published var isConnectedToCamera = false
    @Published var discoveredCameras: [MCPeerID] = []
    @Published var connectionStatus = "Not connected"
    @Published var isReceivingVideo = false
    
    // History for undo/redo
    private var history: [Match] = []
    private var redoStack: [Match] = []
    
    private var multipeerService: MultipeerService?
    private var visionProcessor: VisionProcessor?
    
    private let deviceName = {
        #if os(macOS)
        return Host.current().localizedName ?? "Mac"
        #else
        return UIDevice.current.name
        #endif
    }()
    
    // MARK: - Setup
    
    func setup() {
        setupMultipeer()
        setupVisionProcessor()
    }
    
    private func setupMultipeer() {
        multipeerService = MultipeerService(displayName: deviceName, role: .processor)
        multipeerService?.delegate = self
        multipeerService?.startAdvertising()
        multipeerService?.startBrowsing()
    }
    
    private func setupVisionProcessor() {
        visionProcessor = VisionProcessor()
        visionProcessor?.onRallyDetected = { [weak self] suggestion in
            Task { @MainActor in
                self?.handleAISuggestion(suggestion)
            }
        }
    }
    
    // MARK: - Match Control
    
    func startMatch(playerA: String, playerB: String, bestOf: Int) {
        let newMatch = Match(
            playerA: playerA,
            playerB: playerB,
            bestOf: bestOf,
            server: .A
        )
        
        match = newMatch
        history = []
        redoStack = []
        
        // Send start signal to camera
        sendControlCommand(.startMatch)
    }
    
    func endMatch() {
        sendControlCommand(.endMatch)
        match = nil
        history = []
        redoStack = []
    }
    
    func startNewMatch() {
        endMatch()
    }
    
    func startNextGame() {
        guard var match = match, let currentGame = match.currentGame else { return }
        
        let nextGame = ScoringEngine.createNextGame(after: currentGame.gameIndex)
        
        // Save current state
        saveToHistory()
        
        // Alternate server for next game
        match.server = match.server.opposite
        match.games.append(nextGame)
        
        self.match = match
    }
    
    // MARK: - Rally Processing
    
    func processRally(winnerSide: Side, endReason: EndReason, isManual: Bool) {
        guard var match = match, let currentGame = match.currentGame else { return }
        
        let rally = Rally(
            serverSide: match.server,
            winnerSide: winnerSide,
            endReason: endReason,
            isManualOverride: isManual
        )
        
        // Save current state for undo
        saveToHistory()
        
        // Process rally
        let updatedGame = ScoringEngine.processRally(currentGame, rally: rally)
        
        // Update games array
        match.games[match.games.count - 1] = updatedGame
        
        // Update server (winner of rally serves next)
        if endReason != .let {
            match.server = winnerSide
        }
        
        // Check if match is complete
        if ScoringEngine.isMatchOver(games: match.games, bestOf: match.bestOf) {
            match.isComplete = true
            match.winner = ScoringEngine.getMatchWinner(games: match.games, bestOf: match.bestOf)
        }
        
        self.match = match
        
        // Clear AI suggestion
        aiSuggestion = nil
        isManualOverride = false
        
        // Send score update to camera
        sendScoreUpdate()
    }
    
    private func handleAISuggestion(_ suggestion: AISuggestion) {
        aiSuggestion = suggestion
        isLoadingAI = false
    }
    
    func confirmAISuggestion() {
        guard let suggestion = aiSuggestion else { return }
        processRally(winnerSide: suggestion.winnerSide, endReason: suggestion.endReason, isManual: false)
    }
    
    func rejectAISuggestion() {
        aiSuggestion = nil
        isManualOverride = true
    }
    
    func cancelManualOverride() {
        isManualOverride = false
    }
    
    // MARK: - Undo/Redo
    
    var canUndo: Bool {
        !history.isEmpty
    }
    
    var canRedo: Bool {
        !redoStack.isEmpty
    }
    
    func undo() {
        guard let lastMatch = history.popLast() else { return }
        
        if let currentMatch = match {
            redoStack.append(currentMatch)
        }
        
        match = lastMatch
        aiSuggestion = nil
        isManualOverride = false
    }
    
    func redo() {
        guard let nextMatch = redoStack.popLast() else { return }
        
        if let currentMatch = match {
            history.append(currentMatch)
        }
        
        match = nextMatch
    }
    
    private func saveToHistory() {
        if let currentMatch = match {
            history.append(currentMatch)
            redoStack.removeAll()  // Clear redo stack on new action
        }
    }
    
    // MARK: - Camera Connection
    
    func connectToCamera(_ peerID: MCPeerID) {
        multipeerService?.invitePeer(peerID)
        connectionStatus = "Connecting..."
    }
    
    func disconnectCamera() {
        multipeerService?.disconnect()
        isConnectedToCamera = false
        isReceivingVideo = false
        connectionStatus = "Disconnected"
    }
    
    // MARK: - Video Processing
    
    func startTracking() {
        sendControlCommand(.startTracking)
        visionProcessor?.startProcessing()
    }
    
    func stopTracking() {
        sendControlCommand(.stopTracking)
        visionProcessor?.stopProcessing()
    }
    
    func processVideoFrame(_ frameData: Data) {
        isReceivingVideo = true
        visionProcessor?.processFrame(frameData)
    }
    
    // MARK: - Network Communication
    
    private func sendControlCommand(_ command: ControlCommand) {
        guard let multipeer = multipeerService else { return }
        
        do {
            let payload = ControlCommandPayload(command: command)
            let message = try NetworkMessage.create(type: .controlCommand, payload: payload)
            try multipeer.sendMessage(message)
        } catch {
            print("Failed to send control command: \(error)")
        }
    }
    
    private func sendScoreUpdate() {
        guard let match = match, let currentGame = match.currentGame else { return }
        guard let multipeer = multipeerService else { return }
        
        do {
            let payload = ScoreUpdatePayload(
                scoreA: currentGame.scoreA,
                scoreB: currentGame.scoreB,
                gameIndex: currentGame.gameIndex,
                server: match.server,
                rally: currentGame.rallies.last
            )
            let message = try NetworkMessage.create(type: .scoreUpdate, payload: payload)
            try multipeer.sendMessage(message)
        } catch {
            print("Failed to send score update: \(error)")
        }
    }
}

// MARK: - MultipeerServiceDelegate

extension MatchViewModel: MultipeerServiceDelegate {
    
    func multipeerService(_ service: MultipeerService, didReceiveMessage message: NetworkMessage) {
        switch message.type {
        case .videoFrame:
            // Handle video frame
            if let payload = try? message.decode(as: VideoFramePayload.self) {
                processVideoFrame(payload.frameData)
            }
            
        case .rallyDetection:
            // Handle rally detection from camera (if camera has detection capability)
            if let payload = try? message.decode(as: RallyDetectionPayload.self) {
                handleAISuggestion(payload.suggestion)
            }
            
        default:
            break
        }
    }
    
    func multipeerService(_ service: MultipeerService, didConnectToPeer peerID: MCPeerID) {
        isConnectedToCamera = true
        connectionStatus = "Connected to \(peerID.displayName)"
    }
    
    func multipeerService(_ service: MultipeerService, didDisconnectFromPeer peerID: MCPeerID) {
        isConnectedToCamera = false
        isReceivingVideo = false
        connectionStatus = "Disconnected"
    }
    
    func multipeerService(_ service: MultipeerService, didDiscoverPeer peerID: MCPeerID, withInfo info: [String: String]?) {
        // Only show camera devices
        if let role = info?["role"], role == DeviceRole.camera.rawValue {
            if !discoveredCameras.contains(peerID) {
                discoveredCameras.append(peerID)
            }
        }
    }
}
