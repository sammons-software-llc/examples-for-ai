=== CONTEXT ===
Mobile application archetype using React Native with Expo.
Targets iOS and Android with over-the-air updates and native features.

=== OBJECTIVE ===
Build production-ready mobile apps with great developer experience.
Success metrics:
□ 60 FPS UI performance
□ <3 second cold start
□ Offline functionality working
□ Push notifications configured
□ App store ready

=== TECHNICAL REQUIREMENTS ===
Core Stack:
- Expo SDK (latest)
- React Native with TypeScript
- React Navigation v6
- MobX for state (same patterns)
- Expo Application Services (EAS)

Native Features:
- expo-camera for camera access
- expo-notifications for push
- expo-secure-store for secrets
- expo-file-system for storage
- expo-location for GPS

Styling:
- NativeWind (Tailwind for RN)
- React Native Reanimated
- Expo Vector Icons

=== PROJECT STRUCTURE ===
```
./
├── app/              # Expo Router (file-based)
│   ├── (tabs)/      # Tab navigation
│   ├── (auth)/      # Auth flow
│   └── _layout.tsx  # Root layout
├── src/
│   ├── components/  # Reusable components
│   ├── stores/      # MobX stores
│   ├── services/    # API/native services
│   ├── hooks/       # Custom hooks
│   └── utils/       # Helpers
├── assets/          # Images, fonts
├── app.json         # Expo config
├── eas.json         # EAS Build config
└── metro.config.js  # Metro bundler
```

=== CONFIGURATION ===
app.json:
```json
{
  "expo": {
    "name": "AppName",
    "slug": "app-name",
    "owner": "sammons-software-llc",
    "version": "1.0.0",
    "orientation": "portrait",
    "scheme": "appname",
    "userInterfaceStyle": "automatic",
    "icon": "./assets/icon.png",
    "splash": {
      "image": "./assets/splash.png",
      "backgroundColor": "#ffffff"
    },
    "updates": {
      "fallbackToCacheTimeout": 0,
      "url": "https://u.expo.dev/..."
    },
    "ios": {
      "bundleIdentifier": "com.sammons.appname",
      "buildNumber": "1",
      "supportsTablet": true
    },
    "android": {
      "package": "com.sammons.appname",
      "versionCode": 1,
      "adaptiveIcon": {
        "foregroundImage": "./assets/adaptive-icon.png"
      }
    },
    "plugins": [
      "expo-camera",
      "expo-notifications"
    ]
  }
}
```

eas.json:
```json
{
  "cli": {
    "version": ">= 5.0.0"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal",
      "ios": {
        "simulator": true
      }
    },
    "production": {
      "autoIncrement": true
    }
  },
  "submit": {
    "production": {}
  }
}
```

=== KEY PATTERNS ===
Navigation Setup:
```typescript
// app/_layout.tsx
import { Stack } from 'expo-router'
import { observer } from 'mobx-react-lite'
import { useAuthStore } from '@/stores/auth-store'

export default observer(function RootLayout() {
  const auth = useAuthStore()
  
  return (
    <Stack>
      <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
      <Stack.Screen name="(auth)" options={{ headerShown: false }} />
    </Stack>
  )
})
```

Native Feature Usage:
```typescript
// Camera with permissions
import { Camera } from 'expo-camera'
import { useState, useEffect } from 'react'

export function CameraScreen() {
  const [permission, requestPermission] = Camera.useCameraPermissions()
  
  if (!permission?.granted) {
    return (
      <View>
        <Text>Camera access required</Text>
        <Button onPress={requestPermission} title="Grant Permission" />
      </View>
    )
  }
  
  return <Camera style={styles.camera} type={Camera.Constants.Type.back} />
}
```

Offline Support:
```typescript
// stores/offline-store.ts
import NetInfo from '@react-native-community/netinfo'
import { makeAutoObservable } from 'mobx'

class OfflineStore {
  isOnline = true
  queue: QueuedRequest[] = []
  
  constructor() {
    makeAutoObservable(this)
    this.setupNetworkListener()
  }
  
  setupNetworkListener() {
    NetInfo.addEventListener(state => {
      this.isOnline = state.isConnected ?? false
      if (this.isOnline) {
        this.processQueue()
      }
    })
  }
  
  async processQueue() {
    while (this.queue.length > 0) {
      const request = this.queue.shift()!
      await this.executeRequest(request)
    }
  }
}
```

Push Notifications:
```typescript
import * as Notifications from 'expo-notifications'

export async function registerForPushNotifications() {
  const { status } = await Notifications.requestPermissionsAsync()
  if (status !== 'granted') return
  
  const token = await Notifications.getExpoPushTokenAsync({
    projectId: Constants.expoConfig?.extra?.eas.projectId
  })
  
  // Send token to backend
  await api.registerPushToken(token.data)
}
```

=== DEVELOPMENT WORKFLOW ===
Local Development:
```bash
# Start Expo dev server
pnpm start

# Run on iOS simulator
pnpm ios

# Run on Android emulator
pnpm android

# Run on device (Expo Go)
pnpm start --tunnel
```

Building:
```bash
# Development build
eas build --profile development --platform all

# Preview build
eas build --profile preview --platform all

# Production build
eas build --profile production --platform all
```

=== DEPLOYMENT ===
Over-the-Air Updates:
```bash
# Publish update
eas update --branch production --message "Bug fixes"

# Rollback if needed
eas update:rollback --branch production
```

App Store Submission:
```bash
# iOS App Store
eas submit -p ios --latest

# Google Play Store  
eas submit -p android --latest
```

=== CONSTRAINTS ===
⛔ NEVER store secrets in code
⛔ NEVER skip permission requests
⛔ NEVER use Expo modules in bare workflow
⛔ NEVER ignore platform differences
✅ ALWAYS handle offline scenarios
✅ ALWAYS test on real devices
✅ ALWAYS optimize bundle size
✅ ALWAYS follow platform guidelines

=== VALIDATION CHECKLIST ===
□ App runs on iOS simulator
□ App runs on Android emulator
□ Navigation flows properly
□ Offline mode handled gracefully
□ Push notifications working
□ Deep linking configured
□ App icons and splash screens set
□ Production build successful
□ OTA updates tested