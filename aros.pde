class Aros {
    Toroid[] aros;
    PVector[] posAros;
    int numeroAros;
    Numeros[] numeros1;
    Xshape[] numeros;
    float rotateNum = 180;

    Aros(Terrain terrain, float terrainSize, int nivel, PApplet simudron) {
        if(nivel == 1)
            numeroAros = 5;
        else if(nivel == 2)
            numeroAros = 7;
        else
            numeroAros = 10;
            
        aros = new Toroid[numeroAros];
        posAros = new PVector[numeroAros];
        PVector orientation = new PVector(0f,0f,90f);
        PVector centreOfRotation = new PVector(0f,0f,0f);
        for(int i = 0; i < numeroAros; i++) {
            // Create the train engine
            aros[i] = new Toroid(simudron, 50, 50, orientation, centreOfRotation);
            aros[i].rotateToX(radians(random(-5, 5)));
            aros[i].rotateToY(radians(random(-70, 70)));
            aros[i].setRadius(3/*grosor anillo*/, 3 /*profundidad*/, 15 /*tamaño global*/);
            aros[i].moveTo(getRandomPosOnTerrain(terrain, terrainSize, i/*, 50*/));
        //    if(i == numeroAros - 1)
            if (i%2 == 0)
            aros[i].setTexture("texturas/rouge.jpg", 8, 4);
            else
            aros[i].setTexture("texturas/tartan.jpg", 8, 4);
            aros[i].drawMode(S3D.TEXTURE);
            terrain.addShape(aros[i]);
        }

        // se añade el numero al escenario
        numeros1 = new Numeros[10];
        numeros = new Xshape[10];

        for(int i = 0; i < 10; i++) {
            numeros1[i] = new Numeros(simudron, i);
            numeros[i] = new Xshape(simudron);
            numeros[i].setXshape(numeros1[i]);
        }
    }

    public void pintarNumeros()
    {
        rotateNum += 5;
        if(rotateNum > 359)
            rotateNum = 0;
          
        for(int i = 0; i < numeroAros; i++) {
            numeros[i].moveTo(posAros[i]);
            numeros[i].rotateToY(radians(rotateNum));
            numeros[i].draw();
        }
    }
    /**
     * Get a random position on the terrain avoiding the edges
     * @param t the terrain
     * @param tsize the size of the terrain
     * @param height height above terrain
     * @return
     */
    public PVector getRandomPosOnTerrain(Terrain t, float tsize/*, float height*/, int nAro){
        //PVector p = new PVector(random(-tsize/2.1f, tsize/2.1f), 0, random(-tsize/2.1f, tsize/2.1f));
        float dist = (tsize/2.1f) / numeroAros + 1;

        PVector p = new PVector(random(-tsize/4f, tsize/4f) /*1/4 del terreno*/, 0, dist*(nAro+1));

        float height1 = random (0, 100);
        p.y = t.getHeight(p.x, p.z) - 30/*a ras de suelo*/ - height1;

        posAros[nAro] = p;

        return p;
    }
}

//en la funcion debuja del terreno
// aros.pintarNumeros();

//en el constructor del terreno
//aros = new Aros(terrain, terrainSize, 1, simudron);
