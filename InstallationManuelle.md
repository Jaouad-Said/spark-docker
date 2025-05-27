Parfait ! Voici **le guide d’installation manuelle** de tout le stack (hors Docker), **sous Windows**, pour :

* **Hadoop 3.2.1**
* **Spark 3.5.5**
* **PostgreSQL 15**
* **Jupyter Notebook**
* **Python 3 + pip**
* **Java (OpenJDK)**
* **PySpark**

Ce guide vise une installation **locale**, tout sur la même machine, avec accès via navigateur.

---

## 🟣 1. Prérequis Système

* Windows 10 ou 11 (64 bits recommandé)
* Un compte administrateur

---

## 🟢 2. Installer Java (OpenJDK)

1. **Téléchargez OpenJDK :**

   * [https://adoptium.net/](https://adoptium.net/)
   * Choisissez “OpenJDK 11 (LTS)” ou “OpenJDK 8”, format `.msi` ou `.zip`.

2. **Installez** et ajoutez le chemin `bin` du JDK dans la variable d’environnement `JAVA_HOME` et dans le `PATH`.

   * Ex : `C:\Program Files\Eclipse Adoptium\jdk-11.0.18.10-hotspot\bin`

---

## 🟢 3. Installer Python et pip

1. Téléchargez Python 3.x (3.9 ou supérieur) ici :

   * [https://www.python.org/downloads/windows/](https://www.python.org/downloads/windows/)

2. **Cochez “Add Python to PATH”** à l’installation !

3. Vérifiez dans le terminal :

   ```powershell
   python --version
   pip --version
   ```

---

## 🟢 4. Installer Hadoop 3.2.1

1. **Téléchargez Hadoop 3.2.1 binaire** :

   * [https://archive.apache.org/dist/hadoop/common/hadoop-3.2.1/](https://archive.apache.org/dist/hadoop/common/hadoop-3.2.1/)

2. **Décompressez** dans un dossier (ex : `C:\hadoop`).

3. **Installez winutils.exe** (outil Windows indispensable pour Hadoop) :

   * Télécharger un build compatible ici (exemple, non officiel) :
     [https://github.com/steveloughran/winutils](https://github.com/steveloughran/winutils)
   * Placez `winutils.exe` dans `C:\hadoop\bin`

4. **Ajoutez les variables d’environnement** :

   * `HADOOP_HOME` = `C:\hadoop`
   * Ajoutez `%HADOOP_HOME%\bin` à votre `PATH`

5. **Configurez les fichiers Hadoop** (`core-site.xml`, `hdfs-site.xml` pour un mode pseudo-distribué local).

   * Je peux vous donner des exemples si besoin.

---

## 🟢 5. Installer Spark 3.5.5

1. **Téléchargez Spark (préconstruit Hadoop 3)** :

   * [https://archive.apache.org/dist/spark/spark-3.5.5/](https://archive.apache.org/dist/spark/spark-3.5.5/)

2. **Décompressez** dans `C:\spark`

3. Ajoutez `C:\spark\bin` à votre `PATH`

---

## 🟢 6. Installer PostgreSQL 15

1. **Téléchargez l’installeur officiel** :

   * [https://www.enterprisedb.com/downloads/postgres-postgresql-downloads](https://www.enterprisedb.com/downloads/postgres-postgresql-downloads)

2. **Installez** PostgreSQL avec un mot de passe, retenez-le pour les connexions Spark.

3. (Optionnel) Ajoutez `C:\Program Files\PostgreSQL\15\bin` à votre `PATH`

---

## 🟢 7. Installer Jupyter Notebook

```powershell
pip install notebook
```

Vous pouvez aussi installer JupyterLab :

```powershell
pip install jupyterlab
```

---

## 🟢 8. Installer PySpark et les libs utiles

```powershell
pip install pyspark pandas matplotlib
```

---

## 🟢 9. Vérifications et Lancements

### a) Vérifiez Java et Python

```powershell
java -version
python --version
```

### b) Démarrez HDFS local (si besoin, pour exercices HDFS)

Depuis `C:\hadoop\sbin` :

```powershell
start-dfs.cmd
```

(Vérifiez et ajustez la conf si besoin.)

### c) Démarrez Spark

```powershell
spark-shell
```

ou pour Python :

```powershell
pyspark
```

### d) Lancez Jupyter

```powershell
jupyter notebook
```

puis ouvrez l’URL dans votre navigateur.

---

## 🟢 10. Connecter Spark à PostgreSQL

1. Téléchargez le driver JDBC PostgreSQL [ici](https://jdbc.postgresql.org/download.html) (ex: `postgresql-42.7.5.jar`).
2. Placez-le dans un dossier accessible (ex: `C:\spark\jars`)
3. Ajoutez ce chemin à Spark lors de vos scripts ou jobs via l’option :

   ```python
   .config("spark.jars", "C:/spark/jars/postgresql-42.7.5.jar")
   ```
