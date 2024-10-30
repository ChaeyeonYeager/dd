import 'dart:convert';
import 'package:http/http.dart' as http;
import 'diary_page.dart';

class ImageService {
  String imageStyle;

  ImageService([this.imageStyle = 'hand-drawn']);

  void setImageStyle(String style) {
    imageStyle = style;
  }

  Future<String> translateToEnglish(String koreanText) async {
    final response = await http.post(
      Uri.parse(
          'https://translation.googleapis.com/language/translate/v2?key=AIzaSyAgrjR9nFqQ2puWX124xsUw7XZmZY0rnys'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'q': koreanText,
        'source': 'ko',
        'target': 'en',
        'format': 'text',
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']['translations'][0]['translatedText'];
    } else {
      print('번역 실패: ${response.body}');
      throw Exception('Failed to translate text: ${response.body}');
    }
  }

  Future<String> refinePrompt(String koreanPrompt) async {
    String englishPrompt = await translateToEnglish(koreanPrompt);

    if (imageStyle == 'realistic') {
      return "This image should depict " +
          englishPrompt +
          " with a realistic style, capturing fine details and true-to-life colors.";
    } else
      return "This image should depict " +
          englishPrompt +
          " with a hand-drawn style, resembling a sketch or illustration. It should include soft, pastel colors and have a slightly rough texture. " +
          "The lines should be gentle and somewhat imperfect, creating a cozy and charming atmosphere. The main object should be at the center of the frame, giving it a warm and inviting feel.";
  }

  Future<String?> generateImage(String prompt) async {
    String refinedPrompt = await refinePrompt(prompt);

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/images/generations'),
      headers: {
        'Content-Type': 'application/json',
        // !!실행할 때는 주석 풀어야 함!!
        //'Authorization':
        //'Bearer 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',
      },
      body: jsonEncode({'prompt': refinedPrompt}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String imageUrl = data['data'][0]['url'];
      print('Generated Image URL: $imageUrl');
      return imageUrl;
    } else {
      print('이미지 생성 실패!!');
      print('API 응답: ${response.body}');
      throw Exception('Failed to generate image: ${response.body}');
    }
  }
}
