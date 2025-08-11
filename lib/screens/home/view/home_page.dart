import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pawspreferences_afs/screens/home/bloc/home_bloc.dart';
import 'package:pawspreferences_afs/screens/home/model/cat.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pawspreferences_afs/screens/home/view/confetti_effect.dart';

// view page of the app that allow user to indicate interest
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int currentIndex = 0;
  List<Cat> likedCats =
      []; // list to record images of cat that were swiped right
  List<Cat> dislikedCats =
      []; // list to record images of cat that were swiped left
  List<Offset> confettiPositions = [];
  List<Color> confettiColors = [];
  double cardOpacity = 1.0;
  double dragX = 0;
  bool showFeedback = false;
  bool isLiked = false;
  String feedbackText = "";
  late AnimationController _confettiController;
  final Duration fadeDuration = const Duration(seconds: 1);
  final FlutterTts flutterTts =
      FlutterTts(); // instance to use text to speech functionality

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(() {
        setState(() {
          _updateConfetti();
        });
      });

    // Delay confetti generation until after build to get screen size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateConfetti();
    });
  }

// dispose to avoid memory leak
  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paws Preference")),
      floatingActionButton: FloatingActionButton(
        onPressed: _showFabMenu,
        child: const Icon(Icons.pets),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is LoadFetchCatImage) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ErrorFetchCatImage) {
            return Center(child: Text(state.message));
          } else if (state is SuccessFetchCatImage) {
            final images =
                state.images; // success state that emits list of images
            final currentCat = images[currentIndex];

            return Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() => dragX += details.delta.dx);
                      },
                      onHorizontalDragEnd: (details) {
                        if (dragX > 50) {
                          _handleSwipe(true, currentCat, images.length);
                        } else if (dragX < -50) {
                          _handleSwipe(false, currentCat, images.length);
                        }
                        setState(() => dragX = 0);
                      },
                      child: Center(
                          child: AnimatedOpacity(
                        opacity: cardOpacity,
                        duration: fadeDuration,
                        child: AnimatedContainer(
                          height: MediaQuery.of(context).size.height *
                              0.6, // the card should not exceed more than 60 percent of the device screen height
                          width: MediaQuery.of(context).size.width *
                              0.6, // the card should not exceed more than 60 percent of device width
                          duration: const Duration(milliseconds: 100),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 6,
                              color: _getBorderColor(),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Image.network(
                            currentCat.imgUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      // label to show current progress
                      "${currentIndex + 1}/${images.length}",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),

                // Feedback overlay
                if (showFeedback)
                  Center(
                    child: AnimatedOpacity(
                      opacity: showFeedback ? 1 : 0,
                      duration: const Duration(milliseconds: 100),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isLiked ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          feedbackText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Confetti
                if (_confettiController.isAnimating)
                  CustomPaint(
                    size: Size(
                      MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height,
                    ),
                    painter: ConfettiEffect(confettiPositions, confettiColors),
                  ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

// show a interactive green when user gesture reach to like and red when reach to red
  Color _getBorderColor() {
    if (dragX > 0) {
      return Colors.green.withValues(alpha: (dragX / 100).clamp(0.0, 1.0));
    } else if (dragX < 0) {
      return Colors.red.withValues(alpha: (-dragX / 100).clamp(0.0, 1.0));
    }
    return Colors.white;
  }

// function to handle swipe left and right
  void _handleSwipe(bool liked, Cat cat, int total) {
    if (liked) {
      likedCats.add(cat);
      _showFeedbackText("Liked", true);
    } else {
      dislikedCats.add(cat);
      _showFeedbackText("Disliked", false);
    }

    // Fade out
    setState(() => cardOpacity = 0.0);

    Future.delayed(fadeDuration, () {
      _nextCat(total);
      // Fade in after switching
      setState(() => cardOpacity = 1.0);
    });
  }

  void _showFeedbackText(String text, bool liked) {
    setState(() {
      showFeedback = true;
      feedbackText = text;
      isLiked = liked;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        showFeedback = false;
      });
    });
  }

// function to push next stack
  void _nextCat(int total) {
    setState(() {
      if (currentIndex < total - 1) {
        currentIndex++;
      } else {
        _triggerCompletion();
      }
    });
  }

  void _triggerCompletion() {
    _confettiController.forward(from: 0).whenComplete(() {
      _showFinalDialog();
    });
  }

// floating action button that reside at bottom right that allow accessing features
  void _showFabMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text("Restart"),
            onTap: () {
              setState(() {
                currentIndex = 0;
                likedCats.clear();
                dislikedCats.clear();
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text("See Progress"),
            onTap: () {
              Navigator.pop(context);
              _showCurrentLikesDislikes();
            },
          ),
          ListTile(
            leading: const Icon(Icons.volume_up),
            title: const Text("Read Instructions"),
            onTap: () {
              Navigator.pop(context);
              _speakInstructions();
            },
          ),
        ],
      ),
    );
  }

  void _showCurrentLikesDislikes() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Your Preferences"),
        content: Text(
            "Liked: ${likedCats.length}\nDisliked: ${dislikedCats.length}"),
        actions: [
          TextButton(
              onPressed: () => {Navigator.pop(context)},
              child: const Text("Return")),
        ],
      ),
    );
  }

  void _showFinalDialog() {
    // Combine liked and disliked into one sequence in original order
    final allCats = [...likedCats, ...dislikedCats];
    // Map likedCats to a set for grouped view
    final likedSet = likedCats.toSet();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("All Done!"),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: allCats.length,
            itemBuilder: (context, index) {
              final cat = allCats[index];
              final isLiked = likedSet.contains(cat);
              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      cat.imgUrl,
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                  Container(
                    color: isLiked
                        ? Colors.green.withValues(alpha: 0.4)
                        : Colors.red.withValues(alpha: 0.4),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Icon(
                      isLiked ? Icons.star : Icons.star_border_outlined,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                currentIndex = 0;
                likedCats.clear();
                dislikedCats.clear();
              });
              Navigator.pop(context);
            },
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }

// function that trigger text to speech functionality
  Future<void> _speakInstructions() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.8); // slower for clarity
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
// content to speak
    await flutterTts.speak(
        "Welcome to Paws Preference. Kindly swipe right to indicate your interest, "
        "and swipe left if not. You may complete upto 15 images in single session to get your daily summary");
  }

  // function to generate confetti animation on full screen upon completing 15 images
  void _generateConfetti() {
    final random = Random();
    final size = MediaQuery.of(context).size; // get device screen size
    confettiPositions = List.generate(
      100,
      (_) => Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      ),
    );
    confettiColors = List.generate(
      100,
      (_) => Colors.primaries[random.nextInt(Colors.primaries.length)],
    );
  }

// animate position of confetti
  void _updateConfetti() {
    final random = Random();
    final height = MediaQuery.of(context).size.height;
    confettiPositions = confettiPositions.map((pos) {
      double dy = pos.dy + random.nextDouble() * 5;
      if (dy > height) dy = 0; // reset to top
      return Offset(pos.dx, dy);
    }).toList();
  }
}
