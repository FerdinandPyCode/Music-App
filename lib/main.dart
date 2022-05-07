import 'dart:async';
import 'package:flutter/material.dart';
import 'Musiques.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FerdiMusic',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'FerdiMusic'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Musique> maListeDeMusiques =[
    Musique("FerdiPyBoss", "La joie de flutter",'Images/deux.png', 'Musiques/iphone.mp3'),
    Musique("Ferd'Son", "Le code est doux",'Images/trois.jpg', 'https://codabee.com/wp-content/uploads/2018/06/deux.mp3')
  ];

  late Musique maMusiqueActuelle;
  Duration position = new Duration(seconds: 0);
  late AudioPlayer audioPlayer;
  late StreamSubscription positionSub;
  late StreamSubscription stateSubscription;
  Duration duree = new Duration(seconds: 10);
  playerState statut = playerState.stopped;

  @override
  void initState() {
    super.initState();
    maMusiqueActuelle = maListeDeMusiques[1];
    configurationAudioPLayer();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(
            widget.title,
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        elevation:7.5 ,

      ),
      backgroundColor: Colors.grey[700],
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Card(
              elevation: 7.5,
              child: Container(
                width: MediaQuery.of(context).size.height / 2.5,
                child: Image.asset(maMusiqueActuelle.imagePath,fit: BoxFit.cover,),
              ),
            ),

            textAvecStyle(maMusiqueActuelle.titre,1.50),
            textAvecStyle(maMusiqueActuelle.artiste, 1.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                bouton(Icons.fast_rewind,30.0, ActionMusic.rewind),
                bouton((statut==playerState.playing) ? Icons.pause:Icons.play_arrow,45.0, (statut==playerState.playing) ? ActionMusic.pause:ActionMusic.play),
                bouton(Icons.fast_forward,30.0, ActionMusic.forward)
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textAvecStyle("0:0", 0.8),
                textAvecStyle("0:32", 0.8)
              ],
            ),
            Slider(
                value: position.inSeconds.toDouble(),
                min:0.0,
                max: 30.0,
                inactiveColor: Colors.white,
                activeColor: Colors.red,
                onChanged:(double d){
                  setState(() {
                    Duration nouvelleDuration = new Duration(seconds: d.toInt());
                    position=nouvelleDuration;
                  });
                }
            )
          ],
        ),
      ),
    );
  }

  IconButton bouton(IconData icone,double taille,ActionMusic action){

        return IconButton(
            onPressed:(){
              switch(action){
                case ActionMusic.play:
                  //play();/*maMusiqueActuelle.urlSong*/
                  audioPlayer.play("Musiques/iphone.mp3",isLocal: true);
                  setState(() {
                    statut=playerState.playing;
                  });
                  break;
                case ActionMusic.forward:
                  print("Forward");
                  break;
                case ActionMusic.rewind:
                  print("Rewind");
                  break;
                case ActionMusic.pause:
                  print("Pause");
                  break;
              }
            },
            iconSize: taille,
            color: Colors.white,
            icon: new Icon(icone)
        );
  }

  Text textAvecStyle(String data,double scale){

    return Text(
        data,
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontStyle: FontStyle.italic
      ),
    );
  }

    void configurationAudioPLayer(){
     audioPlayer=new AudioPlayer();
     positionSub=audioPlayer.onAudioPositionChanged.listen(
             (pos) =>setState(() =>position=pos)
             );
     stateSubscription=audioPlayer.onAudioPositionChanged.listen((state) {
       if(state  == playerState.playing){
         setState(() {
           //****************************************************************************
           duree=audioPlayer.getDuration() as Duration;
         });
       }else if (state== playerState.stopped){
         setState(() {
           statut=playerState.stopped;
         });
       }
     },
     onError: (message){
       print("Erreur : $message");
       setState(() {
         statut=playerState.stopped;
         duree= new Duration(seconds: 0);
         position = new Duration(seconds: 0);
       });
     }
     );
    }

    Future play() async{
    await audioPlayer.play(maMusiqueActuelle.urlSong);
    setState(() {
      statut=playerState.playing;
    });
    }
  Future pause() async{
    await audioPlayer.pause();
    setState(() {
      statut=playerState.paused;
    });
  }
}
enum ActionMusic{
  play,
  rewind,
  pause,
  forward
}

enum playerState{
  playing,
  stopped,
  paused
}