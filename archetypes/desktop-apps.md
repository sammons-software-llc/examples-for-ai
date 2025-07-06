=== CONTEXT ===
Desktop application archetype for cross-platform Electron apps.
Runs on Windows, macOS, and Linux with native OS integration.

=== OBJECTIVE ===
Create performant, secure desktop applications with auto-update capabilities.
Success metrics:
□ <2 second cold start time
□ <100MB memory footprint at idle
□ Native OS integration working
□ Auto-updates functioning
□ Code signed for distribution

=== TECHNICAL REQUIREMENTS ===
Core Stack:
- Electron with TypeScript
- React for UI (same patterns as web)
- Main/renderer process separation
- IPC with type safety via electron-typesafe-ipc

Security:
- Context isolation enabled
- Node integration disabled
- Preload scripts for safe APIs
- CSP headers in renderer

Storage:
- electron-store for preferences
- SQLite for application data
- app.getPath('userData') for files

=== PROJECT STRUCTURE ===
```
./lib/electron/
  ├── main/           # Main process
  │   ├── index.ts    # Entry point
  │   ├── ipc/        # IPC handlers
  │   ├── menu/       # Menu builders
  │   └── updater/    # Auto-update logic
  ├── renderer/       # Renderer process (React)
  │   ├── src/        # Standard React app
  │   └── index.html  # Entry HTML
  ├── preload/        # Preload scripts
  │   └── index.ts    # Exposed APIs
  └── shared/         # Shared types/utils
      └── ipc-types.ts

./resources/         # Icons, installers
./electron-builder.yml # Build config
```

=== CONFIGURATION ===
electron-builder.yml:
```yaml
appId: com.sammons.${name}
productName: ${productName}
directories:
  output: dist
  buildResources: resources

mac:
  category: public.app-category.productivity
  hardenedRuntime: true
  gatekeeperAssess: false
  notarize:
    teamId: ${APPLE_TEAM_ID}

win:
  target: nsis
  publisherName: Sammons Software LLC

linux:
  target: AppImage
  category: Utility

publish:
  provider: github
  owner: sammons-software-llc
  private: true
```

=== KEY PATTERNS ===
Type-Safe IPC:
```typescript
// shared/ipc-types.ts
export interface IpcChannels {
  'app:get-version': {
    request: void
    response: string
  }
  'file:save': {
    request: { path: string; content: string }
    response: { success: boolean }
  }
}

// main/ipc/handlers.ts
import { ipcMain } from 'electron'
import { IpcChannels } from '../../shared/ipc-types'

export function setupIpcHandlers() {
  ipcMain.handle('app:get-version', async () => {
    return app.getVersion()
  })
}

// preload/index.ts
import { contextBridge, ipcRenderer } from 'electron'

contextBridge.exposeInMainWorld('electronAPI', {
  getVersion: () => ipcRenderer.invoke('app:get-version'),
  saveFile: (data) => ipcRenderer.invoke('file:save', data)
})
```

Auto-Updater:
```typescript
import { autoUpdater } from 'electron-updater'

export function setupAutoUpdater() {
  autoUpdater.logger = logger
  autoUpdater.checkForUpdatesAndNotify()
  
  autoUpdater.on('update-downloaded', () => {
    dialog.showMessageBox({
      type: 'info',
      title: 'Update Ready',
      message: 'Restart to apply update?',
      buttons: ['Restart', 'Later']
    }).then((result) => {
      if (result.response === 0) {
        autoUpdater.quitAndInstall()
      }
    })
  })
}
```

=== BUILD & DISTRIBUTION ===
Development:
```bash
# Concurrent main & renderer
pnpm dev:electron

# Main process only (with watch)
pnpm dev:main

# Renderer only
pnpm dev:renderer
```

Distribution:
```bash
# Build for current platform
pnpm build:electron

# Build for all platforms
pnpm build:electron:all

# Publish release
pnpm release:electron
```

Code Signing:
- macOS: Requires Apple Developer ID
- Windows: Requires EV certificate
- Linux: Optional but recommended

=== CONSTRAINTS ===
⛔ NEVER enable nodeIntegration in renderer
⛔ NEVER expose sensitive APIs directly
⛔ NEVER store secrets in plain text
⛔ NEVER skip code signing for distribution
✅ ALWAYS use context isolation
✅ ALWAYS validate IPC inputs
✅ ALWAYS use ASAR packaging
✅ ALWAYS test auto-updates before release

=== VALIDATION CHECKLIST ===
□ Main/renderer processes properly separated
□ IPC channels type-safe
□ Auto-updater configured and tested
□ Native menus working on all platforms
□ App signed and notarized (macOS)
□ Installer working on all platforms
□ Deep linking registered
□ File associations working