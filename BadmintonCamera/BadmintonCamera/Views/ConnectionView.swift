//
//  ConnectionView.swift
//  BadmintonCamera
//
//  View for connecting to processing device
//

import SwiftUI
import MultipeerConnectivity

struct ConnectionView: View {
    @ObservedObject var viewModel: CameraViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            Image(systemName: "video.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                Text("Badminton Camera")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Waiting for connection...")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            
            // Status
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    
                    Text(viewModel.connectionStatus)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
            }
            
            Spacer()
            
            // Discovered devices
            if !viewModel.discoveredPeers.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Available Devices")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    ForEach(viewModel.discoveredPeers, id: \.self) { peer in
                        Button(action: {
                            viewModel.connectToPeer(peer)
                        }) {
                            HStack {
                                Image(systemName: "ipad.and.iphone")
                                    .foregroundColor(.blue)
                                
                                Text(peer.displayName)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            Spacer()
            
            // Info text
            VStack(spacing: 8) {
                Text("Make sure the processing device")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("(iPad or Mac) is running BadmintonTracker")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 32)
        }
        .padding()
    }
}

#Preview {
    ConnectionView(viewModel: CameraViewModel())
}
