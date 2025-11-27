//
//  MatchView.swift
//  BadmintonTracker
//
//  Main match view during gameplay
//

import SwiftUI
import BadmintonCore

struct MatchView: View {
    @ObservedObject var viewModel: MatchViewModel
    
    var body: some View {
        ZStack {
            Color.darkBg.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Main content
                ScrollView {
                    VStack(spacing: 24) {
                        // Scoreboard
                        if let match = viewModel.match {
                            ScoreboardView(match: match)
                                .padding(.top, 20)
                        }
                        
                        // Video preview (placeholder)
                        videoPreview
                        
                        // AI Suggestion or Manual Override
                        if let suggestion = viewModel.aiSuggestion {
                            AISuggestionView(
                                suggestion: suggestion,
                                match: viewModel.match!,
                                onConfirm: { viewModel.confirmAISuggestion() },
                                onReject: { viewModel.rejectAISuggestion() }
                            )
                        } else if viewModel.isManualOverride {
                            ManualOverrideView(
                                onSelect: { winner, reason in
                                    viewModel.processRally(winnerSide: winner, endReason: reason, isManual: true)
                                },
                                onCancel: { viewModel.cancelManualOverride() }
                            )
                        }
                    }
                }
                
                // Footer controls
                footerView
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            Text("Badminton Tracker")
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 16) {
                // Camera status
                HStack(spacing: 6) {
                    Circle()
                        .fill(viewModel.isReceivingVideo ? Color.green : Color.gray)
                        .frame(width: 8, height: 8)
                    
                    Text(viewModel.isReceivingVideo ? "Live" : "No Video")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // End match button
                Button(action: { viewModel.endMatch() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color.lightBg)
    }
    
    // MARK: - Video Preview
    
    private var videoPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black)
                .aspectRatio(16/9, contentMode: .fit)
            
            VStack(spacing: 12) {
                Image(systemName: viewModel.isReceivingVideo ? "video.fill" : "video.slash")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                
                Text(viewModel.isReceivingVideo ? "Video Stream" : "Camera Not Active")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Footer
    
    private var footerView: some View {
        VStack(spacing: 12) {
            // Main action button
            if !viewModel.isLoadingAI && viewModel.aiSuggestion == nil && !viewModel.isManualOverride {
                Button(action: { viewModel.startTracking() }) {
                    Label(viewModel.isReceivingVideo ? "Detect Rally End" : "Start Tracking", 
                          systemImage: "play.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentYellow)
                        .foregroundColor(.darkBg)
                        .cornerRadius(12)
                }
            } else if viewModel.isLoadingAI {
                HStack {
                    ProgressView()
                        .tint(.white)
                    Text("Analyzing...")
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            
            // Undo/Redo
            HStack(spacing: 16) {
                Button(action: { viewModel.undo() }) {
                    Label("Undo", systemImage: "arrow.uturn.backward")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .disabled(!viewModel.canUndo)
                .opacity(viewModel.canUndo ? 1.0 : 0.5)
                
                Button(action: { viewModel.redo() }) {
                    Label("Redo", systemImage: "arrow.uturn.forward")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .disabled(!viewModel.canRedo)
                .opacity(viewModel.canRedo ? 1.0 : 0.5)
            }
        }
        .padding()
        .background(Color.lightBg)
    }
}

#Preview {
    let viewModel = MatchViewModel()
    viewModel.match = Match(playerA: "John", playerB: "Jane", bestOf: 3)
    return MatchView(viewModel: viewModel)
}
