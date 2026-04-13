import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

Future<MultipartFile> multipartFromXFile(XFile file) async {
  final bytes = await file.readAsBytes();
  return MultipartFile.fromBytes(bytes, filename: file.name);
}
