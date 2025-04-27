// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/user_settings.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    if (!settingsProvider.isLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationSettings(context, settingsProvider),
          const Divider(height: 32),
          _buildAppearanceSettings(context, settingsProvider),
          const Divider(height: 32),
          _buildEmergencyContacts(context, settingsProvider),
          const Divider(height: 32),
          _buildAboutSection(context),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(
      BuildContext context, SettingsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notifications',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Enable Alert Notifications'),
          subtitle: const Text('Receive notifications for seizure alerts'),
          value: provider.notificationsEnabled,
          onChanged: (value) {
            provider.toggleNotifications(value);
          },
        ),
      ],
    );
  }

  Widget _buildAppearanceSettings(
      BuildContext context, SettingsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Appearance',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Dark Mode'),
          subtitle: const Text('Toggle dark theme'),
          value: provider.darkModeEnabled,
          onChanged: (value) {
            provider.toggleDarkMode(value);
          },
        ),
      ],
    );
  }

  Widget _buildEmergencyContacts(
      BuildContext context, SettingsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Emergency Contacts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _showAddContactDialog(context, provider);
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        provider.emergencyContacts.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('No emergency contacts added'),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.emergencyContacts.length,
                itemBuilder: (context, index) {
                  final contact = provider.emergencyContacts[index];
                  return ListTile(
                    title: Text(contact.name),
                    subtitle: Text(contact.phoneNumber),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: contact.autoCall,
                          onChanged: (value) {
                            final updatedContact = EmergencyContact(
                              name: contact.name,
                              phoneNumber: contact.phoneNumber,
                              autoCall: value ?? false,
                            );
                            provider.updateEmergencyContact(
                                index, updatedContact);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            provider.removeEmergencyContact(index);
                          },
                        ),
                      ],
                    ),
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                  );
                },
              ),
        if (provider.emergencyContacts.isNotEmpty)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Checked contacts will be automatically called during severe seizures',
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Version'),
          subtitle: const Text('1.0.0'),
        ),
        ListTile(
          title: const Text('Device ID'),
          subtitle: const Text('NeuroScope1'),
        ),
      ],
    );
  }

  void _showAddContactDialog(BuildContext context, SettingsProvider provider) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    bool autoCall = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Emergency Contact'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                    ),
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  CheckboxListTile(
                    title: const Text('Auto-call during severe seizures'),
                    value: autoCall,
                    onChanged: (value) {
                      setState(() {
                        autoCall = value ?? false;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        phoneController.text.isNotEmpty) {
                      provider.addEmergencyContact(
                        EmergencyContact(
                          name: nameController.text,
                          phoneNumber: phoneController.text,
                          autoCall: autoCall,
                        ),
                      );
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
