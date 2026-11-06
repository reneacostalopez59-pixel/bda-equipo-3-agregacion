# bda-equipo-3-agregacion

## 1. Integrantes del equipo
- René Nicolás Acosta López
- Germán Eduardo Ruiz Zúñiga
- Betel Zurisadai Hernandez Sanchez

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

---

## 4.2 Paso a paso alternativo: Reproducción limpia en Hadoop 3.4.0

> **Importante:** Si acabas de ejecutar la prueba en Hadoop 3.3.6 dentro del contenedor, **no ejecutes la versión 3.4.0 en esa misma sesión**, ya que las variables de entorno previas y las rutas relativas causan conflictos y errores de archivos no encontrados. Sigue estos pasos iniciando desde afuera del contenedor en tu terminal principal (PowerShell / CMD / Terminal).

### 1. Salir de la sesión anterior (si sigues dentro del contenedor)
Si aún estás dentro del contenedor tras probar la versión 3.3.6, ejecuta `exit` hasta volver a la terminal de tu computadora:

```bash
exit
```

### 2. Entrar al contenedor en una sesión limpia como `root`
Desde la terminal de tu computadora, abre una nueva sesión como administrador dentro del contenedor `hadoop` para instalar la versión 3.4.0 sin conflictos:

```bash
docker exec -it -u root hadoop bash
```

### 3. Descargar e instalar Apache Hadoop 3.4.0 en `/opt/hadoop34`
Nos ubicamos en el directorio `/opt`, descargamos el paquete oficial de Hadoop 3.4.0, lo descomprimimos en una carpeta independiente llamada `hadoop34` y asignamos los permisos al usuario `hadoop`:

```bash
cd /opt
wget https://archive.apache.org/dist/hadoop/common/hadoop-3.4.0/hadoop-3.4.0.tar.gz
tar -xzf hadoop-3.4.0.tar.gz
mv hadoop-3.4.0 hadoop34
chown -R hadoop:hadoop /opt/hadoop34
```

### 4. Cambiar al usuario `hadoop` y configurar el entorno limpio para 3.4.0
Iniciamos sesión limpia con el usuario `hadoop` y definimos las variables `$HADOOP_HOME`, `$PATH` y `$JAVA_HOME` apuntando exclusivamente a `/opt/hadoop34`:

```bash
su - hadoop
export HADOOP_HOME=/opt/hadoop34
export PATH=/usr/local/bin:/usr/bin:/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh
```

### 5. Comprobar que la versión activa sea Hadoop 3.4.0
Verificamos que el sistema reconozca correctamente los binarios de la versión 3.4.0 antes de procesar los datos:

```bash
hadoop version
```

### 6. Preparar el archivo de entrada en una ruta limpia
Eliminamos cualquier carpeta temporal previa, creamos el directorio `/tmp/quijote_340` y descargamos directamente el libro *Don Quijote de la Mancha* (`pg2000.txt`) usando rutas absolutas para evitar errores de archivos no encontrados:

```bash
rm -rf /tmp/quijote_340 /tmp/salida_q_340_count /tmp/salida_q_340_hist
mkdir -p /tmp/quijote_340
wget -O /tmp/quijote_340/pg2000.txt https://www.gutenberg.org/cache/epub/2000/pg2000.txt
```

### 7. Ejecutar `aggregatewordcount` con Hadoop 3.4.0
Lanzamos el conteo de palabras por agregación utilizando el archivo `.jar` de la versión 3.4.0 con 1 Reducer y formato de texto plano:

```bash
/opt/hadoop34/bin/hadoop jar /opt/hadoop34/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.4.0.jar aggregatewordcount /tmp/quijote_340 /tmp/salida_q_340_count 1 textinputformat
```

### 8. Consultar el Top 10 de palabras más repetidas
Ordenamos de mayor a menor el archivo de salida generado para visualizar las 10 palabras con mayor frecuencia en la obra:

```bash
sort -k2,2nr /tmp/salida_q_340_count/part-r-00000 | head -10
```

### 9. Ejecutar `aggregatewordhist` con Hadoop 3.4.0
Ejecutamos el generador del histograma estadístico sobre el mismo directorio de entrada:

```bash
/opt/hadoop34/bin/hadoop jar /opt/hadoop34/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.4.0.jar aggregatewordhist /tmp/quijote_340 /tmp/salida_q_340_hist 1 textinputformat
```

### 10. Consultar el resultado del histograma
Mostramos las primeras líneas del archivo resultante donde aparece el resumen estadístico (`WORD_HISTOGRAM`) y la distribución de frecuencias:

```bash
head -10 /tmp/salida_q_340_hist/part-r-00000
```

## 5. Resultado esperado
Se divide en dos partes, el resultado teorico y los resultados reales:
### 5.1 Resultado teórico:
El resultado teórico esperado (si no hubiera bug): Las herramientas aggregate deberían devolver una lista detallada con cada palabra única y su frecuencia exacta en el libro (por ejemplo, quijote 2167, sancho 1054).
### 5.2 Resultado real 1:
El resultado será únicamente record_count 38059. Debido al bug del framework en Hadoop 3.3.6, el sistema no separa el texto y simplemente cuenta el total de líneas del documento original.

### 5.3 Resultados real 2 (Versión alterna: Hadoop 3.4.0)

Al ejecutar los programas utilizando **Apache Hadoop 3.4.0** (`hadoop-mapreduce-examples-3.4.0.jar`) sobre el libro *Don Quijote de la Mancha* (`pg2000.txt`), el agregador procesa correctamente todas las palabras de la obra. Los archivos completos generados se encuentran en la carpeta [`resultados_version_alterna/`](./resultados_version_alterna/).

**Comandos ejecutados en Hadoop 3.4.0:**
```bash
export HADOOP_HOME=/opt/hadoop34
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH

hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.4.0.jar aggregatewordcount /tmp/quijote_336 /tmp/salida_q_340_count 1 textinputformat
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.4.0.jar aggregatewordhist /tmp/quijote_336 /tmp/salida_q_340_hist 1 textinputformat
```

**Top 10 palabras obtenidas en `aggregatewordcount` (Hadoop 3.4.0):**
```text
que     19546
de      18133
y       15976
la      10329
a       9627
el      8009
en      7941
no      5622
se      4751
los     4701
```

**Primeras líneas obtenidas en `aggregatewordhist` (Hadoop 3.4.0):**
```text
WORD_HISTOGRAM  39756   1       1       19546   9.952812154140256       199.694962160176
```

## 6. Explicación de Map y Reduce
1. Map: Los datos se dividen en bloques. Cada bloque se procesa por separado y produce pares clave → valor, por ejemplo (palabra, 1).
2. Shuffle: Hadoop junta y ordena automáticamente todos los pares que tienen la misma clave, y los manda al mismo reducer.
3. Combina los valores de cada clave (suma, promedio, conteo) y escribe el resultado final en el archivo part-r-00000.

## 7. Errores comunes y cómo los resolvieron
1. Bug en framework aggregate de Hadoop 3.3.6: El código del programa aggregate en Hadoop 3.3.6 tiene un error que le impide cargar su plugin interno (llamado WordCountPlugInClass). Este componente es el responsable de leer el texto, separar las palabras y asignarles las etiquetas matemáticas que el framework Aggregate necesita (como LongValueSum:).
al fallar la carga de esa herramienta de separación, Hadoop no sabe cómo procesar el texto y activa una acción de emergencia predeterminada, el cual solo devuelve el conteo de lineas del texto. Para solucionarlo, se realizó la práctica en otra versión de Hadoop.
2. **Bug en `ValueAggregatorJob` dentro de Hadoop 3.3.6 (solo devuelve `record_count`):**
   * **Problema:** Al ejecutar `aggregatewordcount` sobre *Don Quijote de la Mancha* en **Hadoop 3.3.6**, el trabajo finaliza sin errores pero el archivo `part-r-00000` únicamente devuelve una línea con el total de renglones del libro (`record_count 38059`), ignorando el conteo de todas las palabras. Esto ocurre porque en la versión 3.3.6 `ValueAggregatorJob` no carga en la configuración el descriptor `WordCountAggregatorDescriptor` y utiliza únicamente el descriptor base por defecto.
   * **Solución y resultado obtenido:** Instalamos **Apache Hadoop 3.4.0** (`/opt/hadoop34`), versión que corrige la carga del descriptor de agregación. Al correr nuevamente ambos programas en Hadoop 3.4.0, obtuvimos el conteo real desglosado de todas las palabras del libro y su histograma de frecuencias completo (disponibles en la carpeta `resultados_version_alterna/`).

3. **Error de formato de entrada (`not a SequenceFile`):**
   * **Problema:** Si no se especifica el formato de entrada, el framework de agregación asume que el archivo es un `SequenceFile` binario y arroja `IOException`.
   * **Solución:** Añadir los argumentos `1 textinputformat` al final del comando para indicar 1 Reducer y lectura de texto plano.

4. **Error de carpeta de salida existente (`FileAlreadyExistsException`):**
   * **Problema:** Hadoop detiene el trabajo si la carpeta de salida en `/tmp` ya existe de una prueba anterior.
   * **Solución:** Eliminar las carpetas de salida previas con `rm -rf` antes de ejecutar nuevamente el comando.

5. **Conflicto de rutas y archivos no encontrados al ejecutar Hadoop 3.4.0 enseguida de Hadoop 3.3.6:**
   * **Problema:** Al intentar correr la prueba de Hadoop 3.4.0 inmediatamente después de haber ejecutado la versión 3.3.6 dentro de la misma sesión de la terminal, el contenedor arroja errores de que no encuentra los archivos o sigue invocando los binarios de `/opt/hadoop` (3.3.6) debido a que las variables de entorno y rutas de trabajo anteriores permanecen activas en memoria.
   * **Solución:** Salir completamente del contenedor (`exit`) hasta la terminal principal de la computadora, abrir una sesión nueva (`docker exec -it ...`) y ejecutar los comandos de la versión 3.4.0 utilizando rutas absolutas (`/opt/hadoop34/bin/hadoop` y `/tmp/quijote_340`).
