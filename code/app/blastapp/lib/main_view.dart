import 'package:blastapp/blast_router.dart';
import 'package:flutter/material.dart';

class MainView extends StatelessWidget {            
  
  // make sure you don't initiate your router                
  // inside of the build function.                
  final _appRouter = BlastRouter();

  MainView({super.key});            
            
  @override            
  Widget build(BuildContext context){            
    return MaterialApp.router(            
      routerConfig: _appRouter.config(),         
    );            
  }            
}      