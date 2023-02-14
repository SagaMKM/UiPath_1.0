*** Settings ***
Library    String
Library    DatabaseLibrary

*** Variables ***
${dbname}    Uipathprojekti
${dbhost}    localhost
${dbuser}    robotuser
${dbpass}    password
${dbport}    3306

*** Test Cases ***
projektin polku
    Connect To Database    pymysql    ${dbname}    ${dbuser}    ${dbpass}    ${dbhost}    ${dbport}



${headers} Get file ${PATH}InvoiceHeaderData.csv
${rows} Get file ${PATH}InvoiceRowData.csv

${rows} Split String 