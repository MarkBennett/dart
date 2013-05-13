// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library template_element_test;

import 'dart:async';
import 'dart:collection';
import 'dart:html';
import 'dart:math' as math;
import 'package:mdv_observe/mdv_observe.dart';
import 'package:unittest/html_config.dart';
import 'package:unittest/unittest.dart';
import 'mdv_observe_utils.dart';

// Note: this file ported from
// https://github.com/toolkitchen/mdv/blob/master/tests/template_element.js
// TODO(jmesserly): submit a small cleanup patch to original. I fixed some
// cases where "div" and "t" were unintentionally using the JS global scope;
// look for "assertNodesAre".

main() {
  useHtmlConfiguration();
  group('Template Element', templateElementTests);
}

templateElementTests() {
  var testDiv;

  setUp(() {
    document.body.append(testDiv = new DivElement());
  });

  tearDown(() {
    testDiv.remove();
    testDiv = null;
  });

  createTestHtml(s) {
    var div = new DivElement();
    div.innerHtml = s;
    testDiv.append(div);

    for (var node in div.queryAll('*')) {
      if (node.isTemplate) TemplateElement.decorate(node);
    }

    return div;
  }

  createShadowTestHtml(s) {
    var div = new DivElement();
    var root = div.createShadowRoot();
    root.innerHtml = s;
    testDiv.append(div);

    for (var node in root.queryAll('*')) {
      if (node.isTemplate) TemplateElement.decorate(node);
    }

    return root;
  }

  recursivelySetTemplateModel(element, model) {
    for (var node in element.queryAll('*')) {
      if (node.isTemplate) node.model = model;
    }
  }

  dispatchEvent(type, target) {
    target.dispatchEvent(new Event(type, cancelable: false));
  }

  test('Template', () {
    var div = createTestHtml('<template bind={{}}>text</template>');
    recursivelySetTemplateModel(div, null);
    deliverChangeRecords();
    expect(div.nodes.length, 2);
    expect(div.nodes.last.text, 'text');
  });

  test('Template-Empty Bind', () {
    var div = createTestHtml('<template bind>text</template>');
    recursivelySetTemplateModel(div, null);
    deliverChangeRecords();
    expect(div.nodes.length, 2);
    expect(div.nodes.last.text, 'text');
  });

  test('TextTemplateWithNullStringBinding', () {
    var div = createTestHtml('<template bind={{}}>a{{b}}c</template>');
    var model = toSymbolMap({'b': 'B'});
    recursivelySetTemplateModel(div, model);

    deliverChanges(model);
    expect(div.nodes.length, 2);
    expect(div.nodes.last.text, 'aBc');

    model[sym('b')] = 'b';
    deliverChanges(model);
    expect(div.nodes.last.text, 'abc');

    model[sym('b')] = null;
    deliverChanges(model);
    expect(div.nodes.last.text, 'ac');

    model = null;
    deliverChanges(model);
    // setting model isn't observable.
    expect(div.nodes.last.text, 'ac');
  });

  test('TextTemplateWithBindingPath', () {
    var div = createTestHtml(
        '<template bind="{{ data }}">a{{b}}c</template>');
    var model = toSymbolMap({ 'data': {'b': 'B'} });
    recursivelySetTemplateModel(div, model);

    deliverChanges(model);
    expect(div.nodes.length, 2);
    expect(div.nodes.last.text, 'aBc');

    model[sym('data')][sym('b')] = 'b';
    deliverChanges(model);
    expect(div.nodes.last.text, 'abc');

    model[sym('data')] = toSymbols({'b': 'X'});
    deliverChanges(model);
    expect(div.nodes.last.text, 'aXc');

    model[sym('data')] = null;
    deliverChanges(model);
    expect(div.nodes.last.text, 'ac');
  });

  test('TextTemplateWithBindingAndConditional', () {
    var div = createTestHtml(
        '<template bind="{{}}" if="{{ d }}">a{{b}}c</template>');
    var model = toSymbolMap({'b': 'B', 'd': 1});
    recursivelySetTemplateModel(div, model);

    deliverChanges(model);
    expect(div.nodes.length, 2);
    expect(div.nodes.last.text, 'aBc');

    model[sym('b')] = 'b';
    deliverChanges(model);
    expect(div.nodes.last.text, 'abc');

    // TODO(jmesserly): MDV set this to empty string and relies on JS conversion
    // rules. Is that intended?
    // See https://github.com/toolkitchen/mdv/issues/59
    model[sym('d')] = null;
    deliverChanges(model);
    expect(div.nodes.length, 1);

    model[sym('d')] = 'here';
    model[sym('b')] = 'd';

    deliverChanges(model);
    expect(div.nodes.length, 2);
    expect(div.nodes.last.text, 'adc');
  });

  test('TemplateWithTextBinding2', () {
    var div = createTestHtml(
        '<template bind="{{ b }}">a{{value}}c</template>');
    expect(div.nodes.length, 1);
    var model = toSymbolMap({'b': {'value': 'B'}});
    recursivelySetTemplateModel(div, model);

    deliverChanges(model);
    expect(div.nodes.length, 2);
    expect(div.nodes.last.text, 'aBc');

    model[sym('b')] = toSymbols({'value': 'b'});
    deliverChanges(model);
    expect(div.nodes.last.text, 'abc');
  });

  test('TemplateWithAttributeBinding', () {
    var div = createTestHtml(
        '<template bind="{{}}">'
        '<div foo="a{{b}}c"></div>'
        '</template>');
    var model = toSymbolMap({'b': 'B'});
    recursivelySetTemplateModel(div, model);

    deliverChanges(model);
    expect(div.nodes.length, 2);
    expect(div.nodes.last.attributes['foo'], 'aBc');

    model[sym('b')] = 'b';
    deliverChanges(model);
    expect(div.nodes.last.attributes['foo'], 'abc');

    model[sym('b')] = 'X';
    deliverChanges(model);
    expect(div.nodes.last.attributes['foo'], 'aXc');
  });

  test('TemplateWithConditionalBinding', () {
    var div = createTestHtml(
        '<template bind="{{}}">'
        '<div foo?="{{b}}"></div>'
        '</template>');
    var model = toSymbolMap({'b': 'b'});
    recursivelySetTemplateModel(div, model);

    deliverChanges(model);
    expect(div.nodes.length, 2);
    expect(div.nodes.last.attributes['foo'], '');
    expect(div.nodes.last.attributes, isNot(contains('foo?')));

    model[sym('b')] = null;
    deliverChanges(model);
    expect(div.nodes.last.attributes, isNot(contains('foo')));
  });

  test('Repeat', () {
    var div = createTestHtml(
        '<template repeat="{{}}"">text</template>');

    var model = toSymbols([0, 1, 2]);
    recursivelySetTemplateModel(div, model);

    deliverChanges(model);
    expect(div.nodes.length, 4);

    model.length = 1;
    deliverChanges(model);
    expect(div.nodes.length, 2);

    model.addAll(toSymbols([3, 4]));
    deliverChanges(model);
    expect(div.nodes.length, 4);

    model.removeRange(1, 2);
    deliverChanges(model);
    expect(div.nodes.length, 3);
  });

  test('Repeat-Empty', () {
    var div = createTestHtml(
        '<template repeat>text</template>');

    var model = toSymbols([0, 1, 2]);
    recursivelySetTemplateModel(div, model);

    deliverChanges(model);
    expect(div.nodes.length, 4);

    model.length = 1;
    deliverChanges(model);
    expect(div.nodes.length, 2);

    model.addAll(toSymbols([3, 4]));
    deliverChanges(model);
    expect(div.nodes.length, 4);

    model.removeRange(1, 2);
    deliverChanges(model);
    expect(div.nodes.length, 3);
  });

  test('Removal from iteration needs to unbind', () {
    var div = createTestHtml(
        '<template repeat="{{}}"><a>{{v}}</a></template>');
    var model = toSymbols([{'v': 0}, {'v': 1}, {'v': 2}, {'v': 3}, {'v': 4}]);
    recursivelySetTemplateModel(div, model);
    deliverChanges(model);

    var nodes = div.nodes.skip(1).toList();
    var vs = model.toList();

    for (var i = 0; i < 5; i++) {
      expect(nodes[i].text, '$i');
    }

    model.length = 3;
    deliverChanges(model);
    for (var i = 0; i < 5; i++) {
      expect(nodes[i].text, '$i');
    }

    vs[3][sym('v')] = 33;
    vs[4][sym('v')] = 44;
    deliverChanges(model);
    for (var i = 0; i < 5; i++) {
      expect(nodes[i].text, '$i');
    }
  });

  test('DOM Stability on Iteration', () {
    var div = createTestHtml(
        '<template repeat="{{}}">{{}}</template>');
    var model = toSymbols([1, 2, 3, 4, 5]);
    recursivelySetTemplateModel(div, model);

    deliverChanges(model);

    // Note: the node at index 0 is the <template>.
    var nodes = div.nodes.toList();
    expect(nodes.length, 6, reason: 'list has 5 items');

    model.removeAt(0);
    model.removeLast();

    deliverChanges(model);
    expect(div.nodes.length, 4, reason: 'list has 3 items');
    expect(identical(div.nodes[1], nodes[2]), true, reason: '2 not removed');
    expect(identical(div.nodes[2], nodes[3]), true, reason: '3 not removed');
    expect(identical(div.nodes[3], nodes[4]), true, reason: '4 not removed');

    model.insert(0, 5);
    model[2] = 6;
    model.add(7);

    deliverChanges(model);

    expect(div.nodes.length, 6, reason: 'list has 5 items');
    expect(nodes.contains(div.nodes[1]), false, reason: '5 is a new node');
    expect(identical(div.nodes[2], nodes[2]), true);
    expect(nodes.contains(div.nodes[3]), false, reason: '6 is a new node');
    expect(identical(div.nodes[4], nodes[4]), true);
    expect(nodes.contains(div.nodes[5]), false, reason: '7 is a new node');

    nodes = div.nodes.toList();

    model.insert(2, 8);

    deliverChanges(model);

    expect(div.nodes.length, 7, reason: 'list has 6 items');
    expect(identical(div.nodes[1], nodes[1]), true);
    expect(identical(div.nodes[2], nodes[2]), true);
    expect(nodes.contains(div.nodes[3]), false, reason: '8 is a new node');
    expect(identical(div.nodes[4], nodes[3]), true);
    expect(identical(div.nodes[5], nodes[4]), true);
    expect(identical(div.nodes[6], nodes[5]), true);
  });

  test('Repeat2', () {
    var div = createTestHtml(
        '<template repeat="{{}}">{{value}}</template>');
    expect(div.nodes.length, 1);

    var model = toSymbols([
      {'value': 0},
      {'value': 1},
      {'value': 2}
    ]);
    recursivelySetTemplateModel(div, model);

    deliverChanges(model);
    expect(div.nodes.length, 4);
    expect(div.nodes[1].text, '0');
    expect(div.nodes[2].text, '1');
    expect(div.nodes[3].text, '2');

    model[1][sym('value')] = 'One';
    deliverChanges(model);
    expect(div.nodes.length, 4);
    expect(div.nodes[1].text, '0');
    expect(div.nodes[2].text, 'One');
    expect(div.nodes[3].text, '2');

    model.replaceRange(0, 1, toSymbols([{'value': 'Zero'}]));
    deliverChanges(model);
    expect(div.nodes.length, 4);
    expect(div.nodes[1].text, 'Zero');
    expect(div.nodes[2].text, 'One');
    expect(div.nodes[3].text, '2');
  });

  test('TemplateWithInputValue', () {
    var div = createTestHtml(
        '<template bind="{{}}">'
        '<input value="{{x}}">'
        '</template>');
    var model = toSymbolMap({'x': 'hi'});
    recursivelySetTemplateModel(div, model);

    deliverChanges(model);
    expect(div.nodes.length, 2);
    expect(div.nodes.last.value, 'hi');

    model[sym('x')] = 'bye';
    expect(div.nodes.last.value, 'hi');
    deliverChanges(model);
    expect(div.nodes.last.value, 'bye');

    div.nodes.last.value = 'hello';
    dispatchEvent('input', div.nodes.last);
    expect(model[sym('x')], 'hello');
    deliverChanges(model);
    expect(div.nodes.last.value, 'hello');
  });

//////////////////////////////////////////////////////////////////////////////

  test('Decorated', () {
    var div = createTestHtml(
        '<template bind="{{ XX }}" id="t1">'
          '<p>Crew member: {{name}}, Job title: {{title}}</p>'
        '</template>'
        '<template bind="{{ XY }}" id="t2" ref="t1"></template>');

    var model = toSymbolMap({
      'XX': {'name': 'Leela', 'title': 'Captain'},
      'XY': {'name': 'Fry', 'title': 'Delivery boy'},
      'XZ': {'name': 'Zoidberg', 'title': 'Doctor'}
    });
    recursivelySetTemplateModel(div, model);

    deliverChanges(model);

    var t1 = document.getElementById('t1');
    var instance = t1.nextElementSibling;
    expect(instance.text, 'Crew member: Leela, Job title: Captain');

    var t2 = document.getElementById('t2');
    instance = t2.nextElementSibling;
    expect(instance.text, 'Crew member: Fry, Job title: Delivery boy');

    expect(div.children.length, 4);
    expect(div.nodes.length, 4);

    expect(div.nodes[1].tagName, 'P');
    expect(div.nodes[3].tagName, 'P');
  });

  test('DefaultStyles', () {
    var t = new Element.tag('template');
    TemplateElement.decorate(t);

    document.body.append(t);
    expect(t.getComputedStyle().display, 'none');

    t.remove();
  });


  test('Bind', () {
    var div = createTestHtml('<template bind="{{}}">Hi {{ name }}</template>');
    var model = toSymbolMap({'name': 'Leela'});
    recursivelySetTemplateModel(div, model);

    deliverChanges(model);
    expect(div.nodes[1].text, 'Hi Leela');
  });

  test('BindImperative', () {
    var div = createTestHtml(
        '<template>'
          'Hi {{ name }}'
        '</template>');
    var t = div.nodes.first;

    var model = toSymbolMap({'name': 'Leela'});
    t.bind('bind', model, '');

    deliverChanges(model);
    expect(div.nodes[1].text, 'Hi Leela');
  });

  test('BindPlaceHolderHasNewLine', () {
    var div = createTestHtml('<template bind="{{}}">Hi {{\nname\n}}</template>');
    var model = toSymbolMap({'name': 'Leela'});
    recursivelySetTemplateModel(div, model);

    deliverChanges(model);
    expect(div.nodes[1].text, 'Hi Leela');
  });

  test('BindWithRef', () {
    var id = 't${new math.Random().nextDouble()}';
    var div = createTestHtml(
        '<template id="$id">'
          'Hi {{ name }}'
        '</template>'
        '<template ref="$id" bind="{{}}"></template>');

    var t1 = div.nodes.first;
    var t2 = div.nodes[1];

    expect(t2.ref, t1);

    var model = toSymbolMap({'name': 'Fry'});
    recursivelySetTemplateModel(div, model);

    deliverChanges(model);
    expect(t2.nextNode.text, 'Hi Fry');
  });

  test('BindChanged', () {
    var model = toSymbolMap({
      'XX': {'name': 'Leela', 'title': 'Captain'},
      'XY': {'name': 'Fry', 'title': 'Delivery boy'},
      'XZ': {'name': 'Zoidberg', 'title': 'Doctor'}
    });

    var div = createTestHtml(
        '<template bind="{{ XX }}">Hi {{ name }}</template>');

    recursivelySetTemplateModel(div, model);

    var t = div.nodes.first;
    deliverChanges(model);

    expect(div.nodes.length, 2);
    expect(t.nextNode.text, 'Hi Leela');

    t.bind('bind', model, 'XZ');
    deliverChanges(model);

    expect(div.nodes.length, 2);
    expect(t.nextNode.text, 'Hi Zoidberg');
  });

  assertNodesAre(div, [arguments]) {
    var expectedLength = arguments.length;
    expect(div.nodes.length, expectedLength + 1);

    for (var i = 0; i < arguments.length; i++) {
      var targetNode = div.nodes[i + 1];
      expect(targetNode.text, arguments[i]);
    }
  }

  test('Repeat3', () {
    var div = createTestHtml(
        '<template repeat="{{ contacts }}">Hi {{ name }}</template>');
    var t = div.nodes.first;

    var m = toSymbols({
      'contacts': [
        {'name': 'Raf'},
        {'name': 'Arv'},
        {'name': 'Neal'}
      ]
    });

    recursivelySetTemplateModel(div, m);
    deliverChanges(m);

    assertNodesAre(div, ['Hi Raf', 'Hi Arv', 'Hi Neal']);

    m[sym('contacts')].add(toSymbols({'name': 'Alex'}));
    deliverChanges(m);
    assertNodesAre(div, ['Hi Raf', 'Hi Arv', 'Hi Neal', 'Hi Alex']);

    m[sym('contacts')].replaceRange(0, 2,
        toSymbols([{'name': 'Rafael'}, {'name': 'Erik'}]));
    deliverChanges(m);
    assertNodesAre(div, ['Hi Rafael', 'Hi Erik', 'Hi Neal', 'Hi Alex']);

    m[sym('contacts')].removeRange(1, 3);
    deliverChanges(m);
    assertNodesAre(div, ['Hi Rafael', 'Hi Alex']);

    m[sym('contacts')].insertAll(1,
        toSymbols([{'name': 'Erik'}, {'name': 'Dimitri'}]));
    deliverChanges(m);
    assertNodesAre(div, ['Hi Rafael', 'Hi Erik', 'Hi Dimitri', 'Hi Alex']);

    m[sym('contacts')].replaceRange(0, 1,
        toSymbols([{'name': 'Tab'}, {'name': 'Neal'}]));
    deliverChanges(m);
    assertNodesAre(div, ['Hi Tab', 'Hi Neal', 'Hi Erik', 'Hi Dimitri', 'Hi Alex']);

    m[sym('contacts')] = toSymbols([{'name': 'Alex'}]);
    deliverChanges(m);
    assertNodesAre(div, ['Hi Alex']);

    m[sym('contacts')].length = 0;
    deliverChanges(m);
    assertNodesAre(div, []);
  });

  test('RepeatModelSet', () {
    var div = createTestHtml(
        '<template repeat="{{ contacts }}">'
          'Hi {{ name }}'
        '</template>');
    var m = toSymbols({
      'contacts': [
        {'name': 'Raf'},
        {'name': 'Arv'},
        {'name': 'Neal'}
      ]
    });
    recursivelySetTemplateModel(div, m);

    deliverChanges(m);
    var t = div.nodes.first;

    assertNodesAre(div, ['Hi Raf', 'Hi Arv', 'Hi Neal']);
  });

  test('RepeatEmptyPath', () {
    var div = createTestHtml('<template repeat="{{}}">Hi {{ name }}</template>');
    var t = div.nodes.first;

    var m = toSymbols([
      {'name': 'Raf'},
      {'name': 'Arv'},
      {'name': 'Neal'}
    ]);
    recursivelySetTemplateModel(div, m);

    deliverChanges(m);

    assertNodesAre(div, ['Hi Raf', 'Hi Arv', 'Hi Neal']);

    m.add(toSymbols({'name': 'Alex'}));
    deliverChanges(m);
    assertNodesAre(div, ['Hi Raf', 'Hi Arv', 'Hi Neal', 'Hi Alex']);

    m.replaceRange(0, 2, toSymbols([{'name': 'Rafael'}, {'name': 'Erik'}]));
    deliverChanges(m);
    assertNodesAre(div, ['Hi Rafael', 'Hi Erik', 'Hi Neal', 'Hi Alex']);

    m.removeRange(1, 3);
    deliverChanges(m);
    assertNodesAre(div, ['Hi Rafael', 'Hi Alex']);

    m.insertAll(1, toSymbols([{'name': 'Erik'}, {'name': 'Dimitri'}]));
    deliverChanges(m);
    assertNodesAre(div, ['Hi Rafael', 'Hi Erik', 'Hi Dimitri', 'Hi Alex']);

    m.replaceRange(0, 1, toSymbols([{'name': 'Tab'}, {'name': 'Neal'}]));
    deliverChanges(m);
    assertNodesAre(div, ['Hi Tab', 'Hi Neal', 'Hi Erik', 'Hi Dimitri', 'Hi Alex']);

    m.length = 0;
    m.add(toSymbols({'name': 'Alex'}));
    deliverChanges(m);
    assertNodesAre(div, ['Hi Alex']);
  });

  test('RepeatNullModel', () {
    var div = createTestHtml('<template repeat="{{}}">Hi {{ name }}</template>');
    var t = div.nodes.first;

    var m = null;
    recursivelySetTemplateModel(div, m);

    expect(div.nodes.length, 1);

    t.attributes['iterate'] = '';
    m = toSymbols({});
    recursivelySetTemplateModel(div, m);

    deliverChanges(m);
    expect(div.nodes.length, 1);
  });

  test('RepeatReuse', () {
    var div = createTestHtml('<template repeat="{{}}">Hi {{ name }}</template>');
    var t = div.nodes.first;

    var m = toSymbols([
      {'name': 'Raf'},
      {'name': 'Arv'},
      {'name': 'Neal'}
    ]);
    recursivelySetTemplateModel(div, m);
    deliverChanges(m);

    assertNodesAre(div, ['Hi Raf', 'Hi Arv', 'Hi Neal']);
    var node1 = div.nodes[1];
    var node2 = div.nodes[2];
    var node3 = div.nodes[3];

    m.replaceRange(1, 2, toSymbols([{'name': 'Erik'}]));
    deliverChanges(m);
    assertNodesAre(div, ['Hi Raf', 'Hi Erik', 'Hi Neal']);
    expect(div.nodes[1], node1,
        reason: 'model[0] did not change so the node should not have changed');
    expect(div.nodes[2], isNot(equals(node2)),
        reason: 'Should not reuse when replacing');
    expect(div.nodes[3], node3,
        reason: 'model[2] did not change so the node should not have changed');

    node2 = div.nodes[2];
    m.insert(0, toSymbols({'name': 'Alex'}));
    deliverChanges(m);
    assertNodesAre(div, ['Hi Alex', 'Hi Raf', 'Hi Erik', 'Hi Neal']);
  });

  test('TwoLevelsDeepBug', () {
    var div = createTestHtml(
      '<template bind="{{}}"><span><span>{{ foo }}</span></span></template>');

    var model = toSymbolMap({'foo': 'bar'});
    recursivelySetTemplateModel(div, model);
    deliverChanges(model);

    expect(div.nodes[1].nodes[0].nodes[0].text, 'bar');
  });

  test('Checked', () {
    var div = createTestHtml(
        '<template>'
          '<input type="checkbox" checked="{{a}}">'
        '</template>');
    var t = div.nodes.first;
    var m = toSymbols({
      'a': true
    });
    t.bind('bind', m, '');
    deliverChanges(m);

    var instanceInput = t.nextNode;
    expect(instanceInput.checked, true);

    instanceInput.click();
    expect(instanceInput.checked, false);

    instanceInput.click();
    expect(instanceInput.checked, true);
  });

  nestedHelper(s, start) {
    var div = createTestHtml(s);

    var m = toSymbols({
      'a': {
        'b': 1,
        'c': {'d': 2}
      },
    });

    recursivelySetTemplateModel(div, m);
    deliverChanges(m);

    var i = start;
    expect(div.nodes[i++].text, '1');
    expect(div.nodes[i++].tagName, 'TEMPLATE');
    expect(div.nodes[i++].text, '2');

    m[sym('a')][sym('b')] = 11;
    deliverChanges(m);
    expect(div.nodes[start].text, '11');

    m[sym('a')][sym('c')] = toSymbols({'d': 22});
    deliverChanges(m);
    expect(div.nodes[start + 2].text, '22');
  }

  test('Nested', () {
    nestedHelper(
        '<template bind="{{a}}">'
          '{{b}}'
          '<template bind="{{c}}">'
            '{{d}}'
          '</template>'
        '</template>', 1);
  });

  test('NestedWithRef', () {
    nestedHelper(
        '<template id="inner">{{d}}</template>'
        '<template id="outer" bind="{{a}}">'
          '{{b}}'
          '<template ref="inner" bind="{{c}}"></template>'
        '</template>', 2);
  });

  nestedIterateInstantiateHelper(s, start) {
    var div = createTestHtml(s);

    var m = toSymbols({
      'a': [
        {
          'b': 1,
          'c': {'d': 11}
        },
        {
          'b': 2,
          'c': {'d': 22}
        }
      ]
    });

    recursivelySetTemplateModel(div, m);
    deliverChanges(m);

    var i = start;
    expect(div.nodes[i++].text, '1');
    expect(div.nodes[i++].tagName, 'TEMPLATE');
    expect(div.nodes[i++].text, '11');
    expect(div.nodes[i++].text, '2');
    expect(div.nodes[i++].tagName, 'TEMPLATE');
    expect(div.nodes[i++].text, '22');

    m[sym('a')][1] = toSymbols({
      'b': 3,
      'c': {'d': 33}
    });

    deliverChanges(m);
    expect(div.nodes[start + 3].text, '3');
    expect(div.nodes[start + 5].text, '33');
  }

  test('NestedRepeatBind', () {
    nestedIterateInstantiateHelper(
        '<template repeat="{{a}}">'
          '{{b}}'
          '<template bind="{{c}}">'
            '{{d}}'
          '</template>'
        '</template>', 1);
  });

  test('NestedRepeatBindWithRef', () {
    nestedIterateInstantiateHelper(
        '<template id="inner">'
          '{{d}}'
        '</template>'
        '<template repeat="{{a}}">'
          '{{b}}'
          '<template ref="inner" bind="{{c}}"></template>'
        '</template>', 2);
  });

  nestedIterateIterateHelper(s, start) {
    var div = createTestHtml(s);

    var m = toSymbols({
      'a': [
        {
          'b': 1,
          'c': [{'d': 11}, {'d': 12}]
        },
        {
          'b': 2,
          'c': [{'d': 21}, {'d': 22}]
        }
      ]
    });

    recursivelySetTemplateModel(div, m);
    deliverChanges(m);

    var i = start;
    expect(div.nodes[i++].text, '1');
    expect(div.nodes[i++].tagName, 'TEMPLATE');
    expect(div.nodes[i++].text, '11');
    expect(div.nodes[i++].text, '12');
    expect(div.nodes[i++].text, '2');
    expect(div.nodes[i++].tagName, 'TEMPLATE');
    expect(div.nodes[i++].text, '21');
    expect(div.nodes[i++].text, '22');

    m[sym('a')][1] = toSymbols({
      'b': 3,
      'c': [{'d': 31}, {'d': 32}, {'d': 33}]
    });

    i = start + 4;
    deliverChanges(m);
    expect(div.nodes[start + 4].text, '3');
    expect(div.nodes[start + 6].text, '31');
    expect(div.nodes[start + 7].text, '32');
    expect(div.nodes[start + 8].text, '33');
  }

  test('NestedRepeatBind', () {
    nestedIterateIterateHelper(
        '<template repeat="{{a}}">'
          '{{b}}'
          '<template repeat="{{c}}">'
            '{{d}}'
          '</template>'
        '</template>', 1);
  });

  test('NestedRepeatRepeatWithRef', () {
    nestedIterateIterateHelper(
        '<template id="inner">'
          '{{d}}'
        '</template>'
        '<template repeat="{{a}}">'
          '{{b}}'
          '<template ref="inner" repeat="{{c}}"></template>'
        '</template>', 2);
  });

  test('NestedRepeatSelfRef', () {
    var div = createTestHtml(
        '<template id="t" repeat="{{}}">'
          '{{name}}'
          '<template ref="t" repeat="{{items}}"></template>'
        '</template>');

    var m = toSymbols([
      {
        'name': 'Item 1',
        'items': [
          {
            'name': 'Item 1.1',
            'items': [
              {
                 'name': 'Item 1.1.1',
                 'items': []
              }
            ]
          },
          {
            'name': 'Item 1.2'
          }
        ]
      },
      {
        'name': 'Item 2',
        'items': []
      },
    ]);

    recursivelySetTemplateModel(div, m);
    deliverChanges(m);

    var i = 1;
    expect(div.nodes[i++].text, 'Item 1');
    expect(div.nodes[i++].tagName, 'TEMPLATE');
    expect(div.nodes[i++].text, 'Item 1.1');
    expect(div.nodes[i++].tagName, 'TEMPLATE');
    expect(div.nodes[i++].text, 'Item 1.1.1');
    expect(div.nodes[i++].tagName, 'TEMPLATE');
    expect(div.nodes[i++].text, 'Item 1.2');
    expect(div.nodes[i++].tagName, 'TEMPLATE');
    expect(div.nodes[i++].text, 'Item 2');

    m[0] = toSymbols({'name': 'Item 1 changed'});

    i = 1;
    deliverChanges(m);
    expect(div.nodes[i++].text, 'Item 1 changed');
    expect(div.nodes[i++].tagName, 'TEMPLATE');
    expect(div.nodes[i++].text, 'Item 2');
  });

  test('NestedIterateTableMixedSemanticNative', () {
    if (!TemplateElement.supported) return;

    var div = createTestHtml(
        '<table><tbody>'
          '<template repeat="{{}}">'
            '<tr>'
              '<td template repeat="{{}}" class="{{ val }}">{{ val }}</td>'
            '</tr>'
          '</template>'
        '</tbody></table>');

    var m = toSymbols([
      [{ 'val': 0 }, { 'val': 1 }],
      [{ 'val': 2 }, { 'val': 3 }]
    ]);

    recursivelySetTemplateModel(div, m);
    deliverChanges(m);

    var tbody = div.nodes[0].nodes[0];

    // 1 for the <tr template>, 2 * (1 tr)
    expect(tbody.nodes.length, 3);

    // 1 for the <td template>, 2 * (1 td)
    expect(tbody.nodes[1].nodes.length, 3);

    expect(tbody.nodes[1].nodes[1].text, '0');
    expect(tbody.nodes[1].nodes[2].text, '1');

    // 1 for the <td template>, 2 * (1 td)
    expect(tbody.nodes[2].nodes.length, 3);
    expect(tbody.nodes[2].nodes[1].text, '2');
    expect(tbody.nodes[2].nodes[2].text, '3');

    // Asset the 'class' binding is retained on the semantic template (just
    // check the last one).
    expect(tbody.nodes[2].nodes[2].attributes["class"], '3');
  });

  test('NestedIterateTable', () {
    var div = createTestHtml(
        '<table><tbody>'
          '<tr template repeat="{{}}">'
            '<td template repeat="{{}}" class="{{ val }}">{{ val }}</td>'
          '</tr>'
        '</tbody></table>');

    var m = toSymbols([
      [{ 'val': 0 }, { 'val': 1 }],
      [{ 'val': 2 }, { 'val': 3 }]
    ]);

    recursivelySetTemplateModel(div, m);
    deliverChanges(m);

    var i = 1;
    var tbody = div.nodes[0].nodes[0];

    // 1 for the <tr template>, 2 * (1 tr)
    expect(tbody.nodes.length, 3);

    // 1 for the <td template>, 2 * (1 td)
    expect(tbody.nodes[1].nodes.length, 3);
    expect(tbody.nodes[1].nodes[1].text, '0');
    expect(tbody.nodes[1].nodes[2].text, '1');

    // 1 for the <td template>, 2 * (1 td)
    expect(tbody.nodes[2].nodes.length, 3);
    expect(tbody.nodes[2].nodes[1].text, '2');
    expect(tbody.nodes[2].nodes[2].text, '3');

    // Asset the 'class' binding is retained on the semantic template (just check
    // the last one).
    expect(tbody.nodes[2].nodes[2].attributes['class'], '3');
  });

  test('NestedRepeatDeletionOfMultipleSubTemplates', () {
    var div = createTestHtml(
        '<ul>'
          '<template repeat="{{}}" id=t1>'
            '<li>{{name}}'
              '<ul>'
                '<template ref=t1 repaet="{{items}}"></template>'
              '</ul>'
            '</li>'
          '</template>'
        '</ul>');

    var m = toSymbols([
      {
        'name': 'Item 1',
        'items': [
          {
            'name': 'Item 1.1'
          }
        ]
      }
    ]);

    recursivelySetTemplateModel(div, m);

    deliverChanges(m);
    m.removeAt(0);
    deliverChanges(m);
  });

  test('DeepNested', () {
    var div = createTestHtml(
      '<template bind="{{a}}">'
        '<p>'
          '<template bind="{{b}}">'
            '{{ c }}'
          '</template>'
        '</p>'
      '</template>');

    var m = toSymbols({
      'a': {
        'b': {
          'c': 42
        }
      }
    });
    recursivelySetTemplateModel(div, m);
    deliverChanges(m);

    expect(div.nodes[1].tagName, 'P');
    expect(div.nodes[1].nodes.first.tagName, 'TEMPLATE');
    expect(div.nodes[1].nodes[1].text, '42');
  });

  test('TemplateContentRemoved', () {
    var div = createTestHtml('<template bind="{{}}">{{ }}</template>');
    var model = 42;

    recursivelySetTemplateModel(div, model);
    deliverChanges(model);
    expect(div.nodes[1].text, '42');
    expect(div.nodes[0].text, '');
  });

  test('TemplateContentRemovedEmptyArray', () {
    var div = createTestHtml('<template iterate>Remove me</template>');
    var model = toSymbols([]);

    recursivelySetTemplateModel(div, model);
    deliverChanges(model);
    expect(div.nodes.length, 1);
    expect(div.nodes[0].text, '');
  });

  test('TemplateContentRemovedNested', () {
    var div = createTestHtml(
        '<template bind="{{}}">'
          '{{ a }}'
          '<template bind="{{}}">'
            '{{ b }}'
          '</template>'
        '</template>');

    var model = toSymbolMap({
      'a': 1,
      'b': 2
    });
    recursivelySetTemplateModel(div, model);
    deliverChanges(model);

    expect(div.nodes[0].text, '');
    expect(div.nodes[1].text, '1');
    expect(div.nodes[2].text, '');
    expect(div.nodes[3].text, '2');
  });

  test('BindWithUndefinedModel', () {
    var div = createTestHtml(
        '<template bind="{{}}" if="{{}}">{{ a }}</template>');

    var model = toSymbolMap({'a': 42});
    recursivelySetTemplateModel(div, model);
    deliverChanges(model);
    expect(div.nodes[1].text, '42');

    model = null;
    recursivelySetTemplateModel(div, model);
    deliverChanges(model);
    expect(div.nodes.length, 1);

    model = toSymbols({'a': 42});
    recursivelySetTemplateModel(div, model);
    deliverChanges(model);
    expect(div.nodes[1].text, '42');
  });

  test('BindNested', () {
    var div = createTestHtml(
        '<template bind="{{}}">'
          'Name: {{ name }}'
          '<template bind="{{wife}}" if="{{wife}}">'
            'Wife: {{ name }}'
          '</template>'
          '<template bind="{{child}}" if="{{child}}">'
            'Child: {{ name }}'
          '</template>'
        '</template>');

    var m = toSymbols({
      'name': 'Hermes',
      'wife': {
        'name': 'LaBarbara'
      }
    });
    recursivelySetTemplateModel(div, m);
    deliverChanges(m);

    expect(div.nodes.length, 5);
    expect(div.nodes[1].text, 'Name: Hermes');
    expect(div.nodes[3].text, 'Wife: LaBarbara');

    m[sym('child')] = toSymbols({'name': 'Dwight'});
    deliverChanges(m);
    expect(div.nodes.length, 6);
    expect(div.nodes[5].text, 'Child: Dwight');

    m.remove(sym('wife'));
    deliverChanges(m);
    expect(div.nodes.length, 5);
    expect(div.nodes[4].text, 'Child: Dwight');
  });

  test('BindRecursive', () {
    var div = createTestHtml(
        '<template bind="{{}}" if="{{}}" id="t">'
          'Name: {{ name }}'
          '<template bind="{{friend}}" if="{{friend}}" ref="t"></template>'
        '</template>');

    var m = toSymbols({
      'name': 'Fry',
      'friend': {
        'name': 'Bender'
      }
    });
    recursivelySetTemplateModel(div, m);
    deliverChanges(m);

    expect(div.nodes.length, 5);
    expect(div.nodes[1].text, 'Name: Fry');
    expect(div.nodes[3].text, 'Name: Bender');

    m[sym('friend')][sym('friend')] = toSymbols({'name': 'Leela'});
    deliverChanges(m);
    expect(div.nodes.length, 7);
    expect(div.nodes[5].text, 'Name: Leela');

    m[sym('friend')] = toSymbols({'name': 'Leela'});
    deliverChanges(m);
    expect(div.nodes.length, 5);
    expect(div.nodes[3].text, 'Name: Leela');
  });

  test('ChangeFromBindToRepeat', () {
    var div = createTestHtml(
        '<template bind="{{a}}">'
          '{{ length }}'
        '</template>');
    var template = div.nodes.first;

    var m = toSymbols({
      'a': [
        {'length': 0},
        {
          'length': 1,
          'b': {'length': 4}
        },
        {'length': 2}
      ]
    });
    recursivelySetTemplateModel(div, m);
    deliverChanges(m);

    expect(div.nodes.length, 2);
    expect(div.nodes[1].text, '3');

    template.unbind('bind');
    template.bind('repeat', m, 'a');
    deliverChanges(m);
    expect(div.nodes.length, 4);
    expect(div.nodes[1].text, '0');
    expect(div.nodes[2].text, '1');
    expect(div.nodes[3].text, '2');

    template.unbind('repeat');
    template.bind('bind', m, 'a.1.b');

    deliverChanges(m);
    expect(div.nodes.length, 2);
    expect(div.nodes[1].text, '4');
  });

  test('ChangeRefId', () {
    var div = createTestHtml(
        '<template id="a">a:{{ }}</template>'
        '<template id="b">b:{{ }}</template>'
        '<template repeat="{{}}">'
          '<template ref="a" bind="{{}}"></template>'
        '</template>');
    var model = toSymbols([]);
    recursivelySetTemplateModel(div, model);
    deliverChanges(model);

    expect(div.nodes.length, 3);

    document.getElementById('a').id = 'old-a';
    document.getElementById('b').id = 'a';

    model..add(1)..add(2);
    deliverChanges(model);

    expect(div.nodes.length, 7);
    expect(div.nodes[4].text, 'b:1');
    expect(div.nodes[6].text, 'b:2');
  });

  test('Content', () {
    var div = createTestHtml(
        '<template><a></a></template>'
        '<template><b></b></template>');
    var templateA = div.nodes.first;
    var templateB = div.nodes.last;
    var contentA = templateA.content;
    var contentB = templateB.content;
    expect(contentA, isNotNull);

    expect(templateA.document, isNot(equals(contentA.document)));
    expect(templateB.document, isNot(equals(contentB.document)));

    expect(templateB.document, templateA.document);
    expect(contentB.document, contentA.document);

    expect(templateA.document.window, window);
    expect(templateB.document.window, window);

    expect(contentA.document.window, null);
    expect(contentB.document.window, null);

    expect(contentA.nodes.last, contentA.nodes.first);
    expect(contentA.nodes.first.tagName, 'A');

    expect(contentB.nodes.last, contentB.nodes.first);
    expect(contentB.nodes.first.tagName, 'B');
  });

  test('NestedContent', () {
    var div = createTestHtml(
        '<template>'
        '<template></template>'
        '</template>');
    var templateA = div.nodes.first;
    var templateB = templateA.content.nodes.first;

    expect(templateB.document, templateA.content.document);
    expect(templateB.content.document, templateA.content.document);
  });

  test('BindShadowDOM', () {
    if (ShadowRoot.supported) {
      var root = createShadowTestHtml(
          '<template bind="{{}}">Hi {{ name }}</template>');
      var model = toSymbolMap({'name': 'Leela'});
      recursivelySetTemplateModel(root, model);
      deliverChanges(model);
      expect(root.nodes[1].text, 'Hi Leela');
    }
  });

  // https://github.com/toolkitchen/mdv/issues/8
  test('UnbindingInNestedBind', () {
    var div = createTestHtml(
      '<template bind="{{outer}}" if="{{outer}}" syntax="testHelper">'
        '<template bind="{{inner}}" if="{{inner}}">'
          '{{ age }}'
        '</template>'
      '</template>');

    var syntax = new UnbindingInNestedBindSyntax();
    TemplateElement.syntax['testHelper'] = syntax;
    try {
      var model = toSymbolMap({
        'outer': {
          'inner': {
            'age': 42
          }
        }
      });

      recursivelySetTemplateModel(div, model);

      deliverChanges(model);
      expect(syntax.count, 1);

      var inner = model[sym('outer')][sym('inner')];
      model[sym('outer')] = null;

      deliverChanges(model);
      expect(syntax.count, 1);

      model[sym('outer')] = toSymbols({'inner': {'age': 2}});
      syntax.expectedAge = 2;

      deliverChanges(model);
      expect(syntax.count, 2);
    } finally {
      TemplateElement.syntax.remove('testHelper');
    }
  });

  // https://github.com/toolkitchen/mdv/issues/8
  test('DontCreateInstancesForAbandonedIterators', () {
    var div = createTestHtml(
      '<template bind="{{}} {{}}">'
        '<template bind="{{}}">Foo'
        '</template>'
      '</template>');
    recursivelySetTemplateModel(div, null);
    // TODO(jmesserly): how to fix this test?
    // Perhaps revive the original?
    // https://github.com/toolkitchen/mdv/commit/8bc1e3466aeb6930150c0d3148f0e830184bf599#L3R1278
    //expect(!!ChangeSummary._errorThrownDuringCallback, false);
  });

  test('CreateInstance', () {
    var div = createTestHtml(
      '<template bind="{{a}}">'
        '<template bind="{{b}}">'
          '{{text}}'
        '</template>'
      '</template>');
    var outer = div.nodes.first;

    var instance = outer.createInstance();
    expect(outer.content.nodes.first, instance.nodes.first.ref);

    var instance2 =  outer.createInstance();
    expect(instance2.nodes.first.ref, instance.nodes.first.ref);
  });

  test('Bootstrap', () {
    var div = new DivElement();
    div.innerHtml =
      '<template>'
        '<div></div>'
        '<template>'
          'Hello'
        '</template>'
      '</template>';

    TemplateElement.bootstrap(div);
    var template = div.nodes.first;
    expect(template.content.nodes.length, 2);
    var template2 = template.content.nodes.first.nextNode;
    expect(template2.content.nodes.length, 1);
    expect(template2.content.nodes.first.text, 'Hello');

    template = new Element.tag('template');
    template.innerHtml =
      '<template>'
        '<div></div>'
        '<template>'
          'Hello'
        '</template>'
      '</template>';

    TemplateElement.bootstrap(template);
    template2 = template.content.nodes.first;
    expect(template2.content.nodes.length, 2);
    var template3 = template2.content.nodes.first.nextNode;
    expect(template3.content.nodes.length, 1);
    expect(template3.content.nodes.first.text, 'Hello');
  });

  test('instanceCreated hack', () {
    var called = false;
    var sub = TemplateElement.instanceCreated.listen((node) {
      called = true;
      expect(node.nodeType, Node.DOCUMENT_FRAGMENT_NODE);
    });

    var div = createTestHtml('<template bind="{{}}">Foo</template>');
    expect(called, false);

    recursivelySetTemplateModel(div, null);
    deliverChangeRecords();
    expect(called, true);

    sub.cancel();
  });
}

class UnbindingInNestedBindSyntax extends CustomBindingSyntax {
  int expectedAge = 42;
  int count = 0;

  getBinding(model, path, name, node) {
    if (name != 'text' || path != 'age')
      return;

    expect(model[sym('age')], expectedAge);
    count++;
  }
}

/** Verifies that the model is Observable, then calls [deliverChangeRecords]. */
void deliverChanges(model) {
  expectObservable(model);
  deliverChangeRecords();
}

void expectObservable(model) {
  if (model is! Observable) {
    // This is here to eagerly catch a bug in the test; it means the test
    // forgot a toSymbols somewhere.
    expect(identical(toSymbols(model), model), true,
        reason: 'model type "${model.runtimeType}" should be observable');
    return;
  }
  if (model is ObservableList) {
    for (var item in model) {
      expectObservable(item);
    }
  } else if (model is ObservableMap) {
    model.forEach((k, v) {
      expectObservable(k);
      expectObservable(v);
    });
  }
}

toSymbols(obj) => toObservable(_deepToSymbol(obj));

sym(x) => new Symbol(x);

_deepToSymbol(value) {
  if (value is Map) {
    var result = new LinkedHashMap();
    value.forEach((k, v) {
      k = k is String ? sym(k) : _deepToSymbol(k);
      result[k] = _deepToSymbol(v);
    });
    return result;
  }
  if (value is Iterable) {
    return value.map(_deepToSymbol).toList();
  }
  return value;
}

