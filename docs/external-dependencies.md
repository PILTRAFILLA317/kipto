# Kipto — Dependencias externas y configuración

Actualizado: 06/09/2026. Inventario vigente; sustituye los pendientes de la auditoría inicial.
Los pasos del titular están en [manual-setup.md](manual-setup.md); las pruebas pendientes,
en [release-checklist.md](release-checklist.md). «Pendiente» no afirma que el titular carezca
de la cuenta o credencial: significa que su configuración no ha sido verificada aquí.

## Servicios y plataformas

| Dependencia | Estado verificado | Pendiente |
|---|---|---|
| Supabase | Proyecto existente `wrkykxyctseqvfwehdcu`; 15 migraciones coincidentes por versión/nombre y 4 functions ACTIVE | OAuth y restauración desde binario nativo |
| IA | `analyze-source` v2, JWT/Auth, modelo servidor `gpt-5.6-luna`; una llamada sintética v1 y replay HTTP200 | Evaluación de calidad y preparación de medios nativa |
| Storage | Bucket privado `kipto-sources`, 20 MiB/original y 1 GiB/Pro; upload/download/hash y aislamiento HTTP verificados | Restauración completa desde móvil |
| Apple | Runner + ShareExtension embebida, entitlements y configuración compartida implementados | IDs comerciales, App Group/Keychain, capacidades, perfiles y firma |
| Android | Recepción de archivos/texto y retorno a origen implementados; release sin firma debug | Application ID comercial, keystore/Play App Signing y prueba de intents |
| RevenueCat | SDK, paywall, restore/manage, entitlement `kipto_pro` y webhook v2 implementados | Apps/productos/offerings, claves públicas, secretos y compra sandbox |
| Privacidad/tiendas | Inventario de datos, textos y capturas sintéticas preparados; exportación/borrado implementados | URLs legales públicas, soporte, marca/metadatos aprobados y declaraciones del archive |

No se cambiaron las identidades de desarrollo `com.example.kipto` y
`com.example.kipto.ShareExtension` por valores comerciales inventados.
Team conservado: `69M84T6477`; firma no verificada.
Sin configuración válida, la compra y las capacidades dependientes muestran indisponibilidad real.

## Dependencias añadidas y fijadas

| Componente | Versión | Uso / licencia revisada |
|---|---|---|
| Inter local | Asset versionado y OFL adjunta | Tipografía sin descarga en runtime; SIL OFL 1.1 |
| flutter_localizations / intl | SDK / ^0.20.2 | Localización ARB es/en; versiones resueltas en pubspec.lock |
| image_picker | 1.2.3 | Selector del sistema; BSD-3-Clause |
| file_selector | 1.1.0 | Archivos explícitos; BSD-3-Clause |
| pdfrx | 2.6.1 | Visor, texto por página y raster acotado; MIT, PDFium nativo |
| crypto | 3.0.7 | SHA-256 durante copia; BSD-3-Clause |
| purchases_flutter | 10.11.0 | RevenueCat; MIT |
| url_launcher | 6.3.2 | URLs legales y gestión de suscripción; BSD-3-Clause |
| share_plus | 13.3.0 | Compartir ZIP exportado; BSD-3-Clause |
| archive | 4.2.0 | ZIP por streaming; MIT |
| AJV / image-size | 8.20.0 / 2.0.2 | Contrato/backend; MIT, fijados en deno.json/deno.lock |
| Deno | 2.9.6 en verificaciones | Herramienta backend mediante npx; MIT |
| pg_jsonschema / pg_cron | Extensiones del proyecto Supabase | Validación JSON y retención; activadas mediante migraciones |

Se preservan Riverpod, GoRouter, Drift, Auth/sync y adaptadores existentes.
No hubo actualización masiva. Los lockfiles forman parte de la entrega.
El análisis/tests y la revisión de APIs/licencias no acreditan compilación o enlace de SDKs nativos.
Los manifests de privacidad presentes en caché deben contrastarse con el archive agregado cuando se autorice.

## Configuración pública y secretos

Flutter recibe defines al compilar: `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`,
`REVENUECAT_IOS_PUBLIC_KEY`, `REVENUECAT_ANDROID_PUBLIC_KEY`, `PRIVACY_URL` y `TERMS_URL`.
Un hot reload no recarga estos valores. No incluir claves privadas ni service role en Flutter.

Los secretos RevenueCat pendientes se configuran en el gestor del servidor:
`REVENUECAT_SECRET_API_KEY` y `REVENUECAT_WEBHOOK_AUTH` (mínimo 32 caracteres).
Las credenciales OpenAI permanecen en servidor; no se imprimieron sus valores.
Los grupos iOS van en `ios/Shared/Share.local.xcconfig`, ignorado por Git;
el access token vigente de la extensión se comparte solo por Keychain, sin refresh token ni token en manifest.

## Referencias técnicas

- [Modelos OpenAI](https://developers.openai.com/api/docs/models),
  [Structured Outputs](https://developers.openai.com/api/docs/guides/structured-outputs) y
  [visión](https://developers.openai.com/api/docs/guides/images-vision), consultados durante FASE06.
- [Controles de datos](https://developers.openai.com/api/docs/guides/your-data):
  `store=false` no garantiza retención cero; no se declara ZDR ni cifrado de extremo a extremo.
- [Auth de Edge Functions](https://supabase.com/docs/guides/functions/auth-headers).
  Las excepciones JWT de webhook/borrado tienen autenticación propia documentada.
- [RevenueCat Flutter](https://www.revenuecat.com/docs/getting-started/installation/flutter).
- Licencias móviles locales en el caché de paquetes de las versiones instaladas; Inter en
  `assets/fonts/OFL.txt`. La resolución nativa final sigue pendiente.

## Evaluación IA opt-in

`scripts/evaluate-analysis.ts` requiere `--run --cases=1` (máximo tres), una identidad sintética
autorizada y env `KIPTO_EVAL_URL`, `KIPTO_EVAL_PUBLIC_KEY`, `KIPTO_EVAL_TOKEN`.
Ejecutar con permisos de red/lectura acotados; no imprimir ni guardar el token en Git.
El operador crea/limpia esa identidad; el script no lo hace. Cada caso puede consumir cuota.
No participa en la suite automática. La prueba real registrada consumió 808 tokens de entrada
y 331 de salida; su identidad fue eliminada. No repetirla para comprobar documentación.
