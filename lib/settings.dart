import 'package:flutter/material.dart';
import 'package:gn_account_manager/setpinscreen.dart';
import 'package:gn_account_manager/home.dart';
import 'clientscreen.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedIndex = 2; // Default to "Settings"
  bool isToggled = false;

  void onToggleSwitch(bool value) {
    setState(() {
      isToggled = value;
    });
    if (value) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SetPinScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey.shade800,
        iconTheme:
            const IconThemeData(color: Colors.white), // Set icon color to white
        foregroundColor:
            Colors.white, // Ensures all foreground elements are white
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Card for PIN Settings
          _buildSettingCard(
            context,
            title: "Enter PIN",
            subtitle: "Secure your app with a PIN.",
            leadingIcon: Icons.pin,
            trailingWidget: Switch(
              value: isToggled,
              onChanged: onToggleSwitch,
            ),
          ),
          const SizedBox(height: 16),
          // Other Settings
          _buildSettingCard(
            context,
            title: "Backup Data",
            subtitle: "Save your data securely.",
            leadingIcon: Icons.backup,
            onTap: () {
              // Handle backup action
            },
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            context,
            title: "Restore Data",
            subtitle: "Restore data from a backup.",
            leadingIcon: Icons.restore,
            onTap: () {
              // Handle restore action
            },
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            context,
            title: "Change Currency",
            subtitle: "Set your preferred currency.",
            leadingIcon: Icons.attach_money,
            onTap: () {
              // Handle change currency action
            },
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            context,
            title: "Change Password",
            subtitle: "Update your account password.",
            leadingIcon: Icons.lock,
            onTap: () {
              // Handle change password action
            },
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            context,
            title: "FAQs",
            subtitle: "Get answers to common questions.",
            leadingIcon: Icons.question_answer,
            onTap: () {
              // Handle FAQ action
            },
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            context,
            title: "Privacy Policy",
            subtitle: "Review our privacy policy.",
            leadingIcon: Icons.privacy_tip,
            onTap: () {
              // Handle privacy policy action
            },
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            context,
            title: "ShareApp",
            subtitle: " Share our App.",
            leadingIcon: Icons.privacy_tip,
            onTap: () {
              // Handle privacy policy action
            },
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            context,
            title: "RateApp",
            subtitle: "Rate our App.",
            leadingIcon: Icons.privacy_tip,
            onTap: () {
              // Handle privacy policy action
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData leadingIcon,
    Widget? trailingWidget,
    VoidCallback? onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4,
      child: ListTile(
        leading: Icon(leadingIcon, color: Colors.blueGrey),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: trailingWidget,
        onTap: onTap,
      ),
    );
  }
}
