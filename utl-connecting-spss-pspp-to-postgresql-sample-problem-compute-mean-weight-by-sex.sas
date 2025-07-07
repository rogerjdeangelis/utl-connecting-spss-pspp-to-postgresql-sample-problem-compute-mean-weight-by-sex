%let pgm=utl-connecting-spss-pspp-to-postgresql-sample-problem-compute-mean-weight-by-sex;

%stop_submission;

Connecting spss pspp to postgresql sample problem compute mean weight by sex

github
https://tinyurl.com/yrzh99mt
https://github.com/rogerjdeangelis/utl-connecting-spss-pspp-to-postgresql-sample-problem-compute-mean-weight-by-sex

PROBLEM (USING PSPP and POSTGRESQL)

 COMPUTE AVERAGE AGE AND WEIGHT BY SEX

           INPUT                POSTGRESQL & SAV FILE    SAS DATASET

     NAME   SEX AGE  WEIGHT           Data List          SEX     AVGAGE     AVGWGT
                                 +---+------+------+
    Alfred   M   14   112.5      |SEX|AVEAGE|AVGWGT|      M     14.0000    107.500
    Alice    F   13    84.0      +---+------+------+      F     13.3333     94.833
    Barbara  F   13    98.0      |M  | 14.00|107.50|
    Carol    F   14   102.5      |F  | 13.33| 94.83|
    Henry    M   14   102.5      +---+------+------+


REPO
----------------------------------------------------------------------------------------------------------------------------------
https://github.com/rogerjdeangelis/utl-partial-key-matching-and-luminosity-in-gene-analysis-sas-r-python-postgresql
https://github.com/rogerjdeangelis/utl-pivot-wide-when-variable-names-contain-values-sql-and-base-r-sas-oython-excel-postgreSQL
https://github.com/rogerjdeangelis/utl-saving-and-creating-r-dataframes-to-and-from-a-postgresql-database-schema


SOAPBOX ON

I am a SPSS beginner!! Be critical.

POSTGRESQL PREP
===============

  CONTENTS

     1 postgresql prep
     2 pspp odbc
     3 no way to use HOST COMMAND=[psql_query].
     4 cannot use a macro function  runpsql "drop table if exists teams;".
     5 this works, the long way
     6 you have to manually assign column names and column types


1 postgresql prep

  a  Use postgres as the user name, it has admin priviledges.
  b  Postgresql does support windows extensions
  c  template1 is the postgresql builtin database

  d  Make sure passwords are turned off.

     Go to
     C:\Program Files\PostgreSQL\16\data\pg_hba,conf
     edit
     ip4 and ip6 replace scram-sha-256 with trust

     # IPv4 local connections:
     host    all             all   127.0.0.1/32   trust
     # IPv6 local connections:
     host    all             all   ::1/128        trust

2 There is a seamless ODBC connection for PSPP postgresql but you need to compile PSPP from source,
  install certain microsoft visual products, and install and link to sveral other modules.
  I decided not to go that route.
  I spent quite abit of time looking for a binary PSPP with ODBC support but could not find one.

3 It looks like there is no way to execute

  compute psqlquery-"...".
  HOST COMMAND=[psql_query].

4 Also can't use a function arguments.

  I tried variations of this

   DEFINE !runpsql (cmd = !TOKENS(1))
    HOST COMMAND=!QUOTE(
      !CONCAT(
        'psql -h localhost -u postgres -d devel -c "',
        !cmd,
        '"'
      )
    ).
  !ENDDEFINE.

  !runpsql "drop table if exists teams;".

5 this works

  %utlfkil(c:/temp/output.sql);
  %utlfkil(d:/csv/teamsout.csv);


  %utl_psppbeginx;
  parmcards4;
  HOST COMMAND=['psql -h localhost -U postgres -d template1 -c "drop table if exists teams;"'].
  HOST COMMAND=['psql -h localhost -U postgres -d template1 -c "create table teams (team text, player text);"'].
  HOST COMMAND=['psql -h localhost -U postgres -d template1 -c "\copy teams from ''d:/csv/have.csv'' delimiter '','' csv header;"'].
  HOST COMMAND=['psql -h localhost -U postgres -d template1 -c "\dt"'].
  HOST COMMAND=['psql -h localhost -U postgres -d template1 -c "select * from teams;"'].
  HOST COMMAND=['psql -h localhost -U postgres -d template1 -c "\copy teams TO ''d:/csv/teamsout.csv'' CSV HEADER;"'].

6 You have to manually assign column names and column types

  table sqlhav (NAME TEXT,SEX TEXT,AGE REAL,WEIGHT REAL);
  /VARIABLES=SEX A1 AVEAGE F8.2 AVGWGT F8.2.

SOAPBOX OFF

REPO
----------------------------------------------------------------------------------------------------------------------------------
https://github.com/rogerjdeangelis/utl-partial-key-matching-and-luminosity-in-gene-analysis-sas-r-python-postgresql
https://github.com/rogerjdeangelis/utl-pivot-wide-when-variable-names-contain-values-sql-and-base-r-sas-oython-excel-postgreSQL
https://github.com/rogerjdeangelis/utl-saving-and-creating-r-dataframes-to-and-from-a-postgresql-database-schema



/****************************************************************************************************************************************************/
/* INPUT                 | PROCESS                                                                | OUTPUT                                          */
/* =====                 | =======                                                                | ======                                          */
/* d:\csv\have.csv       | Process                                                                |                                                 */
/*                       | ========                                                               | Tables in initial template1 database            *
/* NAME,SEX,AGE,WEIGHT   |  1 create a template table                                             | I created the sample dataset                    */
/* Alfred,M,14,112.5     |    table sqlhav (NAME TEXT,SEX TEXT,AGE REAL,WEIGHT REAL);             |                                                 */
/* Alice,F,13,84         |  2 Ceate a file with the complete sql script c:/temp/output.sql        |          List of relations                      */
/* Barbara,F,13,98       |  3 Shell out and run the postgreSQL script  c:/temp/output.sql         |  Schema |  Name  | Type  |  Owner               */
/* Carol,F,14,102.5      |  4 Create a native spss sav data table d:/sav/want.sav                 | --------+--------+-------+----------            */
/* Henry,M,14,102.5      |  5 Create final csv fiile from sav file d:/sav/want.sav                |  public | sample | table | postgres             */
/*                       |  6 Create sas dataset want from pspp csv file work.want                | (1 row)                                         */
/* data have;            |                                                                        |                                                 */
/* informat              |                                  *--- for development        ---*;     |                                                 */
/*   NAME $8.            |  %utlfkil(c:/temp/output.sql);   *--- sql query              ---*;     | POSTGRESQL SQL                                  */
/*   SEX $1.             |  %utlfkil(d:/csv/wantout.csv);   *--- postgresql created csv ---*;     |                                                 */
/*   AGE 8.              |  %utlfkil(d:/sav/want.sav);      *--- native pspp table      ---*;     | +----------------------------------------------+*/
/*   WEIGHT 8.           |                                                                        | |                    qry                       |*/
/* ;                     |  proc datasets lib=work          *--- final sas dataset      ---*;     | +----------------------------------------------+*/
/* input                 |    nodetails nolist;                                                   | |drop table if exists sqlhav;                  |*/
/*  NAME SEX AGE WEIGHT; |    delete wantl                                                        | |drop table if exists want;                    |*/
/* cards4;               |  run;quit;                                                             | |\dt                                           |*/
/* Alfred M 14 112.5     |                                                                        | |create                                        |*/
/* Alice F 13 84         |  %utl_psppbeginx;                                                      | |  table sqlhav                                |*/
/* Barbara F 13 98       |  parmcards4;                                                           | |    (NAME TEXT,SEX TEXT,AGE REAL,WEIGHT REAL);|*/
/* Carol F 14 102.5      |  DATA LIST FIXED / qry 1-80 (A).                                       | |\copy sqlhav from 'd:/csv/have.csv'           |*/
/* Henry M 14 102.5      |                                                                        | |   delimiter ',' csv header;|                 |*/
/* ;;;;                  |  BEGIN DATA                                                            | |\dt                                           |*/
/* run;quit;             |  drop table if exists sqlhav;                                          | |create                                        |*/
/*                       |  drop table if exists want;                                            | |   table want as                              |*/
/*  *- CREATE CSV -*     |  \dt                                                                   | |select                                        |*/
/*                       |  create                                                                | |   sex                                        |*/
/* dm "dexport have      |   table sqlhav                                                         | |  ,avg(age)    as avgage                      |*/
/* 'd:\csv\have.csv'     |      (NAME TEXT,SEX TEXT,AGE REAL,WEIGHT REAL);                        | |  ,avg(weight) as avgwgt                      |*/
/*  replace";            |  \copy sqlhav from 'd:/csv/have.csv' delimiter ',' csv header;         | |from                                          |*/
/*                       |  \dt                                                                   | |   sqlhav                                     |*/
/*                       |  create                                                                | |group                                         |*/
/*                       |     table want as                                                      | |    by sex                                    |*/
/*                       |  select                                                                | |;                                             |*/
/*                       |     sex                                                                | |\dt                                           |*/
/*                       |    ,avg(age)    as avgage                                              | |\copy want TO 'd:/csv/wantout.csv' CSV HEADER;|*/
/*                       |    ,avg(weight) as avgwgt                                              | +----------------------------------------------+*/
/*                       | from                                                                   |         xpy end                                 */
/*                       |     sqlhav                                                             |                                                 */
/*                       |  group                                                                 |  LOADING SAS CSV FILE INTO POSTGRESQL           */
/*                       |      by sex                                                            |          List of relations                      */
/*                       |  ;                                                                     |  Schema |  Name  | Type  |  Owner               */
/*                       |  \dt                                                                   | --------+--------+-------+----------            */
/*                       |  \copy want TO 'd:/csv/wantout.csv' CSV HEADER;                        |  public | sample | table | postgres             */
/*                       |  END DATA.                                                             |  public | sqlhav | table | postgres             */
/*                       |                                                                        |                                                 */
/*                       |  LIST.                                                                 |                                                 */
/*                       |  SAVE TRANSLATE                                                        | CREATING POSTGRESQL TABLE WANT                  */
/*                       |    /OUTFILE='c:/temp/output.sql'                                       | WITH AVGERAGE AGE AND WEIGHT                    */
/*                       |    /TYPE=TAB                                                           |                                                 */
/*                       |    /REPLACE.                                                           |          List of relations                      */
/*                       |                                                                        |  Schema |  Name  | Type  |  Owner               */
/*                       |  HOST COMMAND=['psql -U postgres -d template1 -f c:/temp/output.sql']. | --------+--------+-------+----------            */
/*                       |                                                                        |  public | sample | table | postgres             */
/*                       |  GET DATA                                                              |  public | sqlhav | table | postgres             */
/*                       |    /TYPE=TXT                                                           |  public | want   | table | postgres             */
/*                       |    /FILE='d:/csv/wantout.csv'                                          |                                                 */
/*                       |    /DELCASE=LINE                                                       |       Data List                                 */
/*                       |    /DELIMITERS=","                                                     |  +---+------+------+                            */
/*                       |    /QUALIFIER='"'                                                      |  |SEX|AVEAGE|AVGWGT|                            */
/*                       |    /ARRANGEMENT=DELIMITED                                              |  +---+------+------+                            */
/*                       |    /FIRSTCASE=2                                                        |  |M  | 14.00|107.50|                            */
/*                       |    /VARIABLES=SEX A1 AVEAGE F8.2 AVGWGT F8.2.                          |  |F  | 13.33| 94.83|                            *
/*                       |  EXECUTE.                                                              |  +---+------+------+                            *
/*                       |  SAVE OUTFILE='d:/sav/want.sav'.                                       |                                                 *
/*                       |  LIST.                                                                 | SAS OUTPUT                                      *
/*                       |  ;;;;                                                                  |                                                 *
/*                       |  %utl_psppendx;                                                        | WANT total obs=2                                *
/*                       |                                                                        |                                                 *
/*                       |                                                                        |   SEX     AVGAGE     AVGWGT                     *
/*                       | dm "dimport 'd:/csv/wantout.csv' want  replace";                       |                                                 *
/*                       |                                                                        |    M     14.0000    107.500                     *
/*                       |                                                                        |    F     13.3333     94.833                     *
/***************************************************************************************************************************************************/

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/
data have;
informat
  NAME $8.
  SEX $1.
  AGE 8.
  WEIGHT 8.
;
input
 NAME SEX AGE WEIGHT;
cards4;
Alfred M 14 112.5
Alice F 13 84
Barbara F 13 98
Carol F 14 102.5
Henry M 14 102.5
;;;;
run;quit;

 *- CREATE CSV -*

dm "dexport have
'd:\csv\have.csv'
 replace";

/**************************************************************************************************************************/
/* d:\csv\have.csv                                                                                                        */
/*                                                                                                                        */
/* NAME,SEX,AGE,WEIGHT                                                                                                    */
/* Alfred,M,14,112.5                                                                                                      */
/* Alice,F,13,84                                                                                                          */
/* Barbara,F,13,98                                                                                                        */
/* Carol,F,14,102.5                                                                                                       */
/* Henry,M,14,102.5                                                                                                       */
/**************************************************************************************************************************/

/*
 _ __  _ __ ___   ___ ___  ___ ___
| `_ \| `__/ _ \ / __/ _ \/ __/ __|
| |_) | | | (_) | (_|  __/\__ \__ \
| .__/|_|  \___/ \___\___||___/___/
|_|
*/

%utlfkil(c:/temp/output.sql);   *--- sql query              ---*;
%utlfkil(d:/csv/wantout.csv);   *--- postgresql created csv ---*;
%utlfkil(d:/sav/want.sav);      *--- native pspp table      ---*;

proc datasets lib=work          *--- final sas dataset      ---*;
  nodetails nolist;
  delete wantl
run;quit;

%utl_psppbeginx;
parmcards4;
DATA LIST FIXED / qry 1-80 (A).

BEGIN DATA
drop table if exists sqlhav;
drop table if exists want;
\dt
create
 table sqlhav
    (NAME TEXT,SEX TEXT,AGE REAL,WEIGHT REAL);
\copy sqlhav from 'd:/csv/have.csv' delimiter ',' csv header;
\dt
create
   table want as
select
   sex
  ,avg(age)    as avgage
  ,avg(weight) as avgwgt
from
   sqlhav
group
    by sex
;
\dt
\copy want TO 'd:/csv/wantout.csv' CSV HEADER;
END DATA.

LIST.
SAVE TRANSLATE
  /OUTFILE='c:/temp/output.sql'
  /TYPE=TAB
  /REPLACE.

HOST COMMAND=['psql -U postgres -d template1 -f c:/temp/output.sql'].

GET DATA
  /TYPE=TXT
  /FILE='d:/csv/wantout.csv'
  /DELCASE=LINE
  /DELIMITERS=","
  /QUALIFIER='"'
  /ARRANGEMENT=DELIMITED
  /FIRSTCASE=2
  /VARIABLES=SEX A1 AVEAGE F8.2 AVGWGT F8.2.
EXECUTE.
SAVE OUTFILE='d:/sav/want.sav'.
LIST.
;;;;
%utl_psppendx;

dm "dimport 'd:/csv/wantout.csv' want  replace";

/**************************************************************************************************************************/
/* DROP TABLE                                                                                                             */
/* DROP TABLE                                                                                                             */
/*          List of relations                                                                                             */
/*  Schema |  Name  | Type  |  Owner                                                                                      */
/* --------+--------+-------+----------                                                                                   */
/*  public | sample | table | postgres                                                                                    */
/* (1 row)                                                                                                                */
/*                                                                                                                        */
/* CREATE TABLE                                                                                                           */
/* COPY 5                                                                                                                 */
/*          List of relations                                                                                             */
/*  Schema |  Name  | Type  |  Owner                                                                                      */
/* --------+--------+-------+----------                                                                                   */
/*  public | sample | table | postgres                                                                                    */
/*  public | sqlhav | table | postgres                                                                                    */
/* (2 rows)                                                                                                               */
/*                                                                                                                        */
/* SELECT 2                                                                                                               */
/*          List of relations                                                                                             */
/*  Schema |  Name  | Type  |  Owner                                                                                      */
/* --------+--------+-------+----------                                                                                   */
/*  public | sample | table | postgres                                                                                    */
/*  public | sqlhav | table | postgres                                                                                    */
/*  public | want   | table | postgres                                                                                    */
/* (3 rows)                                                                                                               */
/*                                                                                                                        */
/* COPY 2                                                                                                                 */
/*   Reading 1 record from INLINE.                                                                                        */
/* +--------+------+-------+------+                                                                                       */
/* |Variable|Record|Columns|Format|                                                                                       */
/* +--------+------+-------+------+                                                                                       */
/* |qry     |     1|1-80   |A80   |                                                                                       */
/* +--------+------+-------+------+                                                                                       */
/*                                                                                                                        */
/*                            Data List                                                                                   */
/* +-------------------------------------------------------------+                                                        */
/* |                             qry                             |                                                        */
/* +-------------------------------------------------------------+                                                        */
/* |drop table if exists sqlhav;                                 |                                                        */
/* |drop table if exists want;                                   |                                                        */
/* |\dt                                                          |                                                        */
/* |create                                                       |                                                        */
/* | table sqlhav                                                |                                                        */
/* |    (NAME TEXT,SEX TEXT,AGE REAL,WEIGHT REAL);               |                                                        */
/* |\copy sqlhav from 'd:/csv/have.csv' delimiter ',' csv header;|                                                        */
/* |\dt                                                          |                                                        */
/* |create                                                       |                                                        */
/* |   table want as                                             |                                                        */
/* |select                                                       |                                                        */
/* |   sex                                                       |                                                        */
/* |  ,avg(age)    as avgage                                     |                                                        */
/* |  ,avg(weight) as avgwgt                                     |                                                        */
/* |from                                                         |                                                        */
/* |   sqlhav                                                    |                                                        */
/* |group                                                        |                                                        */
/* |    by sex                                                   |                                                        */
/* |;                                                            |                                                        */
/* |\dt                                                          |                                                        */
/* |\copy want TO 'd:/csv/wantout.csv' CSV HEADER;               |                                                        */
/* +-------------------------------------------------------------+                                                        */
/*                                                                                                                        */
/*      Data List                                                                                                         */
/* +---+------+------+                                                                                                    */
/* |SEX|AVEAGE|AVGWGT|                                                                                                    */
/* +---+------+------+                                                                                                    */
/* |M  | 14.00|107.50|                                                                                                    */
/* |F  | 13.33| 94.83|                                                                                                    */
/* +---+------+------+                                                                                                    */
/**************************************************************************************************************************/

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
