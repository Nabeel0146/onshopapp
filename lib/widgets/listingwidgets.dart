// widgets.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final String iconPath;
  final VoidCallback onTap;

  const ActionButton({
    required this.label,
    required this.color,
    required this.iconPath,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(iconPath, width: 24, height: 24),
              const SizedBox(width: 1),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}

void makeCall(String phoneNumber) async {
  final uri = Uri(scheme: 'tel', path: phoneNumber);
  try {
    if (!await launchUrl(uri)) {
      print('Could not launch $uri');
    }
  } catch (e) {
    print('Error occurred: $e');
  }
}

void openWhatsApp(BuildContext context, String phoneNumber) async {
  // Ensure phone number is in international format
  final formattedPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
  final uri = Uri.parse('https://wa.me/$formattedPhoneNumber');

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open WhatsApp for $phoneNumber')),
    );
  }
}

void shareDetails(
    String title, String description, String phoneNumber) async {
  final footer =
      '\n\nShared from Onshop App\n\nDownload Onshop App now\nGoogle Playstore: https://play.google.com/store/apps/details?id=com.onshopin.onshopapp&pcampaignid=web_share  \nApp Store: https://apps.apple.com/in/app/on-shop/id6740747263  ';
  final shareContent = '''
$title

$description

Contact: $phoneNumber
$footer
''';

  try {
    await Share.share(shareContent, subject: 'Check out this item on Onshop!');
    print('Sharing successful');
  } catch (e) {
    print('Error while sharing: $e');
  }
}

