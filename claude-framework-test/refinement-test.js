/**
 * ML/LLM Scientist Refinement Test
 * Demonstrates the refinement process from CLAUDE.md
 */

class MLLLMScientistRefinement {
  constructor() {
    this.refinementSteps = [
      'Analyze user intent',
      'Identify ambiguities',
      'Refine request for routing',
      'Predict resource requirements'
    ];
  }

  refineRequest(userRequest) {
    console.log('=== ML/LLM SCIENTIST REFINEMENT ===');
    console.log(`Original request: "${userRequest}"`);
    
    // Simulate refinement process
    const analysis = {
      semanticIntent: this.extractIntent(userRequest),
      ambiguities: this.identifyAmbiguities(userRequest),
      refinedRequest: this.optimizeForRouting(userRequest),
      predictedResources: this.predictResources(userRequest)
    };
    
    console.log('\nRefinement Analysis:');
    console.log(`- Semantic Intent: ${analysis.semanticIntent}`);
    console.log(`- Ambiguities: ${analysis.ambiguities.join(', ') || 'None'}`);
    console.log(`- Refined Request: ${analysis.refinedRequest}`);
    console.log(`- Predicted Resources: ${analysis.predictedResources.join(', ')}`);
    
    return analysis;
  }

  extractIntent(request) {
    if (request.includes('create')) return 'creation_task';
    if (request.includes('fix') || request.includes('debug')) return 'debugging_task';
    if (request.includes('review')) return 'review_task';
    return 'general_task';
  }

  identifyAmbiguities(request) {
    const ambiguities = [];
    if (!request.includes('language') && request.includes('app')) {
      ambiguities.push('Programming language not specified');
    }
    if (!request.includes('type') && request.includes('create')) {
      ambiguities.push('Project type not specified');
    }
    return ambiguities;
  }

  optimizeForRouting(request) {
    // Simulate optimization for framework routing
    const intent = this.extractIntent(request);
    if (intent === 'creation_task') {
      return `[CREATE_PROJECT] ${request} - Route to archetype selection`;
    }
    if (intent === 'debugging_task') {
      return `[DEBUG] ${request} - Route to 8-step-fixes process`;
    }
    return `[GENERAL] ${request} - Route to team-lead persona`;
  }

  predictResources(request) {
    const resources = [];
    if (request.includes('create')) {
      resources.push('./archetypes/', './examples/process-overview.md');
    }
    if (request.includes('test')) {
      resources.push('./examples/testing-patterns.md');
    }
    if (request.includes('deploy')) {
      resources.push('./examples/config/deployment.md');
    }
    return resources.length > 0 ? resources : ['./personas/team-lead.md'];
  }
}

// Test the refinement
const refinement = new MLLLMScientistRefinement();
console.log('Testing ML/LLM Scientist Refinement Process:\n');

// Test cases
const testRequests = [
  'create a new web app',
  'fix the authentication bug',
  'review the code for security issues',
  'deploy the application to production'
];

testRequests.forEach(request => {
  refinement.refineRequest(request);
  console.log('\n' + '='.repeat(50) + '\n');
});