import Leaf
import FluentPostgreSQL
import Vapor

class DBConfig {
    
    static func dbConfig() -> PostgreSQLDatabaseConfig {
        return PostgreSQLDatabaseConfig(hostname: "localhost", port: 5432, username: "bx2", database: "bx2", password: nil, transport: .cleartext)
    }
    
}

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    let config = DBConfig.dbConfig()
    let postgres = PostgreSQLDatabase(config: config)

    var databases = DatabasesConfig()
    databases.add(database: postgres, as: .psql)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Song.self, database: .psql)
    services.register(migrations)
}
