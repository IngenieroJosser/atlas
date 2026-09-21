# ATLAS v13.1 — Swift 6 concurrency fixes

Correcciones aplicadas sobre ATLAS v13 FullStack Connected para Xcode/Swift 6 con `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`.

## AtlasAPIModels.swift
- Todos los DTO/modelos de red se declararon `nonisolated`.
- Se conserva `Sendable` en modelos que cruzan límites de concurrencia.
- Esto evita que conformidades `Codable`/`Decodable`/`Encodable` se infieran como `@MainActor`.

## AtlasAPIClient.swift
- `AtlasConfiguration`, `AtlasAPIError` y `AtlasKeychain` ahora son `nonisolated`.
- `EmptyBody`, `CreateAssetPayload` y `WorkOrderPayload` ahora son `nonisolated`.
- La extensión helper de `Data` ahora es `nonisolated`.
- `UIDevice.current` se consulta mediante `MainActor.run` desde el actor del cliente API.
- Registro de dispositivo obtiene nombre, versión de iOS y versión de app de forma segura respecto al MainActor.
- `AtlasDateCodec` dejó de compartir `ISO8601DateFormatter` estáticos; crea formateadores locales para evitar estado no-Sendable compartido.

## AtlasAppStore.swift
- Capturas dentro de closures de autenticación usan `self.api` explícitamente.
- `Float` de `Vision` se convierte explícitamente a `Double` antes de enviarlo al backend.

## Validación disponible en este entorno
- `swiftc -parse` sobre todos los archivos Swift: PASS.
- `AtlasAPIModels.swift` type-check con Swift 6.2, Swift language mode 5 y `-default-isolation MainActor`: PASS.

La compilación final contra SwiftUI/UIKit/Security/AVFoundation debe ejecutarse en Xcode en macOS.
