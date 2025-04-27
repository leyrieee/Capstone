// screens/resources_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcesScreen extends StatelessWidget {
  final List<ResourceItem> _resources = [
    ResourceItem(
      title: 'Seizure First Aid',
      description: 'Learn what to do if someone is having a seizure',
      icon: Icons.medical_services,
    ),
    ResourceItem(
      title: 'Types of Seizures',
      description: 'Information about different seizure types',
      icon: Icons.category,
    ),
    ResourceItem(
      title: 'Epilepsy Foundation',
      description: 'Resources from the Epilepsy Foundation',
      icon: Icons.public,
      url: 'https://www.epilepsy.com',
    ),
    ResourceItem(
      title: 'Medication Information',
      description: 'Common epilepsy medications and their side effects',
      icon: Icons.medication,
    ),
    ResourceItem(
      title: 'Support Groups',
      description: 'Connect with others who understand',
      icon: Icons.people,
    ),
    ResourceItem(
      title: 'Emergency Services',
      description: 'When to call emergency services',
      icon: Icons.emergency,
    ),
  ];

  ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
      ),
      body: ListView.builder(
        itemCount: _resources.length,
        itemBuilder: (context, index) {
          return _buildResourceCard(_resources[index], context);
        },
      ),
    );
  }

  Widget _buildResourceCard(ResourceItem resource, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          // ignore: deprecated_member_use
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            resource.icon,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          resource.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(resource.description),
        ),
        onTap: () {
          if (resource.url != null) {
            _launchURL(resource.url!);
          } else {
            _showResourceDetails(context, resource);
          }
        },
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  void _showResourceDetails(BuildContext context, ResourceItem resource) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResourceDetailScreen(resource: resource),
      ),
    );
  }
}

class ResourceItem {
  final String title;
  final String description;
  final IconData icon;
  final String? url;

  ResourceItem({
    required this.title,
    required this.description,
    required this.icon,
    this.url,
  });
}

class ResourceDetailScreen extends StatelessWidget {
  final ResourceItem resource;

  const ResourceDetailScreen({required this.resource, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(resource.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              resource.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            _getResourceContent(resource.title),
          ],
        ),
      ),
    );
  }

  Widget _getResourceContent(String title) {
    switch (title) {
      case 'Seizure First Aid':
        return const SeizureFirstAidContent();
      case 'Types of Seizures':
        return const SeizureTypesContent();
      case 'Medication Information':
        return const MedicationContent();
      case 'Support Groups':
        return const SupportGroupsContent();
      case 'Emergency Services':
        return const EmergencyServicesContent();
      default:
        return const Text('Content not available');
    }
  }
}

class SeizureFirstAidContent extends StatelessWidget {
  const SeizureFirstAidContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStep(
            '1. Stay calm', 'Remain with the person and time the seizure.'),
        _buildStep('2. Keep them safe',
            'Move dangerous objects away. Don\'t restrain them.'),
        _buildStep(
            '3. Support their head', 'Place something soft under their head.'),
        _buildStep('4. Position them safely',
            'Turn them onto their side (recovery position) after movements subside.'),
        _buildStep('5. Don\'t put anything in their mouth',
            'It\'s a myth that people can swallow their tongues during a seizure.'),
        _buildStep('6. Stay until they recover',
            'Provide reassurance and stay until they are fully conscious.'),
        _buildStep(
            '7. When to call emergency services',
            '• If the seizure lasts more than 5 minutes\n'
                '• If the person doesn\'t regain consciousness\n'
                '• If the person has multiple seizures\n'
                '• If the person is injured\n'
                '• If it\'s their first seizure'),
      ],
    );
  }

  Widget _buildStep(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class SeizureTypesContent extends StatelessWidget {
  const SeizureTypesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildType('Focal Onset Seizures',
            'Starts in one area of the brain. May involve awareness changes.'),
        _buildType('Generalized Onset Seizures',
            'Affects both sides of the brain from the start.'),
        _buildType('Tonic-Clonic',
            'Involves stiffening followed by jerking movements.'),
        _buildType('Absence', 'Brief staring episodes with loss of awareness.'),
        _buildType('Myoclonic', 'Brief, shock-like jerks of muscles.'),
        _buildType(
            'Atonic', 'Sudden loss of muscle tone, often causing falls.'),
      ],
    );
  }

  Widget _buildType(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class MedicationContent extends StatelessWidget {
  const MedicationContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'This section would include information about common epilepsy medications, their uses, and potential side effects. Always consult with a healthcare provider for personalized medical advice.',
      style: TextStyle(fontSize: 16),
    );
  }
}

class SupportGroupsContent extends StatelessWidget {
  const SupportGroupsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'This section would provide information about local and online support groups for people with epilepsy and their caregivers.',
      style: TextStyle(fontSize: 16),
    );
  }
}

class EmergencyServicesContent extends StatelessWidget {
  const EmergencyServicesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'This section would provide guidance on when to call emergency services during a seizure, as well as what information to provide to emergency responders.',
      style: TextStyle(fontSize: 16),
    );
  }
}
