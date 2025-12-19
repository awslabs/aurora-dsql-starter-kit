{% include 'copy-page-script.md' %}
{% include 'copy-page-button.md' %}

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

For most tools, updating the configuration by following the [Default Installation](#default-installation-updating-the-relevant-mcp-config-file) instructions should be sufficient. 

Separate instructions are outlined for [Claude Code](#claude-code) and [Codex](#codex). 

### Default Installation: Updating the Relevant MCP Config File

#### Using `uv`

1. Install `uv` from [Astral](https://docs.astral.sh/uv/getting-started/installation/) or the [GitHub README](https://github.com/astral-sh/uv#installation)
2. Install Python using `uv python install 3.10`

Configure the MCP server in your MCP client configuration ([Finding the MCP Config File](#finding-the-mcp-client-configuration-file))

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

#### Windows Installation

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

#### Finding the MCP Client Configuration File
For some of the most common Agentic development tools, you can find your MCP client configurations 
at the following file paths:

- Kiro:
  - User Config: `~/.kiro/settings/mcp.json`
  - Workspace Config: `/path/to/workspace/.kiro/settings/mcp.json`
- Claude Code: Refer to [Claude Code Installation](#claude-code) for detailed setup help
  - User Config: `~/.claude.json` in `"mcpServers"`
  - Project Config: `/path/to/project/.mcp.json`
  - Local Config: `~/.claude.json` in `"projects" -> "path/to/project" -> "mcpServers"`
- Cursor:
  - Global: `~/.cursor/mcp.json`
  - Project: `/path/to/project/.cursor/mcp.json`
- Codex: `~/.codex/config.toml`
  - Each MCP server is configured with a [mcp_servers.<server-name>] table in the config file. Refer to
    the [Custom Codex Installation Instructions](#codex)
- Warp:
  - File Editing: `~/.warp/mcp_settings.json`
  - Application Editor: `Settings > AI > Manage MCP Servers` and paste json
- Amazon Q Developer CLI: `~/.aws/amazonq/mcp.json`
- Cline: Usually a nested VS Code path - `~/.vscode-server/path/to/cline_mcp_settings.json` 

### Claude Code

#### Prerequisites

**Important:** MCP server management is only available through the Claude Code CLI terminal experience, not the VS Code native panel mode.

Install the Claude Code CLI first by following Claude’s [native installation recommended process](https://code.claude.com/docs/en/setup#native-install-recommended). 

#### Choosing the Right Scope

Claude Code offers 3 different scopes: local (default), project, and user and details which scope to choose based on credential sensitivity and need to share. Refer to the Claude Code documentation on [MCP Installation Scopes](https://code.claude.com/docs/en/mcp#mcp-installation-scopes)for more details.  

1. **Local-scoped** servers represent the default configuration level and are stored in `~/.claude.json` under your project’s path. They’re **both** private to you and only accessible within the current project directory. This is the default `scope` when creating MCP servers. 
2. **Project-scoped** servers **enable team collaboration** while still only being accessible in a project directory. Project-scoped servers add a `.mcp.json` file at your project’s root directory. This file is designed to be checked into version control, ensuring all team members have access to the same MCP tools and services. When you add a project-scoped server, Claude Code automatically creates or updates this file with the appropriate configuration structure.
3. **User-scoped** servers are stored in `~/.claude.json` and **provide cross-project accessibility**, making them available across all projects on your machine while remaining **private to your user account.** 

#### Using the Claude CLI (recommended)

Using an interactive `claude` CLI session enables an improved troubleshooting experience, 
so this is the recommended path. 

```
claude mcp add amazon-aurora-dsql \
  --scope [one of local, project, or user] \
  --env FASTMCP_LOG_LEVEL="ERROR" \
  -- uvx "awslabs.aurora-dsql-mcp-server@latest" \
  --cluster_endpoint "[dsql-cluster-id].dsql.[region].on.aws" \
  --region "[dsql cluster region, eg. us-east-1]" \
  --database_user "[your-username]"
```

##### **Troubleshooting: Using Claude Code with Bedrock on a different AWS Account**

If you've configured Claude Code with a Bedrock AWS account or profile that is
distinct from the profile needed to connect to your dsql cluster, you'll need to 
provide additional environment arguments:

```
  --env AWS_PROFILE="[dsql profile, eg. default]" \
  --env AWS_REGION="[dsql cluster region, eg. us-east-1]" \
```

#### Direct Modification in the Configuration File 
Claude Code Requires alphanumeric naming, so we recommend naming your server:
`aurora-dsql-mcp-server`. 

##### Local-Scope
Update `~/.claude.json` within the project-specific `mcpServers` field:

```json
{
  "projects": {
    "/path/to/project": {
      "mcpServers": {}
    }
  }
}
```

##### Project-Scope
Update `/path/to/project/root/.mcp.json` in the `mcpServers` field:

```json
{
  "mcpServers": {}
}
```

##### User-Scope
Update `~/.claude.json` within the project-specific `mcpServers` field:

```json
{
  "mcpServers": {}
}
```

### Codex

#### Option 1: Codex CLI
If you have the Codex CLI installed, you can use the codex mcp command to configure your MCP servers.

```bash
codex mcp add amazon-aurora-dsql \
  --env FASTMCP_LOG_LEVEL="ERROR" \
  -- uvx "awslabs.aurora-dsql-mcp-server@latest" \
  --cluster_endpoint "[dsql-cluster-id].dsql.[region].on.aws" \
  --region "[dsql cluster region, eg. us-east-1]" \
  --database_user "[your-username]"
```

#### Option 2: config.toml
For more fine grained control over MCP server options, you can manually edit the ~/.codex/config.toml configuration file. Each MCP server is configured with a `[mcp_servers.<server-name>]` table in the config file.

```toml 
[mcp_servers.amazon-aurora-dsql]
command = "uvx"
args = [
  "awslabs.aurora-dsql-mcp-server@latest",
  "--cluster_endpoint", "<DSQL_CLUSTER_ID>.dsql.<AWS_REGION>.on.aws",
  "--region", "<AWS_REGION>",
  "--database_user", "<DATABASE_USERNAME>"
]

[mcp_servers.amazon-aurora-dsql.env]
FASTMCP_LOG_LEVEL = "ERROR"
```

### Verifying Installation

For Amazon Q Developer CLI, Kiro CLI, Claude CLI/TUI, or Codex CLI/TUI, run `/mcp` to see the status 
of the MCP server.

For the Kiro IDE, you can also navigate to the Kiro Panel's `MCP SERVERS` tab which shows 
all configured MCP servers and their connection status indicators. 


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
