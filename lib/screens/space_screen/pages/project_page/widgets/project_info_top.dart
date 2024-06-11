import 'package:flutter/material.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/utils/localization_helper.dart';

class ProjectInfoTop extends StatelessWidget {
  final String columnName;
  final bool isInArchive;
  final void Function()? onArchiveButtonTap;
  final int archiveProjectsCount;
  const ProjectInfoTop({
    required this.columnName,
    required this.isInArchive,
    required this.onArchiveButtonTap,
    required this.archiveProjectsCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                maxLines: 3,
                isInArchive ? localization.an_archive : columnName,
                style: const TextStyle(
                  fontSize: 20,
                  color: ColorConstants.grey02,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (archiveProjectsCount > 0)
              InkWell(
                onTap: onArchiveButtonTap,
                child: Text(
                  isInArchive
                      ? localization.exit_from_archive
                      : localization.project_archive,
                  style: const TextStyle(
                    color: ColorConstants.grey04,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
