/// Maps the backend `unityType` to the short pt-BR form shown in the UI.
/// Unknown values are returned unchanged; empty strings return empty.
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

/// Full pt-BR label for unit selection (e.g. the product form dropdown). The
/// submitted value stays the backend code (kg, liter, box...); only the
/// displayed text changes. Unknown values are returned unchanged.
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
