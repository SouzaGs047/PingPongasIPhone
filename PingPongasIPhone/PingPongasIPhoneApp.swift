//
//  PingPongasIPhoneApp.swift
//  PingPongasIPhone
//
//  Created by Gustavo Souza Santana.
//  Created by Ruan Lopes Viana.

import SwiftUI

@main
struct PingPongasIPhoneApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack(){
                CreatePlayerView()
            }
        }
    }
}
