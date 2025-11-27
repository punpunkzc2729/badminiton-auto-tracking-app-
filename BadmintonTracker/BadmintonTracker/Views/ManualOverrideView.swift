//
//  ManualOverrideView.swift
//  BadmintonTracker
//
//  Manual score entry interface
//

import SwiftUI
import BadmintonCore

struct ManualOverrideView: View {
    let onSelect: (Side, EndReason) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "hand.tap")
                    .foregroundColor(.red)
                
                Text("Manual Override")
                    .font(.headline)
                    .foregroundColor(.red)
                
                Spacer()
            }
            
            // Winner buttons
            VStack(spacing: 12) {
                Text("Award point to:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 12) {
                    Button(action: { onSelect(.A, .manual) }) {
                        Text("Point A")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.brandBlue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    Button(action: { onSelect(.B, .manual) }) {
                        Text("Point B")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.brandBlue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            
            // LET button
            Button(action: { onSelect(.A, .let) }) {
                Text("LET (Replay)")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            // Cancel
            Button(action: onCancel) {
                Text("Cancel")
                    .font(.callout)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.lightBg)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red, lineWidth: 2)
        )
        .padding(.horizontal)
    }
}

#Preview {
    ManualOverrideView(
        onSelect: { _, _ in },
        onCancel: {}
    )
    .background(Color.darkBg)
}
