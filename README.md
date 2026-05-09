# Deploy and Host RESTHeart with Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/TODO?utm_medium=integration&utm_source=button&utm_campaign=restheart)

RESTHeart is a backend framework for MongoDB that instantly exposes REST, GraphQL, and WebSocket APIs on your database — with built-in authentication and authorization. No code required for standard CRUD operations.

## About Hosting RESTHeart

Hosting RESTHeart involves running two services: the RESTHeart API server and a MongoDB database. RESTHeart connects to MongoDB at startup and immediately exposes your collections as HTTP endpoints. The two services communicate over Railway's private network, keeping MongoDB inaccessible from the public internet. RESTHeart handles all authentication, authorization, and API logic, so you can focus on building your application rather than managing backend infrastructure.

## Common Use Cases

- **REST APIs on MongoDB** — expose any MongoDB collection as a fully queryable REST endpoint in seconds
- **Backend for mobile and web apps** — use RESTHeart as a BaaS without writing server-side code
- **GraphQL on MongoDB** — define a GraphQL schema and let RESTHeart resolve queries against your database
- **Real-time apps** — subscribe to MongoDB change streams via WebSocket
- **Microservices** — extend RESTHeart with custom plugins in Java, Kotlin, JavaScript, or TypeScript

## Dependencies for RESTHeart Hosting

### Deployment Dependencies

- [RESTHeart documentation](https://restheart.org/docs)
- [MongoDB documentation](https://www.mongodb.com/docs)
- [RESTHeart Docker Hub](https://hub.docker.com/r/softinstigate/restheart)
- [RESTHeart on GitHub](https://github.com/SoftInstigate/restheart)

### Implementation Details

This template deploys two services connected over Railway's private network:

**RESTHeart** — built from a custom Dockerfile that:
1. Installs `bcrypt` to hash the admin password at container startup
2. Reads `RESTHEART_ADMIN_PASSWORD` and `MONGO_URI` from environment variables
3. Builds the `RHO` configuration override and starts the RESTHeart process

**MongoDB** — deployed from the official `mongo:8.0` image with a persistent volume attached so data survives redeployments.

After deploy, verify RESTHeart is running:

```bash
curl https://<your-railway-domain>/ping
# → Greetings from RESTHeart!
```

Create a collection and insert a document:

```bash
# Create a collection
curl -u admin:<your-password> -X PUT https://<your-railway-domain>/mydb/mycollection

# Insert a document
curl -u admin:<your-password> -X POST https://<your-railway-domain>/mydb/mycollection \
  -H "Content-Type: application/json" \
  -d '{"name": "hello", "from": "RESTHeart on Railway"}'

# Query documents
curl -u admin:<your-password> https://<your-railway-domain>/mydb/mycollection
```

### Why Deploy RESTHeart on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying RESTHeart on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.

---

## Configuration

RESTHeart is configured entirely through the `RHO` environment variable, which accepts semicolon-separated XPath expressions. The template sets it automatically at startup — you do not need to edit it manually.

To customize RESTHeart further (e.g. change mount points, disable features, add roles), refer to the [RESTHeart configuration guide](https://restheart.org/docs/configuration).

## Custom domain

After deploy, you can point your own domain to RESTHeart from the Railway dashboard:

1. Open the RESTHeart service → **Settings → Networking → Custom Domain**
2. Enter your domain (e.g. `api.example.com`)
3. Add the CNAME record Railway provides to your DNS
4. Railway provisions a TLS certificate automatically

No changes to the RESTHeart configuration are needed.

## Changing the admin password

If you know the current password, change it through the standard RESTHeart user management API — see [User Management](https://restheart.org/docs/security/user-management) for the exact request.

After changing it, update `RESTHEART_ADMIN_PASSWORD` in the RESTHeart service settings so the two stay in sync. The env var is only consulted on a recovery (see below), but keeping it aligned avoids surprises later.

## Recovering a lost admin password

The `RESTHEART_ADMIN_PASSWORD` variable is read **only on first startup**, when the `users` collection is empty. If you no longer have the current password, you need to delete the admin document directly in MongoDB so RESTHeart re-creates it from the env var on the next start:

1. Open the **MongoDB** service in your Railway project and connect to it (via the Railway dashboard's data view, the `railway connect` CLI, or MongoDB Compass with the public proxy).
2. Drop the existing admin document:
   ```js
   use restheart
   db.users.deleteOne({ _id: "admin" })
   ```
3. In the **RESTHeart** service, set `RESTHEART_ADMIN_PASSWORD` to the new password you want.
4. Redeploy the RESTHeart service. On startup it will detect the missing admin and re-create it from the env var.

If your admin username is not `admin`, replace it with the value of `RESTHEART_ADMIN_USER`. Other users you've created via the API are preserved — only the single admin document is removed.

## Upgrading to RESTHeart Cloud

Running RESTHeart on Railway gives you full control but also full responsibility: backups, monitoring, upgrades, and scaling are yours to manage.

**[RESTHeart Cloud](https://restheart.com)** offers the same RESTHeart stack as a fully managed service — no infrastructure to maintain, SLA included, with a dashboard for user and permission management.

When you're ready to hand off operations, RESTHeart Cloud is the natural next step.
