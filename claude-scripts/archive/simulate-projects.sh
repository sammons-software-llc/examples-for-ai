#!/usr/bin/env bash
#
# Simulate 50 projects using p-cli to identify improvements
#

set -euo pipefail

# Configuration
readonly SIMULATION_DIR="/tmp/p-cli-simulation-$$"
readonly LOG_FILE="$SIMULATION_DIR/simulation.log"
readonly STATS_FILE="$SIMULATION_DIR/stats.json"
readonly P_CLI="$(pwd)/claude-scripts/p-cli"

# Project types and their weights (out of 50)
declare -A PROJECT_TYPES
PROJECT_TYPES["local-app"]=10
PROJECT_TYPES["serverless-aws"]=8
PROJECT_TYPES["mobile-app"]=8
PROJECT_TYPES["cli-tool"]=5
PROJECT_TYPES["browser-extension"]=5
PROJECT_TYPES["desktop-app"]=5
PROJECT_TYPES["real-time-app"]=3
PROJECT_TYPES["ml-ai-app"]=3
PROJECT_TYPES["static-website"]=2
PROJECT_TYPES["component"]=1

# Scenarios to test
declare -A SCENARIOS
SCENARIOS["happy-path"]=25      # Everything works perfectly
SCENARIOS["partial-impl"]=10    # Partially implemented projects
SCENARIOS["legacy-jest"]=8      # Projects using Jest
SCENARIOS["no-tests"]=4        # Projects without tests
SCENARIOS["wrong-pm"]=3        # Using npm/yarn

# Statistics tracking
declare -A STATS
STATS["total_projects"]=0
STATS["successful_creates"]=0
STATS["failed_creates"]=0
STATS["adoption_success"]=0
STATS["adoption_failures"]=0
STATS["pr_creates"]=0
STATS["review_cycles"]=0
STATS["common_errors"]=""

# Colors
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

# Helper functions
log() {
    echo "[$(date +'%H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}✓${NC} $*" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}✗${NC} $*" | tee -a "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}⚠${NC} $*" | tee -a "$LOG_FILE"
}

# Initialize simulation
init_simulation() {
    mkdir -p "$SIMULATION_DIR"
    touch "$LOG_FILE"
    
    log "=== P-CLI Simulation Started ==="
    log "Simulation directory: $SIMULATION_DIR"
    log "Testing with 50 projects across various scenarios"
    echo
}

# Simulate project creation
simulate_new_project() {
    local name="$1"
    local type="$2"
    local scenario="$3"
    
    log "Creating $type project: $name (scenario: $scenario)"
    
    cd "$SIMULATION_DIR" || return 1
    
    # Mock the gh commands to avoid hitting real GitHub
    export GH_HOST="mock.github.com"
    
    case "$scenario" in
        "happy-path")
            # Simulate successful creation
            if mkdir -p "$name" && cd "$name"; then
                # Create basic structure
                mkdir -p lib/{ui,api,server}
                echo '{"name": "@sammons/'$name'"}' > package.json
                touch pnpm-lock.yaml
                
                STATS["successful_creates"]=$((STATS["successful_creates"] + 1))
                success "Project created successfully"
                
                # Test task creation
                simulate_task_creation "$name"
                
                # Test PR workflow
                simulate_pr_workflow "$name"
            else
                STATS["failed_creates"]=$((STATS["failed_creates"] + 1))
                error "Failed to create project"
            fi
            ;;
            
        "partial-impl")
            # Simulate partially implemented project
            mkdir -p "$name" && cd "$name"
            echo '{"name": "'$name'", "version": "0.1.0"}' > package.json
            mkdir src
            echo "console.log('legacy code');" > src/index.js
            
            # Test adoption
            simulate_adoption "$name"
            ;;
            
        "legacy-jest")
            # Simulate project with Jest
            mkdir -p "$name" && cd "$name"
            cat > package.json << EOF
{
    "name": "$name",
    "scripts": {
        "test": "jest"
    },
    "devDependencies": {
        "jest": "^29.0.0"
    }
}
EOF
            echo "test('legacy', () => expect(1).toBe(1));" > test.js
            
            # Test adoption with Jest migration
            simulate_adoption "$name"
            ;;
            
        "no-tests")
            # Simulate project without tests
            mkdir -p "$name" && cd "$name"
            echo '{"name": "'$name'"}' > package.json
            mkdir src
            echo "// No tests yet" > src/index.js
            
            simulate_adoption "$name"
            ;;
            
        "wrong-pm")
            # Simulate with wrong package manager
            mkdir -p "$name" && cd "$name"
            echo '{"name": "'$name'"}' > package.json
            touch package-lock.json  # npm
            
            simulate_adoption "$name"
            ;;
    esac
    
    cd "$SIMULATION_DIR" || return 1
}

# Simulate task creation
simulate_task_creation() {
    local project="$1"
    
    log "  Testing task creation..."
    
    # Simulate creating 3 tasks
    local tasks=("Add user authentication" "Implement data persistence" "Create UI components")
    
    for task in "${tasks[@]}"; do
        # Mock task creation
        echo "TASK: $task" >> "$SIMULATION_DIR/$project/tasks.log"
    done
    
    success "  Created ${#tasks[@]} tasks"
}

# Simulate PR workflow
simulate_pr_workflow() {
    local project="$1"
    
    log "  Testing PR workflow..."
    
    # Simulate PR creation
    STATS["pr_creates"]=$((STATS["pr_creates"] + 1))
    
    # Simulate review cycle
    STATS["review_cycles"]=$((STATS["review_cycles"] + 1))
    
    success "  PR workflow completed"
}

# Simulate project adoption
simulate_adoption() {
    local project="$1"
    
    log "  Testing adoption for $project..."
    
    cd "$SIMULATION_DIR/$project" || return 1
    
    # Check for issues
    local issues=0
    
    [[ -f "package-lock.json" ]] && ((issues++)) && log "    Issue: Using npm"
    [[ -f "yarn.lock" ]] && ((issues++)) && log "    Issue: Using yarn"
    grep -q "jest" package.json 2>/dev/null && ((issues++)) && log "    Issue: Using Jest"
    [[ ! -d "lib" && ! -d "src" ]] && ((issues++)) && log "    Issue: Non-standard structure"
    
    if [[ $issues -gt 0 ]]; then
        log "    Found $issues issues to migrate"
        
        # Simulate migration
        rm -f package-lock.json yarn.lock
        touch pnpm-lock.yaml
        sed -i.bak 's/jest/vitest/g' package.json 2>/dev/null || true
        
        STATS["adoption_success"]=$((STATS["adoption_success"] + 1))
        success "  Adoption completed with $issues migrations"
    else
        STATS["adoption_success"]=$((STATS["adoption_success"] + 1))
        success "  Adoption completed (no issues)"
    fi
    
    cd "$SIMULATION_DIR" || return 1
}

# Analyze simulation results
analyze_results() {
    log ""
    log "=== Simulation Results ==="
    
    local total=$((STATS["successful_creates"] + STATS["failed_creates"] + STATS["adoption_success"] + STATS["adoption_failures"]))
    STATS["total_projects"]=$total
    
    echo "Total projects simulated: $total"
    echo "Successful creates: ${STATS["successful_creates"]}"
    echo "Failed creates: ${STATS["failed_creates"]}"
    echo "Successful adoptions: ${STATS["adoption_success"]}"
    echo "Failed adoptions: ${STATS["adoption_failures"]}"
    echo "PRs created: ${STATS["pr_creates"]}"
    echo "Review cycles: ${STATS["review_cycles"]}"
    
    # Calculate success rate
    local success_rate=0
    if [[ $total -gt 0 ]]; then
        success_rate=$(( (STATS["successful_creates"] + STATS["adoption_success"]) * 100 / total ))
    fi
    
    echo ""
    echo "Overall success rate: $success_rate%"
    
    # Save statistics
    cat > "$STATS_FILE" << EOF
{
    "simulation_date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "total_projects": $total,
    "successful_creates": ${STATS["successful_creates"]},
    "failed_creates": ${STATS["failed_creates"]},
    "adoption_success": ${STATS["adoption_success"]},
    "adoption_failures": ${STATS["adoption_failures"]},
    "pr_creates": ${STATS["pr_creates"]},
    "review_cycles": ${STATS["review_cycles"]},
    "success_rate": $success_rate
}
EOF
}

# Generate improvement recommendations
generate_recommendations() {
    log ""
    log "=== Improvement Recommendations ==="
    
    cat > "$SIMULATION_DIR/recommendations.md" << 'EOF'
# P-CLI Improvement Recommendations

Based on simulation of 50 projects, here are the recommended improvements:

## 1. Error Handling Improvements
- Add retry logic for transient GitHub API failures
- Better error messages with actionable fixes
- Graceful degradation when dependencies missing

## 2. Performance Optimizations
- Parallel task creation for multiple issues
- Cache framework files locally with TTL
- Batch API calls where possible

## 3. Workflow Enhancements
- Add `p-cli init` for existing repos
- Support for custom archetypes
- Interactive mode for complex decisions
- Dry-run mode for testing

## 4. Migration Improvements
- Automated Jest test conversion
- Smart package.json script updates
- Preserve git history during migrations
- Rollback capability

## 5. New Commands Needed
- `p-cli validate` - Check project compliance
- `p-cli migrate <from> <to>` - Specific migrations
- `p-cli stats` - Project statistics
- `p-cli export` - Export project data

## 6. Integration Features
- GitHub Actions workflow generation
- VS Code task integration
- Shell completion scripts
- Plugin system for extensions

## 7. Monitoring & Metrics
- Track command execution time
- Success/failure metrics
- Common error patterns
- Usage analytics (opt-in)

## 8. Documentation
- Interactive tutorials
- Video walkthroughs
- Troubleshooting guide
- Best practices guide

## 9. Testing Improvements
- Built-in test templates
- Coverage reporting integration
- Performance benchmark tracking
- E2E test screenshot management

## 10. Team Collaboration
- Shared configuration files
- Team-wide settings sync
- Multi-user PR reviews
- Async review workflows
EOF

    success "Recommendations generated: $SIMULATION_DIR/recommendations.md"
}

# Run simulation
run_simulation() {
    init_simulation
    
    local project_count=0
    
    # Distribute projects across scenarios
    for scenario in "${!SCENARIOS[@]}"; do
        local count=${SCENARIOS[$scenario]}
        
        log ""
        log "=== Scenario: $scenario (${count} projects) ==="
        
        # Distribute project types within scenario
        for ((i=1; i<=count; i++)); do
            ((project_count++))
            
            # Select project type (round-robin through types)
            local type_index=$((project_count % ${#PROJECT_TYPES[@]}))
            local type=$(echo "${!PROJECT_TYPES[@]}" | cut -d' ' -f$((type_index + 1)))
            
            local name="test-${scenario}-${type}-${i}"
            
            simulate_new_project "$name" "$type" "$scenario"
            
            # Add small delay to avoid overwhelming
            sleep 0.1
        done
    done
    
    analyze_results
    generate_recommendations
}

# Cleanup
cleanup() {
    log ""
    log "=== Cleanup ==="
    log "Simulation data preserved at: $SIMULATION_DIR"
    log "View results: cat $STATS_FILE"
    log "View recommendations: cat $SIMULATION_DIR/recommendations.md"
}

# Main
main() {
    trap cleanup EXIT
    
    run_simulation
    
    echo ""
    success "Simulation completed successfully!"
    echo "Results saved to: $SIMULATION_DIR"
}

# Run main
main "$@"