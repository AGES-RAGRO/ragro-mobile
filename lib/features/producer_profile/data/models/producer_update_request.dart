/// Payload de atualização de perfil de produtor para `PUT /producers/:id`.
class ProducerUpdateRequest {
  const ProducerUpdateRequest({
    required this.name,
    required this.story,
    required this.phone,
    required this.location,
  });

  final String name;
  final String story;
  final String phone;
  final String location;

  Map<String, dynamic> toJson() => {
    'name': name,
    'story': story,
    'phone': phone,
    'location': location,
  };
}
