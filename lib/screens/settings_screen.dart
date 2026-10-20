import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final settings = state.settings;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader(context, 'Erscheinungsbild'),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                RadioListTile<bool?>(
                  title: const Text('Systemstandard'),
                  subtitle: const Text('Passt sich automatisch an dein Android-Theme an'),
                  value: null,
                  groupValue: settings.isDarkMode,
                  onChanged: (val) {
                    state.updateSettings(settings.copyWith(clearDarkMode: true));
                  },
                ),
                RadioListTile<bool?>(
                  title: const Text('Dunkelmodus (Dark Mode)'),
                  value: true,
                  groupValue: settings.isDarkMode,
                  onChanged: (val) {
                    state.updateSettings(settings.copyWith(isDarkMode: true));
                  },
                ),
                RadioListTile<bool?>(
                  title: const Text('Hellmodus (Light Mode)'),
                  value: false,
                  groupValue: settings.isDarkMode,
                  onChanged: (val) {
                    state.updateSettings(settings.copyWith(isDarkMode: false));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'GPS & Tracking-Optionen'),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.gps_fixed_rounded),
                  title: const Text('GPS-Simulationsmodus'),
                  subtitle: const Text('Ideal zum schnellen Testen auf Emulatoren oder ohne echtes Fahren'),
                  value: settings.simulatedGpsMode,
                  onChanged: (val) {
                    state.updateSettings(settings.copyWith(simulatedGpsMode: val));
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Hintergrund-Benachrichtigung'),
                  subtitle: const Text('Zeigt während der Fahrt eine dauerhafte Notification'),
                  value: settings.enableGpsBackgroundNotice,
                  onChanged: (val) {
                    state.updateSettings(settings.copyWith(enableGpsBackgroundNotice: val));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Einheiten & Währung'),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.straighten_rounded),
                  title: const Text('Distanzeinheit'),
                  trailing: DropdownButton<String>(
                    value: settings.distanceUnit,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'km', child: Text('Kilometer (km)')),
                      DropdownMenuItem(value: 'mi', child: Text('Meilen (mi)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        state.updateSettings(settings.copyWith(distanceUnit: val));
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.local_gas_station_rounded),
                  title: const Text('Volumeneinheit'),
                  trailing: DropdownButton<String>(
                    value: settings.fuelUnit,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'L', child: Text('Liter (L)')),
                      DropdownMenuItem(value: 'gal', child: Text('Gallonen (gal)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        state.updateSettings(settings.copyWith(fuelUnit: val));
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.euro_rounded),
                  title: const Text('Währung'),
                  trailing: DropdownButton<String>(
                    value: settings.currencySymbol,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: '€', child: Text('Euro (€)')),
                      DropdownMenuItem(value: 'CHF', child: Text('Franken (CHF)')),
                      DropdownMenuItem(value: '\$', child: Text('Dollar (\$)')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        state.updateSettings(settings.copyWith(currencySymbol: val));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(context, 'Über diese App'),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline_rounded),
                  title: Text('AutoTrack'),
                  subtitle: Text('Version 1.0.0 • Material 3 GPS Fahrtenbuch & Verbrauchsrechner'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
