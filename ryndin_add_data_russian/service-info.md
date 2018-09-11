
## Spark Standalone 

* spark-master - Spark Standalone Master
    * --public-ip
    * --spark-classpath 
    * --hdfs-namenode
* spark-worker - Spark Standalone Worker
    * --public-ip
    * --spark-classpath 
    * --hdfs-namenode
    * --master
    * --worker-cores 
    * --worker-memory 
                
## Hadoop (HDFS & Yarn)
        
* hdfs-name    - Hadoop HDFS Name Node                                 
    * --public-ip
* hdfs-data    - Hadoop HDFS Data Node
    * --public-ip
    * --hdfs-namenode                           
* yarn-rm      - Yarn Resource Manager
    * --public-ip
    * --hdfs-namenode                                 
* yarn-nm      - Yarn Node Manager
    * --public-ip
    * --yarn-rm 
    * --hdfs-namenode 
    * --worker-cores 
    * --worker-memory 

## Kafka 

* zookeeper       - Kafka Zookeeper service
    * --public-ip
* kafka-server    - Kafka Server (broker). Parameters:                                 
    * --public-ip
    * --zookeeper  - The kafka zookeeper address. 
 
 
## Predefined Kafka Feeds
 
* kafka-feed-forex   - Foreign exchange data from Yahoo Finance into the `forex` kafka topic.
* kafka-feed-stocks  - Stock exchange data from Yahoo Finance into the `stocks` kafka topic.
* kafka-feed-types   - Random test data to `types` kafka topic. 
* kafka-feed-nano    - nano.csv file to `nano` kafka topic. 
* kafka-feed-tx      - Random test data to `tx` kafka topic.           
* kafka-feed-msg     - Random test data to `msg` kafka topic.
* kafka-feed-spatial - Spatial test data to `spatial` kafka topic.
* kafka-feed-complex - Complex json test data to `complex` kafka topic.
* kafka-feed-buses   - Large amount of test data to `buses` kafka topic.
* kafka-feed-goldengate - Large amount of test data to `goldengate` kafka topic.
          
Each `kafka-feed-` service accepts the following parameters:                 
* --public-ip
* --zookeeper              
* --broker                           
* --partitions                           
* --replication-factor

## Druid

Druid services for OSA Analytics.  
* druid-broker
* druid-coordinator
* druid-historical
* druid-middlemanager
* druid-overlord

Each Druid service has the following parameters:   
* --public-ip
* --zookeeper 


## Service parameters explained

* --public-ip {public-ip}  
        Specifies the public IP of the node where the service runs.  
        This should be set to a value which is returned by nslookup at the docker\'s host machine.

* --broker {broker1:port1,broker2:port2}  
        The kafka broker(s) address.  
        For example `localhost:9092`
                           
* --zookeeper {zookeeper:port}  
        Mandatory, the kafka zookeeper address.  
        For example `localhost:2181`
                           
* --partitions {value}  
        Optional, specifies the number of partitions in the generated topic.  
        Default: 1
                          
* --replication-factor  
        Optional, specifies the replication factor of the generated topic.  
        This parameter only makes sense if you have multiple kafka-server services running.  
        Default: 1
        
* --master {spark://host:port}    
        The Spark master URL in Spark Standalone mode.
        Default: spark://localhost:7077
        
* --hdfs-namenode {hostname}  
        The address of the HDFS name node.
        
* --yarn-rm {hostname}  
        The address of the Yarn Resource Manager node.
        
* --worker-cores {value}  
        The number of cores (virtual CPUs) that a Spark Standalone Worker or a Yarn
        Node Manager can allocate for Spark applications.
        Default: 16.
         
* --worker-memory {value}  
        The amount of the memory of the Spark Standalone Worker or a Yarn
        Node Manager that can be allocated for Spark applications on that node.
        This can be specified in mega or giga-bytes like this: 12g or 1500m
        Default: 10g
        
* --spark-classpath {class-path}
        Sets the SPARK_CLASSPATH environment variable in Spark Standalone Master or Worker.
        This option is useful if some extension packages should be placed on the 
        driver/executor path.
