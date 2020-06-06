@testable import App
import XCTVapor
import Fluent

final class AppTests: XCTestCase {
    let userTest = TestUserController()
    let todosTest = TestTodoController()
    
    // MARK: - Configuration de l'application de test
    
    func createTestApp() throws -> Application {
        let app = Application(.testing)
        try configure(app)
        app.databases.use(.sqlite(.memory), as: .sqlite, isDefault: true)
        try app.autoMigrate().wait()
        return app
    }
    
    // MARK: - Test de création de l'utilisateur
    
    func testCreateUser() throws {
        let app = try createTestApp()
        defer { app.shutdown() }
        
        try userTest.createUser(app)
    }
    
    // MARK: - Test de connexion
    
    func testLoginUser() throws {
        let app = try createTestApp()
        defer { app.shutdown() }
        
        try userTest.createUser(app)
        _ = try userTest.getApiToken(app)
    }
    
    // MARK: - Test de création de todo
    
    func testCreateTodo() throws {
        let app = try createTestApp()
        defer { app.shutdown() }
        
        try userTest.createUser(app)
        try todosTest.createTodo(app)
    }
    
    // MARK: - Test d'obtention des todos
    
    func testGetTodo() throws {
        let app = try createTestApp()
        defer { app.shutdown() }
        
        try userTest.createUser(app)
        try todosTest.createTodo(app)
        _ = try todosTest.getTodo(app)
    }
    
    // MARK: - Test de suppresion de todo
    
    func testDeleteTodo() throws {
        let app = try createTestApp()
        defer { app.shutdown() }
        
        try userTest.createUser(app)
        try todosTest.createTodo(app)
        try todosTest.deleteTodo(app)
    }
    
}
