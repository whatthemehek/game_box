part of 'main.dart';

Function randomizeRhythm (Data boxData) {
  int maxFull = 16;
  int howFull = 0;

  for (int i = 0; i < 4; i++) {
    correctListNames[i].clear();
    correctRhythmNums[i].clear();
    while (howFull != maxFull) {
      int fullLeft = maxFull - howFull;
      var validBlocks = [];
      for (String name in boxData.listOfNames) {
        if (boxData.listOfDurations[boxData.listOfNames.indexOf(name)] <= fullLeft) {
          validBlocks.add(name);
        }
      }
      Random random = new Random();
      int randomBlock = random.nextInt(validBlocks.length - 1);
      correctListNames[i].add(validBlocks[randomBlock]);
      howFull += boxData.listOfDurations[boxData.listOfNames.indexOf(validBlocks[randomBlock])];

    }
    howFull = 0;
  }
  for (int i = 0; i < 4; i++) {
    for (var l in correctListNames[i]) {
      correctRhythmNums[i].addAll(boxData.rhythmArrays[boxData.listOfNames.indexOf(l)]);
    }
  }
}