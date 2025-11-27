//
//  MultipeerService.swift
//  BadmintonCore
//
//  Multipeer Connectivity wrapper for device communication
//

import Foundation
import MultipeerConnectivity

/// Delegate protocol for multipeer events
public protocol MultipeerServiceDelegate: AnyObject {
    func multipeerService(_ service: MultipeerService, didReceiveMessage message: NetworkMessage)
    func multipeerService(_ service: MultipeerService, didConnectToPeer peerID: MCPeerID)
    func multipeerService(_ service: MultipeerService, didDisconnectFromPeer peerID: MCPeerID)
    func multipeerService(_ service: MultipeerService, didDiscoverPeer peerID: MCPeerID, withInfo info: [String: String]?)
}

/// Multipeer Connectivity service for peer-to-peer communication
public class MultipeerService: NSObject {
    
    // MARK: - Properties
    
    public weak var delegate: MultipeerServiceDelegate?
    
    private let serviceType = "badminton-track"
    private let myPeerID: MCPeerID
    private let session: MCSession
    private let advertiser: MCNearbyServiceAdvertiser
    private let browser: MCNearbyServiceBrowser
    
    private let role: DeviceRole
    private var discoveredPeers: [MCPeerID] = []
    
    public var isAdvertising: Bool {
        advertiserStarted
    }
    
    public var isBrowsing: Bool {
        browserStarted
    }
    
    public var connectedPeers: [MCPeerID] {
        session.connectedPeers
    }
    
    private var advertiserStarted = false
    private var browserStarted = false
    
    // MARK: - Initialization
    
    public init(displayName: String, role: DeviceRole) {
        self.role = role
        self.myPeerID = MCPeerID(displayName: displayName)
        
        self.session = MCSession(
            peer: myPeerID,
            securityIdentity: nil,
            encryptionPreference: .none  // For better performance, encryption can be added if needed
        )
        
        let discoveryInfo = ["role": role.rawValue]
        
        self.advertiser = MCNearbyServiceAdvertiser(
            peer: myPeerID,
            discoveryInfo: discoveryInfo,
            serviceType: serviceType
        )
        
        self.browser = MCNearbyServiceBrowser(
            peer: myPeerID,
            serviceType: serviceType
        )
        
        super.init()
        
        session.delegate = self
        advertiser.delegate = self
        browser.delegate = self
    }
    
    deinit {
        stopAdvertising()
        stopBrowsing()
        session.disconnect()
    }
    
    // MARK: - Public Methods
    
    /// Start advertising this device
    public func startAdvertising() {
        guard !advertiserStarted else { return }
        advertiser.startAdvertisingPeer()
        advertiserStarted = true
    }
    
    /// Stop advertising this device
    public func stopAdvertising() {
        guard advertiserStarted else { return }
        advertiser.stopAdvertisingPeer()
        advertiserStarted = false
    }
    
    /// Start browsing for peers
    public func startBrowsing() {
        guard !browserStarted else { return }
        browser.startBrowsingForPeers()
        browserStarted = true
    }
    
    /// Stop browsing for peers
    public func stopBrowsing() {
        guard browserStarted else { return }
        browser.stopBrowsingForPeers()
        browserStarted = false
    }
    
    /// Invite a peer to connect
    public func invitePeer(_ peerID: MCPeerID, timeout: TimeInterval = 30) {
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: timeout)
    }
    
    /// Send a message to all connected peers
    public func sendMessage(_ message: NetworkMessage) throws {
        guard !connectedPeers.isEmpty else {
            throw MultipeerError.noPeersConnected
        }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(message)
        
        try session.send(data, toPeers: connectedPeers, with: .reliable)
    }
    
    /// Send a message to specific peer
    public func sendMessage(_ message: NetworkMessage, to peerID: MCPeerID) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(message)
        
        try session.send(data, toPeers: [peerID], with: .reliable)
    }
    
    /// Send data unreliably (for video streaming)
    public func sendDataUnreliable(_ data: Data, to peers: [MCPeerID]? = nil) throws {
        let targetPeers = peers ?? connectedPeers
        guard !targetPeers.isEmpty else {
            throw MultipeerError.noPeersConnected
        }
        try session.send(data, toPeers: targetPeers, with: .unreliable)
    }
    
    /// Disconnect from all peers
    public func disconnect() {
        session.disconnect()
    }
}

// MARK: - MCSessionDelegate

extension MultipeerService: MCSessionDelegate {
    
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch state {
            case .connected:
                self.delegate?.multipeerService(self, didConnectToPeer: peerID)
            case .notConnected:
                self.delegate?.multipeerService(self, didDisconnectFromPeer: peerID)
            case .connecting:
                break
            @unknown default:
                break
            }
        }
    }
    
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let message = try decoder.decode(NetworkMessage.self, from: data)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.multipeerService(self, didReceiveMessage: message)
            }
        } catch {
            print("Failed to decode message: \(error)")
        }
    }
    
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Not used for now
    }
    
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Not used for now
    }
    
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // Not used for now
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension MultipeerService: MCNearbyServiceAdvertiserDelegate {
    
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Auto-accept invitations
        invitationHandler(true, session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension MultipeerService: MCNearbyServiceBrowserDelegate {
    
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if !self.discoveredPeers.contains(peerID) {
                self.discoveredPeers.append(peerID)
            }
            self.delegate?.multipeerService(self, didDiscoverPeer: peerID, withInfo: info)
        }
    }
    
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            self?.discoveredPeers.removeAll { $0 == peerID }
        }
    }
}

// MARK: - Errors

public enum MultipeerError: Error {
    case noPeersConnected
    case encodingFailed
    case sendFailed
}
