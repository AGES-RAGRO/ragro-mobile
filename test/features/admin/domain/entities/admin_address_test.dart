import 'package:flutter_test/flutter_test.dart';
import 'package:ragro_mobile/features/admin/domain/entities/admin_address.dart';

void main() {
  group('AdminAddress.toJson — campo neighborhood', () {
    test('inclui neighborhood no JSON quando preenchido', () {
      const address = AdminAddress(
        street: 'Rua das Flores',
        number: '42',
        city: 'São Paulo',
        state: 'SP',
        zipCode: '01234567',
        neighborhood: 'Centro',
      );

      final json = address.toJson();

      expect(json.containsKey('neighborhood'), isTrue);
      expect(json['neighborhood'], 'Centro');
    });

    test('omite neighborhood do JSON quando nulo', () {
      const address = AdminAddress(
        street: 'Rua das Flores',
        number: '42',
        city: 'São Paulo',
        state: 'SP',
        zipCode: '01234567',
      );

      final json = address.toJson();

      expect(json.containsKey('neighborhood'), isFalse);
    });

    test(
      'campos obrigatórios sempre presentes independente do neighborhood',
      () {
        const address = AdminAddress(
          street: 'Rua das Flores',
          number: '42',
          city: 'São Paulo',
          state: 'SP',
          zipCode: '01234567',
          neighborhood: 'Vila Madalena',
        );

        final json = address.toJson();

        expect(json['street'], 'Rua das Flores');
        expect(json['number'], '42');
        expect(json['city'], 'São Paulo');
        expect(json['state'], 'SP');
        expect(json['zipCode'], '01234567');
        expect(json['neighborhood'], 'Vila Madalena');
      },
    );
  });
}
