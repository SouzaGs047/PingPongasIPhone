//
//  GameClient.swift
//  PingPongasIPhone
//
//  Created by Gustavo Souza Santana on 11/11/25.
//

import Foundation
import Network
import Combine

class GameClient: ObservableObject {
    private var browser: NWBrowser?
    private var connection: NWConnection?

    @Published var availableServers: [NWBrowser.Result] = []
    @Published var connectionState: NWConnection.State = .setup

    func startBrowser() {
        let params = NWParameters.tcp
        let browser = NWBrowser(for: .bonjour(type: "_pocgame._tcp", domain: nil),
                                using: params)
        
        self.browser = browser
        
        browser.browseResultsChangedHandler = { results, _ in
            DispatchQueue.main.async {
                self.availableServers = Array(results)
            }
        }

        browser.start(queue: .main)
        print("Busca iniciada.")
    }

    func connect(to result: NWBrowser.Result) {
        guard case let NWEndpoint.service(name: name, type: _, domain: _, interface: _) = result.endpoint else {
            print("Falha ao conectar.")
            return
        }

        print("Conectando a:", name)

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
    
    func disconnect() {
        print("Desconectando...")

        connection?.cancel()
        connection = nil

        DispatchQueue.main.async {
            self.availableServers = []
            self.connectionState = .setup
        }

        print("Desconectado.")
    }

    func send(_ text: String) {
        guard let conn = connection else { return }
        let data = text.data(using: .utf8)!
        conn.send(content: data, completion: .contentProcessed { _ in })
    }

    private func receive() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 2048) { data, _, _, error in
            
            if let data = data, let text = String(data: data, encoding: .utf8) {
                print("Recebido da TV:", text)
            }

            if error == nil {
                self.receive()
            } else {
                // ✅ Se desconectar, atualiza o estado e reinicia a busca
                DispatchQueue.main.async {
                    self.connectionState = .cancelled
                }
            }

        }
    }
}
