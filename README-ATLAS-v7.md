# ATLAS v7 — Producto completo en español

Esta entrega convierte el prototipo en una experiencia navegable de producto.

## Identidad tipográfica

ATLAS utiliza exclusivamente tipografías nativas del sistema de Apple mediante SwiftUI:

- `AtlasType.display`: diseño `.serif` para titulares editoriales y mensajes de alto impacto.
- `AtlasType.ui`: diseño `.default` para interfaz y contenido.
- `AtlasType.rounded`: números y métricas.
- `AtlasType.mono`: telemetría, estados, índices y metadata.

No requiere archivos `.ttf` ni `.otf`.

## Pantallas montadas

1. Mundo / Home
2. Activos
3. Cambios
4. Perfil
5. Flujo de escaneo: selección → captura → procesamiento → resultado
6. Búsqueda global
7. Notificaciones
8. Alertas
9. Informes
10. Detalle de informe
11. Detalle de activo
12. Gemelo digital
13. Inspecciones
14. Detalle de inspección
15. Preguntar a ATLAS
16. Comparar estados
17. Configuración
18. Cuenta
19. Privacidad
20. Ayuda
21. Acerca de ATLAS
22. Onboarding
23. Inicio de sesión
24. Crear cuenta
25. Mapa de pantallas

## Navegación

- El dock inferior contiene Mundo, Activos, Escanear, Cambios y Tú.
- El botón central abre el flujo completo de escaneo.
- En `Tú` → `Mapa de pantallas` puedes entrar directamente a todas las vistas secundarias.

## Validación realizada

Todos los archivos `.swift` fueron validados con:

```bash
swiftc -parse ATLAS/*.swift
```

El entorno de generación no dispone del SDK de iOS/Xcode, por lo que la compilación final debe verificarse en Xcode.
