//očekujem 3 stanja koja moramo implementirati
//stanje==0 će biti početni ekran
//stanje==1 je igra
//stanje==2 je game over screen

import java.util.Iterator;

boolean leftKeyPressed = false, rightKeyPressed = false, spaceKeyPressed = false;

// Klasa u kojoj su podatci o samim platformama po kojima lik skace
class Platform {

    float x, y, w, h  = 20; // Points of the platform
    int platformNumber;

    Platform(float _x, float _y, float _w, int _platformNumber)
    {
        x = _x;
        y = _y;
        w = _w;
        platformNumber = _platformNumber;
    }

    boolean isOnPlatform(Character player) { 
        if(player.fallSpeed() < 0) return false; // Ako igrac ide prema gore onda ne pada na platformu 

        // Width i height nam ne trebaju jer ih mi namjestamo na 60, odnosno 70
        if ( player.positionY() + 70 >= y - player.fallSpeed()  && player.positionY() + 70  <= y && // Provjeravamo hoce li igrac u sljedecem frameu biti na platformi
             player.positionX() + 60 >= x                       && player.positionX() <= x + w ) {
            player.setPositionY(y - 70); // Postavljamo igraca na platformu
            return true;
        }
        else {
            return false;
        }
    }

    boolean isOutOfBounds() {
        return (y > height);
    }

    void draw() {
        fill(204, 102, 0);
        rect(x, y, w, h);
    }

    void reduceHeight(float amount) {
        y += amount;
    }
}

// Klasa o ekranu na kojem crtamo platforme i kojeg pomicemo
class Screen {

    private float speed;
    private ArrayList<Platform> platforms;
    private int noOfPlatforms = 7;

    Screen() {    
        speed = 0; // Pocetna brzina treba bit nula jer se platforme tek micu kada igrac skoci prvi kat
        platforms = new ArrayList<Platform>();
    }

    float getSpeed() { // Mozda treba vratiti izracunatu brzinu iz moveScreen metode a ne fiksnu ??
        return speed;
    }

    void setSpeed(float v) {
        speed = v;
    }

    void draw() { // Imat ćemo 7 (podlozno promjenama) platformi najviše u isto vrijeme

        // Stvaramo prve platforme na pocetku igre
        if (platforms.size() == 0) {
            for (int i = 0; i < noOfPlatforms; i++) { // Dodajemo platformi koliko fali
                if (i == 0) { // Najdonja platforma
                    platforms.add(new Platform(0, height-20, width, 1));
                } else {
                    platforms.add(new Platform(100, platforms.get(platforms.size() - 1).y - (height/noOfPlatforms), 450, i + 1));
                }
            }
        } else if (platforms.get(0).isOutOfBounds()) { // Ako je najdonja platforma nestala onda nju izbacujemo iz liste i dodajemo novu platformu na vrh
            platforms.remove(0);
            Platform platformBefore = platforms.get(platforms.size() - 1);
            int platNo = platformBefore.platformNumber + 1;
            // Dodajemo novu platformu i ako je neki kat koji je djeljiv sa 100 onda je duzine cijelog ekrana
            platforms.add(new Platform(100, platformBefore.y - (height/noOfPlatforms), (platNo%100 == 0) ? width : 450, platNo));
        }

        for ( Platform pl : platforms) {
            pl.draw();
        }
    }

    ArrayList<Platform> getPlatforms()
    {
        return platforms;
    }

    void moveScreen(float playerPosX, float playerSpeed) { // Move screen dependent of plazer y position and his speed
        float moveAmount = speed; // Prvo postavimo na brzinu kojom se mice konstantno

        // Racunamo koliko ce se pomaknuti
        // TODO: Dodati ovaj izracun

        for ( Platform pl : platforms) {
            pl.reduceHeight(moveAmount);
        }
    }
}

// Klasa sa kojom pokrecemo lika i u kojoj su spremljeni njeni podaci
class Character {

    private float posx, posy;
    private float vx=0, vy=0; 
    private PImage sprite;
    private int run = 1;
    private boolean onGround=false;
    private Screen screen;

    Character( Screen scr ) {
        screen = scr;
        posx = width/2-30;
        posy = height-90;
        sprite=loadImage("harold-standing.png");
        sprite.resize(60, 70);
    }

    float positionX() {
        return posx;
    }

    float positionY() {
        return posy;
    }

    float fallSpeed() {
        return vy;
    }

    void setPositionY(float position) {
        posy = position;
    }

    void jump()
    { 
        // Uvijek se krecemo malo prema dolje u skladu sa brzinog ekrana
        posy += screen.getSpeed();

        if (isOnGround())
        {
            //hary=height-harold.height; 
            vy=0; 
            onGround=true;
        } else
        {
            vy+=ay;
            onGround = false;
        }

        // TODO: SKakanje se jos uvijek ponavlja ako drzimo neki smjer i skakanje
        //ako smo stisli space i nismo u letu, nego smo na površini(onGround==true, onda skacemo
        if (spaceKeyPressed && onGround)
        {
            vy=-10; 
            onGround=false;
            // screen.setSpeed(1); // TODO: Odmaknit
        }

        // vy = constrain(vy, -10, 10);
        posy+=vy;
    }

    void move()
    {
        // TODO: Popravit kretanje u lijevo i u desno
        //ako su pritisnute tipke za lijevo i desno, one su CODED pa moramo ovako
        //izvršavati provjeru
        if (leftKeyPressed)
        {
            vx-=(vx > 0) ? 2*ax : ax;
        }
        if (rightKeyPressed)
        { 
            vx+=(vx < 0) ? 2*ax : ax;
        } 
        if (onGround && !leftKeyPressed && !rightKeyPressed)
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
        posx = constrain(posx, 0, width-sprite.width);
        // U letu odbijaj lika od zidova
        if (!onGround && (posx == 0 || posx+sprite.width == width))
            vx *= (-1);
    }

    boolean isOnGround() {
        for ( Platform pl : screen.getPlatforms()) {
            if (pl.isOnPlatform(this))
            {
                return true;
            }
        }
        return false;
    }

    void setSprite() {
        String character = "harold";
        if (onGround)
        {
            if (vx < 1 & vx > -1) { // Ako se ne krece i stoji na zemlji
                sprite=loadImage(character + "-standing.png");
            } else {
                String image = character + "-run-"+str(run/10);
                run = (run+1)%40; // Mijenjamo sprite za trcanje svako 10 frameova

                if (vx < 0) { // Ako se krece lijevo
                    image += "-left";
                }

                image += ".png";
                sprite = loadImage(image);
            }
        
        }
        else if (keyPressed && key==' ') 
        {
            sprite=loadImage(character + "-jumping.png");
        }
        player.sprite.resize(60, 70);
    }
}

int stanje=0, var=0; 
PFont font; 
PImage bg;
float ax=.32, ay=.32;
Screen mainScreen;
Character player;

void setup()
{
    mainScreen = new Screen();
    player = new Character(mainScreen);
    size(900, 900);
    //font=createFont("ComicSansMS-BoldItalic-48.vlw", 32);
    font = createFont("Georgia", 32);
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

void keyPressed(){
    if (key==CODED)
        {
            if (keyCode==LEFT)
            { 
                leftKeyPressed = true;
            }
            if (keyCode==RIGHT)
            { 
                rightKeyPressed = true;
            }
        } else if (key == ' ')
        {
            spaceKeyPressed = true;
        }
}
 
void keyReleased(){
    if (key==CODED)
        {
            if (keyCode==LEFT)
            { 
                leftKeyPressed = false;
            }
            if (keyCode==RIGHT)
            { 
                rightKeyPressed = false;
            }
        } else if (key == ' ')
        {
            spaceKeyPressed = false;
        }
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
    if(keyPressed && key == 'r') {
        reset();    
    }
    
    background(100);

    mainScreen.draw();

    player.jump();
    player.move();
    player.setSprite();
    player.keep_in_screen();

    mainScreen.moveScreen(player.positionX(), player.positionY());

    image(player.sprite, player.posx, player.posy);
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
    text("Press 'ENTER' to continue.", height/2, width/3+440);

    if (keyPressed && key == ENTER) {
        reset();
    }
}

void reset() {
    mainScreen = new Screen();
    player = new Character(mainScreen);
    stanje = 1;
}
