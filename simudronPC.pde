

//*********************************************************************
// librerías
//*********************************************************************
// comunicaciones
import oscP5.*;
import netP5.*;

import processing.opengl.*;

//*********************************************************************
// variables globales
//*********************************************************************

// ESTADOS de la aplicación
final int CONECTANDO = 0, MAIN = 1, JUEGO = 2, PAUSE = 3, FINJUEGOOK = 4, FINJUEGONOOK = 5;
final int MAX_ESTADOS = 6;

int estado; // variable de control de esetados

// control de tiempo
long tiempo_ant;  // para intermitencia de mensaje "esperando conexión"
boolean blinker;  // estado de visibilidad del mensaje

// objeto para cargar las diferentes imágenes que conforman los estados y su control
Imagenes imagen;

// control de comunicaciones
OscP5 oscP5;
NetAddress ipRemota;
String ipR = "192.168.1.3";

// sensores
float acelerometroX, acelerometroY, acelerometroZ;
float giroscopoX, giroscopoY, giroscopoZ;

// terreno y aros
Terreno terreno;
float[] parametros;


//*********************************************************************
// función de incialización

//*********************************************************************
void setup() {
    // Tamaño de la imagen de background y orientación
    //size(displayWidth, displayHeight);
    size(displayWidth, displayHeight, P3D); //800, 500, P3D);

    // inicialización del objeto imagen con ruta y tamaño del display
    imagen = new Imagenes(width, height);
    imageMode(CENTER);

    // establecimiento de estado de inicio de programa
    estado = CONECTANDO;

    // comunicaciones
	thread("comunicaciones");
//    oscP5 = new OscP5(this, 12000);
//    ipRemota = new NetAddress(ipR, 12000); 

    // configuración inicial de los textos
    textAlign(CENTER, CENTER);
    textSize(24);

    // preparando el terreno de juego
    terreno = new Terreno(this, ipRemota);
	parametros = new float[5];
    for (int i = 0; i < 5; i++)
        parametros[i] = 0;

    tiempo_ant = millis();
}

//*********************************************************************
// bucle de proceso de la aplicación
//*********************************************************************
void draw() {
    // ESTADOS de la aplicación
    //---------------------------------------------------------------------------------------------
    switch(estado) {
      
		case CONECTANDO:
		//*******************************************************************************************
		// control de tiempo
			long tiempo = millis();
			// imagen de fondo inicial del juego
			background(imagen.background);

			// control de intermitencia de mensaje "espera de conexión"
			if (tiempo - tiempo_ant > 1000) {
				blinker = !blinker;
				tiempo_ant = tiempo;
			}
			if (blinker){
				image(imagen.vImagenes[29],
					  width+20-(imagen.vImagenes[29].width*(width/ (float)imagen.background.width))*0.5,
					  50+(imagen.vImagenes[29].height*(height/ (float)imagen.background.height))*0.5);
			}

			// control de pulsador de "salida" cambiando imagen
			if(mousePressed &&
				mouseY > 0.85*height - imagen.vImagenes[9].height/2 &&
				mouseY < 0.85*height + imagen.vImagenes[9].height/2 &&
				mouseX > 0.9*width - imagen.vImagenes[9].width/2 &&
				mouseX < 0.9*width + imagen.vImagenes[9].width/2)
				image(imagen.vImagenes[10], 0.9*width, 0.85*height);
			else
				image(imagen.vImagenes[9], 0.9*width, 0.85*height);
			break;
		case MAIN:
		//*******************************************************************************************
			background(imagen.background_blur);
			// primer dibujado del juego
			image(imagen.vImagenes[30], 0.5*width, 0.5*height);
			// puesta de la partida en disposición de juego
			terreno.pausaJuego = false;
			break;
		case JUEGO:
		//*******************************************************************************************
			background(#00BFFF);
			directionalLight(255,255,255,1,1,1);
			ambientLight(250, 250, 250);

			// actualizar direccion de la cámara
			float achange = 0, hchange = 0;
			if(mousePressed){
				achange = (mouseX - pmouseX);
				hchange = (mouseY - pmouseY);
			}
			
			// lanza el juego si no ha terminado con los aros
			if (terreno.finJuego) {
				int arosPasados = 0;
				for (int i = 0; i < terreno.aros.numeroAros; i+=2)
					arosPasados += terreno.aroPasado[i];
				if (arosPasados >= terreno.aros.numeroAros * 0.5 +1)
					estado = FINJUEGOOK;
				else
					estado = FINJUEGONOOK;
			}
			else {
				terreno.calcula(parametros);
				terreno.calculaFisica();
				terreno.calculaColision();
				terreno.dibuja();
			}

			break;
		case PAUSE:
		//******************************************************************************************* 
			//Se mantiene la imagen anterior del juego y se muestra "juego en pausa"
		//	image(imagen.vImagenes[31], 0.5*width, 0.5*height);
			terreno.dibuja();
			break;
		case FINJUEGOOK:
		//******************************************************************************************* 
			background(imagen.background_blur);
			// imagen de juego felizmente terminado
			image(imagen.vImagenes[49], 0.5*width, 0.5*height);
			break;
		case FINJUEGONOOK:
		//******************************************************************************************* 
			background(imagen.background_blur);
			// imagen de juego terminado sin pasar por los aros obligatorios
			image(imagen.vImagenes[48], 0.5*width, 0.5*height);
			break;
    }
    //---------------------------------------------------------------------------------------------
}

//***********************************************************************************
// control de ordenes sobre pulsaciones de botón
//***********************************************************************************
void mouseReleased() {
	if(estado == CONECTANDO) {
	// pulsador de salida de programa
		if(mouseY > 0.85*height - imagen.vImagenes[9].height/2 &&
		   mouseY < 0.85*height + imagen.vImagenes[9].height/2 &&
		   mouseX > 0.9*width - imagen.vImagenes[9].width/2 &&
		   mouseX < 0.9*width + imagen.vImagenes[9].width/2)
			exit();
	}
}

//***********************************************************************************
// control de mensajes recibidos
//***********************************************************************************
void oscEvent(OscMessage theOscMessage) {
	// datos de sensores
	if (theOscMessage.checkTypetag("ffffii")) { //acelerometro
		acelerometroX = theOscMessage.get(0).floatValue();
        parametros[3] = acelerometroX;
		acelerometroY = theOscMessage.get(1).floatValue();
        parametros[2] = acelerometroY;
		acelerometroZ = theOscMessage.get(2).floatValue();
		giroscopoZ = theOscMessage.get(3).floatValue();
        int botonIzqPulsado = theOscMessage.get(4).intValue();
		int botonDerPulsado = theOscMessage.get(5).intValue();
		if (botonDerPulsado > 0)
		    parametros[0] = acelerometroZ;
		if (botonIzqPulsado > 0)
			parametros[1] = giroscopoZ;
		
	}

	if (theOscMessage.checkTypetag("ffff")) { //giroscopo
		int recorrido = imagen.vImagenes[6].height/2;
		float joystickIzqX = theOscMessage.get(0).floatValue();
		parametros[1] += map(joystickIzqX, -recorrido, recorrido, -10,10);
		float joystickIzqY = theOscMessage.get(1).floatValue();
		parametros[0] += map(joystickIzqY, -recorrido, recorrido, -10,10);
		float joystickDerX = theOscMessage.get(2).floatValue();
		parametros[2] += map(joystickDerX, -recorrido, recorrido, -10,10);
		float joystickDerY = theOscMessage.get(3).floatValue();
		parametros[3] += map(joystickDerY, -recorrido, recorrido, -10,10);
	}

	// cambios de estado
	if (theOscMessage.checkTypetag("i")) {
		switch (theOscMessage.get(0).intValue()) {
			case 0:
				estado = CONECTANDO;
				break;
			case 1:
				OscMessage miMensaje = new OscMessage("cambioEstado");
				miMensaje.add(0);
				oscP5.send(miMensaje, ipRemota);
				estado = MAIN;
				break;
			case 2:
				estado = JUEGO;
				terreno.pausaJuego = false;
				break;
			case 3:
				estado = PAUSE;
				terreno.pausaJuego = true;
				break;
			case 10:
				terreno.elevacion.tau = 15;
				terreno.desplazamientoX.tau = 15;
				terreno.desplazamientoZ.tau = 15;
				terreno.desplazamientoCamX.tau = 15;
				terreno.desplazamientoCamZ.tau = 15;
				terreno.rotacion_cam.tau = 15;
				terreno.giroDronX.tau = 15;
				terreno.giroDronY.tau = 15;
				terreno.giroDronZ.tau = 15;
				break;
			case 11:
				terreno.elevacion.tau = 25;
				terreno.desplazamientoX.tau = 25;
				terreno.desplazamientoZ.tau = 25;
				terreno.desplazamientoCamX.tau = 25;
				terreno.desplazamientoCamZ.tau = 25;
				terreno.rotacion_cam.tau = 25;
				terreno.giroDronX.tau = 25;
				terreno.giroDronY.tau = 25;
				terreno.giroDronZ.tau = 25;
				break;
			case 12:
				terreno.elevacion.tau = 40;
				terreno.desplazamientoX.tau = 40;
				terreno.desplazamientoZ.tau = 40;
				terreno.desplazamientoCamX.tau = 40;
				terreno.desplazamientoCamZ.tau = 40;
				terreno.rotacion_cam.tau = 40;
				terreno.giroDronX.tau = 40;
				terreno.giroDronY.tau = 40;
				terreno.giroDronZ.tau = 40;
		}
	}
}

void keyPressed()
{
	//jostick izquierdo
	if (key == 'a'){
		parametros[1] = -1;
	}

	if (key == 'd'){
		parametros[1] = 1;
	}

	if (key == 'w'){
		parametros[0] += 0.2;
	}

	if (key == 's'){
		parametros[0] -= 0.2;
		if (parametros[0] < 0)
			parametros[0] = 0;
	}

	// joystick derecho
	if (keyCode == UP){
		parametros[3] = 5;
	}

	if (keyCode == DOWN){
		parametros[3] = -5;
	}

	if (keyCode == LEFT){
		parametros[2] = -4;
	}

	if (keyCode == RIGHT){
		parametros[2] = 4;
	}
    
    if (key == 'r') {
        parametros[4] = 2;
    }

}

void keyReleased() {
	for (int i = 1; i < 5; i++)
		parametros[i] = 0;
    if (key == 'q')
        exit();
}

// hilo para el arranque de las comunicaciones en segundo plano
void comunicaciones() {
    oscP5 = new OscP5(this, 12000);
    ipRemota = new NetAddress(ipR, 12000);
}
