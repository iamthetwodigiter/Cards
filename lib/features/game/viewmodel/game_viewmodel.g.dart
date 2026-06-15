// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gameViewModelHash() => r'6c06edd607b1c93a167ca40b32ea4fe7275b2e1d';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$GameViewModel
    extends BuildlessAutoDisposeNotifier<GameState?> {
  late final String roomId;
  late final String playerName;
  late final String avatar;

  GameState? build(String roomId, String playerName, {String avatar = ""});
}

/// See also [GameViewModel].
@ProviderFor(GameViewModel)
const gameViewModelProvider = GameViewModelFamily();

/// See also [GameViewModel].
class GameViewModelFamily extends Family<GameState?> {
  /// See also [GameViewModel].
  const GameViewModelFamily();

  /// See also [GameViewModel].
  GameViewModelProvider call(
    String roomId,
    String playerName, {
    String avatar = "",
  }) {
    return GameViewModelProvider(roomId, playerName, avatar: avatar);
  }

  @override
  GameViewModelProvider getProviderOverride(
    covariant GameViewModelProvider provider,
  ) {
    return call(provider.roomId, provider.playerName, avatar: provider.avatar);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'gameViewModelProvider';
}

/// See also [GameViewModel].
class GameViewModelProvider
    extends AutoDisposeNotifierProviderImpl<GameViewModel, GameState?> {
  /// See also [GameViewModel].
  GameViewModelProvider(String roomId, String playerName, {String avatar = ""})
    : this._internal(
        () => GameViewModel()
          ..roomId = roomId
          ..playerName = playerName
          ..avatar = avatar,
        from: gameViewModelProvider,
        name: r'gameViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$gameViewModelHash,
        dependencies: GameViewModelFamily._dependencies,
        allTransitiveDependencies:
            GameViewModelFamily._allTransitiveDependencies,
        roomId: roomId,
        playerName: playerName,
        avatar: avatar,
      );

  GameViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.roomId,
    required this.playerName,
    required this.avatar,
  }) : super.internal();

  final String roomId;
  final String playerName;
  final String avatar;

  @override
  GameState? runNotifierBuild(covariant GameViewModel notifier) {
    return notifier.build(roomId, playerName, avatar: avatar);
  }

  @override
  Override overrideWith(GameViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: GameViewModelProvider._internal(
        () => create()
          ..roomId = roomId
          ..playerName = playerName
          ..avatar = avatar,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        roomId: roomId,
        playerName: playerName,
        avatar: avatar,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<GameViewModel, GameState?>
  createElement() {
    return _GameViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GameViewModelProvider &&
        other.roomId == roomId &&
        other.playerName == playerName &&
        other.avatar == avatar;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roomId.hashCode);
    hash = _SystemHash.combine(hash, playerName.hashCode);
    hash = _SystemHash.combine(hash, avatar.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GameViewModelRef on AutoDisposeNotifierProviderRef<GameState?> {
  /// The parameter `roomId` of this provider.
  String get roomId;

  /// The parameter `playerName` of this provider.
  String get playerName;

  /// The parameter `avatar` of this provider.
  String get avatar;
}

class _GameViewModelProviderElement
    extends AutoDisposeNotifierProviderElement<GameViewModel, GameState?>
    with GameViewModelRef {
  _GameViewModelProviderElement(super.provider);

  @override
  String get roomId => (origin as GameViewModelProvider).roomId;
  @override
  String get playerName => (origin as GameViewModelProvider).playerName;
  @override
  String get avatar => (origin as GameViewModelProvider).avatar;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
