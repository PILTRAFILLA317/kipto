import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/dev/seed/development_seed.dart';

import 'test_helpers.dart';

void main() {
  test('development seed is idempotent', () async {
    final database = createTestDatabase();
    addTearDown(database.close);
    final seed = DevelopmentSeed(
      database,
      clock: Clock.fixed(DateTime.utc(2026, 8, 29, 12)),
    );

    await seed.run();
    await seed.run();

    expect((await database.savedItemsDao.getActive()).length, 10);
    expect(
      (await database.remindersDao
              .watchForSavedItem(DevelopmentSeed.conversationId)
              .first)
          .length,
      1,
    );
  });
}
