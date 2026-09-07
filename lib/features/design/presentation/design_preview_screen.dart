import 'package:kipto/core/domain/models/fact.dart';
import 'package:kipto/core/domain/models/fact_value.dart';
import 'package:kipto/core/domain/models/temporal_value.dart';
import 'package:kipto/features/items/presentation/widgets/fact_card.dart';
import 'package:flutter/material.dart';
import 'package:kipto/app/shell/main_shell.dart';
import 'package:kipto/core/presentation/widgets/kipto_ui.dart';
import 'package:kipto/core/presentation/widgets/life_admin_card.dart';
import 'package:kipto/features/capture/presentation/add_sheet.dart';
import 'package:kipto/l10n/app_localizations.dart';

class DesignPreviewScreen extends StatelessWidget {
  const DesignPreviewScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.preview)),
      body: KiptoBackground(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              l.outOfYourHead,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 24),
            LifeAdminCard(
              title: l.previewTitle,
              status: l.toReview,
              subtitle: l.previewDate,
              hero: true,
              actionLabel: l.review,
              onTap: () => showAddSheet(context),
            ),
            const SizedBox(height: 16),
            LifeAdminCard(
              title: l.previewSecondTitle,
              status: l.upcoming,
              subtitle: l.previewSecondDate,
              icon: Icons.event_outlined,
            ),
            const SizedBox(height: 24),
            Text(
              l.previewError,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 24),
            FactCard(
              fact: Fact(
                id: 'debug-fact',
                itemId: 'debug-item',
                sourceId: 'debug-source',
                sourceRevision: 1,
                key: 'renewal_date',
                value: DateFactValue(
                  date: CalendarDate(2026, 10, 14),
                  raw: '14/10/2026',
                ),
                userValue: DateFactValue(
                  date: CalendarDate(2026, 10, 15),
                  raw: '15/10/2026',
                ),
                provenance: FactProvenance.extracted,
                evidence: FactEvidence(
                  page: 1,
                  quote: '14/10/2026',
                  verification: EvidenceVerification.visualReference,
                ),
                createdAt: DateTime.utc(2026, 9, 5),
                updatedAt: DateTime.utc(2026, 9, 5),
              ),
            ),
            const SizedBox(height: 24),
            KiptoBottomDock(
              selectedIndex: 0,
              onSelected: (_) {},
              onAdd: () => showAddSheet(context),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => showAddSheet(context),
              child: Text(l.add),
            ),
          ],
        ),
      ),
    );
  }
}
