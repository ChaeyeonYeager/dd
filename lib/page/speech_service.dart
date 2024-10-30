// lib/speech_service.dart
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _hasSpeech = false;
  String recognizedText = "";

  // 음성 인식을 초기화하는 함수
  Future<void> initialize() async {
    _hasSpeech = await _speech.initialize();
  }

  // 음성 인식을 시작하는 함수
  void startListening(Function(String) onResultCallback) {
    if (_hasSpeech) {
      _speech.listen(
        onResult: (SpeechRecognitionResult result) {
          recognizedText = result.recognizedWords;
          onResultCallback(recognizedText); // 결과 콜백을 통해 UI로 전달
        },
      );
    }
  }

  // 음성 인식을 멈추는 함수
  void stopListening() {
    _speech.stop();
  }

  // 리소스를 해제하는 함수
  void dispose() {
    _speech.stop(); // 현재 음성을 멈추고
    _speech.cancel(); // 모든 음성 인식 세션을 취소
  }
}
