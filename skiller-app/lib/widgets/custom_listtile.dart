import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final IconData iconData;
  final String title;
  final VoidCallback onTap;
  final Color color;
  const CustomListTile(
      {Key? key,
      required this.title,
      required this.iconData,
      required this.onTap,
      required this.color})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
      child: InkWell(
        splashColor: Colors.deepOrangeAccent,
        onTap: onTap,
        child: Container(
          decoration: const BoxDecoration(
              border: Border(
            bottom: BorderSide(color: Colors.grey),
          )),
          height: 50.0,
          child: Row(
            children: <Widget>[
              Icon(
                iconData,
                color: color,
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
