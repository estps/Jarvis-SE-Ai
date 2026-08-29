#!/usr/bin/env python3
"""
Host.py - Python Bridge for Ollama AI Integration
ComputerCraft 1.21.1 NeoForge Jarvis System

Handles communication with Ollama API for AI responses.
"""

import sys
import json
import requests
import os
import time

def main():
    """Main entry point - receive question from Host.lua and query Ollama."""
    
    # Get question from command line arguments
    if len(sys.argv) < 2:
        print(json.dumps({
            "response": "Jarvis: Please provide a question. Usage: python Host.py \"your question\"",
            "status": "error"
        }))
        sys.exit(1)
    
    # Join all args as the question (handles spaces properly)
    question = " ".join(sys.argv[1:])
    
    # Ollama configuration
    ollama_host = os.environ.get("OLAMA_HOST", "http://localhost:11434")
    ollama_model = os.environ.get("OLAMA_MODEL", "phi3:mini")
    
    try:
        # Query Ollama API
        url = f"{ollama_host}/api/generate"
        payload = {
            "model": ollama_model,
            "prompt": question,
            "stream": False,
            "options": {
                "temperature": 0.7,
                "top_p": 0.9,
                "max_tokens": 500
            }
        }
        
        response = requests.post(url, json=payload, timeout=30)
        
        if response.status_code == 200:
            result = response.json()
            ai_response = result.get("response", "")
            
            # Format as Jarvis response
            formatted_response = f"Jarvis: {ai_response.strip()}"
            
            output = {
                "response": formatted_response,
                "status": "success",
                "model": ollama_model,
                "timestamp": time.strftime("%H:%M:%S")
            }
        else:
            output = {
                "response": f"Jarvis: Sorry, Ollama API returned status {response.status_code}",
                "status": "error"
            }
    
    except requests.exceptions.ConnectionError:
        # Ollama not running - fallback response
        output = {
            "response": "Jarvis: I'm having trouble connecting to the AI cloud service. " ..
                       "Ensure Ollama is running with: ollama serve",
            "status": "fallback"
        }
    except requests.exceptions.Timeout:
        output = {
            "response": "Jarvis: The AI response timed out. The cloud model may be loading.",
            "status": "timeout"
        }
    except Exception as e:
        output = {
            "response": f"Jarvis: Error contacting AI: {str(e)}",
            "status": "error"
        }
    
    # Output JSON to stdout - Host.lua will capture this
    print(json.dumps(output))
    
    # Also write to temp file for Host.lua to read
    try:
        response_file = os.environ.get("JARVIS_RESPONSE_FILE", "/tmp/jarvis_response.txt")
        with open(response_file, "w") as f:
            f.write(json.dumps(output))
    except:
        pass  # Best effort - primary output is stdout

if __name__ == "__main__":
    main()