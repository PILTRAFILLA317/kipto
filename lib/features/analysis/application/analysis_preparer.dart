import 'package:kipto/features/analysis/domain/analysis_failure.dart';
export 'package:kipto/features/analysis/domain/analysis_failure.dart';

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:kipto/core/domain/models/source.dart';
import 'package:kipto/core/files/original_store.dart';
import 'package:kipto/core/repositories/drift_sources_repository.dart';

class AnalysisPreparer {
  const AnalysisPreparer(this.sources, this.store);
  final DriftSourcesRepository sources;
  final OriginalStore store;

  Future<Map<String, Object?>> prepare(Source source) async {
    if (source.kind == SourceKind.text || source.kind == SourceKind.url) {
      final text = source.textContent ?? '';
      if (text.trim().isEmpty) throw const AnalysisFailure('unreadable');
      if (text.length > 60000) throw const AnalysisFailure('tooLarge');
      return _input(
        textPages: [
          {'page': 1, 'text': text},
        ],
        pages: 1,
      );
    }
    final local = await sources.localFile(source.id);
    if (local?.originalRelativePath == null) {
      throw const AnalysisFailure('originalUnavailable');
    }
    final file = store.file(local!.originalRelativePath!);
    if (!await file.exists()) {
      throw const AnalysisFailure('originalUnavailable');
    }
    final root = await store.root.resolveSymbolicLinks();
    if (!(await file.resolveSymbolicLinks()).startsWith(
          '$root${Platform.pathSeparator}',
        ) ||
        await file.length() != source.byteSize ||
        (await sha256.bind(file.openRead()).first).toString() !=
            source.contentHash) {
      throw const AnalysisFailure('invalidSource');
    }
    try {
      if (source.kind == SourceKind.image) {
        // The platform decoder applies encoded orientation. Re-encoding strips
        // metadata and produces a supported format without changing the original.
        final buffer = await ui.ImmutableBuffer.fromFilePath(file.path);
        try {
          final descriptor = await ui.ImageDescriptor.encoded(buffer);
          try {
            if (descriptor.width * descriptor.height > 40000000) {
              throw const AnalysisFailure('tooLarge');
            }
            final scale = math.min(
              1.0,
              1600 / math.max(descriptor.width, descriptor.height),
            );
            final codec = await descriptor.instantiateCodec(
              targetWidth: math.max(1, (descriptor.width * scale).round()),
              targetHeight: math.max(1, (descriptor.height * scale).round()),
            );
            try {
              final image = (await codec.getNextFrame()).image;
              try {
                return _input(
                  imagePages: [await _imagePage(image, 1)],
                  pages: 1,
                );
              } finally {
                image.dispose();
              }
            } finally {
              codec.dispose();
            }
          } finally {
            descriptor.dispose();
          }
        } finally {
          buffer.dispose();
        }
      }
      final pdf = await PdfDocument.openFile(
        file.path,
        passwordProvider: () async => null,
      );
      try {
        if (pdf.isEncrypted || pdf.pages.isEmpty) {
          throw const AnalysisFailure('unreadable');
        }
        if (pdf.pages.length > 10) throw const AnalysisFailure('tooManyPages');
        final texts = <Map<String, Object?>>[];
        var characters = 0;
        var allText = true;
        for (final page in pdf.pages) {
          final text = (await page.loadText())?.fullText ?? '';
          characters += text.length;
          if (characters > 60000) throw const AnalysisFailure('tooLarge');
          if (text.trim().length < 40) allText = false;
          texts.add({'page': page.pageNumber, 'text': text});
        }
        if (allText) return _input(textPages: texts, pages: pdf.pages.length);
        // Mixed/scanned documents use one uniform visual input. Dispose each
        // raster before rendering the next page and bound the encoded aggregate.
        final images = <Map<String, Object?>>[];
        var encodedSize = 0;
        for (final page in pdf.pages) {
          final scale = 1200 / math.max(page.width, page.height);
          final rendered = await page.render(
            fullWidth: page.width * scale,
            fullHeight: page.height * scale,
          );
          if (rendered == null) throw const AnalysisFailure('unreadable');
          try {
            final image = await rendered.createImage();
            try {
              final encoded = await _imagePage(image, page.pageNumber);
              encodedSize += (encoded['base64'] as String).length;
              if (encodedSize > 7 * 1024 * 1024) {
                throw const AnalysisFailure('tooLarge');
              }
              images.add(encoded);
            } finally {
              image.dispose();
            }
          } finally {
            rendered.dispose();
          }
        }
        return _input(imagePages: images, pages: pdf.pages.length);
      } finally {
        await pdf.dispose();
      }
    } on AnalysisFailure {
      rethrow;
    } on Object {
      throw const AnalysisFailure('unreadable');
    }
  }

  static Future<Map<String, Object?>> _imagePage(
    ui.Image image,
    int page,
  ) async {
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) throw const AnalysisFailure('unreadable');
    final encoded = base64Encode(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
    );
    if (encoded.length > 7 * 1024 * 1024) {
      throw const AnalysisFailure('tooLarge');
    }
    return {'page': page, 'mimeType': 'image/png', 'base64': encoded};
  }

  static Map<String, Object?> _input({
    List<Map<String, Object?>> textPages = const [],
    List<Map<String, Object?>> imagePages = const [],
    required int pages,
  }) => {
    'input': {
      'type': imagePages.isEmpty ? 'text' : 'imagePages',
      'textPages': textPages,
      'imagePages': imagePages,
    },
    'coverage': {
      'totalPagesKnown': pages,
      'analyzedPages': List.generate(pages, (i) => i + 1),
      'isPartial': false,
    },
  };
}
