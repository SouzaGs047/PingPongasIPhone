//
//  ControlerView.swift
//  PingPongasIPhone
//
//  Created by Gustavo Souza Santana on 13/11/25.
//
import SwiftUI
import Network

struct ControlerView: View {
    @ObservedObject var client: GameClient
    @Environment(\.dismiss) var dismiss
    
    @Binding var player: PlayerModel
    @Binding var selectedSide: String?
    @Binding var readyToPlay: Bool
    @Binding var gameStarted: Bool
    
    // Timers para repetição contínua
    @State private var upTimer: Timer?
    @State private var downTimer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // --- Área UP ---
                Rectangle()
                    .fill(Color.blue.opacity(0.4))
                    .overlay(
                        Image(systemName: "arrow.up")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .onLongPressGesture(
                        minimumDuration: 0,         // dispara imediatamente
                        maximumDistance: .infinity, // pode segurar e arrastar um pouco
                        pressing: { isPressing in
                            if isPressing {
                                startUp()
                            } else {
                                stopUp()
                            }
                        },
                        perform: {}
                    )
                
                // --- Área DOWN ---
                Rectangle()
                    .fill(Color.green.opacity(0.4))
                    .overlay(
                        Image(systemName: "arrow.down")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .onLongPressGesture(
                        minimumDuration: 0,
                        maximumDistance: .infinity,
                        pressing: { isPressing in
                            if isPressing {
                                startDown()
                            } else {
                                stopDown()
                            }
                        },
                        perform: {}
                    )
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            // Garante que os timers parem se a tela sumir
            stopUp()
            stopDown()
        }
        // Quando a TV manda START/STOP
        .onChange(of: client.gameStarted) {
            selectedSide = nil
            
            client.send("LEAVE:\(player.name)")
            
            
            client.gameStarted = false
            gameStarted = false
            readyToPlay = false
            client.disconnect()
        }
        
        
        // Quando o estado da conexão com a TV muda
        .onChange(of: client.connectionState) { state in
            switch state {
            case .failed, .cancelled:
                selectedSide = nil
                
                client.send("LEAVE:\(player.name)")
                
                
                client.gameStarted = false
                gameStarted = false
                readyToPlay = false
                
                client.disconnect()
            default:
                break
            }
        }
        
        
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if client.connectionState == .ready {
                    Button(role: .destructive) {
                        client.gameStarted = false
                        gameStarted = false
                    } label: {
                        Text("Desconectar")
                    }
                }
            }
        }
    }
    
    // MARK: - Contínuo UP
    
    private func startUp() {
        guard upTimer == nil else { return } // já está rodando
        
        // manda logo um primeiro comando
        client.send("up")
        
        upTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 20.0, repeats: true) { _ in
            client.send("up")
        }
    }
    
    private func stopUp() {
        upTimer?.invalidate()
        upTimer = nil
    }
    
    // MARK: - Contínuo DOWN
    
    private func startDown() {
        guard downTimer == nil else { return }
        
        client.send("down")
        
        downTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 20.0, repeats: true) { _ in
            client.send("down")
        }
    }
    
    private func stopDown() {
        downTimer?.invalidate()
        downTimer = nil
    }
}

