import 'package:flutter_test/flutter_test.dart';
import 'package:kipto/features/photo_library/data/photo_manager_photo_library_repository.dart';
import 'package:kipto/features/photo_library/domain/photo_library_models.dart';
import 'package:photo_manager/photo_manager.dart';

void main() {
  test('maps every relevant photo_manager permission state to domain', () {
    expect(
      PhotoManagerPhotoLibraryRepository.mapPermissionState(
        PermissionState.authorized,
      ),
      PhotoAccessStatus.authorized,
    );
    expect(
      PhotoManagerPhotoLibraryRepository.mapPermissionState(
        PermissionState.limited,
      ),
      PhotoAccessStatus.limited,
    );
    expect(
      PhotoManagerPhotoLibraryRepository.mapPermissionState(
        PermissionState.denied,
      ),
      PhotoAccessStatus.denied,
    );
    expect(
      PhotoManagerPhotoLibraryRepository.mapPermissionState(
        PermissionState.restricted,
      ),
      PhotoAccessStatus.restricted,
    );
    expect(
      PhotoManagerPhotoLibraryRepository.mapPermissionState(
        PermissionState.notDetermined,
      ),
      PhotoAccessStatus.notDetermined,
    );
  });
}
