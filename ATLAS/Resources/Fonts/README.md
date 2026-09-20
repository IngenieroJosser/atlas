# Fuentes de ATLAS

ATLAS está preparado para usar estas dos fuentes variables:

- `Manrope-VariableFont_wght.ttf` → títulos, headings y cifras importantes.
- `Geist-VariableFont_wght.ttf` → interfaz, labels, metadata y cuerpo de texto.

Copia tus archivos locales en esta carpeta:

```text
ATLAS/Resources/Fonts/
├── Manrope-VariableFont_wght.ttf
└── Geist-VariableFont_wght.ttf
```

`AtlasFontRegistry` las registra al iniciar la aplicación. Si una fuente no está presente, la app usa una fuente del sistema como fallback y sigue compilando.
