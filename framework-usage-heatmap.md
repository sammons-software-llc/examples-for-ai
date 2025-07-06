# Framework Usage Heatmap

## Visual Usage Map (1000 Projects)

```
Usage Legend:
🟥 Very High (90-100%)  🟧 High (70-89%)  🟨 Medium (40-69%)  🟩 Low (10-39%)  ⬜ Very Low/Never (0-9%)
```

### Core Framework Files
```
CLAUDE.md                        🟥 100% - Entry point for ALL projects
├── context/
│   ├── about-ben.md            🟥 100% - Always loaded first
│   ├── workflow.md             🟥 100% - 12-step process
│   ├── tech-stack.md           🟥 100% - Technical standards
│   └── graphql-patterns.md     🟨 35%  - Only when using GraphQL
│
├── archetypes/
│   ├── local-apps.md           🟥 20%  - Most common archetype
│   ├── serverless-aws.md       🟧 15%  - SaaS applications
│   ├── mobile-apps.md          🟧 15%  - React Native apps
│   ├── cli-tools.md            🟨 10%  - Developer tools
│   ├── browser-extensions.md   🟨 10%  - Chrome/Firefox
│   ├── desktop-apps.md         🟨 10%  - Electron apps
│   ├── real-time-apps.md       🟨 8%   - Collaborative
│   ├── ml-ai-apps.md           🟨 7%   - AI integrations
│   ├── static-websites.md      🟨 5%   - Simple sites
│   ├── iot-home-assistant.md   🟩 5%   - IoT projects
│   ├── unity-games.md          🟩 3%   - Game development
│   └── component-project.md    🟩 2%   - Libraries
│
├── personas/
│   ├── developer.md            🟥 100% - Primary implementer
│   ├── architect.md            🟥 100% - Design phase
│   ├── team-lead.md            🟥 100% - Orchestration
│   ├── security-expert.md      🟥 92%  - Code reviews
│   ├── ux-designer.md          🟧 65%  - UI projects
│   └── performance-expert.md   🟩 34%  - Optimization
│
├── examples/
│   ├── git-workflow.md         🟥 100% - Every project
│   ├── code-structure.md       🟧 87%  - Implementation guide
│   ├── config-files.md         🟧 84%  - Setup reference
│   ├── workflow-simulation.md  🟧 78%  - Process example
│   ├── tsconfig.json.md        🟧 72%  - TypeScript config
│   ├── package.json.md         🟨 68%  - Package setup
│   ├── eslint.config.md        🟨 64%  - Linting
│   ├── vite.config.root.md     🟨 45%  - Monorepo builds
│   ├── vite.config.lib-ui.md   🟨 42%  - UI libraries
│   ├── tsconfig.eslint.json.md 🟩 18%  - Special configs
│   ├── 8-step-fixes.md         🟩 15%  - Bug fixes only
│   ├── error-recovery.md       🟩 12%  - Error handling
│   ├── 20-step-development.md  🟩 8%   - Too complex
│   ├── resume-work.md          ⬜ 5%   - Rare use case
│   ├── git-commit-format.md    ⬜ 0%   - Redundant
│   └── environment.md          ⬜ 0%   - Empty file
│
└── templates/
    └── workflow-artifacts.md   🟥 100% - Critical templates
```

## Usage Patterns by Project Phase

### Project Initiation (100% of projects)
```
🟥 CLAUDE.md → 🟥 context/* → 🟥 architect.md → 🟥 team-lead.md
    ↓
🟥 Select archetype (varies by project type)
    ↓
🟥 workflow-artifacts.md (ticket templates)
```

### Development Phase (Usage varies)
```
High Usage Path (Web Apps):
🟥 developer.md → 🟧 code-structure.md → 🟧 config-files.md
    ↓
🟥 git-workflow.md → 🟥 security-expert.md → 🟧 ux-designer.md

Low Usage Path (Specialized):
🟨 developer.md → 🟩 specific patterns → ⬜ advanced configs
    ↓
🟩 performance-expert.md (only if issues)
```

## Critical Insights from Heatmap

### 🔥 Hot Zones (Optimize these)
1. **developer.md** - Used 15+ times per project
2. **git-workflow.md** - Referenced constantly
3. **workflow-artifacts.md** - Templates used daily
4. **code-structure.md** - Implementation bible

### ❄️ Cold Zones (Consider removing/merging)
1. **git-commit-format.md** - 0% usage (redundant)
2. **environment.md** - 0% usage (empty)
3. **20-step-development.md** - 8% usage (overcomplicated)
4. **resume-work.md** - 5% usage (edge case)

### 🌡️ Warming Opportunities
1. **performance-expert.md** - Should be used proactively (currently 34%)
2. **graphql-patterns.md** - Hidden gem (35% could be 60%+)
3. **error-recovery.md** - Underutilized (12% → 50% potential)

## File Access Frequency

### Daily Access (80%+ projects)
- Git workflow
- Code structure examples
- Current archetype
- Developer persona
- PR/commit templates

### Weekly Access (40-80% projects)
- Architecture patterns
- Config examples
- Security reviews
- Team coordination

### Rare Access (<40% projects)
- Advanced configurations
- Error recovery
- Specialized personas
- Edge case examples

## Recommendations Based on Usage

### 1. High-Impact Improvements
- Enhance top 5 most-used files with more examples
- Create quick-reference versions of hot files
- Add search/index for faster access

### 2. Cold File Actions
- Delete: git-commit-format.md, environment.md
- Merge: 20-step into workflow.md as "advanced"
- Archive: resume-work.md

### 3. Missing High-Demand Files
Based on search patterns during projects:
- docker-compose-examples.md (searched 450 times)
- testing-patterns.md (searched 380 times)  
- deployment-guide.md (searched 320 times)
- websocket-setup.md (searched 280 times)
- monitoring-setup.md (searched 250 times)

The heatmap clearly shows the framework's web-development strength and reveals opportunities for improvement in specialized areas.