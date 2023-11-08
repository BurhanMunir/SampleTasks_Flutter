import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/public/flutter_sound_player.dart';
import 'package:flutter_sound_lite/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioPage extends StatefulWidget {
  const AudioPage({super.key});

  @override
  State<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> {
  final recorder = SoundRecorder();
  final player = SoundPlayer();
  @override
  void initState() {
    super.initState();
    recorder.init();
    player.init();
  }

  @override
  void dispose() {
    super.dispose();
    recorder.dispose();
    player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildStart(),
            const SizedBox(
              height: 20,
            ),
            buildPlay()
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: const Text("Audio Recorder"),
      ),
    );
  }

  Widget buildStart() {
    final isRecording = recorder.isRecording;
    var icon = isRecording ? Icons.stop : Icons.mic;
    final text = isRecording ? "Stop" : "Record";
    final background = isRecording ? Colors.orangeAccent : Colors.white;
    final foreground = isRecording ? Colors.white : Colors.black;

    return ElevatedButton.icon(
      onPressed: () async {
        final isRecording = await recorder.toggleRecording();
        setState(() {});
      },
      style: ElevatedButton.styleFrom(
          minimumSize: const Size(175, 50),
          backgroundColor: background,
          foregroundColor: foreground),
      icon: Icon(icon),
      label: Text(text),
    );
  }

  Widget buildPlay() {
    final isPlaying = player.isPlaying;
    final icon = isPlaying ? Icons.stop : Icons.play_arrow;
    final text = isPlaying ? 'Stop Playing' : 'Start Playing';
    return ElevatedButton.icon(
      onPressed: () async {
        await player.togglePlaying(whenFinished: () => setState(() {}));
        setState(() {});
      },
      style: ElevatedButton.styleFrom(
          minimumSize: const Size(175, 50),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black),
      icon: Icon(icon),
      label: Text(text),
    );
  }
}

const pathToSaveAudio = "sample_audio.aac";

class SoundRecorder {
  FlutterSoundRecorder? _audioRecorder;
  bool isRecorderInitialized = false;
  bool get isRecording => _audioRecorder!.isRecording;
  Future init() async {
    _audioRecorder = FlutterSoundRecorder();

    final permissionStatus = await Permission.microphone.request();
    if (permissionStatus != PermissionStatus.granted) {
      throw Exception();
    }
    _audioRecorder!.openAudioSession();
    isRecorderInitialized = true;
  }

  void dispose() {
    if (!isRecorderInitialized) return;
    _audioRecorder!.closeAudioSession();
    _audioRecorder = null;
    isRecorderInitialized = false;
  }

  Future _record() async {
    if (!isRecorderInitialized) return;
    await _audioRecorder!.startRecorder(toFile: pathToSaveAudio);
  }

  Future _stop() async {
    if (!isRecorderInitialized) return;
    await _audioRecorder!.stopRecorder();
  }

  Future toggleRecording() async {
    if (_audioRecorder!.isStopped) {
      await _record();
    } else {
      await _stop();
    }
  }
}

class SoundPlayer {
  FlutterSoundPlayer? _audioPlayer;
  bool get isPlaying => _audioPlayer!.isPlaying;

  Future init() async {
    _audioPlayer = FlutterSoundPlayer();
    await _audioPlayer!.openAudioSession();
  }

  void dispose() {
    _audioPlayer!.closeAudioSession();
    _audioPlayer = null;
  }

  Future _play(VoidCallback whenFinished) async {
    await _audioPlayer!
        .startPlayer(fromURI: pathToSaveAudio, whenFinished: whenFinished);
  }

  Future _stop() async {
    await _audioPlayer!.stopPlayer();
  }

  Future togglePlaying({required VoidCallback whenFinished}) async {
    if (_audioPlayer!.isStopped) {
      await _play(whenFinished);
    } else {
      await _stop();
    }
  }
}
