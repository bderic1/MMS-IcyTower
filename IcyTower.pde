//očekujem 3 stanja koja moramo implementirati
//stanje==0 će biti početni ekran
//stanje==1 je igra
//stanje==2 je game over screen

int stanje=0, var=0; 
PFont font; 
PImage bg, harold;
void setup()
{
  size(900, 900);
  font=createFont("ComicSansMS-BoldItalic-48.vlw",32);
  colorMode(HSB);
  noStroke();
  harold=loadImage("harold.jpg");
  
  
}
void draw()
{
  if(stanje==0)
  pocetni_screen(); 
  else if(stanje==1)
  igra_screen(); 
  else if(stanje==2)
  kraj_screen(); 
 

}

void pocetni_screen()
{
  bg=loadImage("background1.jpg");
  bg.resize(width, height);
  background(bg);
  textAlign(CENTER);
  textSize(70); 
  textFont(font); 
  fill(color(var,255,255));
  var++;
  if(var>255)var=0;
  text("Press any key to start", 3*height/4, 4*width/5);
  textSize(160);
  rotate(PI/6);
  text("ICY", 3*height/4, -width/5);
  text("TOWER", 3*height/4, -width/5+160);
  rotate(-PI/6);
  
  //ako stisnemo neku tipku, onda prelazimo na igru
  
}
void igra_screen()
{  
  background(0);
  image(harold,width/2-harold.width/2, height-harold.height);

}
void kraj_screen()
{

}

void keyPressed()
{
if(stanje==0)
  stanje=1; 
  
}
