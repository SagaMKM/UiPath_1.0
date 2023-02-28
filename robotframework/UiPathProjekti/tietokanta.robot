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

@{ListToDB}
${InvoiceNumber}    empty



${PATH}    C:/Users/niemi/Desktop/HAMK/HAMK21_22/Ohjelmointi/webservices/UiPath/robotframework/UiPathProjekti/


*** Keywords ***
Make Connection
    [Arguments]    ${dbtoconnect}
    Connect To Database    pymysql    ${dbtoconnect}    ${dbuser}    ${dbpass}    ${dbhost}    ${dbport}

*** Keywords ***
Add Invoice Row To DB
    [Arguments]    ${items}
    Make Connection    ${dbname}
    ${insertStmt}=    Set Variable    insert into invoicerows    #tähän databasen variablet tyylillä: (invoicenumber,companyname...) ('${items}[0]',...); video 16 7:00 min
    Execute Sql String    ${insertStmt}


*** Keywords ***
Add Invoice Header to DB
    [Arguments]    ${items}
    Make Connection    ${dbname}
    #TODO: laskun päivä, summatiedot + status ja kommentit
    ${insertStmt}=    Set Variable    insert into invoiceheader    #tähän databasen variablet tyylillä: (invoicenumber,companyname...) (${items}[0],...); video 16 7:00 min
    Execute Sql String    ${insertStmt}

*** Keywords ***
Add Row Data to List
    [Arguments]    ${items}


    #Tarkista järjestys items numeroista eli tietokannan järjestys missä ovat
    @{AddInvoiceRowData}=    Create List
    Append To List    ${AddInvoiceRowData}    ${InvoiceNumber}
    Append To List    ${AddInvoiceRowData}    ${items}[8]
    Append To List    ${AddInvoiceRowData}    ${items}[0]
    Append To List    ${AddInvoiceRowData}    ${items}[1]
    Append To List    ${AddInvoiceRowData}    ${items}[2]
    Append To List    ${AddInvoiceRowData}    ${items}[3]
    Append To List    ${AddInvoiceRowData}    ${items}[4]
    Append To List    ${AddInvoiceRowData}    ${items}[5]
    Append To List    ${AddInvoiceRowData}    ${items}[6]

    Append To List    ${ListToDB}    ${AddInvoiceRowData}

*** Keywords ***
Check Amounts From Invoice
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

    IF  ${length} == 18
        ${status}=  Set Variable    ${True}
    END

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

    #yksittäinen käsittely
    @{headers}=    Split String    ${headerCSV}    \n
    @{rows}=    Split String    ${rowCSV}    \n
    Log    ${rows}

    #poistetaan otsikko 2 riviä
    #saga
    ${length}=  Get length  ${headers}
    ${length}=  Evaluate    ${length}-1
    ${index}=    Convert To Integer    0

    #headers remove
    Remove from list    ${headers}    ${length}
    Remove from list    ${headers}    ${index}

    Log    ${headers}

    ${length}=  Get length  ${rows}
    ${length}=  Evaluate  ${length}-1
    
    #rows remove
    Remove from list    ${rows}    ${length}
    Remove from list    ${rows}    ${index}

    Set Global Variable ${headers}
    Set Global Variable ${rows}

    #ylimääräiset?

    @{headerRow}=    Split String    ${headers}[0]    ;

    Log    ${headerRow}
    ${invoiceNumber}=    Set Variable    ${headerRow}[0]

*** Test Cases***
Loop all invoicerows
    FOR    ${element}  IN    @    {rows}

        Log ${element}

        @{items}=   Split String    ${element}  ;

        #käsiteltävän rivin laskunumero
        ${rowInvoiceNumber}=   Set Variable    ${items}[7]


        #Nämä muuttujat pitää tarkistaa videossa invoicenumber ja rowinvoicenumber
        Log ${invoiceNumber}
        Log ${rowInvoiceNumber} 


        #vaihtuuko laskunumero
        IF    '${rowInvoiceNumber}' == '${InvoiceNumber}'
            Log    Lisätään rivejä laskulle
            
            #lisää käsiteltävän laskun tiedot listaan
            Add Row Data to List    ${items}
        ELSE
            Log    Onko tietokantalistassa jo rivejä
            ${length}=    Get Length    ${ListToDB}
            IF    ${length} == ${0}
                Log    Ensimmäisen laskun tapaus
                #päivittää laskun numeron
                ${InvoiceNumber}=    Set Variable    ${rowInvoiceNumber}
                Set Global Variable    ${InvoiceNumber}
                #lisää käsiteltävän laskun tiedot listaan

                Add Row Data to List    ${items}
            ELSE
                Log    Lasku vaihtuu, pitää käsitellä myös otsikkodata

                #Etsi laskun otsikko rivi
                FOR    ${headerElement}    IN    @    {headers}
                    ${headerItems}=    Split String    ${headerElement}    ;

                    IF    '${headerItems}[0] == '${InvoiceNumber}'
                        Log    Laksu löytyi

                        #validointi

                        #Syötä laskun otsikkorivi tietokantaan
                        Add Invoice Header to DB    ${headerItems}
                        
                        #syötä laskun rivit tietokantaan
                        FOR    ${rowElement}    IN    @{ListToDB}
                            Add Invoice Row To DB    ${rowElement}
                            
                        END
                        
                    END
                    
                END
              

              

              

                #valmista prosessi seuraavaan laskuun
                ${ListToDB}    Create List
                Set Global Variable    ${ListToDB}
                ${InvoiceNumber}=    Set Variable    ${rowInvoiceNumber}
                Set Global Variable    ${InvoiceNumber}

                #lisää käsiteltävän laskun tiedot listaan
                Add Row Data to List    ${items}
            END
        END
    END

    #viimeisen laskun tapaus
    ${length}=    Get Length    ${ListToDB}
    IF    ${length} > ${0}
        Log    Viimeisen laskun otsikkokäsittely

#Etsi laskun otsikko rivi
        FOR    ${headerElement}    IN    @    {headers}
            ${headerItems}=    Split String    ${headerElement}    ;

            IF    '${headerItems}[0] == '${InvoiceNumber}'
                Log    Laksu löytyi

                #validointi

                #Syötä laskun otsikkorivi tietokantaan
                Add Invoice Header to DB    ${headerItems}
                
                #syötä laskun rivit tietokantaan
                FOR    ${rowElement}    IN    @{ListToDB}
                    Add Invoice Row To DB    ${rowElement}
                    
                END
                
            END
            
        END
    END

   


*** Test Cases***
validointitesti
    ${referenceResult}=     Is Reference Number Correct     893479835
    
    IF  not ${referenceResult}
        Log to console  Viite virhe
    END

    ${ibanResult}=     Check IBAN     FI23 2333 4334 3431 34
    
    IF  not ${ibanResult}
        Log to console  IBAN virhe
    END

    ${sumResult}=    Check Amounts From Invoice     2332,22    2332,23
    
    IF  not ${sumResult}
        Log to console  Summa virhe
    END