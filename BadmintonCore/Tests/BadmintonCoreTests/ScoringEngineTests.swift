import XCTest
@testable import BadmintonCore

final class ScoringEngineTests: XCTestCase {
    
    // MARK: - Serving Court Tests
    
    func testServingCourtEvenScore() {
        XCTAssertEqual(ScoringEngine.getServingCourt(forScore: 0), .right)
        XCTAssertEqual(ScoringEngine.getServingCourt(forScore: 2), .right)
        XCTAssertEqual(ScoringEngine.getServingCourt(forScore: 20), .right)
    }
    
    func testServingCourtOddScore() {
        XCTAssertEqual(ScoringEngine.getServingCourt(forScore: 1), .left)
        XCTAssertEqual(ScoringEngine.getServingCourt(forScore: 3), .left)
        XCTAssertEqual(ScoringEngine.getServingCourt(forScore: 19), .left)
    }
    
    // MARK: - Game Over Tests
    
    func testGameNotOver() {
        XCTAssertFalse(ScoringEngine.isGameOver(scoreA: 0, scoreB: 0))
        XCTAssertFalse(ScoringEngine.isGameOver(scoreA: 10, scoreB: 10))
        XCTAssertFalse(ScoringEngine.isGameOver(scoreA: 20, scoreB: 19))
    }
    
    func testGameOverStandardWin() {
        // 21-19: 2-point lead at 21
        XCTAssertTrue(ScoringEngine.isGameOver(scoreA: 21, scoreB: 19))
        XCTAssertTrue(ScoringEngine.isGameOver(scoreA: 19, scoreB: 21))
        
        // 21-18: more than 2-point lead
        XCTAssertTrue(ScoringEngine.isGameOver(scoreA: 21, scoreB: 18))
    }
    
    func testGameNotOverDeuceScenario() {
        // 21-20: Not enough lead
        XCTAssertFalse(ScoringEngine.isGameOver(scoreA: 21, scoreB: 20))
        XCTAssertFalse(ScoringEngine.isGameOver(scoreA: 20, scoreB: 21))
    }
    
    func testGameOverAfterDeuce() {
        // 22-20: 2-point lead after deuce
        XCTAssertTrue(ScoringEngine.isGameOver(scoreA: 22, scoreB: 20))
        XCTAssertTrue(ScoringEngine.isGameOver(scoreA: 25, scoreB: 23))
    }
    
    func testGameOverMaxScore() {
        // 30-29: Max score reached
        XCTAssertTrue(ScoringEngine.isGameOver(scoreA: 30, scoreB: 29))
        XCTAssertTrue(ScoringEngine.isGameOver(scoreA: 29, scoreB: 30))
    }
    
    func testGameNotOverMaxScoreNotReached() {
        // 30-30 or other scenarios
        XCTAssertFalse(ScoringEngine.isGameOver(scoreA: 30, scoreB: 30))
        XCTAssertFalse(ScoringEngine.isGameOver(scoreA: 29, scoreB: 29))
    }
    
    // MARK: - Game Winner Tests
    
    func testGameWinnerNone() {
        XCTAssertNil(ScoringEngine.getGameWinner(scoreA: 20, scoreB: 20))
        XCTAssertNil(ScoringEngine.getGameWinner(scoreA: 21, scoreB: 20))
    }
    
    func testGameWinnerSideA() {
        XCTAssertEqual(ScoringEngine.getGameWinner(scoreA: 21, scoreB: 19), .A)
        XCTAssertEqual(ScoringEngine.getGameWinner(scoreA: 30, scoreB: 29), .A)
    }
    
    func testGameWinnerSideB() {
        XCTAssertEqual(ScoringEngine.getGameWinner(scoreA: 19, scoreB: 21), .B)
        XCTAssertEqual(ScoringEngine.getGameWinner(scoreA: 29, scoreB: 30), .B)
    }
    
    // MARK: - Match Over Tests
    
    func testMatchNotOverBestOf3() {
        let games = [
            Game(gameIndex: 1, scoreA: 21, scoreB: 19, winner: .A, isComplete: true)
        ]
        XCTAssertFalse(ScoringEngine.isMatchOver(games: games, bestOf: 3))
    }
    
    func testMatchOverBestOf3() {
        let games = [
            Game(gameIndex: 1, scoreA: 21, scoreB: 19, winner: .A, isComplete: true),
            Game(gameIndex: 2, scoreA: 21, scoreB: 18, winner: .A, isComplete: true)
        ]
        XCTAssertTrue(ScoringEngine.isMatchOver(games: games, bestOf: 3))
    }
    
    func testMatchNotOverBestOf5() {
        let games = [
            Game(gameIndex: 1, scoreA: 21, scoreB: 19, winner: .A, isComplete: true),
            Game(gameIndex: 2, scoreA: 19, scoreB: 21, winner: .B, isComplete: true)
        ]
        XCTAssertFalse(ScoringEngine.isMatchOver(games: games, bestOf: 5))
    }
    
    func testMatchOverBestOf5() {
        let games = [
            Game(gameIndex: 1, scoreA: 21, scoreB: 19, winner: .A, isComplete: true),
            Game(gameIndex: 2, scoreA: 19, scoreB: 21, winner: .B, isComplete: true),
            Game(gameIndex: 3, scoreA: 21, scoreB: 18, winner: .A, isComplete: true),
            Game(gameIndex: 4, scoreA: 21, scoreB: 16, winner: .A, isComplete: true)
        ]
        XCTAssertTrue(ScoringEngine.isMatchOver(games: games, bestOf: 5))
    }
    
    // MARK: - Match Winner Tests
    
    func testMatchWinnerNone() {
        let games = [
            Game(gameIndex: 1, scoreA: 21, scoreB: 19, winner: .A, isComplete: true)
        ]
        XCTAssertNil(ScoringEngine.getMatchWinner(games: games, bestOf: 3))
    }
    
    func testMatchWinnerSideA() {
        let games = [
            Game(gameIndex: 1, scoreA: 21, scoreB: 19, winner: .A, isComplete: true),
            Game(gameIndex: 2, scoreA: 21, scoreB: 18, winner: .A, isComplete: true)
        ]
        XCTAssertEqual(ScoringEngine.getMatchWinner(games: games, bestOf: 3), .A)
    }
    
    func testMatchWinnerSideB() {
        let games = [
            Game(gameIndex: 1, scoreA: 21, scoreB: 19, winner: .A, isComplete: true),
            Game(gameIndex: 2, scoreA: 19, scoreB: 21, winner: .B, isComplete: true),
            Game(gameIndex: 3, scoreA: 18, scoreB: 21, winner: .B, isComplete: true)
        ]
        XCTAssertEqual(ScoringEngine.getMatchWinner(games: games, bestOf: 3), .B)
    }
    
    // MARK: - Rally Processing Tests
    
    func testProcessRallyNormalPoint() {
        let game = Game(gameIndex: 1, scoreA: 10, scoreB: 10)
        let rally = Rally(serverSide: .A, winnerSide: .A, endReason: .in)
        
        let updated = ScoringEngine.processRally(game, rally: rally)
        
        XCTAssertEqual(updated.scoreA, 11)
        XCTAssertEqual(updated.scoreB, 10)
        XCTAssertEqual(updated.rallies.count, 1)
        XCTAssertFalse(updated.isComplete)
    }
    
    func testProcessRallyLet() {
        let game = Game(gameIndex: 1, scoreA: 10, scoreB: 10)
        let rally = Rally(serverSide: .A, winnerSide: nil, endReason: .let)
        
        let updated = ScoringEngine.processRally(game, rally: rally)
        
        XCTAssertEqual(updated.scoreA, 10)  // No score change
        XCTAssertEqual(updated.scoreB, 10)
        XCTAssertEqual(updated.rallies.count, 1)
        XCTAssertFalse(updated.isComplete)
    }
    
    func testProcessRallyGameWin() {
        let game = Game(gameIndex: 1, scoreA: 20, scoreB: 19)
        let rally = Rally(serverSide: .A, winnerSide: .A, endReason: .in)
        
        let updated = ScoringEngine.processRally(game, rally: rally)
        
        XCTAssertEqual(updated.scoreA, 21)
        XCTAssertEqual(updated.scoreB, 19)
        XCTAssertTrue(updated.isComplete)
        XCTAssertEqual(updated.winner, .A)
    }
    
    // MARK: - Next Game Tests
    
    func testCreateNextGame() {
        let nextGame = ScoringEngine.createNextGame(after: 1)
        
        XCTAssertEqual(nextGame.gameIndex, 2)
        XCTAssertEqual(nextGame.scoreA, 0)
        XCTAssertEqual(nextGame.scoreB, 0)
        XCTAssertTrue(nextGame.rallies.isEmpty)
        XCTAssertNil(nextGame.winner)
        XCTAssertFalse(nextGame.isComplete)
    }
}
