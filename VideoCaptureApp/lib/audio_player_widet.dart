import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:marquee/marquee.dart';

import 'audio_utils.dart';

class AudioSelectors extends StatefulWidget {
  bool isRecodingStart;
  Function(bool) isAudioPreview;
  AudioPlayer player;
  Function(int) currentIndex;

  AudioSelectors({
    super.key,
    required this.isRecodingStart,
    required this.isAudioPreview,
    required this.currentIndex,
    required this.player,
  });

  @override
  _AudioSelectorsState createState() => _AudioSelectorsState();
}

class _AudioSelectorsState extends State<AudioSelectors>
    with WidgetsBindingObserver {
  Map<String, bool> arrCheckedMap = <String, bool>{};
  bool isAudioPlay = false;
  final CarouselController _controller = CarouselController();

  //late AudioPlayer player;
  int _currentTrackIndex = -1;

  void playAudio(int index) {
    if (widget.player.playing) {
      widget.isAudioPreview(false);
      widget.player.stop();
    }
    if (widget.isRecodingStart == false) {
      widget.isAudioPreview(false);
      widget.player.stop();
    }

      widget.player.play();
      widget.isAudioPreview(true);
      widget. player.setAsset(AudioUtils().musicTracks[index]);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
   //   _currentTrackIndex = 0;
    } else if (state == AppLifecycleState.resumed) {
    }
  }



  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          color: Colors.transparent,
          height: 60,
          child: CarouselSlider.builder(
            carouselController: _controller,
            itemCount: AudioUtils().musicTracks.length,
            itemBuilder: (BuildContext context, int index, int realIndex) {
              return GestureDetector(
                onTap: () {
                  if (!widget.isRecodingStart &&
                      _currentTrackIndex == index &&
                      widget.player.playing) {
                    _currentTrackIndex = -1;
                    widget.isAudioPreview(false);
                    widget.player.stop();
                    if (mounted) {
                      setState(() {});
                    }
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: _currentTrackIndex == index && widget.player.playing
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
                                image:
                                    AssetImage(AudioUtils().musicImage[index]),
                                fit: BoxFit.cover),
                            borderRadius: const BorderRadius.all(
                                Radius.elliptical(25, 25)),
                          )),
                      if (widget.player.playing && _currentTrackIndex == index) ...[
                        SizedBox(
                          width: 70,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5.0, left: 2,right: 2),
                            child: Marquee(
                              velocity: 25,
                              text: AudioUtils().musicTracksNames[index],
                              style: buildMusicNameStyle(index),
                              scrollAxis: Axis.horizontal,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              accelerationCurve: Curves.linear,
                              blankSpace:20,
                              decelerationCurve: Curves.easeInOut,
                            ),
                          ),
                        )
                      ] else ...[
                        SizedBox(
                          width: 70,
                          child: Text(
                            AudioUtils().musicTracksNames[index],
                            style: buildMusicNameStyle(index),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: 40,
              viewportFraction: 0.3,
              enableInfiniteScroll: false,
              onScrolled: (value) {},
              onPageChanged: !widget.isRecodingStart
                  ? (index, reason) {
                      _onItemChanged(index);
                    }
                  : null,
              autoPlay: false,
            ),
          ),
        ),
      ],
    );
  }

  TextStyle buildMusicNameStyle(int index) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.ellipsis,
      color: _currentTrackIndex == index  && widget.player.playing ? Colors.black : Colors.white,
    );
  }

  void _onItemChanged(int index) {
    setState(() {
      _currentTrackIndex = index;
      widget.currentIndex(_currentTrackIndex);
    });

    playAudio(index);
  }
}
