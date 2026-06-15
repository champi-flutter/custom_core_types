import 'package:custom_core_types/custom_core_types.dart';
import 'package:meta/meta.dart';

/// 全期間に対して一意に識別できる「週」を表す不変クラス。
///
/// ISO 8601 規格に準拠した週ベースの表現（例: "2026-W23"）と、
/// 基準となるエポック（デフォルトは1970年1月5日（月））からの
/// 経過週数によるシリアル表現を相互に変換できる。
@immutable
class UniqueWeek implements Comparable<UniqueWeek> {
  /// 週の絶対的な基準エポック（1970年1月5日・月曜日）。
  /// 実際のインデックス計算時の起点日は、指定された [firstWeek] に応じて
  /// 自動的にシフト（調整）される。
  static final Date _baseEpoch = Date.utc(1970, 1, 5);

  /// 指定された開始曜日（[firstWeek]）にあわせたエポック（起点日）。
  ///
  /// 例えば `firstWeek` が日曜日 (7) の場合、絶対基準である 1970-01-05 (月) から
  /// 1日巻き戻した「1970年1月4日（日）」をこの設定における起点（第0週の始まり）として返す。
  Date get _optimizedEpoch => _getOptimizedEpoch(firstWeekUtc);

  /// 指定された開始曜日にあわせたエポックを取得する static メソッド。
  ///
  /// 例えば `firstWeek` が日曜日 (7) の場合、絶対基準である 1970-01-05 (月) から
  /// 1日巻き戻した「1970年1月4日（日）」をこの設定における起点（第0週の始まり）として返す。
  static Date _getOptimizedEpoch(int firstWeekArg) {
    final int offset = (DateTime.monday - firstWeekArg) % 7;
    // Dart の % 演算子は負の数のとき正の数を返すための調整
    final int adjustedOffset = offset < 0 ? offset + 7 : offset;
    return _baseEpoch.nDaysAgo(adjustedOffset);
  }

  /// [_optimizedEpoch] からの経過日数（内部で UTC に変換）
  int _sinceEpoch(Date date) => _getNumOfDaysSinceEpoch(date, _optimizedEpoch);

  /// 指定 epoch からの経過日数を取得する static メソッド
  static int _getNumOfDaysSinceEpoch(Date date, Date epoch) {
    // タイムゾーンによるブレを防ぐため、UTCに変換して計算
    final Date utcDate = date.toUtc();

    // 指定日とエポックの差分（ミリ秒）から経過週数を計算
    final Duration difference = utcDate.difference(epoch);
    return difference.inDays;
  }

  /// 基準エポックからの累積週数。
  final int relativeWeekIndex;

  /// 週の開始曜日（UTC）
  ///
  /// 月曜日が 1 で、日曜日が 7 。
  final int firstWeekUtc;

  /// 週の開始日（UTC）
  Date get firstDateOfWeekUtc =>
      _optimizedEpoch.nDaysLater(relativeWeekIndex * 7);

  /// 週の開始日（ローカル）
  Date get firstDateOfWeek => firstDateOfWeekUtc.toLocal();

  // final Date firstDateOfWeek;

  /// 週の終了日
  Date get endDateOfWeek => firstDateOfWeek.nDaysLater(6);

  // todo コンストラクタ
  /// 累積週数から直接 [UniqueWeek] を作成。
  const UniqueWeek(
    this.relativeWeekIndex, {
    this.firstWeekUtc = DateTime.monday,
  }) : assert(
         firstWeekUtc >= 1 && firstWeekUtc <= 7,
         "無効な数値です（UniqueWeek.firstWeek）",
       );

  /// 指定した [DateTime]（デフォルトは現在時刻）が属する週の [UniqueWeek] を作成。
  ///
  /// 週の開始日を指定可能（[firstDate]）。指定されなかった場合は、月曜日になる。
  ///
  /// 曜日を [DateTime] から指定する場合は、[DateTime.weekday] を、
  /// [Date] から指定する場合は[Date.week] を用いること。
  factory UniqueWeek.fromDate({required Date currentDate, Date? firstDate})
  // 折りたたみ用
  {
    // UTC 基準で曜日を取得
    final int _firstWeek = firstDate == null
    // 指定されなかった場合は月曜日
        ? DateTime.monday
        : firstDate.toUtc().week;
    // 相対 epoch を取得
    final Date optimizedEpoch = _getOptimizedEpoch(_firstWeek);

    // 指定日と epoch の差分
    final int elapsedDays = _getNumOfDaysSinceEpoch(
      currentDate,
      optimizedEpoch,
    );

    // epoch の差分を 7 で割った商を取得（一応、負（epoch より古い）の場合を考慮）
    final weekIndex = (elapsedDays >= 0)
        ? (elapsedDays ~/ 7)
        : ((elapsedDays - 6) ~/ 7);

    return UniqueWeek(weekIndex, firstWeekUtc: _firstWeek);
  }

  /// ISO 8601 週表記（例: "2026-W23"）の文字列から [UniqueWeek] をパースするコンストラクタ。
  ///
  /// 曜日を [DateTime] から指定する場合は、[DateTime.weekday] を、
  /// [Date] から指定する場合は[Date.week] を用いること。
  ///
  /// フォーマットが不正な場合は [FormatException] を投げる。
  factory UniqueWeek.parse(String formattedString, {required Date firstDate}) {
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
    return UniqueWeek.fromDate(currentDate: monday, firstDate: firstDate);
  }

  /// 指定された年とISO週番号から直接 [UniqueWeek] を作成するコンストラクタ。
  ///
  /// 曜日を [DateTime] から指定する場合は、[DateTime.weekday] を、
  /// [Date] から指定する場合は[Date.week] を用いること。
  factory UniqueWeek.fromISO(
    int year,
    int weekNumber, {
    required Date firstDate,
  }) {
    if (weekNumber < 1 || weekNumber > 53) {
      throw ArgumentError.value(
        weekNumber,
        'weekNumber',
        'Must be between 1 and 53',
      );
    }
    final Date monday = _isoWeekToMonday(year, weekNumber);
    return UniqueWeek.fromDate(currentDate: monday, firstDate: firstDate);
  }

  /// ISO 8601 の年と週番号を計算してリストで返すメソッド
  ///  - `0`: 属する年
  ///  - `1`: 経過 **週** 数
  List<int> _toIsoYearAndWeek() {
    // 週の真ん中の日が属する年を、その週の所属年とする（年を跨ぐ週の調整）
    final Date middleOfWeek = firstDateOfWeek.nDaysLater(3);
    final int theYear = middleOfWeek.year;

    // 1月4日（UTC）を含む週を、その年の「最初の週（第1週）」とする
    final Date utcJan4 = Date.utc(theYear, 1, 4);
    // 現在設定されている firstWeekUtc に基づき、最初の週の最初の日（UTC）を取得
    final Date firstDayOfFirstWeek = getStartOfWeek(utcJan4);
    // 現在の週の最初の日（UTC）と ↑ との差分
    final Duration duration = firstDateOfWeekUtc.difference(
      firstDayOfFirstWeek,
    );
    // firstDayOfFirstWeek からの経過日数を 7 で割った商（経過週数）
    // に +1（スタートは `1` 週目）
    // （Dart の `.floor` は床関数（その数を超えない最大の整数を返す））
    final int weekNum = (duration.inDays / 7).floor() + 1;

    if (weekNum > 0) {
      return [theYear, weekNum];
    }
    // 1月の 1 ~ 3 日では、1月4日を含む週の開始日より前なら、前年（の週）になる
    // ex: (weekNum == 0)... 今が今年の 0 週目 == 前年の 52 か 53 週目
    else {
      // 前年の1月4日（UTC）
      final Date prevJan4 = Date.utc(theYear - 1, 1, 4);
      // 前年の、最初の週の最初の日（UTC）を取得
      final prevFirstDayOfFirstWeek = getStartOfWeek(prevJan4);
      // 現在の週の最初の日（UTC）と ↑ との差分
      final Duration prevDuration = firstDateOfWeekUtc.difference(
        prevFirstDayOfFirstWeek,
      );
      return [theYear - 1, (prevDuration.inDays / 7).floor() + 1];
    }
  }

  /// この週が属する年。
  ///
  /// （例: 開始曜日が金曜日の場合、2026年1月1日は木曜日なので、2025年第53週となり、
  /// 2025 年に属することになる）
  int get year {
    return _toIsoYearAndWeek()[0];
  }

  /// 年の初めからの経過週数。
  int get indexInYear {
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
  /// 1桁目は開始曜日、2桁目以降は、基準エポックからの経過週数（[relativeWeekIndex]）。
  int toIntIdentifier() => relativeWeekIndex * 10 + firstWeekUtc;

  /// 未来または過去の [UniqueWeek] を返すメソッド。
  ///
  /// 引数は、何週先か（負の場合は何週前か）を指定する。
  UniqueWeek addWeeks(int weeks) {
    return UniqueWeek(relativeWeekIndex + weeks, firstWeekUtc: firstWeekUtc);
  }

  /// 2つの [UniqueWeek] の間の週数の差を計算するメソッド。
  ///
  /// [other] のほうが古い場合に正。
  int differenceInWeeks(UniqueWeek other) {
    return relativeWeekIndex - other.relativeWeekIndex;
  }

  /// 設定された開始曜日（[firstWeekUtc]）に基づく、[date] （引数）を含む週の開始日を取得
  /// するメソッド。
  ///
  /// 内部で、UTC 基準で計算するので、ローカルを渡せばローカルで返し、
  /// UTC で渡せば UTC で返す。
  Date getStartOfWeek(Date date) {
    // UTC 基準で計算
    final Date utcDate = date.toUtc();
    // 指定した引数の日付の曜日と現在指定されている開始曜日の差分
    final int relativeWeek = utcDate.week - firstWeekUtc;
    final int offset = relativeWeek % 7;
    // 切り捨て除算形式を採用しているプラットフォームを介す場合（Dart の `%` は床関数）
    final int adjustedOffset = offset < 0 ? offset + 7 : offset;
    // 差分は UTC もローカルも変わらない
    return date.nDaysAgo(adjustedOffset);
  }

  /// ISO 8601 週から該当週の月曜日（DateTime）を求めるヘルパー
  static Date _isoWeekToMonday(int year, int weekNumber) {
    // 1月4日は常に第1週に含まれる
    final Date jan4 = Date.utc(year, 1, 4);
    final Date jan4Monday = jan4.nDaysAgo((jan4.week - DateTime.monday) % 7);

    // 第1週からのオフセットを加算
    return jan4Monday.nDaysLater((weekNumber - 1) * 7);
  }

  /// 指定日付がこの週に含まれているかどうか
  bool includesDate(Date date) {
    final Date utcDate = date.toUtc();
    // 週の開始日から何日はなれているか（週の開始日より古い日付の場合、負になる）
    final int difference = utcDate.difference(firstDateOfWeekUtc).inDays;
    // 差分が 0 日以上、 7 日未満なら true
    return difference >= 0 && difference < 7;
  }

  /// この週が当日を含んでいるかどうか
  bool get todays => includesDate(today);

  // 標準のオブジェクトメソッドの実装

  @override
  String toString() => 'UniqueWeek($toIsoString(), index: $relativeWeekIndex)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UniqueWeek &&
          runtimeType == other.runtimeType &&
          relativeWeekIndex == other.relativeWeekIndex;

  @override
  int get hashCode => relativeWeekIndex.hashCode;

  @override
  int compareTo(UniqueWeek other) {
    return relativeWeekIndex.compareTo(other.relativeWeekIndex);
  }
}
