-----------------------------------------------------------------------------------
This example is for demonstration or learning purposes. Not optimized not modulated
-----------------------------------------------------------------------------------

You need terraform installed
You need a Confluent Cloud account + Confluent Cloud API Key and be logged to Confluent Cloud ($confluent login)
(OPTIONAL) You need a Salesforce account + token to connect to table
(OPTIONAL) You need a AWS account + API key to create and conenct to S3 bucket

Change the variables value in variables.tf before apply
Rememeber to init terraform for providers (Confluent and optional AWS) before apply
Check "plan.jpg" for the execution plan and dependencies
Check the cost of the infrastructure in Confluent Cloud once deployed

Resorces created;

1- Confluent Cloud Environment
2- Confluent Cloud basic cluster
3- Confluent Cloud service account
4- Confluent Cloud service account basic Cluster API KEY
5- Confluent Cloud topic in basic cluster - "orders"
6- Confluent Cloud topic in basic cluster - "account"
7- Confluent Cloud Datagen connector in basic cluster linked to "orders" topic
8- Confluent Cloud dedicated cluster
9- Confluent Cloud service account dedicated Cluster API KEY
10-Confluent Cloud cluster linking - "orders" topic in basic cluster replicated in dedicated cluster

OPTIONAL - uncomment to use ;
11- Confluent Cloud Salesforce Bulk API connector in basic cluster linked to "account" topic
12- AWS S3 bucket
13- Confluent Cloud AWS S3 connector indedicated cluster linked to replicated "orders" topic









