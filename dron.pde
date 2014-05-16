import saito.objloader.*;
import shapes3d.*;

class Dron implements I_Shape {

    // declaracion del objeto a mostrar
    OBJModel quadracopter;
    float rotX;
    float rotY;
    float centroX = 0.85 * width;
    float centroY = 0.8 * height;
    
    Dron (PApplet simudron) {
        // llamando al objeto OBJObject
        quadracopter = new OBJModel(simudron, "Ladybird_Red.obj", "relative", TRIANGLES);
        // activando la salida depurada
        quadracopter.disableDebug();
        // escalado del modelo para ajustarlo a la pantalla
        quadracopter.scale(0.5);
        noStroke();
    }
    
    @Override
    void drawForPicker  (  PGraphicsOpenGL   pickBuffer  ) {
    }
    
    @Override
    void drawWithoutTexture  (  PApplet   app  ) {
        quadracopter.draw();
    }
    
    @Override
    void drawWithTexture  (  PApplet   app, PImage   skin ) {
    }

};