import Vapor
import Fluent

struct TaskController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let tasks = routes.grouped("api", "tasks")
        
        tasks.get(use: getAllTasks)
        tasks.post(use: createTask)
        tasks.group(":taskID") { task in
            task.get(use: getTask)
            task.put(use: updateTask)
            task.delete(use: deleteTask)
            task.patch("toggle", use: toggleTask)
        }
        
        // Additional endpoints
        tasks.get("completed", use: getCompletedTasks)
        tasks.get("pending", use: getPendingTasks)
        tasks.get("priority", ":priority", use: getTasksByPriority)
    }
    
    @Sendable
    func getAllTasks(req: Request) async throws -> [TaskDTO] {
        let sortBy = req.query[String.self, at: "sortBy"] ?? "createdAt"
        let order = req.query[String.self, at: "order"] ?? "desc"
        let limit = req.query[Int.self, at: "limit"] ?? 100
        
        let query = Task.query(on: req.db)
        
        // Apply sorting
        switch sortBy {
        case "title":
            query.sort(\.$title, order == "desc" ? .descending : .ascending)
        case "dueDate":
            query.sort(\.$dueDate, order == "desc" ? .descending : .ascending)
        case "priority":
            query.sort(\.$priority, order == "desc" ? .descending : .ascending)
        default:
            query.sort(\.$createdAt, order == "desc" ? .descending : .ascending)
        }
        
        let tasks = try await query.limit(limit).all()
        return tasks.map(TaskDTO.init)
    }
    
    @Sendable
    func createTask(req: Request) async throws -> TaskDTO {
        try CreateTaskRequest.validate(content: req)
        let createRequest = try req.content.decode(CreateTaskRequest.self)
        
        let task = Task(
            title: createRequest.title,
            description: createRequest.description,
            priority: createRequest.priority ?? .medium,
            dueDate: createRequest.dueDate
        )
        
        try await task.save(on: req.db)
        return TaskDTO(from: task)
    }
    
    @Sendable
    func getTask(req: Request) async throws -> TaskDTO {
        guard let task = try await Task.find(req.parameters.get("taskID"), on: req.db) else {
            throw Abort(.notFound, reason: "Task not found")
        }
        return TaskDTO(from: task)
    }
    
    @Sendable
    func updateTask(req: Request) async throws -> TaskDTO {
        guard let task = try await Task.find(req.parameters.get("taskID"), on: req.db) else {
            throw Abort(.notFound, reason: "Task not found")
        }
        
        try UpdateTaskRequest.validate(content: req)
        let updateRequest = try req.content.decode(UpdateTaskRequest.self)
        
        if let title = updateRequest.title {
            task.title = title
        }
        if let description = updateRequest.description {
            task.description = description
        }
        if let isCompleted = updateRequest.isCompleted {
            task.isCompleted = isCompleted
        }
        if let priority = updateRequest.priority {
            task.priority = priority
        }
        if let dueDate = updateRequest.dueDate {
            task.dueDate = dueDate
        }
        
        try await task.save(on: req.db)
        return TaskDTO(from: task)
    }
    
    @Sendable
    func deleteTask(req: Request) async throws -> HTTPStatus {
        guard let task = try await Task.find(req.parameters.get("taskID"), on: req.db) else {
            throw Abort(.notFound, reason: "Task not found")
        }
        
        try await task.delete(on: req.db)
        return .noContent
    }
    
    @Sendable
    func toggleTask(req: Request) async throws -> TaskDTO {
        guard let task = try await Task.find(req.parameters.get("taskID"), on: req.db) else {
            throw Abort(.notFound, reason: "Task not found")
        }
        
        task.isCompleted.toggle()
        try await task.save(on: req.db)
        return TaskDTO(from: task)
    }
    
    @Sendable
    func getCompletedTasks(req: Request) async throws -> [TaskDTO] {
        let tasks = try await Task.query(on: req.db)
            .filter(\.$isCompleted == true)
            .sort(\.$updatedAt, .descending)
            .all()
        return tasks.map(TaskDTO.init)
    }
    
    @Sendable
    func getPendingTasks(req: Request) async throws -> [TaskDTO] {
        let tasks = try await Task.query(on: req.db)
            .filter(\.$isCompleted == false)
            .sort(\.$createdAt, .descending)
            .all()
        return tasks.map(TaskDTO.init)
    }
    
    @Sendable
    func getTasksByPriority(req: Request) async throws -> [TaskDTO] {
        guard let priorityString = req.parameters.get("priority"),
              let priority = Priority(rawValue: priorityString) else {
            throw Abort(.badRequest, reason: "Invalid priority. Must be: low, medium, high, or urgent")
        }
        
        let tasks = try await Task.query(on: req.db)
            .filter(\.$priority == priority)
            .sort(\.$createdAt, .descending)
            .all()
        return tasks.map(TaskDTO.init)
    }
}
