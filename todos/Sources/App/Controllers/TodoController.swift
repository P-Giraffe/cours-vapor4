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
    }

    func create(req: Request) throws -> EventLoopFuture<Todo> {
        let user = try req.auth.require(User.self)
        let todo:Todo = try req.content.decode(Todo.self)
        return todo.save(on: req.db).transform(to: todo)
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let user = try req.auth.require(User.self)
        return Todo.find(req.parameters.get("todoID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }
}
