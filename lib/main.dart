import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pawspreferences_afs/screens/home/bloc/home_bloc.dart';
import 'package:pawspreferences_afs/screens/home/view/home_page.dart';
// an web app that allow to indicate interest on cat images
// very minimal use of external package
// uses MVC structure and bloc on state management
// uses external packages of
// flutter_bloc on state management
// flutter tts for text to speech function

void main() {
  runApp(const PawsPreferenceApp());
}

class PawsPreferenceApp extends StatelessWidget {
  const PawsPreferenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paws Preference',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: BlocProvider(
        create: (_) => HomeBloc()
          ..add(
              FetchCatImage()), // dispatch event to fetch cat images using bloc
        child: const HomePage(),
      ),
    );
  }
}
