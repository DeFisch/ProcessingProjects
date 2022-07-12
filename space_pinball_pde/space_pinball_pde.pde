import com.jogamp.newt.opengl.GLWindow;


boolean moving = false; // mouse movement
int persp = -1;
float posX = -446;
float posY = -294;
float posZ = -335;
float camAX = 54.0;
float camAY = 37.0;
float camAZ = 0.0;
float speed = 5;
boolean planetDropped = false;
float pickX;
float pickY;
float endPickX;
float endPickY;
float planetRadius = 10;
boolean flashlightOn = false;
ArrayList<Planet> pList = new ArrayList<Planet>();
ArrayList<Explosion> exList = new ArrayList<Explosion>();
PGraphics gui;


//assets
PImage sunTexture;
PImage explosionTexture;
PShape sun;


void setup() {
  fullScreen(P3D);
  frameRate(60);
  smooth(4);
  explosionTexture = loadImage("explosion.jpg");
  sun = createShape(SPHERE, 30);
  sunTexture = loadImage("sun.jpg");
  pList.add(new Planet((float)0,(float)0,(float)0,(float)0,(float)1000,color(random(255),random(255),random(255))));
  
  gui = createGraphics(width, height, JAVA2D );
}

void keyPressed() {
  if(key == 'w' || key == 's' || key == 'a' || key == 'd')
    moving = true;
  if(key == ' '){
    posX = -446;
    posY = -294;
    posZ = -335;
    camAX = 54.0;
    camAY = 37.0;
    camAZ = 0.0;
      if(persp < pList.size() - 1)
        persp ++;
      else
        persp = -1;
  }
  if(key == 'f')
    flashlightOn = !flashlightOn;
  if(key == '-')
    planetRadius -= 1;
  if(key == '=')
    planetRadius += 1;
}

void keyReleased() {
  if(key == 'w' || key == 's' || key == 'a' || key == 'd')
    moving = false;
}

void mousePressed(){
  if(camAY == 0 && persp != -1)
     return;
  else{
  pickX = posX + -1*posY*tan(radians(90-camAY)) * cos(radians(90-camAX));
  pickY = posZ + -1*posY*tan(radians(90-camAY)) * sin(radians(90-camAX));
  }
  planetDropped = true;
}

void mouseReleased(){
   planetDropped = false;
   PVector mousePath = new PVector(pickX-endPickX, pickY-endPickY);
   pList.add(new Planet(pickX, pickY, 
   sqrt(pow(pickX-endPickX,2) + pow(pickY-endPickY,2))/50, 
   mousePath.heading(), 
   pow(planetRadius,2), 
   color(random(255),random(255),random(255))));
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if(e > 0)
    planetRadius-=0.2;
   else
    planetRadius+=0.2;
}

void updatePos(){
  if(key == 'w'){
    posX += sin(radians(camAX)) * cos(radians(camAY))*speed;
    posY += sin(radians(camAY))*speed;
    posZ += cos(radians(camAX)) * cos(radians(camAY))*speed;
  }
  if(key == 's'){
    posX -= sin(radians(camAX)) * cos(radians(camAY))*speed;
    posY -= sin(radians(camAY))*speed;
    posZ -= cos(radians(camAX)) * cos(radians(camAY))*speed;
  }
  if(key == 'd'){
    posX += sin(radians(camAX-90))*speed;
    posZ += cos(radians(camAX-90))*speed;
  }
  if(key == 'a'){
    posX -= sin(radians(camAX-90))*speed;
    posZ -= cos(radians(camAX-90))*speed;
  }
}

void drawOrbits(){
  push();
  noFill();
  rotateX(PI/2);
  stroke(255);
  for(int i = 1; i < 9; i++)
  circle(0,0,i*100);
  pop();
}

void drawSun(){
  push();
  noFill();
  noStroke();
  sun.disableStyle();
  sun.setTexture(sunTexture);
  if(persp!=0)
  shape(sun);
  pointLight(255,255,255,0,0,0);
  pointLight(255,255,255,0,0,0);
  pop();
}

void drawStart(){
  push();
  noStroke();
  translate(pickX, 0, pickY);
  fill(255);
  sphere(planetRadius);
  pop();
}

void drawPlanets(){
 for(int i = 0; i < pList.size(); i++){
   if(i == 0){
     drawSun();
     continue; //skip the sun for all the attractions
   }
   Planet p = pList.get(i);
   if(abs(p.pos.x) >= 2000 || abs(p.pos.y) >= 2000 || (abs(p.pos.x) <= 30 && abs(p.pos.y) <= 30)){
      pList.remove(i);
      i--;
      continue;
   }
   for (int j = 0; j < pList.size(); j++){
      if (i==j) {
        j++;
        continue;//A planet should not be able to attract itself
      }
      else p.attract(pList.get(j));
      if(p.distanceTo(pList.get(j)) < sqrt(p.m)+sqrt(pList.get(j).m)){
        Planet p2 = pList.get(j);
         exList.add(new Explosion(explosionTexture, (p.pos.x + p2.pos.x)/2, (p.pos.y + p2.pos.y)/2, sqrt(p.m)+sqrt(pList.get(j).m)));
         if(i > j){
           pList.remove(j);
           pList.remove(i-1);
         }
         else{
           pList.remove(i);
           pList.remove(j-1);
         }
      }
   }
   p.move();
   if(i != persp)
     p.show();
 }
}

void draw2DLayer(PGraphics gui){
  gui.text("position: (" + (int)posX + ", " + (int)posZ + ", " + (int)posY + ")",10,15);
  gui.text("camera facing: (" + camAX + "°, " + -1*camAY + "°)",10,30);
  gui.text("Instructions:", 10, 50);
  gui.text("Drag mouse to place and shoot planet",10,65);
  gui.text("Spacebar to change perspective",10,80);
  gui.text("F to turn on/off flashlight",10,95);
  gui.text("Mouse scroll to adjust planet size (or -/= key)",10,110);
  gui.text("current planet size: " + (int)(planetRadius*10)/10.0, 10, 135);
  gui.push();
  gui.noStroke();
  gui.ellipse(10 + planetRadius*3/2, 150 + planetRadius*3/2, planetRadius*3, planetRadius*3);
  gui.pop();
  
  gui.stroke(255,0,0);
  gui.strokeWeight(2);
  gui.line(width/2-10,height/2, width/2+10, height/2);
  gui.line(width/2,height/2-10, width/2, height/2+10);
  
  String perspectiveName = "Free Camera";
  if(persp == 0)
    perspectiveName = "perspective: Sun";
  if(persp > 0)
    perspectiveName = "perspective: Planet " + persp;
  gui.push();
  gui.textSize(30);
  gui.text(perspectiveName, width/2 - textWidth(perspectiveName), height - 50);
  gui.pop();
}


void draw() {
  noCursor();
  
  background(0);
  if(moving)
    updatePos();
  
  
  if(mouseX !=0 && mouseY != 0){
    camAX -= (mouseX-width/2)/4;
    camAY += (mouseY-height/2)/4;
    if(camAY > 89)
      camAY = 89;
    if(camAY < -89)
      camAY = -89;
  }
  camAX %= 360;
  
  ((GLWindow)getSurface().getNative()).warpPointer(width / 2, height / 2);
  // set clipping distance and camera angle
  float fov = PI/3.0;
  float cameraZ = (height/2.0) / tan(fov/2.0);
  float nearClippingDistance = 0.01; // default is cameraZ/10.0
  perspective(fov, float(width)/float(height), nearClippingDistance, cameraZ*10.0);
  if(persp >= pList.size())
    persp = -1;
  if(persp == -1){
    camera(posX, posY, posZ, // eyeX, eyeY, eyeZ
           posX + sin(radians(camAX)) * cos(radians(camAY))*20, 
           sin(radians(camAY))*20 + posY, 
           posZ + cos(radians(camAX)) * cos(radians(camAY))*20, // centerX, centerY, centerZ
           0.0, 1.0, 0.0); // upX, upY, upZ
  }
  else if(persp == 0)
    camera(0,0,0,sin(radians(camAX)) * cos(radians(camAY))*20,0,cos(radians(camAX)) * cos(radians(camAY))*20,0.0, 1.0, 0.0);
  else
    camera(pList.get(persp).pos.x,0,pList.get(persp).pos.y,0,0,0,0.0, 1.0, 0.0);
  if(flashlightOn && persp == -1)
    pointLight(255,255,255,posX,posY,posZ);
  
  drawPlanets();
  
  drawOrbits();
  
  if(planetDropped){
    drawStart();
    endPickX = posX + -1*posY*tan(radians(90-camAY)) * cos(radians(90-camAX));
    endPickY = posZ + -1*posY*tan(radians(90-camAY)) * sin(radians(90-camAX));
    push();
    stroke(128);
    strokeWeight(3);
    line(pickX,0,pickY,endPickX,0,endPickY);
    pop();
  }
  
  if(!exList.isEmpty()){
   for(int i = 0; i < exList.size(); i++){
    int a = exList.get(i).update();
    if(a == -1){
      exList.remove(i);
      i--;
    }
    else{
     exList.get(i).show(); 
    }
   }
  }
  
  gui.beginDraw();
  gui.background( 129 );
  draw2DLayer(gui);
 // put arbitrary 2D-code here
  gui.endDraw();
  gui.loadPixels();
  loadPixels();
  for(int i=0;i<pixels.length;i++)
    if( gui.pixels[i]!=color(129) ) pixels[i] = gui.pixels[i];
      updatePixels();
  gui.updatePixels();
}
