# ATLAS v7.1 — Single Target Fixed

Esta versión está preparada para el proyecto que ya tienes abierto en Xcode.

## Estructura intencional
Solo hay cuatro archivos Swift principales:
- ContentView.swift
- DesignSystem.swift
- AtlasMark.swift
- MyApp.swift

Todas las pantallas, modelos, rutas y componentes que antes estaban separados fueron fusionados dentro de `ContentView.swift`.

Esto evita errores como:
- Cannot find type 'AtlasTab' in scope
- Cannot find type 'AtlasRoute' in scope
- Cannot find 'WorldScreen' in scope

## Reemplazo recomendado
No mezcles esta carpeta con versiones anteriores. Abre directamente `ATLAS.xcodeproj` desde esta carpeta.

Si deseas reemplazar archivos manualmente en tu proyecto actual, reemplaza los cuatro `.swift` por los de esta versión y luego ejecuta Product > Clean Build Folder.
