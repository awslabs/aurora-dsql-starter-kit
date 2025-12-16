# AWS Labs Aurora DSQL MCP Server

An AWS Labs Model Context Protocol (MCP) server for Aurora DSQL.

## Features

- Converting human-readable questions and commands into structured Postgres-compatible SQL queries and executing them against the configured Aurora DSQL database.
- Read-only by default, transactions enabled with `--allow-writes`
- Connection reuse between requests for improved performance
- Built-in access to Aurora DSQL documentation, search, and best practice recommendations

## Available Tools

### Database Operations

- **readonly_query** - Execute read-only SQL queries against your DSQL cluster
- **transact** - Execute write operations in a transaction (requires `--allow-writes`)
- **get_schema** - Retrieve table schema information

### Documentation and Recommendations

- **dsql_search_documentation** - Search Aurora DSQL documentation
  - Parameters: `search_phrase` (required), `limit` (optional)
- **dsql_read_documentation** - Read specific DSQL documentation pages
  - Parameters: `url` (required), `start_index` (optional), `max_length` (optional)
- **dsql_recommend** - Get recommendations for DSQL best practices
  - Parameters: `url` (required)

## Prerequisites

1. An AWS account with an [Aurora DSQL Cluster](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/getting-started.html)
2. This MCP server can only be run locally on the same host as your LLM client.
3. Set up AWS credentials with access to AWS services
   - You need an AWS account with a role including these permissions:
     - `dsql:DbConnectAdmin` - Connect to DSQL clusters as the admin user
     - `dsql:DbConnect` - Connect to DSQL clusters with custom database roles (only needed if using non-admin users)
   - Configure AWS credentials with `aws configure` or environment variables

## Installation

### Using `uv`

1. Install `uv` from [Astral](https://docs.astral.sh/uv/getting-started/installation/) or the [GitHub README](https://github.com/astral-sh/uv#installation)
2. Install Python using `uv python install 3.10`

Configure the MCP server in your MCP client configuration (e.g., for Amazon Q Developer CLI, edit `~/.aws/amazonq/mcp.json`):

```json
{
  "mcpServers": {
    "awslabs.aurora-dsql-mcp-server": {
      "command": "uvx",
      "args": [
        "awslabs.aurora-dsql-mcp-server@latest",
        "--cluster_endpoint",
        "[your dsql cluster endpoint, e.g. abcdefghijklmnopqrst234567.dsql.us-east-1.on.aws]",
        "--region",
        "[your dsql cluster region, e.g. us-east-1]",
        "--database_user",
        "[your dsql username, e.g. admin]",
        "--profile",
        "default"
      ],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR"
      },
      "disabled": false,
      "autoApprove": []
    }
  }
}
```

### Windows Installation

For Windows users, the MCP server configuration format is slightly different:

```json
{
  "mcpServers": {
    "awslabs.aurora-dsql-mcp-server": {
      "disabled": false,
      "timeout": 60,
      "type": "stdio",
      "command": "uv",
      "args": [
        "tool",
        "run",
        "--from",
        "awslabs.aurora-dsql-mcp-server@latest",
        "awslabs.aurora-dsql-mcp-server.exe"
      ],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR",
        "AWS_PROFILE": "your-aws-profile",
        "AWS_REGION": "us-east-1"
      }
    }
  }
}
```

### Verifying Installation

For Amazon Q Developer CLI, run `/mcp` to see the status of the MCP server.

## Server Configuration Options

### `--allow-writes`

By default, the dsql mcp server does not allow write operations ("read-only mode"). Any invocations of transact tool will fail in this mode. To use transact tool, allow writes by passing `--allow-writes` parameter.

We recommend using least-privilege access when connecting to DSQL. For example, users should use a role that is read-only when possible. The read-only mode has a best-effort client-side enforcement to reject mutations.

### `--cluster_endpoint`

This is mandatory parameter to specify the cluster to connect to. This should be the full endpoint of your cluster, e.g., `01abc2ldefg3hijklmnopqurstu.dsql.us-east-1.on.aws`

### `--database_user`

This is a mandatory parameter to specify the user to connect as. For example `admin`, or `my_user`. Note that the AWS credentials you are using must have permission to login as that user. For more information on setting up and using database roles in DSQL, see [Using database roles with IAM roles](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/using-database-and-iam-roles.html).

### `--profile`

You can specify the aws profile to use for your credentials. Note that this is not supported for docker installation.

Using the `AWS_PROFILE` environment variable in your MCP configuration is also supported:

```json
"env": {
  "AWS_PROFILE": "your-aws-profile"
}
```

If neither is provided, the MCP server defaults to using the "default" profile in your AWS configuration file.

### `--region`

This is a mandatory parameter to specify the region of your DSQL database.

### `--knowledge-server`

Optional parameter to specify the remote MCP server endpoint for DSQL knowledge tools (documentation search, reading, and recommendations). By default it is pre-configured.

Example:

```bash
--knowledge-server https://custom-knowledge-server.example.com
```

**Note:** For security, only use trusted knowledge server endpoints. The server should be an HTTPS endpoint.

### `--knowledge-timeout`

Optional parameter to specify the timeout in seconds for requests to the knowledge server.

Default: `30.0`

Example:

```bash
--knowledge-timeout 60.0
```

Increase this value if you experience timeouts when accessing documentation on slow networks.
