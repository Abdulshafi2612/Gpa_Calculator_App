import 'package:flutter/material.dart';

/// Client-side target GPA calculator — no backend endpoint needed.
/// Uses the same logic from the old app.
class TargetScreen extends StatefulWidget {
  final double cgpa;
  final double credits;

  const TargetScreen({
    super.key,
    required this.cgpa,
    required this.credits,
  });

  @override
  State<TargetScreen> createState() => _TargetScreenState();
}

class _TargetScreenState extends State<TargetScreen> {
  final _targetGpaController = TextEditingController();
  final _currentCreditsController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _targetGpaController.dispose();
    _currentCreditsController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _calculate() {
    final targetText = _targetGpaController.text.trim();
    final creditsText = _currentCreditsController.text.trim();

    if (targetText.isEmpty || creditsText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fields cannot be empty!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final targetGpa = double.tryParse(targetText);
    final currentCredits = double.tryParse(creditsText);

    if (targetGpa == null ||
        currentCredits == null ||
        targetGpa > 4 ||
        currentCredits <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Invalid input: Target GPA must be ≤ 4 and Credits must be > 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final requiredGpa = ((targetGpa * (widget.credits + currentCredits)) -
            (widget.cgpa * widget.credits)) /
        currentCredits;

    if (requiredGpa > 4) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color.fromARGB(255, 76, 158, 226),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'You would need a ${requiredGpa.toStringAsFixed(2)} GPA, which exceeds 4.0. This target is not achievable with these credits.',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'BauhausStd',
              fontSize: 20,
            ),
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color.fromARGB(255, 76, 158, 226),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text:
                      'Your GPA this semester needs to be ${requiredGpa.toStringAsFixed(2)} or higher.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'BauhausStd',
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text(
            'Know Your Target',
            style: TextStyle(
              fontSize: 25,
              fontFamily: 'BauhausStd',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/Untitled-1.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.white.withValues(alpha: 0.9),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Your CGPA = ${widget.cgpa.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 25,
                          fontFamily: 'BauhausStd',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        'Your credits = ${widget.credits.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 25,
                          fontFamily: 'BauhausStd',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 25),
                      TextFormField(
                        controller: _targetGpaController,
                        keyboardType: TextInputType.number,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_focusNode),
                        decoration: InputDecoration(
                          label: const Center(child: Text('Target GPA')),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      TextFormField(
                        focusNode: _focusNode,
                        controller: _currentCreditsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          label: const Center(child: Text('Current Credits')),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        onPressed: _calculate,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue.withValues(alpha: 0.8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Calculate',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'BauhausStd',
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
