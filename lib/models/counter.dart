class CounterResponse {
  final int id;
  final int? business_id;
  final String business_name;
  final int? counter_number;
  final String? location;

  CounterResponse({required this.id, required this.business_id, required this.business_name, required this.counter_number, required this.location });

  factory CounterResponse.fromJson(Map<String, dynamic> json) {
  return CounterResponse(
    id: json['id'] as int,
    business_id: json['business_id'] as int?,
    business_name: json['business_name'] as String,
    counter_number: json['counter_number'] as int?,
    location: json['location'] as String?,
  );
}
}