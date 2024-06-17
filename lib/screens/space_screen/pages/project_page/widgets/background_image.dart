import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class BackgroundImage extends StatelessWidget {
  final String? url;
  final int? id;
  const BackgroundImage({required this.url, required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    if (url != null) {
      return CachedNetworkImage(
        imageUrl: url!,
        fit: BoxFit.cover,
        width: width,
        height: height,
      );
    } else if (id != null) {
      // так как у нас только 23 дефолтных изображения
      if (id! > 0 && id! < 24) {
        return Image.asset(
          'assets/images/background/$id.jpeg',
          fit: BoxFit.cover,
          width: width,
          height: height,
        );
      }
    }
    return const SizedBox.shrink();
  }
}
