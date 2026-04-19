import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confess_nepal/core/theme/app_colors.dart';
import '../../providers/app_state.dart';
import '../../data/mock_data.dart';

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
  bool _isDisappearing = false;
  bool _isVoice = false;
  int _charCount = 0;
  static const int _maxChars = 1000;

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
  }

  @override
  void dispose() {
    _contentController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final moodColor = AppColors.moodColor(_selectedMood);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Stack(
        children: [
          // Mood-based ambient glow
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
                  colors: [
                    moodColor.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context, state),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Anonymous identity card
                        _buildIdentityCard(context, state),
                        const SizedBox(height: 20),

                        // Mood selector
                        Text(
                          'How are you feeling?',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        _buildMoodSelector(context),
                        const SizedBox(height: 24),

                        // Confession input
                        Text(
                          'Your confession',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        _buildTextInput(context, moodColor),
                        const SizedBox(height: 16),

                        // Location tag
                        _buildLocationSelector(context),
                        const SizedBox(height: 16),

                        // Options
                        _buildOptions(context),
                        const SizedBox(height: 24),

                        // Submit button
                        _buildSubmitButton(context, state, moodColor),
                        const SizedBox(height: 20),

                        // Safety note
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

  Widget _buildHeader(BuildContext context, AppState state) {
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
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'New Confession',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildIdentityCard(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('👤', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Posting as',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  state.currentUsername,
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
            onTap: () => state.regenerateUsername(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'New ID',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
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
      {'key': 'sad', 'emoji': '😢', 'label': 'Sad'},
      {'key': 'love', 'emoji': '💕', 'label': 'Love'},
      {'key': 'funny', 'emoji': '😂', 'label': 'Funny'},
      {'key': 'dark', 'emoji': '🌑', 'label': 'Dark'},
      {'key': 'confused', 'emoji': '🤔', 'label': 'Confused'},
    ];

    return Row(
      children: moods.map((m) {
        final isSelected = _selectedMood == m['key'];
        final color = AppColors.moodColor(m['key']!);

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedMood = m['key']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.15)
                    : AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? color.withOpacity(0.4)
                      : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.15),
                          blurRadius: 12,
                        )
                      ]
                    : [],
              ),
              child: Column(
                children: [
                  Text(
                    m['emoji']!,
                    style: TextStyle(fontSize: isSelected ? 26 : 22),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    m['label']!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isSelected ? color : AppColors.textTertiary,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 10,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildTextInput(BuildContext context, Color moodColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _contentController.text.isNotEmpty
                  ? moodColor.withOpacity(0.2)
                  : Colors.transparent,
            ),
          ),
          child: TextField(
            controller: _contentController,
            maxLines: 8,
            maxLength: _maxChars,
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
              border: InputBorder.none,
              counterText: '',
              contentPadding: const EdgeInsets.all(18),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$_charCount / $_maxChars',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: _charCount > 900
                    ? AppColors.warning
                    : AppColors.textTertiary,
              ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildLocationSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add location tag (optional)',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: MockData.locations.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final location = MockData.locations[index];
              final isSelected = _selectedLocation == location;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedLocation =
                        _selectedLocation == location ? null : location;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.15)
                        : AppColors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.4)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        Icon(Icons.location_on,
                            size: 12, color: AppColors.primary),
                      if (isSelected) const SizedBox(width: 4),
                      Text(
                        location,
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Widget _buildOptions(BuildContext context) {
    return Row(
      children: [
        // Disappearing toggle
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isDisappearing = !_isDisappearing),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isDisappearing
                    ? AppColors.warning.withOpacity(0.1)
                    : AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isDisappearing
                      ? AppColors.warning.withOpacity(0.3)
                      : Colors.transparent,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: _isDisappearing
                        ? AppColors.warning
                        : AppColors.textTertiary,
                    size: 22,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '24h Story',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _isDisappearing
                              ? AppColors.warning
                              : AppColors.textTertiary,
                          fontWeight: _isDisappearing
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Voice confession toggle
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isVoice = !_isVoice),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isVoice
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isVoice
                      ? AppColors.primary.withOpacity(0.3)
                      : Colors.transparent,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.mic_rounded,
                    color:
                        _isVoice ? AppColors.primary : AppColors.textTertiary,
                    size: 22,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Voice',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _isVoice
                              ? AppColors.primary
                              : AppColors.textTertiary,
                          fontWeight:
                              _isVoice ? FontWeight.w600 : FontWeight.w400,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms);
  }

  Widget _buildSubmitButton(
      BuildContext context, AppState state, Color moodColor) {
    final isValid = _contentController.text.trim().length >= 10;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isValid ? AppColors.primaryGradient : null,
        color: isValid ? null : AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isValid
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isValid
              ? () {
                  state.addConfession(
                    content: _contentController.text.trim(),
                    mood: _selectedMood,
                    locationTag: _selectedLocation,
                    isDisappearing: _isDisappearing,
                    isVoice: _isVoice,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Text(AppColors.moodEmoji(_selectedMood)),
                          const SizedBox(width: 8),
                          const Text('Confession posted anonymously!'),
                        ],
                      ),
                      backgroundColor: moodColor.withOpacity(0.9),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.send_rounded,
                  color: isValid ? Colors.white : AppColors.textTertiary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _isDisappearing ? 'Post as 24h Story' : 'Post Anonymously',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isValid ? Colors.white : AppColors.textTertiary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms);
  }

  Widget _buildSafetyNote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
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
