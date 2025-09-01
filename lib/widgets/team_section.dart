// lib/widgets/team_section.dart
import 'package:flutter/material.dart';

class TeamMember {
  final String name;
  final String position;
  final String imagePath; // Placeholder for image asset path

  TeamMember({
    required this.name,
    required this.position,
    required this.imagePath,
  });
}

class TeamSection extends StatelessWidget {
  const TeamSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<TeamMember> team = [
      TeamMember(name: 'Arjit Tak', position: 'Founder & CEO', imagePath: ''),
      TeamMember(
        name: 'Sarthak Srivastava',
        position: 'Head of Research',
        imagePath: '',
      ),
      TeamMember(
        name: 'Vanshika Bhatnagar',
        position: 'Tech Lead',
        imagePath: '',
      ),
    ];

    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          'Meet Our Team',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'The experts guiding your financial journey.',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 24),
        Container(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: team.length,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemBuilder: (context, index) {
              final member = team[index];
              return Container(
                width: 170,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          size: 35,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member.position,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
