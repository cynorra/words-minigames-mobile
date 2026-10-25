import 'dart:convert';
import 'package:http/http.dart' as http;

/// Email service for sending feedback using EmailJS
class EmailService {
  static const String _baseUrl = 'https://api.emailjs.com/api/v1.0/email/send';
  static const String _serviceId = 'service_hvcaxpl';
  static const String _templateId = 'template_pywbd26';
  static const String _userId = 'Uaxh0LXEKAnp1a26V';

  /// Sends feedback email using EmailJS service
  static Future<bool> sendFeedback({
    required String category,
    required String title,
    required String description,
    String? userEmail,
  }) async {
    try {
      final templateParams = {
        'user_subject': 'Quicko Feedback: $category - $title',
        'user_message': '''
Category: $category
Title: $title

Description:
$description

${userEmail != null && userEmail.isNotEmpty ? 'Contact Email: $userEmail' : ''}

---
Sent from Quicko App
''',
        'user_name':
            userEmail != null && userEmail.isNotEmpty
                ? userEmail
                : 'Anonymous User',
        'email':
            userEmail != null && userEmail.isNotEmpty
                ? userEmail
                : 'noreply@quicko.app',
      };

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'service_id': _serviceId,
          'template_id': _templateId,
          'user_id': _userId,
          'template_params': templateParams,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw EmailServiceException('Failed to send email: $e');
    }
  }
}

/// Exception thrown when email service fails
class EmailServiceException implements Exception {
  final String message;
  EmailServiceException(this.message);

  @override
  String toString() => message;
}
