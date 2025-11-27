//
//  CameraView.swift
//  BadmintonCamera
//
//  Camera preview and controls
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @ObservedObject var viewModel: CameraViewModel
    
    var body: some View {
        ZStack {
            // Camera preview
            CameraPreview(previewLayer: viewModel.getPreviewLayer())
                .ignoresSafeArea()
            
            // Overlay UI
            VStack {
                // Top status bar
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(viewModel.isStreaming ? Color.green : Color.gray)
                                .frame(width: 12, height: 12)
                            
                            Text(viewModel.isStreaming ? "STREAMING" : "PAUSED")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text(viewModel.connectionStatus)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.disconnect()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [.black.opacity(0.7), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                Spacer()
                
                // Bottom controls
                VStack(spacing: 16) {
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.callout)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                    }
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            if viewModel.isStreaming {
                                viewModel.stopStreaming()
                            } else {
                                viewModel.startStreaming()
                            }
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: viewModel.isStreaming ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                                
                                Text(viewModel.isStreaming ? "Pause" : "Resume")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding(.bottom, 40)
                .padding(.horizontal)
                .background(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
    }
}

// MARK: - Camera Preview

struct CameraPreview: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer?
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        
        if let layer = previewLayer {
            layer.frame = view.bounds
            view.layer.addSublayer(layer)
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = previewLayer {
            DispatchQueue.main.async {
                layer.frame = uiView.bounds
            }
        }
    }
}

#Preview {
    CameraView(viewModel: CameraViewModel())
}
