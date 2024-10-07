import 'dart:convert';

import 'package:pixabay/constants/utils.dart';

import '../data/get_images_model.dart';
import 'package:http/http.dart' as http;

class ApiInterFace {
  Future<GetImagesModel?> fetchVideos(String query, {required int page}) async {
    final String url = "${Utils.baseUrl}/videos/?key=${Utils.apiKey}&q=$query";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return GetImagesModel.fromJson(data, statusCode: response.statusCode);
      } else {
        // If API call fails, return model with error status code
        return GetImagesModel(statusCode: response.statusCode);
      }
    } catch (e) {
      // Handle exception, return a model with a status code of 500 (Internal Server Error)
      print("Error: $e");
      return GetImagesModel(statusCode: 500);
    }
  }

}
