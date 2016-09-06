//+------------------------------------------------------------------+
//|                                                       sample.mq4 |
//|                                                              Jin |
//|                                                                  |
//+------------------------------------------------------------------+
#include <stderror.mqh>
#include <stdlib.mqh>



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int Count = 0; //count how many ticks
int onThisMinute = TimeMinute(TimeCurrent());
double AskBuyAtStart = Ask; //keep track of current price to determin color of color
double barMinPrice = Ask;
double sizeOfBar = 0;

int OnInit() {
  Alert ("Function init() triggered at start");
  return(INIT_SUCCEEDED); // exit init
}
  
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
  Alert("Function deinit() ");
  return; // exit deinit
}
  
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){

  double AskBuyPrice = Ask; 
  double BidSellPrice = Bid; 
  //Bid is predifined variable for the latest buyer's price. RefreshRates() must be used to update
  
  if (AskBuyAtStart< barMinPrice){//update minimum price
      barMinPrice=AskBuyAtStart;
  }
  Count ++; //count how many ticks
  
  int s=TimeSeconds(TimeCurrent());
  int m=TimeMinute (TimeCurrent());
  
  //get color of previous candle bar right before on M1(minute) chart
  //for the first round, the evaluation of the candle bar will not match the chart because if timing
  if (m!=onThisMinute){
      barMinPrice = Ask;
      int prevBarColor;
      if (AskBuyPrice < AskBuyAtStart){ //price decrease.RED
         prevBarColor=1;  //red=1
         sizeOfBar = AskBuyAtStart-AskBuyPrice;
         Alert("New Minute Started= ", m, "|| prev CandleBar= RED size= ", sizeOfBar, " prev Min of CadleBar= ", barMinPrice );
         
         //if the red bar is very large, buy
         //if the red bar is somewhat large, Wait
         //if the red bar is very small, consider as meaningless
         
         //buy if current price is close to the minimun price of currnet M1 of M5 chart (CopyLow builtin function)
         
         //if Bear on the M1, M5 (Minute) chart, wait
         
      }
      else{//GREEN
         prevBarColor=0;  //green=0
         sizeOfBar = AskBuyPrice - AskBuyAtStart;
         Alert("New Minute Started= ", m, "|| prev CandleBar= GREEN size= ", sizeOfBar);
         if (sizeOfBar<0.00003){
            prevBarColor=1;
         }
      }
      
      
//get min,max during last period(40 bars in m1 chart)
      double m1_min=0;
      double m1_max=0;
      //double m5_min;
         
      //iLowest(symbol, timeframe, type, number of bars to search, start)
      int m1_min_index=iLowest(NULL,1,MODE_LOW,40,0);
      int m1_max_index=iHighest(NULL,1,MODE_HIGH,40,0);
      if(m1_min_index!=-1 && m1_max_index!=-1){
         m1_min=Low[m1_min_index];
         m1_max=High[m1_max_index];
         Alert("m1_min= ", m1_min, " m1_min_index= ", m1_min_index);
         Alert("m1_max= ", m1_max, " m1_max_index= ", m1_max_index);
      }
      else{
         Alert("Error in iLowest/iHightest. Error code=%d",GetLastError());
      }
      
      //if (prevBarColor==1 && m1_min!=0  && m1_max!=0   &&    AskBuyPrice<(m1_min+(m1_max-m1_min)/2)){
      if (prevBarColor==1 && m1_min!=0  && m1_max!=0   &&    AskBuyPrice<(m1_max)){
      
         Alert("BUY");
         //double orderSendPrice=Ask;
         
         double stoploss=AskBuyPrice-0.1;
         double takeprofit=AskBuyPrice+0.1;
         //
         int ticket = OrderSend(Symbol(),  OP_BUY,    0.01,    AskBuyPrice,  0,        stoploss, takeprofit, "My order",11111,        0,             clrYellow);
                      //OrderSend(symbol, operation,  volume,  price,        slippage, stoploss, takeprofit, comment,   magicnumber, pending oprder, color)
         Alert("Bought. Ticket#= ", ticket, " stoploss: ", stoploss, " takeprofit: ", takeprofit);
         if(ticket<0){ //erroe: did NOT send order
            int check=GetLastError();
            if(check!=ERR_NO_ERROR) Alert("Error: ",ErrorDescription(check));
         }
         else{//order succesfully sent
            //need to close order
            
            /*
            if(Bid>AskBuyPrice){
               Alert("close order");
               if( OrderClose(ticket,0.01,Bid,3,Red) != true){
                  int check=GetLastError();
                  if(check!=ERR_NO_ERROR) Alert("Error: ",ErrorDescription(check));
                  
               }
               
            }
            else{
               Alert("Don't close order yet");
           }
           */
         }
      }
      else{
         Alert("No signal to buy");
      }
      
      
      
      
      
      onThisMinute = m;
      AskBuyAtStart = Ask; //initialized when EA robot is attached to chart
  }
  
  
  Alert("New tick ", Count, "|| Buy(Ask)= ", AskBuyPrice, "|| Sell(Bid)= ", BidSellPrice, "|| Min:Sec= ",m,":", s);
  return;
//---
   
}
//+------------------------------------------------------------------+
