import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unityspace/screens/space_screen/pages/project_page/project_page.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class PopUpProjectsButton extends StatelessWidget {
  const PopUpProjectsButton({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    final store = context.wstore<ProjectsPageStore>();

    return PopupMenuButton<String>(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white,
      child: SizedBox(
        height: 24,
        width: 24,
        child: SvgPicture.asset('assets/icons/settings.svg'),
      ),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<String>>[
          if (!store.isArchivedPage) ...[
            _buildMenuItem(
              context,
              text: localization.to_archive,
              onTap: () => store.archiveProject([id], store.archiveColumnId),
            ),
          ] else ...[
            _buildMenuItem(
              context,
              text: localization.from_archive,
              onTap: null,
            ),
          ],
        ];
      },
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    BuildContext context, {
    required String text,
    required void Function()? onTap,
  }) {
    return PopupMenuItem<String>(
      onTap: onTap,
      child: Row(
        children: [
          const SizedBox(
            height: 16,
            width: 16,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 16.41 / 14,
                color: Color.fromRGBO(77, 77, 77, 1)),
          ),
        ],
      ),
    );
  }
}
