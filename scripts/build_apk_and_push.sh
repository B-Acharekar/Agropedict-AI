#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/B-Acharekar/Agropedict-AI.git}"
BRANCH="${BRANCH:-main}"
APK_DIR="apk"
APK_NAME="AgroPredict-AI-debug.apk"
FLUTTER_APK="build/app/outputs/flutter-apk/app-debug.apk"
GRADLE_APK="build/app/outputs/apk/debug/app-debug.apk"

echo "==> Preparing Flutter dependencies"
flutter pub get

echo "==> Cleaning and building debug APK with Gradle"
(
  cd android
  ./gradlew clean assembleDebug
)

echo "==> Copying APK into ${APK_DIR}/"
mkdir -p "${APK_DIR}"

if [[ -f "${FLUTTER_APK}" ]]; then
  cp "${FLUTTER_APK}" "${APK_DIR}/${APK_NAME}"
elif [[ -f "${GRADLE_APK}" ]]; then
  cp "${GRADLE_APK}" "${APK_DIR}/${APK_NAME}"
else
  echo "Could not find generated debug APK." >&2
  echo "Checked: ${FLUTTER_APK}" >&2
  echo "Checked: ${GRADLE_APK}" >&2
  exit 1
fi

echo "==> Initializing Git repository if needed"
if [[ ! -d .git ]]; then
  git init
fi

git branch -M "${BRANCH}"

if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "${REPO_URL}"
else
  git remote add origin "${REPO_URL}"
fi

echo "==> Staging README, source code, and APK"
git add .

if git diff --cached --quiet; then
  echo "No changes to commit."
else
  git commit -m "Prepare SIH submission with APK"
fi

echo "==> Pushing to GitHub"
git push -u origin "${BRANCH}"

echo "Done. APK copied to ${APK_DIR}/${APK_NAME} and pushed to ${REPO_URL}"
