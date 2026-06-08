import 'package:custom_core_types/custom_core_types.dart';
import 'package:custom_core_types/custom_core_types/custom_date_type/month.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 時刻なしの日付データ
@immutable
class Date {
  /// 内部で 00:00:00 の [DateTime] を持つ
  final DateTime _dt;

  Date(int year, int month, int day) : _dt = DateTime(year, month, day);

  Date.onMonth(Month month, int day)
      : _dt = DateTime(month.year, month.month, day);

  DateTime toDateTime() => _dt;

  /// 内部用コンストラクタ
  Date._(this._dt);

  /// 年
  int get year => _dt.year;

  /// 月 (1-12)
  int get month => _dt.month;

  /// 日 (1-31)
  int get day => _dt.day;

  /// [n] 日前
  Date nDaysAgo(int n) => Date._(_dt.subtract(Duration(days: n)));

  /// [n] 日後
  Date nDaysLater(int n) => Date._(_dt.add(Duration(days: n)));

  /// 今日から何日前か
  ///
  /// 今日なら `0` 。
  int get priorToToday {
    final todaysDateTime = DateTime.now().omitTime;
    return todaysDateTime.difference(_dt).inDays;
  }

  // 各比較演算子
  @override
  bool operator ==(Object other) {
    assert(other is! DateTime, "DateクラスとDateTimeクラスを直接比較しています。（ == ）");
    return other is Date && _dt == other._dt;
  }

  bool operator <(Date other) {
    assert(other is! DateTime, "DateクラスとDateTimeクラスを直接比較しています。( < )");
    return _dt.isBefore(other._dt);
  }

  bool operator >(Date other) {
    assert(other is! DateTime, "DateクラスとDateTimeクラスを直接比較しています。( > )");
    return _dt.isAfter(other._dt);
  }

  bool operator <=(Date other) {
    assert(other is! DateTime, "DateクラスとDateTimeクラスを直接比較しています。( <= )");
    return _dt.isBefore(other._dt) || _dt == other._dt;
  }

  bool operator >=(Date other) {
    assert(other is! DateTime, "DateクラスとDateTimeクラスを直接比較しています。( >= )");
    return _dt.isAfter(other._dt) || _dt == other._dt;
  }

  @override
  int get hashCode => _dt.hashCode;
}