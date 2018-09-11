# Docker Image: Spark Standalone and Kafka 

**Pre-requisite:** [Docker Service installed and running](../README.md)

You can manage local Hadoop, Spark, Kafka, Druid servers in docker using the `infra/docker/spark-kafka/manage-service.sh` script.
For the available version of each software component see the [services-base](../services-base/README.md) image.

## How to start

The preferred way to manage/configure HDFS/Spark/Kafka in your local enviroment is using the [service management](../../hosted/README.md) tool.  
Although service management tool is using the same `spark-kafka` docker image, it starts each service in a separate docker container.  
For the available services and their parameters see [service-info.md](./service-info.md)
**Note:** the start command below just prints help on the docker image.

	./manage.sh start

## Get more options
 
	./manage.sh help

## Manage services

You can manage each services individually using the `managa-service.sh` script. 
For more details use the `help` command.

	./manage-services.sh help
     

## Managing Kafka 

For ease of use you can manage kafka using the `kafka.sh` tool. To get help on this tool use the following command:

    kafka.sh help

There are three simple tools to use the most frequent functions of `kafka.sh` easier. (These three scripts and the `kafka.sh` are on the system path, so you can reach them easily from any folder.)

You can list the the kafka topics:

    kafka-topics.sh

You can listen to a topic as follows:

    kafka-listen.sh {topic-name}

And you can start predefined kafka topics easily:

    start-feed.sh {feed-name}

Predefined feed names: `nano`, `forex`, `stocks`, `msg`, `tx`, `spatial`, `goldengate`

In general you can feed test data to your running kafka installation by redirecting the STDOUT of `your-shell-script` to the kafka management tool as follows:

    {your-shell-script} | kafka.sh feed {topic-name} 

**Note:** `your-shell-script` must generate the data in JSON format. For example its output should look like this:

    {"price":284.03,"symbol":"USDHUF=x","name":"USD/HUF"}
    {"price":316.51,"symbol":"EURHUF=x","name":"EUR/HUF"}
    {"price":0.8971,"symbol":"USDEUR=x","name":"USD/EUR"}

There are prebuilt script and data files which allows you to create several types of data to feed a kafka topic. 
The concept is, that the scripts generate CSV format output an there is a 
csv2json.sh converter script, so we can generate both data types.

* Script files in `infra/docker/spark-kafka/feeds`:
    * Generators:
        * `forex-csv.sh`, `stock-csv.sh` - produce financial data (with 10s frequency) in CSV format to the STDOUT
        * `message-csv.sh`, `card-transactions-csv.sh`, `datatypes-csv.sh` - produce random data in CSV format to the STDOUT
        * `loop-file.sh {file}` - loops the entire {file} to the STDOUT.  
        * `loop-csv.sh {file}`  - loops the CSV {file} to the STDOUT. Handles the first line as the header and writes only once to the STDOUT and loops the rest of {file}.    
    * Filters (use these scripts in conjunction with the "linux pipe" mechanism):
        * `sampler.sh {n} {t}` - Reads {n} lines in each {t} seconds from STDIN and writes to STDOUT. Default values: n=1 t=1
        * `csv2json.sh` - Reads the CSV from the STDIN and writes JSON to STDOUT. First line must be the CSV header.
* Data files in `infra/docker/spark-kafka/data`:
    * `test.csv` / `test.json` - simple CSV and JSON test files with the same content
    * `nano.csv` - the "original" nano.csv
    * `spatial.csv` - special CSV file to test spatial functionalities
    * `complex.json` - special json file contains complex json structures
    * `30-min-at-50-rps.json` - big size json file
    * `gg_orders.json` - big size json file

### Examples

With the scripts and data files above you can feed for example random JSON data to the `msg` topic:

    ./feeds/message-csv.sh | ./feeds/csv2json.sh | ./feeds/sampler.sh 1 1 | kafka.sh feed msg &
	
or feed a simple file contains JSON format lines to the `fromfile` topic:

    ./feeds/loop-file.sh ./data/test.json | ./feeds/sampler.sh 5 1 | kafka.sh feed fromfile &

or feed a CSV file converted to JSON format to the `nano` topic:

    ./feeds/loop-csv.sh ./data/nano.csv | ./feeds/csv2json.sh | ./feeds/sampler.sh 1 1 | kafka.sh feed nano &

or feed a CSV file converted to JSON format to the `spatial` topic:

    ./feeds/loop-csv.sh ./data/spatial.csv | ./feeds/csv2json.sh | ./feeds/sampler.sh 1 1 | kafka.sh feed spatial &

or feed a CSV file converted to JSON format to the `spatial` topic:

    ./feeds/loop-csv.sh ./data/spatial.csv | ./feeds/csv2json.sh | ./feeds/sampler.sh 1 1 | ./manage-kafka.sh feed spatial &

or feed live "Foreign Exchange" or "Stock Exchange" data from Yahoo Finance into the `forex` and `stocks` topics: 

    ./feeds/forex-csv.sh | ./feeds/csv2json.sh | kafka.sh feed forex &    
    ./feeds/stocks-csv.sh | ./feeds/csv2json.sh | kafka.sh feed stocks &

or feed complex json structures or large amounts of data into the `complex`, `buses` and `goldengate` topics:

    ./feeds/loop-file.sh ./data/complex.json | ./feeds/sampler.sh 1 1 | kafka.sh feed complex &    
    ./feeds/loop-file.sh ./data/30-min-at-50-rps.json | ./feeds/sampler.sh 20 1 | kafka.sh feed buses &    
    ./feeds/loop-file.sh ./data/gg_orders.json | ./feeds/sampler.sh | kafka.sh feed goldengate &    

The examples above will produce the following topics with the shapes respectively:

    msg: 
        messagetime   :  Timestamp
        messagenumber :  Integer
        messagetext   :  String

    fromfile:
        _number : Integer
        text    : String
   
    nano:
        purchase_sum     : Float
        transaction_time : Timestamp
        client_name      : String
        card_number      : String
        client_age       : Integer

    spatial:
        phoneNo   : Number
        name      : String
        email     : String
        longitude : Longitude
        latitude  : Latitude

    forex:
        symbol : String
        name   : String
        price  : Float
    
    stocks:
        symbol : String
        name   : String
        price  : Float
        date   : String (format: dd/mm/yyyy)
        _time  : String (format: hh:mma)                      
        volume : Big decimal

    complex:
        booleanField        : Bolean
        numberField         : Number
        stringField         : String
        objectField_a_key   : Number
        objectField_a_value : Number
        objectField_c       : String
        objectField_e       : String
        arrayField_0        : Number
        arrayField_1        : Number

    buses:
        id          : String
        reported_at : Timestamp
        lat         : Latitude
        lon         : Longitude
        speed       : Number
        bearing     : Number
        driver_no   : String
        prescriber  : Boolean
        highway     : String

    goldengate:
        table               : String
        op_type             : String
        op_ts               : Timestamp
        current_ts          : Timestamp
        pos                 : String
        tokens              : Not relevant
        before_ORDER_ID     : String
        before_ORDER_STATUS : String
        before_PRODUCT_SKU  : String
        before_QUANTITY     : Integer
        before_REVENUE      : Integer
        after_ORDER_ID      : String
        after_ORDER_STATUS  : String
        after_PRODUCT_SKU   : String
        after_QUANTITY      : Integer
        after_REVENUE       : Integer

## Services

* Kafka zookeeper: $HOSTNAME:2181
* Kafka broker: $HOSTNAME:9092
* Spark Web UI: http://$HOSTNAME:8080
* Spark Master Rest URL: http://$HOSTNAME:6066
* HDFS Web UI: http://$HOSTNAME/50070/explorer.html
* YARN Web UI: http://$HOSTNAME:8088

## Dependencies

* `services-base`  

