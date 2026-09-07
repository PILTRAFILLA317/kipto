# Kipto — Configuración manual

Actualizado el 06/09/2026. La implementación usa el checkout existente y Supabase
`wrkykxyctseqvfwehdcu`. No se han hecho builds, archives ni publicaciones.
Los identificadores que siguen en el código son de desarrollo; no son una propuesta comercial.

## Identidad y firma

1. El titular debe proporcionar los bundle/application IDs registrados. Actualmente se conserva
   `com.example.kipto`; la extensión usa `com.example.kipto.ShareExtension`.
2. Cambiar conjuntamente Runner, ShareExtension, Android namespace/applicationId, callbacks OAuth,
   esquemas URL de iOS/Android y redirects permitidos en Supabase. El callback actual es
   `com.example.kipto://auth/callback`, con flujos separados `protect` y `restore`.
3. Confirmar Apple Team, perfiles y capacidades de ambos targets. El Team conservado es
   `69M84T6477`; no se ha comprobado su firma. El target ShareExtension ya está incorporado y embebido.
4. En `ios/Shared/Share.local.xcconfig` (ignorado), establecer `KIPTO_APP_GROUP` con el grupo registrado
   y `KIPTO_KEYCHAIN_GROUP` con el sufijo de acceso aprobado. Los entitlements anteponen
   `$(AppIdentifierPrefix)` al segundo: no duplicar ese prefijo. Ambos targets deben compartir capacidades.
5. Configurar el keystore comercial y Play App Signing antes de distribuir Android. Release ya no
   hereda la firma debug. `android/key.properties`, `.jks` y `.keystore` están ignorados.
6. Revisar iconos actuales y aprobar arte final de marca, versión `1.0.0+1`, categorías y contacto de soporte.
   No se ha elegido una nueva identidad de tienda ni publicado metadatos.

## Flutter y servicios

Pasar configuración **al compilar**, por ejemplo con un JSON local no versionado:

- `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`: solo valores públicos de cliente.
- `REVENUECAT_IOS_PUBLIC_KEY`, `REVENUECAT_ANDROID_PUBLIC_KEY`: claves públicas por plataforma.
- `PRIVACY_URL`, `TERMS_URL`: páginas públicas reales con HTTPS; no se aceptan placeholders para comprar.

El hot reload no recarga los defines. `config/dev.json` contiene la configuración local existente;
no añadir claves privadas de Supabase, RevenueCat u OpenAI a ese archivo ni al binario.

Apple/Google Auth: verificar proveedor, redirects y el flujo de proteger la misma identidad frente a
restaurar otra biblioteca. No se ha ejecutado OAuth en dispositivo durante esta entrega.

## RevenueCat

- Crear/verificar apps en RevenueCat asociadas a las identidades reales de las tiendas.
- Vincular los productos mensual y anual aprobados a una offering actual y al entitlement **`kipto_pro`**.
  No se han inventado IDs ni precios. La UI obtiene los precios de la tienda.
- App User ID: UUID Supabase. Restaurar compras no restaura la biblioteca ni sustituye OAuth/sync.
- Configurar secretos de servidor `REVENUECAT_SECRET_API_KEY` y `REVENUECAT_WEBHOOK_AUTH`
  (Authorization propio, al menos 32 caracteres) mediante el gestor de secretos; nunca por chat/Git.
- Webhook: `https://wrkykxyctseqvfwehdcu.supabase.co/functions/v1/revenuecat-webhook`.
  JWT de Supabase desactivado deliberadamente: autentica su cabecera propia antes de consultar RevenueCat.
- El backend comprueba el entitlement con la API de RevenueCat. Eventos duplicados/viejos no conceden
  acceso; una cancelación conserva el periodo pagado y sandbox no concede Pro en producción.
- La configuración de cuotas usa `production`. Una prueba sandbox debe registrarse como sandbox;
  no cambiar producción ni conceder acceso a usuarios reales para fingir una compra exitosa.
- Probar compra, cancelación, pendiente, restauración, caducidad y transferencia de identidad con cuentas
  de tienda de prueba. No ejecutado: faltan configuración comercial y ejecución nativa autorizada.

## IA, backup y borrado

- `analyze-source`: JWT obligatorio, Auth deriva el propietario, modelo servidor `gpt-5.6-luna`.
  Una llamada sintética real y su replay ya están documentados; la suite normal no consume IA.
- `source-backup`: JWT obligatorio. Bucket privado `kipto-sources`; máximo 20 MiB por original,
  1 GiB por usuario Pro contando reservas. El servidor verifica tamaño/hash; el cliente no puede
  escribir directamente en Storage. Activar backup requiere consentimiento de metadatos y archivos.
- `delete-account`: JWT de gateway desactivado **solo** porque Auth se comprueba en el cuerpo de la
  función y, después del borrado, se admite consultar un recibo opaco de finalización sin sesión.
  Ese recibo no permite iniciar un borrado ni recuperar identidad/documentos.
- Los borrados esperan leases de uploads en curso. Si falla la red permanecen pendientes y reintentables.
- Mantener los jobs de purga de resultados IA, eventos de facturación y recibos de borrado.

## Comandos de verificación

Ejecutados sin compilar la app nativa:

```sh
rtk proxy dart format --output=none --set-exit-if-changed lib test
rtk proxy flutter analyze
rtk proxy flutter test
rtk proxy npx -y deno test --config supabase/functions/deno.json --allow-read --allow-env=SUPABASE_URL,SUPABASE_SERVICE_ROLE_KEY,SUPABASE_ANON_KEY supabase/functions/analyze-source supabase/functions/revenuecat-webhook
rtk proxy npx -y deno lint --config supabase/functions/deno.json supabase/functions
rtk proxy git diff --check
```

Capturas reproducibles de widgets reales con datos sintéticos, sin ejecutar el binario nativo:

```sh
rtk proxy flutter test --dart-define=KIPTO_RELEASE_PREVIEW=true test/release_preview_test.dart
```

Comando para el titular **después de autorizar una ejecución nativa**:

```sh
rtk proxy flutter run --dart-define-from-file=config/dev.json
```

No se han ejecutado `flutter build`, `xcodebuild`, archive, TestFlight ni publicación.
Antes de distribución, validar la resolución nativa de todos los plugins y el informe agregado de
privacidad del archive: los manifests de plugins presentes en caché no prueban su inclusión final.

## Comprobación Swift sin build (ejecutada)

La extensión pasó typecheck con las restricciones de APIs de app extensions, SDK iOS Simulator26.2,
Swift5 y deployment target iOS15. Comando ejecutado desde el repo (sin enlazar ni crear una app):

```sh
rtk proxy xcrun swiftc -typecheck -application-extension \
  -sdk "$(rtk proxy xcrun --sdk iphonesimulator --show-sdk-path)" \
  -target arm64-apple-ios15.0-simulator -swift-version 5 \
  ios/Shared/ShareStore.swift ios/Shared/ShareSession.swift \
  ios/ShareExtension/ShareAnalysis.swift ios/ShareExtension/NoRedirectDelegate.swift \
  ios/ShareExtension/ShareViewController.swift
```

El adaptador `SharedCaptureAdapter.swift`, junto con ShareStore y ShareSession, también pasó
`swiftc -typecheck` con el mismo SDK/target y `-F` apuntando al slice de simulador del
Flutter.xcframework instalado en `/Users/umartin-/development/flutter/bin/cache/artifacts/engine/ios/`.
No se ha typechecked todo Runner ni enlazado los plugins; sigue pendiente el build autorizado.

En la prueba física de share: guardar debe mostrar la confirmación solo tras publicar el paquete;
Volver debe cerrar sin esperar la animación. Repetir con movimiento reducido del sistema y con la
preferencia local de Kipto; negar/quitar App Group debe impedir falso éxito y conservar el fallback.
