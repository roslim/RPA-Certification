*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt Oas a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium    auto_close=${False}
Library             RPA.HTTP
Library             RPA.Excel.Files
Library             RPA.PDF
Library             RPA.Tables
Library             RPA.Archive


*** Tasks ***
Orders robots from RobotSpareBin Industries Inc.
    Open the robot order website

    ${orders}=    Get orders

    FOR    ${order}    IN    @{orders}
        Log    ${order}
        Fill the form    ${order}
        Wait Until Keyword Succeeds    5x    2s    Submit
        ${pdf}=    Store the receipt as a PDF file    ${order}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${order}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Order another robot
    END

    Create zip file


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Click Button    OK

Get orders
    Download
    ...    https://robotsparebinindustries.com/orders.csv
    ...    target_file=${OUTPUT DIR}${/}orders.csv
    ...    overwrite=True
    ${orders}=    Read table from CSV    orders.csv
    RETURN    ${orders}

Fill the form
    [Arguments]    ${order}
    Select From List By Value    head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    Input Text    xpath://input[contains(@placeholder,'Enter the part number')]    ${order}[Legs]
    Input Text    address    ${order}[Address]
    Click Button    Preview

Submit
    Click Button    Order
    Wait Until Element Is Visible    id:receipt

Store the receipt as a PDF file
    [Arguments]    ${orderid}
    #Wait Until Element Is Visible    id:receipt
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${OUTPUT DIR}${/}receipts${/}Receipt${orderid}.pdf
    RETURN    ${OUTPUT DIR}${/}receipts${/}Receipt${orderid}.pdf

Take a screenshot of the robot
    [Arguments]    ${orderid}
    Screenshot    xpath://div[@id='robot-preview-image']    ${OUTPUT DIR}${/}screenshots${/}Robot${orderid}.png
    RETURN    ${OUTPUT DIR}${/}screenshots${/}Robot${orderid}.png

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Open Pdf    ${pdf}
    Add Watermark Image To PDF
    ...    image_path=${screenshot}
    ...    source_path=${pdf}
    ...    output_path=${pdf}
    Close Pdf

Order another robot
    Click Button    xpath://button[@id='order-another']
    Click Button    OK

Create zip file
    Archive Folder With Zip    ${OUTPUT DIR}${/}receipts    Receipt_PDF.zip
