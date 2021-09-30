
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
const _cardHeaderSize=250.0;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: MyBankPage(),
    );
  }
}
class _MyHeader{
  const _MyHeader(this.visible,this.title);
  final String title;
  final bool visible;
}
class MyBankPage extends StatefulWidget {

  @override
  _MyBankPageState createState() => _MyBankPageState();
}

class _MyBankPageState extends State<MyBankPage> {
  final headerNotifier=ValueNotifier<_MyHeader?>(null);
  final scrollNotifier= ValueNotifier(0.0);
  final scrollController= ScrollController();


  void _refreshHeader(String title,bool visible,{String? lastOne}){

    final headerValue=headerNotifier.value;
    final headerTitle=headerValue?.title??title;
    final headerVisible= headerValue?.visible??false;


    if(
    scrollController.offset > 0 &&
        ( headerTitle!=title || lastOne!=null || headerVisible != visible)){

     Future.microtask(() => {
     if(!visible && lastOne != null){
         headerNotifier.value=_MyHeader(true,lastOne)
    }
    else{
      headerNotifier.value=_MyHeader(visible, title)
    }
     });
    }
  }
  void _onListen(){
    scrollNotifier.value = scrollController.offset;
  }
  @override
  void initState(){
    scrollController.addListener(_onListen);
    super.initState();
  }
  @override
  void dispose(){
    scrollController.removeListener(_onListen);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              controller: scrollController,
              slivers: [
                ValueListenableBuilder<double>(valueListenable: scrollNotifier,

                  builder: (context, snapshot, _) {
                  print(snapshot);
                  final space=_cardHeaderSize - kToolbarHeight;
                  final percent= lerpDouble(0.0, -pi/2, (snapshot/space).clamp(0.0, 1.0))!;
                  final opacity= lerpDouble(1.0, 0.0, (snapshot/space).clamp(0.0, 1.0))!;
                    return SliverAppBar(
                      centerTitle: false,
                      automaticallyImplyLeading: false,
                      backgroundColor: Colors.transparent,
                      title: Text("\$26,710",style: TextStyle(fontWeight: FontWeight.w300,fontSize: 24),
                      ),
                      expandedHeight: _cardHeaderSize,
                      stretch: true,
                      flexibleSpace: FlexibleSpaceBar(
                        stretchModes: [StretchMode.blurBackground],
                        background: Padding(
                          padding: EdgeInsets.only(
                            top: kToolbarHeight
                          ),
                          child: Center(
                            child: Opacity(
                              opacity: opacity,
                              child: Transform(
                                transform: Matrix4.identity()..setEntry(3,2,0.003)..rotateX(percent),
                                alignment: Alignment.center,
                                child: ListView(
                                  padding: EdgeInsets.only(top: 20,left: 20),
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(1),color: Colors.red,),

                                      width: 150,
                                    ),
                                    SizedBox(width: 10,),
                                    Container(
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(1),color: Colors.blue ) ,
                                      width: 120,
                                    ),
                                    SizedBox(width: 10,),
                                    Container(
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(1),color: Colors.red,),

                                      width: 150,
                                    ),
                                    SizedBox(width: 10,),
                                    Container(
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(1),color: Colors.blue ) ,
                                      width: 120,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                ),
                ...[
                  SliverPersistentHeader(delegate: _HearderTitle("Latest Transaction",
                          (visible)=>_refreshHeader("April",visible))
                  ),
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                              (context,index){
                            return ListTile(
                              title: Text("Title: $index"),
                            );
                          },childCount: 15
                      ))
                ],
                ...[
                  SliverPersistentHeader(delegate: _HearderTitle("March 18",
                    (visible)=>_refreshHeader("March",
                        visible,
                      lastOne: 'April'
                    ))
                  ),
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                              (context,index){
                            return ListTile(
                              title: Text("Title: $index"),
                            );
                          },childCount: 15
                      ))
                ],

              ],

            ),
            ValueListenableBuilder<_MyHeader?>(valueListenable: headerNotifier,
              builder: (context, snapshot,_) {
              final visible= snapshot?.visible ?? false;
              final title= snapshot?.title ?? '';
                return Positioned(
                  left: 15,
                    top: 0,
                    right: 0,
                    child:AnimatedSwitcher(duration: Duration(milliseconds: 300),
                      layoutBuilder: (currentChild, previousChildren){
                      return Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          ...previousChildren,
                          if(currentChild != null) currentChild,
                        ],
                      );
                      },
                      transitionBuilder: (widget,animation){
                      return FadeTransition(

                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor:animation,
                          child: widget,
                        ),
                      );
                      },
                      child: visible? DecoratedBox(
                        key: Key(title),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),

                        ),
                        child: Text(title,style: TextStyle(fontWeight: FontWeight.w400,fontSize: 20,color: Colors.yellow),),
                      ) : const SizedBox.shrink(),
                    )
                );
              }
            ),

            Positioned(
              right: 10,
              top: 0,
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(Icons.compare_arrows_sharp),
              ),
            )
          ],

        ),
      ),
    );
  }
}
const MAX_HEADER_TITLE_HEIGHT=55.0;
typedef OnHeaderChanged = void Function(bool visible);

class _HearderTitle extends SliverPersistentHeaderDelegate{
  const _HearderTitle(this.title,this.onHeaderChanged);
  final OnHeaderChanged onHeaderChanged;
  final String title;
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    if(shrinkOffset>0){
      onHeaderChanged(true);
    }
    else{
      onHeaderChanged(false);
    }
   return Padding(
     padding: const EdgeInsets.only(left:15.0),
     child: Align(
       alignment: Alignment.centerLeft,
       child: Text(
         title,
         style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400),
       ),
     ),
   );
  }

  @override
  // TODO: implement maxExtent
  double get maxExtent => MAX_HEADER_TITLE_HEIGHT;

  @override
  // TODO: implement minExtent
  double get minExtent =>MAX_HEADER_TITLE_HEIGHT;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate)=>false;

}