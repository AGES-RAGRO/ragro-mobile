/// Traduz o `unityType` retornado pelo backend para a forma curta em
/// português usada na UI.
///
/// Backend (products.unity_type): `kg | g | un | maço | pacote | box | liter |
/// ml | dozen`.
/// Mapeamento:
///   - kg / g / ml / maço  → mantém (já curtos em pt-BR)
///   - un / unit           → un
///   - pacote              → pct
///   - box                 → caixa
///   - liter               → L
///   - dozen               → dz
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
    case 'un':
      return 'un';
    case 'maço':
      return 'maço';
    case 'pacote':
    case 'pct':
      return 'pct';
    case 'box':
    case 'cx':
      return 'caixa';
    case 'liter':
    case 'l':
      return 'L';
    case 'dozen':
    case 'dz':
      return 'dz';
    default:
      return unityType;
  }
}

/// Rótulo completo em português para SELEÇÃO de unidade (ex.: dropdown do
/// cadastro de produto). O valor submetido continua sendo o código do backend
/// (kg, liter, box, dozen…); só o texto exibido muda. Desconhecidos voltam como
/// vieram.
String unityTypeFullLabel(String unityType) {
  switch (unityType.toLowerCase().trim()) {
    case 'kg':
      return 'Quilograma (kg)';
    case 'g':
      return 'Grama (g)';
    case 'unit':
    case 'un':
      return 'Unidade (un)';
    case 'maço':
      return 'Maço';
    case 'pacote':
      return 'Pacote';
    case 'box':
    case 'cx':
      return 'Caixa';
    case 'liter':
    case 'l':
      return 'Litro (L)';
    case 'ml':
      return 'Mililitro (ml)';
    case 'dozen':
    case 'dz':
      return 'Dúzia (dz)';
    default:
      return unityType;
  }
}
