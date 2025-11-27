//
//  NetworkProtocol.swift
//  BadmintonCore
//
//  Network message protocol for device communication
//

import Foundation

// MARK: - Message Types

/// Types of messages that can be sent between devices
public enum MessageType: String, Codable {
    case videoFrame         // Video frame data
    case rallyDetection     // Rally end detected
    case scoreUpdate        // Score change notification
    case controlCommand     // Control command (start/stop tracking)
    case deviceInfo         // Device information
    case connectionRequest  // Request to connect
    case connectionResponse // Response to connection request
    case ping              // Keep-alive ping
    case pong              // Response to ping
}

// MARK: - Base Message

/// Base message structure
public struct NetworkMessage: Codable {
    public let id: String
    public let type: MessageType
    public let timestamp: Date
    public let payload: Data
    
    public init(id: String = UUID().uuidString, type: MessageType, timestamp: Date = Date(), payload: Data) {
        self.id = id
        self.type = type
        self.timestamp = timestamp
        self.payload = payload
    }
    
    /// Encode a payload object into a message
    public static func create<T: Codable>(type: MessageType, payload: T) throws -> NetworkMessage {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(payload)
        return NetworkMessage(type: type, payload: data)
    }
    
    /// Decode the payload from a message
    public func decode<T: Codable>(as type: T.Type) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(type, from: payload)
    }
}

// MARK: - Specific Message Payloads

/// Video frame payload
public struct VideoFramePayload: Codable {
    public let frameData: Data        // Compressed frame (JPEG or H.264)
    public let frameNumber: Int       // Sequential frame number
    public let timestamp: Double      // Timestamp in seconds
    public let width: Int
    public let height: Int
    
    public init(frameData: Data, frameNumber: Int, timestamp: Double, width: Int, height: Int) {
        self.frameData = frameData
        self.frameNumber = frameNumber
        self.timestamp = timestamp
        self.width = width
        self.height = height
    }
}

/// Rally detection result
public struct RallyDetectionPayload: Codable {
    public let suggestion: AISuggestion
    public let detectionTimestamp: Date
    
    public init(suggestion: AISuggestion, detectionTimestamp: Date = Date()) {
        self.suggestion = suggestion
        self.detectionTimestamp = detectionTimestamp
    }
}

/// Score update notification
public struct ScoreUpdatePayload: Codable {
    public let scoreA: Int
    public let scoreB: Int
    public let gameIndex: Int
    public let server: Side
    public let rally: Rally?
    
    public init(scoreA: Int, scoreB: Int, gameIndex: Int, server: Side, rally: Rally? = nil) {
        self.scoreA = scoreA
        self.scoreB = scoreB
        self.gameIndex = gameIndex
        self.server = server
        self.rally = rally
    }
}

/// Control command
public enum ControlCommand: String, Codable {
    case startTracking
    case stopTracking
    case startMatch
    case endMatch
    case pauseTracking
    case resumeTracking
}

public struct ControlCommandPayload: Codable {
    public let command: ControlCommand
    public let parameters: [String: String]?
    
    public init(command: ControlCommand, parameters: [String: String]? = nil) {
        self.command = command
        self.parameters = parameters
    }
}

/// Device information
public struct DeviceInfoPayload: Codable {
    public let deviceId: String
    public let deviceName: String
    public let role: DeviceRole
    public let capabilities: [String]  // e.g., ["camera", "4k", "60fps"]
    
    public init(deviceId: String, deviceName: String, role: DeviceRole, capabilities: [String] = []) {
        self.deviceId = deviceId
        self.deviceName = deviceName
        self.role = role
        self.capabilities = capabilities
    }
}

/// Connection request
public struct ConnectionRequestPayload: Codable {
    public let deviceInfo: DeviceInfoPayload
    public let requestedRole: DeviceRole
    
    public init(deviceInfo: DeviceInfoPayload, requestedRole: DeviceRole) {
        self.deviceInfo = deviceInfo
        self.requestedRole = requestedRole
    }
}

/// Connection response
public struct ConnectionResponsePayload: Codable {
    public let accepted: Bool
    public let reason: String?
    public let deviceInfo: DeviceInfoPayload?
    
    public init(accepted: Bool, reason: String? = nil, deviceInfo: DeviceInfoPayload? = nil) {
        self.accepted = accepted
        self.reason = reason
        self.deviceInfo = deviceInfo
    }
}
