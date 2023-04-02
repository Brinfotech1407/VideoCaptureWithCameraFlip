import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'audio_utils.dart';

class AudioSelectors extends StatefulWidget {
  const AudioSelectors({Key? key}) : super(key: key);

  @override
  _AudioSelectorsState createState() => _AudioSelectorsState();
}

class _AudioSelectorsState extends State<AudioSelectors> with WidgetsBindingObserver {

  Map<String, bool> arrCheckedMap = <String, bool>{};
  bool isAudioPlay = false;
  final CarouselController _controller = CarouselController();

  final assetsAudioPlayer = AssetsAudioPlayer();
  int _currentTrackIndex = 0;

  void playAudio(int index) {
    assetsAudioPlayer.playlistPlayAtIndex(index);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    assetsAudioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      height: 60,
      child: CarouselSlider.builder(
        carouselController: _controller,
        itemCount: AudioUtils().musicTracks.length,
        itemBuilder: (BuildContext context, int index, int realIndex) {
          return GestureDetector(
            onTap: () {
              setState(() {
                isAudioPlay = true;
              });
              playAudio(index);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: _currentTrackIndex == index
                    ? Colors.white
                    : Colors.white30,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 23,
                      height: 23,
                      margin: const EdgeInsets.only(left: 2, right: 2),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                                AudioUtils().musicImage[index]),
                            fit: BoxFit.cover),
                        borderRadius: const BorderRadius.all(
                            Radius.elliptical(25, 25)),
                      )),
                  SizedBox(
                    width: 70,
                    child: Text(
                      AudioUtils().musicTracksNames[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                        color: _currentTrackIndex == index
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        options: CarouselOptions(
          height: 40,
          viewportFraction: 0.3,
          initialPage: _currentTrackIndex,
          enableInfiniteScroll: false,
          onScrolled: (value) {},
          onPageChanged: (index, reason) {
            _onItemChanged(index);
          },
        ),
      ),
    );
  }

  void _onItemChanged(int index) {
    setState(() {
      _currentTrackIndex = index;
    });
    playAudio(index);
  }

}

