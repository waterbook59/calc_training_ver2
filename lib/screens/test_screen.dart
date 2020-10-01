import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

class TestScreen extends StatefulWidget {
  final remainedNumber;

  TestScreen({this.remainedNumber});//クラスの中で自分で受け取りたい値を設定したコンストラクタを作る

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {

  int questionRemaining=0;
  int correctAnswerNumber =0;
  int correctAnswerRatio=0;

  int questionNumberLeft=0;
  int questionNumberRight=0;
  String operator="";
  String calcResult="";

  Soundpool _soundpool;
  List<int> _soundIds=[0,0];

  bool isCalcButtonsEnabled = false; //電卓ボタン
  bool isAnswerCheckButtonEnabled = false; //答えあわせボタン
  bool isBackButtonEnabled =false;//戻るボタン
  bool isCorrectIncorrectImageEnabled = false; //まるばつボタン
  bool isEndMessageEnabled =false;//終了メッセージ
  bool isCorrect=false;

  @override
  void initState() {
    super.initState();
    questionRemaining = widget.remainedNumber;
    _initSounds();
    //問題を初期設定するメソッド
    _setQuestion();
//    print(_soundIds[0]);
//    setState(() {});

  }

  Future<void> _initSounds()async {
    try {
      _soundpool = Soundpool();
      //公式リファレンスからそのままsoudId取得を貼り付けるとrootBundle認識しないかも
      //rootBundle.load(パス(String))でうまいこといくと.then()の中の変数にByteDate型の値が入ってくる
      _soundIds[0] = await loadSound("assets/sounds/sound_correct.mp3");
      _soundIds[1] = await loadSound("assets/sounds/sound_incorrect.mp3");
      print(_soundIds[1]);

      //initStateにasync/awaitつけられないので、initSoundsが終わる前にbuildが回ってしまう=>ここでsetState必要
      setState(() {});
    } on IOException catch (error){
      print("エラー内容は：$error");
    }
  }

  Future<int> loadSound(String soundPath) {
    //then使っているので、loadSound内ではasync/await使わなくて良い
    return rootBundle.load(soundPath).then((ByteData value)=>_soundpool.load(value));
  }


  @override
  void dispose() {
    _soundpool.release();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(//先にSafeAreaを設定し、その上にScaffold
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 20.0),
                  //スコア表示部 Widgetを外出しするなら、文頭の戻り値Widgetに設定すること
                  _scorePart(),
//                  Container(
//                    child: Text(widget.remainedNumber.toString(),style: TextStyle(fontSize: 18.0),),
//                  ),
                  //todo 問題表示 RowでText横並び
                  _questionPart(),
                  //todo 電卓ボタン
                  _calcButton(),
                  //todo 答えあわせボタン
                  _answerCheckButton(),
                  //todo もどるボタン
                  _backButton(),
                ],
              ),
            ),
            //stackの２つ目のwidgetとして丸バツ画像を外出し
            _correctIncorrectImage(),
            //stackの３つ目のwidgetとしてテスト終了メッセージ
            _finishMessage(),
          ],
        ),),
    );
  }

  Widget _scorePart() {
    return Table(
      border: TableBorder.all(color: Colors.white),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      defaultColumnWidth: FlexColumnWidth(2.0),
      children: [
        TableRow(
            children: [
              Center(child: const Text("残り問題数",style:TextStyle(fontSize: 18.0),)),
              Center(child: const Text("正解数",style:TextStyle(fontSize: 18.0))),
              Center(child: const Text("正答率",style:TextStyle(fontSize: 18.0))),
            ]
        ),
        TableRow(
            children: [
              Container(
                child: Center(child: Text(questionRemaining.toString(),style:TextStyle(fontSize: 25.0))),
              ),
              Container(
                child: Center(child: Text(correctAnswerNumber.toString(),style:TextStyle(fontSize: 25.0))),
              ),
              Container(
                child: Center(child: Text(correctAnswerRatio.toString(),style:TextStyle(fontSize: 25.0))),
              ),
            ]
        ),
      ],
    );
  }

  Widget _questionPart() {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0,bottom: 20.0),
      child: Row(
        children: <Widget>[
          Expanded(flex:2,child: Center(child: Text(questionNumberLeft.toString(),style:TextStyle(fontSize: 36.0)))),
          Expanded(flex:1,child: Center(child: Text(operator,style:TextStyle(fontSize: 20.0)))),
          Expanded(flex:2,child: Center(child: Text(questionNumberRight.toString(),style:TextStyle(fontSize: 36.0)))),
          Expanded(flex:1,child: Center(child: Text("=",style:TextStyle(fontSize: 20.0)))),
          Expanded(flex:3,child: Center(child: Text(calcResult,style:TextStyle(fontSize: 45.0)))),

        ],
      ),
    );
  }

  Widget _calcButton() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top:40.0),
        child: Table(
          children: [
            TableRow(
              children: [//同じWidgetの記載が並ぶ時は、Widget自体をメソッドとして外出し
                _numberOfButton("7"),
                _numberOfButton("8"),
                _numberOfButton("9"),
              ]
            ),
            TableRow(
              children: [
                _numberOfButton("4"),
                _numberOfButton("5"),
                _numberOfButton("6"),
              ]
            ),
            TableRow(
              children: [
                _numberOfButton("1"),
                _numberOfButton("2"),
                _numberOfButton("3"),
                ]
            ),
            TableRow(
                children: [
                _numberOfButton("0"),
                _numberOfButton("-"),
                _numberOfButton("C"),
                ]
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberOfButton(String numString) {

    return Padding(
      padding: const EdgeInsets.only(left: 2.0,right: 2.0),
      child: RaisedButton(
        child:Text(numString,style: TextStyle(fontSize: 20.0),),
        onPressed: isCalcButtonsEnabled ? ()=>inputAnswer(numString) : null,
      ),
    );


  }



  Widget _answerCheckButton() {
    return SizedBox(
      width: double.infinity,
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        color: Colors.brown,
        child: Text("答えあわせ",style: TextStyle(fontSize: 20.0),),
        //答えあわせボタン押せる時は電卓ボタン押せる時
        onPressed: isCalcButtonsEnabled?()=>_checkAnswer():null,
      ),
    );
  }

  Widget _backButton() {
    return  Padding(
      padding: const EdgeInsets.only(bottom:9.0),
      child: SizedBox(
        width: double.infinity,
        child: RaisedButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          color: Colors.lightGreenAccent,
          child: Text("戻る",style: TextStyle(color: Colors.black87,fontSize: 20.0),),
          onPressed: isBackButtonEnabled ?() {
              print(context);
              Navigator.pop(context);
          } : null,
        ),
      ),
    );
  }



  Widget _correctIncorrectImage() {
    if(isCorrectIncorrectImageEnabled) {
      //ここに正解かどうかの条件
      if(isCorrect){
        return Center(child: Image.asset("assets/images/pic_correct.png"));
      }else{//早期リターンしてるからelseなくてもいいみたい
        return Center(child: Image.asset("assets/images/pic_incorrect.png"));
      }

//
    }else{
      return Container();
    }
  }

  Widget _finishMessage() {
    if(isEndMessageEnabled){
      return Center(child: Text("テスト終了",style: TextStyle(fontSize: 40.0,fontWeight: FontWeight.bold),));
    }else{
      return Container();
    }
  }

  _playSound(int soundId) async{
    await _soundpool.play(soundId);
  }

   _setQuestion() {
    isCalcButtonsEnabled =true;
    isAnswerCheckButtonEnabled =true;
    isBackButtonEnabled =false;
    isCorrectIncorrectImageEnabled =false;
    isEndMessageEnabled=false;
    calcResult ="";

    Random random = Random();
    questionNumberLeft =random.nextInt(100)+1;
    questionNumberRight = random.nextInt(100)+1;
    //+,-の二択もrandomの0,1をif文を使ってかける
     if(random.nextInt(2) == 0){
       operator = "+";
     }else{
       operator ="-";
     }
     //2問目以降initState内で使わない場合自力でbuildメソッド呼び出す必要あり
     setState(() {
     });
  }

  inputAnswer(String numString) {
    if(isCalcButtonsEnabled){
      setState(() {
        if(numString == "C"){
          calcResult ="";
          return;
        }
        //-を入力する時:空なら-入力できる
        if(numString == "-"){
          if(calcResult =="") calcResult ="-";
            return;
        }
        //0を入力する時 :空なら0入力できる、0か-が入ってる時は0に置きかえる、0と-以外は後ろに加える
        //短く書くなら...0と-以外が入ってる時後ろに加えて良い
        if(numString == "0"){
          if(calcResult==""){
            calcResult ="0";
            return;
          }
          if(calcResult == "0" || calcResult == "-") {
            calcResult = numString;
            return;
          }
          if(calcResult != "0" || calcResult != "-"){
            calcResult =calcResult + numString;
            return;
          }
        }
        //0と-以外を入力する時：0の時は置きかえる
        if(numString !="0"&& numString !="-"){
          if(calcResult =="0"){
            calcResult = numString;
            return;
          }
          //ここにreturn;だけをかくと0と-以外を入力できない
          //答えの入力の基本の方法は前に入力したものの後ろに押した数字を入れる
          calcResult =calcResult + numString;
        }
      });
    }
  }

  _checkAnswer() {
    //calcResultを入力しないまたは-だけの時は排除
      if(calcResult ==""||calcResult =="-"){
        return;
      }
      //残り問題数１問減らす
      questionRemaining -= 1;

      isCalcButtonsEnabled =false;
      isAnswerCheckButtonEnabled =false;
      isBackButtonEnabled =false;
      isCorrectIncorrectImageEnabled =true;
      isEndMessageEnabled=false;

      var myAnswer = int.parse(calcResult).toInt();

      var realAnswer =0;
      //operatorを+と-で条件わけ
      if(operator =="+"){
        realAnswer = questionNumberLeft + questionNumberRight;
      }else{
        realAnswer = questionNumberLeft - questionNumberRight;
      }

      if(myAnswer == realAnswer){
        _playSound(_soundIds[0]);
        // まるイメージだす(正解・不正解を判定して_correctIncorrectImage内でさらにisCorrectで分岐)
        isCorrect =true;
        //_scorePartの正解数を１もん増やす
        correctAnswerNumber += 1;
      }else{
        _playSound(_soundIds[1]);
        // バツイメージだす
        isCorrect =false;
      }

      //右辺が計算の結果double型になっているので、int型へ変換
      correctAnswerRatio = ((correctAnswerNumber/(widget.remainedNumber-questionRemaining))*100).toInt();

      //終了するかどうか
      if(questionRemaining>0){
        //1秒後に_setQuestionメソッド実行
        Timer(Duration(seconds: 1),()=>_setQuestion());
      //returnを入れると戻っていってしまって下のsetStateまで到達せず、丸ばつ反映されない
      }
      if(questionRemaining == 0){

        isCalcButtonsEnabled =false;
        isAnswerCheckButtonEnabled =false;
        isBackButtonEnabled =true;
        isCorrectIncorrectImageEnabled =true;
        isEndMessageEnabled=true;

      }


      setState(() {

      });
      }



}


