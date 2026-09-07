# Kipto — Decisiones de arquitectura

06/09/2026. Base conservada: `feat/life-admin-pivot`, `ed469d9eda54234ce2097015fff37bdb79cc959e`.
El usuario autorizó continuar todas las fases del [contrato](KIPTO_LIFE_ADMIN_MASTER_PROMPT.md).
No se rehízo el proyecto ni se repitió la limpieza anterior.

## Estado actual

| Responsabilidad | Implementación y decisión |
|---|---|
| Dominio | Item/Reminder conservados; Source, Fact y ItemAction tipados. Corrección separada de extracción, fecha civil separada de instante y zona. |
| Persistencia | Drift v11 es la fuente de lectura. Transacciones de dominio + sync queue, tablas locales para archivos, IA y mappings de avisos. Migraciones incrementales desde v7. |
| Captura | Selectores oficiales, texto y share explícito; original acotado, hash, recibo y commit antes de IA/red. Sin escaneo global, cámara propia ni Screenshot Inbox legacy. |
| Sync | SyncService existente ampliado: Items → Sources → Facts → Actions → Reminders. Protección frente a ACK viejo/cambio de cuenta y consentimientos, Realtime como invalidación. |
| Ownership | RLS/FK remotos y guards locales. El login no reclama datos locales automáticamente; la reclamación explícita excluye tombstones. Streams/rutas se actualizan al cambiar cuenta. |
| IA | Un proveedor/modelo servidor; contrato versionado validado en backend y Flutter. Cola foreground con request/payload persistidos, cancelación, tres intentos y revisión de usuario. |
| Avisos | Aceptación crea un Reminder, no una promesa de entrega. Mapping antes de OS, reconciliación serial, capacidad 50 y estado contrastado con OS. Cleanup espera solicitudes anteriores. |
| Calendario | Se conserva el adaptador: iOS saved/cancelled; Android launched no equivale a saved. La UI comunica el resultado. |
| iOS share | Target separado, App Group para paquetes, Keychain para access token vigente. Nunca abre/migra Drift principal. Guardar es durable; el fallback de avisos exige revisión en Kipto. |
| Backup | FileJobs serial foreground; server-only upload, reserva de cuota y lease. Cliente/servidor verifican bytes/hash. Descarga temporal no sustituye un original local correcto. |
| Billing | RevenueCat gestiona tienda/receipts; backend consulta entitlement y controla cuota. ID de usuario Supabase, eventos idempotentes/ordenados y separación sandbox/production. |
| Privacidad | Consentimientos por cuenta, ZIP portable, redacción de contenido en tombstones, borrados durables, logout recuperable y receipt de borrado de cuenta. |
| UI | Tema existente ampliado, Inter local, es/en, dos destinos, hojas y detalle. Movimiento estándar, título compartido, reducción de movimiento, listas perezosas y visor con decodificación acotada. |

## Invariantes

1. Importar y analizar nunca crean avisos. Solo una confirmación válida acepta una acción.
2. La corrección del usuario y una acción aceptada no se sobrescriben por reanálisis/ACK antiguo.
3. Reservar cuota o transferir bytes no confirma backup; el servidor debe verificar y completar.
4. Salir de cuenta no elimina datos si Auth falla. Si la limpieza posterior se interrumpe, queda
   marcada para reintento. Una cuenta nueva no recibe contenido, jobs ni consentimientos de la anterior.
5. Borrar conserva solo la información técnica de tombstone necesaria para propagar el borrado;
   el texto, evidencias y payloads se eliminan. Los archivos pendientes de eliminación no se reimportan.
6. Reserva de backup, lease y borrado comparten bloqueo por cuenta. El borrado espera uploads antiguos
   y los endpoints acotan lectura/red; una respuesta tardía no debe recrear el original eliminado.
7. Entitlements y cuotas nunca se toman de flags locales o metadatos editables del usuario.
8. Sin credenciales/capacidades, la UI informa indisponibilidad. No hay compras, IA o backup ficticios.

## Decisiones externas sin inventar

Se conservan IDs de desarrollo y el Apple Team existente. Falta registrar identidades comerciales,
App Group/Keychain, productos RevenueCat y URLs legales. Release Android ya no usa firma debug por defecto.
La extensión no programa avisos porque falta la verificación nativa requerida; el fallback está probado
como handoff de análisis en Flutter. Véanse [setup](manual-setup.md) y [checklist](release-checklist.md).

## Método y límites

Grafo `Users-umartin-Desktop-SprayNPray-kipto`, nivel Verify, cobertura consultada para las rutas usadas;
SQL con parse parcial leído directamente y contrastado con funciones/policies remotas. No se interpreta
«sin huecos registrados» como exhaustividad. Se han usado snippets/fuentes para callbacks Riverpod/nativos.
Tests de repositorios, widgets, Deno, SQL con rol authenticated y una prueba HTTP sintética complementan
esa lectura. No se ha compilado ni ejecutado la app nativa: firma, plugins, accesibilidad física,
rendimiento, recepción de avisos y sandbox de compras permanecen pendientes.
