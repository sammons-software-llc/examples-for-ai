=== CONTEXT ===
CLI tool archetype for command-line applications distributed via npm or binaries.
Focuses on developer experience with helpful output and cross-platform support.

=== OBJECTIVE ===
Build user-friendly CLI tools that are easy to install and use.
Success metrics:
□ <100ms startup time
□ Helpful error messages
□ Cross-platform compatibility
□ Auto-completion working
□ Self-updating capability

=== TECHNICAL REQUIREMENTS ===
Core Stack:
- Node.js with TypeScript
- Built-in parseArgs for simple CLIs
- Commander.js only if 5+ subcommands
- Chalk for colors
- Ora for spinners
- Inquirer for prompts

Distribution:
- npm package (primary)
- Standalone binaries via pkg
- Homebrew formula (macOS)
- Scoop manifest (Windows)

=== PROJECT STRUCTURE ===
```
./src/
  ├── cli.ts          # Entry point with shebang
  ├── commands/       # Command implementations
  │   ├── init.ts
  │   ├── build.ts
  │   └── deploy.ts
  ├── utils/          # Shared utilities
  │   ├── logger.ts   # Colored output
  │   ├── config.ts   # Config management
  │   └── spinner.ts  # Progress indicators
  └── types/          # TypeScript types

./templates/         # File templates
./bin/              # Compiled executables
./package.json      # npm configuration
./tsconfig.json     # TypeScript config
```

=== PACKAGE CONFIGURATION ===
package.json:
```json
{
  "name": "@sammons/tool-name",
  "version": "1.0.0",
  "description": "Tool description",
  "type": "module",
  "bin": {
    "tool-name": "./dist/cli.js"
  },
  "files": [
    "dist",
    "templates"
  ],
  "scripts": {
    "build": "tsc",
    "dev": "tsx src/cli.ts",
    "package": "pkg . --out-path bin/",
    "postinstall": "node ./dist/postinstall.js"
  },
  "engines": {
    "node": ">=20.0.0"
  },
  "dependencies": {
    "chalk": "^5.0.0",
    "ora": "^7.0.0",
    "inquirer": "^9.0.0",
    "update-notifier": "^6.0.0"
  },
  "pkg": {
    "scripts": "dist/**/*.js",
    "assets": "templates/**/*",
    "targets": ["node20-linux-x64", "node20-macos-x64", "node20-win-x64"]
  }
}
```

=== KEY PATTERNS ===
Entry Point:
```typescript
#!/usr/bin/env node
// src/cli.ts
import { parseArgs } from 'node:util'
import { logger } from './utils/logger'
import { checkForUpdates } from './utils/updater'

// Check for updates
await checkForUpdates()

// Parse arguments for simple CLI
const { values, positionals } = parseArgs({
  options: {
    version: { type: 'boolean', short: 'v' },
    help: { type: 'boolean', short: 'h' },
    config: { type: 'string', short: 'c' },
    verbose: { type: 'boolean' }
  },
  strict: true,
  allowPositionals: true
})

if (values.help) {
  showHelp()
  process.exit(0)
}

if (values.version) {
  console.log(getVersion())
  process.exit(0)
}

// Route to command
const command = positionals[0]
switch (command) {
  case 'init':
    await initCommand(values)
    break
  case 'build':
    await buildCommand(values)
    break
  default:
    logger.error(`Unknown command: ${command}`)
    showHelp()
    process.exit(1)
}
```

Logging Utilities:
```typescript
// utils/logger.ts
import chalk from 'chalk'

export const logger = {
  info: (msg: string) => console.log(chalk.blue('ℹ'), msg),
  success: (msg: string) => console.log(chalk.green('✓'), msg),
  warning: (msg: string) => console.log(chalk.yellow('⚠'), msg),
  error: (msg: string) => console.error(chalk.red('✖'), msg),
  
  // Formatted output
  box: (title: string, content: string) => {
    console.log(chalk.cyan('┌─'), chalk.bold(title))
    console.log('│', content)
    console.log(chalk.cyan('└─'))
  }
}
```

Progress Indicators:
```typescript
// utils/spinner.ts
import ora from 'ora'

export async function withSpinner<T>(
  text: string,
  fn: () => Promise<T>
): Promise<T> {
  const spinner = ora(text).start()
  try {
    const result = await fn()
    spinner.succeed()
    return result
  } catch (error) {
    spinner.fail()
    throw error
  }
}

// Usage
await withSpinner('Building project...', async () => {
  await buildProject()
})
```

Interactive Prompts:
```typescript
// commands/init.ts
import inquirer from 'inquirer'
import { logger } from '../utils/logger'

export async function initCommand() {
  const answers = await inquirer.prompt([
    {
      type: 'input',
      name: 'projectName',
      message: 'Project name:',
      default: 'my-project'
    },
    {
      type: 'list',
      name: 'template',
      message: 'Select template:',
      choices: [
        { name: 'Basic TypeScript', value: 'basic' },
        { name: 'React App', value: 'react' },
        { name: 'API Server', value: 'api' }
      ]
    },
    {
      type: 'confirm',
      name: 'git',
      message: 'Initialize git repository?',
      default: true
    }
  ])
  
  logger.info(`Creating project: ${answers.projectName}`)
  await createProject(answers)
  logger.success('Project created successfully!')
}
```

Configuration Management:
```typescript
// utils/config.ts
import { homedir } from 'node:os'
import { join } from 'node:path'
import { readFile, writeFile, mkdir } from 'node:fs/promises'

const CONFIG_DIR = join(homedir(), '.config', 'tool-name')
const CONFIG_FILE = join(CONFIG_DIR, 'config.json')

interface Config {
  apiKey?: string
  theme: 'light' | 'dark'
  telemetry: boolean
}

export async function loadConfig(): Promise<Config> {
  try {
    const data = await readFile(CONFIG_FILE, 'utf8')
    return JSON.parse(data)
  } catch {
    return { theme: 'dark', telemetry: true }
  }
}

export async function saveConfig(config: Config): Promise<void> {
  await mkdir(CONFIG_DIR, { recursive: true })
  await writeFile(CONFIG_FILE, JSON.stringify(config, null, 2))
}
```

Auto-Update Check:
```typescript
// utils/updater.ts
import updateNotifier from 'update-notifier'
import { readFileSync } from 'node:fs'

const pkg = JSON.parse(
  readFileSync(new URL('../package.json', import.meta.url), 'utf8')
)

export function checkForUpdates() {
  const notifier = updateNotifier({
    pkg,
    updateCheckInterval: 1000 * 60 * 60 * 24 // Daily
  })
  
  if (notifier.update) {
    notifier.notify({
      message: `Update available: ${notifier.update.latest}
Run ${chalk.cyan('npm install -g @sammons/tool-name')} to update`
    })
  }
}
```

=== SHELL COMPLETION ===
Bash Completion:
```bash
# completions/tool-name.bash
_tool_name_completions() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  local commands="init build deploy help"
  
  if [ $COMP_CWORD -eq 1 ]; then
    COMPREPLY=($(compgen -W "$commands" -- "$cur"))
  fi
}

complete -F _tool_name_completions tool-name
```

Installation Helper:
```typescript
// src/commands/completion.ts
export async function installCompletion() {
  const shell = process.env.SHELL?.split('/').pop() || 'bash'
  
  if (shell === 'bash') {
    const completionPath = join(homedir(), '.bash_completion.d')
    await mkdir(completionPath, { recursive: true })
    await copyFile(
      join(__dirname, '../completions/tool-name.bash'),
      join(completionPath, 'tool-name')
    )
    logger.success('Bash completion installed!')
  }
}
```

=== DISTRIBUTION ===
npm Publishing:
```bash
# Build and test
pnpm build
pnpm test

# Publish to npm
pnpm publish --access public
```

Binary Distribution:
```bash
# Create binaries
pnpm package

# Creates:
# - bin/tool-name-linux
# - bin/tool-name-macos
# - bin/tool-name-win.exe
```

Homebrew Formula:
```ruby
class ToolName < Formula
  desc "Tool description"
  homepage "https://github.com/sammons-software-llc/tool-name"
  url "https://github.com/sammons-software-llc/tool-name/releases/download/v1.0.0/tool-name-macos.tar.gz"
  sha256 "..."
  
  def install
    bin.install "tool-name"
  end
  
  test do
    system "#{bin}/tool-name", "--version"
  end
end
```

=== CONSTRAINTS ===
⛔ NEVER use console.log directly (use logger)
⛔ NEVER assume terminal supports colors
⛔ NEVER block on startup for updates
⛔ NEVER store secrets in plain text
✅ ALWAYS provide --help flag
✅ ALWAYS handle Ctrl+C gracefully
✅ ALWAYS validate user input
✅ ALWAYS support NO_COLOR env var

=== VALIDATION CHECKLIST ===
□ Shebang line present
□ Executable permissions set
□ Help text comprehensive
□ Error messages helpful
□ Colors respect NO_COLOR
□ Works on Windows/Mac/Linux
□ npm package installable
□ Binary distribution working
□ Shell completion available