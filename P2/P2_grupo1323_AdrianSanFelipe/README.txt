En el archivo reg_bank.vhd hemos cambiado el modo en el que se escriben los datos en el banco de registros.
Por defecto, nos encontramos que los datos se escriben mediante un flanco de subida.
Si lo cambiamos para que los datos se escriban en el flanco de bajada (falling_edge) adelantamos la escritura medio ciclo sobre las lecturas.
Así, evitamos el problema de intentar leer y escribir en el mismo ciclo.