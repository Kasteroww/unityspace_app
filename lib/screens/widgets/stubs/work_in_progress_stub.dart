import 'package:flutter/material.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/utils/localization_helper.dart';

class WorkInProgressStub extends StatelessWidget {
  const WorkInProgressStub({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      width: width,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 56,
            bottom: 44,
          ),
          child: Column(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600,
                ),
                child: Image.asset(
                  'assets/images/work_in_progress_sign.png',
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 44),
                child: Text(
                  '${localization.oops_page_is_unavailable} :)',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    height: 24 / 18,
                    color: ColorConstants.grey02,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
