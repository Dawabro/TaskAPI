import Fluent

struct CreateTask: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("tasks")
            .id()
            .field("title", .string, .required)
            .field("description", .string)
            .field("is_completed", .bool, .required, .custom("DEFAULT FALSE"))
            .field("priority", .string, .required, .custom("DEFAULT 'medium'"))
            .field("due_date", .datetime)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema("tasks").delete()
    }
}
