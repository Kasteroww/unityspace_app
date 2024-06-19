import 'package:flutter/material.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/utils/localization_helper.dart';

class WorkInProgressStub extends StatelessWidget {
  final String? text;
  const WorkInProgressStub({
    super.key,
    this.text,
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
                  minHeight: 80,
                  maxWidth: 600,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/images/work_in_progress_sign.png',
                      ),
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          width: constraints.maxWidth -
                              (constraints.maxWidth * 0.2 * 2),
                          height: 100,
                          alignment: Alignment.center,
                          child: Center(
                            child: Text(
                              text ?? localization.in_development,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                                height: 28.13 / 24,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
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
