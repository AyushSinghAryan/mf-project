import 'package:flutter/material.dart';
import 'package:flutter_investeeks_app/widgets/sip_calculator_widget.dart';

class SipCalculatorScreen extends StatelessWidget {
  const SipCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SIP Calculator'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: SipCalculatorWidget(),
      ),
    );
  }
}
