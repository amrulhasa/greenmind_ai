import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/identify_provider.dart';

class IdentifyButton extends ConsumerWidget {
  const IdentifyButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(identifyProvider);
    final notifier = ref.read(identifyProvider.notifier);

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: state.imageBytes == null || state.isLoading
            ? null
            : () async {
                debugPrint('IDENTIFY BUTTON PRESSED');
                await notifier.identifyPlant();
              },
        icon: state.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.search),
        label: Text(
          state.isLoading ? 'Identifying...' : 'Identify Plant',
        ),
      ),
    );
  }
}