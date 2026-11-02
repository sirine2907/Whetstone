import 'package:flutter/foundation.dart';

// Holds the selected bottom tab so any screen can jump to another one.
class NavProvider extends ChangeNotifier {
  int index = 0;

  void goTo(int newIndex) {
    index = newIndex;
    notifyListeners();
  }

  void goToSharpen() => goTo(0);
}
