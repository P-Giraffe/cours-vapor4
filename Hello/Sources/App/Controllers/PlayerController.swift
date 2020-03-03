//
//  File.swift
//  
//
//  Created by Maxime Britto on 25/02/2020.
//

import Vapor

struct PlayerController {
    func fetch(req:Request) throws -> Player {
        guard let playerId:Int = req.parameters.get("playerId", as: Int.self) else {
            throw Abort(.badRequest)
        }
        let player = Player(id: playerId, name: "Poppy")
        return player
    }
    
    func create(req:Request) throws -> Player {
        guard let receivedPlayer = try? req.content.decode(Player.self),
            receivedPlayer.name.count > 2
            else {
                throw Abort(.badRequest)
        }
        
        //Sauvegarder dans la base de données ce nouveau player
        
        return receivedPlayer
    }
}
