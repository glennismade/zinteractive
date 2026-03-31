#!/bin/sh
# Zinteractive — built-in AWS/environment functions

ZI_ENV_FILE="${ZI_ENV_FILE:-$HOME/.config/zinteractive/.env}"

# Load a specific set of vars from the .env file by prefix
# Usage: zi_loadenv AWS_STAGING  → exports AWS_STAGING_ACCESS_KEY_ID as AWS_ACCESS_KEY_ID, etc.
zi_loadenv() {
  local prefix="$1"
  if [ -z "$prefix" ]; then
    echo "[zinteractive] Usage: zi_loadenv <PREFIX>"
    echo "[zinteractive] Loads PREFIX_* vars from $ZI_ENV_FILE and exports without prefix"
    return 1
  fi

  if [ ! -f "$ZI_ENV_FILE" ]; then
    echo "[zinteractive] No .env file found at $ZI_ENV_FILE"
    echo "[zinteractive] Create it with your credentials:"
    echo ""
    echo "  # ~/.config/zinteractive/.env"
    echo "  AWS_STAGING_ACCESS_KEY_ID=AKIA..."
    echo "  AWS_STAGING_SECRET_ACCESS_KEY=..."
    echo "  AWS_PROD_ACCESS_KEY_ID=AKIA..."
    echo "  AWS_PROD_SECRET_ACCESS_KEY=..."
    return 1
  fi

  local found=0
  while IFS='=' read -r key value; do
    # Skip comments and empty lines
    case "$key" in
      "#"*|"") continue ;;
    esac
    # Strip leading/trailing whitespace
    key=$(echo "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sed 's/^"//;s/"$//' | sed "s/^'//;s/'$//")

    case "$key" in
      "${prefix}_"*)
        local export_key="${key#${prefix}_}"
        export "$export_key=$value"
        found=$((found + 1))
        ;;
    esac
  done < "$ZI_ENV_FILE"

  if [ "$found" -eq 0 ]; then
    echo "[zinteractive] No vars with prefix '${prefix}_' found in $ZI_ENV_FILE"
    return 1
  fi
  echo "[zinteractive] Loaded $found vars from ${prefix}_*"
}

zi_tfenv() {
  # Read project .env for ENV= value
  local project_env=".env"
  if [ ! -f "$project_env" ]; then
    echo "[zinteractive] No .env file found in current directory"
    return 1
  fi

  local env_value
  env_value=$(grep -E '^(export )?ENV=' "$project_env" | head -1 | sed 's/^export //' | sed 's/^ENV=//' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sed 's/^"//;s/"$//' | sed "s/^'//;s/'$//")

  if [ -z "$env_value" ]; then
    echo "[zinteractive] No ENV= found in .env"
    return 1
  fi

  case "$env_value" in
    prod|production)
      zi_loadenv "AWS_PROD"
      export AWS_ENV_VALUE="prod"
      ;;
    staging|stage|dev|development)
      zi_loadenv "AWS_STAGING"
      export AWS_ENV_VALUE="staging"
      ;;
    *)
      echo "[zinteractive] Unknown ENV value: $env_value"
      echo "[zinteractive] Expected: prod, production, staging, stage, dev"
      echo "[zinteractive] You can also use: zi_loadenv <PREFIX> to load any prefix"
      return 1
      ;;
  esac
  echo "[zinteractive] Terraform environment ready: $env_value"
}

zi_creds() {
  local key_id secret_key
  key_id="${AWS_ACCESS_KEY_ID:-}"
  secret_key="${AWS_SECRET_ACCESS_KEY:-}"

  if [ -z "$key_id" ] && [ -z "$secret_key" ]; then
    echo "[zinteractive] No AWS credentials found in environment"
    echo "[zinteractive] Run zi_tfenv or zi_loadenv <PREFIX> first"
    return 1
  fi

  local masked_key masked_secret
  if [ -n "$key_id" ]; then
    local suffix_key
    suffix_key=$(printf '%s' "$key_id" | tail -c 4)
    masked_key="****${suffix_key}"
  else
    masked_key="(not set)"
  fi

  if [ -n "$secret_key" ]; then
    local suffix_secret
    suffix_secret=$(printf '%s' "$secret_key" | tail -c 4)
    masked_secret="****${suffix_secret}"
  else
    masked_secret="(not set)"
  fi

  echo ""
  echo "  Environment:       ${AWS_ENV_VALUE:-unknown}"
  echo "  Access Key ID:     $masked_key"
  echo "  Secret Access Key: $masked_secret"
  [ -n "${AWS_DEFAULT_REGION:-}" ] && echo "  Region:            ${AWS_DEFAULT_REGION}"
  echo ""

  local creds_text="AWS_ACCESS_KEY_ID=${key_id}
AWS_SECRET_ACCESS_KEY=${secret_key}"

  if command -v pbcopy >/dev/null 2>&1; then
    printf '%s' "$creds_text" | pbcopy
    echo "  (copied to clipboard)"
  elif command -v xclip >/dev/null 2>&1; then
    printf '%s' "$creds_text" | xclip -selection clipboard
    echo "  (copied to clipboard)"
  fi
  echo ""
}
