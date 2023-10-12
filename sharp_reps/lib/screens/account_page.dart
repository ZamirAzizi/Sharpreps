import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsScreen(
      title: 'Account Settings',
      children: <Widget>[
        buildPrivacy(context),
        buildSecurity(context),
        buildAccountInfo(context),
      ],
    );
  }
}

Widget buildPrivacy(BuildContext context) => SimpleSettingsTile(
      title: 'Privacy',
      subtitle: '',
      leading: Icon(
        Icons.lock,
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: () => ScaffoldMessenger.of(context)
          .showSnackBar('clicked privacy' as SnackBar),
    );

Widget buildSecurity(BuildContext context) => SimpleSettingsTile(
      title: 'Security',
      subtitle: '',
      leading: Icon(
        Icons.security,
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: () => ScaffoldMessenger.of(context)
          .showSnackBar('clicked privacy' as SnackBar),
    );

Widget buildAccountInfo(BuildContext context) => SimpleSettingsTile(
      title: 'Account Info',
      subtitle: '',
      leading: Icon(
        Icons.text_snippet,
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: () => ScaffoldMessenger.of(context)
          .showSnackBar('clicked privacy' as SnackBar),
    );
