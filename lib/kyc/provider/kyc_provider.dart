import 'package:flutter_riverpod/flutter_riverpod.dart';

var selectIdTypeProvider = StateProvider<num>((ref) => 0);
var idFrontSideProvider = StateProvider<String?>((ref) => null);
var idBackSideProvider = StateProvider<String?>((ref) => null);
var selfeImageProvider = StateProvider<String?>((ref) => null);

var kycVerifiedProvider = StateProvider<bool?>((ref) => null);

