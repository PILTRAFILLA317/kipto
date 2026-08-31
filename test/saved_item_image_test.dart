import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/core/presentation/widgets/saved_item_image.dart';
import 'package:kipto/features/cloud_preview/presentation/cloud_preview_providers.dart';
import 'package:kipto/features/photo_library/domain/photo_library_models.dart';
import 'package:kipto/features/photo_library/presentation/providers/photo_library_providers.dart';

import 'fakes/fake_photo_library_repository.dart';
import 'test_helpers.dart';

void main() {
  final png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
  );

  testWidgets('local original wins without requesting cloud preview', (
    tester,
  ) async {
    final photos = FakePhotoLibraryRepository()
      ..setThumbnail(
        'asset-a',
        LocalAssetThumbnailData(bytes: png, width: 1, height: 1),
      );
    addTearDown(photos.dispose);
    final item = testSavedItem(
      id: 'item-a',
      now: DateTime.utc(2026, 8, 30),
      localAssetId: 'asset-a',
      originalAvailable: true,
    ).copyWithCloudPath('user-a/item-a/preview-v1.jpg');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          photoLibraryRepositoryProvider.overrideWithValue(photos),
          resolvedCloudPreviewProvider((
            savedItemId: item.id,
            cloudPath: 'user-a/item-a/preview-v1.jpg',
          )).overrideWith((ref) => throw StateError('cloud must not load')),
        ],
        child: MaterialApp(
          home: Scaffold(body: SavedItemImage(item: item)),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cloud preview renders when original is unavailable', (
    tester,
  ) async {
    final file = File(
      'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png',
    ).absolute;
    final item = testSavedItem(
      id: 'item-cloud',
      now: DateTime.utc(2026, 8, 30),
    ).copyWithCloudPath('user-a/item-cloud/preview-v1.jpg');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          resolvedCloudPreviewProvider((
            savedItemId: item.id,
            cloudPath: item.cloudPreviewPath!,
          )).overrideWith((ref) async => file.path),
        ],
        child: MaterialApp(
          home: Scaffold(body: SavedItemImage(item: item)),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.broken_image_outlined), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets('placeholder renders when neither image source exists', (
    tester,
  ) async {
    final item = testSavedItem(
      id: 'item-empty',
      now: DateTime.utc(2026, 8, 30),
    );
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: SavedItemImage(item: item)),
        ),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
  });
}
