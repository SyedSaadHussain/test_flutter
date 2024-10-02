import 'package:mosque_management_system/data/repositories/custom_odoo_client.dart';
import 'package:mosque_management_system/utils/json_utils.dart';
import 'package:mosque_management_system/utils/paged_data.dart';
import 'package:mosque_management_system/utils/shared_preference.dart';
import 'package:odoo_rpc/odoo_rpc.dart';

class PrayerTime {
  final int? id;
  final int? cityId;
  final String? city;
  final String?  date;
  final String?  month;
  final String?  year;
  final String?  fajarTime;
  final String?  dhuhrTime;
  final String?  asrTime;
  final String?  maghribTime;
  final String?  ishaTime;

  // Add more fields as needed

  PrayerTime({
    this.id,
    this.date,
    this.month,
    this.year,
    this.city,
    this.cityId,
    this.fajarTime,
    this.dhuhrTime,
    this.asrTime,
    this.maghribTime,
    this.ishaTime
  });

  factory PrayerTime.fromJson(Map<String, dynamic> json) {
    return PrayerTime(
      id: JsonUtils.toInt(json['id'])!.toInt(),
      city: JsonUtils.getName(json['name']),
      cityId: JsonUtils.getId(json['name']),
      month: JsonUtils.toText(json['month']),
      year: JsonUtils.toText(json['year']),
      date: JsonUtils.toText(json['date']),
      fajarTime: JsonUtils.toText(json['fajar_time']),
      dhuhrTime: JsonUtils.toText(json['dhuhr_time']),
      asrTime: JsonUtils.toText(json['asr_time']),
      maghribTime: JsonUtils.toText(json['maghrib_time']),
      ishaTime: JsonUtils.toText(json['isha_time'])
    );
  }


}


