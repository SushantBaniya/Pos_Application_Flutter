class CounterResponse {
  final int id;
  final int? business_id;
  final String business_name;
  final int? counter_number;
  final String? location;

  CounterResponse({required this.id, required this.business_id, required this.business_name, required this.counter_number, required this.location });

  factory CounterResponse.fromJson(Map<String, dynamic> json) {
  final counterJson = json['data'] is Map
      ? Map<String, dynamic>.from(json['data'] as Map)
      : json;
  return CounterResponse(
    id: counterJson['id'] as int,
    business_id: counterJson['business_id'] as int?,
    business_name: counterJson['business_name'] as String,
    counter_number: counterJson['counter_number'] as int?,
    location: counterJson['location'] as String?,
  );
}
}

class CounterRequest {
  final int? counter_number;
  final String? location;

  CounterRequest({ this.counter_number, this.location});

  Map<String, dynamic> toJson() {
    return {
      'counter_number': counter_number,
      'location': location,
    };
  }
}