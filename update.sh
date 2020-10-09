#!/bin/bash
set -eo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

./versions.sh "$@"
./apply-templates.sh "$@"
