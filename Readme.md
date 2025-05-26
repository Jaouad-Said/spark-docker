# 🚀 Projet Big Data : Spark, Hadoop, PostgreSQL, Jupyter avec Docker

## 1. Cloner le dépôt

La première étape consiste à cloner le projet depuis GitHub.  
Ouvre un terminal et exécute la commande suivante :

```bash
git clone https://github.com/Jaouad-Said/spark-docker.git
cd spark-docker
```

## 2. Démarrer l'environnement Big Data

Après avoir cloné le dépôt et accédé au dossier du projet, lance tous les services nécessaires avec Docker Compose :

```bash
docker compose up -d
```

Pour vérifier que tous les services sont bien démarrés, utilise :

```bash
docker ps
```

Les interfaces web des différents services sont accessibles sur :

Jupyter Notebook : http://localhost:8888

Spark Master UI : http://localhost:8080

HDFS UI : http://localhost:9870

## 3. Création et vérification du dossier HDFS

```bash
docker exec -it hadoop-namenode bash

# Dans le conteneur du namenode :
hdfs dfs -mkdir -p /user/pros
hdfs dfs -ls /user
```

## 4. Accès à Jupyter Notebook

Pour obtenir le lien d'accès à Jupyter Notebook lancé dans le conteneur, exécute :

```bash
docker-compose exec jupyter jupyter server list

Currently running servers:
http://f0f9477f3b6f:8888/?token=<TON_TOKEN> :: /home/jovyan
```

Ouvre le lien indiqué dans ton navigateur pour accéder à l’interface Jupyter en utilisant TOKEN.

Dans l’interface Jupyter ou depuis VS Code, ouvre le notebook voulu (par exemple operations.ipynb) Lance les cellules du notebook pour réaliser les opérations Spark, comme l’importation des données depuis PostgreSQL et l’affichage du DataFrame

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("check").getOrCreate()

df = spark.read.jdbc(
    url="jdbc:postgresql://postgres:5432/demo",
    table="products",
    properties={
        "user": "postgres",
        "password": "postgres",
        "driver": "org.postgresql.Driver"
    }
)

df.select("id", "name", "brand", "price", "stock_quantity").show()
```

## Export des données de Spark vers HDFS et vérification

## 1. Écriture depuis Spark vers HDFS

Après avoir transformé tes données dans Spark, tu peux exporter les résultats au format CSV dans HDFS (via le port 8020) :

```python
df.select("id", "name", "brand", "price", "stock_quantity") \
  .write.csv("hdfs://hadoop-namenode:8020/user/pros/products_export", header=True, mode="overwrite")
```

## 💡 Astuce Dépannage : Erreur de taille maximale RPC entre Spark et Hadoop

Si tu rencontres cette erreur lors d’un export ou d’un import de fichiers volumineux dans HDFS :

Ajoute ce paramètre lors de la création de la SparkSession :

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("products_job") \
    .config("spark.hadoop.ipc.maximum.data.length", 536870912) \
    .getOrCreate()
```

## Lancement d'un job Spark (spark-submit)

Le script Python du job Spark à exécuter est déjà présent dans le répertoire `jobs/` du projet :
Pour lancer ce job depuis le conteneur `spark-master`, utilise les commandes suivantes :

```bash
docker exec -u 0 -it spark-master bash

# (Dans le conteneur)
export HOME=/tmp USER=root

spark-submit --master spark://spark-master:7077 \
  --jars /opt/spark/jars/postgresql-42.7.5.jar \
  /opt/spark/jobs/products_job.py
```
