
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shortly_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:shortly_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:shortly_app/features/profile/presentation/bloc/profile_state.dart';

import '../../../../core/services/cloudinary/cloudinary_service.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
final ProfileRepository profileRepo;

ProfileBloc({required this.profileRepo}) : super(const ProfileInitial()) {
on<ProfileLoadRequested>(_onLoad);
on<ProfileFollowToggled>(_onFollow);
on<ProfileUpdateRequested>(_onUpdate);
on<ProfileAvatarUpdateRequested>(_onUpdateAvatar);
}

Future<void> _onLoad(
ProfileLoadRequested event, Emitter<ProfileState> emit) async {
emit(const ProfileLoading());

final profileResult = await profileRepo.getProfile(event.userId);

if (profileResult.isLeft()) {
profileResult.fold((f) => emit(ProfileError(f.message)), (_) {});
return;
}

final profile = profileResult.getOrElse(() => throw Exception());

emit(ProfileLoaded(profile: profile));
}

Future<void> _onFollow(
ProfileFollowToggled event, Emitter<ProfileState> emit) async {
final current = state;
if (current is! ProfileLoaded) return;

// Optimistic update
final isNowFollowing = !current.profile.isFollowing;

emit(current.copyWith(
profile: current.profile.copyWith(
isFollowing: isNowFollowing,
followerCount: current.profile.followerCount +
(isNowFollowing ? 1 : -1),
),
));

final result = await profileRepo.toggleFollow(event.targetUserId);
result.fold((_) => emit(current), (_) {});
}

Future<void> _onUpdate(
ProfileUpdateRequested event, Emitter<ProfileState> emit) async {
final current = state;
if (current is! ProfileLoaded) return;

final result = await profileRepo.updateProfile(
displayName: event.displayName,
bio: event.bio,
);

result.fold((_) {}, (p) => emit(current.copyWith(profile: p)));
}

Future<void> _onUpdateAvatar(
ProfileAvatarUpdateRequested event,
Emitter<ProfileState> emit,
) async {
final current = state;
if (current is! ProfileLoaded) return;

emit(current.copyWith(isUploadingAvatar: true));

try {
final cloudinary = CloudinaryService();
final avatarUrl = await cloudinary.uploadThumbnail(event.filePath);

final result = await profileRepo.updateProfile(avatarUrl: avatarUrl);

result.fold(
(_) => emit(current.copyWith(isUploadingAvatar: false)),
(updatedProfile) => emit(current.copyWith(
profile: updatedProfile,
isUploadingAvatar: false,
)),
);
} catch (_) {
emit(current.copyWith(isUploadingAvatar: false));
}
}
}
