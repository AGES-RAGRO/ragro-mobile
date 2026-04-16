import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

Future<MultipartFile> multipartFromXFile(XFile file) async {
  final bytes = await file.readAsBytes();
  final mimeType = file.mimeType ?? 'image/jpeg';
  return MultipartFile.fromBytes(
    bytes,
    filename: file.name,
    contentType: MediaType.parse(mimeType),
  );
}
