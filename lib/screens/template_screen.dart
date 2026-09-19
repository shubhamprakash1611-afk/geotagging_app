import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/template_data.dart';
import '../providers/app_state_provider.dart';
import '../widgets/templates/template_renderer.dart';

class TemplateScreen extends StatelessWidget {
  const TemplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Template', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, state, _) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: GeoTagTemplate.allTemplates.length,
            separatorBuilder: (_, __) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              final template = GeoTagTemplate.allTemplates[index];
              final isSelected = state.settings.activeTemplateId == template.id;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        template.name.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFE65100), // Orange tint
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (template.isNew) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('New', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      state.updateSettings(state.settings.copyWith(activeTemplateId: template.id));
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF00E676) : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Background mock image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Image.asset(
                              'assets/images/app_logo.png', // Temporary background fallback
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: double.infinity,
                                height: 180,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ),
                          // The Template Widget itself
                          Positioned(
                            bottom: 8,
                            left: 8,
                            right: 8,
                            child: TemplateRenderer(
                              templateId: template.id,
                              loc: state.location,
                              weather: state.weather,
                              sensor: state.sensor,
                              settings: state.settings,
                              userNote: state.userNote,
                            ),
                          ),
                          if (isSelected)
                            const Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Color(0xFF00E676),
                                radius: 14,
                                child: Icon(Icons.check, color: Colors.white, size: 18),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

