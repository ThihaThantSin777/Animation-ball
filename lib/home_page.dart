import 'dart:io';

import 'package:animated_ball/color_list_vo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> animation;
  double _sizeValue = 10;
  int _speedValue = 3000;
  bool _isPlay = false;
  int _hitRate = 0;
  int _missRate = 0;
  double _begin = 250.0;
  double _end = -250.0;
  ColorListVO _tempColorListVO = ColorListVO(Colors.redAccent, true, 'Red');

  List<ColorListVO> _colorsList = [
    ColorListVO(Colors.redAccent, true, 'Red'),
    ColorListVO(Colors.blueAccent, false, 'Blue'),
    ColorListVO(Colors.lightBlueAccent, false, 'Light Blue'),
    ColorListVO(Colors.yellowAccent, false, 'Yellow'),
    ColorListVO(Colors.purpleAccent, false, 'Purple'),
    ColorListVO(Colors.orangeAccent, false, 'Orange'),
    ColorListVO(Colors.cyanAccent, false, 'Cyan'),
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        duration: Duration(milliseconds: _speedValue), vsync: this)
      ..addListener(() => setState(() {}));
    animation = Tween(begin: _begin, end: _end).animate(_controller);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void tryAgain(context) => setState(() {
        _sizeValue = 10;
        _speedValue = 3000;
        _isPlay = false;
        _hitRate = 0;
        _missRate = 0;
        _begin = 250.0;
        _end = 250.0;
        _tempColorListVO = ColorListVO(Colors.redAccent, true, 'Red');
        Navigator.of(context).pop();
      });

  void sliderMethod(double value) => setState(() => _sizeValue = value);

  void speedMethod(double value) => setState(() {
        _speedValue = value.toInt();
        _controller.duration = Duration(milliseconds: _speedValue.toInt());
      });

  String getMissOrHitText(int value) {
    if (value <= 1) {
      return '$value time';
    }
    return '$value times';
  }

  void changeColorMethod(ColorListVO colorListVO) => setState(() {
        _tempColorListVO = colorListVO;
        _colorsList = _colorsList.map((data) {
          if (data.name == colorListVO.name) {
            data.isSelect = true;
          } else {
            data.isSelect = false;
          }
          return data;
        }).toList();
      });

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Result',
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Hit Rate',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(getMissOrHitText(_hitRate))
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Miss Rate',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(getMissOrHitText(_missRate))
                ],
              )
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Try Again'),
              onPressed: () => tryAgain(context),
            ),
            TextButton(
              child: const Text('Quit'),
              onPressed: () {
                if (Platform.isIOS) {
                  exit(0);
                } else {
                  SystemNavigator.pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _isPlay = false;
          _controller.stop(canceled: true);
          _showMyDialog();
        },
        child: const Icon(Icons.stop),
      ),
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  _isPlay = !_isPlay;
                  if (_isPlay) {
                    _controller.forward();
                    _controller.repeat(reverse: true);
                  } else {
                    _controller.stop(canceled: false);
                  }
                });
              },
              icon: _isPlay
                  ? const Icon(Icons.pause)
                  : const Icon(Icons.play_arrow))
        ],
        title: const Text('Animated Ball'),
      ),
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleAndSliderView(
                sliderValue: _sizeValue,
                max: 30,
                min: 10,
                title: 'Size',
                onChange: (value) => sliderMethod(value),
              ),
              TitleAndSliderView(
                sliderValue: _speedValue.toDouble(),
                max: 3000,
                min: 100,
                title: 'Speed(millisecond)',
                onChange: (value) => speedMethod(value),
              ),
              ColorView(
                colorsList: _colorsList,
                onTap: (colorListVO) => changeColorMethod(colorListVO),
              ),
              InkWell(
                splashColor: Colors.red,
                onTap: () => _missRate++,
                child: SizedBox(
                  height: 550,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(0.0, animation.value),
                      child: AnimatedBallView(
                          onTap: () => _hitRate++,
                          sizeValue: _sizeValue,
                          tempColorListVO: _tempColorListVO),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedBallView extends StatelessWidget {
  const AnimatedBallView(
      {Key? key,
      required double sizeValue,
      required ColorListVO tempColorListVO,
      required this.onTap})
      : _sizeValue = sizeValue,
        _tempColorListVO = tempColorListVO,
        super(key: key);

  final double _sizeValue;
  final ColorListVO _tempColorListVO;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          splashColor: Colors.green,
          onTap: () => onTap(),
          child: CircleAvatar(
            radius: _sizeValue,
            backgroundColor: _tempColorListVO.color,
          ),
        ),
      ],
    );
  }
}

class ColorView extends StatelessWidget {
  const ColorView({
    Key? key,
    required List<ColorListVO> colorsList,
    required this.onTap,
  })  : _colorsList = colorsList,
        super(key: key);

  final List<ColorListVO> _colorsList;
  final Function(ColorListVO) onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Color',
            style: TextStyle(
              fontSize: 24,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: _colorsList.map((data) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () {
                    onTap(data);
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: data.color,
                    child: data.isSelect ? const Icon(Icons.check) : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class TitleAndSliderView extends StatelessWidget {
  const TitleAndSliderView({
    Key? key,
    required this.sliderValue,
    required this.max,
    required this.min,
    required this.title,
    required this.onChange,
  }) : super(key: key);
  final double sliderValue;
  final double min;
  final double max;
  final String title;
  final Function(double) onChange;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 24,
          ),
        ),
      ),
      SizedBox(
        width: 400,
        child: Slider(
            activeColor: Colors.blueAccent,
            inactiveColor: Colors.grey,
            min: min,
            max: max,
            divisions: 5,
            label: sliderValue.round().toString(),
            value: sliderValue,
            onChanged: (value) {
              onChange(value);
            }),
      ),
    ]);
  }
}
