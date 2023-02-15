*** Settings ***
Library    String
Library    DatabaseLibrary
Library    OperatingSystem
Library    Collections
Library    validointi.py


*** Variables ***
${dbname}    Uipathprojekti
${dbhost}    localhost
${dbuser}    robotuser
${dbpass}    password
${dbport}    3306
${PATH}    C:/Users/niemi/Desktop/HAMK/HAMK21_22/Ohjelmointi/webservices/UiPath/robotframework/UiPathProjekti/

*** Test Cases ***
projektin polku
    Connect To Database    pymysql    ${dbname}    ${dbuser}    ${dbpass}    ${dbhost}    ${dbport}


${headers} Get file ${PATH}InvoiceHeaderData.csv
${rows} Get file ${PATH}InvoiceRowData.csv

${rows} Split String 

    #luetaan csv muuttujiin
    ${headerCSV}=    Get File    ${PATH}InvoiceHeaderData.csv
    ${rowCSV}=    Get File    ${PATH}InvoiceRowData.csv
    Log    ${rowCSV}

    @{header}=    Split String    ${headerCSV}    \n
    @{row}=    Split String    ${rowCSV}    \n
    Log    ${row}

    ${index}=    Convert To Integer    0
    Remove from list    ${header}    ${index}
    Log    ${header}

    @{headerRow}=    Split String    ${header}[0]    ;

    Log    ${headerRow}
    ${invoiceNumber}=    Set Variable    ${headerRow}[0]

*** Test Cases***
validointitesti
    ${referenceResult}=     Is Reference Number Correct     893479835
    
    if  not ${referenceResult}
        Log to console  Viite virhe
    end


