import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:news/utils/internetConnectivity.dart';

class NewsDetailsVideo extends StatefulWidget {
  String? src;
  String type;

  NewsDetailsVideo({super.key, this.src, required this.type});

  @override
  State<StatefulWidget> createState() => StateNewsDetailsVideo();
}

class StateNewsDetailsVideo extends State<NewsDetailsVideo> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isNetworkAvail = true;
  var iframe;

  @override
  void initState() {
    super.initState();

    checkNetwork();
    if ((widget.type == "1") || (widget.type == "3")) {
      iframe = '''
        <html>
          <iframe src="${widget.src!}" width="100%" height="100%" allowfullscreen="allowfullscreen" frame-options="sameorigin"></iframe>
        </html>
        ''';
    } else {
      iframe = '''
        <html>
        <video controls="controls" width="100%" height="100%">
        <source src="${widget.src!}"></video>
        </html>
        ''';
    }
  }

  checkNetwork() async {
    if (await InternetConnectivity.isNetworkAvailable()) {
      setState(() {
        _isNetworkAvail = true;
      });
    } else {
      setState(() {
        _isNetworkAvail = false;
      });
    }
  }

  @override
  void dispose() {
    // set screen back to portrait mode
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown, DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // set screen to landscape mode bydefault
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    return SafeArea(child: Scaffold(key: _scaffoldKey, body: _isNetworkAvail ? viewVideo() : const SizedBox.shrink()));
  }

  //news video link set
  viewVideo() {
    WebUri frm;
    frm = WebUri.uri(Uri.dataFromString(iframe, mimeType: 'text/html'));
    return Center(
      child: InAppWebView(initialUrlRequest: URLRequest(url: frm)),
    );
  }
}
