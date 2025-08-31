# System Architecture Document (SAD)
*Last updated: 2025-08-30*

## Table of Contents
1. [Overview](#overview)
2. [Core Principles](#core-principles)
3. [Component Architecture](#component-architecture)
4. [Build System](#build-system)
5. [Workflow Integration](#workflow-integration)
6. [Deployment](#deployment)
7. [Security](#security)
8. [Monitoring](#monitoring)
9. [Future Considerations](#future-considerations)

## Overview
This mono-repo implements a unified development environment that combines Python application development with Infrastructure as Code (IaC) using Terraform, all managed through the Pants build system. The architecture supports both service development and infrastructure provisioning in a single, cohesive codebase.

**Related Documents**:
- [Development Guide](dev.md)
- [Usage Guidelines](usage.md)
- [Module Documentation](index.md#module-documentation)

## Core Principles

### 1. Unified Build System
- **Pants Build System**: Single build tool for both Python and Terraform components
- **Dependency Management**: Centralized dependency resolution and locking
- **Code Quality Gates**: Unified formatting, linting, and testing across all languages

### 2. Modular Component Structure
- **Python Packages**: Reusable libraries in `packages/` directory
- **Services**: Application code in `services/` directory
- **Infrastructure Modules**: Terraform modules in `infra-packages/` directory
- **Templates**: Cookiecutter templates for consistent project/module creation

### 3. Quality Assurance
- **Pre-commit Hooks**: Automated code quality checks
- **CI/CD Pipelines**: GitHub Actions with change detection
- **Testing**: Unit and integration tests for both Python and Terraform code

## Component Architecture

### Python Components

#### Package Structure (`packages/`)
```
packages/
├── your_package/
│   ├── BUILD              # Pants build configuration
│   ├── pyproject.toml     # Python package metadata
│   ├── src/
│   │   └── your_package/
│   │       ├── __init__.py
│   │       └── module.py
│   └── tests/
│       └── test_module.py
```

**Key Characteristics:**
- Standard Python package layout
- Pants BUILD files for build configuration
- Isolated testing with dedicated test directories
- Dependency management through Pants resolves

#### Service Structure (`services/`)
```
services/
├── your_service/
│   ├── BUILD
│   ├── pyproject.toml
│   ├── src/
│   │   └── your_service/
│   └── tests/
```

**Key Characteristics:**
- Similar to packages but focused on runnable applications
- May include additional configuration files (Docker, deployment configs)
- Integration with infrastructure components

### Infrastructure Components

#### Terraform Module Structure (`infra-packages/`)
```
infra-packages/
├── aws/
│   └── your_module/
│       ├── BUILD              # Pants Terraform configuration
│       ├── main.tf            # Main Terraform configuration
│       ├── variables.tf       # Input variable definitions
│       ├── outputs.tf         # Output definitions
│       ├── versions.tf        # Provider/Terraform version constraints
│       ├── README.md          # Module documentation
│       └── test.tftest.hcl    # Terraform test configuration
```

**Key Characteristics:**
- AWS-focused infrastructure modules
- Standard Terraform module structure
- Pants integration for build and testing
- Comprehensive documentation and examples

## Build System

### Pants Configuration

The `pants.toml` file defines the build system behavior:

```toml
[GLOBAL]
backend_packages = [
    "pants.backend.python",
    "pants.backend.docker",
    "pants.backend.experimental.terraform",
]
pants_version = "2.27.0"

[python]
interpreter_constraints = [">=3.11,<3.12"]
enable_resolves = true
default_resolve = "python-default"

[download-terraform]
version = "1.13.0"
```

### Dependency Resolution

#### Python Dependencies
- Managed through `3rdparty/python/` directory
- Locked versions for reproducible builds
- Pants resolves handle transitive dependencies

#### Terraform Dependencies
- Provider versions pinned in `versions.tf` files
- Terraform version managed by Pants
- Module dependencies through source references

## Workflow Integration

### Code Quality Pipeline

1. **Local Development**
   - Pre-commit hooks for immediate feedback
   - Pants commands for formatting/linting/testing
   - Change detection for efficient development

2. **CI/CD Integration**
   - GitHub Actions workflows
   - Docker-based CI environment
   - Parallel execution with change detection

### Version Control Strategy

- **Monorepo Structure**: Single repository for all components
- **Branch Strategy**: Feature branches with PR-based workflow
- **Release Strategy**: Coordinated releases across Python and Terraform components

## Deployment

### Multi-Environment Support

The architecture supports multiple deployment environments:
- **Development**: Local development and testing
- **Staging**: Pre-production validation
- **Production**: Live deployment environment

### Infrastructure as Code Patterns

- **Immutable Infrastructure**: Resources recreated rather than modified
- **Configuration Management**: All configuration in version control
- **Automated Testing**: Terraform tests validate module behavior

## Security

### Code Security
- **Dependency Scanning**: Automated vulnerability detection
- **Code Review Requirements**: Mandatory reviews for infrastructure changes
- **Access Control**: GitHub branch protection and CODEOWNERS

### Infrastructure Security
- **Least Privilege**: IAM roles with minimal required permissions
- **Encryption**: Data at rest and in transit encryption
- **Compliance**: AWS compliance frameworks integration

## Monitoring

### Application Monitoring
- **Logging**: Structured logging with correlation IDs
- **Metrics**: Application performance metrics
- **Tracing**: Distributed tracing across services

### Infrastructure Monitoring
- **CloudWatch**: AWS service monitoring and alerting
- **Terraform State**: Infrastructure state tracking
- **Cost Monitoring**: Resource usage and cost tracking

## Future Considerations

### Scalability
- **Horizontal Scaling**: Support for multiple AWS regions
- **Microservices Evolution**: Potential decomposition into separate repositories
- **Multi-Cloud Support**: Extension to other cloud providers

### Technology Evolution
- **Python Version Updates**: Migration paths for Python version upgrades
- **Terraform Version Updates**: Compatibility testing for new Terraform versions
- **Build System Evolution**: Pants version upgrades and feature adoption

This architecture provides a solid foundation for developing, testing, and deploying both Python applications and Terraform infrastructure in a unified, maintainable manner.
