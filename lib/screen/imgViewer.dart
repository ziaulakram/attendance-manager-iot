import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class FullScreenImagePage extends StatefulWidget {
  final String imgUrl;
  const FullScreenImagePage({Key? key, required this.imgUrl}) : super(key: key);

  @override
  State<FullScreenImagePage> createState() => _FullScreenImagePageState();
}

class _FullScreenImagePageState extends State<FullScreenImagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: widget.imgUrl.toString()!=''?Image.network(
              widget.imgUrl,
            ):Image.asset('assets/images/unavailable.gif'),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
