import 'package:flutter/material.dart';
import 'package:unityspace/models/task_message_models.dart';
import 'package:unityspace/resources/theme/theme.dart';
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
      watch: (store) => [store.chatItems],
      builder: (context, store) {
        final elementList = store.chatItems;
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
                if (element.message != null) {
                  final TaskMessage message = element.message!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: ColorConstants.grey10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          key: ValueKey('${message.id}'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                UserAvatarWidget(
                                  id: message.senderId,
                                  width: 24,
                                  height: 24,
                                  fontSize: 10,
                                ),
                                const SizedBox(width: 5),
                                Text(store.getUserNameById(message.senderId)),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                '(${DateTimeConverter.formatTimeHHmm(element.date)}) ${message.text}',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                if (element.history != null) {
                  final history = element.history!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      key: ValueKey('${history.id}'),
                      '${store.getUserNameById(history.userId)}'
                      '(${DateTimeConverter.formatTimeHHmm(element.date)})'
                      ' ${history.state}',
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
