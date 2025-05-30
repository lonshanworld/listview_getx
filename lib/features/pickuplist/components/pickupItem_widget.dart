import 'package:flutter/material.dart';

class PickupitemWidget extends StatelessWidget {
  final String trackingId;
  final String osName;
  final String townShipName;
  final String osPrimaryPhone;
  final String pickupDate;
  final num totalWays;
  final String countString;
  const PickupitemWidget({
    super.key,
    required this.countString,
    required this.osName,
    required this.osPrimaryPhone,
    required this.pickupDate,
    required this.totalWays,
    required this.townShipName,
    required this.trackingId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  trackingId,
                  style: const TextStyle( fontSize: 16, color: Colors.blue),
                ),
                const SizedBox(height: 8.0),
                Text(
                  osName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),

              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  townShipName,
                ),
                const SizedBox(height: 8.0),
                Text(
                  osPrimaryPhone,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  pickupDate,
                ),
                const SizedBox(height: 8.0),
                Text(
                  '$totalWays ways',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(
                  countString,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
