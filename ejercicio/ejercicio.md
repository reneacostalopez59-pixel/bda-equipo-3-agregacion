# Mini Ejercicio: Análisis de Tecnologías con Agregación en Hadoop

En este ejercicio práctico utilizaremos las herramientas **`aggregatewordcount`** y **`aggregatewordhist`** del paquete de ejemplos de Hadoop para contabilizar la frecuencia de uso de distintos lenguajes de programación registrados en una serie de proyectos y obtener su distribución estadística.

---

## 1. Preparar los datos de entrada

Ejecuta el siguiente bloque de comandos en tu terminal dentro del contenedor para limpiar ejecuciones previas, crear la carpeta `/tmp/ejercicio_clase` y generar el archivo `lenguajes.txt`:

```bash
rm -rf /tmp/ejercicio_clase /tmp/salida_ej_count /tmp/salida_ej_hist
mkdir -p /tmp/ejercicio_clase

cat << 'EOF' > /tmp/ejercicio_clase/lenguajes.txt
python java python sql bash
python java sql python
rust go python java
sql python bash java
EOF
```

---

## 2. Instrucciones

1. **Conteo por agregación (`aggregatewordcount`):**
   Ejecuta el programa `aggregatewordcount` tomando como entrada la carpeta `/tmp/ejercicio_clase` y como salida `/tmp/salida_ej_count`.
   *(Recuerda agregar los parámetros `1 textinputformat` al final del comando para procesar archivos de texto plano con 1 Reducer).*

2. **Histograma de frecuencias (`aggregatewordhist`):**
   Ejecuta el programa `aggregatewordhist` tomando como entrada la misma carpeta `/tmp/ejercicio_clase` y como salida `/tmp/salida_ej_hist` (incluyendo también `1 textinputformat`).

3. **Consulta los resultados:**
   Muestra en pantalla el contenido del archivo `part-r-00000` de ambas carpetas de salida utilizando `cat`.

---

## 3. Preguntas a responder

1. Según la salida de `aggregatewordcount`, ¿cuál es el lenguaje que más se repite y cuántas apariciones tiene?
2. ¿Cuáles lenguajes empataron con exactamente **2 apariciones**?
3. Si ejecutas este mismo ejercicio usando el archivo `.jar` de **Hadoop 3.3.6** en lugar de **Hadoop 3.4.0**, ¿qué resultado arroja el archivo `part-r-00000` y por qué?