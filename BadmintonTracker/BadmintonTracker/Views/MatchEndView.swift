//
//  MatchEndView.swift
//  BadmintonTracker
//
//  Match completion screen
//

import SwiftUI
import BadmintonCore

struct MatchEndView: View {
    @ObservedObject var viewModel: MatchViewModel
    
    private var winnerName: String {
        guard let match = viewModel.match, let winner = match.winner else {
            return ""
        }
        return match.playerName(for: winner)
    }
    
    var body: some View {
        ZStack {
            Color.darkBg.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Trophy icon with animation
                Image(systemName: "trophy.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.accentYellow)
                    .symbolEffect(.bounce)
                
                // Match over text
                VStack(spacing: 12) {
                    Text("Match Over!")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(winnerName) wins the match!")
                        .font(.title)
                        .foregroundColor(.gray)
                }
                
                // Match summary
                if let match = viewModel.match {
                    VStack(spacing: 16) {
                        HStack(spacing: 40) {
                            VStack(spacing: 8) {
                                Text(match.playerA)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("\(match.gamesWonA)")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(match.winner == .A ? .accentYellow : .gray)
                            }
                            
                            Text("-")
                                .font(.title)
                                .foregroundColor(.gray)
                            
                            VStack(spacing: 8) {
                                Text(match.playerB)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("\(match.gamesWonB)")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(match.winner == .B ? .accentYellow : .gray)
                            }
                        }
                        .padding()
                        .background(Color.lightBg)
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
                
                // New match button
                Button(action: { viewModel.startNewMatch() }) {
                    Text("Start New Match")
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
    match.games = [
        Game(gameIndex: 1, scoreA: 21, scoreB: 18, winner: .A, isComplete: true),
        Game(gameIndex: 2, scoreA: 21, scoreB: 19, winner: .A, isComplete: true)
    ]
    match.isComplete = true
    match.winner = .A
    viewModel.match = match
    
    return MatchEndView(viewModel: viewModel)
}
