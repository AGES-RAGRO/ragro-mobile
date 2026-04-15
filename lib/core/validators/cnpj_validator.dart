// Validação aritmética de CNPJ — algoritmo mod 11 com pesos oficiais.
// Espelha a lógica do backend (br.com.ragro.validation.FiscalNumberValidator).
class CnpjValidator {
  const CnpjValidator._();

  static bool isValid(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 14) return false;
    if (RegExp(r'^(\d)\1{13}$').hasMatch(digits)) return false;

    final numbers = digits.split('').map(int.parse).toList();
    final first = _checkDigit(numbers.sublist(0, 12), const [
      5,
      4,
      3,
      2,
      9,
      8,
      7,
      6,
      5,
      4,
      3,
      2,
    ]);
    if (first != numbers[12]) return false;
    final second = _checkDigit(numbers.sublist(0, 13), const [
      6,
      5,
      4,
      3,
      2,
      9,
      8,
      7,
      6,
      5,
      4,
      3,
      2,
    ]);
    return second == numbers[13];
  }

  static int _checkDigit(List<int> slice, List<int> weights) {
    var sum = 0;
    for (var i = 0; i < slice.length; i++) {
      sum += slice[i] * weights[i];
    }
    final remainder = sum % 11;
    return remainder < 2 ? 0 : 11 - remainder;
  }
}
