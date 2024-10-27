import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'calendar_page.dart'; // CalendarPage 불러오기
import 'speech_service.dart';
import 'image_service.dart';
import 'drawer_menu.dart';

class DiaryPage extends StatefulWidget {
  final DateTime selectedDate;
  final Color backgroundColor; // 배경 색상 추가

  const DiaryPage(
      {Key? key, required this.selectedDate, required this.backgroundColor})
      : super(key: key);

  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late DateTime _selectedDate;
  String _recordingStatus = "마이크 버튼을 누르고 녹음을 시작하세요.";
  bool _isListening = false;
  final SpeechService _speechService = SpeechService();
  final ImageService _imageService = ImageService();
  String _recognizedText = "";
  Uint8List? _imageData;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _speechService.initialize();

    // 애니메이션 컨트롤러 초기화 (깜박임 효과)
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  void _onRecordButtonPressed() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _animationController.repeat(reverse: true); // 녹음 중일 때 애니메이션 반복
        _speechService.startListening((resultText) {
          setState(() {
            _recordingStatus = "$resultText";
            _recognizedText = resultText;
          });
        });
      } else {
        _animationController.stop(); // 녹음 중지 시 애니메이션 중지
        _speechService.stopListening();
        setState(() {
          _recordingStatus = "녹음이 완료되었습니다.";
        });

        _imageService.generateImage(_recognizedText).then((imageUrl) {
          _downloadImage(imageUrl);
        }).catchError((error) {
          setState(() {
            _recordingStatus = "이미지 생성 중 오류 발생: $error";
          });
        });
      }
    });
  }

  Future<void> _downloadImage(String? url) async {
    if (url == null) return;

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _imageData = response.bodyBytes;
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
      backgroundColor: widget.backgroundColor, // 전달받은 배경 색상 사용
      appBar: AppBar(
        backgroundColor: widget.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CalendarPage()),
            );
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
          // 생성된 이미지 표시
          if (_imageData != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.memory(
                  _imageData!,
                  fit: BoxFit.contain, // 이미지가 화면에 맞게 조정되도록 설정
                  width: MediaQuery.of(context).size.width,
                ),
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
          // 마이크 버튼 (애니메이션 추가)
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return IconButton(
                  icon: Icon(
                    Icons.mic,
                    size: 50,
                    color: _isListening
                        ? Colors.red.withOpacity(_animationController.value)
                        : Colors.white,
                  ),
                  onPressed: _onRecordButtonPressed,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
