import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../widgets/glass.dart';
import '../widgets/glossy_shapes.dart';

// Shown on the very first launch only.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: GlowBackground(
        child: Stack(
          children: [
            // Two big bubbles that run off the edges of the screen.
            const Positioned(top: -70, right: -110, child: GlossyOrb(size: 330)),
            const Positioned(top: 250, left: -90, child: GlossyOrb(size: 250)),
            const Positioned(top: 190, right: 60, child: GlossySparkle(size: 56)),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Text('ROUGH IDEAS.\nSHARP\nPROMPTS.', style: theme.textTheme.displaySmall),
                    const SizedBox(height: 16),
                    Text(
                      'Type what you mean, messy is fine. Whetstone turns it into a prompt any AI assistant can follow.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => context.read<SettingsProvider>().finishWelcome(),
                        child: const Text('Get Started'),
                      ),
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
}
