#!/bin/bash

# IMMORTAL GUARDIAN SCRIPT - Omniscient Sub-System Integrity Sentinel
# Location: /opt/omniscient/management/verify_omniscient.sh

# Immutable Directories to Monitor
IMMUTABLE_DIRS=(
    "/opt/omniscient/compiled"
    "/opt/omniscient/conf"
    "/opt/omniscient/db"
    "/opt/omniscient/deb"
    "/opt/omniscient/dockers"
    "/opt/omniscient/docs"
    "/opt/omniscient/factored_scripts"
    "/opt/omniscient/forensics"
    "/opt/omniscient/gui"
    "/opt/omniscient/management"
    "/opt/omniscient/manpages"
    "/opt/omniscient/osint"
    "/opt/omniscient/readme"
    "/opt/omniscient/scripts"
    "/opt/omniscient/voice"
    "/opt/omniscient/web"
)

# Checksum registry file
CHECKSUM_FILE="/opt/omniscient/management/omniscient_checksums.sha256"

# Initialize if missing
init_checksums() {
    echo "[INIT] Generating initial checksums for Omniscient directories..."
    > "$CHECKSUM_FILE"
    for dir in "${IMMUTABLE_DIRS[@]}"; do
        find "$dir" -type f -exec sha256sum {} \; >> "$CHECKSUM_FILE"
    done
    echo "[INIT COMPLETE] Checksums registered at $CHECKSUM_FILE."
}

# Validate checksum integrity
verify_checksums() {
    echo "[VERIFY] Validating integrity of Omniscient sub-system..."
    if [[ ! -f "$CHECKSUM_FILE" ]]; then
        echo "[ERROR] Checksum file missing! Please run with --init first."
        exit 1
    fi
    sha256sum -c "$CHECKSUM_FILE" 2>&1 | tee /var/log/omniscient_guardian.log | grep -E "FAILED|OK"
}

# Lockdown directories with immutability
lockdown_directories() {
    echo "[LOCKDOWN] Applying immutable bit to all protected directories..."
    for dir in "${IMMUTABLE_DIRS[@]}"; do
        chattr -R +i "$dir"
        echo "[LOCKED] $dir"
    done
    echo "[LOCKDOWN COMPLETE] All directories locked."
}

# Main logic
case "$1" in
    --init)
        init_checksums
        ;;
    --verify)
        verify_checksums
        ;;
    --lockdown)
        lockdown_directories
        ;;
    *)
        echo "Omniscient Integrity Sentinel™"
        echo "Usage:"
        echo "  --init       Initialize checksums"
        echo "  --verify     Verify current file integrity"
        echo "  --lockdown   Enforce immutable bit on protected directories"
        ;;
esac
