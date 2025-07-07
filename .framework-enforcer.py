#!/usr/bin/env python3
"""
CLAUDE Framework Enforcer
Automatically blocks non-compliant actions and enforces framework requirements
"""

import json
import os
import sys
import subprocess
from datetime import datetime
from pathlib import Path

class FrameworkEnforcer:
    def __init__(self):
        self.state_file = Path(".framework-state.json")
        self.compliance_log = Path(".framework-compliance.log")
        self.load_state()
        
    def load_state(self):
        """Load framework state from file"""
        if self.state_file.exists():
            with open(self.state_file, 'r') as f:
                self.state = json.load(f)
        else:
            self.state = {
                "ml_llm_scientist_loaded": False,
                "context_files_loaded": [],
                "memory_initialized": False,
                "archetype_selected": None,
                "compliance_checks": [],
                "violations": [],
                "implementation_allowed": False
            }
    
    def save_state(self):
        """Save framework state to file"""
        with open(self.state_file, 'w') as f:
            json.dump(self.state, f, indent=2)
    
    def check_compliance(self):
        """Check all framework requirements"""
        violations = []
        
        # Check ML/LLM Scientist
        if not self.state["ml_llm_scientist_loaded"]:
            if not self.check_log_entry("ML/LLM scientist loaded"):
                violations.append({
                    "requirement": "ML/LLM Scientist Persona",
                    "status": "NOT LOADED",
                    "action": "cat personas/ml-llm-scientist.md",
                    "log_command": "echo 'ML/LLM scientist loaded' >> .framework-compliance.log"
                })
        
        # Check Context Files
        required_context = ["about-ben.md", "workflow.md", "tech-stack.md"]
        for file in required_context:
            if file not in self.state["context_files_loaded"]:
                if not self.check_log_entry(f"{file} loaded"):
                    violations.append({
                        "requirement": f"Context File: {file}",
                        "status": "NOT LOADED",
                        "action": f"cat context/{file}",
                        "log_command": f"echo '{file} loaded' >> .framework-compliance.log"
                    })
        
        # Check Memory System
        if not self.state["memory_initialized"]:
            if not self.check_memory_system():
                violations.append({
                    "requirement": "Memory System",
                    "status": "NOT INITIALIZED",
                    "action": "p memory-init",
                    "log_command": "# Automatic after p memory-init"
                })
        
        # Check Archetype
        if not self.state["archetype_selected"]:
            if not Path(".selected-archetype").exists():
                violations.append({
                    "requirement": "Archetype Selection",
                    "status": "NOT SELECTED",
                    "action": "Select and load appropriate archetype",
                    "log_command": "echo '[archetype-name]' > .selected-archetype"
                })
        
        return violations
    
    def check_log_entry(self, entry):
        """Check if entry exists in compliance log"""
        if not self.compliance_log.exists():
            return False
        
        with open(self.compliance_log, 'r') as f:
            return entry in f.read()
    
    def check_memory_system(self):
        """Check if memory system is initialized"""
        try:
            result = subprocess.run(['./claude-scripts/p', 'memory-stats'], 
                                  capture_output=True, text=True)
            return result.returncode == 0
        except:
            return False
    
    def enforce(self, action="check"):
        """Main enforcement logic"""
        print("🔒 CLAUDE Framework Enforcer")
        print("============================")
        
        violations = self.check_compliance()
        
        if violations:
            print(f"\n❌ FRAMEWORK VIOLATIONS: {len(violations)}")
            print("\nRequired steps not completed:")
            
            for i, v in enumerate(violations, 1):
                print(f"\n{i}. {v['requirement']}: {v['status']}")
                print(f"   ACTION: {v['action']}")
                if v['log_command'] != "# Automatic after p memory-init":
                    print(f"   LOG: {v['log_command']}")
            
            print("\n⛔ IMPLEMENTATION BLOCKED")
            print("Complete ALL required steps above before proceeding.\n")
            
            # Log violation
            self.state["violations"].append({
                "timestamp": datetime.now().isoformat(),
                "action": action,
                "violations_count": len(violations),
                "details": violations
            })
            self.save_state()
            
            return False
        else:
            print("\n✅ FRAMEWORK COMPLIANT")
            print("All requirements satisfied. You may proceed.\n")
            
            # Log compliance
            self.state["compliance_checks"].append({
                "timestamp": datetime.now().isoformat(),
                "action": action,
                "status": "compliant"
            })
            self.state["implementation_allowed"] = True
            self.save_state()
            
            return True
    
    def update_state(self, key, value):
        """Update framework state"""
        if key == "context_file_loaded":
            if value not in self.state["context_files_loaded"]:
                self.state["context_files_loaded"].append(value)
        else:
            self.state[key] = value
        self.save_state()

def main():
    """CLI interface for framework enforcer"""
    enforcer = FrameworkEnforcer()
    
    if len(sys.argv) < 2:
        # Default check
        success = enforcer.enforce("manual_check")
        sys.exit(0 if success else 1)
    
    command = sys.argv[1]
    
    if command == "check":
        success = enforcer.enforce("manual_check")
        sys.exit(0 if success else 1)
    
    elif command == "pre-edit":
        # Check before allowing file edits
        if len(sys.argv) > 2:
            filename = sys.argv[2]
            print(f"Checking compliance before editing: {filename}")
        success = enforcer.enforce("pre_edit")
        sys.exit(0 if success else 1)
    
    elif command == "pre-commit":
        # Check before allowing git commits
        success = enforcer.enforce("pre_commit")
        sys.exit(0 if success else 1)
    
    elif command == "update":
        # Update state based on completed actions
        if len(sys.argv) < 4:
            print("Usage: .framework-enforcer.py update <key> <value>")
            sys.exit(1)
        
        key = sys.argv[2]
        value = sys.argv[3]
        enforcer.update_state(key, value)
        print(f"✅ Updated: {key} = {value}")
    
    elif command == "reset":
        # Reset framework state
        if Path(".framework-state.json").exists():
            Path(".framework-state.json").unlink()
        print("🔄 Framework state reset")
    
    else:
        print(f"Unknown command: {command}")
        print("Available commands: check, pre-edit, pre-commit, update, reset")
        sys.exit(1)

if __name__ == "__main__":
    main()