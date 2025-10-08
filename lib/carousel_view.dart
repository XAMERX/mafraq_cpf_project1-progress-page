import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselViewS extends StatelessWidget {
  const CarouselViewS({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> imgList = [
      'https://picsum.photos/id/237/800/400',
      'https://picsum.photos/id/238/800/400',
      'https://picsum.photos/id/239/800/400',
      'https://picsum.photos/id/240/800/400',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Carousel Slider Example")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            CarouselSlider(
              options: CarouselOptions(
                height: 250,
                enlargeCenterPage: true,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                aspectRatio: 16 / 9,
                viewportFraction: 0.8,
              ),
              items: imgList.map((item) {
                return Builder(
                  builder: (BuildContext context) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 23),
          ],
        ),
      ),
    );
  }
}
