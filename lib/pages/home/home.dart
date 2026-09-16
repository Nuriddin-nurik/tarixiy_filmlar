import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var img1 =
      "https://www.screenhub.com.au/wp-content/uploads/sites/4/2026/07/moana-2026-film-review.jpg";
  var img2 =
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSEsruTcootpfsrQOVQsDKGZhEcHmVQDmbTQZnNu7PFQ_M8JCuolq73l6vq&s=10";
  var img3 =
      "https://www.screenhub.com.au/wp-content/uploads/sites/4/2026/07/moana-2026-film-review.jpg";

  var images = [
    "https://www.screenhub.com.au/wp-content/uploads/sites/4/2026/07/moana-2026-film-review.jpg",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSEsruTcootpfsrQOVQsDKGZhEcHmVQDmbTQZnNu7PFQ_M8JCuolq73l6vq&s=10",
    "https://www.screenhub.com.au/wp-content/uploads/sites/4/2026/07/moana-2026-film-review.jpg",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 44, 52),
      body: SizedBox.expand(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 380.h,
                    width: 1.sw,
                    child: PageView.builder(
                      itemCount: images.length,
                      itemBuilder: (context, index) => pageItem(images[index]),
                      physics: const PageScrollPhysics(),
                    ),
                  ),
                  // image
                  SizedBox(height: 8.h),

                  ///
                  Padding(
                    padding: EdgeInsets.only(left: 16.w, right: 6.w),
                    child: rowText("eldorbek", "Barchasini ko'rish"),
                  ),
                  SizedBox(height: 15.h),

                  ///
                  /// davom eting widget
                  SizedBox(
                    height: 150.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: images.length,

                      itemBuilder: (BuildContext context, int index) {
                        return Row(
                          children: [
                            Column(
                              children: [
                                appContainer(
                                  height: 80.h,
                                  width: 180.w,
                                  child: Image.network(
                                    images[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                appText("Adolat yo'lida", fontSize: 13),
                                appText(
                                  "Usmonli • 1-mavsum, 48-qism",
                                  fontSize: 11,
                                  color: Color.fromRGBO(156, 163, 175, 1),
                                ),
                              ],
                            ),
                            index != images.length - 1
                                ? SizedBox(width: 10.w)
                                : SizedBox.shrink(),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Appbar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset("assets/logo.png", height: 48.h, width: 120.w),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.search, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.notifications, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget appText(
    String text, {
    double fontSize = 15,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.w500,
    TextAlign textAlign = TextAlign.start,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        color: color,
        fontSize: fontSize.sp,
        fontWeight: fontWeight,
      ),
    );
  }

  Widget appContainer({
    required Widget child,
    double width = 180,
    double height = 143,
    double radius = 15,
    Color color = Colors.white,
    EdgeInsetsGeometry margin = EdgeInsets.zero,
  }) {
    return Container(
      width: width.w,
      height: height.h,
      margin: margin,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius.r),
      ),
      child: child,
    );
  }

  Widget rowText(String text1, String text2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        appText(text1, color: Colors.white),

        TextButton(
          onPressed: () {},
          style: ButtonStyle(
            overlayColor: WidgetStateProperty.all(
              Colors.white.withValues(alpha: .1),
            ),
          ),
          child: Row(
            children: [
              appText(text2, color: Colors.yellow),
              SizedBox(width: 5.w),
              Icon(Icons.arrow_forward_ios, color: Colors.yellow, size: 12.sp),
            ],
          ),
        ),
      ],
    );
  }

  Widget pageItem(String images) {
    return Container(
      height: 380.h,
      width: 1.sw,
      color: Colors.blue,
      child: Stack(
        children: [
          Image.network(images, height: 380.h, width: 1.sw, fit: BoxFit.cover),

          Container(
            height: 380.h,
            width: 1.sw,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
