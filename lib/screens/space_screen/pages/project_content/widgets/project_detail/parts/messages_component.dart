import 'package:flutter/material.dart';
import 'package:unityspace/screens/widgets/user_avatar_widget.dart';
import 'package:unityspace/utils/localization_helper.dart';

class MessagesComponent extends StatelessWidget {
  const MessagesComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
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
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Text(localization.all_messages),
                ),
              ),
            ),
          ],
        ),
        ListView.builder(
          primary: false,
          shrinkWrap: true,
          itemCount: 10,
          itemBuilder: (BuildContext context, int index) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    UserAvatarWidget(
                      id: 1,
                      width: 24,
                      height: 24,
                      fontSize: 16,
                    ),
                    SizedBox(width: 5),
                    Text('Михаил Рубцов'),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text('(19:41) Создал(а) задачу'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
