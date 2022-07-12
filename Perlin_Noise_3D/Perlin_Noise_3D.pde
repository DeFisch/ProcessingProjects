import com.jogamp.newt.opengl.GLWindow;

float posX = width/2 + 10000+random(10000);
float posY = height/2 + 10000+random(10000);
float posZ = random(10000);
float camAX = 0; // camera angle x
float camAY = 0;
float speed = 10;
float scale = 20;
int mapX = (int)(posX/scale);
int mapY = (int)(posY/scale);
int mapZ = (int)(posZ/scale);
int loadCapacity = 20;
float noiseScale = 20;
boolean[][][] map = new boolean[loadCapacity*2][loadCapacity*2][loadCapacity*2];
boolean moving = false;
boolean paused = false;

void setup() {
  fullScreen(P3D);
  frameRate(60);
  fill(204);
  loadMap(mapX, mapY, mapZ);
  
  
  ((GLWindow)getSurface().getNative()).warpPointer(width / 2, height / 2);
}

boolean[][][] loadMap(int x, int y, int z){
  mapX = x;
  mapY = y;
  mapZ = z;
  for(int i = 0; i < 2 * loadCapacity; i++){
    for(int j = 0; j < 2 * loadCapacity; j++){
      for(int k = 0; k < 2 * loadCapacity; k++){
        map[i][j][k] = noise((i - loadCapacity + x)/noiseScale,(j - loadCapacity + y)/noiseScale,(k - loadCapacity + z)/noiseScale) > 0.5;
      }
    }
  }
  return map;
}

void drawMap(int x, int y, int z){
  for(int i = 0; i < 2 * loadCapacity; i++){
    for(int j = 0; j < 2 * loadCapacity; j++){
      for(int k = 0; k < 2 * loadCapacity; k++){
        if(map[i][j][k]){
          pushMatrix();
          fill(205);
          translate((mapX+i-loadCapacity)*scale,(mapY+j-loadCapacity)*scale,(mapZ+k-loadCapacity)*scale); //<>//
          //println(posX+(i-loadCapacity)*scale+" "+posY+(j-loadCapacity)*scale+" "+posZ+(k-loadCapacity)*scale);
          noStroke();
          box(scale);
          popMatrix();
        }
      }
    }
  }
}


void keyPressed() {
  if(key == 'w' || key == 's' || key == 'a' || key == 'd')
    moving = true;
  if(key == ' ')
    paused = true;
}

void keyReleased() {
  if(key == 'w' || key == 's' || key == 'a' || key == 'd')
    moving = false;
  if(key == ' ')
    paused = false;
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

void draw() {
  if(paused){
    cursor(CROSS);
    return;
  }
  noCursor();
  if(abs(posX - mapX*scale) > loadCapacity*scale/2 || abs(posY - mapY*scale) > loadCapacity*scale/2 || abs(posZ - mapZ*scale) > loadCapacity*scale/2)
    loadMap((int)(posX/scale), (int)(posY/scale), (int)(posZ/scale));
  
  pointLight(255,255,255,posX,posY,posZ);
  background(0);
  if(moving)
    updatePos();
  
  if(mouseX !=0 && mouseY != 0){
    camAX -= (mouseX-width/2)/10;
    camAY += (mouseY-height/2)/10;
    if(camAY > 90)
      camAY = 90;
    if(camAY < -90)
      camAY = -90;
  }
  camAX %= 360;
  ((GLWindow)getSurface().getNative()).warpPointer(width / 2, height / 2);
  
  camera(posX, posY, posZ, // eyeX, eyeY, eyeZ
         posX + sin(radians(camAX)) * cos(radians(camAY)), sin(radians(camAY)) + posY, posZ + cos(radians(camAX)) * cos(radians(camAY)), // centerX, centerY, centerZ
         0.0, 1.0, 0.0); // upX, upY, upZ
  

  drawMap(mapX,mapY,mapZ); //<>//
  
}
