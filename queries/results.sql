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
\end{lstlisting}

set dynamodb.throughput.read.percent=0.95;
-- LIST EVERY TAG (LIMIT TO 2 results)
INSERT OVERWRITE TABLE tags_s3
SELECT * FROM tags_dynamodb;   

-- ================================================
-- SPOTLIGHT TAGS

CREATE EXTERNAL TABLE if not exists spotlight_s3 (
    tag_id string 
    ,tagger string 
    ,surface_form string 
    ,start_offset bigint 
    ,end_offset bigint 
    ,enumex_type string) 
row format serde "com.bizo.hive.serde.csv.CSVSerde"
with serdeproperties(
"separatorChar" = "\;",
"quoteChar" = "\"")
LOCATION 's3://jaesqudissqueries/spotlight_tags/'; 

-- LIST EVERY TAG from spotlight
INSERT OVERWRITE TABLE spotlight_s3
SELECT * FROM tags_s3
WHERE tagger='spotlight';

-- ================================================
-- STANFORD TAGS

CREATE EXTERNAL TABLE if not exists stanford_s3 (
    tag_id string 
    ,tagger string 
    ,surface_form string 
    ,start_offset bigint 
    ,end_offset bigint 
    ,enumex_type string) 
row format serde "com.bizo.hive.serde.csv.CSVSerde"
with serdeproperties(
"separatorChar" = "\;",
"quoteChar" = "\"")
LOCATION 's3://jaesqudissqueries/stanford_tags/'; 

-- LIST EVERY TAG from spotlight
INSERT OVERWRITE TABLE stanford_s3
SELECT * FROM tags_s3
WHERE tagger='stanford';


-- ================================================
-- OVERLAPPING TAGS
CREATE EXTERNAL TABLE if not exists overlapping_s3 (
    ArticleID string 
    ,StanfordSurface string 
    ,SpotlightSurface string 
    ,StanfordType string 
    ,SpotlightType string 
    ,StanfordStart bigint 
    ,StanfordEnd bigint 
    ,SpotlightStart bigint 
    ,SpotlightEnd bigint 
    ,StanfordID string
    ,SpotlightID string) 
row format serde "com.bizo.hive.serde.csv.CSVSerde"
with serdeproperties(
"separatorChar" = "\;",
"quoteChar" = "\"")
LOCATION 's3://jaesqudissqueries/overlapping_tags/'; 

INSERT OVERWRITE TABLE overlapping_s3
select
substring_index(stan.tag_id, '_', 1) as ArticleID,
stan.surface_form as StanfordSurface,
spot.surface_form as SpotlightSurface,
stan.enumex_type as StanfordType,
spot.enumex_type as SpotlightType,
stan.start_offset as StanfordStart,
stan.end_offset as StanfordEnd,
spot.start_offset as SpotlightStart,
spot.end_offset as SpotlightEnd,
stan.tag_id as StanfordID,
spot.tag_id as SpotlightID
from spotlight_s3 spot
cross join stanford_s3 stan
on
( substring_index(spot.tag_id, '_', 1) = substring_index(stan.tag_id, '_', 1) )
where
((spot.start_offset between stan.start_offset and stan.end_offset)
or (stan.start_offset between spot.start_offset and spot.end_offset))
and
(instr(spot.surface_form, stan.surface_form)>0
or instr(stan.surface_form, spot.surface_form)>0);

-- ================================================
-- STANFORD NOT IN SPOTLIGHT TAGS
CREATE EXTERNAL TABLE if not exists nil_s3 (
    tag_id string 
    ,tagger string 
    ,surface_form string 
    ,start_offset bigint 
    ,end_offset bigint 
    ,enumex_type string) 
row format serde "com.bizo.hive.serde.csv.CSVSerde"
with serdeproperties(
"separatorChar" = "\;",
"quoteChar" = "\"")
LOCATION 's3://jaesqudissqueries/nil_tags/'; 

INSERT OVERWRITE TABLE nil_s3
select stan.tag_id, stan.tagger, stan.surface_form, stan.start_offset, stan.end_offset, stan.enumex_type
from stanford_s3 stan
left outer join overlapping_s3 overlap
on stan.tag_id = overlap.stanfordid
where stanfordid is null;
