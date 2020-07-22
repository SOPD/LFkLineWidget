import 'dart:async';
import 'package:flutter/material.dart';
import 'kLinePrintController.dart';
import 'kLineColorConfig.dart';
import 'kLineTypeSwitchWidget.dart';
import 'kLineModel.dart';
import 'printCore.dart';
import 'kLineDataManager.dart';
import 'kLineParmSetWidget.dart';
class KLineWidget extends StatefulWidget{
    final Rect drawRect ;

    final KLineDataManager dataManager;

    final KLineColorConfig colorConfig;
    final VoidCallback onLeftScrollEnd;
    final VoidCallback onRightScrollEnd;

    @override
    KLineWidget({Key key,this.drawRect,this.dataManager,this.colorConfig,this.onLeftScrollEnd,this.onRightScrollEnd});

    @override
     State<StatefulWidget> createState() {

        return _KLineWidgetState();
  }

}


class _KLineWidgetState extends State<KLineWidget>{

  ScrollController controller = new ScrollController(keepScrollOffset: true,initialScrollOffset: 0,);
 
  int rightIndex;
  int count;
  int moveTemp;
  double dxCount = 0;
  bool isScrollAtEndLeft = false;
  bool isScrollAtEndRight = false;
  Timer bounceCounter;
  int leftCount = 0;
  int readedCount = 2;
  int actionCount = 0;
  bool directionLeft = true;
  bool isShowCross = false;
  Offset currentPressLocation = Offset(0, 0);

  final KlinePrintController controlTabManager = KlinePrintController();

@override 
void dispose(){
  bounceCounter.cancel();
  super.dispose();
}

  @override
  void initState() {
    widget.dataManager.onAppendData = (dataLength){
      rightIndex += dataLength;

    };
    widget.dataManager.onResetData = (){
      setDefaultShowParm();
      };
     controlTabManager.groups.clear();
     controlTabManager.mainGroup = KlineGroup(ratio: 1,components: defaultGroupMap[quotaTypeMA],name: quotaTypeMA,edgeSpace: 10);

    setDefaultShowParm();

   widget.dataManager.caculateDataList();

    super.initState();
  }
 
  @override
  Widget build(BuildContext context) {
     Rect printRect = Rect.fromLTRB(10, widget.drawRect.top, widget.drawRect.right - 10, widget.drawRect.bottom);
      double unitWidth = printRect.width;
     if(widget.dataManager.dataList.length > 0){

      unitWidth = printRect.width / widget.dataManager.dataList.length;
     }

    return Flex(
      direction: Axis.vertical,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Listener(
          child: GestureDetector(
            child:  Container(
              height: widget.drawRect.height == null?200:widget.drawRect.height + 20,
              width: MediaQuery.of(context).size.width,
              child:CustomPaint(painter: KLinePainter(drawRect:printRect,
                                                       dataList:this.showList(count, rightIndex, widget.dataManager.dataList),
                                                       isShowCross:this.isShowCross,
                                                       crossLocation:this.currentPressLocation,
                                                       manager: widget.dataManager.parmManager,
                                                       startIndex: rightIndex - count,
              colorConfig:widget.colorConfig,
              controller: widget.dataManager.printController

              )),
            ),
            onScaleUpdate: onScaleUpdate,
            onScaleStart: onScaleStart,
            onHorizontalDragEnd: onHorizontaDragEnd,
            onTapDown: onTapDown,
            onLongPress: onLongPress,
            onLongPressEnd: onLongPressEnd,
          
          ),
          onPointerMove: onTouchsMove,
        ),
        Stack(children: <Widget>[
          Container(
            height:100,
            width: MediaQuery.of(context).size.width,
            child:CustomPaint(painter: KLinePainter(drawRect:Rect.fromLTRB(10, 5, widget.drawRect.right - 10, 80),
                dataList:widget.dataManager.dataList,
                isShowCross:false,
              //  crossLocation:this.currentPressLocation,
                manager: widget.dataManager.parmManager,
                startIndex: 0,
                colorConfig:widget.colorConfig,
                controller: controlTabManager

            )),
          ),
         Positioned(
           child:  Container(
             height: 80,
             width:unitWidth * (count - 1),
             color: Color.fromRGBO(0, 0, 255, 100),
           ),
           left:unitWidth * 0.5 + 10 + (rightIndex - count) * unitWidth,
           top: 5,
         )
        ],

        )
        ,
        KlineTypeSwitchWidget(
           printController: widget.dataManager.printController,
            colorConfig: widget.colorConfig,
            callback: (String quote){
              widget.dataManager.caculateDataList();
              setState(() {
              });
           },
       ),
       KlineParmSetWidget(
         manager: widget.dataManager.parmManager,
         colorConfig: widget.colorConfig,
         callBack: (){},
       )
      ],
    ); 
  }
  void onTapDown(TapDownDetails details){
    if (bounceCounter != null && bounceCounter.isActive) {
       bounceCounter.cancel();
       readedCount = 2;
    }
   currentPressLocation = details.localPosition;
    leftCount = 0;
  }
  
  void onScaleStart(ScaleStartDetails details){
     moveTemp = count;
  }
  
  void onScaleUpdate(ScaleUpdateDetails details){
   scaleTo(details.horizontalScale.toDouble(), moveTemp);

   setState(() {

   });
  }
  
  void onTouchsMove(PointerMoveEvent event){
   if (bounceCounter != null && bounceCounter.isActive) {
       bounceCounter.cancel();
       readedCount = 2;
    }
    if (isShowCross) {
      
    currentPressLocation = event.localPosition;
    setState(() {
      
    });
      return;
    }
    dxCount = dxCount + event.delta.dx;
    if(dxCount.abs() > widget.drawRect.width / count){

      if(event.delta.dx > 0){
        moveLeft();

        }
       if(event.delta.dx < 0 ){
        moveRight();

        }
       setState(() {

         });
    dxCount = 0;
    }
  }
  
  void onHorizontaDragEnd(DragEndDetails event){

   directionLeft  = event.velocity.pixelsPerSecond.dx >1?true:false;
 
   int result = (event.velocity.pixelsPerSecond.dx ~/ 100).toInt().abs();


   if (result > 10) {
    if (directionLeft && isScrollAtEndLeft) {
    
     widget.onLeftScrollEnd();

   }else if((!directionLeft) && isScrollAtEndRight){
 
     widget.onRightScrollEnd();
   }
   }
   if(result  > 30){
     result = 30;
   }
   //print(result.toString());
   leftCount = result;


   if (bounceCounter != null && bounceCounter.isActive) {
       bounceCounter.cancel();
       readedCount = 2;
    }
   bounceCounter =  Timer.periodic(const Duration(milliseconds: 5), (Timer timer){
    if(leftCount > 0){
     if(actionCount > readedCount){
       if(directionLeft){
         moveLeft();
       }else{
         moveRight();
       }
       setState(() {
       });
    
       leftCount--;
       readedCount = readedCount + 1;
       actionCount = 0;
       
     //  print('ACTON'+ DateTime.now().millisecondsSinceEpoch.toString());

     }else{
          actionCount++;
     }
   }else{
    readedCount = 2;
    bounceCounter.cancel();
   }
 });

 }
  
  void onLongPress(){
   isShowCross = true;
    setState(() {
     
   });
   }
  
  void onLongPressEnd(LongPressEndDetails details){
   isShowCross = false;
   setState(() {
     
   });
   }

  List<KLineModel> showList(int count,int rightIndex,List source){

    if(count == 0 || rightIndex == 0 || source == []) return[];

    int start = rightIndex - count;

    if(start < 0)start = 0;

    return source.sublist(start,rightIndex);
  }

  void setDefaultShowParm(){
   if(widget.dataManager.dataList.length > 0){
     rightIndex = widget.dataManager.dataList.length;
   }else{
     rightIndex = 0;
   }
   count = 30;
print('setdefault show ');
}
  
  void moveLeft(){
      isScrollAtEndRight = false;
    if(rightIndex >  count ){
    rightIndex--;
     isScrollAtEndLeft = false;
    }else{
      isScrollAtEndLeft = true;
    }
  }
  
  void moveRight(){
      isScrollAtEndLeft = false;
    if(rightIndex < widget.dataManager.dataList.length){
      rightIndex++;
      isScrollAtEndRight = false;
    }else{
    isScrollAtEndRight = true;
    }
  }
  
  void scaleTo(double scale,int currentCount) {

    if(widget.dataManager.dataList.length < 5){
      return;
    }

    if (scale < 1 && scale > 0.1) count = currentCount + (4 * (1 / scale)).toInt();
    if (scale > 1 && scale < 10) count = currentCount - (scale * 5).toInt();

    if (count > widget.dataManager.dataList.length) {
      count = widget.dataManager.dataList.length;
    }

    if (rightIndex - count < 0 && count < widget.dataManager.dataList.length) {
      rightIndex = count;
    }

    if(count < 5 ){
      count = 5;
    }
  }
  

}
