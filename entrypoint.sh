#!/bin/bash
set -e

# ---------------------------------------------------------------------------
# Required environment variables (set by Railway template):
#   RESTHEART_ADMIN_PASSWORD  - plain-text password chosen by the user
#   MONGO_URI                 - full MongoDB connection string
#
# Optional:
#   RESTHEART_ADMIN_USER      - admin username (default: admin)
# ---------------------------------------------------------------------------

if [ -z "$RESTHEART_ADMIN_PASSWORD" ]; then
    echo "ERROR: RESTHEART_ADMIN_PASSWORD is not set." >&2
    exit 1
fi

if [ -z "$MONGO_URI" ]; then
    echo "ERROR: MONGO_URI is not set." >&2
    exit 1
fi

echo "Hashing admin password and building RHO config..."
RHO=$(python3 - <<'PYEOF'
import json
import os
import sys

import bcrypt

password = os.environ["RESTHEART_ADMIN_PASSWORD"].encode()
# jBCrypt (used by RESTHeart) does not accept $2b$ salt revision,
# only $2a$. Force prefix=b"2a" so the produced hash is verifiable.
bcrypt_hash = bcrypt.hashpw(
    password, bcrypt.gensalt(rounds=12, prefix=b"2a")
).decode()

mongo_uri = os.environ["MONGO_URI"]
admin_user = os.environ.get("RESTHEART_ADMIN_USER") or "admin"

# mongoRealmAuthenticator expects create-user-document as a quoted JSON
# string (it parses the string itself), not as an inline object literal.
user_doc = json.dumps({
    "_id": admin_user,
    "password": bcrypt_hash,
    "roles": ["admin"],
})

sys.stdout.write(
    f"/mclient/connection-string->{json.dumps(mongo_uri)};"
    f'/http-listener/host->"0.0.0.0";'
    f"/mongoRealmAuthenticator/create-user->true;"
    f"/mongoRealmAuthenticator/create-user-document->{json.dumps(user_doc)};"
)
PYEOF
)

if [ -z "$RHO" ]; then
    echo "ERROR: failed to build RHO config." >&2
    exit 1
fi
export RHO

echo "Starting RESTHeart..."
exec ./restheart
