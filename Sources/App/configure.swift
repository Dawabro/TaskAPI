import Vapor
import Fluent
import FluentPostgresDriver

public func configure(_ app: Application) async throws {
    // Configure database
    if let databaseURL = Environment.get("DATABASE_URL") {
        // Railway PostgreSQL - use URL directly, it handles SSL
        try app.databases.use(.postgres(url: databaseURL), as: .psql)
    } else {
        // Local development configuration
        app.databases.use(
            .postgres(
                hostname: Environment.get("DATABASE_HOST") ?? "localhost",
                port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 5432,
                username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
                password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
                database: Environment.get("DATABASE_NAME") ?? "vapor_database"
            ),
            as: .psql
        )
    }
    
    // Add migrations
    app.migrations.add(CreateTask())
    
    // Configure middleware
    app.middleware.use(CORSMiddleware(configuration: .init(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith]
    )))
    
    app.middleware.use(ErrorMiddleware.default(environment: app.environment))
    
    // Register routes
    try routes(app)
    
    // Auto-migrate on startup 
    if app.environment == .development || app.environment == .production {
        try await app.autoMigrate()
    }
}
