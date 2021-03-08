//
//  TodoController.swift
//
//
//  Created by Maxime Britto on 18/03/2020.
//

import Fluent
import Vapor

struct TodoController {
    func index(req: Request) throws -> EventLoopFuture<[Todo]> {
        return Todo.query(on: req.db)
            .sort(\.$title, .ascending)
            .all()
    }
    
    func count(req: Request) throws -> EventLoopFuture<Int> {
        return Todo.query(on: req.db).all().map { todoList -> Int in todoList.count }
        //return Todo.query(on: req.db).count()         <---- sur un véritable serveur de production, utilisez plutôt cette ligne qui est plus performante. La version ci-dessu est interessante pédagogiquement pour montrer l'utilisation du map uniquement.
    }

    func create(req: Request) throws -> EventLoopFuture<Todo> {
        _ = try req.auth.require(User.self)
        let todo:Todo = try req.content.decode(Todo.self)
        return todo.save(on: req.db).transform(to: todo)
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        _ = try req.auth.require(User.self)
        return Todo.find(req.parameters.get("todoID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
