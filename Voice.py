#!/usr/bin/env python3
"""
Voice.py - Voice Input using Vosk STT
ComputerCraft 1.21.1 NeoForge Jarvis System

Handles speech-to-text using Vosk small model for Jarvis voice commands.
"""

import sys
import json
import os
import struct
import pyaudio
from vosk import Model, KaldiRecognizer

class VoskSTT:
    """Vosk Speech-to-Text handler for ComputerCraft Jarvis system."""
    
    def __init__(self, model_path=None, sample_rate=16000):
        """
        Initialize Vosk STT.
        
        Args:
            model_path: Path to Vosk model directory (defaults to smallest model)
            sample_rate: Audio sample rate (default 16kHz)
        """
        self.sample_rate = sample_rate
        self.model_path = model_path or self._get_default_model_path()
        self.model = None
        self.recognizer = None
        self.p = None
        self.stream = None
        
        self._initialize_vosk()
    
    def _get_default_model_path(self):
        """Get path to smallest Vosk model."""
        # Try common locations for small model
        default_paths = [
            "vosk-model-small-en-us",
            "/usr/share/vosk/model",
            os.path.expanduser("~/.vosk/models"),
        ]
        
        for path in default_paths:
            if os.path.exists(path):
                return path
        
        # Return default and let user handle
        print("Warning: No default Vosk model found, using 'vosk-model-small-en-us'")
        return "vosk-model-small-en-us"
    
    def _initialize_vosk(self):
        """Initialize Vosk model and audio stream."""
        try:
            # Load Vosk model
            if not os.path.exists(self.model_path):
                print(f"Error: Vosk model not found at '{self.model_path}'")
                print("Download from: https://alphacephei.com/vosk/models")
                print("Use: vosk-model-small-en-us for fastest performance")
                sys.exit(1)
            
            print(f"Loading Vosk model from: {self.model_path}")
            self.model = Model(self.model_path)
            
            # Initialize recognizer
            self.recognizer = KaldiRecognizer(self.model, self.sample_rate)
            self.recognizer.SetWords(True)
            
            # Initialize PyAudio
            self.p = pyaudio.PyAudio()
            
            # Open audio stream
            self.stream = self.p.open(
                format=pyaudio.paInt16,
                channels=1,
                rate=self.sample_rate,
                input=True,
                frames_per_buffer=8000
            )
            
            print("Vosk STT initialized successfully")
            print("Listening for speech...")
            
        except ImportError:
            print("Error: 'vosk' Python package not installed")
            print("Install with: pip install vosk")
            print("Also install: pip install pyaudio")
            sys.exit(1)
        except Exception as e:
            print(f"Error initializing Vosk: {e}")
            sys.exit(1)
    
    def listen(self, timeout=5, phrase_time_limit=10):
        """
        Listen for speech and return recognized text.
        
        Args:
            timeout: Seconds of silence before stopping (default 5)
            phrase_time_limit: Max seconds of speaking (default 10)
            
        Returns:
            Recognized text string, or None if no speech detected
        """
        if not self.stream:
            return None
        
        try:
            # Start streaming
            self.stream.start_stream()
            
            last_speech_time = None
            final_text = ""
            
            while True:
                # Read audio data
                data = self.stream.read(4000, exception_occurred=False)
                
                if len(data) == 0:
                    break
                
                # Process with Vosk
                if self.recognizer.AcceptWaveform(data):
                    result = json.loads(self.recognizer.Result())
                    text = result.get("text", "")
                    
                    if text:
                        final_text = text
                        last_speech_time = None  # Reset silence timer
                else:
                    # Partial result
                    result = json.loads(self.recognizer.PartialResult())
                    partial = result.get("partial", "")
                    
                    # Could accumulate partial results here
            
            # Get final result
            self.stream.stop_stream()
            
            final_result = json.loads(self.recognizer.FinalResult())
            final_text = final_result.get("text", final_text)
            
            if final_text.strip():
                return final_text.strip()
            else:
                return None
                
        except KeyboardInterrupt:
            self.stream.stop_stream()
            return None
        except Exception as e:
            print(f"Error during speech recognition: {e}")
            try:
                self.stream.stop_stream()
            except:
                pass
            return None
    
    def continuous_listen(self, callback, stop_callback=None):
        """
        Continuous listening mode.
        
        Args:
            callback: Function to call with recognized text
            stop_callback: Optional function that returns True to stop
        """
        print("Starting continuous listening... (Ctrl+C to stop)")
        
        try:
            self.stream.start_stream()
            
            while True:
                # Check stop callback
                if stop_callback and stop_callback():
                    break
                
                data = self.stream.read(4000, exception_occurred=False)
                
                if self.recognizer.AcceptWaveform(data):
                    result = json.loads(self.recognizer.Result())
                    text = result.get("text", "")
                    if text.strip():
                        callback(text.strip())
                        
        except KeyboardInterrupt:
            print("\nStopping continuous listen mode")
        finally:
            self.stream.stop_stream()
    
    def shutdown(self):
        """Clean up resources."""
        if self.stream:
            self.stream.stop_stream()
            self.stream.close()
        if self.p:
            self.p.terminate()
        print("Vosk STT shutdown complete")


def main():
    """Main entry point - listen for speech and output text."""
    
    # Initialize Vosk STT
    stt = VoskSTT()
    
    # Listen for one phrase
    print("Listening for your command...")
    text = stt.listen(timeout=5, phrase_time_limit=10)
    
    if text:
        print(f"Recognized: {text}")
        
        # Output as JSON for Host.lua to capture
        output = {
            "success": True,
            "text": text,
            "source": "voice_input"
        }
        print(json.dumps(output))
    else:
        print("No speech detected")
        output = {
            "success": False,
            "text": "",
            "source": "voice_input"
        }
        print(json.dumps(output))


if __name__ == "__main__":
    main()