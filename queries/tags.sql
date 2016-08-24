\begin{lstlisting}[
           language=SQL,
           showspaces=false,
           basicstyle=\ttfamily,
           numbers=left,
           numberstyle=\tiny,
           commentstyle=\color{gray}
        ]
add jar /home/hadoop/csv-serde-0.9.1.jar;
CREATE EXTERNAL TABLE tags_s3 (
    tag_id string 
    ,tagger string 
    ,surface_form string 
    ,start_offset bigint 
    ,end_offset bigint 
    ,enumex_type string) 
row format serde 'com.bizo.hive.serde.csv.CSVSerde'
with serdeproperties(
"separatorChar" = "\;",
"quoteChar" = "\"")
LOCATION 's3://jaesqudissqueries/tags/'; 

set dynamodb.throughput.read.percent=0.95;
-- LIST EVERY TAG
INSERT OVERWRITE TABLE tags_s3
SELECT * FROM tags_dynamodb;   
\end{lstlisting}
