
class KLineModel {

   //required
  final double top;
  final double bottom;
  final double open;
  final double close;
  double lastClose = 0;
  bool isChangeCycle = false;
    String time = "1970-01-01";
    double upDown = 0;
    double upDownRate = 0;
   //optional
    double avg = 0; //notnull
    double vol = 0; //notnull
    double volMa1 = 0;
    double volMa2 = 0;
    double ma1 = 0;
    double ma2 = 0;
    double ma3 = 0;

    double ema1 = 0;
    double ema2 = 0;
    double ema3 = 0;

    double dif = 0;
    double dea = 0;
    double macd = 0;
     
    double rsi1 = 0;
    double rsi2 = 0; 
    double rsi3 = 0;


    //caculate
    Map<int,double>maMap = {};
    Map<int,double>rsiMap = {};
    Map<int,double>emaMap = {};
    Map<int,double>volMaMap = {};
    Map<String,String> otherInfo = {};

    @override
    KLineModel({ this.top
                       ,this.bottom
                       ,this.open
                       ,this.close
                       ,this.avg
                       ,this.vol
                       ,this.isChangeCycle
                       ,this.time
                       ,this.lastClose
                       ,this.upDown
                       ,this.upDownRate
                  }){
                    if (avg == null) {
                      avg = (top + bottom) / 2;
                    }
                    if (isChangeCycle == null) {
                      isChangeCycle = false;
                    }
                    if (time == null) {
                      time = "1970-01-01";
                    }
                    if(lastClose == null){
                      lastClose = open;

                    }
                    if(upDown == null){
                      upDown = close - lastClose;
                    }
                    if(upDownRate == null){
                      upDownRate = (close - lastClose) / lastClose;
                    }
                  }

}