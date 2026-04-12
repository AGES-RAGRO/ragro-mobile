// Payload de PUT /producers/:id — patch parcial alinhado ao ProducerUpdateRequest.java.
class ProducerUpdateRequest {
  const ProducerUpdateRequest({
    this.name,
    this.story,
    this.phone,
    this.farmName,
    this.description,
  });

  final String? name;
  final String? story;
  final String? phone;
  final String? farmName;
  final String? description;

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (story != null) 'story': story,
    if (phone != null) 'phone': phone,
    if (farmName != null) 'farmName': farmName,
    if (description != null) 'description': description,
  };
}
