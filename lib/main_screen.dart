import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vision_voice/screens/camera_screen.dart';
import 'package:vision_voice/screens/map_screen.dart';
import 'package:vision_voice/screens/voice_screen.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final FlutterTts flutterTts = FlutterTts();
  
  @override
  void initState() {
    super.initState();
    _speakWelcomeMessage();
  }
  
  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
  
  Future<void> _speakWelcomeMessage() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await flutterTts.speak('Vision Voice тиркемесине кош келиңиз. Негизги экранда үч баскыч бар: Карта, Камера жана Микрофон.');
  }
  
  void _navigateWithFeedback(BuildContext context, Widget screen, String buttonName) {
    HapticFeedback.heavyImpact(); // Виброотклик при нажатии
    flutterTts.speak('$buttonName , ачылууда');
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vision Voice',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 4,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.blue.shade50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Кызматты тандаңыз',
                style: TextStyle(
                  fontSize: 32, 
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GridView.count(
                  crossAxisCount: 1,
                  childAspectRatio: 2.5,
                  mainAxisSpacing: 20,
                  children: [
                    // Карта
                    _buildAccessibleButton(
                      context: context,
                      icon: Icons.map,
                      label: 'Карта',
                      color: Colors.green.shade600,
                      onTap: () => _navigateWithFeedback(context, const MapScreen(), 'Карта'),
                    ),
                    
                    // Камера
                    _buildAccessibleButton(
                      context: context,
                      icon: Icons.camera_alt,
                      label: 'Камера',
                      color: Colors.orange.shade600,
                      onTap: () => _navigateWithFeedback(context, const CameraScreen(), 'Камера'),
                    ),
                    
                    // Микрофон
                    _buildAccessibleButton(
                      context: context,
                      icon: Icons.mic,
                      label: 'Микрофон',
                      color: Colors.purple.shade600,
                      onTap: () => _navigateWithFeedback(context, const VoiceScreen(), 'Микрофон'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAccessibleButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      onTapDown: (_) {
        HapticFeedback.mediumImpact();
        flutterTts.speak(label);
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 60,
            ),
            const SizedBox(width: 20),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
