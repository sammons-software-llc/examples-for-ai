=== CONTEXT ===
Browser extension archetype for Chrome, Firefox, and Edge.
Uses Manifest V3 for future compatibility with modern web extension APIs.

=== OBJECTIVE ===
Create secure, performant browser extensions with cross-browser support.
Success metrics:
□ <50ms popup load time
□ <10MB package size
□ Works on Chrome, Firefox, Edge
□ Passes web store review
□ No memory leaks

=== TECHNICAL REQUIREMENTS ===
Core Stack:
- Manifest V3 specification
- TypeScript for all scripts
- React for popup/options UI
- Webpack for bundling
- webextension-polyfill for compatibility

Architecture:
- Service worker (background)
- Content scripts (page injection)
- Popup UI (React)
- Options page (React)
- Chrome storage API

=== PROJECT STRUCTURE ===
```
./src/
  ├── background/     # Service worker
  │   ├── index.ts   # Entry point
  │   └── handlers/  # Message handlers
  ├── content/       # Content scripts
  │   ├── index.ts   # Main injection
  │   └── styles.css # Injected styles
  ├── popup/         # Popup UI
  │   ├── App.tsx    # React app
  │   ├── index.tsx  # Entry point
  │   └── popup.html # HTML template
  ├── options/       # Options page
  │   ├── App.tsx    # React app
  │   └── options.html
  ├── types/         # Shared types
  └── utils/         # Shared utilities

./public/
  ├── manifest.json  # Extension manifest
  ├── icons/         # Extension icons
  └── _locales/      # i18n files

./webpack/
  ├── webpack.common.js
  ├── webpack.dev.js
  └── webpack.prod.js
```

=== MANIFEST CONFIGURATION ===
manifest.json:
```json
{
  "manifest_version": 3,
  "name": "Extension Name",
  "version": "1.0.0",
  "description": "Extension description",
  "permissions": [
    "storage",
    "activeTab",
    "scripting"
  ],
  "host_permissions": [
    "https://*/*"
  ],
  "background": {
    "service_worker": "background.js",
    "type": "module"
  },
  "content_scripts": [
    {
      "matches": ["<all_urls>"],
      "js": ["content.js"],
      "css": ["content.css"],
      "run_at": "document_idle"
    }
  ],
  "action": {
    "default_popup": "popup.html",
    "default_icon": {
      "16": "icons/icon16.png",
      "48": "icons/icon48.png",
      "128": "icons/icon128.png"
    }
  },
  "options_page": "options.html",
  "icons": {
    "16": "icons/icon16.png",
    "48": "icons/icon48.png",
    "128": "icons/icon128.png"
  }
}
```

=== KEY PATTERNS ===
Message Passing:
```typescript
// types/messages.ts
export interface Messages {
  GET_PAGE_INFO: {
    request: void
    response: { title: string; url: string }
  }
  SAVE_BOOKMARK: {
    request: { url: string; title: string }
    response: { success: boolean }
  }
}

// background/handlers/message-handler.ts
import browser from 'webextension-polyfill'

browser.runtime.onMessage.addListener(async (message, sender) => {
  switch (message.type) {
    case 'GET_PAGE_INFO':
      return handleGetPageInfo(sender.tab)
    case 'SAVE_BOOKMARK':
      return handleSaveBookmark(message.data)
  }
})

// content/index.ts
async function getPageInfo() {
  const response = await browser.runtime.sendMessage({
    type: 'GET_PAGE_INFO'
  })
  return response
}
```

Storage Patterns:
```typescript
// utils/storage.ts
import browser from 'webextension-polyfill'

interface StorageSchema {
  settings: {
    theme: 'light' | 'dark'
    enabled: boolean
  }
  bookmarks: Array<{
    url: string
    title: string
    timestamp: number
  }>
}

export class ExtensionStorage {
  async get<K extends keyof StorageSchema>(
    key: K
  ): Promise<StorageSchema[K] | undefined> {
    const result = await browser.storage.sync.get(key)
    return result[key]
  }
  
  async set<K extends keyof StorageSchema>(
    key: K,
    value: StorageSchema[K]
  ): Promise<void> {
    await browser.storage.sync.set({ [key]: value })
  }
}
```

React Popup:
```typescript
// popup/App.tsx
import { useState, useEffect } from 'react'
import browser from 'webextension-polyfill'

export function App() {
  const [tabInfo, setTabInfo] = useState<TabInfo | null>(null)
  
  useEffect(() => {
    async function getCurrentTab() {
      const [tab] = await browser.tabs.query({ 
        active: true, 
        currentWindow: true 
      })
      setTabInfo({
        title: tab.title || '',
        url: tab.url || ''
      })
    }
    getCurrentTab()
  }, [])
  
  return (
    <div className="w-80 p-4">
      <h1 className="text-lg font-bold mb-2">Current Tab</h1>
      <p className="text-sm">{tabInfo?.title}</p>
      <button 
        onClick={handleSave}
        className="mt-2 px-4 py-2 bg-blue-500 text-white rounded"
      >
        Save Bookmark
      </button>
    </div>
  )
}
```

Content Script Injection:
```typescript
// content/index.ts
import './styles.css'

// Inject UI element
const widget = document.createElement('div')
widget.id = 'extension-widget'
widget.innerHTML = `
  <div class="extension-panel">
    <button id="extension-trigger">Open</button>
  </div>
`
document.body.appendChild(widget)

// Add event listeners
document.getElementById('extension-trigger')?.addEventListener('click', () => {
  browser.runtime.sendMessage({ type: 'OPEN_POPUP' })
})
```

=== BUILD CONFIGURATION ===
webpack.common.js:
```javascript
module.exports = {
  entry: {
    background: './src/background/index.ts',
    content: './src/content/index.ts',
    popup: './src/popup/index.tsx',
    options: './src/options/index.tsx'
  },
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        use: 'ts-loader',
        exclude: /node_modules/
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader', 'postcss-loader']
      }
    ]
  },
  resolve: {
    extensions: ['.tsx', '.ts', '.js'],
    alias: {
      '@': path.resolve(__dirname, '../src')
    }
  }
}
```

=== DEVELOPMENT WORKFLOW ===
Development:
```bash
# Watch mode for all entry points
pnpm dev

# Build for production
pnpm build

# Package for distribution
pnpm package
```

Testing in Browser:
1. Chrome: chrome://extensions → Load unpacked
2. Firefox: about:debugging → Load temporary
3. Edge: edge://extensions → Load unpacked

=== DISTRIBUTION ===
Web Store Publishing:
```bash
# Create zip for submission
pnpm package:chrome
pnpm package:firefox

# Automated publishing (with API keys)
pnpm publish:chrome
pnpm publish:firefox
```

Store Listing Requirements:
- Screenshots: 1280x800 or 640x400
- Promotional images: 440x280
- Privacy policy URL
- Detailed description
- Category selection

=== CONSTRAINTS ===
⛔ NEVER use deprecated Manifest V2 APIs
⛔ NEVER inject scripts on sensitive pages
⛔ NEVER store sensitive data in localStorage
⛔ NEVER use eval() or innerHTML with user data
✅ ALWAYS use content security policy
✅ ALWAYS minimize permissions requested
✅ ALWAYS handle extension updates gracefully
✅ ALWAYS test cross-browser compatibility

=== VALIDATION CHECKLIST ===
□ Manifest V3 compliant
□ All permissions justified
□ No memory leaks in background
□ Content scripts properly scoped
□ Storage sync working
□ Cross-browser tested
□ Icons at all required sizes
□ Localization files present
□ Web store requirements met