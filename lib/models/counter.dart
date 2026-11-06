class CounterResponse {
  final int id;
  final int business_id;
  final String business_name;
  final int counter_number;
  final String location;

  CounterResponse({required this.id, required this.business_id, required this.business_name, required this.counter_number, required this.location });

  factory CounterResponse.fromJson(Map<String, dynamic> json) {
    return CounterResponse(id: json['id '], business_id: json['business_id'], business_name: json['business_name'], counter_number: json['counter_number'], location: json['location']);
  }
}