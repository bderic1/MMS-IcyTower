

// Klasa o ekranu na kojem crtamo platforme i kojeg pomicemo
class Screen {

    private float speed; // Izracunata brzina kretanja ekrana ovisna i o kretanju lika
    private int level, levelTimer=0; // Temeljna brzina kretanja ekrana i timer koji povecava level po potrebi (svako 30 sekundi)
    private ArrayList<Platform> platforms;
    private int noOfPlatforms = 6; // Koliko platformi će biti na ekranu u isto vrijeme
    private float screenStart = 150, screenEnd = width - screenStart; // Imat cemo rubove na ekranu pa nam ovo treba (Height ne trebamo jer su rubovi samo lijevo i desno)
    private float maxPlatformWidth = 400;

    //podaci za sat
    int cx, cy, prvi_prolazak=0;
    float secondsRadius,clockDiameter ;
    String comboWord;
    int comboWordFrameCount, comboWordSize;

    Screen()
    {
        level = 0; // Pocetna brzina treba bit nula jer se platforme tek micu kada igrac stane na platformu iznad cetvrte
        platforms = new ArrayList<Platform>();

        //postavke sata

        int clock_radius = 47;
        secondsRadius = clock_radius * 0.72;
        clockDiameter = clock_radius * 1.8;
        cx = 56;
        cy = 420;
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
        if(levelTimer == 1800) // 30 sekundi (1800 frameova kada je 60 FPS)
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
            var++;
            if (var>255)var=0;
            textWithOutline(comboWord, height/2, width/2, color(var, 255, 255), comboWordSize);
            comboWordFrameCount--;
        }
    }

    // Na kraju comboa postavlja rijec koja se crta (good, wow i sl.) i postavlja koliko frameova ce se pokazivati 
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
      var++;
      if (var>255)var=0;
      textWithOutline("Hurry up!", height/2+r, width/3+r, color(var, 255, 255), 60);
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

    int getLevel()
    {
        return level;
    }

    void setLevel(int v)
    {
        level = v;
        if(v==1 && prvi_prolazak==0)
        {
          prvi_prolazak=1;
        }
    }

    ArrayList<Platform> getPlatforms()
    {
        return platforms;
    }
}
