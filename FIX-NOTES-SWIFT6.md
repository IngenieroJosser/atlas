# ATLAS v11.1 — Swift 6 Vision concurrency fix

Se corrigió `Core/VisionAnalyzer.swift` para compatibilidad con concurrencia estricta de Swift 6 / Xcode 27.

Cambios:

- `@preconcurrency import Vision` para interoperar con tipos de Vision que aún no exponen anotaciones completas de `Sendable`.
- `AtlasVisionResult` ahora conforma a `Sendable`.
- `VNRecognizeTextRequest` y `VNImageRequestHandler` se crean dentro de la closure ejecutada en la cola background, evitando capturar instancias no `Sendable` en una closure `@Sendable`.
- No se utilizó `@unchecked Sendable` ni se desactivó Strict Concurrency.

Validación disponible en este entorno:

```bash
swiftc -parse $(find ATLAS -name '*.swift')
```

Resultado: PASS.

La validación final de tipos contra Vision/UIKit debe realizarse en Xcode 27 sobre macOS/iOS SDK.
