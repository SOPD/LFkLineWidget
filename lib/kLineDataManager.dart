import 'package:flutter/cupertino.dart';
import 'kLinePrintController.dart';

import 'kLineModel.dart';
import 'kLineParmManager.dart';

class KLineDataManager{
List<KLineModel> dataList;
KlineParmManager parmManager;
KlinePrintController printController;
VoidCallback onAppendData;

    @override
    KLineDataManager({Key key
                       ,this.dataList
                       ,this.parmManager
                       ,this.printController
                  });




void completionLastClose(){

  dataList[0].lastClose = dataList[0].open;
  for(int i = 1;i < dataList.length;i++){
    KLineModel pre = dataList[i-1];
    KLineModel cur = dataList[i];
    cur.lastClose = pre.close;
  }
}
void completionAVG(){

  for(int i = 0;i < dataList.length;i++){
    KLineModel cur = dataList[i];
    cur.avg = (cur.open + cur.close) / 2;
  }
}
void completionUpDown(){

  for(int i = 0;i < dataList.length;i++){
    KLineModel cur = dataList[i];
    cur.upDown = cur.close - cur.lastClose;
    cur.upDownRate = cur.upDown/cur.lastClose * 100;
  }
}





void caculateDataList(){
  List<KlineGroup> groups = this.printController.getAllGroups();
  for (var item in groups) {

    for (var lineType in item.components) {
      caculateWithLineType(lineType);
    }
  }

}


void caculateWithLineType(String lineType){

switch (lineType) {
  case lineTypeMA:
    initMA();
    break;
  case lineTypeEMA:
    initEMA();
    break;
  case lineTypeMACD:
   initMACD();
    break;
  case lineTypeVOLMA:
   initVOLMA();
    break;
  case lineTypeRSI:
   initRSI();
    break;
  default:
}

}

 void initMA(){
  _calcuateMa(parmManager.getParm(parmMA1), this.dataList);
  _calcuateMa(parmManager.getParm(parmMA2), this.dataList);
 _calcuateMa(parmManager.getParm(parmMA3), this.dataList);

   for (var item in this.dataList) {
    item.ma1 = item.maMap[parmManager.getParm(parmMA1)];
    item.ma2 = item.maMap[parmManager.getParm(parmMA2)];
    item.ma3 = item.maMap[parmManager.getParm(parmMA3)];
  }
 }

 void initRSI(){
  _caculateRSI(parmManager.getParm(parmRSI1), this.dataList);
  _caculateRSI(parmManager.getParm(parmRSI2), this.dataList);
  _caculateRSI(parmManager.getParm(parmRSI3), this.dataList);

   for (var item in this.dataList) {

    item.rsi1 = item.rsiMap[parmManager.getParm(parmRSI1)];
    item.rsi2 = item.rsiMap[parmManager.getParm(parmRSI2)];
    item.rsi3 = item.rsiMap[parmManager.getParm(parmRSI3)];
  }
 }


 void initVOLMA(){
  _calcuateVolMa(parmManager.getParm(parmVOLMA1), this.dataList);
  _calcuateVolMa(parmManager.getParm(parmVOLMA2), this.dataList);

   for (var item in this.dataList) {
    item.volMa1 = item.volMaMap[parmManager.getParm(parmVOLMA1)];
    item.volMa2 = item.volMaMap[parmManager.getParm(parmVOLMA2)];
  }
 }

 void initEMA(){
  _calcuateEMA(parmManager.getParm(parmEMA1), this.dataList);
  _calcuateEMA(parmManager.getParm(parmEMA2), this.dataList);
  _calcuateEMA(parmManager.getParm(parmEMA3), this.dataList);
   for (var item in this.dataList) {
    item.ema1 = item.emaMap[parmManager.getParm(parmEMA1)];
    item.ema2 = item.emaMap[parmManager.getParm(parmEMA2)];
    item.ema3 = item.emaMap[parmManager.getParm(parmEMA3)];
  }
 }

  void initMACD(){
  _caculateMACD(parmManager.getParm(parmMACDFast), parmManager.getParm(parmMACDSlow), parmManager.getParm(parmMACDSingal), this.dataList);
 }

 void _calcuateMa(int parmDays, List<KLineModel> datalist){
    if(datalist == null || parmDays == null || parmDays < 1){
      return;
    }
     double cur = dataList[0].close;
     for(int i = 0 ; i < datalist.length;i++){
        double curClose = dataList[i].close;
        if(i < parmDays){ 
          cur = cur * (parmDays - 1) /parmDays + curClose  / parmDays ;
        }else{
          cur = cur - (dataList[i - parmDays].close - dataList[i].close) / parmDays;
        }
        dataList[i].maMap[parmDays] = cur;
      }
   }
 
 void _calcuateVolMa(int parmDays, List<KLineModel> datalist){
    if(datalist == null || parmDays == null || parmDays < 1){
      return;
    }
      double cur = dataList[0].vol;
     for(int i = 0 ; i < datalist.length;i++){
        double curClose = dataList[i].vol;
        if(i < parmDays){ 
          cur = cur * (parmDays - 1) /parmDays + curClose  / parmDays ;
        }else{
          cur = cur - (dataList[i - parmDays].vol - dataList[i].vol) / parmDays;
        }
        dataList[i].volMaMap[parmDays] = cur;
      }
   }

 void _calcuateEMA(int parmDays, List<KLineModel> datalist){
     if(datalist == null || parmDays == null || parmDays < 1){
      return;
    }
     double emaCur = dataList[0].close;
     int totalCount = ((1+parmDays) * parmDays) ~/ 2;
     for(int i = 0 ; i < datalist.length;i++){
        double curClose = dataList[i].close;
       if(i < parmDays){ 
          emaCur = emaCur * (parmDays - 1) /(parmDays + 1) + curClose * 2 / (parmDays + 1);
        }else{
          emaCur = (emaCur - dataList[i - parmDays].close  / totalCount) *(totalCount - parmDays)/(totalCount - 1) + dataList[i].close * parmDays / totalCount;
        }
       
        dataList[i].emaMap[parmDays] = emaCur;
      }
      
   }

   void _caculateMACD(int macdFast,int macdSlow,macdSignal, List<KLineModel> datalist){

       double curSlow = dataList[0].close;
       double curFast = dataList[0].close;
       
       double curDea  = 2 * (curFast - curSlow);
       for(int i = 0 ; i < datalist.length;i++){
           KLineModel model =  datalist[i];
           curSlow = curSlow * (macdSlow- 1) /(macdSlow + 1) + model.close * 2 / (macdSlow + 1);
           curFast = curFast * (macdFast- 1) /(macdFast + 1) + model.close * 2 / (macdFast + 1);
           model.dif = 2 * (curFast - curSlow);
           curDea = curDea * (macdSignal - 1) /(macdSignal + 1) + model.dif * 2 / (macdSignal + 1);
           model.dea = curDea;
           model.macd = model.dif - model.dea;
      }
   }

     void _caculateRSI(int parmdays,List<KLineModel> datalist){
        double rsiUp = 0;
        double rsiDown = 0;
       for(int i = 0 ; i < datalist.length;i++){
         KLineModel model = datalist[i];
        if (model.upDown > 0) {
          rsiUp = rsiUp + model.upDown / parmdays;
        }else{
          rsiDown = rsiDown - model.upDown / parmdays;
        }
        if (i >= parmdays) {
          if (datalist[i - parmdays].upDown > 0) {
            rsiUp -= datalist[i - parmdays].upDown / parmdays;
          }else{
             rsiDown += datalist[i - parmdays].upDown / parmdays;
          }
        }
        if (rsiUp + rsiDown == 0) {
            model.rsiMap[parmdays] = 100;
            return;
        }
         if (rsiUp == 0){
            model.rsiMap[parmdays] = 0;
            return;
         }
         model.rsiMap[parmdays] = rsiUp / (rsiUp + rsiDown) * 100;
       }

     }

}