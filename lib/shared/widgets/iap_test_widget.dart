import 'package:flutter/material.dart';
import 'package:quicko_app/core/services/in_app_purchase_service.dart';

class IAPTestWidget extends StatefulWidget {
  const IAPTestWidget({super.key});

  @override
  State<IAPTestWidget> createState() => _IAPTestWidgetState();
}

class _IAPTestWidgetState extends State<IAPTestWidget> {
  final InAppPurchaseService _iapService = InAppPurchaseService();
  String _testResult = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'In-App Purchase Test',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _runTest,
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Test Connection'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testPurchase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Test Purchase'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_testResult.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      _testResult.contains('❌')
                          ? Colors.red.shade100
                          : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _testResult,
                  style: TextStyle(
                    color:
                        _testResult.contains('❌')
                            ? Colors.red.shade800
                            : Colors.green.shade800,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Product ID: ${_iapService.currentProductId}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              'Platform: ${_iapService.isAvailable ? "Available" : "Not Available"}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runTest() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
    });

    try {
      final result = await _iapService.quickTest();
      setState(() {
        _testResult = result;
      });
    } catch (e) {
      setState(() {
        _testResult = 'Test error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testPurchase() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
    });

    try {
      final success = await _iapService.purchaseAdFreeSubscription();
      setState(() {
        _testResult =
            success
                ? '✅ Purchase initiated successfully!'
                : '❌ Purchase failed. Check console for details.';
      });
    } catch (e) {
      setState(() {
        _testResult = 'Purchase error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
