import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../presentation.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, this.routeName, this.path});

  final Object error;
  final String? routeName;
  final String? path;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final styles = AppStyles.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: colors.attitudeErrorMain),
              const SizedBox(height: 24),
              Text(
                'Page Not Found',
                style: styles.heading20Bold.copyWith(color: colors.textColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'The page you are looking for could not be found.',
   style: styles.body16Regular.copyWith(color: colors.textColor.withValues(alpha: 179)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (routeName != null) ...[
                _buildInfoSection(context, 'Route', routeName!, Icons.route_rounded),
                const SizedBox(height: 16),
              ],
              if (kDebugMode) ...[
                if (path != null) ...[
                  _buildInfoSection(context, 'Path', path!, Icons.link_rounded),
                  const SizedBox(height: 16),
                ],
                _buildInfoSection(context, 'Error', error.toString(), Icons.bug_report_rounded),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 32),
              AppButton.primary(label: 'Go Back', onPressed: () => Navigator.of(context).pop()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, String value, IconData icon) {
    final colors = AppColors.of(context);
    final styles = AppStyles.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.grey100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.grey300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: colors.grey700),
              const SizedBox(width: 8),
              Text(title, style: styles.label14Regular.copyWith(color: colors.grey700)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: styles.body14Regular.copyWith(color: colors.textColor)),
        ],
      ),
    );
  }
}
