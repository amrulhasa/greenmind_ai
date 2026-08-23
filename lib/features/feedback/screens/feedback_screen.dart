import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/feedback_service.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({
    super.key,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  // ============================================================
  // CONSTANTS
  // ============================================================

  static const Color _backgroundColor = Color(0xFFF5F9F5);
  static const Color _primaryColor = Color(0xFF2E7D32);
  static const Color _darkTextColor = Color(0xFF172018);
  static const Color _secondaryTextColor = Color(0xFF68736B);
  static const Color _borderColor = Color(0xFFE0E7E1);
  static const Color _headerColor = Color(0xFFE8F5E9);
  static const Color _starColor = Color(0xFFFFB300);

  // ============================================================
  // CONTROLLER
  // ============================================================

  final TextEditingController _feedbackController =
      TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  int _rating = 0;
  bool _submitting = false;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  // ============================================================
  // SUBMIT FEEDBACK
  // ============================================================

  Future<void> _submitFeedback() async {
    if (_submitting) {
      return;
    }

    final String message = _feedbackController.text.trim();

    // ----------------------------------------------------------
    // VALIDATION
    // ----------------------------------------------------------

    if (_rating < 1 || _rating > 5) {
      _showMessage(
        'Please select a rating between 1 and 5.',
      );
      return;
    }

    if (message.isEmpty) {
      _showMessage(
        'Please write your feedback.',
      );
      return;
    }

    if (message.length < 5) {
      _showMessage(
        'Feedback must contain at least 5 characters.',
      );
      return;
    }

    // ----------------------------------------------------------
    // START SUBMITTING
    // ----------------------------------------------------------

    setState(() {
      _submitting = true;
    });

    try {
      await FeedbackService.submitFeedback(
        rating: _rating,
        message: message,
      );

      if (!mounted) {
        return;
      }

      // --------------------------------------------------------
      // RESET FORM
      // --------------------------------------------------------

      _feedbackController.clear();

      setState(() {
        _rating = 0;
        _submitting = false;
      });

      // --------------------------------------------------------
      // SUCCESS MESSAGE
      // --------------------------------------------------------

      _showMessage(
        'Thank you! Your feedback has been submitted successfully.',
        backgroundColor: _primaryColor,
      );

      // --------------------------------------------------------
      // GO BACK
      // --------------------------------------------------------

      await Future<void>.delayed(
        const Duration(milliseconds: 800),
      );

      if (!mounted) {
        return;
      }

      if (context.canPop()) {
        context.pop();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _submitting = false;
      });

      _showMessage(
        _cleanErrorMessage(error),
      );
    }
  }

  // ============================================================
  // CLEAN ERROR MESSAGE
  // ============================================================

  String _cleanErrorMessage(Object error) {
    final String errorText = error.toString().toLowerCase();

    if (errorText.contains('logged in') ||
        errorText.contains('unauthenticated')) {
      return 'Please login again and try submitting feedback.';
    }

    if (errorText.contains('permission-denied') ||
        errorText.contains('permission denied')) {
      return 'You do not have permission to submit feedback.';
    }

    if (errorText.contains('network') ||
        errorText.contains('unavailable')) {
      return 'Network error. Please check your internet connection.';
    }

    if (errorText.contains('feedback id')) {
      return 'Invalid feedback information.';
    }

    if (errorText.contains('firebase')) {
      return 'Unable to submit feedback right now. Please try again.';
    }

    return 'Unable to submit feedback. Please try again.';
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    Color backgroundColor = const Color(0xFF323232),
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  // ============================================================
  // SELECT RATING
  // ============================================================

  void _selectRating(int rating) {
    if (_submitting) {
      return;
    }

    setState(() {
      _rating = rating;
    });
  }

  // ============================================================
  // RATING LABEL
  // ============================================================

  String _ratingLabel() {
    switch (_rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return '';
    }
  }

  // ============================================================
  // GO BACK
  // ============================================================

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/profile');
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _backgroundColor,
        foregroundColor: _darkTextColor,

        leading: IconButton(
          tooltip: 'Back',
          onPressed: _submitting ? null : _goBack,
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),

        centerTitle: true,

        title: const Text(
          'Feedback',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: _darkTextColor,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,

          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            32,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==================================================
              // HEADER
              // ==================================================

              _buildHeader(),

              const SizedBox(
                height: 24,
              ),

              // ==================================================
              // RATING SECTION
              // ==================================================

              const Text(
                'How would you rate your experience?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _darkTextColor,
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              _buildRatingCard(),

              if (_rating > 0) ...[
                const SizedBox(
                  height: 8,
                ),
                Center(
                  child: Text(
                    _ratingLabel(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _primaryColor,
                    ),
                  ),
                ),
              ],

              const SizedBox(
                height: 24,
              ),

              // ==================================================
              // FEEDBACK TITLE
              // ==================================================

              const Text(
                'Your Feedback',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _darkTextColor,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              // ==================================================
              // FEEDBACK FIELD
              // ==================================================

              _buildFeedbackField(),

              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // SUBMIT BUTTON
              // ==================================================

              _buildSubmitButton(),

              const SizedBox(
                height: 14,
              ),

              // ==================================================
              // DISCLAIMER
              // ==================================================

              const Text(
                'Your feedback will be reviewed by '
                'the GreenMind AI administration team.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.4,
                  color: Color(0xFF7A837C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _headerColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.rate_review_outlined,
              size: 34,
              color: _primaryColor,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          const Text(
            'Help Us Improve GreenMind AI',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _darkTextColor,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          const Text(
            'Tell us about your experience. '
            'Your feedback helps us make '
            'GreenMind AI better.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: _secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RATING CARD
  // ============================================================

  Widget _buildRatingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _borderColor,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          5,
          (index) {
            final int star = index + 1;

            return IconButton(
              tooltip:
                  '$star star${star == 1 ? '' : 's'}',

              onPressed: _submitting
                  ? null
                  : () {
                      _selectRating(star);
                    },

              icon: Icon(
                star <= _rating
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                size: 42,
                color: _starColor,
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // FEEDBACK FIELD
  // ============================================================

  Widget _buildFeedbackField() {
    return TextField(
      controller: _feedbackController,
      enabled: !_submitting,

      minLines: 5,
      maxLines: 7,
      maxLength: 1000,

      textInputAction: TextInputAction.newline,

      textCapitalization:
          TextCapitalization.sentences,

      keyboardType: TextInputType.multiline,

      decoration: InputDecoration(
        hintText: 'Write your feedback here...',

        hintStyle: const TextStyle(
          color: Color(0xFF8A938C),
        ),

        filled: true,

        fillColor: Colors.white,

        alignLabelWithHint: true,

        prefixIcon: const Padding(
          padding: EdgeInsets.only(
            bottom: 90,
          ),
          child: Icon(
            Icons.edit_note_rounded,
            color: _primaryColor,
          ),
        ),

        contentPadding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: _borderColor,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: _borderColor,
          ),
        ),

        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: _borderColor,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: _primaryColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUBMIT BUTTON
  // ============================================================

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _submitting
            ? null
            : _submitFeedback,

        icon: _submitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Icon(
                Icons.send_rounded,
              ),

        label: Text(
          _submitting
              ? 'Submitting...'
              : 'Submit Feedback',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),

        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,

          disabledBackgroundColor:
              const Color(0xFF81A784),

          disabledForegroundColor:
              Colors.white,

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}