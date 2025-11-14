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
    @State var player: PlayerModel
    @State private var selectedSide: String? = nil
    @State private var readyToPlay: Bool = false
    
    @State private var gameStarted = false

    
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
                if selectedSide == nil {
                    Text("Escolha seu lado:")
                        .font(.headline)
                    HStack {
                        Button("Lado Esquerdo") {
                            selectedSide = "left"
                            client.send("JOIN:left:\(player.name)")
                            
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Lado Direito") {
                            selectedSide = "right"
                            client.send("JOIN:right:\(player.name)")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    Spacer()
                } else {
                    Text("Você está no lado \(selectedSide == "left" ? "Esquerdo" : "Direito")")
                    Spacer()
                    Button {
                        readyToPlay.toggle()
                        
                        let message = "READY:\(readyToPlay ? "1" : "0")"
                        client.send(message)
                        
                    } label: {
                        HStack {
                            Text("Pronto")
                        }
                        .padding()
                        .foregroundStyle(.white)
                        .background(readyToPlay ? Color.green : Color.blue)
                        .cornerRadius(25)
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            client.startBrowser()
        }
        .onChange(of: client.gameStarted) {
            if client.gameStarted {
                gameStarted = true
            }
        }
        .navigationDestination(isPresented: $gameStarted) {
            ControlerView(
                client: client,
                player: $player,
                selectedSide: $selectedSide,
                readyToPlay: $readyToPlay,
                gameStarted: $gameStarted
            )
        }

        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if client.connectionState == .ready {
                    Button(role: .destructive) {
                        selectedSide = nil
                        
                        readyToPlay = false
                        
                        client.send("READY:0")
                        
                        client.send("LEAVE:\(player.name)")
                        
                        
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
                        
                        readyToPlay = false
                       
                        client.send("READY:0")
                        
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


#Preview {
    
    ContentView(player: PlayerModel(name: "Gugas"))
}

