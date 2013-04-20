// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:math' as Math;
import 'calcui.dart';
import 'dart:async';

Set numberKeyPresses;
Set operatorKeyPresses;
Set equalKeyPresses;
Set clearKeyPresses;
Set dotKeyPresses;
Set backspacePresses;
List eventSubscriptions = [];

void setupEvents() {
  numberKeyPresses = new Set.from([48 /* 0 */,
                                   49 /* 1 */,
                                   50 /* 2 */,
                                   51 /* 3 */,
                                   52 /* 4 */,
                                   53 /* 5 */,
                                   54 /* 6 */,
                                   55 /* 7 */,
                                   56 /* 8 */,
                                   57 /* 9 */,
                                   96 /* Keypad 0 */,
                                   97 /* Keypad 1 */,
                                   98 /* Keypad 2 */,
                                   99 /* Keypad 3 */,
                                   100 /* Keypad 4 */,
                                   101 /* Keypad 5 */,
                                   102 /* Keypad 6 */,
                                   103 /* Keypad 7 */,
                                   104 /* Keypad 8 */,
                                   105 /* Keypad 9 */]);
  operatorKeyPresses = new Set.from([56 /* * */,
                                     187 /* + */,
                                     189 /* - */,
                                     191 /* / */,
                                     106 /* Keypad * */,
                                     107 /* Keypad + */,
                                     109 /* Keypad - */,
                                     111 /* Keypad / */]);
  equalKeyPresses = new Set.from([187 /* = */,
                                  13 /* ENTER */,
                                  0 /* Keypad = */]);
  clearKeyPresses = new Set.from([27 /* ESC */,
                                  67 /* C */,
                                  99 /* c */,
                                  46 /* DEL */]);
  dotKeyPresses = new Set.from([190 /* . */,
                                110 /* Keypad . */]);
  backspacePresses = new Set.from([8 /* Keypad <- or Backspace */]);

  addPadEvents();

  // Catch user keypresses, decide whether to use them or pass to the browser.
  document.onKeyUp.listen((e) {
    processKeyEvent(e);
  });

  document.onClick.listen((MouseEvent e) {
    bool wasOpened = mySettings.isOpen;

    // If settings dialog is open close it.
    mySettings.close(e);

    renderPad(document.body.children.last);
    if (wasOpened) {
      removePadEvents();
      addPadEvents();
    }
  });
}

void addPadEvents() {
  void listen(key, method) {
    eventSubscriptions.add(key.onClick.listen(method));
  }
  listen(padUI.keyZero, (e) { doCalc(48); });
  // Hook-up number key events:
  listen(padUI.keyZero, (e) { doCalc(48); });
  listen(padUI.keyOne, (e) { doCalc(49); });
  listen(padUI.keyTwo, (e) { doCalc(50); });
  listen(padUI.keyThree, (e) { doCalc(51); });
  listen(padUI.keyFour, (e) { doCalc(52); });
  listen(padUI.keyFive, (e) { doCalc(53); });
  listen(padUI.keySix, (e) { doCalc(54); });
  listen(padUI.keySeven, (e) { doCalc(55); });
  listen(padUI.keyEight, (e) { doCalc(56); });
  listen(padUI.keyNine, (e) { doCalc(57); });
  listen(padUI.keyDot, (e) { doCalc(110); });
  // Hook-up operator events:
  listen(padUI.keyPlus, (e) { doCalc(107); });
  listen(padUI.keyMinus, (e) { doCalc(109); });
  listen(padUI.keyStar, (e) { doCalc(106); });
  listen(padUI.keySlash, (e) { doCalc(111); });
  listen(padUI.keyEqual, (e) { doCalc(187); });
  listen(padUI.keyClear, (e) { doCalc(27); });
}

void removePadEvents() {
  for (var subscription in eventSubscriptions) {
    subscription.cancel();
  }
  eventSubscriptions.clear();
}

void renderPad(Element parentElement) {
  bool update = false;

  if (mySettings.isSimple && !(padUI is FlatPadUI)) {
    if (padUI != null) {
      removePadEvents();
    }
    padUI = new FlatPadUI();
    update = true;
  } else if (mySettings.isButton && !(padUI is ButtonPadUI)) {
    if (padUI != null) {
      removePadEvents();
    }
    padUI = new ButtonPadUI();
    update = true;
  }

  if (update) {
    // Update calculator pad.

    // Remove previous pad UI
    if (parentElement.children.length > 1) {
      parentElement.children.last.remove();
    }

    // Add new pad UI.
    parentElement.children.add(padUI.root);
  }
}

/**
 * Controls the logic of how to respond to keypresses and then update the
 * UI accordingly.
 */
void processKeyEvent(KeyboardEvent e) {
  int code = e.keyCode;
  bool shift = e.shiftKey;
  bool ctrl = e.ctrlKey;

  doCalc(code, shift, ctrl);
}

void doCalc(int code, [bool shift = false, bool ctrl = false]) {
  // If settings dialog is open close it.
  mySettings.close();

  if (numberKeyPresses.contains(code)) {
    if (code == 56 && shift) {
      /* * operator */
      processOperator(padUI.keyStar);
      return;
    } else if (code >= 96) {
      code -= 48;         // Normalize from keypad code to ASCII code.
    }

    Element element;
    switch (code) {
    case 48:
      element = padUI.keyZero;
      break;
    case 49:
      element = padUI.keyOne;
      break;
    case 50:
      element = padUI.keyTwo;
      break;
    case 51:
      element = padUI.keyThree;
      break;
    case 52:
      element = padUI.keyFour;
      break;
    case 53:
      element = padUI.keyFive;
      break;
    case 54:
      element = padUI.keySix;
      break;
    case 55:
      element = padUI.keySeven;
      break;
    case 56:
      element = padUI.keyEight;
      break;
    case 57:
      element = padUI.keyNine;
      break;
    default:
      tape.displayError("Unknown key");
    }
    processNumber(code, element);
  } else if (operatorKeyPresses.contains(code)) {
    int op;

    if ((shift && code == 56) || code == 106) {
      /* * operator */
      processOperator(padUI.keyStar);
    } else if ((shift && code == 187) || code == 107) {
      /* + operator */
      processOperator(padUI.keyPlus);
    } else if ((code == 189 && !shift) || code == 109) {
      /* - operator */
      processOperator(padUI.keyMinus);
    } else if ((code == 191 && !shift) || code == 111) {
      /* / operator */
      processOperator(padUI.keySlash);
    } else if (!shift && code == 187) {
      // Equal operator.
      processOperator(padUI.keyEqual);
    } else {
      // No match.
      return;
    }
  } else if (clearKeyPresses.contains(code)) {
    resetCalculatorState();
  } else if (dotKeyPresses.contains(code) && !shift) {
    processNumber(46, padUI.keyDot);
  } else if (equalKeyPresses.contains(code) && !shift) {
    processOperator(padUI.keyClear);
  } else if (backspacePresses.contains(code)) {
    if (ctrl) {
      // CTRL + BS or CTRL + DEL works like C, c, ESC, DEL and removes all
      // entries in the tape.
      resetCalculatorState();
      tape.clearTape();
    } else {
      currentRegister = currentRegister.substring(0,
        Math.max(0, currentRegister.length - 1));
      tape.addToTape(Tape.OP_NOOP, currentRegister);
    }
  }
}

void processNumber(int code, Element key) {
  String char = new String.fromCharCodes([code]);

  // TODO(terry): Need to fix this in Dart library.
  // If there's already a . in our current register don't allow a second period.
  if (char == '.' && currentRegister.indexOf('.') != -1) {
    // Signal dot is valid more than once for a number.
    flickerKey(padUI.keyDot, '-error');
    return;
  } else {
    currentRegister = "${currentRegister}${char}";
  }

  flickerKey(key);
  tape.addToTape(Tape.OP_NOOP, currentRegister);
}

void processOperator(var element) {
  flickerKey(element);

  if (currentRegister.length != 0) {
    int op;

    if (element == padUI.keyPlus) {
      op = Tape.OP_PLUS;
    } else if (element == padUI.keyMinus) {
      if (currentRegister == "-") {
        currentRegister = "";
        op = Tape.OP_NOOP;
      } else if (currentRegister == "-.") {
        currentRegister = ".";
        op = Tape.OP_NOOP;
      } else {
        op = Tape.OP_MINUS;
      }
    } else if (element == padUI.keyStar) {
      op = Tape.OP_MULTI;
    } else if (element == padUI.keySlash) {
      op = Tape.OP_DIV;
    } else if (element == padUI.keyEqual) {
      op = Tape.OP_EQUAL;
    } else if (element == padUI.keyClear) {
      op = Tape.OP_CLEAR;
    } else {
      tape.displayError("Unknown operator");
    }

    // If operator has no current number then don't display another operator
    // until operand is entered.
    if (currentRegister.length != 0 ||
        (tape.activeTotal == null && op == Tape.OP_EQUAL)) {
      tape.addToTape(op, currentRegister);
    }

    currentRegister = "";
  } else if (element == padUI.keyMinus) {
    currentRegister = "-";
    tape.addToTape(Tape.OP_NOOP, currentRegister);
  }
}

void resetCalculatorState() {
  flickerKey(padUI.keyClear);
  tape.removeActiveElements();
  if (!tape.isClear) {
    tape.clearTotal();
    currentRegister = "";
    currentOperator = null;
    total = 0.0;
  }
}

void flickerKey(Element key, [String postfix = '-hover']) {
  // Only Change classes with 1 hyphen that's the main class for an element
  // to handle hover and active.
  String theClass;
  for (final String cls in key.classes) {
    if (cls.split('-').length == 2) {
      theClass = cls;
    }
  }
  key.classes.add('${theClass}${postfix}');
  final String nextPostfix = (postfix == '-error') ? '-error' : '-press';
  new Timer(const Duration(milliseconds: 80),
      () => resetKey(key, '${theClass}${postfix}',
      '${theClass}${nextPostfix}'));
}

void resetKey(Element key, String classToRemove, [String classToAdd = ""]) {
  if (key != null) {
    key.classes.remove(classToRemove);
    if (classToAdd.length > 0) {
      key.classes.add(classToAdd);
      new Timer(const Duration(milliseconds: 80),
          () => resetKey(key, classToAdd));
    }
  }
}

void main() {
  final Element element = new Element.tag('div');

  // Create our Tape UI.
  tapeUI = new TapeUI();
  element.children.add(tapeUI.root);        // Render the UI

  // Create our tape controller.
  tape = new Tape();

  renderPad(element);

  // Render the UI.
  document.body.children.add(element);

  currentRegister = "";
  total = 0.0;

  setupEvents();
}
