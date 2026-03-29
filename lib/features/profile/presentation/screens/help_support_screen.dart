import 'package:flutter/material.dart';
import 'package:style_cart/app/theme/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Help & Support',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3D1010), AppColors.backgroundDark],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
          children: const [
            _HelpHeroCard(),
            SizedBox(height: 18),
            _SupportChannelTile(
              icon: Icons.mail_outline_rounded,
              title: 'Email Support',
              subtitle: 'support@luxr.app',
              detail: 'Best for account help, order questions, and app issues.',
            ),
            SizedBox(height: 12),
            _SupportChannelTile(
              icon: Icons.local_shipping_outlined,
              title: 'Order Assistance',
              subtitle: 'Track, return, or update an order',
              detail:
                  'Open My Orders from your profile anytime to review deliveries and statuses.',
            ),
            SizedBox(height: 12),
            _SupportChannelTile(
              icon: Icons.shield_outlined,
              title: 'Account Safety',
              subtitle: 'Keep your account protected',
              detail:
                  'Use a strong password, verify your email, and review your saved details regularly.',
            ),
            SizedBox(height: 18),
            _FaqCard(
              question: 'How do I update my profile image?',
              answer:
                  'Tap the camera icon on your profile photo, choose a picture from your gallery, and we will update it for you.',
            ),
            SizedBox(height: 12),
            _FaqCard(
              question: 'Can I save more than one address?',
              answer:
                  'Yes. Add as many saved addresses as you need, then choose one as your default delivery address.',
            ),
            SizedBox(height: 12),
            _FaqCard(
              question: 'What payment methods can I save?',
              answer:
                  'Right now you can save Google Play, PayPal, and MasterCard information for quick access.',
            ),
            SizedBox(height: 12),
            _FaqCard(
              question: 'Why do you only store the last 4 digits of my card?',
              answer:
                  'It keeps the experience lightweight and much safer. Full sensitive card details are intentionally not stored in the app profile.',
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpHeroCard extends StatelessWidget {
  const _HelpHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A181B), Color(0xFF231012)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white12,
            child: Icon(Icons.headset_mic_outlined, color: Colors.white),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We are here when you need us',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Find quick answers, support contacts, and helpful tips to keep your shopping smooth.',
                  style: TextStyle(color: Colors.white70, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportChannelTile extends StatelessWidget {
  const _SupportChannelTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.gold),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  detail,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  const _FaqCard({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: ExpansionTile(
        collapsedIconColor: Colors.white70,
        iconColor: AppColors.gold,
        title: Text(
          question,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(
            answer,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}
