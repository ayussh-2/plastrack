import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:waste2ways/config/theme.dart';
import 'package:waste2ways/models/report_model.dart';
import 'package:waste2ways/services/report_list_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ReportListService _reportService = ReportListService();
  late Future<List<Report>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = _reportService.getUserReports();
  }

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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'My Reports',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                const SizedBox(height: 24),

                // Reports list
                Expanded(
                  child: FutureBuilder<List<Report>>(
                    future: _reportsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 60,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load reports',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    // Fixed: changed from named parameter to positional parameter
                                    _reportsFuture =
                                        _reportService.getUserReports();
                                  });
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      final reports = snapshot.data ?? [];

                      if (reports.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppTheme.primaryColor,
                                size: 60,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'You haven\'t submitted any reports yet',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: reports.length,
                        itemBuilder: (context, index) {
                          final report = reports[index];
                          return ReportCard(report: report);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final Report report;

  const ReportCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    // Parse AI Response JSON
    Map<String, dynamic> aiData = {};
    try {
      aiData = json.decode(report.aiResponse);
    } catch (e) {
      print('Error parsing AI response: $e');
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Report image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Image.network(
              report.image,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.grey[500],
                    size: 50,
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                    ),
                  ),
                );
              },
            ),
          ),

          // Report details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        report.trashType.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getSeverityColor(report.severity),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Severity: ${report.getSeverityText()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Reported on ${report.getFormattedDate()}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),

                // Enhanced AI Analysis Section
                ExpansionTile(
                  initiallyExpanded: true,
                  title: const Text(
                    'AI Analysis',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child:
                          aiData.isNotEmpty
                              ? _buildAiAnalysisContent(aiData)
                              : Text(report.aiResponse),
                    ),
                  ],
                ),

                // Feedback section if exists
                if (report.feedback != null && report.feedback!.isNotEmpty) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Your Feedback:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      report.feedback!,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // New method to build the structured AI analysis content
  Widget _buildAiAnalysisContent(Map<String, dynamic> aiData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Material and Confidence Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                  children: [
                    const TextSpan(
                      text: 'Material: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: aiData['material']?.toString() ?? 'Unknown'),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(aiData['confidence']),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Confidence: ${aiData['confidence']}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Recyclability
        RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black, fontSize: 15),
            children: [
              const TextSpan(
                text: 'Recyclability: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: aiData['recyclability']?.toString() ?? 'Unknown',
                style: TextStyle(
                  color: _getRecyclabilityColor(aiData['recyclability']),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Infrastructure Suitability Section
        const Text(
          'Infrastructure Suitability',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),

        if (aiData['infrastructure_suitability'] != null) ...[
          ...aiData['infrastructure_suitability'].entries.map((entry) {
            final double percentage =
                (entry.value is num) ? (entry.value as num).toDouble() : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatInfrastructureName(entry.key),
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[200],
                    color: _getPercentageColor(percentage),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
            );
          }).toList(),
        ],

        const SizedBox(height: 20),

        // Environmental Impact Section
        const Text(
          'Environmental Impact',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),

        if (aiData['environmental_impact'] != null) ...[
          Row(
            children: [
              Expanded(
                child: _buildEnvironmentalImpactCard(
                  'Landfill Reduction',
                  '${aiData['environmental_impact']['landfill_reduction']?.toString() ?? '0'} kg',
                  Icons.delete_outline,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildEnvironmentalImpactCard(
                  'CO₂ Reduction',
                  '${aiData['environmental_impact']['co2_reduction']?.toString() ?? '0'} kg',
                  Icons.co2,
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 16),

        // Notes Section
        if (aiData['notes'] != null) ...[
          const Text(
            'Notes:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            aiData['notes'].toString(),
            style: TextStyle(color: Colors.grey[800], fontSize: 14),
          ),
        ],
      ],
    );
  }

  // Helper widget for environmental impact cards
  Widget _buildEnvironmentalImpactCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.green[700], size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper method to format infrastructure names
  String _formatInfrastructureName(String name) {
    return name
        .split('_')
        .map((word) => word.substring(0, 1).toUpperCase() + word.substring(1))
        .join(' ');
  }

  // Helper method to get color based on confidence percentage
  Color _getConfidenceColor(dynamic confidence) {
    if (confidence == null) return Colors.grey;

    final conf = confidence is num ? confidence.toDouble() : 0.0;
    if (conf >= 80) return Colors.green;
    if (conf >= 60) return Colors.orange;
    return Colors.red;
  }

  // Helper method to get color based on recyclability status
  Color _getRecyclabilityColor(dynamic recyclability) {
    if (recyclability == null) return Colors.grey;

    switch (recyclability.toString().toLowerCase()) {
      case 'recyclable':
        return Colors.green;
      case 'partially recyclable':
        return Colors.orange;
      case 'not recyclable':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper method to get color based on percentage value
  Color _getPercentageColor(double percentage) {
    if (percentage >= 70) return Colors.green;
    if (percentage >= 40) return Colors.orange;
    return Colors.red;
  }

  Color _getSeverityColor(int severity) {
    switch (severity) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
