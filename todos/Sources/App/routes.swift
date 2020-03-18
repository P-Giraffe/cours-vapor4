import Fluent
import Vapor

func routes(_ app: Application) throws {
    let userController = UserController()
    
    let basicGroup = app.grouped(User.authenticator().middleware())
    basicGroup.post("login", use: userController.login)

    let todoController = TodoController()
    app.get("todos", use: todoController.index)
    app.post("todos", use: todoController.create)
    app.delete("todos", ":todoID", use: todoController.delete)
    
    
    app.post("users", use: userController.create)
}
