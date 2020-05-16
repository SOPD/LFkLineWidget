
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'kLinePrintController.dart';
import 'kLineParmManager.dart';
import 'kLineColorConfig.dart';

class KlineParmSetWidget extends StatefulWidget{
final KlineParmManager manager;
final KLineColorConfig colorConfig;
final VoidCallback callBack;

   @override 
       KlineParmSetWidget({Key key, this.manager,this.callBack,this.colorConfig});
       

@override
State<StatefulWidget> createState() {

    return _KlineParmSetState();
  }

}
class _KlineParmSetState extends State<KlineParmSetWidget>{
String currentSelectedGroup = lineTypeMA;
@override
  Widget build(BuildContext context) {
    return Flex(
      crossAxisAlignment: CrossAxisAlignment.center,
      direction: Axis.horizontal,
       children: <Widget>[
         Container(
           height:  150,
            width: 80,
            color: Color(0x55cccccc),
            child: ListView.builder(
      scrollDirection: Axis.vertical,
         itemBuilder:(BuildContext context, int index){
               return  Container(
                width: 80,
            child:FlatButton(
             onPressed: () => _onPressParm(widget.manager.allQuotas()[index]),
             child: new Text(
                 widget.manager.allQuotas()[index],
                 style: new TextStyle( color: widget.manager.allQuotas()[index] == currentSelectedGroup?widget.colorConfig.colorBtnSelection:widget.colorConfig.colorBtnNorma),)
                                   )
                               );
                     },
                                                   itemCount: widget.manager.allQuotas().length,
                                                ),
                           ),
                           Container(
                            width:  300,
                            height:  150,
                               child:ListView.builder(
                                  scrollDirection: Axis.vertical,
                                      itemBuilder:(BuildContext context, int index){
                                       return  Container(
                                                   height: 50,
                                               child: Row(
                                                  children: <Widget>[
                                                    Container(
                                                      width: 110,
                                                      child: Text(widget.manager.getParmGroup(this.currentSelectedGroup)[index].name + ":" + widget.manager.getParmGroup(this.currentSelectedGroup)[index].parm.toString()),
                                                   ),
                                                    CupertinoSlider(value: widget.manager.getParmGroup(this.currentSelectedGroup)[index].parm.toDouble(),
                                                    max:widget.manager.getParmGroup(this.currentSelectedGroup)[index].max.toDouble(),
                                                    min:widget.manager.getParmGroup(this.currentSelectedGroup)[index].min.toDouble(),
                                                    divisions: 255 ,
                                                        onChanged: (double value){
                                                                    widget.manager.getParmGroup(this.currentSelectedGroup)[index].parm = value.toInt();
                                                                    setState(() {
                                                                    });
                                                    },)
                                                  ],
                                               )
                                                         ); },
                                                   itemCount: widget.manager.getParmGroup(currentSelectedGroup).length,
                                                ),
                           
                           ),
                             ],
      
                    ) ;
  }
void _onPressParm(String parmGroupName){
currentSelectedGroup = parmGroupName;
setState(() {
  
});
}

}