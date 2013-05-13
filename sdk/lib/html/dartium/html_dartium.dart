/// The Dart HTML library.
library dart.dom.html;

import 'dart:async';
import 'dart:collection';
import 'dart:_collection-dev' hide Symbol;
import 'dart:html_common';
import 'dart:indexed_db';
import 'dart:isolate';
import 'dart:json' as json;
import 'dart:math';
import 'dart:nativewrappers';
import 'dart:mdv_observe_impl';
import 'dart:typed_data';
import 'dart:web_gl' as gl;
import 'dart:web_sql';
import 'dart:svg' as svg;
import 'dart:web_audio' as web_audio;
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// DO NOT EDIT
// Auto-generated dart:html library.


// Not actually used, but imported since dart:html can generate these objects.





Window _window;

Window get window {
  if (_window != null) {
    return _window;
  }
  _window = _Utils.window();
  return _window;
}

HtmlDocument _document;

HtmlDocument get document {
  if (_document != null) {
    return _document;
  }
  _document = window.document;
  return _document;
}


Element query(String selector) => document.query(selector);
List<Element> queryAll(String selector) => document.queryAll(selector);

int _getNewIsolateId() => _Utils._getNewIsolateId();

bool _callPortInitialized = false;
var _callPortLastResult = null;

_callPortSync(num id, var message) {
  if (!_callPortInitialized) {
    window.on['js-result'].listen((event) {
      _callPortLastResult = json.parse(_getPortSyncEventData(event));
    });
    _callPortInitialized = true;
  }
  assert(_callPortLastResult == null);
  _dispatchEvent('js-sync-message', {'id': id, 'message': message});
  var result = _callPortLastResult;
  _callPortLastResult = null;
  return result;
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('AbstractWorker')
class AbstractWorker extends EventTarget {
  AbstractWorker.internal() : super.internal();

  @DomName('AbstractWorker.errorEvent')
  @DocsEditable
  static const EventStreamProvider<ErrorEvent> errorEvent = const EventStreamProvider<ErrorEvent>('error');

  @DomName('AbstractWorker.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "AbstractWorker_addEventListener_Callback";

  @DomName('AbstractWorker.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event evt) native "AbstractWorker_dispatchEvent_Callback";

  @DomName('AbstractWorker.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "AbstractWorker_removeEventListener_Callback";

  @DomName('AbstractWorker.onerror')
  @DocsEditable
  Stream<ErrorEvent> get onError => errorEvent.forTarget(this);

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLAnchorElement')
class AnchorElement extends _Element_Merged {
  AnchorElement.internal() : super.internal();

  @DomName('HTMLAnchorElement.HTMLAnchorElement')
  @DocsEditable
  factory AnchorElement({String href}) {
    var e = document.$dom_createElement("a");
    if (href != null) e.href = href;
    return e;
  }

  @DomName('HTMLAnchorElement.download')
  @DocsEditable
  String get download native "HTMLAnchorElement_download_Getter";

  @DomName('HTMLAnchorElement.download')
  @DocsEditable
  void set download(String value) native "HTMLAnchorElement_download_Setter";

  @DomName('HTMLAnchorElement.hash')
  @DocsEditable
  String get hash native "HTMLAnchorElement_hash_Getter";

  @DomName('HTMLAnchorElement.hash')
  @DocsEditable
  void set hash(String value) native "HTMLAnchorElement_hash_Setter";

  @DomName('HTMLAnchorElement.host')
  @DocsEditable
  String get host native "HTMLAnchorElement_host_Getter";

  @DomName('HTMLAnchorElement.host')
  @DocsEditable
  void set host(String value) native "HTMLAnchorElement_host_Setter";

  @DomName('HTMLAnchorElement.hostname')
  @DocsEditable
  String get hostname native "HTMLAnchorElement_hostname_Getter";

  @DomName('HTMLAnchorElement.hostname')
  @DocsEditable
  void set hostname(String value) native "HTMLAnchorElement_hostname_Setter";

  @DomName('HTMLAnchorElement.href')
  @DocsEditable
  String get href native "HTMLAnchorElement_href_Getter";

  @DomName('HTMLAnchorElement.href')
  @DocsEditable
  void set href(String value) native "HTMLAnchorElement_href_Setter";

  @DomName('HTMLAnchorElement.hreflang')
  @DocsEditable
  String get hreflang native "HTMLAnchorElement_hreflang_Getter";

  @DomName('HTMLAnchorElement.hreflang')
  @DocsEditable
  void set hreflang(String value) native "HTMLAnchorElement_hreflang_Setter";

  @DomName('HTMLAnchorElement.name')
  @DocsEditable
  String get name native "HTMLAnchorElement_name_Getter";

  @DomName('HTMLAnchorElement.name')
  @DocsEditable
  void set name(String value) native "HTMLAnchorElement_name_Setter";

  @DomName('HTMLAnchorElement.origin')
  @DocsEditable
  String get origin native "HTMLAnchorElement_origin_Getter";

  @DomName('HTMLAnchorElement.pathname')
  @DocsEditable
  String get pathname native "HTMLAnchorElement_pathname_Getter";

  @DomName('HTMLAnchorElement.pathname')
  @DocsEditable
  void set pathname(String value) native "HTMLAnchorElement_pathname_Setter";

  @DomName('HTMLAnchorElement.ping')
  @DocsEditable
  String get ping native "HTMLAnchorElement_ping_Getter";

  @DomName('HTMLAnchorElement.ping')
  @DocsEditable
  void set ping(String value) native "HTMLAnchorElement_ping_Setter";

  @DomName('HTMLAnchorElement.port')
  @DocsEditable
  String get port native "HTMLAnchorElement_port_Getter";

  @DomName('HTMLAnchorElement.port')
  @DocsEditable
  void set port(String value) native "HTMLAnchorElement_port_Setter";

  @DomName('HTMLAnchorElement.protocol')
  @DocsEditable
  String get protocol native "HTMLAnchorElement_protocol_Getter";

  @DomName('HTMLAnchorElement.protocol')
  @DocsEditable
  void set protocol(String value) native "HTMLAnchorElement_protocol_Setter";

  @DomName('HTMLAnchorElement.rel')
  @DocsEditable
  String get rel native "HTMLAnchorElement_rel_Getter";

  @DomName('HTMLAnchorElement.rel')
  @DocsEditable
  void set rel(String value) native "HTMLAnchorElement_rel_Setter";

  @DomName('HTMLAnchorElement.search')
  @DocsEditable
  String get search native "HTMLAnchorElement_search_Getter";

  @DomName('HTMLAnchorElement.search')
  @DocsEditable
  void set search(String value) native "HTMLAnchorElement_search_Setter";

  @DomName('HTMLAnchorElement.target')
  @DocsEditable
  String get target native "HTMLAnchorElement_target_Getter";

  @DomName('HTMLAnchorElement.target')
  @DocsEditable
  void set target(String value) native "HTMLAnchorElement_target_Setter";

  @DomName('HTMLAnchorElement.type')
  @DocsEditable
  String get type native "HTMLAnchorElement_type_Getter";

  @DomName('HTMLAnchorElement.type')
  @DocsEditable
  void set type(String value) native "HTMLAnchorElement_type_Setter";

  @DomName('HTMLAnchorElement.toString')
  @DocsEditable
  String toString() native "HTMLAnchorElement_toString_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('WebKitAnimationEvent')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.SAFARI)
@Experimental
class AnimationEvent extends Event {
  AnimationEvent.internal() : super.internal();

  @DomName('WebKitAnimationEvent.animationName')
  @DocsEditable
  String get animationName native "AnimationEvent_animationName_Getter";

  @DomName('WebKitAnimationEvent.elapsedTime')
  @DocsEditable
  num get elapsedTime native "AnimationEvent_elapsedTime_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('DOMApplicationCache')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.FIREFOX)
@SupportedBrowser(SupportedBrowser.IE, '10')
@SupportedBrowser(SupportedBrowser.OPERA)
@SupportedBrowser(SupportedBrowser.SAFARI)
class ApplicationCache extends EventTarget {
  ApplicationCache.internal() : super.internal();

  @DomName('DOMApplicationCache.cachedEvent')
  @DocsEditable
  static const EventStreamProvider<Event> cachedEvent = const EventStreamProvider<Event>('cached');

  @DomName('DOMApplicationCache.checkingEvent')
  @DocsEditable
  static const EventStreamProvider<Event> checkingEvent = const EventStreamProvider<Event>('checking');

  @DomName('DOMApplicationCache.downloadingEvent')
  @DocsEditable
  static const EventStreamProvider<Event> downloadingEvent = const EventStreamProvider<Event>('downloading');

  @DomName('DOMApplicationCache.errorEvent')
  @DocsEditable
  static const EventStreamProvider<Event> errorEvent = const EventStreamProvider<Event>('error');

  @DomName('DOMApplicationCache.noupdateEvent')
  @DocsEditable
  static const EventStreamProvider<Event> noUpdateEvent = const EventStreamProvider<Event>('noupdate');

  @DomName('DOMApplicationCache.obsoleteEvent')
  @DocsEditable
  static const EventStreamProvider<Event> obsoleteEvent = const EventStreamProvider<Event>('obsolete');

  @DomName('DOMApplicationCache.progressEvent')
  @DocsEditable
  static const EventStreamProvider<Event> progressEvent = const EventStreamProvider<Event>('progress');

  @DomName('DOMApplicationCache.updatereadyEvent')
  @DocsEditable
  static const EventStreamProvider<Event> updateReadyEvent = const EventStreamProvider<Event>('updateready');

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('DOMApplicationCache.CHECKING')
  @DocsEditable
  static const int CHECKING = 2;

  @DomName('DOMApplicationCache.DOWNLOADING')
  @DocsEditable
  static const int DOWNLOADING = 3;

  @DomName('DOMApplicationCache.IDLE')
  @DocsEditable
  static const int IDLE = 1;

  @DomName('DOMApplicationCache.OBSOLETE')
  @DocsEditable
  static const int OBSOLETE = 5;

  @DomName('DOMApplicationCache.UNCACHED')
  @DocsEditable
  static const int UNCACHED = 0;

  @DomName('DOMApplicationCache.UPDATEREADY')
  @DocsEditable
  static const int UPDATEREADY = 4;

  @DomName('DOMApplicationCache.status')
  @DocsEditable
  int get status native "DOMApplicationCache_status_Getter";

  @DomName('DOMApplicationCache.abort')
  @DocsEditable
  void abort() native "DOMApplicationCache_abort_Callback";

  @DomName('DOMApplicationCache.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "DOMApplicationCache_addEventListener_Callback";

  @DomName('DOMApplicationCache.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event evt) native "DOMApplicationCache_dispatchEvent_Callback";

  @DomName('DOMApplicationCache.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "DOMApplicationCache_removeEventListener_Callback";

  @DomName('DOMApplicationCache.swapCache')
  @DocsEditable
  void swapCache() native "DOMApplicationCache_swapCache_Callback";

  @DomName('DOMApplicationCache.update')
  @DocsEditable
  void update() native "DOMApplicationCache_update_Callback";

  @DomName('DOMApplicationCache.oncached')
  @DocsEditable
  Stream<Event> get onCached => cachedEvent.forTarget(this);

  @DomName('DOMApplicationCache.onchecking')
  @DocsEditable
  Stream<Event> get onChecking => checkingEvent.forTarget(this);

  @DomName('DOMApplicationCache.ondownloading')
  @DocsEditable
  Stream<Event> get onDownloading => downloadingEvent.forTarget(this);

  @DomName('DOMApplicationCache.onerror')
  @DocsEditable
  Stream<Event> get onError => errorEvent.forTarget(this);

  @DomName('DOMApplicationCache.onnoupdate')
  @DocsEditable
  Stream<Event> get onNoUpdate => noUpdateEvent.forTarget(this);

  @DomName('DOMApplicationCache.onobsolete')
  @DocsEditable
  Stream<Event> get onObsolete => obsoleteEvent.forTarget(this);

  @DomName('DOMApplicationCache.onprogress')
  @DocsEditable
  Stream<Event> get onProgress => progressEvent.forTarget(this);

  @DomName('DOMApplicationCache.onupdateready')
  @DocsEditable
  Stream<Event> get onUpdateReady => updateReadyEvent.forTarget(this);

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
/**
 * DOM Area Element, which links regions of an image map with a hyperlink.
 *
 * The element can also define an uninteractive region of the map.
 *
 * See also:
 *
 * * [<area>](https://developer.mozilla.org/en-US/docs/HTML/Element/area)
 * on MDN.
 */
@DomName('HTMLAreaElement')
class AreaElement extends _Element_Merged {
  AreaElement.internal() : super.internal();

  @DomName('HTMLAreaElement.HTMLAreaElement')
  @DocsEditable
  factory AreaElement() => document.$dom_createElement("area");

  @DomName('HTMLAreaElement.alt')
  @DocsEditable
  String get alt native "HTMLAreaElement_alt_Getter";

  @DomName('HTMLAreaElement.alt')
  @DocsEditable
  void set alt(String value) native "HTMLAreaElement_alt_Setter";

  @DomName('HTMLAreaElement.coords')
  @DocsEditable
  String get coords native "HTMLAreaElement_coords_Getter";

  @DomName('HTMLAreaElement.coords')
  @DocsEditable
  void set coords(String value) native "HTMLAreaElement_coords_Setter";

  @DomName('HTMLAreaElement.hash')
  @DocsEditable
  String get hash native "HTMLAreaElement_hash_Getter";

  @DomName('HTMLAreaElement.host')
  @DocsEditable
  String get host native "HTMLAreaElement_host_Getter";

  @DomName('HTMLAreaElement.hostname')
  @DocsEditable
  String get hostname native "HTMLAreaElement_hostname_Getter";

  @DomName('HTMLAreaElement.href')
  @DocsEditable
  String get href native "HTMLAreaElement_href_Getter";

  @DomName('HTMLAreaElement.href')
  @DocsEditable
  void set href(String value) native "HTMLAreaElement_href_Setter";

  @DomName('HTMLAreaElement.pathname')
  @DocsEditable
  String get pathname native "HTMLAreaElement_pathname_Getter";

  @DomName('HTMLAreaElement.ping')
  @DocsEditable
  String get ping native "HTMLAreaElement_ping_Getter";

  @DomName('HTMLAreaElement.ping')
  @DocsEditable
  void set ping(String value) native "HTMLAreaElement_ping_Setter";

  @DomName('HTMLAreaElement.port')
  @DocsEditable
  String get port native "HTMLAreaElement_port_Getter";

  @DomName('HTMLAreaElement.protocol')
  @DocsEditable
  String get protocol native "HTMLAreaElement_protocol_Getter";

  @DomName('HTMLAreaElement.search')
  @DocsEditable
  String get search native "HTMLAreaElement_search_Getter";

  @DomName('HTMLAreaElement.shape')
  @DocsEditable
  String get shape native "HTMLAreaElement_shape_Getter";

  @DomName('HTMLAreaElement.shape')
  @DocsEditable
  void set shape(String value) native "HTMLAreaElement_shape_Setter";

  @DomName('HTMLAreaElement.target')
  @DocsEditable
  String get target native "HTMLAreaElement_target_Getter";

  @DomName('HTMLAreaElement.target')
  @DocsEditable
  void set target(String value) native "HTMLAreaElement_target_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('Attr')
class Attr extends Node {
  Attr.internal() : super.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLAudioElement')
class AudioElement extends MediaElement {
  AudioElement.internal() : super.internal();

  @DomName('HTMLAudioElement.HTMLAudioElement')
  @DocsEditable
  factory AudioElement([String src]) {
    return AudioElement._create_1(src);
  }

  @DocsEditable
  static AudioElement _create_1(src) native "HTMLAudioElement__create_1constructorCallback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('AutocompleteErrorEvent')
class AutocompleteErrorEvent extends Event {
  AutocompleteErrorEvent.internal() : super.internal();

  @DomName('AutocompleteErrorEvent.reason')
  @DocsEditable
  String get reason native "AutocompleteErrorEvent_reason_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLBRElement')
class BRElement extends _Element_Merged {
  BRElement.internal() : super.internal();

  @DomName('HTMLBRElement.HTMLBRElement')
  @DocsEditable
  factory BRElement() => document.$dom_createElement("br");

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('BarInfo')
class BarInfo extends NativeFieldWrapperClass1 {
  BarInfo.internal();

  @DomName('BarInfo.visible')
  @DocsEditable
  bool get visible native "BarInfo_visible_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLBaseElement')
class BaseElement extends _Element_Merged {
  BaseElement.internal() : super.internal();

  @DomName('HTMLBaseElement.HTMLBaseElement')
  @DocsEditable
  factory BaseElement() => document.$dom_createElement("base");

  @DomName('HTMLBaseElement.href')
  @DocsEditable
  String get href native "HTMLBaseElement_href_Getter";

  @DomName('HTMLBaseElement.href')
  @DocsEditable
  void set href(String value) native "HTMLBaseElement_href_Setter";

  @DomName('HTMLBaseElement.target')
  @DocsEditable
  String get target native "HTMLBaseElement_target_Getter";

  @DomName('HTMLBaseElement.target')
  @DocsEditable
  void set target(String value) native "HTMLBaseElement_target_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('BeforeLoadEvent')
class BeforeLoadEvent extends Event {
  BeforeLoadEvent.internal() : super.internal();

  @DomName('BeforeLoadEvent.url')
  @DocsEditable
  String get url native "BeforeLoadEvent_url_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('Blob')
class Blob extends NativeFieldWrapperClass1 {
  Blob.internal();
  factory Blob(List blobParts, [String type, String endings]) => _create(blobParts, type, endings);

  @DocsEditable
  static Blob _create(blobParts, type, endings) native "Blob_constructorCallback";

  @DomName('Blob.size')
  @DocsEditable
  int get size native "Blob_size_Getter";

  @DomName('Blob.type')
  @DocsEditable
  String get type native "Blob_type_Getter";

  Blob slice([int start, int end, String contentType]) {
    if (?contentType) {
      return _slice_1(start, end, contentType);
    }
    if (?end) {
      return _slice_2(start, end);
    }
    if (?start) {
      return _slice_3(start);
    }
    return _slice_4();
  }

  Blob _slice_1(start, end, contentType) native "Blob__slice_1_Callback";

  Blob _slice_2(start, end) native "Blob__slice_2_Callback";

  Blob _slice_3(start) native "Blob__slice_3_Callback";

  Blob _slice_4() native "Blob__slice_4_Callback";

}

// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLBodyElement')
class BodyElement extends _Element_Merged {
  BodyElement.internal() : super.internal();

  @DomName('HTMLBodyElement.blurEvent')
  @DocsEditable
  static const EventStreamProvider<Event> blurEvent = const EventStreamProvider<Event>('blur');

  @DomName('HTMLBodyElement.errorEvent')
  @DocsEditable
  static const EventStreamProvider<Event> errorEvent = const EventStreamProvider<Event>('error');

  @DomName('HTMLBodyElement.focusEvent')
  @DocsEditable
  static const EventStreamProvider<Event> focusEvent = const EventStreamProvider<Event>('focus');

  @DomName('HTMLBodyElement.hashchangeEvent')
  @DocsEditable
  static const EventStreamProvider<Event> hashChangeEvent = const EventStreamProvider<Event>('hashchange');

  @DomName('HTMLBodyElement.loadEvent')
  @DocsEditable
  static const EventStreamProvider<Event> loadEvent = const EventStreamProvider<Event>('load');

  @DomName('HTMLBodyElement.messageEvent')
  @DocsEditable
  static const EventStreamProvider<MessageEvent> messageEvent = const EventStreamProvider<MessageEvent>('message');

  @DomName('HTMLBodyElement.offlineEvent')
  @DocsEditable
  static const EventStreamProvider<Event> offlineEvent = const EventStreamProvider<Event>('offline');

  @DomName('HTMLBodyElement.onlineEvent')
  @DocsEditable
  static const EventStreamProvider<Event> onlineEvent = const EventStreamProvider<Event>('online');

  @DomName('HTMLBodyElement.popstateEvent')
  @DocsEditable
  static const EventStreamProvider<PopStateEvent> popStateEvent = const EventStreamProvider<PopStateEvent>('popstate');

  @DomName('HTMLBodyElement.resizeEvent')
  @DocsEditable
  static const EventStreamProvider<Event> resizeEvent = const EventStreamProvider<Event>('resize');

  @DomName('HTMLBodyElement.storageEvent')
  @DocsEditable
  static const EventStreamProvider<StorageEvent> storageEvent = const EventStreamProvider<StorageEvent>('storage');

  @DomName('HTMLBodyElement.unloadEvent')
  @DocsEditable
  static const EventStreamProvider<Event> unloadEvent = const EventStreamProvider<Event>('unload');

  @DomName('HTMLBodyElement.HTMLBodyElement')
  @DocsEditable
  factory BodyElement() => document.$dom_createElement("body");

  @DomName('HTMLBodyElement.onblur')
  @DocsEditable
  Stream<Event> get onBlur => blurEvent.forTarget(this);

  @DomName('HTMLBodyElement.onerror')
  @DocsEditable
  Stream<Event> get onError => errorEvent.forTarget(this);

  @DomName('HTMLBodyElement.onfocus')
  @DocsEditable
  Stream<Event> get onFocus => focusEvent.forTarget(this);

  @DomName('HTMLBodyElement.onhashchange')
  @DocsEditable
  Stream<Event> get onHashChange => hashChangeEvent.forTarget(this);

  @DomName('HTMLBodyElement.onload')
  @DocsEditable
  Stream<Event> get onLoad => loadEvent.forTarget(this);

  @DomName('HTMLBodyElement.onmessage')
  @DocsEditable
  Stream<MessageEvent> get onMessage => messageEvent.forTarget(this);

  @DomName('HTMLBodyElement.onoffline')
  @DocsEditable
  Stream<Event> get onOffline => offlineEvent.forTarget(this);

  @DomName('HTMLBodyElement.ononline')
  @DocsEditable
  Stream<Event> get onOnline => onlineEvent.forTarget(this);

  @DomName('HTMLBodyElement.onpopstate')
  @DocsEditable
  Stream<PopStateEvent> get onPopState => popStateEvent.forTarget(this);

  @DomName('HTMLBodyElement.onresize')
  @DocsEditable
  Stream<Event> get onResize => resizeEvent.forTarget(this);

  @DomName('HTMLBodyElement.onstorage')
  @DocsEditable
  Stream<StorageEvent> get onStorage => storageEvent.forTarget(this);

  @DomName('HTMLBodyElement.onunload')
  @DocsEditable
  Stream<Event> get onUnload => unloadEvent.forTarget(this);

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLButtonElement')
class ButtonElement extends _Element_Merged {
  ButtonElement.internal() : super.internal();

  @DomName('HTMLButtonElement.HTMLButtonElement')
  @DocsEditable
  factory ButtonElement() => document.$dom_createElement("button");

  @DomName('HTMLButtonElement.autofocus')
  @DocsEditable
  bool get autofocus native "HTMLButtonElement_autofocus_Getter";

  @DomName('HTMLButtonElement.autofocus')
  @DocsEditable
  void set autofocus(bool value) native "HTMLButtonElement_autofocus_Setter";

  @DomName('HTMLButtonElement.disabled')
  @DocsEditable
  bool get disabled native "HTMLButtonElement_disabled_Getter";

  @DomName('HTMLButtonElement.disabled')
  @DocsEditable
  void set disabled(bool value) native "HTMLButtonElement_disabled_Setter";

  @DomName('HTMLButtonElement.form')
  @DocsEditable
  FormElement get form native "HTMLButtonElement_form_Getter";

  @DomName('HTMLButtonElement.formAction')
  @DocsEditable
  String get formAction native "HTMLButtonElement_formAction_Getter";

  @DomName('HTMLButtonElement.formAction')
  @DocsEditable
  void set formAction(String value) native "HTMLButtonElement_formAction_Setter";

  @DomName('HTMLButtonElement.formEnctype')
  @DocsEditable
  String get formEnctype native "HTMLButtonElement_formEnctype_Getter";

  @DomName('HTMLButtonElement.formEnctype')
  @DocsEditable
  void set formEnctype(String value) native "HTMLButtonElement_formEnctype_Setter";

  @DomName('HTMLButtonElement.formMethod')
  @DocsEditable
  String get formMethod native "HTMLButtonElement_formMethod_Getter";

  @DomName('HTMLButtonElement.formMethod')
  @DocsEditable
  void set formMethod(String value) native "HTMLButtonElement_formMethod_Setter";

  @DomName('HTMLButtonElement.formNoValidate')
  @DocsEditable
  bool get formNoValidate native "HTMLButtonElement_formNoValidate_Getter";

  @DomName('HTMLButtonElement.formNoValidate')
  @DocsEditable
  void set formNoValidate(bool value) native "HTMLButtonElement_formNoValidate_Setter";

  @DomName('HTMLButtonElement.formTarget')
  @DocsEditable
  String get formTarget native "HTMLButtonElement_formTarget_Getter";

  @DomName('HTMLButtonElement.formTarget')
  @DocsEditable
  void set formTarget(String value) native "HTMLButtonElement_formTarget_Setter";

  @DomName('HTMLButtonElement.labels')
  @DocsEditable
  List<Node> get labels native "HTMLButtonElement_labels_Getter";

  @DomName('HTMLButtonElement.name')
  @DocsEditable
  String get name native "HTMLButtonElement_name_Getter";

  @DomName('HTMLButtonElement.name')
  @DocsEditable
  void set name(String value) native "HTMLButtonElement_name_Setter";

  @DomName('HTMLButtonElement.type')
  @DocsEditable
  String get type native "HTMLButtonElement_type_Getter";

  @DomName('HTMLButtonElement.type')
  @DocsEditable
  void set type(String value) native "HTMLButtonElement_type_Setter";

  @DomName('HTMLButtonElement.validationMessage')
  @DocsEditable
  String get validationMessage native "HTMLButtonElement_validationMessage_Getter";

  @DomName('HTMLButtonElement.validity')
  @DocsEditable
  ValidityState get validity native "HTMLButtonElement_validity_Getter";

  @DomName('HTMLButtonElement.value')
  @DocsEditable
  String get value native "HTMLButtonElement_value_Getter";

  @DomName('HTMLButtonElement.value')
  @DocsEditable
  void set value(String value) native "HTMLButtonElement_value_Setter";

  @DomName('HTMLButtonElement.willValidate')
  @DocsEditable
  bool get willValidate native "HTMLButtonElement_willValidate_Getter";

  @DomName('HTMLButtonElement.checkValidity')
  @DocsEditable
  bool checkValidity() native "HTMLButtonElement_checkValidity_Callback";

  @DomName('HTMLButtonElement.setCustomValidity')
  @DocsEditable
  void setCustomValidity(String error) native "HTMLButtonElement_setCustomValidity_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('CDATASection')
class CDataSection extends Text {
  CDataSection.internal() : super.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('HTMLCanvasElement')
class CanvasElement extends _Element_Merged implements CanvasImageSource {
  CanvasElement.internal() : super.internal();

  @DomName('HTMLCanvasElement.HTMLCanvasElement')
  @DocsEditable
  factory CanvasElement({int width, int height}) {
    var e = document.$dom_createElement("canvas");
    if (width != null) e.width = width;
    if (height != null) e.height = height;
    return e;
  }

  /// The height of this canvas element in CSS pixels.
  @DomName('HTMLCanvasElement.height')
  @DocsEditable
  int get height native "HTMLCanvasElement_height_Getter";

  /// The height of this canvas element in CSS pixels.
  @DomName('HTMLCanvasElement.height')
  @DocsEditable
  void set height(int value) native "HTMLCanvasElement_height_Setter";

  /// The width of this canvas element in CSS pixels.
  @DomName('HTMLCanvasElement.width')
  @DocsEditable
  int get width native "HTMLCanvasElement_width_Getter";

  /// The width of this canvas element in CSS pixels.
  @DomName('HTMLCanvasElement.width')
  @DocsEditable
  void set width(int value) native "HTMLCanvasElement_width_Setter";

  @DomName('HTMLCanvasElement.getContext')
  @DocsEditable
  CanvasRenderingContext getContext(String contextId, [Map attrs]) native "HTMLCanvasElement_getContext_Callback";

  /**
   * Returns a data URI containing a representation of the image in the
   * format specified by type (defaults to 'image/png').
   *
   * Data Uri format is as follow `data:[<MIME-type>][;charset=<encoding>][;base64],<data>`
   *
   * Optional parameter [quality] in the range of 0.0 and 1.0 can be used when requesting [type]
   * 'image/jpeg' or 'image/webp'. If [quality] is not passed the default
   * value is used. Note: the default value varies by browser.
   *
   * If the height or width of this canvas element is 0, then 'data:' is returned,
   * representing no data.
   *
   * If the type requested is not 'image/png', and the returned value is
   * 'data:image/png', then the requested type is not supported.
   *
   * Example usage:
   *
   *     CanvasElement canvas = new CanvasElement();
   *     var ctx = canvas.context2D
   *     ..fillStyle = "rgb(200,0,0)"
   *     ..fillRect(10, 10, 55, 50);
   *     var dataUrl = canvas.toDataURL("image/jpeg", 0.95);
   *     // The Data Uri would look similar to
   *     // 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUA
   *     // AAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO
   *     // 9TXL0Y4OHwAAAABJRU5ErkJggg=='
   *     //Create a new image element from the data URI.
   *     var img = new ImageElement();
   *     img.src = dataUrl;
   *     document.body.children.add(img);
   *
   * See also:
   *
   * * [Data URI Scheme](http://en.wikipedia.org/wiki/Data_URI_scheme) from Wikipedia.
   *
   * * [HTMLCanvasElement](https://developer.mozilla.org/en-US/docs/DOM/HTMLCanvasElement) from MDN.
   *
   * * [toDataUrl](http://dev.w3.org/html5/spec/the-canvas-element.html#dom-canvas-todataurl) from W3C.
   */
  @DomName('HTMLCanvasElement.toDataURL')
  @DocsEditable
  String toDataUrl(String type, [num quality]) native "HTMLCanvasElement_toDataURL_Callback";

  /** An API for drawing on this canvas. */
  CanvasRenderingContext2D get context2D => getContext('2d');

  @deprecated
  CanvasRenderingContext2D get context2d => this.context2D;

  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.FIREFOX)
  @Experimental
  gl.RenderingContext getContext3d({alpha: true, depth: true, stencil: false,
    antialias: true, premultipliedAlpha: true, preserveDrawingBuffer: false}) {

    var options = {
      'alpha': alpha,
      'depth': depth,
      'stencil': stencil,
      'antialias': antialias,
      'premultipliedAlpha': premultipliedAlpha,
      'preserveDrawingBuffer': preserveDrawingBuffer,
    };
    var context = getContext('webgl', options);
    if (context == null) {
      context = getContext('experimental-webgl', options);
    }
    return context;
  }
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
/**
 * An opaque canvas object representing a gradient.
 *
 * Created by calling [createLinearGradient] or [createRadialGradient] on a
 * [CanvasRenderingContext2D] object.
 *
 * Example usage:
 *
 *     var canvas = new CanvasElement(width: 600, height: 600);
 *     var ctx = canvas.context2D;
 *     ctx.clearRect(0, 0, 600, 600);
 *     ctx.save();
 *     // Create radial gradient.
 *     CanvasGradient gradient = ctx.createRadialGradient(0, 0, 0, 0, 0, 600);
 *     gradient.addColorStop(0, '#000');
 *     gradient.addColorStop(1, 'rgb(255, 255, 255)');
 *     // Assign gradients to fill.
 *     ctx.fillStyle = gradient;
 *     // Draw a rectangle with a gradient fill.
 *     ctx.fillRect(0, 0, 600, 600);
 *     ctx.save();
 *     document.body.children.add(canvas);
 *
 * See also:
 *
 * * [CanvasGradient](https://developer.mozilla.org/en-US/docs/DOM/CanvasGradient) from MDN.
 * * [CanvasGradient](http://www.whatwg.org/specs/web-apps/current-work/multipage/the-canvas-element.html#canvasgradient) from whatwg.
 * * [CanvasGradient](http://www.w3.org/TR/2010/WD-2dcontext-20100304/#canvasgradient) from W3C.
 */
@DomName('CanvasGradient')
class CanvasGradient extends NativeFieldWrapperClass1 {
  CanvasGradient.internal();

  /**
   * Adds a color stop to this gradient at the offset.
   *
   * The [offset] can range between 0.0 and 1.0.
   *
   * See also:
   *
   * * [Multiple Color Stops](https://developer.mozilla.org/en-US/docs/CSS/linear-gradient#Gradient_with_multiple_color_stops) from MDN.
   */
  @DomName('CanvasGradient.addColorStop')
  @DocsEditable
  void addColorStop(num offset, String color) native "CanvasGradient_addColorStop_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
/**
 * An opaque object representing a pattern of image, canvas, or video.
 *
 * Created by calling [createPattern] on a [CanvasRenderingContext2D] object.
 *
 * Example usage:
 *
 *     var canvas = new CanvasElement(width: 600, height: 600);
 *     var ctx = canvas.context2D;
 *     var img = new ImageElement();
 *     // Image src needs to be loaded before pattern is applied.
 *     img.onLoad.listen((event) {
 *       // When the image is loaded, create a pattern
 *       // from the ImageElement.
 *       CanvasPattern pattern = ctx.createPattern(img, 'repeat');
 *       ctx.rect(0, 0, canvas.width, canvas.height);
 *       ctx.fillStyle = pattern;
 *       ctx.fill();
 *     });
 *     img.src = "images/foo.jpg";
 *     document.body.children.add(canvas);
 *
 * See also:
 * * [CanvasPattern](https://developer.mozilla.org/en-US/docs/DOM/CanvasPattern) from MDN.
 * * [CanvasPattern](http://www.whatwg.org/specs/web-apps/current-work/multipage/the-canvas-element.html#canvaspattern) from whatwg.
 * * [CanvasPattern](http://www.w3.org/TR/2010/WD-2dcontext-20100304/#canvaspattern) from W3C.
 */
@DomName('CanvasPattern')
class CanvasPattern extends NativeFieldWrapperClass1 {
  CanvasPattern.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('CanvasProxy')
class CanvasProxy extends NativeFieldWrapperClass1 {
  CanvasProxy.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
/**
 * A rendering context for a canvas element.
 *
 * This context is extended by [CanvasRenderingContext2D] and
 * [WebGLRenderingContext].
 */
@DomName('CanvasRenderingContext')
class CanvasRenderingContext extends NativeFieldWrapperClass1 {
  CanvasRenderingContext.internal();

  /// Reference to the canvas element to which this context belongs.
  @DomName('CanvasRenderingContext.canvas')
  @DocsEditable
  CanvasElement get canvas native "CanvasRenderingContext_canvas_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('CanvasRenderingContext2D')
class CanvasRenderingContext2D extends CanvasRenderingContext {
  CanvasRenderingContext2D.internal() : super.internal();

  @DomName('CanvasRenderingContext2D.currentPath')
  @DocsEditable
  Path get currentPath native "CanvasRenderingContext2D_currentPath_Getter";

  @DomName('CanvasRenderingContext2D.currentPath')
  @DocsEditable
  void set currentPath(Path value) native "CanvasRenderingContext2D_currentPath_Setter";

  @DomName('CanvasRenderingContext2D.fillStyle')
  @DocsEditable
  dynamic get fillStyle native "CanvasRenderingContext2D_fillStyle_Getter";

  @DomName('CanvasRenderingContext2D.fillStyle')
  @DocsEditable
  void set fillStyle(dynamic value) native "CanvasRenderingContext2D_fillStyle_Setter";

  @DomName('CanvasRenderingContext2D.font')
  @DocsEditable
  String get font native "CanvasRenderingContext2D_font_Getter";

  @DomName('CanvasRenderingContext2D.font')
  @DocsEditable
  void set font(String value) native "CanvasRenderingContext2D_font_Setter";

  @DomName('CanvasRenderingContext2D.globalAlpha')
  @DocsEditable
  num get globalAlpha native "CanvasRenderingContext2D_globalAlpha_Getter";

  @DomName('CanvasRenderingContext2D.globalAlpha')
  @DocsEditable
  void set globalAlpha(num value) native "CanvasRenderingContext2D_globalAlpha_Setter";

  @DomName('CanvasRenderingContext2D.globalCompositeOperation')
  @DocsEditable
  String get globalCompositeOperation native "CanvasRenderingContext2D_globalCompositeOperation_Getter";

  @DomName('CanvasRenderingContext2D.globalCompositeOperation')
  @DocsEditable
  void set globalCompositeOperation(String value) native "CanvasRenderingContext2D_globalCompositeOperation_Setter";

  @DomName('CanvasRenderingContext2D.lineCap')
  @DocsEditable
  String get lineCap native "CanvasRenderingContext2D_lineCap_Getter";

  @DomName('CanvasRenderingContext2D.lineCap')
  @DocsEditable
  void set lineCap(String value) native "CanvasRenderingContext2D_lineCap_Setter";

  @DomName('CanvasRenderingContext2D.lineDashOffset')
  @DocsEditable
  num get lineDashOffset native "CanvasRenderingContext2D_lineDashOffset_Getter";

  @DomName('CanvasRenderingContext2D.lineDashOffset')
  @DocsEditable
  void set lineDashOffset(num value) native "CanvasRenderingContext2D_lineDashOffset_Setter";

  @DomName('CanvasRenderingContext2D.lineJoin')
  @DocsEditable
  String get lineJoin native "CanvasRenderingContext2D_lineJoin_Getter";

  @DomName('CanvasRenderingContext2D.lineJoin')
  @DocsEditable
  void set lineJoin(String value) native "CanvasRenderingContext2D_lineJoin_Setter";

  @DomName('CanvasRenderingContext2D.lineWidth')
  @DocsEditable
  num get lineWidth native "CanvasRenderingContext2D_lineWidth_Getter";

  @DomName('CanvasRenderingContext2D.lineWidth')
  @DocsEditable
  void set lineWidth(num value) native "CanvasRenderingContext2D_lineWidth_Setter";

  @DomName('CanvasRenderingContext2D.miterLimit')
  @DocsEditable
  num get miterLimit native "CanvasRenderingContext2D_miterLimit_Getter";

  @DomName('CanvasRenderingContext2D.miterLimit')
  @DocsEditable
  void set miterLimit(num value) native "CanvasRenderingContext2D_miterLimit_Setter";

  @DomName('CanvasRenderingContext2D.shadowBlur')
  @DocsEditable
  num get shadowBlur native "CanvasRenderingContext2D_shadowBlur_Getter";

  @DomName('CanvasRenderingContext2D.shadowBlur')
  @DocsEditable
  void set shadowBlur(num value) native "CanvasRenderingContext2D_shadowBlur_Setter";

  @DomName('CanvasRenderingContext2D.shadowColor')
  @DocsEditable
  String get shadowColor native "CanvasRenderingContext2D_shadowColor_Getter";

  @DomName('CanvasRenderingContext2D.shadowColor')
  @DocsEditable
  void set shadowColor(String value) native "CanvasRenderingContext2D_shadowColor_Setter";

  @DomName('CanvasRenderingContext2D.shadowOffsetX')
  @DocsEditable
  num get shadowOffsetX native "CanvasRenderingContext2D_shadowOffsetX_Getter";

  @DomName('CanvasRenderingContext2D.shadowOffsetX')
  @DocsEditable
  void set shadowOffsetX(num value) native "CanvasRenderingContext2D_shadowOffsetX_Setter";

  @DomName('CanvasRenderingContext2D.shadowOffsetY')
  @DocsEditable
  num get shadowOffsetY native "CanvasRenderingContext2D_shadowOffsetY_Getter";

  @DomName('CanvasRenderingContext2D.shadowOffsetY')
  @DocsEditable
  void set shadowOffsetY(num value) native "CanvasRenderingContext2D_shadowOffsetY_Setter";

  @DomName('CanvasRenderingContext2D.strokeStyle')
  @DocsEditable
  dynamic get strokeStyle native "CanvasRenderingContext2D_strokeStyle_Getter";

  @DomName('CanvasRenderingContext2D.strokeStyle')
  @DocsEditable
  void set strokeStyle(dynamic value) native "CanvasRenderingContext2D_strokeStyle_Setter";

  @DomName('CanvasRenderingContext2D.textAlign')
  @DocsEditable
  String get textAlign native "CanvasRenderingContext2D_textAlign_Getter";

  @DomName('CanvasRenderingContext2D.textAlign')
  @DocsEditable
  void set textAlign(String value) native "CanvasRenderingContext2D_textAlign_Setter";

  @DomName('CanvasRenderingContext2D.textBaseline')
  @DocsEditable
  String get textBaseline native "CanvasRenderingContext2D_textBaseline_Getter";

  @DomName('CanvasRenderingContext2D.textBaseline')
  @DocsEditable
  void set textBaseline(String value) native "CanvasRenderingContext2D_textBaseline_Setter";

  @DomName('CanvasRenderingContext2D.webkitBackingStorePixelRatio')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  num get backingStorePixelRatio native "CanvasRenderingContext2D_webkitBackingStorePixelRatio_Getter";

  @DomName('CanvasRenderingContext2D.webkitImageSmoothingEnabled')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  bool get imageSmoothingEnabled native "CanvasRenderingContext2D_webkitImageSmoothingEnabled_Getter";

  @DomName('CanvasRenderingContext2D.webkitImageSmoothingEnabled')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void set imageSmoothingEnabled(bool value) native "CanvasRenderingContext2D_webkitImageSmoothingEnabled_Setter";

  @DomName('CanvasRenderingContext2D.arc')
  @DocsEditable
  void $dom_arc(num x, num y, num radius, num startAngle, num endAngle, bool anticlockwise) native "CanvasRenderingContext2D_arc_Callback";

  @DomName('CanvasRenderingContext2D.arcTo')
  @DocsEditable
  void arcTo(num x1, num y1, num x2, num y2, num radius) native "CanvasRenderingContext2D_arcTo_Callback";

  @DomName('CanvasRenderingContext2D.beginPath')
  @DocsEditable
  void beginPath() native "CanvasRenderingContext2D_beginPath_Callback";

  @DomName('CanvasRenderingContext2D.bezierCurveTo')
  @DocsEditable
  void bezierCurveTo(num cp1x, num cp1y, num cp2x, num cp2y, num x, num y) native "CanvasRenderingContext2D_bezierCurveTo_Callback";

  @DomName('CanvasRenderingContext2D.clearRect')
  @DocsEditable
  void clearRect(num x, num y, num width, num height) native "CanvasRenderingContext2D_clearRect_Callback";

  void clip([String winding]) {
    if (?winding) {
      _clip_1(winding);
      return;
    }
    _clip_2();
    return;
  }

  void _clip_1(winding) native "CanvasRenderingContext2D__clip_1_Callback";

  void _clip_2() native "CanvasRenderingContext2D__clip_2_Callback";

  @DomName('CanvasRenderingContext2D.closePath')
  @DocsEditable
  void closePath() native "CanvasRenderingContext2D_closePath_Callback";

  @DomName('CanvasRenderingContext2D.createImageData')
  @DocsEditable
  ImageData createImageData(num sw, num sh) native "CanvasRenderingContext2D_createImageData_Callback";

  @DomName('CanvasRenderingContext2D.createImageDataFromImageData')
  @DocsEditable
  ImageData createImageDataFromImageData(ImageData imagedata) native "CanvasRenderingContext2D_createImageDataFromImageData_Callback";

  @DomName('CanvasRenderingContext2D.createLinearGradient')
  @DocsEditable
  CanvasGradient createLinearGradient(num x0, num y0, num x1, num y1) native "CanvasRenderingContext2D_createLinearGradient_Callback";

  CanvasPattern createPattern(canvas_OR_image, String repetitionType) {
    if ((canvas_OR_image is CanvasElement || canvas_OR_image == null) && (repetitionType is String || repetitionType == null)) {
      return _createPattern_1(canvas_OR_image, repetitionType);
    }
    if ((canvas_OR_image is ImageElement || canvas_OR_image == null) && (repetitionType is String || repetitionType == null)) {
      return _createPattern_2(canvas_OR_image, repetitionType);
    }
    throw new ArgumentError("Incorrect number or type of arguments");
  }

  CanvasPattern _createPattern_1(canvas_OR_image, repetitionType) native "CanvasRenderingContext2D__createPattern_1_Callback";

  CanvasPattern _createPattern_2(canvas_OR_image, repetitionType) native "CanvasRenderingContext2D__createPattern_2_Callback";

  @DomName('CanvasRenderingContext2D.createRadialGradient')
  @DocsEditable
  CanvasGradient createRadialGradient(num x0, num y0, num r0, num x1, num y1, num r1) native "CanvasRenderingContext2D_createRadialGradient_Callback";

  void $dom_drawImage(canvas_OR_image_OR_video, num sx_OR_x, num sy_OR_y, [num sw_OR_width, num height_OR_sh, num dx, num dy, num dw, num dh]) {
    if ((canvas_OR_image_OR_video is ImageElement || canvas_OR_image_OR_video == null) && (sx_OR_x is num || sx_OR_x == null) && (sy_OR_y is num || sy_OR_y == null) && !?sw_OR_width && !?height_OR_sh && !?dx && !?dy && !?dw && !?dh) {
      _drawImage_1(canvas_OR_image_OR_video, sx_OR_x, sy_OR_y);
      return;
    }
    if ((canvas_OR_image_OR_video is ImageElement || canvas_OR_image_OR_video == null) && (sx_OR_x is num || sx_OR_x == null) && (sy_OR_y is num || sy_OR_y == null) && (sw_OR_width is num || sw_OR_width == null) && (height_OR_sh is num || height_OR_sh == null) && !?dx && !?dy && !?dw && !?dh) {
      _drawImage_2(canvas_OR_image_OR_video, sx_OR_x, sy_OR_y, sw_OR_width, height_OR_sh);
      return;
    }
    if ((canvas_OR_image_OR_video is ImageElement || canvas_OR_image_OR_video == null) && (sx_OR_x is num || sx_OR_x == null) && (sy_OR_y is num || sy_OR_y == null) && (sw_OR_width is num || sw_OR_width == null) && (height_OR_sh is num || height_OR_sh == null) && (dx is num || dx == null) && (dy is num || dy == null) && (dw is num || dw == null) && (dh is num || dh == null)) {
      _drawImage_3(canvas_OR_image_OR_video, sx_OR_x, sy_OR_y, sw_OR_width, height_OR_sh, dx, dy, dw, dh);
      return;
    }
    if ((canvas_OR_image_OR_video is CanvasElement || canvas_OR_image_OR_video == null) && (sx_OR_x is num || sx_OR_x == null) && (sy_OR_y is num || sy_OR_y == null) && !?sw_OR_width && !?height_OR_sh && !?dx && !?dy && !?dw && !?dh) {
      _drawImage_4(canvas_OR_image_OR_video, sx_OR_x, sy_OR_y);
      return;
    }
    if ((canvas_OR_image_OR_video is CanvasElement || canvas_OR_image_OR_video == null) && (sx_OR_x is num || sx_OR_x == null) && (sy_OR_y is num || sy_OR_y == null) && (sw_OR_width is num || sw_OR_width == null) && (height_OR_sh is num || height_OR_sh == null) && !?dx && !?dy && !?dw && !?dh) {
      _drawImage_5(canvas_OR_image_OR_video, sx_OR_x, sy_OR_y, sw_OR_width, height_OR_sh);
      return;
    }
    if ((canvas_OR_image_OR_video is CanvasElement || canvas_OR_image_OR_video == null) && (sx_OR_x is num || sx_OR_x == null) && (sy_OR_y is num || sy_OR_y == null) && (sw_OR_width is num || sw_OR_width == null) && (height_OR_sh is num || height_OR_sh == null) && (dx is num || dx == null) && (dy is num || dy == null) && (dw is num || dw == null) && (dh is num || dh == null)) {
      _drawImage_6(canvas_OR_image_OR_video, sx_OR_x, sy_OR_y, sw_OR_width, height_OR_sh, dx, dy, dw, dh);
      return;
    }
    if ((canvas_OR_image_OR_video is VideoElement || canvas_OR_image_OR_video == null) && (sx_OR_x is num || sx_OR_x == null) && (sy_OR_y is num || sy_OR_y == null) && !?sw_OR_width && !?height_OR_sh && !?dx && !?dy && !?dw && !?dh) {
      _drawImage_7(canvas_OR_image_OR_video, sx_OR_x, sy_OR_y);
      return;
    }
    if ((canvas_OR_image_OR_video is VideoElement || canvas_OR_image_OR_video == null) && (sx_OR_x is num || sx_OR_x == null) && (sy_OR_y is num || sy_OR_y == null) && (sw_OR_width is num || sw_OR_width == null) && (height_OR_sh is num || height_OR_sh == null) && !?dx && !?dy && !?dw && !?dh) {
      _drawImage_8(canvas_OR_image_OR_video, sx_OR_x, sy_OR_y, sw_OR_width, height_OR_sh);
      return;
    }
    if ((canvas_OR_image_OR_video is VideoElement || canvas_OR_image_OR_video == null) && (sx_OR_x is num || sx_OR_x == null) && (sy_OR_y is num || sy_OR_y == null) && (sw_OR_width is num || sw_OR_width == null) && (height_OR_sh is num || height_OR_sh == null) && (dx is num || dx == null) && (dy is num || dy == null) && (dw is num || dw == null) && (dh is num || dh == null)) {
      _drawImage_9(canvas_OR_image_OR_video, sx_OR_x, sy_OR_y, sw_OR_width, height_OR_sh, dx, dy, dw, dh);
      return;
    }
    throw new ArgumentError("Incorrect number or type of arguments");
  }

  void _drawImage_1(canvas_OR_image_OR_video, sx_OR_x, sy_OR_y) native "CanvasRenderingContext2D__drawImage_1_Callback";

  void _drawImage_2(canvas_OR_image_OR_video, sx_OR_x, sy_OR_y, sw_OR_width, height_OR_sh) native "CanvasRenderingContext2D__drawImage_2_Callback";

  void _drawImage_3(canvas_OR_image_OR_video, sx_OR_x, sy_OR_y, sw_OR_width, height_OR_sh, dx, dy, dw, dh) native "CanvasRenderingContext2D__drawImage_3_Callback";

  void _drawImage_4(canvas_OR_image_OR_video, sx_OR_x, sy_OR_y) native "CanvasRenderingContext2D__drawImage_4_Callback";

  void _drawImage_5(canvas_OR_image_OR_video, sx_OR_x, sy_OR_y, sw_OR_width, height_OR_sh) native "CanvasRenderingContext2D__drawImage_5_Callback";

  void _drawImage_6(canvas_OR_image_OR_video, sx_OR_x, sy_OR_y, sw_OR_width, height_OR_sh, dx, dy, dw, dh) native "CanvasRenderingContext2D__drawImage_6_Callback";

  void _drawImage_7(canvas_OR_image_OR_video, sx_OR_x, sy_OR_y) native "CanvasRenderingContext2D__drawImage_7_Callback";

  void _drawImage_8(canvas_OR_image_OR_video, sx_OR_x, sy_OR_y, sw_OR_width, height_OR_sh) native "CanvasRenderingContext2D__drawImage_8_Callback";

  void _drawImage_9(canvas_OR_image_OR_video, sx_OR_x, sy_OR_y, sw_OR_width, height_OR_sh, dx, dy, dw, dh) native "CanvasRenderingContext2D__drawImage_9_Callback";

  void fill([String winding]) {
    if (?winding) {
      _fill_1(winding);
      return;
    }
    _fill_2();
    return;
  }

  void _fill_1(winding) native "CanvasRenderingContext2D__fill_1_Callback";

  void _fill_2() native "CanvasRenderingContext2D__fill_2_Callback";

  @DomName('CanvasRenderingContext2D.fillRect')
  @DocsEditable
  void fillRect(num x, num y, num width, num height) native "CanvasRenderingContext2D_fillRect_Callback";

  void fillText(String text, num x, num y, [num maxWidth]) {
    if (?maxWidth) {
      _fillText_1(text, x, y, maxWidth);
      return;
    }
    _fillText_2(text, x, y);
    return;
  }

  void _fillText_1(text, x, y, maxWidth) native "CanvasRenderingContext2D__fillText_1_Callback";

  void _fillText_2(text, x, y) native "CanvasRenderingContext2D__fillText_2_Callback";

  @DomName('CanvasRenderingContext2D.getImageData')
  @DocsEditable
  ImageData getImageData(num sx, num sy, num sw, num sh) native "CanvasRenderingContext2D_getImageData_Callback";

  @DomName('CanvasRenderingContext2D.getLineDash')
  @DocsEditable
  List<num> getLineDash() native "CanvasRenderingContext2D_getLineDash_Callback";

  bool isPointInPath(num x, num y, [String winding]) {
    if (?winding) {
      return _isPointInPath_1(x, y, winding);
    }
    return _isPointInPath_2(x, y);
  }

  bool _isPointInPath_1(x, y, winding) native "CanvasRenderingContext2D__isPointInPath_1_Callback";

  bool _isPointInPath_2(x, y) native "CanvasRenderingContext2D__isPointInPath_2_Callback";

  @DomName('CanvasRenderingContext2D.isPointInStroke')
  @DocsEditable
  bool isPointInStroke(num x, num y) native "CanvasRenderingContext2D_isPointInStroke_Callback";

  @DomName('CanvasRenderingContext2D.lineTo')
  @DocsEditable
  void lineTo(num x, num y) native "CanvasRenderingContext2D_lineTo_Callback";

  @DomName('CanvasRenderingContext2D.measureText')
  @DocsEditable
  TextMetrics measureText(String text) native "CanvasRenderingContext2D_measureText_Callback";

  @DomName('CanvasRenderingContext2D.moveTo')
  @DocsEditable
  void moveTo(num x, num y) native "CanvasRenderingContext2D_moveTo_Callback";

  void putImageData(ImageData imagedata, num dx, num dy, [num dirtyX, num dirtyY, num dirtyWidth, num dirtyHeight]) {
    if ((imagedata is ImageData || imagedata == null) && (dx is num || dx == null) && (dy is num || dy == null) && !?dirtyX && !?dirtyY && !?dirtyWidth && !?dirtyHeight) {
      _putImageData_1(imagedata, dx, dy);
      return;
    }
    if ((imagedata is ImageData || imagedata == null) && (dx is num || dx == null) && (dy is num || dy == null) && (dirtyX is num || dirtyX == null) && (dirtyY is num || dirtyY == null) && (dirtyWidth is num || dirtyWidth == null) && (dirtyHeight is num || dirtyHeight == null)) {
      _putImageData_2(imagedata, dx, dy, dirtyX, dirtyY, dirtyWidth, dirtyHeight);
      return;
    }
    throw new ArgumentError("Incorrect number or type of arguments");
  }

  void _putImageData_1(imagedata, dx, dy) native "CanvasRenderingContext2D__putImageData_1_Callback";

  void _putImageData_2(imagedata, dx, dy, dirtyX, dirtyY, dirtyWidth, dirtyHeight) native "CanvasRenderingContext2D__putImageData_2_Callback";

  @DomName('CanvasRenderingContext2D.quadraticCurveTo')
  @DocsEditable
  void quadraticCurveTo(num cpx, num cpy, num x, num y) native "CanvasRenderingContext2D_quadraticCurveTo_Callback";

  @DomName('CanvasRenderingContext2D.rect')
  @DocsEditable
  void rect(num x, num y, num width, num height) native "CanvasRenderingContext2D_rect_Callback";

  @DomName('CanvasRenderingContext2D.restore')
  @DocsEditable
  void restore() native "CanvasRenderingContext2D_restore_Callback";

  @DomName('CanvasRenderingContext2D.rotate')
  @DocsEditable
  void rotate(num angle) native "CanvasRenderingContext2D_rotate_Callback";

  @DomName('CanvasRenderingContext2D.save')
  @DocsEditable
  void save() native "CanvasRenderingContext2D_save_Callback";

  @DomName('CanvasRenderingContext2D.scale')
  @DocsEditable
  void scale(num sx, num sy) native "CanvasRenderingContext2D_scale_Callback";

  @DomName('CanvasRenderingContext2D.setLineDash')
  @DocsEditable
  void setLineDash(List<num> dash) native "CanvasRenderingContext2D_setLineDash_Callback";

  @DomName('CanvasRenderingContext2D.setTransform')
  @DocsEditable
  void setTransform(num m11, num m12, num m21, num m22, num dx, num dy) native "CanvasRenderingContext2D_setTransform_Callback";

  @DomName('CanvasRenderingContext2D.stroke')
  @DocsEditable
  void stroke() native "CanvasRenderingContext2D_stroke_Callback";

  void strokeRect(num x, num y, num width, num height, [num lineWidth]) {
    if (?lineWidth) {
      _strokeRect_1(x, y, width, height, lineWidth);
      return;
    }
    _strokeRect_2(x, y, width, height);
    return;
  }

  void _strokeRect_1(x, y, width, height, lineWidth) native "CanvasRenderingContext2D__strokeRect_1_Callback";

  void _strokeRect_2(x, y, width, height) native "CanvasRenderingContext2D__strokeRect_2_Callback";

  void strokeText(String text, num x, num y, [num maxWidth]) {
    if (?maxWidth) {
      _strokeText_1(text, x, y, maxWidth);
      return;
    }
    _strokeText_2(text, x, y);
    return;
  }

  void _strokeText_1(text, x, y, maxWidth) native "CanvasRenderingContext2D__strokeText_1_Callback";

  void _strokeText_2(text, x, y) native "CanvasRenderingContext2D__strokeText_2_Callback";

  @DomName('CanvasRenderingContext2D.transform')
  @DocsEditable
  void transform(num m11, num m12, num m21, num m22, num dx, num dy) native "CanvasRenderingContext2D_transform_Callback";

  @DomName('CanvasRenderingContext2D.translate')
  @DocsEditable
  void translate(num tx, num ty) native "CanvasRenderingContext2D_translate_Callback";

  @DomName('CanvasRenderingContext2D.webkitGetImageDataHD')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  ImageData getImageDataHD(num sx, num sy, num sw, num sh) native "CanvasRenderingContext2D_webkitGetImageDataHD_Callback";

  void putImageDataHD(ImageData imagedata, num dx, num dy, [num dirtyX, num dirtyY, num dirtyWidth, num dirtyHeight]) {
    if ((imagedata is ImageData || imagedata == null) && (dx is num || dx == null) && (dy is num || dy == null) && !?dirtyX && !?dirtyY && !?dirtyWidth && !?dirtyHeight) {
      _webkitPutImageDataHD_1(imagedata, dx, dy);
      return;
    }
    if ((imagedata is ImageData || imagedata == null) && (dx is num || dx == null) && (dy is num || dy == null) && (dirtyX is num || dirtyX == null) && (dirtyY is num || dirtyY == null) && (dirtyWidth is num || dirtyWidth == null) && (dirtyHeight is num || dirtyHeight == null)) {
      _webkitPutImageDataHD_2(imagedata, dx, dy, dirtyX, dirtyY, dirtyWidth, dirtyHeight);
      return;
    }
    throw new ArgumentError("Incorrect number or type of arguments");
  }

  void _webkitPutImageDataHD_1(imagedata, dx, dy) native "CanvasRenderingContext2D__webkitPutImageDataHD_1_Callback";

  void _webkitPutImageDataHD_2(imagedata, dx, dy, dirtyX, dirtyY, dirtyWidth, dirtyHeight) native "CanvasRenderingContext2D__webkitPutImageDataHD_2_Callback";


  /**
   * Sets the color used inside shapes.
   * [r], [g], [b] are 0-255, [a] is 0-1.
   */
  void setFillColorRgb(int r, int g, int b, [num a = 1]) {
    this.fillStyle = 'rgba($r, $g, $b, $a)';
  }

  /**
   * Sets the color used inside shapes.
   * [h] is in degrees, 0-360.
   * [s], [l] are in percent, 0-100.
   * [a] is 0-1.
   */
  void setFillColorHsl(int h, num s, num l, [num a = 1]) {
    this.fillStyle = 'hsla($h, $s%, $l%, $a)';
  }

  /**
   * Sets the color used for stroking shapes.
   * [r], [g], [b] are 0-255, [a] is 0-1.
   */
  void setStrokeColorRgb(int r, int g, int b, [num a = 1]) {
    this.strokeStyle = 'rgba($r, $g, $b, $a)';
  }

  /**
   * Sets the color used for stroking shapes.
   * [h] is in degrees, 0-360.
   * [s], [l] are in percent, 0-100.
   * [a] is 0-1.
   */
  void setStrokeColorHsl(int h, num s, num l, [num a = 1]) {
    this.strokeStyle = 'hsla($h, $s%, $l%, $a)';
  }

  @DomName('CanvasRenderingContext2D.arc')
  void arc(num x,  num y,  num radius,  num startAngle, num endAngle,
      [bool anticlockwise = false]) {
    $dom_arc(x, y, radius, startAngle, endAngle, anticlockwise);
  }

  /**
   * Draws an image from a CanvasImageSource to an area of this canvas.
   *
   * The image will be drawn to an area of this canvas defined by
   * [destRect]. [sourceRect] defines the region of the source image that is
   * drawn.
   * If [sourceRect] is not provided, then
   * the entire rectangular image from [source] will be drawn to this context.
   *
   * If the image is larger than canvas
   * will allow, the image will be clipped to fit the available space.
   *
   *     CanvasElement canvas = new CanvasElement(width: 600, height: 600);
   *     CanvasRenderingContext2D ctx = canvas.context2D;
   *     ImageElement img = document.query('img');
   *     img.width = 100;
   *     img.height = 100;
   *
   *     // Scale the image to 20x20.
   *     ctx.drawImageToRect(img, new Rect(50, 50, 20, 20));
   *
   *     VideoElement video = document.query('video');
   *     video.width = 100;
   *     video.height = 100;
   *     // Take the middle 20x20 pixels from the video and stretch them.
   *     ctx.drawImageToRect(video, new Rect(50, 50, 100, 100),
   *         sourceRect: new Rect(40, 40, 20, 20));
   *
   *     // Draw the top 100x20 pixels from the otherCanvas.
   *     CanvasElement otherCanvas = document.query('canvas');
   *     ctx.drawImageToRect(otherCanvas, new Rect(0, 0, 100, 20),
   *         sourceRect: new Rect(0, 0, 100, 20));
   *
   * See also:
   *
   *   * [CanvasImageSource] for more information on what data is retrieved
   * from [source].
   *   * [drawImage](http://www.whatwg.org/specs/web-apps/current-work/multipage/the-canvas-element.html#dom-context-2d-drawimage)
   * from the WHATWG.
   */
  @DomName('CanvasRenderingContext2D.drawImage')
  void drawImageToRect(CanvasImageSource source, Rect destRect,
      {Rect sourceRect}) {
    if (sourceRect == null) {
      $dom_drawImage(source,
          destRect.left,
          destRect.top,
          destRect.width,
          destRect.height);
    } else {
      $dom_drawImage(source,
          sourceRect.left,
          sourceRect.top,
          sourceRect.width,
          sourceRect.height,
          destRect.left,
          destRect.top,
          destRect.width,
          destRect.height);
    }
  }

  /**
   * Draws an image from a CanvasImageSource to this canvas.
   *
   * The entire image from [source] will be drawn to this context with its top
   * left corner at the point ([destX], [destY]). If the image is
   * larger than canvas will allow, the image will be clipped to fit the
   * available space.
   *
   *     CanvasElement canvas = new CanvasElement(width: 600, height: 600);
   *     CanvasRenderingContext2D ctx = canvas.context2D;
   *     ImageElement img = document.query('img');
   *
   *     ctx.drawImage(img, 100, 100);
   *
   *     VideoElement video = document.query('video');
   *     ctx.drawImage(video, 0, 0);
   *
   *     CanvasElement otherCanvas = document.query('canvas');
   *     otherCanvas.width = 100;
   *     otherCanvas.height = 100;
   *     ctx.drawImage(otherCanvas, 590, 590); // will get clipped
   *
   * See also:
   *
   *   * [CanvasImageSource] for more information on what data is retrieved
   * from [source].
   *   * [drawImage](http://www.whatwg.org/specs/web-apps/current-work/multipage/the-canvas-element.html#dom-context-2d-drawimage)
   * from the WHATWG.
   */
  @DomName('CanvasRenderingContext2D.drawImage')
  void drawImage(CanvasImageSource source, num destX, num destY) {
    $dom_drawImage(source, destX, destY);
  }

  /**
   * Draws an image from a CanvasImageSource to an area of this canvas.
   *
   * The image will be drawn to this context with its top left corner at the
   * point ([destX], [destY]) and will be scaled to be [destWidth] wide and
   * [destHeight] tall.
   *
   * If the image is larger than canvas
   * will allow, the image will be clipped to fit the available space.
   *
   *     CanvasElement canvas = new CanvasElement(width: 600, height: 600);
   *     CanvasRenderingContext2D ctx = canvas.context2D;
   *     ImageElement img = document.query('img');
   *     img.width = 100;
   *     img.height = 100;
   *
   *     // Scale the image to 300x50 at the point (20, 20)
   *     ctx.drawImageScaled(img, 20, 20, 300, 50);
   *
   * See also:
   *
   *   * [CanvasImageSource] for more information on what data is retrieved
   * from [source].
   *   * [drawImage](http://www.whatwg.org/specs/web-apps/current-work/multipage/the-canvas-element.html#dom-context-2d-drawimage)
   * from the WHATWG.
   */
  @DomName('CanvasRenderingContext2D.drawImage')
  void drawImageScaled(CanvasImageSource source,
      num destX, num destY, num destWidth, num destHeight) {
    $dom_drawImage(source, destX, destY, destWidth, destHeight);
  }

  /**
   * Draws an image from a CanvasImageSource to an area of this canvas.
   *
   * The image is a region of [source] that is [sourceWidth] wide and
   * [destHeight] tall with top left corner at ([sourceX], [sourceY]).
   * The image will be drawn to this context with its top left corner at the
   * point ([destX], [destY]) and will be scaled to be [destWidth] wide and
   * [destHeight] tall.
   *
   * If the image is larger than canvas
   * will allow, the image will be clipped to fit the available space.
   *
   *     VideoElement video = document.query('video');
   *     video.width = 100;
   *     video.height = 100;
   *     // Take the middle 20x20 pixels from the video and stretch them.
   *     ctx.drawImageScaledFromSource(video, 40, 40, 20, 20, 50, 50, 100, 100);
   *
   *     // Draw the top 100x20 pixels from the otherCanvas to this one.
   *     CanvasElement otherCanvas = document.query('canvas');
   *     ctx.drawImageScaledFromSource(otherCanvas, 0, 0, 100, 20, 0, 0, 100, 20);
   *
   * See also:
   *
   *   * [CanvasImageSource] for more information on what data is retrieved
   * from [source].
   *   * [drawImage](http://www.whatwg.org/specs/web-apps/current-work/multipage/the-canvas-element.html#dom-context-2d-drawimage)
   * from the WHATWG.
   */
  @DomName('CanvasRenderingContext2D.drawImage')
  void drawImageScaledFromSource(CanvasImageSource source,
      num sourceX, num sourceY, num sourceWidth, num sourceHeight,
      num destX, num destY, num destWidth, num destHeight) {
    $dom_drawImage(source, sourceX, sourceY, sourceWidth, sourceHeight,
        destX, destY, destWidth, destHeight);
  }

  // TODO(amouravski): Add Dartium native methods for drawImage once we figure
  // out how to not break native bindings.
}

// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('CharacterData')
class CharacterData extends Node {
  CharacterData.internal() : super.internal();

  @DomName('CharacterData.data')
  @DocsEditable
  String get data native "CharacterData_data_Getter";

  @DomName('CharacterData.data')
  @DocsEditable
  void set data(String value) native "CharacterData_data_Setter";

  @DomName('CharacterData.length')
  @DocsEditable
  int get length native "CharacterData_length_Getter";

  @DomName('CharacterData.appendData')
  @DocsEditable
  void appendData(String data) native "CharacterData_appendData_Callback";

  @DomName('CharacterData.deleteData')
  @DocsEditable
  void deleteData(int offset, int length) native "CharacterData_deleteData_Callback";

  @DomName('CharacterData.insertData')
  @DocsEditable
  void insertData(int offset, String data) native "CharacterData_insertData_Callback";

  @DomName('CharacterData.replaceData')
  @DocsEditable
  void replaceData(int offset, int length, String data) native "CharacterData_replaceData_Callback";

  @DomName('CharacterData.substringData')
  @DocsEditable
  String substringData(int offset, int length) native "CharacterData_substringData_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('CloseEvent')
class CloseEvent extends Event {
  CloseEvent.internal() : super.internal();

  @DomName('CloseEvent.code')
  @DocsEditable
  int get code native "CloseEvent_code_Getter";

  @DomName('CloseEvent.reason')
  @DocsEditable
  String get reason native "CloseEvent_reason_Getter";

  @DomName('CloseEvent.wasClean')
  @DocsEditable
  bool get wasClean native "CloseEvent_wasClean_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('Comment')
class Comment extends CharacterData {
  Comment.internal() : super.internal();

}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DomName('CompositionEvent')
class CompositionEvent extends UIEvent {
  factory CompositionEvent(String type,
      {bool canBubble: false, bool cancelable: false, Window view,
      String data}) {
    if (view == null) {
      view = window;
    }
    var e = document.$dom_createEvent("CompositionEvent");
    e.$dom_initCompositionEvent(type, canBubble, cancelable, view, data);
    return e;
  }
  CompositionEvent.internal() : super.internal();

  @DomName('CompositionEvent.data')
  @DocsEditable
  String get data native "CompositionEvent_data_Getter";

  @DomName('CompositionEvent.initCompositionEvent')
  @DocsEditable
  void $dom_initCompositionEvent(String typeArg, bool canBubbleArg, bool cancelableArg, Window viewArg, String dataArg) native "CompositionEvent_initCompositionEvent_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('Console')
class Console extends NativeFieldWrapperClass1 {
  Console.internal();

  @DomName('Console.memory')
  @DocsEditable
  MemoryInfo get memory native "Console_memory_Getter";

  @DomName('Console.profiles')
  @DocsEditable
  List<ScriptProfile> get profiles native "Console_profiles_Getter";

  @DomName('Console.assertCondition')
  @DocsEditable
  void assertCondition(bool condition, Object arg) native "Console_assertCondition_Callback";

  @DomName('Console.clear')
  @DocsEditable
  void clear(Object arg) native "Console_clear_Callback";

  @DomName('Console.count')
  @DocsEditable
  void count(Object arg) native "Console_count_Callback";

  @DomName('Console.debug')
  @DocsEditable
  void debug(Object arg) native "Console_debug_Callback";

  @DomName('Console.dir')
  @DocsEditable
  void dir(Object arg) native "Console_dir_Callback";

  @DomName('Console.dirxml')
  @DocsEditable
  void dirxml(Object arg) native "Console_dirxml_Callback";

  @DomName('Console.error')
  @DocsEditable
  void error(Object arg) native "Console_error_Callback";

  @DomName('Console.group')
  @DocsEditable
  void group(Object arg) native "Console_group_Callback";

  @DomName('Console.groupCollapsed')
  @DocsEditable
  void groupCollapsed(Object arg) native "Console_groupCollapsed_Callback";

  @DomName('Console.groupEnd')
  @DocsEditable
  void groupEnd() native "Console_groupEnd_Callback";

  @DomName('Console.info')
  @DocsEditable
  void info(Object arg) native "Console_info_Callback";

  @DomName('Console.log')
  @DocsEditable
  void log(Object arg) native "Console_log_Callback";

  @DomName('Console.markTimeline')
  @DocsEditable
  void markTimeline() native "Console_markTimeline_Callback";

  @DomName('Console.profile')
  @DocsEditable
  void profile(String title) native "Console_profile_Callback";

  @DomName('Console.profileEnd')
  @DocsEditable
  void profileEnd(String title) native "Console_profileEnd_Callback";

  @DomName('Console.table')
  @DocsEditable
  void table(Object arg) native "Console_table_Callback";

  @DomName('Console.time')
  @DocsEditable
  void time(String title) native "Console_time_Callback";

  @DomName('Console.timeEnd')
  @DocsEditable
  void timeEnd(String title) native "Console_timeEnd_Callback";

  @DomName('Console.timeStamp')
  @DocsEditable
  void timeStamp() native "Console_timeStamp_Callback";

  @DomName('Console.trace')
  @DocsEditable
  void trace(Object arg) native "Console_trace_Callback";

  @DomName('Console.warn')
  @DocsEditable
  void warn(Object arg) native "Console_warn_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLContentElement')
@SupportedBrowser(SupportedBrowser.CHROME, '26')
@Experimental
class ContentElement extends _Element_Merged {
  ContentElement.internal() : super.internal();

  @DomName('HTMLContentElement.HTMLContentElement')
  @DocsEditable
  factory ContentElement() => document.$dom_createElement("content");

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('HTMLContentElement.resetStyleInheritance')
  @DocsEditable
  bool get resetStyleInheritance native "HTMLContentElement_resetStyleInheritance_Getter";

  @DomName('HTMLContentElement.resetStyleInheritance')
  @DocsEditable
  void set resetStyleInheritance(bool value) native "HTMLContentElement_resetStyleInheritance_Setter";

  @DomName('HTMLContentElement.select')
  @DocsEditable
  String get select native "HTMLContentElement_select_Getter";

  @DomName('HTMLContentElement.select')
  @DocsEditable
  void set select(String value) native "HTMLContentElement_select_Setter";

  @DomName('HTMLContentElement.getDistributedNodes')
  @DocsEditable
  List<Node> getDistributedNodes() native "HTMLContentElement_getDistributedNodes_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('Coordinates')
class Coordinates extends NativeFieldWrapperClass1 {
  Coordinates.internal();

  @DomName('Coordinates.accuracy')
  @DocsEditable
  num get accuracy native "Coordinates_accuracy_Getter";

  @DomName('Coordinates.altitude')
  @DocsEditable
  num get altitude native "Coordinates_altitude_Getter";

  @DomName('Coordinates.altitudeAccuracy')
  @DocsEditable
  num get altitudeAccuracy native "Coordinates_altitudeAccuracy_Getter";

  @DomName('Coordinates.heading')
  @DocsEditable
  num get heading native "Coordinates_heading_Getter";

  @DomName('Coordinates.latitude')
  @DocsEditable
  num get latitude native "Coordinates_latitude_Getter";

  @DomName('Coordinates.longitude')
  @DocsEditable
  num get longitude native "Coordinates_longitude_Getter";

  @DomName('Coordinates.speed')
  @DocsEditable
  num get speed native "Coordinates_speed_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('Crypto')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.SAFARI)
@Experimental
class Crypto extends NativeFieldWrapperClass1 {
  Crypto.internal();

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('Crypto.getRandomValues')
  @DocsEditable
  TypedData getRandomValues(TypedData array) native "Crypto_getRandomValues_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('CSSCharsetRule')
class CssCharsetRule extends CssRule {
  CssCharsetRule.internal() : super.internal();

  @DomName('CSSCharsetRule.encoding')
  @DocsEditable
  String get encoding native "CSSCharsetRule_encoding_Getter";

  @DomName('CSSCharsetRule.encoding')
  @DocsEditable
  void set encoding(String value) native "CSSCharsetRule_encoding_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('WebKitCSSFilterRule')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.SAFARI)
@Experimental
class CssFilterRule extends CssRule {
  CssFilterRule.internal() : super.internal();

  @DomName('WebKitCSSFilterRule.style')
  @DocsEditable
  CssStyleDeclaration get style native "WebKitCSSFilterRule_style_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('CSSFontFaceLoadEvent')
class CssFontFaceLoadEvent extends Event {
  CssFontFaceLoadEvent.internal() : super.internal();

  @DomName('CSSFontFaceLoadEvent.error')
  @DocsEditable
  DomError get error native "CSSFontFaceLoadEvent_error_Getter";

  @DomName('CSSFontFaceLoadEvent.fontface')
  @DocsEditable
  CssFontFaceRule get fontface native "CSSFontFaceLoadEvent_fontface_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('CSSFontFaceRule')
class CssFontFaceRule extends CssRule {
  CssFontFaceRule.internal() : super.internal();

  @DomName('CSSFontFaceRule.style')
  @DocsEditable
  CssStyleDeclaration get style native "CSSFontFaceRule_style_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('CSSHostRule')
@SupportedBrowser(SupportedBrowser.CHROME, '26')
@Experimental
class CssHostRule extends CssRule {
  CssHostRule.internal() : super.internal();

  @DomName('CSSHostRule.cssRules')
  @DocsEditable
  List<CssRule> get cssRules native "CSSHostRule_cssRules_Getter";

  @DomName('CSSHostRule.deleteRule')
  @DocsEditable
  void deleteRule(int index) native "CSSHostRule_deleteRule_Callback";

  @DomName('CSSHostRule.insertRule')
  @DocsEditable
  int insertRule(String rule, int index) native "CSSHostRule_insertRule_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('CSSImportRule')
class CssImportRule extends CssRule {
  CssImportRule.internal() : super.internal();

  @DomName('CSSImportRule.href')
  @DocsEditable
  String get href native "CSSImportRule_href_Getter";

  @DomName('CSSImportRule.media')
  @DocsEditable
  MediaList get media native "CSSImportRule_media_Getter";

  @DomName('CSSImportRule.styleSheet')
  @DocsEditable
  CssStyleSheet get styleSheet native "CSSImportRule_styleSheet_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('WebKitCSSKeyframeRule')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.SAFARI)
@Experimental
class CssKeyframeRule extends CssRule {
  CssKeyframeRule.internal() : super.internal();

  @DomName('WebKitCSSKeyframeRule.keyText')
  @DocsEditable
  String get keyText native "WebKitCSSKeyframeRule_keyText_Getter";

  @DomName('WebKitCSSKeyframeRule.keyText')
  @DocsEditable
  void set keyText(String value) native "WebKitCSSKeyframeRule_keyText_Setter";

  @DomName('WebKitCSSKeyframeRule.style')
  @DocsEditable
  CssStyleDeclaration get style native "WebKitCSSKeyframeRule_style_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('WebKitCSSKeyframesRule')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.SAFARI)
@Experimental
class CssKeyframesRule extends CssRule {
  CssKeyframesRule.internal() : super.internal();

  @DomName('WebKitCSSKeyframesRule.cssRules')
  @DocsEditable
  List<CssRule> get cssRules native "WebKitCSSKeyframesRule_cssRules_Getter";

  @DomName('WebKitCSSKeyframesRule.name')
  @DocsEditable
  String get name native "WebKitCSSKeyframesRule_name_Getter";

  @DomName('WebKitCSSKeyframesRule.name')
  @DocsEditable
  void set name(String value) native "WebKitCSSKeyframesRule_name_Setter";

  @DomName('WebKitCSSKeyframesRule.deleteRule')
  @DocsEditable
  void deleteRule(String key) native "WebKitCSSKeyframesRule_deleteRule_Callback";

  @DomName('WebKitCSSKeyframesRule.findRule')
  @DocsEditable
  CssKeyframeRule findRule(String key) native "WebKitCSSKeyframesRule_findRule_Callback";

  @DomName('WebKitCSSKeyframesRule.insertRule')
  @DocsEditable
  void insertRule(String rule) native "WebKitCSSKeyframesRule_insertRule_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('CSSMediaRule')
class CssMediaRule extends CssRule {
  CssMediaRule.internal() : super.internal();

  @DomName('CSSMediaRule.cssRules')
  @DocsEditable
  List<CssRule> get cssRules native "CSSMediaRule_cssRules_Getter";

  @DomName('CSSMediaRule.media')
  @DocsEditable
  MediaList get media native "CSSMediaRule_media_Getter";

  @DomName('CSSMediaRule.deleteRule')
  @DocsEditable
  void deleteRule(int index) native "CSSMediaRule_deleteRule_Callback";

  @DomName('CSSMediaRule.insertRule')
  @DocsEditable
  int insertRule(String rule, int index) native "CSSMediaRule_insertRule_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('CSSPageRule')
class CssPageRule extends CssRule {
  CssPageRule.internal() : super.internal();

  @DomName('CSSPageRule.selectorText')
  @DocsEditable
  String get selectorText native "CSSPageRule_selectorText_Getter";

  @DomName('CSSPageRule.selectorText')
  @DocsEditable
  void set selectorText(String value) native "CSSPageRule_selectorText_Setter";

  @DomName('CSSPageRule.style')
  @DocsEditable
  CssStyleDeclaration get style native "CSSPageRule_style_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('WebKitCSSRegionRule')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.SAFARI)
@Experimental
class CssRegionRule extends CssRule {
  CssRegionRule.internal() : super.internal();

  @DomName('WebKitCSSRegionRule.cssRules')
  @DocsEditable
  List<CssRule> get cssRules native "WebKitCSSRegionRule_cssRules_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('CSSRule')
class CssRule extends NativeFieldWrapperClass1 {
  CssRule.internal();

  @DomName('CSSRule.CHARSET_RULE')
  @DocsEditable
  static const int CHARSET_RULE = 2;

  @DomName('CSSRule.FONT_FACE_RULE')
  @DocsEditable
  static const int FONT_FACE_RULE = 5;

  @DomName('CSSRule.HOST_RULE')
  @DocsEditable
  static const int HOST_RULE = 1001;

  @DomName('CSSRule.IMPORT_RULE')
  @DocsEditable
  static const int IMPORT_RULE = 3;

  @DomName('CSSRule.MEDIA_RULE')
  @DocsEditable
  static const int MEDIA_RULE = 4;

  @DomName('CSSRule.PAGE_RULE')
  @DocsEditable
  static const int PAGE_RULE = 6;

  @DomName('CSSRule.STYLE_RULE')
  @DocsEditable
  static const int STYLE_RULE = 1;

  @DomName('CSSRule.UNKNOWN_RULE')
  @DocsEditable
  static const int UNKNOWN_RULE = 0;

  @DomName('CSSRule.WEBKIT_FILTER_RULE')
  @DocsEditable
  static const int WEBKIT_FILTER_RULE = 17;

  @DomName('CSSRule.WEBKIT_KEYFRAMES_RULE')
  @DocsEditable
  static const int WEBKIT_KEYFRAMES_RULE = 7;

  @DomName('CSSRule.WEBKIT_KEYFRAME_RULE')
  @DocsEditable
  static const int WEBKIT_KEYFRAME_RULE = 8;

  @DomName('CSSRule.WEBKIT_REGION_RULE')
  @DocsEditable
  static const int WEBKIT_REGION_RULE = 16;

  @DomName('CSSRule.cssText')
  @DocsEditable
  String get cssText native "CSSRule_cssText_Getter";

  @DomName('CSSRule.cssText')
  @DocsEditable
  void set cssText(String value) native "CSSRule_cssText_Setter";

  @DomName('CSSRule.parentRule')
  @DocsEditable
  CssRule get parentRule native "CSSRule_parentRule_Getter";

  @DomName('CSSRule.parentStyleSheet')
  @DocsEditable
  CssStyleSheet get parentStyleSheet native "CSSRule_parentStyleSheet_Getter";

  @DomName('CSSRule.type')
  @DocsEditable
  int get type native "CSSRule_type_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('CSSStyleDeclaration')
class CssStyleDeclaration extends NativeFieldWrapperClass1 {
  factory CssStyleDeclaration() => _CssStyleDeclarationFactoryProvider.createCssStyleDeclaration();
  factory CssStyleDeclaration.css(String css) =>
      _CssStyleDeclarationFactoryProvider.createCssStyleDeclaration_css(css);

  CssStyleDeclaration.internal();

  @DomName('CSSStyleDeclaration.cssText')
  @DocsEditable
  String get cssText native "CSSStyleDeclaration_cssText_Getter";

  @DomName('CSSStyleDeclaration.cssText')
  @DocsEditable
  void set cssText(String value) native "CSSStyleDeclaration_cssText_Setter";

  @DomName('CSSStyleDeclaration.length')
  @DocsEditable
  int get length native "CSSStyleDeclaration_length_Getter";

  @DomName('CSSStyleDeclaration.parentRule')
  @DocsEditable
  CssRule get parentRule native "CSSStyleDeclaration_parentRule_Getter";

  @DomName('CSSStyleDeclaration.getPropertyPriority')
  @DocsEditable
  String getPropertyPriority(String propertyName) native "CSSStyleDeclaration_getPropertyPriority_Callback";

  @DomName('CSSStyleDeclaration.getPropertyShorthand')
  @DocsEditable
  String getPropertyShorthand(String propertyName) native "CSSStyleDeclaration_getPropertyShorthand_Callback";

  @DomName('CSSStyleDeclaration.getPropertyValue')
  @DocsEditable
  String _getPropertyValue(String propertyName) native "CSSStyleDeclaration_getPropertyValue_Callback";

  @DomName('CSSStyleDeclaration.isPropertyImplicit')
  @DocsEditable
  bool isPropertyImplicit(String propertyName) native "CSSStyleDeclaration_isPropertyImplicit_Callback";

  @DomName('CSSStyleDeclaration.item')
  @DocsEditable
  String item(int index) native "CSSStyleDeclaration_item_Callback";

  @DomName('CSSStyleDeclaration.removeProperty')
  @DocsEditable
  String removeProperty(String propertyName) native "CSSStyleDeclaration_removeProperty_Callback";

  @DomName('CSSStyleDeclaration.setProperty')
  @DocsEditable
  void _setProperty(String propertyName, String value, String priority) native "CSSStyleDeclaration_setProperty_Callback";


  String getPropertyValue(String propertyName) {
    var propValue = _getPropertyValue(propertyName);
    return propValue != null ? propValue : '';
  }

  /**
   * Checks to see if CSS Transitions are supported.
   */
  static bool get supportsTransitions => true;

  @DomName('CSSStyleDeclaration.setProperty')
  void setProperty(String propertyName, String value, [String priority]) {
    if (priority == null) {
      priority = '';
    }
    _setProperty(propertyName, value, priority);
  }

  // TODO(jacobr): generate this list of properties using the existing script.
  /** Gets the value of "align-content" */
  String get alignContent =>
    getPropertyValue('${Device.cssPrefix}align-content');

  /** Sets the value of "align-content" */
  void set alignContent(String value) {
    setProperty('${Device.cssPrefix}align-content', value, '');
  }

  /** Gets the value of "align-items" */
  String get alignItems =>
    getPropertyValue('${Device.cssPrefix}align-items');

  /** Sets the value of "align-items" */
  void set alignItems(String value) {
    setProperty('${Device.cssPrefix}align-items', value, '');
  }

  /** Gets the value of "align-self" */
  String get alignSelf =>
    getPropertyValue('${Device.cssPrefix}align-self');

  /** Sets the value of "align-self" */
  void set alignSelf(String value) {
    setProperty('${Device.cssPrefix}align-self', value, '');
  }

  /** Gets the value of "animation" */
  String get animation =>
    getPropertyValue('${Device.cssPrefix}animation');

  /** Sets the value of "animation" */
  void set animation(String value) {
    setProperty('${Device.cssPrefix}animation', value, '');
  }

  /** Gets the value of "animation-delay" */
  String get animationDelay =>
    getPropertyValue('${Device.cssPrefix}animation-delay');

  /** Sets the value of "animation-delay" */
  void set animationDelay(String value) {
    setProperty('${Device.cssPrefix}animation-delay', value, '');
  }

  /** Gets the value of "animation-direction" */
  String get animationDirection =>
    getPropertyValue('${Device.cssPrefix}animation-direction');

  /** Sets the value of "animation-direction" */
  void set animationDirection(String value) {
    setProperty('${Device.cssPrefix}animation-direction', value, '');
  }

  /** Gets the value of "animation-duration" */
  String get animationDuration =>
    getPropertyValue('${Device.cssPrefix}animation-duration');

  /** Sets the value of "animation-duration" */
  void set animationDuration(String value) {
    setProperty('${Device.cssPrefix}animation-duration', value, '');
  }

  /** Gets the value of "animation-fill-mode" */
  String get animationFillMode =>
    getPropertyValue('${Device.cssPrefix}animation-fill-mode');

  /** Sets the value of "animation-fill-mode" */
  void set animationFillMode(String value) {
    setProperty('${Device.cssPrefix}animation-fill-mode', value, '');
  }

  /** Gets the value of "animation-iteration-count" */
  String get animationIterationCount =>
    getPropertyValue('${Device.cssPrefix}animation-iteration-count');

  /** Sets the value of "animation-iteration-count" */
  void set animationIterationCount(String value) {
    setProperty('${Device.cssPrefix}animation-iteration-count', value, '');
  }

  /** Gets the value of "animation-name" */
  String get animationName =>
    getPropertyValue('${Device.cssPrefix}animation-name');

  /** Sets the value of "animation-name" */
  void set animationName(String value) {
    setProperty('${Device.cssPrefix}animation-name', value, '');
  }

  /** Gets the value of "animation-play-state" */
  String get animationPlayState =>
    getPropertyValue('${Device.cssPrefix}animation-play-state');

  /** Sets the value of "animation-play-state" */
  void set animationPlayState(String value) {
    setProperty('${Device.cssPrefix}animation-play-state', value, '');
  }

  /** Gets the value of "animation-timing-function" */
  String get animationTimingFunction =>
    getPropertyValue('${Device.cssPrefix}animation-timing-function');

  /** Sets the value of "animation-timing-function" */
  void set animationTimingFunction(String value) {
    setProperty('${Device.cssPrefix}animation-timing-function', value, '');
  }

  /** Gets the value of "app-region" */
  String get appRegion =>
    getPropertyValue('${Device.cssPrefix}app-region');

  /** Sets the value of "app-region" */
  void set appRegion(String value) {
    setProperty('${Device.cssPrefix}app-region', value, '');
  }

  /** Gets the value of "appearance" */
  String get appearance =>
    getPropertyValue('${Device.cssPrefix}appearance');

  /** Sets the value of "appearance" */
  void set appearance(String value) {
    setProperty('${Device.cssPrefix}appearance', value, '');
  }

  /** Gets the value of "aspect-ratio" */
  String get aspectRatio =>
    getPropertyValue('${Device.cssPrefix}aspect-ratio');

  /** Sets the value of "aspect-ratio" */
  void set aspectRatio(String value) {
    setProperty('${Device.cssPrefix}aspect-ratio', value, '');
  }

  /** Gets the value of "backface-visibility" */
  String get backfaceVisibility =>
    getPropertyValue('${Device.cssPrefix}backface-visibility');

  /** Sets the value of "backface-visibility" */
  void set backfaceVisibility(String value) {
    setProperty('${Device.cssPrefix}backface-visibility', value, '');
  }

  /** Gets the value of "background" */
  String get background =>
    getPropertyValue('background');

  /** Sets the value of "background" */
  void set background(String value) {
    setProperty('background', value, '');
  }

  /** Gets the value of "background-attachment" */
  String get backgroundAttachment =>
    getPropertyValue('background-attachment');

  /** Sets the value of "background-attachment" */
  void set backgroundAttachment(String value) {
    setProperty('background-attachment', value, '');
  }

  /** Gets the value of "background-clip" */
  String get backgroundClip =>
    getPropertyValue('background-clip');

  /** Sets the value of "background-clip" */
  void set backgroundClip(String value) {
    setProperty('background-clip', value, '');
  }

  /** Gets the value of "background-color" */
  String get backgroundColor =>
    getPropertyValue('background-color');

  /** Sets the value of "background-color" */
  void set backgroundColor(String value) {
    setProperty('background-color', value, '');
  }

  /** Gets the value of "background-composite" */
  String get backgroundComposite =>
    getPropertyValue('${Device.cssPrefix}background-composite');

  /** Sets the value of "background-composite" */
  void set backgroundComposite(String value) {
    setProperty('${Device.cssPrefix}background-composite', value, '');
  }

  /** Gets the value of "background-image" */
  String get backgroundImage =>
    getPropertyValue('background-image');

  /** Sets the value of "background-image" */
  void set backgroundImage(String value) {
    setProperty('background-image', value, '');
  }

  /** Gets the value of "background-origin" */
  String get backgroundOrigin =>
    getPropertyValue('background-origin');

  /** Sets the value of "background-origin" */
  void set backgroundOrigin(String value) {
    setProperty('background-origin', value, '');
  }

  /** Gets the value of "background-position" */
  String get backgroundPosition =>
    getPropertyValue('background-position');

  /** Sets the value of "background-position" */
  void set backgroundPosition(String value) {
    setProperty('background-position', value, '');
  }

  /** Gets the value of "background-position-x" */
  String get backgroundPositionX =>
    getPropertyValue('background-position-x');

  /** Sets the value of "background-position-x" */
  void set backgroundPositionX(String value) {
    setProperty('background-position-x', value, '');
  }

  /** Gets the value of "background-position-y" */
  String get backgroundPositionY =>
    getPropertyValue('background-position-y');

  /** Sets the value of "background-position-y" */
  void set backgroundPositionY(String value) {
    setProperty('background-position-y', value, '');
  }

  /** Gets the value of "background-repeat" */
  String get backgroundRepeat =>
    getPropertyValue('background-repeat');

  /** Sets the value of "background-repeat" */
  void set backgroundRepeat(String value) {
    setProperty('background-repeat', value, '');
  }

  /** Gets the value of "background-repeat-x" */
  String get backgroundRepeatX =>
    getPropertyValue('background-repeat-x');

  /** Sets the value of "background-repeat-x" */
  void set backgroundRepeatX(String value) {
    setProperty('background-repeat-x', value, '');
  }

  /** Gets the value of "background-repeat-y" */
  String get backgroundRepeatY =>
    getPropertyValue('background-repeat-y');

  /** Sets the value of "background-repeat-y" */
  void set backgroundRepeatY(String value) {
    setProperty('background-repeat-y', value, '');
  }

  /** Gets the value of "background-size" */
  String get backgroundSize =>
    getPropertyValue('background-size');

  /** Sets the value of "background-size" */
  void set backgroundSize(String value) {
    setProperty('background-size', value, '');
  }

  /** Gets the value of "blend-mode" */
  String get blendMode =>
    getPropertyValue('${Device.cssPrefix}blend-mode');

  /** Sets the value of "blend-mode" */
  void set blendMode(String value) {
    setProperty('${Device.cssPrefix}blend-mode', value, '');
  }

  /** Gets the value of "border" */
  String get border =>
    getPropertyValue('border');

  /** Sets the value of "border" */
  void set border(String value) {
    setProperty('border', value, '');
  }

  /** Gets the value of "border-after" */
  String get borderAfter =>
    getPropertyValue('${Device.cssPrefix}border-after');

  /** Sets the value of "border-after" */
  void set borderAfter(String value) {
    setProperty('${Device.cssPrefix}border-after', value, '');
  }

  /** Gets the value of "border-after-color" */
  String get borderAfterColor =>
    getPropertyValue('${Device.cssPrefix}border-after-color');

  /** Sets the value of "border-after-color" */
  void set borderAfterColor(String value) {
    setProperty('${Device.cssPrefix}border-after-color', value, '');
  }

  /** Gets the value of "border-after-style" */
  String get borderAfterStyle =>
    getPropertyValue('${Device.cssPrefix}border-after-style');

  /** Sets the value of "border-after-style" */
  void set borderAfterStyle(String value) {
    setProperty('${Device.cssPrefix}border-after-style', value, '');
  }

  /** Gets the value of "border-after-width" */
  String get borderAfterWidth =>
    getPropertyValue('${Device.cssPrefix}border-after-width');

  /** Sets the value of "border-after-width" */
  void set borderAfterWidth(String value) {
    setProperty('${Device.cssPrefix}border-after-width', value, '');
  }

  /** Gets the value of "border-before" */
  String get borderBefore =>
    getPropertyValue('${Device.cssPrefix}border-before');

  /** Sets the value of "border-before" */
  void set borderBefore(String value) {
    setProperty('${Device.cssPrefix}border-before', value, '');
  }

  /** Gets the value of "border-before-color" */
  String get borderBeforeColor =>
    getPropertyValue('${Device.cssPrefix}border-before-color');

  /** Sets the value of "border-before-color" */
  void set borderBeforeColor(String value) {
    setProperty('${Device.cssPrefix}border-before-color', value, '');
  }

  /** Gets the value of "border-before-style" */
  String get borderBeforeStyle =>
    getPropertyValue('${Device.cssPrefix}border-before-style');

  /** Sets the value of "border-before-style" */
  void set borderBeforeStyle(String value) {
    setProperty('${Device.cssPrefix}border-before-style', value, '');
  }

  /** Gets the value of "border-before-width" */
  String get borderBeforeWidth =>
    getPropertyValue('${Device.cssPrefix}border-before-width');

  /** Sets the value of "border-before-width" */
  void set borderBeforeWidth(String value) {
    setProperty('${Device.cssPrefix}border-before-width', value, '');
  }

  /** Gets the value of "border-bottom" */
  String get borderBottom =>
    getPropertyValue('border-bottom');

  /** Sets the value of "border-bottom" */
  void set borderBottom(String value) {
    setProperty('border-bottom', value, '');
  }

  /** Gets the value of "border-bottom-color" */
  String get borderBottomColor =>
    getPropertyValue('border-bottom-color');

  /** Sets the value of "border-bottom-color" */
  void set borderBottomColor(String value) {
    setProperty('border-bottom-color', value, '');
  }

  /** Gets the value of "border-bottom-left-radius" */
  String get borderBottomLeftRadius =>
    getPropertyValue('border-bottom-left-radius');

  /** Sets the value of "border-bottom-left-radius" */
  void set borderBottomLeftRadius(String value) {
    setProperty('border-bottom-left-radius', value, '');
  }

  /** Gets the value of "border-bottom-right-radius" */
  String get borderBottomRightRadius =>
    getPropertyValue('border-bottom-right-radius');

  /** Sets the value of "border-bottom-right-radius" */
  void set borderBottomRightRadius(String value) {
    setProperty('border-bottom-right-radius', value, '');
  }

  /** Gets the value of "border-bottom-style" */
  String get borderBottomStyle =>
    getPropertyValue('border-bottom-style');

  /** Sets the value of "border-bottom-style" */
  void set borderBottomStyle(String value) {
    setProperty('border-bottom-style', value, '');
  }

  /** Gets the value of "border-bottom-width" */
  String get borderBottomWidth =>
    getPropertyValue('border-bottom-width');

  /** Sets the value of "border-bottom-width" */
  void set borderBottomWidth(String value) {
    setProperty('border-bottom-width', value, '');
  }

  /** Gets the value of "border-collapse" */
  String get borderCollapse =>
    getPropertyValue('border-collapse');

  /** Sets the value of "border-collapse" */
  void set borderCollapse(String value) {
    setProperty('border-collapse', value, '');
  }

  /** Gets the value of "border-color" */
  String get borderColor =>
    getPropertyValue('border-color');

  /** Sets the value of "border-color" */
  void set borderColor(String value) {
    setProperty('border-color', value, '');
  }

  /** Gets the value of "border-end" */
  String get borderEnd =>
    getPropertyValue('${Device.cssPrefix}border-end');

  /** Sets the value of "border-end" */
  void set borderEnd(String value) {
    setProperty('${Device.cssPrefix}border-end', value, '');
  }

  /** Gets the value of "border-end-color" */
  String get borderEndColor =>
    getPropertyValue('${Device.cssPrefix}border-end-color');

  /** Sets the value of "border-end-color" */
  void set borderEndColor(String value) {
    setProperty('${Device.cssPrefix}border-end-color', value, '');
  }

  /** Gets the value of "border-end-style" */
  String get borderEndStyle =>
    getPropertyValue('${Device.cssPrefix}border-end-style');

  /** Sets the value of "border-end-style" */
  void set borderEndStyle(String value) {
    setProperty('${Device.cssPrefix}border-end-style', value, '');
  }

  /** Gets the value of "border-end-width" */
  String get borderEndWidth =>
    getPropertyValue('${Device.cssPrefix}border-end-width');

  /** Sets the value of "border-end-width" */
  void set borderEndWidth(String value) {
    setProperty('${Device.cssPrefix}border-end-width', value, '');
  }

  /** Gets the value of "border-fit" */
  String get borderFit =>
    getPropertyValue('${Device.cssPrefix}border-fit');

  /** Sets the value of "border-fit" */
  void set borderFit(String value) {
    setProperty('${Device.cssPrefix}border-fit', value, '');
  }

  /** Gets the value of "border-horizontal-spacing" */
  String get borderHorizontalSpacing =>
    getPropertyValue('${Device.cssPrefix}border-horizontal-spacing');

  /** Sets the value of "border-horizontal-spacing" */
  void set borderHorizontalSpacing(String value) {
    setProperty('${Device.cssPrefix}border-horizontal-spacing', value, '');
  }

  /** Gets the value of "border-image" */
  String get borderImage =>
    getPropertyValue('border-image');

  /** Sets the value of "border-image" */
  void set borderImage(String value) {
    setProperty('border-image', value, '');
  }

  /** Gets the value of "border-image-outset" */
  String get borderImageOutset =>
    getPropertyValue('border-image-outset');

  /** Sets the value of "border-image-outset" */
  void set borderImageOutset(String value) {
    setProperty('border-image-outset', value, '');
  }

  /** Gets the value of "border-image-repeat" */
  String get borderImageRepeat =>
    getPropertyValue('border-image-repeat');

  /** Sets the value of "border-image-repeat" */
  void set borderImageRepeat(String value) {
    setProperty('border-image-repeat', value, '');
  }

  /** Gets the value of "border-image-slice" */
  String get borderImageSlice =>
    getPropertyValue('border-image-slice');

  /** Sets the value of "border-image-slice" */
  void set borderImageSlice(String value) {
    setProperty('border-image-slice', value, '');
  }

  /** Gets the value of "border-image-source" */
  String get borderImageSource =>
    getPropertyValue('border-image-source');

  /** Sets the value of "border-image-source" */
  void set borderImageSource(String value) {
    setProperty('border-image-source', value, '');
  }

  /** Gets the value of "border-image-width" */
  String get borderImageWidth =>
    getPropertyValue('border-image-width');

  /** Sets the value of "border-image-width" */
  void set borderImageWidth(String value) {
    setProperty('border-image-width', value, '');
  }

  /** Gets the value of "border-left" */
  String get borderLeft =>
    getPropertyValue('border-left');

  /** Sets the value of "border-left" */
  void set borderLeft(String value) {
    setProperty('border-left', value, '');
  }

  /** Gets the value of "border-left-color" */
  String get borderLeftColor =>
    getPropertyValue('border-left-color');

  /** Sets the value of "border-left-color" */
  void set borderLeftColor(String value) {
    setProperty('border-left-color', value, '');
  }

  /** Gets the value of "border-left-style" */
  String get borderLeftStyle =>
    getPropertyValue('border-left-style');

  /** Sets the value of "border-left-style" */
  void set borderLeftStyle(String value) {
    setProperty('border-left-style', value, '');
  }

  /** Gets the value of "border-left-width" */
  String get borderLeftWidth =>
    getPropertyValue('border-left-width');

  /** Sets the value of "border-left-width" */
  void set borderLeftWidth(String value) {
    setProperty('border-left-width', value, '');
  }

  /** Gets the value of "border-radius" */
  String get borderRadius =>
    getPropertyValue('border-radius');

  /** Sets the value of "border-radius" */
  void set borderRadius(String value) {
    setProperty('border-radius', value, '');
  }

  /** Gets the value of "border-right" */
  String get borderRight =>
    getPropertyValue('border-right');

  /** Sets the value of "border-right" */
  void set borderRight(String value) {
    setProperty('border-right', value, '');
  }

  /** Gets the value of "border-right-color" */
  String get borderRightColor =>
    getPropertyValue('border-right-color');

  /** Sets the value of "border-right-color" */
  void set borderRightColor(String value) {
    setProperty('border-right-color', value, '');
  }

  /** Gets the value of "border-right-style" */
  String get borderRightStyle =>
    getPropertyValue('border-right-style');

  /** Sets the value of "border-right-style" */
  void set borderRightStyle(String value) {
    setProperty('border-right-style', value, '');
  }

  /** Gets the value of "border-right-width" */
  String get borderRightWidth =>
    getPropertyValue('border-right-width');

  /** Sets the value of "border-right-width" */
  void set borderRightWidth(String value) {
    setProperty('border-right-width', value, '');
  }

  /** Gets the value of "border-spacing" */
  String get borderSpacing =>
    getPropertyValue('border-spacing');

  /** Sets the value of "border-spacing" */
  void set borderSpacing(String value) {
    setProperty('border-spacing', value, '');
  }

  /** Gets the value of "border-start" */
  String get borderStart =>
    getPropertyValue('${Device.cssPrefix}border-start');

  /** Sets the value of "border-start" */
  void set borderStart(String value) {
    setProperty('${Device.cssPrefix}border-start', value, '');
  }

  /** Gets the value of "border-start-color" */
  String get borderStartColor =>
    getPropertyValue('${Device.cssPrefix}border-start-color');

  /** Sets the value of "border-start-color" */
  void set borderStartColor(String value) {
    setProperty('${Device.cssPrefix}border-start-color', value, '');
  }

  /** Gets the value of "border-start-style" */
  String get borderStartStyle =>
    getPropertyValue('${Device.cssPrefix}border-start-style');

  /** Sets the value of "border-start-style" */
  void set borderStartStyle(String value) {
    setProperty('${Device.cssPrefix}border-start-style', value, '');
  }

  /** Gets the value of "border-start-width" */
  String get borderStartWidth =>
    getPropertyValue('${Device.cssPrefix}border-start-width');

  /** Sets the value of "border-start-width" */
  void set borderStartWidth(String value) {
    setProperty('${Device.cssPrefix}border-start-width', value, '');
  }

  /** Gets the value of "border-style" */
  String get borderStyle =>
    getPropertyValue('border-style');

  /** Sets the value of "border-style" */
  void set borderStyle(String value) {
    setProperty('border-style', value, '');
  }

  /** Gets the value of "border-top" */
  String get borderTop =>
    getPropertyValue('border-top');

  /** Sets the value of "border-top" */
  void set borderTop(String value) {
    setProperty('border-top', value, '');
  }

  /** Gets the value of "border-top-color" */
  String get borderTopColor =>
    getPropertyValue('border-top-color');

  /** Sets the value of "border-top-color" */
  void set borderTopColor(String value) {
    setProperty('border-top-color', value, '');
  }

  /** Gets the value of "border-top-left-radius" */
  String get borderTopLeftRadius =>
    getPropertyValue('border-top-left-radius');

  /** Sets the value of "border-top-left-radius" */
  void set borderTopLeftRadius(String value) {
    setProperty('border-top-left-radius', value, '');
  }

  /** Gets the value of "border-top-right-radius" */
  String get borderTopRightRadius =>
    getPropertyValue('border-top-right-radius');

  /** Sets the value of "border-top-right-radius" */
  void set borderTopRightRadius(String value) {
    setProperty('border-top-right-radius', value, '');
  }

  /** Gets the value of "border-top-style" */
  String get borderTopStyle =>
    getPropertyValue('border-top-style');

  /** Sets the value of "border-top-style" */
  void set borderTopStyle(String value) {
    setProperty('border-top-style', value, '');
  }

  /** Gets the value of "border-top-width" */
  String get borderTopWidth =>
    getPropertyValue('border-top-width');

  /** Sets the value of "border-top-width" */
  void set borderTopWidth(String value) {
    setProperty('border-top-width', value, '');
  }

  /** Gets the value of "border-vertical-spacing" */
  String get borderVerticalSpacing =>
    getPropertyValue('${Device.cssPrefix}border-vertical-spacing');

  /** Sets the value of "border-vertical-spacing" */
  void set borderVerticalSpacing(String value) {
    setProperty('${Device.cssPrefix}border-vertical-spacing', value, '');
  }

  /** Gets the value of "border-width" */
  String get borderWidth =>
    getPropertyValue('border-width');

  /** Sets the value of "border-width" */
  void set borderWidth(String value) {
    setProperty('border-width', value, '');
  }

  /** Gets the value of "bottom" */
  String get bottom =>
    getPropertyValue('bottom');

  /** Sets the value of "bottom" */
  void set bottom(String value) {
    setProperty('bottom', value, '');
  }

  /** Gets the value of "box-align" */
  String get boxAlign =>
    getPropertyValue('${Device.cssPrefix}box-align');

  /** Sets the value of "box-align" */
  void set boxAlign(String value) {
    setProperty('${Device.cssPrefix}box-align', value, '');
  }

  /** Gets the value of "box-decoration-break" */
  String get boxDecorationBreak =>
    getPropertyValue('${Device.cssPrefix}box-decoration-break');

  /** Sets the value of "box-decoration-break" */
  void set boxDecorationBreak(String value) {
    setProperty('${Device.cssPrefix}box-decoration-break', value, '');
  }

  /** Gets the value of "box-direction" */
  String get boxDirection =>
    getPropertyValue('${Device.cssPrefix}box-direction');

  /** Sets the value of "box-direction" */
  void set boxDirection(String value) {
    setProperty('${Device.cssPrefix}box-direction', value, '');
  }

  /** Gets the value of "box-flex" */
  String get boxFlex =>
    getPropertyValue('${Device.cssPrefix}box-flex');

  /** Sets the value of "box-flex" */
  void set boxFlex(String value) {
    setProperty('${Device.cssPrefix}box-flex', value, '');
  }

  /** Gets the value of "box-flex-group" */
  String get boxFlexGroup =>
    getPropertyValue('${Device.cssPrefix}box-flex-group');

  /** Sets the value of "box-flex-group" */
  void set boxFlexGroup(String value) {
    setProperty('${Device.cssPrefix}box-flex-group', value, '');
  }

  /** Gets the value of "box-lines" */
  String get boxLines =>
    getPropertyValue('${Device.cssPrefix}box-lines');

  /** Sets the value of "box-lines" */
  void set boxLines(String value) {
    setProperty('${Device.cssPrefix}box-lines', value, '');
  }

  /** Gets the value of "box-ordinal-group" */
  String get boxOrdinalGroup =>
    getPropertyValue('${Device.cssPrefix}box-ordinal-group');

  /** Sets the value of "box-ordinal-group" */
  void set boxOrdinalGroup(String value) {
    setProperty('${Device.cssPrefix}box-ordinal-group', value, '');
  }

  /** Gets the value of "box-orient" */
  String get boxOrient =>
    getPropertyValue('${Device.cssPrefix}box-orient');

  /** Sets the value of "box-orient" */
  void set boxOrient(String value) {
    setProperty('${Device.cssPrefix}box-orient', value, '');
  }

  /** Gets the value of "box-pack" */
  String get boxPack =>
    getPropertyValue('${Device.cssPrefix}box-pack');

  /** Sets the value of "box-pack" */
  void set boxPack(String value) {
    setProperty('${Device.cssPrefix}box-pack', value, '');
  }

  /** Gets the value of "box-reflect" */
  String get boxReflect =>
    getPropertyValue('${Device.cssPrefix}box-reflect');

  /** Sets the value of "box-reflect" */
  void set boxReflect(String value) {
    setProperty('${Device.cssPrefix}box-reflect', value, '');
  }

  /** Gets the value of "box-shadow" */
  String get boxShadow =>
    getPropertyValue('box-shadow');

  /** Sets the value of "box-shadow" */
  void set boxShadow(String value) {
    setProperty('box-shadow', value, '');
  }

  /** Gets the value of "box-sizing" */
  String get boxSizing =>
    getPropertyValue('box-sizing');

  /** Sets the value of "box-sizing" */
  void set boxSizing(String value) {
    setProperty('box-sizing', value, '');
  }

  /** Gets the value of "caption-side" */
  String get captionSide =>
    getPropertyValue('caption-side');

  /** Sets the value of "caption-side" */
  void set captionSide(String value) {
    setProperty('caption-side', value, '');
  }

  /** Gets the value of "clear" */
  String get clear =>
    getPropertyValue('clear');

  /** Sets the value of "clear" */
  void set clear(String value) {
    setProperty('clear', value, '');
  }

  /** Gets the value of "clip" */
  String get clip =>
    getPropertyValue('clip');

  /** Sets the value of "clip" */
  void set clip(String value) {
    setProperty('clip', value, '');
  }

  /** Gets the value of "clip-path" */
  String get clipPath =>
    getPropertyValue('${Device.cssPrefix}clip-path');

  /** Sets the value of "clip-path" */
  void set clipPath(String value) {
    setProperty('${Device.cssPrefix}clip-path', value, '');
  }

  /** Gets the value of "color" */
  String get color =>
    getPropertyValue('color');

  /** Sets the value of "color" */
  void set color(String value) {
    setProperty('color', value, '');
  }

  /** Gets the value of "color-correction" */
  String get colorCorrection =>
    getPropertyValue('${Device.cssPrefix}color-correction');

  /** Sets the value of "color-correction" */
  void set colorCorrection(String value) {
    setProperty('${Device.cssPrefix}color-correction', value, '');
  }

  /** Gets the value of "column-axis" */
  String get columnAxis =>
    getPropertyValue('${Device.cssPrefix}column-axis');

  /** Sets the value of "column-axis" */
  void set columnAxis(String value) {
    setProperty('${Device.cssPrefix}column-axis', value, '');
  }

  /** Gets the value of "column-break-after" */
  String get columnBreakAfter =>
    getPropertyValue('${Device.cssPrefix}column-break-after');

  /** Sets the value of "column-break-after" */
  void set columnBreakAfter(String value) {
    setProperty('${Device.cssPrefix}column-break-after', value, '');
  }

  /** Gets the value of "column-break-before" */
  String get columnBreakBefore =>
    getPropertyValue('${Device.cssPrefix}column-break-before');

  /** Sets the value of "column-break-before" */
  void set columnBreakBefore(String value) {
    setProperty('${Device.cssPrefix}column-break-before', value, '');
  }

  /** Gets the value of "column-break-inside" */
  String get columnBreakInside =>
    getPropertyValue('${Device.cssPrefix}column-break-inside');

  /** Sets the value of "column-break-inside" */
  void set columnBreakInside(String value) {
    setProperty('${Device.cssPrefix}column-break-inside', value, '');
  }

  /** Gets the value of "column-count" */
  String get columnCount =>
    getPropertyValue('${Device.cssPrefix}column-count');

  /** Sets the value of "column-count" */
  void set columnCount(String value) {
    setProperty('${Device.cssPrefix}column-count', value, '');
  }

  /** Gets the value of "column-gap" */
  String get columnGap =>
    getPropertyValue('${Device.cssPrefix}column-gap');

  /** Sets the value of "column-gap" */
  void set columnGap(String value) {
    setProperty('${Device.cssPrefix}column-gap', value, '');
  }

  /** Gets the value of "column-progression" */
  String get columnProgression =>
    getPropertyValue('${Device.cssPrefix}column-progression');

  /** Sets the value of "column-progression" */
  void set columnProgression(String value) {
    setProperty('${Device.cssPrefix}column-progression', value, '');
  }

  /** Gets the value of "column-rule" */
  String get columnRule =>
    getPropertyValue('${Device.cssPrefix}column-rule');

  /** Sets the value of "column-rule" */
  void set columnRule(String value) {
    setProperty('${Device.cssPrefix}column-rule', value, '');
  }

  /** Gets the value of "column-rule-color" */
  String get columnRuleColor =>
    getPropertyValue('${Device.cssPrefix}column-rule-color');

  /** Sets the value of "column-rule-color" */
  void set columnRuleColor(String value) {
    setProperty('${Device.cssPrefix}column-rule-color', value, '');
  }

  /** Gets the value of "column-rule-style" */
  String get columnRuleStyle =>
    getPropertyValue('${Device.cssPrefix}column-rule-style');

  /** Sets the value of "column-rule-style" */
  void set columnRuleStyle(String value) {
    setProperty('${Device.cssPrefix}column-rule-style', value, '');
  }

  /** Gets the value of "column-rule-width" */
  String get columnRuleWidth =>
    getPropertyValue('${Device.cssPrefix}column-rule-width');

  /** Sets the value of "column-rule-width" */
  void set columnRuleWidth(String value) {
    setProperty('${Device.cssPrefix}column-rule-width', value, '');
  }

  /** Gets the value of "column-span" */
  String get columnSpan =>
    getPropertyValue('${Device.cssPrefix}column-span');

  /** Sets the value of "column-span" */
  void set columnSpan(String value) {
    setProperty('${Device.cssPrefix}column-span', value, '');
  }

  /** Gets the value of "column-width" */
  String get columnWidth =>
    getPropertyValue('${Device.cssPrefix}column-width');

  /** Sets the value of "column-width" */
  void set columnWidth(String value) {
    setProperty('${Device.cssPrefix}column-width', value, '');
  }

  /** Gets the value of "columns" */
  String get columns =>
    getPropertyValue('${Device.cssPrefix}columns');

  /** Sets the value of "columns" */
  void set columns(String value) {
    setProperty('${Device.cssPrefix}columns', value, '');
  }

  /** Gets the value of "content" */
  String get content =>
    getPropertyValue('content');

  /** Sets the value of "content" */
  void set content(String value) {
    setProperty('content', value, '');
  }

  /** Gets the value of "counter-increment" */
  String get counterIncrement =>
    getPropertyValue('counter-increment');

  /** Sets the value of "counter-increment" */
  void set counterIncrement(String value) {
    setProperty('counter-increment', value, '');
  }

  /** Gets the value of "counter-reset" */
  String get counterReset =>
    getPropertyValue('counter-reset');

  /** Sets the value of "counter-reset" */
  void set counterReset(String value) {
    setProperty('counter-reset', value, '');
  }

  /** Gets the value of "cursor" */
  String get cursor =>
    getPropertyValue('cursor');

  /** Sets the value of "cursor" */
  void set cursor(String value) {
    setProperty('cursor', value, '');
  }

  /** Gets the value of "dashboard-region" */
  String get dashboardRegion =>
    getPropertyValue('${Device.cssPrefix}dashboard-region');

  /** Sets the value of "dashboard-region" */
  void set dashboardRegion(String value) {
    setProperty('${Device.cssPrefix}dashboard-region', value, '');
  }

  /** Gets the value of "direction" */
  String get direction =>
    getPropertyValue('direction');

  /** Sets the value of "direction" */
  void set direction(String value) {
    setProperty('direction', value, '');
  }

  /** Gets the value of "display" */
  String get display =>
    getPropertyValue('display');

  /** Sets the value of "display" */
  void set display(String value) {
    setProperty('display', value, '');
  }

  /** Gets the value of "empty-cells" */
  String get emptyCells =>
    getPropertyValue('empty-cells');

  /** Sets the value of "empty-cells" */
  void set emptyCells(String value) {
    setProperty('empty-cells', value, '');
  }

  /** Gets the value of "filter" */
  String get filter =>
    getPropertyValue('${Device.cssPrefix}filter');

  /** Sets the value of "filter" */
  void set filter(String value) {
    setProperty('${Device.cssPrefix}filter', value, '');
  }

  /** Gets the value of "flex" */
  String get flex =>
    getPropertyValue('${Device.cssPrefix}flex');

  /** Sets the value of "flex" */
  void set flex(String value) {
    setProperty('${Device.cssPrefix}flex', value, '');
  }

  /** Gets the value of "flex-basis" */
  String get flexBasis =>
    getPropertyValue('${Device.cssPrefix}flex-basis');

  /** Sets the value of "flex-basis" */
  void set flexBasis(String value) {
    setProperty('${Device.cssPrefix}flex-basis', value, '');
  }

  /** Gets the value of "flex-direction" */
  String get flexDirection =>
    getPropertyValue('${Device.cssPrefix}flex-direction');

  /** Sets the value of "flex-direction" */
  void set flexDirection(String value) {
    setProperty('${Device.cssPrefix}flex-direction', value, '');
  }

  /** Gets the value of "flex-flow" */
  String get flexFlow =>
    getPropertyValue('${Device.cssPrefix}flex-flow');

  /** Sets the value of "flex-flow" */
  void set flexFlow(String value) {
    setProperty('${Device.cssPrefix}flex-flow', value, '');
  }

  /** Gets the value of "flex-grow" */
  String get flexGrow =>
    getPropertyValue('${Device.cssPrefix}flex-grow');

  /** Sets the value of "flex-grow" */
  void set flexGrow(String value) {
    setProperty('${Device.cssPrefix}flex-grow', value, '');
  }

  /** Gets the value of "flex-shrink" */
  String get flexShrink =>
    getPropertyValue('${Device.cssPrefix}flex-shrink');

  /** Sets the value of "flex-shrink" */
  void set flexShrink(String value) {
    setProperty('${Device.cssPrefix}flex-shrink', value, '');
  }

  /** Gets the value of "flex-wrap" */
  String get flexWrap =>
    getPropertyValue('${Device.cssPrefix}flex-wrap');

  /** Sets the value of "flex-wrap" */
  void set flexWrap(String value) {
    setProperty('${Device.cssPrefix}flex-wrap', value, '');
  }

  /** Gets the value of "float" */
  String get float =>
    getPropertyValue('float');

  /** Sets the value of "float" */
  void set float(String value) {
    setProperty('float', value, '');
  }

  /** Gets the value of "flow-from" */
  String get flowFrom =>
    getPropertyValue('${Device.cssPrefix}flow-from');

  /** Sets the value of "flow-from" */
  void set flowFrom(String value) {
    setProperty('${Device.cssPrefix}flow-from', value, '');
  }

  /** Gets the value of "flow-into" */
  String get flowInto =>
    getPropertyValue('${Device.cssPrefix}flow-into');

  /** Sets the value of "flow-into" */
  void set flowInto(String value) {
    setProperty('${Device.cssPrefix}flow-into', value, '');
  }

  /** Gets the value of "font" */
  String get font =>
    getPropertyValue('font');

  /** Sets the value of "font" */
  void set font(String value) {
    setProperty('font', value, '');
  }

  /** Gets the value of "font-family" */
  String get fontFamily =>
    getPropertyValue('font-family');

  /** Sets the value of "font-family" */
  void set fontFamily(String value) {
    setProperty('font-family', value, '');
  }

  /** Gets the value of "font-feature-settings" */
  String get fontFeatureSettings =>
    getPropertyValue('${Device.cssPrefix}font-feature-settings');

  /** Sets the value of "font-feature-settings" */
  void set fontFeatureSettings(String value) {
    setProperty('${Device.cssPrefix}font-feature-settings', value, '');
  }

  /** Gets the value of "font-kerning" */
  String get fontKerning =>
    getPropertyValue('${Device.cssPrefix}font-kerning');

  /** Sets the value of "font-kerning" */
  void set fontKerning(String value) {
    setProperty('${Device.cssPrefix}font-kerning', value, '');
  }

  /** Gets the value of "font-size" */
  String get fontSize =>
    getPropertyValue('font-size');

  /** Sets the value of "font-size" */
  void set fontSize(String value) {
    setProperty('font-size', value, '');
  }

  /** Gets the value of "font-size-delta" */
  String get fontSizeDelta =>
    getPropertyValue('${Device.cssPrefix}font-size-delta');

  /** Sets the value of "font-size-delta" */
  void set fontSizeDelta(String value) {
    setProperty('${Device.cssPrefix}font-size-delta', value, '');
  }

  /** Gets the value of "font-smoothing" */
  String get fontSmoothing =>
    getPropertyValue('${Device.cssPrefix}font-smoothing');

  /** Sets the value of "font-smoothing" */
  void set fontSmoothing(String value) {
    setProperty('${Device.cssPrefix}font-smoothing', value, '');
  }

  /** Gets the value of "font-stretch" */
  String get fontStretch =>
    getPropertyValue('font-stretch');

  /** Sets the value of "font-stretch" */
  void set fontStretch(String value) {
    setProperty('font-stretch', value, '');
  }

  /** Gets the value of "font-style" */
  String get fontStyle =>
    getPropertyValue('font-style');

  /** Sets the value of "font-style" */
  void set fontStyle(String value) {
    setProperty('font-style', value, '');
  }

  /** Gets the value of "font-variant" */
  String get fontVariant =>
    getPropertyValue('font-variant');

  /** Sets the value of "font-variant" */
  void set fontVariant(String value) {
    setProperty('font-variant', value, '');
  }

  /** Gets the value of "font-variant-ligatures" */
  String get fontVariantLigatures =>
    getPropertyValue('${Device.cssPrefix}font-variant-ligatures');

  /** Sets the value of "font-variant-ligatures" */
  void set fontVariantLigatures(String value) {
    setProperty('${Device.cssPrefix}font-variant-ligatures', value, '');
  }

  /** Gets the value of "font-weight" */
  String get fontWeight =>
    getPropertyValue('font-weight');

  /** Sets the value of "font-weight" */
  void set fontWeight(String value) {
    setProperty('font-weight', value, '');
  }

  /** Gets the value of "grid-column" */
  String get gridColumn =>
    getPropertyValue('${Device.cssPrefix}grid-column');

  /** Sets the value of "grid-column" */
  void set gridColumn(String value) {
    setProperty('${Device.cssPrefix}grid-column', value, '');
  }

  /** Gets the value of "grid-columns" */
  String get gridColumns =>
    getPropertyValue('${Device.cssPrefix}grid-columns');

  /** Sets the value of "grid-columns" */
  void set gridColumns(String value) {
    setProperty('${Device.cssPrefix}grid-columns', value, '');
  }

  /** Gets the value of "grid-row" */
  String get gridRow =>
    getPropertyValue('${Device.cssPrefix}grid-row');

  /** Sets the value of "grid-row" */
  void set gridRow(String value) {
    setProperty('${Device.cssPrefix}grid-row', value, '');
  }

  /** Gets the value of "grid-rows" */
  String get gridRows =>
    getPropertyValue('${Device.cssPrefix}grid-rows');

  /** Sets the value of "grid-rows" */
  void set gridRows(String value) {
    setProperty('${Device.cssPrefix}grid-rows', value, '');
  }

  /** Gets the value of "height" */
  String get height =>
    getPropertyValue('height');

  /** Sets the value of "height" */
  void set height(String value) {
    setProperty('height', value, '');
  }

  /** Gets the value of "highlight" */
  String get highlight =>
    getPropertyValue('${Device.cssPrefix}highlight');

  /** Sets the value of "highlight" */
  void set highlight(String value) {
    setProperty('${Device.cssPrefix}highlight', value, '');
  }

  /** Gets the value of "hyphenate-character" */
  String get hyphenateCharacter =>
    getPropertyValue('${Device.cssPrefix}hyphenate-character');

  /** Sets the value of "hyphenate-character" */
  void set hyphenateCharacter(String value) {
    setProperty('${Device.cssPrefix}hyphenate-character', value, '');
  }

  /** Gets the value of "hyphenate-limit-after" */
  String get hyphenateLimitAfter =>
    getPropertyValue('${Device.cssPrefix}hyphenate-limit-after');

  /** Sets the value of "hyphenate-limit-after" */
  void set hyphenateLimitAfter(String value) {
    setProperty('${Device.cssPrefix}hyphenate-limit-after', value, '');
  }

  /** Gets the value of "hyphenate-limit-before" */
  String get hyphenateLimitBefore =>
    getPropertyValue('${Device.cssPrefix}hyphenate-limit-before');

  /** Sets the value of "hyphenate-limit-before" */
  void set hyphenateLimitBefore(String value) {
    setProperty('${Device.cssPrefix}hyphenate-limit-before', value, '');
  }

  /** Gets the value of "hyphenate-limit-lines" */
  String get hyphenateLimitLines =>
    getPropertyValue('${Device.cssPrefix}hyphenate-limit-lines');

  /** Sets the value of "hyphenate-limit-lines" */
  void set hyphenateLimitLines(String value) {
    setProperty('${Device.cssPrefix}hyphenate-limit-lines', value, '');
  }

  /** Gets the value of "hyphens" */
  String get hyphens =>
    getPropertyValue('${Device.cssPrefix}hyphens');

  /** Sets the value of "hyphens" */
  void set hyphens(String value) {
    setProperty('${Device.cssPrefix}hyphens', value, '');
  }

  /** Gets the value of "image-orientation" */
  String get imageOrientation =>
    getPropertyValue('image-orientation');

  /** Sets the value of "image-orientation" */
  void set imageOrientation(String value) {
    setProperty('image-orientation', value, '');
  }

  /** Gets the value of "image-rendering" */
  String get imageRendering =>
    getPropertyValue('image-rendering');

  /** Sets the value of "image-rendering" */
  void set imageRendering(String value) {
    setProperty('image-rendering', value, '');
  }

  /** Gets the value of "image-resolution" */
  String get imageResolution =>
    getPropertyValue('image-resolution');

  /** Sets the value of "image-resolution" */
  void set imageResolution(String value) {
    setProperty('image-resolution', value, '');
  }

  /** Gets the value of "justify-content" */
  String get justifyContent =>
    getPropertyValue('${Device.cssPrefix}justify-content');

  /** Sets the value of "justify-content" */
  void set justifyContent(String value) {
    setProperty('${Device.cssPrefix}justify-content', value, '');
  }

  /** Gets the value of "left" */
  String get left =>
    getPropertyValue('left');

  /** Sets the value of "left" */
  void set left(String value) {
    setProperty('left', value, '');
  }

  /** Gets the value of "letter-spacing" */
  String get letterSpacing =>
    getPropertyValue('letter-spacing');

  /** Sets the value of "letter-spacing" */
  void set letterSpacing(String value) {
    setProperty('letter-spacing', value, '');
  }

  /** Gets the value of "line-align" */
  String get lineAlign =>
    getPropertyValue('${Device.cssPrefix}line-align');

  /** Sets the value of "line-align" */
  void set lineAlign(String value) {
    setProperty('${Device.cssPrefix}line-align', value, '');
  }

  /** Gets the value of "line-box-contain" */
  String get lineBoxContain =>
    getPropertyValue('${Device.cssPrefix}line-box-contain');

  /** Sets the value of "line-box-contain" */
  void set lineBoxContain(String value) {
    setProperty('${Device.cssPrefix}line-box-contain', value, '');
  }

  /** Gets the value of "line-break" */
  String get lineBreak =>
    getPropertyValue('${Device.cssPrefix}line-break');

  /** Sets the value of "line-break" */
  void set lineBreak(String value) {
    setProperty('${Device.cssPrefix}line-break', value, '');
  }

  /** Gets the value of "line-clamp" */
  String get lineClamp =>
    getPropertyValue('${Device.cssPrefix}line-clamp');

  /** Sets the value of "line-clamp" */
  void set lineClamp(String value) {
    setProperty('${Device.cssPrefix}line-clamp', value, '');
  }

  /** Gets the value of "line-grid" */
  String get lineGrid =>
    getPropertyValue('${Device.cssPrefix}line-grid');

  /** Sets the value of "line-grid" */
  void set lineGrid(String value) {
    setProperty('${Device.cssPrefix}line-grid', value, '');
  }

  /** Gets the value of "line-height" */
  String get lineHeight =>
    getPropertyValue('line-height');

  /** Sets the value of "line-height" */
  void set lineHeight(String value) {
    setProperty('line-height', value, '');
  }

  /** Gets the value of "line-snap" */
  String get lineSnap =>
    getPropertyValue('${Device.cssPrefix}line-snap');

  /** Sets the value of "line-snap" */
  void set lineSnap(String value) {
    setProperty('${Device.cssPrefix}line-snap', value, '');
  }

  /** Gets the value of "list-style" */
  String get listStyle =>
    getPropertyValue('list-style');

  /** Sets the value of "list-style" */
  void set listStyle(String value) {
    setProperty('list-style', value, '');
  }

  /** Gets the value of "list-style-image" */
  String get listStyleImage =>
    getPropertyValue('list-style-image');

  /** Sets the value of "list-style-image" */
  void set listStyleImage(String value) {
    setProperty('list-style-image', value, '');
  }

  /** Gets the value of "list-style-position" */
  String get listStylePosition =>
    getPropertyValue('list-style-position');

  /** Sets the value of "list-style-position" */
  void set listStylePosition(String value) {
    setProperty('list-style-position', value, '');
  }

  /** Gets the value of "list-style-type" */
  String get listStyleType =>
    getPropertyValue('list-style-type');

  /** Sets the value of "list-style-type" */
  void set listStyleType(String value) {
    setProperty('list-style-type', value, '');
  }

  /** Gets the value of "locale" */
  String get locale =>
    getPropertyValue('${Device.cssPrefix}locale');

  /** Sets the value of "locale" */
  void set locale(String value) {
    setProperty('${Device.cssPrefix}locale', value, '');
  }

  /** Gets the value of "logical-height" */
  String get logicalHeight =>
    getPropertyValue('${Device.cssPrefix}logical-height');

  /** Sets the value of "logical-height" */
  void set logicalHeight(String value) {
    setProperty('${Device.cssPrefix}logical-height', value, '');
  }

  /** Gets the value of "logical-width" */
  String get logicalWidth =>
    getPropertyValue('${Device.cssPrefix}logical-width');

  /** Sets the value of "logical-width" */
  void set logicalWidth(String value) {
    setProperty('${Device.cssPrefix}logical-width', value, '');
  }

  /** Gets the value of "margin" */
  String get margin =>
    getPropertyValue('margin');

  /** Sets the value of "margin" */
  void set margin(String value) {
    setProperty('margin', value, '');
  }

  /** Gets the value of "margin-after" */
  String get marginAfter =>
    getPropertyValue('${Device.cssPrefix}margin-after');

  /** Sets the value of "margin-after" */
  void set marginAfter(String value) {
    setProperty('${Device.cssPrefix}margin-after', value, '');
  }

  /** Gets the value of "margin-after-collapse" */
  String get marginAfterCollapse =>
    getPropertyValue('${Device.cssPrefix}margin-after-collapse');

  /** Sets the value of "margin-after-collapse" */
  void set marginAfterCollapse(String value) {
    setProperty('${Device.cssPrefix}margin-after-collapse', value, '');
  }

  /** Gets the value of "margin-before" */
  String get marginBefore =>
    getPropertyValue('${Device.cssPrefix}margin-before');

  /** Sets the value of "margin-before" */
  void set marginBefore(String value) {
    setProperty('${Device.cssPrefix}margin-before', value, '');
  }

  /** Gets the value of "margin-before-collapse" */
  String get marginBeforeCollapse =>
    getPropertyValue('${Device.cssPrefix}margin-before-collapse');

  /** Sets the value of "margin-before-collapse" */
  void set marginBeforeCollapse(String value) {
    setProperty('${Device.cssPrefix}margin-before-collapse', value, '');
  }

  /** Gets the value of "margin-bottom" */
  String get marginBottom =>
    getPropertyValue('margin-bottom');

  /** Sets the value of "margin-bottom" */
  void set marginBottom(String value) {
    setProperty('margin-bottom', value, '');
  }

  /** Gets the value of "margin-bottom-collapse" */
  String get marginBottomCollapse =>
    getPropertyValue('${Device.cssPrefix}margin-bottom-collapse');

  /** Sets the value of "margin-bottom-collapse" */
  void set marginBottomCollapse(String value) {
    setProperty('${Device.cssPrefix}margin-bottom-collapse', value, '');
  }

  /** Gets the value of "margin-collapse" */
  String get marginCollapse =>
    getPropertyValue('${Device.cssPrefix}margin-collapse');

  /** Sets the value of "margin-collapse" */
  void set marginCollapse(String value) {
    setProperty('${Device.cssPrefix}margin-collapse', value, '');
  }

  /** Gets the value of "margin-end" */
  String get marginEnd =>
    getPropertyValue('${Device.cssPrefix}margin-end');

  /** Sets the value of "margin-end" */
  void set marginEnd(String value) {
    setProperty('${Device.cssPrefix}margin-end', value, '');
  }

  /** Gets the value of "margin-left" */
  String get marginLeft =>
    getPropertyValue('margin-left');

  /** Sets the value of "margin-left" */
  void set marginLeft(String value) {
    setProperty('margin-left', value, '');
  }

  /** Gets the value of "margin-right" */
  String get marginRight =>
    getPropertyValue('margin-right');

  /** Sets the value of "margin-right" */
  void set marginRight(String value) {
    setProperty('margin-right', value, '');
  }

  /** Gets the value of "margin-start" */
  String get marginStart =>
    getPropertyValue('${Device.cssPrefix}margin-start');

  /** Sets the value of "margin-start" */
  void set marginStart(String value) {
    setProperty('${Device.cssPrefix}margin-start', value, '');
  }

  /** Gets the value of "margin-top" */
  String get marginTop =>
    getPropertyValue('margin-top');

  /** Sets the value of "margin-top" */
  void set marginTop(String value) {
    setProperty('margin-top', value, '');
  }

  /** Gets the value of "margin-top-collapse" */
  String get marginTopCollapse =>
    getPropertyValue('${Device.cssPrefix}margin-top-collapse');

  /** Sets the value of "margin-top-collapse" */
  void set marginTopCollapse(String value) {
    setProperty('${Device.cssPrefix}margin-top-collapse', value, '');
  }

  /** Gets the value of "marquee" */
  String get marquee =>
    getPropertyValue('${Device.cssPrefix}marquee');

  /** Sets the value of "marquee" */
  void set marquee(String value) {
    setProperty('${Device.cssPrefix}marquee', value, '');
  }

  /** Gets the value of "marquee-direction" */
  String get marqueeDirection =>
    getPropertyValue('${Device.cssPrefix}marquee-direction');

  /** Sets the value of "marquee-direction" */
  void set marqueeDirection(String value) {
    setProperty('${Device.cssPrefix}marquee-direction', value, '');
  }

  /** Gets the value of "marquee-increment" */
  String get marqueeIncrement =>
    getPropertyValue('${Device.cssPrefix}marquee-increment');

  /** Sets the value of "marquee-increment" */
  void set marqueeIncrement(String value) {
    setProperty('${Device.cssPrefix}marquee-increment', value, '');
  }

  /** Gets the value of "marquee-repetition" */
  String get marqueeRepetition =>
    getPropertyValue('${Device.cssPrefix}marquee-repetition');

  /** Sets the value of "marquee-repetition" */
  void set marqueeRepetition(String value) {
    setProperty('${Device.cssPrefix}marquee-repetition', value, '');
  }

  /** Gets the value of "marquee-speed" */
  String get marqueeSpeed =>
    getPropertyValue('${Device.cssPrefix}marquee-speed');

  /** Sets the value of "marquee-speed" */
  void set marqueeSpeed(String value) {
    setProperty('${Device.cssPrefix}marquee-speed', value, '');
  }

  /** Gets the value of "marquee-style" */
  String get marqueeStyle =>
    getPropertyValue('${Device.cssPrefix}marquee-style');

  /** Sets the value of "marquee-style" */
  void set marqueeStyle(String value) {
    setProperty('${Device.cssPrefix}marquee-style', value, '');
  }

  /** Gets the value of "mask" */
  String get mask =>
    getPropertyValue('${Device.cssPrefix}mask');

  /** Sets the value of "mask" */
  void set mask(String value) {
    setProperty('${Device.cssPrefix}mask', value, '');
  }

  /** Gets the value of "mask-attachment" */
  String get maskAttachment =>
    getPropertyValue('${Device.cssPrefix}mask-attachment');

  /** Sets the value of "mask-attachment" */
  void set maskAttachment(String value) {
    setProperty('${Device.cssPrefix}mask-attachment', value, '');
  }

  /** Gets the value of "mask-box-image" */
  String get maskBoxImage =>
    getPropertyValue('${Device.cssPrefix}mask-box-image');

  /** Sets the value of "mask-box-image" */
  void set maskBoxImage(String value) {
    setProperty('${Device.cssPrefix}mask-box-image', value, '');
  }

  /** Gets the value of "mask-box-image-outset" */
  String get maskBoxImageOutset =>
    getPropertyValue('${Device.cssPrefix}mask-box-image-outset');

  /** Sets the value of "mask-box-image-outset" */
  void set maskBoxImageOutset(String value) {
    setProperty('${Device.cssPrefix}mask-box-image-outset', value, '');
  }

  /** Gets the value of "mask-box-image-repeat" */
  String get maskBoxImageRepeat =>
    getPropertyValue('${Device.cssPrefix}mask-box-image-repeat');

  /** Sets the value of "mask-box-image-repeat" */
  void set maskBoxImageRepeat(String value) {
    setProperty('${Device.cssPrefix}mask-box-image-repeat', value, '');
  }

  /** Gets the value of "mask-box-image-slice" */
  String get maskBoxImageSlice =>
    getPropertyValue('${Device.cssPrefix}mask-box-image-slice');

  /** Sets the value of "mask-box-image-slice" */
  void set maskBoxImageSlice(String value) {
    setProperty('${Device.cssPrefix}mask-box-image-slice', value, '');
  }

  /** Gets the value of "mask-box-image-source" */
  String get maskBoxImageSource =>
    getPropertyValue('${Device.cssPrefix}mask-box-image-source');

  /** Sets the value of "mask-box-image-source" */
  void set maskBoxImageSource(String value) {
    setProperty('${Device.cssPrefix}mask-box-image-source', value, '');
  }

  /** Gets the value of "mask-box-image-width" */
  String get maskBoxImageWidth =>
    getPropertyValue('${Device.cssPrefix}mask-box-image-width');

  /** Sets the value of "mask-box-image-width" */
  void set maskBoxImageWidth(String value) {
    setProperty('${Device.cssPrefix}mask-box-image-width', value, '');
  }

  /** Gets the value of "mask-clip" */
  String get maskClip =>
    getPropertyValue('${Device.cssPrefix}mask-clip');

  /** Sets the value of "mask-clip" */
  void set maskClip(String value) {
    setProperty('${Device.cssPrefix}mask-clip', value, '');
  }

  /** Gets the value of "mask-composite" */
  String get maskComposite =>
    getPropertyValue('${Device.cssPrefix}mask-composite');

  /** Sets the value of "mask-composite" */
  void set maskComposite(String value) {
    setProperty('${Device.cssPrefix}mask-composite', value, '');
  }

  /** Gets the value of "mask-image" */
  String get maskImage =>
    getPropertyValue('${Device.cssPrefix}mask-image');

  /** Sets the value of "mask-image" */
  void set maskImage(String value) {
    setProperty('${Device.cssPrefix}mask-image', value, '');
  }

  /** Gets the value of "mask-origin" */
  String get maskOrigin =>
    getPropertyValue('${Device.cssPrefix}mask-origin');

  /** Sets the value of "mask-origin" */
  void set maskOrigin(String value) {
    setProperty('${Device.cssPrefix}mask-origin', value, '');
  }

  /** Gets the value of "mask-position" */
  String get maskPosition =>
    getPropertyValue('${Device.cssPrefix}mask-position');

  /** Sets the value of "mask-position" */
  void set maskPosition(String value) {
    setProperty('${Device.cssPrefix}mask-position', value, '');
  }

  /** Gets the value of "mask-position-x" */
  String get maskPositionX =>
    getPropertyValue('${Device.cssPrefix}mask-position-x');

  /** Sets the value of "mask-position-x" */
  void set maskPositionX(String value) {
    setProperty('${Device.cssPrefix}mask-position-x', value, '');
  }

  /** Gets the value of "mask-position-y" */
  String get maskPositionY =>
    getPropertyValue('${Device.cssPrefix}mask-position-y');

  /** Sets the value of "mask-position-y" */
  void set maskPositionY(String value) {
    setProperty('${Device.cssPrefix}mask-position-y', value, '');
  }

  /** Gets the value of "mask-repeat" */
  String get maskRepeat =>
    getPropertyValue('${Device.cssPrefix}mask-repeat');

  /** Sets the value of "mask-repeat" */
  void set maskRepeat(String value) {
    setProperty('${Device.cssPrefix}mask-repeat', value, '');
  }

  /** Gets the value of "mask-repeat-x" */
  String get maskRepeatX =>
    getPropertyValue('${Device.cssPrefix}mask-repeat-x');

  /** Sets the value of "mask-repeat-x" */
  void set maskRepeatX(String value) {
    setProperty('${Device.cssPrefix}mask-repeat-x', value, '');
  }

  /** Gets the value of "mask-repeat-y" */
  String get maskRepeatY =>
    getPropertyValue('${Device.cssPrefix}mask-repeat-y');

  /** Sets the value of "mask-repeat-y" */
  void set maskRepeatY(String value) {
    setProperty('${Device.cssPrefix}mask-repeat-y', value, '');
  }

  /** Gets the value of "mask-size" */
  String get maskSize =>
    getPropertyValue('${Device.cssPrefix}mask-size');

  /** Sets the value of "mask-size" */
  void set maskSize(String value) {
    setProperty('${Device.cssPrefix}mask-size', value, '');
  }

  /** Gets the value of "max-height" */
  String get maxHeight =>
    getPropertyValue('max-height');

  /** Sets the value of "max-height" */
  void set maxHeight(String value) {
    setProperty('max-height', value, '');
  }

  /** Gets the value of "max-logical-height" */
  String get maxLogicalHeight =>
    getPropertyValue('${Device.cssPrefix}max-logical-height');

  /** Sets the value of "max-logical-height" */
  void set maxLogicalHeight(String value) {
    setProperty('${Device.cssPrefix}max-logical-height', value, '');
  }

  /** Gets the value of "max-logical-width" */
  String get maxLogicalWidth =>
    getPropertyValue('${Device.cssPrefix}max-logical-width');

  /** Sets the value of "max-logical-width" */
  void set maxLogicalWidth(String value) {
    setProperty('${Device.cssPrefix}max-logical-width', value, '');
  }

  /** Gets the value of "max-width" */
  String get maxWidth =>
    getPropertyValue('max-width');

  /** Sets the value of "max-width" */
  void set maxWidth(String value) {
    setProperty('max-width', value, '');
  }

  /** Gets the value of "max-zoom" */
  String get maxZoom =>
    getPropertyValue('max-zoom');

  /** Sets the value of "max-zoom" */
  void set maxZoom(String value) {
    setProperty('max-zoom', value, '');
  }

  /** Gets the value of "min-height" */
  String get minHeight =>
    getPropertyValue('min-height');

  /** Sets the value of "min-height" */
  void set minHeight(String value) {
    setProperty('min-height', value, '');
  }

  /** Gets the value of "min-logical-height" */
  String get minLogicalHeight =>
    getPropertyValue('${Device.cssPrefix}min-logical-height');

  /** Sets the value of "min-logical-height" */
  void set minLogicalHeight(String value) {
    setProperty('${Device.cssPrefix}min-logical-height', value, '');
  }

  /** Gets the value of "min-logical-width" */
  String get minLogicalWidth =>
    getPropertyValue('${Device.cssPrefix}min-logical-width');

  /** Sets the value of "min-logical-width" */
  void set minLogicalWidth(String value) {
    setProperty('${Device.cssPrefix}min-logical-width', value, '');
  }

  /** Gets the value of "min-width" */
  String get minWidth =>
    getPropertyValue('min-width');

  /** Sets the value of "min-width" */
  void set minWidth(String value) {
    setProperty('min-width', value, '');
  }

  /** Gets the value of "min-zoom" */
  String get minZoom =>
    getPropertyValue('min-zoom');

  /** Sets the value of "min-zoom" */
  void set minZoom(String value) {
    setProperty('min-zoom', value, '');
  }

  /** Gets the value of "nbsp-mode" */
  String get nbspMode =>
    getPropertyValue('${Device.cssPrefix}nbsp-mode');

  /** Sets the value of "nbsp-mode" */
  void set nbspMode(String value) {
    setProperty('${Device.cssPrefix}nbsp-mode', value, '');
  }

  /** Gets the value of "opacity" */
  String get opacity =>
    getPropertyValue('opacity');

  /** Sets the value of "opacity" */
  void set opacity(String value) {
    setProperty('opacity', value, '');
  }

  /** Gets the value of "order" */
  String get order =>
    getPropertyValue('${Device.cssPrefix}order');

  /** Sets the value of "order" */
  void set order(String value) {
    setProperty('${Device.cssPrefix}order', value, '');
  }

  /** Gets the value of "orientation" */
  String get orientation =>
    getPropertyValue('orientation');

  /** Sets the value of "orientation" */
  void set orientation(String value) {
    setProperty('orientation', value, '');
  }

  /** Gets the value of "orphans" */
  String get orphans =>
    getPropertyValue('orphans');

  /** Sets the value of "orphans" */
  void set orphans(String value) {
    setProperty('orphans', value, '');
  }

  /** Gets the value of "outline" */
  String get outline =>
    getPropertyValue('outline');

  /** Sets the value of "outline" */
  void set outline(String value) {
    setProperty('outline', value, '');
  }

  /** Gets the value of "outline-color" */
  String get outlineColor =>
    getPropertyValue('outline-color');

  /** Sets the value of "outline-color" */
  void set outlineColor(String value) {
    setProperty('outline-color', value, '');
  }

  /** Gets the value of "outline-offset" */
  String get outlineOffset =>
    getPropertyValue('outline-offset');

  /** Sets the value of "outline-offset" */
  void set outlineOffset(String value) {
    setProperty('outline-offset', value, '');
  }

  /** Gets the value of "outline-style" */
  String get outlineStyle =>
    getPropertyValue('outline-style');

  /** Sets the value of "outline-style" */
  void set outlineStyle(String value) {
    setProperty('outline-style', value, '');
  }

  /** Gets the value of "outline-width" */
  String get outlineWidth =>
    getPropertyValue('outline-width');

  /** Sets the value of "outline-width" */
  void set outlineWidth(String value) {
    setProperty('outline-width', value, '');
  }

  /** Gets the value of "overflow" */
  String get overflow =>
    getPropertyValue('overflow');

  /** Sets the value of "overflow" */
  void set overflow(String value) {
    setProperty('overflow', value, '');
  }

  /** Gets the value of "overflow-scrolling" */
  String get overflowScrolling =>
    getPropertyValue('${Device.cssPrefix}overflow-scrolling');

  /** Sets the value of "overflow-scrolling" */
  void set overflowScrolling(String value) {
    setProperty('${Device.cssPrefix}overflow-scrolling', value, '');
  }

  /** Gets the value of "overflow-wrap" */
  String get overflowWrap =>
    getPropertyValue('overflow-wrap');

  /** Sets the value of "overflow-wrap" */
  void set overflowWrap(String value) {
    setProperty('overflow-wrap', value, '');
  }

  /** Gets the value of "overflow-x" */
  String get overflowX =>
    getPropertyValue('overflow-x');

  /** Sets the value of "overflow-x" */
  void set overflowX(String value) {
    setProperty('overflow-x', value, '');
  }

  /** Gets the value of "overflow-y" */
  String get overflowY =>
    getPropertyValue('overflow-y');

  /** Sets the value of "overflow-y" */
  void set overflowY(String value) {
    setProperty('overflow-y', value, '');
  }

  /** Gets the value of "padding" */
  String get padding =>
    getPropertyValue('padding');

  /** Sets the value of "padding" */
  void set padding(String value) {
    setProperty('padding', value, '');
  }

  /** Gets the value of "padding-after" */
  String get paddingAfter =>
    getPropertyValue('${Device.cssPrefix}padding-after');

  /** Sets the value of "padding-after" */
  void set paddingAfter(String value) {
    setProperty('${Device.cssPrefix}padding-after', value, '');
  }

  /** Gets the value of "padding-before" */
  String get paddingBefore =>
    getPropertyValue('${Device.cssPrefix}padding-before');

  /** Sets the value of "padding-before" */
  void set paddingBefore(String value) {
    setProperty('${Device.cssPrefix}padding-before', value, '');
  }

  /** Gets the value of "padding-bottom" */
  String get paddingBottom =>
    getPropertyValue('padding-bottom');

  /** Sets the value of "padding-bottom" */
  void set paddingBottom(String value) {
    setProperty('padding-bottom', value, '');
  }

  /** Gets the value of "padding-end" */
  String get paddingEnd =>
    getPropertyValue('${Device.cssPrefix}padding-end');

  /** Sets the value of "padding-end" */
  void set paddingEnd(String value) {
    setProperty('${Device.cssPrefix}padding-end', value, '');
  }

  /** Gets the value of "padding-left" */
  String get paddingLeft =>
    getPropertyValue('padding-left');

  /** Sets the value of "padding-left" */
  void set paddingLeft(String value) {
    setProperty('padding-left', value, '');
  }

  /** Gets the value of "padding-right" */
  String get paddingRight =>
    getPropertyValue('padding-right');

  /** Sets the value of "padding-right" */
  void set paddingRight(String value) {
    setProperty('padding-right', value, '');
  }

  /** Gets the value of "padding-start" */
  String get paddingStart =>
    getPropertyValue('${Device.cssPrefix}padding-start');

  /** Sets the value of "padding-start" */
  void set paddingStart(String value) {
    setProperty('${Device.cssPrefix}padding-start', value, '');
  }

  /** Gets the value of "padding-top" */
  String get paddingTop =>
    getPropertyValue('padding-top');

  /** Sets the value of "padding-top" */
  void set paddingTop(String value) {
    setProperty('padding-top', value, '');
  }

  /** Gets the value of "page" */
  String get page =>
    getPropertyValue('page');

  /** Sets the value of "page" */
  void set page(String value) {
    setProperty('page', value, '');
  }

  /** Gets the value of "page-break-after" */
  String get pageBreakAfter =>
    getPropertyValue('page-break-after');

  /** Sets the value of "page-break-after" */
  void set pageBreakAfter(String value) {
    setProperty('page-break-after', value, '');
  }

  /** Gets the value of "page-break-before" */
  String get pageBreakBefore =>
    getPropertyValue('page-break-before');

  /** Sets the value of "page-break-before" */
  void set pageBreakBefore(String value) {
    setProperty('page-break-before', value, '');
  }

  /** Gets the value of "page-break-inside" */
  String get pageBreakInside =>
    getPropertyValue('page-break-inside');

  /** Sets the value of "page-break-inside" */
  void set pageBreakInside(String value) {
    setProperty('page-break-inside', value, '');
  }

  /** Gets the value of "perspective" */
  String get perspective =>
    getPropertyValue('${Device.cssPrefix}perspective');

  /** Sets the value of "perspective" */
  void set perspective(String value) {
    setProperty('${Device.cssPrefix}perspective', value, '');
  }

  /** Gets the value of "perspective-origin" */
  String get perspectiveOrigin =>
    getPropertyValue('${Device.cssPrefix}perspective-origin');

  /** Sets the value of "perspective-origin" */
  void set perspectiveOrigin(String value) {
    setProperty('${Device.cssPrefix}perspective-origin', value, '');
  }

  /** Gets the value of "perspective-origin-x" */
  String get perspectiveOriginX =>
    getPropertyValue('${Device.cssPrefix}perspective-origin-x');

  /** Sets the value of "perspective-origin-x" */
  void set perspectiveOriginX(String value) {
    setProperty('${Device.cssPrefix}perspective-origin-x', value, '');
  }

  /** Gets the value of "perspective-origin-y" */
  String get perspectiveOriginY =>
    getPropertyValue('${Device.cssPrefix}perspective-origin-y');

  /** Sets the value of "perspective-origin-y" */
  void set perspectiveOriginY(String value) {
    setProperty('${Device.cssPrefix}perspective-origin-y', value, '');
  }

  /** Gets the value of "pointer-events" */
  String get pointerEvents =>
    getPropertyValue('pointer-events');

  /** Sets the value of "pointer-events" */
  void set pointerEvents(String value) {
    setProperty('pointer-events', value, '');
  }

  /** Gets the value of "position" */
  String get position =>
    getPropertyValue('position');

  /** Sets the value of "position" */
  void set position(String value) {
    setProperty('position', value, '');
  }

  /** Gets the value of "print-color-adjust" */
  String get printColorAdjust =>
    getPropertyValue('${Device.cssPrefix}print-color-adjust');

  /** Sets the value of "print-color-adjust" */
  void set printColorAdjust(String value) {
    setProperty('${Device.cssPrefix}print-color-adjust', value, '');
  }

  /** Gets the value of "quotes" */
  String get quotes =>
    getPropertyValue('quotes');

  /** Sets the value of "quotes" */
  void set quotes(String value) {
    setProperty('quotes', value, '');
  }

  /** Gets the value of "region-break-after" */
  String get regionBreakAfter =>
    getPropertyValue('${Device.cssPrefix}region-break-after');

  /** Sets the value of "region-break-after" */
  void set regionBreakAfter(String value) {
    setProperty('${Device.cssPrefix}region-break-after', value, '');
  }

  /** Gets the value of "region-break-before" */
  String get regionBreakBefore =>
    getPropertyValue('${Device.cssPrefix}region-break-before');

  /** Sets the value of "region-break-before" */
  void set regionBreakBefore(String value) {
    setProperty('${Device.cssPrefix}region-break-before', value, '');
  }

  /** Gets the value of "region-break-inside" */
  String get regionBreakInside =>
    getPropertyValue('${Device.cssPrefix}region-break-inside');

  /** Sets the value of "region-break-inside" */
  void set regionBreakInside(String value) {
    setProperty('${Device.cssPrefix}region-break-inside', value, '');
  }

  /** Gets the value of "region-overflow" */
  String get regionOverflow =>
    getPropertyValue('${Device.cssPrefix}region-overflow');

  /** Sets the value of "region-overflow" */
  void set regionOverflow(String value) {
    setProperty('${Device.cssPrefix}region-overflow', value, '');
  }

  /** Gets the value of "resize" */
  String get resize =>
    getPropertyValue('resize');

  /** Sets the value of "resize" */
  void set resize(String value) {
    setProperty('resize', value, '');
  }

  /** Gets the value of "right" */
  String get right =>
    getPropertyValue('right');

  /** Sets the value of "right" */
  void set right(String value) {
    setProperty('right', value, '');
  }

  /** Gets the value of "rtl-ordering" */
  String get rtlOrdering =>
    getPropertyValue('${Device.cssPrefix}rtl-ordering');

  /** Sets the value of "rtl-ordering" */
  void set rtlOrdering(String value) {
    setProperty('${Device.cssPrefix}rtl-ordering', value, '');
  }

  /** Gets the value of "shape-inside" */
  String get shapeInside =>
    getPropertyValue('${Device.cssPrefix}shape-inside');

  /** Sets the value of "shape-inside" */
  void set shapeInside(String value) {
    setProperty('${Device.cssPrefix}shape-inside', value, '');
  }

  /** Gets the value of "shape-margin" */
  String get shapeMargin =>
    getPropertyValue('${Device.cssPrefix}shape-margin');

  /** Sets the value of "shape-margin" */
  void set shapeMargin(String value) {
    setProperty('${Device.cssPrefix}shape-margin', value, '');
  }

  /** Gets the value of "shape-outside" */
  String get shapeOutside =>
    getPropertyValue('${Device.cssPrefix}shape-outside');

  /** Sets the value of "shape-outside" */
  void set shapeOutside(String value) {
    setProperty('${Device.cssPrefix}shape-outside', value, '');
  }

  /** Gets the value of "shape-padding" */
  String get shapePadding =>
    getPropertyValue('${Device.cssPrefix}shape-padding');

  /** Sets the value of "shape-padding" */
  void set shapePadding(String value) {
    setProperty('${Device.cssPrefix}shape-padding', value, '');
  }

  /** Gets the value of "size" */
  String get size =>
    getPropertyValue('size');

  /** Sets the value of "size" */
  void set size(String value) {
    setProperty('size', value, '');
  }

  /** Gets the value of "speak" */
  String get speak =>
    getPropertyValue('speak');

  /** Sets the value of "speak" */
  void set speak(String value) {
    setProperty('speak', value, '');
  }

  /** Gets the value of "src" */
  String get src =>
    getPropertyValue('src');

  /** Sets the value of "src" */
  void set src(String value) {
    setProperty('src', value, '');
  }

  /** Gets the value of "tab-size" */
  String get tabSize =>
    getPropertyValue('tab-size');

  /** Sets the value of "tab-size" */
  void set tabSize(String value) {
    setProperty('tab-size', value, '');
  }

  /** Gets the value of "table-layout" */
  String get tableLayout =>
    getPropertyValue('table-layout');

  /** Sets the value of "table-layout" */
  void set tableLayout(String value) {
    setProperty('table-layout', value, '');
  }

  /** Gets the value of "tap-highlight-color" */
  String get tapHighlightColor =>
    getPropertyValue('${Device.cssPrefix}tap-highlight-color');

  /** Sets the value of "tap-highlight-color" */
  void set tapHighlightColor(String value) {
    setProperty('${Device.cssPrefix}tap-highlight-color', value, '');
  }

  /** Gets the value of "text-align" */
  String get textAlign =>
    getPropertyValue('text-align');

  /** Sets the value of "text-align" */
  void set textAlign(String value) {
    setProperty('text-align', value, '');
  }

  /** Gets the value of "text-align-last" */
  String get textAlignLast =>
    getPropertyValue('${Device.cssPrefix}text-align-last');

  /** Sets the value of "text-align-last" */
  void set textAlignLast(String value) {
    setProperty('${Device.cssPrefix}text-align-last', value, '');
  }

  /** Gets the value of "text-combine" */
  String get textCombine =>
    getPropertyValue('${Device.cssPrefix}text-combine');

  /** Sets the value of "text-combine" */
  void set textCombine(String value) {
    setProperty('${Device.cssPrefix}text-combine', value, '');
  }

  /** Gets the value of "text-decoration" */
  String get textDecoration =>
    getPropertyValue('text-decoration');

  /** Sets the value of "text-decoration" */
  void set textDecoration(String value) {
    setProperty('text-decoration', value, '');
  }

  /** Gets the value of "text-decoration-line" */
  String get textDecorationLine =>
    getPropertyValue('${Device.cssPrefix}text-decoration-line');

  /** Sets the value of "text-decoration-line" */
  void set textDecorationLine(String value) {
    setProperty('${Device.cssPrefix}text-decoration-line', value, '');
  }

  /** Gets the value of "text-decoration-style" */
  String get textDecorationStyle =>
    getPropertyValue('${Device.cssPrefix}text-decoration-style');

  /** Sets the value of "text-decoration-style" */
  void set textDecorationStyle(String value) {
    setProperty('${Device.cssPrefix}text-decoration-style', value, '');
  }

  /** Gets the value of "text-decorations-in-effect" */
  String get textDecorationsInEffect =>
    getPropertyValue('${Device.cssPrefix}text-decorations-in-effect');

  /** Sets the value of "text-decorations-in-effect" */
  void set textDecorationsInEffect(String value) {
    setProperty('${Device.cssPrefix}text-decorations-in-effect', value, '');
  }

  /** Gets the value of "text-emphasis" */
  String get textEmphasis =>
    getPropertyValue('${Device.cssPrefix}text-emphasis');

  /** Sets the value of "text-emphasis" */
  void set textEmphasis(String value) {
    setProperty('${Device.cssPrefix}text-emphasis', value, '');
  }

  /** Gets the value of "text-emphasis-color" */
  String get textEmphasisColor =>
    getPropertyValue('${Device.cssPrefix}text-emphasis-color');

  /** Sets the value of "text-emphasis-color" */
  void set textEmphasisColor(String value) {
    setProperty('${Device.cssPrefix}text-emphasis-color', value, '');
  }

  /** Gets the value of "text-emphasis-position" */
  String get textEmphasisPosition =>
    getPropertyValue('${Device.cssPrefix}text-emphasis-position');

  /** Sets the value of "text-emphasis-position" */
  void set textEmphasisPosition(String value) {
    setProperty('${Device.cssPrefix}text-emphasis-position', value, '');
  }

  /** Gets the value of "text-emphasis-style" */
  String get textEmphasisStyle =>
    getPropertyValue('${Device.cssPrefix}text-emphasis-style');

  /** Sets the value of "text-emphasis-style" */
  void set textEmphasisStyle(String value) {
    setProperty('${Device.cssPrefix}text-emphasis-style', value, '');
  }

  /** Gets the value of "text-fill-color" */
  String get textFillColor =>
    getPropertyValue('${Device.cssPrefix}text-fill-color');

  /** Sets the value of "text-fill-color" */
  void set textFillColor(String value) {
    setProperty('${Device.cssPrefix}text-fill-color', value, '');
  }

  /** Gets the value of "text-indent" */
  String get textIndent =>
    getPropertyValue('text-indent');

  /** Sets the value of "text-indent" */
  void set textIndent(String value) {
    setProperty('text-indent', value, '');
  }

  /** Gets the value of "text-line-through" */
  String get textLineThrough =>
    getPropertyValue('text-line-through');

  /** Sets the value of "text-line-through" */
  void set textLineThrough(String value) {
    setProperty('text-line-through', value, '');
  }

  /** Gets the value of "text-line-through-color" */
  String get textLineThroughColor =>
    getPropertyValue('text-line-through-color');

  /** Sets the value of "text-line-through-color" */
  void set textLineThroughColor(String value) {
    setProperty('text-line-through-color', value, '');
  }

  /** Gets the value of "text-line-through-mode" */
  String get textLineThroughMode =>
    getPropertyValue('text-line-through-mode');

  /** Sets the value of "text-line-through-mode" */
  void set textLineThroughMode(String value) {
    setProperty('text-line-through-mode', value, '');
  }

  /** Gets the value of "text-line-through-style" */
  String get textLineThroughStyle =>
    getPropertyValue('text-line-through-style');

  /** Sets the value of "text-line-through-style" */
  void set textLineThroughStyle(String value) {
    setProperty('text-line-through-style', value, '');
  }

  /** Gets the value of "text-line-through-width" */
  String get textLineThroughWidth =>
    getPropertyValue('text-line-through-width');

  /** Sets the value of "text-line-through-width" */
  void set textLineThroughWidth(String value) {
    setProperty('text-line-through-width', value, '');
  }

  /** Gets the value of "text-orientation" */
  String get textOrientation =>
    getPropertyValue('${Device.cssPrefix}text-orientation');

  /** Sets the value of "text-orientation" */
  void set textOrientation(String value) {
    setProperty('${Device.cssPrefix}text-orientation', value, '');
  }

  /** Gets the value of "text-overflow" */
  String get textOverflow =>
    getPropertyValue('text-overflow');

  /** Sets the value of "text-overflow" */
  void set textOverflow(String value) {
    setProperty('text-overflow', value, '');
  }

  /** Gets the value of "text-overline" */
  String get textOverline =>
    getPropertyValue('text-overline');

  /** Sets the value of "text-overline" */
  void set textOverline(String value) {
    setProperty('text-overline', value, '');
  }

  /** Gets the value of "text-overline-color" */
  String get textOverlineColor =>
    getPropertyValue('text-overline-color');

  /** Sets the value of "text-overline-color" */
  void set textOverlineColor(String value) {
    setProperty('text-overline-color', value, '');
  }

  /** Gets the value of "text-overline-mode" */
  String get textOverlineMode =>
    getPropertyValue('text-overline-mode');

  /** Sets the value of "text-overline-mode" */
  void set textOverlineMode(String value) {
    setProperty('text-overline-mode', value, '');
  }

  /** Gets the value of "text-overline-style" */
  String get textOverlineStyle =>
    getPropertyValue('text-overline-style');

  /** Sets the value of "text-overline-style" */
  void set textOverlineStyle(String value) {
    setProperty('text-overline-style', value, '');
  }

  /** Gets the value of "text-overline-width" */
  String get textOverlineWidth =>
    getPropertyValue('text-overline-width');

  /** Sets the value of "text-overline-width" */
  void set textOverlineWidth(String value) {
    setProperty('text-overline-width', value, '');
  }

  /** Gets the value of "text-rendering" */
  String get textRendering =>
    getPropertyValue('text-rendering');

  /** Sets the value of "text-rendering" */
  void set textRendering(String value) {
    setProperty('text-rendering', value, '');
  }

  /** Gets the value of "text-security" */
  String get textSecurity =>
    getPropertyValue('${Device.cssPrefix}text-security');

  /** Sets the value of "text-security" */
  void set textSecurity(String value) {
    setProperty('${Device.cssPrefix}text-security', value, '');
  }

  /** Gets the value of "text-shadow" */
  String get textShadow =>
    getPropertyValue('text-shadow');

  /** Sets the value of "text-shadow" */
  void set textShadow(String value) {
    setProperty('text-shadow', value, '');
  }

  /** Gets the value of "text-size-adjust" */
  String get textSizeAdjust =>
    getPropertyValue('${Device.cssPrefix}text-size-adjust');

  /** Sets the value of "text-size-adjust" */
  void set textSizeAdjust(String value) {
    setProperty('${Device.cssPrefix}text-size-adjust', value, '');
  }

  /** Gets the value of "text-stroke" */
  String get textStroke =>
    getPropertyValue('${Device.cssPrefix}text-stroke');

  /** Sets the value of "text-stroke" */
  void set textStroke(String value) {
    setProperty('${Device.cssPrefix}text-stroke', value, '');
  }

  /** Gets the value of "text-stroke-color" */
  String get textStrokeColor =>
    getPropertyValue('${Device.cssPrefix}text-stroke-color');

  /** Sets the value of "text-stroke-color" */
  void set textStrokeColor(String value) {
    setProperty('${Device.cssPrefix}text-stroke-color', value, '');
  }

  /** Gets the value of "text-stroke-width" */
  String get textStrokeWidth =>
    getPropertyValue('${Device.cssPrefix}text-stroke-width');

  /** Sets the value of "text-stroke-width" */
  void set textStrokeWidth(String value) {
    setProperty('${Device.cssPrefix}text-stroke-width', value, '');
  }

  /** Gets the value of "text-transform" */
  String get textTransform =>
    getPropertyValue('text-transform');

  /** Sets the value of "text-transform" */
  void set textTransform(String value) {
    setProperty('text-transform', value, '');
  }

  /** Gets the value of "text-underline" */
  String get textUnderline =>
    getPropertyValue('text-underline');

  /** Sets the value of "text-underline" */
  void set textUnderline(String value) {
    setProperty('text-underline', value, '');
  }

  /** Gets the value of "text-underline-color" */
  String get textUnderlineColor =>
    getPropertyValue('text-underline-color');

  /** Sets the value of "text-underline-color" */
  void set textUnderlineColor(String value) {
    setProperty('text-underline-color', value, '');
  }

  /** Gets the value of "text-underline-mode" */
  String get textUnderlineMode =>
    getPropertyValue('text-underline-mode');

  /** Sets the value of "text-underline-mode" */
  void set textUnderlineMode(String value) {
    setProperty('text-underline-mode', value, '');
  }

  /** Gets the value of "text-underline-style" */
  String get textUnderlineStyle =>
    getPropertyValue('text-underline-style');

  /** Sets the value of "text-underline-style" */
  void set textUnderlineStyle(String value) {
    setProperty('text-underline-style', value, '');
  }

  /** Gets the value of "text-underline-width" */
  String get textUnderlineWidth =>
    getPropertyValue('text-underline-width');

  /** Sets the value of "text-underline-width" */
  void set textUnderlineWidth(String value) {
    setProperty('text-underline-width', value, '');
  }

  /** Gets the value of "top" */
  String get top =>
    getPropertyValue('top');

  /** Sets the value of "top" */
  void set top(String value) {
    setProperty('top', value, '');
  }

  /** Gets the value of "transform" */
  String get transform =>
    getPropertyValue('${Device.cssPrefix}transform');

  /** Sets the value of "transform" */
  void set transform(String value) {
    setProperty('${Device.cssPrefix}transform', value, '');
  }

  /** Gets the value of "transform-origin" */
  String get transformOrigin =>
    getPropertyValue('${Device.cssPrefix}transform-origin');

  /** Sets the value of "transform-origin" */
  void set transformOrigin(String value) {
    setProperty('${Device.cssPrefix}transform-origin', value, '');
  }

  /** Gets the value of "transform-origin-x" */
  String get transformOriginX =>
    getPropertyValue('${Device.cssPrefix}transform-origin-x');

  /** Sets the value of "transform-origin-x" */
  void set transformOriginX(String value) {
    setProperty('${Device.cssPrefix}transform-origin-x', value, '');
  }

  /** Gets the value of "transform-origin-y" */
  String get transformOriginY =>
    getPropertyValue('${Device.cssPrefix}transform-origin-y');

  /** Sets the value of "transform-origin-y" */
  void set transformOriginY(String value) {
    setProperty('${Device.cssPrefix}transform-origin-y', value, '');
  }

  /** Gets the value of "transform-origin-z" */
  String get transformOriginZ =>
    getPropertyValue('${Device.cssPrefix}transform-origin-z');

  /** Sets the value of "transform-origin-z" */
  void set transformOriginZ(String value) {
    setProperty('${Device.cssPrefix}transform-origin-z', value, '');
  }

  /** Gets the value of "transform-style" */
  String get transformStyle =>
    getPropertyValue('${Device.cssPrefix}transform-style');

  /** Sets the value of "transform-style" */
  void set transformStyle(String value) {
    setProperty('${Device.cssPrefix}transform-style', value, '');
  }

  /** Gets the value of "transition" */
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.FIREFOX)
  @SupportedBrowser(SupportedBrowser.IE, '10')
  @SupportedBrowser(SupportedBrowser.SAFARI)
  String get transition =>
    getPropertyValue('${Device.cssPrefix}transition');

  /** Sets the value of "transition" */
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.FIREFOX)
  @SupportedBrowser(SupportedBrowser.IE, '10')
  @SupportedBrowser(SupportedBrowser.SAFARI)
  void set transition(String value) {
    setProperty('${Device.cssPrefix}transition', value, '');
  }

  /** Gets the value of "transition-delay" */
  String get transitionDelay =>
    getPropertyValue('${Device.cssPrefix}transition-delay');

  /** Sets the value of "transition-delay" */
  void set transitionDelay(String value) {
    setProperty('${Device.cssPrefix}transition-delay', value, '');
  }

  /** Gets the value of "transition-duration" */
  String get transitionDuration =>
    getPropertyValue('${Device.cssPrefix}transition-duration');

  /** Sets the value of "transition-duration" */
  void set transitionDuration(String value) {
    setProperty('${Device.cssPrefix}transition-duration', value, '');
  }

  /** Gets the value of "transition-property" */
  String get transitionProperty =>
    getPropertyValue('${Device.cssPrefix}transition-property');

  /** Sets the value of "transition-property" */
  void set transitionProperty(String value) {
    setProperty('${Device.cssPrefix}transition-property', value, '');
  }

  /** Gets the value of "transition-timing-function" */
  String get transitionTimingFunction =>
    getPropertyValue('${Device.cssPrefix}transition-timing-function');

  /** Sets the value of "transition-timing-function" */
  void set transitionTimingFunction(String value) {
    setProperty('${Device.cssPrefix}transition-timing-function', value, '');
  }

  /** Gets the value of "unicode-bidi" */
  String get unicodeBidi =>
    getPropertyValue('unicode-bidi');

  /** Sets the value of "unicode-bidi" */
  void set unicodeBidi(String value) {
    setProperty('unicode-bidi', value, '');
  }

  /** Gets the value of "unicode-range" */
  String get unicodeRange =>
    getPropertyValue('unicode-range');

  /** Sets the value of "unicode-range" */
  void set unicodeRange(String value) {
    setProperty('unicode-range', value, '');
  }

  /** Gets the value of "user-drag" */
  String get userDrag =>
    getPropertyValue('${Device.cssPrefix}user-drag');

  /** Sets the value of "user-drag" */
  void set userDrag(String value) {
    setProperty('${Device.cssPrefix}user-drag', value, '');
  }

  /** Gets the value of "user-modify" */
  String get userModify =>
    getPropertyValue('${Device.cssPrefix}user-modify');

  /** Sets the value of "user-modify" */
  void set userModify(String value) {
    setProperty('${Device.cssPrefix}user-modify', value, '');
  }

  /** Gets the value of "user-select" */
  String get userSelect =>
    getPropertyValue('${Device.cssPrefix}user-select');

  /** Sets the value of "user-select" */
  void set userSelect(String value) {
    setProperty('${Device.cssPrefix}user-select', value, '');
  }

  /** Gets the value of "user-zoom" */
  String get userZoom =>
    getPropertyValue('user-zoom');

  /** Sets the value of "user-zoom" */
  void set userZoom(String value) {
    setProperty('user-zoom', value, '');
  }

  /** Gets the value of "vertical-align" */
  String get verticalAlign =>
    getPropertyValue('vertical-align');

  /** Sets the value of "vertical-align" */
  void set verticalAlign(String value) {
    setProperty('vertical-align', value, '');
  }

  /** Gets the value of "visibility" */
  String get visibility =>
    getPropertyValue('visibility');

  /** Sets the value of "visibility" */
  void set visibility(String value) {
    setProperty('visibility', value, '');
  }

  /** Gets the value of "white-space" */
  String get whiteSpace =>
    getPropertyValue('white-space');

  /** Sets the value of "white-space" */
  void set whiteSpace(String value) {
    setProperty('white-space', value, '');
  }

  /** Gets the value of "widows" */
  String get widows =>
    getPropertyValue('widows');

  /** Sets the value of "widows" */
  void set widows(String value) {
    setProperty('widows', value, '');
  }

  /** Gets the value of "width" */
  String get width =>
    getPropertyValue('width');

  /** Sets the value of "width" */
  void set width(String value) {
    setProperty('width', value, '');
  }

  /** Gets the value of "word-break" */
  String get wordBreak =>
    getPropertyValue('word-break');

  /** Sets the value of "word-break" */
  void set wordBreak(String value) {
    setProperty('word-break', value, '');
  }

  /** Gets the value of "word-spacing" */
  String get wordSpacing =>
    getPropertyValue('word-spacing');

  /** Sets the value of "word-spacing" */
  void set wordSpacing(String value) {
    setProperty('word-spacing', value, '');
  }

  /** Gets the value of "word-wrap" */
  String get wordWrap =>
    getPropertyValue('word-wrap');

  /** Sets the value of "word-wrap" */
  void set wordWrap(String value) {
    setProperty('word-wrap', value, '');
  }

  /** Gets the value of "wrap" */
  String get wrap =>
    getPropertyValue('${Device.cssPrefix}wrap');

  /** Sets the value of "wrap" */
  void set wrap(String value) {
    setProperty('${Device.cssPrefix}wrap', value, '');
  }

  /** Gets the value of "wrap-flow" */
  String get wrapFlow =>
    getPropertyValue('${Device.cssPrefix}wrap-flow');

  /** Sets the value of "wrap-flow" */
  void set wrapFlow(String value) {
    setProperty('${Device.cssPrefix}wrap-flow', value, '');
  }

  /** Gets the value of "wrap-through" */
  String get wrapThrough =>
    getPropertyValue('${Device.cssPrefix}wrap-through');

  /** Sets the value of "wrap-through" */
  void set wrapThrough(String value) {
    setProperty('${Device.cssPrefix}wrap-through', value, '');
  }

  /** Gets the value of "writing-mode" */
  String get writingMode =>
    getPropertyValue('${Device.cssPrefix}writing-mode');

  /** Sets the value of "writing-mode" */
  void set writingMode(String value) {
    setProperty('${Device.cssPrefix}writing-mode', value, '');
  }

  /** Gets the value of "z-index" */
  String get zIndex =>
    getPropertyValue('z-index');

  /** Sets the value of "z-index" */
  void set zIndex(String value) {
    setProperty('z-index', value, '');
  }

  /** Gets the value of "zoom" */
  String get zoom =>
    getPropertyValue('zoom');

  /** Sets the value of "zoom" */
  void set zoom(String value) {
    setProperty('zoom', value, '');
  }
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('CSSStyleRule')
class CssStyleRule extends CssRule {
  CssStyleRule.internal() : super.internal();

  @DomName('CSSStyleRule.selectorText')
  @DocsEditable
  String get selectorText native "CSSStyleRule_selectorText_Getter";

  @DomName('CSSStyleRule.selectorText')
  @DocsEditable
  void set selectorText(String value) native "CSSStyleRule_selectorText_Setter";

  @DomName('CSSStyleRule.style')
  @DocsEditable
  CssStyleDeclaration get style native "CSSStyleRule_style_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('CSSStyleSheet')
class CssStyleSheet extends StyleSheet {
  CssStyleSheet.internal() : super.internal();

  @DomName('CSSStyleSheet.cssRules')
  @DocsEditable
  List<CssRule> get cssRules native "CSSStyleSheet_cssRules_Getter";

  @DomName('CSSStyleSheet.ownerRule')
  @DocsEditable
  CssRule get ownerRule native "CSSStyleSheet_ownerRule_Getter";

  @DomName('CSSStyleSheet.rules')
  @DocsEditable
  List<CssRule> get rules native "CSSStyleSheet_rules_Getter";

  int addRule(String selector, String style, [int index]) {
    if (?index) {
      return _addRule_1(selector, style, index);
    }
    return _addRule_2(selector, style);
  }

  int _addRule_1(selector, style, index) native "CSSStyleSheet__addRule_1_Callback";

  int _addRule_2(selector, style) native "CSSStyleSheet__addRule_2_Callback";

  @DomName('CSSStyleSheet.deleteRule')
  @DocsEditable
  void deleteRule(int index) native "CSSStyleSheet_deleteRule_Callback";

  @DomName('CSSStyleSheet.insertRule')
  @DocsEditable
  int insertRule(String rule, int index) native "CSSStyleSheet_insertRule_Callback";

  @DomName('CSSStyleSheet.removeRule')
  @DocsEditable
  void removeRule(int index) native "CSSStyleSheet_removeRule_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('CSSUnknownRule')
class CssUnknownRule extends CssRule {
  CssUnknownRule.internal() : super.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('CustomElementConstructor')
class CustomElementConstructor extends NativeFieldWrapperClass1 {
  CustomElementConstructor.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DomName('CustomEvent')
class CustomEvent extends Event {
  factory CustomEvent(String type,
      {bool canBubble: true, bool cancelable: true, Object detail}) {

    final CustomEvent e = document.$dom_createEvent("CustomEvent");
    e.$dom_initCustomEvent(type, canBubble, cancelable, detail);

    return e;
  }
  CustomEvent.internal() : super.internal();

  @DomName('CustomEvent.detail')
  @DocsEditable
  Object get detail native "CustomEvent_detail_Getter";

  @DomName('CustomEvent.initCustomEvent')
  @DocsEditable
  void $dom_initCustomEvent(String typeArg, bool canBubbleArg, bool cancelableArg, Object detailArg) native "CustomEvent_initCustomEvent_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLDListElement')
class DListElement extends _Element_Merged {
  DListElement.internal() : super.internal();

  @DomName('HTMLDListElement.HTMLDListElement')
  @DocsEditable
  factory DListElement() => document.$dom_createElement("dl");

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLDataListElement')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.FIREFOX)
@SupportedBrowser(SupportedBrowser.IE, '10')
@SupportedBrowser(SupportedBrowser.SAFARI)
class DataListElement extends _Element_Merged {
  DataListElement.internal() : super.internal();

  @DomName('HTMLDataListElement.HTMLDataListElement')
  @DocsEditable
  factory DataListElement() => document.$dom_createElement("datalist");

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('HTMLDataListElement.options')
  @DocsEditable
  HtmlCollection get options native "HTMLDataListElement_options_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('Clipboard')
class DataTransfer extends NativeFieldWrapperClass1 {
  DataTransfer.internal();

  @DomName('Clipboard.dropEffect')
  @DocsEditable
  String get dropEffect native "Clipboard_dropEffect_Getter";

  @DomName('Clipboard.dropEffect')
  @DocsEditable
  void set dropEffect(String value) native "Clipboard_dropEffect_Setter";

  @DomName('Clipboard.effectAllowed')
  @DocsEditable
  String get effectAllowed native "Clipboard_effectAllowed_Getter";

  @DomName('Clipboard.effectAllowed')
  @DocsEditable
  void set effectAllowed(String value) native "Clipboard_effectAllowed_Setter";

  @DomName('Clipboard.files')
  @DocsEditable
  List<File> get files native "Clipboard_files_Getter";

  @DomName('Clipboard.items')
  @DocsEditable
  DataTransferItemList get items native "Clipboard_items_Getter";

  @DomName('Clipboard.types')
  @DocsEditable
  List get types native "Clipboard_types_Getter";

  @DomName('Clipboard.clearData')
  @DocsEditable
  void clearData([String type]) native "Clipboard_clearData_Callback";

  /**
   * Gets the data for the specified type.
   *
   * The data is only available from within a drop operation (such as an
   * [Element.onDrop] event) and will return `null` before the event is
   * triggered.
   *
   * Data transfer is prohibited across domains. If a drag originates
   * from content from another domain or protocol (HTTP vs HTTPS) then the
   * data cannot be accessed.
   *
   * The [type] can have values such as:
   *
   * * `'Text'`
   * * `'URL'`
   */
  @DomName('Clipboard.getData')
  @DocsEditable
  String getData(String type) native "Clipboard_getData_Callback";

  @DomName('Clipboard.setData')
  @DocsEditable
  bool setData(String type, String data) native "Clipboard_setData_Callback";

  @DomName('Clipboard.setDragImage')
  @DocsEditable
  void setDragImage(ImageElement image, int x, int y) native "Clipboard_setDragImage_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('DataTransferItem')
class DataTransferItem extends NativeFieldWrapperClass1 {
  DataTransferItem.internal();

  @DomName('DataTransferItem.kind')
  @DocsEditable
  String get kind native "DataTransferItem_kind_Getter";

  @DomName('DataTransferItem.type')
  @DocsEditable
  String get type native "DataTransferItem_type_Getter";

  @DomName('DataTransferItem.getAsFile')
  @DocsEditable
  Blob getAsFile() native "DataTransferItem_getAsFile_Callback";

  @DomName('DataTransferItem.getAsString')
  @DocsEditable
  void _getAsString([_StringCallback callback]) native "DataTransferItem_getAsString_Callback";

  Future<String> getAsString() {
    var completer = new Completer<String>();
    _getAsString(
        (value) { completer.complete(value); });
    return completer.future;
  }

  @DomName('DataTransferItem.webkitGetAsEntry')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  Entry getAsEntry() native "DataTransferItem_webkitGetAsEntry_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('DataTransferItemList')
class DataTransferItemList extends NativeFieldWrapperClass1 {
  DataTransferItemList.internal();

  @DomName('DataTransferItemList.length')
  @DocsEditable
  int get length native "DataTransferItemList_length_Getter";

  void add(data_OR_file, [String type]) {
    if ((data_OR_file is File || data_OR_file == null) && !?type) {
      _add_1(data_OR_file);
      return;
    }
    if ((data_OR_file is String || data_OR_file == null) && (type is String || type == null)) {
      _add_2(data_OR_file, type);
      return;
    }
    throw new ArgumentError("Incorrect number or type of arguments");
  }

  void _add_1(data_OR_file) native "DataTransferItemList__add_1_Callback";

  void _add_2(data_OR_file, type) native "DataTransferItemList__add_2_Callback";

  @DomName('DataTransferItemList.clear')
  @DocsEditable
  void clear() native "DataTransferItemList_clear_Callback";

  @DomName('DataTransferItemList.item')
  @DocsEditable
  DataTransferItem item(int index) native "DataTransferItemList_item_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


typedef void DatabaseCallback(database);
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLDetailsElement')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.SAFARI)
@Experimental
class DetailsElement extends _Element_Merged {
  DetailsElement.internal() : super.internal();

  @DomName('HTMLDetailsElement.HTMLDetailsElement')
  @DocsEditable
  factory DetailsElement() => document.$dom_createElement("details");

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('HTMLDetailsElement.open')
  @DocsEditable
  bool get open native "HTMLDetailsElement_open_Getter";

  @DomName('HTMLDetailsElement.open')
  @DocsEditable
  void set open(bool value) native "HTMLDetailsElement_open_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('DeviceAcceleration')
class DeviceAcceleration extends NativeFieldWrapperClass1 {
  DeviceAcceleration.internal();

  @DomName('DeviceAcceleration.x')
  @DocsEditable
  num get x native "DeviceAcceleration_x_Getter";

  @DomName('DeviceAcceleration.y')
  @DocsEditable
  num get y native "DeviceAcceleration_y_Getter";

  @DomName('DeviceAcceleration.z')
  @DocsEditable
  num get z native "DeviceAcceleration_z_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('DeviceMotionEvent')
class DeviceMotionEvent extends Event {
  DeviceMotionEvent.internal() : super.internal();

  @DomName('DeviceMotionEvent.acceleration')
  @DocsEditable
  DeviceAcceleration get acceleration native "DeviceMotionEvent_acceleration_Getter";

  @DomName('DeviceMotionEvent.accelerationIncludingGravity')
  @DocsEditable
  DeviceAcceleration get accelerationIncludingGravity native "DeviceMotionEvent_accelerationIncludingGravity_Getter";

  @DomName('DeviceMotionEvent.interval')
  @DocsEditable
  num get interval native "DeviceMotionEvent_interval_Getter";

  @DomName('DeviceMotionEvent.rotationRate')
  @DocsEditable
  DeviceRotationRate get rotationRate native "DeviceMotionEvent_rotationRate_Getter";

}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.

@DomName('DeviceOrientationEvent')

class DeviceOrientationEvent extends Event {
  factory DeviceOrientationEvent(String type,
      {bool canBubble: true, bool cancelable: true, num alpha: 0, num beta: 0,
      num gamma: 0, bool absolute: false}) {
    var e = document.$dom_createEvent("DeviceOrientationEvent");
    e.$dom_initDeviceOrientationEvent(type, canBubble, cancelable, alpha, beta,
        gamma, absolute);
    return e;
  }
  DeviceOrientationEvent.internal() : super.internal();

  @DomName('DeviceOrientationEvent.absolute')
  @DocsEditable
  bool get absolute native "DeviceOrientationEvent_absolute_Getter";

  @DomName('DeviceOrientationEvent.alpha')
  @DocsEditable
  num get alpha native "DeviceOrientationEvent_alpha_Getter";

  @DomName('DeviceOrientationEvent.beta')
  @DocsEditable
  num get beta native "DeviceOrientationEvent_beta_Getter";

  @DomName('DeviceOrientationEvent.gamma')
  @DocsEditable
  num get gamma native "DeviceOrientationEvent_gamma_Getter";

  @DomName('DeviceOrientationEvent.initDeviceOrientationEvent')
  @DocsEditable
  void $dom_initDeviceOrientationEvent(String type, bool bubbles, bool cancelable, num alpha, num beta, num gamma, bool absolute) native "DeviceOrientationEvent_initDeviceOrientationEvent_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('DeviceRotationRate')
class DeviceRotationRate extends NativeFieldWrapperClass1 {
  DeviceRotationRate.internal();

  @DomName('DeviceRotationRate.alpha')
  @DocsEditable
  num get alpha native "DeviceRotationRate_alpha_Getter";

  @DomName('DeviceRotationRate.beta')
  @DocsEditable
  num get beta native "DeviceRotationRate_beta_Getter";

  @DomName('DeviceRotationRate.gamma')
  @DocsEditable
  num get gamma native "DeviceRotationRate_gamma_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLDialogElement')
class DialogElement extends _Element_Merged {
  DialogElement.internal() : super.internal();

  @DomName('HTMLDialogElement.open')
  @DocsEditable
  bool get open native "HTMLDialogElement_open_Getter";

  @DomName('HTMLDialogElement.open')
  @DocsEditable
  void set open(bool value) native "HTMLDialogElement_open_Setter";

  @DomName('HTMLDialogElement.close')
  @DocsEditable
  void close() native "HTMLDialogElement_close_Callback";

  @DomName('HTMLDialogElement.show')
  @DocsEditable
  void show() native "HTMLDialogElement_show_Callback";

  @DomName('HTMLDialogElement.showModal')
  @DocsEditable
  void showModal() native "HTMLDialogElement_showModal_Callback";

}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('DirectoryEntry')
class DirectoryEntry extends Entry {
  
  /**
   * Create a new directory with the specified `path`. If `exclusive` is true,
   * the returned Future will complete with an error if a directory already
   * exists with the specified `path`.
   */
  Future<Entry> createDirectory(String path, {bool exclusive: false}) {
    return _getDirectory(path, options: 
        {'create': true, 'exclusive': exclusive});
  }

  /**
   * Retrieve an already existing directory entry. The returned future will
   * result in an error if a directory at `path` does not exist or if the item
   * at `path` is not a directory.
   */
  Future<Entry> getDirectory(String path) {
    return _getDirectory(path);
  }

  /**
   * Create a new file with the specified `path`. If `exclusive` is true,
   * the returned Future will complete with an error if a file already
   * exists at the specified `path`.
   */
  Future<Entry> createFile(String path, {bool exclusive: false}) {
    return _getFile(path, options: {'create': true, 'exclusive': exclusive});
  }
  
  /**
   * Retrieve an already existing file entry. The returned future will
   * result in an error if a file at `path` does not exist or if the item at
   * `path` is not a file.
   */
  Future<Entry> getFile(String path) {
    return _getFile(path);
  }
  DirectoryEntry.internal() : super.internal();

  @DomName('DirectoryEntry.createReader')
  @DocsEditable
  DirectoryReader createReader() native "DirectoryEntry_createReader_Callback";

  @DomName('DirectoryEntry.getDirectory')
  @DocsEditable
  void __getDirectory(String path, {Map options, _EntryCallback successCallback, _ErrorCallback errorCallback}) native "DirectoryEntry_getDirectory_Callback";

  Future<Entry> _getDirectory(String path, {Map options}) {
    var completer = new Completer<Entry>();
    __getDirectory(path, options : options,
        successCallback : (value) { completer.complete(value); },
        errorCallback : (error) { completer.completeError(error); });
    return completer.future;
  }

  @DomName('DirectoryEntry.getFile')
  @DocsEditable
  void __getFile(String path, {Map options, _EntryCallback successCallback, _ErrorCallback errorCallback}) native "DirectoryEntry_getFile_Callback";

  Future<Entry> _getFile(String path, {Map options}) {
    var completer = new Completer<Entry>();
    __getFile(path, options : options,
        successCallback : (value) { completer.complete(value); },
        errorCallback : (error) { completer.completeError(error); });
    return completer.future;
  }

  @DomName('DirectoryEntry.removeRecursively')
  @DocsEditable
  void _removeRecursively(VoidCallback successCallback, [_ErrorCallback errorCallback]) native "DirectoryEntry_removeRecursively_Callback";

  Future removeRecursively() {
    var completer = new Completer();
    _removeRecursively(
        () { completer.complete(); },
        (error) { completer.completeError(error); });
    return completer.future;
  }

}

// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('DirectoryReader')
class DirectoryReader extends NativeFieldWrapperClass1 {
  DirectoryReader.internal();

  @DomName('DirectoryReader.readEntries')
  @DocsEditable
  void _readEntries(_EntriesCallback successCallback, [_ErrorCallback errorCallback]) native "DirectoryReader_readEntries_Callback";

  Future<List<Entry>> readEntries() {
    var completer = new Completer<List<Entry>>();
    _readEntries(
        (value) { completer.complete(value); },
        (error) { completer.completeError(error); });
    return completer.future;
  }

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
/**
 * Represents an HTML <div> element.
 *
 * The [DivElement] is a generic container for content and does not have any
 * special significance. It is functionally similar to [SpanElement].
 *
 * The [DivElement] is a block-level element, as opposed to [SpanElement],
 * which is an inline-level element.
 *
 * Example usage:
 *
 *     DivElement div = new DivElement();
 *     div.text = 'Here's my new DivElem
 *     document.body.elements.add(elem);
 *
 * See also:
 *
 * * [HTML <div> element](http://www.w3.org/TR/html-markup/div.html) from W3C.
 * * [Block-level element](http://www.w3.org/TR/CSS2/visuren.html#block-boxes) from W3C.
 * * [Inline-level element](http://www.w3.org/TR/CSS2/visuren.html#inline-boxes) from W3C.
 */
@DomName('HTMLDivElement')
class DivElement extends _Element_Merged {
  DivElement.internal() : super.internal();

  @DomName('HTMLDivElement.HTMLDivElement')
  @DocsEditable
  factory DivElement() => document.$dom_createElement("div");

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/**
 * The base class for all documents.
 *
 * Each web page loaded in the browser has its own [Document] object, which is
 * typically an [HtmlDocument].
 *
 * If you aren't comfortable with DOM concepts, see the Dart tutorial
 * [Target 2: Connect Dart & HTML](http://www.dartlang.org/docs/tutorials/connect-dart-html/).
 */
@DomName('Document')
class Document extends Node 
{

  Document.internal() : super.internal();

  @DomName('Document.readystatechangeEvent')
  @DocsEditable
  static const EventStreamProvider<Event> readyStateChangeEvent = const EventStreamProvider<Event>('readystatechange');

  @DomName('Document.selectionchangeEvent')
  @DocsEditable
  static const EventStreamProvider<Event> selectionChangeEvent = const EventStreamProvider<Event>('selectionchange');

  @DomName('Document.webkitpointerlockchangeEvent')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  static const EventStreamProvider<Event> pointerLockChangeEvent = const EventStreamProvider<Event>('webkitpointerlockchange');

  @DomName('Document.webkitpointerlockerrorEvent')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  static const EventStreamProvider<Event> pointerLockErrorEvent = const EventStreamProvider<Event>('webkitpointerlockerror');

  /// Moved to [HtmlDocument].
  @DomName('Document.body')
  @DocsEditable
  Element get $dom_body native "Document_body_Getter";

  /// Moved to [HtmlDocument].
  @DomName('Document.body')
  @DocsEditable
  void set $dom_body(Element value) native "Document_body_Setter";

  @DomName('Document.charset')
  @DocsEditable
  String get charset native "Document_charset_Getter";

  @DomName('Document.charset')
  @DocsEditable
  void set charset(String value) native "Document_charset_Setter";

  @DomName('Document.cookie')
  @DocsEditable
  String get cookie native "Document_cookie_Getter";

  @DomName('Document.cookie')
  @DocsEditable
  void set cookie(String value) native "Document_cookie_Setter";

  @DomName('Document.defaultView')
  @DocsEditable
  WindowBase get window native "Document_defaultView_Getter";

  @DomName('Document.documentElement')
  @DocsEditable
  Element get documentElement native "Document_documentElement_Getter";

  @DomName('Document.domain')
  @DocsEditable
  String get domain native "Document_domain_Getter";

  @DomName('Document.fontloader')
  @DocsEditable
  FontLoader get fontloader native "Document_fontloader_Getter";

  /// Moved to [HtmlDocument].
  @DomName('Document.head')
  @DocsEditable
  HeadElement get $dom_head native "Document_head_Getter";

  @DomName('Document.implementation')
  @DocsEditable
  DomImplementation get implementation native "Document_implementation_Getter";

  /// Moved to [HtmlDocument].
  @DomName('Document.lastModified')
  @DocsEditable
  String get $dom_lastModified native "Document_lastModified_Getter";

  @DomName('Document.preferredStylesheetSet')
  @DocsEditable
  String get $dom_preferredStylesheetSet native "Document_preferredStylesheetSet_Getter";

  @DomName('Document.readyState')
  @DocsEditable
  String get readyState native "Document_readyState_Getter";

  /// Moved to [HtmlDocument].
  @DomName('Document.referrer')
  @DocsEditable
  String get $dom_referrer native "Document_referrer_Getter";

  @DomName('Document.securityPolicy')
  @DocsEditable
  SecurityPolicy get securityPolicy native "Document_securityPolicy_Getter";

  @DomName('Document.selectedStylesheetSet')
  @DocsEditable
  String get $dom_selectedStylesheetSet native "Document_selectedStylesheetSet_Getter";

  @DomName('Document.selectedStylesheetSet')
  @DocsEditable
  void set $dom_selectedStylesheetSet(String value) native "Document_selectedStylesheetSet_Setter";

  /// Moved to [HtmlDocument]
  @DomName('Document.styleSheets')
  @DocsEditable
  List<StyleSheet> get $dom_styleSheets native "Document_styleSheets_Getter";

  /// Moved to [HtmlDocument].
  @DomName('Document.title')
  @DocsEditable
  String get $dom_title native "Document_title_Getter";

  /// Moved to [HtmlDocument].
  @DomName('Document.title')
  @DocsEditable
  void set $dom_title(String value) native "Document_title_Setter";

  /// Moved to [HtmlDocument].
  @DomName('Document.webkitFullscreenElement')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  Element get $dom_webkitFullscreenElement native "Document_webkitFullscreenElement_Getter";

  /// Moved to [HtmlDocument].
  @DomName('Document.webkitFullscreenEnabled')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  bool get $dom_webkitFullscreenEnabled native "Document_webkitFullscreenEnabled_Getter";

  /// Moved to [HtmlDocument].
  @DomName('Document.webkitHidden')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  bool get $dom_webkitHidden native "Document_webkitHidden_Getter";

  /// Moved to [HtmlDocument].
  @DomName('Document.webkitIsFullScreen')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  bool get $dom_webkitIsFullScreen native "Document_webkitIsFullScreen_Getter";

  /// Moved to [HtmlDocument].
  @DomName('Document.webkitPointerLockElement')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  Element get $dom_webkitPointerLockElement native "Document_webkitPointerLockElement_Getter";

  @DomName('Document.webkitVisibilityState')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  String get $dom_webkitVisibilityState native "Document_webkitVisibilityState_Getter";

  /// Use the [Range] constructor instead.
  @DomName('Document.caretRangeFromPoint')
  @DocsEditable
  Range $dom_caretRangeFromPoint(int x, int y) native "Document_caretRangeFromPoint_Callback";

  @DomName('Document.createCDATASection')
  @DocsEditable
  CDataSection createCDataSection(String data) native "Document_createCDATASection_Callback";

  @DomName('Document.createDocumentFragment')
  @DocsEditable
  DocumentFragment createDocumentFragment() native "Document_createDocumentFragment_Callback";

  Element $dom_createElement(String localName_OR_tagName, [String typeExtension]) {
    if ((localName_OR_tagName is String || localName_OR_tagName == null) && !?typeExtension) {
      return _createElement_1(localName_OR_tagName);
    }
    if ((localName_OR_tagName is String || localName_OR_tagName == null) && (typeExtension is String || typeExtension == null)) {
      return _createElement_2(localName_OR_tagName, typeExtension);
    }
    throw new ArgumentError("Incorrect number or type of arguments");
  }

  Element _createElement_1(localName_OR_tagName) native "Document__createElement_1_Callback";

  Element _createElement_2(localName_OR_tagName, typeExtension) native "Document__createElement_2_Callback";

  Element $dom_createElementNS(String namespaceURI, String qualifiedName, [String typeExtension]) {
    if ((namespaceURI is String || namespaceURI == null) && (qualifiedName is String || qualifiedName == null) && !?typeExtension) {
      return _createElementNS_1(namespaceURI, qualifiedName);
    }
    if ((namespaceURI is String || namespaceURI == null) && (qualifiedName is String || qualifiedName == null) && (typeExtension is String || typeExtension == null)) {
      return _createElementNS_2(namespaceURI, qualifiedName, typeExtension);
    }
    throw new ArgumentError("Incorrect number or type of arguments");
  }

  Element _createElementNS_1(namespaceURI, qualifiedName) native "Document__createElementNS_1_Callback";

  Element _createElementNS_2(namespaceURI, qualifiedName, typeExtension) native "Document__createElementNS_2_Callback";

  @DomName('Document.createEvent')
  @DocsEditable
  Event $dom_createEvent(String eventType) native "Document_createEvent_Callback";

  @DomName('Document.createNodeIterator')
  @DocsEditable
  NodeIterator $dom_createNodeIterator(Node root, int whatToShow, NodeFilter filter, bool expandEntityReferences) native "Document_createNodeIterator_Callback";

  @DomName('Document.createRange')
  @DocsEditable
  Range $dom_createRange() native "Document_createRange_Callback";

  @DomName('Document.createTextNode')
  @DocsEditable
  Text $dom_createTextNode(String data) native "Document_createTextNode_Callback";

  @DomName('Document.createTouch')
  @DocsEditable
  Touch $dom_createTouch(Window window, EventTarget target, int identifier, int pageX, int pageY, int screenX, int screenY, int webkitRadiusX, int webkitRadiusY, num webkitRotationAngle, num webkitForce) native "Document_createTouch_Callback";

  /// Use the [TouchList] constructor instead.
  @DomName('Document.createTouchList')
  @DocsEditable
  TouchList $dom_createTouchList() native "Document_createTouchList_Callback";

  @DomName('Document.createTreeWalker')
  @DocsEditable
  TreeWalker $dom_createTreeWalker(Node root, int whatToShow, NodeFilter filter, bool expandEntityReferences) native "Document_createTreeWalker_Callback";

  @DomName('Document.elementFromPoint')
  @DocsEditable
  Element $dom_elementFromPoint(int x, int y) native "Document_elementFromPoint_Callback";

  @DomName('Document.execCommand')
  @DocsEditable
  bool execCommand(String command, bool userInterface, String value) native "Document_execCommand_Callback";

  /// Moved to [HtmlDocument].
  @DomName('Document.getCSSCanvasContext')
  @DocsEditable
  CanvasRenderingContext $dom_getCssCanvasContext(String contextId, String name, int width, int height) native "Document_getCSSCanvasContext_Callback";

  @DomName('Document.getElementById')
  @DocsEditable
  Element getElementById(String elementId) native "Document_getElementById_Callback";

  @DomName('Document.getElementsByClassName')
  @DocsEditable
  List<Node> getElementsByClassName(String tagname) native "Document_getElementsByClassName_Callback";

  @DomName('Document.getElementsByName')
  @DocsEditable
  List<Node> getElementsByName(String elementName) native "Document_getElementsByName_Callback";

  @DomName('Document.getElementsByTagName')
  @DocsEditable
  List<Node> getElementsByTagName(String tagname) native "Document_getElementsByTagName_Callback";

  @DomName('Document.queryCommandEnabled')
  @DocsEditable
  bool queryCommandEnabled(String command) native "Document_queryCommandEnabled_Callback";

  @DomName('Document.queryCommandIndeterm')
  @DocsEditable
  bool queryCommandIndeterm(String command) native "Document_queryCommandIndeterm_Callback";

  @DomName('Document.queryCommandState')
  @DocsEditable
  bool queryCommandState(String command) native "Document_queryCommandState_Callback";

  @DomName('Document.queryCommandSupported')
  @DocsEditable
  bool queryCommandSupported(String command) native "Document_queryCommandSupported_Callback";

  @DomName('Document.queryCommandValue')
  @DocsEditable
  String queryCommandValue(String command) native "Document_queryCommandValue_Callback";

  /**
 * Finds the first descendant element of this document that matches the
 * specified group of selectors.
 *
 * Unless your webpage contains multiple documents, the top-level query
 * method behaves the same as this method, so you should use it instead to
 * save typing a few characters.
 *
 * [selectors] should be a string using CSS selector syntax.
 *     var element1 = document.query('.className');
 *     var element2 = document.query('#id');
 *
 * For details about CSS selector syntax, see the
 * [CSS selector specification](http://www.w3.org/TR/css3-selectors/).
 */
  @DomName('Document.querySelector')
  @DocsEditable
  Element query(String selectors) native "Document_querySelector_Callback";

  /// Deprecated: use query("#$elementId") instead.
  @DomName('Document.querySelectorAll')
  @DocsEditable
  List<Node> $dom_querySelectorAll(String selectors) native "Document_querySelectorAll_Callback";

  /// Moved to [HtmlDocument].
  @DomName('Document.webkitCancelFullScreen')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void $dom_webkitCancelFullScreen() native "Document_webkitCancelFullScreen_Callback";

  /// Moved to [HtmlDocument].
  @DomName('Document.webkitExitFullscreen')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void $dom_webkitExitFullscreen() native "Document_webkitExitFullscreen_Callback";

  /// Moved to [HtmlDocument].
  @DomName('Document.webkitExitPointerLock')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void $dom_webkitExitPointerLock() native "Document_webkitExitPointerLock_Callback";

  @DomName('Document.webkitGetNamedFlows')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  NamedFlowCollection getNamedFlows() native "Document_webkitGetNamedFlows_Callback";

  @DomName('Document.webkitRegister')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  CustomElementConstructor register(String name, [Map options]) native "Document_webkitRegister_Callback";

  @DomName('Document.onabort')
  @DocsEditable
  Stream<Event> get onAbort => Element.abortEvent.forTarget(this);

  @DomName('Document.onbeforecopy')
  @DocsEditable
  Stream<Event> get onBeforeCopy => Element.beforeCopyEvent.forTarget(this);

  @DomName('Document.onbeforecut')
  @DocsEditable
  Stream<Event> get onBeforeCut => Element.beforeCutEvent.forTarget(this);

  @DomName('Document.onbeforepaste')
  @DocsEditable
  Stream<Event> get onBeforePaste => Element.beforePasteEvent.forTarget(this);

  @DomName('Document.onblur')
  @DocsEditable
  Stream<Event> get onBlur => Element.blurEvent.forTarget(this);

  @DomName('Document.onchange')
  @DocsEditable
  Stream<Event> get onChange => Element.changeEvent.forTarget(this);

  @DomName('Document.onclick')
  @DocsEditable
  Stream<MouseEvent> get onClick => Element.clickEvent.forTarget(this);

  @DomName('Document.oncontextmenu')
  @DocsEditable
  Stream<MouseEvent> get onContextMenu => Element.contextMenuEvent.forTarget(this);

  @DomName('Document.oncopy')
  @DocsEditable
  Stream<Event> get onCopy => Element.copyEvent.forTarget(this);

  @DomName('Document.oncut')
  @DocsEditable
  Stream<Event> get onCut => Element.cutEvent.forTarget(this);

  @DomName('Document.ondblclick')
  @DocsEditable
  Stream<Event> get onDoubleClick => Element.doubleClickEvent.forTarget(this);

  @DomName('Document.ondrag')
  @DocsEditable
  Stream<MouseEvent> get onDrag => Element.dragEvent.forTarget(this);

  @DomName('Document.ondragend')
  @DocsEditable
  Stream<MouseEvent> get onDragEnd => Element.dragEndEvent.forTarget(this);

  @DomName('Document.ondragenter')
  @DocsEditable
  Stream<MouseEvent> get onDragEnter => Element.dragEnterEvent.forTarget(this);

  @DomName('Document.ondragleave')
  @DocsEditable
  Stream<MouseEvent> get onDragLeave => Element.dragLeaveEvent.forTarget(this);

  @DomName('Document.ondragover')
  @DocsEditable
  Stream<MouseEvent> get onDragOver => Element.dragOverEvent.forTarget(this);

  @DomName('Document.ondragstart')
  @DocsEditable
  Stream<MouseEvent> get onDragStart => Element.dragStartEvent.forTarget(this);

  @DomName('Document.ondrop')
  @DocsEditable
  Stream<MouseEvent> get onDrop => Element.dropEvent.forTarget(this);

  @DomName('Document.onerror')
  @DocsEditable
  Stream<Event> get onError => Element.errorEvent.forTarget(this);

  @DomName('Document.onfocus')
  @DocsEditable
  Stream<Event> get onFocus => Element.focusEvent.forTarget(this);

  @DomName('Document.oninput')
  @DocsEditable
  Stream<Event> get onInput => Element.inputEvent.forTarget(this);

  @DomName('Document.oninvalid')
  @DocsEditable
  Stream<Event> get onInvalid => Element.invalidEvent.forTarget(this);

  @DomName('Document.onkeydown')
  @DocsEditable
  Stream<KeyboardEvent> get onKeyDown => Element.keyDownEvent.forTarget(this);

  @DomName('Document.onkeypress')
  @DocsEditable
  Stream<KeyboardEvent> get onKeyPress => Element.keyPressEvent.forTarget(this);

  @DomName('Document.onkeyup')
  @DocsEditable
  Stream<KeyboardEvent> get onKeyUp => Element.keyUpEvent.forTarget(this);

  @DomName('Document.onload')
  @DocsEditable
  Stream<Event> get onLoad => Element.loadEvent.forTarget(this);

  @DomName('Document.onmousedown')
  @DocsEditable
  Stream<MouseEvent> get onMouseDown => Element.mouseDownEvent.forTarget(this);

  @DomName('Document.onmousemove')
  @DocsEditable
  Stream<MouseEvent> get onMouseMove => Element.mouseMoveEvent.forTarget(this);

  @DomName('Document.onmouseout')
  @DocsEditable
  Stream<MouseEvent> get onMouseOut => Element.mouseOutEvent.forTarget(this);

  @DomName('Document.onmouseover')
  @DocsEditable
  Stream<MouseEvent> get onMouseOver => Element.mouseOverEvent.forTarget(this);

  @DomName('Document.onmouseup')
  @DocsEditable
  Stream<MouseEvent> get onMouseUp => Element.mouseUpEvent.forTarget(this);

  @DomName('Document.onmousewheel')
  @DocsEditable
  Stream<WheelEvent> get onMouseWheel => Element.mouseWheelEvent.forTarget(this);

  @DomName('Document.onpaste')
  @DocsEditable
  Stream<Event> get onPaste => Element.pasteEvent.forTarget(this);

  @DomName('Document.onreadystatechange')
  @DocsEditable
  Stream<Event> get onReadyStateChange => readyStateChangeEvent.forTarget(this);

  @DomName('Document.onreset')
  @DocsEditable
  Stream<Event> get onReset => Element.resetEvent.forTarget(this);

  @DomName('Document.onscroll')
  @DocsEditable
  Stream<Event> get onScroll => Element.scrollEvent.forTarget(this);

  @DomName('Document.onsearch')
  @DocsEditable
  Stream<Event> get onSearch => Element.searchEvent.forTarget(this);

  @DomName('Document.onselect')
  @DocsEditable
  Stream<Event> get onSelect => Element.selectEvent.forTarget(this);

  @DomName('Document.onselectionchange')
  @DocsEditable
  Stream<Event> get onSelectionChange => selectionChangeEvent.forTarget(this);

  @DomName('Document.onselectstart')
  @DocsEditable
  Stream<Event> get onSelectStart => Element.selectStartEvent.forTarget(this);

  @DomName('Document.onsubmit')
  @DocsEditable
  Stream<Event> get onSubmit => Element.submitEvent.forTarget(this);

  @DomName('Document.ontouchcancel')
  @DocsEditable
  Stream<TouchEvent> get onTouchCancel => Element.touchCancelEvent.forTarget(this);

  @DomName('Document.ontouchend')
  @DocsEditable
  Stream<TouchEvent> get onTouchEnd => Element.touchEndEvent.forTarget(this);

  @DomName('Document.ontouchmove')
  @DocsEditable
  Stream<TouchEvent> get onTouchMove => Element.touchMoveEvent.forTarget(this);

  @DomName('Document.ontouchstart')
  @DocsEditable
  Stream<TouchEvent> get onTouchStart => Element.touchStartEvent.forTarget(this);

  @DomName('Document.onwebkitfullscreenchange')
  @DocsEditable
  Stream<Event> get onFullscreenChange => Element.fullscreenChangeEvent.forTarget(this);

  @DomName('Document.onwebkitfullscreenerror')
  @DocsEditable
  Stream<Event> get onFullscreenError => Element.fullscreenErrorEvent.forTarget(this);

  @DomName('Document.onwebkitpointerlockchange')
  @DocsEditable
  Stream<Event> get onPointerLockChange => pointerLockChangeEvent.forTarget(this);

  @DomName('Document.onwebkitpointerlockerror')
  @DocsEditable
  Stream<Event> get onPointerLockError => pointerLockErrorEvent.forTarget(this);


  /**
   * Finds all descendant elements of this document that match the specified
   * group of selectors.
   *
   * Unless your webpage contains multiple documents, the top-level queryAll
   * method behaves the same as this method, so you should use it instead to
   * save typing a few characters.
   *
   * [selectors] should be a string using CSS selector syntax.
   *     var items = document.queryAll('.itemClassName');
   *
   * For details about CSS selector syntax, see the
   * [CSS selector specification](http://www.w3.org/TR/css3-selectors/).
   */
  ElementList queryAll(String selectors) {
    return new _FrozenElementList._wrap($dom_querySelectorAll(selectors));
  }
}
// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('DocumentFragment')
class DocumentFragment extends Node {
  factory DocumentFragment() => _DocumentFragmentFactoryProvider.createDocumentFragment();

  factory DocumentFragment.html(String html) =>
      _DocumentFragmentFactoryProvider.createDocumentFragment_html(html);

  factory DocumentFragment.svg(String svgContent) =>
      _DocumentFragmentFactoryProvider.createDocumentFragment_svg(svgContent);

  List<Element> _children;

  List<Element> get children {
    if (_children == null) {
      _children = new FilteredElementList(this);
    }
    return _children;
  }

  void set children(List<Element> value) {
    // Copy list first since we don't want liveness during iteration.
    List copy = new List.from(value);
    var children = this.children;
    children.clear();
    children.addAll(copy);
  }

  Element query(String selectors) => $dom_querySelector(selectors);

  List<Element> queryAll(String selectors) =>
    new _FrozenElementList._wrap($dom_querySelectorAll(selectors));

  String get innerHtml {
    final e = new Element.tag("div");
    e.append(this.clone(true));
    return e.innerHtml;
  }

  // TODO(nweiz): Do we want to support some variant of innerHtml for XML and/or
  // SVG strings?
  void set innerHtml(String value) {
    this.nodes.clear();

    final e = new Element.tag("div");
    e.innerHtml = value;

    // Copy list first since we don't want liveness during iteration.
    List nodes = new List.from(e.nodes, growable: false);
    this.nodes.addAll(nodes);
  }

  /**
   * Adds the specified text as a text node after the last child of this
   * document fragment.
   */
  void appendText(String text) {
    this.append(new Text(text));
  }


  /**
   * Parses the specified text as HTML and adds the resulting node after the
   * last child of this document fragment.
   */
  void appendHtml(String text) {
    this.append(new DocumentFragment.html(text));
  }

  DocumentFragment.internal() : super.internal();

  @DomName('DocumentFragment.querySelector')
  @DocsEditable
  Element $dom_querySelector(String selectors) native "DocumentFragment_querySelector_Callback";

  @DomName('DocumentFragment.querySelectorAll')
  @DocsEditable
  List<Node> $dom_querySelectorAll(String selectors) native "DocumentFragment_querySelectorAll_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('DocumentType')
class DocumentType extends Node {
  DocumentType.internal() : super.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('DOMError')
class DomError extends NativeFieldWrapperClass1 {
  DomError.internal();

  @DomName('DOMError.name')
  @DocsEditable
  String get name native "DOMError_name_Getter";

}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('DOMException')
class DomException extends NativeFieldWrapperClass1 {

  static const String INDEX_SIZE = 'IndexSizeError';
  static const String HIERARCHY_REQUEST = 'HierarchyRequestError';
  static const String WRONG_DOCUMENT = 'WrongDocumentError';
  static const String INVALID_CHARACTER = 'InvalidCharacterError';
  static const String NO_MODIFICATION_ALLOWED = 'NoModificationAllowedError';
  static const String NOT_FOUND = 'NotFoundError';
  static const String NOT_SUPPORTED = 'NotSupportedError';
  static const String INVALID_STATE = 'InvalidStateError';
  static const String SYNTAX = 'SyntaxError';
  static const String INVALID_MODIFICATION = 'InvalidModificationError';
  static const String NAMESPACE = 'NamespaceError';
  static const String INVALID_ACCESS = 'InvalidAccessError';
  static const String TYPE_MISMATCH = 'TypeMismatchError';
  static const String SECURITY = 'SecurityError';
  static const String NETWORK = 'NetworkError';
  static const String ABORT = 'AbortError';
  static const String URL_MISMATCH = 'URLMismatchError';
  static const String QUOTA_EXCEEDED = 'QuotaExceededError';
  static const String TIMEOUT = 'TimeoutError';
  static const String INVALID_NODE_TYPE = 'InvalidNodeTypeError';
  static const String DATA_CLONE = 'DataCloneError';

  DomException.internal();

  @DomName('DOMException.message')
  @DocsEditable
  String get message native "DOMCoreException_message_Getter";

  @DomName('DOMException.name')
  @DocsEditable
  String get name native "DOMCoreException_name_Getter";

  @DomName('DOMException.toString')
  @DocsEditable
  String toString() native "DOMCoreException_toString_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('DOMImplementation')
class DomImplementation extends NativeFieldWrapperClass1 {
  DomImplementation.internal();

  @DomName('DOMImplementation.createCSSStyleSheet')
  @DocsEditable
  CssStyleSheet createCssStyleSheet(String title, String media) native "DOMImplementation_createCSSStyleSheet_Callback";

  @DomName('DOMImplementation.createDocument')
  @DocsEditable
  Document createDocument(String namespaceURI, String qualifiedName, DocumentType doctype) native "DOMImplementation_createDocument_Callback";

  @DomName('DOMImplementation.createDocumentType')
  @DocsEditable
  DocumentType createDocumentType(String qualifiedName, String publicId, String systemId) native "DOMImplementation_createDocumentType_Callback";

  @DomName('DOMImplementation.createHTMLDocument')
  @DocsEditable
  HtmlDocument createHtmlDocument(String title) native "DOMImplementation_createHTMLDocument_Callback";

  @DomName('DOMImplementation.hasFeature')
  @DocsEditable
  bool hasFeature(String feature, String version) native "DOMImplementation_hasFeature_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('DOMParser')
class DomParser extends NativeFieldWrapperClass1 {
  DomParser.internal();

  @DomName('DOMParser.DOMParser')
  @DocsEditable
  factory DomParser() {
    return DomParser._create_1();
  }

  @DocsEditable
  static DomParser _create_1() native "DOMParser__create_1constructorCallback";

  @DomName('DOMParser.parseFromString')
  @DocsEditable
  Document parseFromString(String str, String contentType) native "DOMParser_parseFromString_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('DOMSettableTokenList')
class DomSettableTokenList extends DomTokenList {
  DomSettableTokenList.internal() : super.internal();

  @DomName('DOMSettableTokenList.value')
  @DocsEditable
  String get value native "DOMSettableTokenList_value_Getter";

  @DomName('DOMSettableTokenList.value')
  @DocsEditable
  void set value(String value) native "DOMSettableTokenList_value_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('DOMStringList')
class DomStringList extends NativeFieldWrapperClass1 with ListMixin<String>, ImmutableListMixin<String> implements List<String> {
  DomStringList.internal();

  @DomName('DOMStringList.length')
  @DocsEditable
  int get length native "DOMStringList_length_Getter";

  String operator[](int index) {
    if (index < 0 || index >= length)
      throw new RangeError.range(index, 0, length);
    return _nativeIndexedGetter(index);
  }
  String _nativeIndexedGetter(int index) native "DOMStringList_item_Callback";

  void operator[]=(int index, String value) {
    throw new UnsupportedError("Cannot assign element of immutable List.");
  }
  // -- start List<String> mixins.
  // String is the element type.


  void set length(int value) {
    throw new UnsupportedError("Cannot resize immutable List.");
  }

  String get first {
    if (this.length > 0) {
      return this[0];
    }
    throw new StateError("No elements");
  }

  String get last {
    int len = this.length;
    if (len > 0) {
      return this[len - 1];
    }
    throw new StateError("No elements");
  }

  String get single {
    int len = this.length;
    if (len == 1) {
      return this[0];
    }
    if (len == 0) throw new StateError("No elements");
    throw new StateError("More than one element");
  }

  String elementAt(int index) => this[index];
  // -- end List<String> mixins.

  @DomName('DOMStringList.contains')
  @DocsEditable
  bool contains(String string) native "DOMStringList_contains_Callback";

  @DomName('DOMStringList.item')
  @DocsEditable
  String item(int index) native "DOMStringList_item_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('DOMStringMap')
class DomStringMap extends NativeFieldWrapperClass1 {
  DomStringMap.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('DOMTokenList')
class DomTokenList extends NativeFieldWrapperClass1 {
  DomTokenList.internal();

  @DomName('DOMTokenList.length')
  @DocsEditable
  int get length native "DOMTokenList_length_Getter";

  @DomName('DOMTokenList.contains')
  @DocsEditable
  bool contains(String token) native "DOMTokenList_contains_Callback";

  @DomName('DOMTokenList.item')
  @DocsEditable
  String item(int index) native "DOMTokenList_item_Callback";

  @DomName('DOMTokenList.toString')
  @DocsEditable
  String toString() native "DOMTokenList_toString_Callback";

  bool toggle(String token, [bool force]) {
    if (?force) {
      return _toggle_1(token, force);
    }
    return _toggle_2(token);
  }

  bool _toggle_1(token, force) native "DOMTokenList__toggle_1_Callback";

  bool _toggle_2(token) native "DOMTokenList__toggle_2_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


class _ChildrenElementList extends ListBase<Element> {
  // Raw Element.
  final Element _element;
  final HtmlCollection _childElements;

  _ChildrenElementList._wrap(Element element)
    : _childElements = element.$dom_children,
      _element = element;

  bool contains(Element element) => _childElements.contains(element);


  bool get isEmpty {
    return _element.$dom_firstElementChild == null;
  }

  int get length {
    return _childElements.length;
  }

  Element operator [](int index) {
    return _childElements[index];
  }

  void operator []=(int index, Element value) {
    _element.$dom_replaceChild(value, _childElements[index]);
  }

  void set length(int newLength) {
    // TODO(jacobr): remove children when length is reduced.
    throw new UnsupportedError('Cannot resize element lists');
  }

  Element add(Element value) {
    _element.append(value);
    return value;
  }

  Iterator<Element> get iterator => toList().iterator;

  void addAll(Iterable<Element> iterable) {
    if (iterable is _ChildNodeListLazy) {
      iterable = new List.from(iterable);
    }

    for (Element element in iterable) {
      _element.append(element);
    }
  }

  void sort([int compare(Element a, Element b)]) {
    throw new UnsupportedError('Cannot sort element lists');
  }

  void setRange(int start, int end, Iterable<Element> iterable,
                [int skipCount = 0]) {
    throw new UnimplementedError();
  }

  void replaceRange(int start, int end, Iterable<Element> iterable) {
    throw new UnimplementedError();
  }

  void fillRange(int start, int end, [Element fillValue]) {
    throw new UnimplementedError();
  }

  bool remove(Object object) {
    if (object is Element) {
      Element element = object;
      if (identical(element.parentNode, _element)) {
        _element.$dom_removeChild(element);
        return true;
      }
    }
    return false;
  }

  void insert(int index, Element element) {
    if (index < 0 || index > length) {
      throw new RangeError.range(index, 0, length);
    }
    if (index == length) {
      _element.append(element);
    } else {
      _element.insertBefore(element, this[index]);
    }
  }

  void setAll(int index, Iterable<Element> iterable) {
    throw new UnimplementedError();
  }

  void clear() {
    // It is unclear if we want to keep non element nodes?
    _element.text = '';
  }

  Element removeAt(int index) {
    final result = this[index];
    if (result != null) {
      _element.$dom_removeChild(result);
    }
    return result;
  }

  Element removeLast() {
    final result = this.last;
    if (result != null) {
      _element.$dom_removeChild(result);
    }
    return result;
  }

  Element get first {
    Element result = _element.$dom_firstElementChild;
    if (result == null) throw new StateError("No elements");
    return result;
  }


  Element get last {
    Element result = _element.$dom_lastElementChild;
    if (result == null) throw new StateError("No elements");
    return result;
  }

  Element get single {
    if (length > 1) throw new StateError("More than one element");
    return first;
  }
}

/**
 * An immutable list containing HTML elements. This list contains some
 * additional methods for ease of CSS manipulation on a group of elements.
 */
abstract class ElementList<T extends Element> extends ListBase<T> {
  /**
   * The union of all CSS classes applied to the elements in this list.
   *
   * This set makes it easy to add, remove or toggle (add if not present, remove
   * if present) the classes applied to a collection of elements.
   *
   *     htmlList.classes.add('selected');
   *     htmlList.classes.toggle('isOnline');
   *     htmlList.classes.remove('selected');
   */
  CssClassSet get classes;

  /** Replace the classes with `value` for every element in this list. */
  set classes(Iterable<String> value);
}

// TODO(jacobr): this is an inefficient implementation but it is hard to see
// a better option given that we cannot quite force NodeList to be an
// ElementList as there are valid cases where a NodeList JavaScript object
// contains Node objects that are not Elements.
class _FrozenElementList<T extends Element> extends ListBase<T> implements ElementList {
  final List<Node> _nodeList;

  _FrozenElementList._wrap(this._nodeList);

  int get length => _nodeList.length;

  Element operator [](int index) => _nodeList[index];

  void operator []=(int index, Element value) {
    throw new UnsupportedError('Cannot modify list');
  }

  void set length(int newLength) {
    throw new UnsupportedError('Cannot modify list');
  }

  void sort([Comparator<Element> compare]) {
    throw new UnsupportedError('Cannot sort list');
  }

  Element get first => _nodeList.first;

  Element get last => _nodeList.last;

  Element get single => _nodeList.single;

  CssClassSet get classes => new _MultiElementCssClassSet(
      _nodeList.where((e) => e is Element));

  void set classes(Iterable<String> value) {
    _nodeList.where((e) => e is Element).forEach((e) => e.classes = value);
  }
}

/**
 * An abstract class, which all HTML elements extend.
 */
@DomName('Element')
abstract class Element extends Node implements ElementTraversal {

  /**
   * Creates an HTML element from a valid fragment of HTML.
   *
   * The [html] fragment must represent valid HTML with a single element root,
   * which will be parsed and returned.
   *
   * Important: the contents of [html] should not contain any user-supplied
   * data. Without strict data validation it is impossible to prevent script
   * injection exploits.
   *
   * It is instead recommended that elements be constructed via [Element.tag]
   * and text be added via [text].
   *
   *     var element = new Element.html('<div class="foo">content</div>');
   */
  factory Element.html(String html) =>
      _ElementFactoryProvider.createElement_html(html);

  /**
   * Creates the HTML element specified by the tag name.
   *
   * This is similar to [Document.createElement].
   * [tag] should be a valid HTML tag name. If [tag] is an unknown tag then
   * this will create an [UnknownElement].
   *
   *     var divElement = new Element.tag('div');
   *     print(divElement is DivElement); // 'true'
   *     var myElement = new Element.tag('unknownTag');
   *     print(myElement is UnknownElement); // 'true'
   *
   * For standard elements it is more preferable to use the type constructors:
   *     var element = new DivElement();
   *
   * See also:
   *
   * * [isTagSupported]
   */
  factory Element.tag(String tag) =>
      _ElementFactoryProvider.createElement_tag(tag);

  /**
   * All attributes on this element.
   *
   * Any modifications to the attribute map will automatically be applied to
   * this element.
   *
   * This only includes attributes which are not in a namespace
   * (such as 'xlink:href'), additional attributes can be accessed via
   * [getNamespacedAttributes].
   */
  Map<String, String> get attributes => new _ElementAttributeMap(this);

  void set attributes(Map<String, String> value) {
    Map<String, String> attributes = this.attributes;
    attributes.clear();
    for (String key in value.keys) {
      attributes[key] = value[key];
    }
  }

  /**
   * List of the direct children of this element.
   *
   * This collection can be used to add and remove elements from the document.
   *
   *     var item = new DivElement();
   *     item.text = 'Something';
   *     document.body.children.add(item) // Item is now displayed on the page.
   *     for (var element in document.body.children) {
   *       element.style.background = 'red'; // Turns every child of body red.
   *     }
   */
  List<Element> get children => new _ChildrenElementList._wrap(this);

  void set children(List<Element> value) {
    // Copy list first since we don't want liveness during iteration.
    List copy = new List.from(value);
    var children = this.children;
    children.clear();
    children.addAll(copy);
  }

  /**
   * Finds all descendent elements of this element that match the specified
   * group of selectors.
   *
   * [selectors] should be a string using CSS selector syntax.
   *
   *     var items = element.query('.itemClassName');
   */
  ElementList queryAll(String selectors) =>
    new _FrozenElementList._wrap($dom_querySelectorAll(selectors));

  /**
   * The set of CSS classes applied to this element.
   *
   * This set makes it easy to add, remove or toggle the classes applied to
   * this element.
   *
   *     element.classes.add('selected');
   *     element.classes.toggle('isOnline');
   *     element.classes.remove('selected');
   */
  CssClassSet get classes => new _ElementCssClassSet(this);

  void set classes(Iterable<String> value) {
    CssClassSet classSet = classes;
    classSet.clear();
    classSet.addAll(value);
  }

  /**
   * Allows access to all custom data attributes (data-*) set on this element.
   *
   * The keys for the map must follow these rules:
   *
   * * The name must not begin with 'xml'.
   * * The name cannot contain a semi-colon (';').
   * * The name cannot contain any capital letters.
   *
   * Any keys from markup will be converted to camel-cased keys in the map.
   *
   * For example, HTML specified as:
   *
   *     <div data-my-random-value='value'></div>
   *
   * Would be accessed in Dart as:
   *
   *     var value = element.dataset['myRandomValue'];
   *
   * See also:
   *
   * * [Custom data attributes](http://www.w3.org/TR/html5/global-attributes.html#custom-data-attribute)
   */
  Map<String, String> get dataset =>
    new _DataAttributeMap(attributes);

  void set dataset(Map<String, String> value) {
    final data = this.dataset;
    data.clear();
    for (String key in value.keys) {
      data[key] = value[key];
    }
  }

  /**
   * Gets a map for manipulating the attributes of a particular namespace.
   *
   * This is primarily useful for SVG attributes such as xref:link.
   */
  Map<String, String> getNamespacedAttributes(String namespace) {
    return new _NamespacedAttributeMap(this, namespace);
  }

  /**
   * The set of all CSS values applied to this element, including inherited
   * and default values.
   *
   * The computedStyle contains values that are inherited from other
   * sources, such as parent elements or stylesheets. This differs from the
   * [style] property, which contains only the values specified directly on this
   * element.
   *
   * PseudoElement can be values such as `::after`, `::before`, `::marker`,
   * `::line-marker`.
   *
   * See also:
   *
   * * [CSS Inheritance and Cascade](http://docs.webplatform.org/wiki/tutorials/inheritance_and_cascade)
   * * [Pseudo-elements](http://docs.webplatform.org/wiki/css/selectors/pseudo-elements)
   */
  CssStyleDeclaration getComputedStyle([String pseudoElement]) {
    if (pseudoElement == null) {
      pseudoElement = '';
    }
    // TODO(jacobr): last param should be null, see b/5045788
    return window.$dom_getComputedStyle(this, pseudoElement);
  }

  /**
   * Gets the position of this element relative to the client area of the page.
   */
  Rect get client => new Rect(clientLeft, clientTop, clientWidth, clientHeight);

  /**
   * Gets the offset of this element relative to its offsetParent.
   */
  Rect get offset => new Rect(offsetLeft, offsetTop, offsetWidth, offsetHeight);

  /**
   * Adds the specified text as a text node after the last child of this
   * element.
   */
  void appendText(String text) {
    this.insertAdjacentText('beforeend', text);
  }

  /**
   * Parses the specified text as HTML and adds the resulting node after the
   * last child of this element.
   */
  void appendHtml(String text) {
    this.insertAdjacentHtml('beforeend', text);
  }

  /**
   * Checks to see if the tag name is supported by the current platform.
   *
   * The tag should be a valid HTML tag name.
   */
  static bool isTagSupported(String tag) {
    var e = _ElementFactoryProvider.createElement_tag(tag);
    return e is Element && !(e is UnknownElement);
  }

  /**
   * Called by the DOM when this element has been instantiated.
   */
  @Experimental
  void onCreated() {}

  // Hooks to support custom WebComponents.

  Element _xtag;

  /**
   * Experimental support for [web components][wc]. This field stores a
   * reference to the component implementation. It was inspired by Mozilla's
   * [x-tags][] project. Please note: in the future it may be possible to
   * `extend Element` from your class, in which case this field will be
   * deprecated.
   *
   * If xtag has not been set, it will simply return `this` [Element].
   *
   * [wc]: http://dvcs.w3.org/hg/webcomponents/raw-file/tip/explainer/index.html
   * [x-tags]: http://x-tags.org/
   */
  Element get xtag => _xtag != null ? _xtag : this;

  void set xtag(Element value) {
    _xtag = value;
  }

  /**
   * Scrolls this element into view.
   *
   * Only one of of the alignment options may be specified at a time.
   *
   * If no options are specified then this will attempt to scroll the minimum
   * amount needed to bring the element into view.
   *
   * Note that alignCenter is currently only supported on WebKit platforms. If
   * alignCenter is specified but not supported then this will fall back to
   * alignTop.
   *
   * See also:
   *
   * * [scrollIntoView](http://docs.webplatform.org/wiki/dom/methods/scrollIntoView)
   * * [scrollIntoViewIfNeeded](http://docs.webplatform.org/wiki/dom/methods/scrollIntoViewIfNeeded)
   */
  void scrollIntoView([ScrollAlignment alignment]) {
    var hasScrollIntoViewIfNeeded = false;
    if (alignment == ScrollAlignment.TOP) {
      this.$dom_scrollIntoView(true);
    } else if (alignment == ScrollAlignment.BOTTOM) {
      this.$dom_scrollIntoView(false);
    } else if (hasScrollIntoViewIfNeeded) {
      if (alignment == ScrollAlignment.CENTER) {
        this.$dom_scrollIntoViewIfNeeded(true);
      } else {
        this.$dom_scrollIntoViewIfNeeded();
      }
    } else {
      this.$dom_scrollIntoView();
    }
  }


  @Creates('Null')
  Map<String, StreamSubscription> _attributeBindings;

  // TODO(jmesserly): I'm concerned about adding these to every element.
  // Conceptually all of these belong on TemplateElement. They are here to
  // support browsers that don't have <template> yet.
  // However even in the polyfill they're restricted to certain tags
  // (see [isTemplate]). So we can probably convert it to a (public) mixin, and
  // only mix it in to the elements that need it.
  var _model;

  _TemplateIterator _templateIterator;

  Element _templateInstanceRef;

  // Note: only used if `this is! TemplateElement`
  DocumentFragment _templateContent;

  bool _templateIsDecorated;

  // TODO(jmesserly): should path be optional, and default to empty path?
  // It is used that way in at least one path in JS TemplateElement tests
  // (see "BindImperative" test in original JS code).
  @Experimental
  void bind(String name, model, String path) {
    _bindElement(this, name, model, path);
  }

  // TODO(jmesserly): this is static to work around http://dartbug.com/10166
  // Similar issue for unbind/unbindAll below.
  static void _bindElement(Element self, String name, model, String path) {
    if (self._bindTemplate(name, model, path)) return;

    if (self._attributeBindings == null) {
      self._attributeBindings = new Map<String, StreamSubscription>();
    }

    self.xtag.attributes.remove(name);

    var changed;
    if (name.endsWith('?')) {
      name = name.substring(0, name.length - 1);

      changed = (value) {
        if (_Bindings._toBoolean(value)) {
          self.xtag.attributes[name] = '';
        } else {
          self.xtag.attributes.remove(name);
        }
      };
    } else {
      changed = (value) {
        // TODO(jmesserly): escape value if needed to protect against XSS.
        // See https://github.com/toolkitchen/mdv/issues/58
        self.xtag.attributes[name] = value == null ? '' : '$value';
      };
    }

    self.unbind(name);

    self._attributeBindings[name] =
        new PathObserver(model, path).bindSync(changed);
  }

  @Experimental
  void unbind(String name) {
    _unbindElement(this, name);
  }

  static _unbindElement(Element self, String name) {
    if (self._unbindTemplate(name)) return;
    if (self._attributeBindings != null) {
      var binding = self._attributeBindings.remove(name);
      if (binding != null) binding.cancel();
    }
  }

  @Experimental
  void unbindAll() {
    _unbindAllElement(this);
  }

  static void _unbindAllElement(Element self) {
    self._unbindAllTemplate();

    if (self._attributeBindings != null) {
      for (var binding in self._attributeBindings.values) {
        binding.cancel();
      }
      self._attributeBindings = null;
    }
  }

  // TODO(jmesserly): unlike the JS polyfill, we can't mixin
  // HTMLTemplateElement at runtime into things that are semantically template
  // elements. So instead we implement it here with a runtime check.
  // If the bind succeeds, we return true, otherwise we return false and let
  // the normal Element.bind logic kick in.
  bool _bindTemplate(String name, model, String path) {
    if (isTemplate) {
      switch (name) {
        case 'bind':
        case 'repeat':
        case 'if':
          _ensureTemplate();
          if (_templateIterator == null) {
            _templateIterator = new _TemplateIterator(this);
          }
          _templateIterator.inputs.bind(name, model, path);
          return true;
      }
    }
    return false;
  }

  bool _unbindTemplate(String name) {
    if (isTemplate) {
      switch (name) {
        case 'bind':
        case 'repeat':
        case 'if':
          _ensureTemplate();
          if (_templateIterator != null) {
            _templateIterator.inputs.unbind(name);
          }
          return true;
      }
    }
    return false;
  }

  void _unbindAllTemplate() {
    if (isTemplate) {
      unbind('bind');
      unbind('repeat');
      unbind('if');
    }
  }

  /**
   * Gets the template this node refers to.
   * This is only supported if [isTemplate] is true.
   */
  @Experimental
  Element get ref {
    _ensureTemplate();

    Element ref = null;
    var refId = attributes['ref'];
    if (refId != null) {
      ref = document.getElementById(refId);
    }

    return ref != null ? ref : _templateInstanceRef;
  }

  /**
   * Gets the content of this template.
   * This is only supported if [isTemplate] is true.
   */
  @Experimental
  DocumentFragment get content {
    _ensureTemplate();
    return _templateContent;
  }

  /**
   * Creates an instance of the template.
   * This is only supported if [isTemplate] is true.
   */
  @Experimental
  DocumentFragment createInstance() {
    _ensureTemplate();

    var template = ref;
    if (template == null) template = this;

    var instance = _Bindings._createDeepCloneAndDecorateTemplates(
        template.content, attributes['syntax']);

    if (TemplateElement._instanceCreated != null) {
      TemplateElement._instanceCreated.add(instance);
    }
    return instance;
  }

  /**
   * The data model which is inherited through the tree.
   * This is only supported if [isTemplate] is true.
   *
   * Setting this will destructive propagate the value to all descendant nodes,
   * and reinstantiate all of the nodes expanded by this template.
   *
   * Currently this does not support propagation through Shadow DOMs.
   */
  @Experimental
  get model => _model;

  @Experimental
  void set model(value) {
    _ensureTemplate();

    var syntax = TemplateElement.syntax[attributes['syntax']];
    _model = value;
    _Bindings._addBindings(this, model, syntax);
  }

  // TODO(jmesserly): const set would be better
  static const _TABLE_TAGS = const {
    'caption': null,
    'col': null,
    'colgroup': null,
    'tbody': null,
    'td': null,
    'tfoot': null,
    'th': null,
    'thead': null,
    'tr': null,
  };

  bool get _isAttributeTemplate => attributes.containsKey('template') &&
      (localName == 'option' || _TABLE_TAGS.containsKey(localName));

  /**
   * Returns true if this node is a template.
   *
   * A node is a template if [tagName] is TEMPLATE, or the node has the
   * 'template' attribute and this tag supports attribute form for backwards
   * compatibility with existing HTML parsers. The nodes that can use attribute
   * form are table elments (THEAD, TBODY, TFOOT, TH, TR, TD, CAPTION, COLGROUP
   * and COL) and OPTION.
   */
  // TODO(jmesserly): this is not a public MDV API, but it seems like a useful
  // place to document which tags our polyfill considers to be templates.
  // Otherwise I'd be repeating it in several other places.
  // See if we can replace this with a TemplateMixin.
  @Experimental
  bool get isTemplate => tagName == 'TEMPLATE' || _isAttributeTemplate;

  void _ensureTemplate() {
    if (!isTemplate) {
      throw new UnsupportedError('$this is not a template.');
    }
    TemplateElement.decorate(this);
  }

  Element.internal() : super.internal();

  @DomName('Element.abortEvent')
  @DocsEditable
  static const EventStreamProvider<Event> abortEvent = const EventStreamProvider<Event>('abort');

  @DomName('Element.beforecopyEvent')
  @DocsEditable
  static const EventStreamProvider<Event> beforeCopyEvent = const EventStreamProvider<Event>('beforecopy');

  @DomName('Element.beforecutEvent')
  @DocsEditable
  static const EventStreamProvider<Event> beforeCutEvent = const EventStreamProvider<Event>('beforecut');

  @DomName('Element.beforepasteEvent')
  @DocsEditable
  static const EventStreamProvider<Event> beforePasteEvent = const EventStreamProvider<Event>('beforepaste');

  @DomName('Element.blurEvent')
  @DocsEditable
  static const EventStreamProvider<Event> blurEvent = const EventStreamProvider<Event>('blur');

  @DomName('Element.changeEvent')
  @DocsEditable
  static const EventStreamProvider<Event> changeEvent = const EventStreamProvider<Event>('change');

  @DomName('Element.clickEvent')
  @DocsEditable
  static const EventStreamProvider<MouseEvent> clickEvent = const EventStreamProvider<MouseEvent>('click');

  @DomName('Element.contextmenuEvent')
  @DocsEditable
  static const EventStreamProvider<MouseEvent> contextMenuEvent = const EventStreamProvider<MouseEvent>('contextmenu');

  @DomName('Element.copyEvent')
  @DocsEditable
  static const EventStreamProvider<Event> copyEvent = const EventStreamProvider<Event>('copy');

  @DomName('Element.cutEvent')
  @DocsEditable
  static const EventStreamProvider<Event> cutEvent = const EventStreamProvider<Event>('cut');

  @DomName('Element.dblclickEvent')
  @DocsEditable
  static const EventStreamProvider<Event> doubleClickEvent = const EventStreamProvider<Event>('dblclick');

  @DomName('Element.dragEvent')
  @DocsEditable
  static const EventStreamProvider<MouseEvent> dragEvent = const EventStreamProvider<MouseEvent>('drag');

  @DomName('Element.dragendEvent')
  @DocsEditable
  static const EventStreamProvider<MouseEvent> dragEndEvent = const EventStreamProvider<MouseEvent>('dragend');

  @DomName('Element.dragenterEvent')
  @DocsEditable
  static const EventStreamProvider<MouseEvent> dragEnterEvent = const EventStreamProvider<MouseEvent>('dragenter');

  @DomName('Element.dragleaveEvent')
  @DocsEditable
  static const EventStreamProvider<MouseEvent> dragLeaveEvent = const EventStreamProvider<MouseEvent>('dragleave');

  @DomName('Element.dragoverEvent')
  @DocsEditable
  static const EventStreamProvider<MouseEvent> dragOverEvent = const EventStreamProvider<MouseEvent>('dragover');

  @DomName('Element.dragstartEvent')
  @DocsEditable
  static const EventStreamProvider<MouseEvent> dragStartEvent = const EventStreamProvider<MouseEvent>('dragstart');

  @DomName('Element.dropEvent')
  @DocsEditable
  static const EventStreamProvider<MouseEvent> dropEvent = const EventStreamProvider<MouseEvent>('drop');

  @DomName('Element.errorEvent')
  @DocsEditable
  static const EventStreamProvider<Event> errorEvent = const EventStreamProvider<Event>('error');

  @DomName('Element.focusEvent')
  @DocsEditable
  static const EventStreamProvider<Event> focusEvent = const EventStreamProvider<Event>('focus');

  @DomName('Element.inputEvent')
  @DocsEditable
  static const EventStreamProvider<Event> inputEvent = const EventStreamProvider<Event>('input');

  @DomName('Element.invalidEvent')
  @DocsEditable
  static const EventStreamProvider<Event> invalidEvent = const EventStreamProvider<Event>('invalid');

  @DomName('Element.keydownEvent')
  @DocsEditable
  static const EventStreamProvider<KeyboardEvent> keyDownEvent = const EventStreamProvider<KeyboardEvent>('keydown');

  @DomName('Element.keypressEvent')
  @DocsEditable
  static const EventStreamProvider<KeyboardEvent> keyPressEvent = const EventStreamProvider<KeyboardEvent>('keypress');

  @DomName('Element.keyupEvent')
  @DocsEditable
  static const EventStreamProvider<KeyboardEvent> keyUpEvent = const EventStreamProvider<KeyboardEvent>('keyup');

  @DomName('Element.loadEvent')
  @DocsEditable
  static const EventStreamProvider<Event> loadEvent = const EventStreamProvider<Event>('load');

  @DomName('Element.mousedownEvent')
  @DocsEditable
  static const EventStreamProvider<MouseEvent> mouseDownEvent = const EventStreamProvider<MouseEvent>('mousedown');

  @DomName('Element.mousemoveEvent')
  @DocsEditable
  static const EventStreamProvider<MouseEvent> mouseMoveEvent = const EventStreamProvider<MouseEvent>('mousemove');

  @DomName('Element.mouseoutEvent')
  @DocsEditable
  static const EventStreamProvider<MouseEvent> mouseOutEvent = const EventStreamProvider<MouseEvent>('mouseout');

  @DomName('Element.mouseoverEvent')
  @DocsEditable
  static const EventStreamProvider<MouseEvent> mouseOverEvent = const EventStreamProvider<MouseEvent>('mouseover');

  @DomName('Element.mouseupEvent')
  @DocsEditable
  static const EventStreamProvider<MouseEvent> mouseUpEvent = const EventStreamProvider<MouseEvent>('mouseup');

  @DomName('Element.mousewheelEvent')
  @DocsEditable
  static const EventStreamProvider<WheelEvent> mouseWheelEvent = const EventStreamProvider<WheelEvent>('mousewheel');

  @DomName('Element.pasteEvent')
  @DocsEditable
  static const EventStreamProvider<Event> pasteEvent = const EventStreamProvider<Event>('paste');

  @DomName('Element.resetEvent')
  @DocsEditable
  static const EventStreamProvider<Event> resetEvent = const EventStreamProvider<Event>('reset');

  @DomName('Element.scrollEvent')
  @DocsEditable
  static const EventStreamProvider<Event> scrollEvent = const EventStreamProvider<Event>('scroll');

  @DomName('Element.searchEvent')
  @DocsEditable
  static const EventStreamProvider<Event> searchEvent = const EventStreamProvider<Event>('search');

  @DomName('Element.selectEvent')
  @DocsEditable
  static const EventStreamProvider<Event> selectEvent = const EventStreamProvider<Event>('select');

  @DomName('Element.selectstartEvent')
  @DocsEditable
  static const EventStreamProvider<Event> selectStartEvent = const EventStreamProvider<Event>('selectstart');

  @DomName('Element.submitEvent')
  @DocsEditable
  static const EventStreamProvider<Event> submitEvent = const EventStreamProvider<Event>('submit');

  @DomName('Element.touchcancelEvent')
  @DocsEditable
  static const EventStreamProvider<TouchEvent> touchCancelEvent = const EventStreamProvider<TouchEvent>('touchcancel');

  @DomName('Element.touchendEvent')
  @DocsEditable
  static const EventStreamProvider<TouchEvent> touchEndEvent = const EventStreamProvider<TouchEvent>('touchend');

  @DomName('Element.touchenterEvent')
  @DocsEditable
  static const EventStreamProvider<TouchEvent> touchEnterEvent = const EventStreamProvider<TouchEvent>('touchenter');

  @DomName('Element.touchleaveEvent')
  @DocsEditable
  static const EventStreamProvider<TouchEvent> touchLeaveEvent = const EventStreamProvider<TouchEvent>('touchleave');

  @DomName('Element.touchmoveEvent')
  @DocsEditable
  static const EventStreamProvider<TouchEvent> touchMoveEvent = const EventStreamProvider<TouchEvent>('touchmove');

  @DomName('Element.touchstartEvent')
  @DocsEditable
  static const EventStreamProvider<TouchEvent> touchStartEvent = const EventStreamProvider<TouchEvent>('touchstart');

  @DomName('Element.webkitTransitionEndEvent')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  static const EventStreamProvider<TransitionEvent> transitionEndEvent = const EventStreamProvider<TransitionEvent>('webkitTransitionEnd');

  @DomName('Element.webkitfullscreenchangeEvent')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  static const EventStreamProvider<Event> fullscreenChangeEvent = const EventStreamProvider<Event>('webkitfullscreenchange');

  @DomName('Element.webkitfullscreenerrorEvent')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  static const EventStreamProvider<Event> fullscreenErrorEvent = const EventStreamProvider<Event>('webkitfullscreenerror');

  HtmlCollection get $dom_children;

  String contentEditable;

  String dir;

  bool draggable;

  bool hidden;

  String id;

  String innerHtml;

  bool get isContentEditable;

  String lang;

  String get outerHtml;

  bool spellcheck;

  int tabIndex;

  String title;

  bool translate;

  String dropzone;

  void click();

  Element insertAdjacentElement(String where, Element element);

  void insertAdjacentHtml(String where, String html);

  void insertAdjacentText(String where, String text);

  @DomName('Element.ALLOW_KEYBOARD_INPUT')
  @DocsEditable
  static const int ALLOW_KEYBOARD_INPUT = 1;

  @DomName('Element.attributes')
  @DocsEditable
  _NamedNodeMap get $dom_attributes native "Element_attributes_Getter";

  @DomName('Element.childElementCount')
  @DocsEditable
  int get $dom_childElementCount native "Element_childElementCount_Getter";

  @DomName('Element.className')
  @DocsEditable
  String get $dom_className native "Element_className_Getter";

  @DomName('Element.className')
  @DocsEditable
  void set $dom_className(String value) native "Element_className_Setter";

  @DomName('Element.clientHeight')
  @DocsEditable
  int get clientHeight native "Element_clientHeight_Getter";

  @DomName('Element.clientLeft')
  @DocsEditable
  int get clientLeft native "Element_clientLeft_Getter";

  @DomName('Element.clientTop')
  @DocsEditable
  int get clientTop native "Element_clientTop_Getter";

  @DomName('Element.clientWidth')
  @DocsEditable
  int get clientWidth native "Element_clientWidth_Getter";

  @DomName('Element.firstElementChild')
  @DocsEditable
  Element get $dom_firstElementChild native "Element_firstElementChild_Getter";

  @DomName('Element.lastElementChild')
  @DocsEditable
  Element get $dom_lastElementChild native "Element_lastElementChild_Getter";

  @DomName('Element.nextElementSibling')
  @DocsEditable
  Element get nextElementSibling native "Element_nextElementSibling_Getter";

  @DomName('Element.offsetHeight')
  @DocsEditable
  int get offsetHeight native "Element_offsetHeight_Getter";

  @DomName('Element.offsetLeft')
  @DocsEditable
  int get offsetLeft native "Element_offsetLeft_Getter";

  @DomName('Element.offsetParent')
  @DocsEditable
  Element get offsetParent native "Element_offsetParent_Getter";

  @DomName('Element.offsetTop')
  @DocsEditable
  int get offsetTop native "Element_offsetTop_Getter";

  @DomName('Element.offsetWidth')
  @DocsEditable
  int get offsetWidth native "Element_offsetWidth_Getter";

  @DomName('Element.previousElementSibling')
  @DocsEditable
  Element get previousElementSibling native "Element_previousElementSibling_Getter";

  @DomName('Element.scrollHeight')
  @DocsEditable
  int get scrollHeight native "Element_scrollHeight_Getter";

  @DomName('Element.scrollLeft')
  @DocsEditable
  int get scrollLeft native "Element_scrollLeft_Getter";

  @DomName('Element.scrollLeft')
  @DocsEditable
  void set scrollLeft(int value) native "Element_scrollLeft_Setter";

  @DomName('Element.scrollTop')
  @DocsEditable
  int get scrollTop native "Element_scrollTop_Getter";

  @DomName('Element.scrollTop')
  @DocsEditable
  void set scrollTop(int value) native "Element_scrollTop_Setter";

  @DomName('Element.scrollWidth')
  @DocsEditable
  int get scrollWidth native "Element_scrollWidth_Getter";

  @DomName('Element.style')
  @DocsEditable
  CssStyleDeclaration get style native "Element_style_Getter";

  @DomName('Element.tagName')
  @DocsEditable
  String get tagName native "Element_tagName_Getter";

  @DomName('Element.webkitInsertionParent')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  Node get insertionParent native "Element_webkitInsertionParent_Getter";

  @DomName('Element.webkitPseudo')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  String get pseudo native "Element_webkitPseudo_Getter";

  @DomName('Element.webkitPseudo')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void set pseudo(String value) native "Element_webkitPseudo_Setter";

  @DomName('Element.webkitRegionOverset')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  String get regionOverset native "Element_webkitRegionOverset_Getter";

  @DomName('Element.webkitShadowRoot')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  ShadowRoot get shadowRoot native "Element_webkitShadowRoot_Getter";

  @DomName('Element.blur')
  @DocsEditable
  void blur() native "Element_blur_Callback";

  @DomName('Element.focus')
  @DocsEditable
  void focus() native "Element_focus_Callback";

  @DomName('Element.getAttribute')
  @DocsEditable
  String $dom_getAttribute(String name) native "Element_getAttribute_Callback";

  @DomName('Element.getAttributeNS')
  @DocsEditable
  String $dom_getAttributeNS(String namespaceURI, String localName) native "Element_getAttributeNS_Callback";

  @DomName('Element.getBoundingClientRect')
  @DocsEditable
  Rect getBoundingClientRect() native "Element_getBoundingClientRect_Callback";

  @DomName('Element.getClientRects')
  @DocsEditable
  List<Rect> getClientRects() native "Element_getClientRects_Callback";

  @DomName('Element.getElementsByClassName')
  @DocsEditable
  List<Node> getElementsByClassName(String name) native "Element_getElementsByClassName_Callback";

  @DomName('Element.getElementsByTagName')
  @DocsEditable
  List<Node> $dom_getElementsByTagName(String name) native "Element_getElementsByTagName_Callback";

  @DomName('Element.hasAttribute')
  @DocsEditable
  bool $dom_hasAttribute(String name) native "Element_hasAttribute_Callback";

  @DomName('Element.hasAttributeNS')
  @DocsEditable
  bool $dom_hasAttributeNS(String namespaceURI, String localName) native "Element_hasAttributeNS_Callback";

  /**
 * Finds the first descendant element of this element that matches the
 * specified group of selectors.
 *
 * [selectors] should be a string using CSS selector syntax.
 *
 *     // Gets the first descendant with the class 'classname'
 *     var element = element.query('.className');
 *     // Gets the element with id 'id'
 *     var element = element.query('#id');
 *     // Gets the first descendant [ImageElement]
 *     var img = element.query('img');
 *
 * See also:
 *
 * * [CSS Selectors](http://docs.webplatform.org/wiki/css/selectors)
 */
  @DomName('Element.querySelector')
  @DocsEditable
  Element query(String selectors) native "Element_querySelector_Callback";

  @DomName('Element.querySelectorAll')
  @DocsEditable
  List<Node> $dom_querySelectorAll(String selectors) native "Element_querySelectorAll_Callback";

  @DomName('Element.remove')
  @DocsEditable
  void remove() native "Element_remove_Callback";

  @DomName('Element.removeAttribute')
  @DocsEditable
  void $dom_removeAttribute(String name) native "Element_removeAttribute_Callback";

  @DomName('Element.removeAttributeNS')
  @DocsEditable
  void $dom_removeAttributeNS(String namespaceURI, String localName) native "Element_removeAttributeNS_Callback";

  @DomName('Element.scrollByLines')
  @DocsEditable
  void scrollByLines(int lines) native "Element_scrollByLines_Callback";

  @DomName('Element.scrollByPages')
  @DocsEditable
  void scrollByPages(int pages) native "Element_scrollByPages_Callback";

  void $dom_scrollIntoView([bool alignWithTop]) {
    if (?alignWithTop) {
      _scrollIntoView_1(alignWithTop);
      return;
    }
    _scrollIntoView_2();
    return;
  }

  void _scrollIntoView_1(alignWithTop) native "Element__scrollIntoView_1_Callback";

  void _scrollIntoView_2() native "Element__scrollIntoView_2_Callback";

  void $dom_scrollIntoViewIfNeeded([bool centerIfNeeded]) {
    if (?centerIfNeeded) {
      _scrollIntoViewIfNeeded_1(centerIfNeeded);
      return;
    }
    _scrollIntoViewIfNeeded_2();
    return;
  }

  void _scrollIntoViewIfNeeded_1(centerIfNeeded) native "Element__scrollIntoViewIfNeeded_1_Callback";

  void _scrollIntoViewIfNeeded_2() native "Element__scrollIntoViewIfNeeded_2_Callback";

  @DomName('Element.setAttribute')
  @DocsEditable
  void $dom_setAttribute(String name, String value) native "Element_setAttribute_Callback";

  @DomName('Element.setAttributeNS')
  @DocsEditable
  void $dom_setAttributeNS(String namespaceURI, String qualifiedName, String value) native "Element_setAttributeNS_Callback";

  @DomName('Element.webkitCreateShadowRoot')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME, '25')
  @Experimental
  ShadowRoot createShadowRoot() native "Element_webkitCreateShadowRoot_Callback";

  @DomName('Element.webkitGetRegionFlowRanges')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  List<Range> getRegionFlowRanges() native "Element_webkitGetRegionFlowRanges_Callback";

  @DomName('Element.webkitMatchesSelector')
  @DocsEditable
  @Experimental()
  bool matches(String selectors) native "Element_webkitMatchesSelector_Callback";

  @DomName('Element.webkitRequestFullScreen')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void requestFullScreen(int flags) native "Element_webkitRequestFullScreen_Callback";

  @DomName('Element.webkitRequestFullscreen')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void requestFullscreen() native "Element_webkitRequestFullscreen_Callback";

  @DomName('Element.webkitRequestPointerLock')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void requestPointerLock() native "Element_webkitRequestPointerLock_Callback";

  @DomName('Element.onabort')
  @DocsEditable
  Stream<Event> get onAbort => abortEvent.forTarget(this);

  @DomName('Element.onbeforecopy')
  @DocsEditable
  Stream<Event> get onBeforeCopy => beforeCopyEvent.forTarget(this);

  @DomName('Element.onbeforecut')
  @DocsEditable
  Stream<Event> get onBeforeCut => beforeCutEvent.forTarget(this);

  @DomName('Element.onbeforepaste')
  @DocsEditable
  Stream<Event> get onBeforePaste => beforePasteEvent.forTarget(this);

  @DomName('Element.onblur')
  @DocsEditable
  Stream<Event> get onBlur => blurEvent.forTarget(this);

  @DomName('Element.onchange')
  @DocsEditable
  Stream<Event> get onChange => changeEvent.forTarget(this);

  @DomName('Element.onclick')
  @DocsEditable
  Stream<MouseEvent> get onClick => clickEvent.forTarget(this);

  @DomName('Element.oncontextmenu')
  @DocsEditable
  Stream<MouseEvent> get onContextMenu => contextMenuEvent.forTarget(this);

  @DomName('Element.oncopy')
  @DocsEditable
  Stream<Event> get onCopy => copyEvent.forTarget(this);

  @DomName('Element.oncut')
  @DocsEditable
  Stream<Event> get onCut => cutEvent.forTarget(this);

  @DomName('Element.ondblclick')
  @DocsEditable
  Stream<Event> get onDoubleClick => doubleClickEvent.forTarget(this);

  @DomName('Element.ondrag')
  @DocsEditable
  Stream<MouseEvent> get onDrag => dragEvent.forTarget(this);

  @DomName('Element.ondragend')
  @DocsEditable
  Stream<MouseEvent> get onDragEnd => dragEndEvent.forTarget(this);

  @DomName('Element.ondragenter')
  @DocsEditable
  Stream<MouseEvent> get onDragEnter => dragEnterEvent.forTarget(this);

  @DomName('Element.ondragleave')
  @DocsEditable
  Stream<MouseEvent> get onDragLeave => dragLeaveEvent.forTarget(this);

  @DomName('Element.ondragover')
  @DocsEditable
  Stream<MouseEvent> get onDragOver => dragOverEvent.forTarget(this);

  @DomName('Element.ondragstart')
  @DocsEditable
  Stream<MouseEvent> get onDragStart => dragStartEvent.forTarget(this);

  @DomName('Element.ondrop')
  @DocsEditable
  Stream<MouseEvent> get onDrop => dropEvent.forTarget(this);

  @DomName('Element.onerror')
  @DocsEditable
  Stream<Event> get onError => errorEvent.forTarget(this);

  @DomName('Element.onfocus')
  @DocsEditable
  Stream<Event> get onFocus => focusEvent.forTarget(this);

  @DomName('Element.oninput')
  @DocsEditable
  Stream<Event> get onInput => inputEvent.forTarget(this);

  @DomName('Element.oninvalid')
  @DocsEditable
  Stream<Event> get onInvalid => invalidEvent.forTarget(this);

  @DomName('Element.onkeydown')
  @DocsEditable
  Stream<KeyboardEvent> get onKeyDown => keyDownEvent.forTarget(this);

  @DomName('Element.onkeypress')
  @DocsEditable
  Stream<KeyboardEvent> get onKeyPress => keyPressEvent.forTarget(this);

  @DomName('Element.onkeyup')
  @DocsEditable
  Stream<KeyboardEvent> get onKeyUp => keyUpEvent.forTarget(this);

  @DomName('Element.onload')
  @DocsEditable
  Stream<Event> get onLoad => loadEvent.forTarget(this);

  @DomName('Element.onmousedown')
  @DocsEditable
  Stream<MouseEvent> get onMouseDown => mouseDownEvent.forTarget(this);

  @DomName('Element.onmousemove')
  @DocsEditable
  Stream<MouseEvent> get onMouseMove => mouseMoveEvent.forTarget(this);

  @DomName('Element.onmouseout')
  @DocsEditable
  Stream<MouseEvent> get onMouseOut => mouseOutEvent.forTarget(this);

  @DomName('Element.onmouseover')
  @DocsEditable
  Stream<MouseEvent> get onMouseOver => mouseOverEvent.forTarget(this);

  @DomName('Element.onmouseup')
  @DocsEditable
  Stream<MouseEvent> get onMouseUp => mouseUpEvent.forTarget(this);

  @DomName('Element.onmousewheel')
  @DocsEditable
  Stream<WheelEvent> get onMouseWheel => mouseWheelEvent.forTarget(this);

  @DomName('Element.onpaste')
  @DocsEditable
  Stream<Event> get onPaste => pasteEvent.forTarget(this);

  @DomName('Element.onreset')
  @DocsEditable
  Stream<Event> get onReset => resetEvent.forTarget(this);

  @DomName('Element.onscroll')
  @DocsEditable
  Stream<Event> get onScroll => scrollEvent.forTarget(this);

  @DomName('Element.onsearch')
  @DocsEditable
  Stream<Event> get onSearch => searchEvent.forTarget(this);

  @DomName('Element.onselect')
  @DocsEditable
  Stream<Event> get onSelect => selectEvent.forTarget(this);

  @DomName('Element.onselectstart')
  @DocsEditable
  Stream<Event> get onSelectStart => selectStartEvent.forTarget(this);

  @DomName('Element.onsubmit')
  @DocsEditable
  Stream<Event> get onSubmit => submitEvent.forTarget(this);

  @DomName('Element.ontouchcancel')
  @DocsEditable
  Stream<TouchEvent> get onTouchCancel => touchCancelEvent.forTarget(this);

  @DomName('Element.ontouchend')
  @DocsEditable
  Stream<TouchEvent> get onTouchEnd => touchEndEvent.forTarget(this);

  @DomName('Element.ontouchenter')
  @DocsEditable
  Stream<TouchEvent> get onTouchEnter => touchEnterEvent.forTarget(this);

  @DomName('Element.ontouchleave')
  @DocsEditable
  Stream<TouchEvent> get onTouchLeave => touchLeaveEvent.forTarget(this);

  @DomName('Element.ontouchmove')
  @DocsEditable
  Stream<TouchEvent> get onTouchMove => touchMoveEvent.forTarget(this);

  @DomName('Element.ontouchstart')
  @DocsEditable
  Stream<TouchEvent> get onTouchStart => touchStartEvent.forTarget(this);

  @DomName('Element.onwebkitTransitionEnd')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.FIREFOX)
  @SupportedBrowser(SupportedBrowser.IE, '10')
  @SupportedBrowser(SupportedBrowser.SAFARI)
  Stream<TransitionEvent> get onTransitionEnd => transitionEndEvent.forTarget(this);

  @DomName('Element.onwebkitfullscreenchange')
  @DocsEditable
  Stream<Event> get onFullscreenChange => fullscreenChangeEvent.forTarget(this);

  @DomName('Element.onwebkitfullscreenerror')
  @DocsEditable
  Stream<Event> get onFullscreenError => fullscreenErrorEvent.forTarget(this);

}


final _START_TAG_REGEXP = new RegExp('<(\\w+)');
class _ElementFactoryProvider {
  static const _CUSTOM_PARENT_TAG_MAP = const {
    'body' : 'html',
    'head' : 'html',
    'caption' : 'table',
    'td': 'tr',
    'th': 'tr',
    'colgroup': 'table',
    'col' : 'colgroup',
    'tr' : 'tbody',
    'tbody' : 'table',
    'tfoot' : 'table',
    'thead' : 'table',
    'track' : 'audio',
  };

  @DomName('Document.createElement')
  static Element createElement_html(String html) {
    // TODO(jacobr): this method can be made more robust and performant.
    // 1) Cache the dummy parent elements required to use innerHTML rather than
    //    creating them every call.
    // 2) Verify that the html does not contain leading or trailing text nodes.
    // 3) Verify that the html does not contain both <head> and <body> tags.
    // 4) Detatch the created element from its dummy parent.
    String parentTag = 'div';
    String tag;
    final match = _START_TAG_REGEXP.firstMatch(html);
    if (match != null) {
      tag = match.group(1).toLowerCase();
      if (Device.isIE && Element._TABLE_TAGS.containsKey(tag)) {
        return _createTableForIE(html, tag);
      }
      parentTag = _CUSTOM_PARENT_TAG_MAP[tag];
      if (parentTag == null) parentTag = 'div';
    }

    final temp = new Element.tag(parentTag);
    temp.innerHtml = html;

    Element element;
    if (temp.children.length == 1) {
      element = temp.children[0];
    } else if (parentTag == 'html' && temp.children.length == 2) {
      // In html5 the root <html> tag will always have a <body> and a <head>,
      // even though the inner html only contains one of them.
      element = temp.children[tag == 'head' ? 0 : 1];
    } else {
      _singleNode(temp.children);
    }
    element.remove();
    return element;
  }

  /**
   * IE table elements don't support innerHTML (even in standards mode).
   * Instead we use a div and inject the table element in the innerHtml string.
   * This technique works on other browsers too, but it's probably slower,
   * so we only use it when running on IE.
   *
   * See also innerHTML:
   * <http://msdn.microsoft.com/en-us/library/ie/ms533897(v=vs.85).aspx>
   * and Building Tables Dynamically:
   * <http://msdn.microsoft.com/en-us/library/ie/ms532998(v=vs.85).aspx>.
   */
  static Element _createTableForIE(String html, String tag) {
    var div = new Element.tag('div');
    div.innerHtml = '<table>$html</table>';
    var table = _singleNode(div.children);
    Element element;
    switch (tag) {
      case 'td':
      case 'th':
        TableRowElement row = _singleNode(table.rows);
        element = _singleNode(row.cells);
        break;
      case 'tr':
        element = _singleNode(table.rows);
        break;
      case 'tbody':
        element = _singleNode(table.tBodies);
        break;
      case 'thead':
        element = table.tHead;
        break;
      case 'tfoot':
        element = table.tFoot;
        break;
      case 'caption':
        element = table.caption;
        break;
      case 'colgroup':
        element = _getColgroup(table);
        break;
      case 'col':
        element = _singleNode(_getColgroup(table).children);
        break;
    }
    element.remove();
    return element;
  }

  static TableColElement _getColgroup(TableElement table) {
    // TODO(jmesserly): is there a better way to do this?
    return _singleNode(table.children.where((n) => n.tagName == 'COLGROUP')
        .toList());
  }

  static Node _singleNode(List<Node> list) {
    if (list.length == 1) return list[0];
    throw new ArgumentError('HTML had ${list.length} '
        'top level elements but 1 expected');
  }

  @DomName('Document.createElement')
  static Element createElement_tag(String tag) =>
      document.$dom_createElement(tag);
}


/**
 * Options for Element.scrollIntoView.
 */
class ScrollAlignment {
  final _value;
  const ScrollAlignment._internal(this._value);
  toString() => 'ScrollAlignment.$_value';

  /// Attempt to align the element to the top of the scrollable area.
  static const TOP = const ScrollAlignment._internal('TOP');
  /// Attempt to center the element in the scrollable area.
  static const CENTER = const ScrollAlignment._internal('CENTER');
  /// Attempt to align the element to the bottom of the scrollable area.
  static const BOTTOM = const ScrollAlignment._internal('BOTTOM');
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('ElementTraversal')
class ElementTraversal extends NativeFieldWrapperClass1 {
  ElementTraversal.internal();

  @DomName('ElementTraversal.childElementCount')
  @DocsEditable
  int get $dom_childElementCount native "ElementTraversal_childElementCount_Getter";

  @DomName('ElementTraversal.firstElementChild')
  @DocsEditable
  Element get $dom_firstElementChild native "ElementTraversal_firstElementChild_Getter";

  @DomName('ElementTraversal.lastElementChild')
  @DocsEditable
  Element get $dom_lastElementChild native "ElementTraversal_lastElementChild_Getter";

  @DomName('ElementTraversal.nextElementSibling')
  @DocsEditable
  Element get nextElementSibling native "ElementTraversal_nextElementSibling_Getter";

  @DomName('ElementTraversal.previousElementSibling')
  @DocsEditable
  Element get previousElementSibling native "ElementTraversal_previousElementSibling_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLEmbedElement')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.IE)
@SupportedBrowser(SupportedBrowser.SAFARI)
class EmbedElement extends _Element_Merged {
  EmbedElement.internal() : super.internal();

  @DomName('HTMLEmbedElement.HTMLEmbedElement')
  @DocsEditable
  factory EmbedElement() => document.$dom_createElement("embed");

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('HTMLEmbedElement.align')
  @DocsEditable
  String get align native "HTMLEmbedElement_align_Getter";

  @DomName('HTMLEmbedElement.align')
  @DocsEditable
  void set align(String value) native "HTMLEmbedElement_align_Setter";

  @DomName('HTMLEmbedElement.height')
  @DocsEditable
  String get height native "HTMLEmbedElement_height_Getter";

  @DomName('HTMLEmbedElement.height')
  @DocsEditable
  void set height(String value) native "HTMLEmbedElement_height_Setter";

  @DomName('HTMLEmbedElement.name')
  @DocsEditable
  String get name native "HTMLEmbedElement_name_Getter";

  @DomName('HTMLEmbedElement.name')
  @DocsEditable
  void set name(String value) native "HTMLEmbedElement_name_Setter";

  @DomName('HTMLEmbedElement.src')
  @DocsEditable
  String get src native "HTMLEmbedElement_src_Getter";

  @DomName('HTMLEmbedElement.src')
  @DocsEditable
  void set src(String value) native "HTMLEmbedElement_src_Setter";

  @DomName('HTMLEmbedElement.type')
  @DocsEditable
  String get type native "HTMLEmbedElement_type_Getter";

  @DomName('HTMLEmbedElement.type')
  @DocsEditable
  void set type(String value) native "HTMLEmbedElement_type_Setter";

  @DomName('HTMLEmbedElement.width')
  @DocsEditable
  String get width native "HTMLEmbedElement_width_Getter";

  @DomName('HTMLEmbedElement.width')
  @DocsEditable
  void set width(String value) native "HTMLEmbedElement_width_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


typedef void _EntriesCallback(List<Entry> entries);
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('Entry')
class Entry extends NativeFieldWrapperClass1 {
  Entry.internal();

  @DomName('Entry.filesystem')
  @DocsEditable
  FileSystem get filesystem native "Entry_filesystem_Getter";

  @DomName('Entry.fullPath')
  @DocsEditable
  String get fullPath native "Entry_fullPath_Getter";

  @DomName('Entry.isDirectory')
  @DocsEditable
  bool get isDirectory native "Entry_isDirectory_Getter";

  @DomName('Entry.isFile')
  @DocsEditable
  bool get isFile native "Entry_isFile_Getter";

  @DomName('Entry.name')
  @DocsEditable
  String get name native "Entry_name_Getter";

  void _copyTo(DirectoryEntry parent, {String name, _EntryCallback successCallback, _ErrorCallback errorCallback}) {
    if (?name) {
      _copyTo_1(parent, name, successCallback, errorCallback);
      return;
    }
    _copyTo_2(parent);
    return;
  }

  void _copyTo_1(parent, name, successCallback, errorCallback) native "Entry__copyTo_1_Callback";

  void _copyTo_2(parent) native "Entry__copyTo_2_Callback";

  Future<Entry> copyTo(DirectoryEntry parent, {String name}) {
    var completer = new Completer<Entry>();
    _copyTo(parent, name : name,
        successCallback : (value) { completer.complete(value); },
        errorCallback : (error) { completer.completeError(error); });
    return completer.future;
  }

  @DomName('Entry.getMetadata')
  @DocsEditable
  void _getMetadata(MetadataCallback successCallback, [_ErrorCallback errorCallback]) native "Entry_getMetadata_Callback";

  Future<Metadata> getMetadata() {
    var completer = new Completer<Metadata>();
    _getMetadata(
        (value) { completer.complete(value); },
        (error) { completer.completeError(error); });
    return completer.future;
  }

  @DomName('Entry.getParent')
  @DocsEditable
  void _getParent([_EntryCallback successCallback, _ErrorCallback errorCallback]) native "Entry_getParent_Callback";

  Future<Entry> getParent() {
    var completer = new Completer<Entry>();
    _getParent(
        (value) { completer.complete(value); },
        (error) { completer.completeError(error); });
    return completer.future;
  }

  void _moveTo(DirectoryEntry parent, {String name, _EntryCallback successCallback, _ErrorCallback errorCallback}) {
    if (?name) {
      _moveTo_1(parent, name, successCallback, errorCallback);
      return;
    }
    _moveTo_2(parent);
    return;
  }

  void _moveTo_1(parent, name, successCallback, errorCallback) native "Entry__moveTo_1_Callback";

  void _moveTo_2(parent) native "Entry__moveTo_2_Callback";

  Future<Entry> moveTo(DirectoryEntry parent, {String name}) {
    var completer = new Completer<Entry>();
    _moveTo(parent, name : name,
        successCallback : (value) { completer.complete(value); },
        errorCallback : (error) { completer.completeError(error); });
    return completer.future;
  }

  @DomName('Entry.remove')
  @DocsEditable
  void _remove(VoidCallback successCallback, [_ErrorCallback errorCallback]) native "Entry_remove_Callback";

  Future remove() {
    var completer = new Completer();
    _remove(
        () { completer.complete(); },
        (error) { completer.completeError(error); });
    return completer.future;
  }

  @DomName('Entry.toURL')
  @DocsEditable
  String toUrl() native "Entry_toURL_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


typedef void _EntryCallback(Entry entry);
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


typedef void _ErrorCallback(FileError error);
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('ErrorEvent')
class ErrorEvent extends Event {
  ErrorEvent.internal() : super.internal();

  @DomName('ErrorEvent.filename')
  @DocsEditable
  String get filename native "ErrorEvent_filename_Getter";

  @DomName('ErrorEvent.lineno')
  @DocsEditable
  int get lineno native "ErrorEvent_lineno_Getter";

  @DomName('ErrorEvent.message')
  @DocsEditable
  String get message native "ErrorEvent_message_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DomName('Event')
class Event extends NativeFieldWrapperClass1 {
  // In JS, canBubble and cancelable are technically required parameters to
  // init*Event. In practice, though, if they aren't provided they simply
  // default to false (since that's Boolean(undefined)).
  //
  // Contrary to JS, we default canBubble and cancelable to true, since that's
  // what people want most of the time anyway.
  factory Event(String type,
      {bool canBubble: true, bool cancelable: true}) {
    return new Event.eventType('Event', type, canBubble: canBubble,
        cancelable: cancelable);
  }

  /**
   * Creates a new Event object of the specified type.
   *
   * This is analogous to document.createEvent.
   * Normally events should be created via their constructors, if available.
   *
   *     var e = new Event.type('MouseEvent', 'mousedown', true, true);
   */
  factory Event.eventType(String type, String name, {bool canBubble: true,
      bool cancelable: true}) {
    final Event e = document.$dom_createEvent(type);
    e.$dom_initEvent(name, canBubble, cancelable);
    return e;
  }
  Event.internal();

  @DomName('Event.AT_TARGET')
  @DocsEditable
  static const int AT_TARGET = 2;

  @DomName('Event.BLUR')
  @DocsEditable
  static const int BLUR = 8192;

  @DomName('Event.BUBBLING_PHASE')
  @DocsEditable
  static const int BUBBLING_PHASE = 3;

  @DomName('Event.CAPTURING_PHASE')
  @DocsEditable
  static const int CAPTURING_PHASE = 1;

  @DomName('Event.CHANGE')
  @DocsEditable
  static const int CHANGE = 32768;

  @DomName('Event.CLICK')
  @DocsEditable
  static const int CLICK = 64;

  @DomName('Event.DBLCLICK')
  @DocsEditable
  static const int DBLCLICK = 128;

  @DomName('Event.DRAGDROP')
  @DocsEditable
  static const int DRAGDROP = 2048;

  @DomName('Event.FOCUS')
  @DocsEditable
  static const int FOCUS = 4096;

  @DomName('Event.KEYDOWN')
  @DocsEditable
  static const int KEYDOWN = 256;

  @DomName('Event.KEYPRESS')
  @DocsEditable
  static const int KEYPRESS = 1024;

  @DomName('Event.KEYUP')
  @DocsEditable
  static const int KEYUP = 512;

  @DomName('Event.MOUSEDOWN')
  @DocsEditable
  static const int MOUSEDOWN = 1;

  @DomName('Event.MOUSEDRAG')
  @DocsEditable
  static const int MOUSEDRAG = 32;

  @DomName('Event.MOUSEMOVE')
  @DocsEditable
  static const int MOUSEMOVE = 16;

  @DomName('Event.MOUSEOUT')
  @DocsEditable
  static const int MOUSEOUT = 8;

  @DomName('Event.MOUSEOVER')
  @DocsEditable
  static const int MOUSEOVER = 4;

  @DomName('Event.MOUSEUP')
  @DocsEditable
  static const int MOUSEUP = 2;

  @DomName('Event.NONE')
  @DocsEditable
  static const int NONE = 0;

  @DomName('Event.SELECT')
  @DocsEditable
  static const int SELECT = 16384;

  @DomName('Event.bubbles')
  @DocsEditable
  bool get bubbles native "Event_bubbles_Getter";

  @DomName('Event.cancelBubble')
  @DocsEditable
  bool get cancelBubble native "Event_cancelBubble_Getter";

  @DomName('Event.cancelBubble')
  @DocsEditable
  void set cancelBubble(bool value) native "Event_cancelBubble_Setter";

  @DomName('Event.cancelable')
  @DocsEditable
  bool get cancelable native "Event_cancelable_Getter";

  @DomName('Event.clipboardData')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  DataTransfer get clipboardData native "Event_clipboardData_Getter";

  @DomName('Event.currentTarget')
  @DocsEditable
  EventTarget get currentTarget native "Event_currentTarget_Getter";

  @DomName('Event.defaultPrevented')
  @DocsEditable
  bool get defaultPrevented native "Event_defaultPrevented_Getter";

  @DomName('Event.eventPhase')
  @DocsEditable
  int get eventPhase native "Event_eventPhase_Getter";

  @DomName('Event.target')
  @DocsEditable
  EventTarget get target native "Event_target_Getter";

  @DomName('Event.timeStamp')
  @DocsEditable
  int get timeStamp native "Event_timeStamp_Getter";

  @DomName('Event.type')
  @DocsEditable
  String get type native "Event_type_Getter";

  @DomName('Event.initEvent')
  @DocsEditable
  void $dom_initEvent(String eventTypeArg, bool canBubbleArg, bool cancelableArg) native "Event_initEvent_Callback";

  @DomName('Event.preventDefault')
  @DocsEditable
  void preventDefault() native "Event_preventDefault_Callback";

  @DomName('Event.stopImmediatePropagation')
  @DocsEditable
  void stopImmediatePropagation() native "Event_stopImmediatePropagation_Callback";

  @DomName('Event.stopPropagation')
  @DocsEditable
  void stopPropagation() native "Event_stopPropagation_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('EventException')
class EventException extends NativeFieldWrapperClass1 {
  EventException.internal();

  @DomName('EventException.DISPATCH_REQUEST_ERR')
  @DocsEditable
  static const int DISPATCH_REQUEST_ERR = 1;

  @DomName('EventException.UNSPECIFIED_EVENT_TYPE_ERR')
  @DocsEditable
  static const int UNSPECIFIED_EVENT_TYPE_ERR = 0;

  @DomName('EventException.code')
  @DocsEditable
  int get code native "EventException_code_Getter";

  @DomName('EventException.message')
  @DocsEditable
  String get message native "EventException_message_Getter";

  @DomName('EventException.name')
  @DocsEditable
  String get name native "EventException_name_Getter";

  @DomName('EventException.toString')
  @DocsEditable
  String toString() native "EventException_toString_Callback";

}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('EventSource')
class EventSource extends EventTarget {
  factory EventSource(String title, {withCredentials: false}) {
    var parsedOptions = {
      'withCredentials': withCredentials,
    };
    return EventSource._factoryEventSource(title, parsedOptions);
  }
  EventSource.internal() : super.internal();

  @DomName('EventSource.errorEvent')
  @DocsEditable
  static const EventStreamProvider<Event> errorEvent = const EventStreamProvider<Event>('error');

  @DomName('EventSource.messageEvent')
  @DocsEditable
  static const EventStreamProvider<MessageEvent> messageEvent = const EventStreamProvider<MessageEvent>('message');

  @DomName('EventSource.openEvent')
  @DocsEditable
  static const EventStreamProvider<Event> openEvent = const EventStreamProvider<Event>('open');

  @DomName('EventSource.EventSource')
  @DocsEditable
  static EventSource _factoryEventSource(String url, [Map eventSourceInit]) {
    return EventSource._create_1(url, eventSourceInit);
  }

  @DocsEditable
  static EventSource _create_1(url, eventSourceInit) native "EventSource__create_1constructorCallback";

  @DomName('EventSource.CLOSED')
  @DocsEditable
  static const int CLOSED = 2;

  @DomName('EventSource.CONNECTING')
  @DocsEditable
  static const int CONNECTING = 0;

  @DomName('EventSource.OPEN')
  @DocsEditable
  static const int OPEN = 1;

  @DomName('EventSource.readyState')
  @DocsEditable
  int get readyState native "EventSource_readyState_Getter";

  @DomName('EventSource.url')
  @DocsEditable
  String get url native "EventSource_url_Getter";

  @DomName('EventSource.withCredentials')
  @DocsEditable
  bool get withCredentials native "EventSource_withCredentials_Getter";

  @DomName('EventSource.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "EventSource_addEventListener_Callback";

  @DomName('EventSource.close')
  @DocsEditable
  void close() native "EventSource_close_Callback";

  @DomName('EventSource.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event evt) native "EventSource_dispatchEvent_Callback";

  @DomName('EventSource.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "EventSource_removeEventListener_Callback";

  @DomName('EventSource.onerror')
  @DocsEditable
  Stream<Event> get onError => errorEvent.forTarget(this);

  @DomName('EventSource.onmessage')
  @DocsEditable
  Stream<MessageEvent> get onMessage => messageEvent.forTarget(this);

  @DomName('EventSource.onopen')
  @DocsEditable
  Stream<Event> get onOpen => openEvent.forTarget(this);

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/**
 * Base class that supports listening for and dispatching browser events.
 *
 * Normally events are accessed via the Stream getter:
 *
 *     element.onMouseOver.listen((e) => print('Mouse over!'));
 *
 * To access bubbling events which are declared on one element, but may bubble
 * up to another element type (common for MediaElement events):
 *
 *     MediaElement.pauseEvent.forTarget(document.body).listen(...);
 *
 * To useCapture on events:
 *
 *     Element.keyDownEvent.forTarget(element, useCapture: true).listen(...);
 *
 * Custom events can be declared as:
 *
 *    class DataGenerator {
 *      static EventStreamProvider<Event> dataEvent =
 *          new EventStreamProvider('data');
 *    }
 *
 * Then listeners should access the event with:
 *
 *     DataGenerator.dataEvent.forTarget(element).listen(...);
 *
 * Custom events can also be accessed as:
 *
 *     element.on['some_event'].listen(...);
 *
 * This approach is generally discouraged as it loses the event typing and
 * some DOM events may have multiple platform-dependent event names under the
 * covers. By using the standard Stream getters you will get the platform
 * specific event name automatically.
 */
class Events {
  /* Raw event target. */
  final EventTarget _ptr;

  Events(this._ptr);

  Stream operator [](String type) {
    return new _EventStream(_ptr, type, false);
  }
}

/**
 * Base class for all browser objects that support events.
 *
 * Use the [on] property to add, and remove events (rather than
 * [$dom_addEventListener] and [$dom_removeEventListener]
 * for compile-time type checks and a more concise API.
 */
@DomName('EventTarget')
class EventTarget extends NativeFieldWrapperClass1 {

  /**
   * This is an ease-of-use accessor for event streams which should only be
   * used when an explicit accessor is not available.
   */
  Events get on => new Events(this);
  EventTarget.internal();

  @DomName('EventTarget.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "EventTarget_addEventListener_Callback";

  @DomName('EventTarget.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event event) native "EventTarget_dispatchEvent_Callback";

  @DomName('EventTarget.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "EventTarget_removeEventListener_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLFieldSetElement')
class FieldSetElement extends _Element_Merged {
  FieldSetElement.internal() : super.internal();

  @DomName('HTMLFieldSetElement.HTMLFieldSetElement')
  @DocsEditable
  factory FieldSetElement() => document.$dom_createElement("fieldset");

  @DomName('HTMLFieldSetElement.disabled')
  @DocsEditable
  bool get disabled native "HTMLFieldSetElement_disabled_Getter";

  @DomName('HTMLFieldSetElement.disabled')
  @DocsEditable
  void set disabled(bool value) native "HTMLFieldSetElement_disabled_Setter";

  @DomName('HTMLFieldSetElement.elements')
  @DocsEditable
  HtmlCollection get elements native "HTMLFieldSetElement_elements_Getter";

  @DomName('HTMLFieldSetElement.form')
  @DocsEditable
  FormElement get form native "HTMLFieldSetElement_form_Getter";

  @DomName('HTMLFieldSetElement.name')
  @DocsEditable
  String get name native "HTMLFieldSetElement_name_Getter";

  @DomName('HTMLFieldSetElement.name')
  @DocsEditable
  void set name(String value) native "HTMLFieldSetElement_name_Setter";

  @DomName('HTMLFieldSetElement.type')
  @DocsEditable
  String get type native "HTMLFieldSetElement_type_Getter";

  @DomName('HTMLFieldSetElement.validationMessage')
  @DocsEditable
  String get validationMessage native "HTMLFieldSetElement_validationMessage_Getter";

  @DomName('HTMLFieldSetElement.validity')
  @DocsEditable
  ValidityState get validity native "HTMLFieldSetElement_validity_Getter";

  @DomName('HTMLFieldSetElement.willValidate')
  @DocsEditable
  bool get willValidate native "HTMLFieldSetElement_willValidate_Getter";

  @DomName('HTMLFieldSetElement.checkValidity')
  @DocsEditable
  bool checkValidity() native "HTMLFieldSetElement_checkValidity_Callback";

  @DomName('HTMLFieldSetElement.setCustomValidity')
  @DocsEditable
  void setCustomValidity(String error) native "HTMLFieldSetElement_setCustomValidity_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('File')
class File extends Blob {
  File.internal() : super.internal();

  @DomName('File.lastModifiedDate')
  @DocsEditable
  DateTime get lastModifiedDate native "File_lastModifiedDate_Getter";

  @DomName('File.name')
  @DocsEditable
  String get name native "File_name_Getter";

  @DomName('File.webkitRelativePath')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  String get relativePath native "File_webkitRelativePath_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


typedef void _FileCallback(File file);
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('FileEntry')
class FileEntry extends Entry {
  FileEntry.internal() : super.internal();

  @DomName('FileEntry.createWriter')
  @DocsEditable
  void _createWriter(_FileWriterCallback successCallback, [_ErrorCallback errorCallback]) native "FileEntry_createWriter_Callback";

  Future<FileWriter> createWriter() {
    var completer = new Completer<FileWriter>();
    _createWriter(
        (value) { completer.complete(value); },
        (error) { completer.completeError(error); });
    return completer.future;
  }

  @DomName('FileEntry.file')
  @DocsEditable
  void _file(_FileCallback successCallback, [_ErrorCallback errorCallback]) native "FileEntry_file_Callback";

  Future<File> file() {
    var completer = new Completer<File>();
    _file(
        (value) { completer.complete(value); },
        (error) { completer.completeError(error); });
    return completer.future;
  }

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('FileError')
class FileError extends NativeFieldWrapperClass1 {
  FileError.internal();

  @DomName('FileError.ABORT_ERR')
  @DocsEditable
  static const int ABORT_ERR = 3;

  @DomName('FileError.ENCODING_ERR')
  @DocsEditable
  static const int ENCODING_ERR = 5;

  @DomName('FileError.INVALID_MODIFICATION_ERR')
  @DocsEditable
  static const int INVALID_MODIFICATION_ERR = 9;

  @DomName('FileError.INVALID_STATE_ERR')
  @DocsEditable
  static const int INVALID_STATE_ERR = 7;

  @DomName('FileError.NOT_FOUND_ERR')
  @DocsEditable
  static const int NOT_FOUND_ERR = 1;

  @DomName('FileError.NOT_READABLE_ERR')
  @DocsEditable
  static const int NOT_READABLE_ERR = 4;

  @DomName('FileError.NO_MODIFICATION_ALLOWED_ERR')
  @DocsEditable
  static const int NO_MODIFICATION_ALLOWED_ERR = 6;

  @DomName('FileError.PATH_EXISTS_ERR')
  @DocsEditable
  static const int PATH_EXISTS_ERR = 12;

  @DomName('FileError.QUOTA_EXCEEDED_ERR')
  @DocsEditable
  static const int QUOTA_EXCEEDED_ERR = 10;

  @DomName('FileError.SECURITY_ERR')
  @DocsEditable
  static const int SECURITY_ERR = 2;

  @DomName('FileError.SYNTAX_ERR')
  @DocsEditable
  static const int SYNTAX_ERR = 8;

  @DomName('FileError.TYPE_MISMATCH_ERR')
  @DocsEditable
  static const int TYPE_MISMATCH_ERR = 11;

  @DomName('FileError.code')
  @DocsEditable
  int get code native "FileError_code_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('FileException')
class FileException extends NativeFieldWrapperClass1 {
  FileException.internal();

  @DomName('FileException.ABORT_ERR')
  @DocsEditable
  static const int ABORT_ERR = 3;

  @DomName('FileException.ENCODING_ERR')
  @DocsEditable
  static const int ENCODING_ERR = 5;

  @DomName('FileException.INVALID_MODIFICATION_ERR')
  @DocsEditable
  static const int INVALID_MODIFICATION_ERR = 9;

  @DomName('FileException.INVALID_STATE_ERR')
  @DocsEditable
  static const int INVALID_STATE_ERR = 7;

  @DomName('FileException.NOT_FOUND_ERR')
  @DocsEditable
  static const int NOT_FOUND_ERR = 1;

  @DomName('FileException.NOT_READABLE_ERR')
  @DocsEditable
  static const int NOT_READABLE_ERR = 4;

  @DomName('FileException.NO_MODIFICATION_ALLOWED_ERR')
  @DocsEditable
  static const int NO_MODIFICATION_ALLOWED_ERR = 6;

  @DomName('FileException.PATH_EXISTS_ERR')
  @DocsEditable
  static const int PATH_EXISTS_ERR = 12;

  @DomName('FileException.QUOTA_EXCEEDED_ERR')
  @DocsEditable
  static const int QUOTA_EXCEEDED_ERR = 10;

  @DomName('FileException.SECURITY_ERR')
  @DocsEditable
  static const int SECURITY_ERR = 2;

  @DomName('FileException.SYNTAX_ERR')
  @DocsEditable
  static const int SYNTAX_ERR = 8;

  @DomName('FileException.TYPE_MISMATCH_ERR')
  @DocsEditable
  static const int TYPE_MISMATCH_ERR = 11;

  @DomName('FileException.code')
  @DocsEditable
  int get code native "FileException_code_Getter";

  @DomName('FileException.message')
  @DocsEditable
  String get message native "FileException_message_Getter";

  @DomName('FileException.name')
  @DocsEditable
  String get name native "FileException_name_Getter";

  @DomName('FileException.toString')
  @DocsEditable
  String toString() native "FileException_toString_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('FileList')
class FileList extends NativeFieldWrapperClass1 with ListMixin<File>, ImmutableListMixin<File> implements List<File> {
  FileList.internal();

  @DomName('FileList.length')
  @DocsEditable
  int get length native "FileList_length_Getter";

  File operator[](int index) {
    if (index < 0 || index >= length)
      throw new RangeError.range(index, 0, length);
    return _nativeIndexedGetter(index);
  }
  File _nativeIndexedGetter(int index) native "FileList_item_Callback";

  void operator[]=(int index, File value) {
    throw new UnsupportedError("Cannot assign element of immutable List.");
  }
  // -- start List<File> mixins.
  // File is the element type.


  void set length(int value) {
    throw new UnsupportedError("Cannot resize immutable List.");
  }

  File get first {
    if (this.length > 0) {
      return this[0];
    }
    throw new StateError("No elements");
  }

  File get last {
    int len = this.length;
    if (len > 0) {
      return this[len - 1];
    }
    throw new StateError("No elements");
  }

  File get single {
    int len = this.length;
    if (len == 1) {
      return this[0];
    }
    if (len == 0) throw new StateError("No elements");
    throw new StateError("More than one element");
  }

  File elementAt(int index) => this[index];
  // -- end List<File> mixins.

  @DomName('FileList.item')
  @DocsEditable
  File item(int index) native "FileList_item_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('FileReader')
class FileReader extends EventTarget {
  FileReader.internal() : super.internal();

  @DomName('FileReader.abortEvent')
  @DocsEditable
  static const EventStreamProvider<ProgressEvent> abortEvent = const EventStreamProvider<ProgressEvent>('abort');

  @DomName('FileReader.errorEvent')
  @DocsEditable
  static const EventStreamProvider<Event> errorEvent = const EventStreamProvider<Event>('error');

  @DomName('FileReader.loadEvent')
  @DocsEditable
  static const EventStreamProvider<ProgressEvent> loadEvent = const EventStreamProvider<ProgressEvent>('load');

  @DomName('FileReader.loadendEvent')
  @DocsEditable
  static const EventStreamProvider<ProgressEvent> loadEndEvent = const EventStreamProvider<ProgressEvent>('loadend');

  @DomName('FileReader.loadstartEvent')
  @DocsEditable
  static const EventStreamProvider<ProgressEvent> loadStartEvent = const EventStreamProvider<ProgressEvent>('loadstart');

  @DomName('FileReader.progressEvent')
  @DocsEditable
  static const EventStreamProvider<ProgressEvent> progressEvent = const EventStreamProvider<ProgressEvent>('progress');

  @DomName('FileReader.FileReader')
  @DocsEditable
  factory FileReader() {
    return FileReader._create_1();
  }

  @DocsEditable
  static FileReader _create_1() native "FileReader__create_1constructorCallback";

  @DomName('FileReader.DONE')
  @DocsEditable
  static const int DONE = 2;

  @DomName('FileReader.EMPTY')
  @DocsEditable
  static const int EMPTY = 0;

  @DomName('FileReader.LOADING')
  @DocsEditable
  static const int LOADING = 1;

  @DomName('FileReader.error')
  @DocsEditable
  FileError get error native "FileReader_error_Getter";

  @DomName('FileReader.readyState')
  @DocsEditable
  int get readyState native "FileReader_readyState_Getter";

  @DomName('FileReader.result')
  @DocsEditable
  Object get result native "FileReader_result_Getter";

  @DomName('FileReader.abort')
  @DocsEditable
  void abort() native "FileReader_abort_Callback";

  @DomName('FileReader.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "FileReader_addEventListener_Callback";

  @DomName('FileReader.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event evt) native "FileReader_dispatchEvent_Callback";

  @DomName('FileReader.readAsArrayBuffer')
  @DocsEditable
  void readAsArrayBuffer(Blob blob) native "FileReader_readAsArrayBuffer_Callback";

  @DomName('FileReader.readAsBinaryString')
  @DocsEditable
  void readAsBinaryString(Blob blob) native "FileReader_readAsBinaryString_Callback";

  @DomName('FileReader.readAsDataURL')
  @DocsEditable
  void readAsDataUrl(Blob blob) native "FileReader_readAsDataURL_Callback";

  void readAsText(Blob blob, [String encoding]) {
    if (?encoding) {
      _readAsText_1(blob, encoding);
      return;
    }
    _readAsText_2(blob);
    return;
  }

  void _readAsText_1(blob, encoding) native "FileReader__readAsText_1_Callback";

  void _readAsText_2(blob) native "FileReader__readAsText_2_Callback";

  @DomName('FileReader.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "FileReader_removeEventListener_Callback";

  @DomName('FileReader.onabort')
  @DocsEditable
  Stream<ProgressEvent> get onAbort => abortEvent.forTarget(this);

  @DomName('FileReader.onerror')
  @DocsEditable
  Stream<Event> get onError => errorEvent.forTarget(this);

  @DomName('FileReader.onload')
  @DocsEditable
  Stream<ProgressEvent> get onLoad => loadEvent.forTarget(this);

  @DomName('FileReader.onloadend')
  @DocsEditable
  Stream<ProgressEvent> get onLoadEnd => loadEndEvent.forTarget(this);

  @DomName('FileReader.onloadstart')
  @DocsEditable
  Stream<ProgressEvent> get onLoadStart => loadStartEvent.forTarget(this);

  @DomName('FileReader.onprogress')
  @DocsEditable
  Stream<ProgressEvent> get onProgress => progressEvent.forTarget(this);

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('DOMFileSystem')
@SupportedBrowser(SupportedBrowser.CHROME)
@Experimental
class FileSystem extends NativeFieldWrapperClass1 {
  FileSystem.internal();

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('DOMFileSystem.name')
  @DocsEditable
  String get name native "DOMFileSystem_name_Getter";

  @DomName('DOMFileSystem.root')
  @DocsEditable
  DirectoryEntry get root native "DOMFileSystem_root_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


typedef void _FileSystemCallback(FileSystem fileSystem);
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('FileWriter')
class FileWriter extends EventTarget {
  FileWriter.internal() : super.internal();

  @DomName('FileWriter.abortEvent')
  @DocsEditable
  static const EventStreamProvider<ProgressEvent> abortEvent = const EventStreamProvider<ProgressEvent>('abort');

  @DomName('FileWriter.errorEvent')
  @DocsEditable
  static const EventStreamProvider<Event> errorEvent = const EventStreamProvider<Event>('error');

  @DomName('FileWriter.progressEvent')
  @DocsEditable
  static const EventStreamProvider<ProgressEvent> progressEvent = const EventStreamProvider<ProgressEvent>('progress');

  @DomName('FileWriter.writeEvent')
  @DocsEditable
  static const EventStreamProvider<ProgressEvent> writeEvent = const EventStreamProvider<ProgressEvent>('write');

  @DomName('FileWriter.writeendEvent')
  @DocsEditable
  static const EventStreamProvider<ProgressEvent> writeEndEvent = const EventStreamProvider<ProgressEvent>('writeend');

  @DomName('FileWriter.writestartEvent')
  @DocsEditable
  static const EventStreamProvider<ProgressEvent> writeStartEvent = const EventStreamProvider<ProgressEvent>('writestart');

  @DomName('FileWriter.DONE')
  @DocsEditable
  static const int DONE = 2;

  @DomName('FileWriter.INIT')
  @DocsEditable
  static const int INIT = 0;

  @DomName('FileWriter.WRITING')
  @DocsEditable
  static const int WRITING = 1;

  @DomName('FileWriter.error')
  @DocsEditable
  FileError get error native "FileWriter_error_Getter";

  @DomName('FileWriter.length')
  @DocsEditable
  int get length native "FileWriter_length_Getter";

  @DomName('FileWriter.position')
  @DocsEditable
  int get position native "FileWriter_position_Getter";

  @DomName('FileWriter.readyState')
  @DocsEditable
  int get readyState native "FileWriter_readyState_Getter";

  @DomName('FileWriter.abort')
  @DocsEditable
  void abort() native "FileWriter_abort_Callback";

  @DomName('FileWriter.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "FileWriter_addEventListener_Callback";

  @DomName('FileWriter.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event evt) native "FileWriter_dispatchEvent_Callback";

  @DomName('FileWriter.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "FileWriter_removeEventListener_Callback";

  @DomName('FileWriter.seek')
  @DocsEditable
  void seek(int position) native "FileWriter_seek_Callback";

  @DomName('FileWriter.truncate')
  @DocsEditable
  void truncate(int size) native "FileWriter_truncate_Callback";

  @DomName('FileWriter.write')
  @DocsEditable
  void write(Blob data) native "FileWriter_write_Callback";

  @DomName('FileWriter.onabort')
  @DocsEditable
  Stream<ProgressEvent> get onAbort => abortEvent.forTarget(this);

  @DomName('FileWriter.onerror')
  @DocsEditable
  Stream<Event> get onError => errorEvent.forTarget(this);

  @DomName('FileWriter.onprogress')
  @DocsEditable
  Stream<ProgressEvent> get onProgress => progressEvent.forTarget(this);

  @DomName('FileWriter.onwrite')
  @DocsEditable
  Stream<ProgressEvent> get onWrite => writeEvent.forTarget(this);

  @DomName('FileWriter.onwriteend')
  @DocsEditable
  Stream<ProgressEvent> get onWriteEnd => writeEndEvent.forTarget(this);

  @DomName('FileWriter.onwritestart')
  @DocsEditable
  Stream<ProgressEvent> get onWriteStart => writeStartEvent.forTarget(this);

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


typedef void _FileWriterCallback(FileWriter fileWriter);
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('FocusEvent')
class FocusEvent extends UIEvent {
  FocusEvent.internal() : super.internal();

  @DomName('FocusEvent.relatedTarget')
  @DocsEditable
  EventTarget get relatedTarget native "FocusEvent_relatedTarget_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('FontLoader')
class FontLoader extends EventTarget {
  FontLoader.internal() : super.internal();

  @DomName('FontLoader.errorEvent')
  @DocsEditable
  static const EventStreamProvider<Event> errorEvent = const EventStreamProvider<Event>('error');

  @DomName('FontLoader.loadEvent')
  @DocsEditable
  static const EventStreamProvider<Event> loadEvent = const EventStreamProvider<Event>('load');

  @DomName('FontLoader.loading')
  @DocsEditable
  bool get loading native "FontLoader_loading_Getter";

  @DomName('FontLoader.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "FontLoader_addEventListener_Callback";

  @DomName('FontLoader.checkFont')
  @DocsEditable
  bool checkFont(String font, String text) native "FontLoader_checkFont_Callback";

  @DomName('FontLoader.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event evt) native "FontLoader_dispatchEvent_Callback";

  @DomName('FontLoader.loadFont')
  @DocsEditable
  void loadFont(Map params) native "FontLoader_loadFont_Callback";

  @DomName('FontLoader.notifyWhenFontsReady')
  @DocsEditable
  void notifyWhenFontsReady(VoidCallback callback) native "FontLoader_notifyWhenFontsReady_Callback";

  @DomName('FontLoader.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "FontLoader_removeEventListener_Callback";

  @DomName('FontLoader.onerror')
  @DocsEditable
  Stream<Event> get onError => errorEvent.forTarget(this);

  @DomName('FontLoader.onload')
  @DocsEditable
  Stream<Event> get onLoad => loadEvent.forTarget(this);

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('FormData')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.FIREFOX)
@SupportedBrowser(SupportedBrowser.IE, '10')
@SupportedBrowser(SupportedBrowser.SAFARI)
class FormData extends NativeFieldWrapperClass1 {
  FormData.internal();
  factory FormData([FormElement form]) => _create(form);

  @DocsEditable
  static FormData _create(form) native "DOMFormData_constructorCallback";

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('FormData.append')
  @DocsEditable
  void append(String name, value, [String filename]) native "DOMFormData_append_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLFormElement')
class FormElement extends _Element_Merged {
  FormElement.internal() : super.internal();

  @DomName('HTMLFormElement.HTMLFormElement')
  @DocsEditable
  factory FormElement() => document.$dom_createElement("form");

  @DomName('HTMLFormElement.acceptCharset')
  @DocsEditable
  String get acceptCharset native "HTMLFormElement_acceptCharset_Getter";

  @DomName('HTMLFormElement.acceptCharset')
  @DocsEditable
  void set acceptCharset(String value) native "HTMLFormElement_acceptCharset_Setter";

  @DomName('HTMLFormElement.action')
  @DocsEditable
  String get action native "HTMLFormElement_action_Getter";

  @DomName('HTMLFormElement.action')
  @DocsEditable
  void set action(String value) native "HTMLFormElement_action_Setter";

  @DomName('HTMLFormElement.autocomplete')
  @DocsEditable
  String get autocomplete native "HTMLFormElement_autocomplete_Getter";

  @DomName('HTMLFormElement.autocomplete')
  @DocsEditable
  void set autocomplete(String value) native "HTMLFormElement_autocomplete_Setter";

  @DomName('HTMLFormElement.encoding')
  @DocsEditable
  String get encoding native "HTMLFormElement_encoding_Getter";

  @DomName('HTMLFormElement.encoding')
  @DocsEditable
  void set encoding(String value) native "HTMLFormElement_encoding_Setter";

  @DomName('HTMLFormElement.enctype')
  @DocsEditable
  String get enctype native "HTMLFormElement_enctype_Getter";

  @DomName('HTMLFormElement.enctype')
  @DocsEditable
  void set enctype(String value) native "HTMLFormElement_enctype_Setter";

  @DomName('HTMLFormElement.length')
  @DocsEditable
  int get length native "HTMLFormElement_length_Getter";

  @DomName('HTMLFormElement.method')
  @DocsEditable
  String get method native "HTMLFormElement_method_Getter";

  @DomName('HTMLFormElement.method')
  @DocsEditable
  void set method(String value) native "HTMLFormElement_method_Setter";

  @DomName('HTMLFormElement.name')
  @DocsEditable
  String get name native "HTMLFormElement_name_Getter";

  @DomName('HTMLFormElement.name')
  @DocsEditable
  void set name(String value) native "HTMLFormElement_name_Setter";

  @DomName('HTMLFormElement.noValidate')
  @DocsEditable
  bool get noValidate native "HTMLFormElement_noValidate_Getter";

  @DomName('HTMLFormElement.noValidate')
  @DocsEditable
  void set noValidate(bool value) native "HTMLFormElement_noValidate_Setter";

  @DomName('HTMLFormElement.target')
  @DocsEditable
  String get target native "HTMLFormElement_target_Getter";

  @DomName('HTMLFormElement.target')
  @DocsEditable
  void set target(String value) native "HTMLFormElement_target_Setter";

  @DomName('HTMLFormElement.checkValidity')
  @DocsEditable
  bool checkValidity() native "HTMLFormElement_checkValidity_Callback";

  @DomName('HTMLFormElement.requestAutocomplete')
  @DocsEditable
  void requestAutocomplete() native "HTMLFormElement_requestAutocomplete_Callback";

  @DomName('HTMLFormElement.reset')
  @DocsEditable
  void reset() native "HTMLFormElement_reset_Callback";

  @DomName('HTMLFormElement.submit')
  @DocsEditable
  void submit() native "HTMLFormElement_submit_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('Gamepad')
class Gamepad extends NativeFieldWrapperClass1 {
  Gamepad.internal();

  @DomName('Gamepad.axes')
  @DocsEditable
  List<num> get axes native "Gamepad_axes_Getter";

  @DomName('Gamepad.buttons')
  @DocsEditable
  List<num> get buttons native "Gamepad_buttons_Getter";

  @DomName('Gamepad.id')
  @DocsEditable
  String get id native "Gamepad_id_Getter";

  @DomName('Gamepad.index')
  @DocsEditable
  int get index native "Gamepad_index_Getter";

  @DomName('Gamepad.timestamp')
  @DocsEditable
  int get timestamp native "Gamepad_timestamp_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DocsEditable
@DomName('Geolocation')
class Geolocation extends NativeFieldWrapperClass1 {

  @DomName('Geolocation.getCurrentPosition')
  Future<Geoposition> getCurrentPosition({bool enableHighAccuracy,
      Duration timeout, Duration maximumAge}) {
    var options = {};
    if (enableHighAccuracy != null) {
      options['enableHighAccuracy'] = enableHighAccuracy;
    }
    if (timeout != null) {
      options['timeout'] = timeout.inMilliseconds;
    }
    if (maximumAge != null) {
      options['maximumAge'] = maximumAge.inMilliseconds;
    }
    var completer = new Completer<Geoposition>();
    try {
      $dom_getCurrentPosition(
          (position) {
            completer.complete(_ensurePosition(position));
          },
          (error) {
            completer.completeError(error);
          },
          options);
    } catch (e, stacktrace) {
      completer.completeError(e, stacktrace);
    }
    return completer.future;
  }

  @DomName('Geolocation.watchPosition')
  Stream<Geoposition> watchPosition({bool enableHighAccuracy,
      Duration timeout, Duration maximumAge}) {

    var options = {};
    if (enableHighAccuracy != null) {
      options['enableHighAccuracy'] = enableHighAccuracy;
    }
    if (timeout != null) {
      options['timeout'] = timeout.inMilliseconds;
    }
    if (maximumAge != null) {
      options['maximumAge'] = maximumAge.inMilliseconds;
    }

    int watchId;
    var controller;
    controller = new StreamController<Geoposition>(
      onListen: () {
        assert(watchId == null);
        watchId = $dom_watchPosition(
            (position) {
              controller.add(_ensurePosition(position));
            },
            (error) {
              controller.addError(error);
            },
            options);
      },
      onCancel: () {
        assert(watchId != null);
        $dom_clearWatch(watchId);
      });

    return controller.stream;
  }

  Geoposition _ensurePosition(domPosition) {
    return domPosition;
  }

  Geolocation.internal();

  @DomName('Geolocation.clearWatch')
  @DocsEditable
  void $dom_clearWatch(int watchID) native "Geolocation_clearWatch_Callback";

  @DomName('Geolocation.getCurrentPosition')
  @DocsEditable
  void $dom_getCurrentPosition(_PositionCallback successCallback, [_PositionErrorCallback errorCallback, Object options]) native "Geolocation_getCurrentPosition_Callback";

  @DomName('Geolocation.watchPosition')
  @DocsEditable
  int $dom_watchPosition(_PositionCallback successCallback, [_PositionErrorCallback errorCallback, Object options]) native "Geolocation_watchPosition_Callback";
}



// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('Geoposition')
class Geoposition extends NativeFieldWrapperClass1 {
  Geoposition.internal();

  @DomName('Geoposition.coords')
  @DocsEditable
  Coordinates get coords native "Geoposition_coords_Getter";

  @DomName('Geoposition.timestamp')
  @DocsEditable
  int get timestamp native "Geoposition_timestamp_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
/**
 * An `<hr>` tag.
 */
@DomName('HTMLHRElement')
class HRElement extends _Element_Merged {
  HRElement.internal() : super.internal();

  @DomName('HTMLHRElement.HTMLHRElement')
  @DocsEditable
  factory HRElement() => document.$dom_createElement("hr");

}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.

@DomName('HashChangeEvent')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.FIREFOX)
@SupportedBrowser(SupportedBrowser.SAFARI)

class HashChangeEvent extends Event {
  factory HashChangeEvent(String type,
      {bool canBubble: true, bool cancelable: true, String oldUrl,
      String newUrl}) {
    var event = document.$dom_createEvent("HashChangeEvent");
    event.$dom_initHashChangeEvent(type, canBubble, cancelable, oldUrl, newUrl);
    return event;
  }
  HashChangeEvent.internal() : super.internal();

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('HashChangeEvent.newURL')
  @DocsEditable
  String get newUrl native "HashChangeEvent_newURL_Getter";

  @DomName('HashChangeEvent.oldURL')
  @DocsEditable
  String get oldUrl native "HashChangeEvent_oldURL_Getter";

  @DomName('HashChangeEvent.initHashChangeEvent')
  @DocsEditable
  void $dom_initHashChangeEvent(String type, bool canBubble, bool cancelable, String oldURL, String newURL) native "HashChangeEvent_initHashChangeEvent_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLHeadElement')
class HeadElement extends _Element_Merged {
  HeadElement.internal() : super.internal();

  @DomName('HTMLHeadElement.HTMLHeadElement')
  @DocsEditable
  factory HeadElement() => document.$dom_createElement("head");

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLHeadingElement')
class HeadingElement extends _Element_Merged {
  HeadingElement.internal() : super.internal();

  @DomName('HTMLHeadingElement.HTMLHeadingElement')
  @DocsEditable
  factory HeadingElement.h1() => document.$dom_createElement("h1");

  @DomName('HTMLHeadingElement.HTMLHeadingElement')
  @DocsEditable
  factory HeadingElement.h2() => document.$dom_createElement("h2");

  @DomName('HTMLHeadingElement.HTMLHeadingElement')
  @DocsEditable
  factory HeadingElement.h3() => document.$dom_createElement("h3");

  @DomName('HTMLHeadingElement.HTMLHeadingElement')
  @DocsEditable
  factory HeadingElement.h4() => document.$dom_createElement("h4");

  @DomName('HTMLHeadingElement.HTMLHeadingElement')
  @DocsEditable
  factory HeadingElement.h5() => document.$dom_createElement("h5");

  @DomName('HTMLHeadingElement.HTMLHeadingElement')
  @DocsEditable
  factory HeadingElement.h6() => document.$dom_createElement("h6");

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('History')
class History extends NativeFieldWrapperClass1 implements HistoryBase {

  /**
   * Checks if the State APIs are supported on the current platform.
   *
   * See also:
   *
   * * [pushState]
   * * [replaceState]
   * * [state]
   */
  static bool get supportsState => true;
  History.internal();

  @DomName('History.length')
  @DocsEditable
  int get length native "History_length_Getter";

  @DomName('History.state')
  @DocsEditable
  dynamic get state native "History_state_Getter";

  @DomName('History.back')
  @DocsEditable
  void back() native "History_back_Callback";

  @DomName('History.forward')
  @DocsEditable
  void forward() native "History_forward_Callback";

  @DomName('History.go')
  @DocsEditable
  void go(int distance) native "History_go_Callback";

  @DomName('History.pushState')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.FIREFOX)
  @SupportedBrowser(SupportedBrowser.IE, '10')
  @SupportedBrowser(SupportedBrowser.SAFARI)
  void pushState(Object data, String title, [String url]) native "History_pushState_Callback";

  @DomName('History.replaceState')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.FIREFOX)
  @SupportedBrowser(SupportedBrowser.IE, '10')
  @SupportedBrowser(SupportedBrowser.SAFARI)
  void replaceState(Object data, String title, [String url]) native "History_replaceState_Callback";
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLAllCollection')
class HtmlAllCollection extends NativeFieldWrapperClass1 with ListMixin<Node>, ImmutableListMixin<Node> implements List<Node> {
  HtmlAllCollection.internal();

  @DomName('HTMLAllCollection.length')
  @DocsEditable
  int get length native "HTMLAllCollection_length_Getter";

  Node operator[](int index) {
    if (index < 0 || index >= length)
      throw new RangeError.range(index, 0, length);
    return _nativeIndexedGetter(index);
  }
  Node _nativeIndexedGetter(int index) native "HTMLAllCollection_item_Callback";

  void operator[]=(int index, Node value) {
    throw new UnsupportedError("Cannot assign element of immutable List.");
  }
  // -- start List<Node> mixins.
  // Node is the element type.


  void set length(int value) {
    throw new UnsupportedError("Cannot resize immutable List.");
  }

  Node get first {
    if (this.length > 0) {
      return this[0];
    }
    throw new StateError("No elements");
  }

  Node get last {
    int len = this.length;
    if (len > 0) {
      return this[len - 1];
    }
    throw new StateError("No elements");
  }

  Node get single {
    int len = this.length;
    if (len == 1) {
      return this[0];
    }
    if (len == 0) throw new StateError("No elements");
    throw new StateError("More than one element");
  }

  Node elementAt(int index) => this[index];
  // -- end List<Node> mixins.

  @DomName('HTMLAllCollection.item')
  @DocsEditable
  Node item(int index) native "HTMLAllCollection_item_Callback";

  @DomName('HTMLAllCollection.namedItem')
  @DocsEditable
  Node namedItem(String name) native "HTMLAllCollection_namedItem_Callback";

  @DomName('HTMLAllCollection.tags')
  @DocsEditable
  List<Node> tags(String name) native "HTMLAllCollection_tags_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLCollection')
class HtmlCollection extends NativeFieldWrapperClass1 with ListMixin<Node>, ImmutableListMixin<Node> implements List<Node> {
  HtmlCollection.internal();

  @DomName('HTMLCollection.length')
  @DocsEditable
  int get length native "HTMLCollection_length_Getter";

  Node operator[](int index) {
    if (index < 0 || index >= length)
      throw new RangeError.range(index, 0, length);
    return _nativeIndexedGetter(index);
  }
  Node _nativeIndexedGetter(int index) native "HTMLCollection_item_Callback";

  void operator[]=(int index, Node value) {
    throw new UnsupportedError("Cannot assign element of immutable List.");
  }
  // -- start List<Node> mixins.
  // Node is the element type.


  void set length(int value) {
    throw new UnsupportedError("Cannot resize immutable List.");
  }

  Node get first {
    if (this.length > 0) {
      return this[0];
    }
    throw new StateError("No elements");
  }

  Node get last {
    int len = this.length;
    if (len > 0) {
      return this[len - 1];
    }
    throw new StateError("No elements");
  }

  Node get single {
    int len = this.length;
    if (len == 1) {
      return this[0];
    }
    if (len == 0) throw new StateError("No elements");
    throw new StateError("More than one element");
  }

  Node elementAt(int index) => this[index];
  // -- end List<Node> mixins.

  @DomName('HTMLCollection.item')
  @DocsEditable
  Node item(int index) native "HTMLCollection_item_Callback";

  @DomName('HTMLCollection.namedItem')
  @DocsEditable
  Node namedItem(String name) native "HTMLCollection_namedItem_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DomName('HTMLDocument')
class HtmlDocument extends Document {
  HtmlDocument.internal() : super.internal();

  @DomName('HTMLDocument.activeElement')
  @DocsEditable
  Element get activeElement native "HTMLDocument_activeElement_Getter";


  @DomName('Document.body')
  BodyElement get body => $dom_body;

  @DomName('Document.body')
  void set body(BodyElement value) {
    $dom_body = value;
  }

  @DomName('Document.caretRangeFromPoint')
  Range caretRangeFromPoint(int x, int y) {
    return $dom_caretRangeFromPoint(x, y);
  }

  @DomName('Document.elementFromPoint')
  Element elementFromPoint(int x, int y) {
    return $dom_elementFromPoint(x, y);
  }

  /**
   * Checks if the getCssCanvasContext API is supported on the current platform.
   *
   * See also:
   *
   * * [getCssCanvasContext]
   */
  static bool get supportsCssCanvasContext => true;


  /**
   * Gets a CanvasRenderingContext which can be used as the CSS background of an
   * element.
   *
   * CSS:
   *
   *     background: -webkit-canvas(backgroundCanvas)
   *
   * Generate the canvas:
   *
   *     var context = document.getCssCanvasContext('2d', 'backgroundCanvas',
   *         100, 100);
   *     context.fillStyle = 'red';
   *     context.fillRect(0, 0, 100, 100);
   *
   * See also:
   *
   * * [supportsCssCanvasContext]
   * * [CanvasElement.getContext]
   */
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  @DomName('Document.getCSSCanvasContext')
  CanvasRenderingContext getCssCanvasContext(String contextId, String name,
      int width, int height) {
    return $dom_getCssCanvasContext(contextId, name, width, height);
  }

  @DomName('Document.head')
  HeadElement get head => $dom_head;

  @DomName('Document.lastModified')
  String get lastModified => $dom_lastModified;

  @DomName('Document.preferredStylesheetSet')
  String get preferredStylesheetSet => $dom_preferredStylesheetSet;

  @DomName('Document.referrer')
  String get referrer => $dom_referrer;

  @DomName('Document.selectedStylesheetSet')
  String get selectedStylesheetSet => $dom_selectedStylesheetSet;
  void set selectedStylesheetSet(String value) {
    $dom_selectedStylesheetSet = value;
  }

  @DomName('Document.styleSheets')
  List<StyleSheet> get styleSheets => $dom_styleSheets;

  @DomName('Document.title')
  String get title => $dom_title;

  @DomName('Document.title')
  void set title(String value) {
    $dom_title = value;
  }

  @DomName('Document.webkitCancelFullScreen')
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void cancelFullScreen() {
    $dom_webkitCancelFullScreen();
  }

  @DomName('Document.webkitExitFullscreen')
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void exitFullscreen() {
    $dom_webkitExitFullscreen();
  }

  @DomName('Document.webkitExitPointerLock')
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void exitPointerLock() {
    $dom_webkitExitPointerLock();
  }

  @DomName('Document.webkitFullscreenElement')
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  Element get fullscreenElement => $dom_webkitFullscreenElement;

  @DomName('Document.webkitFullscreenEnabled')
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  bool get fullscreenEnabled => $dom_webkitFullscreenEnabled;

  @DomName('Document.webkitHidden')
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  bool get hidden => $dom_webkitHidden;

  @DomName('Document.webkitIsFullScreen')
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  bool get isFullScreen => $dom_webkitIsFullScreen;

  @DomName('Document.webkitPointerLockElement')
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  Element get pointerLockElement =>
      $dom_webkitPointerLockElement;

  @DomName('Document.webkitVisibilityState')
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  String get visibilityState => $dom_webkitVisibilityState;


  // Note: used to polyfill <template>
  Document _templateContentsOwner;
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLHtmlElement')
class HtmlElement extends _Element_Merged {
  HtmlElement.internal() : super.internal();

  @DomName('HTMLHtmlElement.HTMLHtmlElement')
  @DocsEditable
  factory HtmlElement() => document.$dom_createElement("html");

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLFormControlsCollection')
class HtmlFormControlsCollection extends HtmlCollection {
  HtmlFormControlsCollection.internal() : super.internal();

  @DomName('HTMLFormControlsCollection.namedItem')
  @DocsEditable
  Node namedItem(String name) native "HTMLFormControlsCollection_namedItem_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLOptionsCollection')
class HtmlOptionsCollection extends HtmlCollection {
  HtmlOptionsCollection.internal() : super.internal();

  @DomName('HTMLOptionsCollection.numericIndexGetter')
  @DocsEditable
  Node operator[](int index) native "HTMLOptionsCollection_numericIndexGetter_Callback";

  @DomName('HTMLOptionsCollection.numericIndexSetter')
  @DocsEditable
  void operator[]=(int index, Node value) native "HTMLOptionsCollection_numericIndexSetter_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/**
 * A utility for retrieving data from a URL.
 *
 * HttpRequest can be used to obtain data from http, ftp, and file
 * protocols.
 *
 * For example, suppose we're developing these API docs, and we
 * wish to retrieve the HTML of the top-level page and print it out.
 * The easiest way to do that would be:
 *
 *     HttpRequest.getString('http://api.dartlang.org').then((response) {
 *       print(response);
 *     });
 *
 * **Important**: With the default behavior of this class, your
 * code making the request should be served from the same origin (domain name,
 * port, and application layer protocol) as the URL you are trying to access
 * with HttpRequest. However, there are ways to
 * [get around this restriction](http://www.dartlang.org/articles/json-web-service/#note-on-jsonp).
 *
 * See also:
 *
 * * [Dart article on using HttpRequests](http://www.dartlang.org/articles/json-web-service/#getting-data)
 * * [JS XMLHttpRequest](https://developer.mozilla.org/en-US/docs/DOM/XMLHttpRequest)
 * * [Using XMLHttpRequest](https://developer.mozilla.org/en-US/docs/DOM/XMLHttpRequest/Using_XMLHttpRequest)
 */
@DomName('XMLHttpRequest')
class HttpRequest extends EventTarget {

  /**
   * Creates a URL get request for the specified [url].
   *
   * The server response must be a `text/` mime type for this request to
   * succeed.
   *
   * This is similar to [request] but specialized for HTTP GET requests which
   * return text content.
   *
   * See also:
   *
   * * [request]
   */
  static Future<String> getString(String url,
      {bool withCredentials, void onProgress(ProgressEvent e)}) {
    return request(url, withCredentials: withCredentials,
        onProgress: onProgress).then((xhr) => xhr.responseText);
  }

  /**
   * Creates a URL request for the specified [url].
   *
   * By default this will do an HTTP GET request, this can be overridden with
   * [method].
   *
   * The Future is completed when the response is available.
   *
   * The [withCredentials] parameter specified that credentials such as a cookie
   * (already) set in the header or
   * [authorization headers](http://tools.ietf.org/html/rfc1945#section-10.2)
   * should be specified for the request. Details to keep in mind when using
   * credentials:
   *
   * * Using credentials is only useful for cross-origin requests.
   * * The `Access-Control-Allow-Origin` header of `url` cannot contain a wildcard (*).
   * * The `Access-Control-Allow-Credentials` header of `url` must be set to true.
   * * If `Access-Control-Expose-Headers` has not been set to true, only a subset of all the response headers will be returned when calling [getAllRequestHeaders].
   *
   * Note that requests for file:// URIs are only supported by Chrome extensions
   * with appropriate permissions in their manifest. Requests to file:// URIs
   * will also never fail- the Future will always complete successfully, even
   * when the file cannot be found.
   *
   * See also: [authorization headers](http://en.wikipedia.org/wiki/Basic_access_authentication).
   */
  static Future<HttpRequest> request(String url,
      {String method, bool withCredentials, String responseType,
      String mimeType, Map<String, String> requestHeaders, sendData,
      void onProgress(ProgressEvent e)}) {
    var completer = new Completer<HttpRequest>();

    var xhr = new HttpRequest();
    if (method == null) {
      method = 'GET';
    }
    xhr.open(method, url, async: true);

    if (withCredentials != null) {
      xhr.withCredentials = withCredentials;
    }

    if (responseType != null) {
      xhr.responseType = responseType;
    }

    if (mimeType != null) {
      xhr.overrideMimeType(mimeType);
    }

    if (requestHeaders != null) {
      requestHeaders.forEach((header, value) {
        xhr.setRequestHeader(header, value);
      });
    }

    if (onProgress != null) {
      xhr.onProgress.listen(onProgress);
    }

    xhr.onLoad.listen((e) {
      // Note: file:// URIs have status of 0.
      if ((xhr.status >= 200 && xhr.status < 300) ||
          xhr.status == 0 || xhr.status == 304) {
        completer.complete(xhr);
      } else {
        completer.completeError(e);
      }
    });

    xhr.onError.listen((e) {
      completer.completeError(e);
    });

    if (sendData != null) {
      xhr.send(sendData);
    } else {
      xhr.send();
    }

    return completer.future;
  }

  /**
   * Checks to see if the Progress event is supported on the current platform.
   */
  static bool get supportsProgressEvent {
    return true;
  }

  /**
   * Checks to see if the current platform supports making cross origin
   * requests.
   *
   * Note that even if cross origin requests are supported, they still may fail
   * if the destination server does not support CORS requests.
   */
  static bool get supportsCrossOrigin {
    return true;
  }

  /**
   * Checks to see if the LoadEnd event is supported on the current platform.
   */
  static bool get supportsLoadEndEvent {
    return true;
  }

  /**
   * Checks to see if the overrideMimeType method is supported on the current
   * platform.
   */
  static bool get supportsOverrideMimeType {
    return true;
  }

  HttpRequest.internal() : super.internal();

  @DomName('XMLHttpRequest.abortEvent')
  @DocsEditable
  static const EventStreamProvider<ProgressEvent> abortEvent = const EventStreamProvider<ProgressEvent>('abort');

  @DomName('XMLHttpRequest.errorEvent')
  @DocsEditable
  static const EventStreamProvider<ProgressEvent> errorEvent = const EventStreamProvider<ProgressEvent>('error');

  @DomName('XMLHttpRequest.loadEvent')
  @DocsEditable
  static const EventStreamProvider<ProgressEvent> loadEvent = const EventStreamProvider<ProgressEvent>('load');

  @DomName('XMLHttpRequest.loadendEvent')
  @DocsEditable
  static const EventStreamProvider<ProgressEvent> loadEndEvent = const EventStreamProvider<ProgressEvent>('loadend');

  @DomName('XMLHttpRequest.loadstartEvent')
  @DocsEditable
  static const EventStreamProvider<ProgressEvent> loadStartEvent = const EventStreamProvider<ProgressEvent>('loadstart');

  @DomName('XMLHttpRequest.progressEvent')
  @DocsEditable
  static const EventStreamProvider<ProgressEvent> progressEvent = const EventStreamProvider<ProgressEvent>('progress');

  @DomName('XMLHttpRequest.readystatechangeEvent')
  @DocsEditable
  static const EventStreamProvider<ProgressEvent> readyStateChangeEvent = const EventStreamProvider<ProgressEvent>('readystatechange');
  factory HttpRequest() => _create();

  @DocsEditable
  static HttpRequest _create() native "XMLHttpRequest_constructorCallback";

  @DomName('XMLHttpRequest.DONE')
  @DocsEditable
  static const int DONE = 4;

  @DomName('XMLHttpRequest.HEADERS_RECEIVED')
  @DocsEditable
  static const int HEADERS_RECEIVED = 2;

  @DomName('XMLHttpRequest.LOADING')
  @DocsEditable
  static const int LOADING = 3;

  @DomName('XMLHttpRequest.OPENED')
  @DocsEditable
  static const int OPENED = 1;

  @DomName('XMLHttpRequest.UNSENT')
  @DocsEditable
  static const int UNSENT = 0;

  /**
   * Indicator of the current state of the request:
   *
   * <table>
   *   <tr>
   *     <td>Value</td>
   *     <td>State</td>
   *     <td>Meaning</td>
   *   </tr>
   *   <tr>
   *     <td>0</td>
   *     <td>unsent</td>
   *     <td><code>open()</code> has not yet been called</td>
   *   </tr>
   *   <tr>
   *     <td>1</td>
   *     <td>opened</td>
   *     <td><code>send()</code> has not yet been called</td>
   *   </tr>
   *   <tr>
   *     <td>2</td>
   *     <td>headers received</td>
   *     <td><code>sent()</code> has been called; response headers and <code>status</code> are available</td>
   *   </tr>
   *   <tr>
   *     <td>3</td> <td>loading</td> <td><code>responseText</code> holds some data</td>
   *   </tr>
   *   <tr>
   *     <td>4</td> <td>done</td> <td>request is complete</td>
   *   </tr>
   * </table>
   */
  @DomName('XMLHttpRequest.readyState')
  @DocsEditable
  int get readyState native "XMLHttpRequest_readyState_Getter";

  /**
   * The data received as a reponse from the request.
   *
   * The data could be in the
   * form of a [String], [ArrayBuffer], [Document], [Blob], or json (also a
   * [String]). `null` indicates request failure.
   */
  @DomName('XMLHttpRequest.response')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.FIREFOX)
  @SupportedBrowser(SupportedBrowser.IE, '10')
  @SupportedBrowser(SupportedBrowser.SAFARI)
  Object get response native "XMLHttpRequest_response_Getter";

  /**
   * The response in string form or `null on failure.
   */
  @DomName('XMLHttpRequest.responseText')
  @DocsEditable
  String get responseText native "XMLHttpRequest_responseText_Getter";

  /**
   * [String] telling the server the desired response format.
   *
   * Default is `String`.
   * Other options are one of 'arraybuffer', 'blob', 'document', 'json',
   * 'text'. Some newer browsers will throw NS_ERROR_DOM_INVALID_ACCESS_ERR if
   * `responseType` is set while performing a synchronous request.
   *
   * See also: [MDN responseType](https://developer.mozilla.org/en-US/docs/DOM/XMLHttpRequest#responseType)
   */
  @DomName('XMLHttpRequest.responseType')
  @DocsEditable
  String get responseType native "XMLHttpRequest_responseType_Getter";

  /**
   * [String] telling the server the desired response format.
   *
   * Default is `String`.
   * Other options are one of 'arraybuffer', 'blob', 'document', 'json',
   * 'text'. Some newer browsers will throw NS_ERROR_DOM_INVALID_ACCESS_ERR if
   * `responseType` is set while performing a synchronous request.
   *
   * See also: [MDN responseType](https://developer.mozilla.org/en-US/docs/DOM/XMLHttpRequest#responseType)
   */
  @DomName('XMLHttpRequest.responseType')
  @DocsEditable
  void set responseType(String value) native "XMLHttpRequest_responseType_Setter";

  /**
   * The request response, or null on failure.
   *
   * The response is processed as
   * `text/xml` stream, unless responseType = 'document' and the request is
   * synchronous.
   */
  @DomName('XMLHttpRequest.responseXML')
  @DocsEditable
  Document get responseXml native "XMLHttpRequest_responseXML_Getter";

  /**
   * The http result code from the request (200, 404, etc).
   * See also: [Http Status Codes](http://en.wikipedia.org/wiki/List_of_HTTP_status_codes)
   */
  @DomName('XMLHttpRequest.status')
  @DocsEditable
  int get status native "XMLHttpRequest_status_Getter";

  /**
   * The request response string (such as \"200 OK\").
   * See also: [Http Status Codes](http://en.wikipedia.org/wiki/List_of_HTTP_status_codes)
   */
  @DomName('XMLHttpRequest.statusText')
  @DocsEditable
  String get statusText native "XMLHttpRequest_statusText_Getter";

  /**
   * [EventTarget] that can hold listeners to track the progress of the request.
   * The events fired will be members of [HttpRequestUploadEvents].
   */
  @DomName('XMLHttpRequest.upload')
  @DocsEditable
  HttpRequestUpload get upload native "XMLHttpRequest_upload_Getter";

  /**
   * True if cross-site requests should use credentials such as cookies
   * or authorization headers; false otherwise.
   *
   * This value is ignored for same-site requests.
   */
  @DomName('XMLHttpRequest.withCredentials')
  @DocsEditable
  bool get withCredentials native "XMLHttpRequest_withCredentials_Getter";

  /**
   * True if cross-site requests should use credentials such as cookies
   * or authorization headers; false otherwise.
   *
   * This value is ignored for same-site requests.
   */
  @DomName('XMLHttpRequest.withCredentials')
  @DocsEditable
  void set withCredentials(bool value) native "XMLHttpRequest_withCredentials_Setter";

  /**
   * Stop the current request.
   *
   * The request can only be stopped if readyState is `HEADERS_RECIEVED` or
   * `LOADING`. If this method is not in the process of being sent, the method
   * has no effect.
   */
  @DomName('XMLHttpRequest.abort')
  @DocsEditable
  void abort() native "XMLHttpRequest_abort_Callback";

  @DomName('XMLHttpRequest.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "XMLHttpRequest_addEventListener_Callback";

  @DomName('XMLHttpRequest.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event evt) native "XMLHttpRequest_dispatchEvent_Callback";

  /**
   * Retrieve all the response headers from a request.
   *
   * `null` if no headers have been received. For multipart requests,
   * `getAllResponseHeaders` will return the response headers for the current
   * part of the request.
   *
   * See also [HTTP response headers](http://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Responses)
   * for a list of common response headers.
   */
  @DomName('XMLHttpRequest.getAllResponseHeaders')
  @DocsEditable
  String getAllResponseHeaders() native "XMLHttpRequest_getAllResponseHeaders_Callback";

  /**
   * Return the response header named `header`, or `null` if not found.
   *
   * See also [HTTP response headers](http://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Responses)
   * for a list of common response headers.
   */
  @DomName('XMLHttpRequest.getResponseHeader')
  @DocsEditable
  String getResponseHeader(String header) native "XMLHttpRequest_getResponseHeader_Callback";

  /**
   * Specify the desired `url`, and `method` to use in making the request.
   *
   * By default the request is done asyncronously, with no user or password
   * authentication information. If `async` is false, the request will be send
   * synchronously.
   *
   * Calling `open` again on a currently active request is equivalent to
   * calling `abort`.
   */
  @DomName('XMLHttpRequest.open')
  @DocsEditable
  void open(String method, String url, {bool async, String user, String password}) native "XMLHttpRequest_open_Callback";

  /**
   * Specify a particular MIME type (such as `text/xml`) desired for the
   * response.
   *
   * This value must be set before the request has been sent. See also the list
   * of [common MIME types](http://en.wikipedia.org/wiki/Internet_media_type#List_of_common_media_types)
   */
  @DomName('XMLHttpRequest.overrideMimeType')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.FIREFOX)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  void overrideMimeType(String override) native "XMLHttpRequest_overrideMimeType_Callback";

  @DomName('XMLHttpRequest.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "XMLHttpRequest_removeEventListener_Callback";

  /**
   * Send the request with any given `data`.
   *
   * See also:
   *
   *   * [send](https://developer.mozilla.org/en-US/docs/DOM/XMLHttpRequest#send%28%29)
   * from MDN.
   */
  @DomName('XMLHttpRequest.send')
  @DocsEditable
  void send([data]) native "XMLHttpRequest_send_Callback";

  @DomName('XMLHttpRequest.setRequestHeader')
  @DocsEditable
  void setRequestHeader(String header, String value) native "XMLHttpRequest_setRequestHeader_Callback";

  /**
   * Event listeners to be notified when request has been aborted,
   * generally due to calling `httpRequest.abort()`.
   */
  @DomName('XMLHttpRequest.onabort')
  @DocsEditable
  Stream<ProgressEvent> get onAbort => abortEvent.forTarget(this);

  /**
   * Event listeners to be notified when a request has failed, such as when a
   * cross-domain error occurred or the file wasn't found on the server.
   */
  @DomName('XMLHttpRequest.onerror')
  @DocsEditable
  Stream<ProgressEvent> get onError => errorEvent.forTarget(this);

  /**
   * Event listeners to be notified once the request has completed
   * *successfully*.
   */
  @DomName('XMLHttpRequest.onload')
  @DocsEditable
  Stream<ProgressEvent> get onLoad => loadEvent.forTarget(this);

  /**
   * Event listeners to be notified once the request has completed (on
   * either success or failure).
   */
  @DomName('XMLHttpRequest.onloadend')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.FIREFOX)
  @SupportedBrowser(SupportedBrowser.IE, '10')
  @SupportedBrowser(SupportedBrowser.SAFARI)
  Stream<ProgressEvent> get onLoadEnd => loadEndEvent.forTarget(this);

  /**
   * Event listeners to be notified when the request starts, once
   * `httpRequest.send()` has been called.
   */
  @DomName('XMLHttpRequest.onloadstart')
  @DocsEditable
  Stream<ProgressEvent> get onLoadStart => loadStartEvent.forTarget(this);

  /**
   * Event listeners to be notified when data for the request
   * is being sent or loaded.
   *
   * Progress events are fired every 50ms or for every byte transmitted,
   * whichever is less frequent.
   */
  @DomName('XMLHttpRequest.onprogress')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.FIREFOX)
  @SupportedBrowser(SupportedBrowser.IE, '10')
  @SupportedBrowser(SupportedBrowser.SAFARI)
  Stream<ProgressEvent> get onProgress => progressEvent.forTarget(this);

  /**
   * Event listeners to be notified every time the [HttpRequest]
   * object's `readyState` changes values.
   */
  @DomName('XMLHttpRequest.onreadystatechange')
  @DocsEditable
  Stream<ProgressEvent> get onReadyStateChange => readyStateChangeEvent.forTarget(this);

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('XMLHttpRequestException')
class HttpRequestException extends NativeFieldWrapperClass1 {
  HttpRequestException.internal();

  @DomName('XMLHttpRequestException.ABORT_ERR')
  @DocsEditable
  static const int ABORT_ERR = 102;

  @DomName('XMLHttpRequestException.NETWORK_ERR')
  @DocsEditable
  static const int NETWORK_ERR = 101;

  @DomName('XMLHttpRequestException.code')
  @DocsEditable
  int get code native "XMLHttpRequestException_code_Getter";

  @DomName('XMLHttpRequestException.message')
  @DocsEditable
  String get message native "XMLHttpRequestException_message_Getter";

  @DomName('XMLHttpRequestException.name')
  @DocsEditable
  String get name native "XMLHttpRequestException_name_Getter";

  @DomName('XMLHttpRequestException.toString')
  @DocsEditable
  String toString() native "XMLHttpRequestException_toString_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('XMLHttpRequestProgressEvent')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.SAFARI)
@Experimental
class HttpRequestProgressEvent extends ProgressEvent {
  HttpRequestProgressEvent.internal() : super.internal();

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('XMLHttpRequestProgressEvent.position')
  @DocsEditable
  int get position native "XMLHttpRequestProgressEvent_position_Getter";

  @DomName('XMLHttpRequestProgressEvent.totalSize')
  @DocsEditable
  int get totalSize native "XMLHttpRequestProgressEvent_totalSize_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('XMLHttpRequestUpload')
class HttpRequestUpload extends EventTarget {
  HttpRequestUpload.internal() : super.internal();

  @DomName('XMLHttpRequestUpload.abortEvent')
  @DocsEditable
  static const EventStreamProvider<ProgressEvent> abortEvent = const EventStreamProvider<ProgressEvent>('abort');

  @DomName('XMLHttpRequestUpload.errorEvent')
  @DocsEditable
  static const EventStreamProvider<ProgressEvent> errorEvent = const EventStreamProvider<ProgressEvent>('error');

  @DomName('XMLHttpRequestUpload.loadEvent')
  @DocsEditable
  static const EventStreamProvider<ProgressEvent> loadEvent = const EventStreamProvider<ProgressEvent>('load');

  @DomName('XMLHttpRequestUpload.loadendEvent')
  @DocsEditable
  static const EventStreamProvider<ProgressEvent> loadEndEvent = const EventStreamProvider<ProgressEvent>('loadend');

  @DomName('XMLHttpRequestUpload.loadstartEvent')
  @DocsEditable
  static const EventStreamProvider<ProgressEvent> loadStartEvent = const EventStreamProvider<ProgressEvent>('loadstart');

  @DomName('XMLHttpRequestUpload.progressEvent')
  @DocsEditable
  static const EventStreamProvider<ProgressEvent> progressEvent = const EventStreamProvider<ProgressEvent>('progress');

  @DomName('XMLHttpRequestUpload.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "XMLHttpRequestUpload_addEventListener_Callback";

  @DomName('XMLHttpRequestUpload.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event evt) native "XMLHttpRequestUpload_dispatchEvent_Callback";

  @DomName('XMLHttpRequestUpload.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "XMLHttpRequestUpload_removeEventListener_Callback";

  @DomName('XMLHttpRequestUpload.onabort')
  @DocsEditable
  Stream<ProgressEvent> get onAbort => abortEvent.forTarget(this);

  @DomName('XMLHttpRequestUpload.onerror')
  @DocsEditable
  Stream<ProgressEvent> get onError => errorEvent.forTarget(this);

  @DomName('XMLHttpRequestUpload.onload')
  @DocsEditable
  Stream<ProgressEvent> get onLoad => loadEvent.forTarget(this);

  @DomName('XMLHttpRequestUpload.onloadend')
  @DocsEditable
  Stream<ProgressEvent> get onLoadEnd => loadEndEvent.forTarget(this);

  @DomName('XMLHttpRequestUpload.onloadstart')
  @DocsEditable
  Stream<ProgressEvent> get onLoadStart => loadStartEvent.forTarget(this);

  @DomName('XMLHttpRequestUpload.onprogress')
  @DocsEditable
  Stream<ProgressEvent> get onProgress => progressEvent.forTarget(this);

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLIFrameElement')
class IFrameElement extends _Element_Merged {
  IFrameElement.internal() : super.internal();

  @DomName('HTMLIFrameElement.HTMLIFrameElement')
  @DocsEditable
  factory IFrameElement() => document.$dom_createElement("iframe");

  @DomName('HTMLIFrameElement.contentWindow')
  @DocsEditable
  WindowBase get contentWindow native "HTMLIFrameElement_contentWindow_Getter";

  @DomName('HTMLIFrameElement.height')
  @DocsEditable
  String get height native "HTMLIFrameElement_height_Getter";

  @DomName('HTMLIFrameElement.height')
  @DocsEditable
  void set height(String value) native "HTMLIFrameElement_height_Setter";

  @DomName('HTMLIFrameElement.name')
  @DocsEditable
  String get name native "HTMLIFrameElement_name_Getter";

  @DomName('HTMLIFrameElement.name')
  @DocsEditable
  void set name(String value) native "HTMLIFrameElement_name_Setter";

  @DomName('HTMLIFrameElement.sandbox')
  @DocsEditable
  String get sandbox native "HTMLIFrameElement_sandbox_Getter";

  @DomName('HTMLIFrameElement.sandbox')
  @DocsEditable
  void set sandbox(String value) native "HTMLIFrameElement_sandbox_Setter";

  @DomName('HTMLIFrameElement.seamless')
  @DocsEditable
  bool get seamless native "HTMLIFrameElement_seamless_Getter";

  @DomName('HTMLIFrameElement.seamless')
  @DocsEditable
  void set seamless(bool value) native "HTMLIFrameElement_seamless_Setter";

  @DomName('HTMLIFrameElement.src')
  @DocsEditable
  String get src native "HTMLIFrameElement_src_Getter";

  @DomName('HTMLIFrameElement.src')
  @DocsEditable
  void set src(String value) native "HTMLIFrameElement_src_Setter";

  @DomName('HTMLIFrameElement.srcdoc')
  @DocsEditable
  String get srcdoc native "HTMLIFrameElement_srcdoc_Getter";

  @DomName('HTMLIFrameElement.srcdoc')
  @DocsEditable
  void set srcdoc(String value) native "HTMLIFrameElement_srcdoc_Setter";

  @DomName('HTMLIFrameElement.width')
  @DocsEditable
  String get width native "HTMLIFrameElement_width_Getter";

  @DomName('HTMLIFrameElement.width')
  @DocsEditable
  void set width(String value) native "HTMLIFrameElement_width_Setter";

}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@DomName('ImageData')

class ImageData extends NativeFieldWrapperClass1 {
  List<int> __data;

  List<int> get data {
    if (__data == null) {
      __data = _data;
    }
    return __data;
  }

  ImageData.internal();

  @DomName('ImageData.data')
  @DocsEditable
  List<int> get _data native "ImageData_data_Getter";

  @DomName('ImageData.height')
  @DocsEditable
  int get height native "ImageData_height_Getter";

  @DomName('ImageData.width')
  @DocsEditable
  int get width native "ImageData_width_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('HTMLImageElement')
class ImageElement extends _Element_Merged implements CanvasImageSource {
  ImageElement.internal() : super.internal();

  @DomName('HTMLImageElement.HTMLImageElement')
  @DocsEditable
  factory ImageElement({String src, int width, int height}) {
    var e = document.$dom_createElement("img");
    if (src != null) e.src = src;
    if (width != null) e.width = width;
    if (height != null) e.height = height;
    return e;
  }

  @DomName('HTMLImageElement.alt')
  @DocsEditable
  String get alt native "HTMLImageElement_alt_Getter";

  @DomName('HTMLImageElement.alt')
  @DocsEditable
  void set alt(String value) native "HTMLImageElement_alt_Setter";

  @DomName('HTMLImageElement.border')
  @DocsEditable
  String get border native "HTMLImageElement_border_Getter";

  @DomName('HTMLImageElement.border')
  @DocsEditable
  void set border(String value) native "HTMLImageElement_border_Setter";

  @DomName('HTMLImageElement.complete')
  @DocsEditable
  bool get complete native "HTMLImageElement_complete_Getter";

  @DomName('HTMLImageElement.crossOrigin')
  @DocsEditable
  String get crossOrigin native "HTMLImageElement_crossOrigin_Getter";

  @DomName('HTMLImageElement.crossOrigin')
  @DocsEditable
  void set crossOrigin(String value) native "HTMLImageElement_crossOrigin_Setter";

  @DomName('HTMLImageElement.height')
  @DocsEditable
  int get height native "HTMLImageElement_height_Getter";

  @DomName('HTMLImageElement.height')
  @DocsEditable
  void set height(int value) native "HTMLImageElement_height_Setter";

  @DomName('HTMLImageElement.isMap')
  @DocsEditable
  bool get isMap native "HTMLImageElement_isMap_Getter";

  @DomName('HTMLImageElement.isMap')
  @DocsEditable
  void set isMap(bool value) native "HTMLImageElement_isMap_Setter";

  @DomName('HTMLImageElement.lowsrc')
  @DocsEditable
  String get lowsrc native "HTMLImageElement_lowsrc_Getter";

  @DomName('HTMLImageElement.lowsrc')
  @DocsEditable
  void set lowsrc(String value) native "HTMLImageElement_lowsrc_Setter";

  @DomName('HTMLImageElement.naturalHeight')
  @DocsEditable
  int get naturalHeight native "HTMLImageElement_naturalHeight_Getter";

  @DomName('HTMLImageElement.naturalWidth')
  @DocsEditable
  int get naturalWidth native "HTMLImageElement_naturalWidth_Getter";

  @DomName('HTMLImageElement.src')
  @DocsEditable
  String get src native "HTMLImageElement_src_Getter";

  @DomName('HTMLImageElement.src')
  @DocsEditable
  void set src(String value) native "HTMLImageElement_src_Setter";

  @DomName('HTMLImageElement.useMap')
  @DocsEditable
  String get useMap native "HTMLImageElement_useMap_Getter";

  @DomName('HTMLImageElement.useMap')
  @DocsEditable
  void set useMap(String value) native "HTMLImageElement_useMap_Setter";

  @DomName('HTMLImageElement.width')
  @DocsEditable
  int get width native "HTMLImageElement_width_Getter";

  @DomName('HTMLImageElement.width')
  @DocsEditable
  void set width(int value) native "HTMLImageElement_width_Setter";

  @DomName('HTMLImageElement.x')
  @DocsEditable
  int get x native "HTMLImageElement_x_Getter";

  @DomName('HTMLImageElement.y')
  @DocsEditable
  int get y native "HTMLImageElement_y_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('HTMLInputElement')
class InputElement extends _Element_Merged implements
    HiddenInputElement,
    SearchInputElement,
    TextInputElement,
    UrlInputElement,
    TelephoneInputElement,
    EmailInputElement,
    PasswordInputElement,
    DateInputElement,
    MonthInputElement,
    WeekInputElement,
    TimeInputElement,
    LocalDateTimeInputElement,
    NumberInputElement,
    RangeInputElement,
    CheckboxInputElement,
    RadioButtonInputElement,
    FileUploadInputElement,
    SubmitButtonInputElement,
    ImageButtonInputElement,
    ResetButtonInputElement,
    ButtonInputElement
     {

  factory InputElement({String type}) {
    var e = document.$dom_createElement("input");
    if (type != null) {
      try {
        // IE throws an exception for unknown types.
        e.type = type;
      } catch(_) {}
    }
    return e;
  }

  _ValueBinding _valueBinding;

  _CheckedBinding _checkedBinding;

  @Experimental
  void bind(String name, model, String path) {
    switch (name) {
      case 'value':
        unbind('value');
        attributes.remove('value');
        _valueBinding = new _ValueBinding(this, model, path);
        break;
      case 'checked':
        unbind('checked');
        attributes.remove('checked');
        _checkedBinding = new _CheckedBinding(this, model, path);
        break;
      default:
        // TODO(jmesserly): this should be "super" (http://dartbug.com/10166).
        // Similar issue for unbind/unbindAll below.
        Element._bindElement(this, name, model, path);
        break;
    }
  }

  @Experimental
  void unbind(String name) {
    switch (name) {
      case 'value':
        if (_valueBinding != null) {
          _valueBinding.unbind();
          _valueBinding = null;
        }
        break;
      case 'checked':
        if (_checkedBinding != null) {
          _checkedBinding.unbind();
          _checkedBinding = null;
        }
        break;
      default:
        Element._unbindElement(this, name);
        break;
    }
  }

  @Experimental
  void unbindAll() {
    unbind('value');
    unbind('checked');
    Element._unbindAllElement(this);
  }

  InputElement.internal() : super.internal();

  @DomName('HTMLInputElement.webkitSpeechChangeEvent')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  static const EventStreamProvider<Event> speechChangeEvent = const EventStreamProvider<Event>('webkitSpeechChange');

  @DomName('HTMLInputElement.accept')
  @DocsEditable
  String get accept native "HTMLInputElement_accept_Getter";

  @DomName('HTMLInputElement.accept')
  @DocsEditable
  void set accept(String value) native "HTMLInputElement_accept_Setter";

  @DomName('HTMLInputElement.alt')
  @DocsEditable
  String get alt native "HTMLInputElement_alt_Getter";

  @DomName('HTMLInputElement.alt')
  @DocsEditable
  void set alt(String value) native "HTMLInputElement_alt_Setter";

  @DomName('HTMLInputElement.autocomplete')
  @DocsEditable
  String get autocomplete native "HTMLInputElement_autocomplete_Getter";

  @DomName('HTMLInputElement.autocomplete')
  @DocsEditable
  void set autocomplete(String value) native "HTMLInputElement_autocomplete_Setter";

  @DomName('HTMLInputElement.autofocus')
  @DocsEditable
  bool get autofocus native "HTMLInputElement_autofocus_Getter";

  @DomName('HTMLInputElement.autofocus')
  @DocsEditable
  void set autofocus(bool value) native "HTMLInputElement_autofocus_Setter";

  @DomName('HTMLInputElement.checked')
  @DocsEditable
  bool get checked native "HTMLInputElement_checked_Getter";

  @DomName('HTMLInputElement.checked')
  @DocsEditable
  void set checked(bool value) native "HTMLInputElement_checked_Setter";

  @DomName('HTMLInputElement.defaultChecked')
  @DocsEditable
  bool get defaultChecked native "HTMLInputElement_defaultChecked_Getter";

  @DomName('HTMLInputElement.defaultChecked')
  @DocsEditable
  void set defaultChecked(bool value) native "HTMLInputElement_defaultChecked_Setter";

  @DomName('HTMLInputElement.defaultValue')
  @DocsEditable
  String get defaultValue native "HTMLInputElement_defaultValue_Getter";

  @DomName('HTMLInputElement.defaultValue')
  @DocsEditable
  void set defaultValue(String value) native "HTMLInputElement_defaultValue_Setter";

  @DomName('HTMLInputElement.dirName')
  @DocsEditable
  String get dirName native "HTMLInputElement_dirName_Getter";

  @DomName('HTMLInputElement.dirName')
  @DocsEditable
  void set dirName(String value) native "HTMLInputElement_dirName_Setter";

  @DomName('HTMLInputElement.disabled')
  @DocsEditable
  bool get disabled native "HTMLInputElement_disabled_Getter";

  @DomName('HTMLInputElement.disabled')
  @DocsEditable
  void set disabled(bool value) native "HTMLInputElement_disabled_Setter";

  @DomName('HTMLInputElement.files')
  @DocsEditable
  List<File> get files native "HTMLInputElement_files_Getter";

  @DomName('HTMLInputElement.files')
  @DocsEditable
  void set files(List<File> value) native "HTMLInputElement_files_Setter";

  @DomName('HTMLInputElement.form')
  @DocsEditable
  FormElement get form native "HTMLInputElement_form_Getter";

  @DomName('HTMLInputElement.formAction')
  @DocsEditable
  String get formAction native "HTMLInputElement_formAction_Getter";

  @DomName('HTMLInputElement.formAction')
  @DocsEditable
  void set formAction(String value) native "HTMLInputElement_formAction_Setter";

  @DomName('HTMLInputElement.formEnctype')
  @DocsEditable
  String get formEnctype native "HTMLInputElement_formEnctype_Getter";

  @DomName('HTMLInputElement.formEnctype')
  @DocsEditable
  void set formEnctype(String value) native "HTMLInputElement_formEnctype_Setter";

  @DomName('HTMLInputElement.formMethod')
  @DocsEditable
  String get formMethod native "HTMLInputElement_formMethod_Getter";

  @DomName('HTMLInputElement.formMethod')
  @DocsEditable
  void set formMethod(String value) native "HTMLInputElement_formMethod_Setter";

  @DomName('HTMLInputElement.formNoValidate')
  @DocsEditable
  bool get formNoValidate native "HTMLInputElement_formNoValidate_Getter";

  @DomName('HTMLInputElement.formNoValidate')
  @DocsEditable
  void set formNoValidate(bool value) native "HTMLInputElement_formNoValidate_Setter";

  @DomName('HTMLInputElement.formTarget')
  @DocsEditable
  String get formTarget native "HTMLInputElement_formTarget_Getter";

  @DomName('HTMLInputElement.formTarget')
  @DocsEditable
  void set formTarget(String value) native "HTMLInputElement_formTarget_Setter";

  @DomName('HTMLInputElement.height')
  @DocsEditable
  int get height native "HTMLInputElement_height_Getter";

  @DomName('HTMLInputElement.height')
  @DocsEditable
  void set height(int value) native "HTMLInputElement_height_Setter";

  @DomName('HTMLInputElement.incremental')
  @DocsEditable
  bool get incremental native "HTMLInputElement_incremental_Getter";

  @DomName('HTMLInputElement.incremental')
  @DocsEditable
  void set incremental(bool value) native "HTMLInputElement_incremental_Setter";

  @DomName('HTMLInputElement.indeterminate')
  @DocsEditable
  bool get indeterminate native "HTMLInputElement_indeterminate_Getter";

  @DomName('HTMLInputElement.indeterminate')
  @DocsEditable
  void set indeterminate(bool value) native "HTMLInputElement_indeterminate_Setter";

  @DomName('HTMLInputElement.labels')
  @DocsEditable
  List<Node> get labels native "HTMLInputElement_labels_Getter";

  @DomName('HTMLInputElement.list')
  @DocsEditable
  Element get list native "HTMLInputElement_list_Getter";

  @DomName('HTMLInputElement.max')
  @DocsEditable
  String get max native "HTMLInputElement_max_Getter";

  @DomName('HTMLInputElement.max')
  @DocsEditable
  void set max(String value) native "HTMLInputElement_max_Setter";

  @DomName('HTMLInputElement.maxLength')
  @DocsEditable
  int get maxLength native "HTMLInputElement_maxLength_Getter";

  @DomName('HTMLInputElement.maxLength')
  @DocsEditable
  void set maxLength(int value) native "HTMLInputElement_maxLength_Setter";

  @DomName('HTMLInputElement.min')
  @DocsEditable
  String get min native "HTMLInputElement_min_Getter";

  @DomName('HTMLInputElement.min')
  @DocsEditable
  void set min(String value) native "HTMLInputElement_min_Setter";

  @DomName('HTMLInputElement.multiple')
  @DocsEditable
  bool get multiple native "HTMLInputElement_multiple_Getter";

  @DomName('HTMLInputElement.multiple')
  @DocsEditable
  void set multiple(bool value) native "HTMLInputElement_multiple_Setter";

  @DomName('HTMLInputElement.name')
  @DocsEditable
  String get name native "HTMLInputElement_name_Getter";

  @DomName('HTMLInputElement.name')
  @DocsEditable
  void set name(String value) native "HTMLInputElement_name_Setter";

  @DomName('HTMLInputElement.pattern')
  @DocsEditable
  String get pattern native "HTMLInputElement_pattern_Getter";

  @DomName('HTMLInputElement.pattern')
  @DocsEditable
  void set pattern(String value) native "HTMLInputElement_pattern_Setter";

  @DomName('HTMLInputElement.placeholder')
  @DocsEditable
  String get placeholder native "HTMLInputElement_placeholder_Getter";

  @DomName('HTMLInputElement.placeholder')
  @DocsEditable
  void set placeholder(String value) native "HTMLInputElement_placeholder_Setter";

  @DomName('HTMLInputElement.readOnly')
  @DocsEditable
  bool get readOnly native "HTMLInputElement_readOnly_Getter";

  @DomName('HTMLInputElement.readOnly')
  @DocsEditable
  void set readOnly(bool value) native "HTMLInputElement_readOnly_Setter";

  @DomName('HTMLInputElement.required')
  @DocsEditable
  bool get required native "HTMLInputElement_required_Getter";

  @DomName('HTMLInputElement.required')
  @DocsEditable
  void set required(bool value) native "HTMLInputElement_required_Setter";

  @DomName('HTMLInputElement.selectionDirection')
  @DocsEditable
  String get selectionDirection native "HTMLInputElement_selectionDirection_Getter";

  @DomName('HTMLInputElement.selectionDirection')
  @DocsEditable
  void set selectionDirection(String value) native "HTMLInputElement_selectionDirection_Setter";

  @DomName('HTMLInputElement.selectionEnd')
  @DocsEditable
  int get selectionEnd native "HTMLInputElement_selectionEnd_Getter";

  @DomName('HTMLInputElement.selectionEnd')
  @DocsEditable
  void set selectionEnd(int value) native "HTMLInputElement_selectionEnd_Setter";

  @DomName('HTMLInputElement.selectionStart')
  @DocsEditable
  int get selectionStart native "HTMLInputElement_selectionStart_Getter";

  @DomName('HTMLInputElement.selectionStart')
  @DocsEditable
  void set selectionStart(int value) native "HTMLInputElement_selectionStart_Setter";

  @DomName('HTMLInputElement.size')
  @DocsEditable
  int get size native "HTMLInputElement_size_Getter";

  @DomName('HTMLInputElement.size')
  @DocsEditable
  void set size(int value) native "HTMLInputElement_size_Setter";

  @DomName('HTMLInputElement.src')
  @DocsEditable
  String get src native "HTMLInputElement_src_Getter";

  @DomName('HTMLInputElement.src')
  @DocsEditable
  void set src(String value) native "HTMLInputElement_src_Setter";

  @DomName('HTMLInputElement.step')
  @DocsEditable
  String get step native "HTMLInputElement_step_Getter";

  @DomName('HTMLInputElement.step')
  @DocsEditable
  void set step(String value) native "HTMLInputElement_step_Setter";

  @DomName('HTMLInputElement.type')
  @DocsEditable
  String get type native "HTMLInputElement_type_Getter";

  @DomName('HTMLInputElement.type')
  @DocsEditable
  void set type(String value) native "HTMLInputElement_type_Setter";

  @DomName('HTMLInputElement.useMap')
  @DocsEditable
  String get useMap native "HTMLInputElement_useMap_Getter";

  @DomName('HTMLInputElement.useMap')
  @DocsEditable
  void set useMap(String value) native "HTMLInputElement_useMap_Setter";

  @DomName('HTMLInputElement.validationMessage')
  @DocsEditable
  String get validationMessage native "HTMLInputElement_validationMessage_Getter";

  @DomName('HTMLInputElement.validity')
  @DocsEditable
  ValidityState get validity native "HTMLInputElement_validity_Getter";

  @DomName('HTMLInputElement.value')
  @DocsEditable
  String get value native "HTMLInputElement_value_Getter";

  @DomName('HTMLInputElement.value')
  @DocsEditable
  void set value(String value) native "HTMLInputElement_value_Setter";

  @DomName('HTMLInputElement.valueAsDate')
  @DocsEditable
  DateTime get valueAsDate native "HTMLInputElement_valueAsDate_Getter";

  @DomName('HTMLInputElement.valueAsDate')
  @DocsEditable
  void set valueAsDate(DateTime value) native "HTMLInputElement_valueAsDate_Setter";

  @DomName('HTMLInputElement.valueAsNumber')
  @DocsEditable
  num get valueAsNumber native "HTMLInputElement_valueAsNumber_Getter";

  @DomName('HTMLInputElement.valueAsNumber')
  @DocsEditable
  void set valueAsNumber(num value) native "HTMLInputElement_valueAsNumber_Setter";

  @DomName('HTMLInputElement.webkitEntries')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  List<Entry> get entries native "HTMLInputElement_webkitEntries_Getter";

  @DomName('HTMLInputElement.webkitGrammar')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  bool get grammar native "HTMLInputElement_webkitGrammar_Getter";

  @DomName('HTMLInputElement.webkitGrammar')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void set grammar(bool value) native "HTMLInputElement_webkitGrammar_Setter";

  @DomName('HTMLInputElement.webkitSpeech')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  bool get speech native "HTMLInputElement_webkitSpeech_Getter";

  @DomName('HTMLInputElement.webkitSpeech')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void set speech(bool value) native "HTMLInputElement_webkitSpeech_Setter";

  @DomName('HTMLInputElement.webkitdirectory')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  bool get directory native "HTMLInputElement_webkitdirectory_Getter";

  @DomName('HTMLInputElement.webkitdirectory')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void set directory(bool value) native "HTMLInputElement_webkitdirectory_Setter";

  @DomName('HTMLInputElement.width')
  @DocsEditable
  int get width native "HTMLInputElement_width_Getter";

  @DomName('HTMLInputElement.width')
  @DocsEditable
  void set width(int value) native "HTMLInputElement_width_Setter";

  @DomName('HTMLInputElement.willValidate')
  @DocsEditable
  bool get willValidate native "HTMLInputElement_willValidate_Getter";

  @DomName('HTMLInputElement.checkValidity')
  @DocsEditable
  bool checkValidity() native "HTMLInputElement_checkValidity_Callback";

  @DomName('HTMLInputElement.select')
  @DocsEditable
  void select() native "HTMLInputElement_select_Callback";

  @DomName('HTMLInputElement.setCustomValidity')
  @DocsEditable
  void setCustomValidity(String error) native "HTMLInputElement_setCustomValidity_Callback";

  void setRangeText(String replacement, {int start, int end, String selectionMode}) {
    if ((replacement is String || replacement == null) && !?start && !?end && !?selectionMode) {
      _setRangeText_1(replacement);
      return;
    }
    if ((replacement is String || replacement == null) && (start is int || start == null) && (end is int || end == null) && (selectionMode is String || selectionMode == null)) {
      _setRangeText_2(replacement, start, end, selectionMode);
      return;
    }
    throw new ArgumentError("Incorrect number or type of arguments");
  }

  void _setRangeText_1(replacement) native "HTMLInputElement__setRangeText_1_Callback";

  void _setRangeText_2(replacement, start, end, selectionMode) native "HTMLInputElement__setRangeText_2_Callback";

  @DomName('HTMLInputElement.setSelectionRange')
  @DocsEditable
  void setSelectionRange(int start, int end, [String direction]) native "HTMLInputElement_setSelectionRange_Callback";

  void stepDown([int n]) {
    if (?n) {
      _stepDown_1(n);
      return;
    }
    _stepDown_2();
    return;
  }

  void _stepDown_1(n) native "HTMLInputElement__stepDown_1_Callback";

  void _stepDown_2() native "HTMLInputElement__stepDown_2_Callback";

  void stepUp([int n]) {
    if (?n) {
      _stepUp_1(n);
      return;
    }
    _stepUp_2();
    return;
  }

  void _stepUp_1(n) native "HTMLInputElement__stepUp_1_Callback";

  void _stepUp_2() native "HTMLInputElement__stepUp_2_Callback";

  @DomName('HTMLInputElement.onwebkitSpeechChange')
  @DocsEditable
  Stream<Event> get onSpeechChange => speechChangeEvent.forTarget(this);

}


// Interfaces representing the InputElement APIs which are supported
// for the various types of InputElement. From:
// http://www.w3.org/html/wg/drafts/html/master/forms.html#the-input-element.

/**
 * Exposes the functionality common between all InputElement types.
 */
abstract class InputElementBase implements Element {
  @DomName('HTMLInputElement.autofocus')
  bool autofocus;

  @DomName('HTMLInputElement.disabled')
  bool disabled;

  @DomName('HTMLInputElement.incremental')
  bool incremental;

  @DomName('HTMLInputElement.indeterminate')
  bool indeterminate;

  @DomName('HTMLInputElement.labels')
  List<Node> get labels;

  @DomName('HTMLInputElement.name')
  String name;

  @DomName('HTMLInputElement.validationMessage')
  String get validationMessage;

  @DomName('HTMLInputElement.validity')
  ValidityState get validity;

  @DomName('HTMLInputElement.value')
  String value;

  @DomName('HTMLInputElement.willValidate')
  bool get willValidate;

  @DomName('HTMLInputElement.checkValidity')
  bool checkValidity();

  @DomName('HTMLInputElement.setCustomValidity')
  void setCustomValidity(String error);
}

/**
 * Hidden input which is not intended to be seen or edited by the user.
 */
abstract class HiddenInputElement implements InputElementBase {
  factory HiddenInputElement() => new InputElement(type: 'hidden');
}


/**
 * Base interface for all inputs which involve text editing.
 */
abstract class TextInputElementBase implements InputElementBase {
  @DomName('HTMLInputElement.autocomplete')
  String autocomplete;

  @DomName('HTMLInputElement.maxLength')
  int maxLength;

  @DomName('HTMLInputElement.pattern')
  String pattern;

  @DomName('HTMLInputElement.placeholder')
  String placeholder;

  @DomName('HTMLInputElement.readOnly')
  bool readOnly;

  @DomName('HTMLInputElement.required')
  bool required;

  @DomName('HTMLInputElement.size')
  int size;

  @DomName('HTMLInputElement.select')
  void select();

  @DomName('HTMLInputElement.selectionDirection')
  String selectionDirection;

  @DomName('HTMLInputElement.selectionEnd')
  int selectionEnd;

  @DomName('HTMLInputElement.selectionStart')
  int selectionStart;

  @DomName('HTMLInputElement.setSelectionRange')
  void setSelectionRange(int start, int end, [String direction]);
}

/**
 * Similar to [TextInputElement], but on platforms where search is styled
 * differently this will get the search style.
 *
 * Use [supported] to check if this is supported on the current platform.
 */
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.FIREFOX)
@SupportedBrowser(SupportedBrowser.IE, '10')
@SupportedBrowser(SupportedBrowser.SAFARI)
abstract class SearchInputElement implements TextInputElementBase {
  factory SearchInputElement() => new InputElement(type: 'search');

  @DomName('HTMLInputElement.dirName')
  String dirName;

  @DomName('HTMLInputElement.list')
  Element get list;

  /// Returns true if this input type is supported on the current platform.
  static bool get supported {
    return (new InputElement(type: 'search')).type == 'search';
  }
}

/**
 * A basic text input editor control.
 */
abstract class TextInputElement implements TextInputElementBase {
  factory TextInputElement() => new InputElement(type: 'text');

  @DomName('HTMLInputElement.dirName')
  String dirName;

  @DomName('HTMLInputElement.list')
  Element get list;
}

/**
 * A control for editing an absolute URL.
 *
 * Use [supported] to check if this is supported on the current platform.
 */
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.FIREFOX)
@SupportedBrowser(SupportedBrowser.IE, '10')
@SupportedBrowser(SupportedBrowser.SAFARI)
abstract class UrlInputElement implements TextInputElementBase {
  factory UrlInputElement() => new InputElement(type: 'url');

  @DomName('HTMLInputElement.list')
  Element get list;

  /// Returns true if this input type is supported on the current platform.
  static bool get supported {
    return (new InputElement(type: 'url')).type == 'url';
  }
}

/**
 * Represents a control for editing a telephone number.
 *
 * This provides a single line of text with minimal formatting help since
 * there is a wide variety of telephone numbers.
 *
 * Use [supported] to check if this is supported on the current platform.
 */
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.FIREFOX)
@SupportedBrowser(SupportedBrowser.IE, '10')
@SupportedBrowser(SupportedBrowser.SAFARI)
abstract class TelephoneInputElement implements TextInputElementBase {
  factory TelephoneInputElement() => new InputElement(type: 'tel');

  @DomName('HTMLInputElement.list')
  Element get list;

  /// Returns true if this input type is supported on the current platform.
  static bool get supported {
    return (new InputElement(type: 'tel')).type == 'tel';
  }
}

/**
 * An e-mail address or list of e-mail addresses.
 *
 * Use [supported] to check if this is supported on the current platform.
 */
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.FIREFOX)
@SupportedBrowser(SupportedBrowser.IE, '10')
@SupportedBrowser(SupportedBrowser.SAFARI)
abstract class EmailInputElement implements TextInputElementBase {
  factory EmailInputElement() => new InputElement(type: 'email');

  @DomName('HTMLInputElement.autocomplete')
  String autocomplete;

  @DomName('HTMLInputElement.autofocus')
  bool autofocus;

  @DomName('HTMLInputElement.list')
  Element get list;

  @DomName('HTMLInputElement.maxLength')
  int maxLength;

  @DomName('HTMLInputElement.multiple')
  bool multiple;

  @DomName('HTMLInputElement.pattern')
  String pattern;

  @DomName('HTMLInputElement.placeholder')
  String placeholder;

  @DomName('HTMLInputElement.readOnly')
  bool readOnly;

  @DomName('HTMLInputElement.required')
  bool required;

  @DomName('HTMLInputElement.size')
  int size;

  /// Returns true if this input type is supported on the current platform.
  static bool get supported {
    return (new InputElement(type: 'email')).type == 'email';
  }
}

/**
 * Text with no line breaks (sensitive information).
 */
abstract class PasswordInputElement implements TextInputElementBase {
  factory PasswordInputElement() => new InputElement(type: 'password');
}

/**
 * Base interface for all input element types which involve ranges.
 */
abstract class RangeInputElementBase implements InputElementBase {

  @DomName('HTMLInputElement.list')
  Element get list;

  @DomName('HTMLInputElement.max')
  String max;

  @DomName('HTMLInputElement.min')
  String min;

  @DomName('HTMLInputElement.step')
  String step;

  @DomName('HTMLInputElement.valueAsNumber')
  num valueAsNumber;

  @DomName('HTMLInputElement.stepDown')
  void stepDown([int n]);

  @DomName('HTMLInputElement.stepUp')
  void stepUp([int n]);
}

/**
 * A date (year, month, day) with no time zone.
 *
 * Use [supported] to check if this is supported on the current platform.
 */
@SupportedBrowser(SupportedBrowser.CHROME, '25')
@Experimental
abstract class DateInputElement implements RangeInputElementBase {
  factory DateInputElement() => new InputElement(type: 'date');

  @DomName('HTMLInputElement.valueAsDate')
  DateTime valueAsDate;

  @DomName('HTMLInputElement.readOnly')
  bool readOnly;

  @DomName('HTMLInputElement.required')
  bool required;

  /// Returns true if this input type is supported on the current platform.
  static bool get supported {
    return (new InputElement(type: 'date')).type == 'date';
  }
}

/**
 * A date consisting of a year and a month with no time zone.
 *
 * Use [supported] to check if this is supported on the current platform.
 */
@SupportedBrowser(SupportedBrowser.CHROME, '25')
@Experimental
abstract class MonthInputElement implements RangeInputElementBase {
  factory MonthInputElement() => new InputElement(type: 'month');

  @DomName('HTMLInputElement.valueAsDate')
  DateTime valueAsDate;

  @DomName('HTMLInputElement.readOnly')
  bool readOnly;

  @DomName('HTMLInputElement.required')
  bool required;

  /// Returns true if this input type is supported on the current platform.
  static bool get supported {
    return (new InputElement(type: 'month')).type == 'month';
  }
}

/**
 * A date consisting of a week-year number and a week number with no time zone.
 *
 * Use [supported] to check if this is supported on the current platform.
 */
@SupportedBrowser(SupportedBrowser.CHROME, '25')
@Experimental
abstract class WeekInputElement implements RangeInputElementBase {
  factory WeekInputElement() => new InputElement(type: 'week');

  @DomName('HTMLInputElement.valueAsDate')
  DateTime valueAsDate;

  @DomName('HTMLInputElement.readOnly')
  bool readOnly;

  @DomName('HTMLInputElement.required')
  bool required;

  /// Returns true if this input type is supported on the current platform.
  static bool get supported {
    return (new InputElement(type: 'week')).type == 'week';
  }
}

/**
 * A time (hour, minute, seconds, fractional seconds) with no time zone.
 *
 * Use [supported] to check if this is supported on the current platform.
 */
@SupportedBrowser(SupportedBrowser.CHROME)
@Experimental
abstract class TimeInputElement implements RangeInputElementBase {
  factory TimeInputElement() => new InputElement(type: 'time');

  @DomName('HTMLInputElement.valueAsDate')
  DateTime valueAsDate;

  @DomName('HTMLInputElement.readOnly')
  bool readOnly;

  @DomName('HTMLInputElement.required')
  bool required;

  /// Returns true if this input type is supported on the current platform.
  static bool get supported {
    return (new InputElement(type: 'time')).type == 'time';
  }
}

/**
 * A date and time (year, month, day, hour, minute, second, fraction of a
 * second) with no time zone.
 *
 * Use [supported] to check if this is supported on the current platform.
 */
@SupportedBrowser(SupportedBrowser.CHROME, '25')
@Experimental
abstract class LocalDateTimeInputElement implements RangeInputElementBase {
  factory LocalDateTimeInputElement() =>
      new InputElement(type: 'datetime-local');

  @DomName('HTMLInputElement.readOnly')
  bool readOnly;

  @DomName('HTMLInputElement.required')
  bool required;

  /// Returns true if this input type is supported on the current platform.
  static bool get supported {
    return (new InputElement(type: 'datetime-local')).type == 'datetime-local';
  }
}

/**
 * A numeric editor control.
 */
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.IE)
@SupportedBrowser(SupportedBrowser.SAFARI)
@Experimental
abstract class NumberInputElement implements RangeInputElementBase {
  factory NumberInputElement() => new InputElement(type: 'number');

  @DomName('HTMLInputElement.placeholder')
  String placeholder;

  @DomName('HTMLInputElement.readOnly')
  bool readOnly;

  @DomName('HTMLInputElement.required')
  bool required;

  /// Returns true if this input type is supported on the current platform.
  static bool get supported {
    return (new InputElement(type: 'number')).type == 'number';
  }
}

/**
 * Similar to [NumberInputElement] but the browser may provide more optimal
 * styling (such as a slider control).
 *
 * Use [supported] to check if this is supported on the current platform.
 */
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.IE, '10')
@Experimental
abstract class RangeInputElement implements RangeInputElementBase {
  factory RangeInputElement() => new InputElement(type: 'range');

  /// Returns true if this input type is supported on the current platform.
  static bool get supported {
    return (new InputElement(type: 'range')).type == 'range';
  }
}

/**
 * A boolean editor control.
 *
 * Note that if [indeterminate] is set then this control is in a third
 * indeterminate state.
 */
abstract class CheckboxInputElement implements InputElementBase {
  factory CheckboxInputElement() => new InputElement(type: 'checkbox');

  @DomName('HTMLInputElement.checked')
  bool checked;

  @DomName('HTMLInputElement.required')
  bool required;
}


/**
 * A control that when used with other [ReadioButtonInputElement] controls
 * forms a radio button group in which only one control can be checked at a
 * time.
 *
 * Radio buttons are considered to be in the same radio button group if:
 *
 * * They are all of type 'radio'.
 * * They all have either the same [FormElement] owner, or no owner.
 * * Their name attributes contain the same name.
 */
abstract class RadioButtonInputElement implements InputElementBase {
  factory RadioButtonInputElement() => new InputElement(type: 'radio');

  @DomName('HTMLInputElement.checked')
  bool checked;

  @DomName('HTMLInputElement.required')
  bool required;
}

/**
 * A control for picking files from the user's computer.
 */
abstract class FileUploadInputElement implements InputElementBase {
  factory FileUploadInputElement() => new InputElement(type: 'file');

  @DomName('HTMLInputElement.accept')
  String accept;

  @DomName('HTMLInputElement.multiple')
  bool multiple;

  @DomName('HTMLInputElement.required')
  bool required;

  @DomName('HTMLInputElement.files')
  List<File> files;
}

/**
 * A button, which when clicked, submits the form.
 */
abstract class SubmitButtonInputElement implements InputElementBase {
  factory SubmitButtonInputElement() => new InputElement(type: 'submit');

  @DomName('HTMLInputElement.formAction')
  String formAction;

  @DomName('HTMLInputElement.formEnctype')
  String formEnctype;

  @DomName('HTMLInputElement.formMethod')
  String formMethod;

  @DomName('HTMLInputElement.formNoValidate')
  bool formNoValidate;

  @DomName('HTMLInputElement.formTarget')
  String formTarget;
}

/**
 * Either an image which the user can select a coordinate to or a form
 * submit button.
 */
abstract class ImageButtonInputElement implements InputElementBase {
  factory ImageButtonInputElement() => new InputElement(type: 'image');

  @DomName('HTMLInputElement.alt')
  String alt;

  @DomName('HTMLInputElement.formAction')
  String formAction;

  @DomName('HTMLInputElement.formEnctype')
  String formEnctype;

  @DomName('HTMLInputElement.formMethod')
  String formMethod;

  @DomName('HTMLInputElement.formNoValidate')
  bool formNoValidate;

  @DomName('HTMLInputElement.formTarget')
  String formTarget;

  @DomName('HTMLInputElement.height')
  int height;

  @DomName('HTMLInputElement.src')
  String src;

  @DomName('HTMLInputElement.width')
  int width;
}

/**
 * A button, which when clicked, resets the form.
 */
abstract class ResetButtonInputElement implements InputElementBase {
  factory ResetButtonInputElement() => new InputElement(type: 'reset');
}

/**
 * A button, with no default behavior.
 */
abstract class ButtonInputElement implements InputElementBase {
  factory ButtonInputElement() => new InputElement(type: 'button');
}

// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('KeyboardEvent')
class KeyboardEvent extends UIEvent {

  factory KeyboardEvent(String type,
      {Window view, bool canBubble: true, bool cancelable: true,
      String keyIdentifier: "", int keyLocation: 1, bool ctrlKey: false,
      bool altKey: false, bool shiftKey: false, bool metaKey: false,
      bool altGraphKey: false}) {
    if (view == null) {
      view = window;
    }
    final e = document.$dom_createEvent("KeyboardEvent");
    e.$dom_initKeyboardEvent(type, canBubble, cancelable, view, keyIdentifier,
        keyLocation, ctrlKey, altKey, shiftKey, metaKey, altGraphKey);
    return e;
  }

  @DomName('KeyboardEvent.keyCode')
  int get keyCode => $dom_keyCode;

  @DomName('KeyboardEvent.charCode')
  int get charCode => $dom_charCode;
  KeyboardEvent.internal() : super.internal();

  @DomName('KeyboardEvent.altGraphKey')
  @DocsEditable
  bool get altGraphKey native "KeyboardEvent_altGraphKey_Getter";

  @DomName('KeyboardEvent.altKey')
  @DocsEditable
  bool get altKey native "KeyboardEvent_altKey_Getter";

  @DomName('KeyboardEvent.ctrlKey')
  @DocsEditable
  bool get ctrlKey native "KeyboardEvent_ctrlKey_Getter";

  @DomName('KeyboardEvent.keyIdentifier')
  @DocsEditable
  String get $dom_keyIdentifier native "KeyboardEvent_keyIdentifier_Getter";

  @DomName('KeyboardEvent.keyLocation')
  @DocsEditable
  int get keyLocation native "KeyboardEvent_keyLocation_Getter";

  @DomName('KeyboardEvent.metaKey')
  @DocsEditable
  bool get metaKey native "KeyboardEvent_metaKey_Getter";

  @DomName('KeyboardEvent.shiftKey')
  @DocsEditable
  bool get shiftKey native "KeyboardEvent_shiftKey_Getter";

  @DomName('KeyboardEvent.initKeyboardEvent')
  @DocsEditable
  void $dom_initKeyboardEvent(String type, bool canBubble, bool cancelable, Window view, String keyIdentifier, int keyLocation, bool ctrlKey, bool altKey, bool shiftKey, bool metaKey, bool altGraphKey) native "KeyboardEvent_initKeyboardEvent_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLKeygenElement')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.SAFARI)
@Experimental
class KeygenElement extends _Element_Merged {
  KeygenElement.internal() : super.internal();

  @DomName('HTMLKeygenElement.HTMLKeygenElement')
  @DocsEditable
  factory KeygenElement() => document.$dom_createElement("keygen");

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('HTMLKeygenElement.autofocus')
  @DocsEditable
  bool get autofocus native "HTMLKeygenElement_autofocus_Getter";

  @DomName('HTMLKeygenElement.autofocus')
  @DocsEditable
  void set autofocus(bool value) native "HTMLKeygenElement_autofocus_Setter";

  @DomName('HTMLKeygenElement.challenge')
  @DocsEditable
  String get challenge native "HTMLKeygenElement_challenge_Getter";

  @DomName('HTMLKeygenElement.challenge')
  @DocsEditable
  void set challenge(String value) native "HTMLKeygenElement_challenge_Setter";

  @DomName('HTMLKeygenElement.disabled')
  @DocsEditable
  bool get disabled native "HTMLKeygenElement_disabled_Getter";

  @DomName('HTMLKeygenElement.disabled')
  @DocsEditable
  void set disabled(bool value) native "HTMLKeygenElement_disabled_Setter";

  @DomName('HTMLKeygenElement.form')
  @DocsEditable
  FormElement get form native "HTMLKeygenElement_form_Getter";

  @DomName('HTMLKeygenElement.keytype')
  @DocsEditable
  String get keytype native "HTMLKeygenElement_keytype_Getter";

  @DomName('HTMLKeygenElement.keytype')
  @DocsEditable
  void set keytype(String value) native "HTMLKeygenElement_keytype_Setter";

  @DomName('HTMLKeygenElement.labels')
  @DocsEditable
  List<Node> get labels native "HTMLKeygenElement_labels_Getter";

  @DomName('HTMLKeygenElement.name')
  @DocsEditable
  String get name native "HTMLKeygenElement_name_Getter";

  @DomName('HTMLKeygenElement.name')
  @DocsEditable
  void set name(String value) native "HTMLKeygenElement_name_Setter";

  @DomName('HTMLKeygenElement.type')
  @DocsEditable
  String get type native "HTMLKeygenElement_type_Getter";

  @DomName('HTMLKeygenElement.validationMessage')
  @DocsEditable
  String get validationMessage native "HTMLKeygenElement_validationMessage_Getter";

  @DomName('HTMLKeygenElement.validity')
  @DocsEditable
  ValidityState get validity native "HTMLKeygenElement_validity_Getter";

  @DomName('HTMLKeygenElement.willValidate')
  @DocsEditable
  bool get willValidate native "HTMLKeygenElement_willValidate_Getter";

  @DomName('HTMLKeygenElement.checkValidity')
  @DocsEditable
  bool checkValidity() native "HTMLKeygenElement_checkValidity_Callback";

  @DomName('HTMLKeygenElement.setCustomValidity')
  @DocsEditable
  void setCustomValidity(String error) native "HTMLKeygenElement_setCustomValidity_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLLIElement')
class LIElement extends _Element_Merged {
  LIElement.internal() : super.internal();

  @DomName('HTMLLIElement.HTMLLIElement')
  @DocsEditable
  factory LIElement() => document.$dom_createElement("li");

  @DomName('HTMLLIElement.type')
  @DocsEditable
  String get type native "HTMLLIElement_type_Getter";

  @DomName('HTMLLIElement.type')
  @DocsEditable
  void set type(String value) native "HTMLLIElement_type_Setter";

  @DomName('HTMLLIElement.value')
  @DocsEditable
  int get value native "HTMLLIElement_value_Getter";

  @DomName('HTMLLIElement.value')
  @DocsEditable
  void set value(int value) native "HTMLLIElement_value_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLLabelElement')
class LabelElement extends _Element_Merged {
  LabelElement.internal() : super.internal();

  @DomName('HTMLLabelElement.HTMLLabelElement')
  @DocsEditable
  factory LabelElement() => document.$dom_createElement("label");

  @DomName('HTMLLabelElement.control')
  @DocsEditable
  Element get control native "HTMLLabelElement_control_Getter";

  @DomName('HTMLLabelElement.form')
  @DocsEditable
  FormElement get form native "HTMLLabelElement_form_Getter";

  @DomName('HTMLLabelElement.htmlFor')
  @DocsEditable
  String get htmlFor native "HTMLLabelElement_htmlFor_Getter";

  @DomName('HTMLLabelElement.htmlFor')
  @DocsEditable
  void set htmlFor(String value) native "HTMLLabelElement_htmlFor_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLLegendElement')
class LegendElement extends _Element_Merged {
  LegendElement.internal() : super.internal();

  @DomName('HTMLLegendElement.HTMLLegendElement')
  @DocsEditable
  factory LegendElement() => document.$dom_createElement("legend");

  @DomName('HTMLLegendElement.form')
  @DocsEditable
  FormElement get form native "HTMLLegendElement_form_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLLinkElement')
class LinkElement extends _Element_Merged {
  LinkElement.internal() : super.internal();

  @DomName('HTMLLinkElement.HTMLLinkElement')
  @DocsEditable
  factory LinkElement() => document.$dom_createElement("link");

  @DomName('HTMLLinkElement.disabled')
  @DocsEditable
  bool get disabled native "HTMLLinkElement_disabled_Getter";

  @DomName('HTMLLinkElement.disabled')
  @DocsEditable
  void set disabled(bool value) native "HTMLLinkElement_disabled_Setter";

  @DomName('HTMLLinkElement.href')
  @DocsEditable
  String get href native "HTMLLinkElement_href_Getter";

  @DomName('HTMLLinkElement.href')
  @DocsEditable
  void set href(String value) native "HTMLLinkElement_href_Setter";

  @DomName('HTMLLinkElement.hreflang')
  @DocsEditable
  String get hreflang native "HTMLLinkElement_hreflang_Getter";

  @DomName('HTMLLinkElement.hreflang')
  @DocsEditable
  void set hreflang(String value) native "HTMLLinkElement_hreflang_Setter";

  @DomName('HTMLLinkElement.media')
  @DocsEditable
  String get media native "HTMLLinkElement_media_Getter";

  @DomName('HTMLLinkElement.media')
  @DocsEditable
  void set media(String value) native "HTMLLinkElement_media_Setter";

  @DomName('HTMLLinkElement.rel')
  @DocsEditable
  String get rel native "HTMLLinkElement_rel_Getter";

  @DomName('HTMLLinkElement.rel')
  @DocsEditable
  void set rel(String value) native "HTMLLinkElement_rel_Setter";

  @DomName('HTMLLinkElement.sheet')
  @DocsEditable
  StyleSheet get sheet native "HTMLLinkElement_sheet_Getter";

  @DomName('HTMLLinkElement.sizes')
  @DocsEditable
  DomSettableTokenList get sizes native "HTMLLinkElement_sizes_Getter";

  @DomName('HTMLLinkElement.sizes')
  @DocsEditable
  void set sizes(DomSettableTokenList value) native "HTMLLinkElement_sizes_Setter";

  @DomName('HTMLLinkElement.type')
  @DocsEditable
  String get type native "HTMLLinkElement_type_Getter";

  @DomName('HTMLLinkElement.type')
  @DocsEditable
  void set type(String value) native "HTMLLinkElement_type_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('LocalMediaStream')
@SupportedBrowser(SupportedBrowser.CHROME)
@Experimental
class LocalMediaStream extends MediaStream implements EventTarget {
  LocalMediaStream.internal() : super.internal();

  @DomName('LocalMediaStream.stop')
  @DocsEditable
  void stop() native "LocalMediaStream_stop_Callback";

}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DocsEditable
@DomName('Location')
class Location extends NativeFieldWrapperClass1 implements LocationBase {
  Location.internal();

  @DomName('Location.ancestorOrigins')
  @DocsEditable
  List<String> get ancestorOrigins native "Location_ancestorOrigins_Getter";

  @DomName('Location.hash')
  @DocsEditable
  String get hash native "Location_hash_Getter";

  @DomName('Location.hash')
  @DocsEditable
  void set hash(String value) native "Location_hash_Setter";

  @DomName('Location.host')
  @DocsEditable
  String get host native "Location_host_Getter";

  @DomName('Location.host')
  @DocsEditable
  void set host(String value) native "Location_host_Setter";

  @DomName('Location.hostname')
  @DocsEditable
  String get hostname native "Location_hostname_Getter";

  @DomName('Location.hostname')
  @DocsEditable
  void set hostname(String value) native "Location_hostname_Setter";

  @DomName('Location.href')
  @DocsEditable
  String get href native "Location_href_Getter";

  @DomName('Location.href')
  @DocsEditable
  void set href(String value) native "Location_href_Setter";

  @DomName('Location.origin')
  @DocsEditable
  String get origin native "Location_origin_Getter";

  @DomName('Location.pathname')
  @DocsEditable
  String get pathname native "Location_pathname_Getter";

  @DomName('Location.pathname')
  @DocsEditable
  void set pathname(String value) native "Location_pathname_Setter";

  @DomName('Location.port')
  @DocsEditable
  String get port native "Location_port_Getter";

  @DomName('Location.port')
  @DocsEditable
  void set port(String value) native "Location_port_Setter";

  @DomName('Location.protocol')
  @DocsEditable
  String get protocol native "Location_protocol_Getter";

  @DomName('Location.protocol')
  @DocsEditable
  void set protocol(String value) native "Location_protocol_Setter";

  @DomName('Location.search')
  @DocsEditable
  String get search native "Location_search_Getter";

  @DomName('Location.search')
  @DocsEditable
  void set search(String value) native "Location_search_Setter";

  @DomName('Location.assign')
  @DocsEditable
  void assign(String url) native "Location_assign_Callback";

  @DomName('Location.reload')
  @DocsEditable
  void reload() native "Location_reload_Callback";

  @DomName('Location.replace')
  @DocsEditable
  void replace(String url) native "Location_replace_Callback";

  @DomName('Location.toString')
  @DocsEditable
  String toString() native "Location_toString_Callback";

  @DomName('Location.valueOf')
  @DocsEditable
  Object valueOf() native "Location_valueOf_Callback";


}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLMapElement')
class MapElement extends _Element_Merged {
  MapElement.internal() : super.internal();

  @DomName('HTMLMapElement.HTMLMapElement')
  @DocsEditable
  factory MapElement() => document.$dom_createElement("map");

  @DomName('HTMLMapElement.areas')
  @DocsEditable
  HtmlCollection get areas native "HTMLMapElement_areas_Getter";

  @DomName('HTMLMapElement.name')
  @DocsEditable
  String get name native "HTMLMapElement_name_Getter";

  @DomName('HTMLMapElement.name')
  @DocsEditable
  void set name(String value) native "HTMLMapElement_name_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('MediaController')
class MediaController extends EventTarget {
  MediaController.internal() : super.internal();

  @DomName('MediaController.MediaController')
  @DocsEditable
  factory MediaController() {
    return MediaController._create_1();
  }

  @DocsEditable
  static MediaController _create_1() native "MediaController__create_1constructorCallback";

  @DomName('MediaController.buffered')
  @DocsEditable
  TimeRanges get buffered native "MediaController_buffered_Getter";

  @DomName('MediaController.currentTime')
  @DocsEditable
  num get currentTime native "MediaController_currentTime_Getter";

  @DomName('MediaController.currentTime')
  @DocsEditable
  void set currentTime(num value) native "MediaController_currentTime_Setter";

  @DomName('MediaController.defaultPlaybackRate')
  @DocsEditable
  num get defaultPlaybackRate native "MediaController_defaultPlaybackRate_Getter";

  @DomName('MediaController.defaultPlaybackRate')
  @DocsEditable
  void set defaultPlaybackRate(num value) native "MediaController_defaultPlaybackRate_Setter";

  @DomName('MediaController.duration')
  @DocsEditable
  num get duration native "MediaController_duration_Getter";

  @DomName('MediaController.muted')
  @DocsEditable
  bool get muted native "MediaController_muted_Getter";

  @DomName('MediaController.muted')
  @DocsEditable
  void set muted(bool value) native "MediaController_muted_Setter";

  @DomName('MediaController.paused')
  @DocsEditable
  bool get paused native "MediaController_paused_Getter";

  @DomName('MediaController.playbackRate')
  @DocsEditable
  num get playbackRate native "MediaController_playbackRate_Getter";

  @DomName('MediaController.playbackRate')
  @DocsEditable
  void set playbackRate(num value) native "MediaController_playbackRate_Setter";

  @DomName('MediaController.playbackState')
  @DocsEditable
  String get playbackState native "MediaController_playbackState_Getter";

  @DomName('MediaController.played')
  @DocsEditable
  TimeRanges get played native "MediaController_played_Getter";

  @DomName('MediaController.seekable')
  @DocsEditable
  TimeRanges get seekable native "MediaController_seekable_Getter";

  @DomName('MediaController.volume')
  @DocsEditable
  num get volume native "MediaController_volume_Getter";

  @DomName('MediaController.volume')
  @DocsEditable
  void set volume(num value) native "MediaController_volume_Setter";

  @DomName('MediaController.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "MediaController_addEventListener_Callback";

  @DomName('MediaController.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event evt) native "MediaController_dispatchEvent_Callback";

  @DomName('MediaController.pause')
  @DocsEditable
  void pause() native "MediaController_pause_Callback";

  @DomName('MediaController.play')
  @DocsEditable
  void play() native "MediaController_play_Callback";

  @DomName('MediaController.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "MediaController_removeEventListener_Callback";

  @DomName('MediaController.unpause')
  @DocsEditable
  void unpause() native "MediaController_unpause_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLMediaElement')
class MediaElement extends _Element_Merged {
  MediaElement.internal() : super.internal();

  @DomName('HTMLMediaElement.canplayEvent')
  @DocsEditable
  static const EventStreamProvider<Event> canPlayEvent = const EventStreamProvider<Event>('canplay');

  @DomName('HTMLMediaElement.canplaythroughEvent')
  @DocsEditable
  static const EventStreamProvider<Event> canPlayThroughEvent = const EventStreamProvider<Event>('canplaythrough');

  @DomName('HTMLMediaElement.durationchangeEvent')
  @DocsEditable
  static const EventStreamProvider<Event> durationChangeEvent = const EventStreamProvider<Event>('durationchange');

  @DomName('HTMLMediaElement.emptiedEvent')
  @DocsEditable
  static const EventStreamProvider<Event> emptiedEvent = const EventStreamProvider<Event>('emptied');

  @DomName('HTMLMediaElement.endedEvent')
  @DocsEditable
  static const EventStreamProvider<Event> endedEvent = const EventStreamProvider<Event>('ended');

  @DomName('HTMLMediaElement.loadeddataEvent')
  @DocsEditable
  static const EventStreamProvider<Event> loadedDataEvent = const EventStreamProvider<Event>('loadeddata');

  @DomName('HTMLMediaElement.loadedmetadataEvent')
  @DocsEditable
  static const EventStreamProvider<Event> loadedMetadataEvent = const EventStreamProvider<Event>('loadedmetadata');

  @DomName('HTMLMediaElement.loadstartEvent')
  @DocsEditable
  static const EventStreamProvider<Event> loadStartEvent = const EventStreamProvider<Event>('loadstart');

  @DomName('HTMLMediaElement.pauseEvent')
  @DocsEditable
  static const EventStreamProvider<Event> pauseEvent = const EventStreamProvider<Event>('pause');

  @DomName('HTMLMediaElement.playEvent')
  @DocsEditable
  static const EventStreamProvider<Event> playEvent = const EventStreamProvider<Event>('play');

  @DomName('HTMLMediaElement.playingEvent')
  @DocsEditable
  static const EventStreamProvider<Event> playingEvent = const EventStreamProvider<Event>('playing');

  @DomName('HTMLMediaElement.progressEvent')
  @DocsEditable
  static const EventStreamProvider<Event> progressEvent = const EventStreamProvider<Event>('progress');

  @DomName('HTMLMediaElement.ratechangeEvent')
  @DocsEditable
  static const EventStreamProvider<Event> rateChangeEvent = const EventStreamProvider<Event>('ratechange');

  @DomName('HTMLMediaElement.seekedEvent')
  @DocsEditable
  static const EventStreamProvider<Event> seekedEvent = const EventStreamProvider<Event>('seeked');

  @DomName('HTMLMediaElement.seekingEvent')
  @DocsEditable
  static const EventStreamProvider<Event> seekingEvent = const EventStreamProvider<Event>('seeking');

  @DomName('HTMLMediaElement.showEvent')
  @DocsEditable
  static const EventStreamProvider<Event> showEvent = const EventStreamProvider<Event>('show');

  @DomName('HTMLMediaElement.stalledEvent')
  @DocsEditable
  static const EventStreamProvider<Event> stalledEvent = const EventStreamProvider<Event>('stalled');

  @DomName('HTMLMediaElement.suspendEvent')
  @DocsEditable
  static const EventStreamProvider<Event> suspendEvent = const EventStreamProvider<Event>('suspend');

  @DomName('HTMLMediaElement.timeupdateEvent')
  @DocsEditable
  static const EventStreamProvider<Event> timeUpdateEvent = const EventStreamProvider<Event>('timeupdate');

  @DomName('HTMLMediaElement.volumechangeEvent')
  @DocsEditable
  static const EventStreamProvider<Event> volumeChangeEvent = const EventStreamProvider<Event>('volumechange');

  @DomName('HTMLMediaElement.waitingEvent')
  @DocsEditable
  static const EventStreamProvider<Event> waitingEvent = const EventStreamProvider<Event>('waiting');

  @DomName('HTMLMediaElement.webkitkeyaddedEvent')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  static const EventStreamProvider<MediaKeyEvent> keyAddedEvent = const EventStreamProvider<MediaKeyEvent>('webkitkeyadded');

  @DomName('HTMLMediaElement.webkitkeyerrorEvent')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  static const EventStreamProvider<MediaKeyEvent> keyErrorEvent = const EventStreamProvider<MediaKeyEvent>('webkitkeyerror');

  @DomName('HTMLMediaElement.webkitkeymessageEvent')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  static const EventStreamProvider<MediaKeyEvent> keyMessageEvent = const EventStreamProvider<MediaKeyEvent>('webkitkeymessage');

  @DomName('HTMLMediaElement.webkitneedkeyEvent')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  static const EventStreamProvider<MediaKeyEvent> needKeyEvent = const EventStreamProvider<MediaKeyEvent>('webkitneedkey');

  @DomName('HTMLMediaElement.HAVE_CURRENT_DATA')
  @DocsEditable
  static const int HAVE_CURRENT_DATA = 2;

  @DomName('HTMLMediaElement.HAVE_ENOUGH_DATA')
  @DocsEditable
  static const int HAVE_ENOUGH_DATA = 4;

  @DomName('HTMLMediaElement.HAVE_FUTURE_DATA')
  @DocsEditable
  static const int HAVE_FUTURE_DATA = 3;

  @DomName('HTMLMediaElement.HAVE_METADATA')
  @DocsEditable
  static const int HAVE_METADATA = 1;

  @DomName('HTMLMediaElement.HAVE_NOTHING')
  @DocsEditable
  static const int HAVE_NOTHING = 0;

  @DomName('HTMLMediaElement.NETWORK_EMPTY')
  @DocsEditable
  static const int NETWORK_EMPTY = 0;

  @DomName('HTMLMediaElement.NETWORK_IDLE')
  @DocsEditable
  static const int NETWORK_IDLE = 1;

  @DomName('HTMLMediaElement.NETWORK_LOADING')
  @DocsEditable
  static const int NETWORK_LOADING = 2;

  @DomName('HTMLMediaElement.NETWORK_NO_SOURCE')
  @DocsEditable
  static const int NETWORK_NO_SOURCE = 3;

  @DomName('HTMLMediaElement.autoplay')
  @DocsEditable
  bool get autoplay native "HTMLMediaElement_autoplay_Getter";

  @DomName('HTMLMediaElement.autoplay')
  @DocsEditable
  void set autoplay(bool value) native "HTMLMediaElement_autoplay_Setter";

  @DomName('HTMLMediaElement.buffered')
  @DocsEditable
  TimeRanges get buffered native "HTMLMediaElement_buffered_Getter";

  @DomName('HTMLMediaElement.controller')
  @DocsEditable
  MediaController get controller native "HTMLMediaElement_controller_Getter";

  @DomName('HTMLMediaElement.controller')
  @DocsEditable
  void set controller(MediaController value) native "HTMLMediaElement_controller_Setter";

  @DomName('HTMLMediaElement.controls')
  @DocsEditable
  bool get controls native "HTMLMediaElement_controls_Getter";

  @DomName('HTMLMediaElement.controls')
  @DocsEditable
  void set controls(bool value) native "HTMLMediaElement_controls_Setter";

  @DomName('HTMLMediaElement.currentSrc')
  @DocsEditable
  String get currentSrc native "HTMLMediaElement_currentSrc_Getter";

  @DomName('HTMLMediaElement.currentTime')
  @DocsEditable
  num get currentTime native "HTMLMediaElement_currentTime_Getter";

  @DomName('HTMLMediaElement.currentTime')
  @DocsEditable
  void set currentTime(num value) native "HTMLMediaElement_currentTime_Setter";

  @DomName('HTMLMediaElement.defaultMuted')
  @DocsEditable
  bool get defaultMuted native "HTMLMediaElement_defaultMuted_Getter";

  @DomName('HTMLMediaElement.defaultMuted')
  @DocsEditable
  void set defaultMuted(bool value) native "HTMLMediaElement_defaultMuted_Setter";

  @DomName('HTMLMediaElement.defaultPlaybackRate')
  @DocsEditable
  num get defaultPlaybackRate native "HTMLMediaElement_defaultPlaybackRate_Getter";

  @DomName('HTMLMediaElement.defaultPlaybackRate')
  @DocsEditable
  void set defaultPlaybackRate(num value) native "HTMLMediaElement_defaultPlaybackRate_Setter";

  @DomName('HTMLMediaElement.duration')
  @DocsEditable
  num get duration native "HTMLMediaElement_duration_Getter";

  @DomName('HTMLMediaElement.ended')
  @DocsEditable
  bool get ended native "HTMLMediaElement_ended_Getter";

  @DomName('HTMLMediaElement.error')
  @DocsEditable
  MediaError get error native "HTMLMediaElement_error_Getter";

  @DomName('HTMLMediaElement.initialTime')
  @DocsEditable
  num get initialTime native "HTMLMediaElement_initialTime_Getter";

  @DomName('HTMLMediaElement.loop')
  @DocsEditable
  bool get loop native "HTMLMediaElement_loop_Getter";

  @DomName('HTMLMediaElement.loop')
  @DocsEditable
  void set loop(bool value) native "HTMLMediaElement_loop_Setter";

  @DomName('HTMLMediaElement.mediaGroup')
  @DocsEditable
  String get mediaGroup native "HTMLMediaElement_mediaGroup_Getter";

  @DomName('HTMLMediaElement.mediaGroup')
  @DocsEditable
  void set mediaGroup(String value) native "HTMLMediaElement_mediaGroup_Setter";

  @DomName('HTMLMediaElement.muted')
  @DocsEditable
  bool get muted native "HTMLMediaElement_muted_Getter";

  @DomName('HTMLMediaElement.muted')
  @DocsEditable
  void set muted(bool value) native "HTMLMediaElement_muted_Setter";

  @DomName('HTMLMediaElement.networkState')
  @DocsEditable
  int get networkState native "HTMLMediaElement_networkState_Getter";

  @DomName('HTMLMediaElement.paused')
  @DocsEditable
  bool get paused native "HTMLMediaElement_paused_Getter";

  @DomName('HTMLMediaElement.playbackRate')
  @DocsEditable
  num get playbackRate native "HTMLMediaElement_playbackRate_Getter";

  @DomName('HTMLMediaElement.playbackRate')
  @DocsEditable
  void set playbackRate(num value) native "HTMLMediaElement_playbackRate_Setter";

  @DomName('HTMLMediaElement.played')
  @DocsEditable
  TimeRanges get played native "HTMLMediaElement_played_Getter";

  @DomName('HTMLMediaElement.preload')
  @DocsEditable
  String get preload native "HTMLMediaElement_preload_Getter";

  @DomName('HTMLMediaElement.preload')
  @DocsEditable
  void set preload(String value) native "HTMLMediaElement_preload_Setter";

  @DomName('HTMLMediaElement.readyState')
  @DocsEditable
  int get readyState native "HTMLMediaElement_readyState_Getter";

  @DomName('HTMLMediaElement.seekable')
  @DocsEditable
  TimeRanges get seekable native "HTMLMediaElement_seekable_Getter";

  @DomName('HTMLMediaElement.seeking')
  @DocsEditable
  bool get seeking native "HTMLMediaElement_seeking_Getter";

  @DomName('HTMLMediaElement.src')
  @DocsEditable
  String get src native "HTMLMediaElement_src_Getter";

  @DomName('HTMLMediaElement.src')
  @DocsEditable
  void set src(String value) native "HTMLMediaElement_src_Setter";

  @DomName('HTMLMediaElement.startTime')
  @DocsEditable
  num get startTime native "HTMLMediaElement_startTime_Getter";

  @DomName('HTMLMediaElement.textTracks')
  @DocsEditable
  TextTrackList get textTracks native "HTMLMediaElement_textTracks_Getter";

  @DomName('HTMLMediaElement.volume')
  @DocsEditable
  num get volume native "HTMLMediaElement_volume_Getter";

  @DomName('HTMLMediaElement.volume')
  @DocsEditable
  void set volume(num value) native "HTMLMediaElement_volume_Setter";

  @DomName('HTMLMediaElement.webkitAudioDecodedByteCount')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  int get audioDecodedByteCount native "HTMLMediaElement_webkitAudioDecodedByteCount_Getter";

  @DomName('HTMLMediaElement.webkitClosedCaptionsVisible')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  bool get closedCaptionsVisible native "HTMLMediaElement_webkitClosedCaptionsVisible_Getter";

  @DomName('HTMLMediaElement.webkitClosedCaptionsVisible')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void set closedCaptionsVisible(bool value) native "HTMLMediaElement_webkitClosedCaptionsVisible_Setter";

  @DomName('HTMLMediaElement.webkitHasClosedCaptions')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  bool get hasClosedCaptions native "HTMLMediaElement_webkitHasClosedCaptions_Getter";

  @DomName('HTMLMediaElement.webkitPreservesPitch')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  bool get preservesPitch native "HTMLMediaElement_webkitPreservesPitch_Getter";

  @DomName('HTMLMediaElement.webkitPreservesPitch')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void set preservesPitch(bool value) native "HTMLMediaElement_webkitPreservesPitch_Setter";

  @DomName('HTMLMediaElement.webkitVideoDecodedByteCount')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  int get videoDecodedByteCount native "HTMLMediaElement_webkitVideoDecodedByteCount_Getter";

  TextTrack addTextTrack(String kind, [String label, String language]) {
    if (?language) {
      return _addTextTrack_1(kind, label, language);
    }
    if (?label) {
      return _addTextTrack_2(kind, label);
    }
    return _addTextTrack_3(kind);
  }

  TextTrack _addTextTrack_1(kind, label, language) native "HTMLMediaElement__addTextTrack_1_Callback";

  TextTrack _addTextTrack_2(kind, label) native "HTMLMediaElement__addTextTrack_2_Callback";

  TextTrack _addTextTrack_3(kind) native "HTMLMediaElement__addTextTrack_3_Callback";

  @DomName('HTMLMediaElement.canPlayType')
  @DocsEditable
  String canPlayType(String type, String keySystem) native "HTMLMediaElement_canPlayType_Callback";

  @DomName('HTMLMediaElement.load')
  @DocsEditable
  void load() native "HTMLMediaElement_load_Callback";

  @DomName('HTMLMediaElement.pause')
  @DocsEditable
  void pause() native "HTMLMediaElement_pause_Callback";

  @DomName('HTMLMediaElement.play')
  @DocsEditable
  void play() native "HTMLMediaElement_play_Callback";

  void addKey(String keySystem, Uint8List key, [Uint8List initData, String sessionId]) {
    if (?initData) {
      _webkitAddKey_1(keySystem, key, initData, sessionId);
      return;
    }
    _webkitAddKey_2(keySystem, key);
    return;
  }

  void _webkitAddKey_1(keySystem, key, initData, sessionId) native "HTMLMediaElement__webkitAddKey_1_Callback";

  void _webkitAddKey_2(keySystem, key) native "HTMLMediaElement__webkitAddKey_2_Callback";

  @DomName('HTMLMediaElement.webkitCancelKeyRequest')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void cancelKeyRequest(String keySystem, String sessionId) native "HTMLMediaElement_webkitCancelKeyRequest_Callback";

  void generateKeyRequest(String keySystem, [Uint8List initData]) {
    if (?initData) {
      _webkitGenerateKeyRequest_1(keySystem, initData);
      return;
    }
    _webkitGenerateKeyRequest_2(keySystem);
    return;
  }

  void _webkitGenerateKeyRequest_1(keySystem, initData) native "HTMLMediaElement__webkitGenerateKeyRequest_1_Callback";

  void _webkitGenerateKeyRequest_2(keySystem) native "HTMLMediaElement__webkitGenerateKeyRequest_2_Callback";

  @DomName('HTMLMediaElement.oncanplay')
  @DocsEditable
  Stream<Event> get onCanPlay => canPlayEvent.forTarget(this);

  @DomName('HTMLMediaElement.oncanplaythrough')
  @DocsEditable
  Stream<Event> get onCanPlayThrough => canPlayThroughEvent.forTarget(this);

  @DomName('HTMLMediaElement.ondurationchange')
  @DocsEditable
  Stream<Event> get onDurationChange => durationChangeEvent.forTarget(this);

  @DomName('HTMLMediaElement.onemptied')
  @DocsEditable
  Stream<Event> get onEmptied => emptiedEvent.forTarget(this);

  @DomName('HTMLMediaElement.onended')
  @DocsEditable
  Stream<Event> get onEnded => endedEvent.forTarget(this);

  @DomName('HTMLMediaElement.onloadeddata')
  @DocsEditable
  Stream<Event> get onLoadedData => loadedDataEvent.forTarget(this);

  @DomName('HTMLMediaElement.onloadedmetadata')
  @DocsEditable
  Stream<Event> get onLoadedMetadata => loadedMetadataEvent.forTarget(this);

  @DomName('HTMLMediaElement.onloadstart')
  @DocsEditable
  Stream<Event> get onLoadStart => loadStartEvent.forTarget(this);

  @DomName('HTMLMediaElement.onpause')
  @DocsEditable
  Stream<Event> get onPause => pauseEvent.forTarget(this);

  @DomName('HTMLMediaElement.onplay')
  @DocsEditable
  Stream<Event> get onPlay => playEvent.forTarget(this);

  @DomName('HTMLMediaElement.onplaying')
  @DocsEditable
  Stream<Event> get onPlaying => playingEvent.forTarget(this);

  @DomName('HTMLMediaElement.onprogress')
  @DocsEditable
  Stream<Event> get onProgress => progressEvent.forTarget(this);

  @DomName('HTMLMediaElement.onratechange')
  @DocsEditable
  Stream<Event> get onRateChange => rateChangeEvent.forTarget(this);

  @DomName('HTMLMediaElement.onseeked')
  @DocsEditable
  Stream<Event> get onSeeked => seekedEvent.forTarget(this);

  @DomName('HTMLMediaElement.onseeking')
  @DocsEditable
  Stream<Event> get onSeeking => seekingEvent.forTarget(this);

  @DomName('HTMLMediaElement.onshow')
  @DocsEditable
  Stream<Event> get onShow => showEvent.forTarget(this);

  @DomName('HTMLMediaElement.onstalled')
  @DocsEditable
  Stream<Event> get onStalled => stalledEvent.forTarget(this);

  @DomName('HTMLMediaElement.onsuspend')
  @DocsEditable
  Stream<Event> get onSuspend => suspendEvent.forTarget(this);

  @DomName('HTMLMediaElement.ontimeupdate')
  @DocsEditable
  Stream<Event> get onTimeUpdate => timeUpdateEvent.forTarget(this);

  @DomName('HTMLMediaElement.onvolumechange')
  @DocsEditable
  Stream<Event> get onVolumeChange => volumeChangeEvent.forTarget(this);

  @DomName('HTMLMediaElement.onwaiting')
  @DocsEditable
  Stream<Event> get onWaiting => waitingEvent.forTarget(this);

  @DomName('HTMLMediaElement.onwebkitkeyadded')
  @DocsEditable
  Stream<MediaKeyEvent> get onKeyAdded => keyAddedEvent.forTarget(this);

  @DomName('HTMLMediaElement.onwebkitkeyerror')
  @DocsEditable
  Stream<MediaKeyEvent> get onKeyError => keyErrorEvent.forTarget(this);

  @DomName('HTMLMediaElement.onwebkitkeymessage')
  @DocsEditable
  Stream<MediaKeyEvent> get onKeyMessage => keyMessageEvent.forTarget(this);

  @DomName('HTMLMediaElement.onwebkitneedkey')
  @DocsEditable
  Stream<MediaKeyEvent> get onNeedKey => needKeyEvent.forTarget(this);

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('MediaError')
class MediaError extends NativeFieldWrapperClass1 {
  MediaError.internal();

  @DomName('MediaError.MEDIA_ERR_ABORTED')
  @DocsEditable
  static const int MEDIA_ERR_ABORTED = 1;

  @DomName('MediaError.MEDIA_ERR_DECODE')
  @DocsEditable
  static const int MEDIA_ERR_DECODE = 3;

  @DomName('MediaError.MEDIA_ERR_ENCRYPTED')
  @DocsEditable
  static const int MEDIA_ERR_ENCRYPTED = 5;

  @DomName('MediaError.MEDIA_ERR_NETWORK')
  @DocsEditable
  static const int MEDIA_ERR_NETWORK = 2;

  @DomName('MediaError.MEDIA_ERR_SRC_NOT_SUPPORTED')
  @DocsEditable
  static const int MEDIA_ERR_SRC_NOT_SUPPORTED = 4;

  @DomName('MediaError.code')
  @DocsEditable
  int get code native "MediaError_code_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('MediaKeyError')
class MediaKeyError extends NativeFieldWrapperClass1 {
  MediaKeyError.internal();

  @DomName('MediaKeyError.MEDIA_KEYERR_CLIENT')
  @DocsEditable
  static const int MEDIA_KEYERR_CLIENT = 2;

  @DomName('MediaKeyError.MEDIA_KEYERR_DOMAIN')
  @DocsEditable
  static const int MEDIA_KEYERR_DOMAIN = 6;

  @DomName('MediaKeyError.MEDIA_KEYERR_HARDWARECHANGE')
  @DocsEditable
  static const int MEDIA_KEYERR_HARDWARECHANGE = 5;

  @DomName('MediaKeyError.MEDIA_KEYERR_OUTPUT')
  @DocsEditable
  static const int MEDIA_KEYERR_OUTPUT = 4;

  @DomName('MediaKeyError.MEDIA_KEYERR_SERVICE')
  @DocsEditable
  static const int MEDIA_KEYERR_SERVICE = 3;

  @DomName('MediaKeyError.MEDIA_KEYERR_UNKNOWN')
  @DocsEditable
  static const int MEDIA_KEYERR_UNKNOWN = 1;

  @DomName('MediaKeyError.code')
  @DocsEditable
  int get code native "MediaKeyError_code_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('MediaKeyEvent')
class MediaKeyEvent extends Event {
  MediaKeyEvent.internal() : super.internal();

  @DomName('MediaKeyEvent.defaultURL')
  @DocsEditable
  String get defaultUrl native "MediaKeyEvent_defaultURL_Getter";

  @DomName('MediaKeyEvent.errorCode')
  @DocsEditable
  MediaKeyError get errorCode native "MediaKeyEvent_errorCode_Getter";

  @DomName('MediaKeyEvent.initData')
  @DocsEditable
  Uint8List get initData native "MediaKeyEvent_initData_Getter";

  @DomName('MediaKeyEvent.keySystem')
  @DocsEditable
  String get keySystem native "MediaKeyEvent_keySystem_Getter";

  @DomName('MediaKeyEvent.message')
  @DocsEditable
  Uint8List get message native "MediaKeyEvent_message_Getter";

  @DomName('MediaKeyEvent.sessionId')
  @DocsEditable
  String get sessionId native "MediaKeyEvent_sessionId_Getter";

  @DomName('MediaKeyEvent.systemCode')
  @DocsEditable
  int get systemCode native "MediaKeyEvent_systemCode_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('MediaList')
class MediaList extends NativeFieldWrapperClass1 {
  MediaList.internal();

  @DomName('MediaList.length')
  @DocsEditable
  int get length native "MediaList_length_Getter";

  @DomName('MediaList.mediaText')
  @DocsEditable
  String get mediaText native "MediaList_mediaText_Getter";

  @DomName('MediaList.mediaText')
  @DocsEditable
  void set mediaText(String value) native "MediaList_mediaText_Setter";

  @DomName('MediaList.appendMedium')
  @DocsEditable
  void appendMedium(String newMedium) native "MediaList_appendMedium_Callback";

  @DomName('MediaList.deleteMedium')
  @DocsEditable
  void deleteMedium(String oldMedium) native "MediaList_deleteMedium_Callback";

  @DomName('MediaList.item')
  @DocsEditable
  String item(int index) native "MediaList_item_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('MediaQueryList')
class MediaQueryList extends NativeFieldWrapperClass1 {
  MediaQueryList.internal();

  @DomName('MediaQueryList.matches')
  @DocsEditable
  bool get matches native "MediaQueryList_matches_Getter";

  @DomName('MediaQueryList.media')
  @DocsEditable
  String get media native "MediaQueryList_media_Getter";

  @DomName('MediaQueryList.addListener')
  @DocsEditable
  void addListener(MediaQueryListListener listener) native "MediaQueryList_addListener_Callback";

  @DomName('MediaQueryList.removeListener')
  @DocsEditable
  void removeListener(MediaQueryListListener listener) native "MediaQueryList_removeListener_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('MediaQueryListListener')
class MediaQueryListListener extends NativeFieldWrapperClass1 {
  MediaQueryListListener.internal();

  @DomName('MediaQueryListListener.queryChanged')
  @DocsEditable
  void queryChanged(MediaQueryList list) native "MediaQueryListListener_queryChanged_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('MediaSource')
class MediaSource extends EventTarget {
  MediaSource.internal() : super.internal();

  @DomName('MediaSource.MediaSource')
  @DocsEditable
  factory MediaSource() {
    return MediaSource._create_1();
  }

  @DocsEditable
  static MediaSource _create_1() native "MediaSource__create_1constructorCallback";

  @DomName('MediaSource.activeSourceBuffers')
  @DocsEditable
  SourceBufferList get activeSourceBuffers native "MediaSource_activeSourceBuffers_Getter";

  @DomName('MediaSource.duration')
  @DocsEditable
  num get duration native "MediaSource_duration_Getter";

  @DomName('MediaSource.duration')
  @DocsEditable
  void set duration(num value) native "MediaSource_duration_Setter";

  @DomName('MediaSource.readyState')
  @DocsEditable
  String get readyState native "MediaSource_readyState_Getter";

  @DomName('MediaSource.sourceBuffers')
  @DocsEditable
  SourceBufferList get sourceBuffers native "MediaSource_sourceBuffers_Getter";

  @DomName('MediaSource.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "MediaSource_addEventListener_Callback";

  @DomName('MediaSource.addSourceBuffer')
  @DocsEditable
  SourceBuffer addSourceBuffer(String type) native "MediaSource_addSourceBuffer_Callback";

  @DomName('MediaSource.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event event) native "MediaSource_dispatchEvent_Callback";

  @DomName('MediaSource.endOfStream')
  @DocsEditable
  void endOfStream(String error) native "MediaSource_endOfStream_Callback";

  @DomName('MediaSource.isTypeSupported')
  @DocsEditable
  static bool isTypeSupported(String type) native "MediaSource_isTypeSupported_Callback";

  @DomName('MediaSource.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "MediaSource_removeEventListener_Callback";

  @DomName('MediaSource.removeSourceBuffer')
  @DocsEditable
  void removeSourceBuffer(SourceBuffer buffer) native "MediaSource_removeSourceBuffer_Callback";

}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('MediaStream')
@SupportedBrowser(SupportedBrowser.CHROME)
@Experimental
class MediaStream extends EventTarget {
  MediaStream.internal() : super.internal();

  @DomName('MediaStream.addtrackEvent')
  @DocsEditable
  static const EventStreamProvider<Event> addTrackEvent = const EventStreamProvider<Event>('addtrack');

  @DomName('MediaStream.endedEvent')
  @DocsEditable
  static const EventStreamProvider<Event> endedEvent = const EventStreamProvider<Event>('ended');

  @DomName('MediaStream.removetrackEvent')
  @DocsEditable
  static const EventStreamProvider<Event> removeTrackEvent = const EventStreamProvider<Event>('removetrack');

  @DomName('MediaStream.MediaStream')
  @DocsEditable
  factory MediaStream([stream_OR_tracks]) {
    if (!?stream_OR_tracks) {
      return MediaStream._create_1();
    }
    if ((stream_OR_tracks is MediaStream || stream_OR_tracks == null)) {
      return MediaStream._create_2(stream_OR_tracks);
    }
    if ((stream_OR_tracks is List<MediaStreamTrack> || stream_OR_tracks == null)) {
      return MediaStream._create_3(stream_OR_tracks);
    }
    throw new ArgumentError("Incorrect number or type of arguments");
  }

  @DocsEditable
  static MediaStream _create_1() native "MediaStream__create_1constructorCallback";

  @DocsEditable
  static MediaStream _create_2(stream_OR_tracks) native "MediaStream__create_2constructorCallback";

  @DocsEditable
  static MediaStream _create_3(stream_OR_tracks) native "MediaStream__create_3constructorCallback";

  @DomName('MediaStream.ended')
  @DocsEditable
  bool get ended native "MediaStream_ended_Getter";

  @DomName('MediaStream.id')
  @DocsEditable
  String get id native "MediaStream_id_Getter";

  @DomName('MediaStream.label')
  @DocsEditable
  String get label native "MediaStream_label_Getter";

  @DomName('MediaStream.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "MediaStream_addEventListener_Callback";

  @DomName('MediaStream.addTrack')
  @DocsEditable
  void addTrack(MediaStreamTrack track) native "MediaStream_addTrack_Callback";

  @DomName('MediaStream.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event event) native "MediaStream_dispatchEvent_Callback";

  @DomName('MediaStream.getAudioTracks')
  @DocsEditable
  List<MediaStreamTrack> getAudioTracks() native "MediaStream_getAudioTracks_Callback";

  @DomName('MediaStream.getTrackById')
  @DocsEditable
  MediaStreamTrack getTrackById(String trackId) native "MediaStream_getTrackById_Callback";

  @DomName('MediaStream.getVideoTracks')
  @DocsEditable
  List<MediaStreamTrack> getVideoTracks() native "MediaStream_getVideoTracks_Callback";

  @DomName('MediaStream.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "MediaStream_removeEventListener_Callback";

  @DomName('MediaStream.removeTrack')
  @DocsEditable
  void removeTrack(MediaStreamTrack track) native "MediaStream_removeTrack_Callback";

  @DomName('MediaStream.onaddtrack')
  @DocsEditable
  Stream<Event> get onAddTrack => addTrackEvent.forTarget(this);

  @DomName('MediaStream.onended')
  @DocsEditable
  Stream<Event> get onEnded => endedEvent.forTarget(this);

  @DomName('MediaStream.onremovetrack')
  @DocsEditable
  Stream<Event> get onRemoveTrack => removeTrackEvent.forTarget(this);


  /**
   * Checks if the MediaStream APIs are supported on the current platform.
   *
   * See also:
   *
   * * [Navigator.getUserMedia]
   */
  static bool get supported => true;
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('MediaStreamEvent')
@SupportedBrowser(SupportedBrowser.CHROME)
@Experimental
class MediaStreamEvent extends Event {
  MediaStreamEvent.internal() : super.internal();

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('MediaStreamEvent.stream')
  @DocsEditable
  MediaStream get stream native "MediaStreamEvent_stream_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('MediaStreamTrack')
@SupportedBrowser(SupportedBrowser.CHROME)
@Experimental
class MediaStreamTrack extends EventTarget {
  MediaStreamTrack.internal() : super.internal();

  @DomName('MediaStreamTrack.endedEvent')
  @DocsEditable
  static const EventStreamProvider<Event> endedEvent = const EventStreamProvider<Event>('ended');

  @DomName('MediaStreamTrack.muteEvent')
  @DocsEditable
  static const EventStreamProvider<Event> muteEvent = const EventStreamProvider<Event>('mute');

  @DomName('MediaStreamTrack.unmuteEvent')
  @DocsEditable
  static const EventStreamProvider<Event> unmuteEvent = const EventStreamProvider<Event>('unmute');

  @DomName('MediaStreamTrack.enabled')
  @DocsEditable
  bool get enabled native "MediaStreamTrack_enabled_Getter";

  @DomName('MediaStreamTrack.enabled')
  @DocsEditable
  void set enabled(bool value) native "MediaStreamTrack_enabled_Setter";

  @DomName('MediaStreamTrack.id')
  @DocsEditable
  String get id native "MediaStreamTrack_id_Getter";

  @DomName('MediaStreamTrack.kind')
  @DocsEditable
  String get kind native "MediaStreamTrack_kind_Getter";

  @DomName('MediaStreamTrack.label')
  @DocsEditable
  String get label native "MediaStreamTrack_label_Getter";

  @DomName('MediaStreamTrack.readyState')
  @DocsEditable
  String get readyState native "MediaStreamTrack_readyState_Getter";

  @DomName('MediaStreamTrack.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "MediaStreamTrack_addEventListener_Callback";

  @DomName('MediaStreamTrack.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event event) native "MediaStreamTrack_dispatchEvent_Callback";

  @DomName('MediaStreamTrack.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "MediaStreamTrack_removeEventListener_Callback";

  @DomName('MediaStreamTrack.onended')
  @DocsEditable
  Stream<Event> get onEnded => endedEvent.forTarget(this);

  @DomName('MediaStreamTrack.onmute')
  @DocsEditable
  Stream<Event> get onMute => muteEvent.forTarget(this);

  @DomName('MediaStreamTrack.onunmute')
  @DocsEditable
  Stream<Event> get onUnmute => unmuteEvent.forTarget(this);

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('MediaStreamTrackEvent')
@SupportedBrowser(SupportedBrowser.CHROME)
@Experimental
class MediaStreamTrackEvent extends Event {
  MediaStreamTrackEvent.internal() : super.internal();

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('MediaStreamTrackEvent.track')
  @DocsEditable
  MediaStreamTrack get track native "MediaStreamTrackEvent_track_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('MemoryInfo')
class MemoryInfo extends NativeFieldWrapperClass1 {
  MemoryInfo.internal();

  @DomName('MemoryInfo.jsHeapSizeLimit')
  @DocsEditable
  int get jsHeapSizeLimit native "MemoryInfo_jsHeapSizeLimit_Getter";

  @DomName('MemoryInfo.totalJSHeapSize')
  @DocsEditable
  int get totalJSHeapSize native "MemoryInfo_totalJSHeapSize_Getter";

  @DomName('MemoryInfo.usedJSHeapSize')
  @DocsEditable
  int get usedJSHeapSize native "MemoryInfo_usedJSHeapSize_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
/**
 * An HTML <menu> element.
 *
 * A <menu> element represents an unordered list of menu commands.
 *
 * See also:
 *
 *  * [Menu Element](https://developer.mozilla.org/en-US/docs/HTML/Element/menu) from MDN.
 *  * [Menu Element](http://www.w3.org/TR/html5/the-menu-element.html#the-menu-element) from the W3C.
 */
@DomName('HTMLMenuElement')
class MenuElement extends _Element_Merged {
  MenuElement.internal() : super.internal();

  @DomName('HTMLMenuElement.HTMLMenuElement')
  @DocsEditable
  factory MenuElement() => document.$dom_createElement("menu");

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('MessageChannel')
class MessageChannel extends NativeFieldWrapperClass1 {
  MessageChannel.internal();
  factory MessageChannel() => _create();

  @DocsEditable
  static MessageChannel _create() native "MessageChannel_constructorCallback";

  @DomName('MessageChannel.port1')
  @DocsEditable
  MessagePort get port1 native "MessageChannel_port1_Getter";

  @DomName('MessageChannel.port2')
  @DocsEditable
  MessagePort get port2 native "MessageChannel_port2_Getter";

}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DomName('MessageEvent')
class MessageEvent extends Event {
  factory MessageEvent(String type,
      {bool canBubble: false, bool cancelable: false, Object data,
      String origin, String lastEventId,
      Window source, List messagePorts}) {
    if (source == null) {
      source = window;
    }
    var event = document.$dom_createEvent("MessageEvent");
    event.$dom_initMessageEvent(type, canBubble, cancelable, data, origin,
        lastEventId, source, messagePorts);
    return event;
  }
  MessageEvent.internal() : super.internal();

  @DomName('MessageEvent.data')
  @DocsEditable
  Object get data native "MessageEvent_data_Getter";

  @DomName('MessageEvent.lastEventId')
  @DocsEditable
  String get lastEventId native "MessageEvent_lastEventId_Getter";

  @DomName('MessageEvent.origin')
  @DocsEditable
  String get origin native "MessageEvent_origin_Getter";

  @DomName('MessageEvent.ports')
  @DocsEditable
  List get ports native "MessageEvent_ports_Getter";

  @DomName('MessageEvent.source')
  @DocsEditable
  WindowBase get source native "MessageEvent_source_Getter";

  @DomName('MessageEvent.initMessageEvent')
  @DocsEditable
  void $dom_initMessageEvent(String typeArg, bool canBubbleArg, bool cancelableArg, Object dataArg, String originArg, String lastEventIdArg, Window sourceArg, List messagePorts) native "MessageEvent_initMessageEvent_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('MessagePort')
class MessagePort extends EventTarget {
  MessagePort.internal() : super.internal();

  @DomName('MessagePort.messageEvent')
  @DocsEditable
  static const EventStreamProvider<MessageEvent> messageEvent = const EventStreamProvider<MessageEvent>('message');

  @DomName('MessagePort.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "MessagePort_addEventListener_Callback";

  @DomName('MessagePort.close')
  @DocsEditable
  void close() native "MessagePort_close_Callback";

  @DomName('MessagePort.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event evt) native "MessagePort_dispatchEvent_Callback";

  @DomName('MessagePort.postMessage')
  @DocsEditable
  void postMessage(Object message, [List messagePorts]) native "MessagePort_postMessage_Callback";

  @DomName('MessagePort.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "MessagePort_removeEventListener_Callback";

  @DomName('MessagePort.start')
  @DocsEditable
  void start() native "MessagePort_start_Callback";

  @DomName('MessagePort.onmessage')
  @DocsEditable
  Stream<MessageEvent> get onMessage => messageEvent.forTarget(this);

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLMetaElement')
class MetaElement extends _Element_Merged {
  MetaElement.internal() : super.internal();

  @DomName('HTMLMetaElement.content')
  @DocsEditable
  String get content native "HTMLMetaElement_content_Getter";

  @DomName('HTMLMetaElement.content')
  @DocsEditable
  void set content(String value) native "HTMLMetaElement_content_Setter";

  @DomName('HTMLMetaElement.httpEquiv')
  @DocsEditable
  String get httpEquiv native "HTMLMetaElement_httpEquiv_Getter";

  @DomName('HTMLMetaElement.httpEquiv')
  @DocsEditable
  void set httpEquiv(String value) native "HTMLMetaElement_httpEquiv_Setter";

  @DomName('HTMLMetaElement.name')
  @DocsEditable
  String get name native "HTMLMetaElement_name_Getter";

  @DomName('HTMLMetaElement.name')
  @DocsEditable
  void set name(String value) native "HTMLMetaElement_name_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('Metadata')
class Metadata extends NativeFieldWrapperClass1 {
  Metadata.internal();

  @DomName('Metadata.modificationTime')
  @DocsEditable
  DateTime get modificationTime native "Metadata_modificationTime_Getter";

  @DomName('Metadata.size')
  @DocsEditable
  int get size native "Metadata_size_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


typedef void MetadataCallback(Metadata metadata);
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLMeterElement')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.FIREFOX)
@SupportedBrowser(SupportedBrowser.SAFARI)
class MeterElement extends _Element_Merged {
  MeterElement.internal() : super.internal();

  @DomName('HTMLMeterElement.HTMLMeterElement')
  @DocsEditable
  factory MeterElement() => document.$dom_createElement("meter");

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('HTMLMeterElement.high')
  @DocsEditable
  num get high native "HTMLMeterElement_high_Getter";

  @DomName('HTMLMeterElement.high')
  @DocsEditable
  void set high(num value) native "HTMLMeterElement_high_Setter";

  @DomName('HTMLMeterElement.labels')
  @DocsEditable
  List<Node> get labels native "HTMLMeterElement_labels_Getter";

  @DomName('HTMLMeterElement.low')
  @DocsEditable
  num get low native "HTMLMeterElement_low_Getter";

  @DomName('HTMLMeterElement.low')
  @DocsEditable
  void set low(num value) native "HTMLMeterElement_low_Setter";

  @DomName('HTMLMeterElement.max')
  @DocsEditable
  num get max native "HTMLMeterElement_max_Getter";

  @DomName('HTMLMeterElement.max')
  @DocsEditable
  void set max(num value) native "HTMLMeterElement_max_Setter";

  @DomName('HTMLMeterElement.min')
  @DocsEditable
  num get min native "HTMLMeterElement_min_Getter";

  @DomName('HTMLMeterElement.min')
  @DocsEditable
  void set min(num value) native "HTMLMeterElement_min_Setter";

  @DomName('HTMLMeterElement.optimum')
  @DocsEditable
  num get optimum native "HTMLMeterElement_optimum_Getter";

  @DomName('HTMLMeterElement.optimum')
  @DocsEditable
  void set optimum(num value) native "HTMLMeterElement_optimum_Setter";

  @DomName('HTMLMeterElement.value')
  @DocsEditable
  num get value native "HTMLMeterElement_value_Getter";

  @DomName('HTMLMeterElement.value')
  @DocsEditable
  void set value(num value) native "HTMLMeterElement_value_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('MimeType')
class MimeType extends NativeFieldWrapperClass1 {
  MimeType.internal();

  @DomName('MimeType.description')
  @DocsEditable
  String get description native "DOMMimeType_description_Getter";

  @DomName('MimeType.enabledPlugin')
  @DocsEditable
  Plugin get enabledPlugin native "DOMMimeType_enabledPlugin_Getter";

  @DomName('MimeType.suffixes')
  @DocsEditable
  String get suffixes native "DOMMimeType_suffixes_Getter";

  @DomName('MimeType.type')
  @DocsEditable
  String get type native "DOMMimeType_type_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('MimeTypeArray')
class MimeTypeArray extends NativeFieldWrapperClass1 with ListMixin<MimeType>, ImmutableListMixin<MimeType> implements List<MimeType> {
  MimeTypeArray.internal();

  @DomName('MimeTypeArray.length')
  @DocsEditable
  int get length native "DOMMimeTypeArray_length_Getter";

  MimeType operator[](int index) {
    if (index < 0 || index >= length)
      throw new RangeError.range(index, 0, length);
    return _nativeIndexedGetter(index);
  }
  MimeType _nativeIndexedGetter(int index) native "DOMMimeTypeArray_item_Callback";

  void operator[]=(int index, MimeType value) {
    throw new UnsupportedError("Cannot assign element of immutable List.");
  }
  // -- start List<MimeType> mixins.
  // MimeType is the element type.


  void set length(int value) {
    throw new UnsupportedError("Cannot resize immutable List.");
  }

  MimeType get first {
    if (this.length > 0) {
      return this[0];
    }
    throw new StateError("No elements");
  }

  MimeType get last {
    int len = this.length;
    if (len > 0) {
      return this[len - 1];
    }
    throw new StateError("No elements");
  }

  MimeType get single {
    int len = this.length;
    if (len == 1) {
      return this[0];
    }
    if (len == 0) throw new StateError("No elements");
    throw new StateError("More than one element");
  }

  MimeType elementAt(int index) => this[index];
  // -- end List<MimeType> mixins.

  @DomName('MimeTypeArray.item')
  @DocsEditable
  MimeType item(int index) native "DOMMimeTypeArray_item_Callback";

  @DomName('MimeTypeArray.namedItem')
  @DocsEditable
  MimeType namedItem(String name) native "DOMMimeTypeArray_namedItem_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLModElement')
class ModElement extends _Element_Merged {
  ModElement.internal() : super.internal();

  @DomName('HTMLModElement.cite')
  @DocsEditable
  String get cite native "HTMLModElement_cite_Getter";

  @DomName('HTMLModElement.cite')
  @DocsEditable
  void set cite(String value) native "HTMLModElement_cite_Setter";

  @DomName('HTMLModElement.dateTime')
  @DocsEditable
  String get dateTime native "HTMLModElement_dateTime_Getter";

  @DomName('HTMLModElement.dateTime')
  @DocsEditable
  void set dateTime(String value) native "HTMLModElement_dateTime_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DomName('MouseEvent')
class MouseEvent extends UIEvent {
  factory MouseEvent(String type,
      {Window view, int detail: 0, int screenX: 0, int screenY: 0,
      int clientX: 0, int clientY: 0, int button: 0, bool canBubble: true,
      bool cancelable: true, bool ctrlKey: false, bool altKey: false,
      bool shiftKey: false, bool metaKey: false, EventTarget relatedTarget}) {

    if (view == null) {
      view = window;
    }
    var event = document.$dom_createEvent('MouseEvent');
    event.$dom_initMouseEvent(type, canBubble, cancelable, view, detail,
        screenX, screenY, clientX, clientY, ctrlKey, altKey, shiftKey, metaKey,
        button, relatedTarget);
    return event;
  }
  MouseEvent.internal() : super.internal();

  @DomName('MouseEvent.altKey')
  @DocsEditable
  bool get altKey native "MouseEvent_altKey_Getter";

  @DomName('MouseEvent.button')
  @DocsEditable
  int get button native "MouseEvent_button_Getter";

  @DomName('MouseEvent.clientX')
  @DocsEditable
  int get $dom_clientX native "MouseEvent_clientX_Getter";

  @DomName('MouseEvent.clientY')
  @DocsEditable
  int get $dom_clientY native "MouseEvent_clientY_Getter";

  @DomName('MouseEvent.ctrlKey')
  @DocsEditable
  bool get ctrlKey native "MouseEvent_ctrlKey_Getter";

  @DomName('MouseEvent.dataTransfer')
  @DocsEditable
  DataTransfer get dataTransfer native "MouseEvent_dataTransfer_Getter";

  @DomName('MouseEvent.fromElement')
  @DocsEditable
  Node get fromElement native "MouseEvent_fromElement_Getter";

  @DomName('MouseEvent.metaKey')
  @DocsEditable
  bool get metaKey native "MouseEvent_metaKey_Getter";

  @DomName('MouseEvent.offsetX')
  @DocsEditable
  int get $dom_offsetX native "MouseEvent_offsetX_Getter";

  @DomName('MouseEvent.offsetY')
  @DocsEditable
  int get $dom_offsetY native "MouseEvent_offsetY_Getter";

  @DomName('MouseEvent.relatedTarget')
  @DocsEditable
  EventTarget get relatedTarget native "MouseEvent_relatedTarget_Getter";

  @DomName('MouseEvent.screenX')
  @DocsEditable
  int get $dom_screenX native "MouseEvent_screenX_Getter";

  @DomName('MouseEvent.screenY')
  @DocsEditable
  int get $dom_screenY native "MouseEvent_screenY_Getter";

  @DomName('MouseEvent.shiftKey')
  @DocsEditable
  bool get shiftKey native "MouseEvent_shiftKey_Getter";

  @DomName('MouseEvent.toElement')
  @DocsEditable
  Node get toElement native "MouseEvent_toElement_Getter";

  @DomName('MouseEvent.webkitMovementX')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  int get $dom_webkitMovementX native "MouseEvent_webkitMovementX_Getter";

  @DomName('MouseEvent.webkitMovementY')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  int get $dom_webkitMovementY native "MouseEvent_webkitMovementY_Getter";

  @DomName('MouseEvent.initMouseEvent')
  @DocsEditable
  void $dom_initMouseEvent(String type, bool canBubble, bool cancelable, Window view, int detail, int screenX, int screenY, int clientX, int clientY, bool ctrlKey, bool altKey, bool shiftKey, bool metaKey, int button, EventTarget relatedTarget) native "MouseEvent_initMouseEvent_Callback";


  @deprecated
  int get clientX => client.x;
  @deprecated
  int get clientY => client.y;
  @deprecated
  int get offsetX => offset.x;
  @deprecated
  int get offsetY => offset.y;
  @deprecated
  int get movementX => movement.x;
  @deprecated
  int get movementY => movement.y;
  @deprecated
  int get screenX => screen.x;
  @deprecated
  int get screenY => screen.y;

  @DomName('MouseEvent.clientX')
  @DomName('MouseEvent.clientY')
  Point get client => new Point($dom_clientX, $dom_clientY);

  @DomName('MouseEvent.movementX')
  @DomName('MouseEvent.movementY')
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  Point get movement => new Point($dom_webkitMovementX, $dom_webkitMovementY);

  /**
   * The coordinates of the mouse pointer in target node coordinates.
   *
   * This value may vary between platforms if the target node moves
   * after the event has fired or if the element has CSS transforms affecting
   * it.
   */
  Point get offset => new Point($dom_offsetX, $dom_offsetY);

  @DomName('MouseEvent.screenX')
  @DomName('MouseEvent.screenY')
  Point get screen => new Point($dom_screenX, $dom_screenY);
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


typedef void MutationCallback(List<MutationRecord> mutations, MutationObserver observer);
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('MutationEvent')
class MutationEvent extends Event {
  factory MutationEvent(String type,
      {bool canBubble: false, bool cancelable: false, Node relatedNode,
      String prevValue, String newValue, String attrName, int attrChange: 0}) {

    var event = document.$dom_createEvent('MutationEvent');
    event.$dom_initMutationEvent(type, canBubble, cancelable, relatedNode,
        prevValue, newValue, attrName, attrChange);
    return event;
  }
  MutationEvent.internal() : super.internal();

  @DomName('MutationEvent.ADDITION')
  @DocsEditable
  static const int ADDITION = 2;

  @DomName('MutationEvent.MODIFICATION')
  @DocsEditable
  static const int MODIFICATION = 1;

  @DomName('MutationEvent.REMOVAL')
  @DocsEditable
  static const int REMOVAL = 3;

  @DomName('MutationEvent.attrChange')
  @DocsEditable
  int get attrChange native "MutationEvent_attrChange_Getter";

  @DomName('MutationEvent.attrName')
  @DocsEditable
  String get attrName native "MutationEvent_attrName_Getter";

  @DomName('MutationEvent.newValue')
  @DocsEditable
  String get newValue native "MutationEvent_newValue_Getter";

  @DomName('MutationEvent.prevValue')
  @DocsEditable
  String get prevValue native "MutationEvent_prevValue_Getter";

  @DomName('MutationEvent.relatedNode')
  @DocsEditable
  Node get relatedNode native "MutationEvent_relatedNode_Getter";

  @DomName('MutationEvent.initMutationEvent')
  @DocsEditable
  void $dom_initMutationEvent(String type, bool canBubble, bool cancelable, Node relatedNode, String prevValue, String newValue, String attrName, int attrChange) native "MutationEvent_initMutationEvent_Callback";

}



// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('MutationObserver')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.FIREFOX)
@SupportedBrowser(SupportedBrowser.SAFARI)
@Experimental
class MutationObserver extends NativeFieldWrapperClass1 {
  MutationObserver.internal();
  factory MutationObserver(MutationCallback callback) => _create(callback);

  @DocsEditable
  static MutationObserver _create(callback) native "MutationObserver_constructorCallback";

  @DomName('MutationObserver.disconnect')
  @DocsEditable
  void disconnect() native "MutationObserver_disconnect_Callback";

  @DomName('MutationObserver.observe')
  @DocsEditable
  void _observe(Node target, Map options) native "MutationObserver_observe_Callback";

  @DomName('MutationObserver.takeRecords')
  @DocsEditable
  List<MutationRecord> takeRecords() native "MutationObserver_takeRecords_Callback";

  /**
   * Checks to see if the mutation observer API is supported on the current
   * platform.
   */
  static bool get supported {
    return true;
  }

  void observe(Node target,
               {bool childList,
                bool attributes,
                bool characterData,
                bool subtree,
                bool attributeOldValue,
                bool characterDataOldValue,
                List<String> attributeFilter}) {

    // Parse options into map of known type.
    var parsedOptions = _createDict();

    // Override options passed in the map with named optional arguments.
    override(key, value) {
      if (value != null) _add(parsedOptions, key, value);
    }

    override('childList', childList);
    override('attributes', attributes);
    override('characterData', characterData);
    override('subtree', subtree);
    override('attributeOldValue', attributeOldValue);
    override('characterDataOldValue', characterDataOldValue);
    if (attributeFilter != null) {
      override('attributeFilter', _fixupList(attributeFilter));
    }

    _call(target, parsedOptions);
  }

   // TODO: Change to a set when const Sets are available.
  static final _boolKeys =
    const {'childList': true,
           'attributes': true,
           'characterData': true,
           'subtree': true,
           'attributeOldValue': true,
           'characterDataOldValue': true };

  static _createDict() => {};
  static _add(m, String key, value) { m[key] = value; }
  static _fixupList(list) => list;

  void _call(Node target, options) {
    _observe(target, options);
  }

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('MutationRecord')
class MutationRecord extends NativeFieldWrapperClass1 {
  MutationRecord.internal();

  @DomName('MutationRecord.addedNodes')
  @DocsEditable
  List<Node> get addedNodes native "MutationRecord_addedNodes_Getter";

  @DomName('MutationRecord.attributeName')
  @DocsEditable
  String get attributeName native "MutationRecord_attributeName_Getter";

  @DomName('MutationRecord.attributeNamespace')
  @DocsEditable
  String get attributeNamespace native "MutationRecord_attributeNamespace_Getter";

  @DomName('MutationRecord.nextSibling')
  @DocsEditable
  Node get nextSibling native "MutationRecord_nextSibling_Getter";

  @DomName('MutationRecord.oldValue')
  @DocsEditable
  String get oldValue native "MutationRecord_oldValue_Getter";

  @DomName('MutationRecord.previousSibling')
  @DocsEditable
  Node get previousSibling native "MutationRecord_previousSibling_Getter";

  @DomName('MutationRecord.removedNodes')
  @DocsEditable
  List<Node> get removedNodes native "MutationRecord_removedNodes_Getter";

  @DomName('MutationRecord.target')
  @DocsEditable
  Node get target native "MutationRecord_target_Getter";

  @DomName('MutationRecord.type')
  @DocsEditable
  String get type native "MutationRecord_type_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('WebKitNamedFlow')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.SAFARI)
@Experimental
class NamedFlow extends EventTarget {
  NamedFlow.internal() : super.internal();

  @DomName('WebKitNamedFlow.firstEmptyRegionIndex')
  @DocsEditable
  int get firstEmptyRegionIndex native "NamedFlow_firstEmptyRegionIndex_Getter";

  @DomName('WebKitNamedFlow.name')
  @DocsEditable
  String get name native "NamedFlow_name_Getter";

  @DomName('WebKitNamedFlow.overset')
  @DocsEditable
  bool get overset native "NamedFlow_overset_Getter";

  @DomName('WebKitNamedFlow.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "NamedFlow_addEventListener_Callback";

  @DomName('WebKitNamedFlow.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event event) native "NamedFlow_dispatchEvent_Callback";

  @DomName('WebKitNamedFlow.getContent')
  @DocsEditable
  List<Node> getContent() native "NamedFlow_getContent_Callback";

  @DomName('WebKitNamedFlow.getRegions')
  @DocsEditable
  List<Node> getRegions() native "NamedFlow_getRegions_Callback";

  @DomName('WebKitNamedFlow.getRegionsByContent')
  @DocsEditable
  List<Node> getRegionsByContent(Node contentNode) native "NamedFlow_getRegionsByContent_Callback";

  @DomName('WebKitNamedFlow.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "NamedFlow_removeEventListener_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('WebKitNamedFlowCollection')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.SAFARI)
@Experimental
class NamedFlowCollection extends NativeFieldWrapperClass1 {
  NamedFlowCollection.internal();

  @DomName('WebKitNamedFlowCollection.length')
  @DocsEditable
  int get length native "DOMNamedFlowCollection_length_Getter";

  @DomName('WebKitNamedFlowCollection.item')
  @DocsEditable
  NamedFlow item(int index) native "DOMNamedFlowCollection_item_Callback";

  @DomName('WebKitNamedFlowCollection.namedItem')
  @DocsEditable
  NamedFlow namedItem(String name) native "DOMNamedFlowCollection_namedItem_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('Navigator')
class Navigator extends NativeFieldWrapperClass1 {


  /**
   * Gets a stream (video and or audio) from the local computer.
   *
   * Use [MediaStream.supported] to check if this is supported by the current
   * platform. The arguments `audio` and `video` default to `false` (stream does
   * not use audio or video, respectively).
   *
   * Simple example usage:
   *
   *     window.navigator.getUserMedia(audio: true, video: true).then((stream) {
   *       var video = new VideoElement()
   *         ..autoplay = true
   *         ..src = Url.createObjectUrl(stream);
   *       document.body.append(video);
   *     });
   *
   * The user can also pass in Maps to the audio or video parameters to specify 
   * mandatory and optional constraints for the media stream. Not passing in a 
   * map, but passing in `true` will provide a LocalMediaStream with audio or 
   * video capabilities, but without any additional constraints. The particular
   * constraint names for audio and video are still in flux, but as of this 
   * writing, here is an example providing more constraints.
   *
   *     window.navigator.getUserMedia(
   *         audio: true, 
   *         video: {'mandatory': 
   *                    { 'minAspectRatio': 1.333, 'maxAspectRatio': 1.334 },
   *                 'optional': 
   *                    [{ 'minFrameRate': 60 },
   *                     { 'maxWidth': 640 }]
   *     });
   *
   * See also:
   * * [MediaStream.supported]
   */
  @DomName('Navigator.webkitGetUserMedia')
  @SupportedBrowser(SupportedBrowser.CHROME)
  @Experimental
  Future<LocalMediaStream> getUserMedia({audio: false, video: false}) {
    var completer = new Completer<LocalMediaStream>();
    var options = {
      'audio': audio,
      'video': video
    };
    this._getUserMedia(options,
      (stream) {
        completer.complete(stream);
      },
      (error) {
        completer.completeError(error);
      });
    return completer.future;
  }


  Navigator.internal();

  @DomName('Navigator.appCodeName')
  @DocsEditable
  String get appCodeName native "Navigator_appCodeName_Getter";

  @DomName('Navigator.appName')
  @DocsEditable
  String get appName native "Navigator_appName_Getter";

  @DomName('Navigator.appVersion')
  @DocsEditable
  String get appVersion native "Navigator_appVersion_Getter";

  @DomName('Navigator.cookieEnabled')
  @DocsEditable
  bool get cookieEnabled native "Navigator_cookieEnabled_Getter";

  @DomName('Navigator.doNotTrack')
  @DocsEditable
  String get doNotTrack native "Navigator_doNotTrack_Getter";

  @DomName('Navigator.geolocation')
  @DocsEditable
  Geolocation get geolocation native "Navigator_geolocation_Getter";

  @DomName('Navigator.language')
  @DocsEditable
  String get language native "Navigator_language_Getter";

  @DomName('Navigator.mimeTypes')
  @DocsEditable
  MimeTypeArray get mimeTypes native "Navigator_mimeTypes_Getter";

  @DomName('Navigator.onLine')
  @DocsEditable
  bool get onLine native "Navigator_onLine_Getter";

  @DomName('Navigator.platform')
  @DocsEditable
  String get platform native "Navigator_platform_Getter";

  @DomName('Navigator.plugins')
  @DocsEditable
  PluginArray get plugins native "Navigator_plugins_Getter";

  @DomName('Navigator.product')
  @DocsEditable
  String get product native "Navigator_product_Getter";

  @DomName('Navigator.productSub')
  @DocsEditable
  String get productSub native "Navigator_productSub_Getter";

  @DomName('Navigator.userAgent')
  @DocsEditable
  String get userAgent native "Navigator_userAgent_Getter";

  @DomName('Navigator.vendor')
  @DocsEditable
  String get vendor native "Navigator_vendor_Getter";

  @DomName('Navigator.vendorSub')
  @DocsEditable
  String get vendorSub native "Navigator_vendorSub_Getter";

  @DomName('Navigator.webkitPersistentStorage')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  StorageQuota get persistentStorage native "Navigator_webkitPersistentStorage_Getter";

  @DomName('Navigator.webkitTemporaryStorage')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  StorageQuota get temporaryStorage native "Navigator_webkitTemporaryStorage_Getter";

  @DomName('Navigator.getStorageUpdates')
  @DocsEditable
  void getStorageUpdates() native "Navigator_getStorageUpdates_Callback";

  @DomName('Navigator.javaEnabled')
  @DocsEditable
  bool javaEnabled() native "Navigator_javaEnabled_Callback";

  @DomName('Navigator.registerProtocolHandler')
  @DocsEditable
  void registerProtocolHandler(String scheme, String url, String title) native "Navigator_registerProtocolHandler_Callback";

  @DomName('Navigator.webkitGetGamepads')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  List<Gamepad> getGamepads() native "Navigator_webkitGetGamepads_Callback";

  @DomName('Navigator.webkitGetUserMedia')
  @DocsEditable
  void _getUserMedia(Map options, _NavigatorUserMediaSuccessCallback successCallback, [_NavigatorUserMediaErrorCallback errorCallback]) native "Navigator_webkitGetUserMedia_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('NavigatorUserMediaError')
class NavigatorUserMediaError extends NativeFieldWrapperClass1 {
  NavigatorUserMediaError.internal();

  @DomName('NavigatorUserMediaError.PERMISSION_DENIED')
  @DocsEditable
  static const int PERMISSION_DENIED = 1;

  @DomName('NavigatorUserMediaError.code')
  @DocsEditable
  int get code native "NavigatorUserMediaError_code_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


typedef void _NavigatorUserMediaErrorCallback(NavigatorUserMediaError error);
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


typedef void _NavigatorUserMediaSuccessCallback(LocalMediaStream stream);
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/**
 * Lazy implementation of the child nodes of an element that does not request
 * the actual child nodes of an element until strictly necessary greatly
 * improving performance for the typical cases where it is not required.
 */
class _ChildNodeListLazy extends ListBase<Node> {
  final Node _this;

  _ChildNodeListLazy(this._this);


  Node get first {
    Node result = _this.$dom_firstChild;
    if (result == null) throw new StateError("No elements");
    return result;
  }
  Node get last {
    Node result = _this.$dom_lastChild;
    if (result == null) throw new StateError("No elements");
    return result;
  }
  Node get single {
    int l = this.length;
    if (l == 0) throw new StateError("No elements");
    if (l > 1) throw new StateError("More than one element");
    return _this.$dom_firstChild;
  }

  void add(Node value) {
    _this.append(value);
  }

  void addAll(Iterable<Node> iterable) {
    if (iterable is _ChildNodeListLazy) {
      if (!identical(iterable._this, _this)) {
        // Optimized route for copying between nodes.
        for (var i = 0, len = iterable.length; i < len; ++i) {
          // Should use $dom_firstChild, Bug 8886.
          _this.append(iterable[0]);
        }
      }
      return;
    }
    for (Node node in iterable) {
      _this.append(node);
    }
  }

  void insert(int index, Node node) {
    if (index < 0 || index > length) {
      throw new RangeError.range(index, 0, length);
    }
    if (index == length) {
      _this.append(node);
    } else {
      _this.insertBefore(node, this[index]);
    }
  }

  void insertAll(int index, Iterable<Node> iterable) {
    var item = this[index];
    _this.insertAllBefore(iterable, item);
  }

  void setAll(int index, Iterable<Node> iterable) {
    throw new UnsupportedError("Cannot setAll on Node list");
  }

  Node removeLast() {
    final result = last;
    if (result != null) {
      _this.$dom_removeChild(result);
    }
    return result;
  }

  Node removeAt(int index) {
    var result = this[index];
    if (result != null) {
      _this.$dom_removeChild(result);
    }
    return result;
  }

  bool remove(Object object) {
    if (object is! Node) return false;
    Node node = object;
    if (!identical(_this, node.parentNode)) return false;
    _this.$dom_removeChild(node);
    return true;
  }

  void _filter(bool test(Node node), bool removeMatching) {
    // This implementation of removeWhere/retainWhere is more efficient
    // than the default in ListBase. Child nodes can be removed in constant
    // time.
    Node child = _this.$dom_firstChild;
    while (child != null) {
      Node nextChild = child.nextNode;
      if (test(child) == removeMatching) {
        _this.$dom_removeChild(child);
      }
      child = nextChild;
    }
  }

  void removeWhere(bool test(Node node)) {
    _filter(test, true);
  }

  void retainWhere(bool test(Node node)) {
    _filter(test, false);
  }

  void clear() {
    _this.text = '';
  }

  void operator []=(int index, Node value) {
    _this.$dom_replaceChild(value, this[index]);
  }

  Iterator<Node> get iterator => _this.$dom_childNodes.iterator;

  // From List<Node>:

  // TODO(jacobr): this could be implemented for child node lists.
  // The exception we throw here is misleading.
  void sort([Comparator<Node> compare]) {
    throw new UnsupportedError("Cannot sort Node list");
  }

  // FIXME: implement these.
  void setRange(int start, int end, Iterable<Node> iterable,
                [int skipCount = 0]) {
    throw new UnsupportedError("Cannot setRange on Node list");
  }

  void fillRange(int start, int end, [Node fill]) {
    throw new UnsupportedError("Cannot fillRange on Node list");
  }
  // -- end List<Node> mixins.

  // TODO(jacobr): benchmark whether this is more efficient or whether caching
  // a local copy of $dom_childNodes is more efficient.
  int get length => _this.$dom_childNodes.length;

  void set length(int value) {
    throw new UnsupportedError(
        "Cannot set length on immutable List.");
  }

  Node operator[](int index) => _this.$dom_childNodes[index];
}

@DomName('Node')
class Node extends EventTarget {
  List<Node> get nodes {
    return new _ChildNodeListLazy(this);
  }

  void set nodes(Iterable<Node> value) {
    // Copy list first since we don't want liveness during iteration.
    // TODO(jacobr): there is a better way to do this.
    List copy = new List.from(value);
    text = '';
    for (Node node in copy) {
      append(node);
    }
  }

  /**
   * Removes this node from the DOM.
   */
  @DomName('Node.removeChild')
  void remove() {
    // TODO(jacobr): should we throw an exception if parent is already null?
    // TODO(vsm): Use the native remove when available.
    if (this.parentNode != null) {
      final Node parent = this.parentNode;
      parentNode.$dom_removeChild(this);
    }
  }

  /**
   * Replaces this node with another node.
   */
  @DomName('Node.replaceChild')
  Node replaceWith(Node otherNode) {
    try {
      final Node parent = this.parentNode;
      parent.$dom_replaceChild(otherNode, this);
    } catch (e) {

    };
    return this;
  }

  /**
   * Inserts all of the nodes into this node directly before refChild.
   *
   * See also:
   *
   * * [insertBefore]
   */
  Node insertAllBefore(Iterable<Node> newNodes, Node refChild) {
    if (newNodes is _ChildNodeListLazy) {
      if (identical(newNodes._this, this)) {
        throw new ArgumentError(newNodes);
      }

      // Optimized route for copying between nodes.
      for (var i = 0, len = newNodes.length; i < len; ++i) {
        // Should use $dom_firstChild, Bug 8886.
        this.insertBefore(newNodes[0], refChild);
      }
    } else {
      for (var node in newNodes) {
        this.insertBefore(node, refChild);
      }
    }
  }

  /**
   * Print out a String representation of this Node.
   */
  String toString() => localName == null ?
      (nodeValue == null ? super.toString() : nodeValue) : localName;

  /**
   * Binds the attribute [name] to the [path] of the [model].
   * Path is a String of accessors such as `foo.bar.baz`.
   */
  @Experimental
  void bind(String name, model, String path) {
    // TODO(jmesserly): should we throw instead?
    window.console.error('Unhandled binding to Node: '
        '$this $name $model $path');
  }

  /** Unbinds the attribute [name]. */
  @Experimental
  void unbind(String name) {}

  /** Unbinds all bound attributes. */
  @Experimental
  void unbindAll() {}

  TemplateInstance _templateInstance;

  /** Gets the template instance that instantiated this node, if any. */
  @Experimental
  TemplateInstance get templateInstance =>
      _templateInstance != null ? _templateInstance :
      (parent != null ? parent.templateInstance : null);

  Node.internal() : super.internal();

  @DomName('Node.ATTRIBUTE_NODE')
  @DocsEditable
  static const int ATTRIBUTE_NODE = 2;

  @DomName('Node.CDATA_SECTION_NODE')
  @DocsEditable
  static const int CDATA_SECTION_NODE = 4;

  @DomName('Node.COMMENT_NODE')
  @DocsEditable
  static const int COMMENT_NODE = 8;

  @DomName('Node.DOCUMENT_FRAGMENT_NODE')
  @DocsEditable
  static const int DOCUMENT_FRAGMENT_NODE = 11;

  @DomName('Node.DOCUMENT_NODE')
  @DocsEditable
  static const int DOCUMENT_NODE = 9;

  @DomName('Node.DOCUMENT_TYPE_NODE')
  @DocsEditable
  static const int DOCUMENT_TYPE_NODE = 10;

  @DomName('Node.ELEMENT_NODE')
  @DocsEditable
  static const int ELEMENT_NODE = 1;

  @DomName('Node.ENTITY_NODE')
  @DocsEditable
  static const int ENTITY_NODE = 6;

  @DomName('Node.ENTITY_REFERENCE_NODE')
  @DocsEditable
  static const int ENTITY_REFERENCE_NODE = 5;

  @DomName('Node.NOTATION_NODE')
  @DocsEditable
  static const int NOTATION_NODE = 12;

  @DomName('Node.PROCESSING_INSTRUCTION_NODE')
  @DocsEditable
  static const int PROCESSING_INSTRUCTION_NODE = 7;

  @DomName('Node.TEXT_NODE')
  @DocsEditable
  static const int TEXT_NODE = 3;

  @DomName('Node.childNodes')
  @DocsEditable
  List<Node> get $dom_childNodes native "Node_childNodes_Getter";

  @DomName('Node.firstChild')
  @DocsEditable
  Node get $dom_firstChild native "Node_firstChild_Getter";

  @DomName('Node.lastChild')
  @DocsEditable
  Node get $dom_lastChild native "Node_lastChild_Getter";

  @DomName('Node.localName')
  @DocsEditable
  String get localName native "Node_localName_Getter";

  @DomName('Node.namespaceURI')
  @DocsEditable
  String get $dom_namespaceUri native "Node_namespaceURI_Getter";

  @DomName('Node.nextSibling')
  @DocsEditable
  Node get nextNode native "Node_nextSibling_Getter";

  @DomName('Node.nodeType')
  @DocsEditable
  int get nodeType native "Node_nodeType_Getter";

  @DomName('Node.nodeValue')
  @DocsEditable
  String get nodeValue native "Node_nodeValue_Getter";

  @DomName('Node.ownerDocument')
  @DocsEditable
  Document get document native "Node_ownerDocument_Getter";

  @DomName('Node.parentElement')
  @DocsEditable
  Element get parent native "Node_parentElement_Getter";

  @DomName('Node.parentNode')
  @DocsEditable
  Node get parentNode native "Node_parentNode_Getter";

  @DomName('Node.previousSibling')
  @DocsEditable
  Node get previousNode native "Node_previousSibling_Getter";

  @DomName('Node.textContent')
  @DocsEditable
  String get text native "Node_textContent_Getter";

  @DomName('Node.textContent')
  @DocsEditable
  void set text(String value) native "Node_textContent_Setter";

  @DomName('Node.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "Node_addEventListener_Callback";

  /**
   * Adds a node to the end of the child [nodes] list of this node.
   *
   * If the node already exists in this document, it will be removed from its
   * current parent node, then added to this node.
   *
   * This method is more efficient than `nodes.add`, and is the preferred
   * way of appending a child node.
   */
  @DomName('Node.appendChild')
  @DocsEditable
  Node append(Node newChild) native "Node_appendChild_Callback";

  @DomName('Node.cloneNode')
  @DocsEditable
  Node clone(bool deep) native "Node_cloneNode_Callback";

  @DomName('Node.contains')
  @DocsEditable
  bool contains(Node other) native "Node_contains_Callback";

  @DomName('Node.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event event) native "Node_dispatchEvent_Callback";

  @DomName('Node.hasChildNodes')
  @DocsEditable
  bool hasChildNodes() native "Node_hasChildNodes_Callback";

  @DomName('Node.insertBefore')
  @DocsEditable
  Node insertBefore(Node newChild, Node refChild) native "Node_insertBefore_Callback";

  @DomName('Node.removeChild')
  @DocsEditable
  Node $dom_removeChild(Node oldChild) native "Node_removeChild_Callback";

  @DomName('Node.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "Node_removeEventListener_Callback";

  @DomName('Node.replaceChild')
  @DocsEditable
  Node $dom_replaceChild(Node newChild, Node oldChild) native "Node_replaceChild_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('NodeFilter')
class NodeFilter extends NativeFieldWrapperClass1 {
  NodeFilter.internal();

  @DomName('NodeFilter.FILTER_ACCEPT')
  @DocsEditable
  static const int FILTER_ACCEPT = 1;

  @DomName('NodeFilter.FILTER_REJECT')
  @DocsEditable
  static const int FILTER_REJECT = 2;

  @DomName('NodeFilter.FILTER_SKIP')
  @DocsEditable
  static const int FILTER_SKIP = 3;

  @DomName('NodeFilter.SHOW_ALL')
  @DocsEditable
  static const int SHOW_ALL = 0xFFFFFFFF;

  @DomName('NodeFilter.SHOW_ATTRIBUTE')
  @DocsEditable
  static const int SHOW_ATTRIBUTE = 0x00000002;

  @DomName('NodeFilter.SHOW_CDATA_SECTION')
  @DocsEditable
  static const int SHOW_CDATA_SECTION = 0x00000008;

  @DomName('NodeFilter.SHOW_COMMENT')
  @DocsEditable
  static const int SHOW_COMMENT = 0x00000080;

  @DomName('NodeFilter.SHOW_DOCUMENT')
  @DocsEditable
  static const int SHOW_DOCUMENT = 0x00000100;

  @DomName('NodeFilter.SHOW_DOCUMENT_FRAGMENT')
  @DocsEditable
  static const int SHOW_DOCUMENT_FRAGMENT = 0x00000400;

  @DomName('NodeFilter.SHOW_DOCUMENT_TYPE')
  @DocsEditable
  static const int SHOW_DOCUMENT_TYPE = 0x00000200;

  @DomName('NodeFilter.SHOW_ELEMENT')
  @DocsEditable
  static const int SHOW_ELEMENT = 0x00000001;

  @DomName('NodeFilter.SHOW_ENTITY')
  @DocsEditable
  static const int SHOW_ENTITY = 0x00000020;

  @DomName('NodeFilter.SHOW_ENTITY_REFERENCE')
  @DocsEditable
  static const int SHOW_ENTITY_REFERENCE = 0x00000010;

  @DomName('NodeFilter.SHOW_NOTATION')
  @DocsEditable
  static const int SHOW_NOTATION = 0x00000800;

  @DomName('NodeFilter.SHOW_PROCESSING_INSTRUCTION')
  @DocsEditable
  static const int SHOW_PROCESSING_INSTRUCTION = 0x00000040;

  @DomName('NodeFilter.SHOW_TEXT')
  @DocsEditable
  static const int SHOW_TEXT = 0x00000004;

}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('NodeIterator')
class NodeIterator extends NativeFieldWrapperClass1 {
  factory NodeIterator(Node root, int whatToShow) {
    return document.$dom_createNodeIterator(root, whatToShow, null, false);
  }
  NodeIterator.internal();

  @DomName('NodeIterator.pointerBeforeReferenceNode')
  @DocsEditable
  bool get pointerBeforeReferenceNode native "NodeIterator_pointerBeforeReferenceNode_Getter";

  @DomName('NodeIterator.referenceNode')
  @DocsEditable
  Node get referenceNode native "NodeIterator_referenceNode_Getter";

  @DomName('NodeIterator.root')
  @DocsEditable
  Node get root native "NodeIterator_root_Getter";

  @DomName('NodeIterator.whatToShow')
  @DocsEditable
  int get whatToShow native "NodeIterator_whatToShow_Getter";

  @DomName('NodeIterator.detach')
  @DocsEditable
  void detach() native "NodeIterator_detach_Callback";

  @DomName('NodeIterator.nextNode')
  @DocsEditable
  Node nextNode() native "NodeIterator_nextNode_Callback";

  @DomName('NodeIterator.previousNode')
  @DocsEditable
  Node previousNode() native "NodeIterator_previousNode_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('NodeList')
class NodeList extends NativeFieldWrapperClass1 with ListMixin<Node>, ImmutableListMixin<Node> implements List<Node> {
  NodeList.internal();

  @DomName('NodeList.length')
  @DocsEditable
  int get length native "NodeList_length_Getter";

  Node operator[](int index) {
    if (index < 0 || index >= length)
      throw new RangeError.range(index, 0, length);
    return _nativeIndexedGetter(index);
  }
  Node _nativeIndexedGetter(int index) native "NodeList_item_Callback";

  void operator[]=(int index, Node value) {
    throw new UnsupportedError("Cannot assign element of immutable List.");
  }
  // -- start List<Node> mixins.
  // Node is the element type.


  void set length(int value) {
    throw new UnsupportedError("Cannot resize immutable List.");
  }

  Node get first {
    if (this.length > 0) {
      return this[0];
    }
    throw new StateError("No elements");
  }

  Node get last {
    int len = this.length;
    if (len > 0) {
      return this[len - 1];
    }
    throw new StateError("No elements");
  }

  Node get single {
    int len = this.length;
    if (len == 1) {
      return this[0];
    }
    if (len == 0) throw new StateError("No elements");
    throw new StateError("More than one element");
  }

  Node elementAt(int index) => this[index];
  // -- end List<Node> mixins.

  @DomName('NodeList.item')
  @DocsEditable
  Node _item(int index) native "NodeList_item_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('Notation')
class Notation extends Node {
  Notation.internal() : super.internal();

  @DomName('Notation.publicId')
  @DocsEditable
  String get publicId native "Notation_publicId_Getter";

  @DomName('Notation.systemId')
  @DocsEditable
  String get systemId native "Notation_systemId_Getter";

}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('Notification')
class Notification extends EventTarget {

  factory Notification(String title, {String titleDir: null, String body: null, 
      String bodyDir: null, String tag: null, String iconUrl: null}) {

    var parsedOptions = {};
    if (titleDir != null) parsedOptions['titleDir'] = titleDir;
    if (body != null) parsedOptions['body'] = body;
    if (bodyDir != null) parsedOptions['bodyDir'] = bodyDir;
    if (tag != null) parsedOptions['tag'] = tag;
    if (iconUrl != null) parsedOptions['iconUrl'] = iconUrl;

    return Notification._factoryNotification(title, parsedOptions);
  }
  Notification.internal() : super.internal();

  @DomName('Notification.clickEvent')
  @DocsEditable
  static const EventStreamProvider<Event> clickEvent = const EventStreamProvider<Event>('click');

  @DomName('Notification.closeEvent')
  @DocsEditable
  static const EventStreamProvider<Event> closeEvent = const EventStreamProvider<Event>('close');

  @DomName('Notification.displayEvent')
  @DocsEditable
  static const EventStreamProvider<Event> displayEvent = const EventStreamProvider<Event>('display');

  @DomName('Notification.errorEvent')
  @DocsEditable
  static const EventStreamProvider<Event> errorEvent = const EventStreamProvider<Event>('error');

  @DomName('Notification.showEvent')
  @DocsEditable
  static const EventStreamProvider<Event> showEvent = const EventStreamProvider<Event>('show');

  @DomName('Notification.Notification')
  @DocsEditable
  static Notification _factoryNotification(String title, [Map options]) {
    return Notification._create_1(title, options);
  }

  @DocsEditable
  static Notification _create_1(title, options) native "Notification__create_1constructorCallback";

  @DomName('Notification.dir')
  @DocsEditable
  String get dir native "Notification_dir_Getter";

  @DomName('Notification.dir')
  @DocsEditable
  void set dir(String value) native "Notification_dir_Setter";

  @DomName('Notification.permission')
  @DocsEditable
  String get permission native "Notification_permission_Getter";

  @DomName('Notification.replaceId')
  @DocsEditable
  String get replaceId native "Notification_replaceId_Getter";

  @DomName('Notification.replaceId')
  @DocsEditable
  void set replaceId(String value) native "Notification_replaceId_Setter";

  @DomName('Notification.tag')
  @DocsEditable
  String get tag native "Notification_tag_Getter";

  @DomName('Notification.tag')
  @DocsEditable
  void set tag(String value) native "Notification_tag_Setter";

  @DomName('Notification.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "Notification_addEventListener_Callback";

  @DomName('Notification.cancel')
  @DocsEditable
  void cancel() native "Notification_cancel_Callback";

  @DomName('Notification.close')
  @DocsEditable
  void close() native "Notification_close_Callback";

  @DomName('Notification.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event evt) native "Notification_dispatchEvent_Callback";

  @DomName('Notification.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "Notification_removeEventListener_Callback";

  @DomName('Notification.requestPermission')
  @DocsEditable
  static void _requestPermission([_NotificationPermissionCallback callback]) native "Notification_requestPermission_Callback";

  static Future<String> requestPermission() {
    var completer = new Completer<String>();
    _requestPermission(
        (value) { completer.complete(value); });
    return completer.future;
  }

  @DomName('Notification.show')
  @DocsEditable
  void show() native "Notification_show_Callback";

  @DomName('Notification.onclick')
  @DocsEditable
  Stream<Event> get onClick => clickEvent.forTarget(this);

  @DomName('Notification.onclose')
  @DocsEditable
  Stream<Event> get onClose => closeEvent.forTarget(this);

  @DomName('Notification.ondisplay')
  @DocsEditable
  Stream<Event> get onDisplay => displayEvent.forTarget(this);

  @DomName('Notification.onerror')
  @DocsEditable
  Stream<Event> get onError => errorEvent.forTarget(this);

  @DomName('Notification.onshow')
  @DocsEditable
  Stream<Event> get onShow => showEvent.forTarget(this);

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('NotificationCenter')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.SAFARI)
@Experimental
class NotificationCenter extends NativeFieldWrapperClass1 {
  NotificationCenter.internal();

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('NotificationCenter.checkPermission')
  @DocsEditable
  int checkPermission() native "NotificationCenter_checkPermission_Callback";

  @DomName('NotificationCenter.createHTMLNotification')
  @DocsEditable
  Notification createHtmlNotification(String url) native "NotificationCenter_createHTMLNotification_Callback";

  @DomName('NotificationCenter.createNotification')
  @DocsEditable
  Notification createNotification(String iconUrl, String title, String body) native "NotificationCenter_createNotification_Callback";

  @DomName('NotificationCenter.requestPermission')
  @DocsEditable
  void _requestPermission([VoidCallback callback]) native "NotificationCenter_requestPermission_Callback";

  Future requestPermission() {
    var completer = new Completer();
    _requestPermission(
        () { completer.complete(); });
    return completer.future;
  }

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


typedef void _NotificationPermissionCallback(String permission);
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLOListElement')
class OListElement extends _Element_Merged {
  OListElement.internal() : super.internal();

  @DomName('HTMLOListElement.HTMLOListElement')
  @DocsEditable
  factory OListElement() => document.$dom_createElement("ol");

  @DomName('HTMLOListElement.reversed')
  @DocsEditable
  bool get reversed native "HTMLOListElement_reversed_Getter";

  @DomName('HTMLOListElement.reversed')
  @DocsEditable
  void set reversed(bool value) native "HTMLOListElement_reversed_Setter";

  @DomName('HTMLOListElement.start')
  @DocsEditable
  int get start native "HTMLOListElement_start_Getter";

  @DomName('HTMLOListElement.start')
  @DocsEditable
  void set start(int value) native "HTMLOListElement_start_Setter";

  @DomName('HTMLOListElement.type')
  @DocsEditable
  String get type native "HTMLOListElement_type_Getter";

  @DomName('HTMLOListElement.type')
  @DocsEditable
  void set type(String value) native "HTMLOListElement_type_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLObjectElement')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.IE)
@SupportedBrowser(SupportedBrowser.SAFARI)
class ObjectElement extends _Element_Merged {
  ObjectElement.internal() : super.internal();

  @DomName('HTMLObjectElement.HTMLObjectElement')
  @DocsEditable
  factory ObjectElement() => document.$dom_createElement("object");

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('HTMLObjectElement.code')
  @DocsEditable
  String get code native "HTMLObjectElement_code_Getter";

  @DomName('HTMLObjectElement.code')
  @DocsEditable
  void set code(String value) native "HTMLObjectElement_code_Setter";

  @DomName('HTMLObjectElement.data')
  @DocsEditable
  String get data native "HTMLObjectElement_data_Getter";

  @DomName('HTMLObjectElement.data')
  @DocsEditable
  void set data(String value) native "HTMLObjectElement_data_Setter";

  @DomName('HTMLObjectElement.form')
  @DocsEditable
  FormElement get form native "HTMLObjectElement_form_Getter";

  @DomName('HTMLObjectElement.height')
  @DocsEditable
  String get height native "HTMLObjectElement_height_Getter";

  @DomName('HTMLObjectElement.height')
  @DocsEditable
  void set height(String value) native "HTMLObjectElement_height_Setter";

  @DomName('HTMLObjectElement.name')
  @DocsEditable
  String get name native "HTMLObjectElement_name_Getter";

  @DomName('HTMLObjectElement.name')
  @DocsEditable
  void set name(String value) native "HTMLObjectElement_name_Setter";

  @DomName('HTMLObjectElement.type')
  @DocsEditable
  String get type native "HTMLObjectElement_type_Getter";

  @DomName('HTMLObjectElement.type')
  @DocsEditable
  void set type(String value) native "HTMLObjectElement_type_Setter";

  @DomName('HTMLObjectElement.useMap')
  @DocsEditable
  String get useMap native "HTMLObjectElement_useMap_Getter";

  @DomName('HTMLObjectElement.useMap')
  @DocsEditable
  void set useMap(String value) native "HTMLObjectElement_useMap_Setter";

  @DomName('HTMLObjectElement.validationMessage')
  @DocsEditable
  String get validationMessage native "HTMLObjectElement_validationMessage_Getter";

  @DomName('HTMLObjectElement.validity')
  @DocsEditable
  ValidityState get validity native "HTMLObjectElement_validity_Getter";

  @DomName('HTMLObjectElement.width')
  @DocsEditable
  String get width native "HTMLObjectElement_width_Getter";

  @DomName('HTMLObjectElement.width')
  @DocsEditable
  void set width(String value) native "HTMLObjectElement_width_Setter";

  @DomName('HTMLObjectElement.willValidate')
  @DocsEditable
  bool get willValidate native "HTMLObjectElement_willValidate_Getter";

  @DomName('HTMLObjectElement.checkValidity')
  @DocsEditable
  bool checkValidity() native "HTMLObjectElement_checkValidity_Callback";

  @DomName('HTMLObjectElement.setCustomValidity')
  @DocsEditable
  void setCustomValidity(String error) native "HTMLObjectElement_setCustomValidity_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLOptGroupElement')
class OptGroupElement extends _Element_Merged {
  OptGroupElement.internal() : super.internal();

  @DomName('HTMLOptGroupElement.HTMLOptGroupElement')
  @DocsEditable
  factory OptGroupElement() => document.$dom_createElement("optgroup");

  @DomName('HTMLOptGroupElement.disabled')
  @DocsEditable
  bool get disabled native "HTMLOptGroupElement_disabled_Getter";

  @DomName('HTMLOptGroupElement.disabled')
  @DocsEditable
  void set disabled(bool value) native "HTMLOptGroupElement_disabled_Setter";

  @DomName('HTMLOptGroupElement.label')
  @DocsEditable
  String get label native "HTMLOptGroupElement_label_Getter";

  @DomName('HTMLOptGroupElement.label')
  @DocsEditable
  void set label(String value) native "HTMLOptGroupElement_label_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLOptionElement')
class OptionElement extends _Element_Merged {
  OptionElement.internal() : super.internal();

  @DomName('HTMLOptionElement.HTMLOptionElement')
  @DocsEditable
  factory OptionElement([String data, String value, bool defaultSelected, bool selected]) {
    return OptionElement._create_1(data, value, defaultSelected, selected);
  }

  @DocsEditable
  static OptionElement _create_1(data, value, defaultSelected, selected) native "HTMLOptionElement__create_1constructorCallback";

  @DomName('HTMLOptionElement.defaultSelected')
  @DocsEditable
  bool get defaultSelected native "HTMLOptionElement_defaultSelected_Getter";

  @DomName('HTMLOptionElement.defaultSelected')
  @DocsEditable
  void set defaultSelected(bool value) native "HTMLOptionElement_defaultSelected_Setter";

  @DomName('HTMLOptionElement.disabled')
  @DocsEditable
  bool get disabled native "HTMLOptionElement_disabled_Getter";

  @DomName('HTMLOptionElement.disabled')
  @DocsEditable
  void set disabled(bool value) native "HTMLOptionElement_disabled_Setter";

  @DomName('HTMLOptionElement.form')
  @DocsEditable
  FormElement get form native "HTMLOptionElement_form_Getter";

  @DomName('HTMLOptionElement.index')
  @DocsEditable
  int get index native "HTMLOptionElement_index_Getter";

  @DomName('HTMLOptionElement.label')
  @DocsEditable
  String get label native "HTMLOptionElement_label_Getter";

  @DomName('HTMLOptionElement.label')
  @DocsEditable
  void set label(String value) native "HTMLOptionElement_label_Setter";

  @DomName('HTMLOptionElement.selected')
  @DocsEditable
  bool get selected native "HTMLOptionElement_selected_Getter";

  @DomName('HTMLOptionElement.selected')
  @DocsEditable
  void set selected(bool value) native "HTMLOptionElement_selected_Setter";

  @DomName('HTMLOptionElement.value')
  @DocsEditable
  String get value native "HTMLOptionElement_value_Getter";

  @DomName('HTMLOptionElement.value')
  @DocsEditable
  void set value(String value) native "HTMLOptionElement_value_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLOutputElement')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.FIREFOX)
@SupportedBrowser(SupportedBrowser.SAFARI)
class OutputElement extends _Element_Merged {
  OutputElement.internal() : super.internal();

  @DomName('HTMLOutputElement.HTMLOutputElement')
  @DocsEditable
  factory OutputElement() => document.$dom_createElement("output");

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('HTMLOutputElement.defaultValue')
  @DocsEditable
  String get defaultValue native "HTMLOutputElement_defaultValue_Getter";

  @DomName('HTMLOutputElement.defaultValue')
  @DocsEditable
  void set defaultValue(String value) native "HTMLOutputElement_defaultValue_Setter";

  @DomName('HTMLOutputElement.form')
  @DocsEditable
  FormElement get form native "HTMLOutputElement_form_Getter";

  @DomName('HTMLOutputElement.htmlFor')
  @DocsEditable
  DomSettableTokenList get htmlFor native "HTMLOutputElement_htmlFor_Getter";

  @DomName('HTMLOutputElement.labels')
  @DocsEditable
  List<Node> get labels native "HTMLOutputElement_labels_Getter";

  @DomName('HTMLOutputElement.name')
  @DocsEditable
  String get name native "HTMLOutputElement_name_Getter";

  @DomName('HTMLOutputElement.name')
  @DocsEditable
  void set name(String value) native "HTMLOutputElement_name_Setter";

  @DomName('HTMLOutputElement.type')
  @DocsEditable
  String get type native "HTMLOutputElement_type_Getter";

  @DomName('HTMLOutputElement.validationMessage')
  @DocsEditable
  String get validationMessage native "HTMLOutputElement_validationMessage_Getter";

  @DomName('HTMLOutputElement.validity')
  @DocsEditable
  ValidityState get validity native "HTMLOutputElement_validity_Getter";

  @DomName('HTMLOutputElement.value')
  @DocsEditable
  String get value native "HTMLOutputElement_value_Getter";

  @DomName('HTMLOutputElement.value')
  @DocsEditable
  void set value(String value) native "HTMLOutputElement_value_Setter";

  @DomName('HTMLOutputElement.willValidate')
  @DocsEditable
  bool get willValidate native "HTMLOutputElement_willValidate_Getter";

  @DomName('HTMLOutputElement.checkValidity')
  @DocsEditable
  bool checkValidity() native "HTMLOutputElement_checkValidity_Callback";

  @DomName('HTMLOutputElement.setCustomValidity')
  @DocsEditable
  void setCustomValidity(String error) native "HTMLOutputElement_setCustomValidity_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('OverflowEvent')
class OverflowEvent extends Event {
  OverflowEvent.internal() : super.internal();

  @DomName('OverflowEvent.BOTH')
  @DocsEditable
  static const int BOTH = 2;

  @DomName('OverflowEvent.HORIZONTAL')
  @DocsEditable
  static const int HORIZONTAL = 0;

  @DomName('OverflowEvent.VERTICAL')
  @DocsEditable
  static const int VERTICAL = 1;

  @DomName('OverflowEvent.horizontalOverflow')
  @DocsEditable
  bool get horizontalOverflow native "OverflowEvent_horizontalOverflow_Getter";

  @DomName('OverflowEvent.orient')
  @DocsEditable
  int get orient native "OverflowEvent_orient_Getter";

  @DomName('OverflowEvent.verticalOverflow')
  @DocsEditable
  bool get verticalOverflow native "OverflowEvent_verticalOverflow_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('PageTransitionEvent')
class PageTransitionEvent extends Event {
  PageTransitionEvent.internal() : super.internal();

  @DomName('PageTransitionEvent.persisted')
  @DocsEditable
  bool get persisted native "PageTransitionEvent_persisted_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLParagraphElement')
class ParagraphElement extends _Element_Merged {
  ParagraphElement.internal() : super.internal();

  @DomName('HTMLParagraphElement.HTMLParagraphElement')
  @DocsEditable
  factory ParagraphElement() => document.$dom_createElement("p");

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLParamElement')
class ParamElement extends _Element_Merged {
  ParamElement.internal() : super.internal();

  @DomName('HTMLParamElement.HTMLParamElement')
  @DocsEditable
  factory ParamElement() => document.$dom_createElement("param");

  @DomName('HTMLParamElement.name')
  @DocsEditable
  String get name native "HTMLParamElement_name_Getter";

  @DomName('HTMLParamElement.name')
  @DocsEditable
  void set name(String value) native "HTMLParamElement_name_Setter";

  @DomName('HTMLParamElement.value')
  @DocsEditable
  String get value native "HTMLParamElement_value_Getter";

  @DomName('HTMLParamElement.value')
  @DocsEditable
  void set value(String value) native "HTMLParamElement_value_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('Path')
class Path extends NativeFieldWrapperClass1 {
  Path.internal();

  @DomName('Path.DOMPath')
  @DocsEditable
  factory Path([path_OR_text]) {
    if (!?path_OR_text) {
      return Path._create_1();
    }
    if ((path_OR_text is Path || path_OR_text == null)) {
      return Path._create_2(path_OR_text);
    }
    if ((path_OR_text is String || path_OR_text == null)) {
      return Path._create_3(path_OR_text);
    }
    throw new ArgumentError("Incorrect number or type of arguments");
  }

  @DocsEditable
  static Path _create_1() native "DOMPath__create_1constructorCallback";

  @DocsEditable
  static Path _create_2(path_OR_text) native "DOMPath__create_2constructorCallback";

  @DocsEditable
  static Path _create_3(path_OR_text) native "DOMPath__create_3constructorCallback";

  @DomName('Path.arc')
  @DocsEditable
  void arc(num x, num y, num radius, num startAngle, num endAngle, bool anticlockwise) native "DOMPath_arc_Callback";

  @DomName('Path.arcTo')
  @DocsEditable
  void arcTo(num x1, num y1, num x2, num y2, num radius) native "DOMPath_arcTo_Callback";

  @DomName('Path.bezierCurveTo')
  @DocsEditable
  void bezierCurveTo(num cp1x, num cp1y, num cp2x, num cp2y, num x, num y) native "DOMPath_bezierCurveTo_Callback";

  @DomName('Path.closePath')
  @DocsEditable
  void closePath() native "DOMPath_closePath_Callback";

  @DomName('Path.lineTo')
  @DocsEditable
  void lineTo(num x, num y) native "DOMPath_lineTo_Callback";

  @DomName('Path.moveTo')
  @DocsEditable
  void moveTo(num x, num y) native "DOMPath_moveTo_Callback";

  @DomName('Path.quadraticCurveTo')
  @DocsEditable
  void quadraticCurveTo(num cpx, num cpy, num x, num y) native "DOMPath_quadraticCurveTo_Callback";

  @DomName('Path.rect')
  @DocsEditable
  void rect(num x, num y, num width, num height) native "DOMPath_rect_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('Performance')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.FIREFOX)
@SupportedBrowser(SupportedBrowser.IE)
class Performance extends EventTarget {
  Performance.internal() : super.internal();

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('Performance.memory')
  @DocsEditable
  MemoryInfo get memory native "Performance_memory_Getter";

  @DomName('Performance.navigation')
  @DocsEditable
  PerformanceNavigation get navigation native "Performance_navigation_Getter";

  @DomName('Performance.timing')
  @DocsEditable
  PerformanceTiming get timing native "Performance_timing_Getter";

  @DomName('Performance.now')
  @DocsEditable
  num now() native "Performance_now_Callback";

  @DomName('Performance.webkitClearMarks')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void clearMarks(String markName) native "Performance_webkitClearMarks_Callback";

  @DomName('Performance.webkitClearMeasures')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void clearMeasures(String measureName) native "Performance_webkitClearMeasures_Callback";

  @DomName('Performance.webkitClearResourceTimings')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void clearResourceTimings() native "Performance_webkitClearResourceTimings_Callback";

  @DomName('Performance.webkitGetEntries')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  List<PerformanceEntry> getEntries() native "Performance_webkitGetEntries_Callback";

  @DomName('Performance.webkitGetEntriesByName')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  List<PerformanceEntry> getEntriesByName(String name, String entryType) native "Performance_webkitGetEntriesByName_Callback";

  @DomName('Performance.webkitGetEntriesByType')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  List<PerformanceEntry> getEntriesByType(String entryType) native "Performance_webkitGetEntriesByType_Callback";

  @DomName('Performance.webkitMark')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void mark(String markName) native "Performance_webkitMark_Callback";

  @DomName('Performance.webkitMeasure')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void measure(String measureName, String startMark, String endMark) native "Performance_webkitMeasure_Callback";

  @DomName('Performance.webkitSetResourceTimingBufferSize')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void setResourceTimingBufferSize(int maxSize) native "Performance_webkitSetResourceTimingBufferSize_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('PerformanceEntry')
class PerformanceEntry extends NativeFieldWrapperClass1 {
  PerformanceEntry.internal();

  @DomName('PerformanceEntry.duration')
  @DocsEditable
  num get duration native "PerformanceEntry_duration_Getter";

  @DomName('PerformanceEntry.entryType')
  @DocsEditable
  String get entryType native "PerformanceEntry_entryType_Getter";

  @DomName('PerformanceEntry.name')
  @DocsEditable
  String get name native "PerformanceEntry_name_Getter";

  @DomName('PerformanceEntry.startTime')
  @DocsEditable
  num get startTime native "PerformanceEntry_startTime_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('PerformanceEntryList')
class PerformanceEntryList extends NativeFieldWrapperClass1 {
  PerformanceEntryList.internal();

  @DomName('PerformanceEntryList.length')
  @DocsEditable
  int get length native "PerformanceEntryList_length_Getter";

  @DomName('PerformanceEntryList.item')
  @DocsEditable
  PerformanceEntry item(int index) native "PerformanceEntryList_item_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('PerformanceMark')
class PerformanceMark extends PerformanceEntry {
  PerformanceMark.internal() : super.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('PerformanceMeasure')
class PerformanceMeasure extends PerformanceEntry {
  PerformanceMeasure.internal() : super.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('PerformanceNavigation')
class PerformanceNavigation extends NativeFieldWrapperClass1 {
  PerformanceNavigation.internal();

  @DomName('PerformanceNavigation.TYPE_BACK_FORWARD')
  @DocsEditable
  static const int TYPE_BACK_FORWARD = 2;

  @DomName('PerformanceNavigation.TYPE_NAVIGATE')
  @DocsEditable
  static const int TYPE_NAVIGATE = 0;

  @DomName('PerformanceNavigation.TYPE_RELOAD')
  @DocsEditable
  static const int TYPE_RELOAD = 1;

  @DomName('PerformanceNavigation.TYPE_RESERVED')
  @DocsEditable
  static const int TYPE_RESERVED = 255;

  @DomName('PerformanceNavigation.redirectCount')
  @DocsEditable
  int get redirectCount native "PerformanceNavigation_redirectCount_Getter";

  @DomName('PerformanceNavigation.type')
  @DocsEditable
  int get type native "PerformanceNavigation_type_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('PerformanceResourceTiming')
class PerformanceResourceTiming extends PerformanceEntry {
  PerformanceResourceTiming.internal() : super.internal();

  @DomName('PerformanceResourceTiming.connectEnd')
  @DocsEditable
  num get connectEnd native "PerformanceResourceTiming_connectEnd_Getter";

  @DomName('PerformanceResourceTiming.connectStart')
  @DocsEditable
  num get connectStart native "PerformanceResourceTiming_connectStart_Getter";

  @DomName('PerformanceResourceTiming.domainLookupEnd')
  @DocsEditable
  num get domainLookupEnd native "PerformanceResourceTiming_domainLookupEnd_Getter";

  @DomName('PerformanceResourceTiming.domainLookupStart')
  @DocsEditable
  num get domainLookupStart native "PerformanceResourceTiming_domainLookupStart_Getter";

  @DomName('PerformanceResourceTiming.fetchStart')
  @DocsEditable
  num get fetchStart native "PerformanceResourceTiming_fetchStart_Getter";

  @DomName('PerformanceResourceTiming.initiatorType')
  @DocsEditable
  String get initiatorType native "PerformanceResourceTiming_initiatorType_Getter";

  @DomName('PerformanceResourceTiming.redirectEnd')
  @DocsEditable
  num get redirectEnd native "PerformanceResourceTiming_redirectEnd_Getter";

  @DomName('PerformanceResourceTiming.redirectStart')
  @DocsEditable
  num get redirectStart native "PerformanceResourceTiming_redirectStart_Getter";

  @DomName('PerformanceResourceTiming.requestStart')
  @DocsEditable
  num get requestStart native "PerformanceResourceTiming_requestStart_Getter";

  @DomName('PerformanceResourceTiming.responseEnd')
  @DocsEditable
  num get responseEnd native "PerformanceResourceTiming_responseEnd_Getter";

  @DomName('PerformanceResourceTiming.responseStart')
  @DocsEditable
  num get responseStart native "PerformanceResourceTiming_responseStart_Getter";

  @DomName('PerformanceResourceTiming.secureConnectionStart')
  @DocsEditable
  num get secureConnectionStart native "PerformanceResourceTiming_secureConnectionStart_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('PerformanceTiming')
class PerformanceTiming extends NativeFieldWrapperClass1 {
  PerformanceTiming.internal();

  @DomName('PerformanceTiming.connectEnd')
  @DocsEditable
  int get connectEnd native "PerformanceTiming_connectEnd_Getter";

  @DomName('PerformanceTiming.connectStart')
  @DocsEditable
  int get connectStart native "PerformanceTiming_connectStart_Getter";

  @DomName('PerformanceTiming.domComplete')
  @DocsEditable
  int get domComplete native "PerformanceTiming_domComplete_Getter";

  @DomName('PerformanceTiming.domContentLoadedEventEnd')
  @DocsEditable
  int get domContentLoadedEventEnd native "PerformanceTiming_domContentLoadedEventEnd_Getter";

  @DomName('PerformanceTiming.domContentLoadedEventStart')
  @DocsEditable
  int get domContentLoadedEventStart native "PerformanceTiming_domContentLoadedEventStart_Getter";

  @DomName('PerformanceTiming.domInteractive')
  @DocsEditable
  int get domInteractive native "PerformanceTiming_domInteractive_Getter";

  @DomName('PerformanceTiming.domLoading')
  @DocsEditable
  int get domLoading native "PerformanceTiming_domLoading_Getter";

  @DomName('PerformanceTiming.domainLookupEnd')
  @DocsEditable
  int get domainLookupEnd native "PerformanceTiming_domainLookupEnd_Getter";

  @DomName('PerformanceTiming.domainLookupStart')
  @DocsEditable
  int get domainLookupStart native "PerformanceTiming_domainLookupStart_Getter";

  @DomName('PerformanceTiming.fetchStart')
  @DocsEditable
  int get fetchStart native "PerformanceTiming_fetchStart_Getter";

  @DomName('PerformanceTiming.loadEventEnd')
  @DocsEditable
  int get loadEventEnd native "PerformanceTiming_loadEventEnd_Getter";

  @DomName('PerformanceTiming.loadEventStart')
  @DocsEditable
  int get loadEventStart native "PerformanceTiming_loadEventStart_Getter";

  @DomName('PerformanceTiming.navigationStart')
  @DocsEditable
  int get navigationStart native "PerformanceTiming_navigationStart_Getter";

  @DomName('PerformanceTiming.redirectEnd')
  @DocsEditable
  int get redirectEnd native "PerformanceTiming_redirectEnd_Getter";

  @DomName('PerformanceTiming.redirectStart')
  @DocsEditable
  int get redirectStart native "PerformanceTiming_redirectStart_Getter";

  @DomName('PerformanceTiming.requestStart')
  @DocsEditable
  int get requestStart native "PerformanceTiming_requestStart_Getter";

  @DomName('PerformanceTiming.responseEnd')
  @DocsEditable
  int get responseEnd native "PerformanceTiming_responseEnd_Getter";

  @DomName('PerformanceTiming.responseStart')
  @DocsEditable
  int get responseStart native "PerformanceTiming_responseStart_Getter";

  @DomName('PerformanceTiming.secureConnectionStart')
  @DocsEditable
  int get secureConnectionStart native "PerformanceTiming_secureConnectionStart_Getter";

  @DomName('PerformanceTiming.unloadEventEnd')
  @DocsEditable
  int get unloadEventEnd native "PerformanceTiming_unloadEventEnd_Getter";

  @DomName('PerformanceTiming.unloadEventStart')
  @DocsEditable
  int get unloadEventStart native "PerformanceTiming_unloadEventStart_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('Plugin')
class Plugin extends NativeFieldWrapperClass1 {
  Plugin.internal();

  @DomName('Plugin.description')
  @DocsEditable
  String get description native "DOMPlugin_description_Getter";

  @DomName('Plugin.filename')
  @DocsEditable
  String get filename native "DOMPlugin_filename_Getter";

  @DomName('Plugin.length')
  @DocsEditable
  int get length native "DOMPlugin_length_Getter";

  @DomName('Plugin.name')
  @DocsEditable
  String get name native "DOMPlugin_name_Getter";

  @DomName('Plugin.item')
  @DocsEditable
  MimeType item(int index) native "DOMPlugin_item_Callback";

  @DomName('Plugin.namedItem')
  @DocsEditable
  MimeType namedItem(String name) native "DOMPlugin_namedItem_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('PluginArray')
class PluginArray extends NativeFieldWrapperClass1 with ListMixin<Plugin>, ImmutableListMixin<Plugin> implements List<Plugin> {
  PluginArray.internal();

  @DomName('PluginArray.length')
  @DocsEditable
  int get length native "DOMPluginArray_length_Getter";

  Plugin operator[](int index) {
    if (index < 0 || index >= length)
      throw new RangeError.range(index, 0, length);
    return _nativeIndexedGetter(index);
  }
  Plugin _nativeIndexedGetter(int index) native "DOMPluginArray_item_Callback";

  void operator[]=(int index, Plugin value) {
    throw new UnsupportedError("Cannot assign element of immutable List.");
  }
  // -- start List<Plugin> mixins.
  // Plugin is the element type.


  void set length(int value) {
    throw new UnsupportedError("Cannot resize immutable List.");
  }

  Plugin get first {
    if (this.length > 0) {
      return this[0];
    }
    throw new StateError("No elements");
  }

  Plugin get last {
    int len = this.length;
    if (len > 0) {
      return this[len - 1];
    }
    throw new StateError("No elements");
  }

  Plugin get single {
    int len = this.length;
    if (len == 1) {
      return this[0];
    }
    if (len == 0) throw new StateError("No elements");
    throw new StateError("More than one element");
  }

  Plugin elementAt(int index) => this[index];
  // -- end List<Plugin> mixins.

  @DomName('PluginArray.item')
  @DocsEditable
  Plugin item(int index) native "DOMPluginArray_item_Callback";

  @DomName('PluginArray.namedItem')
  @DocsEditable
  Plugin namedItem(String name) native "DOMPluginArray_namedItem_Callback";

  @DomName('PluginArray.refresh')
  @DocsEditable
  void refresh(bool reload) native "DOMPluginArray_refresh_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('PopStateEvent')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.FIREFOX)
@SupportedBrowser(SupportedBrowser.IE, '10')
@SupportedBrowser(SupportedBrowser.SAFARI)
class PopStateEvent extends Event {
  PopStateEvent.internal() : super.internal();

  @DomName('PopStateEvent.state')
  @DocsEditable
  Object get state native "PopStateEvent_state_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


typedef void _PositionCallback(Geoposition position);
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('PositionError')
class PositionError extends NativeFieldWrapperClass1 {
  PositionError.internal();

  @DomName('PositionError.PERMISSION_DENIED')
  @DocsEditable
  static const int PERMISSION_DENIED = 1;

  @DomName('PositionError.POSITION_UNAVAILABLE')
  @DocsEditable
  static const int POSITION_UNAVAILABLE = 2;

  @DomName('PositionError.TIMEOUT')
  @DocsEditable
  static const int TIMEOUT = 3;

  @DomName('PositionError.code')
  @DocsEditable
  int get code native "PositionError_code_Getter";

  @DomName('PositionError.message')
  @DocsEditable
  String get message native "PositionError_message_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


typedef void _PositionErrorCallback(PositionError error);
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLPreElement')
class PreElement extends _Element_Merged {
  PreElement.internal() : super.internal();

  @DomName('HTMLPreElement.HTMLPreElement')
  @DocsEditable
  factory PreElement() => document.$dom_createElement("pre");

  @DomName('HTMLPreElement.wrap')
  @DocsEditable
  bool get wrap native "HTMLPreElement_wrap_Getter";

  @DomName('HTMLPreElement.wrap')
  @DocsEditable
  void set wrap(bool value) native "HTMLPreElement_wrap_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('ProcessingInstruction')
class ProcessingInstruction extends Node {
  ProcessingInstruction.internal() : super.internal();

  @DomName('ProcessingInstruction.data')
  @DocsEditable
  String get data native "ProcessingInstruction_data_Getter";

  @DomName('ProcessingInstruction.data')
  @DocsEditable
  void set data(String value) native "ProcessingInstruction_data_Setter";

  @DomName('ProcessingInstruction.sheet')
  @DocsEditable
  StyleSheet get sheet native "ProcessingInstruction_sheet_Getter";

  @DomName('ProcessingInstruction.target')
  @DocsEditable
  String get target native "ProcessingInstruction_target_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLProgressElement')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.FIREFOX)
@SupportedBrowser(SupportedBrowser.IE, '10')
@SupportedBrowser(SupportedBrowser.SAFARI)
class ProgressElement extends _Element_Merged {
  ProgressElement.internal() : super.internal();

  @DomName('HTMLProgressElement.HTMLProgressElement')
  @DocsEditable
  factory ProgressElement() => document.$dom_createElement("progress");

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('HTMLProgressElement.labels')
  @DocsEditable
  List<Node> get labels native "HTMLProgressElement_labels_Getter";

  @DomName('HTMLProgressElement.max')
  @DocsEditable
  num get max native "HTMLProgressElement_max_Getter";

  @DomName('HTMLProgressElement.max')
  @DocsEditable
  void set max(num value) native "HTMLProgressElement_max_Setter";

  @DomName('HTMLProgressElement.position')
  @DocsEditable
  num get position native "HTMLProgressElement_position_Getter";

  @DomName('HTMLProgressElement.value')
  @DocsEditable
  num get value native "HTMLProgressElement_value_Getter";

  @DomName('HTMLProgressElement.value')
  @DocsEditable
  void set value(num value) native "HTMLProgressElement_value_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('ProgressEvent')
class ProgressEvent extends Event {
  ProgressEvent.internal() : super.internal();

  @DomName('ProgressEvent.lengthComputable')
  @DocsEditable
  bool get lengthComputable native "ProgressEvent_lengthComputable_Getter";

  @DomName('ProgressEvent.loaded')
  @DocsEditable
  int get loaded native "ProgressEvent_loaded_Getter";

  @DomName('ProgressEvent.total')
  @DocsEditable
  int get total native "ProgressEvent_total_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLQuoteElement')
class QuoteElement extends _Element_Merged {
  QuoteElement.internal() : super.internal();

  @DomName('HTMLQuoteElement.cite')
  @DocsEditable
  String get cite native "HTMLQuoteElement_cite_Getter";

  @DomName('HTMLQuoteElement.cite')
  @DocsEditable
  void set cite(String value) native "HTMLQuoteElement_cite_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


typedef void _RtcErrorCallback(String errorInformation);
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


typedef void _RtcSessionDescriptionCallback(RtcSessionDescription sdp);
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


typedef void RtcStatsCallback(RtcStatsResponse response);
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DomName('Range')
class Range extends NativeFieldWrapperClass1 {
  factory Range() => document.$dom_createRange();

  Range.internal();

  @DomName('Range.END_TO_END')
  @DocsEditable
  static const int END_TO_END = 2;

  @DomName('Range.END_TO_START')
  @DocsEditable
  static const int END_TO_START = 3;

  @DomName('Range.NODE_AFTER')
  @DocsEditable
  static const int NODE_AFTER = 1;

  @DomName('Range.NODE_BEFORE')
  @DocsEditable
  static const int NODE_BEFORE = 0;

  @DomName('Range.NODE_BEFORE_AND_AFTER')
  @DocsEditable
  static const int NODE_BEFORE_AND_AFTER = 2;

  @DomName('Range.NODE_INSIDE')
  @DocsEditable
  static const int NODE_INSIDE = 3;

  @DomName('Range.START_TO_END')
  @DocsEditable
  static const int START_TO_END = 1;

  @DomName('Range.START_TO_START')
  @DocsEditable
  static const int START_TO_START = 0;

  @DomName('Range.collapsed')
  @DocsEditable
  bool get collapsed native "Range_collapsed_Getter";

  @DomName('Range.commonAncestorContainer')
  @DocsEditable
  Node get commonAncestorContainer native "Range_commonAncestorContainer_Getter";

  @DomName('Range.endContainer')
  @DocsEditable
  Node get endContainer native "Range_endContainer_Getter";

  @DomName('Range.endOffset')
  @DocsEditable
  int get endOffset native "Range_endOffset_Getter";

  @DomName('Range.startContainer')
  @DocsEditable
  Node get startContainer native "Range_startContainer_Getter";

  @DomName('Range.startOffset')
  @DocsEditable
  int get startOffset native "Range_startOffset_Getter";

  @DomName('Range.cloneContents')
  @DocsEditable
  DocumentFragment cloneContents() native "Range_cloneContents_Callback";

  @DomName('Range.cloneRange')
  @DocsEditable
  Range cloneRange() native "Range_cloneRange_Callback";

  @DomName('Range.collapse')
  @DocsEditable
  void collapse(bool toStart) native "Range_collapse_Callback";

  @DomName('Range.compareNode')
  @DocsEditable
  int compareNode(Node refNode) native "Range_compareNode_Callback";

  @DomName('Range.comparePoint')
  @DocsEditable
  int comparePoint(Node refNode, int offset) native "Range_comparePoint_Callback";

  @DomName('Range.createContextualFragment')
  @DocsEditable
  DocumentFragment createContextualFragment(String html) native "Range_createContextualFragment_Callback";

  @DomName('Range.deleteContents')
  @DocsEditable
  void deleteContents() native "Range_deleteContents_Callback";

  @DomName('Range.detach')
  @DocsEditable
  void detach() native "Range_detach_Callback";

  @DomName('Range.expand')
  @DocsEditable
  void expand(String unit) native "Range_expand_Callback";

  @DomName('Range.extractContents')
  @DocsEditable
  DocumentFragment extractContents() native "Range_extractContents_Callback";

  @DomName('Range.getBoundingClientRect')
  @DocsEditable
  Rect getBoundingClientRect() native "Range_getBoundingClientRect_Callback";

  @DomName('Range.getClientRects')
  @DocsEditable
  List<Rect> getClientRects() native "Range_getClientRects_Callback";

  @DomName('Range.insertNode')
  @DocsEditable
  void insertNode(Node newNode) native "Range_insertNode_Callback";

  @DomName('Range.intersectsNode')
  @DocsEditable
  bool intersectsNode(Node refNode) native "Range_intersectsNode_Callback";

  @DomName('Range.isPointInRange')
  @DocsEditable
  bool isPointInRange(Node refNode, int offset) native "Range_isPointInRange_Callback";

  @DomName('Range.selectNode')
  @DocsEditable
  void selectNode(Node refNode) native "Range_selectNode_Callback";

  @DomName('Range.selectNodeContents')
  @DocsEditable
  void selectNodeContents(Node refNode) native "Range_selectNodeContents_Callback";

  @DomName('Range.setEnd')
  @DocsEditable
  void setEnd(Node refNode, int offset) native "Range_setEnd_Callback";

  @DomName('Range.setEndAfter')
  @DocsEditable
  void setEndAfter(Node refNode) native "Range_setEndAfter_Callback";

  @DomName('Range.setEndBefore')
  @DocsEditable
  void setEndBefore(Node refNode) native "Range_setEndBefore_Callback";

  @DomName('Range.setStart')
  @DocsEditable
  void setStart(Node refNode, int offset) native "Range_setStart_Callback";

  @DomName('Range.setStartAfter')
  @DocsEditable
  void setStartAfter(Node refNode) native "Range_setStartAfter_Callback";

  @DomName('Range.setStartBefore')
  @DocsEditable
  void setStartBefore(Node refNode) native "Range_setStartBefore_Callback";

  @DomName('Range.surroundContents')
  @DocsEditable
  void surroundContents(Node newParent) native "Range_surroundContents_Callback";

  @DomName('Range.toString')
  @DocsEditable
  String toString() native "Range_toString_Callback";


  /**
   * Checks if createContextualFragment is supported.
   *
   * See also:
   *
   * * [createContextualFragment]
   */
  static bool get supportsCreateContextualFragment => true;
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('RangeException')
class RangeException extends NativeFieldWrapperClass1 {
  RangeException.internal();

  @DomName('RangeException.BAD_BOUNDARYPOINTS_ERR')
  @DocsEditable
  static const int BAD_BOUNDARYPOINTS_ERR = 1;

  @DomName('RangeException.INVALID_NODE_TYPE_ERR')
  @DocsEditable
  static const int INVALID_NODE_TYPE_ERR = 2;

  @DomName('RangeException.code')
  @DocsEditable
  int get code native "RangeException_code_Getter";

  @DomName('RangeException.message')
  @DocsEditable
  String get message native "RangeException_message_Getter";

  @DomName('RangeException.name')
  @DocsEditable
  String get name native "RangeException_name_Getter";

  @DomName('RangeException.toString')
  @DocsEditable
  String toString() native "RangeException_toString_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


typedef void RequestAnimationFrameCallback(num highResTime);
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('RTCDataChannel')
class RtcDataChannel extends EventTarget {
  RtcDataChannel.internal() : super.internal();

  @DomName('RTCDataChannel.closeEvent')
  @DocsEditable
  static const EventStreamProvider<Event> closeEvent = const EventStreamProvider<Event>('close');

  @DomName('RTCDataChannel.errorEvent')
  @DocsEditable
  static const EventStreamProvider<Event> errorEvent = const EventStreamProvider<Event>('error');

  @DomName('RTCDataChannel.messageEvent')
  @DocsEditable
  static const EventStreamProvider<MessageEvent> messageEvent = const EventStreamProvider<MessageEvent>('message');

  @DomName('RTCDataChannel.openEvent')
  @DocsEditable
  static const EventStreamProvider<Event> openEvent = const EventStreamProvider<Event>('open');

  @DomName('RTCDataChannel.binaryType')
  @DocsEditable
  String get binaryType native "RTCDataChannel_binaryType_Getter";

  @DomName('RTCDataChannel.binaryType')
  @DocsEditable
  void set binaryType(String value) native "RTCDataChannel_binaryType_Setter";

  @DomName('RTCDataChannel.bufferedAmount')
  @DocsEditable
  int get bufferedAmount native "RTCDataChannel_bufferedAmount_Getter";

  @DomName('RTCDataChannel.label')
  @DocsEditable
  String get label native "RTCDataChannel_label_Getter";

  @DomName('RTCDataChannel.readyState')
  @DocsEditable
  String get readyState native "RTCDataChannel_readyState_Getter";

  @DomName('RTCDataChannel.reliable')
  @DocsEditable
  bool get reliable native "RTCDataChannel_reliable_Getter";

  @DomName('RTCDataChannel.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "RTCDataChannel_addEventListener_Callback";

  @DomName('RTCDataChannel.close')
  @DocsEditable
  void close() native "RTCDataChannel_close_Callback";

  @DomName('RTCDataChannel.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event event) native "RTCDataChannel_dispatchEvent_Callback";

  @DomName('RTCDataChannel.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "RTCDataChannel_removeEventListener_Callback";

  void send(data) {
    if ((data is TypedData || data == null)) {
      _send_1(data);
      return;
    }
    if ((data is ByteBuffer || data == null)) {
      _send_2(data);
      return;
    }
    if ((data is Blob || data == null)) {
      _send_3(data);
      return;
    }
    if ((data is String || data == null)) {
      _send_4(data);
      return;
    }
    throw new ArgumentError("Incorrect number or type of arguments");
  }

  void _send_1(data) native "RTCDataChannel__send_1_Callback";

  void _send_2(data) native "RTCDataChannel__send_2_Callback";

  void _send_3(data) native "RTCDataChannel__send_3_Callback";

  void _send_4(data) native "RTCDataChannel__send_4_Callback";

  @DomName('RTCDataChannel.onclose')
  @DocsEditable
  Stream<Event> get onClose => closeEvent.forTarget(this);

  @DomName('RTCDataChannel.onerror')
  @DocsEditable
  Stream<Event> get onError => errorEvent.forTarget(this);

  @DomName('RTCDataChannel.onmessage')
  @DocsEditable
  Stream<MessageEvent> get onMessage => messageEvent.forTarget(this);

  @DomName('RTCDataChannel.onopen')
  @DocsEditable
  Stream<Event> get onOpen => openEvent.forTarget(this);

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('RTCDataChannelEvent')
class RtcDataChannelEvent extends Event {
  RtcDataChannelEvent.internal() : super.internal();

  @DomName('RTCDataChannelEvent.channel')
  @DocsEditable
  RtcDataChannel get channel native "RTCDataChannelEvent_channel_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('RTCDTMFSender')
class RtcDtmfSender extends EventTarget {
  RtcDtmfSender.internal() : super.internal();

  @DomName('RTCDTMFSender.tonechangeEvent')
  @DocsEditable
  static const EventStreamProvider<RtcDtmfToneChangeEvent> toneChangeEvent = const EventStreamProvider<RtcDtmfToneChangeEvent>('tonechange');

  @DomName('RTCDTMFSender.canInsertDTMF')
  @DocsEditable
  bool get canInsertDtmf native "RTCDTMFSender_canInsertDTMF_Getter";

  @DomName('RTCDTMFSender.duration')
  @DocsEditable
  int get duration native "RTCDTMFSender_duration_Getter";

  @DomName('RTCDTMFSender.interToneGap')
  @DocsEditable
  int get interToneGap native "RTCDTMFSender_interToneGap_Getter";

  @DomName('RTCDTMFSender.toneBuffer')
  @DocsEditable
  String get toneBuffer native "RTCDTMFSender_toneBuffer_Getter";

  @DomName('RTCDTMFSender.track')
  @DocsEditable
  MediaStreamTrack get track native "RTCDTMFSender_track_Getter";

  @DomName('RTCDTMFSender.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "RTCDTMFSender_addEventListener_Callback";

  @DomName('RTCDTMFSender.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event event) native "RTCDTMFSender_dispatchEvent_Callback";

  void insertDtmf(String tones, [int duration, int interToneGap]) {
    if (?interToneGap) {
      _insertDTMF_1(tones, duration, interToneGap);
      return;
    }
    if (?duration) {
      _insertDTMF_2(tones, duration);
      return;
    }
    _insertDTMF_3(tones);
    return;
  }

  void _insertDTMF_1(tones, duration, interToneGap) native "RTCDTMFSender__insertDTMF_1_Callback";

  void _insertDTMF_2(tones, duration) native "RTCDTMFSender__insertDTMF_2_Callback";

  void _insertDTMF_3(tones) native "RTCDTMFSender__insertDTMF_3_Callback";

  @DomName('RTCDTMFSender.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "RTCDTMFSender_removeEventListener_Callback";

  @DomName('RTCDTMFSender.ontonechange')
  @DocsEditable
  Stream<RtcDtmfToneChangeEvent> get onToneChange => toneChangeEvent.forTarget(this);

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('RTCDTMFToneChangeEvent')
class RtcDtmfToneChangeEvent extends Event {
  RtcDtmfToneChangeEvent.internal() : super.internal();

  @DomName('RTCDTMFToneChangeEvent.tone')
  @DocsEditable
  String get tone native "RTCDTMFToneChangeEvent_tone_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('RTCIceCandidate')
@SupportedBrowser(SupportedBrowser.CHROME)
@Experimental
class RtcIceCandidate extends NativeFieldWrapperClass1 {
  RtcIceCandidate.internal();

  @DomName('RTCIceCandidate.RTCIceCandidate')
  @DocsEditable
  factory RtcIceCandidate(Map dictionary) {
    return RtcIceCandidate._create_1(dictionary);
  }

  @DocsEditable
  static RtcIceCandidate _create_1(dictionary) native "RTCIceCandidate__create_1constructorCallback";

  @DomName('RTCIceCandidate.candidate')
  @DocsEditable
  String get candidate native "RTCIceCandidate_candidate_Getter";

  @DomName('RTCIceCandidate.sdpMLineIndex')
  @DocsEditable
  int get sdpMLineIndex native "RTCIceCandidate_sdpMLineIndex_Getter";

  @DomName('RTCIceCandidate.sdpMid')
  @DocsEditable
  String get sdpMid native "RTCIceCandidate_sdpMid_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('RTCIceCandidateEvent')
class RtcIceCandidateEvent extends Event {
  RtcIceCandidateEvent.internal() : super.internal();

  @DomName('RTCIceCandidateEvent.candidate')
  @DocsEditable
  RtcIceCandidate get candidate native "RTCIceCandidateEvent_candidate_Getter";

}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('RTCPeerConnection')
@SupportedBrowser(SupportedBrowser.CHROME)
@Experimental
class RtcPeerConnection extends EventTarget {

  /**
   * Checks if Real Time Communication (RTC) APIs are supported and enabled on
   * the current platform.
   */
  static bool get supported => true;
  Future<RtcSessionDescription> createOffer([Map mediaConstraints]) {
    var completer = new Completer<RtcSessionDescription>();
    _createOffer(
        (value) { completer.complete(value); },
        (error) { completer.completeError(error); }, mediaConstraints);
    return completer.future;
  }

  Future<RtcSessionDescription> createAnswer([Map mediaConstraints]) {
    var completer = new Completer<RtcSessionDescription>();
    _createAnswer(
        (value) { completer.complete(value); },
        (error) { completer.completeError(error); }, mediaConstraints);
    return completer.future;
  }
  RtcPeerConnection.internal() : super.internal();

  @DomName('RTCPeerConnection.addstreamEvent')
  @DocsEditable
  static const EventStreamProvider<MediaStreamEvent> addStreamEvent = const EventStreamProvider<MediaStreamEvent>('addstream');

  @DomName('RTCPeerConnection.datachannelEvent')
  @DocsEditable
  static const EventStreamProvider<RtcDataChannelEvent> dataChannelEvent = const EventStreamProvider<RtcDataChannelEvent>('datachannel');

  @DomName('RTCPeerConnection.icecandidateEvent')
  @DocsEditable
  static const EventStreamProvider<RtcIceCandidateEvent> iceCandidateEvent = const EventStreamProvider<RtcIceCandidateEvent>('icecandidate');

  @DomName('RTCPeerConnection.iceconnectionstatechangeEvent')
  @DocsEditable
  static const EventStreamProvider<Event> iceConnectionStateChangeEvent = const EventStreamProvider<Event>('iceconnectionstatechange');

  @DomName('RTCPeerConnection.negotiationneededEvent')
  @DocsEditable
  static const EventStreamProvider<Event> negotiationNeededEvent = const EventStreamProvider<Event>('negotiationneeded');

  @DomName('RTCPeerConnection.removestreamEvent')
  @DocsEditable
  static const EventStreamProvider<MediaStreamEvent> removeStreamEvent = const EventStreamProvider<MediaStreamEvent>('removestream');

  @DomName('RTCPeerConnection.signalingstatechangeEvent')
  @DocsEditable
  static const EventStreamProvider<Event> signalingStateChangeEvent = const EventStreamProvider<Event>('signalingstatechange');

  @DomName('RTCPeerConnection.RTCPeerConnection')
  @DocsEditable
  factory RtcPeerConnection(Map rtcIceServers, [Map mediaConstraints]) {
    return RtcPeerConnection._create_1(rtcIceServers, mediaConstraints);
  }

  @DocsEditable
  static RtcPeerConnection _create_1(rtcIceServers, mediaConstraints) native "RTCPeerConnection__create_1constructorCallback";

  @DomName('RTCPeerConnection.iceConnectionState')
  @DocsEditable
  String get iceConnectionState native "RTCPeerConnection_iceConnectionState_Getter";

  @DomName('RTCPeerConnection.iceGatheringState')
  @DocsEditable
  String get iceGatheringState native "RTCPeerConnection_iceGatheringState_Getter";

  @DomName('RTCPeerConnection.localDescription')
  @DocsEditable
  RtcSessionDescription get localDescription native "RTCPeerConnection_localDescription_Getter";

  @DomName('RTCPeerConnection.remoteDescription')
  @DocsEditable
  RtcSessionDescription get remoteDescription native "RTCPeerConnection_remoteDescription_Getter";

  @DomName('RTCPeerConnection.signalingState')
  @DocsEditable
  String get signalingState native "RTCPeerConnection_signalingState_Getter";

  @DomName('RTCPeerConnection.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "RTCPeerConnection_addEventListener_Callback";

  @DomName('RTCPeerConnection.addIceCandidate')
  @DocsEditable
  void addIceCandidate(RtcIceCandidate candidate) native "RTCPeerConnection_addIceCandidate_Callback";

  @DomName('RTCPeerConnection.addStream')
  @DocsEditable
  void addStream(MediaStream stream, [Map mediaConstraints]) native "RTCPeerConnection_addStream_Callback";

  @DomName('RTCPeerConnection.close')
  @DocsEditable
  void close() native "RTCPeerConnection_close_Callback";

  @DomName('RTCPeerConnection.createAnswer')
  @DocsEditable
  void _createAnswer(_RtcSessionDescriptionCallback successCallback, [_RtcErrorCallback failureCallback, Map mediaConstraints]) native "RTCPeerConnection_createAnswer_Callback";

  @DomName('RTCPeerConnection.createDTMFSender')
  @DocsEditable
  RtcDtmfSender createDtmfSender(MediaStreamTrack track) native "RTCPeerConnection_createDTMFSender_Callback";

  @DomName('RTCPeerConnection.createDataChannel')
  @DocsEditable
  RtcDataChannel createDataChannel(String label, [Map options]) native "RTCPeerConnection_createDataChannel_Callback";

  @DomName('RTCPeerConnection.createOffer')
  @DocsEditable
  void _createOffer(_RtcSessionDescriptionCallback successCallback, [_RtcErrorCallback failureCallback, Map mediaConstraints]) native "RTCPeerConnection_createOffer_Callback";

  @DomName('RTCPeerConnection.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event event) native "RTCPeerConnection_dispatchEvent_Callback";

  @DomName('RTCPeerConnection.getLocalStreams')
  @DocsEditable
  List<MediaStream> getLocalStreams() native "RTCPeerConnection_getLocalStreams_Callback";

  @DomName('RTCPeerConnection.getRemoteStreams')
  @DocsEditable
  List<MediaStream> getRemoteStreams() native "RTCPeerConnection_getRemoteStreams_Callback";

  @DomName('RTCPeerConnection.getStats')
  @DocsEditable
  void getStats(RtcStatsCallback successCallback, MediaStreamTrack selector) native "RTCPeerConnection_getStats_Callback";

  @DomName('RTCPeerConnection.getStreamById')
  @DocsEditable
  MediaStream getStreamById(String streamId) native "RTCPeerConnection_getStreamById_Callback";

  @DomName('RTCPeerConnection.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "RTCPeerConnection_removeEventListener_Callback";

  @DomName('RTCPeerConnection.removeStream')
  @DocsEditable
  void removeStream(MediaStream stream) native "RTCPeerConnection_removeStream_Callback";

  @DomName('RTCPeerConnection.setLocalDescription')
  @DocsEditable
  void _setLocalDescription(RtcSessionDescription description, [VoidCallback successCallback, _RtcErrorCallback failureCallback]) native "RTCPeerConnection_setLocalDescription_Callback";

  Future setLocalDescription(RtcSessionDescription description) {
    var completer = new Completer();
    _setLocalDescription(description,
        () { completer.complete(); },
        (error) { completer.completeError(error); });
    return completer.future;
  }

  @DomName('RTCPeerConnection.setRemoteDescription')
  @DocsEditable
  void _setRemoteDescription(RtcSessionDescription description, [VoidCallback successCallback, _RtcErrorCallback failureCallback]) native "RTCPeerConnection_setRemoteDescription_Callback";

  Future setRemoteDescription(RtcSessionDescription description) {
    var completer = new Completer();
    _setRemoteDescription(description,
        () { completer.complete(); },
        (error) { completer.completeError(error); });
    return completer.future;
  }

  @DomName('RTCPeerConnection.updateIce')
  @DocsEditable
  void updateIce([Map configuration, Map mediaConstraints]) native "RTCPeerConnection_updateIce_Callback";

  @DomName('RTCPeerConnection.onaddstream')
  @DocsEditable
  Stream<MediaStreamEvent> get onAddStream => addStreamEvent.forTarget(this);

  @DomName('RTCPeerConnection.ondatachannel')
  @DocsEditable
  Stream<RtcDataChannelEvent> get onDataChannel => dataChannelEvent.forTarget(this);

  @DomName('RTCPeerConnection.onicecandidate')
  @DocsEditable
  Stream<RtcIceCandidateEvent> get onIceCandidate => iceCandidateEvent.forTarget(this);

  @DomName('RTCPeerConnection.oniceconnectionstatechange')
  @DocsEditable
  Stream<Event> get onIceConnectionStateChange => iceConnectionStateChangeEvent.forTarget(this);

  @DomName('RTCPeerConnection.onnegotiationneeded')
  @DocsEditable
  Stream<Event> get onNegotiationNeeded => negotiationNeededEvent.forTarget(this);

  @DomName('RTCPeerConnection.onremovestream')
  @DocsEditable
  Stream<MediaStreamEvent> get onRemoveStream => removeStreamEvent.forTarget(this);

  @DomName('RTCPeerConnection.onsignalingstatechange')
  @DocsEditable
  Stream<Event> get onSignalingStateChange => signalingStateChangeEvent.forTarget(this);

}


// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('RTCSessionDescription')
@SupportedBrowser(SupportedBrowser.CHROME)
@Experimental
class RtcSessionDescription extends NativeFieldWrapperClass1 {
  RtcSessionDescription.internal();

  @DomName('RTCSessionDescription.RTCSessionDescription')
  @DocsEditable
  factory RtcSessionDescription(Map dictionary) {
    return RtcSessionDescription._create_1(dictionary);
  }

  @DocsEditable
  static RtcSessionDescription _create_1(dictionary) native "RTCSessionDescription__create_1constructorCallback";

  @DomName('RTCSessionDescription.sdp')
  @DocsEditable
  String get sdp native "RTCSessionDescription_sdp_Getter";

  @DomName('RTCSessionDescription.sdp')
  @DocsEditable
  void set sdp(String value) native "RTCSessionDescription_sdp_Setter";

  @DomName('RTCSessionDescription.type')
  @DocsEditable
  String get type native "RTCSessionDescription_type_Getter";

  @DomName('RTCSessionDescription.type')
  @DocsEditable
  void set type(String value) native "RTCSessionDescription_type_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('RTCStatsReport')
class RtcStatsReport extends NativeFieldWrapperClass1 {
  RtcStatsReport.internal();

  @DomName('RTCStatsReport.id')
  @DocsEditable
  String get id native "RTCStatsReport_id_Getter";

  @DomName('RTCStatsReport.local')
  @DocsEditable
  RtcStatsReport get local native "RTCStatsReport_local_Getter";

  @DomName('RTCStatsReport.remote')
  @DocsEditable
  RtcStatsReport get remote native "RTCStatsReport_remote_Getter";

  @DomName('RTCStatsReport.timestamp')
  @DocsEditable
  DateTime get timestamp native "RTCStatsReport_timestamp_Getter";

  @DomName('RTCStatsReport.type')
  @DocsEditable
  String get type native "RTCStatsReport_type_Getter";

  @DomName('RTCStatsReport.names')
  @DocsEditable
  List<String> names() native "RTCStatsReport_names_Callback";

  @DomName('RTCStatsReport.stat')
  @DocsEditable
  String stat(String name) native "RTCStatsReport_stat_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('RTCStatsResponse')
class RtcStatsResponse extends NativeFieldWrapperClass1 {
  RtcStatsResponse.internal();

  @DomName('RTCStatsResponse.namedItem')
  @DocsEditable
  RtcStatsReport namedItem(String name) native "RTCStatsResponse_namedItem_Callback";

  @DomName('RTCStatsResponse.result')
  @DocsEditable
  List<RtcStatsReport> result() native "RTCStatsResponse_result_Callback";

}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DocsEditable
@DomName('Screen')
class Screen extends NativeFieldWrapperClass1 {

  @DomName('Screen.availHeight')
  @DomName('Screen.availLeft')
  @DomName('Screen.availTop')
  @DomName('Screen.availWidth')
  Rect get available => new Rect($dom_availLeft, $dom_availTop, $dom_availWidth,
      $dom_availHeight);
  Screen.internal();

  @DomName('Screen.availHeight')
  @DocsEditable
  int get $dom_availHeight native "Screen_availHeight_Getter";

  @DomName('Screen.availLeft')
  @DocsEditable
  int get $dom_availLeft native "Screen_availLeft_Getter";

  @DomName('Screen.availTop')
  @DocsEditable
  int get $dom_availTop native "Screen_availTop_Getter";

  @DomName('Screen.availWidth')
  @DocsEditable
  int get $dom_availWidth native "Screen_availWidth_Getter";

  @DomName('Screen.colorDepth')
  @DocsEditable
  int get colorDepth native "Screen_colorDepth_Getter";

  @DomName('Screen.height')
  @DocsEditable
  int get height native "Screen_height_Getter";

  @DomName('Screen.pixelDepth')
  @DocsEditable
  int get pixelDepth native "Screen_pixelDepth_Getter";

  @DomName('Screen.width')
  @DocsEditable
  int get width native "Screen_width_Getter";
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLScriptElement')
class ScriptElement extends _Element_Merged {
  ScriptElement.internal() : super.internal();

  @DomName('HTMLScriptElement.HTMLScriptElement')
  @DocsEditable
  factory ScriptElement() => document.$dom_createElement("script");

  @DomName('HTMLScriptElement.async')
  @DocsEditable
  bool get async native "HTMLScriptElement_async_Getter";

  @DomName('HTMLScriptElement.async')
  @DocsEditable
  void set async(bool value) native "HTMLScriptElement_async_Setter";

  @DomName('HTMLScriptElement.charset')
  @DocsEditable
  String get charset native "HTMLScriptElement_charset_Getter";

  @DomName('HTMLScriptElement.charset')
  @DocsEditable
  void set charset(String value) native "HTMLScriptElement_charset_Setter";

  @DomName('HTMLScriptElement.crossOrigin')
  @DocsEditable
  String get crossOrigin native "HTMLScriptElement_crossOrigin_Getter";

  @DomName('HTMLScriptElement.crossOrigin')
  @DocsEditable
  void set crossOrigin(String value) native "HTMLScriptElement_crossOrigin_Setter";

  @DomName('HTMLScriptElement.defer')
  @DocsEditable
  bool get defer native "HTMLScriptElement_defer_Getter";

  @DomName('HTMLScriptElement.defer')
  @DocsEditable
  void set defer(bool value) native "HTMLScriptElement_defer_Setter";

  @DomName('HTMLScriptElement.event')
  @DocsEditable
  String get event native "HTMLScriptElement_event_Getter";

  @DomName('HTMLScriptElement.event')
  @DocsEditable
  void set event(String value) native "HTMLScriptElement_event_Setter";

  @DomName('HTMLScriptElement.htmlFor')
  @DocsEditable
  String get htmlFor native "HTMLScriptElement_htmlFor_Getter";

  @DomName('HTMLScriptElement.htmlFor')
  @DocsEditable
  void set htmlFor(String value) native "HTMLScriptElement_htmlFor_Setter";

  @DomName('HTMLScriptElement.nonce')
  @DocsEditable
  String get nonce native "HTMLScriptElement_nonce_Getter";

  @DomName('HTMLScriptElement.nonce')
  @DocsEditable
  void set nonce(String value) native "HTMLScriptElement_nonce_Setter";

  @DomName('HTMLScriptElement.src')
  @DocsEditable
  String get src native "HTMLScriptElement_src_Getter";

  @DomName('HTMLScriptElement.src')
  @DocsEditable
  void set src(String value) native "HTMLScriptElement_src_Setter";

  @DomName('HTMLScriptElement.type')
  @DocsEditable
  String get type native "HTMLScriptElement_type_Getter";

  @DomName('HTMLScriptElement.type')
  @DocsEditable
  void set type(String value) native "HTMLScriptElement_type_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('ScriptProfile')
class ScriptProfile extends NativeFieldWrapperClass1 {
  ScriptProfile.internal();

  @DomName('ScriptProfile.head')
  @DocsEditable
  ScriptProfileNode get head native "ScriptProfile_head_Getter";

  @DomName('ScriptProfile.idleTime')
  @DocsEditable
  num get idleTime native "ScriptProfile_idleTime_Getter";

  @DomName('ScriptProfile.title')
  @DocsEditable
  String get title native "ScriptProfile_title_Getter";

  @DomName('ScriptProfile.uid')
  @DocsEditable
  int get uid native "ScriptProfile_uid_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('ScriptProfileNode')
class ScriptProfileNode extends NativeFieldWrapperClass1 {
  ScriptProfileNode.internal();

  @DomName('ScriptProfileNode.callUID')
  @DocsEditable
  int get callUid native "ScriptProfileNode_callUID_Getter";

  @DomName('ScriptProfileNode.functionName')
  @DocsEditable
  String get functionName native "ScriptProfileNode_functionName_Getter";

  @DomName('ScriptProfileNode.lineNumber')
  @DocsEditable
  int get lineNumber native "ScriptProfileNode_lineNumber_Getter";

  @DomName('ScriptProfileNode.numberOfCalls')
  @DocsEditable
  int get numberOfCalls native "ScriptProfileNode_numberOfCalls_Getter";

  @DomName('ScriptProfileNode.selfTime')
  @DocsEditable
  num get selfTime native "ScriptProfileNode_selfTime_Getter";

  @DomName('ScriptProfileNode.totalTime')
  @DocsEditable
  num get totalTime native "ScriptProfileNode_totalTime_Getter";

  @DomName('ScriptProfileNode.url')
  @DocsEditable
  String get url native "ScriptProfileNode_url_Getter";

  @DomName('ScriptProfileNode.visible')
  @DocsEditable
  bool get visible native "ScriptProfileNode_visible_Getter";

  @DomName('ScriptProfileNode.children')
  @DocsEditable
  List<ScriptProfileNode> children() native "ScriptProfileNode_children_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('SecurityPolicy')
class SecurityPolicy extends NativeFieldWrapperClass1 {
  SecurityPolicy.internal();

  @DomName('SecurityPolicy.allowsEval')
  @DocsEditable
  bool get allowsEval native "DOMSecurityPolicy_allowsEval_Getter";

  @DomName('SecurityPolicy.allowsInlineScript')
  @DocsEditable
  bool get allowsInlineScript native "DOMSecurityPolicy_allowsInlineScript_Getter";

  @DomName('SecurityPolicy.allowsInlineStyle')
  @DocsEditable
  bool get allowsInlineStyle native "DOMSecurityPolicy_allowsInlineStyle_Getter";

  @DomName('SecurityPolicy.isActive')
  @DocsEditable
  bool get isActive native "DOMSecurityPolicy_isActive_Getter";

  @DomName('SecurityPolicy.reportURIs')
  @DocsEditable
  List<String> get reportURIs native "DOMSecurityPolicy_reportURIs_Getter";

  @DomName('SecurityPolicy.allowsConnectionTo')
  @DocsEditable
  bool allowsConnectionTo(String url) native "DOMSecurityPolicy_allowsConnectionTo_Callback";

  @DomName('SecurityPolicy.allowsFontFrom')
  @DocsEditable
  bool allowsFontFrom(String url) native "DOMSecurityPolicy_allowsFontFrom_Callback";

  @DomName('SecurityPolicy.allowsFormAction')
  @DocsEditable
  bool allowsFormAction(String url) native "DOMSecurityPolicy_allowsFormAction_Callback";

  @DomName('SecurityPolicy.allowsFrameFrom')
  @DocsEditable
  bool allowsFrameFrom(String url) native "DOMSecurityPolicy_allowsFrameFrom_Callback";

  @DomName('SecurityPolicy.allowsImageFrom')
  @DocsEditable
  bool allowsImageFrom(String url) native "DOMSecurityPolicy_allowsImageFrom_Callback";

  @DomName('SecurityPolicy.allowsMediaFrom')
  @DocsEditable
  bool allowsMediaFrom(String url) native "DOMSecurityPolicy_allowsMediaFrom_Callback";

  @DomName('SecurityPolicy.allowsObjectFrom')
  @DocsEditable
  bool allowsObjectFrom(String url) native "DOMSecurityPolicy_allowsObjectFrom_Callback";

  @DomName('SecurityPolicy.allowsPluginType')
  @DocsEditable
  bool allowsPluginType(String type) native "DOMSecurityPolicy_allowsPluginType_Callback";

  @DomName('SecurityPolicy.allowsScriptFrom')
  @DocsEditable
  bool allowsScriptFrom(String url) native "DOMSecurityPolicy_allowsScriptFrom_Callback";

  @DomName('SecurityPolicy.allowsStyleFrom')
  @DocsEditable
  bool allowsStyleFrom(String url) native "DOMSecurityPolicy_allowsStyleFrom_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('SecurityPolicyViolationEvent')
class SecurityPolicyViolationEvent extends Event {
  SecurityPolicyViolationEvent.internal() : super.internal();

  @DomName('SecurityPolicyViolationEvent.blockedURI')
  @DocsEditable
  String get blockedUri native "SecurityPolicyViolationEvent_blockedURI_Getter";

  @DomName('SecurityPolicyViolationEvent.documentURI')
  @DocsEditable
  String get documentUri native "SecurityPolicyViolationEvent_documentURI_Getter";

  @DomName('SecurityPolicyViolationEvent.effectiveDirective')
  @DocsEditable
  String get effectiveDirective native "SecurityPolicyViolationEvent_effectiveDirective_Getter";

  @DomName('SecurityPolicyViolationEvent.lineNumber')
  @DocsEditable
  int get lineNumber native "SecurityPolicyViolationEvent_lineNumber_Getter";

  @DomName('SecurityPolicyViolationEvent.originalPolicy')
  @DocsEditable
  String get originalPolicy native "SecurityPolicyViolationEvent_originalPolicy_Getter";

  @DomName('SecurityPolicyViolationEvent.referrer')
  @DocsEditable
  String get referrer native "SecurityPolicyViolationEvent_referrer_Getter";

  @DomName('SecurityPolicyViolationEvent.sourceFile')
  @DocsEditable
  String get sourceFile native "SecurityPolicyViolationEvent_sourceFile_Getter";

  @DomName('SecurityPolicyViolationEvent.violatedDirective')
  @DocsEditable
  String get violatedDirective native "SecurityPolicyViolationEvent_violatedDirective_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('HTMLSelectElement')
class SelectElement extends _Element_Merged {
  SelectElement.internal() : super.internal();

  @DomName('HTMLSelectElement.HTMLSelectElement')
  @DocsEditable
  factory SelectElement() => document.$dom_createElement("select");

  @DomName('HTMLSelectElement.autofocus')
  @DocsEditable
  bool get autofocus native "HTMLSelectElement_autofocus_Getter";

  @DomName('HTMLSelectElement.autofocus')
  @DocsEditable
  void set autofocus(bool value) native "HTMLSelectElement_autofocus_Setter";

  @DomName('HTMLSelectElement.disabled')
  @DocsEditable
  bool get disabled native "HTMLSelectElement_disabled_Getter";

  @DomName('HTMLSelectElement.disabled')
  @DocsEditable
  void set disabled(bool value) native "HTMLSelectElement_disabled_Setter";

  @DomName('HTMLSelectElement.form')
  @DocsEditable
  FormElement get form native "HTMLSelectElement_form_Getter";

  @DomName('HTMLSelectElement.labels')
  @DocsEditable
  List<Node> get labels native "HTMLSelectElement_labels_Getter";

  @DomName('HTMLSelectElement.length')
  @DocsEditable
  int get length native "HTMLSelectElement_length_Getter";

  @DomName('HTMLSelectElement.length')
  @DocsEditable
  void set length(int value) native "HTMLSelectElement_length_Setter";

  @DomName('HTMLSelectElement.multiple')
  @DocsEditable
  bool get multiple native "HTMLSelectElement_multiple_Getter";

  @DomName('HTMLSelectElement.multiple')
  @DocsEditable
  void set multiple(bool value) native "HTMLSelectElement_multiple_Setter";

  @DomName('HTMLSelectElement.name')
  @DocsEditable
  String get name native "HTMLSelectElement_name_Getter";

  @DomName('HTMLSelectElement.name')
  @DocsEditable
  void set name(String value) native "HTMLSelectElement_name_Setter";

  @DomName('HTMLSelectElement.required')
  @DocsEditable
  bool get required native "HTMLSelectElement_required_Getter";

  @DomName('HTMLSelectElement.required')
  @DocsEditable
  void set required(bool value) native "HTMLSelectElement_required_Setter";

  @DomName('HTMLSelectElement.selectedIndex')
  @DocsEditable
  int get selectedIndex native "HTMLSelectElement_selectedIndex_Getter";

  @DomName('HTMLSelectElement.selectedIndex')
  @DocsEditable
  void set selectedIndex(int value) native "HTMLSelectElement_selectedIndex_Setter";

  @DomName('HTMLSelectElement.size')
  @DocsEditable
  int get size native "HTMLSelectElement_size_Getter";

  @DomName('HTMLSelectElement.size')
  @DocsEditable
  void set size(int value) native "HTMLSelectElement_size_Setter";

  @DomName('HTMLSelectElement.type')
  @DocsEditable
  String get type native "HTMLSelectElement_type_Getter";

  @DomName('HTMLSelectElement.validationMessage')
  @DocsEditable
  String get validationMessage native "HTMLSelectElement_validationMessage_Getter";

  @DomName('HTMLSelectElement.validity')
  @DocsEditable
  ValidityState get validity native "HTMLSelectElement_validity_Getter";

  @DomName('HTMLSelectElement.value')
  @DocsEditable
  String get value native "HTMLSelectElement_value_Getter";

  @DomName('HTMLSelectElement.value')
  @DocsEditable
  void set value(String value) native "HTMLSelectElement_value_Setter";

  @DomName('HTMLSelectElement.willValidate')
  @DocsEditable
  bool get willValidate native "HTMLSelectElement_willValidate_Getter";

  @DomName('HTMLSelectElement.checkValidity')
  @DocsEditable
  bool checkValidity() native "HTMLSelectElement_checkValidity_Callback";

  @DomName('HTMLSelectElement.item')
  @DocsEditable
  Node item(int index) native "HTMLSelectElement_item_Callback";

  @DomName('HTMLSelectElement.namedItem')
  @DocsEditable
  Node namedItem(String name) native "HTMLSelectElement_namedItem_Callback";

  @DomName('HTMLSelectElement.setCustomValidity')
  @DocsEditable
  void setCustomValidity(String error) native "HTMLSelectElement_setCustomValidity_Callback";


  // Override default options, since IE returns SelectElement itself and it
  // does not operate as a List.
  List<OptionElement> get options {
    var options = this.children.where((e) => e is OptionElement).toList();
    return new UnmodifiableListView(options);
  }

  List<OptionElement> get selectedOptions {
    // IE does not change the selected flag for single-selection items.
    if (this.multiple) {
      var options = this.options.where((o) => o.selected).toList();
      return new UnmodifiableListView(options);
    } else {
      return [this.options[this.selectedIndex]];
    }
  }
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('Selection')
class Selection extends NativeFieldWrapperClass1 {
  Selection.internal();

  @DomName('Selection.anchorNode')
  @DocsEditable
  Node get anchorNode native "DOMSelection_anchorNode_Getter";

  @DomName('Selection.anchorOffset')
  @DocsEditable
  int get anchorOffset native "DOMSelection_anchorOffset_Getter";

  @DomName('Selection.baseNode')
  @DocsEditable
  Node get baseNode native "DOMSelection_baseNode_Getter";

  @DomName('Selection.baseOffset')
  @DocsEditable
  int get baseOffset native "DOMSelection_baseOffset_Getter";

  @DomName('Selection.extentNode')
  @DocsEditable
  Node get extentNode native "DOMSelection_extentNode_Getter";

  @DomName('Selection.extentOffset')
  @DocsEditable
  int get extentOffset native "DOMSelection_extentOffset_Getter";

  @DomName('Selection.focusNode')
  @DocsEditable
  Node get focusNode native "DOMSelection_focusNode_Getter";

  @DomName('Selection.focusOffset')
  @DocsEditable
  int get focusOffset native "DOMSelection_focusOffset_Getter";

  @DomName('Selection.isCollapsed')
  @DocsEditable
  bool get isCollapsed native "DOMSelection_isCollapsed_Getter";

  @DomName('Selection.rangeCount')
  @DocsEditable
  int get rangeCount native "DOMSelection_rangeCount_Getter";

  @DomName('Selection.type')
  @DocsEditable
  String get type native "DOMSelection_type_Getter";

  @DomName('Selection.addRange')
  @DocsEditable
  void addRange(Range range) native "DOMSelection_addRange_Callback";

  @DomName('Selection.collapse')
  @DocsEditable
  void collapse(Node node, int index) native "DOMSelection_collapse_Callback";

  @DomName('Selection.collapseToEnd')
  @DocsEditable
  void collapseToEnd() native "DOMSelection_collapseToEnd_Callback";

  @DomName('Selection.collapseToStart')
  @DocsEditable
  void collapseToStart() native "DOMSelection_collapseToStart_Callback";

  @DomName('Selection.containsNode')
  @DocsEditable
  bool containsNode(Node node, bool allowPartial) native "DOMSelection_containsNode_Callback";

  @DomName('Selection.deleteFromDocument')
  @DocsEditable
  void deleteFromDocument() native "DOMSelection_deleteFromDocument_Callback";

  @DomName('Selection.empty')
  @DocsEditable
  void empty() native "DOMSelection_empty_Callback";

  @DomName('Selection.extend')
  @DocsEditable
  void extend(Node node, int offset) native "DOMSelection_extend_Callback";

  @DomName('Selection.getRangeAt')
  @DocsEditable
  Range getRangeAt(int index) native "DOMSelection_getRangeAt_Callback";

  @DomName('Selection.modify')
  @DocsEditable
  void modify(String alter, String direction, String granularity) native "DOMSelection_modify_Callback";

  @DomName('Selection.removeAllRanges')
  @DocsEditable
  void removeAllRanges() native "DOMSelection_removeAllRanges_Callback";

  @DomName('Selection.selectAllChildren')
  @DocsEditable
  void selectAllChildren(Node node) native "DOMSelection_selectAllChildren_Callback";

  @DomName('Selection.setBaseAndExtent')
  @DocsEditable
  void setBaseAndExtent(Node baseNode, int baseOffset, Node extentNode, int extentOffset) native "DOMSelection_setBaseAndExtent_Callback";

  @DomName('Selection.setPosition')
  @DocsEditable
  void setPosition(Node node, int offset) native "DOMSelection_setPosition_Callback";

  @DomName('Selection.toString')
  @DocsEditable
  String toString() native "DOMSelection_toString_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLShadowElement')
@SupportedBrowser(SupportedBrowser.CHROME, '26')
@Experimental
class ShadowElement extends _Element_Merged {
  ShadowElement.internal() : super.internal();

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('HTMLShadowElement.olderShadowRoot')
  @DocsEditable
  ShadowRoot get olderShadowRoot native "HTMLShadowElement_olderShadowRoot_Getter";

  @DomName('HTMLShadowElement.resetStyleInheritance')
  @DocsEditable
  bool get resetStyleInheritance native "HTMLShadowElement_resetStyleInheritance_Getter";

  @DomName('HTMLShadowElement.resetStyleInheritance')
  @DocsEditable
  void set resetStyleInheritance(bool value) native "HTMLShadowElement_resetStyleInheritance_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DomName('ShadowRoot')
@SupportedBrowser(SupportedBrowser.CHROME, '26')
@Experimental
class ShadowRoot extends DocumentFragment {
  ShadowRoot.internal() : super.internal();

  @DomName('ShadowRoot.activeElement')
  @DocsEditable
  Element get activeElement native "ShadowRoot_activeElement_Getter";

  @DomName('ShadowRoot.applyAuthorStyles')
  @DocsEditable
  bool get applyAuthorStyles native "ShadowRoot_applyAuthorStyles_Getter";

  @DomName('ShadowRoot.applyAuthorStyles')
  @DocsEditable
  void set applyAuthorStyles(bool value) native "ShadowRoot_applyAuthorStyles_Setter";

  @DomName('ShadowRoot.innerHTML')
  @DocsEditable
  String get innerHtml native "ShadowRoot_innerHTML_Getter";

  @DomName('ShadowRoot.innerHTML')
  @DocsEditable
  void set innerHtml(String value) native "ShadowRoot_innerHTML_Setter";

  @DomName('ShadowRoot.resetStyleInheritance')
  @DocsEditable
  bool get resetStyleInheritance native "ShadowRoot_resetStyleInheritance_Getter";

  @DomName('ShadowRoot.resetStyleInheritance')
  @DocsEditable
  void set resetStyleInheritance(bool value) native "ShadowRoot_resetStyleInheritance_Setter";

  @DomName('ShadowRoot.cloneNode')
  @DocsEditable
  Node clone(bool deep) native "ShadowRoot_cloneNode_Callback";

  @DomName('ShadowRoot.elementFromPoint')
  @DocsEditable
  Element elementFromPoint(int x, int y) native "ShadowRoot_elementFromPoint_Callback";

  @DomName('ShadowRoot.getElementById')
  @DocsEditable
  Element getElementById(String elementId) native "ShadowRoot_getElementById_Callback";

  @DomName('ShadowRoot.getElementsByClassName')
  @DocsEditable
  List<Node> getElementsByClassName(String className) native "ShadowRoot_getElementsByClassName_Callback";

  @DomName('ShadowRoot.getElementsByTagName')
  @DocsEditable
  List<Node> getElementsByTagName(String tagName) native "ShadowRoot_getElementsByTagName_Callback";

  @DomName('ShadowRoot.getSelection')
  @DocsEditable
  Selection getSelection() native "ShadowRoot_getSelection_Callback";

  static bool get supported => _Utils.shadowRootSupported(window.document);
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('SourceBuffer')
class SourceBuffer extends NativeFieldWrapperClass1 {
  SourceBuffer.internal();

  @DomName('SourceBuffer.buffered')
  @DocsEditable
  TimeRanges get buffered native "SourceBuffer_buffered_Getter";

  @DomName('SourceBuffer.timestampOffset')
  @DocsEditable
  num get timestampOffset native "SourceBuffer_timestampOffset_Getter";

  @DomName('SourceBuffer.timestampOffset')
  @DocsEditable
  void set timestampOffset(num value) native "SourceBuffer_timestampOffset_Setter";

  @DomName('SourceBuffer.abort')
  @DocsEditable
  void abort() native "SourceBuffer_abort_Callback";

  @DomName('SourceBuffer.append')
  @DocsEditable
  void append(Uint8List data) native "SourceBuffer_append_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('SourceBufferList')
class SourceBufferList extends EventTarget with ListMixin<SourceBuffer>, ImmutableListMixin<SourceBuffer> implements List<SourceBuffer> {
  SourceBufferList.internal() : super.internal();

  @DomName('SourceBufferList.length')
  @DocsEditable
  int get length native "SourceBufferList_length_Getter";

  SourceBuffer operator[](int index) {
    if (index < 0 || index >= length)
      throw new RangeError.range(index, 0, length);
    return _nativeIndexedGetter(index);
  }
  SourceBuffer _nativeIndexedGetter(int index) native "SourceBufferList_item_Callback";

  void operator[]=(int index, SourceBuffer value) {
    throw new UnsupportedError("Cannot assign element of immutable List.");
  }
  // -- start List<SourceBuffer> mixins.
  // SourceBuffer is the element type.


  void set length(int value) {
    throw new UnsupportedError("Cannot resize immutable List.");
  }

  SourceBuffer get first {
    if (this.length > 0) {
      return this[0];
    }
    throw new StateError("No elements");
  }

  SourceBuffer get last {
    int len = this.length;
    if (len > 0) {
      return this[len - 1];
    }
    throw new StateError("No elements");
  }

  SourceBuffer get single {
    int len = this.length;
    if (len == 1) {
      return this[0];
    }
    if (len == 0) throw new StateError("No elements");
    throw new StateError("More than one element");
  }

  SourceBuffer elementAt(int index) => this[index];
  // -- end List<SourceBuffer> mixins.

  @DomName('SourceBufferList.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "SourceBufferList_addEventListener_Callback";

  @DomName('SourceBufferList.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event event) native "SourceBufferList_dispatchEvent_Callback";

  @DomName('SourceBufferList.item')
  @DocsEditable
  SourceBuffer item(int index) native "SourceBufferList_item_Callback";

  @DomName('SourceBufferList.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "SourceBufferList_removeEventListener_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLSourceElement')
class SourceElement extends _Element_Merged {
  SourceElement.internal() : super.internal();

  @DomName('HTMLSourceElement.HTMLSourceElement')
  @DocsEditable
  factory SourceElement() => document.$dom_createElement("source");

  @DomName('HTMLSourceElement.media')
  @DocsEditable
  String get media native "HTMLSourceElement_media_Getter";

  @DomName('HTMLSourceElement.media')
  @DocsEditable
  void set media(String value) native "HTMLSourceElement_media_Setter";

  @DomName('HTMLSourceElement.src')
  @DocsEditable
  String get src native "HTMLSourceElement_src_Getter";

  @DomName('HTMLSourceElement.src')
  @DocsEditable
  void set src(String value) native "HTMLSourceElement_src_Setter";

  @DomName('HTMLSourceElement.type')
  @DocsEditable
  String get type native "HTMLSourceElement_type_Getter";

  @DomName('HTMLSourceElement.type')
  @DocsEditable
  void set type(String value) native "HTMLSourceElement_type_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLSpanElement')
class SpanElement extends _Element_Merged {
  SpanElement.internal() : super.internal();

  @DomName('HTMLSpanElement.HTMLSpanElement')
  @DocsEditable
  factory SpanElement() => document.$dom_createElement("span");

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('SpeechGrammar')
class SpeechGrammar extends NativeFieldWrapperClass1 {
  SpeechGrammar.internal();

  @DomName('SpeechGrammar.SpeechGrammar')
  @DocsEditable
  factory SpeechGrammar() {
    return SpeechGrammar._create_1();
  }

  @DocsEditable
  static SpeechGrammar _create_1() native "SpeechGrammar__create_1constructorCallback";

  @DomName('SpeechGrammar.src')
  @DocsEditable
  String get src native "SpeechGrammar_src_Getter";

  @DomName('SpeechGrammar.src')
  @DocsEditable
  void set src(String value) native "SpeechGrammar_src_Setter";

  @DomName('SpeechGrammar.weight')
  @DocsEditable
  num get weight native "SpeechGrammar_weight_Getter";

  @DomName('SpeechGrammar.weight')
  @DocsEditable
  void set weight(num value) native "SpeechGrammar_weight_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('SpeechGrammarList')
class SpeechGrammarList extends NativeFieldWrapperClass1 with ListMixin<SpeechGrammar>, ImmutableListMixin<SpeechGrammar> implements List<SpeechGrammar> {
  SpeechGrammarList.internal();

  @DomName('SpeechGrammarList.SpeechGrammarList')
  @DocsEditable
  factory SpeechGrammarList() {
    return SpeechGrammarList._create_1();
  }

  @DocsEditable
  static SpeechGrammarList _create_1() native "SpeechGrammarList__create_1constructorCallback";

  @DomName('SpeechGrammarList.length')
  @DocsEditable
  int get length native "SpeechGrammarList_length_Getter";

  SpeechGrammar operator[](int index) {
    if (index < 0 || index >= length)
      throw new RangeError.range(index, 0, length);
    return _nativeIndexedGetter(index);
  }
  SpeechGrammar _nativeIndexedGetter(int index) native "SpeechGrammarList_item_Callback";

  void operator[]=(int index, SpeechGrammar value) {
    throw new UnsupportedError("Cannot assign element of immutable List.");
  }
  // -- start List<SpeechGrammar> mixins.
  // SpeechGrammar is the element type.


  void set length(int value) {
    throw new UnsupportedError("Cannot resize immutable List.");
  }

  SpeechGrammar get first {
    if (this.length > 0) {
      return this[0];
    }
    throw new StateError("No elements");
  }

  SpeechGrammar get last {
    int len = this.length;
    if (len > 0) {
      return this[len - 1];
    }
    throw new StateError("No elements");
  }

  SpeechGrammar get single {
    int len = this.length;
    if (len == 1) {
      return this[0];
    }
    if (len == 0) throw new StateError("No elements");
    throw new StateError("More than one element");
  }

  SpeechGrammar elementAt(int index) => this[index];
  // -- end List<SpeechGrammar> mixins.

  void addFromString(String string, [num weight]) {
    if (?weight) {
      _addFromString_1(string, weight);
      return;
    }
    _addFromString_2(string);
    return;
  }

  void _addFromString_1(string, weight) native "SpeechGrammarList__addFromString_1_Callback";

  void _addFromString_2(string) native "SpeechGrammarList__addFromString_2_Callback";

  void addFromUri(String src, [num weight]) {
    if (?weight) {
      _addFromUri_1(src, weight);
      return;
    }
    _addFromUri_2(src);
    return;
  }

  void _addFromUri_1(src, weight) native "SpeechGrammarList__addFromUri_1_Callback";

  void _addFromUri_2(src) native "SpeechGrammarList__addFromUri_2_Callback";

  @DomName('SpeechGrammarList.item')
  @DocsEditable
  SpeechGrammar item(int index) native "SpeechGrammarList_item_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('SpeechInputEvent')
class SpeechInputEvent extends Event {
  SpeechInputEvent.internal() : super.internal();

  @DomName('SpeechInputEvent.results')
  @DocsEditable
  List<SpeechInputResult> get results native "SpeechInputEvent_results_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('SpeechInputResult')
class SpeechInputResult extends NativeFieldWrapperClass1 {
  SpeechInputResult.internal();

  @DomName('SpeechInputResult.confidence')
  @DocsEditable
  num get confidence native "SpeechInputResult_confidence_Getter";

  @DomName('SpeechInputResult.utterance')
  @DocsEditable
  String get utterance native "SpeechInputResult_utterance_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('SpeechRecognition')
@SupportedBrowser(SupportedBrowser.CHROME, '25')
@Experimental
class SpeechRecognition extends EventTarget {
  SpeechRecognition.internal() : super.internal();

  @DomName('SpeechRecognition.audioendEvent')
  @DocsEditable
  static const EventStreamProvider<Event> audioEndEvent = const EventStreamProvider<Event>('audioend');

  @DomName('SpeechRecognition.audiostartEvent')
  @DocsEditable
  static const EventStreamProvider<Event> audioStartEvent = const EventStreamProvider<Event>('audiostart');

  @DomName('SpeechRecognition.endEvent')
  @DocsEditable
  static const EventStreamProvider<Event> endEvent = const EventStreamProvider<Event>('end');

  @DomName('SpeechRecognition.errorEvent')
  @DocsEditable
  static const EventStreamProvider<SpeechRecognitionError> errorEvent = const EventStreamProvider<SpeechRecognitionError>('error');

  @DomName('SpeechRecognition.nomatchEvent')
  @DocsEditable
  static const EventStreamProvider<SpeechRecognitionEvent> noMatchEvent = const EventStreamProvider<SpeechRecognitionEvent>('nomatch');

  @DomName('SpeechRecognition.resultEvent')
  @DocsEditable
  static const EventStreamProvider<SpeechRecognitionEvent> resultEvent = const EventStreamProvider<SpeechRecognitionEvent>('result');

  @DomName('SpeechRecognition.soundendEvent')
  @DocsEditable
  static const EventStreamProvider<Event> soundEndEvent = const EventStreamProvider<Event>('soundend');

  @DomName('SpeechRecognition.soundstartEvent')
  @DocsEditable
  static const EventStreamProvider<Event> soundStartEvent = const EventStreamProvider<Event>('soundstart');

  @DomName('SpeechRecognition.speechendEvent')
  @DocsEditable
  static const EventStreamProvider<Event> speechEndEvent = const EventStreamProvider<Event>('speechend');

  @DomName('SpeechRecognition.speechstartEvent')
  @DocsEditable
  static const EventStreamProvider<Event> speechStartEvent = const EventStreamProvider<Event>('speechstart');

  @DomName('SpeechRecognition.startEvent')
  @DocsEditable
  static const EventStreamProvider<Event> startEvent = const EventStreamProvider<Event>('start');

  @DomName('SpeechRecognition.SpeechRecognition')
  @DocsEditable
  factory SpeechRecognition() {
    return SpeechRecognition._create_1();
  }

  @DocsEditable
  static SpeechRecognition _create_1() native "SpeechRecognition__create_1constructorCallback";

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('SpeechRecognition.continuous')
  @DocsEditable
  bool get continuous native "SpeechRecognition_continuous_Getter";

  @DomName('SpeechRecognition.continuous')
  @DocsEditable
  void set continuous(bool value) native "SpeechRecognition_continuous_Setter";

  @DomName('SpeechRecognition.grammars')
  @DocsEditable
  SpeechGrammarList get grammars native "SpeechRecognition_grammars_Getter";

  @DomName('SpeechRecognition.grammars')
  @DocsEditable
  void set grammars(SpeechGrammarList value) native "SpeechRecognition_grammars_Setter";

  @DomName('SpeechRecognition.interimResults')
  @DocsEditable
  bool get interimResults native "SpeechRecognition_interimResults_Getter";

  @DomName('SpeechRecognition.interimResults')
  @DocsEditable
  void set interimResults(bool value) native "SpeechRecognition_interimResults_Setter";

  @DomName('SpeechRecognition.lang')
  @DocsEditable
  String get lang native "SpeechRecognition_lang_Getter";

  @DomName('SpeechRecognition.lang')
  @DocsEditable
  void set lang(String value) native "SpeechRecognition_lang_Setter";

  @DomName('SpeechRecognition.maxAlternatives')
  @DocsEditable
  int get maxAlternatives native "SpeechRecognition_maxAlternatives_Getter";

  @DomName('SpeechRecognition.maxAlternatives')
  @DocsEditable
  void set maxAlternatives(int value) native "SpeechRecognition_maxAlternatives_Setter";

  @DomName('SpeechRecognition.abort')
  @DocsEditable
  void abort() native "SpeechRecognition_abort_Callback";

  @DomName('SpeechRecognition.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "SpeechRecognition_addEventListener_Callback";

  @DomName('SpeechRecognition.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event evt) native "SpeechRecognition_dispatchEvent_Callback";

  @DomName('SpeechRecognition.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "SpeechRecognition_removeEventListener_Callback";

  @DomName('SpeechRecognition.start')
  @DocsEditable
  void start() native "SpeechRecognition_start_Callback";

  @DomName('SpeechRecognition.stop')
  @DocsEditable
  void stop() native "SpeechRecognition_stop_Callback";

  @DomName('SpeechRecognition.onaudioend')
  @DocsEditable
  Stream<Event> get onAudioEnd => audioEndEvent.forTarget(this);

  @DomName('SpeechRecognition.onaudiostart')
  @DocsEditable
  Stream<Event> get onAudioStart => audioStartEvent.forTarget(this);

  @DomName('SpeechRecognition.onend')
  @DocsEditable
  Stream<Event> get onEnd => endEvent.forTarget(this);

  @DomName('SpeechRecognition.onerror')
  @DocsEditable
  Stream<SpeechRecognitionError> get onError => errorEvent.forTarget(this);

  @DomName('SpeechRecognition.onnomatch')
  @DocsEditable
  Stream<SpeechRecognitionEvent> get onNoMatch => noMatchEvent.forTarget(this);

  @DomName('SpeechRecognition.onresult')
  @DocsEditable
  Stream<SpeechRecognitionEvent> get onResult => resultEvent.forTarget(this);

  @DomName('SpeechRecognition.onsoundend')
  @DocsEditable
  Stream<Event> get onSoundEnd => soundEndEvent.forTarget(this);

  @DomName('SpeechRecognition.onsoundstart')
  @DocsEditable
  Stream<Event> get onSoundStart => soundStartEvent.forTarget(this);

  @DomName('SpeechRecognition.onspeechend')
  @DocsEditable
  Stream<Event> get onSpeechEnd => speechEndEvent.forTarget(this);

  @DomName('SpeechRecognition.onspeechstart')
  @DocsEditable
  Stream<Event> get onSpeechStart => speechStartEvent.forTarget(this);

  @DomName('SpeechRecognition.onstart')
  @DocsEditable
  Stream<Event> get onStart => startEvent.forTarget(this);

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('SpeechRecognitionAlternative')
@SupportedBrowser(SupportedBrowser.CHROME, '25')
@Experimental
class SpeechRecognitionAlternative extends NativeFieldWrapperClass1 {
  SpeechRecognitionAlternative.internal();

  @DomName('SpeechRecognitionAlternative.confidence')
  @DocsEditable
  num get confidence native "SpeechRecognitionAlternative_confidence_Getter";

  @DomName('SpeechRecognitionAlternative.transcript')
  @DocsEditable
  String get transcript native "SpeechRecognitionAlternative_transcript_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('SpeechRecognitionError')
@SupportedBrowser(SupportedBrowser.CHROME, '25')
@Experimental
class SpeechRecognitionError extends Event {
  SpeechRecognitionError.internal() : super.internal();

  @DomName('SpeechRecognitionError.error')
  @DocsEditable
  String get error native "SpeechRecognitionError_error_Getter";

  @DomName('SpeechRecognitionError.message')
  @DocsEditable
  String get message native "SpeechRecognitionError_message_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('SpeechRecognitionEvent')
@SupportedBrowser(SupportedBrowser.CHROME, '25')
@Experimental
class SpeechRecognitionEvent extends Event {
  SpeechRecognitionEvent.internal() : super.internal();

  @DomName('SpeechRecognitionEvent.emma')
  @DocsEditable
  Document get emma native "SpeechRecognitionEvent_emma_Getter";

  @DomName('SpeechRecognitionEvent.interpretation')
  @DocsEditable
  Document get interpretation native "SpeechRecognitionEvent_interpretation_Getter";

  @DomName('SpeechRecognitionEvent.resultIndex')
  @DocsEditable
  int get resultIndex native "SpeechRecognitionEvent_resultIndex_Getter";

  @DomName('SpeechRecognitionEvent.results')
  @DocsEditable
  List<SpeechRecognitionResult> get results native "SpeechRecognitionEvent_results_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('SpeechRecognitionResult')
@SupportedBrowser(SupportedBrowser.CHROME, '25')
@Experimental
class SpeechRecognitionResult extends NativeFieldWrapperClass1 {
  SpeechRecognitionResult.internal();

  @DomName('SpeechRecognitionResult.isFinal')
  @DocsEditable
  bool get isFinal native "SpeechRecognitionResult_isFinal_Getter";

  @DomName('SpeechRecognitionResult.length')
  @DocsEditable
  int get length native "SpeechRecognitionResult_length_Getter";

  @DomName('SpeechRecognitionResult.item')
  @DocsEditable
  SpeechRecognitionAlternative item(int index) native "SpeechRecognitionResult_item_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/**
 * The type used by the
 * [Window.localStorage] and [Window.sessionStorage] properties.
 * Storage is implemented as a Map&lt;String, String>.
 *
 * To store and get values, use Dart's built-in map syntax:
 *
 *     window.localStorage['key1'] = 'val1';
 *     window.localStorage['key2'] = 'val2';
 *     window.localStorage['key3'] = 'val3';
 *     assert(window.localStorage['key3'] == 'val3');
 *
 * You can use [Map](http://api.dartlang.org/dart_core/Map.html) APIs
 * such as containsValue(), clear(), and length:
 *
 *     assert(window.localStorage.containsValue('does not exist') == false);
 *     window.localStorage.clear();
 *     assert(window.localStorage.length == 0);
 *
 * For more examples of using this API, see
 * [localstorage_test.dart](http://code.google.com/p/dart/source/browse/branches/bleeding_edge/dart/tests/html/localstorage_test.dart).
 * For details on using the Map API, see the
 * [Maps](http://www.dartlang.org/docs/library-tour/#maps-aka-dictionaries-or-hashes)
 * section of the library tour.
 */
@DomName('Storage')
class Storage extends NativeFieldWrapperClass1 implements Map<String, String>
     {

  // TODO(nweiz): update this when maps support lazy iteration
  bool containsValue(String value) => values.any((e) => e == value);

  bool containsKey(String key) => $dom_getItem(key) != null;

  String operator [](String key) => $dom_getItem(key);

  void operator []=(String key, String value) { $dom_setItem(key, value); }

  String putIfAbsent(String key, String ifAbsent()) {
    if (!containsKey(key)) this[key] = ifAbsent();
    return this[key];
  }

  String remove(String key) {
    final value = this[key];
    $dom_removeItem(key);
    return value;
  }

  void clear() => $dom_clear();

  void forEach(void f(String key, String value)) {
    for (var i = 0; true; i++) {
      final key = $dom_key(i);
      if (key == null) return;

      f(key, this[key]);
    }
  }

  Iterable<String> get keys {
    final keys = [];
    forEach((k, v) => keys.add(k));
    return keys;
  }

  Iterable<String> get values {
    final values = [];
    forEach((k, v) => values.add(v));
    return values;
  }

  int get length => $dom_length;

  bool get isEmpty => $dom_key(0) == null;
  Storage.internal();

  @DomName('Storage.length')
  @DocsEditable
  int get $dom_length native "Storage_length_Getter";

  @DomName('Storage.clear')
  @DocsEditable
  void $dom_clear() native "Storage_clear_Callback";

  @DomName('Storage.getItem')
  @DocsEditable
  String $dom_getItem(String key) native "Storage_getItem_Callback";

  @DomName('Storage.key')
  @DocsEditable
  String $dom_key(int index) native "Storage_key_Callback";

  @DomName('Storage.removeItem')
  @DocsEditable
  void $dom_removeItem(String key) native "Storage_removeItem_Callback";

  @DomName('Storage.setItem')
  @DocsEditable
  void $dom_setItem(String key, String data) native "Storage_setItem_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


typedef void StorageErrorCallback(DomException error);
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DomName('StorageEvent')
class StorageEvent extends Event {
  factory StorageEvent(String type,
    {bool canBubble: false, bool cancelable: false, String key, String oldValue,
    String newValue, String url, Storage storageArea}) {

    var e = document.$dom_createEvent("StorageEvent");
    e.$dom_initStorageEvent(type, canBubble, cancelable, key, oldValue,
        newValue, url, storageArea);
    return e;
  }
  StorageEvent.internal() : super.internal();

  @DomName('StorageEvent.key')
  @DocsEditable
  String get key native "StorageEvent_key_Getter";

  @DomName('StorageEvent.newValue')
  @DocsEditable
  String get newValue native "StorageEvent_newValue_Getter";

  @DomName('StorageEvent.oldValue')
  @DocsEditable
  String get oldValue native "StorageEvent_oldValue_Getter";

  @DomName('StorageEvent.storageArea')
  @DocsEditable
  Storage get storageArea native "StorageEvent_storageArea_Getter";

  @DomName('StorageEvent.url')
  @DocsEditable
  String get url native "StorageEvent_url_Getter";

  @DomName('StorageEvent.initStorageEvent')
  @DocsEditable
  void $dom_initStorageEvent(String typeArg, bool canBubbleArg, bool cancelableArg, String keyArg, String oldValueArg, String newValueArg, String urlArg, Storage storageAreaArg) native "StorageEvent_initStorageEvent_Callback";

}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('StorageInfo')
class StorageInfo extends NativeFieldWrapperClass1 {
  StorageInfo.internal();

  @DomName('StorageInfo.PERSISTENT')
  @DocsEditable
  static const int PERSISTENT = 1;

  @DomName('StorageInfo.TEMPORARY')
  @DocsEditable
  static const int TEMPORARY = 0;

  @DomName('StorageInfo.queryUsageAndQuota')
  @DocsEditable
  void _queryUsageAndQuota(int storageType, [StorageUsageCallback usageCallback, StorageErrorCallback errorCallback]) native "StorageInfo_queryUsageAndQuota_Callback";

  @DomName('StorageInfo.requestQuota')
  @DocsEditable
  void _requestQuota(int storageType, int newQuotaInBytes, [StorageQuotaCallback quotaCallback, StorageErrorCallback errorCallback]) native "StorageInfo_requestQuota_Callback";

  Future<int> requestQuota(int storageType, int newQuotaInBytes) {
    var completer = new Completer<int>();
    _requestQuota(storageType, newQuotaInBytes,
        (value) { completer.complete(value); },
        (error) { completer.completeError(error); });
    return completer.future;
  }

  Future<StorageInfoUsage> queryUsageAndQuota(int storageType) {
    var completer = new Completer<StorageInfoUsage>();
    _queryUsageAndQuota(storageType,
        (currentUsageInBytes, currentQuotaInBytes) { 
          completer.complete(new StorageInfoUsage(currentUsageInBytes, 
              currentQuotaInBytes));
        },
        (error) { completer.completeError(error); });
    return completer.future;
  }
}

/** 
 * A simple container class for the two values that are returned from the
 * futures in requestQuota and queryUsageAndQuota.
 */
class StorageInfoUsage {
  final int currentUsageInBytes;
  final int currentQuotaInBytes;
  const StorageInfoUsage(this.currentUsageInBytes, this.currentQuotaInBytes);
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('StorageQuota')
class StorageQuota extends NativeFieldWrapperClass1 {
  StorageQuota.internal();

  @DomName('StorageQuota.queryUsageAndQuota')
  @DocsEditable
  void queryUsageAndQuota(StorageUsageCallback usageCallback, [StorageErrorCallback errorCallback]) native "StorageQuota_queryUsageAndQuota_Callback";

  @DomName('StorageQuota.requestQuota')
  @DocsEditable
  void requestQuota(int newQuotaInBytes, [StorageQuotaCallback quotaCallback, StorageErrorCallback errorCallback]) native "StorageQuota_requestQuota_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


typedef void StorageQuotaCallback(int grantedQuotaInBytes);
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


typedef void StorageUsageCallback(int currentUsageInBytes, int currentQuotaInBytes);
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


typedef void _StringCallback(String data);
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLStyleElement')
class StyleElement extends _Element_Merged {
  StyleElement.internal() : super.internal();

  @DomName('HTMLStyleElement.HTMLStyleElement')
  @DocsEditable
  factory StyleElement() => document.$dom_createElement("style");

  @DomName('HTMLStyleElement.disabled')
  @DocsEditable
  bool get disabled native "HTMLStyleElement_disabled_Getter";

  @DomName('HTMLStyleElement.disabled')
  @DocsEditable
  void set disabled(bool value) native "HTMLStyleElement_disabled_Setter";

  @DomName('HTMLStyleElement.media')
  @DocsEditable
  String get media native "HTMLStyleElement_media_Getter";

  @DomName('HTMLStyleElement.media')
  @DocsEditable
  void set media(String value) native "HTMLStyleElement_media_Setter";

  @DomName('HTMLStyleElement.scoped')
  @DocsEditable
  bool get scoped native "HTMLStyleElement_scoped_Getter";

  @DomName('HTMLStyleElement.scoped')
  @DocsEditable
  void set scoped(bool value) native "HTMLStyleElement_scoped_Setter";

  @DomName('HTMLStyleElement.sheet')
  @DocsEditable
  StyleSheet get sheet native "HTMLStyleElement_sheet_Getter";

  @DomName('HTMLStyleElement.type')
  @DocsEditable
  String get type native "HTMLStyleElement_type_Getter";

  @DomName('HTMLStyleElement.type')
  @DocsEditable
  void set type(String value) native "HTMLStyleElement_type_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('StyleMedia')
class StyleMedia extends NativeFieldWrapperClass1 {
  StyleMedia.internal();

  @DomName('StyleMedia.type')
  @DocsEditable
  String get type native "StyleMedia_type_Getter";

  @DomName('StyleMedia.matchMedium')
  @DocsEditable
  bool matchMedium(String mediaquery) native "StyleMedia_matchMedium_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('StyleSheet')
class StyleSheet extends NativeFieldWrapperClass1 {
  StyleSheet.internal();

  @DomName('StyleSheet.disabled')
  @DocsEditable
  bool get disabled native "StyleSheet_disabled_Getter";

  @DomName('StyleSheet.disabled')
  @DocsEditable
  void set disabled(bool value) native "StyleSheet_disabled_Setter";

  @DomName('StyleSheet.href')
  @DocsEditable
  String get href native "StyleSheet_href_Getter";

  @DomName('StyleSheet.media')
  @DocsEditable
  MediaList get media native "StyleSheet_media_Getter";

  @DomName('StyleSheet.ownerNode')
  @DocsEditable
  Node get ownerNode native "StyleSheet_ownerNode_Getter";

  @DomName('StyleSheet.parentStyleSheet')
  @DocsEditable
  StyleSheet get parentStyleSheet native "StyleSheet_parentStyleSheet_Getter";

  @DomName('StyleSheet.title')
  @DocsEditable
  String get title native "StyleSheet_title_Getter";

  @DomName('StyleSheet.type')
  @DocsEditable
  String get type native "StyleSheet_type_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLTableCaptionElement')
class TableCaptionElement extends _Element_Merged {
  TableCaptionElement.internal() : super.internal();

  @DomName('HTMLTableCaptionElement.HTMLTableCaptionElement')
  @DocsEditable
  factory TableCaptionElement() => document.$dom_createElement("caption");

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLTableCellElement')
class TableCellElement extends _Element_Merged {
  TableCellElement.internal() : super.internal();

  @DomName('HTMLTableCellElement.HTMLTableCellElement')
  @DocsEditable
  factory TableCellElement() => document.$dom_createElement("td");

  @DomName('HTMLTableCellElement.cellIndex')
  @DocsEditable
  int get cellIndex native "HTMLTableCellElement_cellIndex_Getter";

  @DomName('HTMLTableCellElement.colSpan')
  @DocsEditable
  int get colSpan native "HTMLTableCellElement_colSpan_Getter";

  @DomName('HTMLTableCellElement.colSpan')
  @DocsEditable
  void set colSpan(int value) native "HTMLTableCellElement_colSpan_Setter";

  @DomName('HTMLTableCellElement.headers')
  @DocsEditable
  String get headers native "HTMLTableCellElement_headers_Getter";

  @DomName('HTMLTableCellElement.headers')
  @DocsEditable
  void set headers(String value) native "HTMLTableCellElement_headers_Setter";

  @DomName('HTMLTableCellElement.rowSpan')
  @DocsEditable
  int get rowSpan native "HTMLTableCellElement_rowSpan_Getter";

  @DomName('HTMLTableCellElement.rowSpan')
  @DocsEditable
  void set rowSpan(int value) native "HTMLTableCellElement_rowSpan_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLTableColElement')
class TableColElement extends _Element_Merged {
  TableColElement.internal() : super.internal();

  @DomName('HTMLTableColElement.HTMLTableColElement')
  @DocsEditable
  factory TableColElement() => document.$dom_createElement("col");

  @DomName('HTMLTableColElement.span')
  @DocsEditable
  int get span native "HTMLTableColElement_span_Getter";

  @DomName('HTMLTableColElement.span')
  @DocsEditable
  void set span(int value) native "HTMLTableColElement_span_Setter";

}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DocsEditable
@DomName('HTMLTableElement')
class TableElement extends _Element_Merged {

  @DomName('HTMLTableElement.tBodies')
  List<TableSectionElement> get tBodies =>
  new _WrappedList<TableSectionElement>($dom_tBodies);

  @DomName('HTMLTableElement.rows')
  List<TableRowElement> get rows =>
      new _WrappedList<TableRowElement>($dom_rows);

  TableRowElement addRow() {
    return insertRow(-1);
  }

  TableCaptionElement createCaption() => $dom_createCaption();
  TableSectionElement createTBody() => $dom_createTBody();
  TableSectionElement createTFoot() => $dom_createTFoot();
  TableSectionElement createTHead() => $dom_createTHead();
  TableRowElement insertRow(int index) => $dom_insertRow(index);


  TableElement.internal() : super.internal();

  @DomName('HTMLTableElement.HTMLTableElement')
  @DocsEditable
  factory TableElement() => document.$dom_createElement("table");

  @DomName('HTMLTableElement.border')
  @DocsEditable
  String get border native "HTMLTableElement_border_Getter";

  @DomName('HTMLTableElement.border')
  @DocsEditable
  void set border(String value) native "HTMLTableElement_border_Setter";

  @DomName('HTMLTableElement.caption')
  @DocsEditable
  TableCaptionElement get caption native "HTMLTableElement_caption_Getter";

  @DomName('HTMLTableElement.caption')
  @DocsEditable
  void set caption(TableCaptionElement value) native "HTMLTableElement_caption_Setter";

  @DomName('HTMLTableElement.rows')
  @DocsEditable
  HtmlCollection get $dom_rows native "HTMLTableElement_rows_Getter";

  @DomName('HTMLTableElement.tBodies')
  @DocsEditable
  HtmlCollection get $dom_tBodies native "HTMLTableElement_tBodies_Getter";

  @DomName('HTMLTableElement.tFoot')
  @DocsEditable
  TableSectionElement get tFoot native "HTMLTableElement_tFoot_Getter";

  @DomName('HTMLTableElement.tFoot')
  @DocsEditable
  void set tFoot(TableSectionElement value) native "HTMLTableElement_tFoot_Setter";

  @DomName('HTMLTableElement.tHead')
  @DocsEditable
  TableSectionElement get tHead native "HTMLTableElement_tHead_Getter";

  @DomName('HTMLTableElement.tHead')
  @DocsEditable
  void set tHead(TableSectionElement value) native "HTMLTableElement_tHead_Setter";

  @DomName('HTMLTableElement.createCaption')
  @DocsEditable
  Element $dom_createCaption() native "HTMLTableElement_createCaption_Callback";

  @DomName('HTMLTableElement.createTBody')
  @DocsEditable
  Element $dom_createTBody() native "HTMLTableElement_createTBody_Callback";

  @DomName('HTMLTableElement.createTFoot')
  @DocsEditable
  Element $dom_createTFoot() native "HTMLTableElement_createTFoot_Callback";

  @DomName('HTMLTableElement.createTHead')
  @DocsEditable
  Element $dom_createTHead() native "HTMLTableElement_createTHead_Callback";

  @DomName('HTMLTableElement.deleteCaption')
  @DocsEditable
  void deleteCaption() native "HTMLTableElement_deleteCaption_Callback";

  @DomName('HTMLTableElement.deleteRow')
  @DocsEditable
  void deleteRow(int index) native "HTMLTableElement_deleteRow_Callback";

  @DomName('HTMLTableElement.deleteTFoot')
  @DocsEditable
  void deleteTFoot() native "HTMLTableElement_deleteTFoot_Callback";

  @DomName('HTMLTableElement.deleteTHead')
  @DocsEditable
  void deleteTHead() native "HTMLTableElement_deleteTHead_Callback";

  @DomName('HTMLTableElement.insertRow')
  @DocsEditable
  Element $dom_insertRow(int index) native "HTMLTableElement_insertRow_Callback";
}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DocsEditable
@DomName('HTMLTableRowElement')
class TableRowElement extends _Element_Merged {

  @DomName('HTMLTableRowElement.cells')
  List<TableCellElement> get cells =>
      new _WrappedList<TableCellElement>($dom_cells);

  TableCellElement addCell() {
    return insertCell(-1);
  }

  TableCellElement insertCell(int index) => $dom_insertCell(index);

  TableRowElement.internal() : super.internal();

  @DomName('HTMLTableRowElement.HTMLTableRowElement')
  @DocsEditable
  factory TableRowElement() => document.$dom_createElement("tr");

  @DomName('HTMLTableRowElement.cells')
  @DocsEditable
  HtmlCollection get $dom_cells native "HTMLTableRowElement_cells_Getter";

  @DomName('HTMLTableRowElement.rowIndex')
  @DocsEditable
  int get rowIndex native "HTMLTableRowElement_rowIndex_Getter";

  @DomName('HTMLTableRowElement.sectionRowIndex')
  @DocsEditable
  int get sectionRowIndex native "HTMLTableRowElement_sectionRowIndex_Getter";

  @DomName('HTMLTableRowElement.deleteCell')
  @DocsEditable
  void deleteCell(int index) native "HTMLTableRowElement_deleteCell_Callback";

  @DomName('HTMLTableRowElement.insertCell')
  @DocsEditable
  Element $dom_insertCell(int index) native "HTMLTableRowElement_insertCell_Callback";
}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DocsEditable
@DomName('HTMLTableSectionElement')
class TableSectionElement extends _Element_Merged {

  @DomName('HTMLTableSectionElement.rows')
  List<TableRowElement> get rows =>
    new _WrappedList<TableRowElement>($dom_rows);

  TableRowElement addRow() {
    return insertRow(-1);
  }

  TableRowElement insertRow(int index) => $dom_insertRow(index);

  TableSectionElement.internal() : super.internal();

  @DomName('HTMLTableSectionElement.rows')
  @DocsEditable
  HtmlCollection get $dom_rows native "HTMLTableSectionElement_rows_Getter";

  @DomName('HTMLTableSectionElement.deleteRow')
  @DocsEditable
  void deleteRow(int index) native "HTMLTableSectionElement_deleteRow_Callback";

  @DomName('HTMLTableSectionElement.insertRow')
  @DocsEditable
  Element $dom_insertRow(int index) native "HTMLTableSectionElement_insertRow_Callback";
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@Experimental
@DomName('HTMLTemplateElement')
@SupportedBrowser(SupportedBrowser.CHROME)
@Experimental
class TemplateElement extends _Element_Merged {
  TemplateElement.internal() : super.internal();

  @DomName('HTMLTemplateElement.HTMLTemplateElement')
  @DocsEditable
  factory TemplateElement() => document.$dom_createElement("template");

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('HTMLTemplateElement.content')
  @DocsEditable
  DocumentFragment get $dom_content native "HTMLTemplateElement_content_Getter";


  // For real TemplateElement use the actual DOM .content field instead of
  // our polyfilled expando.
  @Experimental
  DocumentFragment get content => $dom_content;

  static StreamController<DocumentFragment> _instanceCreated;

  /**
   * *Warning*: This is an implementation helper for Model-Driven Views and
   * should not be used in your code.
   *
   * This event is fired whenever a template is instantiated via
   * [createInstance].
   */
  // TODO(rafaelw): This is a hack, and is neccesary for the polyfill
  // because custom elements are not upgraded during clone()
  @Experimental
  static Stream<DocumentFragment> get instanceCreated {
    if (_instanceCreated == null) {
      _instanceCreated = new StreamController<DocumentFragment>();
    }
    return _instanceCreated.stream;
  }

  /**
   * Ensures proper API and content model for template elements.
   *
   * [instanceRef] can be used to set the [Element.ref] property of [template],
   * and use the ref's content will be used as source when createInstance() is
   * invoked.
   *
   * Returns true if this template was just decorated, or false if it was
   * already decorated.
   */
  @Experimental
  static bool decorate(Element template, [Element instanceRef]) {
    // == true check because it starts as a null field.
    if (template._templateIsDecorated == true) return false;

    template._templateIsDecorated = true;

    _injectStylesheet();

    // Create content
    if (template is! TemplateElement) {
      var doc = _Bindings._getTemplateContentsOwner(template.document);
      template._templateContent = doc.createDocumentFragment();
    }

    if (instanceRef != null) {
      template._templateInstanceRef = instanceRef;
      return true; // content is empty.
    }

    if (template is TemplateElement) {
      bootstrap(template.content);
    } else {
      _Bindings._liftNonNativeChildrenIntoContent(template);
    }

    return true;
  }

  /**
   * This used to decorate recursively all templates from a given node.
   *
   * By default [decorate] will be called on templates lazily when certain
   * properties such as [model] are accessed, but it can be run eagerly to
   * decorate an entire tree recursively.
   */
  // TODO(rafaelw): Review whether this is the right public API.
  @Experimental
  static void bootstrap(Node content) {
    _Bindings._bootstrapTemplatesRecursivelyFrom(content);
  }

  static bool _initStyles;

  static void _injectStylesheet() {
    if (_initStyles == true) return;
    _initStyles = true;

    var style = new StyleElement();
    style.text = r'''
template,
thead[template],
tbody[template],
tfoot[template],
th[template],
tr[template],
td[template],
caption[template],
colgroup[template],
col[template],
option[template] {
  display: none;
}''';
    document.head.append(style);
  }

  /**
   * A mapping of names to Custom Syntax objects. See [CustomBindingSyntax] for
   * more information.
   */
  @Experimental
  static Map<String, CustomBindingSyntax> syntax = {};
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DomName('Text')
class Text extends CharacterData {
  factory Text(String data) => _TextFactoryProvider.createText(data);
  Text.internal() : super.internal();

  @DomName('Text.webkitInsertionParent')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  Node get insertionParent native "Text_webkitInsertionParent_Getter";

  @DomName('Text.wholeText')
  @DocsEditable
  String get wholeText native "Text_wholeText_Getter";

  @DomName('Text.replaceWholeText')
  @DocsEditable
  Text replaceWholeText(String content) native "Text_replaceWholeText_Callback";

  @DomName('Text.splitText')
  @DocsEditable
  Text splitText(int offset) native "Text_splitText_Callback";


  StreamSubscription _textBinding;

  @Experimental
  void bind(String name, model, String path) {
    if (name != 'text') {
      super.bind(name, model, path);
      return;
    }

    unbind('text');

    _textBinding = new PathObserver(model, path).bindSync((value) {
      text = value == null ? '' : '$value';
    });
  }

  @Experimental
  void unbind(String name) {
    if (name != 'text') {
      super.unbind(name);
      return;
    }

    if (_textBinding == null) return;

    _textBinding.cancel();
    _textBinding = null;
  }

  @Experimental
  void unbindAll() {
    unbind('text');
    super.unbindAll();
  }
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLTextAreaElement')
class TextAreaElement extends _Element_Merged {
  TextAreaElement.internal() : super.internal();

  @DomName('HTMLTextAreaElement.HTMLTextAreaElement')
  @DocsEditable
  factory TextAreaElement() => document.$dom_createElement("textarea");

  @DomName('HTMLTextAreaElement.autofocus')
  @DocsEditable
  bool get autofocus native "HTMLTextAreaElement_autofocus_Getter";

  @DomName('HTMLTextAreaElement.autofocus')
  @DocsEditable
  void set autofocus(bool value) native "HTMLTextAreaElement_autofocus_Setter";

  @DomName('HTMLTextAreaElement.cols')
  @DocsEditable
  int get cols native "HTMLTextAreaElement_cols_Getter";

  @DomName('HTMLTextAreaElement.cols')
  @DocsEditable
  void set cols(int value) native "HTMLTextAreaElement_cols_Setter";

  @DomName('HTMLTextAreaElement.defaultValue')
  @DocsEditable
  String get defaultValue native "HTMLTextAreaElement_defaultValue_Getter";

  @DomName('HTMLTextAreaElement.defaultValue')
  @DocsEditable
  void set defaultValue(String value) native "HTMLTextAreaElement_defaultValue_Setter";

  @DomName('HTMLTextAreaElement.dirName')
  @DocsEditable
  String get dirName native "HTMLTextAreaElement_dirName_Getter";

  @DomName('HTMLTextAreaElement.dirName')
  @DocsEditable
  void set dirName(String value) native "HTMLTextAreaElement_dirName_Setter";

  @DomName('HTMLTextAreaElement.disabled')
  @DocsEditable
  bool get disabled native "HTMLTextAreaElement_disabled_Getter";

  @DomName('HTMLTextAreaElement.disabled')
  @DocsEditable
  void set disabled(bool value) native "HTMLTextAreaElement_disabled_Setter";

  @DomName('HTMLTextAreaElement.form')
  @DocsEditable
  FormElement get form native "HTMLTextAreaElement_form_Getter";

  @DomName('HTMLTextAreaElement.labels')
  @DocsEditable
  List<Node> get labels native "HTMLTextAreaElement_labels_Getter";

  @DomName('HTMLTextAreaElement.maxLength')
  @DocsEditable
  int get maxLength native "HTMLTextAreaElement_maxLength_Getter";

  @DomName('HTMLTextAreaElement.maxLength')
  @DocsEditable
  void set maxLength(int value) native "HTMLTextAreaElement_maxLength_Setter";

  @DomName('HTMLTextAreaElement.name')
  @DocsEditable
  String get name native "HTMLTextAreaElement_name_Getter";

  @DomName('HTMLTextAreaElement.name')
  @DocsEditable
  void set name(String value) native "HTMLTextAreaElement_name_Setter";

  @DomName('HTMLTextAreaElement.placeholder')
  @DocsEditable
  String get placeholder native "HTMLTextAreaElement_placeholder_Getter";

  @DomName('HTMLTextAreaElement.placeholder')
  @DocsEditable
  void set placeholder(String value) native "HTMLTextAreaElement_placeholder_Setter";

  @DomName('HTMLTextAreaElement.readOnly')
  @DocsEditable
  bool get readOnly native "HTMLTextAreaElement_readOnly_Getter";

  @DomName('HTMLTextAreaElement.readOnly')
  @DocsEditable
  void set readOnly(bool value) native "HTMLTextAreaElement_readOnly_Setter";

  @DomName('HTMLTextAreaElement.required')
  @DocsEditable
  bool get required native "HTMLTextAreaElement_required_Getter";

  @DomName('HTMLTextAreaElement.required')
  @DocsEditable
  void set required(bool value) native "HTMLTextAreaElement_required_Setter";

  @DomName('HTMLTextAreaElement.rows')
  @DocsEditable
  int get rows native "HTMLTextAreaElement_rows_Getter";

  @DomName('HTMLTextAreaElement.rows')
  @DocsEditable
  void set rows(int value) native "HTMLTextAreaElement_rows_Setter";

  @DomName('HTMLTextAreaElement.selectionDirection')
  @DocsEditable
  String get selectionDirection native "HTMLTextAreaElement_selectionDirection_Getter";

  @DomName('HTMLTextAreaElement.selectionDirection')
  @DocsEditable
  void set selectionDirection(String value) native "HTMLTextAreaElement_selectionDirection_Setter";

  @DomName('HTMLTextAreaElement.selectionEnd')
  @DocsEditable
  int get selectionEnd native "HTMLTextAreaElement_selectionEnd_Getter";

  @DomName('HTMLTextAreaElement.selectionEnd')
  @DocsEditable
  void set selectionEnd(int value) native "HTMLTextAreaElement_selectionEnd_Setter";

  @DomName('HTMLTextAreaElement.selectionStart')
  @DocsEditable
  int get selectionStart native "HTMLTextAreaElement_selectionStart_Getter";

  @DomName('HTMLTextAreaElement.selectionStart')
  @DocsEditable
  void set selectionStart(int value) native "HTMLTextAreaElement_selectionStart_Setter";

  @DomName('HTMLTextAreaElement.textLength')
  @DocsEditable
  int get textLength native "HTMLTextAreaElement_textLength_Getter";

  @DomName('HTMLTextAreaElement.type')
  @DocsEditable
  String get type native "HTMLTextAreaElement_type_Getter";

  @DomName('HTMLTextAreaElement.validationMessage')
  @DocsEditable
  String get validationMessage native "HTMLTextAreaElement_validationMessage_Getter";

  @DomName('HTMLTextAreaElement.validity')
  @DocsEditable
  ValidityState get validity native "HTMLTextAreaElement_validity_Getter";

  @DomName('HTMLTextAreaElement.value')
  @DocsEditable
  String get value native "HTMLTextAreaElement_value_Getter";

  @DomName('HTMLTextAreaElement.value')
  @DocsEditable
  void set value(String value) native "HTMLTextAreaElement_value_Setter";

  @DomName('HTMLTextAreaElement.willValidate')
  @DocsEditable
  bool get willValidate native "HTMLTextAreaElement_willValidate_Getter";

  @DomName('HTMLTextAreaElement.wrap')
  @DocsEditable
  String get wrap native "HTMLTextAreaElement_wrap_Getter";

  @DomName('HTMLTextAreaElement.wrap')
  @DocsEditable
  void set wrap(String value) native "HTMLTextAreaElement_wrap_Setter";

  @DomName('HTMLTextAreaElement.checkValidity')
  @DocsEditable
  bool checkValidity() native "HTMLTextAreaElement_checkValidity_Callback";

  @DomName('HTMLTextAreaElement.select')
  @DocsEditable
  void select() native "HTMLTextAreaElement_select_Callback";

  @DomName('HTMLTextAreaElement.setCustomValidity')
  @DocsEditable
  void setCustomValidity(String error) native "HTMLTextAreaElement_setCustomValidity_Callback";

  void setRangeText(String replacement, [int start, int end, String selectionMode]) {
    if ((replacement is String || replacement == null) && !?start && !?end && !?selectionMode) {
      _setRangeText_1(replacement);
      return;
    }
    if ((replacement is String || replacement == null) && (start is int || start == null) && (end is int || end == null) && (selectionMode is String || selectionMode == null)) {
      _setRangeText_2(replacement, start, end, selectionMode);
      return;
    }
    throw new ArgumentError("Incorrect number or type of arguments");
  }

  void _setRangeText_1(replacement) native "HTMLTextAreaElement__setRangeText_1_Callback";

  void _setRangeText_2(replacement, start, end, selectionMode) native "HTMLTextAreaElement__setRangeText_2_Callback";

  void setSelectionRange(int start, int end, [String direction]) {
    if (?direction) {
      _setSelectionRange_1(start, end, direction);
      return;
    }
    _setSelectionRange_2(start, end);
    return;
  }

  void _setSelectionRange_1(start, end, direction) native "HTMLTextAreaElement__setSelectionRange_1_Callback";

  void _setSelectionRange_2(start, end) native "HTMLTextAreaElement__setSelectionRange_2_Callback";

}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DomName('TextEvent')
class TextEvent extends UIEvent {
  factory TextEvent(String type,
    {bool canBubble: false, bool cancelable: false, Window view, String data}) {
    if (view == null) {
      view = window;
    }
    var e = document.$dom_createEvent("TextEvent");
    e.$dom_initTextEvent(type, canBubble, cancelable, view, data);
    return e;
  }
  TextEvent.internal() : super.internal();

  @DomName('TextEvent.data')
  @DocsEditable
  String get data native "TextEvent_data_Getter";

  @DomName('TextEvent.initTextEvent')
  @DocsEditable
  void $dom_initTextEvent(String typeArg, bool canBubbleArg, bool cancelableArg, Window viewArg, String dataArg) native "TextEvent_initTextEvent_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('TextMetrics')
class TextMetrics extends NativeFieldWrapperClass1 {
  TextMetrics.internal();

  @DomName('TextMetrics.width')
  @DocsEditable
  num get width native "TextMetrics_width_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('TextTrack')
class TextTrack extends EventTarget {
  TextTrack.internal() : super.internal();

  @DomName('TextTrack.cuechangeEvent')
  @DocsEditable
  static const EventStreamProvider<Event> cueChangeEvent = const EventStreamProvider<Event>('cuechange');

  @DomName('TextTrack.activeCues')
  @DocsEditable
  TextTrackCueList get activeCues native "TextTrack_activeCues_Getter";

  @DomName('TextTrack.cues')
  @DocsEditable
  TextTrackCueList get cues native "TextTrack_cues_Getter";

  @DomName('TextTrack.kind')
  @DocsEditable
  String get kind native "TextTrack_kind_Getter";

  @DomName('TextTrack.label')
  @DocsEditable
  String get label native "TextTrack_label_Getter";

  @DomName('TextTrack.language')
  @DocsEditable
  String get language native "TextTrack_language_Getter";

  @DomName('TextTrack.mode')
  @DocsEditable
  String get mode native "TextTrack_mode_Getter";

  @DomName('TextTrack.mode')
  @DocsEditable
  void set mode(String value) native "TextTrack_mode_Setter";

  @DomName('TextTrack.addCue')
  @DocsEditable
  void addCue(TextTrackCue cue) native "TextTrack_addCue_Callback";

  @DomName('TextTrack.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "TextTrack_addEventListener_Callback";

  @DomName('TextTrack.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event evt) native "TextTrack_dispatchEvent_Callback";

  @DomName('TextTrack.removeCue')
  @DocsEditable
  void removeCue(TextTrackCue cue) native "TextTrack_removeCue_Callback";

  @DomName('TextTrack.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "TextTrack_removeEventListener_Callback";

  @DomName('TextTrack.oncuechange')
  @DocsEditable
  Stream<Event> get onCueChange => cueChangeEvent.forTarget(this);

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('TextTrackCue')
class TextTrackCue extends EventTarget {
  TextTrackCue.internal() : super.internal();

  @DomName('TextTrackCue.enterEvent')
  @DocsEditable
  static const EventStreamProvider<Event> enterEvent = const EventStreamProvider<Event>('enter');

  @DomName('TextTrackCue.exitEvent')
  @DocsEditable
  static const EventStreamProvider<Event> exitEvent = const EventStreamProvider<Event>('exit');

  @DomName('TextTrackCue.TextTrackCue')
  @DocsEditable
  factory TextTrackCue(num startTime, num endTime, String text) {
    return TextTrackCue._create_1(startTime, endTime, text);
  }

  @DocsEditable
  static TextTrackCue _create_1(startTime, endTime, text) native "TextTrackCue__create_1constructorCallback";

  @DomName('TextTrackCue.align')
  @DocsEditable
  String get align native "TextTrackCue_align_Getter";

  @DomName('TextTrackCue.align')
  @DocsEditable
  void set align(String value) native "TextTrackCue_align_Setter";

  @DomName('TextTrackCue.endTime')
  @DocsEditable
  num get endTime native "TextTrackCue_endTime_Getter";

  @DomName('TextTrackCue.endTime')
  @DocsEditable
  void set endTime(num value) native "TextTrackCue_endTime_Setter";

  @DomName('TextTrackCue.id')
  @DocsEditable
  String get id native "TextTrackCue_id_Getter";

  @DomName('TextTrackCue.id')
  @DocsEditable
  void set id(String value) native "TextTrackCue_id_Setter";

  @DomName('TextTrackCue.line')
  @DocsEditable
  int get line native "TextTrackCue_line_Getter";

  @DomName('TextTrackCue.line')
  @DocsEditable
  void set line(int value) native "TextTrackCue_line_Setter";

  @DomName('TextTrackCue.pauseOnExit')
  @DocsEditable
  bool get pauseOnExit native "TextTrackCue_pauseOnExit_Getter";

  @DomName('TextTrackCue.pauseOnExit')
  @DocsEditable
  void set pauseOnExit(bool value) native "TextTrackCue_pauseOnExit_Setter";

  @DomName('TextTrackCue.position')
  @DocsEditable
  int get position native "TextTrackCue_position_Getter";

  @DomName('TextTrackCue.position')
  @DocsEditable
  void set position(int value) native "TextTrackCue_position_Setter";

  @DomName('TextTrackCue.size')
  @DocsEditable
  int get size native "TextTrackCue_size_Getter";

  @DomName('TextTrackCue.size')
  @DocsEditable
  void set size(int value) native "TextTrackCue_size_Setter";

  @DomName('TextTrackCue.snapToLines')
  @DocsEditable
  bool get snapToLines native "TextTrackCue_snapToLines_Getter";

  @DomName('TextTrackCue.snapToLines')
  @DocsEditable
  void set snapToLines(bool value) native "TextTrackCue_snapToLines_Setter";

  @DomName('TextTrackCue.startTime')
  @DocsEditable
  num get startTime native "TextTrackCue_startTime_Getter";

  @DomName('TextTrackCue.startTime')
  @DocsEditable
  void set startTime(num value) native "TextTrackCue_startTime_Setter";

  @DomName('TextTrackCue.text')
  @DocsEditable
  String get text native "TextTrackCue_text_Getter";

  @DomName('TextTrackCue.text')
  @DocsEditable
  void set text(String value) native "TextTrackCue_text_Setter";

  @DomName('TextTrackCue.track')
  @DocsEditable
  TextTrack get track native "TextTrackCue_track_Getter";

  @DomName('TextTrackCue.vertical')
  @DocsEditable
  String get vertical native "TextTrackCue_vertical_Getter";

  @DomName('TextTrackCue.vertical')
  @DocsEditable
  void set vertical(String value) native "TextTrackCue_vertical_Setter";

  @DomName('TextTrackCue.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "TextTrackCue_addEventListener_Callback";

  @DomName('TextTrackCue.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event evt) native "TextTrackCue_dispatchEvent_Callback";

  @DomName('TextTrackCue.getCueAsHTML')
  @DocsEditable
  DocumentFragment getCueAsHtml() native "TextTrackCue_getCueAsHTML_Callback";

  @DomName('TextTrackCue.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "TextTrackCue_removeEventListener_Callback";

  @DomName('TextTrackCue.onenter')
  @DocsEditable
  Stream<Event> get onEnter => enterEvent.forTarget(this);

  @DomName('TextTrackCue.onexit')
  @DocsEditable
  Stream<Event> get onExit => exitEvent.forTarget(this);

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('TextTrackCueList')
class TextTrackCueList extends NativeFieldWrapperClass1 with ListMixin<TextTrackCue>, ImmutableListMixin<TextTrackCue> implements List<TextTrackCue> {
  TextTrackCueList.internal();

  @DomName('TextTrackCueList.length')
  @DocsEditable
  int get length native "TextTrackCueList_length_Getter";

  TextTrackCue operator[](int index) {
    if (index < 0 || index >= length)
      throw new RangeError.range(index, 0, length);
    return _nativeIndexedGetter(index);
  }
  TextTrackCue _nativeIndexedGetter(int index) native "TextTrackCueList_item_Callback";

  void operator[]=(int index, TextTrackCue value) {
    throw new UnsupportedError("Cannot assign element of immutable List.");
  }
  // -- start List<TextTrackCue> mixins.
  // TextTrackCue is the element type.


  void set length(int value) {
    throw new UnsupportedError("Cannot resize immutable List.");
  }

  TextTrackCue get first {
    if (this.length > 0) {
      return this[0];
    }
    throw new StateError("No elements");
  }

  TextTrackCue get last {
    int len = this.length;
    if (len > 0) {
      return this[len - 1];
    }
    throw new StateError("No elements");
  }

  TextTrackCue get single {
    int len = this.length;
    if (len == 1) {
      return this[0];
    }
    if (len == 0) throw new StateError("No elements");
    throw new StateError("More than one element");
  }

  TextTrackCue elementAt(int index) => this[index];
  // -- end List<TextTrackCue> mixins.

  @DomName('TextTrackCueList.getCueById')
  @DocsEditable
  TextTrackCue getCueById(String id) native "TextTrackCueList_getCueById_Callback";

  @DomName('TextTrackCueList.item')
  @DocsEditable
  TextTrackCue item(int index) native "TextTrackCueList_item_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('TextTrackList')
class TextTrackList extends EventTarget with ListMixin<TextTrack>, ImmutableListMixin<TextTrack> implements List<TextTrack> {
  TextTrackList.internal() : super.internal();

  @DomName('TextTrackList.addtrackEvent')
  @DocsEditable
  static const EventStreamProvider<TrackEvent> addTrackEvent = const EventStreamProvider<TrackEvent>('addtrack');

  @DomName('TextTrackList.length')
  @DocsEditable
  int get length native "TextTrackList_length_Getter";

  TextTrack operator[](int index) {
    if (index < 0 || index >= length)
      throw new RangeError.range(index, 0, length);
    return _nativeIndexedGetter(index);
  }
  TextTrack _nativeIndexedGetter(int index) native "TextTrackList_item_Callback";

  void operator[]=(int index, TextTrack value) {
    throw new UnsupportedError("Cannot assign element of immutable List.");
  }
  // -- start List<TextTrack> mixins.
  // TextTrack is the element type.


  void set length(int value) {
    throw new UnsupportedError("Cannot resize immutable List.");
  }

  TextTrack get first {
    if (this.length > 0) {
      return this[0];
    }
    throw new StateError("No elements");
  }

  TextTrack get last {
    int len = this.length;
    if (len > 0) {
      return this[len - 1];
    }
    throw new StateError("No elements");
  }

  TextTrack get single {
    int len = this.length;
    if (len == 1) {
      return this[0];
    }
    if (len == 0) throw new StateError("No elements");
    throw new StateError("More than one element");
  }

  TextTrack elementAt(int index) => this[index];
  // -- end List<TextTrack> mixins.

  @DomName('TextTrackList.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "TextTrackList_addEventListener_Callback";

  @DomName('TextTrackList.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event evt) native "TextTrackList_dispatchEvent_Callback";

  @DomName('TextTrackList.item')
  @DocsEditable
  TextTrack item(int index) native "TextTrackList_item_Callback";

  @DomName('TextTrackList.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "TextTrackList_removeEventListener_Callback";

  @DomName('TextTrackList.onaddtrack')
  @DocsEditable
  Stream<TrackEvent> get onAddTrack => addTrackEvent.forTarget(this);

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('TimeRanges')
class TimeRanges extends NativeFieldWrapperClass1 {
  TimeRanges.internal();

  @DomName('TimeRanges.length')
  @DocsEditable
  int get length native "TimeRanges_length_Getter";

  @DomName('TimeRanges.end')
  @DocsEditable
  num end(int index) native "TimeRanges_end_Callback";

  @DomName('TimeRanges.start')
  @DocsEditable
  num start(int index) native "TimeRanges_start_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


typedef void TimeoutHandler();
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLTitleElement')
class TitleElement extends _Element_Merged {
  TitleElement.internal() : super.internal();

  @DomName('HTMLTitleElement.HTMLTitleElement')
  @DocsEditable
  factory TitleElement() => document.$dom_createElement("title");

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DocsEditable
@DomName('Touch')
class Touch extends NativeFieldWrapperClass1 {
  Touch.internal();

  @DomName('Touch.clientX')
  @DocsEditable
  int get $dom_clientX native "Touch_clientX_Getter";

  @DomName('Touch.clientY')
  @DocsEditable
  int get $dom_clientY native "Touch_clientY_Getter";

  @DomName('Touch.identifier')
  @DocsEditable
  int get identifier native "Touch_identifier_Getter";

  @DomName('Touch.pageX')
  @DocsEditable
  int get $dom_pageX native "Touch_pageX_Getter";

  @DomName('Touch.pageY')
  @DocsEditable
  int get $dom_pageY native "Touch_pageY_Getter";

  @DomName('Touch.screenX')
  @DocsEditable
  int get $dom_screenX native "Touch_screenX_Getter";

  @DomName('Touch.screenY')
  @DocsEditable
  int get $dom_screenY native "Touch_screenY_Getter";

  @DomName('Touch.target')
  @DocsEditable
  EventTarget get target native "Touch_target_Getter";

  @DomName('Touch.webkitForce')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  num get force native "Touch_webkitForce_Getter";

  @DomName('Touch.webkitRadiusX')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  int get radiusX native "Touch_webkitRadiusX_Getter";

  @DomName('Touch.webkitRadiusY')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  int get radiusY native "Touch_webkitRadiusY_Getter";

  @DomName('Touch.webkitRotationAngle')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  num get rotationAngle native "Touch_webkitRotationAngle_Getter";


  @DomName('Touch.clientX')
  @DomName('Touch.clientY')
  Point get client => new Point($dom_clientX, $dom_clientY);

  @DomName('Touch.pageX')
  @DomName('Touch.pageY')
  Point get page => new Point($dom_pageX, $dom_pageY);

  @DomName('Touch.screenX')
  @DomName('Touch.screenY')
  Point get screen => new Point($dom_screenX, $dom_screenY);
}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DomName('TouchEvent')
class TouchEvent extends UIEvent {
  factory TouchEvent(TouchList touches, TouchList targetTouches,
      TouchList changedTouches, String type,
      {Window view, int screenX: 0, int screenY: 0, int clientX: 0,
      int clientY: 0, bool ctrlKey: false, bool altKey: false,
      bool shiftKey: false, bool metaKey: false}) {
    if (view == null) {
      view = window;
    }
    var e = document.$dom_createEvent("TouchEvent");
    e.$dom_initTouchEvent(touches, targetTouches, changedTouches, type, view,
        screenX, screenY, clientX, clientY, ctrlKey, altKey, shiftKey, metaKey);
    return e;
  }
  TouchEvent.internal() : super.internal();

  @DomName('TouchEvent.altKey')
  @DocsEditable
  bool get altKey native "TouchEvent_altKey_Getter";

  @DomName('TouchEvent.changedTouches')
  @DocsEditable
  TouchList get changedTouches native "TouchEvent_changedTouches_Getter";

  @DomName('TouchEvent.ctrlKey')
  @DocsEditable
  bool get ctrlKey native "TouchEvent_ctrlKey_Getter";

  @DomName('TouchEvent.metaKey')
  @DocsEditable
  bool get metaKey native "TouchEvent_metaKey_Getter";

  @DomName('TouchEvent.shiftKey')
  @DocsEditable
  bool get shiftKey native "TouchEvent_shiftKey_Getter";

  @DomName('TouchEvent.targetTouches')
  @DocsEditable
  TouchList get targetTouches native "TouchEvent_targetTouches_Getter";

  @DomName('TouchEvent.touches')
  @DocsEditable
  TouchList get touches native "TouchEvent_touches_Getter";

  @DomName('TouchEvent.initTouchEvent')
  @DocsEditable
  void $dom_initTouchEvent(TouchList touches, TouchList targetTouches, TouchList changedTouches, String type, Window view, int screenX, int screenY, int clientX, int clientY, bool ctrlKey, bool altKey, bool shiftKey, bool metaKey) native "TouchEvent_initTouchEvent_Callback";


  /**
   * Checks if touch events supported on the current platform.
   *
   * Note that touch events are only supported if the user is using a touch
   * device.
   */
  static bool get supported {
    // Bug #8186 add equivalent 'ontouchstart' check for Dartium.
    // Basically, this is a fairly common check and it'd be great if it did not
    // throw exceptions.
    return Device.isEventTypeSupported('TouchEvent');
  }
}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DomName('TouchList')
class TouchList extends NativeFieldWrapperClass1 with ListMixin<Touch>, ImmutableListMixin<Touch> implements List<Touch> {
  /// NB: This constructor likely does not work as you might expect it to! This
  /// constructor will simply fail (returning null) if you are not on a device
  /// with touch enabled. See dartbug.com/8314.
  factory TouchList() => document.$dom_createTouchList();
  TouchList.internal();

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('TouchList.length')
  @DocsEditable
  int get length native "TouchList_length_Getter";

  Touch operator[](int index) {
    if (index < 0 || index >= length)
      throw new RangeError.range(index, 0, length);
    return _nativeIndexedGetter(index);
  }
  Touch _nativeIndexedGetter(int index) native "TouchList_item_Callback";

  void operator[]=(int index, Touch value) {
    throw new UnsupportedError("Cannot assign element of immutable List.");
  }
  // -- start List<Touch> mixins.
  // Touch is the element type.


  void set length(int value) {
    throw new UnsupportedError("Cannot resize immutable List.");
  }

  Touch get first {
    if (this.length > 0) {
      return this[0];
    }
    throw new StateError("No elements");
  }

  Touch get last {
    int len = this.length;
    if (len > 0) {
      return this[len - 1];
    }
    throw new StateError("No elements");
  }

  Touch get single {
    int len = this.length;
    if (len == 1) {
      return this[0];
    }
    if (len == 0) throw new StateError("No elements");
    throw new StateError("More than one element");
  }

  Touch elementAt(int index) => this[index];
  // -- end List<Touch> mixins.

  @DomName('TouchList.item')
  @DocsEditable
  Touch item(int index) native "TouchList_item_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLTrackElement')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.IE, '10')
@SupportedBrowser(SupportedBrowser.SAFARI)
class TrackElement extends _Element_Merged {
  TrackElement.internal() : super.internal();

  @DomName('HTMLTrackElement.HTMLTrackElement')
  @DocsEditable
  factory TrackElement() => document.$dom_createElement("track");

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('HTMLTrackElement.ERROR')
  @DocsEditable
  static const int ERROR = 3;

  @DomName('HTMLTrackElement.LOADED')
  @DocsEditable
  static const int LOADED = 2;

  @DomName('HTMLTrackElement.LOADING')
  @DocsEditable
  static const int LOADING = 1;

  @DomName('HTMLTrackElement.NONE')
  @DocsEditable
  static const int NONE = 0;

  @DomName('HTMLTrackElement.default')
  @DocsEditable
  bool get defaultValue native "HTMLTrackElement_default_Getter";

  @DomName('HTMLTrackElement.default')
  @DocsEditable
  void set defaultValue(bool value) native "HTMLTrackElement_default_Setter";

  @DomName('HTMLTrackElement.kind')
  @DocsEditable
  String get kind native "HTMLTrackElement_kind_Getter";

  @DomName('HTMLTrackElement.kind')
  @DocsEditable
  void set kind(String value) native "HTMLTrackElement_kind_Setter";

  @DomName('HTMLTrackElement.label')
  @DocsEditable
  String get label native "HTMLTrackElement_label_Getter";

  @DomName('HTMLTrackElement.label')
  @DocsEditable
  void set label(String value) native "HTMLTrackElement_label_Setter";

  @DomName('HTMLTrackElement.readyState')
  @DocsEditable
  int get readyState native "HTMLTrackElement_readyState_Getter";

  @DomName('HTMLTrackElement.src')
  @DocsEditable
  String get src native "HTMLTrackElement_src_Getter";

  @DomName('HTMLTrackElement.src')
  @DocsEditable
  void set src(String value) native "HTMLTrackElement_src_Setter";

  @DomName('HTMLTrackElement.srclang')
  @DocsEditable
  String get srclang native "HTMLTrackElement_srclang_Getter";

  @DomName('HTMLTrackElement.srclang')
  @DocsEditable
  void set srclang(String value) native "HTMLTrackElement_srclang_Setter";

  @DomName('HTMLTrackElement.track')
  @DocsEditable
  TextTrack get track native "HTMLTrackElement_track_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('TrackEvent')
class TrackEvent extends Event {
  TrackEvent.internal() : super.internal();

  @DomName('TrackEvent.track')
  @DocsEditable
  Object get track native "TrackEvent_track_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('TransitionEvent')
class TransitionEvent extends Event {
  TransitionEvent.internal() : super.internal();

  @DomName('TransitionEvent.elapsedTime')
  @DocsEditable
  num get elapsedTime native "TransitionEvent_elapsedTime_Getter";

  @DomName('TransitionEvent.propertyName')
  @DocsEditable
  String get propertyName native "TransitionEvent_propertyName_Getter";

  @DomName('TransitionEvent.pseudoElement')
  @DocsEditable
  String get pseudoElement native "TransitionEvent_pseudoElement_Getter";

}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('TreeWalker')
class TreeWalker extends NativeFieldWrapperClass1 {
  factory TreeWalker(Node root, int whatToShow) {
    return document.$dom_createTreeWalker(root, whatToShow, null, false);
  }
  TreeWalker.internal();

  @DomName('TreeWalker.currentNode')
  @DocsEditable
  Node get currentNode native "TreeWalker_currentNode_Getter";

  @DomName('TreeWalker.currentNode')
  @DocsEditable
  void set currentNode(Node value) native "TreeWalker_currentNode_Setter";

  @DomName('TreeWalker.expandEntityReferences')
  @DocsEditable
  bool get expandEntityReferences native "TreeWalker_expandEntityReferences_Getter";

  @DomName('TreeWalker.filter')
  @DocsEditable
  NodeFilter get filter native "TreeWalker_filter_Getter";

  @DomName('TreeWalker.root')
  @DocsEditable
  Node get root native "TreeWalker_root_Getter";

  @DomName('TreeWalker.whatToShow')
  @DocsEditable
  int get whatToShow native "TreeWalker_whatToShow_Getter";

  @DomName('TreeWalker.firstChild')
  @DocsEditable
  Node firstChild() native "TreeWalker_firstChild_Callback";

  @DomName('TreeWalker.lastChild')
  @DocsEditable
  Node lastChild() native "TreeWalker_lastChild_Callback";

  @DomName('TreeWalker.nextNode')
  @DocsEditable
  Node nextNode() native "TreeWalker_nextNode_Callback";

  @DomName('TreeWalker.nextSibling')
  @DocsEditable
  Node nextSibling() native "TreeWalker_nextSibling_Callback";

  @DomName('TreeWalker.parentNode')
  @DocsEditable
  Node parentNode() native "TreeWalker_parentNode_Callback";

  @DomName('TreeWalker.previousNode')
  @DocsEditable
  Node previousNode() native "TreeWalker_previousNode_Callback";

  @DomName('TreeWalker.previousSibling')
  @DocsEditable
  Node previousSibling() native "TreeWalker_previousSibling_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DomName('UIEvent')
class UIEvent extends Event {
  // In JS, canBubble and cancelable are technically required parameters to
  // init*Event. In practice, though, if they aren't provided they simply
  // default to false (since that's Boolean(undefined)).
  //
  // Contrary to JS, we default canBubble and cancelable to true, since that's
  // what people want most of the time anyway.
  factory UIEvent(String type,
      {Window view, int detail: 0, bool canBubble: true,
      bool cancelable: true}) {
    if (view == null) {
      view = window;
    }
    final e = document.$dom_createEvent("UIEvent");
    e.$dom_initUIEvent(type, canBubble, cancelable, view, detail);
    return e;
  }
  UIEvent.internal() : super.internal();

  @DomName('UIEvent.charCode')
  @DocsEditable
  int get $dom_charCode native "UIEvent_charCode_Getter";

  @DomName('UIEvent.detail')
  @DocsEditable
  int get detail native "UIEvent_detail_Getter";

  @DomName('UIEvent.keyCode')
  @DocsEditable
  int get $dom_keyCode native "UIEvent_keyCode_Getter";

  @DomName('UIEvent.layerX')
  @DocsEditable
  int get $dom_layerX native "UIEvent_layerX_Getter";

  @DomName('UIEvent.layerY')
  @DocsEditable
  int get $dom_layerY native "UIEvent_layerY_Getter";

  @DomName('UIEvent.pageX')
  @DocsEditable
  int get $dom_pageX native "UIEvent_pageX_Getter";

  @DomName('UIEvent.pageY')
  @DocsEditable
  int get $dom_pageY native "UIEvent_pageY_Getter";

  @DomName('UIEvent.view')
  @DocsEditable
  WindowBase get view native "UIEvent_view_Getter";

  @DomName('UIEvent.which')
  @DocsEditable
  int get which native "UIEvent_which_Getter";

  @DomName('UIEvent.initUIEvent')
  @DocsEditable
  void $dom_initUIEvent(String type, bool canBubble, bool cancelable, Window view, int detail) native "UIEvent_initUIEvent_Callback";


  @deprecated
  int get layerX => layer.x;
  @deprecated
  int get layerY => layer.y;

  @deprecated
  int get pageX => page.x;
  @deprecated
  int get pageY => page.y;

  @DomName('UIEvent.layerX')
  @DomName('UIEvent.layerY')
  Point get layer => new Point($dom_layerX, $dom_layerY);

  @DomName('UIEvent.pageX')
  @DomName('UIEvent.pageY')
  Point get page => new Point($dom_pageX, $dom_pageY);
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLUListElement')
class UListElement extends _Element_Merged {
  UListElement.internal() : super.internal();

  @DomName('HTMLUListElement.HTMLUListElement')
  @DocsEditable
  factory UListElement() => document.$dom_createElement("ul");

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLUnknownElement')
class UnknownElement extends _Element_Merged {
  UnknownElement.internal() : super.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('URL')
class Url extends NativeFieldWrapperClass1 {
  Url.internal();

  static String createObjectUrl(blob_OR_source_OR_stream) {
    if ((blob_OR_source_OR_stream is MediaSource || blob_OR_source_OR_stream == null)) {
      return _createObjectURL_1(blob_OR_source_OR_stream);
    }
    if ((blob_OR_source_OR_stream is MediaStream || blob_OR_source_OR_stream == null)) {
      return _createObjectURL_2(blob_OR_source_OR_stream);
    }
    if ((blob_OR_source_OR_stream is Blob || blob_OR_source_OR_stream == null)) {
      return _createObjectURL_3(blob_OR_source_OR_stream);
    }
    throw new ArgumentError("Incorrect number or type of arguments");
  }

  static String _createObjectURL_1(blob_OR_source_OR_stream) native "DOMURL__createObjectURL_1_Callback";

  static String _createObjectURL_2(blob_OR_source_OR_stream) native "DOMURL__createObjectURL_2_Callback";

  static String _createObjectURL_3(blob_OR_source_OR_stream) native "DOMURL__createObjectURL_3_Callback";

  @DomName('URL.revokeObjectURL')
  @DocsEditable
  static void revokeObjectUrl(String url) native "DOMURL_revokeObjectURL_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('ValidityState')
class ValidityState extends NativeFieldWrapperClass1 {
  ValidityState.internal();

  @DomName('ValidityState.badInput')
  @DocsEditable
  bool get badInput native "ValidityState_badInput_Getter";

  @DomName('ValidityState.customError')
  @DocsEditable
  bool get customError native "ValidityState_customError_Getter";

  @DomName('ValidityState.patternMismatch')
  @DocsEditable
  bool get patternMismatch native "ValidityState_patternMismatch_Getter";

  @DomName('ValidityState.rangeOverflow')
  @DocsEditable
  bool get rangeOverflow native "ValidityState_rangeOverflow_Getter";

  @DomName('ValidityState.rangeUnderflow')
  @DocsEditable
  bool get rangeUnderflow native "ValidityState_rangeUnderflow_Getter";

  @DomName('ValidityState.stepMismatch')
  @DocsEditable
  bool get stepMismatch native "ValidityState_stepMismatch_Getter";

  @DomName('ValidityState.tooLong')
  @DocsEditable
  bool get tooLong native "ValidityState_tooLong_Getter";

  @DomName('ValidityState.typeMismatch')
  @DocsEditable
  bool get typeMismatch native "ValidityState_typeMismatch_Getter";

  @DomName('ValidityState.valid')
  @DocsEditable
  bool get valid native "ValidityState_valid_Getter";

  @DomName('ValidityState.valueMissing')
  @DocsEditable
  bool get valueMissing native "ValidityState_valueMissing_Getter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('HTMLVideoElement')
class VideoElement extends MediaElement implements CanvasImageSource {
  VideoElement.internal() : super.internal();

  @DomName('HTMLVideoElement.HTMLVideoElement')
  @DocsEditable
  factory VideoElement() => document.$dom_createElement("video");

  @DomName('HTMLVideoElement.height')
  @DocsEditable
  int get height native "HTMLVideoElement_height_Getter";

  @DomName('HTMLVideoElement.height')
  @DocsEditable
  void set height(int value) native "HTMLVideoElement_height_Setter";

  @DomName('HTMLVideoElement.poster')
  @DocsEditable
  String get poster native "HTMLVideoElement_poster_Getter";

  @DomName('HTMLVideoElement.poster')
  @DocsEditable
  void set poster(String value) native "HTMLVideoElement_poster_Setter";

  @DomName('HTMLVideoElement.videoHeight')
  @DocsEditable
  int get videoHeight native "HTMLVideoElement_videoHeight_Getter";

  @DomName('HTMLVideoElement.videoWidth')
  @DocsEditable
  int get videoWidth native "HTMLVideoElement_videoWidth_Getter";

  @DomName('HTMLVideoElement.webkitDecodedFrameCount')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  int get decodedFrameCount native "HTMLVideoElement_webkitDecodedFrameCount_Getter";

  @DomName('HTMLVideoElement.webkitDisplayingFullscreen')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  bool get displayingFullscreen native "HTMLVideoElement_webkitDisplayingFullscreen_Getter";

  @DomName('HTMLVideoElement.webkitDroppedFrameCount')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  int get droppedFrameCount native "HTMLVideoElement_webkitDroppedFrameCount_Getter";

  @DomName('HTMLVideoElement.webkitSupportsFullscreen')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  bool get supportsFullscreen native "HTMLVideoElement_webkitSupportsFullscreen_Getter";

  @DomName('HTMLVideoElement.width')
  @DocsEditable
  int get width native "HTMLVideoElement_width_Getter";

  @DomName('HTMLVideoElement.width')
  @DocsEditable
  void set width(int value) native "HTMLVideoElement_width_Setter";

  @DomName('HTMLVideoElement.webkitEnterFullScreen')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void enterFullScreen() native "HTMLVideoElement_webkitEnterFullScreen_Callback";

  @DomName('HTMLVideoElement.webkitEnterFullscreen')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void enterFullscreen() native "HTMLVideoElement_webkitEnterFullscreen_Callback";

  @DomName('HTMLVideoElement.webkitExitFullScreen')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void exitFullScreen() native "HTMLVideoElement_webkitExitFullScreen_Callback";

  @DomName('HTMLVideoElement.webkitExitFullscreen')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void exitFullscreen() native "HTMLVideoElement_webkitExitFullscreen_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


typedef void VoidCallback();
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
/**
 * Use the WebSocket interface to connect to a WebSocket,
 * and to send and receive data on that WebSocket.
 *
 * To use a WebSocket in your web app, first create a WebSocket object,
 * passing the WebSocket URL as an argument to the constructor.
 *
 *     var webSocket = new WebSocket('ws://127.0.0.1:1337/ws');
 *
 * To send data on the WebSocket, use the [send] method.
 *
 *     if (webSocket != null && webSocket.readyState == WebSocket.OPEN) {
 *       webSocket.send(data);
 *     } else {
 *       print('WebSocket not connected, message $data not sent');
 *     }
 *
 * To receive data on the WebSocket, register a listener for message events.
 *
 *     webSocket.on.message.add((MessageEvent e) {
 *       receivedData(e.data);
 *     });
 *
 * The message event handler receives a [MessageEvent] object
 * as its sole argument.
 * You can also define open, close, and error handlers,
 * as specified by [WebSocketEvents].
 *
 * For more information, see the
 * [WebSockets](http://www.dartlang.org/docs/library-tour/#html-websockets)
 * section of the library tour and
 * [Introducing WebSockets](http://www.html5rocks.com/en/tutorials/websockets/basics/),
 * an HTML5Rocks.com tutorial.
 */
@DomName('WebSocket')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.FIREFOX)
@SupportedBrowser(SupportedBrowser.IE, '10')
@SupportedBrowser(SupportedBrowser.SAFARI)
class WebSocket extends EventTarget {
  WebSocket.internal() : super.internal();

  @DomName('WebSocket.closeEvent')
  @DocsEditable
  static const EventStreamProvider<CloseEvent> closeEvent = const EventStreamProvider<CloseEvent>('close');

  @DomName('WebSocket.errorEvent')
  @DocsEditable
  static const EventStreamProvider<Event> errorEvent = const EventStreamProvider<Event>('error');

  @DomName('WebSocket.messageEvent')
  @DocsEditable
  static const EventStreamProvider<MessageEvent> messageEvent = const EventStreamProvider<MessageEvent>('message');

  @DomName('WebSocket.openEvent')
  @DocsEditable
  static const EventStreamProvider<Event> openEvent = const EventStreamProvider<Event>('open');

  @DomName('WebSocket.WebSocket')
  @DocsEditable
  factory WebSocket(String url, [protocol_OR_protocols]) {
    if ((url is String || url == null) && !?protocol_OR_protocols) {
      return WebSocket._create_1(url);
    }
    if ((url is String || url == null) && (protocol_OR_protocols is List<String> || protocol_OR_protocols == null)) {
      return WebSocket._create_2(url, protocol_OR_protocols);
    }
    if ((url is String || url == null) && (protocol_OR_protocols is String || protocol_OR_protocols == null)) {
      return WebSocket._create_3(url, protocol_OR_protocols);
    }
    throw new ArgumentError("Incorrect number or type of arguments");
  }

  @DocsEditable
  static WebSocket _create_1(url) native "WebSocket__create_1constructorCallback";

  @DocsEditable
  static WebSocket _create_2(url, protocol_OR_protocols) native "WebSocket__create_2constructorCallback";

  @DocsEditable
  static WebSocket _create_3(url, protocol_OR_protocols) native "WebSocket__create_3constructorCallback";

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('WebSocket.CLOSED')
  @DocsEditable
  static const int CLOSED = 3;

  @DomName('WebSocket.CLOSING')
  @DocsEditable
  static const int CLOSING = 2;

  @DomName('WebSocket.CONNECTING')
  @DocsEditable
  static const int CONNECTING = 0;

  @DomName('WebSocket.OPEN')
  @DocsEditable
  static const int OPEN = 1;

  @DomName('WebSocket.URL')
  @DocsEditable
  String get Url native "WebSocket_URL_Getter";

  @DomName('WebSocket.binaryType')
  @DocsEditable
  String get binaryType native "WebSocket_binaryType_Getter";

  @DomName('WebSocket.binaryType')
  @DocsEditable
  void set binaryType(String value) native "WebSocket_binaryType_Setter";

  @DomName('WebSocket.bufferedAmount')
  @DocsEditable
  int get bufferedAmount native "WebSocket_bufferedAmount_Getter";

  @DomName('WebSocket.extensions')
  @DocsEditable
  String get extensions native "WebSocket_extensions_Getter";

  @DomName('WebSocket.protocol')
  @DocsEditable
  String get protocol native "WebSocket_protocol_Getter";

  @DomName('WebSocket.readyState')
  @DocsEditable
  int get readyState native "WebSocket_readyState_Getter";

  @DomName('WebSocket.url')
  @DocsEditable
  String get url native "WebSocket_url_Getter";

  @DomName('WebSocket.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "WebSocket_addEventListener_Callback";

  void close([int code, String reason]) {
    if (?reason) {
      _close_1(code, reason);
      return;
    }
    if (?code) {
      _close_2(code);
      return;
    }
    _close_3();
    return;
  }

  void _close_1(code, reason) native "WebSocket__close_1_Callback";

  void _close_2(code) native "WebSocket__close_2_Callback";

  void _close_3() native "WebSocket__close_3_Callback";

  @DomName('WebSocket.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event evt) native "WebSocket_dispatchEvent_Callback";

  @DomName('WebSocket.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "WebSocket_removeEventListener_Callback";

  @DomName('WebSocket.send')
  @DocsEditable
  void send(data) native "WebSocket_send_Callback";

  @DomName('WebSocket.onclose')
  @DocsEditable
  Stream<CloseEvent> get onClose => closeEvent.forTarget(this);

  @DomName('WebSocket.onerror')
  @DocsEditable
  Stream<Event> get onError => errorEvent.forTarget(this);

  @DomName('WebSocket.onmessage')
  @DocsEditable
  Stream<MessageEvent> get onMessage => messageEvent.forTarget(this);

  @DomName('WebSocket.onopen')
  @DocsEditable
  Stream<Event> get onOpen => openEvent.forTarget(this);

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('WheelEvent')
class WheelEvent extends MouseEvent {

  factory WheelEvent(String type,
      {Window view, int deltaX: 0, int deltaY: 0,
      int detail: 0, int screenX: 0, int screenY: 0, int clientX: 0,
      int clientY: 0, int button: 0, bool canBubble: true,
      bool cancelable: true, bool ctrlKey: false, bool altKey: false,
      bool shiftKey: false, bool metaKey: false, EventTarget relatedTarget}) {

    if (view == null) {
      view = window;
    }
    var eventType = 'WheelEvent';
    if (Device.isFirefox) {
      eventType = 'MouseScrollEvents';
    }
    final event = document.$dom_createEvent(eventType);
    // Dartium always needs these flipped because we're essentially always
    // polyfilling (see similar dart2js code as well)
    deltaX = -deltaX;
    deltaY = -deltaY;
      // Fallthrough for Dartium.
      event.$dom_initMouseEvent(type, canBubble, cancelable, view, detail,
          screenX, screenY, clientX, clientY, ctrlKey, altKey, shiftKey,
          metaKey, button, relatedTarget);
      event.$dom_initWebKitWheelEvent(deltaX,
          deltaY ~/ 120, // Chrome does an auto-convert to pixels.
          view, screenX, screenY, clientX, clientY, ctrlKey, altKey, shiftKey,
          metaKey);

    return event;
  }

  WheelEvent.internal() : super.internal();

  @DomName('WheelEvent.DOM_DELTA_LINE')
  @DocsEditable
  static const int DOM_DELTA_LINE = 0x01;

  @DomName('WheelEvent.DOM_DELTA_PAGE')
  @DocsEditable
  static const int DOM_DELTA_PAGE = 0x02;

  @DomName('WheelEvent.DOM_DELTA_PIXEL')
  @DocsEditable
  static const int DOM_DELTA_PIXEL = 0x00;

  @DomName('WheelEvent.deltaMode')
  @DocsEditable
  int get deltaMode native "WheelEvent_deltaMode_Getter";

  @DomName('WheelEvent.webkitDirectionInvertedFromDevice')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  bool get directionInvertedFromDevice native "WheelEvent_webkitDirectionInvertedFromDevice_Getter";

  @DomName('WheelEvent.wheelDeltaX')
  @DocsEditable
  int get $dom_wheelDeltaX native "WheelEvent_wheelDeltaX_Getter";

  @DomName('WheelEvent.wheelDeltaY')
  @DocsEditable
  int get $dom_wheelDeltaY native "WheelEvent_wheelDeltaY_Getter";

  @DomName('WheelEvent.initWebKitWheelEvent')
  @DocsEditable
  void $dom_initWebKitWheelEvent(int wheelDeltaX, int wheelDeltaY, Window view, int screenX, int screenY, int clientX, int clientY, bool ctrlKey, bool altKey, bool shiftKey, bool metaKey) native "WheelEvent_initWebKitWheelEvent_Callback";


  /**
   * The amount that is expected to scroll horizontally, in units determined by
   * [deltaMode].
   *
   * See also:
   *
   * * [WheelEvent.deltaX](http://dev.w3.org/2006/webapi/DOM-Level-3-Events/html/DOM3-Events.html#events-WheelEvent-deltaX) from the W3C.
   */
  @DomName('WheelEvent.deltaX')
  num get deltaX => -$dom_wheelDeltaX;

  /**
   * The amount that is expected to scroll vertically, in units determined by
   * [deltaMode].
   *
   * See also:
   *
   * * [WheelEvent.deltaY](http://dev.w3.org/2006/webapi/DOM-Level-3-Events/html/DOM3-Events.html#events-WheelEvent-deltaY) from the W3C.
   */
  @DomName('WheelEvent.deltaY')
  num get deltaY => -$dom_wheelDeltaY;
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('Window')
class Window extends EventTarget implements WindowBase {

  /**
   * Executes a [callback] after the immediate execution stack has completed.
   *
   * This differs from using Timer.run(callback)
   * because Timer will run in about 4-15 milliseconds, depending on browser,
   * depending on load. [setImmediate], in contrast, makes browser-specific
   * changes in behavior to attempt to run immediately after the current
   * frame unwinds, causing the future to complete after all processing has
   * completed for the current event, but before any subsequent events.
   */
  void setImmediate(TimeoutHandler callback) {
    _addMicrotaskCallback(callback);
  }
  /**
   * Lookup a port by its [name].  Return null if no port is
   * registered under [name].
   */
  SendPortSync lookupPort(String name) {
    var portStr = document.documentElement.attributes['dart-port:$name'];
    if (portStr == null) {
      return null;
    }
    var port = json.parse(portStr);
    return _deserialize(port);
  }

  /**
   * Register a [port] on this window under the given [name].  This
   * port may be retrieved by any isolate (or JavaScript script)
   * running in this window.
   */
  void registerPort(String name, var port) {
    var serialized = _serialize(port);
    document.documentElement.attributes['dart-port:$name'] =
        json.stringify(serialized);
  }

  /**
   * Returns a Future that completes just before the window is about to repaint
   * so the user can draw an animation frame
   *
   * If you need to later cancel this animation, use [requestAnimationFrame]
   * instead.
   *
   * Note: The code that runs when the future completes should call
   * [animationFrame] again for the animation to continue.
   */
  Future<num> get animationFrame {
    var completer = new Completer<num>();
    requestAnimationFrame((time) {
      completer.complete(time);
    });
    return completer.future;
  }

  /// Checks if _setImmediate is supported.
  static bool get _supportsSetImmediate => false;

  /// Dartium stub for IE's setImmediate.
  void _setImmediate(void callback()) {
    throw new UnsupportedError('setImmediate is not supported');
  }

  /**
   * Access a sandboxed file system of the specified `size`. If `persistent` is
   * true, the application will request permission from the user to create
   * lasting storage. This storage cannot be freed without the user's
   * permission. Returns a [Future] whose value stores a reference to the
   * sandboxed file system for use. Because the file system is sandboxed,
   * applications cannot access file systems created in other web pages.
   */
  Future<FileSystem> requestFileSystem(int size, {bool persistent: false}) {
    return _requestFileSystem(persistent? 1 : 0, size);
  }

  @DomName('DOMWindow.convertPointFromNodeToPage')
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  Point convertPointFromNodeToPage(Node node, Point point) {
    var result = _convertPointFromNodeToPage(node,
        new _DomPoint(point.x, point.y));
    return new Point(result.x, result.y);
  }

  @DomName('DOMWindow.convertPointFromPageToNode')
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  Point convertPointFromPageToNode(Node node, Point point) {
    var result = _convertPointFromPageToNode(node,
        new _DomPoint(point.x, point.y));
    return new Point(result.x, result.y);
  }

  /**
   * Checks whether [convertPointFromNodeToPage] and
   * [convertPointFromPageToNode] are supported on the current platform.
   */
  static bool get supportsPointConversions => _DomPoint.supported;
  Window.internal() : super.internal();

  @DomName('Window.DOMContentLoadedEvent')
  @DocsEditable
  static const EventStreamProvider<Event> contentLoadedEvent = const EventStreamProvider<Event>('DOMContentLoaded');

  @DomName('Window.devicemotionEvent')
  @DocsEditable
  static const EventStreamProvider<DeviceMotionEvent> deviceMotionEvent = const EventStreamProvider<DeviceMotionEvent>('devicemotion');

  @DomName('Window.deviceorientationEvent')
  @DocsEditable
  static const EventStreamProvider<DeviceOrientationEvent> deviceOrientationEvent = const EventStreamProvider<DeviceOrientationEvent>('deviceorientation');

  @DomName('Window.hashchangeEvent')
  @DocsEditable
  static const EventStreamProvider<Event> hashChangeEvent = const EventStreamProvider<Event>('hashchange');

  @DomName('Window.messageEvent')
  @DocsEditable
  static const EventStreamProvider<MessageEvent> messageEvent = const EventStreamProvider<MessageEvent>('message');

  @DomName('Window.offlineEvent')
  @DocsEditable
  static const EventStreamProvider<Event> offlineEvent = const EventStreamProvider<Event>('offline');

  @DomName('Window.onlineEvent')
  @DocsEditable
  static const EventStreamProvider<Event> onlineEvent = const EventStreamProvider<Event>('online');

  @DomName('Window.pagehideEvent')
  @DocsEditable
  static const EventStreamProvider<Event> pageHideEvent = const EventStreamProvider<Event>('pagehide');

  @DomName('Window.pageshowEvent')
  @DocsEditable
  static const EventStreamProvider<Event> pageShowEvent = const EventStreamProvider<Event>('pageshow');

  @DomName('Window.popstateEvent')
  @DocsEditable
  static const EventStreamProvider<PopStateEvent> popStateEvent = const EventStreamProvider<PopStateEvent>('popstate');

  @DomName('Window.resizeEvent')
  @DocsEditable
  static const EventStreamProvider<Event> resizeEvent = const EventStreamProvider<Event>('resize');

  @DomName('Window.storageEvent')
  @DocsEditable
  static const EventStreamProvider<StorageEvent> storageEvent = const EventStreamProvider<StorageEvent>('storage');

  @DomName('Window.unloadEvent')
  @DocsEditable
  static const EventStreamProvider<Event> unloadEvent = const EventStreamProvider<Event>('unload');

  @DomName('Window.webkitAnimationEndEvent')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  static const EventStreamProvider<AnimationEvent> animationEndEvent = const EventStreamProvider<AnimationEvent>('webkitAnimationEnd');

  @DomName('Window.webkitAnimationIterationEvent')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  static const EventStreamProvider<AnimationEvent> animationIterationEvent = const EventStreamProvider<AnimationEvent>('webkitAnimationIteration');

  @DomName('Window.webkitAnimationStartEvent')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  static const EventStreamProvider<AnimationEvent> animationStartEvent = const EventStreamProvider<AnimationEvent>('webkitAnimationStart');

  @DomName('Window.PERSISTENT')
  @DocsEditable
  static const int PERSISTENT = 1;

  @DomName('Window.TEMPORARY')
  @DocsEditable
  static const int TEMPORARY = 0;

  @DomName('Window.applicationCache')
  @DocsEditable
  ApplicationCache get applicationCache native "DOMWindow_applicationCache_Getter";

  @DomName('Window.closed')
  @DocsEditable
  bool get closed native "DOMWindow_closed_Getter";

  @DomName('Window.console')
  @DocsEditable
  Console get console native "DOMWindow_console_Getter";

  @DomName('Window.crypto')
  @DocsEditable
  Crypto get crypto native "DOMWindow_crypto_Getter";

  @DomName('Window.defaultStatus')
  @DocsEditable
  String get defaultStatus native "DOMWindow_defaultStatus_Getter";

  @DomName('Window.defaultStatus')
  @DocsEditable
  void set defaultStatus(String value) native "DOMWindow_defaultStatus_Setter";

  @DomName('Window.defaultstatus')
  @DocsEditable
  String get defaultstatus native "DOMWindow_defaultstatus_Getter";

  @DomName('Window.defaultstatus')
  @DocsEditable
  void set defaultstatus(String value) native "DOMWindow_defaultstatus_Setter";

  @DomName('Window.devicePixelRatio')
  @DocsEditable
  num get devicePixelRatio native "DOMWindow_devicePixelRatio_Getter";

  @DomName('Window.document')
  @DocsEditable
  Document get document native "DOMWindow_document_Getter";

  @DomName('Window.event')
  @DocsEditable
  Event get event native "DOMWindow_event_Getter";

  @DomName('Window.history')
  @DocsEditable
  History get history native "DOMWindow_history_Getter";

  @DomName('Window.indexedDB')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.FIREFOX, '15')
  @SupportedBrowser(SupportedBrowser.IE, '10')
  @Experimental
  IdbFactory get indexedDB native "DOMWindow_indexedDB_Getter";

  @DomName('Window.innerHeight')
  @DocsEditable
  int get innerHeight native "DOMWindow_innerHeight_Getter";

  @DomName('Window.innerWidth')
  @DocsEditable
  int get innerWidth native "DOMWindow_innerWidth_Getter";

  @DomName('Window.localStorage')
  @DocsEditable
  Storage get localStorage native "DOMWindow_localStorage_Getter";

  @DomName('Window.location')
  @DocsEditable
  Location get location native "DOMWindow_location_Getter";

  @DomName('Window.location')
  @DocsEditable
  void set location(Location value) native "DOMWindow_location_Setter";

  @DomName('Window.locationbar')
  @DocsEditable
  BarInfo get locationbar native "DOMWindow_locationbar_Getter";

  @DomName('Window.menubar')
  @DocsEditable
  BarInfo get menubar native "DOMWindow_menubar_Getter";

  @DomName('Window.name')
  @DocsEditable
  String get name native "DOMWindow_name_Getter";

  @DomName('Window.name')
  @DocsEditable
  void set name(String value) native "DOMWindow_name_Setter";

  @DomName('Window.navigator')
  @DocsEditable
  Navigator get navigator native "DOMWindow_navigator_Getter";

  @DomName('Window.offscreenBuffering')
  @DocsEditable
  bool get offscreenBuffering native "DOMWindow_offscreenBuffering_Getter";

  @DomName('Window.opener')
  @DocsEditable
  WindowBase get opener native "DOMWindow_opener_Getter";

  @DomName('Window.outerHeight')
  @DocsEditable
  int get outerHeight native "DOMWindow_outerHeight_Getter";

  @DomName('Window.outerWidth')
  @DocsEditable
  int get outerWidth native "DOMWindow_outerWidth_Getter";

  @DomName('Window.pageXOffset')
  @DocsEditable
  int get pageXOffset native "DOMWindow_pageXOffset_Getter";

  @DomName('Window.pageYOffset')
  @DocsEditable
  int get pageYOffset native "DOMWindow_pageYOffset_Getter";

  @DomName('Window.parent')
  @DocsEditable
  WindowBase get parent native "DOMWindow_parent_Getter";

  @DomName('Window.performance')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.FIREFOX)
  @SupportedBrowser(SupportedBrowser.IE)
  Performance get performance native "DOMWindow_performance_Getter";

  @DomName('Window.personalbar')
  @DocsEditable
  BarInfo get personalbar native "DOMWindow_personalbar_Getter";

  @DomName('Window.screen')
  @DocsEditable
  Screen get screen native "DOMWindow_screen_Getter";

  @DomName('Window.screenLeft')
  @DocsEditable
  int get screenLeft native "DOMWindow_screenLeft_Getter";

  @DomName('Window.screenTop')
  @DocsEditable
  int get screenTop native "DOMWindow_screenTop_Getter";

  @DomName('Window.screenX')
  @DocsEditable
  int get screenX native "DOMWindow_screenX_Getter";

  @DomName('Window.screenY')
  @DocsEditable
  int get screenY native "DOMWindow_screenY_Getter";

  @DomName('Window.scrollX')
  @DocsEditable
  int get scrollX native "DOMWindow_scrollX_Getter";

  @DomName('Window.scrollY')
  @DocsEditable
  int get scrollY native "DOMWindow_scrollY_Getter";

  @DomName('Window.scrollbars')
  @DocsEditable
  BarInfo get scrollbars native "DOMWindow_scrollbars_Getter";

  @DomName('Window.self')
  @DocsEditable
  WindowBase get self native "DOMWindow_self_Getter";

  @DomName('Window.sessionStorage')
  @DocsEditable
  Storage get sessionStorage native "DOMWindow_sessionStorage_Getter";

  @DomName('Window.status')
  @DocsEditable
  String get status native "DOMWindow_status_Getter";

  @DomName('Window.status')
  @DocsEditable
  void set status(String value) native "DOMWindow_status_Setter";

  @DomName('Window.statusbar')
  @DocsEditable
  BarInfo get statusbar native "DOMWindow_statusbar_Getter";

  @DomName('Window.styleMedia')
  @DocsEditable
  StyleMedia get styleMedia native "DOMWindow_styleMedia_Getter";

  @DomName('Window.toolbar')
  @DocsEditable
  BarInfo get toolbar native "DOMWindow_toolbar_Getter";

  @DomName('Window.top')
  @DocsEditable
  WindowBase get top native "DOMWindow_top_Getter";

  @DomName('Window.webkitNotifications')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  NotificationCenter get notifications native "DOMWindow_webkitNotifications_Getter";

  @DomName('Window.webkitStorageInfo')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  StorageInfo get storageInfo native "DOMWindow_webkitStorageInfo_Getter";

  @DomName('Window.window')
  @DocsEditable
  WindowBase get window native "DOMWindow_window_Getter";

  @DomName('Window.addEventListener')
  @DocsEditable
  void $dom_addEventListener(String type, EventListener listener, [bool useCapture]) native "DOMWindow_addEventListener_Callback";

  @DomName('Window.alert')
  @DocsEditable
  void alert(String message) native "DOMWindow_alert_Callback";

  @DomName('Window.atob')
  @DocsEditable
  String atob(String string) native "DOMWindow_atob_Callback";

  @DomName('Window.btoa')
  @DocsEditable
  String btoa(String string) native "DOMWindow_btoa_Callback";

  @DomName('Window.cancelAnimationFrame')
  @DocsEditable
  void cancelAnimationFrame(int id) native "DOMWindow_cancelAnimationFrame_Callback";

  @DomName('Window.captureEvents')
  @DocsEditable
  void captureEvents() native "DOMWindow_captureEvents_Callback";

  @DomName('Window.clearInterval')
  @DocsEditable
  void _clearInterval(int handle) native "DOMWindow_clearInterval_Callback";

  @DomName('Window.clearTimeout')
  @DocsEditable
  void _clearTimeout(int handle) native "DOMWindow_clearTimeout_Callback";

  @DomName('Window.close')
  @DocsEditable
  void close() native "DOMWindow_close_Callback";

  @DomName('Window.confirm')
  @DocsEditable
  bool confirm(String message) native "DOMWindow_confirm_Callback";

  @DomName('Window.dispatchEvent')
  @DocsEditable
  bool dispatchEvent(Event evt) native "DOMWindow_dispatchEvent_Callback";

  @DomName('Window.find')
  @DocsEditable
  bool find(String string, bool caseSensitive, bool backwards, bool wrap, bool wholeWord, bool searchInFrames, bool showDialog) native "DOMWindow_find_Callback";

  @DomName('Window.getComputedStyle')
  @DocsEditable
  CssStyleDeclaration $dom_getComputedStyle(Element element, String pseudoElement) native "DOMWindow_getComputedStyle_Callback";

  @DomName('Window.getMatchedCSSRules')
  @DocsEditable
  List<CssRule> getMatchedCssRules(Element element, String pseudoElement) native "DOMWindow_getMatchedCSSRules_Callback";

  @DomName('Window.getSelection')
  @DocsEditable
  Selection getSelection() native "DOMWindow_getSelection_Callback";

  @DomName('Window.matchMedia')
  @DocsEditable
  MediaQueryList matchMedia(String query) native "DOMWindow_matchMedia_Callback";

  @DomName('Window.moveBy')
  @DocsEditable
  void moveBy(num x, num y) native "DOMWindow_moveBy_Callback";

  @DomName('Window.moveTo')
  @DocsEditable
  void moveTo(num x, num y) native "DOMWindow_moveTo_Callback";

  @DomName('Window.open')
  @DocsEditable
  WindowBase open(String url, String name, [String options]) native "DOMWindow_open_Callback";

  @DomName('Window.openDatabase')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  SqlDatabase openDatabase(String name, String version, String displayName, int estimatedSize, [DatabaseCallback creationCallback]) native "DOMWindow_openDatabase_Callback";

  @DomName('Window.postMessage')
  @DocsEditable
  void postMessage(/*SerializedScriptValue*/ message, String targetOrigin, [List messagePorts]) native "DOMWindow_postMessage_Callback";

  @DomName('Window.print')
  @DocsEditable
  void print() native "DOMWindow_print_Callback";

  @DomName('Window.releaseEvents')
  @DocsEditable
  void releaseEvents() native "DOMWindow_releaseEvents_Callback";

  @DomName('Window.removeEventListener')
  @DocsEditable
  void $dom_removeEventListener(String type, EventListener listener, [bool useCapture]) native "DOMWindow_removeEventListener_Callback";

  @DomName('Window.requestAnimationFrame')
  @DocsEditable
  int requestAnimationFrame(RequestAnimationFrameCallback callback) native "DOMWindow_requestAnimationFrame_Callback";

  @DomName('Window.resizeBy')
  @DocsEditable
  void resizeBy(num x, num y) native "DOMWindow_resizeBy_Callback";

  @DomName('Window.resizeTo')
  @DocsEditable
  void resizeTo(num width, num height) native "DOMWindow_resizeTo_Callback";

  @DomName('Window.scroll')
  @DocsEditable
  void scroll(int x, int y) native "DOMWindow_scroll_Callback";

  @DomName('Window.scrollBy')
  @DocsEditable
  void scrollBy(int x, int y) native "DOMWindow_scrollBy_Callback";

  @DomName('Window.scrollTo')
  @DocsEditable
  void scrollTo(int x, int y) native "DOMWindow_scrollTo_Callback";

  @DomName('Window.setInterval')
  @DocsEditable
  int _setInterval(Object handler, int timeout) native "DOMWindow_setInterval_Callback";

  @DomName('Window.setTimeout')
  @DocsEditable
  int _setTimeout(Object handler, int timeout) native "DOMWindow_setTimeout_Callback";

  @DomName('Window.showModalDialog')
  @DocsEditable
  Object showModalDialog(String url, [Object dialogArgs, String featureArgs]) native "DOMWindow_showModalDialog_Callback";

  @DomName('Window.stop')
  @DocsEditable
  void stop() native "DOMWindow_stop_Callback";

  @DomName('Window.toString')
  @DocsEditable
  String toString() native "DOMWindow_toString_Callback";

  @DomName('Window.webkitConvertPointFromNodeToPage')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  _DomPoint _convertPointFromNodeToPage(Node node, _DomPoint p) native "DOMWindow_webkitConvertPointFromNodeToPage_Callback";

  @DomName('Window.webkitConvertPointFromPageToNode')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  _DomPoint _convertPointFromPageToNode(Node node, _DomPoint p) native "DOMWindow_webkitConvertPointFromPageToNode_Callback";

  @DomName('Window.webkitRequestFileSystem')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @Experimental
  void __requestFileSystem(int type, int size, _FileSystemCallback successCallback, [_ErrorCallback errorCallback]) native "DOMWindow_webkitRequestFileSystem_Callback";

  Future<FileSystem> _requestFileSystem(int type, int size) {
    var completer = new Completer<FileSystem>();
    __requestFileSystem(type, size,
        (value) { completer.complete(value); },
        (error) { completer.completeError(error); });
    return completer.future;
  }

  @DomName('Window.webkitResolveLocalFileSystemURL')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @Experimental
  void _resolveLocalFileSystemUrl(String url, _EntryCallback successCallback, [_ErrorCallback errorCallback]) native "DOMWindow_webkitResolveLocalFileSystemURL_Callback";

  Future<Entry> resolveLocalFileSystemUrl(String url) {
    var completer = new Completer<Entry>();
    _resolveLocalFileSystemUrl(url,
        (value) { completer.complete(value); },
        (error) { completer.completeError(error); });
    return completer.future;
  }

  @DomName('Window.onDOMContentLoaded')
  @DocsEditable
  Stream<Event> get onContentLoaded => contentLoadedEvent.forTarget(this);

  @DomName('Window.onabort')
  @DocsEditable
  Stream<Event> get onAbort => Element.abortEvent.forTarget(this);

  @DomName('Window.onblur')
  @DocsEditable
  Stream<Event> get onBlur => Element.blurEvent.forTarget(this);

  @DomName('Window.onchange')
  @DocsEditable
  Stream<Event> get onChange => Element.changeEvent.forTarget(this);

  @DomName('Window.onclick')
  @DocsEditable
  Stream<MouseEvent> get onClick => Element.clickEvent.forTarget(this);

  @DomName('Window.oncontextmenu')
  @DocsEditable
  Stream<MouseEvent> get onContextMenu => Element.contextMenuEvent.forTarget(this);

  @DomName('Window.ondblclick')
  @DocsEditable
  Stream<Event> get onDoubleClick => Element.doubleClickEvent.forTarget(this);

  @DomName('Window.ondevicemotion')
  @DocsEditable
  Stream<DeviceMotionEvent> get onDeviceMotion => deviceMotionEvent.forTarget(this);

  @DomName('Window.ondeviceorientation')
  @DocsEditable
  Stream<DeviceOrientationEvent> get onDeviceOrientation => deviceOrientationEvent.forTarget(this);

  @DomName('Window.ondrag')
  @DocsEditable
  Stream<MouseEvent> get onDrag => Element.dragEvent.forTarget(this);

  @DomName('Window.ondragend')
  @DocsEditable
  Stream<MouseEvent> get onDragEnd => Element.dragEndEvent.forTarget(this);

  @DomName('Window.ondragenter')
  @DocsEditable
  Stream<MouseEvent> get onDragEnter => Element.dragEnterEvent.forTarget(this);

  @DomName('Window.ondragleave')
  @DocsEditable
  Stream<MouseEvent> get onDragLeave => Element.dragLeaveEvent.forTarget(this);

  @DomName('Window.ondragover')
  @DocsEditable
  Stream<MouseEvent> get onDragOver => Element.dragOverEvent.forTarget(this);

  @DomName('Window.ondragstart')
  @DocsEditable
  Stream<MouseEvent> get onDragStart => Element.dragStartEvent.forTarget(this);

  @DomName('Window.ondrop')
  @DocsEditable
  Stream<MouseEvent> get onDrop => Element.dropEvent.forTarget(this);

  @DomName('Window.onerror')
  @DocsEditable
  Stream<Event> get onError => Element.errorEvent.forTarget(this);

  @DomName('Window.onfocus')
  @DocsEditable
  Stream<Event> get onFocus => Element.focusEvent.forTarget(this);

  @DomName('Window.onhashchange')
  @DocsEditable
  Stream<Event> get onHashChange => hashChangeEvent.forTarget(this);

  @DomName('Window.oninput')
  @DocsEditable
  Stream<Event> get onInput => Element.inputEvent.forTarget(this);

  @DomName('Window.oninvalid')
  @DocsEditable
  Stream<Event> get onInvalid => Element.invalidEvent.forTarget(this);

  @DomName('Window.onkeydown')
  @DocsEditable
  Stream<KeyboardEvent> get onKeyDown => Element.keyDownEvent.forTarget(this);

  @DomName('Window.onkeypress')
  @DocsEditable
  Stream<KeyboardEvent> get onKeyPress => Element.keyPressEvent.forTarget(this);

  @DomName('Window.onkeyup')
  @DocsEditable
  Stream<KeyboardEvent> get onKeyUp => Element.keyUpEvent.forTarget(this);

  @DomName('Window.onload')
  @DocsEditable
  Stream<Event> get onLoad => Element.loadEvent.forTarget(this);

  @DomName('Window.onmessage')
  @DocsEditable
  Stream<MessageEvent> get onMessage => messageEvent.forTarget(this);

  @DomName('Window.onmousedown')
  @DocsEditable
  Stream<MouseEvent> get onMouseDown => Element.mouseDownEvent.forTarget(this);

  @DomName('Window.onmousemove')
  @DocsEditable
  Stream<MouseEvent> get onMouseMove => Element.mouseMoveEvent.forTarget(this);

  @DomName('Window.onmouseout')
  @DocsEditable
  Stream<MouseEvent> get onMouseOut => Element.mouseOutEvent.forTarget(this);

  @DomName('Window.onmouseover')
  @DocsEditable
  Stream<MouseEvent> get onMouseOver => Element.mouseOverEvent.forTarget(this);

  @DomName('Window.onmouseup')
  @DocsEditable
  Stream<MouseEvent> get onMouseUp => Element.mouseUpEvent.forTarget(this);

  @DomName('Window.onmousewheel')
  @DocsEditable
  Stream<WheelEvent> get onMouseWheel => Element.mouseWheelEvent.forTarget(this);

  @DomName('Window.onoffline')
  @DocsEditable
  Stream<Event> get onOffline => offlineEvent.forTarget(this);

  @DomName('Window.ononline')
  @DocsEditable
  Stream<Event> get onOnline => onlineEvent.forTarget(this);

  @DomName('Window.onpagehide')
  @DocsEditable
  Stream<Event> get onPageHide => pageHideEvent.forTarget(this);

  @DomName('Window.onpageshow')
  @DocsEditable
  Stream<Event> get onPageShow => pageShowEvent.forTarget(this);

  @DomName('Window.onpopstate')
  @DocsEditable
  Stream<PopStateEvent> get onPopState => popStateEvent.forTarget(this);

  @DomName('Window.onreset')
  @DocsEditable
  Stream<Event> get onReset => Element.resetEvent.forTarget(this);

  @DomName('Window.onresize')
  @DocsEditable
  Stream<Event> get onResize => resizeEvent.forTarget(this);

  @DomName('Window.onscroll')
  @DocsEditable
  Stream<Event> get onScroll => Element.scrollEvent.forTarget(this);

  @DomName('Window.onsearch')
  @DocsEditable
  Stream<Event> get onSearch => Element.searchEvent.forTarget(this);

  @DomName('Window.onselect')
  @DocsEditable
  Stream<Event> get onSelect => Element.selectEvent.forTarget(this);

  @DomName('Window.onstorage')
  @DocsEditable
  Stream<StorageEvent> get onStorage => storageEvent.forTarget(this);

  @DomName('Window.onsubmit')
  @DocsEditable
  Stream<Event> get onSubmit => Element.submitEvent.forTarget(this);

  @DomName('Window.ontouchcancel')
  @DocsEditable
  Stream<TouchEvent> get onTouchCancel => Element.touchCancelEvent.forTarget(this);

  @DomName('Window.ontouchend')
  @DocsEditable
  Stream<TouchEvent> get onTouchEnd => Element.touchEndEvent.forTarget(this);

  @DomName('Window.ontouchmove')
  @DocsEditable
  Stream<TouchEvent> get onTouchMove => Element.touchMoveEvent.forTarget(this);

  @DomName('Window.ontouchstart')
  @DocsEditable
  Stream<TouchEvent> get onTouchStart => Element.touchStartEvent.forTarget(this);

  @DomName('Window.onunload')
  @DocsEditable
  Stream<Event> get onUnload => unloadEvent.forTarget(this);

  @DomName('Window.onwebkitAnimationEnd')
  @DocsEditable
  Stream<AnimationEvent> get onAnimationEnd => animationEndEvent.forTarget(this);

  @DomName('Window.onwebkitAnimationIteration')
  @DocsEditable
  Stream<AnimationEvent> get onAnimationIteration => animationIterationEvent.forTarget(this);

  @DomName('Window.onwebkitAnimationStart')
  @DocsEditable
  Stream<AnimationEvent> get onAnimationStart => animationStartEvent.forTarget(this);

  @DomName('Window.onwebkitTransitionEnd')
  @DocsEditable
  Stream<TransitionEvent> get onTransitionEnd => Element.transitionEndEvent.forTarget(this);


  @DomName('DOMWindow.beforeunloadEvent')
  @DocsEditable
  static const EventStreamProvider<BeforeUnloadEvent> beforeUnloadEvent =
      const _BeforeUnloadEventStreamProvider('beforeunload');

  @DomName('DOMWindow.onbeforeunload')
  @DocsEditable
  Stream<Event> get onBeforeUnload => beforeUnloadEvent.forTarget(this);
}

/**
 * Event object that is fired before the window is closed.
 *
 * The standard window close behavior can be prevented by setting the
 * [returnValue]. This will display a dialog to the user confirming that they
 * want to close the page.
 */
abstract class BeforeUnloadEvent implements Event {
  /**
   * If set to a non-null value, a dialog will be presented to the user
   * confirming that they want to close the page.
   */
  String returnValue;
}

class _BeforeUnloadEvent extends _WrappedEvent implements BeforeUnloadEvent {
  String _returnValue;

  _BeforeUnloadEvent(Event base): super(base);

  String get returnValue => _returnValue;

  void set returnValue(String value) {
    _returnValue = value;
  }
}

class _BeforeUnloadEventStreamProvider implements
    EventStreamProvider<BeforeUnloadEvent> {
  final String _eventType;

  const _BeforeUnloadEventStreamProvider(this._eventType);

  Stream<BeforeUnloadEvent> forTarget(EventTarget e, {bool useCapture: false}) {
    var controller = new StreamController();
    var stream = new _EventStream(e, _eventType, useCapture);
    stream.listen((event) {
      var wrapped = new _BeforeUnloadEvent(event);
      controller.add(wrapped);
      return wrapped.returnValue;
    });

    return controller.stream;
  }

  String getEventType(EventTarget target) {
    return _eventType;
  }
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('Worker')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.FIREFOX)
@SupportedBrowser(SupportedBrowser.IE, '10')
@SupportedBrowser(SupportedBrowser.SAFARI)
class Worker extends AbstractWorker {
  Worker.internal() : super.internal();

  @DomName('Worker.messageEvent')
  @DocsEditable
  static const EventStreamProvider<MessageEvent> messageEvent = const EventStreamProvider<MessageEvent>('message');

  @DomName('Worker.Worker')
  @DocsEditable
  factory Worker(String scriptUrl) {
    return Worker._create_1(scriptUrl);
  }

  @DocsEditable
  static Worker _create_1(scriptUrl) native "Worker__create_1constructorCallback";

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('Worker.postMessage')
  @DocsEditable
  void postMessage(/*SerializedScriptValue*/ message, [List messagePorts]) native "Worker_postMessage_Callback";

  @DomName('Worker.terminate')
  @DocsEditable
  void terminate() native "Worker_terminate_Callback";

  @DomName('Worker.onmessage')
  @DocsEditable
  Stream<MessageEvent> get onMessage => messageEvent.forTarget(this);

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('XPathEvaluator')
class XPathEvaluator extends NativeFieldWrapperClass1 {
  XPathEvaluator.internal();

  @DomName('XPathEvaluator.XPathEvaluator')
  @DocsEditable
  factory XPathEvaluator() {
    return XPathEvaluator._create_1();
  }

  @DocsEditable
  static XPathEvaluator _create_1() native "XPathEvaluator__create_1constructorCallback";

  @DomName('XPathEvaluator.createExpression')
  @DocsEditable
  XPathExpression createExpression(String expression, XPathNSResolver resolver) native "XPathEvaluator_createExpression_Callback";

  @DomName('XPathEvaluator.createNSResolver')
  @DocsEditable
  XPathNSResolver createNSResolver(Node nodeResolver) native "XPathEvaluator_createNSResolver_Callback";

  @DomName('XPathEvaluator.evaluate')
  @DocsEditable
  XPathResult evaluate(String expression, Node contextNode, XPathNSResolver resolver, int type, XPathResult inResult) native "XPathEvaluator_evaluate_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('XPathException')
class XPathException extends NativeFieldWrapperClass1 {
  XPathException.internal();

  @DomName('XPathException.INVALID_EXPRESSION_ERR')
  @DocsEditable
  static const int INVALID_EXPRESSION_ERR = 51;

  @DomName('XPathException.TYPE_ERR')
  @DocsEditable
  static const int TYPE_ERR = 52;

  @DomName('XPathException.code')
  @DocsEditable
  int get code native "XPathException_code_Getter";

  @DomName('XPathException.message')
  @DocsEditable
  String get message native "XPathException_message_Getter";

  @DomName('XPathException.name')
  @DocsEditable
  String get name native "XPathException_name_Getter";

  @DomName('XPathException.toString')
  @DocsEditable
  String toString() native "XPathException_toString_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('XPathExpression')
class XPathExpression extends NativeFieldWrapperClass1 {
  XPathExpression.internal();

  @DomName('XPathExpression.evaluate')
  @DocsEditable
  XPathResult evaluate(Node contextNode, int type, XPathResult inResult) native "XPathExpression_evaluate_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('XPathNSResolver')
class XPathNSResolver extends NativeFieldWrapperClass1 {
  XPathNSResolver.internal();

  @DomName('XPathNSResolver.lookupNamespaceURI')
  @DocsEditable
  String lookupNamespaceUri(String prefix) native "XPathNSResolver_lookupNamespaceURI_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('XPathResult')
class XPathResult extends NativeFieldWrapperClass1 {
  XPathResult.internal();

  @DomName('XPathResult.ANY_TYPE')
  @DocsEditable
  static const int ANY_TYPE = 0;

  @DomName('XPathResult.ANY_UNORDERED_NODE_TYPE')
  @DocsEditable
  static const int ANY_UNORDERED_NODE_TYPE = 8;

  @DomName('XPathResult.BOOLEAN_TYPE')
  @DocsEditable
  static const int BOOLEAN_TYPE = 3;

  @DomName('XPathResult.FIRST_ORDERED_NODE_TYPE')
  @DocsEditable
  static const int FIRST_ORDERED_NODE_TYPE = 9;

  @DomName('XPathResult.NUMBER_TYPE')
  @DocsEditable
  static const int NUMBER_TYPE = 1;

  @DomName('XPathResult.ORDERED_NODE_ITERATOR_TYPE')
  @DocsEditable
  static const int ORDERED_NODE_ITERATOR_TYPE = 5;

  @DomName('XPathResult.ORDERED_NODE_SNAPSHOT_TYPE')
  @DocsEditable
  static const int ORDERED_NODE_SNAPSHOT_TYPE = 7;

  @DomName('XPathResult.STRING_TYPE')
  @DocsEditable
  static const int STRING_TYPE = 2;

  @DomName('XPathResult.UNORDERED_NODE_ITERATOR_TYPE')
  @DocsEditable
  static const int UNORDERED_NODE_ITERATOR_TYPE = 4;

  @DomName('XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE')
  @DocsEditable
  static const int UNORDERED_NODE_SNAPSHOT_TYPE = 6;

  @DomName('XPathResult.booleanValue')
  @DocsEditable
  bool get booleanValue native "XPathResult_booleanValue_Getter";

  @DomName('XPathResult.invalidIteratorState')
  @DocsEditable
  bool get invalidIteratorState native "XPathResult_invalidIteratorState_Getter";

  @DomName('XPathResult.numberValue')
  @DocsEditable
  num get numberValue native "XPathResult_numberValue_Getter";

  @DomName('XPathResult.resultType')
  @DocsEditable
  int get resultType native "XPathResult_resultType_Getter";

  @DomName('XPathResult.singleNodeValue')
  @DocsEditable
  Node get singleNodeValue native "XPathResult_singleNodeValue_Getter";

  @DomName('XPathResult.snapshotLength')
  @DocsEditable
  int get snapshotLength native "XPathResult_snapshotLength_Getter";

  @DomName('XPathResult.stringValue')
  @DocsEditable
  String get stringValue native "XPathResult_stringValue_Getter";

  @DomName('XPathResult.iterateNext')
  @DocsEditable
  Node iterateNext() native "XPathResult_iterateNext_Callback";

  @DomName('XPathResult.snapshotItem')
  @DocsEditable
  Node snapshotItem(int index) native "XPathResult_snapshotItem_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('XMLSerializer')
class XmlSerializer extends NativeFieldWrapperClass1 {
  XmlSerializer.internal();

  @DomName('XMLSerializer.XMLSerializer')
  @DocsEditable
  factory XmlSerializer() {
    return XmlSerializer._create_1();
  }

  @DocsEditable
  static XmlSerializer _create_1() native "XMLSerializer__create_1constructorCallback";

  @DomName('XMLSerializer.serializeToString')
  @DocsEditable
  String serializeToString(Node node) native "XMLSerializer_serializeToString_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('XSLTProcessor')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.FIREFOX)
@SupportedBrowser(SupportedBrowser.SAFARI)
class XsltProcessor extends NativeFieldWrapperClass1 {
  XsltProcessor.internal();

  @DomName('XSLTProcessor.XSLTProcessor')
  @DocsEditable
  factory XsltProcessor() {
    return XsltProcessor._create_1();
  }

  @DocsEditable
  static XsltProcessor _create_1() native "XSLTProcessor__create_1constructorCallback";

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('XSLTProcessor.clearParameters')
  @DocsEditable
  void clearParameters() native "XSLTProcessor_clearParameters_Callback";

  @DomName('XSLTProcessor.getParameter')
  @DocsEditable
  String getParameter(String namespaceURI, String localName) native "XSLTProcessor_getParameter_Callback";

  @DomName('XSLTProcessor.importStylesheet')
  @DocsEditable
  void importStylesheet(Node stylesheet) native "XSLTProcessor_importStylesheet_Callback";

  @DomName('XSLTProcessor.removeParameter')
  @DocsEditable
  void removeParameter(String namespaceURI, String localName) native "XSLTProcessor_removeParameter_Callback";

  @DomName('XSLTProcessor.reset')
  @DocsEditable
  void reset() native "XSLTProcessor_reset_Callback";

  @DomName('XSLTProcessor.setParameter')
  @DocsEditable
  void setParameter(String namespaceURI, String localName, String value) native "XSLTProcessor_setParameter_Callback";

  @DomName('XSLTProcessor.transformToDocument')
  @DocsEditable
  Document transformToDocument(Node source) native "XSLTProcessor_transformToDocument_Callback";

  @DomName('XSLTProcessor.transformToFragment')
  @DocsEditable
  DocumentFragment transformToFragment(Node source, Document docVal) native "XSLTProcessor_transformToFragment_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('CSSPrimitiveValue')
abstract class _CSSPrimitiveValue extends _CSSValue {
  _CSSPrimitiveValue.internal() : super.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('CSSValue')
abstract class _CSSValue extends NativeFieldWrapperClass1 {
  _CSSValue.internal();

}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DocsEditable
@DomName('ClientRect')
class _ClientRect extends NativeFieldWrapperClass1 implements Rect {

  // NOTE! All code below should be common with Rect.
  // TODO(blois): implement with mixins when available.

  String toString() {
    return '($left, $top, $width, $height)';
  }

  bool operator ==(other) {
    if (other is !Rect) return false;
    return left == other.left && top == other.top && width == other.width &&
        height == other.height;
  }

  /**
   * Computes the intersection of this rectangle and the rectangle parameter.
   * Returns null if there is no intersection.
   */
  Rect intersection(Rect rect) {
    var x0 = max(left, rect.left);
    var x1 = min(left + width, rect.left + rect.width);

    if (x0 <= x1) {
      var y0 = max(top, rect.top);
      var y1 = min(top + height, rect.top + rect.height);

      if (y0 <= y1) {
        return new Rect(x0, y0, x1 - x0, y1 - y0);
      }
    }
    return null;
  }


  /**
   * Returns whether a rectangle intersects this rectangle.
   */
  bool intersects(Rect other) {
    return (left <= other.left + other.width && other.left <= left + width &&
        top <= other.top + other.height && other.top <= top + height);
  }

  /**
   * Returns a new rectangle which completely contains this rectangle and the
   * input rectangle.
   */
  Rect union(Rect rect) {
    var right = max(this.left + this.width, rect.left + rect.width);
    var bottom = max(this.top + this.height, rect.top + rect.height);

    var left = min(this.left, rect.left);
    var top = min(this.top, rect.top);

    return new Rect(left, top, right - left, bottom - top);
  }

  /**
   * Tests whether this rectangle entirely contains another rectangle.
   */
  bool containsRect(Rect another) {
    return left <= another.left &&
           left + width >= another.left + another.width &&
           top <= another.top &&
           top + height >= another.top + another.height;
  }

  /**
   * Tests whether this rectangle entirely contains a point.
   */
  bool containsPoint(Point another) {
    return another.x >= left &&
           another.x <= left + width &&
           another.y >= top &&
           another.y <= top + height;
  }

  Rect ceil() => new Rect(left.ceil(), top.ceil(), width.ceil(), height.ceil());
  Rect floor() => new Rect(left.floor(), top.floor(), width.floor(),
      height.floor());
  Rect round() => new Rect(left.round(), top.round(), width.round(),
      height.round());

  /**
   * Truncates coordinates to integers and returns the result as a new
   * rectangle.
   */
  Rect toInt() => new Rect(left.toInt(), top.toInt(), width.toInt(),
      height.toInt());

  Point get topLeft => new Point(this.left, this.top);
  Point get bottomRight => new Point(this.left + this.width,
      this.top + this.height);
  _ClientRect.internal();

  @DomName('ClientRect.bottom')
  @DocsEditable
  num get bottom native "ClientRect_bottom_Getter";

  @DomName('ClientRect.height')
  @DocsEditable
  num get height native "ClientRect_height_Getter";

  @DomName('ClientRect.left')
  @DocsEditable
  num get left native "ClientRect_left_Getter";

  @DomName('ClientRect.right')
  @DocsEditable
  num get right native "ClientRect_right_Getter";

  @DomName('ClientRect.top')
  @DocsEditable
  num get top native "ClientRect_top_Getter";

  @DomName('ClientRect.width')
  @DocsEditable
  num get width native "ClientRect_width_Getter";
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('ClientRectList')
class _ClientRectList extends NativeFieldWrapperClass1 with ListMixin<Rect>, ImmutableListMixin<Rect> implements List<Rect> {
  _ClientRectList.internal();

  @DomName('ClientRectList.length')
  @DocsEditable
  int get length native "ClientRectList_length_Getter";

  Rect operator[](int index) {
    if (index < 0 || index >= length)
      throw new RangeError.range(index, 0, length);
    return _nativeIndexedGetter(index);
  }
  Rect _nativeIndexedGetter(int index) native "ClientRectList_item_Callback";

  void operator[]=(int index, Rect value) {
    throw new UnsupportedError("Cannot assign element of immutable List.");
  }
  // -- start List<Rect> mixins.
  // Rect is the element type.


  void set length(int value) {
    throw new UnsupportedError("Cannot resize immutable List.");
  }

  Rect get first {
    if (this.length > 0) {
      return this[0];
    }
    throw new StateError("No elements");
  }

  Rect get last {
    int len = this.length;
    if (len > 0) {
      return this[len - 1];
    }
    throw new StateError("No elements");
  }

  Rect get single {
    int len = this.length;
    if (len == 1) {
      return this[0];
    }
    if (len == 0) throw new StateError("No elements");
    throw new StateError("More than one element");
  }

  Rect elementAt(int index) => this[index];
  // -- end List<Rect> mixins.

  @DomName('ClientRectList.item')
  @DocsEditable
  Rect item(int index) native "ClientRectList_item_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('Counter')
abstract class _Counter extends NativeFieldWrapperClass1 {
  _Counter.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('CSSRuleList')
class _CssRuleList extends NativeFieldWrapperClass1 with ListMixin<CssRule>, ImmutableListMixin<CssRule> implements List<CssRule> {
  _CssRuleList.internal();

  @DomName('CSSRuleList.length')
  @DocsEditable
  int get length native "CSSRuleList_length_Getter";

  CssRule operator[](int index) {
    if (index < 0 || index >= length)
      throw new RangeError.range(index, 0, length);
    return _nativeIndexedGetter(index);
  }
  CssRule _nativeIndexedGetter(int index) native "CSSRuleList_item_Callback";

  void operator[]=(int index, CssRule value) {
    throw new UnsupportedError("Cannot assign element of immutable List.");
  }
  // -- start List<CssRule> mixins.
  // CssRule is the element type.


  void set length(int value) {
    throw new UnsupportedError("Cannot resize immutable List.");
  }

  CssRule get first {
    if (this.length > 0) {
      return this[0];
    }
    throw new StateError("No elements");
  }

  CssRule get last {
    int len = this.length;
    if (len > 0) {
      return this[len - 1];
    }
    throw new StateError("No elements");
  }

  CssRule get single {
    int len = this.length;
    if (len == 1) {
      return this[0];
    }
    if (len == 0) throw new StateError("No elements");
    throw new StateError("More than one element");
  }

  CssRule elementAt(int index) => this[index];
  // -- end List<CssRule> mixins.

  @DomName('CSSRuleList.item')
  @DocsEditable
  CssRule item(int index) native "CSSRuleList_item_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('CSSValueList')
class _CssValueList extends _CSSValue with ListMixin<_CSSValue>, ImmutableListMixin<_CSSValue> implements List<_CSSValue> {
  _CssValueList.internal() : super.internal();

  @DomName('CSSValueList.length')
  @DocsEditable
  int get length native "CSSValueList_length_Getter";

  _CSSValue operator[](int index) {
    if (index < 0 || index >= length)
      throw new RangeError.range(index, 0, length);
    return _nativeIndexedGetter(index);
  }
  _CSSValue _nativeIndexedGetter(int index) native "CSSValueList_item_Callback";

  void operator[]=(int index, _CSSValue value) {
    throw new UnsupportedError("Cannot assign element of immutable List.");
  }
  // -- start List<_CSSValue> mixins.
  // _CSSValue is the element type.


  void set length(int value) {
    throw new UnsupportedError("Cannot resize immutable List.");
  }

  _CSSValue get first {
    if (this.length > 0) {
      return this[0];
    }
    throw new StateError("No elements");
  }

  _CSSValue get last {
    int len = this.length;
    if (len > 0) {
      return this[len - 1];
    }
    throw new StateError("No elements");
  }

  _CSSValue get single {
    int len = this.length;
    if (len == 1) {
      return this[0];
    }
    if (len == 0) throw new StateError("No elements");
    throw new StateError("More than one element");
  }

  _CSSValue elementAt(int index) => this[index];
  // -- end List<_CSSValue> mixins.

  @DomName('CSSValueList.item')
  @DocsEditable
  _CSSValue item(int index) native "CSSValueList_item_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('DOMFileSystemSync')
@SupportedBrowser(SupportedBrowser.CHROME)
@Experimental
abstract class _DOMFileSystemSync extends NativeFieldWrapperClass1 {
  _DOMFileSystemSync.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('DatabaseSync')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.SAFARI)
@Experimental
abstract class _DatabaseSync extends NativeFieldWrapperClass1 {
  _DatabaseSync.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('DedicatedWorkerContext')
abstract class _DedicatedWorkerContext extends _WorkerContext {
  _DedicatedWorkerContext.internal() : super.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('DirectoryEntrySync')
abstract class _DirectoryEntrySync extends _EntrySync {
  _DirectoryEntrySync.internal() : super.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('DirectoryReaderSync')
abstract class _DirectoryReaderSync extends NativeFieldWrapperClass1 {
  _DirectoryReaderSync.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('WebKitPoint')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.SAFARI)
@Experimental
class _DomPoint extends NativeFieldWrapperClass1 {
  _DomPoint.internal();
  factory _DomPoint(num x, num y) => _create(x, y);

  @DocsEditable
  static _DomPoint _create(x, y) native "DOMPoint_constructorCallback";

  /// Checks if this type is supported on the current platform.
  static bool get supported => true;

  @DomName('WebKitPoint.x')
  @DocsEditable
  num get x native "DOMPoint_x_Getter";

  @DomName('WebKitPoint.x')
  @DocsEditable
  void set x(num value) native "DOMPoint_x_Setter";

  @DomName('WebKitPoint.y')
  @DocsEditable
  num get y native "DOMPoint_y_Getter";

  @DomName('WebKitPoint.y')
  @DocsEditable
  void set y(num value) native "DOMPoint_y_Setter";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLElement')
class _Element_Merged extends Element {
  _Element_Merged.internal() : super.internal();

  @DomName('HTMLElement.children')
  @DocsEditable
  HtmlCollection get $dom_children native "HTMLElement_children_Getter";

  @DomName('HTMLElement.contentEditable')
  @DocsEditable
  String get contentEditable native "HTMLElement_contentEditable_Getter";

  @DomName('HTMLElement.contentEditable')
  @DocsEditable
  void set contentEditable(String value) native "HTMLElement_contentEditable_Setter";

  @DomName('HTMLElement.dir')
  @DocsEditable
  String get dir native "HTMLElement_dir_Getter";

  @DomName('HTMLElement.dir')
  @DocsEditable
  void set dir(String value) native "HTMLElement_dir_Setter";

  @DomName('HTMLElement.draggable')
  @DocsEditable
  bool get draggable native "HTMLElement_draggable_Getter";

  @DomName('HTMLElement.draggable')
  @DocsEditable
  void set draggable(bool value) native "HTMLElement_draggable_Setter";

  @DomName('HTMLElement.hidden')
  @DocsEditable
  bool get hidden native "HTMLElement_hidden_Getter";

  @DomName('HTMLElement.hidden')
  @DocsEditable
  void set hidden(bool value) native "HTMLElement_hidden_Setter";

  @DomName('HTMLElement.id')
  @DocsEditable
  String get id native "HTMLElement_id_Getter";

  @DomName('HTMLElement.id')
  @DocsEditable
  void set id(String value) native "HTMLElement_id_Setter";

  @DomName('HTMLElement.innerHTML')
  @DocsEditable
  String get innerHtml native "HTMLElement_innerHTML_Getter";

  @DomName('HTMLElement.innerHTML')
  @DocsEditable
  void set innerHtml(String value) native "HTMLElement_innerHTML_Setter";

  @DomName('HTMLElement.isContentEditable')
  @DocsEditable
  bool get isContentEditable native "HTMLElement_isContentEditable_Getter";

  @DomName('HTMLElement.lang')
  @DocsEditable
  String get lang native "HTMLElement_lang_Getter";

  @DomName('HTMLElement.lang')
  @DocsEditable
  void set lang(String value) native "HTMLElement_lang_Setter";

  @DomName('HTMLElement.outerHTML')
  @DocsEditable
  String get outerHtml native "HTMLElement_outerHTML_Getter";

  @DomName('HTMLElement.spellcheck')
  @DocsEditable
  bool get spellcheck native "HTMLElement_spellcheck_Getter";

  @DomName('HTMLElement.spellcheck')
  @DocsEditable
  void set spellcheck(bool value) native "HTMLElement_spellcheck_Setter";

  @DomName('HTMLElement.tabIndex')
  @DocsEditable
  int get tabIndex native "HTMLElement_tabIndex_Getter";

  @DomName('HTMLElement.tabIndex')
  @DocsEditable
  void set tabIndex(int value) native "HTMLElement_tabIndex_Setter";

  @DomName('HTMLElement.title')
  @DocsEditable
  String get title native "HTMLElement_title_Getter";

  @DomName('HTMLElement.title')
  @DocsEditable
  void set title(String value) native "HTMLElement_title_Setter";

  @DomName('HTMLElement.translate')
  @DocsEditable
  bool get translate native "HTMLElement_translate_Getter";

  @DomName('HTMLElement.translate')
  @DocsEditable
  void set translate(bool value) native "HTMLElement_translate_Setter";

  @DomName('HTMLElement.webkitdropzone')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  String get dropzone native "HTMLElement_webkitdropzone_Getter";

  @DomName('HTMLElement.webkitdropzone')
  @DocsEditable
  @SupportedBrowser(SupportedBrowser.CHROME)
  @SupportedBrowser(SupportedBrowser.SAFARI)
  @Experimental
  void set dropzone(String value) native "HTMLElement_webkitdropzone_Setter";

  @DomName('HTMLElement.click')
  @DocsEditable
  void click() native "HTMLElement_click_Callback";

  @DomName('HTMLElement.insertAdjacentElement')
  @DocsEditable
  Element insertAdjacentElement(String where, Element element) native "HTMLElement_insertAdjacentElement_Callback";

  @DomName('HTMLElement.insertAdjacentHTML')
  @DocsEditable
  void insertAdjacentHtml(String where, String html) native "HTMLElement_insertAdjacentHTML_Callback";

  @DomName('HTMLElement.insertAdjacentText')
  @DocsEditable
  void insertAdjacentText(String where, String text) native "HTMLElement_insertAdjacentText_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('EntityReference')
abstract class _EntityReference extends Node {
  _EntityReference.internal() : super.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('EntryArray')
class _EntryArray extends NativeFieldWrapperClass1 with ListMixin<Entry>, ImmutableListMixin<Entry> implements List<Entry> {
  _EntryArray.internal();

  @DomName('EntryArray.length')
  @DocsEditable
  int get length native "EntryArray_length_Getter";

  Entry operator[](int index) {
    if (index < 0 || index >= length)
      throw new RangeError.range(index, 0, length);
    return _nativeIndexedGetter(index);
  }
  Entry _nativeIndexedGetter(int index) native "EntryArray_item_Callback";

  void operator[]=(int index, Entry value) {
    throw new UnsupportedError("Cannot assign element of immutable List.");
  }
  // -- start List<Entry> mixins.
  // Entry is the element type.


  void set length(int value) {
    throw new UnsupportedError("Cannot resize immutable List.");
  }

  Entry get first {
    if (this.length > 0) {
      return this[0];
    }
    throw new StateError("No elements");
  }

  Entry get last {
    int len = this.length;
    if (len > 0) {
      return this[len - 1];
    }
    throw new StateError("No elements");
  }

  Entry get single {
    int len = this.length;
    if (len == 1) {
      return this[0];
    }
    if (len == 0) throw new StateError("No elements");
    throw new StateError("More than one element");
  }

  Entry elementAt(int index) => this[index];
  // -- end List<Entry> mixins.

  @DomName('EntryArray.item')
  @DocsEditable
  Entry item(int index) native "EntryArray_item_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('EntryArraySync')
class _EntryArraySync extends NativeFieldWrapperClass1 with ListMixin<_EntrySync>, ImmutableListMixin<_EntrySync> implements List<_EntrySync> {
  _EntryArraySync.internal();

  @DomName('EntryArraySync.length')
  @DocsEditable
  int get length native "EntryArraySync_length_Getter";

  _EntrySync operator[](int index) {
    if (index < 0 || index >= length)
      throw new RangeError.range(index, 0, length);
    return _nativeIndexedGetter(index);
  }
  _EntrySync _nativeIndexedGetter(int index) native "EntryArraySync_item_Callback";

  void operator[]=(int index, _EntrySync value) {
    throw new UnsupportedError("Cannot assign element of immutable List.");
  }
  // -- start List<_EntrySync> mixins.
  // _EntrySync is the element type.


  void set length(int value) {
    throw new UnsupportedError("Cannot resize immutable List.");
  }

  _EntrySync get first {
    if (this.length > 0) {
      return this[0];
    }
    throw new StateError("No elements");
  }

  _EntrySync get last {
    int len = this.length;
    if (len > 0) {
      return this[len - 1];
    }
    throw new StateError("No elements");
  }

  _EntrySync get single {
    int len = this.length;
    if (len == 1) {
      return this[0];
    }
    if (len == 0) throw new StateError("No elements");
    throw new StateError("More than one element");
  }

  _EntrySync elementAt(int index) => this[index];
  // -- end List<_EntrySync> mixins.

  @DomName('EntryArraySync.item')
  @DocsEditable
  _EntrySync item(int index) native "EntryArraySync_item_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('EntrySync')
abstract class _EntrySync extends NativeFieldWrapperClass1 {
  _EntrySync.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('FileEntrySync')
abstract class _FileEntrySync extends _EntrySync {
  _FileEntrySync.internal() : super.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('FileReaderSync')
abstract class _FileReaderSync extends NativeFieldWrapperClass1 {
  _FileReaderSync.internal();

  @DomName('FileReaderSync.FileReaderSync')
  @DocsEditable
  factory _FileReaderSync() {
    return _FileReaderSync._create_1();
  }

  @DocsEditable
  static _FileReaderSync _create_1() native "FileReaderSync__create_1constructorCallback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('FileWriterSync')
abstract class _FileWriterSync extends NativeFieldWrapperClass1 {
  _FileWriterSync.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('GamepadList')
class _GamepadList extends NativeFieldWrapperClass1 with ListMixin<Gamepad>, ImmutableListMixin<Gamepad> implements List<Gamepad> {
  _GamepadList.internal();

  @DomName('GamepadList.length')
  @DocsEditable
  int get length native "GamepadList_length_Getter";

  Gamepad operator[](int index) {
    if (index < 0 || index >= length)
      throw new RangeError.range(index, 0, length);
    return _nativeIndexedGetter(index);
  }
  Gamepad _nativeIndexedGetter(int index) native "GamepadList_item_Callback";

  void operator[]=(int index, Gamepad value) {
    throw new UnsupportedError("Cannot assign element of immutable List.");
  }
  // -- start List<Gamepad> mixins.
  // Gamepad is the element type.


  void set length(int value) {
    throw new UnsupportedError("Cannot resize immutable List.");
  }

  Gamepad get first {
    if (this.length > 0) {
      return this[0];
    }
    throw new StateError("No elements");
  }

  Gamepad get last {
    int len = this.length;
    if (len > 0) {
      return this[len - 1];
    }
    throw new StateError("No elements");
  }

  Gamepad get single {
    int len = this.length;
    if (len == 1) {
      return this[0];
    }
    if (len == 0) throw new StateError("No elements");
    throw new StateError("More than one element");
  }

  Gamepad elementAt(int index) => this[index];
  // -- end List<Gamepad> mixins.

  @DomName('GamepadList.item')
  @DocsEditable
  Gamepad item(int index) native "GamepadList_item_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLAppletElement')
abstract class _HTMLAppletElement extends _Element_Merged {
  _HTMLAppletElement.internal() : super.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLBaseFontElement')
abstract class _HTMLBaseFontElement extends _Element_Merged {
  _HTMLBaseFontElement.internal() : super.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLDirectoryElement')
abstract class _HTMLDirectoryElement extends _Element_Merged {
  _HTMLDirectoryElement.internal() : super.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLFontElement')
abstract class _HTMLFontElement extends _Element_Merged {
  _HTMLFontElement.internal() : super.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLFrameElement')
abstract class _HTMLFrameElement extends _Element_Merged {
  _HTMLFrameElement.internal() : super.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLFrameSetElement')
abstract class _HTMLFrameSetElement extends _Element_Merged {
  _HTMLFrameSetElement.internal() : super.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('HTMLMarqueeElement')
abstract class _HTMLMarqueeElement extends _Element_Merged {
  _HTMLMarqueeElement.internal() : super.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('NamedNodeMap')
class _NamedNodeMap extends NativeFieldWrapperClass1 with ListMixin<Node>, ImmutableListMixin<Node> implements List<Node> {
  _NamedNodeMap.internal();

  @DomName('NamedNodeMap.length')
  @DocsEditable
  int get length native "NamedNodeMap_length_Getter";

  Node operator[](int index) {
    if (index < 0 || index >= length)
      throw new RangeError.range(index, 0, length);
    return _nativeIndexedGetter(index);
  }
  Node _nativeIndexedGetter(int index) native "NamedNodeMap_item_Callback";

  void operator[]=(int index, Node value) {
    throw new UnsupportedError("Cannot assign element of immutable List.");
  }
  // -- start List<Node> mixins.
  // Node is the element type.


  void set length(int value) {
    throw new UnsupportedError("Cannot resize immutable List.");
  }

  Node get first {
    if (this.length > 0) {
      return this[0];
    }
    throw new StateError("No elements");
  }

  Node get last {
    int len = this.length;
    if (len > 0) {
      return this[len - 1];
    }
    throw new StateError("No elements");
  }

  Node get single {
    int len = this.length;
    if (len == 1) {
      return this[0];
    }
    if (len == 0) throw new StateError("No elements");
    throw new StateError("More than one element");
  }

  Node elementAt(int index) => this[index];
  // -- end List<Node> mixins.

  @DomName('NamedNodeMap.getNamedItem')
  @DocsEditable
  Node getNamedItem(String name) native "NamedNodeMap_getNamedItem_Callback";

  @DomName('NamedNodeMap.getNamedItemNS')
  @DocsEditable
  Node getNamedItemNS(String namespaceURI, String localName) native "NamedNodeMap_getNamedItemNS_Callback";

  @DomName('NamedNodeMap.item')
  @DocsEditable
  Node item(int index) native "NamedNodeMap_item_Callback";

  @DomName('NamedNodeMap.removeNamedItem')
  @DocsEditable
  Node removeNamedItem(String name) native "NamedNodeMap_removeNamedItem_Callback";

  @DomName('NamedNodeMap.removeNamedItemNS')
  @DocsEditable
  Node removeNamedItemNS(String namespaceURI, String localName) native "NamedNodeMap_removeNamedItemNS_Callback";

  @DomName('NamedNodeMap.setNamedItem')
  @DocsEditable
  Node setNamedItem(Node node) native "NamedNodeMap_setNamedItem_Callback";

  @DomName('NamedNodeMap.setNamedItemNS')
  @DocsEditable
  Node setNamedItemNS(Node node) native "NamedNodeMap_setNamedItemNS_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('PagePopupController')
abstract class _PagePopupController extends NativeFieldWrapperClass1 {
  _PagePopupController.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('RGBColor')
abstract class _RGBColor extends NativeFieldWrapperClass1 {
  _RGBColor.internal();

}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


@DomName('RadioNodeList')
class _RadioNodeList extends NodeList {
  _RadioNodeList.internal() : super.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('Rect')
abstract class _Rect extends NativeFieldWrapperClass1 {
  _Rect.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('SharedWorker')
abstract class _SharedWorker extends AbstractWorker {
  _SharedWorker.internal() : super.internal();

  @DomName('SharedWorker.SharedWorker')
  @DocsEditable
  factory _SharedWorker(String scriptURL, [String name]) {
    return _SharedWorker._create_1(scriptURL, name);
  }

  @DocsEditable
  static _SharedWorker _create_1(scriptURL, name) native "SharedWorker__create_1constructorCallback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('SharedWorkerContext')
abstract class _SharedWorkerContext extends _WorkerContext {
  _SharedWorkerContext.internal() : super.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('SpeechInputResultList')
class _SpeechInputResultList extends NativeFieldWrapperClass1 with ListMixin<SpeechInputResult>, ImmutableListMixin<SpeechInputResult> implements List<SpeechInputResult> {
  _SpeechInputResultList.internal();

  @DomName('SpeechInputResultList.length')
  @DocsEditable
  int get length native "SpeechInputResultList_length_Getter";

  SpeechInputResult operator[](int index) {
    if (index < 0 || index >= length)
      throw new RangeError.range(index, 0, length);
    return _nativeIndexedGetter(index);
  }
  SpeechInputResult _nativeIndexedGetter(int index) native "SpeechInputResultList_item_Callback";

  void operator[]=(int index, SpeechInputResult value) {
    throw new UnsupportedError("Cannot assign element of immutable List.");
  }
  // -- start List<SpeechInputResult> mixins.
  // SpeechInputResult is the element type.


  void set length(int value) {
    throw new UnsupportedError("Cannot resize immutable List.");
  }

  SpeechInputResult get first {
    if (this.length > 0) {
      return this[0];
    }
    throw new StateError("No elements");
  }

  SpeechInputResult get last {
    int len = this.length;
    if (len > 0) {
      return this[len - 1];
    }
    throw new StateError("No elements");
  }

  SpeechInputResult get single {
    int len = this.length;
    if (len == 1) {
      return this[0];
    }
    if (len == 0) throw new StateError("No elements");
    throw new StateError("More than one element");
  }

  SpeechInputResult elementAt(int index) => this[index];
  // -- end List<SpeechInputResult> mixins.

  @DomName('SpeechInputResultList.item')
  @DocsEditable
  SpeechInputResult item(int index) native "SpeechInputResultList_item_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('SpeechRecognitionResultList')
class _SpeechRecognitionResultList extends NativeFieldWrapperClass1 with ListMixin<SpeechRecognitionResult>, ImmutableListMixin<SpeechRecognitionResult> implements List<SpeechRecognitionResult> {
  _SpeechRecognitionResultList.internal();

  @DomName('SpeechRecognitionResultList.length')
  @DocsEditable
  int get length native "SpeechRecognitionResultList_length_Getter";

  SpeechRecognitionResult operator[](int index) {
    if (index < 0 || index >= length)
      throw new RangeError.range(index, 0, length);
    return _nativeIndexedGetter(index);
  }
  SpeechRecognitionResult _nativeIndexedGetter(int index) native "SpeechRecognitionResultList_item_Callback";

  void operator[]=(int index, SpeechRecognitionResult value) {
    throw new UnsupportedError("Cannot assign element of immutable List.");
  }
  // -- start List<SpeechRecognitionResult> mixins.
  // SpeechRecognitionResult is the element type.


  void set length(int value) {
    throw new UnsupportedError("Cannot resize immutable List.");
  }

  SpeechRecognitionResult get first {
    if (this.length > 0) {
      return this[0];
    }
    throw new StateError("No elements");
  }

  SpeechRecognitionResult get last {
    int len = this.length;
    if (len > 0) {
      return this[len - 1];
    }
    throw new StateError("No elements");
  }

  SpeechRecognitionResult get single {
    int len = this.length;
    if (len == 1) {
      return this[0];
    }
    if (len == 0) throw new StateError("No elements");
    throw new StateError("More than one element");
  }

  SpeechRecognitionResult elementAt(int index) => this[index];
  // -- end List<SpeechRecognitionResult> mixins.

  @DomName('SpeechRecognitionResultList.item')
  @DocsEditable
  SpeechRecognitionResult item(int index) native "SpeechRecognitionResultList_item_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('StyleSheetList')
class _StyleSheetList extends NativeFieldWrapperClass1 with ListMixin<StyleSheet>, ImmutableListMixin<StyleSheet> implements List<StyleSheet> {
  _StyleSheetList.internal();

  @DomName('StyleSheetList.length')
  @DocsEditable
  int get length native "StyleSheetList_length_Getter";

  StyleSheet operator[](int index) {
    if (index < 0 || index >= length)
      throw new RangeError.range(index, 0, length);
    return _nativeIndexedGetter(index);
  }
  StyleSheet _nativeIndexedGetter(int index) native "StyleSheetList_item_Callback";

  void operator[]=(int index, StyleSheet value) {
    throw new UnsupportedError("Cannot assign element of immutable List.");
  }
  // -- start List<StyleSheet> mixins.
  // StyleSheet is the element type.


  void set length(int value) {
    throw new UnsupportedError("Cannot resize immutable List.");
  }

  StyleSheet get first {
    if (this.length > 0) {
      return this[0];
    }
    throw new StateError("No elements");
  }

  StyleSheet get last {
    int len = this.length;
    if (len > 0) {
      return this[len - 1];
    }
    throw new StateError("No elements");
  }

  StyleSheet get single {
    int len = this.length;
    if (len == 1) {
      return this[0];
    }
    if (len == 0) throw new StateError("No elements");
    throw new StateError("More than one element");
  }

  StyleSheet elementAt(int index) => this[index];
  // -- end List<StyleSheet> mixins.

  @DomName('StyleSheetList.item')
  @DocsEditable
  StyleSheet item(int index) native "StyleSheetList_item_Callback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('WebKitCSSFilterValue')
abstract class _WebKitCSSFilterValue extends _CssValueList {
  _WebKitCSSFilterValue.internal() : super.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('WebKitCSSMatrix')
@SupportedBrowser(SupportedBrowser.CHROME)
@SupportedBrowser(SupportedBrowser.SAFARI)
@Experimental
abstract class _WebKitCSSMatrix extends NativeFieldWrapperClass1 {
  _WebKitCSSMatrix.internal();

  @DomName('WebKitCSSMatrix.WebKitCSSMatrix')
  @DocsEditable
  factory _WebKitCSSMatrix([String cssValue]) {
    return _WebKitCSSMatrix._create_1(cssValue);
  }

  @DocsEditable
  static _WebKitCSSMatrix _create_1(cssValue) native "WebKitCSSMatrix__create_1constructorCallback";

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('WebKitCSSMixFunctionValue')
abstract class _WebKitCSSMixFunctionValue extends _CssValueList {
  _WebKitCSSMixFunctionValue.internal() : super.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('WebKitCSSTransformValue')
abstract class _WebKitCSSTransformValue extends _CssValueList {
  _WebKitCSSTransformValue.internal() : super.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('WorkerContext')
abstract class _WorkerContext extends EventTarget {
  _WorkerContext.internal() : super.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('WorkerLocation')
abstract class _WorkerLocation extends NativeFieldWrapperClass1 {
  _WorkerLocation.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// WARNING: Do not edit - generated code.


@DocsEditable
@DomName('WorkerNavigator')
abstract class _WorkerNavigator extends NativeFieldWrapperClass1 {
  _WorkerNavigator.internal();

}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


abstract class _AttributeMap implements Map<String, String> {
  final Element _element;

  _AttributeMap(this._element);

  bool containsValue(String value) {
    for (var v in this.values) {
      if (value == v) {
        return true;
      }
    }
    return false;
  }

  String putIfAbsent(String key, String ifAbsent()) {
    if (!containsKey(key)) {
      this[key] = ifAbsent();
    }
    return this[key];
  }

  void clear() {
    for (var key in keys) {
      remove(key);
    }
  }

  void forEach(void f(String key, String value)) {
    for (var key in keys) {
      var value = this[key];
      f(key, value);
    }
  }

  Iterable<String> get keys {
    // TODO: generate a lazy collection instead.
    var attributes = _element.$dom_attributes;
    var keys = new List<String>();
    for (int i = 0, len = attributes.length; i < len; i++) {
      if (_matches(attributes[i])) {
        keys.add(attributes[i].localName);
      }
    }
    return keys;
  }

  Iterable<String> get values {
    // TODO: generate a lazy collection instead.
    var attributes = _element.$dom_attributes;
    var values = new List<String>();
    for (int i = 0, len = attributes.length; i < len; i++) {
      if (_matches(attributes[i])) {
        values.add(attributes[i].value);
      }
    }
    return values;
  }

  /**
   * Returns true if there is no {key, value} pair in the map.
   */
  bool get isEmpty {
    return length == 0;
  }

  /**
   * Checks to see if the node should be included in this map.
   */
  bool _matches(Node node);
}

/**
 * Wrapper to expose [Element.attributes] as a typed map.
 */
class _ElementAttributeMap extends _AttributeMap {

  _ElementAttributeMap(Element element): super(element);

  bool containsKey(String key) {
    return _element.$dom_hasAttribute(key);
  }

  String operator [](String key) {
    return _element.$dom_getAttribute(key);
  }

  void operator []=(String key, String value) {
    _element.$dom_setAttribute(key, value);
  }

  String remove(String key) {
    String value = _element.$dom_getAttribute(key);
    _element.$dom_removeAttribute(key);
    return value;
  }

  /**
   * The number of {key, value} pairs in the map.
   */
  int get length {
    return keys.length;
  }

  bool _matches(Node node) => node.$dom_namespaceUri == null;
}

/**
 * Wrapper to expose namespaced attributes as a typed map.
 */
class _NamespacedAttributeMap extends _AttributeMap {

  final String _namespace;

  _NamespacedAttributeMap(Element element, this._namespace): super(element);

  bool containsKey(String key) {
    return _element.$dom_hasAttributeNS(_namespace, key);
  }

  String operator [](String key) {
    return _element.$dom_getAttributeNS(_namespace, key);
  }

  void operator []=(String key, String value) {
    _element.$dom_setAttributeNS(_namespace, key, value);
  }

  String remove(String key) {
    String value = this[key];
    _element.$dom_removeAttributeNS(_namespace, key);
    return value;
  }

  /**
   * The number of {key, value} pairs in the map.
   */
  int get length {
    return keys.length;
  }

  bool _matches(Node node) => node.$dom_namespaceUri == _namespace;
}


/**
 * Provides a Map abstraction on top of data-* attributes, similar to the
 * dataSet in the old DOM.
 */
class _DataAttributeMap implements Map<String, String> {

  final Map<String, String> $dom_attributes;

  _DataAttributeMap(this.$dom_attributes);

  // interface Map

  // TODO: Use lazy iterator when it is available on Map.
  bool containsValue(String value) => values.any((v) => v == value);

  bool containsKey(String key) => $dom_attributes.containsKey(_attr(key));

  String operator [](String key) => $dom_attributes[_attr(key)];

  void operator []=(String key, String value) {
    $dom_attributes[_attr(key)] = value;
  }

  String putIfAbsent(String key, String ifAbsent()) =>
    $dom_attributes.putIfAbsent(_attr(key), ifAbsent);

  String remove(String key) => $dom_attributes.remove(_attr(key));

  void clear() {
    // Needs to operate on a snapshot since we are mutating the collection.
    for (String key in keys) {
      remove(key);
    }
  }

  void forEach(void f(String key, String value)) {
    $dom_attributes.forEach((String key, String value) {
      if (_matches(key)) {
        f(_strip(key), value);
      }
    });
  }

  Iterable<String> get keys {
    final keys = new List<String>();
    $dom_attributes.forEach((String key, String value) {
      if (_matches(key)) {
        keys.add(_strip(key));
      }
    });
    return keys;
  }

  Iterable<String> get values {
    final values = new List<String>();
    $dom_attributes.forEach((String key, String value) {
      if (_matches(key)) {
        values.add(value);
      }
    });
    return values;
  }

  int get length => keys.length;

  // TODO: Use lazy iterator when it is available on Map.
  bool get isEmpty => length == 0;

  // Helpers.
  String _attr(String key) => 'data-$key';
  bool _matches(String key) => key.startsWith('data-');
  String _strip(String key) => key.substring(5);
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/**
 * An object that can be drawn to a [CanvasRenderingContext2D] object with
 * [CanvasRenderingContext2D.drawImage],
 * [CanvasRenderingContext2D.drawImageRect],
 * [CanvasRenderingContext2D.drawImageScaled], or
 * [CanvasRenderingContext2D.drawImageScaledFromSource].
 *
 * If the CanvasImageSource is an [ImageElement] then the element's image is
 * used. If the [ImageElement] is an animated image, then the poster frame is
 * used. If there is no poster frame, then the first frame of animation is used.
 *
 * If the CanvasImageSource is a [VideoElement] then the frame at the current
 * playback position is used as the image.
 *
 * If the CanvasImageSource is a [CanvasElement] then the element's bitmap is
 * used.
 *
 * ** Note: ** Currently, all versions of Internet Explorer do not support
 * drawing a VideoElement to a canvas. Also, you may experience problems drawing
 * a video to a canvas in Firefox if the source of the video is a data URL.
 *
 * See also:
 *
 *  * [CanvasImageSource](http://www.whatwg.org/specs/web-apps/current-work/multipage/the-canvas-element.html#image-sources-for-2d-rendering-contexts)
 * from the WHATWG.
 *  * [drawImage](http://www.whatwg.org/specs/web-apps/current-work/multipage/the-canvas-element.html#dom-context-2d-drawimage)
 * from the WHATWG.
 */
abstract class CanvasImageSource {}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/**
 * An object representing the top-level context object for web scripting.
 *
 * In a web browser, a [Window] object represents the actual browser window.
 * In a multi-tabbed browser, each tab has its own [Window] object. A [Window]
 * is the container that displays a [Document]'s content. All web scripting
 * happens within the context of a [Window] object.
 *
 * **Note:** This class represents any window, whereas [Window] is
 * used to access the properties and content of the current window.
 *
 * See also:
 *
 * * [DOM Window](https://developer.mozilla.org/en-US/docs/DOM/window) from MDN.
 * * [Window](http://www.w3.org/TR/Window/) from the W3C.
 */
abstract class WindowBase {
  // Fields.

  /**
   * The current location of this window.
   *
   *     Location currentLocation = window.location;
   *     print(currentLocation.href); // 'http://www.example.com:80/'
   */
  LocationBase get location;
  HistoryBase get history;

  /**
   * Indicates whether this window has been closed.
   *
   *     print(window.closed); // 'false'
   *     window.close();
   *     print(window.closed); // 'true'
   */
  bool get closed;

  /**
   * A reference to the window that opened this one.
   *
   *     Window thisWindow = window;
   *     WindowBase otherWindow = thisWindow.open('http://www.example.com/', 'foo');
   *     print(otherWindow.opener == thisWindow); // 'true'
   */
  WindowBase get opener;

  /**
   * A reference to the parent of this window.
   *
   * If this [WindowBase] has no parent, [parent] will return a reference to
   * the [WindowBase] itself.
   *
   *     IFrameElement myIFrame = new IFrameElement();
   *     window.document.body.elements.add(myIFrame);
   *     print(myIframe.contentWindow.parent == window) // 'true'
   *
   *     print(window.parent == window) // 'true'
   */
  WindowBase get parent;

  /**
   * A reference to the topmost window in the window hierarchy.
   *
   * If this [WindowBase] is the topmost [WindowBase], [top] will return a
   * reference to the [WindowBase] itself.
   *
   *     // Add an IFrame to the current window.
   *     IFrameElement myIFrame = new IFrameElement();
   *     window.document.body.elements.add(myIFrame);
   *
   *     // Add an IFrame inside of the other IFrame.
   *     IFrameElement innerIFrame = new IFrameElement();
   *     myIFrame.elements.add(innerIFrame);
   *
   *     print(myIframe.contentWindow.top == window) // 'true'
   *     print(innerIFrame.contentWindow.top == window) // 'true'
   *
   *     print(window.top == window) // 'true'
   */
  WindowBase get top;

  // Methods.
  /**
   * Closes the window.
   *
   * This method should only succeed if the [WindowBase] object is
   * **script-closeable** and the window calling [close] is allowed to navigate
   * the window.
   *
   * A window is script-closeable if it is either a window
   * that was opened by another window, or if it is a window with only one
   * document in its history.
   *
   * A window might not be allowed to navigate, and therefore close, another
   * window due to browser security features.
   *
   *     var other = window.open('http://www.example.com', 'foo');
   *     // Closes other window, as it is script-closeable.
   *     other.close();
   *     print(other.closed()); // 'true'
   *
   *     window.location('http://www.mysite.com', 'foo');
   *     // Does not close this window, as the history has changed.
   *     window.close();
   *     print(window.closed()); // 'false'
   *
   * See also:
   *
   * * [Window close discussion](http://www.w3.org/TR/html5/browsers.html#dom-window-close) from the W3C
   */
  void close();
  void postMessage(var message, String targetOrigin, [List messagePorts]);
}

abstract class LocationBase {
  void set href(String val);
}

abstract class HistoryBase {
  void back();
  void forward();
  void go(int distance);
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/** A Set that stores the CSS class names for an element. */
abstract class CssClassSet implements Set<String> {

  /**
   * Adds the class [value] to the element if it is not on it, removes it if it
   * is.
   */
  bool toggle(String value);

  /**
   * Returns [:true:] if classes cannot be added or removed from this
   * [:CssClassSet:].
   */
  bool get frozen;

  /**
   * Determine if this element contains the class [value].
   *
   * This is the Dart equivalent of jQuery's
   * [hasClass](http://api.jquery.com/hasClass/).
   */
  bool contains(String value);

  /**
   * Add the class [value] to element.
   *
   * This is the Dart equivalent of jQuery's
   * [addClass](http://api.jquery.com/addClass/).
   */
  void add(String value);

  /**
   * Remove the class [value] from element, and return true on successful
   * removal.
   *
   * This is the Dart equivalent of jQuery's
   * [removeClass](http://api.jquery.com/removeClass/).
   */
  bool remove(Object value);

  /**
   * Add all classes specified in [iterable] to element.
   *
   * This is the Dart equivalent of jQuery's
   * [addClass](http://api.jquery.com/addClass/).
   */
  void addAll(Iterable<String> iterable);

  /**
   * Remove all classes specified in [iterable] from element.
   *
   * This is the Dart equivalent of jQuery's
   * [removeClass](http://api.jquery.com/removeClass/).
   */
  void removeAll(Iterable<String> iterable);

  /**
   * Toggles all classes specified in [iterable] on element.
   *
   * Iterate through [iterable]'s items, and add it if it is not on it, or
   * remove it if it is. This is the Dart equivalent of jQuery's
   * [toggleClass](http://api.jquery.com/toggleClass/).
   */
  void toggleAll(Iterable<String> iterable);
}

/**
 * A set (union) of the CSS classes that are present in a set of elements.
 * Implemented separately from _ElementCssClassSet for performance.
 */
class _MultiElementCssClassSet extends CssClassSetImpl {
  final Iterable<Element> _elementIterable;
  Iterable<_ElementCssClassSet> _elementCssClassSetIterable;

  _MultiElementCssClassSet(this._elementIterable) {
    _elementCssClassSetIterable = new List.from(_elementIterable).map(
        (e) => new _ElementCssClassSet(e));
  }

  Set<String> readClasses() {
    var s = new LinkedHashSet<String>();
    _elementCssClassSetIterable.forEach((e) => s.addAll(e.readClasses()));
    return s;
  }

  void writeClasses(Set<String> s) {
    var classes = new List.from(s).join(' ');
    for (Element e in _elementIterable) {
      e.$dom_className = classes;
    }
  }

  /**
   * Helper method used to modify the set of css classes on this element.
   *
   *   f - callback with:
   *   s - a Set of all the css class name currently on this element.
   *
   *   After f returns, the modified set is written to the
   *       className property of this element.
   */
  void modify( f(Set<String> s)) {
    _elementCssClassSetIterable.forEach((e) => e.modify(f));
  }

  /**
   * Adds the class [value] to the element if it is not on it, removes it if it
   * is.
   */
  bool toggle(String value) =>
      _modifyWithReturnValue((e) => e.toggle(value));

  /**
   * Remove the class [value] from element, and return true on successful
   * removal.
   *
   * This is the Dart equivalent of jQuery's
   * [removeClass](http://api.jquery.com/removeClass/).
   */
  bool remove(Object value) => _modifyWithReturnValue((e) => e.remove(value));

  bool _modifyWithReturnValue(f) => _elementCssClassSetIterable.fold(
      false, (prevValue, element) => f(element) || prevValue);
}

class _ElementCssClassSet extends CssClassSetImpl {

  final Element _element;

  _ElementCssClassSet(this._element);

  Set<String> readClasses() {
    var s = new LinkedHashSet<String>();
    var classname = _element.$dom_className;

    for (String name in classname.split(' ')) {
      String trimmed = name.trim();
      if (!trimmed.isEmpty) {
        s.add(trimmed);
      }
    }
    return s;
  }

  void writeClasses(Set<String> s) {
    List list = new List.from(s);
    _element.$dom_className = s.join(' ');
  }
}
// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


typedef EventListener(Event event);
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/**
 * Adapter for exposing DOM events as Dart streams.
 */
class _EventStream<T extends Event> extends Stream<T> {
  final EventTarget _target;
  final String _eventType;
  final bool _useCapture;

  _EventStream(this._target, this._eventType, this._useCapture);

  // DOM events are inherently multi-subscribers.
  Stream<T> asBroadcastStream() => this;
  bool get isBroadcast => true;

  StreamSubscription<T> listen(void onData(T event),
      { void onError(error),
        void onDone(),
        bool cancelOnError}) {

    return new _EventStreamSubscription<T>(
        this._target, this._eventType, onData, this._useCapture);
  }
}

class _EventStreamSubscription<T extends Event> extends StreamSubscription<T> {
  int _pauseCount = 0;
  EventTarget _target;
  final String _eventType;
  var _onData;
  final bool _useCapture;

  _EventStreamSubscription(this._target, this._eventType, this._onData,
      this._useCapture) {
    _tryResume();
  }

  void cancel() {
    if (_canceled) return;

    _unlisten();
    // Clear out the target to indicate this is complete.
    _target = null;
    _onData = null;
  }

  bool get _canceled => _target == null;

  void onData(void handleData(T event)) {
    if (_canceled) {
      throw new StateError("Subscription has been canceled.");
    }
    // Remove current event listener.
    _unlisten();

    _onData = handleData;
    _tryResume();
  }

  /// Has no effect.
  void onError(void handleError(error)) {}

  /// Has no effect.
  void onDone(void handleDone()) {}

  void pause([Future resumeSignal]) {
    if (_canceled) return;
    ++_pauseCount;
    _unlisten();

    if (resumeSignal != null) {
      resumeSignal.whenComplete(resume);
    }
  }

  bool get _paused => _pauseCount > 0;

  void resume() {
    if (_canceled || !_paused) return;
    --_pauseCount;
    _tryResume();
  }

  void _tryResume() {
    if (_onData != null && !_paused) {
      _target.$dom_addEventListener(_eventType, _onData, _useCapture);
    }
  }

  void _unlisten() {
    if (_onData != null) {
      _target.$dom_removeEventListener(_eventType, _onData, _useCapture);
    }
  }

  Future asFuture([var futureValue]) {
    // We just need a future that will never succeed or fail.
    Completer completer = new Completer();
    return completer.future;
  }
}


/**
 * A factory to expose DOM events as Streams.
 */
class EventStreamProvider<T extends Event> {
  final String _eventType;

  const EventStreamProvider(this._eventType);

  /**
   * Gets a [Stream] for this event type, on the specified target.
   *
   * This may be used to capture DOM events:
   *
   *     Element.keyDownEvent.forTarget(element, useCapture: true).listen(...);
   *
   * Or for listening to an event which will bubble through the DOM tree:
   *
   *     MediaElement.pauseEvent.forTarget(document.body).listen(...);
   *
   * See also:
   *
   * [addEventListener](http://docs.webplatform.org/wiki/dom/methods/addEventListener)
   */
  Stream<T> forTarget(EventTarget e, {bool useCapture: false}) {
    return new _EventStream(e, _eventType, useCapture);
  }

  /**
   * Gets the type of the event which this would listen for on the specified
   * event target.
   *
   * The target is necessary because some browsers may use different event names
   * for the same purpose and the target allows differentiating browser support.
   */
  String getEventType(EventTarget target) {
    return _eventType;
  }
}

/**
 * A factory to expose DOM events as streams, where the DOM event name has to
 * be determined on the fly (for example, mouse wheel events).
 */
class _CustomEventStreamProvider<T extends Event>
    implements EventStreamProvider<T> {

  final _eventTypeGetter;
  const _CustomEventStreamProvider(this._eventTypeGetter);

  Stream<T> forTarget(EventTarget e, {bool useCapture: false}) {
    return new _EventStream(e, _eventTypeGetter(e), useCapture);
  }

  String getEventType(EventTarget target) {
    return _eventTypeGetter(target);
  }
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


abstract class ImmutableListMixin<E> implements List<E> {
  // From Iterable<$E>:
  Iterator<E> get iterator {
    // Note: NodeLists are not fixed size. And most probably length shouldn't
    // be cached in both iterator _and_ forEach method. For now caching it
    // for consistency.
    return new FixedSizeListIterator<E>(this);
  }

  // From Collection<E>:
  void add(E value) {
    throw new UnsupportedError("Cannot add to immutable List.");
  }

  void addAll(Iterable<E> iterable) {
    throw new UnsupportedError("Cannot add to immutable List.");
  }

  // From List<E>:
  void sort([int compare(E a, E b)]) {
    throw new UnsupportedError("Cannot sort immutable List.");
  }

  void insert(int index, E element) {
    throw new UnsupportedError("Cannot add to immutable List.");
  }

  void insertAll(int index, Iterable<E> iterable) {
    throw new UnsupportedError("Cannot add to immutable List.");
  }

  void setAll(int index, Iterable<E> iterable) {
    throw new UnsupportedError("Cannot modify an immutable List.");
  }

  E removeAt(int pos) {
    throw new UnsupportedError("Cannot remove from immutable List.");
  }

  E removeLast() {
    throw new UnsupportedError("Cannot remove from immutable List.");
  }

  void remove(Object object) {
    throw new UnsupportedError("Cannot remove from immutable List.");
  }

  void removeWhere(bool test(E element)) {
    throw new UnsupportedError("Cannot remove from immutable List.");
  }

  void retainWhere(bool test(E element)) {
    throw new UnsupportedError("Cannot remove from immutable List.");
  }

  void setRange(int start, int end, Iterable<E> iterable, [int skipCount]) {
    throw new UnsupportedError("Cannot setRange on immutable List.");
  }

  void removeRange(int start, int end) {
    throw new UnsupportedError("Cannot removeRange on immutable List.");
  }

  void replaceRange(int start, int end, Iterable<E> iterable) {
    throw new UnsupportedError("Cannot modify an immutable List.");
  }

  void fillRange(int start, int end, [E fillValue]) {
    throw new UnsupportedError("Cannot modify an immutable List.");
  }
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/**
 * Internal class that does the actual calculations to determine keyCode and
 * charCode for keydown, keypress, and keyup events for all browsers.
 */
class _KeyboardEventHandler extends EventStreamProvider<KeyEvent> {
  // This code inspired by Closure's KeyHandling library.
  // http://closure-library.googlecode.com/svn/docs/closure_goog_events_keyhandler.js.source.html

  /**
   * The set of keys that have been pressed down without seeing their
   * corresponding keyup event.
   */
  final List<KeyboardEvent> _keyDownList = <KeyboardEvent>[];

  /** The type of KeyEvent we are tracking (keyup, keydown, keypress). */
  final String _type;

  /** The element we are watching for events to happen on. */
  final EventTarget _target;

  // The distance to shift from upper case alphabet Roman letters to lower case.
  static final int _ROMAN_ALPHABET_OFFSET = "a".codeUnits[0] - "A".codeUnits[0];

  /** Controller to produce KeyEvents for the stream. */
  final StreamController _controller = new StreamController();

  static const _EVENT_TYPE = 'KeyEvent';

  /**
   * An enumeration of key identifiers currently part of the W3C draft for DOM3
   * and their mappings to keyCodes.
   * http://www.w3.org/TR/DOM-Level-3-Events/keyset.html#KeySet-Set
   */
  static const Map<String, int> _keyIdentifier = const {
    'Up': KeyCode.UP,
    'Down': KeyCode.DOWN,
    'Left': KeyCode.LEFT,
    'Right': KeyCode.RIGHT,
    'Enter': KeyCode.ENTER,
    'F1': KeyCode.F1,
    'F2': KeyCode.F2,
    'F3': KeyCode.F3,
    'F4': KeyCode.F4,
    'F5': KeyCode.F5,
    'F6': KeyCode.F6,
    'F7': KeyCode.F7,
    'F8': KeyCode.F8,
    'F9': KeyCode.F9,
    'F10': KeyCode.F10,
    'F11': KeyCode.F11,
    'F12': KeyCode.F12,
    'U+007F': KeyCode.DELETE,
    'Home': KeyCode.HOME,
    'End': KeyCode.END,
    'PageUp': KeyCode.PAGE_UP,
    'PageDown': KeyCode.PAGE_DOWN,
    'Insert': KeyCode.INSERT
  };

  /** Return a stream for KeyEvents for the specified target. */
  Stream<KeyEvent> forTarget(EventTarget e, {bool useCapture: false}) {
    return new _KeyboardEventHandler.initializeAllEventListeners(
        _type, e).stream;
  }

  /**
   * Accessor to the stream associated with a particular KeyboardEvent
   * EventTarget.
   *
   * [forTarget] must be called to initialize this stream to listen to a
   * particular EventTarget.
   */
  Stream<KeyEvent> get stream {
    if(_target != null) {
      return _controller.stream;
    } else {
      throw new StateError("Not initialized. Call forTarget to access a stream "
          "initialized with a particular EventTarget.");
    }
  }

  /**
   * General constructor, performs basic initialization for our improved
   * KeyboardEvent controller.
   */
  _KeyboardEventHandler(this._type) :
    _target = null, super(_EVENT_TYPE) {
  }

  /**
   * Hook up all event listeners under the covers so we can estimate keycodes
   * and charcodes when they are not provided.
   */
  _KeyboardEventHandler.initializeAllEventListeners(this._type, this._target) : 
    super(_EVENT_TYPE) {
    Element.keyDownEvent.forTarget(_target, useCapture: true).listen(
        processKeyDown);
    Element.keyPressEvent.forTarget(_target, useCapture: true).listen(
        processKeyPress);
    Element.keyUpEvent.forTarget(_target, useCapture: true).listen(
        processKeyUp);
  }

  /**
   * Notify all callback listeners that a KeyEvent of the relevant type has
   * occurred.
   */
  bool _dispatch(KeyEvent event) {
    if (event.type == _type)
      _controller.add(event);
  }

  /** Determine if caps lock is one of the currently depressed keys. */
  bool get _capsLockOn =>
      _keyDownList.any((var element) => element.keyCode == KeyCode.CAPS_LOCK);

  /**
   * Given the previously recorded keydown key codes, see if we can determine
   * the keycode of this keypress [event]. (Generally browsers only provide
   * charCode information for keypress events, but with a little
   * reverse-engineering, we can also determine the keyCode.) Returns
   * KeyCode.UNKNOWN if the keycode could not be determined.
   */
  int _determineKeyCodeForKeypress(KeyboardEvent event) {
    // Note: This function is a work in progress. We'll expand this function
    // once we get more information about other keyboards.
    for (var prevEvent in _keyDownList) {
      if (prevEvent._shadowCharCode == event.charCode) {
        return prevEvent.keyCode;
      }
      if ((event.shiftKey || _capsLockOn) && event.charCode >= "A".codeUnits[0]
          && event.charCode <= "Z".codeUnits[0] && event.charCode +
          _ROMAN_ALPHABET_OFFSET == prevEvent._shadowCharCode) {
        return prevEvent.keyCode;
      }
    }
    return KeyCode.UNKNOWN;
  }

  /**
   * Given the charater code returned from a keyDown [event], try to ascertain
   * and return the corresponding charCode for the character that was pressed.
   * This information is not shown to the user, but used to help polyfill
   * keypress events.
   */
  int _findCharCodeKeyDown(KeyboardEvent event) {
    if (event.keyLocation == 3) { // Numpad keys.
      switch (event.keyCode) {
        case KeyCode.NUM_ZERO:
          // Even though this function returns _charCodes_, for some cases the
          // KeyCode == the charCode we want, in which case we use the keycode
          // constant for readability.
          return KeyCode.ZERO;
        case KeyCode.NUM_ONE:
          return KeyCode.ONE;
        case KeyCode.NUM_TWO:
          return KeyCode.TWO;
        case KeyCode.NUM_THREE:
          return KeyCode.THREE;
        case KeyCode.NUM_FOUR:
          return KeyCode.FOUR;
        case KeyCode.NUM_FIVE:
          return KeyCode.FIVE;
        case KeyCode.NUM_SIX:
          return KeyCode.SIX;
        case KeyCode.NUM_SEVEN:
          return KeyCode.SEVEN;
        case KeyCode.NUM_EIGHT:
          return KeyCode.EIGHT;
        case KeyCode.NUM_NINE:
          return KeyCode.NINE;
        case KeyCode.NUM_MULTIPLY:
          return 42; // Char code for *
        case KeyCode.NUM_PLUS:
          return 43; // +
        case KeyCode.NUM_MINUS:
          return 45; // -
        case KeyCode.NUM_PERIOD:
          return 46; // .
        case KeyCode.NUM_DIVISION:
          return 47; // /
      }
    } else if (event.keyCode >= 65 && event.keyCode <= 90) {
      // Set the "char code" for key down as the lower case letter. Again, this
      // will not show up for the user, but will be helpful in estimating
      // keyCode locations and other information during the keyPress event.
      return event.keyCode + _ROMAN_ALPHABET_OFFSET;
    }
    switch(event.keyCode) {
      case KeyCode.SEMICOLON:
        return KeyCode.FF_SEMICOLON;
      case KeyCode.EQUALS:
        return KeyCode.FF_EQUALS;
      case KeyCode.COMMA:
        return 44; // Ascii value for ,
      case KeyCode.DASH:
        return 45; // -
      case KeyCode.PERIOD:
        return 46; // .
      case KeyCode.SLASH:
        return 47; // /
      case KeyCode.APOSTROPHE:
        return 96; // `
      case KeyCode.OPEN_SQUARE_BRACKET:
        return 91; // [
      case KeyCode.BACKSLASH:
        return 92; // \
      case KeyCode.CLOSE_SQUARE_BRACKET:
        return 93; // ]
      case KeyCode.SINGLE_QUOTE:
        return 39; // '
    }
    return event.keyCode;
  }

  /**
   * Returns true if the key fires a keypress event in the current browser.
   */
  bool _firesKeyPressEvent(KeyEvent event) {
    if (!Device.isIE && !Device.isWebKit) {
      return true;
    }

    if (Device.userAgent.contains('Mac') && event.altKey) {
      return KeyCode.isCharacterKey(event.keyCode);
    }

    // Alt but not AltGr which is represented as Alt+Ctrl.
    if (event.altKey && !event.ctrlKey) {
      return false;
    }

    // Saves Ctrl or Alt + key for IE and WebKit, which won't fire keypress.
    if (!event.shiftKey &&
        (_keyDownList.last.keyCode == KeyCode.CTRL ||
         _keyDownList.last.keyCode == KeyCode.ALT ||
         Device.userAgent.contains('Mac') &&
         _keyDownList.last.keyCode == KeyCode.META)) {
      return false;
    }

    // Some keys with Ctrl/Shift do not issue keypress in WebKit.
    if (Device.isWebKit && event.ctrlKey && event.shiftKey && (
        event.keyCode == KeyCode.BACKSLASH ||
        event.keyCode == KeyCode.OPEN_SQUARE_BRACKET ||
        event.keyCode == KeyCode.CLOSE_SQUARE_BRACKET ||
        event.keyCode == KeyCode.TILDE ||
        event.keyCode == KeyCode.SEMICOLON || event.keyCode == KeyCode.DASH ||
        event.keyCode == KeyCode.EQUALS || event.keyCode == KeyCode.COMMA ||
        event.keyCode == KeyCode.PERIOD || event.keyCode == KeyCode.SLASH ||
        event.keyCode == KeyCode.APOSTROPHE ||
        event.keyCode == KeyCode.SINGLE_QUOTE)) {
      return false;
    }

    switch (event.keyCode) {
      case KeyCode.ENTER:
        // IE9 does not fire keypress on ENTER.
        return !Device.isIE;
      case KeyCode.ESC:
        return !Device.isWebKit;
    }

    return KeyCode.isCharacterKey(event.keyCode);
  }

  /**
   * Normalize the keycodes to the IE KeyCodes (this is what Chrome, IE, and
   * Opera all use).
   */
  int _normalizeKeyCodes(KeyboardEvent event) {
    // Note: This may change once we get input about non-US keyboards.
    if (Device.isFirefox) {
      switch(event.keyCode) {
        case KeyCode.FF_EQUALS:
          return KeyCode.EQUALS;
        case KeyCode.FF_SEMICOLON:
          return KeyCode.SEMICOLON;
        case KeyCode.MAC_FF_META:
          return KeyCode.META;
        case KeyCode.WIN_KEY_FF_LINUX:
          return KeyCode.WIN_KEY;
      }
    }
    return event.keyCode;
  }

  /** Handle keydown events. */
  void processKeyDown(KeyboardEvent e) {
    // Ctrl-Tab and Alt-Tab can cause the focus to be moved to another window
    // before we've caught a key-up event.  If the last-key was one of these
    // we reset the state.
    if (_keyDownList.length > 0 &&
        (_keyDownList.last.keyCode == KeyCode.CTRL && !e.ctrlKey ||
         _keyDownList.last.keyCode == KeyCode.ALT && !e.altKey ||
         Device.userAgent.contains('Mac') &&
         _keyDownList.last.keyCode == KeyCode.META && !e.metaKey)) {
      _keyDownList.clear();
    }

    var event = new KeyEvent(e);
    event._shadowKeyCode = _normalizeKeyCodes(event);
    // Technically a "keydown" event doesn't have a charCode. This is
    // calculated nonetheless to provide us with more information in giving
    // as much information as possible on keypress about keycode and also
    // charCode.
    event._shadowCharCode = _findCharCodeKeyDown(event);
    if (_keyDownList.length > 0 && event.keyCode != _keyDownList.last.keyCode &&
        !_firesKeyPressEvent(event)) {
      // Some browsers have quirks not firing keypress events where all other
      // browsers do. This makes them more consistent.
      processKeyPress(event);
    }
    _keyDownList.add(event);
    _dispatch(event);
  }

  /** Handle keypress events. */
  void processKeyPress(KeyboardEvent event) {
    var e = new KeyEvent(event);
    // IE reports the character code in the keyCode field for keypress events.
    // There are two exceptions however, Enter and Escape.
    if (Device.isIE) {
      if (e.keyCode == KeyCode.ENTER || e.keyCode == KeyCode.ESC) {
        e._shadowCharCode = 0;
      } else {
        e._shadowCharCode = e.keyCode;
      }
    } else if (Device.isOpera) {
      // Opera reports the character code in the keyCode field.
      e._shadowCharCode = KeyCode.isCharacterKey(e.keyCode) ? e.keyCode : 0;
    }
    // Now we guestimate about what the keycode is that was actually
    // pressed, given previous keydown information.
    e._shadowKeyCode = _determineKeyCodeForKeypress(e);

    // Correct the key value for certain browser-specific quirks.
    if (e._shadowKeyIdentifier != null &&
        _keyIdentifier.containsKey(e._shadowKeyIdentifier)) {
      // This is needed for Safari Windows because it currently doesn't give a
      // keyCode/which for non printable keys.
      e._shadowKeyCode = _keyIdentifier[e._shadowKeyIdentifier];
    }
    e._shadowAltKey = _keyDownList.any((var element) => element.altKey);
    _dispatch(e);
  }

  /** Handle keyup events. */
  void processKeyUp(KeyboardEvent event) {
    var e = new KeyEvent(event);
    KeyboardEvent toRemove = null;
    for (var key in _keyDownList) {
      if (key.keyCode == e.keyCode) {
        toRemove = key;
      }
    }
    if (toRemove != null) {
      _keyDownList.removeWhere((element) => element == toRemove);
    } else if (_keyDownList.length > 0) {
      // This happens when we've reached some international keyboard case we
      // haven't accounted for or we haven't correctly eliminated all browser
      // inconsistencies. Filing bugs on when this is reached is welcome!
      _keyDownList.removeLast();
    }
    _dispatch(e);
  }
}


/**
 * Records KeyboardEvents that occur on a particular element, and provides a
 * stream of outgoing KeyEvents with cross-browser consistent keyCode and
 * charCode values despite the fact that a multitude of browsers that have
 * varying keyboard default behavior.
 *
 * Example usage:
 *
 *     KeyboardEventStream.onKeyDown(document.body).listen(
 *         keydownHandlerTest);
 *
 * This class is very much a work in progress, and we'd love to get information
 * on how we can make this class work with as many international keyboards as
 * possible. Bugs welcome!
 */
class KeyboardEventStream {

  /** Named constructor to produce a stream for onKeyPress events. */
  static Stream<KeyEvent> onKeyPress(EventTarget target) =>
      new _KeyboardEventHandler('keypress').forTarget(target);

  /** Named constructor to produce a stream for onKeyUp events. */
  static Stream<KeyEvent> onKeyUp(EventTarget target) =>
      new _KeyboardEventHandler('keyup').forTarget(target);

  /** Named constructor to produce a stream for onKeyDown events. */
  static Stream<KeyEvent> onKeyDown(EventTarget target) =>
    new _KeyboardEventHandler('keydown').forTarget(target);
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/**
 * Defines the keycode values for keys that are returned by
 * KeyboardEvent.keyCode.
 *
 * Important note: There is substantial divergence in how different browsers
 * handle keycodes and their variants in different locales/keyboard layouts. We
 * provide these constants to help make code processing keys more readable.
 */
abstract class KeyCode {
  // These constant names were borrowed from Closure's Keycode enumeration
  // class.
  // http://closure-library.googlecode.com/svn/docs/closure_goog_events_keycodes.js.source.html
  static const int WIN_KEY_FF_LINUX = 0;
  static const int MAC_ENTER = 3;
  static const int BACKSPACE = 8;
  static const int TAB = 9;
  /** NUM_CENTER is also NUMLOCK for FF and Safari on Mac. */
  static const int NUM_CENTER = 12;
  static const int ENTER = 13;
  static const int SHIFT = 16;
  static const int CTRL = 17;
  static const int ALT = 18;
  static const int PAUSE = 19;
  static const int CAPS_LOCK = 20;
  static const int ESC = 27;
  static const int SPACE = 32;
  static const int PAGE_UP = 33;
  static const int PAGE_DOWN = 34;
  static const int END = 35;
  static const int HOME = 36;
  static const int LEFT = 37;
  static const int UP = 38;
  static const int RIGHT = 39;
  static const int DOWN = 40;
  static const int NUM_NORTH_EAST = 33;
  static const int NUM_SOUTH_EAST = 34;
  static const int NUM_SOUTH_WEST = 35;
  static const int NUM_NORTH_WEST = 36;
  static const int NUM_WEST = 37;
  static const int NUM_NORTH = 38;
  static const int NUM_EAST = 39;
  static const int NUM_SOUTH = 40;
  static const int PRINT_SCREEN = 44;
  static const int INSERT = 45;
  static const int NUM_INSERT = 45;
  static const int DELETE = 46;
  static const int NUM_DELETE = 46;
  static const int ZERO = 48;
  static const int ONE = 49;
  static const int TWO = 50;
  static const int THREE = 51;
  static const int FOUR = 52;
  static const int FIVE = 53;
  static const int SIX = 54;
  static const int SEVEN = 55;
  static const int EIGHT = 56;
  static const int NINE = 57;
  static const int FF_SEMICOLON = 59;
  static const int FF_EQUALS = 61;
  /**
   * CAUTION: The question mark is for US-keyboard layouts. It varies
   * for other locales and keyboard layouts.
   */
  static const int QUESTION_MARK = 63;
  static const int A = 65;
  static const int B = 66;
  static const int C = 67;
  static const int D = 68;
  static const int E = 69;
  static const int F = 70;
  static const int G = 71;
  static const int H = 72;
  static const int I = 73;
  static const int J = 74;
  static const int K = 75;
  static const int L = 76;
  static const int M = 77;
  static const int N = 78;
  static const int O = 79;
  static const int P = 80;
  static const int Q = 81;
  static const int R = 82;
  static const int S = 83;
  static const int T = 84;
  static const int U = 85;
  static const int V = 86;
  static const int W = 87;
  static const int X = 88;
  static const int Y = 89;
  static const int Z = 90;
  static const int META = 91;
  static const int WIN_KEY_LEFT = 91;
  static const int WIN_KEY_RIGHT = 92;
  static const int CONTEXT_MENU = 93;
  static const int NUM_ZERO = 96;
  static const int NUM_ONE = 97;
  static const int NUM_TWO = 98;
  static const int NUM_THREE = 99;
  static const int NUM_FOUR = 100;
  static const int NUM_FIVE = 101;
  static const int NUM_SIX = 102;
  static const int NUM_SEVEN = 103;
  static const int NUM_EIGHT = 104;
  static const int NUM_NINE = 105;
  static const int NUM_MULTIPLY = 106;
  static const int NUM_PLUS = 107;
  static const int NUM_MINUS = 109;
  static const int NUM_PERIOD = 110;
  static const int NUM_DIVISION = 111;
  static const int F1 = 112;
  static const int F2 = 113;
  static const int F3 = 114;
  static const int F4 = 115;
  static const int F5 = 116;
  static const int F6 = 117;
  static const int F7 = 118;
  static const int F8 = 119;
  static const int F9 = 120;
  static const int F10 = 121;
  static const int F11 = 122;
  static const int F12 = 123;
  static const int NUMLOCK = 144;
  static const int SCROLL_LOCK = 145;

  // OS-specific media keys like volume controls and browser controls.
  static const int FIRST_MEDIA_KEY = 166;
  static const int LAST_MEDIA_KEY = 183;

  /**
   * CAUTION: This constant requires localization for other locales and keyboard
   * layouts.
   */
  static const int SEMICOLON = 186;
  /**
   * CAUTION: This constant requires localization for other locales and keyboard
   * layouts.
   */
  static const int DASH = 189;
  /**
   * CAUTION: This constant requires localization for other locales and keyboard
   * layouts.
   */
  static const int EQUALS = 187;
  /**
   * CAUTION: This constant requires localization for other locales and keyboard
   * layouts.
   */
  static const int COMMA = 188;
  /**
   * CAUTION: This constant requires localization for other locales and keyboard
   * layouts.
   */
  static const int PERIOD = 190;
  /**
   * CAUTION: This constant requires localization for other locales and keyboard
   * layouts.
   */
  static const int SLASH = 191;
  /**
   * CAUTION: This constant requires localization for other locales and keyboard
   * layouts.
   */
  static const int APOSTROPHE = 192;
  /**
   * CAUTION: This constant requires localization for other locales and keyboard
   * layouts.
   */
  static const int TILDE = 192;
  /**
   * CAUTION: This constant requires localization for other locales and keyboard
   * layouts.
   */
  static const int SINGLE_QUOTE = 222;
  /**
   * CAUTION: This constant requires localization for other locales and keyboard
   * layouts.
   */
  static const int OPEN_SQUARE_BRACKET = 219;
  /**
   * CAUTION: This constant requires localization for other locales and keyboard
   * layouts.
   */
  static const int BACKSLASH = 220;
  /**
   * CAUTION: This constant requires localization for other locales and keyboard
   * layouts.
   */
  static const int CLOSE_SQUARE_BRACKET = 221;
  static const int WIN_KEY = 224;
  static const int MAC_FF_META = 224;
  static const int WIN_IME = 229;

  /** A sentinel value if the keycode could not be determined. */
  static const int UNKNOWN = -1;

  /**
   * Returns true if the keyCode produces a (US keyboard) character.
   * Note: This does not (yet) cover characters on non-US keyboards (Russian,
   * Hebrew, etc.).
   */
  static bool isCharacterKey(int keyCode) {
    if ((keyCode >= ZERO && keyCode <= NINE) ||
        (keyCode >= NUM_ZERO && keyCode <= NUM_MULTIPLY) ||
        (keyCode >= A && keyCode <= Z)) {
      return true;
    }

    // Safari sends zero key code for non-latin characters.
    if (Device.isWebKit && keyCode == 0) {
      return true;
    }

    return (keyCode == SPACE || keyCode == QUESTION_MARK || keyCode == NUM_PLUS
        || keyCode == NUM_MINUS || keyCode == NUM_PERIOD ||
        keyCode == NUM_DIVISION || keyCode == SEMICOLON ||
        keyCode == FF_SEMICOLON || keyCode == DASH || keyCode == EQUALS ||
        keyCode == FF_EQUALS || keyCode == COMMA || keyCode == PERIOD ||
        keyCode == SLASH || keyCode == APOSTROPHE || keyCode == SINGLE_QUOTE ||
        keyCode == OPEN_SQUARE_BRACKET || keyCode == BACKSLASH ||
        keyCode == CLOSE_SQUARE_BRACKET);
  }
}
// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/**
 * Defines the standard key locations returned by
 * KeyboardEvent.getKeyLocation.
 */
abstract class KeyLocation {

  /**
   * The event key is not distinguished as the left or right version
   * of the key, and did not originate from the numeric keypad (or did not
   * originate with a virtual key corresponding to the numeric keypad).
   */
  static const int STANDARD = 0;

  /**
   * The event key is in the left key location.
   */
  static const int LEFT = 1;

  /**
   * The event key is in the right key location.
   */
  static const int RIGHT = 2;

  /**
   * The event key originated on the numeric keypad or with a virtual key
   * corresponding to the numeric keypad.
   */
  static const int NUMPAD = 3;

  /**
   * The event key originated on a mobile device, either on a physical
   * keypad or a virtual keyboard.
   */
  static const int MOBILE = 4;

  /**
   * The event key originated on a game controller or a joystick on a mobile
   * device.
   */
  static const int JOYSTICK = 5;
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/**
 * Defines the standard keyboard identifier names for keys that are returned
 * by KeyEvent.getKeyboardIdentifier when the key does not have a direct
 * unicode mapping.
 */
abstract class KeyName {

  /** The Accept (Commit, OK) key */
  static const String ACCEPT = "Accept";

  /** The Add key */
  static const String ADD = "Add";

  /** The Again key */
  static const String AGAIN = "Again";

  /** The All Candidates key */
  static const String ALL_CANDIDATES = "AllCandidates";

  /** The Alphanumeric key */
  static const String ALPHANUMERIC = "Alphanumeric";

  /** The Alt (Menu) key */
  static const String ALT = "Alt";

  /** The Alt-Graph key */
  static const String ALT_GRAPH = "AltGraph";

  /** The Application key */
  static const String APPS = "Apps";

  /** The ATTN key */
  static const String ATTN = "Attn";

  /** The Browser Back key */
  static const String BROWSER_BACK = "BrowserBack";

  /** The Browser Favorites key */
  static const String BROWSER_FAVORTIES = "BrowserFavorites";

  /** The Browser Forward key */
  static const String BROWSER_FORWARD = "BrowserForward";

  /** The Browser Home key */
  static const String BROWSER_NAME = "BrowserHome";

  /** The Browser Refresh key */
  static const String BROWSER_REFRESH = "BrowserRefresh";

  /** The Browser Search key */
  static const String BROWSER_SEARCH = "BrowserSearch";

  /** The Browser Stop key */
  static const String BROWSER_STOP = "BrowserStop";

  /** The Camera key */
  static const String CAMERA = "Camera";

  /** The Caps Lock (Capital) key */
  static const String CAPS_LOCK = "CapsLock";

  /** The Clear key */
  static const String CLEAR = "Clear";

  /** The Code Input key */
  static const String CODE_INPUT = "CodeInput";

  /** The Compose key */
  static const String COMPOSE = "Compose";

  /** The Control (Ctrl) key */
  static const String CONTROL = "Control";

  /** The Crsel key */
  static const String CRSEL = "Crsel";

  /** The Convert key */
  static const String CONVERT = "Convert";

  /** The Copy key */
  static const String COPY = "Copy";

  /** The Cut key */
  static const String CUT = "Cut";

  /** The Decimal key */
  static const String DECIMAL = "Decimal";

  /** The Divide key */
  static const String DIVIDE = "Divide";

  /** The Down Arrow key */
  static const String DOWN = "Down";

  /** The diagonal Down-Left Arrow key */
  static const String DOWN_LEFT = "DownLeft";

  /** The diagonal Down-Right Arrow key */
  static const String DOWN_RIGHT = "DownRight";

  /** The Eject key */
  static const String EJECT = "Eject";

  /** The End key */
  static const String END = "End";

  /**
   * The Enter key. Note: This key value must also be used for the Return
   *  (Macintosh numpad) key
   */
  static const String ENTER = "Enter";

  /** The Erase EOF key */
  static const String ERASE_EOF= "EraseEof";

  /** The Execute key */
  static const String EXECUTE = "Execute";

  /** The Exsel key */
  static const String EXSEL = "Exsel";

  /** The Function switch key */
  static const String FN = "Fn";

  /** The F1 key */
  static const String F1 = "F1";

  /** The F2 key */
  static const String F2 = "F2";

  /** The F3 key */
  static const String F3 = "F3";

  /** The F4 key */
  static const String F4 = "F4";

  /** The F5 key */
  static const String F5 = "F5";

  /** The F6 key */
  static const String F6 = "F6";

  /** The F7 key */
  static const String F7 = "F7";

  /** The F8 key */
  static const String F8 = "F8";

  /** The F9 key */
  static const String F9 = "F9";

  /** The F10 key */
  static const String F10 = "F10";

  /** The F11 key */
  static const String F11 = "F11";

  /** The F12 key */
  static const String F12 = "F12";

  /** The F13 key */
  static const String F13 = "F13";

  /** The F14 key */
  static const String F14 = "F14";

  /** The F15 key */
  static const String F15 = "F15";

  /** The F16 key */
  static const String F16 = "F16";

  /** The F17 key */
  static const String F17 = "F17";

  /** The F18 key */
  static const String F18 = "F18";

  /** The F19 key */
  static const String F19 = "F19";

  /** The F20 key */
  static const String F20 = "F20";

  /** The F21 key */
  static const String F21 = "F21";

  /** The F22 key */
  static const String F22 = "F22";

  /** The F23 key */
  static const String F23 = "F23";

  /** The F24 key */
  static const String F24 = "F24";

  /** The Final Mode (Final) key used on some asian keyboards */
  static const String FINAL_MODE = "FinalMode";

  /** The Find key */
  static const String FIND = "Find";

  /** The Full-Width Characters key */
  static const String FULL_WIDTH = "FullWidth";

  /** The Half-Width Characters key */
  static const String HALF_WIDTH = "HalfWidth";

  /** The Hangul (Korean characters) Mode key */
  static const String HANGUL_MODE = "HangulMode";

  /** The Hanja (Korean characters) Mode key */
  static const String HANJA_MODE = "HanjaMode";

  /** The Help key */
  static const String HELP = "Help";

  /** The Hiragana (Japanese Kana characters) key */
  static const String HIRAGANA = "Hiragana";

  /** The Home key */
  static const String HOME = "Home";

  /** The Insert (Ins) key */
  static const String INSERT = "Insert";

  /** The Japanese-Hiragana key */
  static const String JAPANESE_HIRAGANA = "JapaneseHiragana";

  /** The Japanese-Katakana key */
  static const String JAPANESE_KATAKANA = "JapaneseKatakana";

  /** The Japanese-Romaji key */
  static const String JAPANESE_ROMAJI = "JapaneseRomaji";

  /** The Junja Mode key */
  static const String JUNJA_MODE = "JunjaMode";

  /** The Kana Mode (Kana Lock) key */
  static const String KANA_MODE = "KanaMode";

  /**
   * The Kanji (Japanese name for ideographic characters of Chinese origin)
   * Mode key
   */
  static const String KANJI_MODE = "KanjiMode";

  /** The Katakana (Japanese Kana characters) key */
  static const String KATAKANA = "Katakana";

  /** The Start Application One key */
  static const String LAUNCH_APPLICATION_1 = "LaunchApplication1";

  /** The Start Application Two key */
  static const String LAUNCH_APPLICATION_2 = "LaunchApplication2";

  /** The Start Mail key */
  static const String LAUNCH_MAIL = "LaunchMail";

  /** The Left Arrow key */
  static const String LEFT = "Left";

  /** The Menu key */
  static const String MENU = "Menu";

  /**
   * The Meta key. Note: This key value shall be also used for the Apple
   * Command key
   */
  static const String META = "Meta";

  /** The Media Next Track key */
  static const String MEDIA_NEXT_TRACK = "MediaNextTrack";

  /** The Media Play Pause key */
  static const String MEDIA_PAUSE_PLAY = "MediaPlayPause";

  /** The Media Previous Track key */
  static const String MEDIA_PREVIOUS_TRACK = "MediaPreviousTrack";

  /** The Media Stop key */
  static const String MEDIA_STOP = "MediaStop";

  /** The Mode Change key */
  static const String MODE_CHANGE = "ModeChange";

  /** The Next Candidate function key */
  static const String NEXT_CANDIDATE = "NextCandidate";

  /** The Nonconvert (Don't Convert) key */
  static const String NON_CONVERT = "Nonconvert";

  /** The Number Lock key */
  static const String NUM_LOCK = "NumLock";

  /** The Page Down (Next) key */
  static const String PAGE_DOWN = "PageDown";

  /** The Page Up key */
  static const String PAGE_UP = "PageUp";

  /** The Paste key */
  static const String PASTE = "Paste";

  /** The Pause key */
  static const String PAUSE = "Pause";

  /** The Play key */
  static const String PLAY = "Play";

  /**
   * The Power key. Note: Some devices may not expose this key to the
   * operating environment
   */
  static const String POWER = "Power";

  /** The Previous Candidate function key */
  static const String PREVIOUS_CANDIDATE = "PreviousCandidate";

  /** The Print Screen (PrintScrn, SnapShot) key */
  static const String PRINT_SCREEN = "PrintScreen";

  /** The Process key */
  static const String PROCESS = "Process";

  /** The Props key */
  static const String PROPS = "Props";

  /** The Right Arrow key */
  static const String RIGHT = "Right";

  /** The Roman Characters function key */
  static const String ROMAN_CHARACTERS = "RomanCharacters";

  /** The Scroll Lock key */
  static const String SCROLL = "Scroll";

  /** The Select key */
  static const String SELECT = "Select";

  /** The Select Media key */
  static const String SELECT_MEDIA = "SelectMedia";

  /** The Separator key */
  static const String SEPARATOR = "Separator";

  /** The Shift key */
  static const String SHIFT = "Shift";

  /** The Soft1 key */
  static const String SOFT_1 = "Soft1";

  /** The Soft2 key */
  static const String SOFT_2 = "Soft2";

  /** The Soft3 key */
  static const String SOFT_3 = "Soft3";

  /** The Soft4 key */
  static const String SOFT_4 = "Soft4";

  /** The Stop key */
  static const String STOP = "Stop";

  /** The Subtract key */
  static const String SUBTRACT = "Subtract";

  /** The Symbol Lock key */
  static const String SYMBOL_LOCK = "SymbolLock";

  /** The Up Arrow key */
  static const String UP = "Up";

  /** The diagonal Up-Left Arrow key */
  static const String UP_LEFT = "UpLeft";

  /** The diagonal Up-Right Arrow key */
  static const String UP_RIGHT = "UpRight";

  /** The Undo key */
  static const String UNDO = "Undo";

  /** The Volume Down key */
  static const String VOLUME_DOWN = "VolumeDown";

  /** The Volume Mute key */
  static const String VOLUMN_MUTE = "VolumeMute";

  /** The Volume Up key */
  static const String VOLUMN_UP = "VolumeUp";

  /** The Windows Logo key */
  static const String WIN = "Win";

  /** The Zoom key */
  static const String ZOOM = "Zoom";

  /**
   * The Backspace (Back) key. Note: This key value shall be also used for the
   * key labeled 'delete' MacOS keyboards when not modified by the 'Fn' key
   */
  static const String BACKSPACE = "Backspace";

  /** The Horizontal Tabulation (Tab) key */
  static const String TAB = "Tab";

  /** The Cancel key */
  static const String CANCEL = "Cancel";

  /** The Escape (Esc) key */
  static const String ESC = "Esc";

  /** The Space (Spacebar) key:   */
  static const String SPACEBAR = "Spacebar";

  /**
   * The Delete (Del) Key. Note: This key value shall be also used for the key
   * labeled 'delete' MacOS keyboards when modified by the 'Fn' key
   */
  static const String DEL = "Del";

  /** The Combining Grave Accent (Greek Varia, Dead Grave) key */
  static const String DEAD_GRAVE = "DeadGrave";

  /**
   * The Combining Acute Accent (Stress Mark, Greek Oxia, Tonos, Dead Eacute)
   * key
   */
  static const String DEAD_EACUTE = "DeadEacute";

  /** The Combining Circumflex Accent (Hat, Dead Circumflex) key */
  static const String DEAD_CIRCUMFLEX = "DeadCircumflex";

  /** The Combining Tilde (Dead Tilde) key */
  static const String DEAD_TILDE = "DeadTilde";

  /** The Combining Macron (Long, Dead Macron) key */
  static const String DEAD_MACRON = "DeadMacron";

  /** The Combining Breve (Short, Dead Breve) key */
  static const String DEAD_BREVE = "DeadBreve";

  /** The Combining Dot Above (Derivative, Dead Above Dot) key */
  static const String DEAD_ABOVE_DOT = "DeadAboveDot";

  /**
   * The Combining Diaeresis (Double Dot Abode, Umlaut, Greek Dialytika,
   * Double Derivative, Dead Diaeresis) key
   */
  static const String DEAD_UMLAUT = "DeadUmlaut";

  /** The Combining Ring Above (Dead Above Ring) key */
  static const String DEAD_ABOVE_RING = "DeadAboveRing";

  /** The Combining Double Acute Accent (Dead Doubleacute) key */
  static const String DEAD_DOUBLEACUTE = "DeadDoubleacute";

  /** The Combining Caron (Hacek, V Above, Dead Caron) key */
  static const String DEAD_CARON = "DeadCaron";

  /** The Combining Cedilla (Dead Cedilla) key */
  static const String DEAD_CEDILLA = "DeadCedilla";

  /** The Combining Ogonek (Nasal Hook, Dead Ogonek) key */
  static const String DEAD_OGONEK = "DeadOgonek";

  /**
   * The Combining Greek Ypogegrammeni (Greek Non-Spacing Iota Below, Iota
   * Subscript, Dead Iota) key
   */
  static const String DEAD_IOTA = "DeadIota";

  /**
   * The Combining Katakana-Hiragana Voiced Sound Mark (Dead Voiced Sound) key
   */
  static const String DEAD_VOICED_SOUND = "DeadVoicedSound";

  /**
   * The Combining Katakana-Hiragana Semi-Voiced Sound Mark (Dead Semivoiced
   * Sound) key
   */
  static const String DEC_SEMIVOICED_SOUND= "DeadSemivoicedSound";

  /**
   * Key value used when an implementation is unable to identify another key
   * value, due to either hardware, platform, or software constraints
   */
  static const String UNIDENTIFIED = "Unidentified";
}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


// This code is inspired by ChangeSummary:
// https://github.com/rafaelw/ChangeSummary/blob/master/change_summary.js
// ...which underlies MDV. Since we don't need the functionality of
// ChangeSummary, we just implement what we need for data bindings.
// This allows our implementation to be much simpler.

// TODO(jmesserly): should we make these types stronger, and require
// Observable objects? Currently, it is fine to say something like:
//     var path = new PathObserver(123, '');
//     print(path.value); // "123"
//
// Furthermore this degenerate case is allowed:
//     var path = new PathObserver(123, 'foo.bar.baz.qux');
//     print(path.value); // "null"
//
// Here we see that any invalid (i.e. not Observable) value will break the
// path chain without producing an error or exception.
//
// Now the real question: should we do this? For the former case, the behavior
// is correct but we could chose to handle it in the dart:html bindings layer.
// For the latter case, it might be better to throw an error so users can find
// the problem.


/**
 * A data-bound path starting from a view-model or model object, for example
 * `foo.bar.baz`.
 *
 * When the [values] stream is being listened to, this will observe changes to
 * the object and any intermediate object along the path, and send [values]
 * accordingly. When all listeners are unregistered it will stop observing
 * the objects.
 *
 * This class is used to implement [Node.bind] and similar functionality.
 */
// TODO(jmesserly): find a better home for this type.
@Experimental
class PathObserver {
  /** The object being observed. */
  final object;

  /** The path string. */
  final String path;

  /** True if the path is valid, otherwise false. */
  final bool _isValid;

  // TODO(jmesserly): same issue here as ObservableMixin: is there an easier
  // way to get a broadcast stream?
  StreamController _values;
  Stream _valueStream;

  _PropertyObserver _observer, _lastObserver;

  Object _lastValue;
  bool _scheduled = false;

  /**
   * Observes [path] on [object] for changes. This returns an object that can be
   * used to get the changes and get/set the value at this path.
   * See [PathObserver.values] and [PathObserver.value].
   */
  PathObserver(this.object, String path)
    : path = path, _isValid = _isPathValid(path) {

    // TODO(jmesserly): if the path is empty, or the object is! Observable, we
    // can optimize the PathObserver to be more lightweight.

    _values = new StreamController(onListen: _observe, onCancel: _unobserve);

    if (_isValid) {
      var segments = [];
      for (var segment in path.trim().split('.')) {
        if (segment == '') continue;
        var index = int.parse(segment, onError: (_) {});
        segments.add(index != null ? index : new Symbol(segment));
      }

      // Create the property observer linked list.
      // Note that the structure of a path can't change after it is initially
      // constructed, even though the objects along the path can change.
      for (int i = segments.length - 1; i >= 0; i--) {
        _observer = new _PropertyObserver(this, segments[i], _observer);
        if (_lastObserver == null) _lastObserver = _observer;
      }
    }
  }

  // TODO(jmesserly): we could try adding the first value to the stream, but
  // that delivers the first record async.
  /**
   * Listens to the stream, and invokes the [callback] immediately with the
   * current [value]. This is useful for bindings, which want to be up-to-date
   * immediately.
   */
  StreamSubscription bindSync(void callback(value)) {
    var result = values.listen(callback);
    callback(value);
    return result;
  }

  // TODO(jmesserly): should this be a change record with the old value?
  // TODO(jmesserly): should this be a broadcast stream? We only need
  // single-subscription in the bindings system, so single sub saves overhead.
  /**
   * Gets the stream of values that were observed at this path.
   * This returns a single-subscription stream.
   */
  Stream get values => _values.stream;

  /** Force synchronous delivery of [values]. */
  void _deliverValues() {
    _scheduled = false;

    var newValue = value;
    if (!identical(_lastValue, newValue)) {
      _values.add(newValue);
      _lastValue = newValue;
    }
  }

  void _observe() {
    if (_observer != null) {
      _lastValue = value;
      _observer.observe();
    }
  }

  void _unobserve() {
    if (_observer != null) _observer.unobserve();
  }

  void _notifyChange() {
    if (_scheduled) return;
    _scheduled = true;

    // TODO(jmesserly): should we have a guarenteed order with respect to other
    // paths? If so, we could implement this fairly easily by sorting instances
    // of this class by birth order before delivery.
    queueChangeRecords(_deliverValues);
  }

  /** Gets the last reported value at this path. */
  get value {
    if (!_isValid) return null;
    if (_observer == null) return object;
    _observer.ensureValue(object);
    return _lastObserver.value;
  }

  /** Sets the value at this path. */
  void set value(Object value) {
    // TODO(jmesserly): throw if property cannot be set?
    // MDV seems tolerant of these error.
    if (_observer == null || !_isValid) return;
    _observer.ensureValue(object);
    var last = _lastObserver;
    if (_setObjectProperty(last._object, last._property, value)) {
      // Technically, this would get updated asynchronously via a change record.
      // However, it is nice if calling the getter will yield the same value
      // that was just set. So we use this opportunity to update our cache.
      last.value = value;
    }
  }
}

// TODO(jmesserly): these should go away in favor of mirrors!
_getObjectProperty(object, property) {
  if (object is List && property is int) {
    if (property >= 0 && property < object.length) {
      return object[property];
    } else {
      return null;
    }
  }

  // TODO(jmesserly): what about length?
  if (object is Map) return object[property];

  if (object is Observable) return object.getValueWorkaround(property);

  return null;
}

bool _setObjectProperty(object, property, value) {
  if (object is List && property is int) {
    object[property] = value;
  } else if (object is Map) {
    object[property] = value;
  } else if (object is Observable) {
    (object as Observable).setValueWorkaround(property, value);
  } else {
    return false;
  }
  return true;
}


class _PropertyObserver {
  final PathObserver _path;
  final _property;
  final _PropertyObserver _next;

  // TODO(jmesserly): would be nice not to store both of these.
  Object _object;
  Object _value;
  StreamSubscription _sub;

  _PropertyObserver(this._path, this._property, this._next);

  get value => _value;

  void set value(Object newValue) {
    _value = newValue;
    if (_next != null) {
      if (_sub != null) _next.unobserve();
      _next.ensureValue(_value);
      if (_sub != null) _next.observe();
    }
  }

  void ensureValue(object) {
    // If we're observing, values should be up to date already.
    if (_sub != null) return;

    _object = object;
    value = _getObjectProperty(object, _property);
  }

  void observe() {
    if (_object is Observable) {
      assert(_sub == null);
      _sub = (_object as Observable).changes.listen(_onChange);
    }
    if (_next != null) _next.observe();
  }

  void unobserve() {
    if (_sub == null) return;

    _sub.cancel();
    _sub = null;
    if (_next != null) _next.unobserve();
  }

  void _onChange(List<ChangeRecord> changes) {
    for (var change in changes) {
      // TODO(jmesserly): what to do about "new Symbol" here?
      // Ideally this would only preserve names if the user has opted in to
      // them being preserved.
      // TODO(jmesserly): should we drop observable maps with String keys?
      // If so then we only need one check here.
      if (change.changes(_property)) {
        value = _getObjectProperty(_object, _property);
        _path._notifyChange();
        return;
      }
    }
  }
}

// From: https://github.com/rafaelw/ChangeSummary/blob/master/change_summary.js

const _pathIndentPart = r'[$a-z0-9_]+[$a-z0-9_\d]*';
final _pathRegExp = new RegExp('^'
    '(?:#?' + _pathIndentPart + ')?'
    '(?:'
      '(?:\\.' + _pathIndentPart + ')'
    ')*'
    r'$', caseSensitive: false);

final _spacesRegExp = new RegExp(r'\s');

bool _isPathValid(String s) {
  s = s.replaceAll(_spacesRegExp, '');

  if (s == '') return true;
  if (s[0] == '.') return false;
  return _pathRegExp.hasMatch(s);
}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/**
 * A utility class for representing two-dimensional positions.
 */
class Point {
  final num x;
  final num y;

  const Point([num x = 0, num y = 0]): x = x, y = y;

  String toString() => '($x, $y)';

  bool operator ==(other) {
    if (other is !Point) return false;
    return x == other.x && y == other.y;
  }

  Point operator +(Point other) {
    return new Point(x + other.x, y + other.y);
  }

  Point operator -(Point other) {
    return new Point(x - other.x, y - other.y);
  }

  Point operator *(num factor) {
    return new Point(x * factor, y * factor);
  }

  /**
   * Returns the distance between two points.
   */
  double distanceTo(Point other) {
    var dx = x - other.x;
    var dy = y - other.y;
    return sqrt(dx * dx + dy * dy);
  }

  /**
   * Returns the squared distance between two points.
   *
   * Squared distances can be used for comparisons when the actual value is not
   * required.
   */
  num squaredDistanceTo(Point other) {
    var dx = x - other.x;
    var dy = y - other.y;
    return dx * dx + dy * dy;
  }

  Point ceil() => new Point(x.ceil(), y.ceil());
  Point floor() => new Point(x.floor(), y.floor());
  Point round() => new Point(x.round(), y.round());

  /**
   * Truncates x and y to integers and returns the result as a new point.
   */
  Point toInt() => new Point(x.toInt(), y.toInt());
}
// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/**
 * Contains the set of standard values returned by HTMLDocument.getReadyState.
 */
abstract class ReadyState {
  /**
   * Indicates the document is still loading and parsing.
   */
  static const String LOADING = "loading";

  /**
   * Indicates the document is finished parsing but is still loading
   * subresources.
   */
  static const String INTERACTIVE = "interactive";

  /**
   * Indicates the document and all subresources have been loaded.
   */
  static const String COMPLETE = "complete";
}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/**
 * A class for representing two-dimensional rectangles.
 */
class Rect {
  final num left;
  final num top;
  final num width;
  final num height;

  const Rect(this.left, this.top, this.width, this.height);

  factory Rect.fromPoints(Point a, Point b) {
    var left;
    var width;
    if (a.x < b.x) {
      left = a.x;
      width = b.x - left;
    } else {
      left = b.x;
      width = a.x - left;
    }
    var top;
    var height;
    if (a.y < b.y) {
      top = a.y;
      height = b.y - top;
    } else {
      top = b.y;
      height = a.y - top;
    }

    return new Rect(left, top, width, height);
  }

  num get right => left + width;
  num get bottom => top + height;

  // NOTE! All code below should be common with Rect.
  // TODO: implement with mixins when available.

  String toString() {
    return '($left, $top, $width, $height)';
  }

  bool operator ==(other) {
    if (other is !Rect) return false;
    return left == other.left && top == other.top && width == other.width &&
        height == other.height;
  }

  /**
   * Computes the intersection of this rectangle and the rectangle parameter.
   * Returns null if there is no intersection.
   */
  Rect intersection(Rect rect) {
    var x0 = max(left, rect.left);
    var x1 = min(left + width, rect.left + rect.width);

    if (x0 <= x1) {
      var y0 = max(top, rect.top);
      var y1 = min(top + height, rect.top + rect.height);

      if (y0 <= y1) {
        return new Rect(x0, y0, x1 - x0, y1 - y0);
      }
    }
    return null;
  }


  /**
   * Returns whether a rectangle intersects this rectangle.
   */
  bool intersects(Rect other) {
    return (left <= other.left + other.width && other.left <= left + width &&
        top <= other.top + other.height && other.top <= top + height);
  }

  /**
   * Returns a new rectangle which completely contains this rectangle and the
   * input rectangle.
   */
  Rect union(Rect rect) {
    var right = max(this.left + this.width, rect.left + rect.width);
    var bottom = max(this.top + this.height, rect.top + rect.height);

    var left = min(this.left, rect.left);
    var top = min(this.top, rect.top);

    return new Rect(left, top, right - left, bottom - top);
  }

  /**
   * Tests whether this rectangle entirely contains another rectangle.
   */
  bool containsRect(Rect another) {
    return left <= another.left &&
           left + width >= another.left + another.width &&
           top <= another.top &&
           top + height >= another.top + another.height;
  }

  /**
   * Tests whether this rectangle entirely contains a point.
   */
  bool containsPoint(Point another) {
    return another.x >= left &&
           another.x <= left + width &&
           another.y >= top &&
           another.y <= top + height;
  }

  Rect ceil() => new Rect(left.ceil(), top.ceil(), width.ceil(), height.ceil());
  Rect floor() => new Rect(left.floor(), top.floor(), width.floor(),
      height.floor());
  Rect round() => new Rect(left.round(), top.round(), width.round(),
      height.round());

  /**
   * Truncates coordinates to integers and returns the result as a new
   * rectangle.
   */
  Rect toInt() => new Rect(left.toInt(), top.toInt(), width.toInt(),
      height.toInt());

  Point get topLeft => new Point(this.left, this.top);
  Point get bottomRight => new Point(this.left + this.width,
      this.top + this.height);
}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


// This code is a port of Model-Driven-Views:
// https://github.com/toolkitchen/mdv
// The code mostly comes from src/template_element.js

typedef void _ChangeHandler(value);

/**
 * Model-Driven Views (MDV)'s native features enables a wide-range of use cases,
 * but (by design) don't attempt to implement a wide array of specialized
 * behaviors.
 *
 * Enabling these features in MDV is a matter of implementing and registering an
 * MDV Custom Syntax. A Custom Syntax is an object which contains one or more
 * delegation functions which implement specialized behavior. This object is
 * registered with MDV via [TemplateElement.syntax]:
 *
 *
 * HTML:
 *     <template bind syntax="MySyntax">
 *       {{ What!Ever('crazy')->thing^^^I+Want(data) }}
 *     </template>
 *
 * Dart:
 *     class MySyntax extends CustomBindingSyntax {
 *       getBinding(model, path, name, node) {
 *         // The magic happens here!
 *       }
 *     }
 *
 *     ...
 *
 *     TemplateElement.syntax['MySyntax'] = new MySyntax();
 *
 * See <https://github.com/toolkitchen/mdv/blob/master/docs/syntax.md> for more
 * information about Custom Syntax.
 */
// TODO(jmesserly): if this is just one method, a function type would make it
// more Dart-friendly.
@Experimental
abstract class CustomBindingSyntax {
  /**
   * This syntax method allows for a custom interpretation of the contents of
   * mustaches (`{{` ... `}}`).
   *
   * When a template is inserting an instance, it will invoke this method for
   * each mustache which is encountered. The function is invoked with four
   * arguments:
   *
   * - [model]: The data context for which this instance is being created.
   * - [path]: The text contents (trimmed of outer whitespace) of the mustache.
   * - [name]: The context in which the mustache occurs. Within element
   *   attributes, this will be the name of the attribute. Within text,
   *   this will be 'text'.
   * - [node]: A reference to the node to which this binding will be created.
   *
   * If the method wishes to handle binding, it is required to return an object
   * which has at least a `value` property that can be observed. If it does,
   * then MDV will call [Node.bind on the node:
   *
   *     node.bind(name, retval, 'value');
   *
   * If the 'getBinding' does not wish to override the binding, it should return
   * null.
   */
  // TODO(jmesserly): I had to remove type annotations from "name" and "node"
  // Normally they are String and Node respectively. But sometimes it will pass
  // (int name, CompoundBinding node). That seems very confusing; we may want
  // to change this API.
  getBinding(model, String path, name, node) => null;

  /**
   * This syntax method allows a syntax to provide an alterate model than the
   * one the template would otherwise use when producing an instance.
   *
   * When a template is about to create an instance, it will invoke this method
   * The function is invoked with two arguments:
   *
   * - [template]: The template element which is about to create and insert an
   *   instance.
   * - [model]: The data context for which this instance is being created.
   *
   * The template element will always use the return value of `getInstanceModel`
   * as the model for the new instance. If the syntax does not wish to override
   * the value, it should simply return the `model` value it was passed.
   */
  getInstanceModel(Element template, model) => model;

  /**
   * This syntax method allows a syntax to provide an alterate expansion of
   * the [template] contents. When the template wants to create an instance,
   * it will call this method with the template element.
   *
   * By default this will call `template.createInstance()`.
   */
  getInstanceFragment(Element template) => template.createInstance();
}

/** The callback used in the [CompoundBinding.combinator] field. */
@Experimental
typedef Object CompoundBindingCombinator(Map objects);

/** Information about the instantiated template. */
@Experimental
class TemplateInstance {
  // TODO(rafaelw): firstNode & lastNode should be read-synchronous
  // in cases where script has modified the template instance boundary.

  /** The first node of this template instantiation. */
  final Node firstNode;

  /**
   * The last node of this template instantiation.
   * This could be identical to [firstNode] if the template only expanded to a
   * single node.
   */
  final Node lastNode;

  /** The model used to instantiate the template. */
  final model;

  TemplateInstance(this.firstNode, this.lastNode, this.model);
}

/**
 * Model-Driven Views contains a helper object which is useful for the
 * implementation of a Custom Syntax.
 *
 *     var binding = new CompoundBinding((values) {
 *       var combinedValue;
 *       // compute combinedValue based on the current values which are provided
 *       return combinedValue;
 *     });
 *     binding.bind('name1', obj1, path1);
 *     binding.bind('name2', obj2, path2);
 *     //...
 *     binding.bind('nameN', objN, pathN);
 *
 * CompoundBinding is an object which knows how to listen to multiple path
 * values (registered via [bind]) and invoke its [combinator] when one or more
 * of the values have changed and set its [value] property to the return value
 * of the function. When any value has changed, all current values are provided
 * to the [combinator] in the single `values` argument.
 *
 * See [CustomBindingSyntax] for more information.
 */
// TODO(jmesserly): what is the public API surface here? I just guessed;
// most of it seemed non-public.
@Experimental
class CompoundBinding extends ObservableBase {
  CompoundBindingCombinator _combinator;

  // TODO(jmesserly): ideally these would be String keys, but sometimes we
  // use integers.
  Map<dynamic, StreamSubscription> _bindings = new Map();
  Map _values = new Map();
  bool _scheduled = false;
  bool _disposed = false;
  Object _value;

  CompoundBinding([CompoundBindingCombinator combinator]) {
    // TODO(jmesserly): this is a tweak to the original code, it seemed to me
    // that passing the combinator to the constructor should be equivalent to
    // setting it via the property.
    // I also added a null check to the combinator setter.
    this.combinator = combinator;
  }

  CompoundBindingCombinator get combinator => _combinator;

  set combinator(CompoundBindingCombinator combinator) {
    _combinator = combinator;
    if (combinator != null) _scheduleResolve();
  }

  static const _VALUE = const Symbol('value');

  get value => _value;

  void set value(newValue) {
    _value = notifyPropertyChange(_VALUE, _value, newValue);
  }

  // TODO(jmesserly): remove these workarounds when dart2js supports mirrors!
  getValueWorkaround(key) {
    if (key == _VALUE) return value;
    return null;
  }
  setValueWorkaround(key, val) {
    if (key == _VALUE) value = val;
  }

  void bind(name, model, String path) {
    unbind(name);

    _bindings[name] = new PathObserver(model, path).bindSync((value) {
      _values[name] = value;
      _scheduleResolve();
    });
  }

  void unbind(name, {bool suppressResolve: false}) {
    var binding = _bindings.remove(name);
    if (binding == null) return;

    binding.cancel();
    _values.remove(name);
    if (!suppressResolve) _scheduleResolve();
  }

  // TODO(rafaelw): Is this the right processing model?
  // TODO(rafaelw): Consider having a seperate ChangeSummary for
  // CompoundBindings so to excess dirtyChecks.
  void _scheduleResolve() {
    if (_scheduled) return;
    _scheduled = true;
    queueChangeRecords(resolve);
  }

  void resolve() {
    if (_disposed) return;
    _scheduled = false;

    if (_combinator == null) {
      throw new StateError(
          'CompoundBinding attempted to resolve without a combinator');
    }

    value = _combinator(_values);
  }

  void dispose() {
    for (var binding in _bindings.values) {
      binding.cancel();
    }
    _bindings.clear();
    _values.clear();

    _disposed = true;
    value = null;
  }
}

abstract class _InputBinding {
  final InputElement element;
  PathObserver binding;
  StreamSubscription _pathSub;
  StreamSubscription _eventSub;

  _InputBinding(this.element, model, String path) {
    binding = new PathObserver(model, path);
    _pathSub = binding.bindSync(valueChanged);
    _eventSub = _getStreamForInputType(element).listen(updateBinding);
  }

  void valueChanged(newValue);

  void updateBinding(e);

  void unbind() {
    binding = null;
    _pathSub.cancel();
    _eventSub.cancel();
  }


  static Stream<Event> _getStreamForInputType(InputElement element) {
    switch (element.type) {
      case 'checkbox':
        return element.onClick;
      case 'radio':
      case 'select-multiple':
      case 'select-one':
        return element.onChange;
      default:
        return element.onInput;
    }
  }
}

class _ValueBinding extends _InputBinding {
  _ValueBinding(element, model, path) : super(element, model, path);

  void valueChanged(value) {
    element.value = value == null ? '' : '$value';
  }

  void updateBinding(e) {
    binding.value = element.value;
  }
}

class _CheckedBinding extends _InputBinding {
  _CheckedBinding(element, model, path) : super(element, model, path);

  void valueChanged(value) {
    element.checked = _Bindings._toBoolean(value);
  }

  void updateBinding(e) {
    binding.value = element.checked;

    // Only the radio button that is getting checked gets an event. We
    // therefore find all the associated radio buttons and update their
    // CheckedBinding manually.
    if (element is InputElement && element.type == 'radio') {
      for (var r in _getAssociatedRadioButtons(element)) {
        var checkedBinding = r._checkedBinding;
        if (checkedBinding != null) {
          // Set the value directly to avoid an infinite call stack.
          checkedBinding.binding.value = false;
        }
      }
    }
  }

  // |element| is assumed to be an HTMLInputElement with |type| == 'radio'.
  // Returns an array containing all radio buttons other than |element| that
  // have the same |name|, either in the form that |element| belongs to or,
  // if no form, in the document tree to which |element| belongs.
  //
  // This implementation is based upon the HTML spec definition of a
  // "radio button group":
  //   http://www.whatwg.org/specs/web-apps/current-work/multipage/number-state.html#radio-button-group
  //
  static Iterable _getAssociatedRadioButtons(element) {
    if (!_isNodeInDocument(element)) return [];
    if (element.form != null) {
      return element.form.nodes.where((el) {
        return el != element &&
            el is InputElement &&
            el.type == 'radio' &&
            el.name == element.name;
      });
    } else {
      var radios = element.document.queryAll(
          'input[type="radio"][name="${element.name}"]');
      return radios.where((el) => el != element && el.form == null);
    }
  }

  // TODO(jmesserly): polyfill document.contains API instead of doing it here
  static bool _isNodeInDocument(Node node) {
    // On non-IE this works:
    // return node.document.contains(node);
    var document = node.document;
    if (node == document || node.parentNode == document) return true;
    return document.documentElement.contains(node);
  }
}

class _Bindings {
  // TODO(jmesserly): not sure what kind of boolean conversion rules to
  // apply for template data-binding. HTML attributes are true if they're
  // present. However Dart only treats "true" as true. Since this is HTML we'll
  // use something closer to the HTML rules: null (missing) and false are false,
  // everything else is true. See: https://github.com/toolkitchen/mdv/issues/59
  static bool _toBoolean(value) => null != value && false != value;

  static Node _createDeepCloneAndDecorateTemplates(Node node, String syntax) {
    var clone = node.clone(false); // Shallow clone.
    if (clone is Element && clone.isTemplate) {
      TemplateElement.decorate(clone, node);
      if (syntax != null) {
        clone.attributes.putIfAbsent('syntax', () => syntax);
      }
    }

    for (var c = node.$dom_firstChild; c != null; c = c.nextNode) {
      clone.append(_createDeepCloneAndDecorateTemplates(c, syntax));
    }
    return clone;
  }

  // http://dvcs.w3.org/hg/webcomponents/raw-file/tip/spec/templates/index.html#dfn-template-contents-owner
  static Document _getTemplateContentsOwner(Document doc) {
    if (doc.window == null) {
      return doc;
    }
    var d = doc._templateContentsOwner;
    if (d == null) {
      // TODO(arv): This should either be a Document or HTMLDocument depending
      // on doc.
      d = doc.implementation.createHtmlDocument('');
      while (d.$dom_lastChild != null) {
        d.$dom_lastChild.remove();
      }
      doc._templateContentsOwner = d;
    }
    return d;
  }

  static Element _cloneAndSeperateAttributeTemplate(Element templateElement) {
    var clone = templateElement.clone(false);
    var attributes = templateElement.attributes;
    for (var name in attributes.keys.toList()) {
      switch (name) {
        case 'template':
        case 'repeat':
        case 'bind':
        case 'ref':
          clone.attributes.remove(name);
          break;
        default:
          attributes.remove(name);
          break;
      }
    }

    return clone;
  }

  static void _liftNonNativeChildrenIntoContent(Element templateElement) {
    var content = templateElement.content;

    if (!templateElement._isAttributeTemplate) {
      var child;
      while ((child = templateElement.$dom_firstChild) != null) {
        content.append(child);
      }
      return;
    }

    // For attribute templates we copy the whole thing into the content and
    // we move the non template attributes into the content.
    //
    //   <tr foo template>
    //
    // becomes
    //
    //   <tr template>
    //   + #document-fragment
    //     + <tr foo>
    //
    var newRoot = _cloneAndSeperateAttributeTemplate(templateElement);
    var child;
    while ((child = templateElement.$dom_firstChild) != null) {
      newRoot.append(child);
    }
    content.append(newRoot);
  }

  static void _bootstrapTemplatesRecursivelyFrom(Node node) {
    void bootstrap(template) {
      if (!TemplateElement.decorate(template)) {
        _bootstrapTemplatesRecursivelyFrom(template.content);
      }
    }

    // Need to do this first as the contents may get lifted if |node| is
    // template.
    // TODO(jmesserly): node is DocumentFragment or Element
    var descendents = (node as dynamic).queryAll(_allTemplatesSelectors);
    if (node is Element && node.isTemplate) bootstrap(node);

    descendents.forEach(bootstrap);
  }

  static final String _allTemplatesSelectors = 'template, option[template], ' +
      Element._TABLE_TAGS.keys.map((k) => "$k[template]").join(", ");

  static void _addBindings(Node node, model, [CustomBindingSyntax syntax]) {
    if (node is Element) {
      _addAttributeBindings(node, model, syntax);
    } else if (node is Text) {
      _parseAndBind(node, 'text', node.text, model, syntax);
    }

    for (var c = node.$dom_firstChild; c != null; c = c.nextNode) {
      _addBindings(c, model, syntax);
    }
  }

  static void _addAttributeBindings(Element element, model, syntax) {
    element.attributes.forEach((name, value) {
      if (value == '' && (name == 'bind' || name == 'repeat')) {
        value = '{{}}';
      }
      _parseAndBind(element, name, value, model, syntax);
    });
  }

  static void _parseAndBind(Node node, String name, String text, model,
      CustomBindingSyntax syntax) {

    var tokens = _parseMustacheTokens(text);
    if (tokens.length == 0 || (tokens.length == 1 && tokens[0].isText)) {
      return;
    }

    if (tokens.length == 1 && tokens[0].isBinding) {
      _bindOrDelegate(node, name, model, tokens[0].value, syntax);
      return;
    }

    var replacementBinding = new CompoundBinding();
    for (var i = 0; i < tokens.length; i++) {
      var token = tokens[i];
      if (token.isBinding) {
        _bindOrDelegate(replacementBinding, i, model, token.value, syntax);
      }
    }

    replacementBinding.combinator = (values) {
      var newValue = new StringBuffer();

      for (var i = 0; i < tokens.length; i++) {
        var token = tokens[i];
        if (token.isText) {
          newValue.write(token.value);
        } else {
          var value = values[i];
          if (value != null) {
            newValue.write(value);
          }
        }
      }

      return newValue.toString();
    };

    _nodeOrCustom(node).bind(name, replacementBinding, 'value');
  }

  static void _bindOrDelegate(node, name, model, String path,
      CustomBindingSyntax syntax) {

    if (syntax != null) {
      var delegateBinding = syntax.getBinding(model, path, name, node);
      if (delegateBinding != null) {
        model = delegateBinding;
        path = 'value';
      }
    }

    _nodeOrCustom(node).bind(name, model, path);
  }

  /**
   * Gets the [node]'s custom [Element.xtag] if present, otherwise returns
   * the node. This is used so nodes can override [Node.bind], [Node.unbind],
   * and [Node.unbindAll] like InputElement does.
   */
  // TODO(jmesserly): remove this when we can extend Element for real.
  static _nodeOrCustom(node) => node is Element ? node.xtag : node;

  static List<_BindingToken> _parseMustacheTokens(String s) {
    var result = [];
    var length = s.length;
    var index = 0, lastIndex = 0;
    while (lastIndex < length) {
      index = s.indexOf('{{', lastIndex);
      if (index < 0) {
        result.add(new _BindingToken(s.substring(lastIndex)));
        break;
      } else {
        // There is a non-empty text run before the next path token.
        if (index > 0 && lastIndex < index) {
          result.add(new _BindingToken(s.substring(lastIndex, index)));
        }
        lastIndex = index + 2;
        index = s.indexOf('}}', lastIndex);
        if (index < 0) {
          var text = s.substring(lastIndex - 2);
          if (result.length > 0 && result.last.isText) {
            result.last.value += text;
          } else {
            result.add(new _BindingToken(text));
          }
          break;
        }

        var value = s.substring(lastIndex, index).trim();
        result.add(new _BindingToken(value, isBinding: true));
        lastIndex = index + 2;
      }
    }
    return result;
  }

  static void _addTemplateInstanceRecord(fragment, model) {
    if (fragment.$dom_firstChild == null) {
      return;
    }

    var instanceRecord = new TemplateInstance(
        fragment.$dom_firstChild, fragment.$dom_lastChild, model);

    var node = instanceRecord.firstNode;
    while (node != null) {
      node._templateInstance = instanceRecord;
      node = node.nextNode;
    }
  }

  static void _removeAllBindingsRecursively(Node node) {
    _nodeOrCustom(node).unbindAll();
    for (var c = node.$dom_firstChild; c != null; c = c.nextNode) {
      _removeAllBindingsRecursively(c);
    }
  }

  static void _removeChild(Node parent, Node child) {
    child._templateInstance = null;
    if (child is Element && child.isTemplate) {
      // Make sure we stop observing when we remove an element.
      var templateIterator = child._templateIterator;
      if (templateIterator != null) {
        templateIterator.abandon();
        child._templateIterator = null;
      }
    }
    child.remove();
    _removeAllBindingsRecursively(child);
  }
}

class _BindingToken {
  final String value;
  final bool isBinding;

  _BindingToken(this.value, {this.isBinding: false});

  bool get isText => !isBinding;
}

class _TemplateIterator {
  final Element _templateElement;
  final List<Node> terminators = [];
  final CompoundBinding inputs;
  List iteratedValue;

  StreamSubscription _sub;
  StreamSubscription _valueBinding;

  _TemplateIterator(this._templateElement)
    : inputs = new CompoundBinding(resolveInputs) {

    _valueBinding = new PathObserver(inputs, 'value').bindSync(valueChanged);
  }

  static Object resolveInputs(Map values) {
    if (values.containsKey('if') && !_Bindings._toBoolean(values['if'])) {
      return null;
    }

    if (values.containsKey('repeat')) {
      return values['repeat'];
    }

    if (values.containsKey('bind')) {
      return [values['bind']];
    }

    return null;
  }

  void valueChanged(value) {
    clear();
    if (value is! List) return;

    iteratedValue = value;

    if (value is Observable) {
      _sub = value.changes.listen(_handleChanges);
    }

    int len = iteratedValue.length;
    if (len > 0) {
      _handleChanges([new ListChangeRecord(0, addedCount: len)]);
    }
  }

  Node getTerminatorAt(int index) {
    if (index == -1) return _templateElement;
    var terminator = terminators[index];
    if (terminator is! Element) return terminator;

    var subIterator = terminator._templateIterator;
    if (subIterator == null) return terminator;

    return subIterator.getTerminatorAt(subIterator.terminators.length - 1);
  }

  void insertInstanceAt(int index, Node fragment) {
    var previousTerminator = getTerminatorAt(index - 1);
    var terminator = fragment.$dom_lastChild;
    if (terminator == null) terminator = previousTerminator;

    terminators.insert(index, terminator);
    var parent = _templateElement.parentNode;
    parent.insertBefore(fragment, previousTerminator.nextNode);
  }

  void removeInstanceAt(int index) {
    var previousTerminator = getTerminatorAt(index - 1);
    var terminator = getTerminatorAt(index);
    terminators.removeAt(index);

    var parent = _templateElement.parentNode;
    while (terminator != previousTerminator) {
      var node = terminator;
      terminator = node.previousNode;
      _Bindings._removeChild(parent, node);
    }
  }

  void removeAllInstances() {
    if (terminators.length == 0) return;

    var previousTerminator = _templateElement;
    var terminator = getTerminatorAt(terminators.length - 1);
    terminators.length = 0;

    var parent = _templateElement.parentNode;
    while (terminator != previousTerminator) {
      var node = terminator;
      terminator = node.previousNode;
      _Bindings._removeChild(parent, node);
    }
  }

  void clear() {
    unobserve();
    removeAllInstances();
    iteratedValue = null;
  }

  getInstanceModel(model, syntax) {
    if (syntax != null) {
      return syntax.getInstanceModel(_templateElement, model);
    }
    return model;
  }

  getInstanceFragment(syntax) {
    if (syntax != null) {
      return syntax.getInstanceFragment(_templateElement);
    }
    return _templateElement.createInstance();
  }

  void _handleChanges(List<ListChangeRecord> splices) {
    var syntax = TemplateElement.syntax[_templateElement.attributes['syntax']];

    for (var splice in splices) {
      if (splice is! ListChangeRecord) continue;

      for (int i = 0; i < splice.removedCount; i++) {
        removeInstanceAt(splice.index);
      }

      for (var addIndex = splice.index;
          addIndex < splice.index + splice.addedCount;
          addIndex++) {

        var model = getInstanceModel(iteratedValue[addIndex], syntax);

        var fragment = getInstanceFragment(syntax);

        _Bindings._addBindings(fragment, model, syntax);
        _Bindings._addTemplateInstanceRecord(fragment, model);

        insertInstanceAt(addIndex, fragment);
      }
    }
  }

  void unobserve() {
    if (_sub == null) return;
    _sub.cancel();
    _sub = null;
  }

  void abandon() {
    unobserve();
    _valueBinding.cancel();
    inputs.dispose();
  }
}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/**
 * Helper class to implement custom events which wrap DOM events.
 */
class _WrappedEvent implements Event {
  final Event wrapped;
  _WrappedEvent(this.wrapped);

  bool get bubbles => wrapped.bubbles;

  bool get cancelBubble => wrapped.bubbles;
  void set cancelBubble(bool value) {
    wrapped.cancelBubble = value;
  }

  bool get cancelable => wrapped.cancelable;

  DataTransfer get clipboardData => wrapped.clipboardData;

  EventTarget get currentTarget => wrapped.currentTarget;

  bool get defaultPrevented => wrapped.defaultPrevented;

  int get eventPhase => wrapped.eventPhase;

  EventTarget get target => wrapped.target;

  int get timeStamp => wrapped.timeStamp;

  String get type => wrapped.type;

  void $dom_initEvent(String eventTypeArg, bool canBubbleArg,
      bool cancelableArg) {
    throw new UnsupportedError(
        'Cannot initialize this Event.');
  }

  void preventDefault() {
    wrapped.preventDefault();
  }

  void stopImmediatePropagation() {
    wrapped.stopImmediatePropagation();
  }

  void stopPropagation() {
    wrapped.stopPropagation();
  }
}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


/**
 * A list which just wraps another list, for either intercepting list calls or
 * retyping the list (for example, from List<A> to List<B> where B extends A).
 */
class _WrappedList<E> extends ListBase<E> {
  final List _list;

  _WrappedList(this._list);

  // Iterable APIs

  Iterator<E> get iterator => new _WrappedIterator(_list.iterator);

  int get length => _list.length;

  // Collection APIs

  void add(E element) { _list.add(element); }

  void remove(Object element) { _list.remove(element); }

  void clear() { _list.clear(); }

  // List APIs

  E operator [](int index) => _list[index];

  void operator []=(int index, E value) { _list[index] = value; }

  void set length(int newLength) { _list.length = newLength; }

  void sort([int compare(E a, E b)]) { _list.sort(compare); }

  int indexOf(E element, [int start = 0]) => _list.indexOf(element, start);

  int lastIndexOf(E element, [int start]) => _list.lastIndexOf(element, start);

  void insert(int index, E element) => _list.insert(index, element);

  E removeAt(int index) => _list.removeAt(index);

  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    _list.setRange(start, end, iterable, skipCount);
  }

  void removeRange(int start, int end) { _list.removeRange(start, end); }

  void replaceRange(int start, int end, Iterable<E> iterable) {
    _list.replaceRange(start, end, iterable);
  }

  void fillRange(int start, int end, [E fillValue]) {
    _list.fillRange(start, end, fillValue);
  }
}

/**
 * Iterator wrapper for _WrappedList.
 */
class _WrappedIterator<E> implements Iterator<E> {
  Iterator _iterator;

  _WrappedIterator(this._iterator);

  bool moveNext() {
    return _iterator.moveNext();
  }

  E get current => _iterator.current;
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


class _HttpRequestUtils {

  // Helper for factory HttpRequest.get
  static HttpRequest get(String url,
                            onComplete(HttpRequest request),
                            bool withCredentials) {
    final request = new HttpRequest();
    request.open('GET', url, async: true);

    request.withCredentials = withCredentials;

    request.onReadyStateChange.listen((e) {
      if (request.readyState == HttpRequest.DONE) {
        onComplete(request);
      }
    });

    request.send();

    return request;
  }
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


class _CssStyleDeclarationFactoryProvider {
  static CssStyleDeclaration createCssStyleDeclaration_css(String css) {
    final style = new Element.tag('div').style;
    style.cssText = css;
    return style;
  }

  static CssStyleDeclaration createCssStyleDeclaration() {
    return new CssStyleDeclaration.css('');
  }
}

class _DocumentFragmentFactoryProvider {
  @DomName('Document.createDocumentFragment')
  static DocumentFragment createDocumentFragment() =>
      document.createDocumentFragment();

  static DocumentFragment createDocumentFragment_html(String html) {
    final fragment = new DocumentFragment();
    fragment.innerHtml = html;
    return fragment;
  }

  // TODO(nweiz): enable this when XML is ported.
  // factory DocumentFragment.xml(String xml) {
  //   final fragment = new DocumentFragment();
  //   final e = new XMLElement.tag("xml");
  //   e.innerHtml = xml;
  //
  //   // Copy list first since we don't want liveness during iteration.
  //   final List nodes = new List.from(e.nodes);
  //   fragment.nodes.addAll(nodes);
  //   return fragment;
  // }

  static DocumentFragment createDocumentFragment_svg(String svgContent) {
    final fragment = new DocumentFragment();
    final e = new svg.SvgSvgElement();
    e.innerHtml = svgContent;

    // Copy list first since we don't want liveness during iteration.
    final List nodes = new List.from(e.nodes);
    fragment.nodes.addAll(nodes);
    return fragment;
  }
}
/**
 * A custom KeyboardEvent that attempts to eliminate cross-browser
 * inconsistencies, and also provide both keyCode and charCode information
 * for all key events (when such information can be determined).
 *
 * KeyEvent tries to provide a higher level, more polished keyboard event
 * information on top of the "raw" [KeyboardEvent].
 *
 * This class is very much a work in progress, and we'd love to get information
 * on how we can make this class work with as many international keyboards as
 * possible. Bugs welcome!
 */

class KeyEvent extends _WrappedEvent implements KeyboardEvent {
  /** The parent KeyboardEvent that this KeyEvent is wrapping and "fixing". */
  KeyboardEvent _parent;

  /** The "fixed" value of whether the alt key is being pressed. */
  bool _shadowAltKey;

  /** Caculated value of what the estimated charCode is for this event. */
  int _shadowCharCode;

  /** Caculated value of what the estimated keyCode is for this event. */
  int _shadowKeyCode;

  /** Caculated value of what the estimated keyCode is for this event. */
  int get keyCode => _shadowKeyCode;

  /** Caculated value of what the estimated charCode is for this event. */
  int get charCode => this.type == 'keypress' ? _shadowCharCode : 0;

  /** Caculated value of whether the alt key is pressed is for this event. */
  bool get altKey => _shadowAltKey;

  /** Caculated value of what the estimated keyCode is for this event. */
  int get which => keyCode;

  /** Accessor to the underlying keyCode value is the parent event. */
  int get _realKeyCode => _parent.keyCode;

  /** Accessor to the underlying charCode value is the parent event. */
  int get _realCharCode => _parent.charCode;

  /** Accessor to the underlying altKey value is the parent event. */
  bool get _realAltKey => _parent.altKey;

  /** Construct a KeyEvent with [parent] as the event we're emulating. */
  KeyEvent(KeyboardEvent parent): super(parent) {
    _parent = parent;
    _shadowAltKey = _realAltKey;
    _shadowCharCode = _realCharCode;
    _shadowKeyCode = _realKeyCode;
  }

  /** Accessor to provide a stream of KeyEvents on the desired target. */
  static EventStreamProvider<KeyEvent> keyDownEvent =
    new _KeyboardEventHandler('keydown');
  /** Accessor to provide a stream of KeyEvents on the desired target. */
  static EventStreamProvider<KeyEvent> keyUpEvent =
    new _KeyboardEventHandler('keyup');
  /** Accessor to provide a stream of KeyEvents on the desired target. */
  static EventStreamProvider<KeyEvent> keyPressEvent =
    new _KeyboardEventHandler('keypress');

  /** True if the altGraphKey is pressed during this event. */
  bool get altGraphKey => _parent.altGraphKey;
  /** True if the ctrl key is pressed during this event. */
  bool get ctrlKey => _parent.ctrlKey;
  int get detail => _parent.detail;
  /**
   * Accessor to the part of the keyboard that the key was pressed from (one of
   * KeyLocation.STANDARD, KeyLocation.RIGHT, KeyLocation.LEFT,
   * KeyLocation.NUMPAD, KeyLocation.MOBILE, KeyLocation.JOYSTICK).
   */
  int get keyLocation => _parent.keyLocation;
  Point get layer => _parent.layer;
  /** True if the Meta (or Mac command) key is pressed during this event. */
  bool get metaKey => _parent.metaKey;
  Point get page => _parent.page;
  /** True if the shift key was pressed during this event. */
  bool get shiftKey => _parent.shiftKey;
  Window get view => _parent.view;
  void $dom_initUIEvent(String type, bool canBubble, bool cancelable,
      Window view, int detail) {
    throw new UnsupportedError("Cannot initialize a UI Event from a KeyEvent.");
  }
  String get _shadowKeyIdentifier => _parent.$dom_keyIdentifier;

  int get $dom_charCode => charCode;
  int get $dom_keyCode => keyCode;
  String get $dom_keyIdentifier {
    throw new UnsupportedError("keyIdentifier is unsupported.");
  }
  void $dom_initKeyboardEvent(String type, bool canBubble, bool cancelable,
      Window view, String keyIdentifier, int keyLocation, bool ctrlKey,
      bool altKey, bool shiftKey, bool metaKey,
      bool altGraphKey) {
    throw new UnsupportedError(
        "Cannot initialize a KeyboardEvent from a KeyEvent.");
  }
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


class _TextFactoryProvider {
  static Text createText(String data) => document.$dom_createTextNode(data);
}
// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


class Platform {
  /**
   * Returns true if dart:typed_data types are supported on this
   * browser.  If false, using these types will generate a runtime
   * error.
   */
  static final supportsTypedData = true;

  /**
   * Returns true if SIMD types in dart:typed_data types are supported
   * on this browser.  If false, using these types will generate a runtime
   * error.
   */
  static final supportsSimd = true;
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


_serialize(var message) {
  return new _JsSerializer().traverse(message);
}

class _JsSerializer extends _Serializer {

  visitSendPortSync(SendPortSync x) {
    if (x is _JsSendPortSync) return visitJsSendPortSync(x);
    if (x is _LocalSendPortSync) return visitLocalSendPortSync(x);
    if (x is _RemoteSendPortSync) return visitRemoteSendPortSync(x);
    throw "Unknown port type $x";
  }

  visitJsSendPortSync(_JsSendPortSync x) {
    return [ 'sendport', 'nativejs', x._id ];
  }

  visitLocalSendPortSync(_LocalSendPortSync x) {
    return [ 'sendport', 'dart',
             ReceivePortSync._isolateId, x._receivePort._portId ];
  }

  visitSendPort(SendPort x) {
    throw new UnimplementedError('Asynchronous send port not yet implemented.');
  }

  visitRemoteSendPortSync(_RemoteSendPortSync x) {
    return [ 'sendport', 'dart', x._isolateId, x._portId ];
  }
}

_deserialize(var message) {
  return new _JsDeserializer().deserialize(message);
}


class _JsDeserializer extends _Deserializer {

  static const _UNSPECIFIED = const Object();

  deserializeSendPort(List x) {
    String tag = x[1];
    switch (tag) {
      case 'nativejs':
        num id = x[2];
        return new _JsSendPortSync(id);
      case 'dart':
        num isolateId = x[2];
        num portId = x[3];
        return ReceivePortSync._lookup(isolateId, portId);
      default:
        throw 'Illegal SendPortSync type: $tag';
    }
  }
}

// The receiver is JS.
class _JsSendPortSync implements SendPortSync {

  final num _id;
  _JsSendPortSync(this._id);

  callSync(var message) {
    var serialized = _serialize(message);
    var result = _callPortSync(_id, serialized);
    return _deserialize(result);
  }

  bool operator==(var other) {
    return (other is _JsSendPortSync) && (_id == other._id);
  }

  int get hashCode => _id;
}

// TODO(vsm): Differentiate between Dart2Js and Dartium isolates.
// The receiver is a different Dart isolate, compiled to JS.
class _RemoteSendPortSync implements SendPortSync {

  int _isolateId;
  int _portId;
  _RemoteSendPortSync(this._isolateId, this._portId);

  callSync(var message) {
    var serialized = _serialize(message);
    var result = _call(_isolateId, _portId, serialized);
    return _deserialize(result);
  }

  static _call(int isolateId, int portId, var message) {
    var target = 'dart-port-$isolateId-$portId';
    // TODO(vsm): Make this re-entrant.
    // TODO(vsm): Set this up set once, on the first call.
    var source = '$target-result';
    var result = null;
    window.on[source].first.then((Event e) {
      result = json.parse(_getPortSyncEventData(e));
    });
    _dispatchEvent(target, [source, message]);
    return result;
  }

  bool operator==(var other) {
    return (other is _RemoteSendPortSync) && (_isolateId == other._isolateId)
      && (_portId == other._portId);
  }

  int get hashCode => _isolateId >> 16 + _portId;
}

// The receiver is in the same Dart isolate, compiled to JS.
class _LocalSendPortSync implements SendPortSync {

  ReceivePortSync _receivePort;

  _LocalSendPortSync._internal(this._receivePort);

  callSync(var message) {
    // TODO(vsm): Do a more efficient deep copy.
    var copy = _deserialize(_serialize(message));
    var result = _receivePort._callback(copy);
    return _deserialize(_serialize(result));
  }

  bool operator==(var other) {
    return (other is _LocalSendPortSync)
      && (_receivePort == other._receivePort);
  }

  int get hashCode => _receivePort.hashCode;
}

// TODO(vsm): Move this to dart:isolate.  This will take some
// refactoring as there are dependences here on the DOM.  Users
// interact with this class (or interface if we change it) directly -
// new ReceivePortSync.  I think most of the DOM logic could be
// delayed until the corresponding SendPort is registered on the
// window.

// A Dart ReceivePortSync (tagged 'dart' when serialized) is
// identifiable / resolvable by the combination of its isolateid and
// portid.  When a corresponding SendPort is used within the same
// isolate, the _portMap below can be used to obtain the
// ReceivePortSync directly.  Across isolates (or from JS), an
// EventListener can be used to communicate with the port indirectly.
class ReceivePortSync {

  static Map<int, ReceivePortSync> _portMap;
  static int _portIdCount;
  static int _cachedIsolateId;

  num _portId;
  Function _callback;
  StreamSubscription _portSubscription;

  ReceivePortSync() {
    if (_portIdCount == null) {
      _portIdCount = 0;
      _portMap = new Map<int, ReceivePortSync>();
    }
    _portId = _portIdCount++;
    _portMap[_portId] = this;
  }

  static int get _isolateId {
    // TODO(vsm): Make this coherent with existing isolate code.
    if (_cachedIsolateId == null) {
      _cachedIsolateId = _getNewIsolateId();
    }
    return _cachedIsolateId;
  }

  static String _getListenerName(isolateId, portId) =>
      'dart-port-$isolateId-$portId';
  String get _listenerName => _getListenerName(_isolateId, _portId);

  void receive(callback(var message)) {
    _callback = callback;
    if (_portSubscription == null) {
      _portSubscription = window.on[_listenerName].listen((Event e) {
        var data = json.parse(_getPortSyncEventData(e));
        var replyTo = data[0];
        var message = _deserialize(data[1]);
        var result = _callback(message);
        _dispatchEvent(replyTo, _serialize(result));
      });
    }
  }

  void close() {
    _portMap.remove(_portId);
    if (_portSubscription != null) _portSubscription.cancel();
  }

  SendPortSync toSendPort() {
    return new _LocalSendPortSync._internal(this);
  }

  static SendPortSync _lookup(int isolateId, int portId) {
    if (isolateId == _isolateId) {
      return _portMap[portId].toSendPort();
    } else {
      return new _RemoteSendPortSync(isolateId, portId);
    }
  }
}

get _isolateId => ReceivePortSync._isolateId;

void _dispatchEvent(String receiver, var message) {
  var event = new CustomEvent(receiver, canBubble: false, cancelable:false,
    detail: json.stringify(message));
  window.dispatchEvent(event);
}

String _getPortSyncEventData(CustomEvent event) => event.detail;
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


typedef void _MicrotaskCallback();

/**
 * This class attempts to invoke a callback as soon as the current event stack
 * unwinds, but before the browser repaints.
 */
abstract class _MicrotaskScheduler {
  bool _nextMicrotaskFrameScheduled = false;
  final _MicrotaskCallback _callback;

  _MicrotaskScheduler(this._callback);

  /**
   * Creates the best possible microtask scheduler for the current platform.
   */
  factory _MicrotaskScheduler.best(_MicrotaskCallback callback) {
    if (Window._supportsSetImmediate) {
      return new _SetImmediateScheduler(callback);
    } else if (MutationObserver.supported) {
      return new _MutationObserverScheduler(callback);
    }
    return new _PostMessageScheduler(callback);
  }

  /**
   * Schedules a microtask callback if one has not been scheduled already.
   */
  void maybeSchedule() {
    if (this._nextMicrotaskFrameScheduled) {
      return;
    }
    this._nextMicrotaskFrameScheduled = true;
    this._schedule();
  }

  /**
   * Does the actual scheduling of the callback.
   */
  void _schedule();

  /**
   * Handles the microtask callback and forwards it if necessary.
   */
  void _onCallback() {
    // Ignore spurious messages.
    if (!_nextMicrotaskFrameScheduled) {
      return;
    }
    _nextMicrotaskFrameScheduled = false;
    this._callback();
  }
}

/**
 * Scheduler which uses window.postMessage to schedule events.
 */
class _PostMessageScheduler extends _MicrotaskScheduler {
  const _MICROTASK_MESSAGE = "DART-MICROTASK";

  _PostMessageScheduler(_MicrotaskCallback callback): super(callback) {
      // Messages from other windows do not cause a security risk as
      // all we care about is that _handleMessage is called
      // after the current event loop is unwound and calling the function is
      // a noop when zero requests are pending.
      window.onMessage.listen(this._handleMessage);
  }

  void _schedule() {
    window.postMessage(_MICROTASK_MESSAGE, "*");
  }

  void _handleMessage(e) {
    this._onCallback();
  }
}

/**
 * Scheduler which uses a MutationObserver to schedule events.
 */
class _MutationObserverScheduler extends _MicrotaskScheduler {
  MutationObserver _observer;
  Element _dummy;

  _MutationObserverScheduler(_MicrotaskCallback callback): super(callback) {
    // Mutation events get fired as soon as the current event stack is unwound
    // so we just make a dummy event and listen for that.
    _observer = new MutationObserver(this._handleMutation);
    _dummy = new DivElement();
    _observer.observe(_dummy, attributes: true);
  }

  void _schedule() {
    // Toggle it to trigger the mutation event.
    _dummy.hidden = !_dummy.hidden;
  }

  _handleMutation(List<MutationRecord> mutations, MutationObserver observer) {
    this._onCallback();
  }
}

/**
 * Scheduler which uses window.setImmediate to schedule events.
 */
class _SetImmediateScheduler extends _MicrotaskScheduler {
  _SetImmediateScheduler(_MicrotaskCallback callback): super(callback);

  void _schedule() {
    window._setImmediate(_handleImmediate);
  }

  void _handleImmediate() {
    this._onCallback();
  }
}

List<TimeoutHandler> _pendingMicrotasks;
_MicrotaskScheduler _microtaskScheduler = null;

void _maybeScheduleMicrotaskFrame() {
  if (_microtaskScheduler == null) {
    _microtaskScheduler =
      new _MicrotaskScheduler.best(_completeMicrotasks);
  }
  _microtaskScheduler.maybeSchedule();
}

/**
 * Registers a [callback] which is called after the current execution stack
 * unwinds.
 */
void _addMicrotaskCallback(TimeoutHandler callback) {
  if (_pendingMicrotasks == null) {
    _pendingMicrotasks = <TimeoutHandler>[];
    _maybeScheduleMicrotaskFrame();
  }
  _pendingMicrotasks.add(callback);
}


/**
 * Complete all pending microtasks.
 */
void _completeMicrotasks() {
  var callbacks = _pendingMicrotasks;
  _pendingMicrotasks = null;
  for (var callback in callbacks) {
    callback();
  }
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Patch file for the dart:isolate library.


/********************************************************
  Inserted from lib/isolate/serialization.dart
 ********************************************************/

class _MessageTraverserVisitedMap {

  operator[](var object) => null;
  void operator[]=(var object, var info) { }

  void reset() { }
  void cleanup() { }

}

/** Abstract visitor for dart objects that can be sent as isolate messages. */
abstract class _MessageTraverser {

  _MessageTraverserVisitedMap _visited;
  _MessageTraverser() : _visited = new _MessageTraverserVisitedMap();

  /** Visitor's entry point. */
  traverse(var x) {
    if (isPrimitive(x)) return visitPrimitive(x);
    _visited.reset();
    var result;
    try {
      result = _dispatch(x);
    } finally {
      _visited.cleanup();
    }
    return result;
  }

  _dispatch(var x) {
    if (isPrimitive(x)) return visitPrimitive(x);
    if (x is List) return visitList(x);
    if (x is Map) return visitMap(x);
    if (x is SendPort) return visitSendPort(x);
    if (x is SendPortSync) return visitSendPortSync(x);

    // Overridable fallback.
    return visitObject(x);
  }

  visitPrimitive(x);
  visitList(List x);
  visitMap(Map x);
  visitSendPort(SendPort x);
  visitSendPortSync(SendPortSync x);

  visitObject(Object x) {
    // TODO(floitsch): make this a real exception. (which one)?
    throw "Message serialization: Illegal value $x passed";
  }

  static bool isPrimitive(x) {
    return (x == null) || (x is String) || (x is num) || (x is bool);
  }
}


/** Visitor that serializes a message as a JSON array. */
abstract class _Serializer extends _MessageTraverser {
  int _nextFreeRefId = 0;

  visitPrimitive(x) => x;

  visitList(List list) {
    int copyId = _visited[list];
    if (copyId != null) return ['ref', copyId];

    int id = _nextFreeRefId++;
    _visited[list] = id;
    var jsArray = _serializeList(list);
    // TODO(floitsch): we are losing the generic type.
    return ['list', id, jsArray];
  }

  visitMap(Map map) {
    int copyId = _visited[map];
    if (copyId != null) return ['ref', copyId];

    int id = _nextFreeRefId++;
    _visited[map] = id;
    var keys = _serializeList(map.keys.toList());
    var values = _serializeList(map.values.toList());
    // TODO(floitsch): we are losing the generic type.
    return ['map', id, keys, values];
  }

  _serializeList(List list) {
    int len = list.length;
    var result = new List(len);
    for (int i = 0; i < len; i++) {
      result[i] = _dispatch(list[i]);
    }
    return result;
  }
}

/** Deserializes arrays created with [_Serializer]. */
abstract class _Deserializer {
  Map<int, dynamic> _deserialized;

  _Deserializer();

  static bool isPrimitive(x) {
    return (x == null) || (x is String) || (x is num) || (x is bool);
  }

  deserialize(x) {
    if (isPrimitive(x)) return x;
    // TODO(floitsch): this should be new HashMap<int, dynamic>()
    _deserialized = new HashMap();
    return _deserializeHelper(x);
  }

  _deserializeHelper(x) {
    if (isPrimitive(x)) return x;
    assert(x is List);
    switch (x[0]) {
      case 'ref': return _deserializeRef(x);
      case 'list': return _deserializeList(x);
      case 'map': return _deserializeMap(x);
      case 'sendport': return deserializeSendPort(x);
      default: return deserializeObject(x);
    }
  }

  _deserializeRef(List x) {
    int id = x[1];
    var result = _deserialized[id];
    assert(result != null);
    return result;
  }

  List _deserializeList(List x) {
    int id = x[1];
    // We rely on the fact that Dart-lists are directly mapped to Js-arrays.
    List dartList = x[2];
    _deserialized[id] = dartList;
    int len = dartList.length;
    for (int i = 0; i < len; i++) {
      dartList[i] = _deserializeHelper(dartList[i]);
    }
    return dartList;
  }

  Map _deserializeMap(List x) {
    Map result = new Map();
    int id = x[1];
    _deserialized[id] = result;
    List keys = x[2];
    List values = x[3];
    int len = keys.length;
    assert(len == values.length);
    for (int i = 0; i < len; i++) {
      var key = _deserializeHelper(keys[i]);
      var value = _deserializeHelper(values[i]);
      result[key] = value;
    }
    return result;
  }

  deserializeSendPort(List x);

  deserializeObject(List x) {
    // TODO(floitsch): Use real exception (which one?).
    throw "Unexpected serialized object";
  }
}

// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


// Iterator for arrays with fixed size.
class FixedSizeListIterator<T> implements Iterator<T> {
  final List<T> _array;
  final int _length;  // Cache array length for faster access.
  int _position;
  T _current;
  
  FixedSizeListIterator(List<T> array)
      : _array = array,
        _position = -1,
        _length = array.length;

  bool moveNext() {
    int nextPosition = _position + 1;
    if (nextPosition < _length) {
      _current = _array[nextPosition];
      _position = nextPosition;
      return true;
    }
    _current = null;
    _position = _length;
    return false;
  }

  T get current => _current;
}

// Iterator for arrays with variable size.
class _VariableSizeListIterator<T> implements Iterator<T> {
  final List<T> _array;
  int _position;
  T _current;

  _VariableSizeListIterator(List<T> array)
      : _array = array,
        _position = -1;

  bool moveNext() {
    int nextPosition = _position + 1;
    if (nextPosition < _array.length) {
      _current = _array[nextPosition];
      _position = nextPosition;
      return true;
    }
    _current = null;
    _position = _array.length;
    return false;
  }

  T get current => _current;
}
// Copyright (c) 2011, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


_makeSendPortFuture(spawnRequest) {
  final completer = new Completer<SendPort>.sync();
  final port = new ReceivePort();
  port.receive((result, _) {
    completer.complete(result);
    port.close();
  });
  // TODO: SendPort.hashCode is ugly way to access port id.
  spawnRequest(port.toSendPort().hashCode);
  return completer.future;
}

// This API is exploratory.
Future<SendPort> spawnDomFunction(Function f) =>
    _makeSendPortFuture((portId) { _Utils.spawnDomFunction(f, portId); });

Future<SendPort> spawnDomUri(String uri) =>
    _makeSendPortFuture((portId) { _Utils.spawnDomUri(uri, portId); });

// testRunner implementation.
// FIXME: provide a separate lib for testRunner.

var _testRunner;

TestRunner get testRunner {
  if (_testRunner == null)
    _testRunner = new TestRunner._(_NPObject.retrieve("testRunner"));
  return _testRunner;
}

class TestRunner {
  final _NPObject _npObject;

  TestRunner._(this._npObject);

  display() => _npObject.invoke('display');
  dumpAsText() => _npObject.invoke('dumpAsText');
  notifyDone() => _npObject.invoke('notifyDone');
  setCanOpenWindows() => _npObject.invoke('setCanOpenWindows');
  waitUntilDone() => _npObject.invoke('waitUntilDone');
}
// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


class _Utils {
  static double dateTimeToDouble(DateTime dateTime) =>
      dateTime.millisecondsSinceEpoch.toDouble();
  static DateTime doubleToDateTime(double dateTime) {
    try {
      return new DateTime.fromMillisecondsSinceEpoch(dateTime.toInt());
    } catch(_) {
      // TODO(antonnm): treat exceptions properly in bindings and
      // find out how to treat NaNs.
      return null;
    }
  }

  static List convertToList(List list) {
    // FIXME: [possible optimization]: do not copy the array if Dart_IsArray is fine w/ it.
    final length = list.length;
    List result = new List(length);
    result.setRange(0, length, list);
    return result;
  }

  static List convertMapToList(Map map) {
    List result = [];
    map.forEach((k, v) => result.addAll([k, v]));
    return result;
  }

  static int convertCanvasElementGetContextMap(Map map) {
    int result = 0;
    if (map['alpha'] == true) result |= 0x01;
    if (map['depth'] == true) result |= 0x02;
    if (map['stencil'] == true) result |= 0x4;
    if (map['antialias'] == true) result |= 0x08;
    if (map['premultipliedAlpha'] == true) result |= 0x10;
    if (map['preserveDrawingBuffer'] == true) result |= 0x20;

    return result;
  }

  static List parseStackTrace(StackTrace stackTrace) {
    final regExp = new RegExp(r'#\d\s+(.*) \((.*):(\d+):(\d+)\)');
    List result = [];
    for (var match in regExp.allMatches(stackTrace.toString())) {
      result.add([match.group(1), match.group(2), int.parse(match.group(3)), int.parse(match.group(4))]);
    }
    return result;
  }

  static void populateMap(Map result, List list) {
    for (int i = 0; i < list.length; i += 2) {
      result[list[i]] = list[i + 1];
    }
  }

  static bool isMap(obj) => obj is Map;

  static Map createMap() => {};

  static makeUnimplementedError(String fileName, int lineNo) {
    return new UnsupportedError('[info: $fileName:$lineNo]');
  }

  static window() native "Utils_window";
  static forwardingPrint(String message) native "Utils_forwardingPrint";
  static void spawnDomFunction(Function f, int replyTo) native "Utils_spawnDomFunction";
  static void spawnDomUri(String uri, int replyTo) native "Utils_spawnDomUri";
  static int _getNewIsolateId() native "Utils_getNewIsolateId";
  static bool shadowRootSupported(Document document) native "Utils_shadowRootSupported";
}

class _NPObject extends NativeFieldWrapperClass1 {
  _NPObject.internal();
  static _NPObject retrieve(String key) native "NPObject_retrieve";
  property(String propertyName) native "NPObject_property";
  invoke(String methodName, [List args = null]) native "NPObject_invoke";
}

class _DOMWindowCrossFrame extends NativeFieldWrapperClass1 implements
    WindowBase {
  _DOMWindowCrossFrame.internal();

  // Fields.
  HistoryBase get history native "DOMWindow_history_cross_frame_Getter";
  LocationBase get location native "DOMWindow_location_cross_frame_Getter";
  bool get closed native "DOMWindow_closed_Getter";
  int get length native "DOMWindow_length_Getter";
  WindowBase get opener native "DOMWindow_opener_Getter";
  WindowBase get parent native "DOMWindow_parent_Getter";
  WindowBase get top native "DOMWindow_top_Getter";

  // Methods.
  void close() native "DOMWindow_close_Callback";
  void postMessage(/*SerializedScriptValue*/ message, String targetOrigin, [List messagePorts]) native "DOMWindow_postMessage_Callback";

  // Implementation support.
  String get typeName => "DOMWindow";
}

class _HistoryCrossFrame extends NativeFieldWrapperClass1 implements HistoryBase {
  _HistoryCrossFrame.internal();

  // Methods.
  void back() native "History_back_Callback";
  void forward() native "History_forward_Callback";
  void go(int distance) native "History_go_Callback";

  // Implementation support.
  String get typeName => "History";
}

class _LocationCrossFrame extends NativeFieldWrapperClass1 implements LocationBase {
  _LocationCrossFrame.internal();

  // Fields.
  void set href(String) native "Location_href_Setter";

  // Implementation support.
  String get typeName => "Location";
}

class _DOMStringMap extends NativeFieldWrapperClass1 implements Map<String, String> {
  _DOMStringMap.internal();

  bool containsValue(String value) => Maps.containsValue(this, value);
  bool containsKey(String key) native "DOMStringMap_containsKey_Callback";
  String operator [](String key) native "DOMStringMap_item_Callback";
  void operator []=(String key, String value) native "DOMStringMap_setItem_Callback";
  String putIfAbsent(String key, String ifAbsent()) => Maps.putIfAbsent(this, key, ifAbsent);
  String remove(String key) native "DOMStringMap_remove_Callback";
  void clear() => Maps.clear(this);
  void forEach(void f(String key, String value)) => Maps.forEach(this, f);
  Iterable<String> get keys native "DOMStringMap_getKeys_Callback";
  Iterable<String> get values => Maps.getValues(this);
  int get length => Maps.length(this);
  bool get isEmpty => Maps.isEmpty(this);
}

final Future<SendPort> __HELPER_ISOLATE_PORT =
    spawnDomFunction(_helperIsolateMain);

// Tricky part.
// Once __HELPER_ISOLATE_PORT gets resolved, it will still delay in .then
// and to delay Timer.run is used. However, Timer.run will try to register
// another Timer and here we got stuck: event cannot be posted as then
// callback is not executed because it's delayed with timer.
// Therefore once future is resolved, it's unsafe to call .then on it
// in Timer code.
SendPort __SEND_PORT;

_sendToHelperIsolate(msg, SendPort replyTo) {
  if (__SEND_PORT != null) {
    __SEND_PORT.send(msg, replyTo);
  } else {
    __HELPER_ISOLATE_PORT.then((port) {
      __SEND_PORT = port;
      __SEND_PORT.send(msg, replyTo);
    });
  }
}

final _TIMER_REGISTRY = new Map<SendPort, Timer>();

const _NEW_TIMER = 'NEW_TIMER';
const _CANCEL_TIMER = 'CANCEL_TIMER';
const _TIMER_PING = 'TIMER_PING';
const _PRINT = 'PRINT';

_helperIsolateMain() {
  port.receive((msg, replyTo) {
    final cmd = msg[0];
    if (cmd == _NEW_TIMER) {
      final duration = new Duration(milliseconds: msg[1]);
      bool periodic = msg[2];
      ping() { replyTo.send(_TIMER_PING); };
      _TIMER_REGISTRY[replyTo] = periodic ?
          new Timer.periodic(duration, (_) { ping(); }) :
          new Timer(duration, ping);
    } else if (cmd == _CANCEL_TIMER) {
      _TIMER_REGISTRY.remove(replyTo).cancel();
    } else if (cmd == _PRINT) {
      final message = msg[1];
      // TODO(antonm): we need somehow identify those isolates.
      print('[From isolate] $message');
    }
  });
}

final _printClosure = window.console.log;
final _pureIsolatePrintClosure = (s) {
  _sendToHelperIsolate([_PRINT, s], null);
};

final _forwardingPrintClosure = _Utils.forwardingPrint;

class _Timer implements Timer {
  final canceller;

  _Timer(this.canceller);

  void cancel() { canceller(); }
}

get _timerFactoryClosure => (int milliSeconds, void callback(Timer timer), bool repeating) {
  var maker;
  var canceller;
  if (repeating) {
    maker = window._setInterval;
    canceller = window._clearInterval;
  } else {
    maker = window._setTimeout;
    canceller = window._clearTimeout;
  }
  Timer timer;
  final int id = maker(() { callback(timer); }, milliSeconds);
  timer = new _Timer(() { canceller(id); });
  return timer;
};

class _PureIsolateTimer implements Timer {
  final ReceivePort _port = new ReceivePort();
  SendPort _sendPort; // Effectively final.

  static SendPort _SEND_PORT;

  _PureIsolateTimer(int milliSeconds, callback, repeating) {
    _sendPort = _port.toSendPort();
    _port.receive((msg, replyTo) {
      assert(msg == _TIMER_PING);
      callback(this);
      if (!repeating) _cancel();
    });

    _send([_NEW_TIMER, milliSeconds, repeating]);
  }

  void cancel() {
    _cancel();
    _send([_CANCEL_TIMER]);
  }

  void _cancel() {
    _port.close();
  }

  _send(msg) {
    _sendToHelperIsolate(msg, _sendPort);
  }
}

get _pureIsolateTimerFactoryClosure =>
    ((int milliSeconds, void callback(Timer time), bool repeating) =>
        new _PureIsolateTimer(milliSeconds, callback, repeating));
