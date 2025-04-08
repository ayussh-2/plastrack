import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/trash_report_model.dart';
import '../services/trash_report_service.dart';

class TrashReportResultScreen extends StatelessWidget {
  final TrashClassificationResponse report;
  final TrashReportService _reportService = TrashReportService();

  TrashReportResultScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.backgroundColor1, AppTheme.backgroundColor2],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 15.0,
              bottom: 15.0,
              left: 20.0,
              right: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Waste Classification',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image preview
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            report.image,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return SizedBox(
                                height: 200,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                (loadingProgress
                                                        .expectedTotalBytes ??
                                                    1)
                                            : null,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey.shade300,
                                child: const Center(
                                  child: Icon(Icons.error_outline, size: 50),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Material and Confidence
                        _buildMaterialSection(report),

                        const SizedBox(height: 24),

                        // Report sections
                        Text(
                          'Waste Classification Results',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Main classification details
                        _buildSectionCard(
                          title: 'Classification',
                          content:
                              'Material: ${report.material}\nConfidence: ${report.confidence}%',
                          icon: Icons.category,
                        ),

                        _buildSectionCard(
                          title: 'Recyclability',
                          content: report.recyclability,
                          icon: Icons.recycling,
                        ),

                        // Infrastructure suitability
                        _buildInfrastructureSuitabilitySection(
                          report.infrastructureSuitability,
                        ),

                        // Environmental impact
                        _buildEnvironmentalImpactSection(
                          report.environmentalImpact,
                        ),

                        // Notes
                        if (report.notes.isNotEmpty)
                          _buildSectionCard(
                            title: 'Additional Notes',
                            content: report.notes,
                            icon: Icons.note,
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Feedback button
                ElevatedButton.icon(
                  onPressed: () => _showFeedbackModal(context),
                  icon: const Icon(Icons.feedback),
                  label: const Text('Add Feedback'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Navigation Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.home),
                        label: const Text('Home'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialSection(TrashClassificationResponse report) {
    Color confidenceColor;
    if (report.confidence >= 80) {
      confidenceColor = Colors.green;
    } else if (report.confidence >= 50) {
      confidenceColor = Colors.orange;
    } else {
      confidenceColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            report.material,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: report.confidence / 100,
                    backgroundColor: Colors.grey.shade200,
                    color: confidenceColor,
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${report.confidence}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: confidenceColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Confidence Level',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildInfrastructureSuitabilitySection(
    Map<String, dynamic> suitability,
  ) {
    if (suitability.isEmpty) {
      return Container();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.build, color: AppTheme.primaryColor, size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Construction Reuse Potential',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          ...suitability.entries.map((entry) {
            // Convert snake_case to Title Case
            final formattedKey = entry.key
                .split('_')
                .map(
                  (word) =>
                      word.isEmpty
                          ? ''
                          : '${word[0].toUpperCase()}${word.substring(1)}',
                )
                .join(' ');

            // Get value as integer
            final value =
                entry.value is int
                    ? entry.value
                    : (entry.value is double
                        ? entry.value.toInt()
                        : int.tryParse(entry.value.toString()) ?? 0);

            // Choose color based on value
            Color progressColor;
            if (value >= 70) {
              progressColor = Colors.green;
            } else if (value >= 40) {
              progressColor = Colors.amber;
            } else {
              progressColor = Colors.grey;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formattedKey, style: const TextStyle(fontSize: 14)),
                      Text(
                        '$value%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: value / 100,
                      backgroundColor: Colors.grey.shade200,
                      color: progressColor,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalImpactSection(Map<String, dynamic> impact) {
    if (impact.isEmpty) {
      return Container();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.eco, color: AppTheme.primaryColor, size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Environmental Impact',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Repurposing this waste could save:',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Vertical list of impact metrics
          ...impact.entries.map((entry) {
            // Convert snake_case to Title Case
            final formattedKey = entry.key
                .split('_')
                .map(
                  (word) =>
                      word.isEmpty
                          ? ''
                          : '${word[0].toUpperCase()}${word.substring(1)}',
                )
                .join(' ');

            // Get value
            final value =
                entry.value is int
                    ? entry.value
                    : (entry.value is double
                        ? entry.value.toInt()
                        : int.tryParse(entry.value.toString()) ?? 0);

            // Get appropriate icon based on metric name
            IconData metricIcon = Icons.eco;
            String unit = 'kg';

            if (formattedKey.toLowerCase().contains('landfill')) {
              metricIcon = Icons.delete_outline;
            } else if (formattedKey.toLowerCase().contains('co2') ||
                formattedKey.toLowerCase().contains('carbon')) {
              metricIcon = Icons.cloud_outlined;
            } else if (formattedKey.toLowerCase().contains('water')) {
              metricIcon = Icons.water_drop_outlined;
            } else if (formattedKey.toLowerCase().contains('energy')) {
              metricIcon = Icons.bolt_outlined;
              unit = 'kWh';
            }

            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(metricIcon, size: 24, color: Colors.grey.shade700),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      formattedKey,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$value $unit',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Future<void> _showFeedbackModal(BuildContext context) async {
    final TextEditingController feedbackController = TextEditingController();
    bool isSubmitting = false;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add Your Feedback',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Let us know if our classification is correct or if you have any suggestions:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: feedbackController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Enter your feedback here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            isSubmitting
                                ? null
                                : () async {
                                  if (feedbackController.text.trim().isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please enter feedback'),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    isSubmitting = true;
                                  });

                                  final success = await _submitFeedback(
                                    context,
                                    report.id,
                                    feedbackController.text.trim(),
                                  );

                                  if (success && context.mounted) {
                                    Navigator.pop(context);
                                  }

                                  setState(() {
                                    isSubmitting = false;
                                  });
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child:
                            isSubmitting
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text('Send Feedback'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _submitFeedback(
    BuildContext context,
    int reportId,
    String feedback,
  ) async {
    try {
      final result = await _reportService.submitFeedback(reportId, feedback);

      if (result['success'] == true) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thank you for your feedback!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return true;
      } else {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Feedback Error'),
                content: Text(result['message'] ?? 'Failed to submit feedback'),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              );
            },
          );
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text('An unexpected error occurred: $e'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      }
      return false;
    }
  }
}
