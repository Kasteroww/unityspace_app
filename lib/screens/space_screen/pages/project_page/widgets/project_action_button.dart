import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:unityspace/resources/app_icons.dart';
import 'package:unityspace/resources/theme/theme.dart';
import 'package:unityspace/screens/dialogs/add_project_dialog.dart';
import 'package:unityspace/utils/localization_helper.dart';

class ProjectActionButton extends StatefulWidget {
  final int columnId;
  const ProjectActionButton({required this.columnId, super.key});

  @override
  State<ProjectActionButton> createState() => _ProjectActionButtonState();
}

class _ProjectActionButtonState extends State<ProjectActionButton>
    with SingleTickerProviderStateMixin {
  bool _menuVisible = false;
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation =
        Tween<double>(begin: 0, end: 45 / 360).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _menuVisible = !_menuVisible;
      if (_menuVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = LocalizationHelper.getLocalizations(context);
    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 16),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: GestureDetector(
                onTap: () {
                  _toggleMenu();
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: ColorConstants.main,
                  ),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value * 2 * math.pi,
                          child: SvgPicture.asset(
                            AppIcons.add,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_menuVisible)
            Positioned(
              right: 8,
              bottom: 72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedButton(
                    text: localization.new_group,
                    onPressed: () {
                      _toggleMenu();
                    },
                    assetName: AppIcons.addFolder,
                    controller: _controller,
                  ),
                  AnimatedButton(
                    text: localization.add_project,
                    onPressed: () {
                      showAddProjectDialog(
                        context,
                        widget.columnId,
                      );

                      _toggleMenu();
                    },
                    assetName: AppIcons.addClipBoard,
                    controller: _controller,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class AnimatedButton extends StatelessWidget {
  final Color color;
  final VoidCallback onPressed;
  final AnimationController controller;
  final String? text;
  final String? assetName;

  AnimatedButton({
    required this.onPressed,
    required this.controller,
    this.color = ColorConstants.main,
    super.key,
    this.text,
    this.assetName,
  });

  // тень для вариантов выбора
  final shadow = BoxShadow(
    color: Colors.black.withOpacity(0.15),
    spreadRadius: 1,
    blurRadius: 10,
    offset: const Offset(0, 4),
  );

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: controller,
      child: GestureDetector(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              if (text != null)
                Padding(
                  padding: const EdgeInsets.only(
                    right: 12,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        shadow,
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: Text(
                        text ?? '',
                        style: const TextStyle(
                          color: ColorConstants.grey01,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    shadow,
                  ],
                ),
                child: Center(
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: SvgPicture.asset(
                      assetName ?? AppIcons.add,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
