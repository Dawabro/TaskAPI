import Vapor
import Fluent

final class Task: Model, Content, @unchecked Sendable {
    static let schema = "tasks"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "description")
    var description: String?
    
    @Field(key: "is_completed")
    var isCompleted: Bool
    
    @Field(key: "priority")
    var priority: Priority
    
    @Field(key: "due_date")
    var dueDate: Date?
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() { }
    
    init(id: UUID? = nil, title: String, description: String? = nil,
         priority: Priority = .medium, dueDate: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = false
        self.priority = priority
        self.dueDate = dueDate
    }
}

enum Priority: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case urgent = "urgent"
}

// MARK: - Data Transfer Objects
struct TaskDTO: Content {
    let id: UUID?
    let title: String
    let description: String?
    let isCompleted: Bool
    let priority: Priority
    let dueDate: Date?
    let createdAt: Date?
    let updatedAt: Date?
    
    init(from task: Task) {
        self.id = task.id
        self.title = task.title
        self.description = task.description
        self.isCompleted = task.isCompleted
        self.priority = task.priority
        self.dueDate = task.dueDate
        self.createdAt = task.createdAt
        self.updatedAt = task.updatedAt
    }
}

struct CreateTaskRequest: Content, Validatable {
    let title: String
    let description: String?
    let priority: Priority?
    let dueDate: Date?
    
    static func validations(_ validations: inout Validations) {
        validations.add("title", as: String.self, is: !.empty)
    }
}

struct UpdateTaskRequest: Content, Validatable {
    let title: String?
    let description: String?
    let isCompleted: Bool?
    let priority: Priority?
    let dueDate: Date?
    
    static func validations(_ validations: inout Validations) {
        validations.add("title", as: String.self, is: !.empty, required: false)
    }
}
