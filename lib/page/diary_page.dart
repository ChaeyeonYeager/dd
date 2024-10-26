import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'speech_service.dart'; // SpeechService 불러오기
import 'image_service.dart'; // ImageService 불러오기
import 'drawer_menu.dart'; // DrawerMenu 불러오기

class DiaryPage extends StatefulWidget {
  final DateTime selectedDate;

  const DiaryPage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late DateTime _selectedDate;
  String _recordingStatus = "마이크 버튼을 누르고 녹음을 시작하세요";
  bool _isListening = false;
  final SpeechService _speechService = SpeechService();
  final ImageService _imageService = ImageService();
  String _recognizedText = "";
  Uint8List? _imageData; // 생성된 이미지 데이터를 위한 변수

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _speechService.initialize();
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  void _onRecordButtonPressed() {
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      _speechService.startListening((resultText) {
        setState(() {
          _recordingStatus = "녹음된 텍스트: $resultText";
          _recognizedText = resultText;
        });
      });
    } else {
      _speechService.stopListening(); // 이 부분에서 비동기 처리가 필요 없음
      setState(() {
        _recordingStatus = "녹음 중지됨. 마이크 버튼을 눌러 다시 시작하세요.";
      });

      // AI에 텍스트를 보내고 이미지 URL을 받아오기
      _imageService.generateImage(_recognizedText).then((imageUrl) {
        _downloadImage(imageUrl); // 다운로드 함수 호출
      }).catchError((error) {
        setState(() {
          _recordingStatus = "이미지 생성 중 오류 발생: $error";
        });
      });
    }
  }

  Future<void> _downloadImage(String? url) async {
    if (url == null) return;

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _imageData = response.bodyBytes; // 이미지 데이터를 Uint8List로 저장
        });
      } else {
        throw Exception('이미지 다운로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('오류: $e');
      setState(() {
        _recordingStatus = "이미지 다운로드 중 오류 발생: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF8B4513),
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B4513),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      drawer: DrawerMenu(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 날짜 네비게이션
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _changeDate(-1),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('MM').format(
                            _selectedDate.add(const Duration(days: -1))),
                        style:
                            TextStyle(color: Colors.brown[200], fontSize: 20),
                      ),
                      Text(
                        DateFormat('dd').format(
                            _selectedDate.add(const Duration(days: -1))),
                        style:
                            TextStyle(color: Colors.brown[200], fontSize: 30),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _changeDate(-1),
                      icon: const Icon(Icons.arrow_left,
                          color: Colors.white, size: 30),
                    ),
                    Text(
                      DateFormat('MM dd').format(_selectedDate),
                      style: const TextStyle(color: Colors.white, fontSize: 30),
                    ),
                    IconButton(
                      onPressed: () => _changeDate(1),
                      icon: const Icon(Icons.arrow_right,
                          color: Colors.white, size: 30),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _changeDate(1),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('MM')
                            .format(_selectedDate.add(const Duration(days: 1))),
                        style:
                            TextStyle(color: Colors.brown[200], fontSize: 20),
                      ),
                      Text(
                        DateFormat('dd')
                            .format(_selectedDate.add(const Duration(days: 1))),
                        style:
                            TextStyle(color: Colors.brown[200], fontSize: 30),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 녹음 안내 메시지 박스
          Expanded(
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.brown[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.3,
                child: Center(
                  child: Text(
                    _recordingStatus,
                    style: TextStyle(color: Colors.grey[700], fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          // 생성된 이미지 표시
          if (_imageData != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Image.memory(
                _imageData!, // 메모리에서 이미지 표시
                width:
                    MediaQuery.of(context).size.width * 0.8, // 화면 너비의 80%로 설정
                height:
                    MediaQuery.of(context).size.height * 0.3, // 화면 높이의 30%로 설정
                fit: BoxFit.cover,
              ),
            ),

          // 마이크 버튼
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: IconButton(
              icon: const Icon(Icons.mic, size: 50, color: Colors.white),
              onPressed: _onRecordButtonPressed, // 버튼 클릭 시 녹음 시작
            ),
          ),
        ],
      ),
    );
  }
}
