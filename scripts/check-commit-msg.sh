#!/bin/sh
msg=$(head -1 "$1")
if ! echo "$msg" | grep -qE '^(feat|fix|docs|style|refactor|test|chore|ci|build|perf)(\(.+\))?(!)?: .+'; then
  echo "ERROR: Commit message must follow Conventional Commits format:"
  echo "  <type>(<scope>): <description>"
  echo ""
  echo "  Types: feat, fix, docs, style, refactor, test, chore, ci, build, perf"
  echo "  Example: feat(auth): adiciona tela de login"
  echo ""
  echo "  Your message: $msg"
  exit 1
fi
