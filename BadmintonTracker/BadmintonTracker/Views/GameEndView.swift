//
//  GameEndView.swift
//  BadmintonTracker
//
//  Game completion screen
//

import SwiftUI
import BadmintonCore

struct GameEndView: View {
    @ObservedObject var viewModel: MatchViewModel
    
    private var currentGame: Game? {
        viewModel.match?.currentGame
    }
    
    private var winnerName: String {
        guard let match = viewModel.match, let game = currentGame, let winner = game.winner else {
            return ""
        }
        return match.playerName(for: winner)
    }
    
    var body: some View {
        ZStack {
            Color.darkBg.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Trophy icon
                Image(systemName: "trophy.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.accentYellow)
                
                // Game over text
                VStack(spacing: 12) {
                    Text("Game Over!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("\(winnerName) wins the game!")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                
                // Score
                if let game = currentGame {
                    Text("\(game.scoreA) - \(game.scoreB)")
                        .font(.system(size: 60, weight: .black))
                        .foregroundColor(.accentYellow)
                }
                
                Spacer()
                
                // Next game button
                Button(action: { viewModel.startNextGame() }) {
                    Text("Start Next Game")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brandGreen)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    let viewModel = MatchViewModel()
    var match = Match(playerA: "John", playerB: "Jane", bestOf: 3)
    var game = Game(gameIndex: 1, scoreA: 21, scoreB: 18, winner: .A, isComplete: true)
    match.games = [game]
    viewModel.match = match
    
    return GameEndView(viewModel: viewModel)
}
