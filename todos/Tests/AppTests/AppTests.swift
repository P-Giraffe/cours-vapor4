@testable import App
import XCTVapor
//import Fluent

final class AppTests: XCTestCase {
    let app = Application(.testing)
    let user = UserInformations()
    let routes = Routes()
    
    struct UserInformations {
        let name = "Poppy Lee"
        let email = "poppy@mythicquest.com"
        let password = "password"
    }
    
    struct Routes {
        let users = "users"
        let login = "login"
        let todos = "todos"
    }
    
    enum Action {
        case login, create, delete
    }
    
    func loginAndTodoTesting(action:Action) throws {
        defer { app.shutdown() }
        try configure(app)
        
        let basicCredentials = BasicAuthorization.init(username: user.email, password: user.password)
        var basicToken = HTTPHeaders()
        basicToken.basicAuthorization = basicCredentials
        
        if action == .login || action == .create || action == .delete {
            print("USER LOGIN")
            
            try app.test(.POST, routes.login, headers: basicToken, afterResponse: { res in
                
                let userLoginResponse = try res.content.decode(UserToken.self)
                
                XCTAssertNotNil(userLoginResponse.value)
                XCTAssertEqual(res.status, HTTPStatus.ok)
                
                let bearerCredentials = BearerAuthorization.init(token: userLoginResponse.value)
                var bearerToken = HTTPHeaders()
                bearerToken.bearerAuthorization = bearerCredentials
                
                    
                if action == .create {
                    print("CREATE TODO")
                    
                    try app.test(.POST, routes.todos, headers: bearerToken, beforeRequest: { req in
                        
                        let todoTitle = "Test Todo"
                        try req.content.encode(["title": todoTitle])
                        
                    }, afterResponse: { res in
                        
                        let createTodoResponse = try res.content.decode(Todo.self)
                        XCTAssertNotNil(createTodoResponse.title)
                    })
                }
                
                if action == .delete {
                    print("DELETE TODO")
                    
                    try app.test(.GET, routes.todos, afterResponse: { res in
                        
                        let getTodosResponse = try res.content.decode([Todo].self)
                        XCTAssertEqual(res.status, HTTPStatus.ok)
                        
                        let getFirstTodo:Todo? = getTodosResponse.first
                        if let firstTodo = getFirstTodo {
                            if let todoID = firstTodo.id {
                                let todoIDString = String(todoID)
                                let routeWithTodoID = routes.todos + "/" + todoIDString
                                
                                try app.test(.DELETE, routeWithTodoID, headers: bearerToken, afterResponse: { res in
                                    
                                    XCTAssertEqual(res.status, HTTPStatus.ok)
                                })
                            }
                        }
                    })
                }
            })
        }
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
            XCTAssertEqual(passwordVerify, true)
            XCTAssertEqual(res.status, HTTPStatus.ok)
        })
    }
    
    func testLoginUser() throws {
        try loginAndTodoTesting(action: .login)
    }
    
    func testGetTodo() throws {
        defer { app.shutdown() }
        try configure(app)
        
        try app.test(.GET, routes.todos, afterResponse: { res in
            
            let getTodosResponse = try res.content.decode([Todo].self)
            print(getTodosResponse)
            XCTAssertEqual(res.status, HTTPStatus.ok)
        })
    }
    
    func testCreateTodo() throws {
        try loginAndTodoTesting(action: .create)
    }
    
    func testDeleteTodo() throws {
        try loginAndTodoTesting(action: .delete)
    }
    
}
