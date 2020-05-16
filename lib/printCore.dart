
import 'dart:math';

import 'package:flutter/material.dart';
import 'kLineParmManager.dart';
import 'kLineModel.dart';
import 'dart:ui'as ui;
import 'kLineColorConfig.dart';
import 'kLinePrintController.dart';


class KLinePainter extends CustomPainter{

    KLineColorConfig colorConfig;
    KlineParmManager manager;
    KlinePrintController controller;
    List<KLineModel> dataList;
    double priceTop;
    double priceBottom;
    double volTop;
    double difDeaMax;
    double macdMax;
    bool isShowCross;
    Offset crossLocation;
    int drawUnitCount =30;
    int startIndex = 0;

    Paint _paint = new Paint();
    Rect drawRect;

    @override
    KLinePainter({Key key,this.drawRect,this.dataList,this.colorConfig,this.controller,this.isShowCross,this.crossLocation,this.manager,this.startIndex}){
    if (startIndex < 0) {
      startIndex = 0;
    }
    }


 @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

 @override
 void paint(Canvas canvas, Size size) {
if(dataList == null || this.drawRect == null){
  return;
}
 this.drawKline(canvas);
 }

void drawKline(Canvas canvas){

this.caculateDrawArea();

double start = 0;
double padding = 0;
double totalH = drawRect.height - ((this.controller.groups.length -1) * this.controller.padding);
double allRaito = this.controller.getAllRatio();
for (var drawGroup in this.controller.getAllGroups()) {
  
Rect rect = Rect.fromLTWH(drawRect.left , drawRect.top + totalH * start + padding, drawRect.width , totalH * (drawGroup.ratio / allRaito));
_drawKLineUnit(rect, drawGroup.components, canvas,drawGroup.edgeSpace);
start += (drawGroup.ratio / allRaito);
padding += this.controller.padding;

}
}

//设置数据
 void caculateDrawArea(){

   double doubleMax = 9999999999999;
   this.priceTop = 0;
   this.priceBottom = doubleMax;
   this.volTop = 0.0000001;
   this.macdMax = 0.0000001;
   this.difDeaMax = 0.0000001;


   this.dataList = dataList;
   for(int i = 0 ;i < dataList.length;i++){
     KLineModel model = dataList[i];

     //找到最大最小
    priceTop = max(priceTop, model.top);
    priceBottom = min(priceBottom, model.bottom);
   
    volTop = max(max(volTop,model.vol),max(model.volMa1,model.volMa2));
     
     if (model.dif.abs() > this.difDeaMax) { this.difDeaMax = model.dif.abs();}
     if (model.dea.abs() > this.difDeaMax) { this.difDeaMax = model.dea.abs();}
     if (model.macd.abs() > this.macdMax) { this.macdMax = model.macd.abs();}

     if (controller.mainGroup.name == quotaTypeMA) {
     priceTop = max(max(model.ma1, priceTop),max(model.ma2,model.ma3));
     priceBottom = min(min(model.ma1, priceBottom),min(model.ma2,model.ma3));
     }
     if (controller.mainGroup.name == quotaTypeEMA) {
     priceTop = max(max(model.ema1, priceTop),max(model.ema2,model.ema3));
      priceBottom = min(min(model.ema1, priceBottom),min(model.ema2,model.ema3));
     }
   }
   this.drawUnitCount = dataList.length;
 }

void _drawKLineUnit(Rect rect,List lineTypes,Canvas canvas,double edgeSpace){

   Rect rectInside = Rect.fromLTRB(rect.left , rect.top + edgeSpace + 10, rect.right , rect.bottom -  edgeSpace);
  //画外框
   _drawRoundRect(colorConfig.colorBorder, 0.5, canvas,rect);

      if(this.dataList == null){
        return;
      }
    
    for (var lineType in lineTypes) {
      KLineModel descModel = this.dataList.last;
      if (isShowCross) {
        int selectIndex = crossLocation.dx ~/ (rect.width/drawUnitCount) - 1;
        if (selectIndex >= 0 && selectIndex < this.dataList.length) {
          descModel = this.dataList[selectIndex];
        }
      }
      switch (lineType) {
        case lineTypeCandle:
           _drawLinkCandleLine(this.dataList, canvas, rectInside);
          break;
        case lineTypeVOL:
           _drawVol(this.dataList, canvas, rectInside);
          break;
        case lineTypeVOLMA:
           _drawVOLMA(this.dataList, canvas, rectInside);
          break;
        case lineTypeAVG:
           _drawAVG(this.dataList, canvas, rectInside);
          break;
        case lineTypeMA:
            _drawMA(this.dataList, canvas, rectInside);
          break;
        case lineTypeEMA:
           _drawEMA(this.dataList, canvas, rectInside);
          break;
        case lineTypeMACD:
           _drawMACD(this.dataList, canvas, rectInside);
          break;  
         case lineTypeRSI:
           _drawRSI(this.dataList, canvas, rectInside);
          break;

        default:
      }
  _drawDesc(descModel, lineType, rect, canvas,edgeSpace);
 
if (isShowCross) {
  _drawCross(colorConfig.colorBorder, 0.5, canvas, rectInside, crossLocation);

}
}
}

void _drawMA(List<KLineModel> dataList,Canvas canvas,Rect rect){
    List<double> ma1List = new List();
    List<double> ma2List = new List();
    List<double> ma3List = new List();
    int leftUnit1 = this.manager.getParm(parmMA1) - startIndex - 1;
    int leftUnit2 = this.manager.getParm(parmMA2) - startIndex - 1;
    int leftUnit3 = this.manager.getParm(parmMA3) - startIndex - 1;
    for(int i = 0 ; i < dataList.length; i++) {
      KLineModel model = dataList[i];
       ma1List.add(model.ma1);
       ma2List.add(model.ma2);
       ma3List.add(model.ma3);
    }
    _drawLineContect(colorConfig.colorLine1, 1, ma1List,leftUnit1>0?leftUnit1:0 , canvas, rect, priceTop,priceBottom);
    _drawLineContect(colorConfig.colorLine2, 1, ma2List,leftUnit2>0?leftUnit2:0 , canvas, rect, priceTop,priceBottom);
    _drawLineContect(colorConfig.colorLine3, 1, ma3List,leftUnit3>0?leftUnit3:0 , canvas, rect, priceTop,priceBottom);

  }

void _drawEMA(List<KLineModel> dataList,Canvas canvas,Rect rect){
    List<double> ema1List = new List();
    List<double> ema2List = new List();
    List<double> ema3List = new List();

    for(int i = 0 ; i < dataList.length; i++) {
      KLineModel model = dataList[i];
      ema1List.add(model.ema1);
      ema2List.add(model.ema2);
      ema3List.add(model.ema3);

    }
    _drawLineContect(colorConfig.colorLine1, 1, ema1List,0 , canvas, rect, priceTop,priceBottom);
    _drawLineContect(colorConfig.colorLine2, 1, ema2List,0 , canvas, rect, priceTop,priceBottom);
    _drawLineContect(colorConfig.colorLine3, 1, ema3List,0 , canvas, rect, priceTop,priceBottom);
  }


void _drawVol(List<KLineModel> dataList,Canvas canvas,Rect rect){

  for(int i = 0 ; i < dataList.length; i++){

    KLineModel model = dataList[i];
    if(model.vol == null)continue;
    if(model.open > model.close){

     _drawVolLine(colorConfig.colorDown, i, canvas, rect, model.vol, volTop);
    }else if(model.open < model.close){
     _drawVolLine(colorConfig.colorUp,i, canvas, rect, model.vol, volTop);
    }else{
     _drawVolLine(colorConfig.colorNormal, i, canvas, rect, model.vol, volTop);
    }

  }
  }

void _drawRSI(List<KLineModel> dataList,Canvas canvas,Rect rect){
    List<double> rsi1List = new List();
    List<double> rsi2List = new List();
    List<double> rsi3List = new List();
    
    for(int i = 0 ; i < dataList.length; i++) {
      KLineModel model = dataList[i];
       rsi1List.add(model.rsi1);
       rsi2List.add(model.rsi2);
       rsi3List.add(model.rsi3);
    }
    _drawLineContect(colorConfig.colorLine1, 1, rsi1List,0 , canvas, rect, 100,0);
    _drawLineContect(colorConfig.colorLine2, 1, rsi2List,0 , canvas, rect, 100,0);
    _drawLineContect(colorConfig.colorLine3, 1, rsi3List,0 , canvas, rect, 100,0);

  }

  void _drawAVG(List<KLineModel> dataList,Canvas canvas,Rect rect){
    List<double> avgList = new List();

    for(int i = 0 ; i < dataList.length; i++) {
      KLineModel model = dataList[i];
      avgList.add(model.avg);

    }
    _drawLineContect(colorConfig.colorAvg, 1, avgList,0 , canvas, rect, priceTop,priceBottom);
  }

void _drawVOLMA(List<KLineModel> dataList,Canvas canvas,Rect rect){
    List<double> volMa1List = new List();
    List<double> volMa2List = new List();

    int leftUnit1 = 0;
    int leftUnit2 = 0;

    for(int i = 0 ; i < dataList.length; i++) {
      KLineModel model = dataList[i];
      if (model.volMa1 == null) { leftUnit1 ++;}else{
       volMa1List.add(model.volMa1);
      }                          
      if (model.volMa2 == null) { leftUnit2 ++;}else{
       volMa2List.add(model.volMa2);
      }
  
    }
    _drawLineContect(colorConfig.colorLine1, 1, volMa1List,leftUnit1 , canvas, rect, volTop,0);
    _drawLineContect(colorConfig.colorLine2, 1, volMa2List,leftUnit2 , canvas, rect, volTop,0);


  }

void _drawMACD(List<KLineModel> dataList,Canvas canvas,Rect rect){
 List<double> difList = new List(); 
 List<double> deaList = new List();
  for(int i = 0 ; i < dataList.length; i++){

    KLineModel model = dataList[i];
        difList.add(model.dif);
        deaList.add(model.dea);
    if(model.macd > 0){

       _drawMacdLine(colorConfig.colorUp, i, canvas, rect, model.macd, macdMax);
    }else if(model.macd < 0){
       _drawMacdLine(colorConfig.colorDown,i, canvas, rect, model.macd, macdMax);
    }else{
       _drawMacdLine(colorConfig.colorNormal, i, canvas, rect, model.macd, macdMax);
    }

  }
    _drawLineContect(colorConfig.colorDif, 1, difList,0 , canvas, rect, difDeaMax,-difDeaMax);
      _drawLineContect(colorConfig.colorDea, 1, deaList,0 , canvas, rect, difDeaMax,-difDeaMax);
}

void _drawVolLine(Color color,int count,Canvas canvas,Rect rect,double vol,double areaTop){

    double lineSpace = rect.width/drawUnitCount;

    _paint.color = color;
    _paint.strokeCap = StrokeCap.butt;
    _paint.isAntiAlias = true;
    _paint.strokeWidth = lineSpace  * 0.8;
    _paint.style = PaintingStyle.stroke;
    double unitHigh =  rect.height / areaTop ;
    canvas.drawLine(Offset(rect.left + lineSpace * (count + 0.5) , rect.bottom - vol * unitHigh), Offset(rect.left + lineSpace *  (count + 0.5), rect.bottom), _paint);

  }

void _drawMacdLine(Color color,int count,Canvas canvas,Rect rect,double macd,double areaTop){

    double lineSpace = rect.width/drawUnitCount;

    _paint.color = color;
    _paint.strokeCap = StrokeCap.butt;
    _paint.isAntiAlias = true;
    _paint.strokeWidth = lineSpace  * 0.8;
    _paint.style = PaintingStyle.stroke;
    double unitHigh =  rect.height / areaTop / 2 ;
    canvas.drawLine(Offset(rect.left + lineSpace * (count + 0.5) , rect.center.dy - macd * unitHigh), Offset(rect.left + lineSpace *  (count + 0.5), rect.center.dy), _paint);

  }

void _drawLinkCandleLine(List<KLineModel> dataList,Canvas canvas,Rect rect){
  for(int i = 0 ; i < dataList.length; i++){

    KLineModel model = dataList[i];
    if(model.open > model.close){
       _drawCandleLine(colorConfig.colorDown, i, canvas, rect, model.top, model.bottom, model.open, model.close,priceTop,priceBottom,model.isChangeCycle,model.time);
     }else if(model.open < model.close){
       _drawCandleLine(colorConfig.colorUp, i, canvas, rect, model.top, model.bottom, model.open, model.close,priceTop,priceBottom,model.isChangeCycle,model.time);
     }else{
       _drawCandleLine(colorConfig.colorNormal, i, canvas, rect, model.top, model.bottom, model.open, model.close,priceTop,priceBottom,model.isChangeCycle,model.time);
    }
  
  }
}

void _drawCandleLine(Color color,int count,Canvas canvas,Rect rect,double top,double bottom,double open,double close,double areaTop,double areaBottom,bool isDivide,String time){

  double lineSpace = rect.width/drawUnitCount;

 if (isDivide) {
      _drawGudieLine(canvas,Offset(rect.left + lineSpace * (count + 0.5), rect.top), Offset(rect.left + lineSpace *  (count + 0.5), rect.bottom));
      _drawTextAutoLocation(Offset(rect.left + lineSpace * (count + 0.5), rect.bottom), 50, time, color, 8, canvas); 
    }

   _paint.color = color;
   _paint.strokeCap = StrokeCap.butt;
   _paint.isAntiAlias = true;
   _paint.strokeWidth = lineSpace  * 0.8;
   _paint.style = PaintingStyle.stroke;
   double unitHigh =  rect.height / (areaTop  - areaBottom);

   canvas.drawLine(Offset(rect.left + lineSpace * (count + 0.5) , rect.bottom - (open - areaBottom) * unitHigh), Offset(rect.left + lineSpace *  (count + 0.5), rect.bottom - (close - areaBottom) * unitHigh), _paint);
   _paint.strokeWidth = 1;
   canvas.drawLine(Offset(rect.left + lineSpace * (count + 0.5), rect.bottom - (top - areaBottom) * unitHigh), Offset(rect.left + lineSpace *  (count + 0.5), rect.bottom - (bottom - areaBottom) * unitHigh), _paint);
   if (top == priceTop) {
       _drawTextAutoLocation(Offset(rect.left + 2 + lineSpace * (count + 0.5), rect.bottom - (top - areaBottom) * unitHigh - 5), 100, priceTop.toString() , Colors.black, 10, canvas);
    }
  if (bottom == priceBottom) {
       _drawTextAutoLocation(Offset(rect.left + 2 + lineSpace *  (count + 0.5), rect.bottom - (bottom - areaBottom) * unitHigh - 5), 100,  priceBottom.toString() , Colors.black, 10, canvas);
    }
  
 
 }

void _drawLineContect(Color color,double width,List<double> data,int startCount,Canvas canvas,Rect rect,double areaTop,double areaBottom){

   double lineSpace = rect.width/drawUnitCount;

   _paint.color = color;
   _paint.strokeCap = StrokeCap.round;
   _paint.isAntiAlias = true;
   _paint.strokeWidth = width;
   _paint.style = PaintingStyle.stroke;
   double unitHigh =  rect.height / (areaTop - areaBottom);
   for(int i = startCount ; i < data.length - 1;i++){
     double current = data[i] - areaBottom;
     double next = data[i + 1] - areaBottom;
     canvas.drawLine(Offset(rect.left + lineSpace * (i + 0.5), rect.bottom - current * unitHigh), Offset(rect.left + lineSpace * (i + 1  + 0.5), rect.bottom - next * unitHigh), _paint);
   }
 }

void _drawRoundRect(Color color,double width,Canvas canvas,Rect rect){

      _paint.color = color;
      _paint.strokeCap = StrokeCap.butt;
      _paint.isAntiAlias = true;
      _paint.strokeWidth = width;
      _paint.style = PaintingStyle.stroke;
      canvas.drawRect(rect, _paint);
 }

void _drawCross(Color color,double width,Canvas canvas,Rect rect,Offset location){

      _paint.color = color;
      _paint.strokeCap = StrokeCap.butt;
      _paint.isAntiAlias = true;
      _paint.strokeWidth = width;
      _paint.style = PaintingStyle.stroke;
      if (location.dx >rect.left && location.dx < rect.right) {
        canvas.drawLine(Offset(location.dx,rect.top), Offset(location.dx,rect.bottom), _paint);

      }
       if (location.dy < rect.bottom && location.dy > rect.top) {
        canvas.drawLine(Offset(rect.left,location.dy), Offset(rect.right,location.dy), _paint);
       }
 }

void _drawGudieLine(Canvas canvas,Offset start,Offset end){

      _paint.color = colorConfig.colorGudie;
      _paint.strokeCap = StrokeCap.butt;
      _paint.isAntiAlias = true;
      _paint.strokeWidth = 0.5;
      _paint.style = PaintingStyle.stroke;
   canvas.drawLine(start, end, _paint);
 }

void _drawDesc(KLineModel model,String lineType,Rect rect,Canvas canvas,double edgeSpace){
        double locationTop = rect.top + 10 + edgeSpace ;
        double locationBottom = rect.bottom - edgeSpace ;
        double locationMid = (locationTop + locationBottom) / 2;

   switch (lineType) {

    case lineTypeCandle:
       
       
       _drawText(Offset(rect.left , locationTop), 30, priceTop.toStringAsFixed(2), colorConfig.colorDesc, 8, canvas);
       _drawText(Offset(rect.left , locationBottom), 30, priceBottom.toStringAsFixed(2), colorConfig.colorDesc, 8, canvas);
       _drawText(Offset(rect.left , locationMid), 30, ((priceBottom + priceTop) / 2).toStringAsFixed(2), colorConfig.colorDesc, 8, canvas);
    
      _drawGudieLine(canvas, Offset(rect.left,locationTop),  Offset(rect.right,locationTop));
      _drawGudieLine(canvas, Offset(rect.left,locationBottom), Offset(rect.right,locationBottom));
      _drawGudieLine(canvas, Offset(rect.left,locationMid), Offset(rect.right,locationMid));
      if (isShowCross) {
        if (crossLocation.dy < rect.bottom && crossLocation.dy > rect.top) {
           _drawText(Offset(rect.left , crossLocation.dy), 30, ((priceTop - priceBottom) * (1 - (crossLocation.dy - locationTop) / (locationBottom - locationTop)) + priceBottom).toStringAsFixed(2), colorConfig.colorDesc, 8, canvas);
        }
        if (crossLocation.dx < rect.right && crossLocation.dx > rect.left) {
         _drawTextAutoLocation(Offset(crossLocation.dx, rect.bottom), 50, model.time ,colorConfig.colorDesc, 8, canvas); 
        }
      }
      break;
    case lineTypeVOL:
       if (isShowCross) {
        if (crossLocation.dy < rect.bottom && crossLocation.dy > rect.top) {
           _drawText(Offset(rect.left , crossLocation.dy), 30, ((volTop - 0) * (1 - (crossLocation.dy - locationTop) / (locationBottom - locationTop)) + 0).toStringAsFixed(2), colorConfig.colorDesc, 8, canvas);
        }
      }

      break;

     case lineTypeMA:
       _drawText(Offset(rect.left+5, rect.top+2 ), 80, "ma(" +  manager.getParm(parmMA1).toString() + "," +   manager.getParm(parmMA2).toString() + "," +  manager.getParm(parmMA3).toString()  + ")", colorConfig.colorTitle, 10, canvas);
       _drawText(Offset(rect.left+80, rect.top+2 ), 60, model.ma1.toStringAsFixed(2), colorConfig.colorLine1, 10, canvas);
       _drawText(Offset(rect.left+80 + 60, rect.top+2 ), 60, model.ma2.toStringAsFixed(2), colorConfig.colorLine2, 10, canvas);
       _drawText(Offset(rect.left+80 + 120, rect.top+2 ), 60, model.ma3.toStringAsFixed(2), colorConfig.colorLine3, 10, canvas);
       break;

    case lineTypeEMA:
       _drawText(Offset(rect.left+5, rect.top+2 ), 80, "ema(" +  manager.getParm(parmEMA1).toString() + "," +   manager.getParm(parmEMA2).toString() + "," +  manager.getParm(parmEMA3).toString()  + ")", colorConfig.colorTitle, 10, canvas);
       _drawText(Offset(rect.left+80, rect.top+2 ), 60, model.ema1.toStringAsFixed(2), colorConfig.colorLine1, 10, canvas);
       _drawText(Offset(rect.left+80 + 60, rect.top+2 ), 60, model.ema2.toStringAsFixed(2), colorConfig.colorLine2, 10, canvas);
       _drawText(Offset(rect.left+80 + 120, rect.top+2 ), 60, model.ema3.toStringAsFixed(2), colorConfig.colorLine3, 10, canvas);
     
       break;
     case lineTypeVOLMA:
       _drawText(Offset(rect.left+5, rect.top+2 ), 80, "vol(" +  manager.getParm(parmVOLMA1).toString() + "," +   manager.getParm(parmVOLMA2).toString() + ")", colorConfig.colorTitle, 10, canvas);
       _drawText(Offset(rect.left+80, rect.top+2 ), 60, model.vol.toStringAsFixed(2), colorConfig.colorTitle, 10, canvas);
       _drawText(Offset(rect.left+80 + 60, rect.top+2 ), 60, model.volMa1.toStringAsFixed(2), colorConfig.colorLine1, 10, canvas);
       _drawText(Offset(rect.left+80 + 120, rect.top+2 ), 60, model.volMa2.toStringAsFixed(2), colorConfig.colorLine2, 10, canvas);
       _drawText(Offset(rect.left - 30, rect.top + 10 + edgeSpace - 4), 30, volTop.toStringAsFixed(2), colorConfig.colorTitle, 8, canvas);
       break;

   case lineTypeMACD:
       _drawText(Offset(rect.left+5, rect.top+2 ), 80, "macd(" +  manager.getParm(parmMACDFast).toString() + "," +   manager.getParm(parmMACDSlow).toString()+ "," +  manager.getParm(parmMACDSingal).toString()  + ")", colorConfig.colorTitle, 10, canvas);
       _drawText(Offset(rect.left+80, rect.top+2 ), 60,"diff:" + model.dif.toStringAsFixed(2), colorConfig.colorDif, 10, canvas);
       _drawText(Offset(rect.left+80 + 60, rect.top+2 ), 60,"dea:" + model.dea.toStringAsFixed(2), colorConfig.colorDea, 10, canvas);
       _drawText(Offset(rect.left+80 + 120, rect.top+2 ), 60,"macd:" + model.macd.toStringAsFixed(2), model.macd>0?colorConfig.colorUp:colorConfig.colorDown, 10, canvas);
       _drawText(Offset(rect.left - 30, rect.top + 10 + edgeSpace - 4), 30, macdMax.toStringAsFixed(2), colorConfig.colorTitle, 8, canvas);
       _drawText(Offset(rect.left - 30, rect.bottom - edgeSpace - 4), 30,(-macdMax).toStringAsFixed(2), colorConfig.colorTitle, 8, canvas);

       if (isShowCross) {
        if (crossLocation.dy < rect.bottom && crossLocation.dy > rect.top) {
           _drawText(Offset(rect.left , crossLocation.dy), 30, ((2 *macdMax ) * (1 - (crossLocation.dy - locationTop) / (locationBottom - locationTop)) - macdMax).toStringAsFixed(2), colorConfig.colorDesc, 8, canvas);
        }
      }
       break;


     default:
   }

 }

void _drawTextAutoLocation(Offset offset,double width,String text ,Color color ,double fontSize,Canvas canvas){
  
  ui.ParagraphBuilder pb = ui.ParagraphBuilder(ui.ParagraphStyle(
    textAlign: TextAlign.left,
    fontWeight: FontWeight.w300,
    fontStyle: FontStyle.normal,
    fontSize: fontSize,
  ));
  pb.pushStyle(ui.TextStyle(color: color));
  pb.addText(text);

  ui.ParagraphConstraints pc = ui.ParagraphConstraints(width: fontSize * text.length);
  ui.Paragraph paragraph = pb.build()..layout(pc);
  
  Offset newOffset  = Offset(offset.dx, offset.dy);
  if (offset.dx >drawRect.width / 2 + drawRect.left) {
      newOffset = Offset(offset.dx - paragraph.longestLine - 5, offset.dy);
  }
    
  canvas.drawParagraph(paragraph, newOffset);
}

void _drawText(Offset offset,double width,String text ,Color color ,double fontSize,Canvas canvas){
  
  ui.ParagraphBuilder pb = ui.ParagraphBuilder(ui.ParagraphStyle(
    textAlign: TextAlign.left,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    fontSize: fontSize,
  ));
  pb.pushStyle(ui.TextStyle(color: color));
  pb.addText(text);

  ui.ParagraphConstraints pc = ui.ParagraphConstraints(width: fontSize * text.length);
  ui.Paragraph paragraph = pb.build()..layout(pc);
  Offset newOffset  = Offset(offset.dx, offset.dy);
  canvas.drawParagraph(paragraph, newOffset);
}

}
