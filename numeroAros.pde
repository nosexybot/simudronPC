import saito.objloader.*;
import shapes3d.*;

class Numeros implements I_Shape {
    // declaracion del objeto a mostrar
    OBJModel numero;
    
    Numeros (PApplet simudron, int i) {
        // llamando al objeto OBJObject
        numero = new OBJModel(simudron, i + ".obj");//, "relative", TRIANGLES);
        
        numero.disableDebug();
        
        // escalado del modelo para ajustarlo a la pantalla
        numero.scale(0.2);
        
        noStroke();
    }
    
    @Override
    void drawForPicker(PGraphicsOpenGL pickBuffer) {
    }
    
    @Override
    void drawWithoutTexture(PApplet app) {              
        numero.draw();
    }
    
    @Override
    void drawWithTexture(PApplet app, PImage skin) {
    }
}
