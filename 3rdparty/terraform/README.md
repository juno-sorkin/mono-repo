# Terraform Dependency Management

## Purpose
This directory exists to:
- Maintain structural consistency across the mono-repo
- Avoid confusion about Terraform dependency locations

## Dependency Structure
Terraform manages dependencies differently than traditional packages:

1. **Public Modules**:
   - Wrapped in [`infra-packages/aws`](../../infra-packages/aws)
   - Versioned in each module's `versions.tf`

2. **Providers**:
   - AWS provider configured in module definitions
   - Version constraints in `versions.tf` files

3. **Terraform itself**:
   - Pinned in [`pants.toml`](../../pants.toml)
   - pinned version: `>= 1.13.0`

4. **Terraform's tools**:
   - declared in ['../tools'](../../tools)

## Related Documentation
- [Provider & Module Details](../../infra-packages/aws/docs/deps.md)
- [Global Documentation](../../docs)
- [Project Overview](../../README.md)
