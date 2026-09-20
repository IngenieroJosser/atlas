# ATLAS v9.1 — Camera ObservableObject Fix

Corrección aplicada en `ATLAS/Components/AtlasCamera.swift`:

```swift
import AVFoundation
import Combine
import SwiftUI
import UIKit
```

`AtlasCameraController` usa `ObservableObject` y `@Published`, por lo que `Combine` se importa explícitamente para que `@StateObject` pueda validar la conformidad en Xcode.

## Validación disponible en este entorno

```bash
swiftc -parse $(find ATLAS -name '*.swift')
```

Resultado: OK.

La compilación final contra el SDK de iOS debe ejecutarse en Xcode/macOS.
