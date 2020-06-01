@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    let app = Application(.testing)
    let user = UserInfo()
    let routes = Routes()
    
    func getBasicToken() -> HTTPHeaders {
        let basicCredentials = BasicAuthorization.init(username: user.email, password: user.password)
        var basicToken = HTTPHeaders()
        basicToken.basicAuthorization = basicCredentials
        
        return basicToken
    }
    
    func getBearerToken() throws -> HTTPHeaders {
        let bearerCredentials = try BearerAuthorization.init(token: getApiToken(app))
        var bearerToken = HTTPHeaders()
        bearerToken.bearerAuthorization = bearerCredentials
        
        return bearerToken
    }

    func getApiToken(_ app: Application) throws -> String {
        
        var token: String?
    
        try app.test(.POST, routes.login, headers: getBasicToken(), afterResponse: { res in
            XCTAssertContent(UserToken.self, res) { content in
                XCTAssertNotNil(content.value)
                token = content.value
            }
            XCTAssertEqual(res.status, HTTPStatus.ok)
        })
        
        guard let t = token else {
            XCTFail("Login failed")
            throw Abort(HTTPResponseStatus.unauthorized)
        }
        
        return t
    }
    
    func getTodo(_ app: Application) throws -> [Todo] {
        
        var todos: [Todo] = []
        
        try app.test(.GET, routes.todos, afterResponse: { res in
            XCTAssertContent([Todo].self, res) { content in
                todos = content
            }
            XCTAssertEqual(res.status, HTTPStatus.ok)
        })
        
        return todos
    }
    
    func testCreateUser() throws {
        defer { app.shutdown() }
        try configure(app)

        try app.test(.POST, routes.users, beforeRequest: { req in
            
            try req.content.encode(["name":user.name,"email":user.email,"password":user.password])
            
        }, afterResponse: { res in
            
            let newUserResponse = try res.content.decode(User.self)
            let passwordVerify = try newUserResponse.verify(password: user.password)

            XCTAssertEqual(newUserResponse.name, user.name)
            XCTAssertEqual(newUserResponse.email, user.email)
            XCTAssertTrue(passwordVerify)
            XCTAssertEqual(res.status, HTTPStatus.ok)
        })
    }
    
    func testLoginUser() throws {
        defer { app.shutdown() }
        try configure(app)
        
        try app.test(.POST, routes.login, headers: getBasicToken(), afterResponse: { res in
            XCTAssertContent(UserToken.self, res) { content in
                XCTAssertNotNil(content.value)
            }
            XCTAssertEqual(res.status, HTTPStatus.ok)
        })
    }
    
    func testGetTodo() throws {
        defer { app.shutdown() }
        try configure(app)
        
        let todos = try getTodo(app)
        
        for todo in todos {
            print("\(todo)\n")
        }
    }
    
    func testCreateTodo() throws {
        defer { app.shutdown() }
        try configure(app)
        
        try app.test(.POST, routes.todos, headers: getBearerToken(), beforeRequest: { req in
            
            let todoTitle = "Test Todo"
            try req.content.encode(["title": todoTitle])
            
        }, afterResponse: { res in
            XCTAssertContent(Todo.self, res) { content in
                XCTAssertNotNil(content.title)
            }
            XCTAssertEqual(res.status, HTTPStatus.ok)
        })
    }
    
    func testDeleteTodo() throws {
        defer { app.shutdown() }
        try configure(app)
        
        let todos = try getTodo(app)
        
        let getFirstTodo: Todo? = todos.first
        
        if let firstTodo = getFirstTodo {
            if let todoID = firstTodo.id {
                
                let todoIDString = String(todoID)
                let routeWithTodoID = routes.todos + "/" + todoIDString
                
                try app.test(.DELETE, routeWithTodoID, headers: getBearerToken(), afterResponse: { res in
                    
                    XCTAssertEqual(res.status, HTTPStatus.ok)
                    
                })
            }
        }
    }
    
}
