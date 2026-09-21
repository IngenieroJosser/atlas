# Atlas v13.4 — App Branding

Cambios aplicados en iOS:

- El nombre visible de la aplicación ahora es `Atlas` mediante `CFBundleDisplayName` para Debug y Release.
- El ícono de la aplicación ahora usa el mismo símbolo geométrico definido por `AtlasMark.swift`.
- Se reemplazó el branding visible `ATLAS` por `Atlas` dentro de la interfaz para mantener consistencia de nombre.
- Se mantuvo `com.zyra.ATLAS.api` como identificador interno de Keychain para no invalidar sesiones existentes.
- Se mantuvo el bundle identifier `com.zyra.ATLAS` para no romper firma, provisioning ni instalaciones existentes.

El nuevo AppIcon usa `AtlasColor.navy` (#0A1D33) como fondo y `AtlasColor.blue` (#2D63FF) para el símbolo.
