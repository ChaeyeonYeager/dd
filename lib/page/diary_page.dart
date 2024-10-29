import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'calendar_page.dart';
import 'speech_service.dart';
import 'image_service.dart';
import 'drawer_menu.dart';

class DiaryPage extends StatefulWidget {
  final DateTime selectedDate;
  final Color backgroundColor;

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
  bool _isLoading = true;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool isSaving = false;

  Color _backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _backgroundColor = widget.backgroundColor;
    _speechService.initialize();
    _loadDiaryEntry();
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      _isLoading = true;
      _loadDiaryEntry();
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

      _createAndDownloadImage();
    }
  }

  void _createAndDownloadImage() {
    setState(() {
      _recordingStatus = "이미지를 생성하는 중입니다...";
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
          _recordingStatus = "이미지 생성 완료";
        });
      } else {
        throw Exception('이미지 다운로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _recordingStatus = "이미지 다운로드 중 오류 발생: $e";
      });
    }
  }

  Future<void> _saveImageToFirebase() async {
    if (_imageData == null) return;

    setState(() {
      isSaving = true;
      _recordingStatus = "저장중...";
    });

    try {
      String fileName = '${_selectedDate.toIso8601String()}.png';
      Reference ref = _storage.ref().child('diary_images/$fileName');
      UploadTask uploadTask = ref.putData(_imageData!);

      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();

      await _firestore.collection('diary_entries').add({
        'date': _selectedDate.toIso8601String(),
        'imageUrl': imageUrl,
        'text': _recognizedText,
        'backgroundColor': {
          'red': _backgroundColor.red,
          'green': _backgroundColor.green,
          'blue': _backgroundColor.blue,
        }
      });

      setState(() {
        _recordingStatus = "저장 완료되었습니다!";
      });
    } catch (e) {
      setState(() {
        _recordingStatus = "이미지 저장 중 오류 발생: $e";
      });
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

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
          _recordingStatus = "일기 항목 로드 완료";

          final bgColor = diaryEntry['backgroundColor'];
          if (bgColor != null) {
            _backgroundColor = Color.fromRGBO(
              bgColor['red'],
              bgColor['green'],
              bgColor['blue'],
              1.0,
            );
          }
          _loadImageFromUrl(diaryEntry['imageUrl']);
        });
      } else {
        setState(() {
          _recordingStatus = "새로운 일기를 작성하세요.";
        });
      }
    } catch (e) {
      print('일기 항목 로드 중 오류 발생: $e');
    } finally {
      setState(() {
        _isLoading = false;
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
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
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
          Expanded(
            child: Column(
              children: [
                Expanded(
                  flex: 6,
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _imageData != null
                          ? Image.memory(_imageData!)
                          : Center(child: Text("생성된 이미지가 없습니다")),
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      Text(
                        _recognizedText,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        _recordingStatus,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  _isListening ? Icons.mic_off : Icons.mic,
                  color: Colors.white,
                ),
                onPressed: _onRecordButtonPressed,
                iconSize: 40,
              ),
              IconButton(
                icon: Icon(
                  isSaving ? Icons.check : Icons.save,
                  color: Colors.white,
                ),
                onPressed: isSaving ? null : _saveImageToFirebase,
                iconSize: 40,
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
