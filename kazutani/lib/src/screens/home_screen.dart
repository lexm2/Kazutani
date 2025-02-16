import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /*late VideoPlayerController _controller; */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background video will go here
          // FutureBuilder(
          //   future: _initializeVideoPlayerFuture,
          //   builder: (context, snapshot) {
          //     return VideoPlayer(_controller);
          //   },
          // ),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Kazutani',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(5, 5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                CustomInkButton(
                  onPressed: () => Navigator.pushNamed(context, '/game'),
                  text: 'Play Game',
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 30),
                CustomInkButton(
                  onPressed: () => Navigator.pushNamed(context, '/settings'),
                  text: 'Settings',
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomInkButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final Color color;

  const CustomInkButton({
    required this.onPressed,
    required this.text,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha((0.3 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipPath(
        clipper: InkStrokeClipper(),
        child: Material(
          color: color,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 15,
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InkStrokeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Create an irregular, brush-stroke-like shape
    path.moveTo(0, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.2,
      0,
      size.width * 0.35,
      size.height * 0.15,
    );
    path.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.25,
      size.width,
      size.height * 0.2,
    );
    path.lineTo(size.width, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height,
      size.width * 0.6,
      size.height * 0.85,
    );
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.75,
      0,
      size.height * 0.8,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
