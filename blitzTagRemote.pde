
// IMPORTS
//import oscP5.*;
//import netP5.*;
//import apwidgets.*;
import android.content.Context;
import android.app.Notification;
import android.app.NotificationManager;

// DECLARATIONS
OscP5 oscP5;
NetAddress myRemoteLocation;
NotificationManager gNotificationManager;  
Notification gNotification; 
APWidgetContainer widgetContainer; 
APEditText tF_Port, tF_IP;

// VARIABLES
int menuState = 1;
int drawState = 2;
int state;
float boxX;
String port = "";
String ip = "";
float sw, sh, sw1, sw2, sw3;
float sendX, sendY;
boolean touched = false;
String[] fontList;
PFont androidFont;
float text_size;
long[] gVibrate = {0, 50, 0, 50, 0, 50};

color _0 = color(255,255,255);
color _1 = color(180,60,60);
color _2 = color(60,180,180);
color _3 = color(60,60,180);
color _4 = color(180,60,180);
color _5 = color(60,180,60);
color _6 = color(180,180,60);

int styleIndex = 3;

//----------------------------------------------------------------


void setup() {
  size(screenWidth, screenHeight, A2D);
  sw = screenWidth; // 480.0 on Nexus One
  sh = screenHeight; // 800.0 on Nexus One
  sw1 = sw / 10;
  sw2 = sw / 20;
  sw3 = sw / 40;
  text_size = sw / 40;
  // Set this so the sketch won't reset as the phone is rotated:
  orientation(LANDSCAPE);
  // Paint it Black, yo
  background(0);
  // Setup Fonts:
  fontList = PFont.list();
  androidFont = createFont(fontList[0], text_size, true);
  textFont(androidFont);
  // APWidgets
  widgetContainer = new APWidgetContainer(this);
  tF_Port = new APEditText((int) width/4, (int) sh/2, (int)sw2*3, (int) sw2*2);
  tF_IP = new APEditText((int) width/2, (int) sh/2, (int)sw2*3, (int) sw2*2);
  widgetContainer.addWidget(tF_Port);
  widgetContainer.addWidget(tF_IP);
  // set OSC
  oscInit();
  // Set State
  stateInit();
  // Misc
  rectMode(CENTER);
  smooth();
  noFill();
  boxX = sw/2;
}

//----------------------------------------------------------------

void draw() {
  int fps = round(frameRate);
  //println("FPS " + fps);
  noFill();

  // MENU
  if(state == 1) {
    background(0);
    strokeWeight(4);
    stroke(255);
    
    // Buttons
    rect(sw1,sw1,sw1,sw1); // 80 - 160
    text("prev", sw2 * 1.5, sw1 + sw3);
    rect(sw1 * 2 + sw2,sw1,sw1,sw1); // 200 - 280
    text("next", sw1 * 2 + sw3, sw1 + sw3);
    rect(sw1 * 4,sw1,sw1,sw1); // 320 - 400
    text("frze", sw1 * 3 + sw3 * 3, sw1 + sw3);
    rect(sw1 * 5 + sw2,sw1,sw1,sw1); // 440 - 520
    text("undo", sw1 * 4 + sw3 * 5, sw1 + sw3);
    rect(sw1 * 7,sw1,sw1,sw1); // 560 - 640
    text("clear", sw1 * 6 + sw2 + sw3, sw1 + sw3);
    rect(sw1 * 8 + sw2,sw1,sw1,sw1); // 680 - 720
    text("save", sw1 * 8 + sw3, sw1 + sw3);
    // Show Text Field
    widgetContainer.show();

    // Port
    text("PORT", sw/4, sh/2);
    // IP
    text("IP", sw/2, sh/2);
    // Apply
    rect(sw/2 + sw2*5, sh/2+sw2, sw2*3, sw2*2);
    text("APPLY", sw/2 + sw2*4, sh/2+sw2);
    
    // Width
    line(sw1+sw2, height-sw1, width-sw2, height-sw1);
    rect(boxX, height-sw1, sw3, sw2);

  }
  // DRAW
  else if(state == 2) {  
    
    // Hide Text Field
    widgetContainer.hide();
    
    if(touched == true) {
      sendX = constrain(mouseX / sw, 0, 1);
      sendY = constrain(1 - mouseY / sh, 0, 1);
    }
    else if(touched == false) {
      sendX = -1;
      sendY = -1; 
    }
    //println(sendX + " " + sendY);
  }
  
  // Send OSC
  oscP5.send("/x", new Object[] {new Float(sendX)}, myRemoteLocation);
  oscP5.send("/y", new Object[] {new Float(sendY)}, myRemoteLocation);
  
  // SWITCH
  strokeWeight(2);
  fill(255);
  stroke(255);
  beginShape(TRIANGLES);
    vertex(50, height);
    vertex(0, height);
    vertex(0, height-50);
  endShape();
  noFill();
}

//----------------------------------------------------------------




void mousePressed() {
  // Switch State
  if(mouseX < 50 && mouseY > height-50) {
    //println("switch state");
    gNotificationManager.notify(1, gNotification);
    switchState();
  }
  
  // ReInit OSC
  if (mouseX < sw/2 + sw2*6 && mouseX > sw/2 + sw2*4 ) {
    if(mouseY < sh/2 + sw2*2 && mouseY > sh/2 ) {
      //println("APPLY");
      gNotificationManager.notify(1, gNotification);
      oscReInit();
    }
  }
  
  if(state == 1) {
    // Buttons
    if(mouseX > sw1 && mouseX < sw1 * 2) {
      if(mouseY > sw2 && mouseY < sw1 * 2) {
       //println("PREV");
       styleIndex --;
       if(styleIndex == 0)styleIndex = 6;
       gNotificationManager.notify(1, gNotification);
       oscP5.send("/prev", new Object[] {new Float(1.0)}, myRemoteLocation); 
      }
    }  
    if(mouseX > sw1 * 2 + sw2 && mouseX < sw1 * 3 + sw2) {
      if(mouseY > sw2 && mouseY < sw1 * 2) {
        //println("NEXT"); 
        styleIndex ++;
        if(styleIndex == 6)styleIndex = 0;
        gNotificationManager.notify(1, gNotification);
        oscP5.send("/next", new Object[] {new Float(1.0)}, myRemoteLocation);
      }
    } 
    if(mouseX > sw1 * 4 && mouseX < sw1 * 5) {
      if(mouseY > sw2 && mouseY < sw1 * 2) {
        //println("FRZE"); 
        gNotificationManager.notify(1, gNotification);
        oscP5.send("/freeze", new Object[] {new Float(1.0)}, myRemoteLocation);
      }
    } 
    if(mouseX > sw1 * 5 + sw2 && mouseX < sw1 * 6 + sw2) {
      if(mouseY > sw2 && mouseY < sw1 * 2) {
        //println("UNDO"); 
        gNotificationManager.notify(1, gNotification);
        oscP5.send("/undo", new Object[] {new Float(1.0)}, myRemoteLocation);
      }
    } 
    if(mouseX > sw1 * 7 && mouseX < sw1 * 8) {
      if(mouseY > sw2 && mouseY < sw1 * 2) {
        //println("CLEAR"); 
        gNotificationManager.notify(1, gNotification);
        oscP5.send("/clear", new Object[] {new Float(1.0)}, myRemoteLocation);
      }
    }
    if(mouseX > sw1 * 8 + sw2 && mouseX < sw1 * 9 + sw2) {
      if(mouseY > sw2 && mouseY < sw1 * 2) {
        //println("SAVE"); 
        gNotificationManager.notify(1, gNotification);
        oscP5.send("/save", new Object[] {new Float(1.0)}, myRemoteLocation);
      }
    }

  }
}

void mouseDragged() {
    if(state == 1) {
      // Width
      if(mouseY > height-100 && mouseY < height) {
        boxX = constrain(mouseX, sw1+sw2, width-sw2);
        //println("WIDTH " + boxX); 
        float boxN = boxX / (sw*0.95);
        //println("NEW WIDTH " + boxN); 
        oscP5.send("/width", new Object[] {new Float(boxN)}, myRemoteLocation);
      } 
    }
    if(state == 2) {
      // Drawing
      //println(color(c_styleIndex));
     
      fill(255);
      stroke(255);
      strokeWeight(30-constrain(dist(pmouseX, pmouseY, mouseX, mouseY), 0, 20));
      line(mouseX-1, mouseY-1, mouseX, mouseY);   
    }
}

void mouseReleased() {  
  oscP5.send("/clear", new Object[] {new Float(0.0)}, myRemoteLocation);
  oscP5.send("/undo", new Object[] {new Float(0.0)}, myRemoteLocation);
  oscP5.send("/save", new Object[] {new Float(0.0)}, myRemoteLocation);
  oscP5.send("/prev", new Object[] {new Float(0.0)}, myRemoteLocation);
  oscP5.send("/next", new Object[] {new Float(0.0)}, myRemoteLocation);
  oscP5.send("/freeze", new Object[] {new Float(0.0)}, myRemoteLocation);
}

void keyPressed() {
  if(key == CODED) {
    if(keyCode == MENU) {
      //println("menu");
      //switchState();
      if(state == 2) background(0);
    } 
  }

  
}

//----------------------------------------------------------------

void stateInit() {
 state = 1; 
  
}

void oscInit() {
  oscP5 = new OscP5(this,12000);
  myRemoteLocation = new NetAddress("192.168.1.1",12000);  
  
  oscP5.send("/x", new Object[] {new Float(-1.0)}, myRemoteLocation);
  oscP5.send("/y", new Object[] {new Float(-1.0)}, myRemoteLocation);  
  oscP5.send("/clear", new Object[] {new Float(0.0)}, myRemoteLocation);
  oscP5.send("/undo", new Object[] {new Float(0.0)}, myRemoteLocation);
  oscP5.send("/save", new Object[] {new Float(0.0)}, myRemoteLocation);
  oscP5.send("/prev", new Object[] {new Float(0.0)}, myRemoteLocation);
  oscP5.send("/next", new Object[] {new Float(0.0)}, myRemoteLocation);
  oscP5.send("/freeze", new Object[] {new Float(0.0)}, myRemoteLocation);

}


void oscReInit() {
  port = tF_Port.getText();
  ip = tF_IP.getText();
  //println("Port is " + port + " IP is " + ip);
  oscP5 = new OscP5(this, 12000);
  myRemoteLocation = new NetAddress("ip",12000); 
 
}

void switchState() {
    background(0);
    if(state == 1) state = 2;
    else if(state == 2) state = 1;
    //println("state " + state);
  
}


//----------------------------------------------------------------

void onResume() {
  super.onResume();
  gNotificationManager = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
  gNotification = new Notification();
  gNotification.vibrate = gVibrate;
  //println("RESUMED! (Sketch Entered...)");
}

public boolean surfaceTouchEvent(MotionEvent event) {
  // If user touches the screen, trigger vibration notification:
  //gNotificationManager.notify(1, gNotification);
  return super.surfaceTouchEvent(event);
}

void onPause() {
  //println("PAUSED! (Sketch Exited...)");
  super.onPause();
} 
