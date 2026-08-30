import 'package:kipto/core/domain/enums/saved_item_enums.dart';

enum LibrarySort { newest, oldest, expiringSoon, recentlyUpdated }

final class LibraryFilter {
  const LibraryFilter({
    this.category,
    this.status,
    this.analysisStatus,
    this.favoriteOnly = false,
  });

  final SavedItemCategory? category;
  final SavedItemStatus? status;
  final AnalysisStatus? analysisStatus;
  final bool favoriteOnly;

  bool get isActive =>
      category != null ||
      status != null ||
      analysisStatus != null ||
      favoriteOnly;

  LibraryFilter copyWith({
    SavedItemCategory? category,
    SavedItemStatus? status,
    AnalysisStatus? analysisStatus,
    bool? favoriteOnly,
    bool clearCategory = false,
    bool clearStatus = false,
    bool clearAnalysisStatus = false,
  }) => LibraryFilter(
    category: clearCategory ? null : category ?? this.category,
    status: clearStatus ? null : status ?? this.status,
    analysisStatus: clearAnalysisStatus
        ? null
        : analysisStatus ?? this.analysisStatus,
    favoriteOnly: favoriteOnly ?? this.favoriteOnly,
  );

  @override
  bool operator ==(Object other) =>
      other is LibraryFilter &&
      other.category == category &&
      other.status == status &&
      other.analysisStatus == analysisStatus &&
      other.favoriteOnly == favoriteOnly;

  @override
  int get hashCode =>
      Object.hash(category, status, analysisStatus, favoriteOnly);
}

final class LibraryQuery {
  const LibraryQuery({
    this.filter = const LibraryFilter(),
    this.sort = LibrarySort.newest,
  });

  final LibraryFilter filter;
  final LibrarySort sort;

  @override
  bool operator ==(Object other) =>
      other is LibraryQuery && other.filter == filter && other.sort == sort;

  @override
  int get hashCode => Object.hash(filter, sort);
}

final class LibraryCounts {
  const LibraryCounts({
    required this.total,
    required this.byCategory,
    required this.unprocessed,
  });

  final int total;
  final Map<SavedItemCategory, int> byCategory;
  final int unprocessed;
}
