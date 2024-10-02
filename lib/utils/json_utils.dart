class AppUtils{
  static String addZero(your_number) {
    // return your_number.toString();
    var num = '' + your_number.toString();
    if (your_number < 10) {
      num = '0' + num;
    }
    return num;
  }
  static String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
  static String convertToDisplayString(String status) {
    List<String> parts = status.split('_'); // Split by underscores
    List<String> capitalizedParts = parts.map((part) => capitalize(part)).toList();
    return capitalizedParts.join(' '); // Join parts with spaces
  }

  static bool isNotNullOrEmpty(String? value) {
    return value != null && value.isNotEmpty;
  }
}

class JsonUtils {
  static int? toInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is bool && value == false) {
      return null;
    }
    if (value is num) {
      return value.toInt();
    }
    return null;
  }

  static bool? toBoolean(dynamic value) {
    if (value is bool) {
      return value;
    } else if (value is String) {
      return value.toLowerCase() == 'yes';
    } else if (value is int) {
      return value == 1;
    }
    return null;
  }

  static double? toDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is bool && value == false) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  static String? toText(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is bool && value == false) {
      return '';
    }
    if (value is String) {
      return value;
    }
    return null;
  }

  static String convertToString(dynamic value) {
    if (value == null) {
      return '';
    }
    return value.toString();
  }

  static String? toUniqueId(dynamic value) {

    if (value == null) {
      return null;
    }
    if (value is bool && value == false) {
      return '';
    }
    if (value is String) {
      return value.replaceAll(RegExp(r'[^0-9]'), '');
    }
    return null;
  }

  static DateTime? toDateTime(dynamic value) {
  
    if (value == null) {
      return null;
    }
    if (value is bool && value == false) {
      return null;
    }
    if (value is String) {
      return DateTime.parse(value);
    }
    return null;
  }

  static List<int>? toList(dynamic value) {
  
    if (value == null) {
      return [];
    }
    if (value is bool && value == false) {
      return [];
    }
    return List<int>.from(value);
    return null;
  }

  static List<String>? toStringList(dynamic value) {
 
    if (value == null) {
      return [];
    }
    if (value is bool && value == false) {
      return [];
    }
    return List<String>.from(value);
    return null;
  }

  static int? getId(dynamic list) {
 
    dynamic value=((list??false)==false?[]:list as List<dynamic>);
  
    return value.length>0?value[0]:null;
    return null;
  }
  static String? getName(dynamic list) {
 
    dynamic value=((list??false)==false?[]:list as List<dynamic>);
 
    return value.length>0?value[1]:null;
    return null;
  }

  static void addField(dynamic value,dynamic field,dynamic newValue,dynamic oldValue) {
    if(newValue!=oldValue)
      value[field] = newValue;
  }
}