class Explosion{
 float r;
 float x;
 float y;
 PImage t;
 float curR = 1;
 float frames = 10;
 Explosion(PImage texture, float posX, float posY, float radius){
   t = texture;
   x = posX;
   y = posY;
   r = radius*2;
 }
 
 int update(){
   curR += r/frames;
   if(curR < r)
     return 0;
   return -1; // animation ends
 }
 void show(){
   push();
   translate(x,0,y);
    PShape ex = createShape(SPHERE, curR);
    fill(255);
    ex.disableStyle();
    noFill();
    noStroke();
    ex.setTexture(t);
    ambientLight(255,255,255,x,0,y);
    shape(ex);
    pop();
 }
}
