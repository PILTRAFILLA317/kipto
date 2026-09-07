import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/database/app_database.dart';
import 'package:kipto/core/files/original_store.dart';
import 'package:kipto/core/repositories/drift_sources_repository.dart';
import 'package:kipto/core/sync/local_sync_coordinator.dart';
import 'package:kipto/features/capture/application/capture_service.dart';
import 'package:kipto/features/capture/application/shared_manifest.dart';

import 'test_support.dart';

const delivery = '05c9bb31-b671-4538-8bcd-f6bd7837fc22';
const sourceA = '971691c4-4d96-4786-bff6-94c9f128e61a';
const sourceB = '91d72b73-c829-49d9-befb-471d8d3b9c10';
final png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAAAAAA6fptVAAAACklEQVR4nGNoAAAAggCBd81ytgAAAABJRU5ErkJggg==',
);
Map<String, Object?> packet({List<String> ids = const [sourceA, sourceB]}) => {
  'manifestVersion': 1,
  'state': 'ready',
  'captureId': delivery,
  'accountScopeId': testUser.id,
  'contextText': 'Context supplied by sender',
  'attachments': [
    for (final id in ids)
      {
        'sourceId': id,
        'relativePath': '$delivery/$id',
        'mimeType': 'image/png',
        'originalName': 'synthetic.png',
        'byteSize': png.length,
      },
  ],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory root;
  late AppDatabase db;
  late CaptureService capture;
  late DriftSourcesRepository sources;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('kipto-shared-');
    db = AppDatabase(NativeDatabase.memory());
    sources = DriftSourcesRepository(
      db,
      LocalSyncCoordinator(
        database: db,
        auth: TestAuthRepository(),
        onLocalChange: () {},
      ),
    );
    capture = CaptureService(
      files: OriginalStore(Directory('${root.path}/originals')),
      sources: sources,
      scope: () async => testUser.id,
    );
    await Directory('${root.path}/$delivery').create();
    for (final id in [sourceA, sourceB]) {
      await File('${root.path}/$delivery/$id').writeAsBytes(png);
    }
  });
  tearDown(() async {
    await db.close();
    await root.delete(recursive: true);
  });

  test(
    'T05 repeated batch uses two stable sources and retains accompanying text',
    () async {
      final manifest = SharedManifest.parse(jsonEncode(packet()));
      final importer = SharedManifestImporter(root, capture);
      for (var attempt = 0; attempt < 2; attempt++) {
        expect(await importer.import(manifest, scope: testUser.id), [
          sourceA,
          sourceB,
        ]);
      }
      expect(await db.select(db.items).get(), hasLength(2));
      expect(await db.select(db.sources).get(), hasLength(2));
      final source = (await sources.find(sourceA))!;
      expect(source.mimeType, 'image/png');
      expect(source.textContent, 'Context supplied by sender');
      expect(await capture.files.file('$sourceA/original').readAsBytes(), png);
      expect(await File('${root.path}/$delivery/$sourceA').exists(), isTrue);
    },
  );

  test('T06 incomplete, foreign scope, traversal, symlink and MIME mismatch reject before any commit', () async {
    final cases = <Map<String, Object?>>[
      {...packet(), 'state': 'writing'},
      {...packet(), 'accountScopeId': 'another-owner'},
      packet()
        ..['attachments'] = [
          {
            'sourceId': sourceA,
            'relativePath': '../$delivery/$sourceA',
            'mimeType': 'image/png',
            'originalName': 'x',
            'byteSize': png.length,
          },
        ],
      packet()
        ..['attachments'] = [
          {
            'sourceId': sourceA,
            'relativePath': '$delivery/$sourceA',
            'mimeType': 'application/pdf',
            'originalName': 'x',
            'byteSize': png.length,
          },
        ],
      packet()
        ..['attachments'] = List.filled(
          6,
          (packet()['attachments'] as List).first,
        ),
    ];
    for (final data in cases) {
      await expectLater(
        Future(
          () async => SharedManifestImporter(
            root,
            capture,
          ).import(SharedManifest.parse(jsonEncode(data)), scope: testUser.id),
        ),
        throwsA(isA<CaptureFailure>()),
      );
      expect(await db.select(db.items).get(), isEmpty);
    }
    await File('${root.path}/$delivery/$sourceB').delete();
    await expectLater(
      SharedManifestImporter(
        root,
        capture,
      ).import(SharedManifest.parse(jsonEncode(packet())), scope: testUser.id),
      throwsA(isA<CaptureFailure>()),
    );
    expect(await db.select(db.items).get(), isEmpty);
    final outside = await Directory.systemTemp.createTemp('kipto-outside-');
    addTearDown(() => outside.delete(recursive: true));
    final externalFile = await File('${outside.path}/private')
        .writeAsBytes(png);
    await Link('${root.path}/$delivery/$sourceB').create(externalFile.path);
    await expectLater(
      SharedManifestImporter(
        root,
        capture,
      ).import(SharedManifest.parse(jsonEncode(packet())), scope: testUser.id),
      throwsA(isA<CaptureFailure>()),
    );
    expect(await db.select(db.items).get(), isEmpty);
  });

  test(
    'T06 iOS saved imports once; drafts and other accounts remain staged',
    () async {
      final folder = Directory('${root.path}/$delivery');
      final data = {
        ...packet(ids: [sourceA]),
        'platform': 'ios',
        'title': 'Mi documento',
      };
      final draft = File('${folder.path}/draft.json');
      await draft.writeAsString(jsonEncode(data));
      expect((await readSharedPackages(root)).single.confirmed, isFalse);
      expect(
        await importConfirmedSharedPackages(root, capture, testUser.id),
        0,
      );
      expect(await db.select(db.items).get(), isEmpty);
      final ready = File('${folder.path}/manifest.json');
      await ready.writeAsString(
        jsonEncode({...data, 'accountScopeId': 'another-owner'}),
      );
      expect(
        await importConfirmedSharedPackages(root, capture, testUser.id),
        0,
      );
      expect(await db.select(db.items).get(), isEmpty);
      await ready.writeAsString(jsonEncode(data));
      expect(
        await importConfirmedSharedPackages(root, capture, testUser.id),
        0,
      );
      expect((await db.select(db.items).get()).single.title, 'Mi documento');
      expect(await folder.exists(), isFalse);
      expect(
        await importConfirmedSharedPackages(root, capture, testUser.id),
        0,
      );
      expect(await db.select(db.items).get(), hasLength(1));
    },
  );

  test('a malformed delivery does not hide a ready one', () async {
    await File('${root.path}/$delivery/manifest.json')
        .writeAsString(jsonEncode(packet()));
    final bad = await Directory('${root.path}/$sourceA').create();
    await File('${bad.path}/manifest.json').writeAsString('{');
    final packages = await readSharedPackages(root);
    expect(packages, hasLength(2));
    expect(packages.first.manifest!.id, delivery);
    expect(packages.last.manifest, isNull);
  });

  test('oversized stream never publishes a capture; malformed receipt does not stop recovery', () async {
    await expectLater(
      capture.files.persist(
        captureId: sourceA,
        scope: testUser.id,
        name: 'x.png',
        origin: 'shareSheet',
        bytes: Stream.fromIterable(
          List.generate(21, (_) => Uint8List(1024 * 1024)),
        ),
      ),
      throwsA(isA<CaptureFailure>()),
    );
    expect(
      await File('${capture.files.root.path}/$sourceA/ready.json').exists(),
      isFalse,
    );
    await File('${capture.files.root.path}/$sourceA/ready.json')
        .writeAsString('{');
    await capture.files.persist(
      captureId: sourceB,
      scope: testUser.id,
      name: 'valid.png',
      origin: 'shareSheet',
      bytes: Stream.value(png),
    );
    expect(
      (await capture.files.recover(testUser.id)).single.captureId,
      sourceB,
    );
    expect(capture.files.recoveryFailures, [sourceA]);
  });

  test(
    'one-page synthetic PDF survives durable storage and reopening',
    () async {
      final bytes = await File('test/fixtures/one-page.pdf').readAsBytes();
      final original = await capture.files.persist(
        captureId: sourceA,
        scope: testUser.id,
        name: 'invoice.pdf',
        origin: 'systemPicker',
        bytes: Stream.value(bytes),
      );
      expect(original.mime, 'application/pdf');
      final reopened = OriginalStore(capture.files.root);
      expect((await reopened.recover(testUser.id)).single.hash, original.hash);
      expect(await reopened.file(original.relativePath).readAsBytes(), bytes);
    },
  );

  test(
    'scope changes during copy prevent a commit into another account',
    () async {
      var calls = 0;
      final racing = CaptureService(
        files: capture.files,
        sources: sources,
        scope: () async => calls++ == 0 ? testUser.id : 'another-owner',
      );
      await expectLater(
        racing.importFile(
          captureId: sourceA,
          file: File('${root.path}/$delivery/$sourceA'),
          name: 'x.png',
          expectedScope: testUser.id,
        ),
        throwsA(isA<CaptureFailure>()),
      );
      expect(await db.select(db.items).get(), isEmpty);
      expect(await capture.files.file('$sourceA/original').exists(), isTrue);
    },
  );
}
