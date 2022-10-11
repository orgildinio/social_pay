import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:social_pay/colors.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class SocialPay extends StatefulWidget {
  double payloan;
  SocialPay({Key? key,required this.payloan}) : super(key: key);

  @override
  State<SocialPay> createState() => _SocialPayState();
}

class _SocialPayState extends State<SocialPay> {
  final _storage = new FlutterSecureStorage();
  String pay = "";
  String url = "";
  int pay_int = 0;

  @override
  void initState() {
    getwallet();
    super.initState();
  }

  getwallet() async {
    var walletval = await _storage.read(key: "key_wallet_balance");
    setState(() {
      this.pay = walletval.toString();
      this.pay_int = int.parse("$walletval");
    });
  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color.fromRGBO(243, 245, 248, 1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Social Pay",
          style: TextStyle(
              fontFamily: "Ubuntu",
              fontStyle: FontStyle.normal,
              fontSize: 17,
              color: primarycolor,
              fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: secondarycolor,
              size: 24,
            )),
      ),
      body:  Container(
        padding: EdgeInsets.only(bottom: 22, top: 17),
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 22, top: 17),
              margin: EdgeInsets.symmetric(horizontal: 15),
              width: 400,
              height: 101,
              decoration: BoxDecoration(
                border: Border.all(color: secondarycolor.withOpacity(0.9)),
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: [
                      Text("Төлөх дүн", style: TextStyle(
                        color: primarycolor,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Ubuntu",
                        fontSize: 17,
                        fontStyle: FontStyle.normal,
                      ),),
                      Row(
                        children: <Widget>[
                          Text(
                            NumberFormat.decimalPattern().format(widget.payloan),
                            style: TextStyle(
                              color: primarycolor,
                              fontFamily: "Ubuntu",
                              fontSize: 35,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                          Text("₮",
                            style: TextStyle(
                              color: primarycolor,
                              fontFamily: "Ubuntu",
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                            ),),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 15.0,
                ),
                ButtonTheme(
                  minWidth: 200.0,
                  height: 50.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.fromLTRB(
                          80, 12, 80, 12),
                      primary: secondarycolor.withOpacity(0.9),
                      shape: new RoundedRectangleBorder(
                        borderRadius:
                        new BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () async {
                      socailPay();
                      // print("$url <-- Redirecting this url now");
                    },
                    child: Text(
                      'Төлөх',
                      style: TextStyle(
                          fontFamily: "Ubuntu",
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primarycolor),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Future<dynamic> socailPay() async {
    http.post(Uri.parse("http://localhost:3000/socialpay/invoice"),
      headers: {
        'Content-Type': 'application/json',
        //'Authorization': 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJNRVJDSEFOVF9WVUxDQU5fQU5BTElUWUNTX0xMQyIsImlhdCI6MTY2MDMwMTQwMH0.5S_u88JkeJ5EGQafbN3-5CftMOUEerQ8OBRhGjnLo9E',
      },
      body: jsonEncode({
        'amount': widget.payloan / 0.99,
      }),
    ).then((http.Response response) {
      final int statusCode = response.statusCode;
      if(statusCode < 200 || statusCode > 400 || json == null){
        throw Exception("error");
      }
      var data = jsonDecode(response.body);
      if(data['redirect_url'] != null) {
        setState(() {
          url = data["redirect_url"];
          // print(url);
          Navigator.push(context, MaterialPageRoute(builder: (context) => Golomtbank(url: url)));
        });
      } else {
        print("Failed SCP");
      }
      return json.decode(response.body);
    }
    );
  }
}

class Golomtbank extends StatefulWidget {
  final String url;
  const Golomtbank({Key? key, required this.url}) : super(key: key);
  @override
  State<Golomtbank> createState() => _GolomtbankState();
}

class _GolomtbankState extends State<Golomtbank> {

  double progress = 0;
  bool _loadedPage = false;
  String initialUrl = "";

  @override
  void initState() {
    setState(() {
      initialUrl = widget.url;
    });
    super.initState();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55),
        child: AppBar(
          backgroundColor: Color.fromRGBO(243, 245, 248, 1),
          elevation: 0,
          title: Text(
            "Social Pay төлбөр",
            style: TextStyle(
              color: secondarycolor,
              fontFamily: "Ubuntu",
              fontSize: 17,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                size: 24,
                color: secondarycolor,
              )),
        ),
      ),
      body: Container(
        color: Color.fromRGBO(243, 245, 248, 1),
        child: SafeArea(
          child: Builder(
            builder: (BuildContext context) {
              return Stack(
                children: <Widget>[
                  WebView(
                    backgroundColor: Color.fromRGBO(243, 245, 248, 1),
                    initialUrl: "${widget.url}",
                    javascriptMode: JavascriptMode.unrestricted,
                    javascriptChannels: {
                      JavascriptChannel(
                        name: 'sendDanData',
                        onMessageReceived: (JavascriptMessage message1) {
                          var object = json.decode(message1.message);
                          print(object);
                          log(message1.message);
                          var userData = object['services']
                          ['WS100101_getCitizenIDCardInfo']['response'];
                          print("$userData");
                          //   print(phonenumber);
                          var bodyData = {
                            "issue_date": userData['passportIssueDate'],
                            "expire_date": userData['passportExpireDate'],
                            "aimag_code": userData['aimagCityCode'],
                            "bag_code": userData['bagKhorooCode'],
                            "sum_code": userData['soumDistrictCode'],
                            "firstname": userData['firstname'],
                            "address": userData['passportAddress'],
                            "picture": userData['image'],
                            "reg_no": userData['regnum']
                          };
                          print("E-Mongolia CitizenIDCardInfo -->");
                          print(bodyData);
                          //    updateDanConfirm(bodyData);
                        },
                      ),
                    },
                    userAgent:
                    "Mozilla/5.0 (Linux; Android 4.1.1; Galaxy Nexus Build/JRO03C) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.166 Mobile Safari/535.19",
                    onWebViewCreated: (controller) {
                      controller.clearCache();
                      print("cache cleared");
                      //       print("$phonenumber");
                    },
                    onPageFinished: (url) {
                      setState(() {
                        print("Page Finished $url");
                        _loadedPage = true;
                      });
                    },
                  ),
                  _loadedPage == false
                      ? Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.white,
                      strokeWidth: 1.5,
                      color: primarycolor,
                    ),
                  )
                      : Container(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}


