#!/usr/bin/env bash
# commit_task.sh
# Tự động stage, commit và push một task lên repo shortly-app.
#
# Cách dùng:
#   GITHUB_TOKEN="ghp_..." ./commit_task.sh feature/shop "feat(shop): ..."
#   ./commit_task.sh "ghp_..." feature/shop "feat(shop): ..."
#
# Biến môi trường tùy chọn:
#   REPO_DIR=/path/to/shortly_app   (mặc định: thư mục hiện tại)

set -euo pipefail

REPO_DIR="${REPO_DIR:-$(pwd)}"
cd "$REPO_DIR"

if [[ $# -eq 3 ]]; then
  TOKEN="$1"
  BRANCH="$2"
  MESSAGE="$3"
elif [[ $# -eq 2 ]]; then
  TOKEN="${GITHUB_TOKEN:-}"
  BRANCH="$1"
  MESSAGE="$2"
else
  echo "Usage:"
  echo "  GITHUB_TOKEN=<token> $0 <branch> <commit-message>"
  echo "  $0 <token> <branch> <commit-message>"
  exit 1
fi

if [[ -z "${TOKEN}" ]]; then
  echo "Thiếu GitHub token. Đặt GITHUB_TOKEN hoặc truyền token làm tham số đầu tiên."
  exit 1
fi

if [[ -z "${BRANCH}" || -z "${MESSAGE}" ]]; then
  echo "Thiếu branch hoặc commit message."
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Thư mục hiện tại không phải git repo: $REPO_DIR"
  exit 1
fi

ORIGINAL_URL="$(git remote get-url origin)"
REPO_URL_WITH_TOKEN="https://${TOKEN}@github.com/huyngvan395/shortly-app.git"

restore_remote() {
  git remote set-url origin "${ORIGINAL_URL}" >/dev/null 2>&1 || true
}
trap restore_remote EXIT

# Luôn bắt đầu từ master mới nhất
git checkout master
git pull origin master

# Tạo branch nếu chưa có
if git show-ref --verify --quiet "refs/heads/${BRANCH}"; then
  git checkout "${BRANCH}"
else
  git checkout -b "${BRANCH}"
fi

# Stage tất cả thay đổi
git add -A

# Nếu không có gì để commit thì dừng
if git diff --cached --quiet; then
  echo "Không có thay đổi để commit."
  exit 0
fi

git commit -m "${MESSAGE}"

# Push bằng token tạm thời
git remote set-url origin "${REPO_URL_WITH_TOKEN}"
GIT_TERMINAL_PROMPT=0 git push -u origin "${BRANCH}"

echo "Đã commit và push branch: ${BRANCH}"
echo "Tạo PR tại: https://github.com/huyngvan395/shortly-app/pull/new/${BRANCH}"
