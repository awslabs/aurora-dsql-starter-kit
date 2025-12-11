# Aurora DSQL Documentation

This directory contains the documentation for Amazon Aurora DSQL, built using [MkDocs](https://www.mkdocs.org/) with the Material theme.

## Prerequisites

- Python 3.10+
- pip or uv

## Setup

### Option 1: Using a Virtual Environment (Recommended)

```bash
# Create a virtual environment
python3 -m venv venv

# Activate the virtual environment
source venv/bin/activate  # On macOS/Linux
# or
venv\Scripts\activate  # On Windows

# Install dependencies
pip install mkdocs mkdocs-material pymdown-extensions
```

### Option 2: Using uv

```bash
uv pip install mkdocs mkdocs-material pymdown-extensions
```

## Building the Documentation

To generate the static site:

```bash
mkdocs build
```

This will create the site in the `site` directory.

## Previewing the Documentation

To run a local development server with live reload:

```bash
mkdocs serve
```

This will start a server at [http://127.0.0.1:8000/](http://127.0.0.1:8000/) for previewing the documentation.
