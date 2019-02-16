//očekujem 3 stanja koja moramo implementirati
//stanje==0 će biti početni ekran
//stanje==1 je igra
//stanje==2 je game over screen
//stanje==3 je pause screen

import java.util.Iterator;
import java.util.Map;
import java.lang.*;


// FIXME: Ima bug koji ponekad pri skakanju blizu vrha dovodi do toga da lik zna proci kroz platforme.
//        Cini mi se da se to sada desava samo kada je combo sprite
//        Mozda popravljeno?

// TODO: TImeri su trenutacno ovisni o framerateu. Ja mislim da je to bolje nego realtime jer ako netko ima manji framerate odmah mu je i sporija igra
//       jer je sve ovisno o framerateu.
//       Mozemo implementirati da se ne pomice ovisno o framerateu. Tipa ako se lik pomice 60 pixela na 60 frameova da se pomice i 60 u 30 frameova tj 
//       1 px po frameu u 60 ili 2 px po frameu ako je 30 fps. (Mozda dovoljno sve kretnje mnozit sa 60/frameRate ?)
//       Al posto bi to moglo dovest do malo previse bugova onda mozda bolje ovako jer ipak je ne plasiramo na trziste

// TODO: Asseti

// FIXME: Naknadna upisivanja u ljestvicu najboljih ne upisuju dobro

// Ljestvice najboljih rezultata
// Format je "placement foor combo player"
class Leaderboards {
    ArrayList< HashMap<String, String> > bestCombo = new ArrayList< HashMap<String, String> >(), bestFloor = new ArrayList< HashMap<String, String> >();
    int newCombo, newFloor, indexOfBestCombo, indexOfBestFloor;

    Leaderboards() 
    {
        String[] lines = loadStrings("leaderboards.txt");
        for (int i = 1 ; i < lines.length; i++) 
        {
            if(i < 6)
            {
                String[] values = lines[i].split(" ");
                bestCombo.add(new HashMap<String, String>());
                bestCombo.get(i-1).put("floor", values[1]);
                bestCombo.get(i-1).put("combo", values[2]);
                bestCombo.get(i-1).put("player", values[3]);
            } else if (i > 6) 
            {
                String[] values = lines[i].split(" ");
                bestFloor.add(new HashMap<String, String>());
                bestFloor.get(i-7).put("floor", values[1]);
                bestFloor.get(i-7).put("combo", values[2]);
                bestFloor.get(i-7).put("player", values[3]);
            }
        }
    }

    boolean checkForHighScore(int highestCombo, int floor)
    {
        int br = 0; 
        HashMap<String, String> el;
        indexOfBestCombo = -1;
        indexOfBestFloor = -1;

        for( int i = 0; i < bestCombo.size(); ++i)
        {
            el = bestCombo.get(i);
            if( highestCombo > Integer.parseInt(el.get("combo")))
            {
                indexOfBestCombo = i;
                newCombo = highestCombo;
                newFloor = floor;
                ++br;
                break;
            }
        }

        for( int i = 0; i < bestFloor.size(); ++i)
        {
            el = bestFloor.get(i);
            if( floor > Integer.parseInt(el.get("floor")))
            {
                indexOfBestFloor = i;
                newCombo = highestCombo;
                newFloor = floor;
                ++br;
                break;
            }
        }

        return (br > 0);

    }

    void addNewRecord(String newUsername)
    {
        HashMap<String, String> el;

        if(indexOfBestCombo >= 0)
        {
            int i = indexOfBestCombo;
            el = bestCombo.get(i);
            bestCombo.add(i, new HashMap<String, String>());
            bestCombo.get(i).put("floor", str(newFloor));
            bestCombo.get(i).put("combo", str(newCombo));
            bestCombo.get(i).put("player", newUsername);
            bestCombo.remove(bestCombo.size() - 1);
        }


        if(indexOfBestFloor >= 0)
        {
            int i = indexOfBestFloor;
            el = bestFloor.get(i);
            bestFloor.add(i, new HashMap<String, String>());
            bestFloor.get(i).put("floor", str(newFloor));
            bestFloor.get(i).put("combo", str(newCombo));
            bestFloor.get(i).put("player", newUsername);
            bestFloor.remove(bestFloor.size() - 1);
        }
            
    }



    // Format je "placement foor combo player"
    void saveToFile() 
    {
        HashMap<String, String> el;
        String[] outputString = new String[12];
        outputString[0] = "Highest combo";
        for( int i = 0; i < 5; ++i)
        {
            el = bestCombo.get(i);
            outputString[i+1] = str(i+1) + ' ' + el.get("floor") + ' ' + el.get("combo") + ' ' + el.get("player");
        }

        outputString[5] = "Highest floor\nPl Fl Cm Us";
        for( int i = 0; i < 5; ++i)
        {
            el = bestFloor.get(i);
            outputString[i+7] = str(i+1) + ' ' + el.get("floor") + ' ' + el.get("combo") + ' ' + el.get("player");
        }

        saveStrings("leaderboards.txt", outputString);
    }

    void drawOnStartScreen()
    {
        HashMap<String, String> el;
        String comboString = "Highest combo\n# F C U";
        for( int i = 0; i < 5; ++i)
        {
            el = bestCombo.get(i);
            comboString += '\n' + str(i+1) + ". " + el.get("floor") + " " + el.get("combo") + "    " + el.get("player");
        }

        String floorString = "Highest floor\n# F C U";
        for( int i = 0; i < 5; ++i)
        {
            el = bestFloor.get(i);
            floorString += '\n' + str(i+1) + ". " + el.get("floor") + " " + el.get("combo") + "    " + el.get("player");
        }

        textAlign(LEFT);
        PFont myFont = createFont("SansSerif", 30);
        textFont(myFont);
        fill(255);
        text(comboString, 3*width/5, 5*height/7);
        text(floorString, 4*width/5, 5*height/7);
        textAlign(CENTER);


    }

}

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

    boolean isOnPlatform(Character player) 
    { 
        if (player.verticalSpeed() < 0) return false; // Ako igrac ide prema gore onda ne pada na platformu 


        if ( player.positionY() + player.getSpriteHeight()/2 >= y - player.verticalSpeed()  && // Hoce li igrac pasti na platformu u iducem frame-u
            player.positionY() + player.getSpriteHeight()/2  <= y &&  // Je li igrac iznad platforme?
            player.positionX() + player.getSpriteWidth()/2 >= x &&  // Je li desno rub igraca desno od lijevog ruba platforme
            player.positionX() - player.getSpriteWidth()/2 <= x + w ) // Je li lijevi rub igraca lijevo od desnog ruba platforme
        { 
            player.setPositionY(y - player.getSpriteHeight()/2); // Postavljamo igraca na platformu
            return true;
        } 
        
        return false;
        
    }

    // | -1 = lijevi rub | 0 = nije na rubu | 1 = desni rub |
    int isOnLedge(Character player) 
    { 
        if (player.positionX() - player.getSpriteWidth()/3 <= x + 10)     return -1;
        if (player.positionX() + player.getSpriteWidth()/3 >= x + w - 10) return 1;
        return 0;
    }

    boolean isOutOfBounds() 
    {
        return (y > height); 
    }

    void draw() 
    {
        // Crtaj platfomu
        fill(#770077);
        rect(x, y, w, h);

        // Na svaku desetu napisi broj platforme
        if (platformNumber % 10 == 0) 
        {
            textFont(createFont("Arial Bold", 18));
            fill(255);
            text(str(platformNumber), x + w/2, y + 2*h/3);
        }
    }

    // Spusti platformu na ekranu
    void reduceHeight(float amount) 
    {
        y += amount;
    }
}

// Klasa o ekranu na kojem crtamo platforme i kojeg pomicemo
class Screen {

    private float speed; // Izracunata brzina kretanja ekrana ovisna i o kretanju lika
    private int level, levelTimer=0; // Temeljna brzina kretanja ekrana i timer koji povecava level po potrebi
    private ArrayList<Platform> platforms;
    private int noOfPlatforms = 6;
    private float screenStart = 200, screenEnd = width - screenStart; // Imat cemo rubove na ekranu pa nam ovo treba (Height ne trebamo jer su rubovi samo lijevo i desno)
    private float maxPlatformWidth = 400;

    Screen() 
    {    
        level = 0; // Pocetna brzina treba bit nula jer se platforme tek micu kada igrac stane na platformu iznad cetvrte
        platforms = new ArrayList<Platform>();
    }

    void draw() 
    { // Imat ćemo 7 (podlozno promjenama) platformi najviše u isto vrijeme

        // Crtamo prvo rubove ekrana
        fill(#000077);
        rect(0, 0, screenStart, height); // Lijevi rub
        rect(screenEnd, 0, screenStart, height); // Desni rub (sirina je ista u oba ruba)

        // Stvaramo prve platforme na pocetku igre
        if (platforms.size() == 0) 
        {
            for (int i = 0; i < noOfPlatforms; i++) // Dodajemo platformi koliko treba
            { 
                if (i == 0) // Najdonja platforma
                { 
                    platforms.add(new Platform(screenStart + 0, height-20, screenEnd - screenStart, 1));
                } else 
                {
                    float platformWidth = random(maxPlatformWidth - 150, maxPlatformWidth);
                    platforms.add(new Platform(random(screenStart + 10, screenEnd - platformWidth - 10), platforms.get(platforms.size() - 1).y - (height/noOfPlatforms), platformWidth, i + 1));
                }
            }
        } else if (platforms.get(0).isOutOfBounds()) // Ako je najdonja platforma nestala onda nju izbacujemo iz liste i dodajemo novu platformu na vrh
        { 
            platforms.remove(0);
            Platform platformBefore = platforms.get(platforms.size() - 1);
            int platNo = platformBefore.platformNumber + 1;

            // Randomiziramo velicine platformi
            float platformWidth = (platNo < 200) ? random(maxPlatformWidth*(1-(platNo/1000)) - 150, maxPlatformWidth*(1-(platNo/1000))) : 200;

            // Dodajemo novu platformu i ako je neki kat koji je djeljiv sa 50 onda je sirine cijelog ekrana
            platforms.add(new Platform(( (platNo%50 == 0) ? screenStart : random(screenStart + 10, screenEnd - platformWidth - 10) ), 
                                       platformBefore.y - (height/noOfPlatforms), 
                                       (platNo%50 == 0) ? screenEnd - screenStart :  platformWidth, 
                                       platNo));
        }

        for ( Platform pl : platforms) 
        {
            pl.draw();
        }

        // TODO: Nacrtati sat za timer?

        // TImer za levele
        fill(255);
        rect(5, 345, screenStart - 10, 20);
        fill(0);
        rect(10, 350, screenStart - 20, 10);
        fill(125);
        float timerMappedValue = map(levelTimer, 0, 1800, 0, screenStart - 20);
        rect(10 + screenStart - 20 - timerMappedValue, 350, timerMappedValue, 10);

        // Provjera timera i levela
        if(level == 0) return; // Ako jos nije pocelo onda ne radi nista

        levelTimer++;
        if(levelTimer == 1800) // 30 sekundi 
        {
            level++;
            levelTimer = 0;
        }

        

        
    }

    // Pomakni ekran ovisno o igracevoj poziciji i brzini kretanja
    void moveScreen(float playerPosY, float playerVerticalSpeed) 
    { 
        speed = level;
        if (playerPosY < height/4 && playerVerticalSpeed < 0)
            speed += abs(playerVerticalSpeed) * map(playerPosY, height/4, -10, 0, 1); // Racunamo koliko ce se pomaknuti

        for ( Platform pl : platforms) 
        {
            pl.reduceHeight(speed);
        }
    }

    void pauseScreen()
    {
        // Crtamo prvo rubove ekrana
        fill(#000077);
        rect(0, 0, screenStart, height); // Lijevi rub
        rect(screenEnd, 0, screenStart, height); // Desni rub (sirina je ista u oba ruba)

        for ( Platform pl : platforms) 
        {
            pl.draw();
        }

        // TODO: Nacrtati sat za timer?

        // TImer za levele
        fill(255);
        rect(5, 345, 90, 20);
        fill(0);
        rect(10, 350, 80, 10);
        fill(125);
        float timerMappedValue = map(levelTimer, 0, 1800, 0, 80);
        rect(10 + 80 - timerMappedValue, 350, timerMappedValue, 10);

    }

    float getScreenStart()
    {
        return screenStart;
    }

    float getScreenEnd()
    {
        return screenEnd;
    }

    float getSpeed() 
    { 
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
}


// Klasa sa kojom pokrecemo lika i u kojoj su spremljeni njeni podaci
class Character {

    private float posx, posy;
    private float vx=0, vy=0; 
    private float ax=.32, ay=.64;
    private PImage sprite;
    private int run = 0, ledge = 0, standing = 0, rotation = 0;
    private boolean onGround=false, jumpedFromPlatform=false, firstLanding=false, isInCombo=false, newRecord = false;
    private Screen screen;
    String character;
    private HashMap<String, PImage> sprites = new HashMap<String, PImage>();   
    private int currentPlatformIndex, currentPlatformNumber, previousPlatformNumber, comboCount, comboTimer = 0, highestCombo = 0;
    private float startingJumpSpeed;
    Leaderboards lboards;

    Character( Screen scr, String _character, Leaderboards _lboards) 
    {
        screen = scr;
        lboards = _lboards;
        posx = (screen.getScreenStart() + screen.getScreenEnd())/2-30; 
        posy = height-55;
        character = _character;
        loadSprites();
        sprite = sprites.get("jumping");
    }

    void loadSprites() 
    {
        imageMode(CENTER);
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
        if(isInCombo && abs(startingJumpSpeed) > 10 && jumpedFromPlatform) // Crta "combo" sprite i rotira ga
        {
            sprite = sprites.get("combo");            
            pushMatrix();
            translate(posx, posy);
            rotate(rotation/5); rotation++;
            image(sprite,0,0);
            popMatrix();
            sprite.resize(0, 70);
        }
        else 
        {
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
                    standing = (standing+1)%60; // Mijenjamo sprite za stajanje svako 20 frameova
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
        sprite.resize(0, 70);
        image(sprite, posx, posy);
        }

    }

    void pauseScreen()
    {
        image(sprite, posx, posy);

        drawCombo();
    }

   
    void move()
    {
        horizontalMovement();
        verticalMovement();

        keepInScreen();
        setSprite();

        drawCombo();
        

    }

    void drawCombo()
    {
        // Crtamo counter za combo ako se desava combo
        if(comboCount > 0) 
        {
            textFont(createFont("Arial Bold", 18));
            fill(255);
            text(str(comboCount) + "\n FLOORS!", 40, 270);
        }
        

        // Crtamo bar za combo
        fill(255);
        rect(15, 45, 20, 190);
        fill(0);
        rect(20, 50, 10, 180);
        fill(125);
        rect(20, 50 + 180 - comboTimer, 10, comboTimer);

        //TODO: brisati
        textFont(createFont("Arial Bold", 18));
        fill(255);
        text("FPS: " + str(round(frameRate)), 50, 850);
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

        //ako smo stisli space i nismo u letu nego smo na površini (kada je onGround true), onda skacemo
        if (spaceKeyPressed && onGround)
        {
            vy=-14 - abs(vx);  // Vertikalnu brzinu mijenjamo ovisno o horizontalnoj 
            onGround=false;
            previousPlatformNumber = currentPlatformNumber;
            startingJumpSpeed = vx;
            jumpedFromPlatform = true; // Oznacavamo da je skocio sa platforme a ne pao

            if (currentPlatformIndex > 4) // Ako prijedjemo cetvrtu platformu onda se ekran pocinje kretati i pali se timer
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
        // Sa wiki:
        // A combo ends when a player makes a jump which covers only one floor, 
        // falls off a floor and lands on a lower floor, 
        // or fails to make a jump within a certain time frame (about 3 seconds).
        if(currentPlatformNumber == previousPlatformNumber + 1 || previousPlatformNumber > currentPlatformNumber || comboTimer < 0 ) 
        {
            if(comboCount > highestCombo) highestCombo = comboCount;
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
        {
            newRecord = lboards.checkForHighScore(highestCombo, currentPlatformNumber);
            stanje=2;
        }
             

        //ako harold dođe do vrha, ne može ići više od toga (ostalo -10 jer u originalu on udje malo u strop al vuce ekran za sobom pa nema problema i izgleda prirodno)
        if (posy <= -10)
            posy=-10; 

        // Treba nam jer su slike centrirane
        float spriteHalf = sprite.width/2;

        //moramo mu zabraniti i da iziđe izvan lijevih i desnih rubova
        posx = constrain(posx, screen.getScreenStart() + spriteHalf, screen.getScreenEnd()-sprite.width+spriteHalf);

        // Odbijaj lika od zidova
        if (posx - spriteHalf == screen.getScreenStart() || posx + sprite.width - spriteHalf == screen.getScreenEnd())
        {
            vx *= (-0.5);
        }
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

    boolean isThereANewRecord()
    {
        return newRecord;
    }

}

int stanje=0, var=0, currentLetter=0; 
PFont font; 
PImage bg;
Screen mainScreen;
Character player;
boolean leftKeyPressed = false, rightKeyPressed = false, spaceKeyPressed = false;
boolean usernameEntered = false;
String pickedCharacter;
Leaderboards boards; 
char[] username = new char[] {'A', 'A', 'A'};


void setup()
{
    size(1100, 900);
    //font=createFont("ComicSansMS-BoldItalic-48.vlw", 32);
    font = createFont("Georgia", 32);
    colorMode(HSB);
    noStroke();

    boards = new Leaderboards(); 

    
}

void draw()
{
    if (stanje==0)
        startScreen(); 
    else if (stanje==1)
        gameScreen(); 
    else if (stanje==2)
        endScreen();
    else if (stanje==3)
        pauseScreen();
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
    text("Press H to play with Harold \n Press D to play with Disco Dave", 1*width/4, 4*height/5);
    textSize(160);
    rotate(PI/6);
    text("ICY", 3*width/4, -height/5);
    text("TOWER", 3*width/4, -height/5+160);
    rotate(-PI/6);

    boards.drawOnStartScreen();

    if (keyPressed && stanje==0 && (key == 'd' || key == 'h' || key == 'D' || key == 'H')) 
    {
        pickedCharacter = (key == 'd' || key == 'D') ? "dave" : "harold";
        mainScreen = new Screen();
        player = new Character(mainScreen, pickedCharacter, boards);
        stanje=1;
    }
}

void gameScreen()
{  
    

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
    text("Press 'R' to restart.", width/2, height/3+440);

    

    if(player.isThereANewRecord() && !usernameEntered) 
    {

        fill(125);
        rect(width/7, height/7, 5*width/7, 5*height/7);

        char[] us = username.clone();
        if((frameCount/10)%2 == 0) us[currentLetter] = '_';

        fill(255);
        textSize(40);
        text("NEW RECORD\nWrite your name:\n" + String.valueOf(us) + "\nPress ENTER on end", width/2, 2*height/7);

        if (keyPressed && key == ENTER) 
        {
            usernameEntered = true;
            boards.addNewRecord(String.valueOf(username));
        }
    }
    
    if (usernameEntered && keyPressed && (key == 'r' || key == 'R')) 
    {
        reset();
        usernameEntered = false;
    }
}

void pauseScreen()
{
    background(100);
    mainScreen.pauseScreen();
    player.pauseScreen();

    fill(0);
    rect(150, 150, 600, 600);

    if (keyPressed && (key == 'r' || key == 'R')) 
    {
        reset();
    } else if (keyPressed && (key == 'm' || key == 'M'))
    {
        stanje = 0;
    }

    fill(255);
    textSize(20);
    textAlign(LEFT);
    text("Press 'R' to reset.", 170, 200);
    text("Press 'M' to go to main menu.", 170, 300);
    textAlign(CENTER);


}

void reset() {
    mainScreen = new Screen();
    player = new Character(mainScreen, pickedCharacter, boards);
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
    } else if ((key == 'p' || key == 'P') && (stanje == 1 || stanje == 3))
    {
        stanje = (stanje == 1) ? 3 : 1;
    } else if (stanje == 2 &&  !usernameEntered && key!=ENTER) 
    {
        username[currentLetter] = key;
        currentLetter = (currentLetter+1)%3;
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
