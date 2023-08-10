// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget sectionShimmer(BuildContext context) {
  return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.6),
      highlightColor: Colors.grey,
      child: ListView(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), padding: const EdgeInsetsDirectional.only(top: 10), children: [
        Container(
          height: 55,
          width: double.maxFinite,
          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.6), borderRadius: BorderRadius.circular(10)),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.36,
          margin: EdgeInsetsDirectional.only(top: MediaQuery.of(context).size.height * 0.018),
          child: Stack(children: [
            Container(
              height: MediaQuery.of(context).size.height / 4,
              width: double.maxFinite,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey.withOpacity(0.6)),
            ),
            Positioned.directional(
                textDirection: Directionality.of(context),
                start: 8,
                end: 8,
                top: MediaQuery.of(context).size.height / 7,
                child: Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height / 5,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsetsDirectional.all(10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.grey.withOpacity(0.6)),
                )),
          ]),
        ),
        Container(
          height: 55,
          margin: const EdgeInsets.only(top: 13),
          width: double.maxFinite,
          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.6), borderRadius: BorderRadius.circular(10)),
        ),
        ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height / 3.3,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(top: 15),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.grey.withOpacity(0.6)),
              );
            }),
        Container(
          height: 55,
          margin: const EdgeInsets.only(top: 13),
          width: double.maxFinite,
          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.6), borderRadius: BorderRadius.circular(10)),
        ),
        Container(
          margin: const EdgeInsets.only(top: 15),
          height: MediaQuery.of(context).size.height * 0.34,
          width: double.maxFinite,
          child: Stack(
            children: [
              Positioned.directional(
                  textDirection: Directionality.of(context),
                  start: 0,
                  end: 0,
                  top: MediaQuery.of(context).size.height / 15,
                  child: Container(
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height / 4,
                    margin: const EdgeInsetsDirectional.only(top: 10, bottom: 10),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.grey.withOpacity(0.6)),
                    padding: const EdgeInsets.all(14),
                  )),
              Positioned.directional(
                  textDirection: Directionality.of(context),
                  start: 30,
                  end: 30,
                  child: Container(
                    height: MediaQuery.of(context).size.height / 4.7,
                    width: double.maxFinite,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.grey.withOpacity(0.6)),
                  ))
            ],
          ),
        ),
        Container(
          height: 55,
          margin: const EdgeInsets.only(top: 10),
          width: double.maxFinite,
          decoration: BoxDecoration(color: Colors.grey.withOpacity(0.6), borderRadius: BorderRadius.circular(10)),
        ),
        GridView.builder(
            padding: const EdgeInsets.only(top: 13),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(mainAxisExtent: MediaQuery.of(context).size.height * 0.28, crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 13),
            shrinkWrap: true,
            itemCount: 6,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey.withOpacity(0.6)));
            })
      ]));
}
