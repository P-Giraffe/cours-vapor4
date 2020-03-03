import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    let playerController = PlayerController()
    
    app.get("players", ":playerId", use:playerController.fetch)
    app.post("players", use: playerController.create)
    
}
