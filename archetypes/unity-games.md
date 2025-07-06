=== CONTEXT ===
Unity game development archetype for TypeScript developers.
Focuses on Unity WebGL builds with TypeScript tooling and web integration.

=== OBJECTIVE ===
Build Unity games with familiar web development workflows.
Success metrics:
□ 60 FPS performance on web
□ <10MB initial download size
□ TypeScript integration working
□ Build automation configured
□ Web API communication established

=== TECHNICAL APPROACH ===
Core Stack:
- Unity 2023.2+ LTS
- WebGL build target
- TypeScript for web layer
- jslib for Unity-JS bridge
- Addressables for asset loading

Integration:
- React wrapper for Unity WebGL
- Socket.io for multiplayer
- REST API for persistence
- Web3 for blockchain (optional)

=== PROJECT STRUCTURE ===
```
./unity/                # Unity project
  ├── Assets/
  │   ├── Scripts/      # C# game code
  │   ├── Prefabs/      # Game objects
  │   ├── Materials/    # Shaders/materials
  │   └── Plugins/
  │       └── WebGL/    # .jslib files
  ├── ProjectSettings/
  └── Packages/

./web/                  # TypeScript wrapper
  ├── src/
  │   ├── components/
  │   │   └── UnityGame.tsx
  │   ├── unity/        # Unity communication
  │   ├── api/          # Backend integration
  │   └── types/        # TypeScript types
  └── public/
      └── Build/        # Unity WebGL output

./server/               # Game backend
  ├── src/
  │   ├── game/         # Game logic
  │   ├── matchmaking/  # Player matching
  │   └── persistence/  # Save games
  └── package.json
```

=== UNITY-JAVASCRIPT BRIDGE ===
Unity jslib Plugin:
```javascript
// unity/Assets/Plugins/WebGL/GameBridge.jslib
mergeInto(LibraryManager.library, {
  // Call from Unity to JavaScript
  SendMessageToJS: function(messagePtr) {
    const message = UTF8ToString(messagePtr);
    
    // Dispatch to window
    window.dispatchEvent(new CustomEvent('unity-message', {
      detail: JSON.parse(message)
    }));
  },
  
  // Save game data
  SaveGameData: function(keyPtr, dataPtr) {
    const key = UTF8ToString(keyPtr);
    const data = UTF8ToString(dataPtr);
    
    try {
      localStorage.setItem(`game_${key}`, data);
      return 1; // Success
    } catch (e) {
      console.error('Save failed:', e);
      return 0; // Failure
    }
  },
  
  // Load game data
  LoadGameData: function(keyPtr) {
    const key = UTF8ToString(keyPtr);
    const data = localStorage.getItem(`game_${key}`);
    
    if (data) {
      const buffer = _malloc(lengthBytesUTF8(data) + 1);
      stringToUTF8(data, buffer, lengthBytesUTF8(data) + 1);
      return buffer;
    }
    
    return null;
  },
  
  // Analytics
  TrackEvent: function(eventPtr, paramsPtr) {
    const event = UTF8ToString(eventPtr);
    const params = UTF8ToString(paramsPtr);
    
    if (window.gtag) {
      window.gtag('event', event, JSON.parse(params));
    }
  }
});
```

C# Interface:
```csharp
// Scripts/WebBridge.cs
using System.Runtime.InteropServices;
using UnityEngine;

public class WebBridge : MonoBehaviour
{
    [DllImport("__Internal")]
    private static extern void SendMessageToJS(string message);
    
    [DllImport("__Internal")]
    private static extern int SaveGameData(string key, string data);
    
    [DllImport("__Internal")]
    private static extern string LoadGameData(string key);
    
    [DllImport("__Internal")]
    private static extern void TrackEvent(string eventName, string parameters);
    
    public static WebBridge Instance { get; private set; }
    
    void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
    }
    
    public void SendToJS<T>(string type, T data)
    {
        var message = JsonUtility.ToJson(new {
            type = type,
            data = data
        });
        
        #if UNITY_WEBGL && !UNITY_EDITOR
        SendMessageToJS(message);
        #else
        Debug.Log($"WebBridge: {message}");
        #endif
    }
    
    public void SaveGame(SaveData data)
    {
        string json = JsonUtility.ToJson(data);
        
        #if UNITY_WEBGL && !UNITY_EDITOR
        int result = SaveGameData("save", json);
        if (result == 0)
        {
            Debug.LogError("Failed to save game");
        }
        #else
        PlayerPrefs.SetString("save", json);
        #endif
    }
}
```

=== REACT INTEGRATION ===
Unity Component:
```typescript
// components/UnityGame.tsx
import { useEffect, useRef, useState } from 'react'
import { Unity, useUnityContext } from 'react-unity-webgl'

interface UnityGameProps {
  onReady?: () => void
  onProgress?: (progress: number) => void
  onMessage?: (message: any) => void
}

export function UnityGame({ onReady, onProgress, onMessage }: UnityGameProps) {
  const {
    unityProvider,
    isLoaded,
    loadingProgression,
    sendMessage,
    addEventListener,
    removeEventListener
  } = useUnityContext({
    loaderUrl: '/Build/game.loader.js',
    dataUrl: '/Build/game.data',
    frameworkUrl: '/Build/game.framework.js',
    codeUrl: '/Build/game.wasm',
    streamingAssetsUrl: '/StreamingAssets',
    companyName: 'Sammons Software',
    productName: 'My Game',
    productVersion: '1.0.0'
  })
  
  useEffect(() => {
    if (isLoaded && onReady) {
      onReady()
    }
  }, [isLoaded, onReady])
  
  useEffect(() => {
    if (onProgress) {
      onProgress(loadingProgression)
    }
  }, [loadingProgression, onProgress])
  
  useEffect(() => {
    // Listen for Unity messages
    const handleUnityMessage = (event: CustomEvent) => {
      if (onMessage) {
        onMessage(event.detail)
      }
    }
    
    window.addEventListener('unity-message', handleUnityMessage as any)
    
    // Unity event listeners
    addEventListener('GameReady', () => {
      console.log('Game ready')
    })
    
    addEventListener('ScoreUpdate', (score: number) => {
      console.log('Score:', score)
    })
    
    return () => {
      window.removeEventListener('unity-message', handleUnityMessage as any)
      removeEventListener('GameReady')
      removeEventListener('ScoreUpdate')
    }
  }, [addEventListener, removeEventListener, onMessage])
  
  // Send message to Unity
  const startGame = () => {
    sendMessage('GameManager', 'StartGame', JSON.stringify({
      playerName: 'Player 1',
      difficulty: 'normal'
    }))
  }
  
  return (
    <div className="unity-container">
      {!isLoaded && (
        <div className="loading-overlay">
          <div className="loading-bar">
            <div 
              className="loading-fill"
              style={{ width: `${loadingProgression * 100}%` }}
            />
          </div>
          <p>{Math.round(loadingProgression * 100)}%</p>
        </div>
      )}
      
      <Unity
        unityProvider={unityProvider}
        style={{
          width: '100%',
          height: '100%',
          visibility: isLoaded ? 'visible' : 'hidden'
        }}
      />
      
      {isLoaded && (
        <div className="game-controls">
          <button onClick={startGame}>Start Game</button>
        </div>
      )}
    </div>
  )
}
```

Unity Communication Hook:
```typescript
// hooks/use-unity-bridge.ts
export function useUnityBridge() {
  const { sendMessage, addEventListener, removeEventListener } = useUnityContext()
  
  const callUnityMethod = useCallback((
    gameObject: string,
    method: string,
    data?: any
  ) => {
    const param = data ? JSON.stringify(data) : ''
    sendMessage(gameObject, method, param)
  }, [sendMessage])
  
  const registerHandler = useCallback((
    eventName: string,
    handler: (data: any) => void
  ) => {
    addEventListener(eventName, handler)
    return () => removeEventListener(eventName)
  }, [addEventListener, removeEventListener])
  
  return {
    callUnityMethod,
    registerHandler,
    
    // Common game methods
    startGame: (config: GameConfig) => 
      callUnityMethod('GameManager', 'StartGame', config),
    
    pauseGame: () => 
      callUnityMethod('GameManager', 'PauseGame'),
    
    updateSettings: (settings: GameSettings) =>
      callUnityMethod('SettingsManager', 'UpdateSettings', settings)
  }
}
```

=== MULTIPLAYER INTEGRATION ===
Socket.io Game Server:
```typescript
// server/game/game-room.ts
export class GameRoom {
  private players = new Map<string, Player>()
  private gameState: GameState
  private updateInterval: NodeJS.Timer
  
  constructor(
    private roomId: string,
    private io: Server
  ) {
    this.gameState = this.initializeGameState()
    this.startGameLoop()
  }
  
  addPlayer(socket: Socket, playerData: PlayerData) {
    const player = {
      id: socket.id,
      ...playerData,
      position: this.getSpawnPosition(),
      score: 0
    }
    
    this.players.set(socket.id, player)
    
    // Send current state to new player
    socket.emit('game:init', {
      playerId: socket.id,
      gameState: this.gameState,
      players: Array.from(this.players.values())
    })
    
    // Notify others
    socket.to(this.roomId).emit('player:joined', player)
    
    // Handle player input
    socket.on('player:input', (input: PlayerInput) => {
      this.handlePlayerInput(socket.id, input)
    })
    
    socket.on('disconnect', () => {
      this.removePlayer(socket.id)
    })
  }
  
  private handlePlayerInput(playerId: string, input: PlayerInput) {
    const player = this.players.get(playerId)
    if (!player) return
    
    // Validate input
    if (this.isValidInput(input)) {
      // Update player state
      player.position = input.position
      player.rotation = input.rotation
      
      // Broadcast to others
      this.io.to(this.roomId).emit('player:update', {
        playerId,
        position: player.position,
        rotation: player.rotation
      })
    }
  }
  
  private startGameLoop() {
    this.updateInterval = setInterval(() => {
      this.updateGameState()
      this.broadcastGameState()
    }, 1000 / 30) // 30 FPS
  }
}
```

Unity Multiplayer Client:
```csharp
// Scripts/MultiplayerManager.cs
using SocketIOClient;
using UnityEngine;
using System.Collections.Generic;

public class MultiplayerManager : MonoBehaviour
{
    private SocketIOUnity socket;
    private Dictionary<string, GameObject> remotePlayers = new Dictionary<string, GameObject>();
    
    [SerializeField] private GameObject playerPrefab;
    [SerializeField] private GameObject remotePlayerPrefab;
    
    void Start()
    {
        ConnectToServer();
    }
    
    async void ConnectToServer()
    {
        socket = new SocketIOUnity("http://localhost:3000");
        
        socket.OnConnected += (sender, e) =>
        {
            Debug.Log("Connected to server");
            JoinGame();
        };
        
        socket.On("game:init", (response) =>
        {
            var data = response.GetValue<GameInitData>();
            InitializeGame(data);
        });
        
        socket.On("player:joined", (response) =>
        {
            var player = response.GetValue<PlayerData>();
            SpawnRemotePlayer(player);
        });
        
        socket.On("player:update", (response) =>
        {
            var update = response.GetValue<PlayerUpdate>();
            UpdateRemotePlayer(update);
        });
        
        await socket.ConnectAsync();
    }
    
    void SendPlayerUpdate()
    {
        var data = new
        {
            position = transform.position,
            rotation = transform.rotation.eulerAngles
        };
        
        socket.EmitAsync("player:input", data);
    }
}
```

=== BUILD OPTIMIZATION ===
Unity Build Settings:
```csharp
// Editor/BuildPipeline.cs
using UnityEditor;
using UnityEngine;

public class WebGLBuilder
{
    [MenuItem("Build/WebGL Production")]
    public static void BuildWebGL()
    {
        PlayerSettings.WebGL.compressionFormat = WebGLCompressionFormat.Brotli;
        PlayerSettings.WebGL.linkerTarget = WebGLLinkerTarget.Wasm;
        PlayerSettings.WebGL.memorySize = 256;
        PlayerSettings.WebGL.exceptionSupport = WebGLExceptionSupport.None;
        
        // Enable code stripping
        PlayerSettings.stripEngineCode = true;
        PlayerSettings.managedStrippingLevel = ManagedStrippingLevel.High;
        
        // Optimize for size
        EditorUserBuildSettings.il2CppCodeGeneration = Il2CppCodeGeneration.OptimizeSize;
        
        BuildPipeline.BuildPlayer(new BuildPlayerOptions
        {
            scenes = new[] { "Assets/Scenes/Main.unity" },
            locationPathName = "../web/public/Build",
            target = BuildTarget.WebGL,
            options = BuildOptions.CompressWithLz4HC
        });
    }
}
```

=== DEPLOYMENT ===
Build Script:
```json
{
  "scripts": {
    "build:unity": "cd unity && /Applications/Unity/Unity.app/Contents/MacOS/Unity -batchmode -quit -projectPath . -executeMethod WebGLBuilder.BuildWebGL",
    "build:web": "cd web && pnpm build",
    "build": "pnpm build:unity && pnpm build:web",
    "compress": "cd web/public/Build && brotli -q 11 *.js *.data *.wasm"
  }
}
```

=== CONSTRAINTS ===
⛔ NEVER exceed 20MB compressed build size
⛔ NEVER use synchronous web calls from Unity
⛔ NEVER trust client-side game state
⛔ NEVER ship with development build settings
✅ ALWAYS use Addressables for large assets
✅ ALWAYS compress builds with Brotli
✅ ALWAYS validate multiplayer inputs
✅ ALWAYS handle WebGL memory limits

=== VALIDATION CHECKLIST ===
□ WebGL build under size limit
□ 60 FPS on target hardware
□ JavaScript bridge working
□ Save/load functionality
□ Multiplayer sync working
□ Audio playing correctly
□ Input handling responsive
□ Mobile touch controls (if needed)