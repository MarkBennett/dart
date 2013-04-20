// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library swipe;

import 'dart:async';
import 'dart:html';
import 'dart:math';

Element target;

var figureWidth;

double anglePos = 0.0;

Timer timer;

void main() {
  target = query('#target');

  initialize3D();

  // Handle touch events.
  int touchStartX;

  target.onTouchStart.listen((TouchEvent event) {
    event.preventDefault();

    if (event.touches.length > 0) {
      touchStartX = event.touches[0].page.x;
    }
  });

  target.onTouchMove.listen((TouchEvent event) {
    event.preventDefault();

    if (touchStartX != null && event.touches.length > 0) {
      int newTouchX = event.touches[0].page.x;

      if (newTouchX > touchStartX) {
        spinFigure(target, (newTouchX - touchStartX) ~/ 20 + 1);
        touchStartX = null;
      } else if (newTouchX < touchStartX) {
        spinFigure(target, (newTouchX - touchStartX) ~/ 20 - 1);
        touchStartX = null;
      }
    }
  });

  target.onTouchEnd.listen((TouchEvent event) {
    event.preventDefault();

    touchStartX = null;
  });

  // Handle key events.
  document.onKeyDown.listen((KeyboardEvent event) {
    switch (event.keyCode) {
      case KeyCode.LEFT:
        startSpin(target, -1);
        break;
      case KeyCode.RIGHT:
        startSpin(target, 1);
        break;
    }
  });

  document.onKeyUp.listen((event) => stopSpin());
}

void initialize3D() {
  target.classes.add("transformable");

  num childCount = target.children.length;

  window.setImmediate(() {
    num width = query("#target").client.width;
    figureWidth = (width / 2) ~/ tan(PI / childCount);

    target.style.transform = "translateZ(-${figureWidth}px)";

    num radius = (figureWidth * 1.2).round();
    query('#container2').style.width = "${radius}px";

    for (int i = 0; i < childCount; i++) {
      var panel = target.children[i];

      panel.classes.add("transformable");

      panel.style.transform =
          "rotateY(${i * (360 / childCount)}deg) translateZ(${radius}px)";
    }

    spinFigure(target, -1);
  });
}

void spinFigure(Element figure, int direction) {
  num childCount = target.children.length;

  anglePos += (360.0 / childCount) * direction;

  figure.style.transform =
      'translateZ(-${figureWidth}px) rotateY(${anglePos}deg)';
}

/**
 * Start an indefinite spin in the given direction.
 */
void startSpin(Element figure, int direction) {
  // If we're not already spinning -
  if (timer == null) {
    spinFigure(figure, direction);

    timer = new Timer.periodic(const Duration(milliseconds: 100),
        (Timer t) => spinFigure(figure, direction));
  }
}

/**
 * Stop any spin that may be in progress.
 */
void stopSpin() {
  if (timer != null) {
    timer.cancel();
    timer = null;
  }
}
