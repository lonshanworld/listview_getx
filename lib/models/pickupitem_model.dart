class PickupItemModel {
  final String trackingId;
  final String osName;
  final String pickupDate;
  final String osPrimaryPhone;
  final String osTownshipName;
  final int totalWays;

  PickupItemModel({
    required this.trackingId,
    required this.osName,
    required this.pickupDate,
    required this.osPrimaryPhone,
    required this.osTownshipName,
    required this.totalWays,
  });

  factory PickupItemModel.fromJson(Map<String, dynamic> json) {
    return PickupItemModel(
      trackingId: json['trackingId'] as String,
      osName: json['osName'] as String,
      pickupDate: json['pickupDate'] as String,
      osPrimaryPhone: json['osPrimaryPhone'] as String,
      osTownshipName: json['osTownshipName'] as String,
      totalWays: json['totalWays'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trackingId': trackingId,
      'osName': osName,
      'pickupDate': pickupDate,
      'osPrimaryPhone': osPrimaryPhone,
      'osTownshipName': osTownshipName,
      'totalWays': totalWays,
    };
  }
}