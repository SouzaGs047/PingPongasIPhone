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
            }


            Button("Desconectar") {
                client.disconnect()
            }
            Button("Enviar comando: Jump") {
                client.send("jump")
            }
            .padding()
        }
        .onAppear {
            client.startBrowser()
        }
        .navigationBarBackButtonHidden(true)
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
