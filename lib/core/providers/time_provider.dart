import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentTimeProvider = Provider<DateTime>((_) => DateTime.now().toUtc());
