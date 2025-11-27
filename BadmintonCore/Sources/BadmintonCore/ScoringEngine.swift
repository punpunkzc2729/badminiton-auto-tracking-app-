//
//  ScoringEngine.swift
//  BadmintonCore
//
//  Badminton scoring rules and game logic
//

import Foundation

public struct ScoringEngine {
    
    // MARK: - Constants
    
    private static let targetScore = 21
    private static let maxScore = 30
    
    // MARK: - Serving Court
    
    /// Determine which court the server should serve from based on their score
    /// - Parameter score: Current score of the server
    /// - Returns: The serving court (left or right)
    public static func getServingCourt(forScore score: Int) -> ServingCourt {
        // If score is even, serve from right court
        // If score is odd, serve from left court
        score % 2 == 0 ? .right : .left
    }
    
    // MARK: - Game Status
    
    /// Check if a game is over based on the current scores
    /// - Parameters:
    ///   - scoreA: Score for side A
    ///   - scoreB: Score for side B
    /// - Returns: True if the game is over, false otherwise
    public static func isGameOver(scoreA: Int, scoreB: Int) -> Bool {
        // Max score scenario (30-29 or 29-30)
        if scoreA >= maxScore || scoreB >= maxScore {
            return (scoreA == maxScore && scoreB == maxScore - 1) ||
                   (scoreB == maxScore && scoreA == maxScore - 1)
        }
        
        // Normal win condition: reach 21+ with 2-point lead
        if scoreA >= targetScore || scoreB >= targetScore {
            return abs(scoreA - scoreB) >= 2
        }
        
        return false
    }
    
    /// Get the winner of a game
    /// - Parameters:
    ///   - scoreA: Score for side A
    ///   - scoreB: Score for side B
    /// - Returns: The winning side, or nil if game is not over
    public static func getGameWinner(scoreA: Int, scoreB: Int) -> Side? {
        guard isGameOver(scoreA: scoreA, scoreB: scoreB) else {
            return nil
        }
        return scoreA > scoreB ? .A : .B
    }
    
    // MARK: - Match Status
    
    /// Check if a match is over
    /// - Parameters:
    ///   - games: Array of completed and in-progress games
    ///   - bestOf: Best of X games (3 or 5)
    /// - Returns: True if match is over, false otherwise
    public static func isMatchOver(games: [Game], bestOf: Int) -> Bool {
        let winsA = games.filter { $0.winner == .A }.count
        let winsB = games.filter { $0.winner == .B }.count
        let targetWins = (bestOf + 1) / 2  // Best of 3 → 2 wins, Best of 5 → 3 wins
        
        return winsA >= targetWins || winsB >= targetWins
    }
    
    /// Get the winner of a match
    /// - Parameters:
    ///   - games: Array of completed and in-progress games
    ///   - bestOf: Best of X games (3 or 5)
    /// - Returns: The winning side, or nil if match is not over
    public static func getMatchWinner(games: [Game], bestOf: Int) -> Side? {
        guard isMatchOver(games: games, bestOf: bestOf) else {
            return nil
        }
        
        let winsA = games.filter { $0.winner == .A }.count
        let winsB = games.filter { $0.winner == .B }.count
        
        return winsA > winsB ? .A : .B
    }
    
    // MARK: - Score Processing
    
    /// Process a rally result and update the game
    /// - Parameters:
    ///   - game: Current game state
    ///   - rally: The rally to process
    /// - Returns: Updated game with new score and rally added
    public static func processRally(_ game: Game, rally: Rally) -> Game {
        var updatedGame = game
        
        // Add rally to history
        updatedGame.rallies.append(rally)
        
        // If it's a LET, don't change the score
        guard rally.endReason != .let, let winner = rally.winnerSide else {
            return updatedGame
        }
        
        // Update score
        if winner == .A {
            updatedGame.scoreA += 1
        } else {
            updatedGame.scoreB += 1
        }
        
        // Check if game is complete
        if isGameOver(scoreA: updatedGame.scoreA, scoreB: updatedGame.scoreB) {
            updatedGame.isComplete = true
            updatedGame.winner = getGameWinner(scoreA: updatedGame.scoreA, scoreB: updatedGame.scoreB)
        }
        
        return updatedGame
    }
    
    /// Create the next game in a match
    /// - Parameter currentGameIndex: Index of current game
    /// - Returns: A new game with the next index
    public static func createNextGame(after currentGameIndex: Int) -> Game {
        Game(gameIndex: currentGameIndex + 1)
    }
}
