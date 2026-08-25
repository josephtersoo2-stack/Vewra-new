from .models import SubscriptionTier, UserSubscription

class SubscriptionService:
    @staticmethod
    def ensure_default_tiers():
        """Seed default tiers (FREE, PREMIUM, PRO) if not present."""
        tiers_data = [
            {
                'name': 'FREE',
                'slug': 'free',
                'description': 'Standard access to daily rewards and verified content exploration.',
                'monthly_price': 0.00,
                'annual_price': 0.00,
                'benefits': [
                    'Standard video reward rate (1x)',
                    'Access to Community & Discussions',
                    'Daily Spin Wheel (1 free spin)',
                    'Standard withdrawal limits',
                ],
            },
            {
                'name': 'PREMIUM',
                'slug': 'premium',
                'description': 'Enhanced earning rate, priority verification and exclusive challenges.',
                'monthly_price': 4.99,
                'annual_price': 49.99,
                'benefits': [
                    '2x Watch reward multiplier',
                    'Priority KYC verification queue',
                    '3 daily spin wheel chances',
                    'Access to Premium Community & Quests',
                    'Reduced marketplace transaction fees (50% off)',
                ],
            },
            {
                'name': 'PRO',
                'slug': 'pro',
                'description': 'Maximum rewards, creator suite, analytics and instant payout processing.',
                'monthly_price': 14.99,
                'annual_price': 149.99,
                'benefits': [
                    '3x Watch reward multiplier',
                    'Instant verification and badge',
                    '5 daily spin wheel chances',
                    'Creator Suite & Campaign launching tools',
                    'VIP support & 0% marketplace redemption fees',
                ],
            },
        ]

        for data in tiers_data:
            SubscriptionTier.objects.get_or_create(
                slug=data['slug'],
                defaults=data
            )

    @staticmethod
    def get_user_subscription(user):
        SubscriptionService.ensure_default_tiers()
        free_tier = SubscriptionTier.objects.filter(slug='free').first()
        sub, _ = UserSubscription.objects.get_or_create(
            user=user,
            defaults={'tier': free_tier, 'is_active': True}
        )
        return sub
