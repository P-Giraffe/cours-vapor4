//
//  File.swift
//  
//
//  Created by Maxime Britto on 18/03/2020.
//

import Fluent
import Vapor

struct UserController {
    func create(req: Request) throws -> EventLoopFuture<User> {
        let receivedData = try req.content.decode(User.Create.self)
        let user = try User(name: receivedData.name,
                            email: receivedData.email,
                            passwordHash: Bcrypt.hash(receivedData.password))
        return user.save(on: req.db).transform(to: user)
    }
    
}

extension User {
    struct Create : Content {
        var name: String
        var email: String
        var password: String
    }
}

