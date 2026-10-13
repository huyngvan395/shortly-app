import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shortly_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:shortly_app/features/profile/presentation/bloc/profile_state.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/helpers/require_auth.dart';
import '../../../../core/services/supabase/index.dart';
import '../../../../core/utils/storage_image.dart';
import '../../../../di/injector.dart';
import '../bloc/profile_bloc.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc(profileRepo: sl())
        ..add(ProfileLoadRequested(userId)),
      child: _ProfileView(userId: userId),
    );
  }
}

class _ProfileView extends StatefulWidget {
  final String userId;

  const _ProfileView({required this.userId});

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 512,
      maxHeight: 512,
    );

    if (picked == null || !mounted) return;

    context.read<ProfileBloc>().add(
      ProfileAvatarUpdateRequested(picked.path),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (ctx, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is ProfileError) {
            return _ProfileError(
              message: state.message,
              onRetry: () {
                ctx.read<ProfileBloc>().add(
                  ProfileLoadRequested(widget.userId),
                );
              },
            );
          }

          if (state is! ProfileLoaded) {
            return const SizedBox.shrink();
          }

          final profile = state.profile;
          final isMe = profile.isCurrentUser ||
              SupabaseService.currentUserId == profile.id;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                centerTitle: true,
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        '@${profile.username}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: AppSizes.fontXl,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (profile.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified_rounded,
                        color: AppColors.verified,
                        size: 17,
                      ),
                    ],
                  ],
                ),
                actions: [
                  if (isMe)
                    IconButton(
                      tooltip: 'Menu',
                      icon: const Icon(
                        Icons.menu_rounded,
                        color: Colors.black87,
                      ),
                      onPressed: () => _showOwnerMenu(context),
                    )
                  else
                    IconButton(
                      tooltip: 'Thêm',
                      icon: const Icon(
                        Icons.more_horiz_rounded,
                        color: Colors.black87,
                      ),
                      onPressed: () => _showViewerMenu(context),
                    ),
                ],
              ),
              SliverToBoxAdapter(
                child: _ProfileHeader(
                  state: state,
                  isMe: isMe,
                  onEdit: () => _showEditProfile(ctx, state),
                  onFollow: () => ctx.requireAuth(
                        () => ctx.read<ProfileBloc>().add(
                      ProfileFollowToggled(profile.id),
                    ),
                  ),
                  onAvatarTap: _pickAndUploadAvatar,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showOwnerMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Owner menu',
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final slide = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
        );

        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(ctx).pop(),
              child: Container(color: Colors.transparent),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: SlideTransition(
                position: slide,
                child: _OwnerSideMenu(
                  onClose: () => Navigator.of(ctx).pop(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showViewerMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetHandle(),
            _MenuTile(
              icon: Icons.share_outlined,
              title: 'Share profile',
              onTap: () => Navigator.pop(sheetContext),
            ),
            _MenuTile(
              icon: Icons.flag_outlined,
              title: 'Report',
              color: AppColors.error,
              onTap: () => Navigator.pop(sheetContext),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfile(BuildContext context, ProfileLoaded state) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<ProfileBloc>(),
        child: _EditProfileSheet(state: state),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final ProfileLoaded state;
  final bool isMe;
  final VoidCallback onEdit;
  final VoidCallback onFollow;
  final VoidCallback onAvatarTap;

  const _ProfileHeader({
    required this.state,
    required this.isMe,
    required this.onEdit,
    required this.onFollow,
    required this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final profile = state.profile;
    final displayName = profile.displayName?.trim();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.sm,
        AppSizes.lg,
        AppSizes.lg,
      ),
      child: Column(
        children: [
          _ProfileAvatar(
            avatarPath: profile.avatarUrl,
            canAdd: isMe,
            isUploading: state.isUploadingAvatar,
            onTap: isMe ? onAvatarTap : null,
          ),
          const SizedBox(height: AppSizes.md),
          if (displayName != null && displayName.isNotEmpty)
            Text(
              displayName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
          const SizedBox(height: AppSizes.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Stat(count: profile.followingCount, label: 'Đang theo dõi'),
              const _StatDivider(),
              _Stat(count: profile.followerCount, label: 'Người theo dõi'),
              const _StatDivider(),
              _Stat(count: profile.likeReceivedCount, label: 'Lượt thích'),
            ],
          ),
          if (profile.bio?.trim().isNotEmpty == true) ...[
            const SizedBox(height: AppSizes.lg),
            Text(
              profile.bio!.trim(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF555555),
                fontSize: AppSizes.fontMd,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: AppSizes.lg),
          if (isMe)
            Row(
              children: [
                Expanded(
                  child: _ProfileActionButton(
                    label: 'Sửa hồ sơ',
                    icon: Icons.edit_outlined,
                    onPressed: onEdit,
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                _SquareProfileButton(
                  icon: Icons.share_outlined,
                  onPressed: () {},
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _ProfileActionButton(
                    label: profile.isFollowing ? 'Đang theo dõi' : 'Theo dõi',
                    isPrimary: !profile.isFollowing,
                    onPressed: onFollow,
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                _SquareProfileButton(
                  icon: Icons.share_outlined,
                  onPressed: () {},
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? avatarPath;
  final bool canAdd;
  final bool isUploading;
  final VoidCallback? onTap;

  const _ProfileAvatar({
    required this.avatarPath,
    required this.canAdd,
    this.isUploading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarPath != null && avatarPath!.trim().isNotEmpty;
    final imageProvider = hasAvatar
        ? CachedNetworkImageProvider(StorageImage.avatarUrl(avatarPath!))
        : null;

    return GestureDetector(
      onTap: isUploading ? null : onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: const Color(0xFFE8E8E8),
            backgroundImage: imageProvider,
            child: imageProvider == null
                ? const Icon(
              Icons.person,
              size: 48,
              color: Color(0xFFAAAAAA),
            )
                : null,
          ),
          if (isUploading)
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          if (canAdd && !isUploading)
            Positioned(
              right: -1,
              bottom: 2,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 14),
              ),
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final int count;
  final String label;

  const _Stat({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 86,
      child: Column(
        children: [
          Text(
            StorageImage.formatCount(count),
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF777777),
              fontSize: AppSizes.fontSm,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      width: 1,
      color: const Color(0xFFDDDDDD),
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isPrimary;
  final VoidCallback? onPressed;

  const _ProfileActionButton({
    required this.label,
    this.icon,
    this.isPrimary = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final background =
    isPrimary ? AppColors.primary : const Color(0xFFF0F0F0);
    final border =
    isPrimary ? AppColors.primary : const Color(0xFFDDDDDD);
    final foreground = isPrimary ? Colors.white : Colors.black87;

    return SizedBox(
      height: 42,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: background,
          foregroundColor: foreground,
          disabledBackgroundColor: background.withAlpha(120),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: border),
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 17),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SquareProfileButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _SquareProfileButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 42,
      height: 42,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: const Color(0xFFF0F0F0),
          side: const BorderSide(color: Color(0xFFDDDDDD)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;

  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black45),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(bottom: AppSizes.md),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(AppSizes.radiusCircle),
        ),
      ),
    );
  }
}

class _ProfileError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ProfileError({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 44,
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: AppSizes.lg),
            _ProfileActionButton(
              label: 'Thử lại',
              isPrimary: true,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnerSideMenu extends StatelessWidget {
  final VoidCallback onClose;

  const _OwnerSideMenu({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.white,
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(20),
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.82,
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Menu',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.black45,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black12,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFFE0E0E0), height: 1),
              const SizedBox(height: 8),
              _MenuTile(
                icon: Icons.access_time,
                title: 'Trung tâm hoạt động',
                onTap: onClose,
              ),
              _MenuTile(
                icon: Icons.bookmark_border_rounded,
                title: 'Nội dung đã lưu',
                onTap: onClose,
              ),
              _MenuTile(
                icon: Icons.settings_outlined,
                title: 'Cài đặt và quyền riêng tư',
                onTap: onClose,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Divider(color: Color(0xFFE0E0E0), height: 1),
              ),
              _MenuTile(
                icon: Icons.logout_rounded,
                title: 'Đăng xuất',
                color: AppColors.error,
                onTap: () async {
                  onClose();
                  await SupabaseService.auth.signOut();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  final ProfileLoaded state;

  const _EditProfileSheet({required this.state});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController nameCtrl;
  late final TextEditingController bioCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(
      text: widget.state.profile.displayName,
    );
    bioCtrl = TextEditingController(
      text: widget.state.profile.bio,
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSizes.xl,
        right: AppSizes.xl,
        top: AppSizes.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SheetHandle(),
          const Text(
            'Sửa hồ sơ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: AppSizes.xl),
          _ProfileTextField(
            controller: nameCtrl,
            label: 'Tên hiển thị',
            maxLines: 1,
          ),
          const SizedBox(height: AppSizes.md),
          _ProfileTextField(
            controller: bioCtrl,
            label: 'Bio',
            maxLines: 3,
          ),
          const SizedBox(height: AppSizes.xl),
          _ProfileActionButton(
            label: 'Lưu',
            isPrimary: true,
            onPressed: () {
              context.read<ProfileBloc>().add(
                ProfileUpdateRequested(
                  displayName: nameCtrl.text.trim(),
                  bio: bioCtrl.text.trim(),
                ),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
