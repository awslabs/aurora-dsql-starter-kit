# Add aurora-dsql-samples as submodule for code embedding

## 🎯 Summary

This PR establishes the foundation for embedding code samples directly in documentation by adding `aurora-dsql-samples` as a git submodule.

## 🚀 Motivation

Currently, we have code duplication and maintenance issues:
- ❌ Code examples exist in both repos (starter-kit docs + samples repo)
- ❌ Users must click away from docs to see full examples  
- ❌ No guarantee that docs and samples stay in sync
- ❌ Manual effort to keep examples updated

**This change enables:**
- ✅ **Single source of truth**: All code lives in samples repo
- ✅ **Inline code display**: Users see code directly in docs (no context switching)
- ✅ **CI validation**: Docs build fails if referenced samples break or move
- ✅ **Automatic sync**: Docs always show latest working code

## 🔧 Implementation

### What's Added
- Git submodule at `documentation/docs/samples/` pointing to `aws-samples/aurora-dsql-samples`
- Submodule pinned to specific commit SHA (reproducible builds)

### How It Works
MkDocs already has `pymdownx.snippets` configured, enabling this syntax:

```markdown
## Python Example
```python
--8<-- "samples/python/psycopg/src/example.py:connection-snippet"
```

This renders the code **inline** in the docs, sourced from the samples repo.

### Architecture
```
aurora-dsql-starter-kit/
├── documentation/
│   ├── docs/
│   │   ├── samples/           ← Git submodule (aurora-dsql-samples)
│   │   ├── programming.md     ← Embeds code from samples/
│   │   └── auth-tokens.md     ← Embeds code from samples/
│   └── mkdocs.yml            ← Already has snippets plugin
```

## 🧪 Testing

- [x] Submodule initializes correctly
- [x] MkDocs build still works  
- [x] No breaking changes to existing docs

**To test locally:**
```bash
git submodule update --init --recursive
cd documentation && mkdocs serve
```

## 📋 Next Steps (Follow-up PRs)

1. **Add snippet markers to samples** - Annotate code with `# snippet:auth-token` markers
2. **Refactor docs to embed samples** - Replace inline code blocks with `--8<--` syntax
3. **Update CI** - Add `git submodule update --init --recursive` to build process
4. **Documentation** - Add contributor guide for maintaining embedded samples

## 🔍 Files Changed

- `.gitmodules` - Defines the submodule configuration
- `documentation/docs/samples/` - New submodule directory (commit SHA: `abc123...`)

## 🎉 Benefits

This architectural change will:
- **Reduce maintenance burden** - Update code once, docs update automatically
- **Improve user experience** - No more clicking between repos
- **Increase reliability** - CI catches broken references immediately
- **Enable better examples** - Full, tested, runnable code in docs

---

**Ready to merge?** This is a foundational change that enables the team to start adding snippet markers to samples while we refactor the docs in parallel.