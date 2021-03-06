#!/usr/bin/env bash
# This script sets up the CockroachDB databases for the politeiad cache and
# assigns user privileges.
# This script requires that you have already created CockroachDB certificates
# using the cockroachcerts.sh script and that you have a CockroachDB instance
# listening on the default port localhost:26257.

set -ex

# COCKROACHDB_DIR must be the same directory that was used with the
# cockroachcerts.sh script.
COCKROACHDB_DIR=$1
if [ "${COCKROACHDB_DIR}" == "" ]; then
  COCKROACHDB_DIR="${HOME}/.cockroachdb"
fi

# ROOT_CERTS_DIR must contain client.root.crt, client.root.key, and ca.crt.
readonly ROOT_CERTS_DIR="${COCKROACHDB_DIR}/certs/clients/root"

if [ ! -f "${ROOT_CERTS_DIR}/client.root.crt" ]; then
  >&2 echo "error: file not found ${ROOT_CERTS_DIR}/client.root.crt"
  exit
elif [ ! -f "${ROOT_CERTS_DIR}/client.root.key" ]; then
  >&2 echo "error: file not found ${ROOT_CERTS_DIR}/client.root.key"
  exit
elif [ ! -f "${ROOT_CERTS_DIR}/ca.crt" ]; then
  >&2 echo "error: file not found ${ROOT_CERTS_DIR}/ca.crt"
  exit
fi

# Database names.
readonly DB_MAINNET="records_mainnet"
readonly DB_TESTNET="records_testnet3"

# Database usernames.
readonly USER_POLITEIAD="politeiad"
readonly USER_POLITEIAWWW="politeiawww"

# Create the mainnet and testnet databases for the politeiad records cache.
cockroach sql \
  --certs-dir="${ROOT_CERTS_DIR}" \
  --execute "CREATE DATABASE IF NOT EXISTS ${DB_MAINNET}"

cockroach sql \
  --certs-dir="${ROOT_CERTS_DIR}" \
  --execute "CREATE DATABASE IF NOT EXISTS ${DB_TESTNET}"

# Create the politeiad user and assign privileges.
cockroach sql \
  --certs-dir="${ROOT_CERTS_DIR}" \
  --execute "CREATE USER IF NOT EXISTS ${USER_POLITEIAD}"

cockroach sql \
  --certs-dir="${ROOT_CERTS_DIR}" \
  --execute "GRANT CREATE, SELECT, DROP, INSERT, DELETE, UPDATE \
  ON DATABASE ${DB_MAINNET} TO  ${USER_POLITEIAD}"

cockroach sql \
  --certs-dir="${ROOT_CERTS_DIR}" \
  --execute "GRANT CREATE, SELECT, DROP, INSERT, DELETE, UPDATE \
  ON DATABASE ${DB_TESTNET} TO  ${USER_POLITEIAD}"

# Create politeiawww user and assign privileges.
cockroach sql \
  --certs-dir="${ROOT_CERTS_DIR}" \
  --execute "CREATE USER IF NOT EXISTS ${USER_POLITEIAWWW}"

cockroach sql \
  --certs-dir="${ROOT_CERTS_DIR}" \
  --execute "GRANT SELECT ON DATABASE ${DB_MAINNET} TO  ${USER_POLITEIAWWW}"

cockroach sql \
  --certs-dir="${ROOT_CERTS_DIR}" \
  --execute "GRANT SELECT ON DATABASE ${DB_TESTNET} TO  ${USER_POLITEIAWWW}"

# Disable CockroachDB diagnostic reporting
cockroach sql \
  --certs-dir="${ROOT_CERTS_DIR}" \
  --execute "SET CLUSTER SETTING diagnostics.reporting.enabled=false"

cockroach sql \
  --certs-dir="${ROOT_CERTS_DIR}" \
  --execute "SET CLUSTER SETTING diagnostics.reporting.send_crash_reports=false"
