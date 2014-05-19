class Fisica {

    // declaracion del objeto a mostrar
    float consigna;
    float consigna_ant;
    float intermedio;
    float tau;
    int contador;

    Fisica () {
        consigna = 0;
        consigna_ant = 0;
        intermedio = 0;
        tau = 40;
        contador = 0;
    }
    
    float getValor  (float set_point) {
        // comprobar si se trata del mismo valor a alcanzar
        if (consigna != set_point) {
            consigna = set_point;
            consigna_ant += intermedio;
            contador = 0;
        }
        else
            contador++;
        
        // obtener valor intermedio
        intermedio = (consigna - consigna_ant) * ( 1 - exp( -contador / tau ));
	
        return consigna_ant + intermedio;
    }
};