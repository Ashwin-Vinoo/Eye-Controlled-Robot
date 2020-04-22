#include<LiquidCrystal.h>
#include<NECremote.h>
#include <NewPing.h>
LiquidCrystal lcd(A0,A1,3,4,7,8);
NewPing sonar(12,13,100);
unsigned long serialtimer=0;
void setup() 
{ 
  Serial.begin(9600);
  IRinitialize(0);  
  lcd.begin(16, 2);  
  lcd.setCursor(0,0);
  lcd.print(" EYE CONTROLLED ");
  lcd.setCursor(0,1);
  lcd.print(" WHEELCHAIR BOT ");
  delay(2500);
  pinMode(A2,OUTPUT);  
  pinMode(A3,OUTPUT); 
  pinMode(A4,INPUT); 
  pinMode(A5,INPUT); 
  pinMode(5,OUTPUT);  
  pinMode(6,OUTPUT); 
  pinMode(9,OUTPUT); 
  pinMode(10,OUTPUT);   
  pinMode(11,OUTPUT); 
  digitalWrite(A2,LOW);
  digitalWrite(A3,LOW);  
  digitalWrite(11,HIGH);
}
void loop() 
{
  //*******************REMOTE CONTROL MODE*******************//      
  lcd.setCursor(0,0);
  lcd.print(" REMOTE CONTROL ");
  while(1)
  {
    if(IRbuttontimer()<100)
    {
      if(IRbuttonlatest()=="TWO")
      {
        forward();
      }
      else if(IRbuttonlatest()=="EIGHT")
      {
        backwards();         
      }
      else if(IRbuttonlatest()=="SIX")
      {
        clockwise();      
      }
      else if(IRbuttonlatest()=="FOUR")
      {
        anticlockwise();
      }
      else if(IRbuttonlatest()=="MUTE")
      {
        lcd.setCursor(0,1);
        lcd.print("BUZZER ACTIVATED");
        digitalWrite(A3,HIGH);
      } 
      else
      {
        halt();
        digitalWrite(A3,LOW);
        if(IRbuttonlatest()=="MODE")
        {
          delay(300);
          break;
        }         
        lcd.setCursor(0,1);
        lcd.print(" UNKNOWN BUTTON ");        
      }
    }
    else if(IRbuttontimer()>200)
    {
      lcd.setCursor(0,1);
      lcd.print("NO BUTTON ACTIVE");
      halt();
      digitalWrite(A3,LOW);       
    }      
  }
  //*****************BLUETOOTH/USB DATA MODE*****************//    
  lcd.setCursor(0,0);
  lcd.print("BLUETOOTH / USB ");
  Serial.flush();  
  while(1)
  {
    if(Serial.available())
    {
      byte SerialData=Serial.read();
      serialtimer=millis();
      if(SerialData==0)
      {
        halt(); 
      }
      else if(SerialData==1)
      {
        do
        {
          if(sonar.ping()<1000 && sonar.ping()!=0)
          {
            lcd.setCursor(0,1);
            lcd.print("OBJECT DETECTED ");
            break;
          }
          if(digitalRead(A4)==LOW || digitalRead(A5)==LOW)
          {
            lcd.setCursor(0,1);
            lcd.print(" CLIFF DETECTED ");   
            break;
          }
          forward();
        }
        while(abs(millis()-serialtimer)<195 && !Serial.available());
      }
      else if(SerialData==2)
      {
        backwards(); 
      }
      else if(SerialData==3)
      {
        clockwise();
      }
      else if(SerialData==4)
      {
        anticlockwise(); 
      }
      else
      {
        lcd.setCursor(0,1);
        lcd.print(" UNKNOWN PACKET ");  
      }
    }
    if(abs(millis()-serialtimer)>200)
    {
      lcd.setCursor(0,1);
      lcd.print("NO DATA RECIEVED");
      halt();
    }
    if(IRbuttonlatest()=="MODE" && IRbuttontimer()<100)
    {
      halt();
      delay(300);
      break;
    }   
  }   
  //******************LINE FOLLOWING MODE********************//  
  lcd.setCursor(0,0);
  lcd.print(" LINE FOLLOWING ");
  while(1)
  {
    if(digitalRead(A4)==HIGH && digitalRead(A5)==HIGH)
    {
      forward();
    } 
    else if(digitalRead(A4)==LOW && digitalRead(A5)==LOW)
    {
      lcd.setCursor(0,1);
      lcd.print(" MOTION STOPPED ");
      halt();
    } 
    else if(digitalRead(A4)==HIGH && digitalRead(A5)==LOW)
    {
      clockwise();
    } 
    else if(digitalRead(A4)==LOW && digitalRead(A5)==HIGH)
    {
      anticlockwise();
    }  
    if(IRbuttonlatest()=="MODE" && IRbuttontimer()<100)
    {
      halt();
      delay(300);
      break;
    }    
  }
}
//******************FUNCTION DEFINITIONS*******************//  
void forward()
{
  lcd.setCursor(0,1);
  lcd.print(" MOVING FORWARD ");
  digitalWrite(5,LOW);
  analogWrite(6,100);
  digitalWrite(9,LOW);
  analogWrite(10,100);   
}
void backwards()
{
  lcd.setCursor(0,1);
  lcd.print("MOVING BACKWARDS");
  analogWrite(5,100);
  digitalWrite(6,LOW);
  analogWrite(9,100);
  digitalWrite(10,LOW);  
}
void anticlockwise()
{
  lcd.setCursor(0,1);
  lcd.print("MOVING ANTICLOCK");
  digitalWrite(5,LOW);
  analogWrite(6,100);
  analogWrite(9,100);
  digitalWrite(10,LOW);      
}
void clockwise()
{
  lcd.setCursor(0,1);
  lcd.print("MOVING CLOCKWISE");
  analogWrite(5,100);
  digitalWrite(6,LOW);
  digitalWrite(9,LOW);
  analogWrite(10,100);
}
void halt()
{  
  digitalWrite(5,LOW);
  digitalWrite(6,LOW);
  digitalWrite(9,LOW);
  digitalWrite(10,LOW); 
}
























