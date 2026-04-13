// Validação aritmética de CPF — mesmo algoritmo usado no backend
// (br.com.ragro.validation.FiscalNumberValidator).
class CpfValidator {
  const CpfValidator._();

  static bool isValid(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11) return false;
    if (RegExp(r'^(\d)\1{10}$').hasMatch(digits)) return false;

    final numbers = digits.split('').map(int.parse).toList();
    final firstCheck = _checkDigit(numbers.sublist(0, 9), 10);
    if (firstCheck != numbers[9]) return false;

    final secondCheck = _checkDigit(numbers.sublist(0, 10), 11);
    return secondCheck == numbers[10];
  }

  static int _checkDigit(List<int> slice, int startWeight) {
    var sum = 0;
    for (var i = 0; i < slice.length; i++) {
      sum += slice[i] * (startWeight - i);
    }
    final remainder = sum % 11;
    return remainder < 2 ? 0 : 11 - remainder;
  }
}
