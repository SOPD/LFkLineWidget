import 'kLinePrintController.dart';

const parmMA1 = "ma1";
const parmMA2 = "ma2";
const parmMA3 = "ma3";

const parmRSI1 = "rsi1";
const parmRSI2 = "rsi2";
const parmRSI3 = "rsi3";

const parmVOLMA1 = "volMa1";
const parmVOLMA2 = "volMa2";

const parmEMA1 = "ema1";
const parmEMA2 = "ema2";
const parmEMA3 = "ema3";
const parmMACDFast = "macdFast";
const parmMACDSlow = "macdSlow";
const parmMACDSingal = "macdSignal";



class KlineParmManager{


List<ParmModel> parmList = [   ParmModel(name: "ma1",groupName: lineTypeMA,parm: 5,max: 255,min: 1),
                               ParmModel(name: "ma2",groupName: lineTypeMA,parm: 10,max: 255,min: 1),
                               ParmModel(name: "ma3",groupName: lineTypeMA,parm: 20,max: 255,min: 1),

                               ParmModel(name: "rsi1",groupName: lineTypeRSI,parm: 5,max: 255,min: 1),
                               ParmModel(name: "rsi2",groupName: lineTypeRSI,parm: 10,max: 255,min: 1),
                               ParmModel(name: "rsi3",groupName: lineTypeRSI,parm: 20,max: 255,min: 1),

                               ParmModel(name: "volMa1",groupName: lineTypeVOLMA,parm: 5,max: 255,min: 1),
                               ParmModel(name: "volMa2",groupName: lineTypeVOLMA,parm: 10,max: 255,min: 1),
                               ParmModel(name: "ema1",groupName: lineTypeEMA,parm: 5,max: 255,min: 1),
                               ParmModel(name: "ema2",groupName: lineTypeEMA,parm: 10,max: 255,min: 1),
                               ParmModel(name: "ema3",groupName: lineTypeEMA,parm: 20,max: 255,min: 1),
                               ParmModel(name: "macdFast",groupName: lineTypeMACD,parm: 12,max: 255,min: 1),
                               ParmModel(name: "macdSlow",groupName: lineTypeMACD,parm: 26,max: 255,min: 1),
                               ParmModel(name: "macdSignal",groupName: lineTypeMACD,parm: 9,max: 255,min: 1)];



List<String> allQuotas(){
List<String> result = new List();
for (var item in this.parmList) {
  if (!result.contains(item.groupName)) {
    result.add(item.groupName);
  }
  
}
  return result;
}


void setParm(String parmName,int parm){
for (var item in this.parmList) {
  if (item.name == parmName ) {
    item.setParm(parm);
  }
}

}

int getParm(String parmName){
 int result ;
for (var item in this.parmList) {
  if (item.name == parmName ) {
    result = item.parm;
  }
}
return result;
}

List<ParmModel> getParmGroup(String groupName){
 List<ParmModel>  result  = new List();
for (var item in this.parmList) {
  if (item.groupName == groupName ) {
    result.add(item);
  }
}
return result;
}                
}
class ParmModel{
   int parm;
   int max;
   int min;
   String name;
   String groupName;

 
   @override
   ParmModel({this.parm,this.max,this.min,this.name,this.groupName});

 bool setParm(int parm){
  bool result = false ;
   if (parm > min && parm <max) {
     this.parm = parm;
     result = true;
    }

return result;
 }
}