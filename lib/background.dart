part of 'main.dart';

class BackgroundWidget extends StatefulWidget {
  @override
  //BackgroundWidget({Key key}) : super(key: key);
  final Data boxData;
  BackgroundWidget({this.boxData});
  BackgroundWidgetState createState() => BackgroundWidgetState(boxData: boxData);
  Widget build(BuildContext context) {

  }
}


class BackgroundWidgetState extends State<BackgroundWidget> with TickerProviderStateMixin{
  final Data boxData;
  BackgroundWidgetState({this.boxData});
  @override


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

  Function check(int measureNumber) {
    return () {
        List<String> loadAllArray = loadListsforPlay(measureNumber, boxData);
        player.play('metronome.wav');
        _vibrate(vibrateRhythmNums[measureNumber - 1],
            boxRhythmNums[measureNumber - 1]);
        //var duration = await player.setUrl('https://storage.googleapis.com/mehek_box_sounds/sounds/Index11Length2.wav');
        setState(() {
          //player.play();
          for (String j in loadAllArray) {
            player.play(j);
          }
          setState(() {
            pulsesUsing[measureNumber - 1] = pulser(pulseDurations, pulseColors, measureNumber);
          });
          Future.delayed(Duration(milliseconds: 4000), () {
            setState(() {
              pulsesUsing[measureNumber - 1] = Container();
            });
          });
        });
      };
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
                          child: MeasureBoxWidget(boxData: boxData, measureNumber: i+1, duration: 1000)
                      )
                  ]
              ),
              IconButton(
                iconSize: 80.0,
                icon: Icon(Icons.check_circle),
                color: Colors.green,
                disabledColor: Colors.grey,
                onPressed: check(1),
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
              howFullNums[data[1]] = howFullNums[data[1]] - boxData.listOfDurations[boxData.listOfNames.indexOf(currentListNums[data[1]][data[0]])];
              currentListNums[data[1]].removeAt(data[0]);
            });
          },
          onLeave: (data) {

          }
      ),
    );
  }
}