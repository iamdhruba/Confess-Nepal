import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confess_nepal/core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/confession_provider.dart';
import '../../../features/profile/providers/profile_provider.dart';

class CreateConfessionScreen extends StatefulWidget {
  const CreateConfessionScreen({super.key});

  @override
  State<CreateConfessionScreen> createState() => _CreateConfessionScreenState();
}

class _CreateConfessionScreenState extends State<CreateConfessionScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _contentController = TextEditingController();
  String _selectedMood = 'sad';
  String? _selectedLocation;
  bool _isDisappearing = true; // Default to 24h for everyone, safer
  int _charCount = 0;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _contentController.addListener(() {
      setState(() => _charCount = _contentController.text.length);
    });

    // Check auth status to set default mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProfileProvider>();
      if (!p.hasEmail) {
        setState(() => _isDisappearing = true);
      } else {
        setState(() => _isDisappearing = false); // Default to permanent for logged in
      }
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final moodColor = AppColors.moodColor(_selectedMood);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [moodColor.withOpacity(0.1), Colors.transparent],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildIdentityCard(context, profileProvider),
                        const SizedBox(height: 20),
                        Text('How are you feeling?',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                )),
                        const SizedBox(height: 12),
                        _buildMoodSelector(context),
                        const SizedBox(height: 24),
                        Text('Your confession',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                )),
                        const SizedBox(height: 12),
                        _buildTextInput(context, moodColor),
                        const SizedBox(height: 16),
                        _buildLocationSelector(context),
                        const SizedBox(height: 16),
                        _buildOptions(context, profileProvider),
                        const SizedBox(height: 24),
                        _buildSubmitButton(context, profileProvider, moodColor),
                        const SizedBox(height: 20),
                        _buildSafetyNote(context),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.close_rounded,
                  color: AppColors.primary, size: 20),
            ),
          ),
          const Spacer(),
          Text('New Confession',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildIdentityCard(BuildContext context, ProfileProvider profileProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(100)),
            child: const Center(child: Icon(Icons.person_outline_rounded, color: Colors.white, size: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Posting as', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  profileProvider.currentUsername,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => profileProvider.regenerateUsername(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text('New ID',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          )),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildMoodSelector(BuildContext context) {
    final moods = [
      {'key': 'sad', 'label': 'Sad'},
      {'key': 'love', 'label': 'Love'},
      {'key': 'funny', 'label': 'Funny'},
      {'key': 'dark', 'label': 'Dark'},
      {'key': 'confused', 'label': 'Confused'},
    ];

    final presetMoods = moods.map((m) => m['key']!).toList();
    final bool isCustomSelected = !presetMoods.contains(_selectedMood);

    return Row(
      children: [
        ...moods.map((m) {
          final isSelected = _selectedMood == m['key'];
          final color = AppColors.moodColor(m['key']!);

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedMood = m['key']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.15)
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? color.withOpacity(0.4) : Colors.transparent,
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: color.withOpacity(0.15), blurRadius: 12)]
                      : [],
                ),
                child: Center(
                  child: Text(
                    m['label']!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isSelected ? color : AppColors.textTertiary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 10,
                        ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        Expanded(
          child: GestureDetector(
            onTap: () => _showCustomMoodDialog(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isCustomSelected
                    ? AppColors.primary.withOpacity(0.15)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isCustomSelected ? AppColors.primary.withOpacity(0.4) : AppColors.primary.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  isCustomSelected ? _selectedMood : 'Other',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isCustomSelected ? AppColors.primary : AppColors.textTertiary,
                        fontWeight: isCustomSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 10,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  void _showCustomMoodDialog(BuildContext context) {
    final controller = TextEditingController(text: !['sad', 'love', 'funny', 'dark', 'confused'].contains(_selectedMood) ? _selectedMood : '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('How are you feeling?', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'e.g. Lonely, Tired, Grateful...',
            hintStyle: const TextStyle(color: AppColors.textTertiary),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textTertiary)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final text = controller.text.trim();
                final formatted = text[0].toUpperCase() + text.substring(1).toLowerCase();
                setState(() => _selectedMood = formatted);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput(BuildContext context, Color moodColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: TextField(
            controller: _contentController,
            maxLines: 8,
            maxLength: AppConstants.maxConfessionChars,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
            decoration: InputDecoration(
              hintText:
                  'What\'s on your mind? Let it out...\n\nYour identity is completely anonymous.',
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiary,
                    height: 1.6,
                  ),
              filled: true,
              fillColor: Colors.transparent,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(
                  color: moodColor.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              counterText: '',
              contentPadding: const EdgeInsets.all(24),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$_charCount / ${AppConstants.maxConfessionChars}',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: _charCount > 900 ? AppColors.warning : AppColors.textTertiary,
              ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildLocationSelector(BuildContext context) {
    final List<String> displayLocations = [...AppConstants.locations];
    if (_selectedLocation != null && !displayLocations.contains(_selectedLocation)) {
      displayLocations.add(_selectedLocation!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add location tag (optional)',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                )),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: displayLocations.length + 1, // +1 for the "Add" button
            itemBuilder: (context, index) {
              if (index == displayLocations.length) {
                return GestureDetector(
                  onTap: () => _showCustomLocationDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2), style: BorderStyle.solid),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text('Custom', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              }

              final location = displayLocations[index];
              final isSelected = _selectedLocation == location;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() {
                    _selectedLocation = _selectedLocation == location ? null : location;
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.15)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.4)
                            : Colors.transparent,
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[  
                            const Icon(Icons.location_on, size: 11, color: AppColors.primary),
                            const SizedBox(width: 3),
                          ],
                          Text(
                            location,
                            style: TextStyle(
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  void _showCustomLocationDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('New Location', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'e.g. Basantapur, Lalitpur...',
            hintStyle: const TextStyle(color: AppColors.textTertiary),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textTertiary)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => _selectedLocation = controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions(BuildContext context, ProfileProvider p) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isDisappearing = true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isDisappearing
                    ? AppColors.warning.withOpacity(0.1)
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isDisappearing
                      ? AppColors.warning.withOpacity(0.3)
                      : Colors.transparent,
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.timer_outlined,
                      color: _isDisappearing ? AppColors.warning : AppColors.textTertiary,
                      size: 22),
                  const SizedBox(height: 6),
                  Text('24h Story',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: _isDisappearing ? AppColors.warning : AppColors.textTertiary,
                            fontWeight: _isDisappearing ? FontWeight.w600 : FontWeight.w400,
                          )),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: p.hasEmail 
                ? () => setState(() => _isDisappearing = false)
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🔐 Signup to post permanent confessions!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: !p.hasEmail 
                    ? Theme.of(context).disabledColor.withOpacity(0.05)
                    : !_isDisappearing
                        ? AppColors.primary.withOpacity(0.1)
                        : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: !_isDisappearing && p.hasEmail
                      ? AppColors.primary.withOpacity(0.3)
                      : Colors.transparent,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                      p.hasEmail ? Icons.all_inclusive_rounded : Icons.lock_outline_rounded,
                      color: !p.hasEmail 
                          ? AppColors.textTertiary.withOpacity(0.5)
                          : !_isDisappearing ? AppColors.primary : AppColors.textTertiary,
                      size: 22),
                  const SizedBox(height: 6),
                  Text(p.hasEmail ? 'Permanent' : 'LOCKED',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: !p.hasEmail 
                                ? AppColors.textTertiary.withOpacity(0.5)
                                : !_isDisappearing ? AppColors.primary : AppColors.textTertiary,
                            fontWeight: !_isDisappearing && p.hasEmail ? FontWeight.w600 : FontWeight.w400,
                          )),
                ],
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  Widget _buildSubmitButton(
      BuildContext context, ProfileProvider profileProvider, Color moodColor) {
    final isValid = _contentController.text.trim().length >= AppConstants.minConfessionChars;

    return GestureDetector(
      onTap: isValid
          ? () async {
              final confessionProvider = context.read<ConfessionProvider>();
              final karmaDelta = await confessionProvider.addConfession(
                content: _contentController.text.trim(),
                mood: _selectedMood,
                locationTag: _selectedLocation,
                isDisappearing: _isDisappearing,
                profileProvider: profileProvider,
              );
              profileProvider.incrementStreak();
              profileProvider.incrementTotalConfessions();
              profileProvider.addKarma(karmaDelta);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Confession posted anonymously!'),
                  backgroundColor: moodColor.withOpacity(0.9),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                ),
              );
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isValid ? AppColors.primaryGradient : null,
          color: isValid ? null : AppColors.backgroundSecondary,
          borderRadius: BorderRadius.circular(100),
          boxShadow: isValid
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_rounded,
                color: isValid ? Colors.white : AppColors.textTertiary, size: 20),
            const SizedBox(width: 8),
            Text(
              !isValid 
                ? 'Type ${AppConstants.minConfessionChars - _charCount} more chars'
                : (_isDisappearing ? 'Post as 24h Story' : 'Post Anonymously'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isValid ? Colors.white : AppColors.textTertiary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms);
  }

  Widget _buildSafetyNote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined,
              size: 18, color: AppColors.success.withOpacity(0.7)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your identity is 100% anonymous. Be respectful — hate speech and harmful content will be auto-removed.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
