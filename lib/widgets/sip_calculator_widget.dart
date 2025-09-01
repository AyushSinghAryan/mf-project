// lib/widgets/sip_calculator_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class SipCalculatorWidget extends StatefulWidget {
  const SipCalculatorWidget({super.key});

  @override
  _SipCalculatorWidgetState createState() => _SipCalculatorWidgetState();
}

class _SipCalculatorWidgetState extends State<SipCalculatorWidget> {
  // Controllers for all input fields, matching the JS version
  final _monthlySipController = TextEditingController(text: '40000');
  final _currentAmountController = TextEditingController(text: '1000000');
  final _tenureController = TextEditingController(text: '3');
  final _returnRateController = TextEditingController(text: '16');
  final _inflationRateController = TextEditingController(
    text: '4',
  ); // Corrected default value from screenshot

  // State variables to hold all calculated results
  double _nominalValue = 0.0;
  double _realValue = 0.0;
  double _totalInvestment = 0.0;
  double _nominalWealthGained = 0.0;
  double _realWealthGained = 0.0;
  double _realReturnRate = 0.0;

  // Indian Rupee currency formatter
  final currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _monthlySipController.addListener(_calculateSip);
    _currentAmountController.addListener(_calculateSip);
    _tenureController.addListener(_calculateSip);
    _returnRateController.addListener(_calculateSip);
    _inflationRateController.addListener(_calculateSip);
    _calculateSip(); // Perform initial calculation
  }

  /// This is the Dart translation of your JavaScript calculateSIP function.
  void _calculateSip() {
    final double monthlyInvestment =
        double.tryParse(_monthlySipController.text) ?? 0.0;
    final double currentAmount =
        double.tryParse(_currentAmountController.text) ?? 0.0;
    final double years = double.tryParse(_tenureController.text) ?? 0.0;
    final double returnRate =
        double.tryParse(_returnRateController.text) ?? 0.0;
    final double inflationRate =
        double.tryParse(_inflationRateController.text) ?? 0.0;

    if (years <= 0 && currentAmount <= 0 && monthlyInvestment <= 0) {
      setState(() {
        _nominalValue = 0;
        _realValue = 0;
        _totalInvestment = 0;
        _nominalWealthGained = 0;
        _realWealthGained = 0;
        _realReturnRate = 0;
      });
      return;
    }

    // --- Perform Calculations ---
    final double realReturnRate =
        (((1 + returnRate / 100) / (1 + inflationRate / 100)) - 1) * 100;
    final double monthlyNominalRate = (returnRate / 100) / 12;
    final double monthlyRealRate = (realReturnRate / 100) / 12;
    final double months = years * 12;

    // --- FIX IS HERE: The SIP formula now matches the JavaScript version ---
    final double nominalSipAmount = (months > 0 && monthlyNominalRate > 0)
        ? monthlyInvestment *
              (pow(1 + monthlyNominalRate, months) - 1) /
              monthlyNominalRate *
              (1 + monthlyNominalRate) // <-- This part was missing
        : 0;
    final double nominalFutureValueOfCurrent =
        currentAmount * pow(1 + (returnRate / 100), years);
    final double nominalTotalValue =
        nominalSipAmount + nominalFutureValueOfCurrent;

    final double realSipAmount = (months > 0 && monthlyRealRate > 0)
        ? monthlyInvestment *
              (pow(1 + monthlyRealRate, months) - 1) /
              monthlyRealRate *
              (1 + monthlyRealRate) // <-- This part was missing
        : 0;
    final double realFutureValueOfCurrent =
        currentAmount * pow(1 + (realReturnRate / 100), years);
    final double realTotalValue = realSipAmount + realFutureValueOfCurrent;
    // --- END OF FIX ---

    final double totalInvestment = (monthlyInvestment * months) + currentAmount;
    final double nominalWealthGained = nominalTotalValue - totalInvestment;
    final double realWealthGained = realTotalValue - totalInvestment;

    setState(() {
      _nominalValue = nominalTotalValue;
      _realValue = realTotalValue;
      _totalInvestment = totalInvestment;
      _nominalWealthGained = nominalWealthGained;
      _realWealthGained = realWealthGained;
      _realReturnRate = realReturnRate;
    });
  }

  @override
  void dispose() {
    _monthlySipController.dispose();
    _currentAmountController.dispose();
    _tenureController.dispose();
    _returnRateController.dispose();
    _inflationRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We no longer use a Card, allowing the content to fill the screen.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Input Fields Section ---
        Text(
          'Investment Details',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _monthlySipController,
                label: "Monthly SIP (₹)",
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _currentAmountController,
                label: "Lump Sum (₹)",
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _tenureController,
                label: "Years",
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _returnRateController,
                label: "Return (%)",
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _inflationRateController,
                label: "Inflation (%)",
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // --- Results Display Section ---
        Text(
          'Projected Value',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildMainResult("Nominal Value", _nominalValue),
                    const VerticalDivider(width: 32),
                    _buildMainResult(
                      "Real Value",
                      _realValue,
                      isRealValue: true,
                    ),
                  ],
                ),
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSubResult("Total Investment", _totalInvestment),
                  _buildSubResult(
                    "Nominal Wealth Gained",
                    _nominalWealthGained,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSubResult("Real Wealth Gained", _realWealthGained),
                  _buildSubResult(
                    "Real Return Rate",
                    _realReturnRate,
                    isPercentage: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _buildMainResult(
    String label,
    double value, {
    bool isRealValue = false,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            currencyFormat.format(value),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isRealValue
                  ? Theme.of(context).primaryColorDark
                  : Theme.of(context).primaryColor,
            ),
          ),
          const Spacer(),
          Text(
            isRealValue ? "Adjusted for inflation" : "Before inflation",
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSubResult(
    String label,
    double value, {
    bool isPercentage = false,
  }) {
    final bool isPositive = value >= 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 2),
        Text(
          isPercentage
              ? '${value.toStringAsFixed(2)}%'
              : currencyFormat.format(value),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isPositive ? Colors.green.shade800 : Colors.red.shade800,
          ),
        ),
      ],
    );
  }
}
