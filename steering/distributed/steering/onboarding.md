---
inclusion: manual
---

# DSQL Database Get Started Guide

## Overview

This guide provides steps to help users get started with DSQL in their project. It sets up their DSQL project (with a connection string) and connects their database to their code by understanding the context within the codebase.

## Use Case

These guidelines apply when users say "Get started with DSQL" or similar phrases. The user's codebase may be mature (with existing database connections) or have little to no code - the guidelines should apply to both cases.

## Communication Style

**Keep all responses succinct:**
- ALWAYS tell the user what you did. 
  - Responses MUST be concise and concrete. 
  - ALWAYS contain descriptions to necessary steps. 
  - ALWAYS remove unnecessary verbiage. 
  - Example:
    - "Created an inventory table with 4 columns"
    - "Updated the product column to be NOT NULL"
- Ask direct questions when needed:
  - User ambiguity SHOULD result in questions. 
  - MUST clarify incompatible user decisions
  - Example: 
    - "What column names would you like in this table?"
    - "What is the column name of the primary key?"
    - "JSON must be serialized. Would you like to stringify the JSON to serialize it as TEXT?"


---

## Get Started with DSQL (Interactive Guide)

**TRIGGER PHRASE:** When the user says "Get started with DSQL" or similar phrases, provide an interactive onboarding experience by following these steps:

**Before starting:** Let the user know they can pause and resume anytime by saying "Continue with DSQL setup" if they need to come back later.

**RESUME TRIGGER:** If the user says "Continue with DSQL setup" or similar, check what's already configured (MCP server, .env, dependencies, schema) and resume from where they left off. Ask them which step they'd like to continue from or analyze their setup to determine automatically.

### Step 1: Check for an Existing Cluster

**First, check for organizations:**

Use the DSQL MCP Server to check the user's cluster endpoint if it exists

**If they have a cluster:**

TODO: Fill in with steps moving to operating with the cluster

**If no cluster is configured:**

TODO: Fill in with steps using the AWS CLI or Console to teach the user how to make their cluster. 