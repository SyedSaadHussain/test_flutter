
extension jsonDynamicList on List<dynamic> {

  dynamic? getName() {
    List<dynamic> value = this;
    return value.length>0?value[1]:null;
  }
  dynamic? getId() {
    List<dynamic> value = this;
    return value.length>0?value[0]:null;
  }
}

// extension jsonConvert on Object  {
//   String? convertToName() {
//     return 'saad';
//   }
// }
extension jsonListConvert on List<dynamic>  {
  String? convertToName() {
    return 'saad';
  }
}

extension jsonDynamic on dynamic {

  String? jsonToString() {
    return null;
  }
}