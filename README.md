# bda-equipo-3-agregacion

## 1. Integrantes del equipo
- René Nicolás Acosta López
- Germán Eduardo Ruiz Zúñiga
- Betel

## 2. Descripción del ejemplo y caso de uso real
El ejemplo consiste en el uso del texto completo de Don Quijote, un libro con miles de líneas. Queremos saber cuántas veces aparece cada palabra y cómo se distribuyen esas frecuencias. Hacerlo a mano, o leyendo el archivo línea por línea en una sola máquina, es lento y no escala si el texto crece a miles de libros.

Como caso real, Buscadores y redes sociales como Google lo han usado para construir el índice de la web, y empresas como Yahoo!, Facebook y LinkedIn lo usaron para analizar enormes registros de actividad.
Otra aplicación que tiene es el analisis de textos y vlogs, contar palabras, calcular estadísticas de documentos, revisar registros de servidores o clics, y ordenar grandes conjuntos de datos.

## 3. Requisitos
Contar con un contenedor docker previamente instalado con `Debian 12`, y haber instalado previamente `hadoop 3.3.6` o una versión más reciente de `hadoop` dentro de ese contenedor, además de contar con una versión estable de `Java` dentro del contenedor para el funcionamiento de Hadoop.

## 4. Paso a paso
### 4.1 Crea la carpeta de tu práctica y entra en ella
mkdir proyecto_hadoop
cd proyecto_hadoop

### 4.2 Descarga el libro en texto plano
Descargalo através del github o utiliza el siguiente comando:
`curl -o quijote.txt https://www.gutenberg.org/cache/epub/2000/pg2000.txt`

### 4.3 Ejecuta el contenedor 
Al ejecutar el contenedor te meterá al sistema operativo del contenedor, deberás abrir otra terminal.
`docker start -ai hadoop`


### 4.4 ABRE OTRA TERMINAL EN TU COMPUTADORA Y SIGUE CON:
1. Crea la estructura de carpetas dentro del contenedor como usuario root

`docker exec -u root hadoop mkdir -p /tmp/equipo3/datos_entrada`

2. Copia el archivo desde tu máquina a la nueva carpeta

`docker cp quijote.txt hadoop:/tmp/equipo3/datos_entrada/quijote.txt`

3. Dale la propiedad de toda la carpeta "equipo3" al usuario hadoop
`docker exec -u root hadoop chown -R hadoop:hadoop /tmp/equipo3/`

4. Entra a la terminal del contenedor iniciando sesión como el usuario hadoop
`docker exec -it -u hadoop hadoop /bin/bash`


### DENTRO DEL CONTENEDOR DEBIAN

Mueve tu terminal a la ruta donde está el archivo .jar
`cd /opt/hadoop/share/hadoop/mapreduce/`

Ejecuta aggregatewordcount (conteo de palabras), con la indicación de que lea .txt con textinputformat
`hadoop jar hadoop-mapreduce-examples-3.3.6.jar aggregatewordcount /tmp/equipo3/datos_entrada /tmp/equipo3/salida_conteo 1 textinputformat`

Ejecuta aggregatewordhist (histograma), con la indicación de que lea .txt con textinputformat
`hadoop jar hadoop-mapreduce-examples-3.3.6.jar aggregatewordhist /tmp/equipo3/datos_entrada /tmp/equipo3/salida_histograma 1 textinputformat`

Verifica la existencia de los archivos generados
`ls -l /tmp/equipo3/salida_conteo/`
`ls -l /tmp/equipo3/salida_histograma/`

Valida los resultados en pantalla con el siguiente comando, esto imprimirá las primeras 20 líneas del conteo de palabras:
`head -n 20 /tmp/equipo3/salida_conteo/part-r-00000`

Imprime las primeras 20 lineas del archivo:
`head -n 20 /tmp/equipo3/salida_histograma/part-r-00000`

### Sal del contenedor
`exit`


### EN TU PC (HOST)

1. Crea la carpeta de resultados para alojar las evidencias
`mkdir resultados`

Copia las carpetas procesadas desde Debian directo a tu nueva carpeta de resultados
`docker cp hadoop:/tmp/equipo3/salida_conteo ./resultados/`
`docker cp hadoop:/tmp/equipo3/salida_histograma ./resultados/` 

## 5. Resultado esperado
Se divide en dos partes, el resultado teorico y los resultados reales:
### 5.1 Resultado teórico:
El resultado teórico esperado (si no hubiera bug): Las herramientas aggregate deberían devolver una lista detallada con cada palabra única y su frecuencia exacta en el libro (por ejemplo, quijote 2167, sancho 1054).
### 5.2 Resultado real 1:
El resultado será únicamente record_count 38059. Debido al bug del framework en Hadoop 3.3.6, el sistema no separa el texto y simplemente cuenta el total de líneas del documento original.

### 5.3 Resultado real 2 (otra versión de Hadoop):


## 6. Explicación de Map y Reduce
1. Map: Los datos se dividen en bloques. Cada bloque se procesa por separado y produce pares clave → valor, por ejemplo (palabra, 1).
2. Shuffle: Hadoop junta y ordena automáticamente todos los pares que tienen la misma clave, y los manda al mismo reducer.
3. Combina los valores de cada clave (suma, promedio, conteo) y escribe el resultado final en el archivo part-r-00000.

## 7. Errores comunes y cómo los resolvieron
1. Bug en framework aggregate de Hadoop 3.3.6: El código del programa aggregate en Hadoop 3.3.6 tiene un error que le impide cargar su plugin interno (llamado WordCountPlugInClass). Este componente es el responsable de leer el texto, separar las palabras y asignarles las etiquetas matemáticas que el framework Aggregate necesita (como LongValueSum:).
Al fallar la carga de esa herramienta de separación, Hadoop no sabe cómo procesar el texto y activa una acción de emergencia predeterminada, el cual solo devuelve el conteo de lineas del texto. Para solucionarlo, se realizó la práctica en otra versión de Hadoop.

