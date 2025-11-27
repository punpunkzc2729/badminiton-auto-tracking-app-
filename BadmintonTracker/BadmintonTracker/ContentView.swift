//
//  ContentView.swift
//  BadmintonTracker
//
//  Main view coordinator
//

import SwiftUI

struct ContentView: View {
    @StateObject private var matchViewModel = MatchViewModel()
    
    var body: some View {
        Group {
            if matchViewModel.match == nil {
                MatchSetupView(viewModel: matchViewModel)
            } else if let match = matchViewModel.match {
                if match.isComplete {
                    MatchEndView(viewModel: matchViewModel)
                } else if let currentGame = match.currentGame, currentGame.isComplete {
                    GameEndView(viewModel: matchViewModel)
                } else {
                    MatchView(viewModel: matchViewModel)
                }
            }
        }
        .onAppear {
            matchViewModel.setup()
        }
    }
}

#Preview {
    ContentView()
}
