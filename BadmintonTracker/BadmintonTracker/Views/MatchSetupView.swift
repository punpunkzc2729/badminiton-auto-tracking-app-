//
//  MatchSetupView.swift
//  BadmintonTracker
//
//  Match configuration screen
//

import SwiftUI

struct MatchSetupView: View {
    @ObservedObject var viewModel: MatchViewModel
    
    @State private var playerA = "Player A"
    @State private var playerB = "Player B"
    @State private var bestOf = 3
    @State private var showingCameraConnection = false
    
    var body: some View {
        ZStack {
            Color.darkBg.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // Title
                VStack(spacing: 8) {
                    Image(systemName: "figure.badminton")
                        .font(.system(size: 60))
                        .foregroundColor(.brandGreen)
                    
                    Text("New Badminton Match")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                // Form
                VStack(spacing: 20) {
                    // Player A
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Player A")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        TextField("Player A", text: $playerA)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    // Player B
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Player B")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        TextField("Player B", text: $playerB)
                            .textFieldStyle(CustomTextFieldStyle())
                    }
                    
                    // Best of
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Best of")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 12) {
                            Button(action: { bestOf = 3 }) {
                                Text("3 Games")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(bestOf == 3 ? Color.brandBlue : Color.lightBg)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: { bestOf = 5 }) {
                                Text("5 Games")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(bestOf == 5 ? Color.brandBlue : Color.lightBg)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Camera connection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Camera")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            showingCameraConnection = true
                        }) {
                            HStack {
                                Image(systemName: viewModel.isConnectedToCamera ? "checkmark.circle.fill" : "video.slash")
                                    .foregroundColor(viewModel.isConnectedToCamera ? .green : .gray)
                                
                                Text(viewModel.isConnectedToCamera ? "Camera Connected" : "Connect Camera")
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.lightBg)
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Start button
                Button(action: startMatch) {
                    Label("Start Match", systemImage: "play.fill")
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
        .sheet(isPresented: $showingCameraConnection) {
            CameraConnectionSheet(viewModel: viewModel)
        }
    }
    
    private func startMatch() {
        viewModel.startMatch(playerA: playerA, playerB: playerB, bestOf: bestOf)
    }
}

// MARK: - Custom Text Field Style

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.lightBg)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}

// MARK: - Camera Connection Sheet

struct CameraConnectionSheet: View {
    @ObservedObject var viewModel: MatchViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.darkBg.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    if viewModel.isConnectedToCamera {
                        // Connected state
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            
                            Text("Camera Connected")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(viewModel.connectionStatus)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Button("Disconnect") {
                                viewModel.disconnectCamera()
                            }
                            .foregroundColor(.red)
                            .padding()
                        }
                    } else {
                        // Scanning state
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.brandBlue)
                            
                            Text("Searching for cameras...")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            if !viewModel.discoveredCameras.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Available Cameras")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                    
                                    ForEach(viewModel.discoveredCameras, id: \.self) { camera in
                                        Button(action: {
                                            viewModel.connectToCamera(camera)
                                        }) {
                                            HStack {
                                                Image(systemName: "iphone")
                                                    .foregroundColor(.brandBlue)
                                                
                                                Text(camera.displayName)
                                                    .foregroundColor(.white)
                                                
                                                Spacer()
                                                
                                                Image(systemName: "chevron.right")
                                                    .foregroundColor(.gray)
                                            }
                                            .padding()
                                            .background(Color.lightBg)
                                            .cornerRadius(8)
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Camera Connection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.brandBlue)
                }
            }
        }
    }
}

#Preview {
    MatchSetupView(viewModel: MatchViewModel())
}
