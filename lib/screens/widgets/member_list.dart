import 'package:flutter/material.dart';
import 'package:unityspace/screens/widgets/user_avatar_widget.dart';

class MembersList extends StatelessWidget {
  final double height;
  final List<int> userIds;
  const MembersList({required this.userIds, super.key, this.height = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: userIds.length,
        itemBuilder: (
          BuildContext context,
          int index,
        ) {
          return Transform.translate(
            offset: Offset(
              _calculateOffset(
                itemCount: userIds.length,
                index: index,
                cardOffset: 8,
              ),
              0,
            ),
            child: UserAvatarWidget(
              id: userIds[index],
              width: 24,
              height: 24,
              fontSize: 10,
            ),
          );
        },
      ),
    );
  }

  ///Расчитывается следующим образом:
  /// toRightOffset -  то, на сколько нужно сместить карсточки вправо
  /// cartOffset - непосредственно расчитывается какой offset будет для
  /// наезда одной карточки на другую
  double _calculateOffset({
    required int itemCount,
    required int index,
    required double cardOffset,
  }) {
    final toRightOffset = cardOffset * (itemCount - 1);
    final cartOffset = -cardOffset * index;
    return toRightOffset + cartOffset;
  }
}
