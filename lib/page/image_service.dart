import 'dart:convert';
import 'package:http/http.dart' as http;

class ImageService {
  Future<String?> generateImage(String prompt) async {
    // .env 파일에서 API 키 가져오기
    final response = await http.post(
      Uri.parse(
          'https://api.openai.com/v1/images/generations'), // OpenAI DALL-E API 엔드포인트
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer (edit here)', // 환경 변수에서 API 키 사용
      },
      body: jsonEncode({'prompt': prompt}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String imageUrl = data['data'][0]['url']; // 응답에서 이미지 URL을 가져오기
      print('Generated Image URL: $imageUrl'); // URL을 터미널에 출력
      return imageUrl; // 이미지 URL 반환
    } else {
      print('실패!!');
      print('API 응답: ${response.body}'); // 실패 시 응답 내용 출력
      throw Exception('Failed to generate image: ${response.body}');
    }
  }
}
