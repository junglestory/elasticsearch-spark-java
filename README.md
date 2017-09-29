# elasticsearch-spark-java
This application is a sample for Elasticsearch client with [Spark Java](http://sparkjava.com) and [Freemaker](http://freemarker.org), Bootstrap.

## Features
* MultiMatchQuery
* Hightlight
* Date Range
* Filter
* Sort
* Aggregation
* Paginated

## Requirements
* Java requires 1.8 or higher
* Elasticsearch requires 5.5 or higher

## Installation
* [Download](https://www.elastic.co/downloads/elasticsearch) and unzip the Elasticsearch official distribution.
* Run bin\elasticsearch
* Run curl -X GET http://localhost:9200/
* [Sampe data](https://github.com/junglestory/scrape_blog_crawler)

## Soruce code clone
git clone https://github.com/junglestory/elasticsearch-spark-java.git
<pre><code>
$ cd elasticsearch-spark-java
</code></pre>

## Configuration
* Search.java
<pre><code>
private static String searchServer = "127.0.0.1"; // your host
private static int searchPort = 9300; // search port
</code></pre>

## Run
http://localhost:4567/search
