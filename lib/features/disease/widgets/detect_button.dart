import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/disease_provider.dart';

class DetectButton extends ConsumerWidget {
  const DetectButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(diseaseProvider);
    final notifier = ref.read(diseaseProvider.notifier);

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: state.image == null || state.isLoading
            ? null
            : () async {
                await notifier.detectDisease();
              },
        icon: state.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.search),
        label: Text(
          state.isLoading
              ? 'Detecting...'
              : 'Detect Disease',
        ),
      ),
    );
  }
}