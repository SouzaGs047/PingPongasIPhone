//
//  GameClient.swift
//  PingPongasIPhone
//
//  Created by Gustavo Souza Santana on 11/11/25.
//
//  CORRIGIDO: 'contentProcessed'
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
        guard browser == nil else { return }
        
        let params = NWParameters.tcp
        let browser = NWBrowser(for: .bonjour(type: "_pocgame._tcp", domain: nil),
                                using: params)
        
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
        
        // --- CORREÇÃO AQUI ---
        // Substituímos o 'if/else' por um 'switch'
        connection?.stateUpdateHandler = { [weak self] state in
            DispatchQueue.main.async {
                self?.connectionState = state
                print("Conexão mudou:", state)
                
                switch state {
                case .ready:
                    // Conectado com sucesso!
                    self?.availableServers = []
                    
                case .failed(_), .cancelled:
                    // Se falhar ou for cancelado, desconecta
                    self?.handleDisconnect()
                    
                case .preparing, .setup, .waiting:
                    // Estamos conectando, não faz nada
                    break
                    
                @unknown default:
                    // Para casos futuros que a Apple adicionar
                    break
                }
            }
        }
        // --- FIM DA CORREÇÃO ---
        
        connection?.start(queue: .main)
        receive()
    }
    
    private func handleDisconnect() {
        connection?.cancel()
        connection = nil
        
        DispatchQueue.main.async {
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
        
        // --- CORREÇÃO 4 ---
        // Sendo explícito sobre o tipo 'NWConnection.SendCompletion'
        conn.send(content: data, completion: NWConnection.SendCompletion.contentProcessed { error in
            if let error = error {
                print("Erro ao enviar: \(error)")
                // Usar self?. para evitar retain cycle, embora seja rápido
                DispatchQueue.main.async {
                    self.handleDisconnect()
                }
            }
        })
    }
    
    private func receive() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 2048) { [weak self] data, _, _, error in
            
            if let data = data, let text = String(data: data, encoding: .utf8) {
                print("Recebido da TV:", text)
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
