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

*** Keywords ***
Check Amounts Fom Invoice
    [Arguments]     ${totalSumFromHeader}   ${totalSumFromRows}
    ${status}=  Set Variable    ${False}
    ${totalSumFromHeader}=  Convert To Number    ${totalSumFromHeader}
    ${totalSumFromRows}=    Convert To Number   ${totalSumFromRows}

    ${diff}=    Convert To Number   0,01

    ${status}= Is Equal     ${totalSumFromHeader}   ${totalSumFromRows}     ${diff}

    [Return]    ${status}

*** Keywords ***
Check IBAN
    [Arguments]     ${iban}
    ${status}=      Set Variable    ${False}
    ${iban}=    Remove String   ${iban}     ${SPACE}
    #Log to console  ${iban}

    ${length}=  Get length  ${iban}

    if  ${length} == 18
        ${status}=  Set Variable    ${True}
    end

    [Return]    ${status}

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

    ${ibanResult}=     Check IBAN     FI23 2333 4334 3431 34
    
    if  not ${ibanResult}
        Log to console  IBAN virhe
    end

    ${sumResult}=     Check Amount From Invoice     2332,22    2332,23
    
    if  not ${sumResult}
        Log to console  Summa virhe
    end