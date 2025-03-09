import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color backgroundColor = Colors.blue;
  final List<String> labels = ['DP', 'SP', 'MP1', 'BP', 'MP2', 'EP'];
  final Map<String, String> descriptions = {
    'DP': 'Draw Phase',
    'SP': 'Standby Phase',
    'MP1': 'Main Phase 1',
    'BP': 'Battle Phase',
    'MP2': 'Main Phase 2',
    'EP': 'End Phase'
  };
  String currentPhase = 'Select a Phase';
  bool isRotated = false;
  int turnCount = 1;
  String activePhase = 'DP';
  bool isLocked = false;
  Map<String, bool> phaseEnabled = {
    'DP': true,
    'SP': false,
    'MP1': false,
    'BP': false,
    'MP2': false,
    'EP': false,
  };

  void updatePhase(String phase) {
    if (!phaseEnabled[phase]! || isLocked) return;

    setState(() {
      currentPhase = descriptions[phase] ?? 'Select a Phase';
      activePhase = phase;
      phaseEnabled[phase] = false;
      if (phase == 'DP') {
        phaseEnabled['SP'] = true;
      } else if (phase == 'SP') {
        phaseEnabled['MP1'] = true;
      } else if (phase == 'MP1') {
        phaseEnabled['BP'] = true;
        phaseEnabled['EP'] = true;
      } else if (phase == 'BP') {
        phaseEnabled['MP2'] = true;
      } else if (phase == 'MP2') {
        phaseEnabled['EP'] = true;
      }
    });

    if (phase == 'EP') {
      setState(() {
        isLocked = true;
        phaseEnabled = {
          'DP': false,
          'SP': false,
          'MP1': false,
          'BP': false,
          'MP2': false,
          'EP': false,
        };
      });
      Future.delayed(const Duration(milliseconds: 750), () {
        setState(() {
          isRotated = !isRotated;
          backgroundColor = backgroundColor == Colors.blue ? Colors.red : Colors.blue;
          currentPhase = 'Your Turn!';
          turnCount++;
          activePhase = 'DP';
          phaseEnabled = {
            'DP': true,
            'SP': false,
            'MP1': false,
            'BP': false,
            'MP2': false,
            'EP': false,
          };
        });
      }).then((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          setState(() {
            isLocked = false;
          });
        });
      });
    }
  }

  void resetGame() {
    setState(() {
      turnCount = 1;
      backgroundColor = Colors.blue;
      currentPhase = 'Select a Phase';
      activePhase = 'DP';
      isLocked = false;
      phaseEnabled = {
        'DP': true,
        'SP': false,
        'MP1': false,
        'BP': false,
        'MP2': false,
        'EP': false,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: backgroundColor,
        body: Stack(
          children: [
            Center(
              child: AnimatedRotation(
                turns: isRotated ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 750),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        'Turn Count: $turnCount',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        currentPhase,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) =>
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                updatePhase(labels[index]);
                              },
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: phaseEnabled[labels[index]]! ? Colors.white : Colors.grey,
                                  border: Border.all(color: Colors.black, width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    labels[index],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: labels[index] == 'BP' ? Colors.red : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: resetGame,
                      child: const Text(
                        'Reset',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(
              bottom: 10,
              right: 10,
              child: Text(
                'Made by Xhines',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}