import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
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
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS3oER-iLAjHKaUv8KKZy39vnLoPamIjw7nc8QK6OBfIQ&s=10",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTcIRMU6Kg_ouzdyp8C44ljzcxDeHvbPBDsDquSUX6BJA&s=10",

    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSkEkXRjFD01NefNeh4PJcUhiFfPaSXOptveZ4Bn9Jx8A_ICRsL6KTf8XI&s=10",

    "https://disney.images.edge.bamgrid.com/ripcut-delivery/v2/variant/disney/019d224e-e281-7e6e-b13d-32cc07dc4a69/compose?format=webp&width=467",

    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmqsg6O0B8M9pNxPFv-peuY_lgNFt_bElpMJxj24eveA&s=10",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRivzz74Cxiltke0mIra4IM4Jp-HkrmAomGW5TS3x-BC5i1wqPiM_25x7k&s=10",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ02S4p7cL3EQKZcMqLFMMxJgTmoMzJoI8y2V8uITcKXJ5bTI6tLSR6VR8&s=10",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRe9LsuduYgDZDhzbOTPCxAuzEbyJrhnKdim_7-dLraVi17u27FykB55oc&s=10",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0b0d0e),
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
                    child: rowText(
                      "Ko‘rishni davom etish",
                      "Barchasini ko'rish",
                    ),
                  ),
                  SizedBox(height: 15.h),

                  ///
                  /// davom eting widget
                  SizedBox(
                    height: 143.h,

                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: images.length,

                      itemBuilder: (BuildContext context, int index) {
                        /// height width qo'shish kerak
                        return itemBuilder(
                          images[index],
                          "title",
                          "dis",
                          index,
                        );
                      },
                    ),
                  ),

                  // TARIXIY janglar
                  SizedBox(height: 28.h),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16.w,
                      right: 6.w,
                      bottom: 4.h,
                    ),
                    child: rowText("Tarixiy janglar", "Barchasini ko'rish"),
                  ),
                  appContainer(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),

                    child: appText(
                      "Shiddatli janglar va qahramonlik dostonlari",
                      color: Color(0xff9CA3AF),
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
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

  Widget itemBuilder(String image, String title, String dis, int index) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: appContainer(
                height: 102,
                width: 180,
                child: Stack(
                  alignment: Alignment(0, 0),
                  children: [
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            color: Colors.yellow,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: appContainer(
                        height: 3,
                        width: 180,
                        color: Colors.white.withValues(alpha: .2),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: appContainer(
                        height: 3,
                        width: 180,

                        gradient: LinearGradient(
                          colors: [Color(0xffD4AF37), Colors.transparent],
                          stops: [Random().nextDouble(), 0.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 2),
              child: appText(
                title,
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            appText(
              dis,
              fontSize: 11,
              color: Color.fromRGBO(156, 163, 175, 1),
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
        index != images.length - 1 ? SizedBox(width: 10.w) : SizedBox.shrink(),
      ],
    );
  }

  Widget appText(
    String text, {
    double? fontSize,
    Color? color,
    FontWeight fontWeight = FontWeight.w500,
    TextAlign textAlign = TextAlign.start,
  }) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        color: color,
        fontSize: fontSize?.sp,
        fontWeight: fontWeight,
      ),
    );
  }

  Widget appContainer({
    Widget? child,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    double? radius,
    AlignmentGeometry? alignment,
    Gradient? gradient,
    Color? color,
    EdgeInsetsGeometry margin = EdgeInsets.zero,
  }) {
    return Container(
      width: width?.w,
      alignment: alignment,
      height: height?.h,
      margin: margin,
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color,

        borderRadius: BorderRadius.circular(radius?.r ?? 0),
        gradient: gradient,
      ),
      child: child,
    );
  }

  Widget rowText(String text1, String text2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        appText(text1, color: Colors.white),

        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                children: [
                  appText(text2, color: Colors.yellow),
                  SizedBox(width: 5.w),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.yellow,
                    size: 12.sp,
                  ),
                ],
              ),
            ),
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
          CachedNetworkImage(
            imageUrl: images,
            height: 380.h,
            width: 1.sw,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
                Center(child: CircularProgressIndicator(color: Colors.yellow)),
          ),

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
