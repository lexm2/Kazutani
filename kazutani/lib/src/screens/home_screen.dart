import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'Kazutani',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 72,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 2.0,
                        ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 50.0,
                  left: 24.0,
                  right: 24.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ModernButton(
                      onPressed: () => Navigator.pushNamed(context, '/game'),
                      text: 'Play Game',
                      isPrimary: true,
                    ),
                    const SizedBox(height: 16),
                    ModernButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/settings'),
                      text: 'Settings',
                      isPrimary: false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ModernButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isPrimary;

  const ModernButton({
    required this.onPressed,
    required this.text,
    required this.isPrimary,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 30, // Reduced height
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          foregroundColor: isPrimary
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Fully rounded corners
            side: isPrimary
                ? BorderSide.none
                : BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5, // Slightly thinner border
                  ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16, // Slightly smaller font
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
