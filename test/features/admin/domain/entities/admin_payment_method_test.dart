import 'package:flutter_test/flutter_test.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_payment_method.dart';

void main() {
  group('AdminPaymentMethod.toJson', () {
    test('PIX — serializa apenas campos não nulos', () {
      const pm = AdminPaymentMethod(
        type: 'pix',
        pixKeyType: 'email',
        pixKey: 'joao@example.com',
      );
      final json = pm.toJson();
      expect(json['type'], 'pix');
      expect(json['pixKeyType'], 'email');
      expect(json['pixKey'], 'joao@example.com');
      expect(json.containsKey('bankName'), isFalse);
      expect(json.containsKey('agency'), isFalse);
    });

    test('bank_account — serializa apenas campos bancários', () {
      const pm = AdminPaymentMethod(
        type: 'bank_account',
        bankName: 'Banco do Brasil',
        agency: '1234',
        accountNumber: '56789-0',
        accountType: 'checking',
        holderName: 'João Silva',
        fiscalNumber: '52998224725',
      );
      final json = pm.toJson();
      expect(json['type'], 'bank_account');
      expect(json['bankName'], 'Banco do Brasil');
      expect(json['agency'], '1234');
      expect(json['accountNumber'], '56789-0');
      expect(json['accountType'], 'checking');
      expect(json['holderName'], 'João Silva');
      expect(json['fiscalNumber'], '52998224725');
      expect(json.containsKey('pixKeyType'), isFalse);
      expect(json.containsKey('pixKey'), isFalse);
    });

    test('bankCode nulo não aparece no JSON', () {
      const pm = AdminPaymentMethod(type: 'bank_account', bankName: 'BB');
      expect(pm.toJson().containsKey('bankCode'), isFalse);
    });
  });
}
