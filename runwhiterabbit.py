#!/usr/bin/env python3

import os
import subprocess
import sys
from pathlib import Path

VENV_DIR = Path(__file__).parent / "venv"
PYTHON_BIN = VENV_DIR / "bin" / "python3"
SCRIPT_FILE = Path(__file__).parent / "local_llm_whiterabbitneo.py"

# Step 1: Create a virtual environment if it doesn't exist
def create_venv():
    if not VENV_DIR.exists():
        print("[*] Creating virtual environment...")
        subprocess.run([sys.executable, "-m", "venv", str(VENV_DIR)], check=True)
    else:
        print("[✓] Virtual environment already exists.")

# Step 2: Install required dependencies inside the venv
def install_dependencies():
    print("[*] Installing dependencies in venv...")
    subprocess.run([
        str(PYTHON_BIN), "-m", "pip", "install", "--upgrade", "pip", "llama-cpp-python"
    ], check=True)

# Step 3: Run the WhiteRabbitNeo script inside the venv
def run_script():
    if not SCRIPT_FILE.exists():
        print(f"[!] LLM script not found: {SCRIPT_FILE}")
        sys.exit(1)

    print(f"[>] Running: {SCRIPT_FILE.name}")
    subprocess.run([str(PYTHON_BIN), str(SCRIPT_FILE)])

def main():
    create_venv()
    install_dependencies()
    run_script()

if __name__ == "__main__":
    main()
