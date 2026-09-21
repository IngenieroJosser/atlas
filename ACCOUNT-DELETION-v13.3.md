# ATLAS iOS v13.3 — Eliminación de cuenta

La eliminación de cuenta está disponible en:

`Tú → Security → Zona de riesgo → Eliminar cuenta`

El flujo exige escribir `ELIMINAR` antes de habilitar la acción destructiva. La app llama a `DELETE /api/v1/account` con la confirmación requerida por la API, limpia los tokens del Keychain, elimina la cola offline local, rota el identificador de instalación y vuelve al estado de sesión cerrada.

En organizaciones compartidas, el backend conserva los registros colaborativos sin atribución personal cuando aplica. Si el usuario es el único miembro de una organización propia, esa organización y sus datos se eliminan.
