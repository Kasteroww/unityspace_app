import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:unityspace/utils/date_time_converter.dart';

class NotificationsDayText extends StatelessWidget {
  const NotificationsDayText({
    required this.localization,
    required this.date,
    super.key,
  });

  final AppLocalizations localization;

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Text(
      DateTimeConverter.formatDateEEEEdMMMM(
        locale: localization.localeName,
        date: date,
        localization: localization,
      ),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color.fromRGBO(102, 102, 102, 1),
      ),
    );
  }
}
