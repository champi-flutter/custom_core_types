import 'package:meta/meta.dart';

/// 全期間に対して一意に識別できる「週」を表す不変クラス。
///
/// ISO 8601 規格に準拠した週ベースの表現（例: "2026-W23"）と、
/// 基準となるエポック（デフォルトは1970年1月5日（月））からの
/// 経過週数によるシリアル表現を相互に変換できる。
@immutable
class UniqueWeek implements Comparable<UniqueWeek> {
  /// 週の基準日。1970年1月5日（月曜日）を週の絶対的な起点（第0週）とする。
  /// ISO 8601では月曜日が週の始まりです。
  static final DateTime epoch = DateTime.utc(1970, 1, 5);

  /// 基準エポック（1970-01-05）からの累積週数。
  /// 過去の日付の場合は負の数になる。
  final int absoluteWeekIndex;

  /// 累積週数から直接 [UniqueWeek] を作成。
  const UniqueWeek(this.absoluteWeekIndex);

  /// 指定した [DateTime]（デフォルトは現在時刻）が属する週の [UniqueWeek] を作成。
  factory UniqueWeek.fromDateTime(DateTime dateTime) {
    // タイムゾーンによるブレを防ぐため、UTCに変換して計算
    final utcDate = dateTime.toUtc();

    // 指定日とエポックの差分（ミリ秒）から経過週数を計算
    final difference = utcDate.difference(epoch);
    final elapsedDays = difference.inDays;

    // 割り切れない場合の切り捨て処理（負数の考慮含む）
    final weekIndex = (elapsedDays >= 0)
        ? (elapsedDays ~/ 7)
        : ((elapsedDays - 6) ~/ 7);

    return UniqueWeek(weekIndex);
  }

  /// ISO 8601 週表記（例: "2026-W23"）の文字列から [UniqueWeek] をパースするコンストラクタ。
  ///
  /// フォーマットが不正な場合は [FormatException] を投げる。
  factory UniqueWeek.parse(String formattedString) {
    final RegExp regex = RegExp(r'^(\d{4})-W(\d{1,2})$');
    final match = regex.firstMatch(formattedString.trim());

    if (match == null) {
      throw FormatException(
        'Invalid UniqueWeek format: $formattedString. Expected "YYYY-Www"',
      );
    }

    final year = int.parse(match.group(1)!);
    final weekNum = int.parse(match.group(2)!);

    if (weekNum < 1 || weekNum > 53) {
      throw FormatException(
        'Invalid week number: $weekNum. Must be between 1 and 53.',
      );
    }

    // ISO週番号から最初の日（その週の月曜日）を求め、そこから UniqueWeek を生成
    final monday = _isoWeekToMonday(year, weekNum);
    return UniqueWeek.fromDateTime(monday);
  }

  /// 指定された年とISO週番号から直接 [UniqueWeek] を作成するコンストラクタ。
  factory UniqueWeek.fromISO(int year, int weekNumber) {
    if (weekNumber < 1 || weekNumber > 53) {
      throw ArgumentError.value(
        weekNumber,
        'weekNumber',
        'Must be between 1 and 53',
      );
    }
    final monday = _isoWeekToMonday(year, weekNumber);
    return UniqueWeek.fromDateTime(monday);
  }

  /// この週の開始日（月曜日の午前0時）を返すメソッド。
  ///
  ///  [local]: `true` の場合はローカル時間、`false` の場合は UTC で返す。
  DateTime getStartDate({bool local = false}) {
    final utcStart = epoch.add(Duration(days: absoluteWeekIndex * 7));
    return local ? utcStart.toLocal() : utcStart;
  }

  /// この週の終了日（日曜日の午後11時59分59秒...）を返すメソッド。
  ///
  ///  [local]: `true` の場合はローカル時間、`false` の場合は UTC で返す。
  DateTime getEndDate({bool local = false}) {
    final DateTime utcEnd = getStartDate(local: false).add(
      const Duration(
        days: 6,
        hours: 23,
        minutes: 59,
        seconds: 59,
        milliseconds: 999,
      ),
    );
    return local ? utcEnd.toLocal() : utcEnd;
  }

  /// ISO 8601 規格に基づく「週番号としての年」。
  ///
  /// （例: 2026年1月1日は木曜日なので、2025年第53週となり、この getter は 2025 を返す）
  int get isoYear {
    return _toIsoYearAndWeek()[0];
  }

  /// ISO 8601 規格に基づく週番号（1〜53）。
  int get isoWeek {
    return _toIsoYearAndWeek()[1];
  }

  /// 一意の文字列（例: "2026-W23"）に変換するメソッド。
  ///
  /// これにより、文字列ソートでも時系列順に正しく並ぶ（4桁の年を使用しているため）。
  String toIsoString() {
    final List<int> parts = _toIsoYearAndWeek();
    // 4桁の数字の文字列にする
    final yearStr = parts[0].toString().padLeft(4, '0');
    // 2桁の数字の文字列にする
    final weekStr = parts[1].toString().padLeft(2, '0');
    return '$yearStr-W$weekStr';
  }

  /// 一意の [int] の 識別子に変換するメソッド。
  ///
  /// 基準エポックからの週番号（[absoluteWeekIndex]）を返す。
  int toIntIdentifier() => absoluteWeekIndex;

  /// 未来または過去の [UniqueWeek] を返すメソッド。
  ///
  /// 引数は、何週先か（負の場合は何週前か）を指定する。
  UniqueWeek addWeeks(int weeks) {
    return UniqueWeek(absoluteWeekIndex + weeks);
  }

  /// 2つの [UniqueWeek] の間の週数の差を計算するメソッド。
  int differenceInWeeks(UniqueWeek other) {
    return absoluteWeekIndex - other.absoluteWeekIndex;
  }

  /// ISO 8601 の年と週番号を計算してリスト [year, week] で返すプライベートヘルパー
  List<int> _toIsoYearAndWeek() {
    // 週の木曜日が、その週が属する「年」を決定 (ISO 8601)
    final monday = getStartDate(local: false);
    final thursday = monday.add(const Duration(days: 3));
    final year = thursday.year;

    // その年の1月4日は必ず第1週に含まれる (ISO 8601の定義)
    final jan4 = DateTime.utc(year, 1, 4);
    // 1月4日の属する週の月曜日を求める
    final jan4Monday = jan4.subtract(
      Duration(days: (jan4.weekday - DateTime.monday) % 7),
    );

    // 週数を算出
    final duration = thursday.difference(jan4Monday);
    final weekNum = (duration.inDays / 7).floor() + 1;

    return [year, weekNum];
  }

  /// ISO 8601 週から該当週の月曜日（DateTime）を求めるヘルパー
  static DateTime _isoWeekToMonday(int year, int weekNumber) {
    // 1月4日は常に第1週に含まれる
    final jan4 = DateTime.utc(year, 1, 4);
    final jan4Monday = jan4.subtract(
      Duration(days: (jan4.weekday - DateTime.monday) % 7),
    );

    // 第1週からのオフセットを加算
    return jan4Monday.add(Duration(days: (weekNumber - 1) * 7));
  }

  // 標準のオブジェクトメソッドの実装

  @override
  String toString() => 'UniqueWeek($toIsoString(), index: $absoluteWeekIndex)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UniqueWeek &&
          runtimeType == other.runtimeType &&
          absoluteWeekIndex == other.absoluteWeekIndex;

  @override
  int get hashCode => absoluteWeekIndex.hashCode;

  @override
  int compareTo(UniqueWeek other) {
    return absoluteWeekIndex.compareTo(other.absoluteWeekIndex);
  }
}

/// 今週
UniqueWeek get thisWeek => UniqueWeek.fromDateTime(DateTime.now());
