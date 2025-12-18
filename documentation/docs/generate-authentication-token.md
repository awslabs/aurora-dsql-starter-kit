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
aws dsql generate-db-connect-admin-auth-token \
  --expires-in 3600 \
  --region us-east-1 \
  --hostname your_cluster_endpoint
```

**Note**: If you're not connecting as `admin`, use `generate-db-connect-auth-token` instead.

4. For a complete connection example that generates the token and connects in one step:

--8<-- "samples/authentication-tokens/cli_examples.sh"

5. When the connection is established, you'll see the PostgreSQL prompt: `postgres=>`

## Using the AWS CLI to Generate an Authentication Token

When your cluster is `ACTIVE`, you can generate an authentication token using the `aws dsql` command:

- **Admin role**: Use `generate-db-connect-admin-auth-token`
- **Custom database role**: Use `generate-db-connect-auth-token`

The following example uses these attributes to generate an authentication token for the `admin` role:
- **your_cluster_endpoint**: The endpoint of the cluster (format: `your_cluster_identifier.dsql.region.on.aws`)
- **region**: The AWS Region, such as `us-east-2` or `us-east-1`

**CLI Examples:**
--8<-- "samples/authentication-tokens/cli_examples.sh"

## Using the SDKs to Generate a Token

You can generate an authentication token for your cluster when it is in `ACTIVE` status. The SDK examples use the following attributes to generate an authentication token for the `admin` role:

- **your_cluster_endpoint**: The endpoint of your Aurora DSQL cluster (format: `your_cluster_identifier.dsql.region.on.aws`)
- **region**: The AWS Region in which your cluster is located

### Python SDK

You can generate the token in the following ways:
- **Admin role**: Use `generate_db_connect_admin_auth_token`
- **Custom database role**: Use `generate_connect_auth_token`

--8<-- "samples/authentication-tokens/python_generate_token.py"

For a complete working example, see the [Python authentication token sample](https://github.com/aws-samples/aurora-dsql-samples/tree/main/authentication-tokens/python_generate_token.py).

### C++ SDK

You can generate the token in the following ways:
- **Admin role**: Use `GenerateDBConnectAdminAuthToken`
- **Custom database role**: Use `GenerateDBConnectAuthToken`

```cpp
#include <aws/core/Aws.h>
#include <aws/dsql/DSQLClient.h>
#include <iostream>

using namespace Aws;
using namespace Aws::DSQL;

std::string generateToken(String yourClusterEndpoint, String region) {
    Aws::SDKOptions options;
    Aws::InitAPI(options);
    DSQLClientConfiguration clientConfig;
    clientConfig.region = region;
    DSQLClient client{clientConfig};
    std::string token = "";
    
    // If you are not using the admin role to connect, use GenerateDBConnectAuthToken instead
    const auto presignedString = client.GenerateDBConnectAdminAuthToken(yourClusterEndpoint, region);
    if (presignedString.IsSuccess()) {
        token = presignedString.GetResult();
    } else {
        std::cerr << "Token generation failed." << std::endl;
    }

    std::cout << token << std::endl;

    Aws::ShutdownAPI(options);
    return token;
}
```

### JavaScript SDK

You can generate the token in the following ways:
- **Admin role**: Use `getDbConnectAdminAuthToken`
- **Custom database role**: Use `getDbConnectAuthToken`

--8<-- "samples/authentication-tokens/javascript_generate_token.js"

For a complete working example, see the [JavaScript authentication token sample](https://github.com/aws-samples/aurora-dsql-samples/tree/main/authentication-tokens/javascript_generate_token.js).

### Java SDK

You can generate the token in the following ways:
- **Admin role**: Use `generateDbConnectAdminAuthToken`
- **Custom database role**: Use `generateDbConnectAuthToken`

--8<-- "samples/authentication-tokens/GenerateToken.java"

For a complete working example, see the [Java authentication token sample](https://github.com/aws-samples/aurora-dsql-samples/tree/main/authentication-tokens/GenerateToken.java).

### Rust SDK

You can generate the token in the following ways:
- **Admin role**: Use `db_connect_admin_auth_token`
- **Custom database role**: Use `db_connect_auth_token`

```rust
use aws_config::{BehaviorVersion, Region};
use aws_sdk_dsql::auth_token::{AuthTokenGenerator, Config};

async fn generate_token(your_cluster_endpoint: String, region: String) -> String {
    let sdk_config = aws_config::load_defaults(BehaviorVersion::latest()).await;
    let signer = AuthTokenGenerator::new(
        Config::builder()
            .hostname(&your_cluster_endpoint)
            .region(Region::new(region))
            .build()
            .unwrap(),
    );

    // Use `db_connect_auth_token` if you are _not_ logging in as `admin` user
    let token = signer.db_connect_admin_auth_token(&sdk_config).await.unwrap();
    println!("{}", token);
    token.to_string()
}
```

### Ruby SDK

You can generate the token in the following ways:
- **Admin role**: Use `generate_db_connect_admin_auth_token`
- **Custom database role**: Use `generate_db_connect_auth_token`

```ruby
require 'aws-sdk-dsql'

def generate_token(your_cluster_endpoint, region)
  credentials = Aws::SharedCredentials.new()

  begin
      token_generator = Aws::DSQL::AuthTokenGenerator.new({
          :credentials => credentials
      })
      
      # if you're not using admin role, use generate_db_connect_auth_token instead
      token = token_generator.generate_db_connect_admin_auth_token({
          :endpoint => your_cluster_endpoint,
          :region => region
      })
  rescue => error
    puts error.full_message
  end
end
```

### .NET SDK

**Note**: The official SDK for .NET doesn't include a built-in API call to generate an authentication token for Aurora DSQL. Instead, you must use `DSQLAuthTokenGenerator`, which is a utility class.

You can generate the token in the following ways:
- **Admin role**: Use `DbConnectAdmin`
- **Custom database role**: Use `DbConnect`

```csharp
using Amazon;
using Amazon.DSQL.Util;
using Amazon.Runtime;

var yourClusterEndpoint = "insert-dsql-cluster-endpoint";

AWSCredentials credentials = FallbackCredentialsFactory.GetCredentials();

var token = DSQLAuthTokenGenerator.GenerateDbConnectAdminAuthToken(credentials, RegionEndpoint.USEast1, yourClusterEndpoint);

Console.WriteLine(token);
```

### Golang SDK

**Note**: The Golang SDK doesn't provide a built-in method for generating a pre-signed token. You must manually construct the signed request.

In the following code example, specify the `action` based on the PostgreSQL user:
- **Admin role**: Use the `DbConnectAdmin` action
- **Custom database role**: Use the `DbConnect` action

```go
func GenerateDbConnectAdminAuthToken(yourClusterEndpoint string, region string, action string) (string, error) {
	// Fetch credentials
	sess, err := session.NewSession()
	if err != nil {
		return "", err
	}

	creds, err := sess.Config.Credentials.Get()
	if err != nil {
		return "", err
	}
	staticCredentials := credentials.NewStaticCredentials(
		creds.AccessKeyID,
		creds.SecretAccessKey,
		creds.SessionToken,
	)

	// The scheme is arbitrary and is only needed because validation of the URL requires one.
	endpoint := "https://" + yourClusterEndpoint
	req, err := http.NewRequest("GET", endpoint, nil)
	if err != nil {
		return "", err
	}
	values := req.URL.Query()
	values.Set("Action", action)
	req.URL.RawQuery = values.Encode()

	signer := v4.Signer{
		Credentials: staticCredentials,
	}
	_, err = signer.Presign(req, nil, "dsql", region, 15*time.Minute, time.Now())
	if err != nil {
		return "", err
	}

	url := req.URL.String()[len("https://"):]

	return url, nil
}
```

## Complete Code Examples

For complete, runnable examples with error handling, environment variable setup, and usage instructions, see the [Aurora DSQL Authentication Token Samples](https://github.com/aws-samples/aurora-dsql-samples/tree/main/authentication-tokens).

The samples repository includes:

| Language | File | Description |
|----------|------|-------------|
| **Python** | [`python_generate_token.py`](https://github.com/aws-samples/aurora-dsql-samples/tree/main/authentication-tokens/python_generate_token.py) | Complete Python example using boto3 |
| **JavaScript** | [`javascript_generate_token.js`](https://github.com/aws-samples/aurora-dsql-samples/tree/main/authentication-tokens/javascript_generate_token.js) | Complete JavaScript example using AWS SDK v3 |
| **Java** | [`GenerateToken.java`](https://github.com/aws-samples/aurora-dsql-samples/tree/main/authentication-tokens/GenerateToken.java) | Complete Java example using AWS SDK v2 |
| **CLI** | [`cli_examples.sh`](https://github.com/aws-samples/aurora-dsql-samples/tree/main/authentication-tokens/cli_examples.sh) | CLI examples for all platforms |

Each sample includes:
- ✅ **Error handling** - Proper exception management
- ✅ **Environment variables** - Configurable cluster endpoints and regions  
- ✅ **Both token types** - Admin and custom role examples
- ✅ **Usage instructions** - Step-by-step setup and execution
- ✅ **Integration examples** - How to use tokens with database connections

## Next Steps

Once you have generated an authentication token:

1. **Connect to your cluster** - Use the token as a password with any PostgreSQL-compatible client
2. **Explore programming examples** - See [Programming with Aurora DSQL](programming-with-dsql.md) for database operation examples
3. **Set up database roles** - Learn about [Database Roles and IAM Authentication](database-roles-iam-authentication.md)