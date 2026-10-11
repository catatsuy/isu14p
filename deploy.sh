#!/usr/bin/env bash

set -eux

cd "$(dirname "$0")"

echo "start deploy ${USER}"
(
  cd go
  GOOS=linux GOARCH=amd64 go build -o /tmp/isuride_linux
)

for server in "${@:-isu-app}"; do
  ssh -t "$server" "sudo systemctl stop isuride-go.service"
  scp /tmp/isuride_linux "$server:/home/isucon/webapp/go/isuride"
  rsync -vau ./sql/ "$server:/home/isucon/webapp/sql/"
  ssh -t "$server" "sudo systemctl start isuride-go.service"
done

echo "finish deploy ${USER}"
