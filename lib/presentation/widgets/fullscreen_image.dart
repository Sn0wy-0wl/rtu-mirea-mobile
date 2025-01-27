import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:rtu_mirea_app/presentation/colors.dart';

class FullScreenImage extends StatefulWidget {
  FullScreenImage({Key? key, required this.imageUrl}) : super(key: key);

  final String imageUrl;

  @override
  _FullScreenImageState createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late bool _appBarVisible;

  @override
  void initState() {
    super.initState();

    _appBarVisible = true;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      value: 1.0,
      vsync: this,
    );
  }

  void _toggleAppBarVisibility() {
    _appBarVisible = !_appBarVisible;
    _appBarVisible ? _controller.forward() : _controller.reverse();
  }

  Widget _buildImage() {
    return GestureDetector(
      onTap: () => setState(() {
        _toggleAppBarVisibility();
      }),
      child: PhotoView.customChild(
        initialScale: 1.0,
        child: CachedNetworkImage(
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.contain,
          imageUrl: widget.imageUrl,
        ),
        backgroundDecoration:
            BoxDecoration(color: DarkThemeColors.background01),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Animation<Offset> offsetAnimation = new Tween<Offset>(
      begin: Offset(0.0, -70),
      end: Offset(0.0, 0.0),
    ).animate(_controller);
    return Scaffold(
        body: Stack(
      children: <Widget>[
        _buildImage(),
        SlideTransition(
          position: offsetAnimation,
          child: Container(
            color: DarkThemeColors.background01,
            height: 85,
            child: AppBar(
              title: Text("Просмотр изображения"),
            ),
          ),
        ),
      ],
    ));
  }
}
