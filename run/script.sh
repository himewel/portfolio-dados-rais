#!/usr/bin/env sh

set -e

TMP_PATH=$(date -Iseconds)
mkdir ./$TMP_PATH

rclone sync "${SYSTEM}:${SOURCE}" "./${TMP_PATH}"
gsutil -m cp -r "./${TMP_PATH}/*" "${DESTINATION}${SOURCE}"
