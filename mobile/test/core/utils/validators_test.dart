import 'package:flutter_test/flutter_test.dart';
import 'package:vewra_mobile/core/utils/validators.dart';

void main() {
  group('Validators', () {
    test('email validation passes valid email and fails invalid email', () {
      expect(Validators.email('test@vewra.io'), isNull);
      expect(Validators.email('invalid-email'), isNotNull);
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
    });

    test('password validation requires minimum 6 characters', () {
      expect(Validators.password('123456'), isNull);
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password(''), isNotNull);
    });

    test('confirmPassword checks equality', () {
      expect(Validators.confirmPassword('secret123', 'secret123'), isNull);
      expect(Validators.confirmPassword('secret123', 'otherpass'), isNotNull);
    });

    test('username validation requires minimum 3 characters', () {
      expect(Validators.username('alex'), isNull);
      expect(Validators.username('al'), isNotNull);
    });
  });
}
