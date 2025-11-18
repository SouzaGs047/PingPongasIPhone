//
//  CreatePlayerView.swift
//  PingPongasIPhone
//
//  Created by Gustavo Souza Santana.
//  Created by Ruan Lopes Viana.

import SwiftUI

struct CreatePlayerView: View {
    @State private var nomeDoUsuario: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Digite o nome do jogador")
                .font(.headline)
            
            TextField("Nome do jogador", text: $nomeDoUsuario)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            NavigationLink(value: PlayerModel(name: nomeDoUsuario)) {
                Text("Criar")
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    .background(nomeDoUsuario.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(nomeDoUsuario.isEmpty)
            
            Spacer()
        }
        .padding()
        .navigationDestination(for: PlayerModel.self) { player in
            ContentView(player: player)
        }
    }
}

#Preview {
    NavigationStack {
        CreatePlayerView()
    }
}

