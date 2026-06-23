/// Product categories shared between mobile and backend.
///
/// [wireValue] is the exact backend `ProductCategory` enum constant sent to the
/// API (Spring parses the query param with a case-sensitive `valueOf`). [label]
/// is the Portuguese display name shown in the UI. Keep both in sync with the
/// backend `br.com.ragro.domain.enums.ProductCategory` enum.
enum ProductCategory {
  fruits('Frutas', 'FRUTAS'),
  vegetables('Verduras', 'VERDURAS'),
  legumes('Legumes', 'LEGUMES'),
  dairy('Laticínios', 'LATICINIOS'),
  eggs('Ovos', 'OVOS'),
  grainsCereals('Grãos e Cereais', 'GRAOS_E_CEREAIS'),
  meats('Carnes', 'CARNES'),
  honeyDerivatives('Mel e Derivados', 'MEL_E_DERIVADOS'),
  artisanalProcessed('Processados Artesanais', 'PROCESSADOS_ARTESANAIS'),
  plantsSeedlings('Plantas e Mudas', 'PLANTAS_E_MUDAS');

  const ProductCategory(this.label, this.wireValue);

  final String label;
  final String wireValue;
}
