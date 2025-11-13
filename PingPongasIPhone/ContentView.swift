//
//  ContentView.swift
//  PingPongasIPhone
//
//  Created by Gustavo Souza Santana on 11/11/25.
//
//  MODIFICADO: Agora é o controle do jogo
//

import SwiftUI
import Network

struct ContentView: View {
    @StateObject var client = GameClient()
    var player: PlayerModel
    @State private var selectedSide: String? = nil
    @State private var readyToPlay: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // --- Tela de Conexão ---
            if client.connectionState != .ready {
                VStack {
                    Text("Jogador: \(player.name)")
                        .font(.largeTitle)
                        .padding()
                    
                    Text("Procurando Apple TV...")
                        .font(.headline)
                    
                    List(client.availableServers, id: \.self) { server in
                        Button("Conectar a \(formatName(server))") {
                            client.connect(to: server)
                        }
                    }
                }
                
            } else {
                
                // O CONTROLE
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        
                        // Botão CIMA
                        Button(action: { client.send("up") }) {
                            Rectangle()
                                .fill(Color.blue.opacity(0.4))
                                .overlay(
                                    Image(systemName: "arrow.up")
                                        .font(.system(size: 80, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                        
                        // Botão BAIXO
                        Button(action: { client.send("down") }) {
                            Rectangle()
                                .fill(Color.green.opacity(0.4))
                                .overlay(
                                    Image(systemName: "arrow.down")
                                        .font(.system(size: 80, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                }
                .edgesIgnoringSafeArea(.bottom)

                Button("Desconectar") {
                    client.disconnect()
                }
                .padding()
                .foregroundColor(.red)
            }
            
            Spacer()
        }
        .onAppear {
            client.startBrowser()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if client.connectionState == .ready {
                    Button(role: .destructive) {
                        client.disconnect()
                    } label: {
                        Text("Desconectar")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if selectedSide != nil && client.connectionState == .ready{
                    Button(role: .destructive) {
                        selectedSide = nil
                        client.send("LEAVE:\(player.name)")
                    } label: {
                        Text("Sair da equipe")
                    }
                }

            }
        }
    }
    
    func formatName(_ result: NWBrowser.Result) -> String {
        switch result.endpoint {
            case let .service(name, _, _, _): return name
            default: return "Servidor Desconhecido"
        }
    }
}


//#Preview {
//    @Previewable var nomeDoUsuario: String = "Gugas"
//    ContentView(nomeDoUsuario: .constant(nomeDoUsuario))
//}

