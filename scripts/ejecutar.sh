# Crea la carpeta de tu práctica y entra en ella
mkdir proyecto_hadoop
cd proyecto_hadoop

# Descarga el libro en texto plano
curl -o quijote.txt https://www.gutenberg.org/cache/epub/2000/pg2000.txt

# Primero: Ejecuta el contenedor (Te meterá al sistema operativo del contenedor, deberás abrir otra terminal)
docker start -ai hadoop 


## ABRE OTRA TERMINAL EN TU COMPUTADORA Y SIGUE CON:
# Regresa a tu directorio inicial:
cd proyecto_hadoop # o ingresa la ruta completa si guardaste en un directorio especifico
# 1. Crea la estructura de carpetas dentro del contenedor como usuario root
docker exec -u root hadoop mkdir -p /tmp/equipo3/datos_entrada

# 2. Copia el archivo desde tu máquina a la nueva carpeta
docker cp quijote.txt hadoop:/tmp/equipo3/datos_entrada/quijote.txt

# 3. Dale la propiedad de toda la carpeta "equipo3" al usuario hadoop
docker exec -u root hadoop chown -R hadoop:hadoop /tmp/equipo3/

# 4. Entra a la terminal del contenedor iniciando sesión como el usuario hadoop
docker exec -it -u hadoop hadoop /bin/bash


# ==========================================
# DENTRO DEL CONTENEDOR DEBIAN
# ==========================================

# Mueve tu terminal a la ruta donde está el archivo .jar
cd /opt/hadoop/share/hadoop/mapreduce/

# Ejecuta aggregatewordcount (conteo de palabras), con la indicación de que lea .txt con textinputformat
hadoop jar hadoop-mapreduce-examples-3.3.6.jar aggregatewordcount /tmp/equipo3/datos_entrada /tmp/equipo3/salida_conteo 1 textinputformat

# Ejecuta aggregatewordhist (histograma), con la indicación de que lea .txt con textinputformat
hadoop jar hadoop-mapreduce-examples-3.3.6.jar aggregatewordhist /tmp/equipo3/datos_entrada /tmp/equipo3/salida_histograma 1 textinputformat

# Verifica la existencia de los archivos generados
ls -l /tmp/equipo3/salida_conteo/
ls -l /tmp/equipo3/salida_histograma/

# Valida los resultados en pantalla (¡TOMA CAPTURAS DE PANTALLA DE ESTO PARA TU REPORTE!)
# Esto imprimirá las primeras 20 líneas del conteo de palabras
head -n 20 /tmp/equipo3/salida_conteo/part-r-00000

# Esto imprimirá las primeras 20 líneas del histograma
head -n 20 /tmp/equipo3/salida_histograma/part-r-00000

# Sal del contenedor
exit


# ==========================================
# EN TU PC (HOST)
# ==========================================

# Crea la carpeta de resultados para alojar las evidencias
mkdir resultados

# Copia las carpetas procesadas desde Debian directo a tu nueva carpeta de resultados
docker cp hadoop:/tmp/equipo3/salida_conteo ./resultados/
docker cp hadoop:/tmp/equipo3/salida_histograma ./resultados/
