//
//  TestTodoController.swift
//  
//
//  Created by Anthony Fassler on 04/06/2020.
//

@testable import App
import XCTVapor
import Fluent

class TestTodoController {
    
    private let routes = TestRoutes()
    private let user = TestUserController()
    
    // MARK: - Obtention Todo

    func getTodo(_ app: Application) throws -> [Todo] {
        var todos: [Todo] = []
        
        try app.test(.GET, routes.todos, afterResponse: { res in
            // Récupération du contenu de la réponse
            XCTAssertContent([Todo].self, res) { content in
                todos = content
                // Affichage des Todos dans la console.
                for todo in todos {
                    print("\(todo)\n")
                }
            }
            // Test: Vérification du status HTTP: OK (Code 200)
            XCTAssertEqual(res.status, HTTPStatus.ok)
            print("OBTENTION TODO OK")
        })
        
        return todos
    }
    
    // MARK: - Création Todo
    
    func createTodo(_ app: Application) throws {
        try app.test(.POST, routes.todos, headers: user.getBearerToken(app), beforeRequest: { req in
            // Encodage de la requête avec le nom du Todo.
            let todoTitle: String = "Test Todo"
            try req.content.encode(["title": todoTitle])
        }, afterResponse: { res in
            // Récupération du contenu de la réponse
            XCTAssertContent(Todo.self, res) { content in
                // Test: contenu non vide
                XCTAssertNotNil(content.title)
            }
            // Test: Vérification du status HTTP: OK (Code 200)
            XCTAssertEqual(res.status, HTTPStatus.ok)
            print("CREATE TODO OK")
        })
    }
    
    // MARK: - Suppression Todo
    
    func deleteTodo(_ app: Application) throws {
        // Obtention des Todos.
        let todos: [Todo] = try getTodo(app)
        // Obtention du premier Todo.
        let getFirstTodo: Todo? = todos.first
        
        // Vérification des l'optionnels
        if let firstTodo = getFirstTodo {
            if let todoID = firstTodo.id {
                // Conversion de l'ID en String.
                let todoIDString: String = String(todoID)
                // Création de la Route avec l'ID du Todo.
                let routeWithTodoID: String = routes.todos + "/" + todoIDString
                
                try app.test(.DELETE, routeWithTodoID, headers: user.getBearerToken(app), afterResponse: { res in
                    // Test: Vérification du status HTTP: OK (Code 200)
                    XCTAssertEqual(res.status, HTTPStatus.ok)
                    print("DELETE TODO OK")
                })
            }
        }
    }
    
}
