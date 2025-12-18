{% include 'copy-page-script.md' %}
{% include 'copy-page-button.md' %}

# Generating an Authentication Token in Amazon Aurora DSQL

## Overview

To connect to Amazon Aurora DSQL with a SQL client, generate an authentication token to use as the password. This token is used only for authenticating the connection. After the connection is established, the connection remains valid even if the authentication token expires.

## Token Expiration and Duration

- **AWS Console**: Token automatically expires in one hour by default
- **CLI or SDKs**: Default is 15 minutes
- **Maximum duration**: 604,800 seconds (one week)

To connect to Aurora DSQL from your client again, you can use the same authentication token if it hasn't expired, or you can generate a new one.

## Prerequisites

To get started with generating a token:
1. [Create an IAM policy](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_create-console.html)
2. [Create a cluster in Aurora DSQL](https://docs.aws.amazon.com/aurora-dsql/latest/userguide/getting-started.html#getting-started-quickstart)

At a minimum, you must have the IAM permissions for connecting to clusters, depending on which database role you use to connect.

## Using the AWS Console to Generate an Authentication Token

Aurora DSQL authenticates users with a token rather than a password. You can generate the token from the console.

**To generate an authentication token:**

1. Sign in to the AWS Console and open the Aurora DSQL console at [https://console.aws.amazon.com/dsql](https://console.aws.amazon.com/dsql)

2. Choose the cluster ID of the cluster for which you want to generate an authentication token

3. Choose **Connect** and then select **Get Token**

4. Choose whether you want to connect as an `admin` or with a custom database role

5. Copy the generated authentication token and use it for connecting with SQL clients

## Using AWS CloudShell to Generate an Authentication Token

Before you can generate an authentication token using CloudShell, make sure that you have created an Aurora DSQL cluster.

**To generate an authentication token using CloudShell:**

1. Sign in to the AWS Console and open the Aurora DSQL console at [https://console.aws.amazon.com/dsql](https://console.aws.amazon.com/dsql)

2. At the bottom left of the AWS console, choose **CloudShell**

3. Run the following command to generate an authentication token for the `admin` role:

```bash
--8<-- "samples/cli/authentication/generate_token.sh:cloudshell-admin-token"
```

**Note**: If you're not connecting as `admin`, use `generate-db-connect-auth-token` instead.

4. Use the following command to use `psql` to start a connection to your cluster:

```bash
--8<-- "samples/cli/authentication/generate_token.sh:cloudshell-psql-connection"
```

5. When prompted for a password, paste the generated token

6. Press **Enter** to see the PostgreSQL prompt: `postgres=>`

## Using the AWS CLI to Generate an Authentication Token

When your cluster is `ACTIVE`, you can generate an authentication token using the `aws dsql` command:

- **Admin role**: Use `generate-db-connect-admin-auth-token`
- **Custom database role**: Use `generate-db-connect-auth-token`

The following example uses these attributes to generate an authentication token for the `admin` role:
- **your_cluster_endpoint**: The endpoint of the cluster (format: `your_cluster_identifier.dsql.region.on.aws`)
- **region**: The AWS Region, such as `us-east-2` or `us-east-1`

**Linux and macOS:**
```bash
--8<-- "samples/cli/authentication/generate_token.sh:cli-linux-macos"
```

**Windows:**
```bash
--8<-- "samples/cli/authentication/generate_token.sh:cli-windows"
```

## Using the SDKs to Generate a Token

You can generate an authentication token for your cluster when it is in `ACTIVE` status. The SDK examples use the following attributes to generate an authentication token for the `admin` role:

- **your_cluster_endpoint**: The endpoint of your Aurora DSQL cluster (format: `your_cluster_identifier.dsql.region.on.aws`)
- **region**: The AWS Region in which your cluster is located

### Python SDK

You can generate the token in the following ways:
- **Admin role**: Use `generate_db_connect_admin_auth_token`
- **Custom database role**: Use `generate_connect_auth_token`

```python
--8<-- "samples/python/authentication/src/generate_token.py:python-generate-token"
```

### C++ SDK

You can generate the token in the following ways:
- **Admin role**: Use `GenerateDBConnectAdminAuthToken`
- **Custom database role**: Use `GenerateDBConnectAuthToken`

```cpp
--8<-- "samples/cpp/authentication/src/GenerateToken.cpp:cpp-generate-token"
```

### JavaScript SDK

You can generate the token in the following ways:
- **Admin role**: Use `getDbConnectAdminAuthToken`
- **Custom database role**: Use `getDbConnectAuthToken`

```javascript
--8<-- "samples/javascript/authentication/src/generate_token.js:javascript-generate-token"
```

### Java SDK

You can generate the token in the following ways:
- **Admin role**: Use `generateDbConnectAdminAuthToken`
- **Custom database role**: Use `generateDbConnectAuthToken`

```java
--8<-- "samples/java/authentication/src/main/java/org/example/GenerateToken.java:java-generate-token"
```

### Rust SDK

You can generate the token in the following ways:
- **Admin role**: Use `db_connect_admin_auth_token`
- **Custom database role**: Use `db_connect_auth_token`

```rust
--8<-- "samples/rust/authentication/src/bin/generate_token.rs:rust-generate-token"
```

### Ruby SDK

You can generate the token in the following ways:
- **Admin role**: Use `generate_db_connect_admin_auth_token`
- **Custom database role**: Use `generate_db_connect_auth_token`

```ruby
--8<-- "samples/ruby/authentication/lib/generate_token.rb:ruby-generate-token"
```

### .NET SDK

**Note**: The official SDK for .NET doesn't include a built-in API call to generate an authentication token for Aurora DSQL. Instead, you must use `DSQLAuthTokenGenerator`, which is a utility class.

You can generate the token in the following ways:
- **Admin role**: Use `DbConnectAdmin`
- **Custom database role**: Use `DbConnect`

```csharp
--8<-- "samples/dotnet/authentication/examples/GenerateToken/GenerateToken.cs:dotnet-generate-token"
```

### Golang SDK

**Note**: The Golang SDK doesn't provide a built-in method for generating a pre-signed token. You must manually construct the signed request.

In the following code example, specify the `action` based on the PostgreSQL user:
- **Admin role**: Use the `DbConnectAdmin` action
- **Custom database role**: Use the `DbConnect` action

```go
--8<-- "samples/go/authentication/cmd/generate_token/generate_token.go:go-generate-token"
```
