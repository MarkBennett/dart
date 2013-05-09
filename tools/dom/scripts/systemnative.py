#!/usr/bin/python
# Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

"""This module provides shared functionality for the systems to generate
native binding from the IDL database."""

import emitter
import os
from generator import *
from htmldartgenerator import *
from idlnode import IDLArgument
from systemhtml import js_support_checks, GetCallbackInfo, HTML_LIBRARY_NAMES

class DartiumBackend(HtmlDartGenerator):
  """Generates Dart implementation for one DOM IDL interface."""

  def __init__(self, interface, cpp_library_emitter, options):
    super(DartiumBackend, self).__init__(interface, options)

    self._interface = interface
    self._cpp_library_emitter = cpp_library_emitter
    self._database = options.database
    self._template_loader = options.templates
    self._type_registry = options.type_registry
    self._interface_type_info = self._type_registry.TypeInfo(self._interface.id)
    self._metadata = options.metadata

  def ImplementsMergedMembers(self):
    # We could not add merged functions to implementation class because
    # underlying c++ object doesn't implement them. Merged functions are
    # generated on merged interface implementation instead.
    return False

  def CustomJSMembers(self):
    return {}

  def GenerateCallback(self, info):
    if IsPureInterface(self._interface.id) or IsCustomType(self._interface.id):
      return

    cpp_impl_includes = set()
    cpp_header_handlers_emitter = emitter.Emitter()
    cpp_impl_handlers_emitter = emitter.Emitter()
    class_name = 'Dart%s' % self._interface.id
    for operation in self._interface.operations:
      parameters = []
      arguments = []
      conversion_includes = []
      for argument in operation.arguments:
        argument_type_info = self._TypeInfo(argument.type.id)
        parameters.append('%s %s' % (argument_type_info.parameter_type(),
                                     argument.id))
        arguments.append(argument_type_info.to_dart_conversion(argument.id))
        conversion_includes.extend(argument_type_info.conversion_includes())

      cpp_header_handlers_emitter.Emit(
          '\n'
          '    virtual bool handleEvent($PARAMETERS);\n',
          PARAMETERS=', '.join(parameters))

      if 'Custom' in operation.ext_attrs:
        continue

      cpp_impl_includes |= set(conversion_includes)
      arguments_declaration = 'Dart_Handle arguments[] = { %s }' % ', '.join(arguments)
      if not len(arguments):
        arguments_declaration = 'Dart_Handle* arguments = 0'
      cpp_impl_handlers_emitter.Emit(
          '\n'
          'bool $CLASS_NAME::handleEvent($PARAMETERS)\n'
          '{\n'
          '    if (!m_callback.isIsolateAlive())\n'
          '        return false;\n'
          '    DartIsolateScope scope(m_callback.isolate());\n'
          '    DartApiScope apiScope;\n'
          '    $ARGUMENTS_DECLARATION;\n'
          '    return m_callback.handleEvent($ARGUMENT_COUNT, arguments);\n'
          '}\n',
          CLASS_NAME=class_name,
          PARAMETERS=', '.join(parameters),
          ARGUMENTS_DECLARATION=arguments_declaration,
          ARGUMENT_COUNT=len(arguments))

    cpp_header_emitter = self._cpp_library_emitter.CreateHeaderEmitter(
        self._interface.id,
        self._renamer.GetLibraryName(self._interface),
        True)
    cpp_header_emitter.Emit(
        self._template_loader.Load('cpp_callback_header.template'),
        INTERFACE=self._interface.id,
        HANDLERS=cpp_header_handlers_emitter.Fragments())

    cpp_impl_emitter = self._cpp_library_emitter.CreateSourceEmitter(self._interface.id)
    cpp_impl_emitter.Emit(
        self._template_loader.Load('cpp_callback_implementation.template'),
        INCLUDES=self._GenerateCPPIncludes(cpp_impl_includes),
        INTERFACE=self._interface.id,
        HANDLERS=cpp_impl_handlers_emitter.Fragments())

  def ImplementationTemplate(self):
    template = None
    interface_name = self._interface.doc_js_name
    if interface_name == self._interface.id or not self._database.HasInterface(interface_name):
      template_file = 'impl_%s.darttemplate' % interface_name
      template = self._template_loader.TryLoad(template_file)
    if not template:
      template = self._template_loader.Load('dart_implementation.darttemplate')
    return template

  def RootClassName(self):
    return 'NativeFieldWrapperClass1'

  def NativeSpec(self):
    return ''

  def StartInterface(self, members_emitter):
    # Create emitters for c++ implementation.
    if not IsPureInterface(self._interface.id) and not IsCustomType(self._interface.id):
      self._cpp_header_emitter = self._cpp_library_emitter.CreateHeaderEmitter(
          self._interface.id,
          self._renamer.GetLibraryName(self._interface))
      self._cpp_impl_emitter = self._cpp_library_emitter.CreateSourceEmitter(self._interface.id)
    else:
      self._cpp_header_emitter = emitter.Emitter()
      self._cpp_impl_emitter = emitter.Emitter()

    self._interface_type_info = self._TypeInfo(self._interface.id)
    self._members_emitter = members_emitter
    self._cpp_declarations_emitter = emitter.Emitter()
    self._cpp_impl_includes = set()
    self._cpp_definitions_emitter = emitter.Emitter()
    self._cpp_resolver_emitter = emitter.Emitter()

    # We need to revisit our treatment of typed arrays, right now
    # it is full of hacks.
    if self._interface.ext_attrs.get('ConstructorTemplate') == 'TypedArray':
      self._cpp_resolver_emitter.Emit(
          '    if (name == "$(INTERFACE_NAME)_constructor_Callback")\n'
          '        return Dart$(INTERFACE_NAME)Internal::constructorCallback;\n',
          INTERFACE_NAME=self._interface.id)

      self._cpp_impl_includes.add('"DartArrayBufferViewCustom.h"');
      self._cpp_definitions_emitter.Emit(
        '\n'
        'static void constructorCallback(Dart_NativeArguments args)\n'
        '{\n'
        '    WebCore::DartArrayBufferViewInternal::constructWebGLArray<Dart$(INTERFACE_NAME)>(args);\n'
        '}\n',
        INTERFACE_NAME=self._interface.id);

  def EmitHelpers(self, base_class):
    # Emit internal constructor which is necessary for Dartium bindings
    # to construct wrappers from C++.  Eventually it should go away
    # once it is possible to construct such an instance directly.
    if not self._members_emitter:
      return

    super_constructor = ''
    if base_class and base_class != 'NativeFieldWrapperClass1':
      super_constructor = ' : super.internal()'
    self._members_emitter.Emit(
        '  $CLASSNAME.internal()$SUPERCONSTRUCTOR;\n',
        CLASSNAME=self._interface_type_info.implementation_name(),
        SUPERCONSTRUCTOR=super_constructor)

  def _EmitConstructorInfrastructure(self,
      constructor_info, constructor_callback_cpp_name, factory_method_name,
      argument_count=None):
    constructor_callback_id = self._interface.id + '_' + constructor_callback_cpp_name
    if argument_count is None:
      argument_count = len(constructor_info.param_infos)

    self._members_emitter.Emit(
        '\n  @DocsEditable\n'
        '  static $INTERFACE_NAME $FACTORY_METHOD_NAME($PARAMETERS) '
            'native "$ID";\n',
        INTERFACE_NAME=self._interface_type_info.interface_name(),
        FACTORY_METHOD_NAME=factory_method_name,
        # TODO: add types to parameters.
        PARAMETERS=constructor_info.ParametersAsArgumentList(argument_count),
        ID=constructor_callback_id)

    self._cpp_resolver_emitter.Emit(
        '    if (name == "$ID")\n'
        '        return Dart$(WEBKIT_INTERFACE_NAME)Internal::$CPP_CALLBACK;\n',
        ID=constructor_callback_id,
        WEBKIT_INTERFACE_NAME=self._interface.id,
        CPP_CALLBACK=constructor_callback_cpp_name)

  def GenerateCustomFactory(self, constructor_info):
    if 'CustomConstructor' not in self._interface.ext_attrs:
        return False

    self._members_emitter.Emit(
        '  factory $CTOR($PARAMS) => _create($FACTORY_PARAMS);\n',
        CTOR=constructor_info._ConstructorFullName(self._DartType),
        PARAMS=constructor_info.ParametersDeclaration(self._DartType),
        FACTORY_PARAMS= \
            constructor_info.ParametersAsArgumentList())

    constructor_callback_cpp_name = 'constructorCallback'
    self._EmitConstructorInfrastructure(
        constructor_info, constructor_callback_cpp_name, '_create')

    self._cpp_declarations_emitter.Emit(
        '\n'
        'void $CPP_CALLBACK(Dart_NativeArguments);\n',
        CPP_CALLBACK=constructor_callback_cpp_name)

    return True

  def IsConstructorArgumentOptional(self, argument):
    return False

  def EmitStaticFactoryOverload(self, constructor_info, name, arguments):
    constructor_callback_cpp_name = name + 'constructorCallback'
    self._EmitConstructorInfrastructure(
        constructor_info, constructor_callback_cpp_name, name, len(arguments))

    ext_attrs = self._interface.ext_attrs

    create_function = 'create'
    if 'NamedConstructor' in ext_attrs:
      create_function = 'createForJSConstructor'
    function_expression = '%s::%s' % (self._interface_type_info.native_type(), create_function)
    self._GenerateNativeCallback(
        constructor_callback_cpp_name,
        False,
        function_expression,
        self._interface,
        arguments,
        self._interface.id,
        False,
        'ConstructorRaisesException' in ext_attrs or 'RaisesException' in ext_attrs)

  def HasSupportCheck(self):
    # Need to omit a support check if it is conditional in JS.
    return self._interface.doc_js_name in js_support_checks

  def GetSupportCheck(self):
    # Assume that everything is supported on Dartium.
    value = js_support_checks.get(self._interface.doc_js_name)
    if type(value) == tuple:
      return (value[0], 'true')
    else:
      return 'true'

  def FinishInterface(self):
    self._GenerateCPPHeader()

    self._cpp_impl_emitter.Emit(
        self._template_loader.Load('cpp_implementation.template'),
        INTERFACE=self._interface.id,
        INCLUDES=self._GenerateCPPIncludes(self._cpp_impl_includes),
        CALLBACKS=self._cpp_definitions_emitter.Fragments(),
        RESOLVER=self._cpp_resolver_emitter.Fragments(),
        DART_IMPLEMENTATION_CLASS=self._interface_type_info.implementation_name(),
        DART_IMPLEMENTATION_LIBRARY='dart:%s' % self._renamer.GetLibraryName(self._interface))

  def _GenerateCPPHeader(self):
    to_native_emitter = emitter.Emitter()
    if self._interface_type_info.custom_to_native():
      return_type = 'PassRefPtr<NativeType>'
      to_native_body = ';'
    else:
      return_type = 'NativeType*'
      to_native_body = emitter.Format(
          '\n'
          '    {\n'
          '        return DartDOMWrapper::unwrapDartWrapper<Dart$INTERFACE>(handle, exception);\n'
          '    }',
          INTERFACE=self._interface.id)

    to_native_emitter.Emit(
        '    static $RETURN_TYPE toNative(Dart_Handle handle, Dart_Handle& exception)$TO_NATIVE_BODY\n'
        '\n'
        '    static $RETURN_TYPE toNativeWithNullCheck(Dart_Handle handle, Dart_Handle& exception)\n'
        '    {\n'
        '        return Dart_IsNull(handle) ? 0 : toNative(handle, exception);\n'
        '    }\n',
        RETURN_TYPE=return_type,
        TO_NATIVE_BODY=to_native_body,
        INTERFACE=self._interface.id)

    to_dart_emitter = emitter.Emitter()

    ext_attrs = self._interface.ext_attrs

    if ('CustomToJS' in ext_attrs or
        ('CustomToJSObject' in ext_attrs and 'TypedArray' not in ext_attrs) or
        'PureInterface' in ext_attrs or
        'CPPPureInterface' in ext_attrs or
        self._interface_type_info.custom_to_dart()):
      to_dart_emitter.Emit(
          '    static Dart_Handle toDart(NativeType* value);\n')
    else:
      to_dart_emitter.Emit(
          '    static Dart_Handle toDart(NativeType* value)\n'
          '    {\n'
          '        return DartDOMWrapper::toDart<Dart$(INTERFACE)>(value);\n'
          '    }\n',
          INTERFACE=self._interface.id)

    webcore_includes = self._GenerateCPPIncludes(
        self._interface_type_info.webcore_includes())

    is_node_test = lambda interface: interface.id == 'Node'
    is_active_test = lambda interface: 'ActiveDOMObject' in interface.ext_attrs
    is_event_target_test = lambda interface: 'EventTarget' in interface.ext_attrs
    def TypeCheckHelper(test):
      return 'true' if any(map(test, self._database.Hierarchy(self._interface))) else 'false'

    self._cpp_header_emitter.Emit(
        self._template_loader.Load('cpp_header.template'),
        INTERFACE=self._interface.id,
        WEBCORE_INCLUDES=webcore_includes,
        WEBCORE_CLASS_NAME=self._interface_type_info.native_type(),
        DECLARATIONS=self._cpp_declarations_emitter.Fragments(),
        IS_NODE=TypeCheckHelper(is_node_test),
        IS_ACTIVE=TypeCheckHelper(is_active_test),
        IS_EVENT_TARGET=TypeCheckHelper(is_event_target_test),
        TO_NATIVE=to_native_emitter.Fragments(),
        TO_DART=to_dart_emitter.Fragments())

  def EmitAttribute(self, attribute, html_name, read_only):
    self._AddGetter(attribute, html_name)
    if not read_only:
      self._AddSetter(attribute, html_name)

  def _AddGetter(self, attr, html_name):
    # Temporary hack to force dart:scalarlist clamped array for ImageData.data.
    # TODO(antonm): solve in principled way.
    if self._interface.id == 'ImageData' and html_name == 'data':
      html_name = '_data'
    type_info = self._TypeInfo(attr.type.id)
    dart_declaration = '%s get %s' % (
        self.SecureOutputType(attr.type.id), html_name)
    is_custom = 'Custom' in attr.ext_attrs or 'CustomGetter' in attr.ext_attrs
    cpp_callback_name = self._GenerateNativeBinding(attr.id, 1,
        dart_declaration, 'Getter', is_custom)
    if is_custom:
      return

    if 'Reflect' in attr.ext_attrs:
      webcore_function_name = self._TypeInfo(attr.type.id).webcore_getter_name()
      if 'URL' in attr.ext_attrs:
        if 'NonEmpty' in attr.ext_attrs:
          webcore_function_name = 'getNonEmptyURLAttribute'
        else:
          webcore_function_name = 'getURLAttribute'
    elif 'ImplementedAs' in attr.ext_attrs:
      webcore_function_name = attr.ext_attrs['ImplementedAs']
    else:
      if attr.id == 'operator':
        webcore_function_name = '_operator'
      elif attr.id == 'target' and attr.type.id == 'SVGAnimatedString':
        webcore_function_name = 'svgTarget'
      else:
        webcore_function_name = self._ToWebKitName(attr.id)
      if attr.type.id.startswith('SVGAnimated'):
        webcore_function_name += 'Animated'

    function_expression = self._GenerateWebCoreFunctionExpression(webcore_function_name, attr)
    self._GenerateNativeCallback(
        cpp_callback_name,
        True,
        function_expression,
        attr,
        [],
        attr.type.id,
        attr.type.nullable,
        'GetterRaisesException' in attr.ext_attrs)

  def _AddSetter(self, attr, html_name):
    type_info = self._TypeInfo(attr.type.id)
    dart_declaration = 'void set %s(%s value)' % (html_name, self._DartType(attr.type.id))
    is_custom = set(['Custom', 'CustomSetter', 'V8CustomSetter']) & set(attr.ext_attrs)
    cpp_callback_name = self._GenerateNativeBinding(attr.id, 2,
        dart_declaration, 'Setter', is_custom)
    if is_custom:
      return

    if 'Reflect' in attr.ext_attrs:
      webcore_function_name = self._TypeInfo(attr.type.id).webcore_setter_name()
    else:
      webcore_function_name = re.sub(r'^(xml(?=[A-Z])|\w)',
                                     lambda s: s.group(1).upper(),
                                     attr.id)
      webcore_function_name = 'set%s' % webcore_function_name
      if attr.type.id.startswith('SVGAnimated'):
        webcore_function_name += 'Animated'

    function_expression = self._GenerateWebCoreFunctionExpression(webcore_function_name, attr)
    self._GenerateNativeCallback(
        cpp_callback_name,
        True,
        function_expression,
        attr,
        [attr],
        'void',
        False,
        'SetterRaisesException' in attr.ext_attrs)

  def AddIndexer(self, element_type):
    """Adds all the methods required to complete implementation of List."""
    # We would like to simply inherit the implementation of everything except
    # length, [], and maybe []=.  It is possible to extend from a base
    # array implementation class only when there is no other implementation
    # inheritance.  There might be no implementation inheritance other than
    # DOMBaseWrapper for many classes, but there might be some where the
    # array-ness is introduced by a non-root interface:
    #
    #   interface Y extends X, List<T> ...
    #
    # In the non-root case we have to choose between:
    #
    #   class YImpl extends XImpl { add List<T> methods; }
    #
    # and
    #
    #   class YImpl extends ListBase<T> { copies of transitive XImpl methods; }
    #
    dart_element_type = self._DartType(element_type)
    if self._HasNativeIndexGetter():
      self._EmitNativeIndexGetter(dart_element_type)
    else:
      self._members_emitter.Emit(
          '\n'
          '  $TYPE operator[](int index) {\n'
          '    if (index < 0 || index >= length)\n'
          '      throw new RangeError.range(index, 0, length);\n'
          '    return _nativeIndexedGetter(index);\n'
          '  }\n'
          '  $TYPE _nativeIndexedGetter(int index) native "$(INTERFACE)_item_Callback";\n',
          TYPE=self.SecureOutputType(element_type),
          INTERFACE=self._interface.id)

    if self._HasNativeIndexSetter():
      self._EmitNativeIndexSetter(dart_element_type)
    else:
      self._members_emitter.Emit(
          '\n'
          '  void operator[]=(int index, $TYPE value) {\n'
          '    throw new UnsupportedError("Cannot assign element of immutable List.");\n'
          '  }\n',
          TYPE=dart_element_type)

    self.EmitListMixin(dart_element_type)

  def AmendIndexer(self, element_type):
    # If interface is marked as having native indexed
    # getter or setter, we must emit overrides as it's not
    # guaranteed that the corresponding methods in C++ would be
    # virtual.  For example, as of time of writing, even though
    # Uint8ClampedArray inherits from Uint8Array, ::set method
    # is not virtual and accessing it through Uint8Array pointer
    # would lead to wrong semantics (modulo vs. clamping.)
    dart_element_type = self._DartType(element_type)

    if self._HasNativeIndexGetter():
      self._EmitNativeIndexGetter(dart_element_type)
    if self._HasNativeIndexSetter():
      self._EmitNativeIndexSetter(dart_element_type)

  def _HasNativeIndexGetter(self):
    ext_attrs = self._interface.ext_attrs
    return ('CustomIndexedGetter' in ext_attrs or
        'NumericIndexedGetter' in ext_attrs)

  def _EmitNativeIndexGetter(self, element_type):
    dart_declaration = '%s operator[](int index)' % \
        self.SecureOutputType(element_type, True)
    self._GenerateNativeBinding('numericIndexGetter', 2, dart_declaration,
        'Callback', True)

  def _HasNativeIndexSetter(self):
    return 'CustomIndexedSetter' in self._interface.ext_attrs

  def _EmitNativeIndexSetter(self, element_type):
    dart_declaration = 'void operator[]=(int index, %s value)' % element_type
    self._GenerateNativeBinding('numericIndexSetter', 3, dart_declaration,
        'Callback', True)

  def EmitOperation(self, info, html_name):
    """
    Arguments:
      info: An OperationInfo object.
    """

    dart_declaration = '%s%s %s(%s)' % (
        'static ' if info.IsStatic() else '',
        self.SecureOutputType(info.type_name),
        html_name,
        info.ParametersDeclaration(self._DartType))

    operation = info.operations[0]
    is_custom = 'Custom' in operation.ext_attrs
    has_optional_arguments = any(self._IsArgumentOptionalInWebCore(operation, argument) for argument in operation.arguments)
    needs_dispatcher = not is_custom and (len(info.operations) > 1 or has_optional_arguments)

    if info.callback_args:
      self._AddFutureifiedOperation(info, html_name)
    elif not needs_dispatcher:
      # Bind directly to native implementation
      argument_count = (0 if info.IsStatic() else 1) + len(info.param_infos)
      cpp_callback_name = self._GenerateNativeBinding(
          info.name, argument_count, dart_declaration, 'Callback', is_custom)
      if not is_custom:
        self._GenerateOperationNativeCallback(operation, operation.arguments, cpp_callback_name)
    else:
      self._GenerateDispatcher(info.operations, dart_declaration, [info.name for info in info.param_infos])

  def _GenerateDispatcher(self, operations, dart_declaration, parameter_names):

    def GenerateCall(
        stmts_emitter, call_emitter, version, operation, argument_count):
      overload_name = '_%s_%s' % (operation.id, version)
      argument_list = ', '.join(parameter_names[:argument_count])
      call_emitter.Emit('$NAME($ARGS)', NAME=overload_name, ARGS=argument_list)

      dart_declaration = '%s%s %s(%s)' % (
          'static ' if operation.is_static else '',
          self.SecureOutputType(operation.type.id),
          overload_name, argument_list)
      cpp_callback_name = self._GenerateNativeBinding(
          overload_name, (0 if operation.is_static else 1) + argument_count,
          dart_declaration, 'Callback', False, False)
      self._GenerateOperationNativeCallback(operation, operation.arguments[:argument_count], cpp_callback_name)

    self._GenerateDispatcherBody(
        operations,
        parameter_names,
        dart_declaration,
        GenerateCall,
        self._IsArgumentOptionalInWebCore)

  def SecondaryContext(self, interface):
    pass

  def _GenerateOperationNativeCallback(self, operation, arguments, cpp_callback_name):
    webcore_function_name = operation.ext_attrs.get('ImplementedAs', operation.id)
    function_expression = self._GenerateWebCoreFunctionExpression(webcore_function_name, operation)
    self._GenerateNativeCallback(
        cpp_callback_name,
        not operation.is_static,
        function_expression,
        operation,
        arguments,
        operation.type.id,
        operation.type.nullable,
        'RaisesException' in operation.ext_attrs)

  def _GenerateNativeCallback(self,
      callback_name,
      needs_receiver,
      function_expression,
      node,
      arguments,
      return_type,
      return_type_is_nullable,
      raises_dom_exception):
    ext_attrs = node.ext_attrs

    cpp_arguments = []
    runtime_check = None
    raises_exceptions = raises_dom_exception or arguments

    # TODO(antonm): unify with ScriptState below.
    requires_stack_info = ext_attrs.get('CallWith') == 'ScriptArguments|ScriptState'
    if requires_stack_info:
      raises_exceptions = True
      cpp_arguments = ['&state', 'scriptArguments.release()']
      # WebKit uses scriptArguments to reconstruct last argument, so
      # it's not needed and should be just removed.
      arguments = arguments[:-1]

    # TODO(antonm): unify with ScriptState below.
    requires_script_arguments = ext_attrs.get('CallWith') == 'ScriptArguments'
    if requires_script_arguments:
      raises_exceptions = True
      cpp_arguments = ['scriptArguments.release()']
      # WebKit uses scriptArguments to reconstruct last argument, so
      # it's not needed and should be just removed.
      arguments = arguments[:-1]

    requires_script_execution_context = ext_attrs.get('CallWith') == 'ScriptExecutionContext'
    if requires_script_execution_context:
      raises_exceptions = True
      cpp_arguments = ['context']

    requires_script_state = ext_attrs.get('CallWith') == 'ScriptState'
    if requires_script_state:
      raises_exceptions = True
      cpp_arguments = ['&state']

    requires_dom_window = 'NamedConstructor' in ext_attrs
    if requires_dom_window:
      raises_exceptions = True
      cpp_arguments = ['document']

    if 'ImplementedBy' in ext_attrs:
      assert needs_receiver
      self._cpp_impl_includes.add('"%s.h"' % ext_attrs['ImplementedBy'])
      cpp_arguments.append('receiver')

    if 'Reflect' in ext_attrs:
      cpp_arguments = [self._GenerateWebCoreReflectionAttributeName(node)]

    if return_type_is_nullable:
      cpp_arguments = ['isNull']

    v8EnabledPerContext = ext_attrs.get('synthesizedV8EnabledPerContext', ext_attrs.get('V8EnabledPerContext'))
    v8EnabledAtRuntime = ext_attrs.get('synthesizedV8EnabledAtRuntime', ext_attrs.get('V8EnabledAtRuntime'))
    assert(not (v8EnabledPerContext and v8EnabledAtRuntime))

    if v8EnabledPerContext:
      raises_exceptions = True
      self._cpp_impl_includes.add('"ContextFeatures.h"')
      self._cpp_impl_includes.add('"DOMWindow.h"')
      runtime_check = emitter.Format(
          '        if (!ContextFeatures::$(FEATURE)Enabled(DartUtilities::domWindowForCurrentIsolate()->document())) {\n'
          '            exception = Dart_NewStringFromCString("Feature $FEATURE is not enabled");\n'
          '            goto fail;\n'
          '        }',
          FEATURE=v8EnabledPerContext)

    if v8EnabledAtRuntime:
      raises_exceptions = True
      self._cpp_impl_includes.add('"RuntimeEnabledFeatures.h"')
      runtime_check = emitter.Format(
          '        if (!RuntimeEnabledFeatures::$(FEATURE)Enabled()) {\n'
          '            exception = Dart_NewStringFromCString("Feature $FEATURE is not enabled");\n'
          '            goto fail;\n'
          '        }',
          FEATURE=self._ToWebKitName(v8EnabledAtRuntime))

    body_emitter = self._cpp_definitions_emitter.Emit(
        '\n'
        'static void $CALLBACK_NAME(Dart_NativeArguments args)\n'
        '{\n'
        '    DartApiScope dartApiScope;\n'
        '$!BODY'
        '}\n',
        CALLBACK_NAME=callback_name)

    if raises_exceptions:
      body_emitter = body_emitter.Emit(
          '    Dart_Handle exception = 0;\n'
          '$!BODY'
          '\n'
          'fail:\n'
          '    Dart_ThrowException(exception);\n'
          '    ASSERT_NOT_REACHED();\n')

    body_emitter = body_emitter.Emit(
        '    {\n'
        '$!BODY'
        '        return;\n'
        '    }\n')

    if runtime_check:
      body_emitter.Emit(
          '$RUNTIME_CHECK\n',
          RUNTIME_CHECK=runtime_check)

    if requires_script_execution_context:
      body_emitter.Emit(
          '        ScriptExecutionContext* context = DartUtilities::scriptExecutionContext();\n'
          '        if (!context) {\n'
          '            exception = Dart_NewStringFromCString("Failed to retrieve a context");\n'
          '            goto fail;\n'
          '        }\n\n')

    if requires_script_state:
      body_emitter.Emit(
          '        ScriptState* currentState = ScriptState::current();\n'
          '        if (!currentState) {\n'
          '            exception = Dart_NewStringFromCString("Failed to retrieve a script state");\n'
          '            goto fail;\n'
          '        }\n'
          '        ScriptState& state = *currentState;\n\n')

    if requires_dom_window:
      self._cpp_impl_includes.add('"DOMWindow.h"')
      body_emitter.Emit(
          '        DOMWindow* domWindow = DartUtilities::domWindowForCurrentIsolate();\n'
          '        if (!domWindow) {\n'
          '            exception = Dart_NewStringFromCString("Failed to fetch domWindow");\n'
          '            goto fail;\n'
          '        }\n'
          '        Document* document = domWindow->document();\n')

    if needs_receiver:
      body_emitter.Emit(
          '        $WEBCORE_CLASS_NAME* receiver = DartDOMWrapper::receiver< $WEBCORE_CLASS_NAME >(args);\n',
          WEBCORE_CLASS_NAME=self._interface_type_info.native_type())

    if requires_stack_info:
      self._cpp_impl_includes.add('"ScriptArguments.h"')
      self._cpp_impl_includes.add('"ScriptCallStack.h"')
      body_emitter.Emit(
          '\n'
          '        ScriptState* currentState = ScriptState::current();\n'
          '        if (!currentState) {\n'
          '            exception = Dart_NewStringFromCString("Failed to retrieve a script state");\n'
          '            goto fail;\n'
          '        }\n'
          '        ScriptState& state = *currentState;\n'
          '\n'
          '        Dart_Handle customArgument = Dart_GetNativeArgument(args, $INDEX);\n'
          '        RefPtr<ScriptArguments> scriptArguments(DartUtilities::createScriptArguments(customArgument, exception));\n'
          '        if (!scriptArguments)\n'
          '            goto fail;\n'
          '        RefPtr<ScriptCallStack> scriptCallStack(DartUtilities::createScriptCallStack());\n'
          '        if (!scriptCallStack->size())\n'
          '            return;\n',
          INDEX=len(arguments) + 1)

    if requires_script_arguments:
      self._cpp_impl_includes.add('"ScriptArguments.h"')
      body_emitter.Emit(
          '\n'
          '        Dart_Handle customArgument = Dart_GetNativeArgument(args, $INDEX);\n'
          '        RefPtr<ScriptArguments> scriptArguments(DartUtilities::createScriptArguments(customArgument, exception));\n'
          '        if (!scriptArguments)\n'
          '            goto fail;\n'
          '        RefPtr<ScriptCallStack> scriptCallStack(DartUtilities::createScriptCallStack());\n'
          '        if (!scriptCallStack->size())\n'
          '            return;\n',
          INDEX=len(arguments) + 1)

    # Emit arguments.
    start_index = 1 if needs_receiver else 0
    for i, argument in enumerate(arguments):
      type_info = self._TypeInfo(argument.type.id)
      argument_expression_template, type, cls, function = \
          type_info.to_native_info(argument, self._interface.id)

      def AllowsNull():
        assert argument.ext_attrs.get('TreatNullAs', 'NullString') == 'NullString'
        if argument.ext_attrs.get('TreatNullAs') == 'NullString':
          return True

        if argument.type.nullable:
          return True

        if isinstance(argument, IDLArgument):
          if IsOptional(argument) and not self._IsArgumentOptionalInWebCore(node, argument):
            return True
          if argument.ext_attrs.get('Default') == 'NullString':
            return True
          if _IsOptionalStringArgumentInInitEventMethod(self._interface, node, argument):
            return True

        return False

      if AllowsNull():
        function += 'WithNullCheck'

      argument_name = DartDomNameOfAttribute(argument)
      if type_info.pass_native_by_ref():
        invocation_template =\
            '        $TYPE $ARGUMENT_NAME;\n'\
            '        $CLS::$FUNCTION(Dart_GetNativeArgument(args, $INDEX), $ARGUMENT_NAME, exception);\n'
      else:
        invocation_template =\
            '        $TYPE $ARGUMENT_NAME = $CLS::$FUNCTION(Dart_GetNativeArgument(args, $INDEX), exception);\n'
      body_emitter.Emit(
          '\n' +
          invocation_template +
          '        if (exception)\n'
          '            goto fail;\n',
          TYPE=type,
          ARGUMENT_NAME=argument_name,
          CLS=cls,
          FUNCTION=function,
          INDEX=start_index + i)
      self._cpp_impl_includes.add('"%s.h"' % cls)
      cpp_arguments.append(argument_expression_template % argument_name)

    body_emitter.Emit('\n')

    if 'NeedsUserGestureCheck' in ext_attrs:
      cpp_arguments.append('DartUtilities::processingUserGesture')

    invocation_emitter = body_emitter
    if raises_dom_exception:
      cpp_arguments.append('ec')
      invocation_emitter = body_emitter.Emit(
        '        ExceptionCode ec = 0;\n'
        '$!INVOCATION'
        '        if (UNLIKELY(ec)) {\n'
        '            exception = DartDOMWrapper::exceptionCodeToDartException(ec);\n'
        '            goto fail;\n'
        '        }\n')

    function_call = '%s(%s)' % (function_expression, ', '.join(cpp_arguments))
    if return_type == 'void':
      invocation_emitter.Emit(
        '        $FUNCTION_CALL;\n',
        FUNCTION_CALL=function_call)
    else:
      return_type_info = self._TypeInfo(return_type)
      self._cpp_impl_includes |= set(return_type_info.conversion_includes())

      if return_type_is_nullable:
        invocation_emitter.Emit(
          '        bool isNull = false;\n'
          '        $NATIVE_TYPE result = $FUNCTION_CALL;\n'
          '        if (isNull)\n'
          '            return;\n',
          NATIVE_TYPE=return_type_info.native_type(),
          FUNCTION_CALL=function_call)
        value_expression = 'result'
      else:
        value_expression = function_call

      # Generate to Dart conversion of C++ value.
      to_dart_conversion = return_type_info.to_dart_conversion(value_expression, self._interface.id, ext_attrs)
      invocation_emitter.Emit(
        '        Dart_Handle returnValue = $TO_DART_CONVERSION;\n'
        '        if (returnValue)\n'
        '            Dart_SetReturnValue(args, returnValue);\n',
        TO_DART_CONVERSION=to_dart_conversion)

  def _GenerateNativeBinding(self, idl_name, argument_count, dart_declaration,
      native_suffix, is_custom, emit_metadata=True):
    metadata = []
    if emit_metadata:
      metadata = self._metadata.GetFormattedMetadata(
          self._renamer.GetLibraryName(self._interface),
          self._interface, idl_name, '  ')

    native_binding = '%s_%s_%s' % (self._interface.id, idl_name, native_suffix)
    self._members_emitter.Emit(
        '\n'
        '  $METADATA$DART_DECLARATION native "$NATIVE_BINDING";\n',
        DOMINTERFACE=self._interface.id,
        METADATA=metadata,
        DART_DECLARATION=dart_declaration,
        NATIVE_BINDING=native_binding)

    cpp_callback_name = '%s%s' % (idl_name, native_suffix)
    self._cpp_resolver_emitter.Emit(
        '    if (argumentCount == $ARGC && name == "$NATIVE_BINDING")\n'
        '        return Dart$(INTERFACE_NAME)Internal::$CPP_CALLBACK_NAME;\n',
        ARGC=argument_count,
        NATIVE_BINDING=native_binding,
        INTERFACE_NAME=self._interface.id,
        CPP_CALLBACK_NAME=cpp_callback_name)

    if is_custom:
      self._cpp_declarations_emitter.Emit(
          '\n'
          'void $CPP_CALLBACK_NAME(Dart_NativeArguments);\n',
          CPP_CALLBACK_NAME=cpp_callback_name)

    return cpp_callback_name

  def _GenerateWebCoreReflectionAttributeName(self, attr):
    namespace = 'HTMLNames'
    svg_exceptions = ['class', 'id', 'onabort', 'onclick', 'onerror', 'onload',
                      'onmousedown', 'onmousemove', 'onmouseout', 'onmouseover',
                      'onmouseup', 'onresize', 'onscroll', 'onunload']
    if self._interface.id.startswith('SVG') and not attr.id in svg_exceptions:
      namespace = 'SVGNames'
    self._cpp_impl_includes.add('"%s.h"' % namespace)

    attribute_name = attr.ext_attrs['Reflect'] or attr.id.lower()
    return 'WebCore::%s::%sAttr' % (namespace, attribute_name)

  def _GenerateWebCoreFunctionExpression(self, function_name, idl_node):
    if 'ImplementedBy' in idl_node.ext_attrs:
      return '%s::%s' % (idl_node.ext_attrs['ImplementedBy'], function_name)
    if idl_node.is_static:
      return '%s::%s' % (self._interface_type_info.idl_type(), function_name)
    return '%s%s' % (self._interface_type_info.receiver(), function_name)

  def _IsArgumentOptionalInWebCore(self, operation, argument):
    if not IsOptional(argument):
      return False
    if 'Callback' in argument.ext_attrs:
      return False
    if operation.id in ['addEventListener', 'removeEventListener'] and argument.id == 'useCapture':
      return False
    if 'ForceOptional' in argument.ext_attrs:
      return False
    if argument.type.id == 'Dictionary':
      return False
    return True

  def _GenerateCPPIncludes(self, includes):
    return ''.join(['#include %s\n' % include for include in sorted(includes)])

  def _ToWebKitName(self, name):
    name = name[0].lower() + name[1:]
    name = re.sub(r'^(hTML|uRL|jS|xML|xSLT)', lambda s: s.group(1).lower(),
                  name)
    return re.sub(r'^(create|exclusive)',
                  lambda s: 'is' + s.group(1).capitalize(),
                  name)

  def _TypeInfo(self, type_name):
    return self._type_registry.TypeInfo(type_name)

  def _DartType(self, type_name):
    return self._type_registry.DartType(type_name)


class CPPLibraryEmitter():
  def __init__(self, emitters, cpp_sources_dir):
    self._emitters = emitters
    self._cpp_sources_dir = cpp_sources_dir
    self._library_headers = dict((lib, []) for lib in HTML_LIBRARY_NAMES)
    self._sources_list = []

  def CreateHeaderEmitter(self, interface_name, library_name, is_callback=False):
    path = os.path.join(self._cpp_sources_dir, 'Dart%s.h' % interface_name)
    if not is_callback:
      self._library_headers[library_name].append(path)
    return self._emitters.FileEmitter(path)

  def CreateSourceEmitter(self, interface_name):
    path = os.path.join(self._cpp_sources_dir, 'Dart%s.cpp' % interface_name)
    self._sources_list.append(path)
    return self._emitters.FileEmitter(path)

  def EmitDerivedSources(self, template, output_dir):
    partitions = 20 # FIXME: this should be configurable.
    sources_count = len(self._sources_list)
    for i in range(0, partitions):
      file_path = os.path.join(output_dir, 'DartDerivedSources%02i.cpp' % (i + 1))
      includes_emitter = self._emitters.FileEmitter(file_path).Emit(template)
      for source_file in self._sources_list[i::partitions]:
        path = os.path.relpath(source_file, output_dir)
        includes_emitter.Emit('#include "$PATH"\n', PATH=path)

  def EmitResolver(self, template, output_dir):
    for library_name in self._library_headers.keys():
      file_path = os.path.join(output_dir, '%s_DartResolver.cpp' % library_name)
      includes_emitter, body_emitter = self._emitters.FileEmitter(file_path).Emit(
        template,
        LIBRARY_NAME=library_name)

      headers = self._library_headers[library_name]
      for header_file in headers:
        path = os.path.relpath(header_file, output_dir)
        includes_emitter.Emit('#include "$PATH"\n', PATH=path)
        body_emitter.Emit(
            '    if (Dart_NativeFunction func = $CLASS_NAME::resolver(name, argumentCount))\n'
            '        return func;\n',
            CLASS_NAME=os.path.splitext(os.path.basename(path))[0])

def _IsOptionalStringArgumentInInitEventMethod(interface, operation, argument):
  return (
      interface.id.endswith('Event') and
      operation.id.startswith('init') and
      argument.ext_attrs.get('Default') == 'Undefined' and
      argument.type.id == 'DOMString')
