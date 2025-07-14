#!/bin/bash

set -e
INSTALL_ROOT="/opt/omniscient"
INSTALLERS_DIR="$INSTALL_ROOT/init"
VENV_PATH="$INSTALL_ROOT/venv"
USER_HOME="$INSTALL_ROOT/home/$USER"
LOG_FILE="$INSTALLERS_DIR/installers.log"
ALIASES_SECTION="# ====== Omniscient Aliases ======"

log() {
    echo "[`date`] $1" | tee -a "$LOG_FILE"
}

echo "[+] Initializing Omniscient Framework Installer..."

# Ensure base directories exist
mkdir -p "$INSTALL_ROOT" "$INSTALLERS_DIR" "$USER_HOME" "$INSTALL_ROOT/logs"

# Create standard user home directories
for dir in downloads logs scripts osint docs images video audio; do
    mkdir -p "$USER_HOME/$dir"
done

# Create default .bashrc
cat > "$INSTALL_ROOT/.bashrc" <<EOF
$ALIASES_SECTION
alias arm='sudo chmod +x'
alias implement='sudo apt install'
alias dropoff='sudo apt remove'
alias blowoff='sudo apt autoremove'
# ================================
source "$VENV_PATH/bin/activate"
cd "$INSTALL_ROOT"
EOF

# Add README for bashrc behavior
cat > "$INSTALL_ROOT/README.md" <<EOF
# Omniscient Shell Environment
This folder contains default shell configurations for Omniscient-managed users and environments.
- .bashrc auto-activates venv
- Loads Omniscient-specific aliases
- Default working directory: /opt/omniscient
EOF

# Create default .bash_profile
cat > "$INSTALL_ROOT/.bash_profile" <<EOF
# Omniscient shell profile
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
EOF

# Ensure core structure
mkdir -p "$INSTALL_ROOT"/{ai,backups,bin,compiled,conf,config,core,crons,crosstrax,db,dockers,docs,duckduckgosearch,factored_scripts,forensics,gui,hotswap,logs,management,manpages,osint,scripts,templates,web,www,home,init}

# Validate or create key files
touch "$INSTALL_ROOT/omniscient.conf"
touch "$INSTALL_ROOT/omniscientctl"
touch "$INSTALL_ROOT/rsysai.py"

# Install python3 and pip if not present
if ! command -v python3 &>/dev/null; then
    log "[*] Installing Python 3..."
    sudo apt update && sudo apt install -y python3
fi

if ! command -v pip3 &>/dev/null; then
    log "[*] Installing pip..."
    sudo apt install -y python3-pip
fi

# Create and activate universal venv
if [ ! -d "$VENV_PATH" ]; then
    python3 -m venv "$VENV_PATH"
fi
source "$VENV_PATH/bin/activate"

# Install Python packages
pip install --upgrade pip
pip install openai ollama streamlit transformers huggingface_hub accelerate

# Patch user's bashrc
grep -q "$ALIASES_SECTION" ~/.bashrc || cat "$INSTALL_ROOT/.bashrc" >> ~/.bashrc

# Set shell default directory
sed -i '/cd /d' ~/.bashrc
echo "cd $INSTALL_ROOT" >> ~/.bashrc

log "[✓] Omniscient Framework base system installed."

# Placeholder for future modules (e.g., RBAC CLI, jailed users, ngrok installer)
