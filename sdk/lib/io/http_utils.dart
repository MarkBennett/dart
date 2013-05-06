// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of dart.io;

class _HttpUtils {
  static String decodeUrlEncodedString(String urlEncoded) {
    // First check the string for any encoding.
    int index = 0;
    bool encoded = false;
    while (!encoded && index < urlEncoded.length) {
      encoded = urlEncoded[index] == "+" || urlEncoded[index] == "%";
      index++;
    }
    if (!encoded) return urlEncoded;
    index--;

    // Start decoding from the first encoded character.
    List<int> bytes = new List<int>();
    for (int i = 0; i < index; i++) bytes.add(urlEncoded.codeUnitAt(i));
    for (int i = index; i < urlEncoded.length; i++) {
      if (urlEncoded[i] == "+") {
        bytes.add(32);
      } else if (urlEncoded[i] == "%") {
        if (urlEncoded.length - i < 2) {
          throw new HttpException("Invalid URL encoding");
        }
        int byte = 0;
        for (int j = 0; j < 2; j++) {
          var charCode = urlEncoded.codeUnitAt(i + j + 1);
          if (0x30 <= charCode && charCode <= 0x39) {
            byte = byte * 16 + charCode - 0x30;
          } else {
            // Check ranges A-F (0x41-0x46) and a-f (0x61-0x66).
            charCode |= 0x20;
            if (0x61 <= charCode && charCode <= 0x66) {
              byte = byte * 16 + charCode - 0x57;
            } else {
              throw new ArgumentError("Invalid URL encoding");
            }
          }
        }
        bytes.add(byte);
        i += 2;
      } else {
        bytes.add(urlEncoded.codeUnitAt(i));
      }
    }
    return decodeUtf8(bytes);
  }

  static Map<String, String> splitQueryString(String queryString) {
    Map<String, String> result = new Map<String, String>();
    int currentPosition = 0;
    while (currentPosition < queryString.length) {
      int position = queryString.indexOf("=", currentPosition);
      if (position == -1) {
        break;
      }
      String name = queryString.substring(currentPosition, position);
      currentPosition = position + 1;
      position = queryString.indexOf("&", currentPosition);
      String value;
      if (position == -1) {
        value = queryString.substring(currentPosition);
        currentPosition = queryString.length;
      } else {
        value = queryString.substring(currentPosition, position);
        currentPosition = position + 1;
      }
      result[_HttpUtils.decodeUrlEncodedString(name)] =
        _HttpUtils.decodeUrlEncodedString(value);
    }
    return result;
  }

  // From RFC 2616 section "3.3.1 Full Date"
  // HTTP-date    = rfc1123-date | rfc850-date | asctime-date
  // rfc1123-date = wkday "," SP date1 SP time SP "GMT"
  // rfc850-date  = weekday "," SP date2 SP time SP "GMT"
  // asctime-date = wkday SP date3 SP time SP 4DIGIT
  // date1        = 2DIGIT SP month SP 4DIGIT
  //                ; day month year (e.g., 02 Jun 1982)
  // date2        = 2DIGIT "-" month "-" 2DIGIT
  //                ; day-month-year (e.g., 02-Jun-82)
  // date3        = month SP ( 2DIGIT | ( SP 1DIGIT ))
  //                ; month day (e.g., Jun  2)
  // time         = 2DIGIT ":" 2DIGIT ":" 2DIGIT
  //                ; 00:00:00 - 23:59:59
  // wkday        = "Mon" | "Tue" | "Wed"
  //              | "Thu" | "Fri" | "Sat" | "Sun"
  // weekday      = "Monday" | "Tuesday" | "Wednesday"
  //              | "Thursday" | "Friday" | "Saturday" | "Sunday"
  // month        = "Jan" | "Feb" | "Mar" | "Apr"
  //              | "May" | "Jun" | "Jul" | "Aug"
  //              | "Sep" | "Oct" | "Nov" | "Dec"

  // Format as RFC 1123 date.
  static String formatDate(DateTime date) {
    const List wkday = const ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    const List month = const ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                              "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

    DateTime d = date.toUtc();
    StringBuffer sb = new StringBuffer();
    sb.write(wkday[d.weekday - 1]);
    sb.write(", ");
    sb.write(d.day.toString());
    sb.write(" ");
    sb.write(month[d.month - 1]);
    sb.write(" ");
    sb.write(d.year.toString());
    sb.write(d.hour < 9 ? " 0" : " ");
    sb.write(d.hour.toString());
    sb.write(d.minute < 9 ? ":0" : ":");
    sb.write(d.minute.toString());
    sb.write(d.second < 9 ? ":0" : ":");
    sb.write(d.second.toString());
    sb.write(" GMT");
    return sb.toString();
  }

  static DateTime parseDate(String date) {
    final int SP = 32;
    const List wkdays = const ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    const List weekdays = const ["Monday", "Tuesday", "Wednesday", "Thursday",
                           "Friday", "Saturday", "Sunday"];
    const List months = const ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                         "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    const List wkdaysLowerCase =
        const ["mon", "tue", "wed", "thu", "fri", "sat", "sun"];
    const List weekdaysLowerCase = const ["monday", "tuesday", "wednesday",
                                          "thursday", "friday", "saturday",
                                          "sunday"];
    const List monthsLowerCase = const ["jan", "feb", "mar", "apr", "may",
                                        "jun", "jul", "aug", "sep", "oct",
                                        "nov", "dec"];

    final int formatRfc1123 = 0;
    final int formatRfc850 = 1;
    final int formatAsctime = 2;

    int index = 0;
    String tmp;
    int format;

    void expect(String s) {
      if (date.length - index < s.length) {
        throw new HttpException("Invalid HTTP date $date");
      }
      String tmp = date.substring(index, index + s.length);
      if (tmp != s) {
        throw new HttpException("Invalid HTTP date $date");
      }
      index += s.length;
    }

    int expectWeekday() {
      int weekday;
      // The formatting of the weekday signals the format of the date string.
      int pos = date.indexOf(",", index);
      if (pos == -1) {
        int pos = date.indexOf(" ", index);
        if (pos == -1) throw new HttpException("Invalid HTTP date $date");
        tmp = date.substring(index, pos);
        index = pos + 1;
        weekday = wkdays.indexOf(tmp);
        if (weekday != -1) {
          format = formatAsctime;
          return weekday;
        }
      } else {
        tmp = date.substring(index, pos);
        index = pos + 1;
        weekday = wkdays.indexOf(tmp);
        if (weekday != -1) {
          format = formatRfc1123;
          return weekday;
        }
        weekday = weekdays.indexOf(tmp);
        if (weekday != -1) {
          format = formatRfc850;
          return weekday;
        }
      }
      throw new HttpException("Invalid HTTP date $date");
    }

    int expectMonth(String separator) {
      int pos = date.indexOf(separator, index);
      if (pos - index != 3) throw new HttpException("Invalid HTTP date $date");
      tmp = date.substring(index, pos);
      index = pos + 1;
      int month = months.indexOf(tmp);
      if (month != -1) return month;
      throw new HttpException("Invalid HTTP date $date");
    }

    int expectNum(String separator) {
      int pos;
      if (separator.length > 0) {
        pos = date.indexOf(separator, index);
      } else {
        pos = date.length;
      }
      String tmp = date.substring(index, pos);
      index = pos + separator.length;
      try {
        int value = int.parse(tmp);
        return value;
      } on FormatException catch (e) {
        throw new HttpException("Invalid HTTP date $date");
      }
    }

    void expectEnd() {
      if (index != date.length) {
        throw new HttpException("Invalid HTTP date $date");
      }
    }

    int weekday = expectWeekday();
    int day;
    int month;
    int year;
    int hours;
    int minutes;
    int seconds;
    if (format == formatAsctime) {
      month = expectMonth(" ");
      if (date.codeUnitAt(index) == SP) index++;
      day = expectNum(" ");
      hours = expectNum(":");
      minutes = expectNum(":");
      seconds = expectNum(" ");
      year = expectNum("");
    } else {
      expect(" ");
      day = expectNum(format == formatRfc1123 ? " " : "-");
      month = expectMonth(format == formatRfc1123 ? " " : "-");
      year = expectNum(" ");
      hours = expectNum(":");
      minutes = expectNum(":");
      seconds = expectNum(" ");
      expect("GMT");
    }
    expectEnd();
    return new DateTime.utc(year, month + 1, day, hours, minutes, seconds, 0);
  }

  static DateTime parseCookieDate(String date) {
    const List monthsLowerCase = const ["jan", "feb", "mar", "apr", "may",
                                        "jun", "jul", "aug", "sep", "oct",
                                        "nov", "dec"];

    int position = 0;

    void error() {
      throw new HttpException("Invalid cookie date $date");
    }

    bool isEnd() {
      return position == date.length;
    }

    bool isDelimiter(String s) {
      int char = s.codeUnitAt(0);
      if (char == 0x09) return true;
      if (char >= 0x20 && char <= 0x2F) return true;
      if (char >= 0x3B && char <= 0x40) return true;
      if (char >= 0x5B && char <= 0x60) return true;
      if (char >= 0x7B && char <= 0x7E) return true;
      return false;
    }

    bool isNonDelimiter(String s) {
      int char = s.codeUnitAt(0);
      if (char >= 0x00 && char <= 0x08) return true;
      if (char >= 0x0A && char <= 0x1F) return true;
      if (char >= 0x30 && char <= 0x39) return true;  // Digit
      if (char == 0x3A) return true;  // ':'
      if (char >= 0x41 && char <= 0x5A) return true;  // Alpha
      if (char >= 0x61 && char <= 0x7A) return true;  // Alpha
      if (char >= 0x7F && char <= 0xFF) return true;  // Alpha
      return false;
    }

    bool isDigit(String s) {
      int char = s.codeUnitAt(0);
      if (char > 0x2F && char < 0x3A) return true;
      return false;
    }

    int getMonth(String month) {
      if (month.length < 3) return -1;
      return monthsLowerCase.indexOf(month.substring(0, 3));
    }

    int toInt(String s) {
      int index = 0;
      for (; index < s.length && isDigit(s[index]); index++);
      return int.parse(s.substring(0, index));
    }

    var tokens = [];
    while (!isEnd()) {
      while (!isEnd() && isDelimiter(date[position])) position++;
      int start = position;
      while (!isEnd() && isNonDelimiter(date[position])) position++;
      tokens.add(date.substring(start, position).toLowerCase());
      while (!isEnd() && isDelimiter(date[position])) position++;
    }

    String timeStr;
    String dayOfMonthStr;
    String monthStr;
    String yearStr;

    for (var token in tokens) {
      if (token.length < 1) continue;
      if (timeStr == null && token.length >= 5 && isDigit(token[0]) &&
          (token[1] == ":" || (isDigit(token[1]) && token[2] == ":"))) {
        timeStr = token;
      } else if (dayOfMonthStr == null && isDigit(token[0])) {
        dayOfMonthStr = token;
      } else if (monthStr == null && getMonth(token) >= 0) {
        monthStr = token;
      } else if (yearStr == null && token.length >= 2 &&
                 isDigit(token[0]) && isDigit(token[1])) {
        yearStr = token;
      }
    }

    if (timeStr == null || dayOfMonthStr == null ||
        monthStr == null || yearStr == null) {
      error();
    }

    int year = toInt(yearStr);
    if (year >= 70 && year <= 99) year += 1900;
    else if (year >= 0 && year <= 69) year += 2000;
    if (year < 1601) error();

    int dayOfMonth = toInt(dayOfMonthStr);
    if (dayOfMonth < 1 || dayOfMonth > 31) error();

    int month = getMonth(monthStr) + 1;

    var timeList = timeStr.split(":");
    if (timeList.length != 3) error();
    int hour = toInt(timeList[0]);
    int minute = toInt(timeList[1]);
    int second = toInt(timeList[2]);
    if (hour > 23) error();
    if (minute > 59) error();
    if (second > 59) error();

    return new DateTime.utc(year, month, dayOfMonth, hour, minute, second, 0);
  }

  // Parse a string with HTTP entities. Returns null if the string ends in the
  // middle of a http entity.
  static String parseHttpEntityString(String input) {
    int amp = input.lastIndexOf('&');
    if (amp < 0) return input;
    int end = input.lastIndexOf(';');
    if (end < amp) return null;

    var buffer = new StringBuffer();
    int offset = 0;

    parse(amp, end) {
      switch (input[amp + 1]) {
        case '#':
          if (input[amp + 2] == 'x') {
            buffer.writeCharCode(
                int.parse(input.substring(amp + 3, end), radix: 16));
          } else {
            buffer.writeCharCode(int.parse(input.substring(amp + 2, end)));
          }
          break;

        default:
          throw new HttpException('Unhandled HTTP entity token');
      }
    }

    while ((amp = input.indexOf('&', offset)) >= 0) {
      buffer.write(input.substring(offset, amp));
      int end = input.indexOf(';', amp);
      parse(amp, end);
      offset = end + 1;
    }
    buffer.write(input.substring(offset));
    return buffer.toString();
  }
}
