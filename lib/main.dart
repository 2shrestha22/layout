import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DashboardPage(),
  ));
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<String> items = List.generate(0, (index) => 'Nothing here');
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                _insert();
              },
              icon: const Icon(Icons.add)),
          IconButton(
              onPressed: () {
                if (items.isEmpty) return;
                _listKey.currentState?.removeItem(
                  items.length - 1,
                  (context, animation) {
                    final item = items.elementAt(items.length - 1);
                    return SlideTransition(
                      position: animation.drive(
                        // Tween(begin: Offset.zero, end: const Offset(1, 0)),
                        Tween(
                            begin: const Offset(1, 0), end: const Offset(0, 0)),
                      ),
                      child: Center(child: ItemWidget(item: item)),
                    );
                  },
                  duration: Durations.extralong4,
                );
                SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                  items.removeAt(items.length - 1);
                });
              },
              icon: const Icon(Icons.remove)),
          IconButton(
            onPressed: () {
              timer =
                  Timer.periodic(const Duration(milliseconds: 500), (timer) {
                _insert();
              });
            },
            icon: const Icon(Icons.loop),
          ),
          IconButton(
            onPressed: () {
              timer?.cancel();
            },
            icon: const Icon(Icons.stop),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.bottomRight,
        child: SizedBox(
          width: 400,
          child: AnimatedList(
            reverse: true,
            key: _listKey,
            initialItemCount: items.length,
            itemBuilder: (context, index, animation) {
              final item = items[index];
              return Align(
                alignment: Alignment.bottomRight,
                child: ItemBuilder(
                  item: item,
                  animation: animation,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _insert() {
    setState(() {
      items.add('Something went wrong.');
      _listKey.currentState?.insertItem(0, duration: Durations.long1);
    });
  }
}

class ItemBuilder extends StatelessWidget {
  const ItemBuilder({
    super.key,
    required this.item,
    required this.animation,
  });

  final String item;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    // return AnimatedBuilder(
    //   animation: animation,
    //   builder: (context, child) {},
    // );

    return SizeTransition(
      sizeFactor: animation.drive(CurveTween(curve: const Interval(0, 0.6))),
      axisAlignment: -1,
      child: SlideTransition(
        position: animation.drive(
          //  Tween(begin: const Offset(1, 0), end: Offset.zero)
          //       .chain(CurveTween(curve: const Interval(0.5, 1))),
          Tween(begin: const Offset(1, 0), end: Offset.zero).chain(CurveTween(
              curve: const Interval(
            0,
            1,
            curve: Curves.easeOutBack,
          ))),
        ),
        child: ItemWidget(item: item),
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  const ItemWidget({
    super.key,
    required this.item,
  });

  final String item;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        height: 60,
        width: 300,
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            color: Colors.red,
            child: Center(
              child: Text(
                item,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
