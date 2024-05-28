import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PopUpReglamentButton extends StatelessWidget {
  final List<PopupMenuEntry<String>> popupMenuEntryList;
  const PopUpReglamentButton({super.key, required this.popupMenuEntryList});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white,
      child: SizedBox(
        height: 25,
        width: 25,
        child: SvgPicture.asset('assets/icons/settings.svg'),
      ),
      itemBuilder: (BuildContext context) {
        return popupMenuEntryList;
      },
    );
  }
}

class PopupMenuItemChild extends StatelessWidget {
  final String text;
  const PopupMenuItemChild({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 16.41 / 14,
          color: Color.fromRGBO(77, 77, 77, 1)),
    );
  }
}
