import 'package:blastapp/blast_router.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

class MainView extends StatelessWidget {            
  
  // make sure you don't initiate your router                
  // inside of the build function.                
  final _appRouter = BlastRouter();

  MainView({super.key});            
            
  @override            
  Widget build(BuildContext context){            
    return LoaderOverlay(   
      useDefaultLoading: false,
      overlayWidgetBuilder: (_) {
        return const Center(child: CircularProgressIndicator());       
      },
      overlayColor: Colors.yellow.shade200.withOpacity(0.8),
      child: MaterialApp.router(            
      routerConfig: _appRouter.config(),
      )         
    );            
  }            
}      