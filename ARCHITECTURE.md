# ATLAS — Arquitectura UI modular

## Estructura

```text
ATLAS/
├── App/
│   ├── ContentView.swift
│   └── MyApp.swift
├── Core/
│   └── DesignSystem.swift
├── Models/
│   └── AtlasModels.swift
├── Components/
│   ├── AtlasComponents.swift
│   ├── AtlasDock.swift
│   ├── AtlasMark.swift
│   └── AtlasValueRow.swift
├── Screens/
│   ├── World/
│   │   └── WorldScreen.swift
│   ├── Assets/
│   │   ├── AssetScreens.swift
│   │   └── AssetManagementScreens.swift
│   ├── Inspections/
│   │   └── FindingScreens.swift
│   ├── Maintenance/
│   │   └── MaintenanceScreens.swift
│   ├── Changes/
│   │   ├── ChangeScreens.swift
│   │   └── ActivityLogScreen.swift
│   ├── Intelligence/
│   │   ├── IntelligenceScreens.swift
│   │   └── IntelligenceSupportScreens.swift
│   ├── Scan/
│   │   └── ScanScreens.swift
│   ├── Profile/
│   │   ├── ProfileUtilityScreens.swift
│   │   └── WorkspaceScreens.swift
│   └── Auth/
│       ├── AuthScreens.swift
│       └── RecoveryScreens.swift
└── Assets.xcassets/
```

## Responsabilidades

- **App/**: composición raíz, navegación y entry point.
- **Core/**: design system, colores, tipografía, superficies y primitivas visuales.
- **Models/**: rutas, enums, modelos y datos demo.
- **Components/**: componentes reutilizables sin responsabilidad de pantalla.
- **Screens/**: vistas organizadas por dominio/feature.

## Regla de mantenimiento

Una pantalla nueva debe ir dentro de `Screens/<Feature>/`. Si una pieza visual se reutiliza en dos o más pantallas, muévela a `Components/`. Los tipos compartidos deben vivir en `Models/`; los tokens visuales y helpers globales en `Core/`.

## Navegación

`App/ContentView.swift` mantiene el `NavigationStack` y resuelve `AtlasRoute`. Las pantallas reciben closures como `open: (AtlasRoute) -> Void` cuando necesitan navegar, evitando acoplar cada feature directamente al router.

## Xcode

El proyecto usa `PBXFileSystemSynchronizedRootGroup`, por lo que Xcode sincroniza recursivamente las carpetas dentro de `ATLAS/`. No es necesario agregar manualmente cada archivo Swift al target.
