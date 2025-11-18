//
//  PlayerModel.swift
//  PingPongasIPhone
//
//  Created by Gustavo Souza Santana.
//  Created by Ruan Lopes Viana.

import Foundation
import SwiftData

@Model
final class PlayerModel {
    var name: String

    init(name: String) {
        self.name = name
    }
}
