//
//  ScoreboardView.swift
//  BadmintonTracker
//
//  Scoreboard display
//

import SwiftUI
import BadmintonCore

struct ScoreboardView: View {
    let match: Match
    
    private var currentGame: Game? {
        match.currentGame
    }
    
    private var servingCourt: ServingCourt {
        guard let game = currentGame else { return .right }
        let serverScore = match.server == .A ? game.scoreA : game.scoreB
        return ScoringEngine.getServingCourt(forScore: serverScore)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Player A
                PlayerScoreCard(
                    name: match.playerA,
                    score: currentGame?.scoreA ?? 0,
                    gamesWon: match.gamesWonA,
                    isServing: match.server == .A,
                    servingCourt: servingCourt,
                    side: .A
                )
                
                // VS
                Text("VS")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .frame(width: 60)
                
                // Player B
                PlayerScoreCard(
                    name: match.playerB,
                    score: currentGame?.scoreB ?? 0,
                    gamesWon: match.gamesWonB,
                    isServing: match.server == .B,
                    servingCourt: servingCourt,
                    side: .B
                )
            }
            
            // Match info
            Text("Game \(currentGame?.gameIndex ?? 1) | Best of \(match.bestOf)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

// MARK: - Player Score Card

struct PlayerScoreCard: View {
    let name: String
    let score: Int
    let gamesWon: Int
    let isServing: Bool
    let servingCourt: ServingCourt
    let side: Side
    
    var body: some View {
        VStack(spacing: 12) {
            // Serving court indicator
            if isServing {
                HStack(spacing: 8) {
                    ServingCourtIndicator(court: .left, isActive: servingCourt == .left)
                    ServingCourtIndicator(court: .right, isActive: servingCourt == .right)
                }
            } else {
                Color.clear.frame(height: 32)
            }
            
            // Player name
            Text(name)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            // Score
            Text("\(score)")
                .font(.system(size: 72, weight: .black))
                .foregroundColor(.accentYellow)
            
            // Games won + serving indicator
            HStack(spacing: 6) {
                Text("Games: \(gamesWon)")
                    .font(.callout)
                    .foregroundColor(.gray)
                
                if isServing {
                    Image(systemName: "figure.badminton")
                        .foregroundColor(.brandGreen)
                        .imageScale(.small)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.lightBg)
        .cornerRadius(12)
    }
}

// MARK: - Serving Court Indicator

struct ServingCourtIndicator: View {
    let court: ServingCourt
    let isActive: Bool
    
    var body: some View {
        Text(court == .left ? "L" : "R")
            .font(.caption)
            .fontWeight(.bold)
            .frame(width: 28, height: 28)
            .background(isActive ? Color.brandBlue : Color.clear)
            .foregroundColor(isActive ? .white : .gray)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.gray, lineWidth: 1)
            )
    }
}

#Preview {
    let match = Match(
        playerA: "Player A",
        playerB: "Player B",
        bestOf: 3,
        games: [Game(gameIndex: 1, scoreA: 15, scoreB: 12)],
        server: .A
    )
    
    return ScoreboardView(match: match)
        .background(Color.darkBg)
}
