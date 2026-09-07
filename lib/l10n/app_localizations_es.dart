// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get pending => 'Pendientes';

  @override
  String get archive => 'Archivo';

  @override
  String get add => 'Añadir';

  @override
  String get search => 'Buscar';

  @override
  String get settings => 'Ajustes';

  @override
  String get close => 'Cerrar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get retry => 'Reintentar';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get resolve => 'Resolver';

  @override
  String get reopen => 'Reabrir';

  @override
  String get all => 'Todo';

  @override
  String get saved => 'Guardado';

  @override
  String get resolved => 'Resuelto';

  @override
  String get title => 'Título';

  @override
  String get note => 'Nota';

  @override
  String get outOfYourHead => 'Fuera de tu cabeza.';

  @override
  String get emptyPendingTitle => 'Un poco más de tranquilidad.';

  @override
  String get emptyPendingBody =>
      'Guarda un documento o escribe eso que quieres recordar. Todo empieza aquí.';

  @override
  String get emptyArchiveTitle => 'Un lugar para lo importante.';

  @override
  String get emptyArchiveBody =>
      'Aquí estarán tus documentos guardados y asuntos resueltos, a mano cuando los necesites.';

  @override
  String get image => 'Imagen';

  @override
  String get document => 'Documento';

  @override
  String get writeOrPaste => 'Escribir o pegar';

  @override
  String get shareHint =>
      'También puedes enviar una foto, un PDF o texto a Kipto desde Compartir en otra app.';

  @override
  String get notAvailableYet =>
      'Disponible en la siguiente fase de implementación';

  @override
  String get localError =>
      'No hemos podido abrir tus asuntos guardados. Vuelve a intentarlo.';

  @override
  String get noResults => 'Sin resultados';

  @override
  String get searchHint => 'Busca entre tus asuntos';

  @override
  String get withoutDate => 'Sin fecha';

  @override
  String get localSaved => 'Guardado en este dispositivo';

  @override
  String get notAnalyzed => 'Sin analizar';

  @override
  String get review => 'Revisar';

  @override
  String get toReview => 'Para revisar';

  @override
  String get upcoming => 'Próximamente';

  @override
  String get appearance => 'Apariencia';

  @override
  String get system => 'Sistema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get reduceMotion => 'Reducir movimiento';

  @override
  String get haptics => 'Respuesta háptica';

  @override
  String get notifications => 'Avisos';

  @override
  String get account => 'Cuenta';

  @override
  String get syncNow => 'Sincronizar ahora';

  @override
  String get cloudUnavailable =>
      'La sincronización no está configurada. Tus asuntos se conservan en este dispositivo.';

  @override
  String get preview => 'Vista previa del diseño';

  @override
  String get previewTitle => 'Revisar la renovación del seguro';

  @override
  String get previewDate => '16 de septiembre · fecha por confirmar';

  @override
  String get previewSummary =>
      'Comprueba el plazo de preaviso en el documento original.';

  @override
  String get previewSecondTitle => 'Cita con el dentista';

  @override
  String get previewSecondDate => '18 de septiembre · 09:30';

  @override
  String get previewError =>
      'No se ha podido leer el documento. El original sigue guardado.';

  @override
  String activeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count asuntos activos',
      one: '1 asunto activo',
      zero: 'Ningún asunto activo',
    );
    return '$_temp0';
  }

  @override
  String get saving => 'Guardando…';

  @override
  String get confirmingAction => 'Confirmando…';

  @override
  String get calendarPermissionDenied =>
      'No se ha autorizado el acceso al calendario.';

  @override
  String get evidenceDetails => 'Evidencia del dato';

  @override
  String get captureTooLarge =>
      'El límite es de 20 MiB por archivo y 60.000 caracteres por nota.';

  @override
  String get captureUnsupported =>
      'Elige un archivo JPEG, PNG, WebP, HEIC o PDF.';

  @override
  String get captureUnreadable =>
      'No se puede leer este archivo. Comprueba que está completo y no está protegido con contraseña.';

  @override
  String get captureFailed =>
      'No se ha podido guardar esta fuente. Tus asuntos anteriores siguen guardados. Vuelve a intentarlo.';

  @override
  String get captureAccountChanged =>
      'Tu cuenta ha cambiado. Vuelve a abrir Añadir antes de guardar en esta biblioteca.';

  @override
  String get sourceUnavailable =>
      'El original no está disponible en este dispositivo.';

  @override
  String get openOriginal => 'Abrir original';

  @override
  String get source => 'Fuente';

  @override
  String get syncConsent => 'Sincronizar mis asuntos';

  @override
  String get syncConsentBody =>
      'Incluye títulos, notas, texto de fuentes y datos extraídos en tu biblioteca privada en la nube. Los archivos originales necesitan un consentimiento de backup separado.';

  @override
  String get cloud => 'Nube y privacidad';

  @override
  String get protectLibrary => 'Proteger esta biblioteca';

  @override
  String get protectLibraryBody =>
      'Conecta Apple o Google para recuperar tus asuntos en otro dispositivo.';

  @override
  String get getStarted => 'Continuar con una cuenta privada';

  @override
  String get restoreApple => 'Restaurar con Apple';

  @override
  String get restoreGoogle => 'Restaurar con Google';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get signOutBody =>
      'Retira esta biblioteca de este dispositivo. Los datos en la nube se conservan.';

  @override
  String get operationFailed =>
      'No se ha podido completar la acción. Vuelve a intentarlo.';

  @override
  String get notificationEnabled => 'Los avisos locales están activados';

  @override
  String get notificationDisabled => 'Los avisos están desactivados';

  @override
  String get notificationAsk => 'Actívalos al crear un aviso';

  @override
  String get notificationUnavailable => 'No disponible en este dispositivo';

  @override
  String get sourceTextHint => 'Escribe o pega lo que quieres conservar';

  @override
  String get fieldRequired => 'Escribe un título y un texto.';

  @override
  String get recoveryFailed =>
      'No se han podido recuperar algunas fuentes pendientes. Sus archivos se han conservado.';

  @override
  String get pdfLimit =>
      'Solo se pueden analizar hasta 10 páginas. Conserva este original o aporta un PDF más corto.';

  @override
  String sharedReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fuentes compartidas están listas',
      one: '1 fuente compartida está lista',
    );
    return '$_temp0';
  }

  @override
  String sharedAsMatters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se guardarán como $count asuntos independientes.',
      one: 'Se guardará como un asunto.',
    );
    return '$_temp0';
  }

  @override
  String get discardCapture => 'Descartar captura';

  @override
  String get discardCaptureBody =>
      'Se eliminará esta entrega pendiente. Los asuntos ya guardados se conservarán.';

  @override
  String get detectedDate => 'Fecha detectada';

  @override
  String get detectedFact => 'Dato detectado';

  @override
  String get correctedFact => 'Dato corregido';

  @override
  String get originalValue => 'Valor original';

  @override
  String get checkOriginal =>
      'Comprueba este dato en el original antes de usarlo.';

  @override
  String get proposedReminder => 'Aviso propuesto';

  @override
  String calendarMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meses naturales',
      one: '1 mes natural',
    );
    return '$_temp0';
  }

  @override
  String calendarDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String pageNumber(int count) {
    return 'Página $count';
  }

  @override
  String get analyze => 'Analizar fuente';

  @override
  String get analyzeAgain => 'Volver a analizar';

  @override
  String get analysisConsentTitle => 'Analizar con IA';

  @override
  String get analysisConsentBody =>
      'Se enviará una copia preparada de esta fuente a Supabase y OpenAI para extraer datos y propuestas. Se creará una sesión anónima si hace falta. El original se conserva aquí. Esto no activa sincronización ni copia de seguridad. Puedes desactivarlo en Ajustes.';

  @override
  String get analysisConsent => 'Permitir análisis con IA';

  @override
  String get analysisConsentShort =>
      'Envía solo las fuentes que elijas. No crea avisos automáticamente.';

  @override
  String get analysisQueued => 'Guardado · por analizar';

  @override
  String get analysisRunning => 'Analizando la fuente…';

  @override
  String get analysisRetry => 'Esperando para reintentar';

  @override
  String get analysisReady => 'Análisis listo · revisa las propuestas';

  @override
  String get analysisPaused => 'El análisis está desactivado en Ajustes.';

  @override
  String get analysisCoverage =>
      'Revisa la cobertura y las evidencias antes de confirmar una acción.';

  @override
  String get analysisPartial => 'Análisis parcial: faltan páginas por revisar.';

  @override
  String get analysisTooLarge =>
      'La fuente supera el límite de análisis. El original está guardado; importa una copia reducida.';

  @override
  String get analysisTooManyPages =>
      'Este PDF tiene más de 10 páginas. Importa una copia con las páginas relevantes para analizarla. El original se conserva.';

  @override
  String get analysisUnreadable =>
      'No se puede leer esta fuente. Puedes guardar los datos manualmente o importar otra copia.';

  @override
  String get analysisNetwork =>
      'No se ha podido completar la conexión. Tu fuente sigue guardada.';

  @override
  String get analysisQuota =>
      'Has alcanzado un límite de análisis. Los documentos y avisos existentes siguen disponibles.';

  @override
  String get analysisSession =>
      'No hay una sesión válida para analizar. Revisa la cuenta en Ajustes.';

  @override
  String get analysisConfiguration =>
      'El servicio de análisis no está disponible. Puedes seguir guardando y creando datos manualmente.';

  @override
  String get analysisInvalid =>
      'No se ha podido validar el resultado. No se han creado propuestas ni avisos.';

  @override
  String get analysisIndeterminate =>
      'No podemos confirmar si el proveedor terminó el análisis. Esta petición no se repetirá automáticamente.';

  @override
  String get analysisStale =>
      'Este resultado ya no corresponde a la cuenta o fuente actual.';

  @override
  String get analysisNewRequestTitle => '¿Iniciar otro análisis?';

  @override
  String get analysisNewRequestBody =>
      'Se enviará otra petición que puede consumir un análisis de tu cuota. Se conservarán los datos corregidos y las acciones ya aceptadas.';

  @override
  String get analysisContextOmitted =>
      'El texto acompañante se conserva en el asunto; este análisis revisa solo el archivo.';

  @override
  String get analysisUncertainty => 'Dato incierto';

  @override
  String get analysisReviewTitle => 'Título propuesto';

  @override
  String get analysisNoActions =>
      'No se han propuesto acciones. Guardar sin fecha sigue siendo válido.';

  @override
  String get reviewAction => 'Revisar propuesta';

  @override
  String get remindAction => 'Recordar';

  @override
  String get eventAction => 'Añadir al calendario';

  @override
  String get keepAction => 'Solo guardar';

  @override
  String get confirmAction => 'Confirmar';

  @override
  String get chooseDate => 'Elegir fecha';

  @override
  String get chooseTime => 'Elegir hora';

  @override
  String get timeZone => 'Zona horaria';

  @override
  String get startDate => 'Fecha de inicio';

  @override
  String get endDate => 'Fecha de fin';

  @override
  String get startTime => 'Hora de inicio';

  @override
  String get endTime => 'Hora de fin';

  @override
  String get allDay => 'Todo el día';

  @override
  String get endDateExclusive => 'La fecha de fin no está incluida.';

  @override
  String get locationOptional => 'Lugar (opcional)';

  @override
  String get confirmTemporal =>
      'Comprueba fecha, hora y zona. Una fecha detectada no crea un aviso por sí sola.';

  @override
  String get invalidTemporal =>
      'Completa los datos temporales con una zona válida y un intervalo correcto.';

  @override
  String get nonexistentTime =>
      'Esa hora no existe en la zona elegida por el cambio horario. Elige otra.';

  @override
  String get ambiguousTime =>
      'Esa hora ocurre dos veces. Elige cuál corresponde.';

  @override
  String get sameDate => 'Ese día';

  @override
  String get dayBefore => 'Un día antes';

  @override
  String get weekBefore => 'Una semana antes';

  @override
  String get monthBefore => 'Un mes natural antes';

  @override
  String get monthClamped => 'Se ha ajustado al último día del mes.';

  @override
  String get reminderScheduled => 'Aviso programado en este dispositivo.';

  @override
  String get reminderNotScheduled =>
      'Aviso guardado, pero no programado en este dispositivo. Revisa el permiso o la capacidad de avisos.';

  @override
  String get calendarSaved => 'Evento guardado en el calendario.';

  @override
  String get calendarOpened =>
      'Calendario abierto. Kipto no puede confirmar si guardaste el evento.';

  @override
  String get calendarCancelled => 'No se ha guardado ningún evento.';

  @override
  String get calendarUnavailable =>
      'No se puede abrir el calendario en este dispositivo.';

  @override
  String get keepExplained =>
      'Conserva el documento sin crear fechas. Si no hay avisos futuros, se descartarán las otras propuestas y el asunto pasará a Archivo.';

  @override
  String get keptResult =>
      'Documento conservado. Los avisos que ya existían no se han cancelado.';

  @override
  String get dismissProposal => 'Descartar propuesta';

  @override
  String get proposedAction => 'Por confirmar';

  @override
  String get acceptedAction => 'Confirmado';

  @override
  String get reopenCalendar => 'Volver a abrir calendario';

  @override
  String get reopenCalendarBody =>
      'Puede que el evento ya exista. Comprueba el calendario antes de crear otra copia.';

  @override
  String get resolveMatter => 'Resolver asunto';

  @override
  String get reopenMatter => 'Volver a Pendientes';

  @override
  String get archiveMatter => 'Archivar asunto';

  @override
  String get archiveReminderBody =>
      'Archivar cancelará los avisos futuros de este asunto. No se eliminará ningún evento del calendario.';

  @override
  String get resolveReminderBody =>
      'Resolver cancelará los avisos pendientes y conservará el documento en Archivo. Deshacer reprogramará solo los avisos futuros válidos.';

  @override
  String get editMatter => 'Editar título y resumen';

  @override
  String get matterTitle => 'Título';

  @override
  String get matterSummary => 'Resumen';

  @override
  String get actionTitle => 'Título de la acción';

  @override
  String get savedChange => 'Cambios guardados';

  @override
  String get lifecycleFailed =>
      'No se ha completado la operación. Revisa el estado guardado y los permisos de avisos antes de repetir.';

  @override
  String get undo => 'Deshacer';

  @override
  String get viewEvidence => 'Ver fuente de este dato';

  @override
  String get pendingReminder => 'Aviso pendiente';

  @override
  String get completedReminder => 'Aviso cancelado o completado';

  @override
  String get cancelReminder => 'Cancelar aviso';

  @override
  String get cancelReminderBody =>
      'Se cancelará este aviso. El asunto seguirá en Pendientes.';

  @override
  String get noReminderCreated => 'Guardar no crea ningún aviso.';

  @override
  String get factValue => 'Valor';

  @override
  String get rawDate => 'Texto de la fecha';

  @override
  String get currency => 'Moneda (opcional)';

  @override
  String get durationCount => 'Cantidad';

  @override
  String get durationUnit => 'Unidad';

  @override
  String get calendarDayUnit => 'Días naturales';

  @override
  String get calendarMonthUnit => 'Meses naturales';

  @override
  String get clearDate => 'Fecha sin confirmar';

  @override
  String get clearTime => 'Hora sin confirmar';

  @override
  String get factCorrectionBody =>
      'La corrección conserva la extracción original y su evidencia. No cambia avisos ya confirmados.';

  @override
  String get reviewGroup => 'Por revisar';

  @override
  String get datedGroup => 'Con fecha';

  @override
  String get otherGroup => 'Otros asuntos';

  @override
  String get sourceLocal => 'Original en este dispositivo';

  @override
  String get sourceMissing => 'Original no disponible en este dispositivo';

  @override
  String get reimportSource => 'Importar otra copia';

  @override
  String get searchResultCount => 'Resultados';

  @override
  String get backupConsent => 'Copia de originales';

  @override
  String get backupConsentBody =>
      'Con Kipto Pro, sube originales a tu copia privada (hasta 1 GiB). Requiere sincronizar sus metadatos. Al desactivarlo se conservan las copias ya subidas.';

  @override
  String backupPending(int count) {
    return '$count archivos pendientes de transferencia';
  }

  @override
  String get backupReady => 'Copia de seguridad confirmada';

  @override
  String backupTransfer(int sent, int total) {
    return 'Transferidos $sent de $total bytes; pendiente de confirmar';
  }

  @override
  String get backupProRequired =>
      'Las nuevas copias requieren Kipto Pro. Tu original sigue en este dispositivo.';

  @override
  String get downloadBackup => 'Descargar copia, si está disponible';

  @override
  String signOutWarning(int changes, int originals) {
    return 'Se retirará la biblioteca de este dispositivo. Hay $changes asuntos con cambios pendientes y $originals originales cuya copia no está confirmada aquí. Puedes cancelar y exportarlos antes de salir.';
  }

  @override
  String get proHeadline => 'Más ayuda.\nTodo a mano.';

  @override
  String get proBody =>
      'Amplía los análisis y guarda una copia privada de tus originales.';

  @override
  String get proAnalysis => '100 análisis al mes';

  @override
  String get proBackup => 'Hasta 1 GiB de originales';

  @override
  String get proVerified => 'Kipto Pro confirmado por el servidor';

  @override
  String get freePlan => 'Plan gratuito · 5 análisis al mes';

  @override
  String get billingUnavailable =>
      'Las compras aún no están disponibles. Puedes seguir guardando y creando avisos manuales.';

  @override
  String get paymentPending =>
      'La tienda está esperando la aprobación del pago.';

  @override
  String get purchaseVerificationPending =>
      'Compra recibida por la tienda. Los límites se ampliarán cuando el servidor confirme tus derechos.';

  @override
  String get monthlyPlan => 'Mensual';

  @override
  String get annualPlan => 'Anual';

  @override
  String get subscriptionTerms =>
      'Suscripción con renovación automática por el periodo indicado. Consulta el importe y las condiciones finales en la tienda antes de confirmar. Guardar, consultar y tus avisos existentes siguen disponibles si cancelas.';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get restorePurchaseBody =>
      'Compras consultadas. Restaurar compras no recupera los documentos de otra cuenta.';

  @override
  String get manageSubscription => 'Gestionar suscripción';

  @override
  String get noSubscription => 'No hay una suscripción activa para gestionar.';

  @override
  String get refreshStatus => 'Actualizar estado';

  @override
  String get privacy => 'Privacidad';

  @override
  String get terms => 'Condiciones';

  @override
  String get exportData => 'Exportar';

  @override
  String get exportBody =>
      'Prepara un ZIP con los datos seleccionados y los originales disponibles. Si faltan archivos, puedes cancelar y descargarlos desde el detalle antes de exportar.';

  @override
  String get exportComplete =>
      'Se han incluido todos los originales seleccionados.';

  @override
  String exportMissing(int count) {
    return 'Faltan $count originales. El manifiesto indica cuáles.';
  }

  @override
  String get saveExport => 'Guardar o compartir ZIP';

  @override
  String get deleteMatter => 'Eliminar asunto';

  @override
  String get deleteMatterBody =>
      'Se eliminará el asunto y sus fuentes, y se cancelarán sus avisos. La eliminación de copias remotas puede quedar pendiente hasta recuperar la conexión. No se puede deshacer.';

  @override
  String get deletePending =>
      'La eliminación se ha solicitado. Hay pasos pendientes; revisa las transferencias en Ajustes.';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteAccountBody =>
      'Se eliminarán tu cuenta, los datos y las copias de originales de Kipto. Exporta primero lo que quieras conservar. No se puede deshacer. La suscripción de la tienda no se cancela automáticamente: puedes gestionarla en Kipto Pro antes de continuar, pero no es un requisito para borrar.';

  @override
  String get accountDeleted => 'Cuenta eliminada';

  @override
  String get accountDeletionPending => 'Eliminación en curso';

  @override
  String get accountDeletionWait =>
      'Las nuevas transferencias están bloqueadas. Si había una subida en curso, la eliminación esperará hasta cinco minutos para no dejar archivos sueltos. Puedes reintentarlo con conexión; la solicitud se conserva si cierras la app.';

  @override
  String get notificationsThisDevice => 'Avisos en este dispositivo';

  @override
  String get notificationsDevicesBody =>
      'Si activas avisos en dos dispositivos, ambos pueden notificar. El permiso del sistema también debe estar activado.';

  @override
  String get notificationTitles => 'Incluir título en los avisos';

  @override
  String get notificationTitlesBody =>
      'Por defecto solo se muestra que tienes un asunto pendiente. Actívalo para mostrar el título, también en la pantalla bloqueada.';

  @override
  String get returnToSource => 'Volver a la app de origen';

  @override
  String get deleteSource => 'Borrar fuente';

  @override
  String get deleteSourceBody =>
      'Se borrarán este original y sus datos extraídos, y se cancelarán los avisos relacionados. El asunto se conserva. Esta acción no se puede deshacer.';

  @override
  String get loading => 'Cargando…';
}
