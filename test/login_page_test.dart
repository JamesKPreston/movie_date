import 'package:flutter_test/flutter_test.dart';
import 'package:movie_date/pages/login_page.dart';

void main() {
  group('Password Validation', () {
    test('returns error when password is null', () {
      final result = validatePassword(null);
      expect(result, 'Password must be at least 6 characters');
    });

    test('returns error when password is empty', () {
      final result = validatePassword('');
      expect(result, 'Password must be at least 6 characters');
    });

    test('returns error when password is less than 6 characters', () {
      final result = validatePassword('12345');
      expect(result, 'Password must be at least 6 characters');
    });

    test('returns error when password is exactly 5 characters', () {
      final result = validatePassword('abcde');
      expect(result, 'Password must be at least 6 characters');
    });

    test('returns null (valid) when password is exactly 6 characters', () {
      final result = validatePassword('abcdef');
      expect(result, null);
    });

    test('returns null (valid) when password is more than 6 characters', () {
      final result = validatePassword('password123');
      expect(result, null);
    });
  });
}
