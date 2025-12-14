#!/usr/bin/env zsh
set -euo pipefail

# Script: git_push_ios_updates.sh
# Purpose: Group changed files (focused on iOS-related and Flutter iOS changes)
#          into multiple short commits (5-10) and push to remote branch.
# Usage: ./scripts/git_push_ios_updates.sh [branch] [remote]
# Example: ./scripts/git_push_ios_updates.sh main origin

branch=${1:-main}
remote=${2:-origin}

echo "Preparing to create grouped commits and push to ${remote}/${branch}"

gitRoot=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [[ -z "$gitRoot" ]]; then
  echo "Error: not inside a git repository." >&2
  exit 1
fi

# Get list of changed files (tracked/untracked) from git status
# Format: XY filename (where XY are status codes)
status_output=$(git status --porcelain)
if [[ -z "$status_output" ]]; then
  echo "No changes to commit. Exiting."
  exit 0
fi

commit_if_changes() {
  local pattern="$1"
  local message="$2"
  local matched=false
  local temp_list=()

  echo "\nScanning for files matching pattern: ${pattern}"

  # Parse git status output and collect matching files
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    
    # Extract filename (skip first 3 chars: XY and space)
    local file="${line:3}"
    # Handle renames (A -> B format)
    file="${file##* -> }"
    
    # Check if file matches pattern and exists
    if echo "$file" | grep -Eq "$pattern"; then
      if [[ -e "$file" ]] || git ls-files --error-unmatch "$file" &>/dev/null; then
        temp_list+=("$file")
        echo "  Found: $file"
      fi
    fi
  done <<< "$status_output"

  # Stage and commit matching files
  if [[ ${#temp_list[@]} -gt 0 ]]; then
    for f in "${temp_list[@]}"; do
      git add -- "$f" 2>/dev/null && echo "  Staged: $f" || echo "  Skip: $f (already staged or error)"
    done
    
    # Only commit if there are staged changes
    if git diff --cached --quiet; then
      echo "  No new changes to commit for: $message"
    else
      git commit -m "$message"
      matched=true
      echo "  ✓ Committed: $message"
    fi
  else
    echo "  No matching files for: $message"
  fi
  
  return 0
}

# 1) iOS native / Xcode project files
commit_if_changes '(^ios/|\.xcodeproj$|\.xcworkspace$|Podfile$|Runner-.*\.xcconfig|Info.plist$|GoogleService-Info.plist$)' 'ios: native project files'

# 2) Flutter iOS integration / platform code / firebase options
commit_if_changes '(^lib/.*firebase_options\.dart$|^lib/.*platform|^lib/services|^lib/config|^lib/main\.dart|^lib/bottom_nav_screen\.dart)' 'flutter: iOS integration code'

# 3) FCM and notification handling (likely iOS fixes)
commit_if_changes '(fcm_service\.dart|firebase_messaging|notification)' 'fix: fcm notification handlers'

# 4) Localization / l10n updates
commit_if_changes '(^lib/l10n/|app_.*\.arb$|app_localizations)' 'i18n: localization updates'

# 5) Pubspec and asset changes
commit_if_changes '(^pubspec.yaml$|^assets/|flutter_launcher_icons|image_path)' 'chore: pubspec & assets'

# 6) Docs and readme
commit_if_changes '(^README\.md$|CHANGELOG|docs/)' 'docs: update README'

# 7) Remaining files (catch-all) — keep this as last commit
# Stage anything left that is not yet committed
remaining_files=()
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  
  local file="${line:3}"
  file="${file##* -> }"
  
  # Check if file exists and not yet staged
  if [[ -e "$file" ]] || git ls-files --error-unmatch "$file" &>/dev/null; then
    if ! git diff --cached --name-only | grep -qxF "$file"; then
      remaining_files+=("$file")
      echo "Found remaining: $file"
    fi
  fi
done <<< "$status_output"

if [[ ${#remaining_files[@]} -gt 0 ]]; then
  for f in "${remaining_files[@]}"; do
    git add -- "$f" 2>/dev/null && echo "Staged remaining: $f"
  done
  
  if ! git diff --cached --quiet; then
    git commit -m 'chore: remaining changes'
    echo "✓ Committed remaining changes"
  else
    echo "No remaining files to commit."
  fi
else
  echo "No remaining files to commit."
fi

# Final: show last commits and push
echo "\nReview last 10 commits:" 
git --no-pager log --oneline -n 10

read -q "REPLY?\nProceed to push these commits to ${remote}/${branch}? (y/n): "
if [[ "$REPLY" != "y" && "$REPLY" != "Y" ]]; then
  echo "\nPush aborted by user. You can push manually later: git push ${remote} ${branch}"
  exit 0
fi

echo "\nPushing to ${remote}/${branch}..."
git push "$remote" "$branch"

echo "Push complete."

# End of script
