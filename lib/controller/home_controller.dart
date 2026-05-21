import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var corouselIndex = 0.obs;
  var corouselIndexCurrent = 0.obs;
  var timer = Timer.periodic(const Duration(seconds: 5), (timer) {});

  updateFields({int? corouselindex, int? corouselindexcurrent}) {
    corouselIndex = corouselindex?.obs ?? corouselIndex;
    corouselIndexCurrent = corouselindexcurrent?.obs ?? corouselIndexCurrent;
  }

  ondispose() {
    timer.cancel();
    super.dispose();
  }

  corouselRun(PageController pageController, int maxItem) {
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      print("max = $maxItem cur =  ${pageController.page?.toInt()}");
      if (maxItem - 1 == pageController.page?.toInt()) {
        pageController.animateToPage(
          0,
          duration: Duration(seconds: 1),
          curve: Curves.linear,
        );
      } else {
        pageController.nextPage(
          duration: Duration(milliseconds: 500),
          curve: Curves.linear,
        );
      }
    });
  }
}
