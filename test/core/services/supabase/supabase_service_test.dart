import 'package:flutter_test/flutter_test.dart';
import 'package:shortly_app/core/services/supabase/index.dart';

void main() {
  group('SupabaseService.pageRange', () {
    test('should return correct range for first page', () {
      final result = SupabaseService.pageRange(0, 10);

      expect(result, (0, 9));
    });

    test('should return correct range for second page', () {
      final result = SupabaseService.pageRange(1, 10);

      expect(result, (10, 19));
    });

    test('should return correct range for third page', () {
      final result = SupabaseService.pageRange(2, 10);

      expect(result, (20, 29));
    });

    test('should return correct range with custom limit', () {
      final result = SupabaseService.pageRange(1, 5);

      expect(result, (5, 9));
    });
  });
}
