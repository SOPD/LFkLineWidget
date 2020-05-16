
const String quotaTypeMA = "MA";
const String quotaTypeAVG = "AVG";
const String quotaTypeRSI = "RSI";
const String quotaTypeEMA = "EMA";
const String quotaTypeVOL = "VOL";
const String quotaTypeMACD = "MACD";

const String lineTypeCandle = 'candle';
const String lineTypeAVG = 'avg';
const String lineTypeRSI = 'rsi';
const String lineTypeMA = 'ma';
const String lineTypeEMA = 'ema';
const String lineTypeMACD = 'macd';
const String lineTypeVOL = 'vol';
const String lineTypeVOLMA = 'volma';

//delfault components 
const List<String> defaultMAGroup = [lineTypeCandle,lineTypeMA];
const List<String> defaultRSIGroup = [lineTypeRSI];
const List<String> defaultEMAGroup = [lineTypeCandle,lineTypeEMA];
const List<String> defaultMACDGroup = [lineTypeMACD];
const List<String> defaultVolGroup = [lineTypeVOL,lineTypeVOLMA];
const List<String> defaultAVGGroup = [lineTypeAVG];




const Map<String ,List<String>> defaultGroupMap = {quotaTypeMA:defaultMAGroup,
                                                   quotaTypeEMA:defaultEMAGroup,
                                                   quotaTypeVOL:defaultVolGroup,
                                                   quotaTypeMACD:defaultMACDGroup,
                                                   quotaTypeRSI:defaultRSIGroup,
                                                    quotaTypeAVG:defaultAVGGroup
                                                   };

const List<String> mainQuotas = [quotaTypeMA,quotaTypeEMA];
const List<String> subQuotas = [quotaTypeVOL,quotaTypeMACD,quotaTypeRSI];




class KlinePrintController{
double padding = 5;
KlineGroup mainGroup = KlineGroup(ratio: 0.6,components: defaultGroupMap[quotaTypeMA],name: quotaTypeMA,edgeSpace: 10);

List<KlineGroup> groups = [ KlineGroup(ratio: 0.2,components: defaultGroupMap[quotaTypeVOL],name: quotaTypeVOL,edgeSpace: 2),
                           KlineGroup(ratio: 0.2,components: defaultGroupMap[quotaTypeMACD],name: quotaTypeMACD,edgeSpace: 2)];


List<KlineGroup> getAllGroups(){
List<KlineGroup> result = new List.from(groups);
 result.insert(0, this.mainGroup);
return result;
}   

double getAllRatio(){
   List<KlineGroup> all = this.getAllGroups();
   double result  = 0;
   for (var item in all) {
     result+=item.ratio;
   }
return result;
 }                                   
}
                          
class KlineGroup{
   double ratio;
   double edgeSpace = 0;
   List<String> components;
   String name;
    @override
    KlineGroup({ this.ratio,
                 this.components,
                 this.name,
                 this.edgeSpace
                  });

}