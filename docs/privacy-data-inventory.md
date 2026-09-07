# Kipto — Inventario de datos y retención

06/09/2026. Documento técnico para redactar la política pública y las declaraciones de tiendas.
No sustituye las URLs legales aprobadas por el titular.

| Datos | Ubicación y finalidad | Retención / salida |
|---|---|---|
| Original seleccionado y recibo de captura | Contenedor persistente de la app; recuperación de importaciones | Hasta borrado confirmado/limpieza de cuenta. Nunca se limpia por un fallo de upload. Excluido del backup automático del sistema mediante configuración nativa; pendiente de prueba física. |
| Paquete de compartir | Staging privado Android o App Group iOS | Hasta importar/descartar. Solo manifest confirmado se importa automáticamente en iOS; draft requiere confirmación. |
| Items, Sources, Facts, Actions y Reminders | SQLite; Supabase solo con consentimiento de metadatos | Datos vivos hasta borrado. Las marcas de borrado conservan IDs/relaciones/fechas técnicas y eliminan títulos, texto, evidencias y payloads. Los originales se eliminan mediante cola durable. |
| Entrada y resultado IA local | AnalysisJobs; recuperar un envío interrumpido y revisar propuestas | Entrada preparada se elimina al completar. Borrado de fuente elimina el job; salida de cuenta limpia su biblioteca. |
| Contenido enviado para IA | Edge Function → proveedor configurado; extracción solicitada | OpenAI `store=false`, sin herramientas ni ejecución de instrucciones del documento. No se declara ZDR ni retención cero del proveedor. |
| Resultado IA remoto | Tabla privada, recuperación idempotente | TTL de 1 hora, purga cada 10 minutos. Borrar fuente invalida requests y elimina resultados al completar el borrado remoto. |
| Metadatos de request IA | IDs, hashes, estado, uso, error acotado; sin documento | Purga a los 90 días; contadores agregados de uso no contienen documentos. |
| Backup de original | Bucket privado `kipto-sources`, solo opt-in | Hasta borrado de fuente/cuenta. Caducar Pro no elimina ni impide descargar un backup existente. Borrado espera leases y puede requerir reintento en red. |
| ZIP exportado | Directorio temporal propio; compartir por hoja del sistema | Se limpia tras compartir/cerrar; restos de más de 24 h se purgan al siguiente arranque. Las copias que el usuario guarde/comparta salen del control de Kipto. |
| Preferencias de consentimiento | SharedPreferences, versión/fecha y ámbito de cuenta | No se heredan entre cuentas. Desactivar un consentimiento detiene nuevas transferencias; no elimina por sí solo datos ya guardados en nube. |
| Preferencia de movimiento | SharedPreferences y booleano `reduced-motion.json` en App Group para la extensión | Preferencia del dispositivo, sin cuenta ni contenido. Se sobrescribe al cambiarla; ante lectura ausente/fallida la extensión reduce el movimiento. |
| Sesión Auth | SDK Supabase; acceso compartido a la extensión mediante Keychain | La extensión solo recibe access token vigente, expiración y consentimiento; nunca refresh token ni tokens en App Group. Cleanup al salir/borrar cuenta. |
| Compras | Tienda/RevenueCat y entitlement verificado backend | UUID Supabase como identificador. Webhook conserva metadatos mínimos; eventos purgados a los 180 días. Borrar cuenta no cancela una suscripción de tienda. |
| Recibo de borrado de cuenta | Tabla backend privada, sin FK que lo destruya al borrar Auth | Recibo opaco para recuperar respuesta perdida; completados purgados a los 90 días. |
| Avisos del sistema | OS del dispositivo, IDs y payload de ruta | Reconciliados al confirmar/editar/resolver/borrar. Texto discreto por defecto; incluir título es opt-in por dispositivo. |

No hay anuncios ni escaneo masivo de fototeca. No se declaran cifrado de extremo a extremo,
procesamiento exclusivamente local ni entrega infalible de avisos. HTTPS, sandbox/Keychain y los
controles del proveedor no equivalen a borrado forense de páginas SQLite o a control de copias externas.

Manifests inspeccionados en dependencias instaladas: file_selector_ios, image_picker_ios,
share_plus y shared_preferences_foundation. Este último declara UserDefaults, razón `1C8F.1`.
RevenueCat y otros SDK nativos necesitan revisión del archive agregado después de resolver dependencias;
la inspección de caché no acredita inclusión ni cumplimiento final de las declaraciones de App Store.
