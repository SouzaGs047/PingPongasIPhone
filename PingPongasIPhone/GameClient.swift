//
//  GameClient.swift
//  PingPongasIPhone
//
//  Created by Gustavo Souza Santana.
//  Created by Ruan Lopes Viana.

import Foundation
import Network
import Combine

class GameClient: ObservableObject {
    private var browser: NWBrowser?
    private var connection: NWConnection?
    
    @Published var availableServers: [NWBrowser.Result] = []
    @Published var connectionState: NWConnection.State = .setup
    
    @Published var gameStarted: Bool = false
    
    func startBrowser() {
        guard browser == nil else { return }
        
        let params = NWParameters.tcp
        let browser = NWBrowser(
            for: .bonjour(type: "_pocgame._tcp", domain: nil),
            using: NWParameters()
        )

        self.browser = browser
        
        browser.browseResultsChangedHandler = { [weak self] results, _ in
            DispatchQueue.main.async {
                if self?.connectionState != .ready {
                    self?.availableServers = Array(results)
                }
            }
        }
        
        browser.start(queue: .main)
        print("Busca iniciada.")
    }
    
    // Em GameClient.swift
    
    func connect(to result: NWBrowser.Result) {
        guard case let NWEndpoint.service(name: name, type: _, domain: _, interface: _) = result.endpoint else {
            print("Falha ao extrair endpoint.")
            return
        }
        
        print("Conectando a:", name)
        
        browser?.cancel()
        browser = nil
        
        connection = NWConnection(to: result.endpoint, using: .tcp)
        
        connection?.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                self?.connectionState = state
                print("Conexão mudou:", state)
            }
        }
        
        connection?.start(queue: .main)
        receive()
    }
    
    private func handleDisconnect() {
        connection?.cancel()
        connection = nil
        
        DispatchQueue.main.async {
            self.gameStarted = false      
            self.connectionState = .setup
            self.startBrowser()
        }
        print("Desconectado. Reiniciando a busca.")
    }

    
    func disconnect() {
        print("Desconectando manualmente...")
        handleDisconnect()
    }
    
    func send(_ text: String) {
        guard let conn = connection, connectionState == .ready else { return }
        let data = text.data(using: .utf8)!
        conn.send(content: data, completion: .contentProcessed { _ in })
    }
    
    private func receive() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 2048) { [weak self] data, _, _, error in
            
            if let data = data, let text = String(data: data, encoding: .utf8) {
                print("Recebido da TV:", text)

                if text == "START" {
                    DispatchQueue.main.async {
                        self?.gameStarted = true
                    }
                } else if text == "STOP" {
                    DispatchQueue.main.async {
                        self?.gameStarted = false
                    }
                }
                
            }
            
            if error == nil {
                self?.receive()
            } else {
                print("Erro na conexão (receive): \(error?.localizedDescription ?? "desconhecido")")
                self?.handleDisconnect()
            }
        }
    }

}
