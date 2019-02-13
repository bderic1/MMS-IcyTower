//očekujem 3 stanja koja moramo implementirati
//stanje==0 će biti početni ekran
//stanje==1 je igra
//stanje==2 je game over screen

import java.util.Iterator;
import java.util.Map;

// TODO: Ima bug koji ponekad pri skakanju blizu vrha dovodi do toga da lik zna proci kroz platforme
//       Koliko sam shvatio desava se ako lik prijede neku platformu na nacin da prijedje vrh al ne dovoljno da stane na nju. ALi desava se samo nekada.
//       Cini mi se da sam mozda popravio al tesko je dokazat dok se ne dogodi

// TODO: Implementirati comboe
// TODO: Level design (Kolike će bit platforme i kada i na kojim pozicijama)
// TODO: Možda popravit spriteove tako da su malo smisleniji. Ovako su animacije malo čudne. Trebalo bi možda koristit male spriteove i image.width i image.height umjesto fiksne veličine

// Klasa u kojoj su podatci o samim platformama po kojima lik skace
class Platform {

    private float x, y, w, h  = 30; // Parametri platforme
    private int platformNumber;

    Platform(float _x, float _y, float _w, int _platformNumber)
    {
        x = _x;
        y = _y;
        w = _w;
        platformNumber = _platformNumber;
    }

    int getPlatformNumber()
    {
        return platformNumber;
    }

    boolean isOnPlatform(Character player) 
    { 
        if (player.verticalSpeed() < 0) return false; // Ako igrac ide prema gore onda ne pada na platformu 

        // Provjeravamo hoce li igrac u sljedecem frameu biti na platformi
        if ( player.positionY() + player.getSpriteHeight() >= y - player.verticalSpeed()  && player.positionY() + player.getSpriteHeight()  <= y && 
             player.positionX() + player.getSpriteWidth() >= x && player.positionX() <= x + w ) // Gledamo je li lijevi rub igraca lijevo od desnog ruba platforme i ubrnuto
        { 
            player.setPositionY(y - player.getSpriteHeight()); // Postavljamo igraca na platformu
            return true;
        } else 
        {
            return false;
        }
    }

    // | -1 = lijevi rub | 0 = nije na rubu | 1 = desni rub |
    int isOnLedge(Character player) 
    { 
        if (player.positionX() +   player.getSpriteWidth()/3 <= x + 10)     return -1;
        if (player.positionX() + 2*player.getSpriteWidth()/3 >= x + w - 10) return 1;
        return 0;
    }

    boolean isOutOfBounds() 
    {
        return (y > height); 
    }

    void draw() 
    {
        fill(204, 102, 0);
        rect(x, y, w, h);
        if (platformNumber % 10 == 0) 
        {
            textFont(createFont("Arial Bold", 18));
            fill(255);
            text(str(platformNumber), x + w/2, y + 2*h/3);
        }
    }

    void reduceHeight(float amount) 
    {
        y += amount;
    }
}

// Klasa o ekranu na kojem crtamo platforme i kojeg pomicemo
class Screen {

    private float speed;
    private int level;
    private ArrayList<Platform> platforms;
    private int noOfPlatforms = 7;
    private float screenStart = 100, screenEnd = width - screenStart; // Imat cemo rubove na ekranu pa nam ovo treba (Height ne trebamo jer su rubovi samo lijevo i desno)
    private float maxPlatformWidth = 350;

    float getScreenStart()
    {
        return screenStart;
    }

    float getScreenEnd()
    {
        return screenEnd;
    }

    Screen() 
    {    
        level = 0; // Pocetna brzina treba bit nula jer se platforme tek micu kada igrac skoci prvi kat
        platforms = new ArrayList<Platform>();
    }

    float getSpeed() 
    { // Mozda treba vratiti izracunatu brzinu iz moveScreen metode a ne fiksnu ??
        return speed;
    }

    void setLevel(int v) 
    {
        level = v;
    }

    ArrayList<Platform> getPlatforms()
    {
        return platforms;
    }

    void draw() 
    { // Imat ćemo 7 (podlozno promjenama) platformi najviše u isto vrijeme

        // Crtamo prvo rubove
        fill(204, 102, 0);
        rect(0, 0, screenStart, height); // Lijevi rub
        rect(screenEnd, 0, screenStart, height); // Desni rub (sirina je ista u oba ruba)

        

        // Stvaramo prve platforme na pocetku igre
        if (platforms.size() == 0) 
        {
            for (int i = 0; i < noOfPlatforms; i++) // Dodajemo platformi koliko fali
            { 
                if (i == 0) // Najdonja platforma
                { 
                    platforms.add(new Platform(screenStart + 0, height-20, screenEnd, 1));
                } else 
                {
                    float platformWidth = random(maxPlatformWidth - 150, maxPlatformWidth);
                    platforms.add(new Platform(random(screenStart + 10, screenEnd - platformWidth - 10), platforms.get(platforms.size() - 1).y - (height/noOfPlatforms), platformWidth, i + 1));
                }
            }
        } else if (platforms.get(0).isOutOfBounds()) 
        { // Ako je najdonja platforma nestala onda nju izbacujemo iz liste i dodajemo novu platformu na vrh
            platforms.remove(0);
            Platform platformBefore = platforms.get(platforms.size() - 1);
            int platNo = platformBefore.platformNumber + 1;

            float platformWidth = (platNo < 200) ? random(maxPlatformWidth*(1-(platNo/1000)) - 150, maxPlatformWidth*(1-(platNo/1000))) : 200;
            // Dodajemo novu platformu i ako je neki kat koji je djeljiv sa 50 onda je duzine cijelog ekrana
            platforms.add(new Platform(( (platNo%50 == 0) ? screenStart : random(screenStart + 10, screenEnd - platformWidth - 10) ), 
                                       platformBefore.y - (height/noOfPlatforms), 
                                       (platNo%50 == 0) ? screenEnd :  platformWidth, 
                                       platNo));

            // Ako je platforma djeljiva sa 100 onda povećamo brzinu za 1
            // TODO: Brzina se povećava ovisno o timeru a ne katu
            // Zelimo li da je timer ovisan o frameovima ili da je real-time?
            if (platNo%100 == 0) level++;
        }

        for ( Platform pl : platforms) 
        {
            pl.draw();
        }
    }

    void moveScreen(float playerPosY, float playerVerticalSpeed) // Pomakni ekran ovisno o igracevoj poziciji i brzini kretanja
    { 
        // Racunamo koliko ce se pomaknuti
        // TODO: Dodati ovaj izracun

        speed = level;
        if (playerPosY < height/4 && playerVerticalSpeed < 0)
            speed += abs(playerVerticalSpeed) * map(playerPosY, height/4, -10, 0, 1);

        for ( Platform pl : platforms) 
        {
            pl.reduceHeight(speed);
        }
    }
}


// Klasa sa kojom pokrecemo lika i u kojoj su spremljeni njeni podaci
class Character {

    private float posx, posy;
    private float vx=0, vy=0; 
    private float ax=.32, ay=.32;
    private PImage sprite;
    private int run = 0, ledge = 0, standing = 0, rotation = 0;
    private boolean onGround=false;
    private Screen screen;
    String character;
    private HashMap<String, PImage> sprites = new HashMap<String, PImage>();   
    ;
    private int currentPlatformIndex, currentPlatformNumber;

    Character( Screen scr, String _character) 
    {
        screen = scr;
        posx = (screen.getScreenStart() + screen.getScreenEnd())/2-30; 
        posy = height-90;
        character = _character;
        loadSprites();
        sprite = sprites.get("jumping");
    }

    void loadSprites() 
    {

        sprites.put("jumping", loadImage(character + "-jumping.png"));
        sprites.put("jumping-right", loadImage(character + "-jumping-right.png"));
        sprites.put("jumping-left", loadImage(character + "-jumping-left.png"));
        sprites.put("jumping-top-right", loadImage(character + "-jumping-top-right.png"));
        sprites.put("jumping-top-left", loadImage(character + "-jumping-top-left.png"));
        sprites.put("falling-right", loadImage(character + "-falling-right.png"));
        sprites.put("falling-left", loadImage(character + "-falling-left.png"));
        sprites.put("combo", loadImage(character + "-combo.png"));
        for (int i = 0; i < 4; ++i) 
        {
            sprites.put("run-" + str(i) + "-left", loadImage(character + "-run-" + str(i) + "-left.png"));
            sprites.put("run-" + str(i) + "-right", loadImage(character + "-run-" + str(i) + "-right.png"));

            if (i < 3) // Standing nema 3
            { 
                sprites.put("standing-" + str(i), loadImage(character + "-standing-" + str(i)+ ".png"));
            }
            if (i < 2) // Ledge nema 2 i 3
            { 
                sprites.put("left-ledge-" + str(i), loadImage(character + "-left-ledge-" + str(i) + ".png"));
                sprites.put("right-ledge-" + str(i), loadImage(character + "-right-ledge-" + str(i) + ".png"));
            }
        }
    }

    void setSprite() 
    {        
        if(isInCombo()) // Crta 'combo' sprite i rotira ga
        {
            sprite = sprites.get("combo");
            sprite.resize(60, 70);
            pushMatrix();
            imageMode(CENTER);
            translate(posx, posy);
            rotate(rotation/5); rotation++;
            image(sprite,0,0);
            popMatrix();
            imageMode(CORNER);
        }
        else 
        {
        if (onGround)
        {
            if ( vx > -1 && vx < 1 ) // Ako se ne krece i stoji na zemlji
            { 

                // Ako je igrac na rubu platforme 
                int isPlayerOnLedge = screen.getPlatforms().get(currentPlatformIndex).isOnLedge(this);
                if (abs(isPlayerOnLedge) == 1) 
                { 
                    String image = "-ledge-"+str(ledge/10);
                    ledge = (ledge+1)%20; // Mijenjamo sprite za rub svako 10 frameova
                    image = ((isPlayerOnLedge == -1) ? "left" : "right") + image;
                    sprite = sprites.get(image);
                } else 
                {
                    sprite = sprites.get("standing-"+str(standing/20));
                    standing = (standing+1)%60; // Mijenjamo sprite za rub svako 20 frameova
                }
            } else 
            {
                String image = "run-"+str(run/10);
                run = (run+1)%40; // Mijenjamo sprite za trcanje svako 10 frameova
                image += (vx < 0) ? "-left" : "-right";
                sprite = sprites.get(image);
            }
        } else
        {
            if ( vx > -1 && vx < 1 ) // Ako se ne krece desno ili lijevo
            { 
                sprite = sprites.get("jumping");
            } else 
            {
                
                if (vy > -3 && vy < 3 ) // Ako leti i u vrhu je skoka
                { 
                    sprite = sprites.get("jumping-top" + ( (vx < 0) ? "-left" : "-right") );
                } else 
                {
                    String image = (vy < 0) ? "jumping" : "falling";
                    image += (vx < 0) ? "-left" : "-right";
                    sprite = sprites.get(image);
                }
            }
        }
        sprite.resize(60, 70);
        image(sprite, posx, posy);
        }

    }

    float getSpriteWidth() 
    {
        return 60;
    }

    float getSpriteHeight() 
    {
        return 70;
    }

    float positionX() 
    {
        return posx;
    }

    float positionY() 
    {
        return posy;
    }

    float verticalSpeed() 
    {
        return vy;
    }

    void setPositionY(float position) 
    {
        posy = position;
    }

    void setCurrentPlatformIndex(int platformNo) 
    {
        currentPlatformIndex = platformNo;
    }

    void setCurrentPlatformNumber(int platformNo) 
    {
        currentPlatformNumber = platformNo;
    }

    void move()
    {
        horizontalMovement();

        verticalMovement();

        keepInScreen();
        setSprite();
    }

    void horizontalMovement()
    {
        // Horizontalne kretnje
        if (leftKeyPressed)
        {
            vx-=(vx > 0) ? 1.5*ax : ax;
        }
        if (rightKeyPressed)
        { 
            vx+=(vx < 0) ? 1.5*ax : ax;
        } 
        if (onGround && !leftKeyPressed && !rightKeyPressed)
        {
            vx*=0.9;
        }

        vx = constrain(vx, -15, 15);
        posx += vx;

    }

    void verticalMovement()
    {
        // Vertikalne kretnje (skakanje)
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

        //ako smo stisli space i nismo u letu, nego smo na površini(onGround==true, onda skacemo
        if (spaceKeyPressed && onGround)
        {
            vy=-10 - abs(vx / 2);  // Vertikalnu brzinu mijenjamo ovisno o horizontalnoj TODO: Mozda pametnije napisat?
            onGround=false;

            if (currentPlatformIndex > 2) // Ako prijedjemo drugo platformu onda se ekran pocinje kretati
            {
                screen.setLevel(1);
            }
        }

        vy = constrain(vy, -20, 20);
        posy+=vy;
        // Uvijek se krecemo malo prema dolje u skladu sa brzinog ekrana
        posy += screen.getSpeed();
    }

    boolean isInCombo() // Provjeravamo je li combo
    { 
        return false;
    }

    void keepInScreen()
    {
        //ako haroldova dođe ispod visine, gotovi smo
        if (posy>=height-sprite.height/2)
            stanje=2; 

        //ako harold dođe do vrha, ne može ići više od toga (ostalo -10 jer u originalu on udje malo u strop al vuce ekran za sobom pa nema problema i izgleda prirodno)
        if (posy <= -10)
            posy=-10; 

        //moramo mu zabraniti i da iziđe izvan lijevih i desnih rubova
        posx = constrain(posx, screen.getScreenStart(), screen.getScreenEnd()-sprite.width);

        // Odbijaj lika od zidova
        if (posx == screen.getScreenStart() || posx + sprite.width == screen.getScreenEnd())
            vx *= (-0.5);
    }

    boolean isOnGround() 
    {
        for ( Platform pl : screen.getPlatforms()) 
        {
            if (pl.isOnPlatform(this))
            {
                player.setCurrentPlatformIndex(screen.getPlatforms().indexOf(pl));
                player.setCurrentPlatformNumber(pl.getPlatformNumber());
                return true;
            }
        }
        return false;
    }
}

int stanje=0, var=0; 
PFont font; 
PImage bg;
Screen mainScreen;
Character player;
boolean leftKeyPressed = false, rightKeyPressed = false, spaceKeyPressed = false;
String pickedCharacter;


void setup()
{
    mainScreen = new Screen();
    size(900, 900);
    //font=createFont("ComicSansMS-BoldItalic-48.vlw", 32);
    font = createFont("Georgia", 32);
    colorMode(HSB);
    noStroke();
}

void draw()
{
    if (stanje==0)
        startScreen(); 
    else if (stanje==1)
        gameScreen(); 
    else if (stanje==2)
        endScreen();
}


void startScreen()
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
    text("Press any key to start \n ('d' to play with Disco Dave)", 3*height/4, 4*width/5);
    textSize(160);
    rotate(PI/6);
    text("ICY", 3*height/4, -width/5);
    text("TOWER", 3*height/4, -width/5+160);
    rotate(-PI/6);

    if (keyPressed && stanje==0) 
    {
        pickedCharacter = (key == 'd') ? "dave" : "harold";
        player = new Character(mainScreen, pickedCharacter);
        stanje=1;
    }
    //ako stisnemo neku tipku, onda prelazimo na igru
}

void gameScreen()
{  
    if (keyPressed && key == 'r') 
    {
        reset();
    }

    background(100);

    mainScreen.draw();

    player.move(); // U njemu pomicemo i crtamo

    mainScreen.moveScreen(player.positionY(), player.verticalSpeed());
}

void endScreen()
{
    background(0);
    textAlign(CENTER);
    textFont(font); 
    fill(color(var, 255, 255));
    var++;
    if (var>255)var=0;
    textSize(220);
    text("GAME", height/2, width/3);
    text("OVER", height/2, width/3 + 220);
    textSize(20);
    text("Press 'ENTER' to continue.", height/2, width/3+440);

    if (keyPressed && key == ENTER) 
    {
        reset();
    }
}

void reset() {
    mainScreen = new Screen();
    player = new Character(mainScreen, pickedCharacter);
    stanje = 1;
}

// Ako su pritisnute tipke za lijevo i desno, one su CODED pa moramo ovako
// izvršavati provjeru

void keyPressed() {
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

void keyReleased() {
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
