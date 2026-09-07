import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kipto/app/theme/app_tokens.dart';
import 'package:kipto/core/presentation/widgets/kipto_ui.dart';
import 'package:kipto/features/analysis/domain/analysis_contract.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:kipto/core/domain/models/source.dart';
import 'package:kipto/core/providers/sync_providers.dart';
import 'package:kipto/features/analysis/application/analysis_preparer.dart';
import 'package:kipto/features/analysis/presentation/analysis_providers.dart';
import 'package:kipto/features/settings/application/privacy_preferences.dart';
import 'package:kipto/l10n/app_localizations.dart';

String analysisErrorText(AppLocalizations l, String? code) => switch (code) {
  'tooManyPages' => l.analysisTooManyPages,
  'tooLarge' => l.analysisTooLarge,
  'unreadable' ||
  'originalUnavailable' ||
  'invalidSource' => l.analysisUnreadable,
  'network' || 'busy' || 'providerRateLimited' => l.analysisNetwork,
  'quotaBlocked' || 'globalLimit' => l.analysisQuota,
  'authenticationRequired' => l.analysisSession,
  'configurationUnavailable' || 'serviceUnavailable' => l.analysisConfiguration,
  'indeterminate' ||
  'providerIndeterminate' ||
  'expired' => l.analysisIndeterminate,
  'stale' => l.analysisStale,
  'consentRequired' => l.analysisPaused,
  _ => l.analysisInvalid,
};

class AnalysisPanel extends ConsumerStatefulWidget {
  const AnalysisPanel({super.key, required this.source});
  final Source source;
  @override
  ConsumerState<AnalysisPanel> createState() => _AnalysisPanelState();
}

class _AnalysisPanelState extends ConsumerState<AnalysisPanel> {
  bool _busy = false;
  String? _error;
  Future<bool> _confirm(String title, String body, String accept) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: Text(body)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(accept),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _start({required bool repeat, required bool retry}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final l = AppLocalizations.of(context);
    try {
      if (!ref.read(appConfigProvider).isCloudConfigured) {
        throw const AnalysisFailure('configurationUnavailable');
      }
      if (!ref.read(privacyPreferencesProvider).analysis ||
          ref.read(authRepositoryProvider).userId == null) {
        if (!await _confirm(
          l.analysisConsentTitle,
          l.analysisConsentBody,
          l.analyze,
        )) {
          return;
        }
        if (!mounted) return;
        final auth = ref.read(authRepositoryProvider);
        final session = await auth.ensureSession();
        if (!mounted) return;
        if (session == null) {
          throw const AnalysisFailure('authenticationRequired');
        }
        await ref
            .read(localSyncCoordinatorProvider)
            .claimLocalOnlyData(session.user.id);
        if (!mounted) return;
        ref.invalidate(privacyPreferencesProvider);
        await ref
            .read(privacyPreferencesProvider.notifier)
            .update(analysis: true);
      }
      if (!mounted) return;
      if (repeat &&
          !retry &&
          !await _confirm(
            l.analysisNewRequestTitle,
            l.analysisNewRequestBody,
            l.analyzeAgain,
          )) {
        return;
      }
      if (!mounted) return;
      final queue = ref.read(analysisQueueProvider);
      if (retry) {
        await queue.retry(widget.source.id);
        return;
      }
      final zone = (await FlutterTimezone.getLocalTimezone()).identifier;
      if (!mounted) return;
      await queue.enqueue(
        widget.source.id,
        locale: l.localeName,
        timeZone: zone,
      );
    } on Object catch (error) {
      if (mounted) {
        setState(
          () => _error = error is AnalysisFailure
              ? error.code
              : 'serviceUnavailable',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    ref.watch(authStateProvider.select((s) => s.valueOrNull?.userId));
    final owner = ref.read(authRepositoryProvider).userId;
    if (widget.source.ownerId != owner || widget.source.deletedAt != null) {
      return const SizedBox.shrink();
    }
    final jobAsync = ref.watch(analysisJobProvider(widget.source.id));
    final rawJob = jobAsync.valueOrNull;
    final job =
        rawJob?.ownerId == owner &&
            rawJob?.revision == widget.source.revision &&
            rawJob?.sourceId == widget.source.id &&
            !jobAsync.hasError
        ? rawJob
        : null;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final active = const {'queued', 'running', 'retry'}.contains(job?.state);
    final retryable =
        job?.state == 'failed' &&
        const {
          'network',
          'busy',
          'providerRateLimited',
          'serviceUnavailable',
          'authenticationRequired',
        }.contains(job?.errorCode);
    AnalysisOutput? output;
    if (job?.state == 'done' && job?.envelope != null) {
      try {
        final raw = Map<String, dynamic>.from(
          (jsonDecode(job!.envelope!) as Map)['output'] as Map,
        );
        final coverage = raw['coverage'] as Map;
        final pages = (coverage['analyzedPages'] as List).cast<int>();
        if (widget.source.pageCount != null &&
            pages.any((page) => page > widget.source.pageCount!)) {
          throw const FormatException('Coverage outside source');
        }
        // The queue verified request/evidence before storing this envelope.
        // Reuse its typed contract here so corrupt local fields cannot crash UI.
        output = AnalysisOutput.parse(
          raw,
          expectedRevision: widget.source.revision,
          expectedPages: widget.source.kind == SourceKind.pdf ? pages : [1],
          expectedPartial: coverage['isPartial'] as bool,
          imageInput: widget.source.kind == SourceKind.image,
        );
      } on Object {
        // Display an explicit invalid-result state, never a false ready state.
      }
    }
    final invalidStored =
        rawJob != null && job == null || job?.state == 'done' && output == null;
    final content = output != null
        ? Column(
            key: ValueKey(job!.requestId),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Text(
                l.analysisReviewTitle,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(output.title),
              if (output.summary.isNotEmpty) Text(output.summary),
              if (output.isPartial) Text(l.analysisPartial),
              Text(
                l.analysisCoverage,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              for (final warning in output.warnings) Text(warning),
              for (final fact in output.facts)
                if (fact.uncertainty != null)
                  Text('${l.analysisUncertainty}: ${fact.uncertainty}'),
              if (output.suggestions.isEmpty) Text(l.analysisNoActions),
            ],
          )
        : job?.state == 'running'
        ? Column(
            key: const ValueKey('analysis-running'),
            children: [
              const SizedBox(height: 8),
              const KiptoSkeleton(height: 84),
              if (!reduced) ...[
                const SizedBox(height: 8),
                const LinearProgressIndicator(),
              ],
            ],
          )
        : const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (jobAsync.hasError || invalidStored || job != null)
            Semantics(
              liveRegion: true,
              child: Text(
                jobAsync.hasError
                    ? l.localError
                    : invalidStored
                    ? l.analysisInvalid
                    : switch (job!.state) {
                        'running' => l.analysisRunning,
                        'retry' => l.analysisRetry,
                        'done' => l.analysisReady,
                        'queued' => l.analysisQueued,
                        _ => analysisErrorText(l, job.errorCode),
                      },
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          if (active && !ref.watch(privacyPreferencesProvider).analysis)
            Text(l.analysisPaused),
          if (reduced)
            content
          else
            AnimatedSwitcher(
              key: ValueKey((owner, widget.source.id, widget.source.revision)),
              duration: AppDurations.normal,
              // Never retain an old result or its semantics during transition.
              layoutBuilder: (current, previous) =>
                  current ?? const SizedBox.shrink(),
              child: content,
            ),
          if (widget.source.kind != SourceKind.text &&
              widget.source.kind != SourceKind.url &&
              widget.source.textContent?.isNotEmpty == true)
            Text(
              l.analysisContextOmitted,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (_error != null)
            Text(
              analysisErrorText(l, _error),
              semanticsLabel: analysisErrorText(l, _error),
            ),
          if (!active)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton.icon(
                onPressed: _busy || jobAsync.isLoading || jobAsync.hasError
                    ? null
                    : () => _start(repeat: job != null, retry: retryable),
                icon: const Icon(Icons.auto_awesome_outlined),
                label: Text(
                  retryable
                      ? l.retry
                      : job == null
                      ? l.analyze
                      : l.analyzeAgain,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
