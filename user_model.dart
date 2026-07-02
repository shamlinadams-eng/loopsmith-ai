enum AuthProvider { google, apple, email }

class UserModel {
  final String uid;
  final String displayName;
  final String? email;
  final String? photoUrl;
  final AuthProvider provider;
  final bool isPremium;
  final int dailyGenerationsUsed;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.displayName,
    this.email,
    this.photoUrl,
    required this.provider,
    required this.isPremium,
    required this.dailyGenerationsUsed,
    required this.createdAt,
  });

  /// Free tier: 10 generations per day.
  static const int freeDailyLimit = 10;

  bool get canGenerate => isPremium || dailyGenerationsUsed < freeDailyLimit;

  int get remainingGenerations =>
      isPremium ? 999 : (freeDailyLimit - dailyGenerationsUsed).clamp(0, freeDailyLimit);

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  String get providerLabel {
    switch (provider) {
      case AuthProvider.google:
        return 'Google';
      case AuthProvider.apple:
        return 'Apple';
      case AuthProvider.email:
        return 'Email';
    }
  }

  UserModel copyWith({
    String? displayName,
    String? email,
    String? photoUrl,
    bool? isPremium,
    int? dailyGenerationsUsed,
  }) =>
      UserModel(
        uid: uid,
        displayName: displayName ?? this.displayName,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
        provider: provider,
        isPremium: isPremium ?? this.isPremium,
        dailyGenerationsUsed: dailyGenerationsUsed ?? this.dailyGenerationsUsed,
        createdAt: createdAt,
      );

  /// Build from a live Firebase [User] + optional Firestore document data.
  factory UserModel.fromFirebase(
    dynamic user, {
    Map<String, dynamic>? firestoreData,
  }) {
    final providerIds =
        (user.providerData as List).map((p) => p.providerId as String).toList();
    final AuthProvider provider;
    if (providerIds.contains('google.com')) {
      provider = AuthProvider.google;
    } else if (providerIds.contains('apple.com')) {
      provider = AuthProvider.apple;
    } else {
      provider = AuthProvider.email;
    }

    return UserModel(
      uid: user.uid as String,
      displayName: (user.displayName as String?) ?? 'Producer',
      email: user.email as String?,
      photoUrl: user.photoURL as String?,
      provider: provider,
      isPremium: firestoreData?['isPremium'] as bool? ?? false,
      dailyGenerationsUsed:
          firestoreData?['dailyGenerationsUsed'] as int? ?? 0,
      createdAt: (user.metadata.creationTime as DateTime?) ?? DateTime.now(),
    );
  }

  /// Serialize to Firestore document.
  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'displayName': displayName,
        'email': email,
        'photoUrl': photoUrl,
        'provider': provider.name,
        'isPremium': isPremium,
        'dailyGenerationsUsed': dailyGenerationsUsed,
        'createdAt': createdAt.toIso8601String(),
      };
}
