import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/data/services/firestore_user_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// A map of user profile data streamed from Firestore.
/// Returns null if the user is not logged in or the document doesn't exist yet.
final firestoreUserProfileProvider =
    StreamProvider<Map<String, dynamic>?>((ref) {
  final authStateAsync = ref.watch(authStateProvider);
  return authStateAsync.maybeWhen(
    data: (user) {
      if (user == null) return const Stream.empty();
      return FirestoreUserService.instance.streamUserProfile(user.uid);
    },
    orElse: () => const Stream.empty(),
  );
});
