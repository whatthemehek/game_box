part of 'main.dart';

class BackgroundWidget extends StatefulWidget {
  @override
  final Data boxData;
  BackgroundWidget({this.boxData});
  BackgroundWidgetState createState() => BackgroundWidgetState(boxData: boxData);
  Widget build(BuildContext context) {

  }
}


class BackgroundWidgetState extends State<BackgroundWidget> with TickerProviderStateMixin{
  final Data boxData;
  bool isCheckEnabled = false;
  BackgroundWidgetState({this.boxData});
  @override

  refresh() {
    setState(() {});
  }

  Widget pulser(List<List<double>> pulseDurations, List<List<Color>> pulseColors, int measureNumber) {
    return Stack(
      children: [
        for (int i = 0; i < pulseColors[measureNumber - 1].length; i++)
          SpinKitPulse(
            color: pulseColors[measureNumber - 1][i],
            size: 400.0,
            intervalOne: pulseDurations[measureNumber - 1][i*2],
            intervalTwo: pulseDurations[measureNumber - 1][i*2 + 1],
            controller: AnimationController(
              vsync: this,
              duration: Duration(milliseconds: 4000),
            ),
          )
      ],
    );
  }

  play(String path) async {
    AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.setUrl(path);
    int result = await audioPlayer.play(path);
  }

  Function _enablePlayButton(int measuresOpen) {
    return () {
        for (int measureNumber = 0; measureNumber < measuresOpen; measureNumber++) {
          Future.delayed(Duration(milliseconds: 4000*measureNumber), () {
            List<String> loadAllArray = loadListsforPlay(measureNumber+1, boxData, correctListNames);
            play(baseURL + 'metronome.mp3');
            _vibrate(vibrateRhythmNums[measureNumber],
                boxRhythmNums[measureNumber]);
            //var duration = await player.setUrl('https://storage.googleapis.com/mehek_box_sounds/sounds/Index11Length2.wav');
            setState(() {
              for (String j in loadAllArray) {
                play(j);
              }
              setState(() {
                pulsesUsing[measureNumber] = pulser(pulseDurations, pulseColors, measureNumber+1);
              });
              Future.delayed(Duration(milliseconds: 4000), () {
                setState(() {
                  pulsesUsing[measureNumber] = Container();
                });
              });
            });
          });
        }
      };
  }

  Function checkIfCorrect(int measuresOpen) {
    isCheckEnabled = (howFullNums[0] == boxData.maxFull);
    if (isCheckEnabled) {
      return () {
        bool isCorrect = true;
        for (int i = 0; i < measuresOpen; i++) {
          if (!listEquals(boxRhythmNums[i], correctRhythmNums[i])) {
            print(correctRhythmNums[i]);
            print(boxRhythmNums[i]);
            isCorrect = false;
          }
        }
        if (isCorrect) {
          print("correct");
          randomizeRhythm(boxData);
        } else {
          print('wrong, current: ' + boxRhythmNums.toString() +
              ", correct: " + correctRhythmNums.toString());
        }
      };
    } else {
      return null;
    }
  }

  Widget build(BuildContext context) {
    return Container (
      child: DragTarget<List<int>>
        (builder: (BuildContext context, List<List<int>> incoming, List rejected) {
        return Column (
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row (
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int i = 0; i < howFullNums.length; i++)
                      Center (
                          child: MeasureBoxWidget(boxData: boxData, measureNumber: i+1, duration: 1000, notifyParent: refresh)
                      )
                  ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    iconSize: 80.0,
                    icon: Icon(Icons.play_circle_filled),
                    color: Colors.blue,
                    disabledColor: Colors.grey,
                    onPressed: _enablePlayButton(howFullNums.length),
                  ),
                  IconButton(
                    iconSize: 80.0,
                    icon: Icon(Icons.check_circle),
                    color: Colors.green,
                    disabledColor: Colors.grey,
                    onPressed: checkIfCorrect(howFullNums.length),
                  )
                ]
              ),
              Expanded(
                  child: Container (
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.blue,
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 50.0,
                    ),
                  )
              )
            ]
        );
      },

          onAccept: (data) {
            setState(() {
              successfulDropNums[data[1]] = true;
              howFullNums[data[1]] = howFullNums[data[1]] - boxData.listOfDurations[boxData.listOfNames.indexOf(currentListNames[data[1]][data[0]])];
              currentListNames[data[1]].removeAt(data[0]);
            });
          },
          onLeave: (data) {

          }
      ),
    );
  }
}