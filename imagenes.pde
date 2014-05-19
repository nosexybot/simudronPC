/**************************************************
* background (1280 x 800)
* pulsador atras (200 x 200) -> 01 y 02
* pulsador siguiente (200 x 200) -> 03 y 04
* base joystick (300 x 300) -> 05
* bola joystick (200 x 200) -> 06
* pulsador "conectar" (400 x 200) -> 07 y 08
* pulsador salir (200 x 200) -> 09 y 10
* triángulo ajuste nivel (100 x 100) -> 11
* barra ajuste nivel (300 x 10) -> 12
* música (200 x 200) -> 13 y 14
* pulsador pausa (200 x 200) -> 15 y 16
* pulsador ajustes (200 x 200) -> 17 y 18
* sonido (200 x 200) -> 19 y 20
* "puntuacion" (500 x 150) -> 21
* "simudron" (500 x 300) -> 22
* "ajustes" (500 x 150) -> 23
* menu de ajustes (1000 x 600) -> 24
* ayudas (1000 x 600) -> 25, 26 y 27
* "continuar-salir" (500 x 300) -> 28
* "esperando conexion" (500 x 300) -> 29
* "esperando inicio juego" (500 x 450) -> 30
* "juego en pausa" (500 x 450) -> 31
* menú principal (500 x 450) -> 32
* casillas de verificación (200 x 200) -> 33 y 34
* punto (100 x 100) -> 35
* dos puntos (100 x 200) -> 36
* 0 (200 x 200) -> 37
* 1 (100 x 200) -> 38
* Resto de numeros (200 x 200) -> 39 - 46
* "colisión" (460 x 120) -> 47
* "fin nivel incompleto" -> 48
* "fin nivel completo" -> 49
* bola joystick otro color -> 50
**************************************************/

final int nImagenes = 51;
final String imagePrefix = "simudron";

class Imagenes
{
	public PImage background, background_blur;
	public PImage[] vImagenes;

	public Imagenes(int ancho, int alto)
	{   
		background = loadImage("background.png");
		background_blur = loadImage("background_blur.png");

		float fAncho = ancho / (float)background.width;
		float fAlto = alto / (float)background.height;

		background.resize(ancho, alto);
		background_blur.resize(ancho, alto);

		vImagenes = new PImage[nImagenes];
		String filename;
		for (int i = 1; i < nImagenes; i++) {
			filename = imagePrefix + nf(i, 2) + ".png";
			vImagenes[i] = loadImage(filename);
			vImagenes[i].resize((int)(vImagenes[i].width*fAncho), (int)(vImagenes[i].height*fAlto));
		}
	}
};
