/// Traduz o `unityType` retornado pelo backend para a forma curta em
/// português usada na UI.
///
/// Backend (products.unity_type): `kg | g | unit | box | liter | ml | dozen`.
/// Mapeamento:
///   - kg / g / ml  → mantém (já universais em pt-BR)
///   - unit         → un
///   - box          → cx
///   - liter        → L
///   - dozen        → dz
///
/// Valores desconhecidos são retornados como vieram. Strings vazias retornam
/// vazias (caller decide se mostra ou não).
String localizeUnityType(String unityType) {
  switch (unityType.toLowerCase().trim()) {
    case '':
      return '';
    case 'kg':
      return 'kg';
    case 'g':
      return 'g';
    case 'ml':
      return 'ml';
    case 'unit':
      return 'unidade';
    case 'box':
      return 'caixa';
    case 'liter':
      return 'litro';
    case 'dozen':
      return 'dúzia';
    default:
      return unityType;
  }
}
