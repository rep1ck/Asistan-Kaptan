import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Gece modu — main/settings arasında döngüsel import olmasın diye ayrı dosya.
final nightModeProvider = StateProvider<bool>((ref) => false);
