# Contrato de análisis v1

Congelado para la implementación el 05/09/2026. Cambios incompatibles necesitan
una versión nueva. JSON Schema compartido:
[petición](../../supabase/functions/_shared/contracts/analysis-request-v1.schema.json) y
[respuesta](../../supabase/functions/_shared/contracts/analysis-output-v1.schema.json).
Fixtures sintéticas: `test/fixtures/analysis/`. Estos archivos sirven a Dart,
Edge Function y Swift; no son datos insertados al abrir la aplicación.

## Petición

`requestVersion=1`, `requestId` UUID estable de la operación, `captureId`,
`sourceId`, `sourceRevision >= 1`, `locale` es/en, `userTimeZone` IANA,
`importedAt` ISO con zona, `knownDocumentContext` null o fecha documental
explícita/confirmada. `importedAt` nunca resuelve «mañana».

`input` tiene `type`, `textPages` e `imagePages`; exactamente una lista está
poblada y coincide con type. `coverage` incluye `totalPagesKnown` nullable,
`analyzedPages` únicos, positivos, máximo diez, e `isPartial`. Las páginas deben
coincidir exactamente con las de input. Si el total conocido es mayor que las
páginas enviadas, `isPartial` es true. La V1 conserva un PDF largo y solicita
otro reducido; no trunca silenciosamente. No se admiten campos extra.

Límites de tránsito propios de Kipto: cuerpo UTF-8 máximo 8 MiB, texto agregado
60.000 caracteres, hasta diez imágenes JPEG/PNG/WebP. HEIC se convierte localmente.
Se validan base64, firma MIME, bytes decodificados y dimensiones antes de llamar
al proveedor. No se admiten URLs que descargar. El servidor deriva propietario,
plan y cuota de sesión verificada; ningún campo del cliente los decide.

## Respuesta

`schemaVersion=1`, revisión coincidente, título/etiqueta hasta 100 caracteres,
resumen hasta 300, máximo doce hechos, seis sugerencias y ocho advertencias.
`coverage` debe coincidir con la petición. Identificadores f1/a1 son referencias
locales a esa respuesta, no UUID persistentes. Se rechazan duplicados y
referencias inexistentes. El servidor y Dart validan también las relaciones y
el tipo de `value`; el schema por sí solo no acredita evidencia ni semántica.

Valores de hechos:

| valueType | Objeto value |
|---|---|
| text | `{text}` hasta 2.000 caracteres |
| date | `{date: "YYYY-MM-DD" o null, raw}`; null conserva incertidumbre |
| datetime | `{date, time: "HH:mm" o null, zone: IANA o null, raw}` |
| duration | `{count: entero positivo, unit: calendarDay o calendarMonth}` |
| money | `{amount: decimal como string, currency: código de tres letras o null}` |

La extracción no produce instantes de notificación ni payloads ejecutables.
Cada hecho tiene evidencia `{page, quote}` nullable e incertidumbre explícita.
Dart coteja la cita literal contra la página realmente enviada; sin coincidencia
queda `unverified`. Imágenes tienen `visualReference`; nunca `textMatched` sin
OCR cotejado. No se admiten coordenadas inventadas. Los hechos corregidos
conservan `value` y evidencia originales; `user_value` representa la corrección.

Cada sugerencia lleva kind remind/event/keep, título, claves de hechos,
`anchorFactKey` nullable, `needsUserInput` (date/year/time/zone/occurrence/duration)
y razón. La UI confirma los campos temporales incluso si el modelo deja vacía
la lista. Una fecha sin hora no es un instante. Los meses naturales se calculan
como meses, mostrando si se ajustó al último día. Las horas inexistentes se
rechazan; las duplicadas exigen elegir una de las ocurrencias reales.

## Envolvente y aplicación

La respuesta del endpoint envolverá `output` con `requestId`, `model`,
`promptVersion`, `schemaVersion`, `analyzedAt` y `usage` agregado. El backend
asigna estos campos; el texto generado no los controla. Se aplica solo cuando
coinciden cuenta, fuente, revisión e Item no eliminado. Reanalizar conserva
acciones aceptadas, recordatorios y correcciones del usuario.

Estados digitales: proposed/accepted/dismissed y
notRequested/pending/applied/launchedUnconfirmed/failed. La aceptación se guarda
en transacción antes de llamar al sistema. `applied` acredita la operación
digital, nunca el pago, devolución o asistencia. Un evento de día completo usa
fechas de calendario y final exclusivo; un aviso confirmado usa UTC y zona IANA.

## Estado de integración

Contrato y validación Dart en desarrollo de FASE 05. Este documento no acredita
Edge Function desplegada, credenciales, cuotas ni cliente Swift integrado;
su implementación y pruebas corresponden a las siguientes fases.
