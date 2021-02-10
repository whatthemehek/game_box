part of 'main.dart';

Future<void> _showCorrectDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Congratulations! You matched the rhythm correctly'),
        actions: <Widget>[
          TextButton(
            child: Text('Next Rhythm!'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> _showIncorrectDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Not quite...'),
        actions: <Widget>[
          TextButton(
            child: Text('Keep Trying'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}