// formas 3D -> terreno y aros
import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;

class Terreno {

    // terreno y aros
    Terrain terrain;
    TerrainCam cam;
	Dron dron;
	Xshape quad;
    int camHoversAt = 10;
    float camSpeed;
    float terrainSize = 1000;
    float horizon = 500;
    long time;
    float giro_camara_acum = 0;
	PVector dron_pos;
	PVector dron_rot;
	PVector cam_pos;
	PVector cam_rot;

    Terreno(PApplet simudron) {
        // preparando el terreno de juego
        terrain = new Terrain(simudron, 60, terrainSize, horizon);
        terrain.usePerlinNoiseMap(0, 40, 0.15f, 0.15f);
        terrain.setTexture("texturas/grass2.jpg", 4);
        terrain.tag = "Ground";
        terrain.tagNo = -1;
        terrain.drawMode(S3D.TEXTURE);
        //terrain.y(200);

        // inicializando la cámara
        camSpeed = 10;
        cam = new TerrainCam(simudron);
        cam.adjustToTerrain(terrain, Terrain.WRAP, camHoversAt);
        cam.camera();
        cam.speed(camSpeed);
        cam.forward.set(cam.lookDir());

		// Se le asigna al terreno la cámara inicializada
        terrain.cam = cam;
        
		// se crea un objeto dron y se incluye en el entorno 3D de Shapes3D
		dron = new Dron (simudron);
		quad = new Xshape(simudron);
		quad.setXshape(dron);
		
		// inicialización de PVectores de cámara y dron
		dron_pos = new PVector (0,70,0);
		dron_rot = new PVector (0,0,0);
		cam_pos = new PVector (0,0,0);
		cam_rot = new PVector (0.0.0);
    }
    
    void dibuja () {
		calcular(parametros);
        achange *= PI / width;
        giro_camara_acum -= achange;
        cam.rotateViewBy(achange);
        cam.turnBy(achange);

        // calculo del inncremento de movimiento de la camara
        // basado en la velocidad que se envía (actalizar camSpeed)
        //cam.move(t/1000.0f);
        
        // ajusta la altura de la cámara sobre el terreno a una altura dada. 
        // ojo que esto puede variar independientemente del parámetro pasado
        camHoversAt -= hchange * 0.2;
    /*    if (camHoversAt < 5)
            camHoversAt = 5;
        else if(camHoversAt > 220)
            camHoversAt = 220;
   */   cam.adjustToTerrain(terrain, Terrain.WRAP, camHoversAt);
        // Set the camera view before drawing
        cam.camera();
        
		pushMatrix();
		float altura = terrain.getHeight(0, 75);
		translate(75*sin(giro_camara_acum),altura-10,75*cos(giro_camara_acum));
		rotateY(giro_camara_acum+PI);
		quad.draw();
		popMatrix();

        terrain.draw();
    }
	
	void calcular (float[] parametros)
	{
		if (parametros[0] != 0) {
			//TODO elevación o bajada de dron
		}
		
		if (parametros[1] != 0) {
			//TODO giro con centro en dron
		}
		
		if (parametros[2] != 0) {
			//TODO movimiento lateral y rotación sobre eje z de dron
		}
		
		if (parametros[3] != 0) {
			//TODO movimiento frontal y rotación sobre eje x de dron
		}
	}
}
