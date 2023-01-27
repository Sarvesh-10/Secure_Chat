import 'package:chat_app/Screens/signin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreens extends StatefulWidget {
  const OnboardingScreens({Key? key}) : super(key: key);

  @override
  State<OnboardingScreens> createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens> {
  bool isLastPage = false;
  Image i1 = Image.asset(
    'assets/Images/7495.jpg',
    fit: BoxFit.cover,
  );

  Image i2 = Image.asset(
    'assets/Images/2811113.jpg',
    fit: BoxFit.cover,
  );
  Image i3 = Image.asset(
    'assets/Images/3394897.jpg',
    fit: BoxFit.cover,
  );
  @override
  void didChangeDependencies() {
    precacheImage(i1.image, context);
    precacheImage(i2.image, context);
    precacheImage(i3.image, context);
    super.didChangeDependencies();
  }

  final _controller = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(bottom: 100),
        child: PageView(
          onPageChanged: (index) {
            setState(() {
              isLastPage = index == 2;
            });
          },
          controller: _controller,
          children: [
            Page(
              color: Colors.blue.shade600,
              urlImage: i1,
              title: 'TITLE1',
              subTitle: 'lorem ipsum dolor sit amet asdfmdf sdfklas sadfsdf',
            ),
            Page(
              color: Colors.blue.shade600,
              urlImage: i2,
              title: 'TITLE1',
              subTitle: 'lorem ipsum dolor sit amet asdfmdf sdfklas sadfsdf',
            ),
            Page(
              color: Colors.blue.shade600,
              urlImage: i3,
              title: 'TITLE1',
              subTitle: 'lorem ipsum dolor sit amet asdfmdf sdfklas sadfsdf',
            ),
          ],
        ),
      ),
      bottomSheet: isLastPage
          ? TextButton(
              onPressed: ()  async{
                final prefs = await SharedPreferences.getInstance();
                prefs.setBool('showsignin', true);
                Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (context) {
                  return SignIn();
                }));
              },
              child: Text(
                "Get Started",
                style: TextStyle(color: Colors.white,fontSize: 20),
              ),
              style: TextButton.styleFrom(
                  backgroundColor: Colors.blue.shade300,
                  minimumSize: Size.fromHeight(60)),
            )
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: 100,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: () {
                          _controller.jumpToPage(2);
                        },
                        child: Text("Skip")),
                    Center(
                      child: SmoothPageIndicator(
                        onDotClicked: (index) {
                          _controller.animateToPage(index,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeInOut);
                        },
                        controller: _controller,
                        count: 3,
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          _controller.nextPage(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeIn);
                        },
                        child: Text("NEXT")),
                  ]),
            ),
    );
  }
}

class Page extends StatelessWidget {
  Page(
      {required Color this.color,
      required Image this.urlImage,
      required String this.title,
      required String this.subTitle});

  final color;
  final Image urlImage;
  final title;
  final subTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        urlImage,
        SizedBox(
          height: 60,
        ),
        Text(title,
            style: TextStyle(
                color: Colors.blue.shade100,
                fontSize: 32,
                fontWeight: FontWeight.bold)),
        SizedBox(
          height: 60,
        ),
        Text(subTitle),
      ],
    ));
  }
}
