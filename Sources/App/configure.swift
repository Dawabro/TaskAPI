import Vapor

public func configure(_ app: Application) async throws {
    // Configure middleware
    app.middleware.use(CORSMiddleware(configuration: .init(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith]
    )))
    
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))
    
    // Register routes
    try routes(app)
}
