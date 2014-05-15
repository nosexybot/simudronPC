

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
final int CONECTANDO = 0, MAIN = 1, JUEGO = 2, PAUSE = 3;
final int MAX_ESTADOS = 5;

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

long time;

//*********************************************************************
// función de incialización

//*********************************************************************
void setup() {
    // Tamaño de la imagen de background y orientación
    //size(displayWidth, displayHeight);
    size(850, 480, P3D);

    // inicialización del objeto imagen con ruta y tamaño del display
    imagen = new Imagenes(width, height);
    imageMode(CENTER);

    // establecimiento de estado de inicio de programa
    estado = JUEGO;

    // comunicaciones
    oscP5 = new OscP5(this, 12000);
    ipRemota = new NetAddress(ipR, 12000); // nexus7 en zulo casa

    // configuración inicial de los textos
    textAlign(CENTER, CENTER);
    textSize(24);

    // preparando el terreno de juego
    terreno = new Terreno(this);
	parametros = new float[4];
	parametros = {0,0,0,0};

    time = millis();
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
			break;
		case JUEGO:
		//*******************************************************************************************
			background(50);
			directionalLight(255,255,255,1,1,1);
			ambientLight(250, 250, 250);

			long t = millis() - time;
			time = millis();

			// actualizar direccion de la cámara
			float achange = 0, hchange = 0;
			if(mousePressed){
				achange = (mouseX - pmouseX);
				hchange = (mouseY - pmouseY);
			}
			terreno.calcular(parametros);
			terreno.dibuja();

			break;
		case PAUSE:
		//******************************************************************************************* 
			//Se mantiene la imagen anterior del juego y se muestra "juego en pausa"
			image(imagen.vImagenes[31], 0.5*width, 0.5*height);
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
	if (theOscMessage.checkTypetag("fffi")) { //acelerometro
		acelerometroX = theOscMessage.get(0).floatValue();
		acelerometroY = theOscMessage.get(1).floatValue();
		acelerometroZ = theOscMessage.get(2).floatValue();
	}

	if (theOscMessage.checkTypetag("fff")) { //giroscopo
		giroscopoX = theOscMessage.get(0).floatValue();
		giroscopoY = theOscMessage.get(1).floatValue();
		giroscopoZ = theOscMessage.get(2).floatValue();
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
				break;
			case 3:
				estado = PAUSE;
		}
	}
}

void keyPressed()
{
	//jostick izquierdo
	if (key == 'a'){
		parametros[1] = -3;
	}

	if (key == 'd'){
		parametros[1] = 3;
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
		parametros[3] = 3;
	}

	if (keyCode == DOWN){
		parametros[3] = -3;
	}

	if (keyCode == LEFT){
		parametros[2] = -3;
	}

	if (keyCode == RIGHT){
		parametros[2] = 3;
	}

}

void keyReleased() {
	for (int i = 1; i < 4, i++)
		parametros[i] = 0;
}
