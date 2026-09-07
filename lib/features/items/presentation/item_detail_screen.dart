import 'package:kipto/core/presentation/widgets/life_admin_card.dart';
import 'package:kipto/features/privacy/presentation/privacy_providers.dart';
import 'package:kipto/features/backup/presentation/backup_providers.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/features/items/presentation/widgets/fact_card.dart';
import 'package:kipto/features/analysis/presentation/analysis_panel.dart';
import 'package:kipto/features/actions/presentation/item_actions_panel.dart';
import 'package:kipto/features/items/presentation/widgets/matter_controls.dart';
import 'package:kipto/features/items/presentation/widgets/fact_edit_sheet.dart';
import 'package:kipto/features/capture/presentation/add_sheet.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:kipto/core/domain/models/item.dart';
import 'package:kipto/core/domain/models/source.dart';
import 'package:kipto/core/providers/repository_providers.dart';
import 'package:kipto/core/presentation/widgets/content_width.dart';
import 'package:kipto/core/presentation/widgets/kipto_ui.dart';
import 'package:kipto/features/capture/presentation/capture_providers.dart';
import 'package:kipto/l10n/app_localizations.dart';

final itemProvider = StreamProvider.family<Item?, String>(
  (ref, id) => ref
      .watch(itemsRepositoryProvider)
      .watchAll()
      .map((items) => items.where((item) => item.id == id).firstOrNull),
);

final sourceAvailableProvider = FutureProvider.family<bool, Source>((
  ref,
  source,
) async {
  if (source.kind == SourceKind.text || source.kind == SourceKind.url) {
    return source.textContent != null;
  }
  ref.watch(fileJobsProvider);
  final row = await ref.watch(sourcesRepositoryProvider).localFile(source.id);
  if (row?.originalRelativePath == null) return false;
  final store = await ref.watch(originalStoreProvider.future);
  return store.file(row!.originalRelativePath!).exists();
});

class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({super.key, required this.itemId});
  final String itemId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    ref.watch(authStateProvider.select((state) => state.valueOrNull?.userId));
    final owner = ref.read(authRepositoryProvider).userId;
    final item = ref.watch(itemProvider(itemId));
    return Scaffold(
      appBar: AppBar(title: Text(l.source)),
      body: ContentWidth(
        child: item.when(
          loading: () => const KiptoSkeleton(height: 200),
          error: (_, _) => Center(child: Text(l.localError)),
          data: (item) => item == null || item.ownerId != owner
              ? Center(child: Text(l.noResults))
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    LifeAdminCard(
                      title: item.title,
                      itemId: item.id,
                      hero: true,
                      status: l.localSaved,
                      subtitle: item.summary.isEmpty ? null : item.summary,
                    ),
                    const SizedBox(height: 24),
                    ItemActionsPanel(item: item),
                    ...ref
                        .watch(itemFactsProvider(itemId))
                        .when(
                          loading: () => <Widget>[],
                          error: (_, _) => [Text(l.localError)],
                          data: (facts) => [
                            for (final fact in facts)
                              FactCard(
                                fact: fact,
                                onEdit: () => showModalBottomSheet<void>(
                                  context: context,
                                  isScrollControlled: true,
                                  showDragHandle: true,
                                  builder: (_) => FactEditSheet(fact: fact),
                                ),
                                onSource: fact.sourceId == null
                                    ? null
                                    : () async {
                                        final source = await ref
                                            .read(sourcesRepositoryProvider)
                                            .find(fact.sourceId!);
                                        if (source == null ||
                                            !context.mounted) {
                                          return;
                                        }
                                        Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) => SourceViewer(
                                              source: source,
                                              initialPage: fact.evidence.page,
                                            ),
                                          ),
                                        );
                                      },
                              ),
                          ],
                        ),
                    ...ref
                        .watch(itemSourcesProvider(itemId))
                        .when(
                          loading: () => [const KiptoSkeleton(height: 100)],
                          error: (_, _) => [Text(l.localError)],
                          data: (sources) => [
                            for (final source in sources) ...[
                              KiptoActionRow(
                                icon: source.kind == SourceKind.pdf
                                    ? Icons.picture_as_pdf_outlined
                                    : source.kind == SourceKind.image
                                    ? Icons.image_outlined
                                    : Icons.notes_outlined,
                                title: source.originalName,
                                subtitle:
                                    ref
                                            .watch(
                                              sourceAvailableProvider(source),
                                            )
                                            .valueOrNull ==
                                        true
                                    ? l.sourceLocal
                                    : l.sourceMissing,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        SourceViewer(source: source),
                                  ),
                                ),
                              ),
                              ...ref
                                  .watch(fileJobsProvider)
                                  .when(
                                    loading: () => <Widget>[],
                                    error: (_, _) => [Text(l.operationFailed)],
                                    data: (jobs) {
                                      final job = jobs
                                          .where((j) => j.sourceId == source.id)
                                          .firstOrNull;
                                      if (job == null) return <Widget>[];
                                      return <Widget>[
                                        Text(
                                          job.state == 'done'
                                              ? (job.operation == 'upload'
                                                    ? l.backupReady
                                                    : l.localSaved)
                                              : l.backupTransfer(
                                                  job.transferredBytes,
                                                  source.byteSize,
                                                ),
                                        ),
                                        if (job.errorCode != null)
                                          Text(
                                            job.errorCode == 'proRequired'
                                                ? l.backupProRequired
                                                : l.operationFailed,
                                          ),
                                        if (job.state == 'retry' ||
                                            job.state == 'failed')
                                          TextButton(
                                            onPressed: () => ref
                                                .read(fileQueueProvider)
                                                .enqueue(
                                                  source.id,
                                                  job.operation,
                                                ),
                                            child: Text(l.retry),
                                          ),
                                      ];
                                    },
                                  ),
                              if (source.ownerId != null &&
                                  ref
                                          .watch(
                                            sourceAvailableProvider(source),
                                          )
                                          .valueOrNull ==
                                      false)
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      await ref
                                          .read(fileQueueProvider)
                                          .enqueue(source.id, 'download');
                                    } on Object {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(l.operationFailed),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: Text(l.downloadBackup),
                                ),
                              TextButton.icon(
                                icon: const Icon(Icons.delete_outline),
                                label: Text(l.deleteSource),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (dialog) => AlertDialog(
                                      title: Text(l.deleteSource),
                                      content: Text(l.deleteSourceBody),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(dialog, false),
                                          child: Text(l.cancel),
                                        ),
                                        FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(dialog, true),
                                          child: Text(l.delete),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed != true || !context.mounted) {
                                    return;
                                  }
                                  try {
                                    await ref
                                        .read(deletionServiceProvider)
                                        .deleteSource(itemId, source.id);
                                  } on Object {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            SnackBar(
                                              content: Text(l.deletePending),
                                            ),
                                          );
                                    }
                                  }
                                },
                              ),
                              AnalysisPanel(
                                key: ValueKey(
                                  'analysis:${source.id}:${source.revision}',
                                ),
                                source: source,
                              ),
                              if (ref
                                      .watch(sourceAvailableProvider(source))
                                      .valueOrNull ==
                                  false)
                                TextButton(
                                  onPressed: () => showModalBottomSheet<void>(
                                    context: context,
                                    isScrollControlled: true,
                                    showDragHandle: true,
                                    builder: (_) => const AddSheet(),
                                  ),
                                  child: Text(l.reimportSource),
                                ),
                              if (source.pageCount != null &&
                                  source.pageCount! > 10)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Text(l.pdfLimit),
                                ),
                              if (source.textContent != null &&
                                  source.kind != SourceKind.text &&
                                  source.kind != SourceKind.url)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: SelectableText(source.textContent!),
                                ),
                              const SizedBox(height: 12),
                            ],
                          ],
                        ),
                    const Divider(),
                    const SizedBox(height: 20),
                    MatterControls(item: item),
                  ],
                ),
        ),
      ),
    );
  }
}

class SourceViewer extends ConsumerWidget {
  const SourceViewer({super.key, required this.source, this.initialPage});
  final Source source;
  final int? initialPage;
  Future<File?> _file(WidgetRef ref) async {
    final row = await ref.read(sourcesRepositoryProvider).localFile(source.id);
    if (row?.originalRelativePath == null) return null;
    final file = (await ref.read(originalStoreProvider.future))
        .file(row!.originalRelativePath!);
    return await file.exists() ? file : null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    ref.watch(authStateProvider.select((s) => s.valueOrNull?.userId));
    if (source.ownerId != ref.read(authRepositoryProvider).userId) {
      return Scaffold(
        appBar: AppBar(title: Text(l.source)),
        body: Center(child: Text(l.sourceUnavailable)),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(source.originalName)),
      body: source.kind == SourceKind.text || source.kind == SourceKind.url
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: SelectableText(source.textContent ?? ''),
            )
          : FutureBuilder<File?>(
              future: _file(ref),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return Center(child: KiptoProgress(label: l.loading));
                }
                final file = snapshot.data;
                if (file == null) {
                  return KiptoStateView(
                    icon: Icons.file_present_outlined,
                    title: l.sourceUnavailable,
                    message: '',
                  );
                }
                if (source.kind == SourceKind.pdf) {
                  return PdfViewer.file(
                    file.path,
                    initialPageNumber: initialPage ?? 1,
                  );
                }
                return InteractiveViewer(
                  minScale: .5,
                  maxScale: 6,
                  child: Center(
                    child: Image.file(
                      file,
                      cacheWidth:
                          (MediaQuery.sizeOf(context).width *
                                  MediaQuery.devicePixelRatioOf(context) *
                                  2)
                              .round()
                              .clamp(1, 4096),
                      errorBuilder: (_, _, _) => Text(l.captureUnreadable),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
