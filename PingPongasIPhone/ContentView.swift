//
//  ContentView.swift
//  PingPongasIPhone
//
//  Created by Gustavo Souza Santana on 11/11/25.
//

import SwiftUI
import Network

struct ContentView: View {
    @StateObject var client = GameClient()
    var player: PlayerModel
    @State private var selectedSide: String? = nil
    @State private var readyToPlay: Bool = false
    
    var body: some View {
        VStack {
            Text("Jogador: \(player.name)")
                .font(.largeTitle)
            
            if client.connectionState != .ready {
                List(client.availableServers, id: \.self) { server in
                    Button("Conectar a \(formatName(server))") {
                        client.connect(to: server)
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
                } else {
                    Text("Você está no lado \(selectedSide == "left" ? "Esquerdo" : "Direito")")
                    Button("Pronto") {
                        client.send("Pronto")
                    }
                    .padding()
                }
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
            default: return "Desconhecido"
        }
    }
}


//#Preview {
//    @Previewable var nomeDoUsuario: String = "Gugas"
//    ContentView(nomeDoUsuario: .constant(nomeDoUsuario))
//}

