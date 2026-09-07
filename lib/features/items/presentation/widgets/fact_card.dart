import 'package:flutter/material.dart';
import 'package:kipto/app/theme/app_tokens.dart';
import 'package:intl/intl.dart';
import 'package:kipto/core/domain/models/fact.dart';
import 'package:kipto/core/domain/models/fact_value.dart';
import 'package:kipto/core/domain/models/temporal_value.dart';
import 'package:kipto/core/presentation/widgets/kipto_ui.dart';
import 'package:kipto/l10n/app_localizations.dart';

String formatFactValue(BuildContext context, FactValue value) {
  final l = AppLocalizations.of(context);
  String date(CalendarDate d) =>
      DateFormat.yMMMd(l.localeName).format(DateTime(d.year, d.month, d.day));
  return switch (value) {
    TextFactValue() => value.text,
    DateFactValue() => value.date == null ? value.raw : date(value.date!),
    DateTimeFactValue() =>
      value.date == null
          ? value.raw
          : [
              date(value.date!),
              if (value.time != null) value.time.toString(),
              if (value.zone != null) value.zone!,
            ].join(' · '),
    MoneyFactValue() =>
      '${value.amount}${value.currency == null ? '' : ' ${value.currency}'}',
    DurationFactValue() =>
      value.unit == CalendarDurationUnit.calendarMonth
          ? l.calendarMonths(value.count)
          : l.calendarDays(value.count),
  };
}

class FactCard extends StatelessWidget {
  const FactCard({super.key, required this.fact, this.onEdit, this.onSource});
  final Fact fact;
  final VoidCallback? onEdit;
  final VoidCallback? onSource;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final value = fact.effectiveValue;
    final temporal = value is DateFactValue || value is DateTimeFactValue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: KiptoGlassSurface(
        blur: false,
        shadow: false,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fact.userValue != null
                  ? l.correctedFact
                  : temporal
                  ? l.detectedDate
                  : l.detectedFact,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            SelectableText(
              formatFactValue(context, value),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (fact.userValue != null) ...[
              const SizedBox(height: 8),
              Text(
                '${l.originalValue}: ${formatFactValue(context, fact.value)}',
              ),
            ],
            if (fact.evidence.quote != null || fact.evidence.page != null)
              ExpansionTile(
                key: PageStorageKey('evidence:${fact.ownerId}:${fact.id}'),
                title: Text(l.evidenceDetails),
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 8),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                expandedAlignment: AlignmentDirectional.centerStart,
                shape: const Border(),
                collapsedShape: const Border(),
                expansionAnimationStyle: AnimationStyle(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : AppDurations.normal,
                  reverseDuration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : AppDurations.normal,
                  curve: Curves.easeInOutCubic,
                ),
                children: [
                  if (fact.evidence.quote != null)
                    SelectableText(
                      '«${fact.evidence.quote}»',
                      // Its internal scroll offset must not share the tile's
                      // boolean expansion entry in PageStorage.
                      key: PageStorageKey('evidence-quote:${fact.id}'),
                    ),
                  if (fact.evidence.page != null)
                    Text(
                      l.pageNumber(fact.evidence.page!),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            if (fact.evidence.verification == EvidenceVerification.unverified ||
                fact.evidence.verification ==
                    EvidenceVerification.visualReference)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l.checkOriginal,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (onEdit != null)
              TextButton(onPressed: onEdit, child: Text(l.edit)),
            if (onSource != null)
              TextButton(onPressed: onSource, child: Text(l.viewEvidence)),
          ],
        ),
      ),
    );
  }
}
