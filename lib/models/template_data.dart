class GeoTagTemplate {
  final String id;
  final String name;
  final String description;
  final bool isNew;

  const GeoTagTemplate({
    required this.id,
    required this.name,
    required this.description,
    this.isNew = false,
  });

  static const List<GeoTagTemplate> allTemplates = [
    GeoTagTemplate(
      id: 'advance',
      name: 'Advance Template',
      description: 'Full map, address, and coordinates with sensor data.',
    ),
    GeoTagTemplate(
      id: 'datetime',
      name: 'DateTime Template',
      description: 'Large time display with colored date panel.',
    ),
    GeoTagTemplate(
      id: 'scan_location',
      name: 'Scan Location Template',
      description: 'Includes a QR code to quickly scan coordinates.',
      isNew: true,
    ),
    GeoTagTemplate(
      id: 'classic',
      name: 'Classic Template',
      description: 'Clean minimal design with landscape background.',
    ),
    GeoTagTemplate(
      id: 'reporting',
      name: 'Reporting Template',
      description: 'Check-in badge style for professional reporting.',
    ),
    GeoTagTemplate(
      id: 'navigation',
      name: 'Navigation Compass Template',
      description: 'Includes compass rose and bearing azimuth.',
    ),
  ];
}

