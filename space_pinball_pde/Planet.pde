// partially copied from brodie's code bc I'm too lazy
// credit to https://github.com/brodiemilliken/Lecture-5-Attraction


class Planet{
  PVector pos, vel, acc;
  float m;
  color c;
  
  float diameter;
  
  public Planet(float x, float y, float speed, float direction, float mass, color col){
    pos = new PVector(x,y);
    vel = new PVector(speed * cos(direction), speed * sin(direction));
    acc = new PVector(0,0);
    m = mass;
    c = col;
  } 
  
  void show(){
    noStroke();
    float diameter = sqrt(m);
    push();
    fill(c);
    translate(pos.x,0,pos.y);
    sphere(diameter);
    pop();
  }
  
  void move(){
    vel.add(acc);
    pos.add(vel);
    acc.set(0,0);
  }
  
  void attract(Planet o){
    //Gravity Equation: f = (G * m1 * m2) / r^2
    
    PVector thisPos = pos.copy();
    PVector otherPos = o.pos.copy();
    
    PVector force = thisPos.sub(otherPos);
    float distSq = force.magSq();
    
    float G = 0.98;
    
    float strength = G * (m *o.m)/distSq;
    
    force.setMag(strength);
    this.applyForce(force.mult(-1));
  }
  
  void applyForce(PVector force){
    PVector f = force.div(m);
    acc.add(f);
  }

  float distanceTo(Planet o){
    PVector copyPos = this.pos.copy();
    return copyPos.sub(o.pos).magSq();
  }
}
