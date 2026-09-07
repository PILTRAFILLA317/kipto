# Kipto — Checklist de lanzamiento

06/09/2026 · **No publicable todavía**. Implementación y pruebas automatizadas disponibles;
la firma comercial, configuración externa y validación física siguen pendientes.
No commits, pushes, builds ni publicación realizados.

## Evidencia automatizada

- [x] Drift v11: conservación desde la foundation, fuentes/importación idempotente, Facts/Actions,
  cola IA, cola de archivos y cierre/reapertura del flujo esencial.
- [x] T01/T02/T21: navegación/filtros, texto 2× en 360 px, movimiento reducido, taps repetidos,
  resolver/deshacer, hojas y dispose. También hay capturas sintéticas de pantallas reales.
- [x] T07–T12: fechas parciales/DST, contrato IA, cambios tardíos de propietario/revisión,
  aceptación idempotente, permiso denegado y resultados reales del adaptador Calendar mediante dobles.
- [x] T13/T14: orden de Pendientes, Archivo, búsqueda literal y rutas seguras.
- [x] T16/T20: hashes de archivos, fallo/reintento, exportación portable con faltantes,
  tombstones, recuperación de borrado local tras login y limpieza de salida interrumpida.
- [x] T22: importar → IA falsa → confirmar aviso → reabrir SQLite → resolver → Archivo;
  original conservado y proyección cancelada.
- [x] SQL remoto T17/T18/T19, deletion_guards y tombstone_redaction en transacciones revertidas:
  RLS/FK/Storage, RPC internas cerradas, cuotas/entitlements, gates durante borrado,
  redacción de contenido en las cinco entidades borradas y rechazo de resurrección.
- [x] HTTP real sintético: backup sin Pro denegado; upload/download con hash idéntico;
  otra cuenta no accede; borrado de fuente y de dos cuentas; replay del recibo sin JWT.
  Usuarios, objetos, permisos temporales, tokens y recibos sintéticos limpiados.
- [x] Functions desplegadas y migraciones locales/remotas contrastadas por versión/nombre.
- [x] Swift typecheck de extensión (incluido `-application-extension`) y adaptador Flutter de captura, sin avisos.
- [x] Plists/entitlements, localizaciones es/en y Android XML válidos sintácticamente.

Los tests con gateways falsos no acreditan entrega de notificaciones, Calendar, OAuth, compras o
Share Extension en un dispositivo. La prueba HTTP no acredita los bindings nativos de Flutter.

## Puertas de lanzamiento pendientes

- [ ] Bundle/application IDs comerciales, App Group y Keychain Group registrados por el titular.
- [ ] Firma de Runner y ShareExtension; keystore comercial y configuración Play App Signing.
- [ ] Productos/offerings/keys de RevenueCat, secretos webhook y URLs legales públicas.
- [ ] OAuth Apple/Google en ambas plataformas: proteger UUID, salir y restaurar otra biblioteca.
- [ ] Compra sandbox y restauración verificadas; confirmar precios y textos finales.
- [ ] Resolver e incluir los SDK nativos; revisar manifests de privacidad agregados en archive.
- [ ] Revisar iconos/versión/metadatos y sustituir los IDs de desarrollo antes de distribución.
- [ ] Autorizar y ejecutar las pruebas físicas siguientes; aprobar las capturas para tiendas.

## Recorrido manual mínimo

| Plataforma / riesgo | Pasos y resultado esperado | Estado |
|---|---|---|
| Android cold/warm share | Compartir PDF, imagen, texto y lote desde Archivos/otra app; guardar; repetir intento; volver al origen. Un asunto por archivo, sin duplicados ni grants perdidos. | NO EJECUTADO |
| iOS extensión | App terminada: compartir/guardar; comprobar confirmación y pulsar Volver; abrir Kipto. Interrumpir copia y recuperar draft. Sin App Group debe mostrar indisponibilidad. | NO EJECUTADO |
| Share exprés iOS | Con sesión/consentimiento vigentes, analizar y guardar; forzar timeout; abrir Kipto y revisar/reintentar. No anunciar aviso desde extensión. | NO EJECUTADO |
| Avisos | Confirmar, bloquear dispositivo y recibir; negar permiso, exceder capacidad, cambiar zona/DST, reiniciar, resolver y deshacer. Verificar un único aviso real. | NO EJECUTADO |
| Calendario | iOS: guardar y cancelar. Android: abrir editor sin confundirlo con guardado. Reabrir con advertencia de posible duplicado. | NO EJECUTADO |
| Offline y backup | Guardar original sin red, cerrar/abrir, buscar/ver/exportar. Subir, restaurar en instalación de prueba y comparar bytes; red interrumpida conserva original. | Backend HTTP PASS; móvil NO EJECUTADO |
| Cuenta y privacidad | Cambiar cuenta con detalle/hoja abiertos; la anterior desaparece. Exportar con faltantes; borrar asunto/fuente; borrar cuenta con respuesta perdida y reintentar. | Repositorios/HTTP PASS; móvil NO EJECUTADO |
| Accesibilidad/rendimiento | VoiceOver/TalkBack, pantalla estrecha, teclado, texto 2×, claro/oscuro, movimiento reducido y lista de 50 asuntos. Medir rendimiento en dispositivo autorizado. | Widget parcial PASS; físico NO EJECUTADO |

## Limitaciones conocidas

1. La extensión iOS no programa avisos. Guarda fuente/análisis y remite la confirmación a Kipto;
   es el fallback previsto por el contrato. Hay prueba del handoff de análisis; T15 del contrato,
   que exige un comando Reminder staged y su ID del sistema, NO IMPLEMENTADO/NO EJECUTADO.
2. IA y transferencias se procesan en primer plano; hasta tres intentos automáticos, después reintento
   explícito. No se promete procesamiento ilimitado con app cerrada ni entrega exacta de alarmas Android.
3. PDF: máximo diez páginas de análisis y límites de bytes; cobertura parcial comunicada. No se
   inventan fechas ni se analiza el texto acompañante de una imagen/PDF en esta versión.
4. Android Calendar confirma apertura, no guardado. Recents se oculta mediante API33+; verificar
   comportamiento de versiones/dispositivos anteriores. La caché del sistema y previews requieren prueba física.
5. Las capturas de widgets no acreditan composición/rendimiento nativo ni una compra real.
   Listas, feedback, evidencia y respuesta IA tienen pruebas T21. Añadir/teclado, Ajustes, Pro y
   visor texto/faltante tienen T02 con Inter/2×/360px y claro/oscuro. Persisten pruebas
   de ejecución nativa pendientes. Check, tarjeta compartida e indicador de filtros ya implementados;
   el check de la extensión tiene typecheck, no prueba de UI física. Véase
   [completion-audit.md](completion-audit.md). También falta revisión física.

## Advisors revisados

Reconsulta final tras las 15 migraciones: 9 INFO de RLS sin policies, 2 WARN de funciones
SECURITY DEFINER, 11 WARN de Auth anónimo, 1 WARN de contraseñas y 7 INFO de índices sin uso.
Sin categorías nuevas ni aviso de FK sin índice en esta consulta.

- Tablas internas con RLS sin policies: acceso backend deliberado; no abrir permisos para silenciar
  [el aviso INFO](https://supabase.com/docs/guides/database/database-linter?lint=0008_rls_enabled_no_policy).
- Auth anónimo: permitido por diseño, restringido por propietario. El acceso al esquema cron desde
  authenticated fue **denegado**; el grant de tabla aislado no demuestra acceso efectivo.
  [Referencia](https://supabase.com/docs/guides/database/database-advisors?queryGroups=lint&lint=0012_auth_allow_anonymous_sign_ins).
- `kipto_billing_status()` y `kipto_account_writable()`: SECURITY DEFINER sin UUID suministrado por
  el cliente, derivados de `auth.uid()`. Ejecución authenticated intencionada para UI/RLS.
  [Referencia](https://supabase.com/docs/guides/database/database-linter?lint=0029_authenticated_security_definer_function_executable).
- Protección de contraseñas filtradas desactivada: revisar antes de habilitar login por contraseña;
  la UI entregada usa anónimo/Apple/Google.
  [Configuración](https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection).
- Se añadieron índices FK para billing_events y source_backups. Índices nuevos sin uso no se eliminan
  por falta de tráfico. [Referencia](https://supabase.com/docs/guides/database/database-linter?lint=0005_unused_index).
