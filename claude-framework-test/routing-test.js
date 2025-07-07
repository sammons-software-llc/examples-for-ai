/**
 * Framework Routing System Test
 * Demonstrates the decision tree from CLAUDE.md
 */

class FrameworkRouter {
  constructor() {
    this.archetypes = [
      'static-websites', 'local-apps', 'serverless-aws', 
      'component-project', 'desktop-apps', 'mobile-apps',
      'browser-extensions', 'cli-tools', 'real-time-apps',
      'ml-ai-apps', 'iot-home-assistant', 'unity-games'
    ];
  }

  route(task) {
    console.log(`\n=== ROUTING TASK: "${task}" ===`);
    
    // Determine task type
    const taskType = this.determineTaskType(task);
    console.log(`Task Type: ${taskType}`);
    
    // Get required contexts based on decision tree
    const contexts = this.getRequiredContexts(taskType, task);
    console.log(`\nRequired Contexts:`);
    contexts.forEach(ctx => console.log(`  - ${ctx}`));
    
    // Get triggered contexts based on keywords
    const triggeredContexts = this.getTriggeredContexts(task);
    if (triggeredContexts.length > 0) {
      console.log(`\nTriggered Contexts (by keywords):`);
      triggeredContexts.forEach(ctx => console.log(`  - ${ctx}`));
    }
    
    return { taskType, contexts, triggeredContexts };
  }

  determineTaskType(task) {
    const taskLower = task.toLowerCase();
    
    if (taskLower.includes('create') || taskLower.includes('new') || taskLower.includes('build')) {
      return 'creating_new_project';
    }
    if (taskLower.includes('review') || taskLower.includes('check')) {
      return 'reviewing_code';
    }
    if (taskLower.includes('implement') || taskLower.includes('add feature')) {
      return 'implementing_feature';
    }
    if (taskLower.includes('fix') || taskLower.includes('debug') || taskLower.includes('bug')) {
      return 'fixing_bugs';
    }
    if (taskLower.includes('adopt') || taskLower.includes('migrate')) {
      return 'adopting_existing_project';
    }
    if (taskLower.includes('resume') || taskLower.includes('continue')) {
      return 'resuming_work';
    }
    
    return 'general_task';
  }

  getRequiredContexts(taskType, task) {
    const contexts = [];
    
    switch (taskType) {
      case 'creating_new_project':
        const archetype = this.detectArchetype(task);
        if (archetype) contexts.push(`./archetypes/${archetype}.md`);
        contexts.push('./examples/process-overview.md');
        if (task.toLowerCase().includes('complex')) {
          contexts.push('./examples/development-phases.md');
        }
        contexts.push('./examples/config/environment.md');
        break;
        
      case 'reviewing_code':
        contexts.push('./personas/security-expert.md');
        contexts.push('./personas/architect.md');
        contexts.push('./personas/performance-expert.md');
        contexts.push('./personas/ux-designer.md');
        break;
        
      case 'implementing_feature':
        contexts.push('./personas/developer.md');
        contexts.push('./examples/code-structure.md');
        contexts.push('./examples/testing-patterns.md');
        break;
        
      case 'fixing_bugs':
        contexts.push('./examples/processes/8-step-fixes.md');
        contexts.push('./examples/protocols/error-recovery.md');
        contexts.push('./personas/developer.md');
        break;
        
      case 'adopting_existing_project':
        contexts.push('./examples/processes/adopt-project.md');
        break;
        
      case 'resuming_work':
        contexts.push('./examples/processes/resume-work.md');
        break;
        
      default:
        contexts.push('./personas/team-lead.md');
    }
    
    return contexts;
  }

  detectArchetype(task) {
    const taskLower = task.toLowerCase();
    
    if (taskLower.includes('static') || taskLower.includes('github pages')) return 'static-websites';
    if (taskLower.includes('cli') || taskLower.includes('command line')) return 'cli-tools';
    if (taskLower.includes('desktop') && !taskLower.includes('web')) return 'desktop-apps';
    if (taskLower.includes('mobile') || taskLower.includes('react native')) return 'mobile-apps';
    if (taskLower.includes('serverless') || taskLower.includes('lambda')) return 'serverless-aws';
    if (taskLower.includes('websocket') || taskLower.includes('real-time')) return 'real-time-apps';
    if (taskLower.includes('ml') || taskLower.includes('ai')) return 'ml-ai-apps';
    if (taskLower.includes('extension') || taskLower.includes('chrome')) return 'browser-extensions';
    if (taskLower.includes('component') || taskLower.includes('library')) return 'component-project';
    if (taskLower.includes('iot') || taskLower.includes('home assistant')) return 'iot-home-assistant';
    if (taskLower.includes('unity') || taskLower.includes('game')) return 'unity-games';
    if (taskLower.includes('app') && !taskLower.includes('desktop')) return 'local-apps';
    
    return null;
  }

  getTriggeredContexts(task) {
    const contexts = [];
    const taskLower = task.toLowerCase();
    
    // Check deployment keywords
    if (/deploy|production|release|docker|k8s|aws|gcp/.test(taskLower)) {
      contexts.push('./examples/config/deployment.md');
    }
    
    // Check monitoring keywords
    if (/metrics|logs|telemetry|observability|performance/.test(taskLower)) {
      contexts.push('./examples/monitoring-setup.md');
    }
    
    // Check testing keywords
    if (/test|spec|unit|integration|e2e|vitest/.test(taskLower)) {
      contexts.push('./examples/testing-patterns.md');
    }
    
    // Check configuration keywords
    if (/config|settings|env|dotenv|environment/.test(taskLower)) {
      contexts.push('./examples/config/environment.md');
      if (taskLower.includes('typescript')) contexts.push('./examples/config/typescript.md');
      if (taskLower.includes('build')) contexts.push('./examples/config/build-tools.md');
      if (taskLower.includes('lint')) contexts.push('./examples/config/linting.md');
      if (taskLower.includes('package')) contexts.push('./examples/config/package-management.md');
    }
    
    // Check performance keywords
    if (/optimize|slow|performance|benchmark|profiling/.test(taskLower)) {
      contexts.push('./personas/performance-expert.md');
    }
    
    // Check UX keywords
    if (/user|interface|design|accessibility|usability/.test(taskLower)) {
      contexts.push('./personas/ux-designer.md');
    }
    
    // Check websocket keywords
    if (/websocket|realtime|socket\.io|ws/.test(taskLower)) {
      contexts.push('./examples/websocket-setup.md');
    }
    
    return contexts;
  }
}

// Test the routing system
const router = new FrameworkRouter();
console.log('Testing Framework Routing System:\n');

const testTasks = [
  'create a new CLI tool with testing',
  'review the authentication code for security issues',
  'implement websocket feature with real-time updates',
  'fix performance bug in production deployment',
  'create complex serverless AWS application with monitoring',
  'adopt existing React Native mobile app'
];

testTasks.forEach(task => {
  router.route(task);
});