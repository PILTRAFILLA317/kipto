# Kipto — Life Admin

Kipto conserva una fuente, ayuda a revisar lo importante y permite elegir entre
Recordar, Evento o Guardar. Flutter/Riverpod, Drift, Supabase y RevenueCat.

La implementación de las fases 01–14 está en este checkout, con pruebas automatizadas
y backend aplicado. **El lanzamiento está pendiente de configuración comercial y pruebas
nativas**: no se ha realizado un build, archive ni publicación.

- Importación explícita de imagen, PDF y texto; share Android y target ShareExtension iOS.
- Original duradero antes de IA; hechos/evidencias, correcciones y propuestas por confirmar.
- Pendientes, Archivo, búsqueda local, acciones y reconciliación de avisos por dispositivo.
- Sync de metadatos y backup privado con consentimientos separados y control de propietario.
- Plan Pro con precios de tienda, restore/manage y acceso verificado por backend.
- Exportación ZIP, borrado de fuentes/asuntos/cuenta y recuperación de operaciones interrumpidas.

Sin configuración externa se informa indisponibilidad; no hay IA ni compras ficticias.
El código no implementa Family, email, voz ni escaneo global de fototeca.

## Documentación

- [Estado y evidencia por fase](docs/implementation-status.md)
- [Setup manual](docs/manual-setup.md)
- [Checklist y limitaciones de lanzamiento](docs/release-checklist.md)
- [Arquitectura](docs/architecture-decisions.md)
- [Inventario de datos/retención](docs/privacy-data-inventory.md)
- [Textos y capturas para revisión](docs/store-copy.md)

## Verificación local

```sh
rtk proxy flutter pub get
rtk proxy flutter analyze
rtk proxy flutter test
```

Para una ejecución nativa autorizada, los defines se cargan al compilar:

```sh
rtk proxy flutter run --dart-define-from-file=config/dev.json
```

`config/dev.json` no se versiona. Solo contiene configuración pública del cliente;
las claves de servidor permanecen en Supabase. El hot reload no recarga defines.
