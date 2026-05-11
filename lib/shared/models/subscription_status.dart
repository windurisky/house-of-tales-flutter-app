enum EntitlementStatus { fullAccess, preview }

enum SubscriptionState {
  trialActive,
  active,
  expired,
  none,
  cancelled,
  unknown,
}

class SubscriptionAccess {
  const SubscriptionAccess({
    required this.state,
    required this.entitlement,
    required this.previewPages,
    this.trialEndsAt,
    this.currentPeriodEnd,
  });

  factory SubscriptionAccess.trialActive({required DateTime trialEndsAt}) {
    return SubscriptionAccess(
      state: SubscriptionState.trialActive,
      entitlement: EntitlementStatus.fullAccess,
      previewPages: 2,
      trialEndsAt: trialEndsAt,
    );
  }

  factory SubscriptionAccess.preview() {
    return const SubscriptionAccess(
      state: SubscriptionState.none,
      entitlement: EntitlementStatus.preview,
      previewPages: 2,
    );
  }

  final SubscriptionState state;
  final EntitlementStatus entitlement;
  final int previewPages;
  final DateTime? trialEndsAt;
  final DateTime? currentPeriodEnd;

  bool get hasFullAccess => entitlement == EntitlementStatus.fullAccess;
  String get plainLabel => switch (state) {
    SubscriptionState.trialActive => 'Trial active',
    SubscriptionState.active => 'Subscription active',
    SubscriptionState.expired => 'Preview mode',
    SubscriptionState.none => 'Preview mode',
    SubscriptionState.cancelled => 'Preview mode',
    SubscriptionState.unknown => 'Checking access',
  };
}
