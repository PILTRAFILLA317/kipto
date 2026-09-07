# Kipto — Auditoría de cierre por requisitos

06/09/2026. El objetivo completo sigue **NO ACREDITADO**. Esta auditoría contrasta requisitos
con fuentes actuales; no sustituye el contrato por las funcionalidades ya escritas.
Los PASS automatizados conservan el alcance indicado en implementation-status.md.

## Requisitos revisados en esta continuación

| Requisito | Evidencia actual | Resultado / siguiente prueba |
|---|---|---|
| F13.5: selección accesible de filtros | Archivo usa TabBar con indicador de píldora, selección y navegación accesibles; T01 consulta el árbol semántico tras cambiar destinos | PASS. La selección y el filtro se conservan al abrir/cerrar Añadir y cambiar de destino |
| Sección4: indicador deslizante | KiptoBottomDock usa AnimatedAlign y selección semántica; duración cero con disableAnimations | Implementado; navegación y preview verificados sin binario nativo |
| F13.4: limitar blurs | FactCard dejó de aplicar BackdropFilter/sombra a cada hecho | Corregido en el componente repetido; rendimiento físico no medido |
| T15: comando Reminder desde extensión | life_admin_flow_test prueba análisis inicial/replay, no Reminder staged ni allocator compartido | NO IMPLEMENTADO/NO EJECUTADO. Renombrada la prueba del fallback para evitar atribuirle T15 |
| F09: fallback honesto | Captura/análisis durables; no se anuncia aviso desde extensión | Fallback permitido por el contrato; capacidad de aviso desde extensión pendiente de coordinación y prueba autorizada |
| F13.2: entrada, contracción y reordenación | InboxScreen/ArchiveScreen usan KiptoAnimatedSliverList sobre snapshots ordenados; animación inicial limitada a cinco filas, salidas sin foco/interacción/Hero activo | IMPLEMENTADO. T21 verifica cambios rápidos, resolve/undo desde repositorio, navegación Hero durante salida, aislamiento inmediato de cuenta, carga perezosa de 50 filas y scroll conservado; ambos modos de movimiento |
| F13.2: confirmación tras éxito real | ActionReviewSheet muestra Confirmando durante la operación; ActionFeedback reserva el trazo de check para scheduled/kept/calendarSaved | IMPLEMENTADO. T21 ejecuta servicio/repositorio con adaptador Calendar pausado: no hay resultado antes de responder; guardado/apertura/denegación/cancelación distintos, ambos modos de movimiento |
| Sección4: expansión de evidencia | FactCard usa ExpansionTile con cita y página, estado por hecho y scroll de cita separado; advertencia de revisar original siempre visible | IMPLEMENTADO. T21 verifica texto 2×/360px, desplegar/plegar/reabrir y dispose en ambos modos |
| F13.1/5/6: pantallas principales | T02/T21 cubren shell, listas, detalle/controles, revisión, evidencia, Añadir con teclado, Ajustes, Pro y visor de texto/faltante; cinco capturas de widgets | PASS en los escenarios automatizados. PDF/imagen nativos, lector de pantalla y evaluación física pendientes |
| Sección4: transición de respuesta IA | AnalysisPanel revalida el contrato tipado; incoming fade sin retener el resultado anterior; estado/error fuera de la animación | PASS con análisis parcial, cuota, JSON/campos corruptos, revisión obsoleta y cambio de cuenta, normal/reducido |
| F13.7: carga con movimiento reducido | KiptoProgress sustituye los loops por texto accesible en Pro, Añadir, exportación, borrado, visor y búsqueda; IA conserva estado visible | PASS: Pro con Future deliberadamente pendiente no deja tickers. No se representa un porcentaje ficticio |
| F14: plataforma y comercio | Sin build/ejecución autorizados, IDs/grupos/productos/URLs no confirmados | BLOQUEADO para esas pruebas externas; cierre de los huecos visuales documentado al final |

## Alcance que sigue pendiente

1. Verificar las integraciones nativas y el lector de pantalla con configuración/ejecución autorizadas.
   Las pruebas de widgets no ejecutan PDFium, selectores, Calendar, notificaciones ni compras.
2. Validar en dispositivo la transición de tarjeta completa y los visores PDF/imagen. Hero,
   TabBar y la navegación/paginación de Flutter/pdfrx conservan el control del movimiento en su capa.
   Las comprobaciones de widgets no miden fluidez ni acreditan el renderer nativo de PDF.
3. La extensión muestra un check tras publicar el manifest y ofrece Volver inmediatamente, sin
   temporizador. Su interacción, anuncio accesible y lectura de la preferencia compartida requieren
   prueba física. Continúa sin programar Reminder: T15 no se ha implementado ni ejecutado.
4. F14 permanece sin acreditar hasta resolver identidad comercial, firma, productos/URLs y pruebas
   de lanzamiento. No llamar a update_goal(complete) por la suite verde.

Los bloqueos comerciales se mantienen en manual-setup.md y release-checklist.md.
No se ha solicitado otra vez la decisión que ya está pendiente ni ejecutado builds, commits o publicaciones.

Verificación de esta continuación: 7 tests PASS (preview opt-in, T01/T02, T21 en ambos modos,
flujo integrado y fallback iOS); flutter analyze sin incidencias y git diff --check PASS.
La suite completa anterior de 51 PASS no se repitió para este cambio de presentación.

Continuación de feedback/evidencia: **10 tests focalizados PASS**, incluidos 4 nuevos casos T21
con servicio/repositorio reales y gateways falsos. El servicio de avisos conserva T11; el resultado
de Calendar se verifica desde la hoja hasta el mensaje del panel. El guard abarca también el diálogo
de reapertura/cancelación: dos callbacks rápidos no abren dos diálogos y cancelar libera el control.
Se corrigió una colisión real de PageStorage entre el booleano de expansión y el offset de SelectableText.
No se han probado los adaptadores físicos; la suite completa se repetirá al cerrar el catálogo pendiente.

Continuación de listas: **suite completa 59 PASS, 1 SKIP opt-in**; preview ejecutado por separado PASS.
El análisis estático pasa y el formato de 148 archivos no introduce cambios. T21 añade cuatro casos
de listas (snapshots y pantalla Inbox con repositorio, normal/reducido). La variante ampliada cubre
también resolver el último asunto y deshacer desde el estado vacío. No se ha medido rendimiento nativo.

## Continuación de respuesta IA y pantallas restantes

**63 Flutter PASS, 1 SKIP opt-in**; preview separado PASS. `flutter analyze` sin incidencias;
formato de **149 archivos, 0 cambios**; `git diff --check` PASS. Sin cambios Supabase en esta continuación.

- `remaining_ui_test.dart`: cuatro casos T02/T21 con Inter real, 360px y texto 2×.
  La entrada de texto conserva Guardar accesible con inset de teclado de 300px. Ajustes cambia
  la preferencia de tema; Pro recorre mensual/anual con precios sintéticos largos y compra
  deshabilitada sin URLs; visor muestra texto largo y estado de original faltante.
- IA: queued/running → done parcial, cuota, JSON roto, warning de tipo incorrecto, revisión y
  propietario distintos. El resultado anterior desaparece sin esperar al fade y no se anuncia
  Ready para datos inválidos. La UI verifica estructura, no vuelve a cotejar citas con bytes originales.
- Se detectó y eliminó una excepción real de RenderAnimatedSize al cambiar tamaño con duración
  cero. La respuesta utiliza un único AnimatedSwitcher; movimiento reducido muestra el contenido directamente.
- Capturas reales de widgets añadidas e inspeccionadas: `design/screens/ajustes.png` y
  `design/screens/pro.png`; las otras tres se regeneraron. La captura Pro refleja compras no disponibles.
- La suite imprime el aviso de Drift por dos bases en el escenario de sync de bibliotecas;
  no hubo fallos. No se ha silenciado el aviso ni modificado ese escenario por este cambio visual.

## Contraste de la checklist final (sección 15)

Esta matriz resume evidencia acumulada, no una certificación nativa ni una auditoría exhaustiva
nueva del backend. Los resultados remotos y versiones concretas están en implementation-status.md.

| Grupo contractual | Evidencia disponible | Límite pendiente |
|---|---|---|
| Dos destinos y captura explícita; conservar fuente antes de IA/red | T01, T03/T04 y T22; originales y manifests durables | Selectores y cold/warm share físicos |
| Guardado/por analizar/por confirmar/programado; no resolver al crear aviso | T10–T13, ActionFeedback y T22 | Entrega real del aviso |
| Guardar sin fecha; offline, búsqueda y documento local | T12/T14/T16/T20; visor texto y faltante | Visor PDF/imagen y restauración móvil |
| Hechos frente a propuestas; evidencia y ausencia de fechas inventadas | Fixtures T07–T09 y FactCard; revisión siempre explícita | Calidad de extracción sobre más documentos no acreditada |
| Fecha parcial/hora/zona/DST; PDF parcial | T07/T09 y nuevo panel IA | Adaptadores temporales en dispositivo |
| Reanálisis no pisa correcciones ni avisos; errores visibles | T10 y nuevo T02/T21 de panel | Red/foreground nativos |
| Avisos idempotentes y Calendar con outcomes distintos | T11/T12 y pruebas de hoja con gateway diferido | Permisos, capacidades y Calendar físicos |
| Aislamiento de cuentas, originales y jobs | T08/T10/T14/T16/T17/T20; cambio de cuenta en listas/panel | OAuth y navegación con sistema operativo |
| Apariencia y movimiento | Cinco capturas; T01/T02/T21, 50 filas y scroll conservado | Adaptaciones del catálogo arriba, contraste/lector/rendimiento físicos |
| Migraciones/RLS/FK/Storage y decisiones backend | SQL con rollback, HTTP sintético y migraciones/functions contrastadas | Configuración comercial y validación final de plataforma |
| Cuota/entitlement, webhook, retención IA y privacidad | T09/T10/T18/T19, Deno y privacy-data-inventory.md | Compra/restauración sandbox; revisión de manifests agregados |
| Backup privado, Pro caducado, exportar y borrar | T16/T18/T20, HTTP y tombstone_redaction | Recorrido móvil y firma/configuración del titular |

El objetivo completo continúa **NO ACREDITADO**; los huecos visuales explícitos y las pruebas físicas
no se convierten en PASS por haber cerrado las pruebas de IA y de las pantallas restantes.
El cierre del catálogo que sigue sustituye los huecos de implementación visual registrados antes.

## Cierre de confirmaciones, tarjeta compartida y filtros

06/09/2026. Nueva **suite completa 63 PASS, 1 SKIP opt-in**; preview opt-in PASS y capturas
Archivo/detalle regeneradas e inspeccionadas. Analyze sin incidencias; formato 149 archivos sin
cambios; diff check PASS. No hubo consumo IA, cambios Supabase, commits, builds ni ejecución móvil.

- `KiptoSuccessMark` dibuja el trazo con un tween finito después del outcome real. Se reutiliza
  en acciones confirmadas, resolver y confirmación del share Android. En reducido aparece completo.
  T21 conserva la distinción saved/launched/permissionDenied/cancelled y las pruebas de resolver/deshacer.
- `LifeAdminCard` comparte ahora el contenedor completo con ItemDetailScreen. Se retiró MatterTitle
  como Hero independiente para evitar anidarlos. El detalle reutiliza la tarjeta y comprueba el owner
  del snapshot antes de mostrarlo. T21 navega al detalle real con 360px/texto 2×, durante cambios de lista.
- Archivo usa TabBar/DefaultTabController con indicador de píldora deslizante, scroll horizontal para
  texto grande y duración cero en modo reducido. Filtrar cambia el estado inmediatamente; háptico
  opcional solo si cambia la elección. T01 verifica selección accesible y conservación entre destinos.
- iOS: después de `publish` atómico se muestra «Guardado para revisar en Kipto. No se ha programado
  ningún aviso». Volver está disponible sin esperar a la animación. La confirmación retira nombres y
  resumen de la vista; no hay doble publish ni doble cierre. Cancelar análisis para guardar no inyecta
  posteriormente un error en la confirmación.
- El check iOS respeta la preferencia del sistema y la local, compartida mediante un booleano
  coordinado/atómico en App Group. Ante ausencia o error se muestra estático. No se comparte contenido
  ni credenciales con esa preferencia.
- **Typecheck PASS sin avisos**: cinco fuentes Swift de la extensión con `-application-extension`,
  SDK iPhoneSimulator26.2, target arm64/iOS15 y Swift5. También pasan ShareStore/ShareSession y
  SharedCaptureAdapter contra el Flutter.framework instalado. El manifest nativo solo es Encodable;
  el callback de copia recibe un nombre String, no captura NSItemProvider no Sendable.
- Localizaciones es/en de la extensión pasan `plutil -lint`. Typecheck no acredita firma, enlace,
  provisioning, instalación, renderer ni funcionamiento en una extensión alojada por otra app.

FASE13 queda en **verificación manual pendiente**. Las diferencias de implementación identificadas
para check, tarjeta compartida e indicador de filtros están resueltas. FASE14 y el objetivo global
continúan **NO ACREDITADOS** por configuración comercial y pruebas nativas pendientes.
