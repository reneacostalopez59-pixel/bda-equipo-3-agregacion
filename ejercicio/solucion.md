# Solución del Mini Ejercicio: Análisis de Tecnologías con Agregación

> **Nota importante sobre la versión de Hadoop:** Para obtener el conteo de palabras y el histograma real, este ejercicio debe ejecutarse con **Hadoop 3.4.0** (`hadoop-mapreduce-examples-3.4.0.jar`), ya que la versión 3.3.6 tiene un bug en `ValueAggregatorJob` que ignora el descriptor de palabras y únicamente devuelve el conteo de líneas (`record_count`).

---

## Paso 1: Crear el directorio y el archivo de entrada

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

## Paso 2: Ejecutar `aggregatewordcount` y mostrar el resultado

```bash
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.4.0.jar aggregatewordcount /tmp/ejercicio_clase /tmp/salida_ej_count 1 textinputformat

cat /tmp/salida_ej_count/part-r-00000
```

### Resultado esperado en `/tmp/salida_ej_count/part-r-00000` (Hadoop 3.4.0):
```text
bash	2
go	1
java	4
python	6
rust	1
sql	3
```

---

## Paso 3: Ejecutar `aggregatewordhist` y mostrar el resultado

```bash
hadoop jar $HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.4.0.jar aggregatewordhist /tmp/ejercicio_clase /tmp/salida_ej_hist 1 textinputformat

cat /tmp/salida_ej_hist/part-r-00000
```

### Resultado esperado en `/tmp/salida_ej_hist/part-r-00000` (Hadoop 3.4.0):
El archivo muestra el resumen estadístico de las frecuencias y el desglose de cuántas palabras únicas cayeron en cada frecuencia:
```text
WORD_HISTOGRAM	6	1	6	2.8333333333333335	1.7716909687891083
1	2
2	1
3	1
4	1
6	1
```
*(Desglose de frecuencias: 2 palabras aparecen 1 vez [`go`, `rust`], 1 palabra aparece 2 veces [`bash`], 1 palabra aparece 3 veces [`sql`], 1 palabra aparece 4 veces [`java`] y 1 palabra aparece 6 veces [`python`]).*

---

## Paso 4: Respuestas a las preguntas

1. **¿Cuál es el lenguaje que más se repite y cuántas apariciones tiene?**
   * El lenguaje más repetido es **`python`** con **6 apariciones**.

2. **¿Cuáles lenguajes empataron con exactamente 2 apariciones?**
   * Únicamente **`bash`** tiene 2 apariciones (mientras que **`go`** y **`rust`** empataron con **1 aparición** cada uno).

3. **¿Qué ocurre si se ejecuta en Hadoop 3.3.6?**
   * En **Hadoop 3.3.6**, el archivo `part-r-00000` únicamente imprime:
     ```text
     record_count	4
     ```
   * Esto sucede porque en la versión 3.3.6 la clase `ValueAggregatorJob` no carga el descriptor personalizado (`WordCountAggregatorDescriptor`) en la configuración del trabajo y utiliza el descriptor base por defecto, el cual solo cuenta las 4 líneas del archivo de texto e ignora las palabras.