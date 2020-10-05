import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Vote extends StatefulWidget {
  const Vote({Key key}) : super(key: key);

  @override
  _VoteState createState() => _VoteState();
}

class _VoteState extends State<Vote> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CupertinoButton(
          child: Container(
            // height: 200,
            // width: 200,
            decoration: BoxDecoration(
              // image: DecorationImage(
              //   image: AssetImage("assets/mindful.jpg"),
              //   fit: BoxFit.cover,
              // ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              margin: EdgeInsets.fromLTRB(15, 15, 0, 0),
              child: Text(
                "A",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          onPressed: () {},
        ),
        CupertinoButton(
          child: Container(
            // height: 200,
            // width: 200,
            decoration: BoxDecoration(
              // image: DecorationImage(
              //   image: AssetImage("assets/mindful.jpg"),
              //   fit: BoxFit.cover,
              // ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              margin: EdgeInsets.fromLTRB(15, 15, 0, 0),
              child: Text(
                "B",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          onPressed: () {},
        ),
      ],
    ));
  }
}
