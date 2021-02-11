import processing.video.*;
import themidibus.*;
MidiBus myBus;
Capture cam;
int x=854, y=480, red_on, green_on, blue_on, sw1, sw2;
float feed=.0, var1=.00001, decay=.75, decay2=.0000001, amp_r=3, amp_g=3, amp_b=3, speed_r, speed_g, speed_b, lfo_r, lfo_g, lfo_b, amp_r_saved, amp_g_saved, amp_b_saved, speed_r_saved, speed_g_saved, speed_b_saved;
float[] r=new float[x*y];
float[] g=new float[x*y];
float[] b=new float[x*y];
float[][] r2=new float[x][y];
float[][] g2=new float[x][y];
float[][] b2=new float[x][y];

void setup() {
  size(854, 480);
  frameRate(30);
  String[] cameras = Capture.list();
  if (cameras == null) {
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, x, y);
  } else if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    printArray(cameras);
    cam = new Capture(this, cameras[0]);
    cam.start();
    MidiBus.list(); 
    myBus=new MidiBus(this, 2, 0);
  }
}

void controllerChange(int channel, int note, int velocity) {
  if (channel==0) {
    if (note==0) amp_r=map(velocity, 0, 127, 1, 100);
    if (note==1) amp_g=map(velocity, 0, 127, 1, 100);
    if (note==2) amp_b=map(velocity, 0, 127, 1, 100);
    if (note==7) var1=map(velocity, 0, 127, 0, .0001);
    if (note==16) speed_r=map(velocity, 0, 127, -var1, var1);
    if (note==17) speed_g=map(velocity, 0, 127, 0, var1);
    if (note==18) speed_b=map(velocity, 0, 127, 0, var1);
    if (note==19) feed=map(velocity, 0, 127, 0, 1);
    if (note==32 && velocity==127) sw1=(sw1+1)%2;
    if (note==48 && velocity==127) sw2=(sw2+1)%2;
    if (note==64 && velocity==127) red_on=(red_on+1)%2;
    if (note==65 && velocity==127) green_on=(green_on+1)%2;
    if (note==66 && velocity==127) blue_on=(blue_on+1)%2;
  }
}

void keyPressed() {
  if (key=='r') {
    speed_r=speed_g=speed_b=lfo_r=lfo_g=lfo_b=0;
    amp_r=amp_g=amp_b=20;
  }
  if (key=='s') {
    amp_r_saved=amp_r;
    amp_g_saved=amp_g;
    amp_b_saved=amp_b;
    speed_r_saved=speed_r;
    speed_g_saved=speed_g;
    speed_b_saved=speed_b;
  }
}

void draw() { 
  if (cam.available() == true) cam.read();
  image(cam, 0, 0, width, height);
  if (sw1==1) {
    if (amp_r > 0) amp_r -= decay;
    if (amp_g > 0) amp_g -= decay;
    if (amp_b > 0) amp_b -= decay;
    if (speed_r > 0) speed_r -= decay2;
    if (speed_g > 0) speed_g -= decay2;
    if (speed_b > 0) speed_b -= decay2;
  }
  if (sw2==1) {
    if (amp_r < amp_r_saved) amp_r += decay;
    if (amp_g < amp_g_saved) amp_g += decay;
    if (amp_b < amp_b_saved) amp_b += decay;
    if (speed_r < speed_r_saved) speed_r += decay2;
    if (speed_g < speed_g_saved) speed_g += decay2;
    if (speed_b < speed_b_saved) speed_b += decay2;
  }
  for (int j=0; j<y/2; j++) {
    for (int i=0; i<x/2; i++) {
      color c=get(i, j);
      r[i+j*x]=c >> 16 & 0xFF; 
      g[i+j*x]=c >> 8 & 0xFF;
      b[i+j*x]=c & 0xFF;
      set(i, j, -1);
    }
  }
  for (int j=0; j<y; j++) {
    for (int i=0; i<x; i++) {
      r2[i][j]=r2[i][j]*feed;
      g2[i][j]=g2[i][j]*feed;
      b2[i][j]=b2[i][j]*feed;
    }
  }
  for (int j=0; j<y/2; j++) {
    for (int i=0; i<x/2; i++) {
      int temp1=int(abs((i+x/4)+(cos(lfo_r)*amp_r)));
      int temp2=int(abs((j+y/4)+(sin(lfo_r)*amp_r)));
      int temp3=int(abs((i+x/4)+(cos(lfo_g)*amp_g)));
      int temp4=int(abs((j+y/4)+(sin(lfo_g)*amp_g)));
      int temp5=int(abs((i+x/4)+(cos(lfo_b)*amp_b)));
      int temp6=int(abs((j+y/4)+(sin(lfo_b)*amp_b)));
      if (red_on==0) r2[temp1][temp2]=r[i+j*x/2];
      if (green_on==0) g2[temp3][temp4]=g[i+j*x/2];
      if (blue_on==0) b2[temp5][temp6]=b[i+j*x/2];
      lfo_r += speed_r;
      lfo_g += speed_g;
      lfo_b += speed_b;
      if (lfo_r > TWO_PI) lfo_r = -TWO_PI;
      if (lfo_g > TWO_PI) lfo_g = -TWO_PI;
      if (lfo_b > TWO_PI) lfo_b = -TWO_PI;
    }
  }
  for (int j=0; j<y; j++) {
    for (int i=0; i<x; i++) {
      set(i, j, color(r2[i][j], g2[i][j], b2[i][j]));
    }
  }
}
