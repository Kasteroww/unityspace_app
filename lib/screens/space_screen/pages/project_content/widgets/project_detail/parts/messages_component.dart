import 'package:flutter/material.dart';
import 'package:unityspace/screens/space_screen/pages/project_content/widgets/project_detail/project_detail.dart';
import 'package:unityspace/screens/widgets/user_avatar_widget.dart';
import 'package:unityspace/utils/date_time_converter.dart';
import 'package:unityspace/utils/localization_helper.dart';
import 'package:wstore/wstore.dart';

class MessagesComponent extends StatelessWidget {
  const MessagesComponent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return WStoreBuilder<ProjectDetailStore>(
      watch: (store) => [store.currentHistory],
      builder: (context, store) {
        final elementList = store.currentHistory ?? [];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Среда, 5 июня'),
                Material(
                  clipBehavior: Clip.hardEdge,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: InkWell(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: Text(localization.all_messages),
                    ),
                  ),
                ),
              ],
            ),
            ListView.builder(
              primary: false,
              shrinkWrap: true,
              itemCount: elementList.length,
              itemBuilder: (BuildContext context, int index) {
                final element = elementList[index];
                return Column(
                  key: ValueKey('${element.id}'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        UserAvatarWidget(
                          id: element.userId,
                          width: 24,
                          height: 24,
                          fontSize: 10,
                        ),
                        const SizedBox(width: 5),
                        Text(store.getUserNameById(element.userId)),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        '(${DateTimeConverter.formatTimeHHmm(element.updateDate)}) ${element.state}',
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
