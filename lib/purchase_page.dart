import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'data.dart';

List<ItemData> parseItemData(String responseBody){
  final parsed =  jsonDecode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<ItemData>((json) => ItemData.fromJson(json)).toList();
}

Future<List<ItemData>> getItemData(http.Client client) async{
  final response = await client.get('https://script.google.com/macros/s/AKfycbwxguFPRzpT9P18nLcFQD5tO41J5l9svQ8RhWnGDL2__1-jn1VjgUorMA/exec');

  if(response.statusCode == 200){
    return compute(parseItemData, response.body);
  }
  else{
    throw Exception('Failed to load item data');
  }
}

class PurchasePage extends StatefulWidget {
  PurchasePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  PurchasePageState createState() => PurchasePageState();
}

class PurchasePageState extends State<PurchasePage> {

  Color themeColor = Color(0xff11EEB7);

  List<InCartData> inCartDatas = [];
  int total = 0;
  Future<List<ItemData>> itemDatas;
  static const STATUS_SUCCESS = "SUCCESS";
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController textController = new TextEditingController();

  @override
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double leftWidth = MediaQuery.of(context).size.width*3/5;
    double rightWidth = MediaQuery.of(context).size.width*2/5;

    return FutureBuilder<List<ItemData>>(
      future: getItemData(http.Client()),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              itemScreen(leftWidth, width, snapshot.data),
              checkoutScreen(rightWidth, width, height),
            ],
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }

        // By default, show a loading spinner.
        return Center(
          child: SizedBox(
            height: 30.0,
            width: 30.0,
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget itemScreen(double leftWidth, double width, List<ItemData> itemDatas){
    return SizedBox(
        width: leftWidth,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xffE0E0E0)),
          ),
          child: Scaffold(
            appBar: AppBar(
              elevation: 0.4,
              backgroundColor: Colors.white,
              brightness: Brightness.light,
              leading: IconButton(
                icon: Icon(Icons.menu, size: width / 759.27 * 30, color: themeColor,),
                onPressed: (){

                },
              ),
              centerTitle: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("所有商品", style: TextStyle(fontSize: width / 759.27 * 20, color: Colors.black),),
                  SizedBox(width: 10,),
                  Icon(Icons.keyboard_arrow_down, size: width / 759.27 * 30, color: themeColor,),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.add, size: width / 759.27 * 30, color: themeColor,),
                  onPressed: (){

                  },
                ),
                IconButton(
                  icon: Icon(Icons.refresh, size: width / 759.27 * 30, color: themeColor,),
                  onPressed: (){
                    setState(() {

                    });
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: showItemList(itemDatas),
            ),
          ),
        )
    );
  }

  Widget checkoutScreen(double rightWidth, double width, double height){
    return SizedBox(
      width: rightWidth,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xffE0E0E0)),
        ),
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            elevation: 0.4,
            backgroundColor: Colors.white,
            brightness: Brightness.light,
            leading: IconButton(
              icon: Icon(Icons.delete_forever, size: width / 759.27 * 30, color: themeColor,),
              onPressed: (){
                setState(() {
                  inCartDatas.clear();
                });
              },
            ),
            centerTitle: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("購物車(${inCartSum()}件)", style: TextStyle(fontSize: width / 759.27 * 20, color: Colors.black),),
                SizedBox(width: 10,),
                Icon(Icons.keyboard_arrow_down, size: width / 759.27 * 30, color: themeColor,),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.add, size: width / 759.27 * 30, color: themeColor,),
                onPressed: (){

                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: height / 20),
                Container(
                  height: height / 5.75,
                  width: rightWidth,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: height / 50,),
                      Row(
                        children: [
                          SizedBox(width: rightWidth / 20,),
                          CircleAvatar(
                            radius: 23,
                            backgroundColor: Color(0xff11EEB7),
                            child: CircleAvatar(
                              radius: 21,
                              backgroundImage: AssetImage('assets/pic7.jpg'),
                            ),
                          ),
                          SizedBox(width: rightWidth / 24,),
                          SizedBox(
                            width: rightWidth / 1.5,
                            height: height / 10.5,
                            child: TextField(
                              controller: textController,
                              //textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.phone, size: width / 759.27 * 17,),
                                hintText: '請輸入手機號碼',
                                contentPadding: EdgeInsets.only(top: height / 40, bottom: height / 40),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.5),
                                  borderSide: BorderSide(
                                    color: Color(0xff8E8E8E),
                                  ),
                                )
                              ),
                            ),
                          ),
                          /*Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('Hoshi', style: TextStyle(fontSize: width / 759.27 * 14, color: Color(0xff8E8E8E)),),
                                  SizedBox(width: rightWidth / 33,),
                                  Text('0987654321', style: TextStyle(fontSize: width / 759.27 * 14, color: Color(0xff8E8E8E)),),
                                ],
                              ),
                              Text('累積消費: 12000', style: TextStyle(fontSize: width / 759.27 * 14, color: Color(0xff8E8E8E)),),
                            ],
                          ),*/
                          SizedBox(width: rightWidth / 20,),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height / 20),
                //for(var i in inCartDatas) showInCartDatas(i),
                for(int i = 0 ; i < inCartDatas.length ; i++) showInCartDatas(i),
                SizedBox(height: height / 20),
                showCalculate('小結', ' ', 0),
                for(var i in discountDatas) showCalculate(i.discountName, '-\$ ${i.discountPrice}', i.discountPrice),
                Container(
                  height: MediaQuery.of(context).size.height/9.5,
                  width: MediaQuery.of(context).size.width*2/5,
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: width / 759.27 * 20.0, right: width / 759.27 * 20.0, top: 0.0, bottom: 0.0),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.black,
                        width: 0.1,
                      ),
                      bottom: BorderSide(
                        color: Colors.black,
                        width: 0.1,
                      ),
                    ),
                    color: Colors.white,
                  ),
                  //color: Colors.white,
                  child: ListTile(
                    contentPadding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
                    visualDensity: VisualDensity.comfortable,
                    dense: true,
                    leading: Text('新增整單折扣', style: TextStyle(fontSize: width / 759.27 * 14, color: Color(0xff8E8E8E)),),
                    trailing: Icon(Icons.add_circle_outline, color: Color(0xff11EEB7),),
                    onTap: (){

                    },
                  ),
                ),
                SizedBox(height: height / 20),
                RaisedButton(
                  padding: EdgeInsets.only(left: width / 759.27 * 80, right: width / 759.27 * 80, top: width / 759.27 * 8, bottom: width / 759.27 * 8),
                  color: Color(0xff11EEB7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: total >= 0 ? Text('\$ $total', style: TextStyle(fontSize: width / 759.27 * 22, color: Colors.white),) : Text('\$ 0', style: TextStyle(fontSize: width / 759.27 * 22, color: Colors.white),),
                  onPressed: (){
                    showAlertDialog(context);
                  },
                  /*onPressed: () async{
                    for(var i in inCartDatas){
                      await Future.delayed(const Duration(seconds: 1));
                      uploadOrder(i/*, (String response) {
                          print("Response: $response");
                          if (response == STATUS_SUCCESS) {
                            // Feedback is saved successfully in Google Sheets.
                            showSnackBar("Order Submitted");
                          } else {
                            //print("hi");
                            // Error Occurred while saving data in Google Sheets.
                            showSnackBar("Error Occurred!");
                          }
                        }*/
                      );
                    }
                  },*/
                ),
                SizedBox(height: height / 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showItemList(List<ItemData> itemDatas){
    if(itemDatas.length % 4 == 0){
      return Column(
        children: [
          for(int i = 0 ; i < itemDatas.length / 4; i++)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for(int j = i*4 ; j < (i+1)*4 ; j++) showItem(j, itemDatas),
              ],
            ),
          SizedBox(height: 10,),
        ],
      );
    }
    else{
      return Column(
        children: [
          for(int i = 0 ; i < itemDatas.length / 4 + 1; i++)
            i == itemDatas.length / 4 ?
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for(int j = i*4 ; j < (i+1)*4 ; j++) showItem(j, itemDatas),
              ],
            ):
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for(int j = i*4 ; j < itemDatas.length ; j++) showItem(j, itemDatas),
              ],
            ),
        ],
      );
    }
  }

  Widget showItem(int num, List<ItemData> itemDatas){
    return Column(
      children: [
        FlatButton(
          padding: EdgeInsets.all(0.0),
          onPressed: (){
            setState(() {
              int check = -1;
              for(int i = 0 ; i < inCartDatas.length ; i++){
                if(inCartDatas[i].item == itemDatas[num].name){
                  check = i;
                  break;
                }
              }
              if(check == -1){
                inCartDatas.add(InCartData(item: itemDatas[num].name, number: 1, price: itemDatas[num].price, inventory: itemDatas[num].inventory, id: itemDatas[num].id));
              }
              else{
                inCartDatas[check].number++;
              }
              /*if(itemDatas[num].inCartNum == 0){
                inCartDatas.add(itemDatas[num]);
              }
              itemDatas[num].inCartNum += 1;
              print(itemDatas[num].inCartNum);*/
            });
          },
          child: Container(
            height: MediaQuery.of(context).size.height/4.0,
            width: MediaQuery.of(context).size.width*3/5/4.0 - 0.5,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider('https://drive.google.com/thumbnail?id=${itemDatas[num].id}'),
                  fit: BoxFit.fill,
                )
            ),
          ),
        ),
        Text(itemDatas[num].name),
        Text("\$" + itemDatas[num].price.toString() + ' (${itemDatas[num].type})'),
      ],
    );
  }

  Widget showInCartDatas(int index){

    double width = MediaQuery.of(context).size.width;

    return Dismissible(
      key: Key(inCartDatas[index].item),
      onDismissed: (direction){
        setState(() {
          inCartDatas.removeAt(index);
        });
      },
      background: Container(
        color: Colors.red,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height/7,
        width: MediaQuery.of(context).size.width*2/5,
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: width / 759.27 * 20.0, right: width / 759.27 * 20.0, top: 0.0, bottom: 0.0),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.black,
              width: 0.1,
            ),
            bottom: BorderSide(
              color: Colors.black,
              width: 0.1,
            ),
          ),
          color: Colors.white,
        ),
        child: ListTile(
          contentPadding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
          visualDensity: VisualDensity.comfortable,
          dense: true,
          leading: Container(
            height: MediaQuery.of(context).size.height/10,
            width: MediaQuery.of(context).size.height/10,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider('https://drive.google.com/thumbnail?id=${inCartDatas[index].id}'),
                  fit: BoxFit.fill,
                )
            ),
          ),
          title: Text(inCartDatas[index].item, style: TextStyle(fontSize: width / 759.27 * 14, fontWeight: FontWeight.bold),),
          subtitle: Text('目前庫存: ' + inCartDatas[index].inventory.toString(), style: TextStyle(fontSize: width / 759.27 * 10),),
          trailing: Text('(${inCartDatas[index].number}) \$' + (inCartDatas[index].price * inCartDatas[index].number).toString(), style: TextStyle(fontSize: width / 759.27 * 16, fontWeight: FontWeight.bold),),
        ),
      ),
    );
  }

  Widget showCalculate(String lead, String trail, int discountPrice){

    double width = MediaQuery.of(context).size.width;

    if(lead == '小結'){
      int priceSum = 0;
      for(int i = 0 ; i < inCartDatas.length ; i++){
        priceSum += inCartDatas[i].price * inCartDatas[i].number;
      }
      total = priceSum;
      return Container(
        height: MediaQuery.of(context).size.height/9.5,
        width: MediaQuery.of(context).size.width*2/5,
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: width / 759.27 * 20.0, right: width / 759.27 * 20.0, top: 0.0, bottom: 0.0),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.black,
              width: 0.1,
            ),
            bottom: BorderSide(
              color: Colors.black,
              width: 0.1,
            ),
          ),
          color: Colors.white,
        ),
        //color: Colors.white,
        child: ListTile(
          contentPadding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
          visualDensity: VisualDensity.comfortable,
          dense: true,
          leading: Text(lead, style: TextStyle(fontSize: width / 759.27 * 14),),
          trailing: Text('\$ $priceSum', style: TextStyle(fontSize: width / 759.27 * 16, fontWeight: FontWeight.bold),),
        ),
      );
    }
    total -= discountPrice;
    return Container(
      height: MediaQuery.of(context).size.height/9.5,
      width: MediaQuery.of(context).size.width*2/5,
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: width / 759.27 * 20.0, right: width / 759.27 * 20.0, top: 0.0, bottom: 0.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.black,
            width: 0.1,
          ),
          bottom: BorderSide(
            color: Colors.black,
            width: 0.1,
          ),
        ),
        color: Colors.white,
      ),
      //color: Colors.white,
      child: ListTile(
        contentPadding: EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
        visualDensity: VisualDensity.comfortable,
        dense: true,
        leading: Text(lead, style: TextStyle(fontSize: width / 759.27 * 14),),
        trailing: Text(trail, style: TextStyle(fontSize: width / 759.27 * 16, fontWeight: FontWeight.bold),),
      ),
    );
  }

  int inCartSum(){
    int sum = 0;
    for(var i in inCartDatas) sum += i.number;
    return sum;
  }

  void uploadOrder(InCartData nowData, void Function(String) callback) async{
    print(nowData.item+nowData.number.toString());

    nowData.time = DateTime.now().toLocal().toString();
    nowData.phone = "'" + textController.text;

    try {
      await http.post('https://script.google.com/macros/s/AKfycbwxguFPRzpT9P18nLcFQD5tO41J5l9svQ8RhWnGDL2__1-jn1VjgUorMA/exec',
          body: nowData.toJson())
      .then((response) async {
        if (response.statusCode == 302) {
          var url = response.headers['location'];
          await http.get(url).then((response) {
            callback(jsonDecode(response.body)['status']);
          });
        } else {
          callback(jsonDecode(response.body)['status']);
        }
      });
      print(nowData.item+" end");
    } catch (e) {
      print(e);
    }
  }

  void showAlertDialog(BuildContext context){

    AlertDialog dialog = AlertDialog(
      title: Row(
        children: [
          Icon(Icons.check),
          Text(" 確認訂單", style: TextStyle(fontWeight: FontWeight.bold),),
        ],
      ),
      elevation: 0.0,
      content: Container(
        height: context.size.height * 0.8,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text("Phone: ${textController.text}", style: TextStyle(fontSize: 15.0),),
              for(var i in inCartDatas) Text("${i.item} : ${i.number}", style: TextStyle(fontSize: 15.0),),
            ],
          ),
        ),
      ),
      actions: [
        FlatButton(
          onPressed: () async{
            Navigator.pop(context, true);
            for(var i in inCartDatas){
              await Future.delayed(const Duration(seconds: 1));
              uploadOrder(i, (String response) {
                  print("Response: $response");
                  if (response == STATUS_SUCCESS) {
                    // Feedback is saved successfully in Google Sheets.
                    showSnackBar("Order Submitted");
                  } else {
                    //print("hi");
                    // Error Occurred while saving data in Google Sheets.
                    showSnackBar("Error Occurred!");
                  }
              }
              );
            }
          },
          child: Text("Yes"),
          color: Colors.blueAccent,
        ),
        FlatButton(
          onPressed: (){
            Navigator.pop(context, true);
          },
          child: Text("No"),
        )
      ],
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => dialog,
    );
  }

  void showSnackBar(String message){
    final snackBar = SnackBar(content: Text(message));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}