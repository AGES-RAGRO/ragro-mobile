/// Product categories shared between mobile and backend.
///
/// The enum name is the wire value sent to the backend. The [label] is the
/// Portuguese display name shown in the UI. Both sides must keep this list in
/// sync with the backend `ProductCategory` enum.
enum ProductCategory {
  fruits('Frutas'),
  vegetables('Verduras'),
  legumes('Legumes'),
  dairy('Laticínios'),
  eggs('Ovos'),
  grainsCereals('Grãos e Cereais'),
  meats('Carnes'),
  honeyDerivatives('Mel e Derivados'),
  artisanalProcessed('Processados Artesanais'),
  plantsSeedlings('Plantas e Mudas');

  const ProductCategory(this.label);

  final String label;
}
