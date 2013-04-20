// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of calcui;

class Tape {
  static const int OP_NOOP = 0;
  static const int OP_PLUS = 1;
  static const int OP_MINUS = 2;
  static const int OP_MULTI = 3;
  static const int OP_DIV = 4;
  static const int OP_EQUAL = 5;
  static const int OP_CLEAR = 6;

  Tape() {
    clearTape();
  }

  void addToTape(int op, String number) {
    double displayTotal;
    double numberAsValue;

    if (number != "." && number != "-" && number != "-.") {
      try {
        numberAsValue = double.parse(number.length == 0 ? "0" : number);
      } on FormatException catch (e) {
        displayError(e.toString());
        return;
      }
    } else {
      // Display just the .
      displayTotal = total;
      numberAsValue = 0.0;
    }

    String opAsStr;

    if (op != OP_NOOP || currentOperator == null) {
      // Compute the real running total user pressed a mathematical operator.
      switch (currentOperator) {
        case OP_NOOP:
          total = numberAsValue;
          break;
        case OP_PLUS:
          total += numberAsValue;
          break;
        case OP_MINUS:
          total -= numberAsValue;
          break;
        case OP_MULTI:
          total *= numberAsValue;
          break;
        case OP_DIV:
          total /= numberAsValue;
          break;
        case OP_EQUAL:
          // Do nothing total is final total.
          if (number.length == 0) return;
          break;
        default:
          total = numberAsValue;
      }
    } else if (op == OP_NOOP && currentOperator == OP_EQUAL) {
      // If no operator after = pressed we're starting from scratch.
      total = numberAsValue;
    }

    // Compute if the op (key pressed) it's not a mathematical operator but we
    // want to display the current subtotal if real math operator was pressed.
    if (op == OP_NOOP) {
      switch (currentOperator) {
        case OP_PLUS:
          displayTotal = total + numberAsValue;
          break;
        case OP_MINUS:
          displayTotal = total - numberAsValue;
          break;
        case OP_MULTI:
          displayTotal = total * numberAsValue;
          break;
        case OP_DIV:
          displayTotal = total / numberAsValue;
          break;
        case OP_EQUAL:
          displayTotal = total;
          break;
        default:
          // nothing to do.
      }
    } else {
      displayTotal = total;
    }

    // Current operator to display.
    switch (op) {
      case OP_NOOP:
      case OP_EQUAL:
        opAsStr = " &nbsp;&nbsp;";
        break;
      case OP_PLUS:
        opAsStr = "+ ";
        break;
      case OP_MINUS:
        opAsStr = "- ";
        break;
      case OP_MULTI:
        opAsStr = "* ";
        break;
      case OP_DIV:
        opAsStr = "/ ";
        break;
    }
    if (op != OP_NOOP) {
      currentOperator = op;
    }

    final element = new Element.tag('div');

    DivElement active = activeInput;
    if (op == OP_NOOP) {
      if (active != null) {
        String displayedOp = active.children[0].text;
        active.innerHtml = tapeUI.firstOp(displayedOp, number);
      } else {
        element.innerHtml = tapeUI.displayOpAndNumber(opAsStr, number);
        tapeUI.tape.children.add(element.children[0]);
        element.innerHtml = tapeUI.alignSubTotal();;
        tapeUI.tape.children.add(element.children[0]);
        element.innerHtml = tapeUI.lineBreak();
        tapeUI.tape.children.add(element.children[0]);
      }

      // Update running total if it exist.
      active = activeTotal;
      if (active != null) {
        active.text = "= ${formatOutput(displayTotal)}";
      }
    } else {
      removeActiveElements();

      String leftSide;
      if (op == OP_EQUAL) {
        leftSide = tapeUI.displayEqual();
      } else {
        leftSide = tapeUI.displayOp(opAsStr);
      }

      element.innerHtml = leftSide;
      tapeUI.tape.children.add(element.children[0]);

      if (op == OP_EQUAL) {
        element.innerHtml = tapeUI.displayTotal(formatOutput(displayTotal));
      } else {
        element.innerHtml = tapeUI.displayActiveTotal();
      }
      tapeUI.tape.children.add(element.children[0]);

      element.innerHtml = tapeUI.lineBreak();
      tapeUI.tape.children.add(element.children[0]);
    }

    scrollToTapeBottom();
  }

  String formatOutput(double displayTotal) {
    String formattedNum = "${displayTotal.toStringAsFixed(5)}";
    int dotIdx = formattedNum.indexOf(".");
    if (dotIdx >= 0) {
      if (formattedNum.substring(dotIdx) == ".00000") {
        formattedNum = formattedNum.substring(0, dotIdx);
      }
    }

    return formattedNum;
  }

  void displayError(String err) {
    removeActiveElements();
    DivElement element = new Element.tag("div");
    element.innerHtml = tapeUI.displayError(err);
    tapeUI.tape.children.add(element.children[0]);

    scrollToTapeBottom();

    currentOperator = null;
    currentRegister = "";
    total = 0.0;
  }

  void scrollToTapeBottom() {
    window.setImmediate(() {
      // theTape.rect.scroll.top = rect.scroll.height;
      // TODO(terry): Would like to set scrollTop of tape doesn't seem to work
      //              so I scroll by max lines.
      tapeUI.tape.scrollByLines(100000);
    });
  }

  void removeActiveElements() {
    final element = new Element.tag('div');

    DivElement active = activeInput;
    if (active != null) {
      element.innerHtml = tapeUI.replaceActiveOp(active.innerHtml);
      active.replaceWith(element.children[0]);

      active = activeTotal;
      if (active != null) {
        element.innerHtml = tapeUI.replaceActiveTotal(active.text);
        active.replaceWith(element.children[0]);
      }
    }
  }

  void clearTotal() {
    final element = new Element.tag('div');

    element.innerHtml = tapeUI.clearCalculation();
    tapeUI.tape.children.add(element.children[0]);

    scrollToTapeBottom();
  }

  bool get isClear {
    return tapeUI.tape.children.last.classes.contains(TapeUI.clearCalc);
  }

  void clearTape() {
    tapeUI.tape.children.clear();

    SettingsDialog settingsUI = new SettingsDialog();
    tapeUI.tape.children.add(settingsUI.root);
    mySettings = new Settings(settingsUI, Settings.THEME_BUTTON);
  }

  DivElement get activeInput => window.document.query("#activeInput");
  DivElement get activeTotal => window.document.query("#activeTotal");

  void clear() {
    final element = new Element.tag('div');
    element.innerHtml = tapeUI.clearCalculation();
    tapeUI.tape.children.add(element.children[0]);
  }
}
