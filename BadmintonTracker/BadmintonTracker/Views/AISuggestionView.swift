//
//  AISuggestionView.swift
//  BadmintonTracker
//
//  AI suggestion display with confirm/reject buttons
//

import SwiftUI
import BadmintonCore

struct AISuggestionView: View {
    let suggestion: AISuggestion
    let match: Match
    let onConfirm: () -> Void
    let onReject: () -> Void
    
    private var winnerName: String {
        match.playerName(for: suggestion.winnerSide)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: "brain")
                    .foregroundColor(.brandGreen)
                
                Text("AI Suggestion")
                    .font(.headline)
                    .foregroundColor(.brandGreen)
                
                Spacer()
                
                // Confidence badge
                Text("\(Int(suggestion.confidence * 100))%")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.brandBlue.opacity(0.2))
                    .foregroundColor(.brandBlue)
                    .cornerRadius(4)
            }
            
            // Suggestion content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Point to")
                        .foregroundColor(.white)
                    Text(winnerName)
                        .fontWeight(.bold)
                        .foregroundColor(.accentYellow)
                }
                .font(.title3)
                
                HStack {
                    Text("Reason:")
                        .foregroundColor(.gray)
                    Text(suggestion.endReason.rawValue)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .font(.callout)
                
                if let note = suggestion.playerTrackingNote {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.brandBlue)
                            .imageScale(.small)
                        
                        Text(note)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 4)
                }
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: onConfirm) {
                    Label("Confirm", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: onReject) {
                    Label("Reject", systemImage: "xmark.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.lightBg)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.brandGreen, lineWidth: 2)
        )
        .padding(.horizontal)
    }
}

#Preview {
    let match = Match(playerA: "John", playerB: "Jane", bestOf: 3)
    let suggestion = AISuggestion(
        winnerSide: .A,
        endReason: .in,
        playerTrackingNote: "Player B was out of position on the backhand side",
        confidence: 0.85
    )
    
    return AISuggestionView(
        suggestion: suggestion,
        match: match,
        onConfirm: {},
        onReject: {}
    )
    .background(Color.darkBg)
}
