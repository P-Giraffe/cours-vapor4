import Fluent
import FluentSQLiteDriver
import FluentMySQLDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    if app.environment == .production {
        let password = Environment.get("MYSQL_PASSWORD")!
        //export MYSQL_PASSWORD=3YroPhon=h9PzWM}dcwf
        app.databases.use(.mysql(hostname: "127.0.0.1", username: "vapor_user", password: password))
    } else {
        app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite)
    }

    app.migrations.add(CreateTodo())
    app.migrations.add(CreateUser())
    app.migrations.add(CreateUserToken())

    // register routes
    try routes(app)
}
