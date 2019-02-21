//očekujem 3 stanja koja moramo implementirati
//stanje==0 će biti početni ekran
//stanje==1 je igra
//stanje==2 je game over screen
//stanje==3 je pause screen

import java.util.Iterator;
import java.util.Map;
import java.lang.*;
import ddf.minim.*;


// FIXME: Ima bug koji ponekad pri skakanju blizu vrha dovodi do toga da lik zna proci kroz platforme.
//        Cini mi se da se to sada desava samo kada je combo sprite
//        Mozda popravljeno?
// FIXME: Postoji bug s brojanjem platformi, može se doći do 10.platforme bez da on registrira da sam prešla 4.platfomu ako ne skačeš jednu po jednu.
//
// TODO: TImeri su trenutacno ovisni o framerateu. Ja mislim da je to bolje nego realtime jer ako netko ima manji framerate odmah mu je i sporija igra
//       jer je sve ovisno o framerateu.
//       Mozemo implementirati da se ne pomice ovisno o framerateu. Tipa ako se lik pomice 60 pixela na 60 frameova da se pomice i 60 u 30 frameova tj
//       1 px po frameu u 60 ili 2 px po frameu ako je 30 fps. (Mozda dovoljno sve kretnje mnozit sa 60/frameRate ?)
//       Al posto bi to moglo dovest do malo previse bugova onda mozda bolje ovako jer ipak je ne plasiramo na trziste

// TODO: Asseti

// FIXME: Naci način da supressam ENTER tipku jer kad odem u main menu iz zadnjeg ekrana ono odma skoči u igru i isto tako kad se upisuje username



// Ljestvice najboljih rezultata
// Format je "placement floor combo player"
class Leaderboards {
    ArrayList< HashMap<String, String> > bestCombo = new ArrayList< HashMap<String, String> >(), bestFloor = new ArrayList< HashMap<String, String> >();
    int newCombo, newFloor, indexOfBestCombo, indexOfBestFloor;

    // Ucitava podatke iz datoteke i sprema u listu tako da pristupamo npr drugom najboljem combu i njegovom imenu sa bestCombo.get(1).get("player")
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
        int br = 0; // Prati jesu li sruseni rekordi
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

        outputString[6] = "Highest floor";
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

        float textY = 4*height/7, comboX = 2*width/5, floorX = 3*width/5 + 50;
        float tempY;

        textAlign(LEFT);
        PFont myFont = createFont("SansSerif", 30);
        textFont(myFont);
        fill(255);
        text("Highest combo", comboX, textY);
        text("Highest floor", floorX, textY);

        myFont = createFont("SansSerif", 10);
        textFont(myFont);
        text("PLACE  FLOOR          COMBO           DUDE", comboX, textY+30);
        text("PLACE  FLOOR          COMBO           DUDE", floorX, textY+30);

        myFont = createFont("SansSerif", 30);
        textFont(myFont);
        fill(255);

        tempY = textY+70;
        for( int i = 0; i < 5; ++i)
        {
            el = bestCombo.get(i);
            text(str(i+1), comboX, tempY);
            text(el.get("floor"), comboX + 40, tempY);
            text(el.get("combo"), comboX + 100, tempY);
            text(el.get("player"), comboX+ 160, tempY);
            tempY += 30;
        }

        tempY = textY+70;
        for( int i = 0; i < 5; ++i)
        {
            el = bestFloor.get(i);
            text(str(i+1), floorX, tempY);
            text(el.get("floor"), floorX + 40, tempY);
            text(el.get("combo"), floorX + 100, tempY);
            text(el.get("player"), floorX+ 160, tempY);
            tempY += 30;
            }

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
    private int level, levelTimer=0; // Temeljna brzina kretanja ekrana i timer koji povecava level po potrebi (svako 30 sekundi)
    private ArrayList<Platform> platforms;
    private int noOfPlatforms = 6; // Koliko platformi će biti na ekranu u isto vrijeme
    private float screenStart = 100, screenEnd = width - screenStart; // Imat cemo rubove na ekranu pa nam ovo treba (Height ne trebamo jer su rubovi samo lijevo i desno)
    private float maxPlatformWidth = 400;
    //podaci za sat
    public int sek;
    int cx, cy, prvi_prolazak=0;
    float secondsRadius,clockDiameter ;
    String comboWord;
    int comboWordFrameCount;

    Screen()
    {
        level = 0; // Pocetna brzina treba bit nula jer se platforme tek micu kada igrac stane na platformu iznad cetvrte
        platforms = new ArrayList<Platform>();

        //postavke sata

        int clock_radius = 47;
        secondsRadius = clock_radius * 0.72;
        clockDiameter = clock_radius * 1.8;
        cx = 51;
        cy = 370;
    }


    void draw()
    {
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
                    float platformWidth = random(maxPlatformWidth - 150, maxPlatformWidth); // Randomiziramo sirinu platformi
                    platforms.add(new Platform(random(screenStart + 10, screenEnd - platformWidth - 10), // x
                                                platforms.get(platforms.size() - 1).y - (height/noOfPlatforms), // y
                                                platformWidth, // width
                                                i + 1)); // Platform number
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

        if(level==0)
        crtaj_sat(0,0);
        else
        crtaj_sat(1,levelTimer);

        // Provjera timera i levela
        if(level == 0) return; // Ako jos nije pocelo onda ne radi nista

        levelTimer++;
        if(levelTimer == 1800) // 30 sekundi
        {
            level++;
            levelTimer = 0;
        }

        // Crtamo rijeci koje se pojave na kraju comboa
        drawComboWords();

    }

    void drawComboWords()
    {
        if(comboWordFrameCount > 0)
        {
            textAlign(CENTER);
            textFont(font);
            fill(color(var, 255, 255));
            var++;
            if (var>255)var=0;
            textSize(60);
            text(comboWord, height/2, width/2);
            comboWordFrameCount--;
        }
    }

    void napisi(String s)
    {
        comboWord = s;
        comboWordFrameCount = 60;
    }

    void crtaj_sat(int lvl, int timer)
    {
      float s = map(timer/30, 0, 60, 0, TWO_PI)-HALF_PI;

      if(lvl==0)
      {
        noStroke();
        ellipseMode(RADIUS);
        fill(255, 247, 150);
        ellipse(cx, cy, clockDiameter/2+8, clockDiameter/2+8);

        ellipseMode(CENTER);
        fill(255);
        ellipse(cx, cy, clockDiameter, clockDiameter);
        // Draw the hands of the clock
        stroke(255,0,0);
        strokeWeight(7);
        line(cx, cy, cx + cos(s) * secondsRadius, cy + sin(s) * secondsRadius);
        strokeWeight(2);
        beginShape(POINTS);
        for (int a = 0; a < 360; a+=30) {
          float angle = radians(a);
          float x = cx + cos(angle) * secondsRadius;
          float y = cy + sin(angle) * secondsRadius;
          vertex(x, y);
          }
        endShape();
      }
      else
      {
        noStroke();
        ellipseMode(RADIUS);
        fill(255, 247, 150);
        ellipse(cx, cy, clockDiameter/2+8, clockDiameter/2+8);

        ellipseMode(CENTER);
        fill(255);
        ellipse(cx, cy, clockDiameter, clockDiameter);

        s = map(timer/30, 0, 60, 0, TWO_PI)-HALF_PI;

        if((s+HALF_PI)%TWO_PI>=0 && (s+HALF_PI)%TWO_PI<0.4 && prvi_prolazak>1)
        {
          hurry();
          float r = random(-2,2);
          noStroke();
          ellipseMode(RADIUS);
          fill(255, 247, 150);
          ellipse(cx+r, cy+r, clockDiameter/2+8, clockDiameter/2+8);

          ellipseMode(CENTER);
          fill(255);
          ellipse(cx+r, cy+r, clockDiameter-s, clockDiameter+s);
        }
        // Draw the hands of the clock
        stroke(255,0,0);
        strokeWeight(7);
        line(cx, cy, cx + cos(s) * secondsRadius, cy + sin(s) * secondsRadius);


        strokeWeight(2);
        beginShape(POINTS);
        for (int a = 0; a < 360; a+=30) {
          float angle = radians(a);
          float x = cx + cos(angle) * secondsRadius;
          float y = cy + sin(angle) * secondsRadius;
          vertex(x, y);
          }
        endShape();
        if(prvi_prolazak==1 && s>0)
          prvi_prolazak++;
        }
      }

    void hurry()
    {
      //ispis obavijesti o ubrzavanju i postavljanje zvuka opomene
      float r=random(-2,2);
      textAlign(CENTER);
      textFont(font);
      fill(color(var, 255, 255));
      var++;
      if (var>255)var=0;
      textSize(60);
      text("Hurry up!", height/2+r, width/3+r);
      hurry_up.play();
      if ( hurry_up.position() == hurry_up.length() )
      {
        hurry_up.rewind();
      }

    }




    // Pomakni ekran ovisno o igracevoj poziciji i brzini kretanja
    void moveScreen(float playerPosY, float playerVerticalSpeed)
    {
        if(level<10) //recimo da ubrza 10 puta, a onda ide tom brzinom
          speed = level;
        else speed=10;
        if (playerPosY < height/4 && playerVerticalSpeed < 0) // Ako je blizu vrhu i krece se prema gore
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

        crtaj_sat(0, levelTimer);

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
        if(v==1&&prvi_prolazak==0)
        {
          sek=second();
          prvi_prolazak=1;
        }
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
    private float ax=.32, ay=.9, startingJump = 19;
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
                    ledgeaudio.play();
                } else
                {
                    ledgeaudio.rewind();
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

        //TODO: brisati (Framerate)
        textFont(createFont("Arial Bold", 18));
        fill(255);
        text("FPS: " + str(round(frameRate)), 50, 850);
    }

    void horizontalMovement()
    {
        // Horizontalne kretnje
        if (leftKeyPressed)
        {
            vx -= (vx > 0) ? 1.5*ax : ax; // Ako se vec krece desno onda da se malo brze krece prema lijevo pa da brze uspori
        }
        if (rightKeyPressed)
        {
            vx += (vx < 0) ? 1.5*ax : ax;
        }
        if (onGround && !leftKeyPressed && !rightKeyPressed)
        {
            vx *= 0.9; // Usporavanje ako se ne krece
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
            vy=- startingJump - abs(vx);  // Vertikalnu brzinu mijenjamo ovisno o horizontalnoj
            onGround=false;

            //zvuk skoka ovisi o broju preskočenih platformi
            if(currentPlatformNumber==previousPlatformNumber+1)//preskočena jedna platforma
            {
              skok_jedna.play();
              if ( skok_jedna.position() == skok_jedna.length() )
              {
                skok_jedna.rewind();
              }
            }
            else if(currentPlatformNumber==previousPlatformNumber+2)//preskoceno dvije platforme
            {
              skok_nekoliko.play();
              if ( skok_nekoliko.position() == skok_nekoliko.length() )
              {
                skok_nekoliko.rewind();
              }
            }
            else if(currentPlatformNumber>previousPlatformNumber+2)//preskoceno više platformi
            {
              skok_vise.play();
              if ( skok_vise.position() == skok_vise.length() )
              {
                skok_vise.rewind();
              }
            }

            previousPlatformNumber = currentPlatformNumber;
            startingJumpSpeed = vx; // Potrebno radi odabire sprite-a
            jumpedFromPlatform = true; // Oznacavamo da je skocio sa platforme a ne pao

            if (currentPlatformIndex >= 4) // Ako prijedjemo cetvrtu platformu onda se ekran pocinje kretati i pali se timer
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
          //ovdje staviti fju za provjeru koji zvuk ide oviso o broju comboCount
            koji_zvuk(comboCount);
            if(comboCount > highestCombo) highestCombo = comboCount;
            comboCount = 0;
            comboTimer = 0;
            isInCombo = false;
            return false;
        }

        if(onGround && firstLanding && currentPlatformNumber != previousPlatformNumber) // Zadnji uvjet pazi da nismo skocili na istu platformu
        {
            comboTimer = 180;
            firstLanding = false; // Pazi da ne bi skokove sa iste na istu platformu brojali
            comboCount += currentPlatformNumber - previousPlatformNumber;
        }
        else if(!onGround)
        {
            firstLanding = true;
        }

        if(comboCount != 0) // Timer za combo se ne mice ako nismo u combou
            comboTimer--;
        isInCombo = true;
        return true;
    }

    void keepInScreen()
    {
        //ako lik dođe ispod visine, gotovi smo
        if (posy>=height-sprite.height/2)
        {
          //zvuk za game over
          game_ending.play();
          if ( game_ending.position() == game_ending.length() )
            {
            game_ending.rewind();
            }
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

    //htjela bih napisati funkciju koja će primati comboCount i na temelju toga pustiti
    //odgovarajuci AudioPlayer
    void koji_zvuk(int combo)
    {
      if(4<=combo && combo<=6)
      {
        good.play();
        if ( good.position() == good.length() )
        {
          good.rewind();
        }
        mainScreen.napisi("Good!");
      }
      else if(7<=combo && combo<=14)
      {
        sweet.play();
        if ( sweet.position() == sweet.length() )
          {
          sweet.rewind();
          }
         mainScreen.napisi("Sweet!");
      }
      else if(15<=combo && combo<=24)
      {
        great.play();
        if ( great.position() == great.length() )
          {
          great.rewind();
          }
        mainScreen.napisi("Great!");
      }
      else if(25<=combo && combo<=34)
      {
        superb.play();
        if ( superb.position() == superb.length() )
          {
          superb.rewind();
          }
        mainScreen.napisi("Super!");
      }
      else if(35<=combo && combo<=49)
      {
        wow.play();
        if ( wow.position() == wow.length() )
          {
          wow.rewind();
          }
        mainScreen.napisi("WOW!");
      }
      else if(50<=combo && combo<=69)
      {
        amazing.play();
        if ( amazing.position() == amazing.length() )
          {
          amazing.rewind();
          }
       mainScreen.napisi("Amazing!");
      }
      else if(70<=combo && combo<=99)
      {
        extreme.play();
        if ( extreme.position() == extreme.length() )
          {
          extreme.rewind();
          }
        mainScreen.napisi("Extreme!");
      }
      else if(100<=combo && combo<=139)
      {
        fantastic.play();
        if ( fantastic.position() == fantastic.length() )
          {
          fantastic.rewind();
          }
        mainScreen.napisi("Fantastic!");
      }
      else if(140<=combo && combo<=199)
      {
        splendid.play();
        if ( splendid.position() == splendid.length() )
          {
          splendid.rewind();
          }
        mainScreen.napisi("Splendid!");
      }
      else if(combo>=199)
      {
        no_way.play();
        if ( no_way.position() == no_way.length() )
          {
          no_way.rewind();
          }
        mainScreen.napisi("NO WAY!");
      }


    }
}

int stanje=0, var=0, currentLetter=0, pickedOption=0, currentMenuOptionsCount;
PFont font;
PImage bg, cursorHarold;
Screen mainScreen;
Character player;
boolean leftKeyPressed = false, rightKeyPressed = false, downKeyPressed = false, upKeyPressed = false, spaceKeyPressed = false;
boolean usernameEntered = false;
String pickedCharacter = "Harold";
Leaderboards boards;
char[] username = new char[] {'A', 'A', 'A'};

Minim minim;
//popis mogućih sound datoteka
AudioPlayer amazing, extreme, fantastic, good, great, hurry_up, jo, no_way;
AudioPlayer novi_high_score, game_ending, power, skok_jedna, skok_vise, skok_nekoliko;
AudioPlayer in_game, splendid, superb, sweet, theme, try_again, wow, ledgeaudio ;


void setup()
{
    size(1100, 900);
    //font=createFont("ComicSansMS-BoldItalic-48.vlw", 32);
    font = createFont("Georgia Bold", 32);
    colorMode(HSB);
    noStroke();

    cursorHarold = loadImage("cursorHarold.png");
    cursorHarold.resize(40, 0);

    boards = new Leaderboards();
    minim= new Minim(this);

    //Inicijalizacija svih AudioPlayera
    amazing=minim.loadFile("amazing.wav");
    extreme=minim.loadFile("extreme.wav");
    fantastic=minim.loadFile("fantastic.wav");
    good=minim.loadFile("good.wav");
    great=minim.loadFile("great.wav");
    hurry_up=minim.loadFile("hurry_up.wav");
    jo=minim.loadFile("jo.wav");//postavljeno
    no_way=minim.loadFile("no_way.wav");
    novi_high_score=minim.loadFile("novi_high_score.wav");//postavljeno
    game_ending=minim.loadFile("game_ending.wav");
    power=minim.loadFile("power.wav");
    skok_jedna=minim.loadFile("skok_jedna.wav");
    skok_vise=minim.loadFile("skok_vise.wav");
    skok_nekoliko=minim.loadFile("skok_nekoliko.wav");
    in_game=minim.loadFile("in_game.mp3"); //ovo je pjesma u igri, postavljeno
    splendid=minim.loadFile("splendid_sala.wav");
    superb=minim.loadFile("super.wav");
    sweet=minim.loadFile("sweet.wav");
    theme=minim.loadFile("theme.mp3"); //ova ide na početni ekran, postavljeno
    try_again=minim.loadFile("try_again.wav");
    wow=minim.loadFile("wow.wav");
    ledgeaudio=minim.loadFile("ledge.wav");

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
    currentMenuOptionsCount = 3;

    bg=loadImage("background1.jpg");
    bg.resize(width, height);
    background(bg);

    textAlign(LEFT);
    textFont(font);
    fill(color(var, 255, 255));
    var++;
    if (var>255)var=0;
    text("Play", 70, 1*height/7);
    text("Character: <- " + pickedCharacter + " ->", 70, 2*height/7);
    text("Exit ", 70, 3*height/7);

    image(cursorHarold, 25, (pickedOption+1)*height/7 - 2*cursorHarold.height/3);

    textAlign(CENTER);
    textSize(160);
    rotate(PI/6);
    text("ICY", 4*width/5, -height/5);
    text("TOWER", 4*width/5, -height/5+160);
    rotate(-PI/6);

    theme.play();
    if ( theme.position() == theme.length() )
    {
      theme.rewind();
      theme.play();
    }
    boards.drawOnStartScreen();

    if ( keyPressed && key == ENTER && (pickedOption == 0 || pickedOption == currentMenuOptionsCount - 1) )
    {
        if(pickedOption == currentMenuOptionsCount - 1) // Exit ce uvijek biti zadnja
        {
            myExit();
        }

        pickedCharacter = (pickedCharacter == "Dave") ? "dave" : "harold";
        mainScreen = new Screen();
        player = new Character(mainScreen, pickedCharacter, boards);
        stanje = 1;
        pickedOption = 0; // Resetiramo ga na nulu
    }
}

void gameScreen()
{
    background(100);

    mainScreen.draw();

    player.move(); // U njemu pomicemo i crtamo

    mainScreen.moveScreen(player.positionY(), player.verticalSpeed());

    theme.close();
    in_game.play();
    jo.play();
    if ( in_game.position() == in_game.length() )  //ako dođem do kraja, želim ponoviti pjesmu
    {
      in_game.rewind();
      in_game.play();
    }

}

void endScreen()
{
    background(#800040);

    textAlign(CENTER);
    textFont(font);
    fill(color(var, 255, 255));
    var++;
    if (var>255)var=0;
    textSize(220);
    text("GAME", height/2, width/3);
    text("OVER", height/2, width/3 + 220);

    currentMenuOptionsCount = 3;

    textAlign(LEFT);
    textSize(50);
    text("Play again", 70, height/3+440);
    text("Main menu", 70, height/3+490);
    text("Exit", 70, height/3+540);
    textAlign(CENTER);

    image(cursorHarold, 25, (pickedOption)*50 + height/3+440 - cursorHarold.height/2);

    in_game.close();
    jo.close();


    // Provjerava ako ima rekord i onda otvara prozor za upis usernamea
    if(player.isThereANewRecord() && !usernameEntered)
    {
        novi_high_score.play();
        if(novi_high_score.position()==novi_high_score.length())
          novi_high_score.rewind();

        fill(125);
        rect(width/7, height/7, 5*width/7, 5*height/7);

        char[] us = username.clone();
        if((frameCount/10)%2 == 0) us[currentLetter] = '_'; // Da simulira koje slovo se trenutno bira

        fill(255);
        textSize(40);
        text("NEW RECORD\nWrite your name:\n" + String.valueOf(us) + "\nPress '+' on end", width/2, 2*height/7);

        if (stanje == 2 && !usernameEntered && key == '+') // + je ovdje privremeno dok ne nadjem opciju kako da mi ne racuna ENTER vise puta
        {
            usernameEntered = true;
            boards.addNewRecord(String.valueOf(username));
        }

        pickedOption = 0; // Osiguravamo da se cursor ne mice dok je otvoren prozor za combo
    }

    if ((!player.isThereANewRecord() || usernameEntered) && keyPressed && key == ENTER)
    {
        if(pickedOption == currentMenuOptionsCount - 1) // Exit ce uvijek biti zadnja
        {
            myExit();
        }

        if(pickedOption == 1)
        {
            stanje = 0;
            return;
        }

        reset();
        usernameEntered = false;
        pickedOption = 0;

    }

}

void pauseScreen()
{
    background(100);
    mainScreen.pauseScreen();
    player.pauseScreen();

    fill(0, 80);
    rect(0, 0, width, height);


    fill(255);
    textSize(150);
    text("PAUSED", width/2, 200);

    textSize(60);
    text("Press 'R' to reset.", width/2, 400);
    text("Press 'M' to go to main menu.", width/2, 500);
    text("Press 'P' to continue.", width/2, 600);

    if (keyPressed && (key == 'r' || key == 'R'))
    {
        reset();
    } else if (keyPressed && (key == 'm' || key == 'M'))
    {
        stanje = 0;
    }

}

void myExit()
{
    boards.saveToFile();
    exit();
}

void reset() {
    mainScreen = new Screen();
    //moraju se "restartati" za novo korištnenje, ne znam zašto, malo je bezveze.
    in_game=minim.loadFile("in_game.mp3");
    jo=minim.loadFile("jo.wav");

    player = new Character(mainScreen, pickedCharacter, boards);
    stanje = 1;
}

// Ako su pritisnute tipke za lijevo i desno, one su CODED pa moramo ovako
// izvršavati provjeru

void keyPressed() {
    char c = key;
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

        if(stanje == 1 || stanje == 3) return; // U stanjima 1 i 3 nema menija

        // Pomicanje odabira u meni-u
        if(keyCode==UP)
        {
            pickedOption = (pickedOption == 0) ? 2 : (pickedOption - 1) % currentMenuOptionsCount;
        }
        if(keyCode==DOWN)
        {
            pickedOption = (pickedOption + 1) % currentMenuOptionsCount;
        }

        // Mijenja odabir lika
        if(stanje == 0 && (keyCode==LEFT || keyCode==RIGHT) && pickedOption == 1)
        {
            pickedCharacter = (pickedCharacter == "Harold") ? "Dave" : "Harold";
        }


    } else if (key == ' ')
    {
        spaceKeyPressed = true;
    } else if ((key == 'p' || key == 'P') && (stanje == 1 || stanje == 3)) // Pause screen on/off
    {
        stanje = (stanje == 1) ? 3 : 1;
    } else if (stanje == 2 && !usernameEntered && key!=ENTER) // Ako je rekord onda upis slova za username
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
