
import 'package:equatable/equatable.dart';
import 'package:shortly_app/features/profile/domain/entities/profile_entity.dart';

abstract class ProfileState extends Equatable {
const ProfileState();

@override
List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
const ProfileInitial();
}

class ProfileLoading extends ProfileState {
const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
final ProfileEntity profile;
final bool isUploadingAvatar;

const ProfileLoaded({
required this.profile,
this.isUploadingAvatar = false,
});

ProfileLoaded copyWith({
ProfileEntity? profile,
bool? isUploadingAvatar,
}) =>
ProfileLoaded(
profile: profile ?? this.profile,
isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
);

@override
List<Object?> get props => [profile, isUploadingAvatar];
}

class ProfileError extends ProfileState {
final String message;

const ProfileError(this.message);

@override
List<Object?> get props => [message];
}