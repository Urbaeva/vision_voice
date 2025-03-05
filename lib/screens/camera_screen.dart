import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isProcessing = false;
  final FlutterTts flutterTts = FlutterTts();
  String _analysisResult = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _speakWelcomeMessage() async {
    await flutterTts.speak('Камера активирована. Нажмите на большую кнопку внизу экрана для анализа окружения.');
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      await flutterTts.speak('Камера недоступна на вашем устройстве.');
      return;
    }

    final CameraController cameraController = CameraController(
      cameras[0],
      ResolutionPreset.high,
    );

    await cameraController.initialize();
    if (!mounted) return;

    setState(() {
      _controller = cameraController;
      _isInitialized = true;
    });
    _speakWelcomeMessage();
  }

  @override
  void dispose() {
    _controller?.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _analyzeImage(XFile image) async {
    setState(() {
      _isProcessing = true;
      _analysisResult = '';
    });

    HapticFeedback.mediumImpact(); // Виброотклик при начале анализа
    await flutterTts.speak('Анализ окружения...');

    try {
      // Имитация отправки изображения на бэкенд
      // В реальном приложении здесь будет код для отправки изображения на сервер
      final response = await _sendImageToBackend(image);
      
      setState(() {
        _isProcessing = false;
        _analysisResult = response;
      });
      
      // Виброотклик при получении результата
      HapticFeedback.heavyImpact();
      
      // Озвучиваем результат анализа
      await flutterTts.speak(response);
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _analysisResult = 'Ошибка при анализе изображения: $e';
      });
      
      // Виброотклик при ошибке (двойной)
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 300));
      HapticFeedback.heavyImpact();
      
      await flutterTts.speak('Произошла ошибка при анализе изображения.');
    }
  }

  // Имитация отправки изображения на бэкенд
  Future<String> _sendImageToBackend(XFile image) async {
    // Здесь должен быть реальный код для отправки изображения на сервер
    // Для демонстрации возвращаем фиктивный ответ
    await Future.delayed(const Duration(seconds: 2)); // Имитация задержки сети
    
    // Примеры ответов от бэкенда
    final List<String> possibleResponses = [
      'Перед вами дверь. Расстояние примерно 2 метра.',
      'Перед вами стол с чашкой кофе и ноутбуком.',
      'Перед вами человек, стоящий на расстоянии примерно 3 метра.',
      'Перед вами лестница, ведущая вниз. Будьте осторожны.',
      'Перед вами пешеходный переход. Светофор показывает красный свет.',
    ];
    
    // Возвращаем случайный ответ из списка
    return possibleResponses[DateTime.now().second % possibleResponses.length];
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Камера',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.orange.shade600,
          elevation: 4,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 32, color: Colors.white),
            onPressed: () {
              HapticFeedback.mediumImpact();
              flutterTts.speak('Возвращаемся на главный экран');
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Container(
          color: Colors.black,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 5,
                ),
                SizedBox(height: 30),
                Text(
                  'Активация камеры...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Камера',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.orange.shade600,
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32, color: Colors.white),
          onPressed: () {
            HapticFeedback.mediumImpact();
            flutterTts.speak('Возвращаемся на главный экран');
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          // Область предпросмотра камеры на весь экран
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CameraPreview(_controller!),
          ),
          
          // Полупрозрачная инструкция для пользователя
          if (!_isProcessing && _analysisResult.isEmpty)
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  'Нажмите на кнопку внизу для анализа окружения',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          
          // Индикатор обработки
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 5,
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Анализ окружения...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Пожалуйста, подождите',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Результат анализа
          if (_analysisResult.isNotEmpty && !_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 80,
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Результат анализа:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        _analysisResult,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Кнопка для повторного озвучивания
                        _buildActionButton(
                          icon: Icons.volume_up,
                          label: 'Повторить',
                          color: Colors.blue,
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            flutterTts.speak(_analysisResult);
                          },
                        ),
                        // Кнопка для нового анализа
                        _buildActionButton(
                          icon: Icons.camera_alt,
                          label: 'Новый анализ',
                          color: Colors.orange,
                          onTap: () async {
                            HapticFeedback.heavyImpact();
                            setState(() {
                              _analysisResult = '';
                            });
                            flutterTts.speak('Готов к новому анализу. Нажмите на кнопку для съемки.');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          
          // Кнопка для съемки фото
          if (!_isProcessing && _analysisResult.isEmpty)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () async {
                    HapticFeedback.heavyImpact(); // Виброотклик при нажатии
                    if (!_isProcessing && _controller != null) {
                      try {
                        final image = await _controller!.takePicture();
                        _analyzeImage(image);
                      } catch (e) {
                        HapticFeedback.vibrate();
                        flutterTts.speak('Ошибка при съемке фото');
                      }
                    }
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.orange,
                        width: 5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 50,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}