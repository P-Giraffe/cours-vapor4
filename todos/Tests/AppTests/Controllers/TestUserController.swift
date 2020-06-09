//
//  TestUserController.swift
//  
//
//  Created by Anthony Fassler on 01/06/2020.
//

@testable import App
import XCTVapor
import Fluent

class TestUserController {
    
    private let routes = TestRoutes()
    private let userData = TestUserData()
    
    // MARK: - Création d'un utilisateur
    
    func createUser(_ app: Application) throws {
        try app.test(.POST, routes.users, beforeRequest: { req in
            // Encodage des données de l'utilisateur pour la requête.
            try req.content.encode(["name":userData.name,"email":userData.email,"password":userData.password])
        }, afterResponse: { res in
            // Décodage des données de l'utilisateur renvoyé par le serveur.
            let newUserResponse: User = try res.content.decode(User.self)
            // Vérification du mot de passe envoyé par celui répondu encrypté.
            let passwordVerify: Bool = try newUserResponse.verify(password: userData.password)
            
            // Test: Vérification du nom entre la requête et la réponse
            XCTAssertEqual(newUserResponse.name, userData.name)
            // Test: Vérification de l'email entre la requête et la réponse
            XCTAssertEqual(newUserResponse.email, userData.email)
            // Test: Vérification du mot de passe
            XCTAssertTrue(passwordVerify)
            // Test: Vérification du status HTTP: OK (Code 200)
            XCTAssertEqual(res.status, HTTPStatus.ok)
            print("CREATE USER OK")
        })
    }
    
    // MARK: - Obtention du Basic Token
    
    private func getBasicToken() -> HTTPHeaders {
        let basicCredentials: BasicAuthorization = BasicAuthorization.init(username: userData.email, password: userData.password)
        var basicToken: HTTPHeaders = HTTPHeaders()
        basicToken.basicAuthorization = basicCredentials
        
        return basicToken
    }
    
    // MARK: - Login et Obtention du Token de l'Utilisateur
    
    func getApiToken(_ app: Application) throws -> String {
        var token: String?
    
        try app.test(.POST, routes.login, headers: getBasicToken(), afterResponse: { res in
            // Récupération du contenu de la réponse
            XCTAssertContent(UserToken.self, res) { content in
                // Test: contenu non vide
                XCTAssertNotNil(content.value)
                token = content.value
            }
            // Test: Vérification du status HTTP: OK (Code 200)
            XCTAssertEqual(res.status, HTTPStatus.ok)
            print("LOGIN USER OK")
        })
        
        guard let t = token else {
            // Test: Échoué
            XCTFail("LOGIN FAILED")
            throw Abort(HTTPResponseStatus.unauthorized)
        }
        
        return t
    }
    
    // MARK: - Obtention du Bearer Token
    
    func getBearerToken(_ app: Application) throws -> HTTPHeaders {
        let bearerCredentials: BearerAuthorization = try BearerAuthorization.init(token: getApiToken(app))
        var bearerToken: HTTPHeaders = HTTPHeaders()
        bearerToken.bearerAuthorization = bearerCredentials
        
        return bearerToken
    }
    
}


