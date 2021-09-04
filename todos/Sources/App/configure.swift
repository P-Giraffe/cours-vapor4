import Fluent
import FluentSQLiteDriver
import FluentMySQLDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    if app.environment == .production {
        //Environment.get("MySQL_VAPOR_PASSWORD")
        
        var tlsCustomConfiguration = TLSConfiguration.makeClientConfiguration()
        tlsCustomConfiguration.certificateVerification = .none
        
        app.databases.use(.mysql(hostname: "127.0.0.1", username: "vapor_user", password: "", tlsConfiguration: tlsCustomConfiguration), as: .mysql)
    } else {
        app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    }

    app.migrations.add(CreateTodo())
    app.migrations.add(CreateUser())
    app.migrations.add(CreateUserToken())

    // register routes
    try routes(app)
}
