# ATLAS — Backend integration

## Production API

ATLAS v13.2 points by default to the Render deployment:

`https://atlas-api-fomq.onrender.com/api/v1`

The API host is:

`https://atlas-api-fomq.onrender.com`

The base URL can still be changed from **Tú → Settings → Backend** for development or staging.

## Local development

Start FastAPI on the Mac with:

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Simulator URL:

`http://127.0.0.1:8000/api/v1`

Physical iPhone: use the Mac LAN IP, for example:

`http://192.168.1.25:8000/api/v1`

The Debug Xcode configuration keeps the HTTP development exception. Release uses the HTTPS production API.

## URL persistence

v13.2 uses a new UserDefaults key (`atlas.api.baseURL.v2`) so devices that previously stored the localhost endpoint do not keep using it after upgrading. The default therefore becomes the Render production endpoint automatically.
