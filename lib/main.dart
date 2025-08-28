import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  LlamaParent? _llamaParent;
  StreamSubscription<String>? _streamSubscription;
  bool _isModelLoading = true;
  bool _isGenerating = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    try {
      final modelPath = await _getModelPath();
      final loadCommand = LlamaLoad(
        path: modelPath,
        modelParams: ModelParams()
          ..nGpuLayers = 0
          ..vocabOnly = false
          ..useMemoryLock = false
          ..useMemorymap = true,
        contextParams: ContextParams()
          ..nCtx = 2048
          ..nBatch = 512
          ..nUbatch = 512
          ..nThreads = -1
          ..embeddings = false,
        samplingParams: SamplerParams()
          ..topK = 40
          ..topP = 0.95
          ..minP = 0.05
          ..temp = 0.7
          ..penaltyRepeat = 1.1
          ..seed = -1,
        format: ChatMLFormat(),
      );

      _llamaParent = LlamaParent(loadCommand);
      await _llamaParent!.init();

      _streamSubscription = _llamaParent!.stream.listen(
            (token) {
          if (!_isDisposed && mounted && token.isNotEmpty) {
            setState(() {
              if (_messages.isNotEmpty && _messages.last.startsWith("Bot: ")) {
                _messages[_messages.length - 1] += token;
              } else {
                _messages.add("Bot: $token");
              }
            });
          }
        },
        onError: (error) {
          if (!_isDisposed && mounted) {
            setState(() {
              _messages.add("Error: Stream error - $error");
              _isGenerating = false;
            });
          }
        },
        onDone: () {
          if (!_isDisposed && mounted) {
            setState(() {
              _isGenerating = false;
            });
          }
        },
      );

      if (!_isDisposed && mounted) {
        setState(() {
          _isModelLoading = false;
        });
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _isModelLoading = false;
          _messages.add("Error: Failed to load model - $e");
        });
      }
    }
  }

  Future<String> _getModelPath() async {
    if (Platform.isAndroid) {
      if (!await Permission.manageExternalStorage.isGranted) {
        final status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          openAppSettings();
          throw Exception("Storage permission denied. Please allow 'All files access'.");
        }
      }
    }
    final modelPath = "/sdcard/Download/Phi-3-mini-4k-instruct-q4.gguf";
    final file = File(modelPath);
    if (!await file.exists()) {
      throw Exception(
        "Model file not found at $modelPath.\n"
            "Please push it using adb:\n"
            "adb push Phi-3-mini-4k-instruct-q4.gguf /sdcard/Download/",
      );
    }
    return file.path;
  }

  Future<void> _sendMessage(String prompt) async {
    if (_llamaParent == null || _isGenerating || _isDisposed) return;
    try {
      setState(() {
        _messages.add("You: $prompt");
        _isGenerating = true;
      });

      // Prevent race condition
      await Future.delayed(const Duration(milliseconds: 100));

      if (!_isDisposed && mounted) {
        _llamaParent!.sendPrompt(prompt);
        await Future.delayed(const Duration(seconds: 2));
        if (!_isDisposed && mounted) {
          setState(() {
            _isGenerating = false;
          });
        }
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _messages.add("Error: Failed to send message - $e");
          _isGenerating = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _streamSubscription?.cancel();
    _controller.dispose();
    Future.delayed(const Duration(milliseconds: 100), () {
      _llamaParent?.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isModelLoading ? "Loading Phi-3 Model..." : "Phi-3 Local Chat",
        ),
        backgroundColor: _isModelLoading ? Colors.orange : Colors.blue,
      ),
      body: Column(
        children: [
          if (_isModelLoading) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: _messages[i].startsWith("You: ")
                      ? Colors.blue[100]
                      : Colors.grey[100],
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      _messages[i],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isGenerating) const Padding(
            padding: EdgeInsets.all(8.0),
            child: LinearProgressIndicator(),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !_isModelLoading && !_isGenerating && !_isDisposed,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (text) {
                      final trimmedText = text.trim();
                      if (trimmedText.isNotEmpty && !_isDisposed) {
                        _controller.clear();
                        _sendMessage(trimmedText);
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isModelLoading || _isGenerating || _isDisposed
                      ? null
                      : () {
                    final t = _controller.text.trim();
                    if (t.isNotEmpty) {
                      _controller.clear();
                      _sendMessage(t);
                    }
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
