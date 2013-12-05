#!/bin/bash

BASE_DIR="$(dirname "${0}")"

if [ -z "${BASE_DIR}" ]; then
  echo "**ERROR** BASE_DIR empty" >&2
  exit 1
fi

rm -rf "${BASE_DIR}/java/out"
mkdir -p "${BASE_DIR}/java/out"

javac -d "${BASE_DIR}/java/out/" $(find "${BASE_DIR}/java/src/" -name *\.java)
