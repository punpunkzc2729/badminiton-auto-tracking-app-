//
//  ContentView.swift
//  BadmintonCamera
//
//  Main view coordinator
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = CameraViewModel()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if viewModel.isConnected {
                CameraView(viewModel: viewModel)
            } else {
                ConnectionView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.setup()
        }
    }
}

#Preview {
    ContentView()
}
