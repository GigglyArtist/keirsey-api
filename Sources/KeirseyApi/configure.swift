import Vapor

/// configures your application
func configure(_ app: Application) async throws {

    app.middleware.use(FileMiddleware(
        publicDirectory: app.directory.publicDirectory,
        defaultFile: "index.html"
    ))
    
    if let port = Environment.get("PORT").flatMap(Int.init) {
        app.http.server.configuration.port = port
    }

    app.http.server.configuration.hostname = "0.0.0.0"
    
    // register routes
    try routes(app)
}
