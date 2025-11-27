//
//  Models.swift
//  BadmintonCore
//
//  Core data models for badminton match tracking
//

import Foundation

// MARK: - Enumerations

/// Represents which side (A or B) in a badminton match
public enum Side: String, Codable, CaseIterable {
    case A
    case B
    
    /// Get the opposite side
    public var opposite: Side {
        self == .A ? .B : .A
    }
}

/// Reason why a rally ended
public enum EndReason: String, Codable, CaseIterable {
    case `in` = "IN"              // Shuttlecock landed in bounds
    case out = "OUT"              // Shuttlecock landed out of bounds
    case net = "NET"              // Shuttlecock hit the net
    case faultServe = "FAULT_SERVE" // Serve fault
    case `let` = "LET"            // Let (replay the rally)
    case manual = "MANUAL"        // Manually scored
}

/// Which court side the server is serving from
public enum ServingCourt: String, Codable {
    case left = "LEFT"
    case right = "RIGHT"
    
    public var opposite: ServingCourt {
        self == .left ? .right : .left
    }
}

// MARK: - Rally

/// Represents a single rally in a game
public struct Rally: Codable, Identifiable {
    public let id: String
    public let serverSide: Side
    public let winnerSide: Side?
    public let endReason: EndReason?
    public let isManualOverride: Bool
    public let timestamp: Date
    
    public init(
        id: String = UUID().uuidString,
        serverSide: Side,
        winnerSide: Side?,
        endReason: EndReason?,
        isManualOverride: Bool = false,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.serverSide = serverSide
        self.winnerSide = winnerSide
        self.endReason = endReason
        self.isManualOverride = isManualOverride
        self.timestamp = timestamp
    }
}

// MARK: - Game

/// Represents a single game within a match
public struct Game: Codable, Identifiable {
    public var id: String { "game-\(gameIndex)" }
    public let gameIndex: Int
    public var scoreA: Int
    public var scoreB: Int
    public var rallies: [Rally]
    public var winner: Side?
    public var isComplete: Bool
    
    public init(
        gameIndex: Int,
        scoreA: Int = 0,
        scoreB: Int = 0,
        rallies: [Rally] = [],
        winner: Side? = nil,
        isComplete: Bool = false
    ) {
        self.gameIndex = gameIndex
        self.scoreA = scoreA
        self.scoreB = scoreB
        self.rallies = rallies
        self.winner = winner
        self.isComplete = isComplete
    }
}

// MARK: - Match

/// Represents a complete badminton match
public struct Match: Codable, Identifiable {
    public let id: String
    public let playerA: String
    public let playerB: String
    public let bestOf: Int  // 3 or 5
    public var games: [Game]
    public var winner: Side?
    public var isComplete: Bool
    public var server: Side
    public let startTime: Date
    
    public init(
        id: String = UUID().uuidString,
        playerA: String,
        playerB: String,
        bestOf: Int,
        games: [Game] = [],
        winner: Side? = nil,
        isComplete: Bool = false,
        server: Side = .A,
        startTime: Date = Date()
    ) {
        self.id = id
        self.playerA = playerA
        self.playerB = playerB
        self.bestOf = bestOf
        self.games = games.isEmpty ? [Game(gameIndex: 1)] : games
        self.winner = winner
        self.isComplete = isComplete
        self.server = server
        self.startTime = startTime
    }
    
    /// Get the current game
    public var currentGame: Game? {
        games.last
    }
    
    /// Get player name for a side
    public func playerName(for side: Side) -> String {
        side == .A ? playerA : playerB
    }
    
    /// Count games won by each side
    public var gamesWonA: Int {
        games.filter { $0.winner == .A }.count
    }
    
    public var gamesWonB: Int {
        games.filter { $0.winner == .B }.count
    }
}

// MARK: - AI Suggestion

/// AI/ML suggestion for rally outcome
public struct AISuggestion: Codable {
    public let winnerSide: Side
    public let endReason: EndReason
    public let playerTrackingNote: String?
    public let confidence: Double  // 0.0 to 1.0
    
    public init(
        winnerSide: Side,
        endReason: EndReason,
        playerTrackingNote: String? = nil,
        confidence: Double = 0.0
    ) {
        self.winnerSide = winnerSide
        self.endReason = endReason
        self.playerTrackingNote = playerTrackingNote
        self.confidence = confidence
    }
}

// MARK: - Device Role

/// Role of device in distributed system
public enum DeviceRole: String, Codable {
    case camera        // iPhone capturing video
    case processor     // iPad/Mac processing video
    case unknown
}
