//očekujem 3 stanja koja moramo implementirati
//stanje==0 će biti početni ekran
//stanje==1 je igra
//stanje==2 je game over screen

int stanje=0, var=0; 
PFont font; 
PImage bg;
float ax=.32, ay=.32;
Screen mainScreen;
Character player;

class Screen {
  float speed;
  Screen() {
    speed = 0;
  }
}


class Character {
  float posx, posy;
  float vx=0, vy=0; 
  PImage sprite;
  float speed;
  boolean onGround=false;
  Screen screen;

  Character( Screen scr ) {
    screen = scr;
    posx = width/2-30;
    posy = height-70;
    sprite=loadImage("harold.jpg");
    sprite.resize(60, 70);
  }

  void jump()
  {
    vy+=ay;
    posy+=vy;
    if (posy > height-sprite.height)
    {
      //hary=height-harold.height; 
      vy=0; 
      onGround=true;
    }
    
    //ako smo stisli space i nismo u letu, nego smo na površini(onGround==true, onda skacemo
    if (keyPressed && key==' ' && onGround)
    {
      vy=-10; 
      onGround=false;
    }
  }

  void move()
  {
    //ako su pritisnute tipke za lijevo i desno, one su CODED pa moramo ovako
    //izvršavati provjeru
    if (keyPressed && key==CODED)
    {
      if (keyCode==LEFT)
      { 
        vx-=0.2;
      }
      else if (keyCode==RIGHT)
      { 
        vx+=0.2;
      }
    }
    else if(onGround)
    {
      vx*=0.5;
    }
    vx = constrain(vx, -10, 10);
    posx += vx;
  }
  
  void keep_in_screen()
  {
    //ako haroldova dođe ispod visine, gotovi smo
    if (posy>=height-sprite.height/2)
      stanje=2; 
    //ako harold dođe do vrha, ne može ići više od toga
    if (posy-sprite.height<0)
      posy=sprite.height; 
    //moramo mu zabraniti i da iziđe izvan lijevih i desnih rubova
    if (posx<0)
      posx=0;
    if (posx+sprite.width>width)
      posx=width-sprite.width;
  }
}



void setup()
{
  Screen mainScreen = new Screen();
  player = new Character(mainScreen);

  size(900, 900);
  font=createFont("ComicSansMS-BoldItalic-48.vlw", 32);
  colorMode(HSB);
  noStroke();
}
void draw()
{
  if (stanje==0)
    pocetni_screen(); 
  else if (stanje==1)
    igra_screen(); 
  else if (stanje==2)
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
  fill(color(var, 255, 255));
  var++;
  if (var>255)var=0;
  text("Press any key to start", 3*height/4, 4*width/5);
  textSize(160);
  rotate(PI/6);
  text("ICY", 3*height/4, -width/5);
  text("TOWER", 3*height/4, -width/5+160);
  rotate(-PI/6);

  if (keyPressed && stanje==0)
    stanje=1; 
  //ako stisnemo neku tipku, onda prelazimo na igru
}

void igra_screen()
{  
  background(0);
  image(player.sprite, player.posx, player.posy);
  
  player.jump();
  player.move();
  player.keep_in_screen();
}

void kraj_screen()
{
  background(0);
  textAlign(CENTER);
  textFont(font); 
  fill(color(var, 255, 255));
  var++;
  if (var>255)var=0;
  textSize(220);
  text("GAME", height/2, width/3);
  text("OVER", height/2, width/3+220);
  textSize(20);
  text("Press 'space' to continue.", height/2, width/3+440);
  
  if(keyPressed && key == ' ') {
      Screen mainScreen = new Screen();
      player = new Character(mainScreen);
      stanje = 1;
    }
}
