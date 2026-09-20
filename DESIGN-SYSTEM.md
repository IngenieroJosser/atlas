# ATLAS Design System v12

## Dirección visual

ATLAS adopta una dirección editorial mobile-first: jerarquía tipográfica fuerte, secciones numeradas, microcopy corto, superficies sobrias y una única pieza visual protagonista por pantalla cuando corresponde.

La referencia conceptual proviene de la disciplina de composición de VORON, no de su contenido ni de su estructura de marketplace.

## Tipografía

- **Manrope**: títulos, headings, cifras importantes y mensajes de producto.
- **Geist**: navegación, labels, metadata, inputs y texto normal.
- **SF Mono / system monospaced**: IDs, fechas, telemetría y estados técnicos.

Las fuentes se registran con `AtlasFontRegistry` desde `ATLAS/Resources/Fonts`.
Si las fuentes no están disponibles, la aplicación usa un fallback nativo y sigue compilando.

## Paleta

- Canvas: `#F4F6F8`
- Navy: `#0A1D33`
- Cobalt: `#2D63FF`
- Ink: `#0A1420`
- Surface: `#FFFFFF`
- Muted: `#788695`

Estados:
- Healthy: `#238B5B`
- Attention: `#C48A1D`
- Warning: `#D66B16`
- Critical: `#C83C4B`

## Reglas

- No usar cards para cada bloque.
- Preferir divisores, ritmo, jerarquía y alineación.
- Un único hero visual fuerte en pantallas importantes.
- Radius 11–20 según jerarquía; pills solo para estados/filtros.
- Sombras prácticamente inexistentes.
- SF Symbols como iconografía base.
- Acciones primarias cobalt; AI insights en navy.
