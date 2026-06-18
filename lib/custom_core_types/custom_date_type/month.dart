import 'package:custom_core_types/custom_core_types/custom_date_type/date.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 全期間に対して一意に識別できる「月」を表す不変クラス。
@immutable
class Month implements Comparable<Month>{
  final int year;
  final int month;

  // DateTimeのコンストラクタで翌月の「0日」を指定すると、今月の末日が得られるらしい
  int get numberOfDays => DateTime(year, month + 1, 0).day;

  // int get numberOfDays {
  //   final DateTime startOfNextMonth = month + 1 <= 12
  //       ? DateTime(year, month + 1, 1)
  //       : DateTime(year + 1, 1, 1);
  //   return startOfNextMonth.subtract(Duration(days: 1)).day;
  // }
  const Month(this.year, this.month);

  factory Month.fromDateTime(DateTime dateTime){
    return Month(dateTime.year, dateTime.month);
  }

  /// 1ヶ月前を取得するメソッド
  Month back() {
    // 1月の場合は、前年の12月を返す
    if (month == 1) {
      return Month(year - 1, 12);
    }
    // それ以外は、前の月を返す
    else {
      return Month(year, month - 1);
    }
  }

  /// 1ヶ月後を取得するメソッド
  Month toNext() {
    // 12月の場合は、翌年の1月を返す
    if (month == 12) {
      return Month(year + 1, 1);
    }
    // それ以外は、次の月を返す
    else {
      return Month(year, month + 1);
    }
  }

  /// [DateTime] に変換（その月の1日）
  DateTime toDateTime() => DateTime(year, month, 1);

  /// [Date] に変換（その月の1日）
  Date toDate() => Date.onMonth(this, 1);

  /// 比較ロジック
  @override
  int compareTo(Month other) {
    if (year != other.year) {
      return year.compareTo(other.year);
    }
    return month.compareTo(other.month);
  }
  // 各比較演算子
  @override
  bool operator ==(Object other) {
    assert(other is Month, "DateクラスとDateTimeクラスを直接比較しています。（ == ）");
    return other is Month && month == other.month && year == other.year;
  }
}

/// 今月
Month get thisMonth => Month.fromDateTime(DateTime.now());