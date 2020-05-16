import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'kLinePrintController.dart';
import 'kLineColorConfig.dart';
typedef SwitchWidgetCallback = void Function(String);
class KlineTypeSwitchWidget extends StatelessWidget{
  
   final KLineColorConfig colorConfig;
   final KlinePrintController printController;
   final SwitchWidgetCallback callback;

   @override 
       KlineTypeSwitchWidget({Key key, this.printController,this.callback,this.colorConfig});
       


@override
  Widget build(BuildContext context) {
    return   Flex(
      direction: Axis.vertical,
       children: <Widget>[
                Container(height:  30,
                          // width: 100,
                           color: Color(0x55cccccc),
                           child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                      itemBuilder:(BuildContext context, int index){
                                       return  Container(
                                                   width: 100,
                                                   child:FlatButton(
                                                         onPressed: () => _onPressListMainBtn(index),
                                                             child: new Text(
                                                                   mainQuotas[index],
                                                                   style: new TextStyle(color: isSelection(mainQuotas[index])?colorConfig.colorBtnSelection:colorConfig.colorBtnNorma),)
                                                                           )
                                                         );
                                                                                      },
                                                   itemCount: mainQuotas.length,
                                                ),
                           ),
                           Container(
                             height: 40,
                             child:ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                      itemBuilder:(BuildContext context, int index){
                                       return  Container(
                                                   width: 100,
                                                   child:FlatButton(
                                                         onPressed: () => _onPressListSubBtn(index),
                                                             child: new Text(
                                                                   subQuotas[index],
                                                                   style: new TextStyle(color: isSelection(subQuotas[index])?colorConfig.colorBtnSelection:colorConfig.colorBtnNorma),)
                                                                           )
                                                         );
                                                                                      },
                                                   itemCount: subQuotas.length,
                                                ),
                           ),
                             ],
      
                    ) ;


 }
 bool isSelection(String quotaName){
   bool result = false;
  List<KlineGroup>  list = this.printController.getAllGroups();
  for (var item in list) {
    if (item.name == quotaName) {
      result = true;
    }
  }
return result;
 }
 void _onPressListMainBtn(int index){
  printController.mainGroup.name = mainQuotas[index];
  printController.mainGroup.components = defaultGroupMap[mainQuotas[index]];
  callback(mainQuotas[index]);
 }
 void _onPressListSubBtn(int index){

bool hasQuota = false;
int deleteIndex = 0;
for (int i = 0;i< printController.groups.length;i++) {
  if (printController.groups[i].name == subQuotas[index]) {
    deleteIndex = i;
    hasQuota = true;
  }
}
if (hasQuota) {
  printController.groups.removeAt(deleteIndex);
}else{
if (printController.groups.length <= 3) {
  printController.groups.add(KlineGroup(ratio: 0.2,name:subQuotas[index],components:defaultGroupMap[subQuotas[index]], edgeSpace: 2));
}
}
 callback(subQuotas[index]);

 }
}