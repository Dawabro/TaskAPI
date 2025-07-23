import Vapor

func routes(_ app: Application) throws {
    // Health check endpoint
    app.get { req async in
        return [
            "message": "Task Management API",
            "version": "1.0.0",
            "status": "running"
        ]
    }
    
    app.get("health") { req async in
        return [
            "status": "healthy",
            "timestamp": Date().ISO8601Format()
        ]
    }
    
    // Register task routes
    try app.register(collection: TaskController())
}
