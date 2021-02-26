part of 'main.dart';

class MeasureBoxWidget extends StatefulWidget {
  final Data boxData;
  final int measureNumber;
  final int duration;
  final Function() notifyParent;
  MeasureBoxWidget({Key key, this.boxData, this.measureNumber, this.duration, @required this.notifyParent}) : super(key: key);
  @override
  MBWidgetState createState() => MBWidgetState(boxData: boxData, measureNumber: measureNumber, duration: duration);
  Widget build(BuildContext context) {

  }
}



void _vibrate(List<int> vibrateRhythm, List<int> boxRhythm) async {
  if (await Vibration.hasVibrator() && await Vibration.hasCustomVibrationsSupport()) {
    vibrateRhythm.clear();
    int rest = 250;
    for (int i = 0; i < boxRhythm.length; i++) {
      if (boxRhythm[i] != 0) {
        vibrateRhythm.add(rest + 10);
        vibrateRhythm.add(boxRhythm[i]*250 - 10);
        i += boxRhythm[i] - 1;
        rest = 0;
      } else {
        rest += 250;
      }
    }
    Vibration.vibrate(pattern: vibrateRhythm);
  }
}

String baseURL = "https://storage.googleapis.com/mehek_box_sounds/sounds_mp3/";

String _canPlay = 'Measure not full: Fill to play';

List<Widget> pulsesUsing = [Container(), Container(), Container(), Container()];

Function loadRhythmNums(int measureNumber, Data boxData, var list, bool isCorrect) {
  if (isCorrect) {
    correctRhythmNums[measureNumber - 1].clear();
    for (var l in list[measureNumber - 1]) {
      correctRhythmNums[measureNumber - 1].addAll(boxData.rhythmArrays[boxData.listOfNames.indexOf(l)]);
      for (int i = 0; i < boxData.rhythmArrays[boxData.listOfNames.indexOf(l)].length; i++) {
        rhythmColorLists[measureNumber - 1].add(boxData.listOfColors[boxData.listOfNames.indexOf(l)]);
      }
    }
  } else {
    boxRhythmNums[measureNumber - 1].clear();
    for (var l in list[measureNumber - 1]) {
      boxRhythmNums[measureNumber - 1].addAll(boxData.rhythmArrays[boxData.listOfNames.indexOf(l)]);
    }
  }
}

List<String> loadListsforPlay(int measureNumber, Data boxData, var list, bool isCorrect) {
  pulseDurations[measureNumber - 1].clear();
  pulseColors[measureNumber - 1].clear();
  rhythmColorLists[measureNumber - 1].clear();
  loadRhythmNums(measureNumber, boxData, list, isCorrect);
  var numslist;
  if (isCorrect) {
    numslist = correctRhythmNums;
  } else {
    numslist = boxRhythmNums;
  }
  //player.clearCache();
  print(numslist);
  List<String> loadAllArray = [];
  double lastTime = 0.0;
  for (int i = 0; i < numslist[measureNumber - 1].length; i++) {
      print("numslist[" + (measureNumber - 1).toString() + "][" + i.toString() + "] =" + numslist[measureNumber - 1][i].toString());
      loadAllArray.add(baseURL+ 'Index'+ (i + 1).toString() + 'Length' + numslist[measureNumber - 1][i].toString() + '.mp3');
      print(loadAllArray);
      pulseDurations[measureNumber - 1].add(lastTime);
      int duration = 0;
      if (numslist[measureNumber - 1][i] != 0) {
        duration = numslist[measureNumber - 1][i];
      } else {
        int j = i;
        bool yes = true;
        while(yes && j < boxData.maxFull) {
          print("index =" +j.toString());
          print("numslist[" + (measureNumber - 1).toString() + "][" + j.toString() + "] =" + numslist[measureNumber - 1][j].toString());
          if (numslist[measureNumber - 1][j] == 0) {
            duration++;
            print(duration);
            j++;
          } else {
            yes = false;
          }
        }
      }
      pulseDurations[measureNumber - 1].add(lastTime + duration / 16.0);
      lastTime = lastTime + duration / 16.0;
      pulseColors[measureNumber - 1].add(rhythmColorLists[measureNumber - 1][i]);
      i = i + duration - 1;
  }
  return(loadAllArray);
}



class MBWidgetState extends State<MeasureBoxWidget> with TickerProviderStateMixin{
  final Data boxData;
  final int measureNumber;
  final int duration;
  bool isButtonEnabled = false;
  MBWidgetState({this.boxData, this.measureNumber, this.duration});
  @override

  int _duration;
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    _duration = widget.duration;
    animationController = AnimationController(
        duration: Duration(milliseconds: _duration),
        vsync: this
    );
  }

  @override
  void didUpdateWidget(MeasureBoxWidget oldWidget) {
    setState(() {
      _duration = widget.duration;
    });

    updateController(oldWidget);
    super.didUpdateWidget(oldWidget);
  }


  void updateController(MeasureBoxWidget oldWidget){
    if(oldWidget.duration != _duration){
      animationController.dispose();
      animationController = AnimationController(duration: Duration(milliseconds: _duration), vsync:this);
    }
  }

  Widget pulser(List<List<double>> pulseDurations, List<List<Color>> pulseColors) {
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

  Function checkIfCorrect() {}

  play(String path) async {
    AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.setUrl(path);
    int result = await audioPlayer.play(path);
  }

  Function _removeRhythm(int indexCurrentList, int indexData) {
    return () {
      setState(() {
        isAccessible = true;
        currentListNames[measureNumber - 1].removeAt(indexCurrentList);
        howFullNums[measureNumber - 1] -= boxData.listOfDurations[indexData];
        widget.notifyParent();
      });
    };
  }



  Widget build(BuildContext context) {
    if (isAccessible) {
      return Container(
          child: Column(
              children: [
                Center(
                  //Draws the box, with the right size
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        pulsesUsing[measureNumber - 1],
                        Container(
                          height: boxData.boxHeight * n,
                          width: boxData.boxWidth * n,
                          decoration: BoxDecoration(
                            color: Color(0xc9c9c9),
                            border: Border.all(
                              color: Colors.white,
                              width: 2 * n,
                            ),
                          ),
                        ),
                        Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),
                            child: Container(
                                height: boxData.boxHeight * n,
                                width: boxData.boxWidth * n,
                                decoration: BoxDecoration(
                                  color: Color(0xc9c9c9),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2 * n,
                                  ),
                                ),
                                // Draws the blocks currently in the box
                                child: Center(
                                    child: Row(
                                      children: [
                                        for (int i = 0; i < currentListNames[measureNumber - 1].length; i++)
                                          Container (
                                              width: boxData.listOfWidths[boxData.listOfNames.indexOf(currentListNames[measureNumber - 1][i])]*n,
                                              height:(boxData.boxHeight - 4)*n,
                                              child: RawMaterialButton(
                                                onPressed: _removeRhythm(i, boxData.listOfNames.indexOf(currentListNames[measureNumber - 1][i])),
                                                padding: EdgeInsets.all(0),
                                                child: Tooltip(message: currentListNames[measureNumber - 1][i],
                                                    child: boxData.listOfContainers[boxData.listOfNames.indexOf(currentListNames[measureNumber - 1][i])]),
                                              )
                                          )
                                      ],
                                    )
                                )
                            )
                        ),
                      ]
                    ),
                ),
              ]
          )
      );
    } else {
      return DragTarget<String>(builder: (BuildContext context, List<String> incoming, List rejected) {
          return Column (
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    pulsesUsing[measureNumber - 1],
                    Container(
                      height: boxData.boxHeight * n,
                      width: boxData.boxWidth * n,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                      ),
                    ),
                    Container (
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                      ),
                      child: Container (
                        height: boxData.boxHeight*n,
                        width: boxData.boxWidth*n,
                        decoration: BoxDecoration(
                          color: Color(0xc9c9c9),
                          border: Border.all(
                            color: Colors.white,
                            width: 2*n,
                          ),
                        ),
                        child: Center ( // Draws the blocks currently in the box
                          child: Row(
                            children: [
                              for (var i in currentListNames[measureNumber - 1])
                              Draggable(
                                child: boxData.listOfContainers[boxData.listOfNames.indexOf(i)],
                                feedback: Material (
                                  child: boxData.listOfContainers[boxData.listOfNames.indexOf(i)],
                                ),
                                childWhenDragging: null,
                                data: ([currentListNames[measureNumber - 1].indexOf(i), measureNumber - 1]),
                              ),
                            ],
                          )
                        )
                      )
                    ),

                  ]
                ),
              ]
          );
        },

        onWillAccept: (data) {
          if (data is String) {
            return (boxData.listOfDurations[boxData.listOfNames.indexOf(data)] + howFullNums[measureNumber - 1] <= boxData.maxFull);
          }
          if (data is int) {
            //
          }
          return false;
        },
        onAccept: (data) {
          setState(() {
            isAccessible = false;
            howFullNums[measureNumber - 1] = boxData.listOfDurations[boxData.listOfNames.indexOf(data)] + howFullNums[measureNumber - 1];
            print(howFullNums[measureNumber - 1]);
            currentListNames[measureNumber - 1].add(data);
            loadRhythmNums(measureNumber, boxData, currentListNames, false);
            widget.notifyParent();
          });
        },
        onLeave: (data) {
        },


      );
    }
  }
}
