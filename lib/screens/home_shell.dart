import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/nav_provider.dart';
import '../providers/sharpen_provider.dart';
import '../theme.dart';
import '../widgets/glass.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'sharpen_screen.dart';
import 'templates_screen.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavProvider>();

    const screens = [SharpenScreen(), TemplatesScreen(), HistoryScreen(), SettingsScreen()];

    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // On a wide window the content stays a readable width.
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: IndexedStack(index: nav.index, children: screens),
                ),
              ),
              const Positioned(left: 20, right: 20, bottom: 14, child: _PillNavBar()),
            ],
          ),
        ),
      ),
    );
  }
}

// The tab bar floats over the screen as a frosted pill, with a round
// "new prompt" button next to it.
class _PillNavBar extends StatelessWidget {
  const _PillNavBar();

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavProvider>();

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Row(
          children: [
            Expanded(
              child: GlassCard(
                radius: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _NavIcon(
                      index: 0,
                      icon: Icons.home_rounded,
                      label: 'Sharpen',
                      selected: nav.index == 0,
                    ),
                    _NavIcon(
                      index: 1,
                      icon: Icons.grid_view_rounded,
                      label: 'Templates',
                      selected: nav.index == 1,
                    ),
                    _NavIcon(
                      index: 2,
                      icon: Icons.history_rounded,
                      label: 'History',
                      selected: nav.index == 2,
                    ),
                    _NavIcon(
                      index: 3,
                      icon: Icons.person_outline_rounded,
                      label: 'Settings',
                      selected: nav.index == 3,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            RoundIconButton(
              icon: Icons.edit_outlined,
              tooltip: 'New prompt',
              size: 62,
              onPressed: () {
                context.read<SharpenProvider>().loadDraft('');
                context.read<NavProvider>().goToSharpen();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.index,
    required this.icon,
    required this.label,
    required this.selected,
  });

  final int index;
  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final glass = GlassColors.of(context);

    return Tooltip(
      message: label,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => context.read<NavProvider>().goTo(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? glass.bubble : Colors.transparent,
          ),
          child: Icon(icon, size: 23, color: selected ? colors.onSurface : colors.onSurfaceVariant),
        ),
      ),
    );
  }
}
