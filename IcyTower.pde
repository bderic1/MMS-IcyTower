//očekujem 3 stanja koja moramo implementirati
//stanje==0 će biti početni ekran
//stanje==1 je igra
//stanje==2 je game over screen

import java.util.Iterator;
import java.util.Map;

// FIXME: Ima bug koji ponekad pri skakanju blizu vrha dovodi do toga da lik zna proci kroz platforme.
//        Cini mi se da se to sada desava samo kada je combo sprite

// TODO: Implementirati comboe
// TODO: Level design (Kolike će bit platforme i kada i na kojim pozicijama)
// TODO: Možda popravit spriteove tako da su malo smisleniji. Ovako su animacije malo čudne.

// Klasa u kojoj su podatci o samim platformama po kojima lik skace
class Platform {

    private float x, y, w, h  = 40; // Parametri platforme
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

    boolean isOnPlatform(Character player, boolean usingComboSprite) 
    { 
        if (player.verticalSpeed() < 0) return false; // Ako igrac ide prema gore onda ne pada na platformu 

        // TODO: Obrisati
        // if(platformNumber == 1){
        //     println(' ');
        //     println("uvjet na y 1: " + (player.positionY() + player.getSpriteHeight() >= y - player.verticalSpeed()));
        //     println("uvjet na y 2: " + (player.positionY() + player.getSpriteHeight()  <= y));
        //     println(str(player.positionY()) + ' ' + str(player.getSpriteHeight()) + ' ' + str(player.verticalSpeed()) + ' ' + str(y));
        //     println(str(player.positionY() + player.getSpriteHeight()) + ' '  + str(y - player.verticalSpeed()));
        //     }


        // Provjeravamo hoce li igrac u sljedecem frameu biti na platformi 
        if(usingComboSprite) // Combo sprite su posx i posy po sredini spritea
        {
            if ( player.positionY() + player.getSpriteHeight()/2 >= y - player.verticalSpeed()  && // Hoce li igrac pasti na platformu u iducem frame-u
                 player.positionY() + player.getSpriteHeight()/2  <= y && 
                 player.positionX() + player.getSpriteWidth()/2 >= x && 
                 player.positionX() - player.getSpriteWidth()/2 <= x + w ) // Gledamo je li lijevi rub igraca lijevo od desnog ruba platforme i ubrnuto
            { 
                player.setPositionY(y - player.getSpriteHeight()); // Postavljamo igraca na platformu
                return true;
            } 
        }
        else if ( player.positionY() + player.getSpriteHeight() >= y - player.verticalSpeed()  && // Hoce li igrac pasti na platformu u iducem frame-u
                  player.positionY() + player.getSpriteHeight()  <= y && 
                  player.positionX() + player.getSpriteWidth() >= x && 
                  player.positionX() <= x + w ) // Gledamo je li lijevi rub igraca lijevo od desnog ruba platforme i ubrnuto
        { 
            player.setPositionY(y - player.getSpriteHeight()); // Postavljamo igraca na platformu
            return true;
        } 
        
        return false;
        
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
    private int noOfPlatforms = 8;
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
    private float ax=.32, ay=.64;
    private PImage sprite;
    private int run = 0, ledge = 0, standing = 0, rotation = 0;
    private boolean onGround=false, usingComboSprite=false, jumpedFromPlatform=false, firstLanding=false, isInCombo=false;
    private Screen screen;
    String character;
    private HashMap<String, PImage> sprites = new HashMap<String, PImage>();   
    private int currentPlatformIndex, currentPlatformNumber, previousPlatformNumber, comboCount, comboTimer=0;
    private float startingJumpSpeed;

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
        if(isInCombo && abs(startingJumpSpeed) > 10 && jumpedFromPlatform) // Crta 'combo' sprite i rotira ga
        {
            // FIXME: Cini mi se da combo sprite se ne ocitava dobro i nekad prolazi kroz platforme kad se cini da ne bi trebao
            usingComboSprite = true;
            sprite = sprites.get("combo");            
            pushMatrix();
            imageMode(CENTER);
            translate(posx, posy);
            rotate(rotation/5); rotation++;
            image(sprite,0,0);
            popMatrix();
            imageMode(CORNER);
            sprite.resize(0, 70);
            // image(sprite, posx, posy);
        }
        else 
        {
        usingComboSprite = false;
        if (onGround)
        {
            if (abs(vx) < 1) // Ako se ne krece i stoji na zemlji
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
            if (abs(vx) < 1) // Ako se ne krece desno ili lijevo
            { 
                sprite = sprites.get("jumping");
            } else 
            {
                
                if (abs(vy) < 3) // Ako leti i u vrhu je skoka
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
        // sprite.resize(60, 70);
        sprite.resize(0, 70);
        image(sprite, posx, posy);
        }

    }

   
    void move()
    {
        horizontalMovement();
        verticalMovement();

        keepInScreen();
        setSprite();

        // Drawing combo counter
        textFont(createFont("Arial Bold", 18));
        fill(255);
        text(str(comboCount), 20, 20);

        // Drawing combo bar
        fill(255);
        rect(15, 45, 20, 190);
        fill(0);
        rect(20, 50, 10, 180);
        fill(125);
        rect(20, 50 + 180 - comboTimer, 10, comboTimer);

        //TODO: brisati
        textFont(createFont("Arial Bold", 18));
        fill(255);
        text(str(round(frameRate)), 50, 850);
        

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
            vy=0; 
            onGround=true;
            jumpedFromPlatform = false;
        } else
        {
            previousPlatformNumber = currentPlatformNumber;
            vy+=ay;
            onGround = false;
        }

        // Provjeravamo combo ovdje u slucaju da igrac odma odskoci od platforme pa cemo zabiljeziti tu platformu
        checkForCombo();

        // TODO: Mozda napraviti da, ako se samo drzi space, bar u jednom frameu dotakne platformu a ne odma skakati dalje

        //ako smo stisli space i nismo u letu, nego smo na površini(onGround==true, onda skacemo
        if (spaceKeyPressed && onGround)
        {
            vy=-12 - abs(vx);  // Vertikalnu brzinu mijenjamo ovisno o horizontalnoj 
            onGround=false;
            previousPlatformNumber = currentPlatformNumber;
            startingJumpSpeed = vx;
            jumpedFromPlatform = true; // Oznacavamo da je skocio sa platforme a ne pao

            if (currentPlatformIndex > 2) // Ako prijedjemo drugo platformu onda se ekran pocinje kretati
            {
                screen.setLevel(1);
            }
        }

        vy = constrain(vy, -30, 30);
        posy+=vy;

        // Uvijek se krecemo malo prema dolje u skladu sa brzinog ekrana
        posy += screen.getSpeed();
    }

    boolean checkForCombo() // Provjeravamo je li combo
    { 
        // FIXME: jedan frame je u combo a drugi nije prije samog pocetka comboa
        // Sa wiki:
        // A combo ends when a player makes a jump which covers only one floor, 
        // falls off a floor and lands on a lower floor, 
        // or fails to make a jump within a certain time frame (about 3 seconds).
        if(currentPlatformNumber == previousPlatformNumber + 1 || previousPlatformNumber > currentPlatformNumber || comboTimer < 0 ) 
        {
            comboCount = 0;
            comboTimer = 0;
            isInCombo = false;
            return false;
        }

        if(onGround && firstLanding && currentPlatformNumber != previousPlatformNumber) // Zadnji uvjet pazi da nismo skocili na istu platformu
        {
            comboTimer = 180;
            firstLanding = false;
            comboCount += currentPlatformNumber - previousPlatformNumber;
        }
        else if(!onGround)
        {
            firstLanding = true;
        }
        
        if(comboCount != 0)
            comboTimer--;
        isInCombo = true;
        return true;
    }

    void keepInScreen()
    {
        //ako haroldova dođe ispod visine, gotovi smo
        if (posy>=height-sprite.height/2)
            stanje=2; 

        //ako harold dođe do vrha, ne može ići više od toga (ostalo -10 jer u originalu on udje malo u strop al vuce ekran za sobom pa nema problema i izgleda prirodno)
        if (posy <= -10)
            posy=-10; 

        // Treba nam jer za vrijeme comboa sprite je centriran
        float comboSpriteHalf = (usingComboSprite) ? sprite.width/2 : 0;

        //moramo mu zabraniti i da iziđe izvan lijevih i desnih rubova
        posx = constrain(posx, screen.getScreenStart() + comboSpriteHalf, screen.getScreenEnd()-sprite.width+comboSpriteHalf);

        // Odbijaj lika od zidova
        if (posx - comboSpriteHalf == screen.getScreenStart() || posx + sprite.width - comboSpriteHalf == screen.getScreenEnd())
        {
            vx *= (-0.5);
        }
    }

    boolean isOnGround() 
    {
        for ( Platform pl : screen.getPlatforms()) 
        {
            if (pl.isOnPlatform(this, usingComboSprite))
            {
                player.setCurrentPlatformIndex(screen.getPlatforms().indexOf(pl));
                player.setCurrentPlatformNumber(pl.getPlatformNumber());
                return true;
            }
        }
        return false;
    }

     // Dijelimo sa 2 kad je combo sprite jer je on centriran a ne pocinje od ruba 
    float getSpriteWidth() 
    {
        return sprite.width;
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

    void setPositionY(float position) 
    {
        posy = position;
    }

    float verticalSpeed() 
    {
        return vy+ay; // Dodajemo u ay jer nam je bitno gdje ce lik biti iduci frame tako da znamo hoce li sletiti na platformu
    }

    void setCurrentPlatformIndex(int platformNo) 
    {
        currentPlatformIndex = platformNo;
    }

    void setCurrentPlatformNumber(int platformNo) 
    {
        currentPlatformNumber = platformNo;
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
