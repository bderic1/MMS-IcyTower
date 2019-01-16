//očekujem 3 stanja koja moramo implementirati
//stanje==0 će biti početni ekran
//stanje==1 je igra
//stanje==2 je game over screen

int stanje=0, var=0; 
PFont font; 
PImage bg, harold;
float harx, hary;
float ax=0,ay=.32; 
float vx=0, vy=0; 
boolean can_jump=false; 
void setup()
{
  size(900, 900);
  font=createFont("ComicSansMS-BoldItalic-48.vlw",32);
  colorMode(HSB);
  noStroke();
  harold=loadImage("harold.jpg");
  harx=width/2-30;
  hary=height-70;
  
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
  harold.resize(60,70);
  image(harold, harx, hary);
  jump();
  keep_in_screen();
  

}
void kraj_screen()
{
  background(0);
  textAlign(CENTER);
  textFont(font); 
  fill(color(var,255,255));
  var++;
  if(var>255)var=0;
  textSize(220);
  text("GAME", height/2, width/3);
  text("OVER", height/2, width/3+220);
}

void keyPressed()
{
if(stanje==0)
  stanje=1; 
if(stanje==1)
  { //ako smo stisli space i nismo u letu, nego smo na površini(can_jump==true, onda skacemo
     if(key==' ' && can_jump)
       {
         vy=-10; 
         can_jump=false; 
       }
  }
}
void jump()
{
  vy+=ay;
  hary+=vy;
  if(hary>height-harold.height)
  {
    //hary=height-harold.height; 
    vy=0; 
    can_jump=true;
  }
}

void keep_in_screen()
{
  //ako haroldova dođe ispod visine, gotovi smo
  if(hary>=height-harold.height/2)
      stanje=2; 
  //ako harold dođe do vrha, ne može ići više od toga
   if(hary-harold.height<0)
      hary=harold.height; 
   //moramo mu zabraniti i da iziđe izvan lijevih i desnih rubova
   if(harx-harold.width<0)
   harx=harold.width;
   if(harx+harold.width>width)
   harx=width-harold.width;
      
}
