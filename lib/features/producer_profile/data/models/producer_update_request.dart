// Payload de PUT /producers/:id — patch parcial alinhado ao ProducerUpdateRequest.java.
class ProducerUpdateRequest {
  const ProducerUpdateRequest({
    this.name,
    this.story,
    this.phone,
    this.farmName,
    this.description,
    this.address,
    this.paymentMethods,
    this.availability,
  });

  final String? name;
  final String? story;
  final String? phone;
  final String? farmName;
  final String? description;
  final Map<String, dynamic>? address;
  final List<Map<String, dynamic>>? paymentMethods;
  final List<Map<String, dynamic>>? availability;

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (story != null) 'story': story,
    if (phone != null) 'phone': phone,
    if (farmName != null) 'farmName': farmName,
    if (description != null) 'description': description,
    if (address != null) 'address': address,
    if (paymentMethods != null) 'paymentMethods': paymentMethods,
    if (availability != null) 'availability': availability,
  };
}
