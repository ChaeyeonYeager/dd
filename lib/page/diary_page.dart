import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

class _DiaryPageState extends State<DiaryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late DateTime _selectedDate;
  String _recordingStatus = "마이크 버튼을 누르고 녹음을 시작하세요";
  bool _isListening = false;
  final SpeechService _speechService = SpeechService();
  final ImageService _imageService = ImageService();
  String _recognizedText = "";
  Uint8List? _imageData;
  bool _isLoading = true; // 로딩 상태를 나타내는 플래그 추가

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool isSaving = false; // 저장 상태를 나타내는 플래그 추가

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _speechService.initialize();
    _loadDiaryEntry(); // 페이지 로드 시 일기 항목 불러오기
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      _isLoading = true; // 날짜 변경 시 로딩 상태로 설정
      _loadDiaryEntry(); // 날짜 변경 시 일기 항목 다시 로드
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
      _speechService.stopListening();
      setState(() {
        _recordingStatus = "녹음 중지됨. 마이크 버튼을 눌러 다시 시작하세요.";
      });

      // 이미지 생성 및 다운로드 로직 추가
      _createAndDownloadImage();
    }
  }

  void _createAndDownloadImage() {
    setState(() {
      _recordingStatus = "이미지를 생성하는 중입니다..."; // 이미지 생성 중 메시지 표시
    });

    _imageService.generateImage(_recognizedText).then((imageUrl) {
      _downloadImage(imageUrl);
    }).catchError((error) {
      setState(() {
        _recordingStatus = "이미지 생성 중 오류 발생: $error";
      });
    });
  }

  Future<void> _downloadImage(String? url) async {
    if (url == null) return;

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _imageData = response.bodyBytes;
          _recordingStatus = "이미지 생성 완료"; // 이미지 생성 완료 메시지
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

  // Firebase Storage에 이미지 저장 및 Firestore에 날짜와 URL 저장
  Future<void> _saveImageToFirebase() async {
    if (_imageData == null) return;

    setState(() {
      isSaving = true; // 저장 시작
      _recordingStatus = "저장중..."; // 저장 중 메시지 표시
    });

    try {
      // Firebase Storage에 이미지 업로드
      String fileName = '${_selectedDate.toIso8601String()}.png';
      Reference ref = _storage.ref().child('diary_images/$fileName');
      UploadTask uploadTask = ref.putData(_imageData!);

      // 이미지 업로드 완료를 기다림
      TaskSnapshot snapshot = await uploadTask;

      // 업로드된 이미지 URL 가져오기
      String imageUrl = await snapshot.ref.getDownloadURL();

      // Firestore에 날짜와 이미지 URL 저장
      await _firestore.collection('diary_entries').add({
        'date': _selectedDate.toIso8601String(),
        'imageUrl': imageUrl,
        'text': _recognizedText, // 텍스트도 함께 저장
      });

      // 상태 업데이트
      setState(() {
        _recordingStatus = "저장 완료되었습니다!"; // 저장 완료 메시지 표시
      });
    } catch (e) {
      setState(() {
        _recordingStatus = "이미지 저장 중 오류 발생: $e";
      });
    } finally {
      setState(() {
        isSaving = false; // 저장 완료
      });
    }
  }

  // Firestore에서 저장된 텍스트 및 이미지를 가져오는 메서드
  Future<void> _loadDiaryEntry() async {
    try {
      final querySnapshot = await _firestore
          .collection('diary_entries')
          .where('date', isEqualTo: _selectedDate.toIso8601String())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final diaryEntry = querySnapshot.docs.first.data();
        setState(() {
          _recognizedText = diaryEntry['text'] ?? "";
          _recordingStatus = "일기 항목 로드 완료"; // 로드 완료 메시지
          // 이미지 데이터 로드 추가
          _loadImageFromUrl(diaryEntry['imageUrl']);
        });
      } else {
        setState(() {
          _recordingStatus = "새로운 일기를 작성하세요."; // 새 일기 메시지
        });
      }
    } catch (e) {
      print('일기 항목 로드 중 오류 발생: $e');
    } finally {
      setState(() {
        _isLoading = false; // 로딩 완료
      });
    }
  }

  Future<void> _loadImageFromUrl(String? url) async {
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
      print('이미지 로드 중 오류 발생: $e');
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
          // 로딩 중일 때 로딩 인디케이터 표시
          if (_isLoading)
            Center(child: CircularProgressIndicator())
          else
            // 이미지와 텍스트가 있을 경우 표시
            Column(
              children: [
                if (_imageData != null) Image.memory(_imageData!),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _recognizedText.isNotEmpty
                        ? _recognizedText
                        : "아직 작성된 내용이 없습니다.",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(height: 20),
                // 녹음 버튼
                ElevatedButton(
                  onPressed: _onRecordButtonPressed,
                  child: Text(_isListening ? "녹음 중지" : "녹음 시작"),
                ),
                // 저장 버튼이 보이도록 설정
                ElevatedButton(
                  onPressed: isSaving ? null : _saveImageToFirebase,
                  child: Text(isSaving ? "저장 완료!" : "저장하기"),
                ),
                // 녹음 상태 메시지 표시
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _recordingStatus,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
