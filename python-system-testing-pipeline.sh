#!/bin/bash

# === Configuration ===
ROOT_DIR="/opt/omniscient"
AI_DIR="$ROOT_DIR/ai"
LOG_DIR="$ROOT_DIR/logs/test_logs"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
SESSION_LOG="$LOG_DIR/test_session_$TIMESTAMP.log"
JSON_SUMMARY="$LOG_DIR/test_summary_$TIMESTAMP.json"
AI_FEEDBACK_LOG="$LOG_DIR/ai_feedback_$TIMESTAMP.md"
OLLAMA_MODEL="whiterabbitneo"

EXCLUDE_DIRS=("venv" "privategpt" "private-gpt" "__pycache__" "tests")

mkdir -p "$LOG_DIR"

# === Initialize JSON summary ===
echo "[" > "$JSON_SUMMARY"

# === Find all Python scripts, excluding unwanted dirs ===
mapfile -t py_scripts < <(
  find "$AI_DIR" -type f -name "*.py" | grep -Ev "$(IFS="|"; echo "${EXCLUDE_DIRS[*]}")"
)

# === Run each script, log outputs and errors ===
for script in "${py_scripts[@]}"; do
  RELATIVE_PATH="${script#$ROOT_DIR/}"
  SCRIPT_LOG="$LOG_DIR/$(echo "$RELATIVE_PATH" | tr '/' '_' | sed 's/.py$//')_$TIMESTAMP.log"

  echo "🔍 Testing $RELATIVE_PATH..."

  {
    echo "=== Running: $RELATIVE_PATH ==="
    echo "Timestamp: $(date)"
    echo
    python3 "$script"
    EXIT_CODE=$?
    echo
    echo "Exit Code: $EXIT_CODE"
  } &> "$SCRIPT_LOG"

  echo "[$(date)] $RELATIVE_PATH => Exit: $EXIT_CODE" >> "$SESSION_LOG"

  echo "  {" >> "$JSON_SUMMARY"
  echo "    \"script\": \"$RELATIVE_PATH\"," >> "$JSON_SUMMARY"
  echo "    \"exit_code\": $EXIT_CODE," >> "$JSON_SUMMARY"
  echo "    \"log_file\": \"$SCRIPT_LOG\"" >> "$JSON_SUMMARY"
  echo "  }," >> "$JSON_SUMMARY"
done

# Remove last comma and close JSON
sed -i '$ s/},/}/' "$JSON_SUMMARY"
echo "]" >> "$JSON_SUMMARY"

echo -e "\n✅ Test run complete. Summary: $JSON_SUMMARY"

# === OLLAMA LLM POST-TEST PIPELINE ===

echo -e "\n🤖 Sending test results to Ollama ($OLLAMA_MODEL)..."
OLLAMA_PROMPT="You are an AI debugging assistant. Analyze the following JSON summary of test results from a Python AI framework. Identify failing scripts, suggest fixes, and generate README notes for each tested module.\n\n"

# Run Ollama pipeline
{
  echo -e "$OLLAMA_PROMPT"
  cat "$JSON_SUMMARY"
} | ollama run "$OLLAMA_MODEL" > "$AI_FEEDBACK_LOG"

echo "🧠 AI feedback written to: $AI_FEEDBACK_LOG"

