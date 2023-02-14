import 'package:driver_vm/page/page.dart';
import 'package:driver_vm/routes/screen_arguments.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const routeName = '/HomePage';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: 'vi');
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords.toLowerCase();
    });
    _speechToText.stop();
    checkLastWord(_lastWords);
  }

  void checkLastWord(String lastWords) {
    switch (lastWords) {
      case 'nguyễn văn tuấn':
        Navigator.pushNamed(context, DriverMapPage.routeName,
            arguments: ScreenArguments(
                arg1: 10.7943793,
                arg2: 106.7013374,
                arg3: '222 Phan Văn Hân',
                arg4: 'Nguyễn Văn Tuấn',
                arg5: 'assets/img/user.jpg'));
        break;
      case 'lê minh việt':
        Navigator.pushNamed(context, DriverMapPage.routeName,
            arguments: ScreenArguments(
                arg1: 11.940501,
                arg2: 108.4232936,
                arg3: 'Đà lạt, Lâm Đồng',
                arg4: 'Lê Minh Việt',
                arg5: 'assets/img/user2.jpg'));
        break;
      case 'tài xế 14':
        Navigator.pushNamed(context, DrawMapPage.routeName,
            arguments: ScreenArguments(
                arg1: 21.0278409,
                arg2: 105.7991402,
                arg3: 'Hà Nội, Hoàn Kiếm, Việt Nam',
                arg4: 'Tài xế 14',
                arg5: 'assets/img/user2.jpg'));
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tìm kiếm vị trí tài xế'.toUpperCase(),
          style: const TextStyle(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Tên được ghi nhận',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                _lastWords.isNotEmpty
                    ? _lastWords
                    : '',
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  _speechToText.isListening
                      ? ''
                      : _speechEnabled
                          ? 'Nhấn microphone để ghi âm...'
                          : 'Không có bản ghi âm',
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            // _speechToText.isNotListening ? _startListening : _stopListening,
        () {
          Navigator.pushNamed(context, DrawMapPage.routeName,
              arguments: ScreenArguments(
                  arg1: 21.0278409,
                  arg2: 105.7991402,
                  arg3: 'Hà Nội, Hoàn Kiếm, Việt Nam',
                  arg4: 'Tài xế 14',
                  arg5: 'assets/img/user2.jpg'));
        },
        tooltip: 'Listen',
        child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}
