// formas 3D -> terreno y aros
import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;

class Terreno {

    // terreno y aros... y otros objetos interesantes
    Terrain terrain;
    TerrainCam cam;
    Dron dron;
    Xshape quad;
    Aros aros;
    Box pausado;     //caja para cartel "juego en pausa"
    Box colision;    //caja para cartel "colisión"
    Imagenes imagen;
    NetAddress ipRemota;

    // variables de control
    int camHoversAt = 5;
    float camSpeed;
    float terrainSize = 1000;
    float horizon = 500;
    long time;
    float giro_camara_acum = 0;
    int distancia_dron = 15;
    float pos_Y_comun, pos_X_dron, pos_Z_dron;
    boolean pausaJuego = false, colisionAro = false, finJuego = false;
    int[] aroPasado = {0,0,0,0,0,0,0,0,0,0};
	int contador = 0;

    // posición de dron y cámara;
    PVector dron_pos;
    PVector dron_rot;
    PVector dron_giro;
    PVector dron_mov;
    PVector dron_dir;
    PVector cam_pos;
    PVector cam_pos_intermedio;
    PVector cam_rot;
    PVector cam_dir;

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

    Terreno(PApplet simudron, NetAddress ipR) {
        // objeto para enviar mensajes
        ipRemota = ipR;

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

        // se crean los aros (con los números dentro.. si lo permite el sistema)
        aros = new Aros(terrain, terrainSize, 1, simudron);

        // se crean cajas con los carteles de "pausa" y "colisión"
        imagen = new Imagenes(width, height);
        pausado = new Box(simudron, 15, 10, 0);
        pausado.setTexture(imagen.vImagenes[31], Box.FRONT);
        pausado.drawMode(S3D.TEXTURE);
        colision = new Box(simudron, 10, 4, 0);
        colision.setTexture(imagen.vImagenes[47], Box.FRONT);
        colision.drawMode(S3D.TEXTURE);

        // inicialización de PVectores de cámara y dron
        dron_pos = new PVector (0,-10,distancia_dron);
        dron_rot = new PVector (0,PI,0);
        dron_giro = new PVector (0,PI,0);
        dron_mov = new PVector (0,-10,distancia_dron);
        dron_dir = new PVector (0,0,1);
        cam_pos = new PVector (0,-13,0);
        cam_pos_intermedio = new PVector (0,-13, 0);
        cam_rot = new PVector (0,PI,0);
        cam_dir = new PVector (0,0,1);

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
        println (dron_rot.y);
        println(aros.posAros[0]);
        println(dron_pos);

        // Set the camera view before drawing
        cam.camera();

        // colocar el dron en el espacio 3D
        quad.moveTo(dron_pos);
        quad.rotateTo(dron_giro);
        quad.draw();

        // pintar números dentro de los aros
    //    aros.pintarNumeros();

        // pintar el cartel de "pausa"
        if (pausaJuego){
			pausado.moveTo(dron_pos.x, dron_pos.y-8, dron_pos.z);
            pausado.rotateTo(0,PI,0);
            pausado.draw();
		}

        // pintar el cartel de "colisión"
        if (colisionAro) {
            colision.moveTo(dron_pos.x, dron_pos.y-10, dron_pos.z);
            colision.rotateTo(0,PI,0);
            colision.draw();
            contador++;
			if (contador >= 100) {
				colisionAro = false;
				contador = 0;
			}
        }

        // pintar el terreno global con todo dentro
        terrain.draw();
    }

    void calcula (float[] parametros)
    {
        // movimiento de elevación
        if (parametros[0] != 0) {
            cam_pos.y = -(13 + parametros[0]);
            if (cam_pos.y > -13)
                cam_pos.y = -13;
            dron_pos.y = cam_pos.y + 3;
        }

        // movimiento de giro sobre sí mismo
        if (parametros[1] != 0) {
            float angulo = atan2(parametros[1], distancia_dron);
            cam_rot.y -= angulo;
            dron_rot.y = cam_rot.y;

            cam_pos.x = (distancia_dron * sin(angulo + cam_rot.y)) + dron_pos.x;
            cam_pos.z = (distancia_dron * cos(angulo + cam_rot.y)) + dron_pos.z;
        }

        // movimiento de desplazamiento lateral
        if (parametros[2] != 0) {
            float factor = map(parametros[2], -10, 10, -0.45, 0.45);
            float aux = dron_rot.y % 2*PI;
            if (aux >= 1.5*PI && aux < 0.5*PI)
                dron_rot.z = PI * factor * (-1);
            else
                dron_rot.z = PI * factor;

            dron_dir.set(0,0,1);
            dron_dir.x = dron_dir.x * cos(dron_rot.y) - dron_dir.z * cos(dron_rot.y);
            dron_dir.y = 0;
            dron_dir.z = dron_dir.x * sin(dron_rot.y) + dron_dir.z * sin(dron_rot.y);
            dron_dir.normalize();
            dron_dir.mult(-factor * 3); //parametros[2]);
            dron_pos = PVector.add(dron_pos, dron_dir);

            cam_pos = PVector.add(cam_pos, dron_dir);
        }
        else {
            dron_rot.z = 0;
        }

        // movimiento de desplazamiento de avance/retroceso
        if (parametros[3] != 0) {
            float factor = map (parametros[3], -10, 10, -0.40, 0.40);
            float aux = dron_rot.y % 2*PI;
            if (aux <= 1.5*PI && aux > 0.5*PI){
                dron_rot.x = PI * factor * (-1);  //parametros[3];
            }
            else{
                dron_rot.x = PI * factor;  //parametros[3] * (-1);
            }

            dron_dir.set(0,0,1);
            dron_dir.x = dron_dir.x * cos(dron_rot.y + 0.5*PI) - dron_dir.z * cos(dron_rot.y + 0.5*PI);
            dron_dir.y = 0;
            dron_dir.z = dron_dir.x * sin(dron_rot.y + 0.5*PI) + dron_dir.z * sin(dron_rot.y + 0.5*PI);
            dron_dir.normalize();
            dron_dir.mult(-factor * 3); //parametros[3]);
            dron_pos = PVector.add(dron_pos, dron_dir);

            cam_pos = PVector.add(cam_pos, dron_dir);
        }
        else {
            dron_rot.x = 0;
        }

        if (parametros[4] != 0) {
            dron_rot.x += 0.2;
        }
    }

    void calculaFisica(){
        pos_Y_comun = elevacion.getValor(cam_pos.y);
        // fisica de la camara
    //    cam_pos_intermedio.x = desplazamientoCamX.getValor(cam_pos.x);
        cam_pos_intermedio.x = cam_pos.x;
        cam_pos_intermedio.y = pos_Y_comun;
    //    cam_pos_intermedio.z = desplazamientoCamZ.getValor(cam_pos.z);
        cam_pos_intermedio.z = cam_pos.z;
    //    cam.rotateViewTo(rotacion_cam.getValor(1.5*PI-cam_rot.y));
        cam.eye(cam_pos_intermedio);
    //    cam.eye(cam_pos);
        cam.rotateViewTo(1.5*PI-cam_rot.y);

        // fisica del dron
        dron_mov.x = desplazamientoX.getValor(dron_pos.x);
    //    dron_mov.y = pos_Y_comun + 5;
        dron_pos.y = pos_Y_comun + 5;
        dron_mov.z = desplazamientoZ.getValor(dron_pos.z);
        dron_giro.x = giroDronX.getValor(dron_rot.x);
    //    dron_giro.y = giroDronY.getValor(dron_rot.y);
        dron_giro.y = dron_rot.y;
        dron_giro.z = giroDronZ.getValor(dron_rot.z);
    }

    void calculaColision() {
        // ecuación a satisfacer por los puntos de un toroide
        // x^2 + y^2 = ( RadioToroide + (radioMenor^2 - z^2)^(1/2) )^2
        for (int i = 0; i < aros.numeroAros; i++) {
            float izq = pow(dron_pos.x - aros.posAros[i].x, 2) + pow(dron_pos.y - aros.posAros[i].y, 2);
            float der_aux1 = pow(15 + 3 + 3, 2);
            float der_aux2 = pow(15 - 3 - 3, 2);
            float z_aux = dron_pos.z - aros.posAros[i].z;

            // comprueba si el dron está colisionando con el cilindro con:
            //    ..radio interior -> RadioToroide - radioMenor - 1/2*anchoDron
            //    ..radio exterior -> RadioToroide + radioMenor + 1/2*anchoDron
            //    ..longitud -> radioMenor + anchoDron
            if (izq <= der_aux1 && izq >= der_aux2) {
                if (z_aux >= (-1)*(3+1.5) && z_aux <= (3+1.5)) {
                    colisionAro = true;

                    // ubicación de dron en punto de partida
                    dron_pos = new PVector (0,-10,distancia_dron);
                    cam_pos = new PVector (0,-13,0);
                    dron_rot = new PVector (0,PI,0);
                    cam_rot = new PVector (0,PI,0);

                    // mensaje de colision a tablet
                    OscMessage miMensaje = new OscMessage("colision");
                    miMensaje.add(2);
                    oscP5.send(miMensaje, ipRemota);

                    return;
                }
            }
            // si no -> comprueba si está en el interior del cilindro anterior
            else if(izq < der_aux2) {
                if (z_aux >= (-1)*(3+1.5) && z_aux <= (3+1.5)) {
                    // marca el aro pasado
                    aroPasado[i] = 1;
                    // mensaje de paso a través de un aro
                    OscMessage miMensaje = new OscMessage("PasaAro");
                    miMensaje.add(i);
                    // si es el último aro -> informa de ello y termina juego.
                    if (i == aros.numeroAros - 1) {
                        miMensaje.add(1);
                        finJuego = true;
                    }
                    else
                        miMensaje.add(0);
                    oscP5.send(miMensaje, ipRemota);
                }
            }
        }
    }
};
