# Kipto — Entrega de las fases 00–14

06/09/2026. Base común: `ed469d9eda54234ce2097015fff37bdb79cc959e`.
Todos los cambios Supabase indicados corresponden a `wrkykxyctseqvfwehdcu`.
Los pasos manuales siguientes están **NO EJECUTADOS** salvo evidencia expresa.
Las fases se continuaron por autorización del usuario; ningún commit sugerido se ha ejecutado.
Las verificaciones globales y sus límites están en [implementation-status.md](implementation-status.md).

## FASE 00 — Auditoría y preparación

**Resultado.** Foundation Item/Reminder e historial conservados; referencia y contrato incorporados.

**Qué puede hacer ahora Kipto.** Consultar la base y decisiones del pivot.

**Qué probar manualmente.**

1. Abrir la foundation
2. entrar en Ajustes
3. cerrar y reabrir sin permiso global de fototeca.

**Verificaciones ejecutadas.** 7 tests de base al inicio; ascendencia Git y análisis comprobados.

**Supabase.** Sin cambios en esta fase.

**Pendiente / bloqueos.** Arranque físico pendiente.

**Commit sugerido.** `docs: establish life admin implementation baseline`

**Siguiente fase.** Fase 01, abordada dentro de la continuación autorizada.

## FASE 01 — Sistema visual y navegación

**Resultado.** Tema claro/oscuro, Inter local, dock, hojas y navegación Pendientes/Archivo.

**Qué puede hacer ahora Kipto.** Navegar entre destinos y conservar filtros; añadir y buscar asuntos.

**Qué probar manualmente.**

1. Cambiar pestaña y volver
2. abrir Añadir
3. probar texto 2× y movimiento reducido.

**Verificaciones ejecutadas.** T01/T02 y preview de widgets PASS.

**Supabase.** Sin cambios.

**Pendiente / bloqueos.** Revisión visual física pendiente.

**Commit sugerido.** `feat(ui): establish Kipto visual system and navigation`

**Siguiente fase.** Fase 02, abordada dentro de la continuación autorizada.

## FASE 02 — Sources e importación explícita

**Resultado.** Sources y originales persistentes con hash, límites, manifest atómico y recuperación idempotente.

**Qué puede hacer ahora Kipto.** Importar imagen, PDF o texto y abrir la fuente guardada sin depender de caché temporal.

**Qué probar manualmente.**

1. Importar PNG y PDF en iOS/Android
2. cerrar y reabrir
3. probar archivo inválido y sin red.

**Verificaciones ejecutadas.** T03/T04, migraciones y recuperación de copia PASS.

**Supabase.** 20260905193607_life_admin_sources.

**Pendiente / bloqueos.** Plugins/HEIC/PDFium y permisos nativos pendientes.

**Commit sugerido.** `feat(capture): persist explicit source imports`

**Siguiente fase.** Fase 03, abordada dentro de la continuación autorizada.

## FASE 03 — Compartir desde Android

**Resultado.** Intents SEND/SEND_MULTIPLE con copia serial y entrega estable al pipeline común.

**Qué puede hacer ahora Kipto.** Guardar archivos o texto compartidos; revisar y volver a la app de origen.

**Qué probar manualmente.**

1. Compartir con app cerrada
2. repetir con app abierta y lote
3. guardar y volver al origen.

**Verificaciones ejecutadas.** T05/T06 de manifest, rutas y doble entrega PASS; XML parse PASS.

**Supabase.** Sin cambios.

**Pendiente / bloqueos.** Activities, grants y retorno físico NO EJECUTADOS.

**Commit sugerido.** `feat(android): receive shared sources safely`

**Siguiente fase.** Fase 04, abordada dentro de la continuación autorizada.

## FASE 04 — Share Extension iOS duradera

**Resultado.** Target embebido, draft/manifest atómico y adaptador de App Group implementados.

**Qué puede hacer ahora Kipto.** Conservar un paquete y recuperarlo al abrir Kipto sin que la extensión abra Drift.

**Qué probar manualmente.**

1. Configurar grupos registrados
2. compartir y cerrar extensión
3. interrumpir copia y abrir Kipto.

**Verificaciones ejecutadas.** T06/importación PASS; Swift parse y plists/entitlements PASS.

**Supabase.** Sin cambios.

**Pendiente / bloqueos.** Typecheck de la extensión y adaptador de captura PASS; firma, capacidades, enlace y ejecución nativa pendientes.

**Commit sugerido.** `feat(ios): add durable share extension intake`

**Siguiente fase.** Fase 05, abordada dentro de la continuación autorizada.

## FASE 05 — Hechos, acciones y fechas

**Resultado.** Facts/Actions tipados, contrato v1, correcciones con evidencia y cálculo temporal explícito.

**Qué puede hacer ahora Kipto.** Distinguir dato detectado/corregido y propuesta; revisar fechas parciales y horas DST.

**Qué probar manualmente.**

1. Abrir una fecha incompleta
2. corregir un hecho
3. revisar hora inexistente y duplicada de Madrid.

**Verificaciones ejecutadas.** T07/T08 y fixtures de contrato PASS.

**Supabase.** 20260905201500_life_admin_facts_actions; 20260905201617_life_admin_reminder_action_index.

**Pendiente / bloqueos.** Lectura de evidencia y accesibilidad física pendientes.

**Commit sugerido.** `feat(domain): model life admin facts and actions`

**Siguiente fase.** Fase 06, abordada dentro de la continuación autorizada.

## FASE 06 — IA real y cola durable

**Resultado.** Cola foreground con request/payload estables, consentimiento, límites y aplicación transaccional.

**Qué puede hacer ahora Kipto.** Analizar fuentes compatibles y reintentar sin duplicar propuestas ni crear avisos automáticamente.

**Qué probar manualmente.**

1. Dar consentimiento explícito
2. analizar una fuente sintética
3. cortar red y reabrir para revisar recuperación.

**Verificaciones ejecutadas.** T09/T10 PASS; llamada real v1 HTTP200, 808/331 tokens, replay idéntico; v2 validada con tests sin nueva llamada pagada.

**Supabase.** 20260905203000_life_admin_analysis_requests; analyze-source ACTIVE v2, JWT true.

**Pendiente / bloqueos.** Red desde Flutter, HEIC/EXIF y reanudación física pendientes; calidad general no acreditada.

**Commit sugerido.** `feat(ai): analyze sources with durable consented jobs`

**Siguiente fase.** Fase 07, abordada dentro de la continuación autorizada.

## FASE 07 — Recordar, Evento y Guardar

**Resultado.** Revisión explícita, aceptación idempotente y estados del sistema separados del estado de negocio.

**Qué puede hacer ahora Kipto.** Confirmar avisos, abrir editor de calendario, guardar sin avisos y resolver/deshacer.

**Qué probar manualmente.**

1. Confirmar y recibir aviso bloqueado
2. guardar/cancelar evento iOS y abrir Android
3. resolver y deshacer.

**Verificaciones ejecutadas.** T11/T12 y scheduler con gateways falsos PASS.

**Supabase.** Sin cambios.

**Pendiente / bloqueos.** Notificaciones, permisos y Calendar físicos NO EJECUTADOS; Android acredita apertura, no guardado.

**Commit sugerido.** `feat(actions): review and apply life admin actions`

**Siguiente fase.** Fase 08, abordada dentro de la continuación autorizada.

## FASE 08 — Pendientes, Archivo, detalle y búsqueda

**Resultado.** Consultas locales ordenadas, filtros estables, detalle y búsqueda literal implementados.

**Qué puede hacer ahora Kipto.** Encontrar asuntos por contenido permitido y consultar fuentes/evidencia o estado de archivo faltante.

**Qué probar manualmente.**

1. Buscar texto literal
2. cambiar filtros y volver
3. abrir detalle con fuente no disponible.

**Verificaciones ejecutadas.** T13/T14 y capturas de widgets PASS.

**Supabase.** Sin cambios.

**Pendiente / bloqueos.** Revisión física y lista de 50 asuntos pendientes.

**Commit sugerido.** `feat(product): complete inbox archive and item experience`

**Siguiente fase.** Fase 09, abordada dentro de la continuación autorizada.

## FASE 09 — Share exprés

**Resultado.** Análisis acotado en extensión con access token vigente en Keychain y handoff durable; Android reutiliza Flutter.

**Qué puede hacer ahora Kipto.** Guardar análisis para revisión en Kipto y recuperar timeout/cierre sin perder la fuente.

**Qué probar manualmente.**

1. Compartir con sesión vigente
2. repetir sin red o token caducado
3. abrir Kipto dos veces y revisar ausencia de duplicados.

**Verificaciones ejecutadas.** Análisis inicial y replay del fallback PASS; Swift typecheck con restricciones de extensión PASS.
T15 del contrato (comando Reminder e ID del sistema staged) NO IMPLEMENTADO/NO EJECUTADO:
la prueba del fallback no demuestra ese requisito.

**Supabase.** Reutiliza analyze-source v2; sin nueva función.

**Pendiente / bloqueos.** Fallback contractual: iOS no programa avisos desde extensión; grupos, sesión y ejecución física pendientes.

**Commit sugerido.** `feat(share): add express analysis with durable handoff`

**Siguiente fase.** Fase 10, abordada dentro de la continuación autorizada.

## FASE 10 — Cuenta, sincronización y backup

**Resultado.** Drift v11, cola de archivos serial/reintentable, aislamiento por cuenta y salida recuperable.

**Qué puede hacer ahora Kipto.** Sincronizar con consentimiento, respaldar originales con Pro y limpiar una biblioteca al salir sin exponerla a otra cuenta.

**Qué probar manualmente.**

1. Cambiar cuenta con hoja abierta
2. interrumpir upload/download
3. restaurar biblioteca y comparar original.

**Verificaciones ejecutadas.** T16/T17, carreras de auth/sync/avisos PASS; HTTP real upload/download/hash y aislamiento de dos cuentas PASS.

**Supabase.** 20260905213307_life_admin_source_backups; source-backup ACTIVE v3; bucket privado kipto-sources.

**Pendiente / bloqueos.** OAuth/restore móvil y almacenamiento nativo pendientes; HTTP se ejecutó en source-backup v2.

**Commit sugerido.** `feat(sync): add private backups and account isolation`

**Siguiente fase.** Fase 11, abordada dentro de la continuación autorizada.

## FASE 11 — RevenueCat y control de acceso

**Resultado.** SDK, paywall mensual/anual, restauración y backend autoritativo con webhook idempotente.

**Qué puede hacer ahora Kipto.** Mostrar precios reales cuando exista configuración; impedir acceso Pro desde un cliente manipulado.

**Qué probar manualmente.**

1. Configurar productos y entitlement kipto_pro
2. comprar/restaurar en sandbox
3. verificar cancelación y expiración.

**Verificaciones ejecutadas.** T18/T19 SQL y webhook Deno PASS; backup sin Pro HTTP403.

**Supabase.** 20260905214347_life_admin_billing_events; revenuecat-webhook ACTIVE v2.

**Pendiente / bloqueos.** BLOQUEADA para prueba comercial: IDs/productos, claves públicas, secretos servidor y URLs legales pendientes; sandbox NO EJECUTADO.

**Commit sugerido.** `feat(billing): integrate RevenueCat and enforce entitlements`

**Siguiente fase.** Fase 12, abordada dentro de la continuación autorizada.

## FASE 12 — Privacidad, exportación y borrado

**Resultado.** Exportación ZIP portable y borrados durables con cancelación de avisos, redacción de contenido y recibo de cuenta.

**Qué puede hacer ahora Kipto.** Exportar originales verificados con faltantes explícitos; borrar fuente/asunto/cuenta y recuperar una respuesta perdida.

**Qué probar manualmente.**

1. Exportar con archivo faltante
2. borrar fuente sin red y reconectar
3. borrar cuenta y reintentar tras perder respuesta.

**Verificaciones ejecutadas.** T20, cleanup/carreras y SQL deletion_guards/tombstone_redaction PASS; HTTP real borrado y replay sin JWT PASS.

**Supabase.** Migraciones deletion_guards, account_deletion, deletion_serialization y tombstone_redaction; delete-account ACTIVE v2.

**Pendiente / bloqueos.** Compartir ZIP, recents y borrado móvil pendientes; HTTP delete-account v1, redacción posterior verificada en SQL.

**Commit sugerido.** `feat(privacy): add portable export and recoverable deletion`

**Siguiente fase.** Fase 13, abordada dentro de la continuación autorizada.

## FASE 13 — Pulido visual y accesibilidad

**Resultado.** Tipografía, hero, continuidad de título, controles del detalle, guards de doble tap y decode de imágenes acotado.
La auditoría posterior corrigió selección semántica de filtros, añadió el indicador deslizante del dock
y retiró blur/sombra de cada FactCard. El cierre posterior añade tarjeta compartida completa, check dibujado e indicador deslizante de filtros;
la fase queda en verificación manual pendiente.

**Qué puede hacer ahora Kipto.** Usar las pantallas con texto ampliado, feedback y preferencia de movimiento reducido.

**Qué probar manualmente.**

1. Recorrer con VoiceOver/TalkBack
2. abrir hoja con teclado y texto 2×
3. medir scroll de 50 asuntos en dispositivo.

**Verificaciones ejecutadas.** T21 real de widgets: taps, resolver/deshacer, hoja/dispose y 360px/2× PASS; capturas sintéticas regeneradas.

**Supabase.** Sin cambios.

**Pendiente / bloqueos.** Inserción/resolución/deshacer de listas, feedback busy → resultado y
expansión de evidencia y respuesta IA implementados con T21 en ambos modos. Añadir/teclado, Ajustes,
Pro y visor texto/faltante pasan T02 en 360px/2× con Inter, claro/oscuro. Check, Hero de tarjeta y
filtros deslizantes cerrados; falta validación de visores nativos.
Lectores de pantalla y rendimiento físico pendientes.
Véase [completion-audit.md](completion-audit.md) para el alcance exacto de la prueba estática y de widgets.

**Commit sugerido.** `style(ui): polish life admin interactions and accessibility`

**Siguiente fase.** Fase 14, abordada dentro de la continuación autorizada.

## FASE 14 — Preparación de lanzamiento

**Resultado.** Documentación, inventario de datos, textos de tienda y pruebas de cierre preparados; firma release debug retirada.

**Qué puede hacer ahora Kipto.** Reproducir las pruebas y preparar configuración/distribución con una checklist explícita.

**Qué probar manualmente.**

1. Completar identidad/firma y URLs
2. ejecutar recorrido físico de la checklist
3. aprobar metadatos/capturas y validar archive cuando se autorice.

**Verificaciones ejecutadas.** 63 tests Flutter PASS, 1 preview opt-in SKIP en suite y PASS separado; 5 Deno PASS; analyze, formato, check/lint y diff PASS.

**Supabase.** 20260905222242_life_admin_release_indexes; 15 migraciones contrastadas por versión/nombre y 4 functions ACTIVE.

**Pendiente / bloqueos.** BLOQUEADA para lanzamiento: configuración comercial, resolución/build nativo autorizado y pruebas físicas. No publicable todavía.

**Commit sugerido.** `chore(release): prepare Kipto life admin release candidate`

**Siguiente fase.** Configuración del titular y recorrido nativo autorizado; no iniciar distribución automáticamente.
