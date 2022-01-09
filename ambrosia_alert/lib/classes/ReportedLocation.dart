import 'package:flutter/material.dart';

@immutable
class ReportedLocation {
  ReportedLocation({
    required this.user_uid,
    required this.nrOfConfirmations,
    required this.confirmedByAuthorities,
    required this.points,
  });

  ReportedLocation.fromJson(Map<String, Object?> json)
      : this(
          user_uid: json['user_uid'] as String,
          nrOfConfirmations: json['nr_of_confirmations']! as int,
          confirmedByAuthorities: json['confirmed_by_authorities']! as bool,
          points: json['points']! as List<dynamic>,
        );

  final String user_uid;
  final int nrOfConfirmations;
  final bool confirmedByAuthorities;
  final List<dynamic> points;

  Map<String, Object?> toJson() {
    return {
      'user_uid': user_uid,
      'nr_of_confirmations': nrOfConfirmations,
      'confirmed_by_authorities': confirmedByAuthorities,
      'points': points,
    };
  }
}
