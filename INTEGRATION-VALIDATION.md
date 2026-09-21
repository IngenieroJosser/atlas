# Integration validation

Validated in this environment:

- Swift syntax parse of every `.swift` file: PASS
- API decoder uses `convertFromSnakeCase` and encoder uses `convertToSnakeCase`
- Backend pagination contract uses `limit` / `offset`
- Asset search uses backend query parameter `q`
- Compare uses `state_a_id` / `state_b_id`
- Report export treats the endpoint as PDF bytes
- Evidence uses multipart upload
- JWT refresh is limited to one retry per request, including multipart upload
- Keychain is used for access and refresh tokens
- No PostgreSQL URL or user database password is included in the frontend
- Debug local-network usage description configured
- iOS deployment target remains 18.0

Not executable in this container:

- Xcode/iOS SDK type-check and final app build
- Physical-device camera and local-network runtime tests
- Sign in with Apple entitlement/capability validation

Run the final validation in Xcode on macOS with the iOS SDK.
