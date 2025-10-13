// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failures.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Failure {
  String get message => throw _privateConstructorUsedError;
  String? get errorCode => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String message, int? statusCode, String? errorCode)
        network,
    required TResult Function(
            String message, int? statusCode, String? errorCode)
        server,
    required TResult Function(String message, String? errorCode) cache,
    required TResult Function(String message, String? errorCode) storage,
    required TResult Function(String message, String? field, String? errorCode)
        validation,
    required TResult Function(String message, String? errorCode) permission,
    required TResult Function(String message, String? errorCode) unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode, String? errorCode)?
        network,
    TResult? Function(String message, int? statusCode, String? errorCode)?
        server,
    TResult? Function(String message, String? errorCode)? cache,
    TResult? Function(String message, String? errorCode)? storage,
    TResult? Function(String message, String? field, String? errorCode)?
        validation,
    TResult? Function(String message, String? errorCode)? permission,
    TResult? Function(String message, String? errorCode)? unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode, String? errorCode)?
        network,
    TResult Function(String message, int? statusCode, String? errorCode)?
        server,
    TResult Function(String message, String? errorCode)? cache,
    TResult Function(String message, String? errorCode)? storage,
    TResult Function(String message, String? field, String? errorCode)?
        validation,
    TResult Function(String message, String? errorCode)? permission,
    TResult Function(String message, String? errorCode)? unknown,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(StorageFailure value) storage,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(UnknownFailure value) unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(StorageFailure value)? storage,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(UnknownFailure value)? unknown,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(CacheFailure value)? cache,
    TResult Function(StorageFailure value)? storage,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $FailureCopyWith<Failure> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FailureCopyWith<$Res> {
  factory $FailureCopyWith(Failure value, $Res Function(Failure) then) =
      _$FailureCopyWithImpl<$Res, Failure>;
  @useResult
  $Res call({String message, String? errorCode});
}

/// @nodoc
class _$FailureCopyWithImpl<$Res, $Val extends Failure>
    implements $FailureCopyWith<$Res> {
  _$FailureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? errorCode = freezed,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      errorCode: freezed == errorCode
          ? _value.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NetworkFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$NetworkFailureImplCopyWith(_$NetworkFailureImpl value,
          $Res Function(_$NetworkFailureImpl) then) =
      __$$NetworkFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, int? statusCode, String? errorCode});
}

/// @nodoc
class __$$NetworkFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$NetworkFailureImpl>
    implements _$$NetworkFailureImplCopyWith<$Res> {
  __$$NetworkFailureImplCopyWithImpl(
      _$NetworkFailureImpl _value, $Res Function(_$NetworkFailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? statusCode = freezed,
    Object? errorCode = freezed,
  }) {
    return _then(_$NetworkFailureImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      statusCode: freezed == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int?,
      errorCode: freezed == errorCode
          ? _value.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$NetworkFailureImpl implements NetworkFailure {
  const _$NetworkFailureImpl(
      {required this.message, this.statusCode, this.errorCode});

  @override
  final String message;
  @override
  final int? statusCode;
  @override
  final String? errorCode;

  @override
  String toString() {
    return 'Failure.network(message: $message, statusCode: $statusCode, errorCode: $errorCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, statusCode, errorCode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkFailureImplCopyWith<_$NetworkFailureImpl> get copyWith =>
      __$$NetworkFailureImplCopyWithImpl<_$NetworkFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String message, int? statusCode, String? errorCode)
        network,
    required TResult Function(
            String message, int? statusCode, String? errorCode)
        server,
    required TResult Function(String message, String? errorCode) cache,
    required TResult Function(String message, String? errorCode) storage,
    required TResult Function(String message, String? field, String? errorCode)
        validation,
    required TResult Function(String message, String? errorCode) permission,
    required TResult Function(String message, String? errorCode) unknown,
  }) {
    return network(message, statusCode, errorCode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode, String? errorCode)?
        network,
    TResult? Function(String message, int? statusCode, String? errorCode)?
        server,
    TResult? Function(String message, String? errorCode)? cache,
    TResult? Function(String message, String? errorCode)? storage,
    TResult? Function(String message, String? field, String? errorCode)?
        validation,
    TResult? Function(String message, String? errorCode)? permission,
    TResult? Function(String message, String? errorCode)? unknown,
  }) {
    return network?.call(message, statusCode, errorCode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode, String? errorCode)?
        network,
    TResult Function(String message, int? statusCode, String? errorCode)?
        server,
    TResult Function(String message, String? errorCode)? cache,
    TResult Function(String message, String? errorCode)? storage,
    TResult Function(String message, String? field, String? errorCode)?
        validation,
    TResult Function(String message, String? errorCode)? permission,
    TResult Function(String message, String? errorCode)? unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(message, statusCode, errorCode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(StorageFailure value) storage,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return network(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(StorageFailure value)? storage,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return network?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(CacheFailure value)? cache,
    TResult Function(StorageFailure value)? storage,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(this);
    }
    return orElse();
  }
}

abstract class NetworkFailure implements Failure {
  const factory NetworkFailure(
      {required final String message,
      final int? statusCode,
      final String? errorCode}) = _$NetworkFailureImpl;

  @override
  String get message;
  int? get statusCode;
  @override
  String? get errorCode;
  @override
  @JsonKey(ignore: true)
  _$$NetworkFailureImplCopyWith<_$NetworkFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ServerFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$ServerFailureImplCopyWith(
          _$ServerFailureImpl value, $Res Function(_$ServerFailureImpl) then) =
      __$$ServerFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, int? statusCode, String? errorCode});
}

/// @nodoc
class __$$ServerFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$ServerFailureImpl>
    implements _$$ServerFailureImplCopyWith<$Res> {
  __$$ServerFailureImplCopyWithImpl(
      _$ServerFailureImpl _value, $Res Function(_$ServerFailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? statusCode = freezed,
    Object? errorCode = freezed,
  }) {
    return _then(_$ServerFailureImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      statusCode: freezed == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int?,
      errorCode: freezed == errorCode
          ? _value.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ServerFailureImpl implements ServerFailure {
  const _$ServerFailureImpl(
      {required this.message, this.statusCode, this.errorCode});

  @override
  final String message;
  @override
  final int? statusCode;
  @override
  final String? errorCode;

  @override
  String toString() {
    return 'Failure.server(message: $message, statusCode: $statusCode, errorCode: $errorCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, statusCode, errorCode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerFailureImplCopyWith<_$ServerFailureImpl> get copyWith =>
      __$$ServerFailureImplCopyWithImpl<_$ServerFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String message, int? statusCode, String? errorCode)
        network,
    required TResult Function(
            String message, int? statusCode, String? errorCode)
        server,
    required TResult Function(String message, String? errorCode) cache,
    required TResult Function(String message, String? errorCode) storage,
    required TResult Function(String message, String? field, String? errorCode)
        validation,
    required TResult Function(String message, String? errorCode) permission,
    required TResult Function(String message, String? errorCode) unknown,
  }) {
    return server(message, statusCode, errorCode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode, String? errorCode)?
        network,
    TResult? Function(String message, int? statusCode, String? errorCode)?
        server,
    TResult? Function(String message, String? errorCode)? cache,
    TResult? Function(String message, String? errorCode)? storage,
    TResult? Function(String message, String? field, String? errorCode)?
        validation,
    TResult? Function(String message, String? errorCode)? permission,
    TResult? Function(String message, String? errorCode)? unknown,
  }) {
    return server?.call(message, statusCode, errorCode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode, String? errorCode)?
        network,
    TResult Function(String message, int? statusCode, String? errorCode)?
        server,
    TResult Function(String message, String? errorCode)? cache,
    TResult Function(String message, String? errorCode)? storage,
    TResult Function(String message, String? field, String? errorCode)?
        validation,
    TResult Function(String message, String? errorCode)? permission,
    TResult Function(String message, String? errorCode)? unknown,
    required TResult orElse(),
  }) {
    if (server != null) {
      return server(message, statusCode, errorCode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(StorageFailure value) storage,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return server(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(StorageFailure value)? storage,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return server?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(CacheFailure value)? cache,
    TResult Function(StorageFailure value)? storage,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (server != null) {
      return server(this);
    }
    return orElse();
  }
}

abstract class ServerFailure implements Failure {
  const factory ServerFailure(
      {required final String message,
      final int? statusCode,
      final String? errorCode}) = _$ServerFailureImpl;

  @override
  String get message;
  int? get statusCode;
  @override
  String? get errorCode;
  @override
  @JsonKey(ignore: true)
  _$$ServerFailureImplCopyWith<_$ServerFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CacheFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$CacheFailureImplCopyWith(
          _$CacheFailureImpl value, $Res Function(_$CacheFailureImpl) then) =
      __$$CacheFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? errorCode});
}

/// @nodoc
class __$$CacheFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$CacheFailureImpl>
    implements _$$CacheFailureImplCopyWith<$Res> {
  __$$CacheFailureImplCopyWithImpl(
      _$CacheFailureImpl _value, $Res Function(_$CacheFailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? errorCode = freezed,
  }) {
    return _then(_$CacheFailureImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      errorCode: freezed == errorCode
          ? _value.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CacheFailureImpl implements CacheFailure {
  const _$CacheFailureImpl({required this.message, this.errorCode});

  @override
  final String message;
  @override
  final String? errorCode;

  @override
  String toString() {
    return 'Failure.cache(message: $message, errorCode: $errorCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CacheFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, errorCode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CacheFailureImplCopyWith<_$CacheFailureImpl> get copyWith =>
      __$$CacheFailureImplCopyWithImpl<_$CacheFailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String message, int? statusCode, String? errorCode)
        network,
    required TResult Function(
            String message, int? statusCode, String? errorCode)
        server,
    required TResult Function(String message, String? errorCode) cache,
    required TResult Function(String message, String? errorCode) storage,
    required TResult Function(String message, String? field, String? errorCode)
        validation,
    required TResult Function(String message, String? errorCode) permission,
    required TResult Function(String message, String? errorCode) unknown,
  }) {
    return cache(message, errorCode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode, String? errorCode)?
        network,
    TResult? Function(String message, int? statusCode, String? errorCode)?
        server,
    TResult? Function(String message, String? errorCode)? cache,
    TResult? Function(String message, String? errorCode)? storage,
    TResult? Function(String message, String? field, String? errorCode)?
        validation,
    TResult? Function(String message, String? errorCode)? permission,
    TResult? Function(String message, String? errorCode)? unknown,
  }) {
    return cache?.call(message, errorCode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode, String? errorCode)?
        network,
    TResult Function(String message, int? statusCode, String? errorCode)?
        server,
    TResult Function(String message, String? errorCode)? cache,
    TResult Function(String message, String? errorCode)? storage,
    TResult Function(String message, String? field, String? errorCode)?
        validation,
    TResult Function(String message, String? errorCode)? permission,
    TResult Function(String message, String? errorCode)? unknown,
    required TResult orElse(),
  }) {
    if (cache != null) {
      return cache(message, errorCode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(StorageFailure value) storage,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return cache(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(StorageFailure value)? storage,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return cache?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(CacheFailure value)? cache,
    TResult Function(StorageFailure value)? storage,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (cache != null) {
      return cache(this);
    }
    return orElse();
  }
}

abstract class CacheFailure implements Failure {
  const factory CacheFailure(
      {required final String message,
      final String? errorCode}) = _$CacheFailureImpl;

  @override
  String get message;
  @override
  String? get errorCode;
  @override
  @JsonKey(ignore: true)
  _$$CacheFailureImplCopyWith<_$CacheFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$StorageFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$StorageFailureImplCopyWith(_$StorageFailureImpl value,
          $Res Function(_$StorageFailureImpl) then) =
      __$$StorageFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? errorCode});
}

/// @nodoc
class __$$StorageFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$StorageFailureImpl>
    implements _$$StorageFailureImplCopyWith<$Res> {
  __$$StorageFailureImplCopyWithImpl(
      _$StorageFailureImpl _value, $Res Function(_$StorageFailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? errorCode = freezed,
  }) {
    return _then(_$StorageFailureImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      errorCode: freezed == errorCode
          ? _value.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$StorageFailureImpl implements StorageFailure {
  const _$StorageFailureImpl({required this.message, this.errorCode});

  @override
  final String message;
  @override
  final String? errorCode;

  @override
  String toString() {
    return 'Failure.storage(message: $message, errorCode: $errorCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StorageFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, errorCode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StorageFailureImplCopyWith<_$StorageFailureImpl> get copyWith =>
      __$$StorageFailureImplCopyWithImpl<_$StorageFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String message, int? statusCode, String? errorCode)
        network,
    required TResult Function(
            String message, int? statusCode, String? errorCode)
        server,
    required TResult Function(String message, String? errorCode) cache,
    required TResult Function(String message, String? errorCode) storage,
    required TResult Function(String message, String? field, String? errorCode)
        validation,
    required TResult Function(String message, String? errorCode) permission,
    required TResult Function(String message, String? errorCode) unknown,
  }) {
    return storage(message, errorCode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode, String? errorCode)?
        network,
    TResult? Function(String message, int? statusCode, String? errorCode)?
        server,
    TResult? Function(String message, String? errorCode)? cache,
    TResult? Function(String message, String? errorCode)? storage,
    TResult? Function(String message, String? field, String? errorCode)?
        validation,
    TResult? Function(String message, String? errorCode)? permission,
    TResult? Function(String message, String? errorCode)? unknown,
  }) {
    return storage?.call(message, errorCode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode, String? errorCode)?
        network,
    TResult Function(String message, int? statusCode, String? errorCode)?
        server,
    TResult Function(String message, String? errorCode)? cache,
    TResult Function(String message, String? errorCode)? storage,
    TResult Function(String message, String? field, String? errorCode)?
        validation,
    TResult Function(String message, String? errorCode)? permission,
    TResult Function(String message, String? errorCode)? unknown,
    required TResult orElse(),
  }) {
    if (storage != null) {
      return storage(message, errorCode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(StorageFailure value) storage,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return storage(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(StorageFailure value)? storage,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return storage?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(CacheFailure value)? cache,
    TResult Function(StorageFailure value)? storage,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (storage != null) {
      return storage(this);
    }
    return orElse();
  }
}

abstract class StorageFailure implements Failure {
  const factory StorageFailure(
      {required final String message,
      final String? errorCode}) = _$StorageFailureImpl;

  @override
  String get message;
  @override
  String? get errorCode;
  @override
  @JsonKey(ignore: true)
  _$$StorageFailureImplCopyWith<_$StorageFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ValidationFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$ValidationFailureImplCopyWith(_$ValidationFailureImpl value,
          $Res Function(_$ValidationFailureImpl) then) =
      __$$ValidationFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? field, String? errorCode});
}

/// @nodoc
class __$$ValidationFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$ValidationFailureImpl>
    implements _$$ValidationFailureImplCopyWith<$Res> {
  __$$ValidationFailureImplCopyWithImpl(_$ValidationFailureImpl _value,
      $Res Function(_$ValidationFailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? field = freezed,
    Object? errorCode = freezed,
  }) {
    return _then(_$ValidationFailureImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      field: freezed == field
          ? _value.field
          : field // ignore: cast_nullable_to_non_nullable
              as String?,
      errorCode: freezed == errorCode
          ? _value.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ValidationFailureImpl implements ValidationFailure {
  const _$ValidationFailureImpl(
      {required this.message, this.field, this.errorCode});

  @override
  final String message;
  @override
  final String? field;
  @override
  final String? errorCode;

  @override
  String toString() {
    return 'Failure.validation(message: $message, field: $field, errorCode: $errorCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.field, field) || other.field == field) &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, field, errorCode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationFailureImplCopyWith<_$ValidationFailureImpl> get copyWith =>
      __$$ValidationFailureImplCopyWithImpl<_$ValidationFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String message, int? statusCode, String? errorCode)
        network,
    required TResult Function(
            String message, int? statusCode, String? errorCode)
        server,
    required TResult Function(String message, String? errorCode) cache,
    required TResult Function(String message, String? errorCode) storage,
    required TResult Function(String message, String? field, String? errorCode)
        validation,
    required TResult Function(String message, String? errorCode) permission,
    required TResult Function(String message, String? errorCode) unknown,
  }) {
    return validation(message, field, errorCode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode, String? errorCode)?
        network,
    TResult? Function(String message, int? statusCode, String? errorCode)?
        server,
    TResult? Function(String message, String? errorCode)? cache,
    TResult? Function(String message, String? errorCode)? storage,
    TResult? Function(String message, String? field, String? errorCode)?
        validation,
    TResult? Function(String message, String? errorCode)? permission,
    TResult? Function(String message, String? errorCode)? unknown,
  }) {
    return validation?.call(message, field, errorCode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode, String? errorCode)?
        network,
    TResult Function(String message, int? statusCode, String? errorCode)?
        server,
    TResult Function(String message, String? errorCode)? cache,
    TResult Function(String message, String? errorCode)? storage,
    TResult Function(String message, String? field, String? errorCode)?
        validation,
    TResult Function(String message, String? errorCode)? permission,
    TResult Function(String message, String? errorCode)? unknown,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(message, field, errorCode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(StorageFailure value) storage,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return validation(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(StorageFailure value)? storage,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return validation?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(CacheFailure value)? cache,
    TResult Function(StorageFailure value)? storage,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(this);
    }
    return orElse();
  }
}

abstract class ValidationFailure implements Failure {
  const factory ValidationFailure(
      {required final String message,
      final String? field,
      final String? errorCode}) = _$ValidationFailureImpl;

  @override
  String get message;
  String? get field;
  @override
  String? get errorCode;
  @override
  @JsonKey(ignore: true)
  _$$ValidationFailureImplCopyWith<_$ValidationFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PermissionFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$PermissionFailureImplCopyWith(_$PermissionFailureImpl value,
          $Res Function(_$PermissionFailureImpl) then) =
      __$$PermissionFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? errorCode});
}

/// @nodoc
class __$$PermissionFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$PermissionFailureImpl>
    implements _$$PermissionFailureImplCopyWith<$Res> {
  __$$PermissionFailureImplCopyWithImpl(_$PermissionFailureImpl _value,
      $Res Function(_$PermissionFailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? errorCode = freezed,
  }) {
    return _then(_$PermissionFailureImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      errorCode: freezed == errorCode
          ? _value.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$PermissionFailureImpl implements PermissionFailure {
  const _$PermissionFailureImpl({required this.message, this.errorCode});

  @override
  final String message;
  @override
  final String? errorCode;

  @override
  String toString() {
    return 'Failure.permission(message: $message, errorCode: $errorCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PermissionFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, errorCode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PermissionFailureImplCopyWith<_$PermissionFailureImpl> get copyWith =>
      __$$PermissionFailureImplCopyWithImpl<_$PermissionFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String message, int? statusCode, String? errorCode)
        network,
    required TResult Function(
            String message, int? statusCode, String? errorCode)
        server,
    required TResult Function(String message, String? errorCode) cache,
    required TResult Function(String message, String? errorCode) storage,
    required TResult Function(String message, String? field, String? errorCode)
        validation,
    required TResult Function(String message, String? errorCode) permission,
    required TResult Function(String message, String? errorCode) unknown,
  }) {
    return permission(message, errorCode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode, String? errorCode)?
        network,
    TResult? Function(String message, int? statusCode, String? errorCode)?
        server,
    TResult? Function(String message, String? errorCode)? cache,
    TResult? Function(String message, String? errorCode)? storage,
    TResult? Function(String message, String? field, String? errorCode)?
        validation,
    TResult? Function(String message, String? errorCode)? permission,
    TResult? Function(String message, String? errorCode)? unknown,
  }) {
    return permission?.call(message, errorCode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode, String? errorCode)?
        network,
    TResult Function(String message, int? statusCode, String? errorCode)?
        server,
    TResult Function(String message, String? errorCode)? cache,
    TResult Function(String message, String? errorCode)? storage,
    TResult Function(String message, String? field, String? errorCode)?
        validation,
    TResult Function(String message, String? errorCode)? permission,
    TResult Function(String message, String? errorCode)? unknown,
    required TResult orElse(),
  }) {
    if (permission != null) {
      return permission(message, errorCode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(StorageFailure value) storage,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return permission(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(StorageFailure value)? storage,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return permission?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(CacheFailure value)? cache,
    TResult Function(StorageFailure value)? storage,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (permission != null) {
      return permission(this);
    }
    return orElse();
  }
}

abstract class PermissionFailure implements Failure {
  const factory PermissionFailure(
      {required final String message,
      final String? errorCode}) = _$PermissionFailureImpl;

  @override
  String get message;
  @override
  String? get errorCode;
  @override
  @JsonKey(ignore: true)
  _$$PermissionFailureImplCopyWith<_$PermissionFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnknownFailureImplCopyWith<$Res>
    implements $FailureCopyWith<$Res> {
  factory _$$UnknownFailureImplCopyWith(_$UnknownFailureImpl value,
          $Res Function(_$UnknownFailureImpl) then) =
      __$$UnknownFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? errorCode});
}

/// @nodoc
class __$$UnknownFailureImplCopyWithImpl<$Res>
    extends _$FailureCopyWithImpl<$Res, _$UnknownFailureImpl>
    implements _$$UnknownFailureImplCopyWith<$Res> {
  __$$UnknownFailureImplCopyWithImpl(
      _$UnknownFailureImpl _value, $Res Function(_$UnknownFailureImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? errorCode = freezed,
  }) {
    return _then(_$UnknownFailureImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      errorCode: freezed == errorCode
          ? _value.errorCode
          : errorCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$UnknownFailureImpl implements UnknownFailure {
  const _$UnknownFailureImpl({required this.message, this.errorCode});

  @override
  final String message;
  @override
  final String? errorCode;

  @override
  String toString() {
    return 'Failure.unknown(message: $message, errorCode: $errorCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnknownFailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.errorCode, errorCode) ||
                other.errorCode == errorCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, errorCode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UnknownFailureImplCopyWith<_$UnknownFailureImpl> get copyWith =>
      __$$UnknownFailureImplCopyWithImpl<_$UnknownFailureImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String message, int? statusCode, String? errorCode)
        network,
    required TResult Function(
            String message, int? statusCode, String? errorCode)
        server,
    required TResult Function(String message, String? errorCode) cache,
    required TResult Function(String message, String? errorCode) storage,
    required TResult Function(String message, String? field, String? errorCode)
        validation,
    required TResult Function(String message, String? errorCode) permission,
    required TResult Function(String message, String? errorCode) unknown,
  }) {
    return unknown(message, errorCode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message, int? statusCode, String? errorCode)?
        network,
    TResult? Function(String message, int? statusCode, String? errorCode)?
        server,
    TResult? Function(String message, String? errorCode)? cache,
    TResult? Function(String message, String? errorCode)? storage,
    TResult? Function(String message, String? field, String? errorCode)?
        validation,
    TResult? Function(String message, String? errorCode)? permission,
    TResult? Function(String message, String? errorCode)? unknown,
  }) {
    return unknown?.call(message, errorCode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message, int? statusCode, String? errorCode)?
        network,
    TResult Function(String message, int? statusCode, String? errorCode)?
        server,
    TResult Function(String message, String? errorCode)? cache,
    TResult Function(String message, String? errorCode)? storage,
    TResult Function(String message, String? field, String? errorCode)?
        validation,
    TResult Function(String message, String? errorCode)? permission,
    TResult Function(String message, String? errorCode)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(message, errorCode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkFailure value) network,
    required TResult Function(ServerFailure value) server,
    required TResult Function(CacheFailure value) cache,
    required TResult Function(StorageFailure value) storage,
    required TResult Function(ValidationFailure value) validation,
    required TResult Function(PermissionFailure value) permission,
    required TResult Function(UnknownFailure value) unknown,
  }) {
    return unknown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkFailure value)? network,
    TResult? Function(ServerFailure value)? server,
    TResult? Function(CacheFailure value)? cache,
    TResult? Function(StorageFailure value)? storage,
    TResult? Function(ValidationFailure value)? validation,
    TResult? Function(PermissionFailure value)? permission,
    TResult? Function(UnknownFailure value)? unknown,
  }) {
    return unknown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkFailure value)? network,
    TResult Function(ServerFailure value)? server,
    TResult Function(CacheFailure value)? cache,
    TResult Function(StorageFailure value)? storage,
    TResult Function(ValidationFailure value)? validation,
    TResult Function(PermissionFailure value)? permission,
    TResult Function(UnknownFailure value)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(this);
    }
    return orElse();
  }
}

abstract class UnknownFailure implements Failure {
  const factory UnknownFailure(
      {required final String message,
      final String? errorCode}) = _$UnknownFailureImpl;

  @override
  String get message;
  @override
  String? get errorCode;
  @override
  @JsonKey(ignore: true)
  _$$UnknownFailureImplCopyWith<_$UnknownFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
