import Vapor

/// configures your application
func configure(_ app: Application) async throws {

    app.middleware.use(FileMiddleware(
        publicDirectory: app.directory.publicDirectory,
        defaultFile: "index.html"
    ))

    // register routes
    try routes(app)
}
