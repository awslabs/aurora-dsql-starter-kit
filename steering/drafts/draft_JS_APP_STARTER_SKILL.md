---
name: dsql-javascript-app
description: Guide for developing DSQL applications using JavaScript following AWS Golden Path patterns. Use when building new applications that utilize Amazon Aurora DSQL, including connection setup with aurora-dsql-nodejs-connector, IAM authentication, schema creation, query patterns, and best practices.
---

# DSQL JavaScript Application Development

This skill guides you through creating JavaScript applications that use Amazon Aurora DSQL, following AWS Golden Path patterns for secure, scalable database applications.

## Core Components

### 1. Connection Setup

- **Use `@aws/aurora-dsql-nodejs-connector`** as the preferred connection method
- This connector handles IAM authentication automatically
- Works with standard PostgreSQL clients (pg, node-postgres)
- Manages token refresh and connection lifecycle
- Configure connection pooling for production applications

### 2. IAM Authentication

- The aurora-dsql-nodejs-connector handles IAM auth automatically
- No manual token generation required
- Uses AWS credentials from environment or IAM roles
- Automatically refreshes authentication tokens
- Supports all standard AWS credential providers

### 3. Schema Creation

- Design schemas following DSQL best practices
- Use migrations for schema version control
- Implement proper indexing strategies
- Consider multi-tenant patterns when applicable

### 4. Query Patterns

- Use parameterized queries to prevent SQL injection
- Implement connection pooling for efficient resource usage
- Handle transactions appropriately
- Use prepared statements for repeated queries
- Implement proper error handling and retry logic
- **IMPORTANT**: `FOR UPDATE` can only be applied to a single table, not joins. Lock tables separately if needed

### 5. Best Practices

- Enable query logging for debugging and monitoring
- Implement health checks for database connectivity
- Use connection timeouts to prevent hanging requests
- Handle connection failures gracefully with exponential backoff
- Monitor query performance and optimize slow queries
- Implement proper cleanup in error scenarios

## Application Structure

```
project/
├── src/
│   ├── config/
│   │   └── database.js       # Connection configuration
│   ├── db/
│   │   ├── client.js         # Database client with DSQL connector
│   │   └── migrations/       # Schema migrations
│   ├── models/               # Data models
│   └── services/             # Business logic
├── .env.example              # Environment template
└── package.json
```

## Key Dependencies

- `@aws/aurora-dsql-nodejs-connector` - Official DSQL connector (preferred)
- `pg` - PostgreSQL client (DSQL is PostgreSQL-compatible)
- `dotenv` - Environment configuration
- Consider: `knex` or `sequelize` for query building/ORM

## Basic Connection Example

```javascript
import { AuroraDSQLPool } from "@aws/aurora-dsql-node-postgres-connector";

const pool = new AuroraDSQLPool({
  host: "your-cluster.dsql.us-east-1.on.aws",
  user: "admin",
  max: 20,
  idleTimeoutMillis: 30000,
});

// Use the pool for queries
const result = await pool.query("SELECT NOW()");
```

```

## Security Considerations

- Never hardcode credentials
- Use IAM roles and temporary credentials
- Implement least privilege access
- Enable encryption in transit (handled by connector)
- Audit database access patterns
- The connector manages credential rotation automatically

## Error Handling

- Catch and handle connection errors
- Implement retry logic for transient failures
- Log errors with appropriate context
- Return user-friendly error messages
- Monitor error rates and patterns
- Handle token refresh failures gracefully

## Testing

- Use test databases for development
- Mock database connections in unit tests
- Implement integration tests with real DSQL instances
- Test connection failure scenarios
- Validate IAM authentication flow

## When to Use This Skill

Use this skill when:
- Creating a new application that uses Amazon Aurora DSQL
- Setting up database connections with the official Node.js connector
- Implementing DSQL query patterns in JavaScript/Node.js
- Following AWS Golden Path for database applications
- Migrating existing PostgreSQL applications to DSQL
- Building applications with React, Angular, Vue.js, Next.js, or Express.js that need DSQL integration

## Reference

- Official connector: https://github.com/awslabs/aurora-dsql-nodejs-connector
```
