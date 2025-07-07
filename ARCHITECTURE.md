# CLAUDE Framework Architecture

## System Overview

```mermaid
graph TB
    subgraph "User Input"
        U[User Prompt]
    end
    
    subgraph "Context Discovery Layer"
        CD[Context Discovery System]
        BP[Blunt Prompt Handlers]
        CD --> BP
    end
    
    subgraph "Intelligence Layer"
        ML[ML/LLM Scientist Refinement]
        MEM[Memory System]
        ML <--> MEM
    end
    
    subgraph "Routing Layer"
        DT[Decision Tree]
        ARCH[Archetypes]
        DT --> ARCH
    end
    
    subgraph "Execution Layer"
        P[Personas]
        E[Examples]
        PR[Protocols]
        P --> E
        P --> PR
    end
    
    subgraph "Enforcement Layer"
        FE[Framework Enforcer]
        FC[Framework Check]
        GH[Git Hooks]
        FE --> FC
        FE --> GH
    end
    
    U --> CD
    CD --> ML
    ML --> DT
    DT --> P
    P --> FE
    FE -.-> U
```

## Component Flow

```mermaid
sequenceDiagram
    participant User
    participant Context Discovery
    participant ML/LLM Scientist
    participant Decision Tree
    participant Personas
    participant Memory
    participant Enforcer
    
    User->>Context Discovery: Blunt prompt
    Context Discovery->>Context Discovery: Discover project state
    Context Discovery->>ML/LLM Scientist: Enriched context
    ML/LLM Scientist->>Memory: Check patterns
    Memory-->>ML/LLM Scientist: Similar patterns
    ML/LLM Scientist->>Decision Tree: Refined request
    Decision Tree->>Personas: Route to experts
    Personas->>Enforcer: Check compliance
    Enforcer-->>User: Block if non-compliant
    Personas->>Memory: Store success pattern
    Personas-->>User: Execute task
```

## Memory System Architecture

```mermaid
graph LR
    subgraph "Repository Memory"
        PM[Pattern Memory]
        CM[Context Memory]
        SM[Success Memory]
    end
    
    subgraph "Operations"
        L[Learn]
        F[Find]
        P[Predict]
        O[Optimize]
    end
    
    subgraph "Storage"
        J[JSONL Files]
        C[Cache]
        S[Statistics]
    end
    
    L --> PM
    F --> CM
    P --> SM
    O --> J
    PM --> J
    CM --> C
    SM --> S
```

## Framework Compliance Flow

```mermaid
stateDiagram-v2
    [*] --> Check_Compliance
    Check_Compliance --> ML_LLM_Loaded: Check personas
    ML_LLM_Loaded --> Context_Loaded: Load ML/LLM Scientist
    ML_LLM_Loaded --> Blocked: Not loaded
    Context_Loaded --> Memory_Init: Load context files
    Context_Loaded --> Blocked: Missing files
    Memory_Init --> Archetype_Selected: Initialize memory
    Memory_Init --> Blocked: Not initialized
    Archetype_Selected --> Implementation_Allowed: Select archetype
    Archetype_Selected --> Blocked: Not selected
    Implementation_Allowed --> [*]
    Blocked --> [*]
```

## Blunt Prompt Resolution

```mermaid
graph TD
    BP[Blunt Prompt]
    BP --> CD{Context Level?}
    CD -->|Low| DS[Discover State]
    CD -->|Medium| CQ[Clarifying Questions]
    CD -->|High| RT[Route Directly]
    
    DS --> PS[Project Structure]
    DS --> GS[Git State]
    DS --> BS[Build State]
    
    CQ --> IT[Intent Type]
    CQ --> SC[Scope]
    CQ --> RE[Requirements]
    
    PS --> EC[Enriched Context]
    GS --> EC
    BS --> EC
    IT --> EC
    SC --> EC
    RE --> EC
    
    EC --> RT
    RT --> FR[Framework Routing]
```

## P-CLI Command Structure

```mermaid
graph TD
    P[p command]
    P --> REPO[Repository Commands]
    P --> PROJ[Project Commands]
    P --> MEM[Memory Commands]
    P --> FRAME[Framework Commands]
    P --> COORD[Coordination Commands]
    
    REPO --> CR[create-repo]
    REPO --> CLF[clone-framework]
    
    PROJ --> CT[create-tasks]
    PROJ --> ATP[add-to-project]
    
    MEM --> MI[memory-init]
    MEM --> ML[memory-learn]
    MEM --> MF[memory-find]
    MEM --> MO[memory-optimize]
    
    FRAME --> FH[framework-health]
    FRAME --> FC[framework-check]
    
    COORD --> SC[set-context]
    COORD --> GC[get-context]
```

## Success Metrics Flow

```mermaid
graph LR
    subgraph "Input Metrics"
        BP[Blunt Prompts]
        CP[Clear Prompts]
    end
    
    subgraph "Processing"
        CD[Context Discovery]
        ML[ML/LLM Refinement]
        RT[Routing]
    end
    
    subgraph "Output Metrics"
        SR[Success Rate]
        FR[Failure Rate]
        TT[Time to Task]
    end
    
    BP --> CD
    CP --> ML
    CD --> ML
    ML --> RT
    RT --> SR
    RT --> FR
    RT --> TT
    
    SR --> |98.7%| Success
    FR --> |<10%| LowFailure
    TT --> |<2min| FastResponse
```

## Archetype Selection Tree

```mermaid
graph TD
    A[Project Type?]
    A --> WEB[Web Application]
    A --> MOB[Mobile App]
    A --> DESK[Desktop App]
    A --> CLI[CLI Tool]
    A --> LIB[Library]
    
    WEB --> STAT[Static Site]
    WEB --> SPA[Single Page App]
    WEB --> SERV[Server App]
    
    STAT --> |GitHub Pages| SW[static-websites.md]
    SPA --> |React/Vue| LA[local-apps.md]
    SERV --> |Lambda| SA[serverless-aws.md]
    
    MOB --> |React Native| MA[mobile-apps.md]
    DESK --> |Electron| DA[desktop-apps.md]
    CLI --> |Node/Python| CT[cli-tools.md]
    LIB --> |NPM Package| CP[component-project.md]
```

## Enforcement Mechanism

```mermaid
sequenceDiagram
    participant Developer
    participant Git
    participant Enforcer
    participant Framework
    
    Developer->>Git: git commit
    Git->>Enforcer: pre-commit hook
    Enforcer->>Framework: Check compliance
    Framework-->>Enforcer: Violations found
    Enforcer-->>Git: Block commit
    Git-->>Developer: Error: Framework violations
    
    Developer->>Framework: p framework-check
    Framework-->>Developer: Required actions
    Developer->>Framework: Complete requirements
    Developer->>Git: git commit
    Git->>Enforcer: pre-commit hook
    Enforcer->>Framework: Check compliance
    Framework-->>Enforcer: Compliant
    Enforcer-->>Git: Allow commit
    Git-->>Developer: Commit successful
```