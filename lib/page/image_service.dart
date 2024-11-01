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
          '(edit here)'),
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
      Uri.parse('https://.openai.com/v1/images/generations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            '(edit here)',
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
      print(' 응답: ${response.body}');
      throw Exception('Failed to generate image: ${response.body}');
    }
  }
}
