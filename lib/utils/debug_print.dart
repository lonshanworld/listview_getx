import 'package:flutter/foundation.dart';

void cusDebugPrint(dynamic data){
  if (kDebugMode) {
    print(data);
  }
}