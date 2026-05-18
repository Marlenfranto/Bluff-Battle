import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:networking_game/core/constants/app_constants.dart';
import 'package:networking_game/core/theme/app_colors.dart';
import 'package:networking_game/core/widgets/animated_button.dart';
import 'package:networking_game/core/widgets/animated_gradient_background.dart';
import 'package:networking_game/core/widgets/glassmorphism_card.dart';
import 'package:networking_game/core/widgets/loading_overlay.dart';
import 'package:networking_game/core/extensions/context_extensions.dart';
import 'package:networking_game/models/user_profile.dart';
import 'package:networking_game/providers/auth_provider.dart';
import 'package:networking_game/providers/user_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _linkedInController = TextEditingController();
  final _truth1Controller = TextEditingController();
  final _truth2Controller = TextEditingController();
  final _lieController = TextEditingController();
  bool _isLoading = false;
  bool _hasPopulated = false;

  void _populateFromProfile(UserProfile profile) {
    if (_hasPopulated) return;
    if (profile.name.isEmpty) return;
    _hasPopulated = true;
    _nameController.text = profile.name;
    _phoneController.text = profile.phone ?? '';
    _emailController.text = profile.email ?? '';
    _linkedInController.text = profile.linkedInUrl;
    _truth1Controller.text = profile.truth1;
    _truth2Controller.text = profile.truth2;
    _lieController.text = profile.lie;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) throw Exception('Not authenticated');

      final firestore = ref.read(firestoreServiceProvider);
      final existing = await firestore.getUserProfile(userId);

      final profile = UserProfile(
        id: userId,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        linkedInUrl: _linkedInController.text.trim(),
        truth1: _truth1Controller.text.trim(),
        truth2: _truth2Controller.text.trim(),
        lie: _lieController.text.trim(),
        score: existing?.score ?? 0,
        totalScans: existing?.totalScans ?? 0,
        correctGuesses: existing?.correctGuesses ?? 0,
        wrongGuesses: existing?.wrongGuesses ?? 0,
        connections: existing?.connections ?? [],
        createdAt: existing?.createdAt,
      );

      if (existing != null) {
        await firestore.updateUserProfile(userId, profile.toMap());
      } else {
        await firestore.createUserProfile(profile);
      }

      if (mounted) {
        context.showSuccessSnackBar('Profile saved!');
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Failed to save profile: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _linkedInController.dispose();
    _truth1Controller.dispose();
    _truth2Controller.dispose();
    _lieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final profile = profileAsync.valueOrNull;
    if (profile != null) _populateFromProfile(profile);

    final isSmall = context.isSmallScreen;
    final pad = context.responsivePadding;

    return Scaffold(
      body: AnimatedGradientBackground(
        child: LoadingOverlay(
          isLoading: _isLoading,
          message: 'Saving profile...',
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(pad),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isSmall ? 8 : 16),
                    Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColors.primaryGradient.createShader(bounds),
                          child: Text(
                            'Setup Your Profile',
                            style: TextStyle(
                              fontSize: isSmall ? 22 : 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        'Make your truths and lie tricky!',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: isSmall ? 12 : 14,
                        ),
                      ),
                    ),
                    SizedBox(height: isSmall ? 20 : 32),

                    // Basic Info
                    GlassmorphismCard(
                      padding: EdgeInsets.all(isSmall ? 12 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            icon: Icons.person,
                            title: 'Basic Information',
                            isSmall: isSmall,
                          ),
                          SizedBox(height: isSmall ? 12 : 16),
                          TextFormField(
                            controller: _nameController,
                            style: TextStyle(fontSize: isSmall ? 14 : 16),
                            decoration: InputDecoration(
                              labelText: 'Name *',
                              prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                              hintText: 'Your display name',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: isSmall ? 12 : 16,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().length < AppConstants.minNameLength) {
                                return 'Min ${AppConstants.minNameLength} characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: isSmall ? 8 : 12),
                          TextFormField(
                            controller: _phoneController,
                            style: TextStyle(fontSize: isSmall ? 14 : 16),
                            decoration: InputDecoration(
                              labelText: 'Phone (optional)',
                              prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                              hintText: '+1 234 567 8900',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: isSmall ? 12 : 16,
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                          SizedBox(height: isSmall ? 8 : 12),
                          TextFormField(
                            controller: _emailController,
                            style: TextStyle(fontSize: isSmall ? 14 : 16),
                            decoration: InputDecoration(
                              labelText: 'Email (optional)',
                              prefixIcon: const Icon(Icons.email_outlined, size: 20),
                              hintText: 'you@example.com',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: isSmall ? 12 : 16,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: isSmall ? 8 : 12),
                          TextFormField(
                            controller: _linkedInController,
                            style: TextStyle(fontSize: isSmall ? 14 : 16),
                            decoration: InputDecoration(
                              labelText: 'LinkedIn URL *',
                              prefixIcon: const Icon(Icons.link, size: 20),
                              hintText: 'linkedin.com/in/yourname',
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: isSmall ? 12 : 16,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'LinkedIn URL is required';
                              }
                              if (!AppConstants.isValidLinkedInUrl(v.trim())) {
                                return 'Enter a valid LinkedIn URL';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isSmall ? 16 : 24),

                    // Truths & Lie
                    GlassmorphismCard(
                      padding: EdgeInsets.all(isSmall ? 12 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            icon: Icons.auto_awesome,
                            title: '2 Truths & 1 Lie',
                            isSmall: isSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Write 2 true statements and 1 lie. Make them hard to tell apart!',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: isSmall ? 11 : 13,
                            ),
                          ),
                          SizedBox(height: isSmall ? 12 : 16),
                          _StatementField(
                            controller: _truth1Controller,
                            label: 'Truth #1 *',
                            icon: Icons.check_circle_outline,
                            iconColor: AppColors.accentGreen,
                            hint: 'A true fact about you...',
                            isSmall: isSmall,
                          ),
                          SizedBox(height: isSmall ? 8 : 12),
                          _StatementField(
                            controller: _truth2Controller,
                            label: 'Truth #2 *',
                            icon: Icons.check_circle_outline,
                            iconColor: AppColors.accentGreen,
                            hint: 'Another true fact...',
                            isSmall: isSmall,
                          ),
                          SizedBox(height: isSmall ? 8 : 12),
                          _StatementField(
                            controller: _lieController,
                            label: 'The Lie *',
                            icon: Icons.cancel_outlined,
                            iconColor: AppColors.errorRed,
                            hint: 'A convincing lie...',
                            isSmall: isSmall,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isSmall ? 20 : 32),

                    // Submit
                    Center(
                      child: AnimatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: isSmall ? 14 : 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.rocket_launch, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Save Profile',
                              style: TextStyle(fontSize: isSmall ? 14 : 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isSmall ? 16 : 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSmall;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryPurple, size: isSmall ? 18 : 20),
        SizedBox(width: isSmall ? 6 : 8),
        Flexible(
          child: Text(
            title,
            style: TextStyle(
              fontSize: isSmall ? 15 : 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StatementField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color iconColor;
  final String hint;
  final bool isSmall;

  const _StatementField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.hint,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 2,
      maxLength: AppConstants.maxStatementLength,
      style: TextStyle(fontSize: isSmall ? 13 : 15),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: iconColor, size: 20),
        hintText: hint,
        counterStyle: TextStyle(
          color: AppColors.textSecondary,
          fontSize: isSmall ? 10 : 12,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: isSmall ? 10 : 14,
        ),
      ),
      validator: (v) {
        if (v == null || v.trim().length < AppConstants.minStatementLength) {
          return 'Min ${AppConstants.minStatementLength} characters';
        }
        return null;
      },
    );
  }
}
