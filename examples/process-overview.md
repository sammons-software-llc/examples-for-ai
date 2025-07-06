# Development Process Overview

Use this process when user request contains: ["build", "create", "implement", "develop", "new feature", "add"]

## Process Flow

**Phase 1: Setup & Architecture** (Steps 1-5)
1. **Identify Project Archetype** - Determine project type (static site, local app, serverless, component)
2. **Repository Setup** - Create repo with branch protection via gh CLI
3. **Expert Agent Initialization** - Spawn 4 agents (Architect, Security, Designer, Performance)
4. **Dependency Verification** - Check versions and compatibility
5. **Project Board Creation** - Set up task tracking with gh CLI

**Phase 2: Planning** (Steps 6-8)
6. **Task Decomposition** - Break features into <8 hour tasks with acceptance criteria
7. **Task Prioritization** - Add dependencies and labels via gh CLI
8. **Sprint Planning** - Group into implementation waves

**Phase 3: Implementation** (Steps 9-13)
9. **Pre-Development Setup** - Node.js via mise, pnpm, pre-commit hooks
10. **Test-Driven Development** - Write failing tests first, then implement
11. **Implementation with Validation** - Continuous lint/type/test checking
12. **Performance Validation** - API <500ms, UI <16ms render time
13. **Documentation** - Update API docs and README during development

**Phase 4: Quality Assurance** (Steps 14-16)
14. **Pre-PR Validation** - All checks must pass before PR creation
15. **Pull Request Creation** - Structured commit messages and PR templates
16. **Automated PR Checks** - GitHub Actions for all validations

**Phase 5: Review & Iteration** (Steps 17-19)
17. **Multi-Persona Expert Review** - 4 experts review with specific focus
18. **Developer Response Protocol** - Structured feedback addressing
19. **Final Validation Round** - Re-run all tests and load testing

**Phase 6: Deployment** (Step 20)
20. **Merge and Post-Merge** - Deploy, monitor, update documentation

## Key Principles

- **Test-Driven Development**: Write tests first, implement to pass
- **Continuous Validation**: Check every 10 minutes during development
- **Expert Review**: 4 specialized personas review each PR
- **Performance First**: Define and meet performance benchmarks
- **Documentation**: Update docs during development, not after

## Success Metrics

- **Test Coverage**: >90% on all new code
- **Performance**: API endpoints <500ms, UI renders <16ms
- **Security**: No moderate+ vulnerabilities in audit
- **Quality**: 0 lint errors, 0 type errors
- **Documentation**: API docs and README updated for each feature

## For Complex Projects

When dealing with complex projects (>5 features, >2 week timeline), also load:
- `./examples/development-phases.md` for detailed phase breakdown
- `./examples/validation-checklists.md` for comprehensive quality gates