# ATLAS v13.2 — Render connection

Default API base URL:

`https://atlas-api-fomq.onrender.com/api/v1`

Changes:

- Production Render URL is now the default in `AtlasConfiguration`.
- A new preferences key prevents the previous localhost value from overriding the production endpoint after upgrade.
- The Settings screen now displays the Render endpoint by default.
- Local development remains configurable from the app.
- Release continues to use HTTPS without a global arbitrary-load ATS exception.
