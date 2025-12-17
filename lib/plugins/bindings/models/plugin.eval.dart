// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'package:dart_eval/dart_eval_bridge.dart';
import 'package:every_door/models/plugin.dart';
import 'package:dart_eval/stdlib/core.dart';
import 'package:every_door/plugins/bindings/models/version.eval.dart';
import 'package:every_door/plugins/bindings/helpers/multi_icon.eval.dart';
import 'package:dart_eval/stdlib/io.dart';
import 'package:every_door/plugins/bindings/helpers/plugin_i18n.eval.dart';

/// dart_eval wrapper binding for [PluginData]
class $PluginData implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
    runtime.registerBridgeFunc(
      'package:every_door/models/plugin.dart',
      'PluginData.',
      $PluginData.$new,
    );
  }

  /// Compile-time type specification of [$PluginData]
  static const $spec = BridgeTypeSpec(
    'package:every_door/models/plugin.dart',
    'PluginData',
  );

  /// Compile-time type declaration of [$PluginData]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$PluginData]
  static const $declaration = BridgeClassDef(
    BridgeClassType($type),
    constructors: {
      '': BridgeConstructorDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation($type),
          namedParams: [
            BridgeParameter(
              'installed',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
              true,
            ),
          ],
          params: [
            BridgeParameter(
              'id',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
            BridgeParameter(
              'data',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
                ]),
              ),
              false,
            ),
          ],
        ),
        isFactory: false,
      ),
    },
    methods: {},
    getters: {
      'name': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          namedParams: [],
          params: [],
        ),
      ),
      'description': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          namedParams: [],
          params: [],
        ),
      ),
      'author': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.string, []),
            nullable: true,
          ),
          namedParams: [],
          params: [],
        ),
      ),
      'apiVersion': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/models/version.dart',
                'PluginVersionRange',
              ),
              [],
            ),
            nullable: true,
          ),
          namedParams: [],
          params: [],
        ),
      ),
      'url': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.uri, []),
            nullable: true,
          ),
          namedParams: [],
          params: [],
        ),
      ),
      'homepage': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.uri, []),
            nullable: true,
          ),
          namedParams: [],
          params: [],
        ),
      ),
      'icon': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/multi_icon.dart',
                'MultiIcon',
              ),
              [],
            ),
            nullable: true,
          ),
          namedParams: [],
          params: [],
        ),
      ),
    },
    setters: {},
    fields: {
      'id': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
        isStatic: false,
      ),
      'data': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(CoreTypes.map, [
            BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
            BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
          ]),
        ),
        isStatic: false,
      ),
      'installed': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),
      'version': BridgeFieldDef(
        BridgeTypeAnnotation(
          BridgeTypeRef(
            BridgeTypeSpec(
              'package:every_door/models/version.dart',
              'PluginVersion',
            ),
            [],
          ),
        ),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  /// Wrapper for the [PluginData.new] constructor
  static $Value? $new(Runtime runtime, $Value? thisValue, List<$Value?> args) {
    return $PluginData.wrap(
      PluginData(
        args[0]!.$value,
        (args[1]!.$reified as Map).cast(),
        installed: args[2]?.$value ?? true,
      ),
    );
  }

  final $Instance _superclass;

  @override
  final PluginData $value;

  @override
  PluginData get $reified => $value;

  /// Wrap a [PluginData] in a [$PluginData]
  $PluginData.wrap(this.$value) : _superclass = $Object($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'id':
        final _id = $value.id;
        return $String(_id);

      case 'data':
        final _data = $value.data;
        return $Map.wrap(_data);

      case 'installed':
        final _installed = $value.installed;
        return $bool(_installed);

      case 'version':
        final _version = $value.version;
        return $PluginVersion.wrap(_version);

      case 'name':
        final _name = $value.name;
        return $String(_name);

      case 'description':
        final _description = $value.description;
        return $String(_description);

      case 'author':
        final _author = $value.author;
        return _author == null ? const $null() : $String(_author);

      case 'apiVersion':
        final _apiVersion = $value.apiVersion;
        return _apiVersion == null
            ? const $null()
            : $PluginVersionRange.wrap(_apiVersion);

      case 'url':
        final _url = $value.url;
        return _url == null ? const $null() : $Uri.wrap(_url);

      case 'homepage':
        final _homepage = $value.homepage;
        return _homepage == null ? const $null() : $Uri.wrap(_homepage);

      case 'icon':
        final _icon = $value.icon;
        return _icon == null ? const $null() : $MultiIcon.wrap(_icon);
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    return _superclass.$setProperty(runtime, identifier, value);
  }
}

/// dart_eval wrapper binding for [Plugin]
class $Plugin implements $Instance {
  /// Configure this class for use in a [Runtime]
  static void configureForRuntime(Runtime runtime) {
  }

  /// Compile-time type specification of [$Plugin]
  static const $spec = BridgeTypeSpec(
    'package:every_door/models/plugin.dart',
    'Plugin',
  );

  /// Compile-time type declaration of [$Plugin]
  static const $type = BridgeTypeRef($spec);

  /// Compile-time class declaration of [$Plugin]
  static const $declaration = BridgeClassDef(
    BridgeClassType(
      $type,
      $extends: BridgeTypeRef(
        BridgeTypeSpec('package:every_door/models/plugin.dart', 'PluginData'),
        [],
      ),
    ),
    constructors: {},
    methods: {
      'getLocalizationsBranch': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/plugin_i18n.dart',
                'PluginLocalizationsBranch',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'prefix',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),
      'translate': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
          namedParams: [
            BridgeParameter(
              'args',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.map, [
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
                  BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.dynamic)),
                ]),
                nullable: true,
              ),
              true,
            ),
          ],
          params: [
            BridgeParameter(
              'context',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:flutter/src/widgets/framework.dart',
                    'BuildContext',
                  ),
                  [],
                ),
              ),
              false,
            ),
            BridgeParameter(
              'key',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),
      'resolvePath': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(IoTypes.file, [])),
          namedParams: [],
          params: [
            BridgeParameter(
              'name',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),
      'resolveDirectory': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(BridgeTypeRef(IoTypes.directory, [])),
          namedParams: [],
          params: [
            BridgeParameter(
              'name',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
          ],
        ),
      ),
      'loadIcon': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/multi_icon.dart',
                'MultiIcon',
              ),
              [],
            ),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'name',
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.string, [])),
              false,
            ),
            BridgeParameter(
              'tooltip',
              BridgeTypeAnnotation(
                BridgeTypeRef(CoreTypes.string, []),
                nullable: true,
              ),
              true,
            ),
          ],
        ),
      ),
      'showIntro': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.future, [
              BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.voidType)),
            ]),
          ),
          namedParams: [],
          params: [
            BridgeParameter(
              'context',
              BridgeTypeAnnotation(
                BridgeTypeRef(
                  BridgeTypeSpec(
                    'package:flutter/src/widgets/framework.dart',
                    'BuildContext',
                  ),
                  [],
                ),
              ),
              false,
            ),
          ],
        ),
      ),
    },
    getters: {
      'intro': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(CoreTypes.string, []),
            nullable: true,
          ),
          namedParams: [],
          params: [],
        ),
      ),
      'icon': BridgeMethodDef(
        BridgeFunctionDef(
          returns: BridgeTypeAnnotation(
            BridgeTypeRef(
              BridgeTypeSpec(
                'package:every_door/helpers/multi_icon.dart',
                'MultiIcon',
              ),
              [],
            ),
            nullable: true,
          ),
          namedParams: [],
          params: [],
        ),
      ),
    },
    setters: {},
    fields: {
      'active': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(CoreTypes.bool, [])),
        isStatic: false,
      ),
      'directory': BridgeFieldDef(
        BridgeTypeAnnotation(BridgeTypeRef(IoTypes.directory, [])),
        isStatic: false,
      ),
    },
    wrap: true,
    bridge: false,
  );

  final $Instance _superclass;

  @override
  final Plugin $value;

  @override
  Plugin get $reified => $value;

  /// Wrap a [Plugin] in a [$Plugin]
  $Plugin.wrap(this.$value) : _superclass = $PluginData.wrap($value);

  @override
  int $getRuntimeType(Runtime runtime) => runtime.lookupType($spec);

  @override
  $Value? $getProperty(Runtime runtime, String identifier) {
    switch (identifier) {
      case 'active':
        final _active = $value.active;
        return $bool(_active);

      case 'directory':
        final _directory = $value.directory;
        return $Directory.wrap(_directory);

      case 'intro':
        final _intro = $value.intro;
        return _intro == null ? const $null() : $String(_intro);

      case 'icon':
        final _icon = $value.icon;
        return _icon == null ? const $null() : $MultiIcon.wrap(_icon);

      case 'getLocalizationsBranch':
        return __getLocalizationsBranch;

      case 'translate':
        return __translate;

      case 'resolvePath':
        return __resolvePath;

      case 'resolveDirectory':
        return __resolveDirectory;

      case 'loadIcon':
        return __loadIcon;

      case 'showIntro':
        return __showIntro;
    }
    return _superclass.$getProperty(runtime, identifier);
  }

  static const $Function __getLocalizationsBranch = $Function(
    _getLocalizationsBranch,
  );
  static $Value? _getLocalizationsBranch(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $Plugin;
    final result = self.$value.getLocalizationsBranch(args[0]!.$value);
    return $PluginLocalizationsBranch.wrap(result);
  }

  static const $Function __translate = $Function(_translate);
  static $Value? _translate(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $Plugin;
    final result = self.$value.translate(
      args[0]!.$value,
      args[1]!.$value,
      args: (args[2]?.$reified as Map?)?.cast(),
    );
    return $String(result);
  }

  static const $Function __resolvePath = $Function(_resolvePath);
  static $Value? _resolvePath(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $Plugin;
    final result = self.$value.resolvePath(args[0]!.$value);
    return $File.wrap(result);
  }

  static const $Function __resolveDirectory = $Function(_resolveDirectory);
  static $Value? _resolveDirectory(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $Plugin;
    final result = self.$value.resolveDirectory(args[0]!.$value);
    return $Directory.wrap(result);
  }

  static const $Function __loadIcon = $Function(_loadIcon);
  static $Value? _loadIcon(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $Plugin;
    final result = self.$value.loadIcon(args[0]!.$value, args[1]?.$value);
    return $MultiIcon.wrap(result);
  }

  static const $Function __showIntro = $Function(_showIntro);
  static $Value? _showIntro(
    Runtime runtime,
    $Value? target,
    List<$Value?> args,
  ) {
    final self = target! as $Plugin;
    final result = self.$value.showIntro(args[0]!.$value);
    return $Future.wrap(result.then((e) => null));
  }

  @override
  void $setProperty(Runtime runtime, String identifier, $Value value) {
    switch (identifier) {
      case 'active':
        $value.active = value.$value;
        return;

      case 'instance':
        $value.instance = value.$value;
        return;
    }
    return _superclass.$setProperty(runtime, identifier, value);
  }
}
