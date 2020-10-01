import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'test_screen.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _numberOfQuestions = 0;
  List<DropdownMenuItem<int>> _menuItems = []; //またはList();


//    DropdownMenuItem(
//      value: _selectedValue[0],
//      child: Text("10"),
//    ),
//    DropdownMenuItem(
//      value: _selectedValue[1],
//      child: Text("20"),
//    ),
//    DropdownMenuItem(
//      value: _selectedValue[2],
//      child: Text("30"),
//    )


  @override
  void initState() {
    super.initState();
    _menuItems.add(DropdownMenuItem(value: 10, child: Text("10")));
    _menuItems.add(DropdownMenuItem(value: 20, child: Text("20")));
    _menuItems.add(DropdownMenuItem(value: 30, child: Text("30")));
    print(_menuItems);
    _numberOfQuestions = _menuItems[0].value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 20.0,),
              Image.asset("assets/images/image_title.png"),
              const SizedBox(height: 20.0,),
              const Text("問題数を選択して「スタートボタンを押してください」"),
              const SizedBox(height: 40.0,),
              DropdownButton(
                items: _menuItems,
                value: _numberOfQuestions,
                onChanged: (int newValue) {
                  setState(() {
                    print(newValue);
                    _numberOfQuestions = newValue;
                  });
                },
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: RaisedButton.icon(
                    onPressed: () => _startTestScreen(),
                    icon: Icon(Icons.play_arrow),
                    label: Text("スタート"),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    color: Colors.brown,
                  ),
                ),
              ),
              const SizedBox(height: 20.0,),

            ],
          ),
        ),
      ),
    );
  }

  _startTestScreen() {
    print(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
          TestScreen(remainedNumber: _numberOfQuestions,)),
    );
  }


}



