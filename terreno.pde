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
    
    // variables de control
    int camHoversAt = 5;
    float camSpeed;
    float terrainSize = 1000;
    float horizon = 500;
    long time;
    float giro_camara_acum = 0;
    int distancia_dron = 75;
    float pos_Y_comun, pos_X_dron, pos_Z_dron;
        
    // posición de dron y cámara;
    PVector dron_pos;
    PVector dron_rot;
    PVector dron_giro;
    PVector dron_mov;
    PVector cam_pos;
    PVector cam_pos_intermedio;
    PVector cam_rot;
    
    // física para movimientos
    Fisica elevacion;
    Fisica desplazamientoX;
    Fisica desplazamientoZ;
    Fisica desplazamientoCamX;
    Fisica desplazamientoCamZ;
    Fisica rotacion_cam;
    Fisica giroDronX;
    Fisica giroDronY;
    Fisica giroDronZ;
    
    Terreno(PApplet simudron) {
        // preparando el terreno de juego
        terrain = new Terrain(simudron, 60, terrainSize, horizon);
        terrain.usePerlinNoiseMap(0, 8, 0.15f, 0.15f);
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
        dron_pos = new PVector (0,-10,distancia_dron);
        dron_rot = new PVector (0,PI,0);
        dron_giro = new PVector (0,PI,0);
        dron_mov = new PVector (0,-10,distancia_dron);
        cam_pos = new PVector (0,-15,0);
        cam_pos_intermedio = new PVector (0,-15, 0);
        cam_rot = new PVector (0,PI,0);
        
        cam.eye(cam_pos);
        
        // inicialización de la física para cada movimiento
        elevacion = new Fisica();
        desplazamientoX = new Fisica();
        desplazamientoZ = new Fisica();
        desplazamientoCamX = new Fisica();
        desplazamientoCamZ = new Fisica();
        rotacion_cam = new Fisica();
        giroDronX = new Fisica();
        giroDronY = new Fisica();
        giroDronZ = new Fisica();
    }
    
    void dibuja () {
    //    cam.eye(cam_pos);
        // Set the camera view before drawing
        cam.camera();
    /*    
        print (dron_rot.y);
        print ("      ");
        println (cam_rot.y);
        print ("posicion dron X: ");
        print (dron_pos.x);
        print ("   rotacion dron X: ");
        println (dron_mov.x);
        print ("posicion dron Y: ");
        print (dron_pos.y);
        print ("   fisica dron Y: ");
        println (dron_mov.y);
        print ("fisica dron Z: ");
        print (dron_pos.z);
        print ("   fisica dron Z: ");
        println (dron_mov.z);       
        print ("rotacion dron X: ");
        print (dron_rot.x);
        print ("   fisicaR dron X: ");
        println (dron_giro.x);
        print ("rotacion dron Y: ");
        print (dron_rot.y);
        print ("   fisicaR dron Y: ");
        println (dron_giro.y);
        print ("rotacion dron Z: ");
        print (dron_rot.z);
        print ("   fisicaR cam Z: ");
        println (dron_giro.z) ;      
    */

            print ("cam_rot.y: ");
            println (cam_rot.y);    

    //    float altura = terrain.getHeight(0, 75);
    //    pushMatrix();
    //    quad.moveTo(pos_X_dron, pos_Y_comun + 5, pos_Z_dron);
    //    quad.moveTo(dron_mov);
        quad.moveTo(dron_pos);
    //    quad.rotateTo(dron_giro);
        quad.rotateTo(dron_rot);
    //  translate(pos_X_dron, pos_Y_comun + 5, pos_Z_dron);
    //    rotateX(dron_rot.x);
    //    rotateY(dron_rot.y);
    //    rotateZ(dron_rot.z);
        quad.draw();
    //    popMatrix();

        terrain.draw();

    }
    
    void calcula (float[] parametros)
    {
        // movimiento de elevación
        if (parametros[0] != 0) {
            //TODO elevación o bajada de dron
            cam_pos.y = -(int(15 + parametros[0]*12));
            if (cam_pos.y > -15)
                cam_pos.y = -15;
            dron_pos.y = cam_pos.y + 5;
        }
       
        // movimiento de giro sobre sí mismo
        if (parametros[1] != 0) {
            //TODO giro con centro en dron
            float angulo = atan2(parametros[1], distancia_dron);
        //    cam.rotateViewBy((1.5*PI)-angulo);
        //    cam.turnBy((1.5*PI)-angulo);
            cam_rot.y -= angulo;
        //    cam.rotateViewTo(1.5*PI-cam_rot.y);
            dron_rot.y = cam_rot.y;
            
            cam_pos.x = int(distancia_dron * sin(angulo + cam_rot.y)) + dron_pos.x;
            cam_pos.z = int(distancia_dron * cos(angulo + cam_rot.y)) + dron_pos.z;
        }
        
        // movimiento de desplazamiento lateral
        if (parametros[2] != 0) {
            //TODO movimiento lateral y rotación sobre eje z de dron
            float factor = map (parametros[2], -10, 10, -0.45, 0.45);
            float aux = dron_rot.y % 2*PI;
            if (aux >= 1.5*PI && aux < 0.5*PI)
                dron_rot.z = PI * factor * (-1);
            else
                dron_rot.z = PI * factor;

            dron_pos.x -= factor * 3 * cos(dron_rot.y-2*(PI-dron_rot.y%(2*PI))); //parametros[2];
            dron_pos.z -= factor * 3 * sin(dron_rot.y-2*(PI-dron_rot.y%(2*PI))); //parametros[2];
            cam_pos.x -= factor * 3 * cos(cam_rot.y-2*(PI-cam_rot.y%(2*PI))); //parametros[2];
            cam_pos.z -= factor * 3 * sin(cam_rot.y-2*(PI-cam_rot.y%(2*PI))); //parametros[2];
        }
        else {
            dron_rot.z = 0;
        }
        
        // movimiento de desplazamiento de avance/retroceso
        if (parametros[3] != 0) {
            //TODO movimiento frontal y rotación sobre eje x de dron
            float factor = map (parametros[3], -10, 10, -0.40, 0.40);
            float aux = dron_rot.y % 2*PI;
            if (aux >= 0 && aux < PI){
                dron_rot.x = PI * factor;  //parametros[3];
            }
            else{
                dron_rot.x = PI * factor * (-1);  //parametros[3] * (-1);
            }
            dron_pos.z += factor * 3; //parametros[3];
			cam_pos.z += factor * 3; //parametros[2];
        } 
        else {
            dron_rot.x = 0;
        }
    }
    
    void calculaFisica(){
        pos_Y_comun = elevacion.getValor(cam_pos.y);
        // fisica de la camara
        cam_pos_intermedio.x = desplazamientoCamX.getValor(cam_pos.x);
		cam_pos_intermedio.y = pos_Y_comun;
		cam_pos_intermedio.z = desplazamientoCamZ.getValor(cam_pos.z);
	//	cam.rotateViewTo(rotacion_cam.getValor(1.5*PI-cam_rot.y));
	//	cam.eye(cam_pos_intermedio);
        cam.eye(cam_pos);
        cam.rotateViewTo(1.5*PI-cam_rot.y);
        
        // fisica del dron
        dron_mov.x = desplazamientoX.getValor(dron_pos.x);
		dron_mov.y = pos_Y_comun + 5;
		dron_mov.z = desplazamientoZ.getValor(dron_pos.z);
		dron_giro.x = giroDronX.getValor(dron_rot.x);
        dron_giro.y = giroDronY.getValor(dron_rot.y);
		dron_giro.z = giroDronZ.getValor(dron_rot.z);
    }
};
