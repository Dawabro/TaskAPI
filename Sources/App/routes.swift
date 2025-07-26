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
        let formatter = ISO8601DateFormatter()
        return [
            "status": "healthy",
            "timestamp": formatter.string(from: Date())
        ]
    }
    
    // Register task routes
    try app.register(collection: TaskController())
}
