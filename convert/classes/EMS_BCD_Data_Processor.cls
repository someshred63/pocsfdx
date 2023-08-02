public without sharing class EMS_BCD_Data_Processor {
    public List<TransactionWrapper> anomaliesAndErrors { get; set; }
    public List<TransactionWrapper> emsTransactions { get; set; }
    public List<TransactionWrapper> nonemsTransactions { get; set; }
    public Map<Integer, String> allTransactions { get; set; }
    public String originalFileName { get; set; }

    public transient Blob csvFileBody { get; set; }
    private transient String csvAsString { get; set; }
    public Boolean isFileUploaded {
        get {
            if (isFileUploaded == null) isFileUploaded = false;
            return isFileUploaded;
        }
        set;
    }

    public String csvHeaderColumns { get; set; }
    public String secondRow { get; set; }
    public String lastRow { get; set; }
    public String preLastRow { get; set; }

    // When System is unable to match a T# with EMS Data
    private static final String commentTravelIncorrect = 'Invalid/Missing EMS Transaction Number';

    // When System is unable to find a budget allocation associated to the event, yet a T# has been created
    private static final String commentCostCenterIncorrect = 'Invalid/Missing Cost Centre';

    // When System finds a valid T# with more than 1 budget allocation associated to the event
    private static final String commentBudgetSplitCorrection = 'Corrected via budget split based on EMS Data';

    // When System finds a valid T# with mismatched/missing Cost Centre(s) associated to the event
    private static final String commentCostCenterCorrection = 'Corrected Cost Centre based on EMS Data';

    private static final Integer columnsXMLCount = 16;
    private static final Integer columnsXMLWidth = 75;
    private static final String tmplWorksheetXML = '<Worksheet ss:Name="{nameWS}"><Table ss:StyleID="{tableStyle}" ss:ExpandedColumnCount="{columnsXMLCount}">{rowsWidth}{rows}</Table></Worksheet>';
    private static final String tmplCellXML = '<Cell{attributeStyleID}{attributeFormula}><Data ss:Type="{nameType}">{data}</Data></Cell>';
    private static final Integer collectionLimit = 1000;
    private static final Integer MAX_TRANSACTIONS_COUNT = 1500;
    private static final Integer MAX_EXPORT_SIZE = 1800;

    private transient Map<String, Integer> headersMap;
    private Set<Integer> uniqueIDcontainer = new Set<Integer>();

    public EMS_BCD_Data_Processor() {
        anomaliesAndErrors = new List<TransactionWrapper>();
        emsTransactions = new List<TransactionWrapper>();
        nonemsTransactions = new List<TransactionWrapper>();
        allTransactions = new Map<Integer, String>();
        uniqueIDcontainer = new Set<Integer>();
    }

    public static String getXMLHeader() {
        return '<?xml version="1.0"?><?mso-application progid="Excel.Sheet"?>';
    }
    public String exportType { get; set; } // XLS or CSV options
    public String sectionToExport { get; set; } // 1)allwoerrors = EMS and Non-EMS Transactions, 2)transactions = EMS Transactions; 3)errors = EMS Errors and Anomalies, 4) nonemstransactions = Non-EMS Transactions
    public String fileName { get; private set; }

    private Boolean exportAll {
        get {
            return (sectionToExport != null && sectionToExport == 'allwoerrors');
        }
    }

    public PageReference openExportPage() {
        PageReference exportPage;
        if (exportType == 'csv') {
            fileName = (sectionToExport == 'allwoerrors') ? 'All' : 'export';
            fileName += ' - ' + DateTime.now().format('MM/dd/yyyy');
            exportPage = new PageReference('/apex/EMS_BCD_Data_ExportCSV');
        }
        if (exportType == 'xls') {
            if (sectionToExport == 'transactions') {
                if (emsTransactions.size() > MAX_EXPORT_SIZE) {
                    ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, 'The number of max transactions has been reached, please adjust the load file.');
                    ApexPages.addMessage(errorMessage);
                    return null;
                }
                fileName = 'EMS Transactions';
            } else if (sectionToExport == 'nonemstransactions') {
                fileName = 'Non EMS Transactions';
            } else if (sectionToExport == 'errors') {
                fileName = 'EMS Anomalies and Errors';
            } else {
                fileName = 'export';
            }
            fileName += ' - ' + DateTime.now().format('MM/dd/yyyy');
            exportPage = new PageReference('/apex/EMS_BCD_Data_ExportXLS');
        }
        exportPage.setRedirect(false);
        return exportPage;
    }

    public List<LimitWrapper> thousandBlocks { get; set; }
    public List<String> dataXML { get; set; }

    public void prepareData() {
        if (sectionToExport == 'allwoerrors') {
            thousandBlocks = new List<LimitWrapper>();

            Integer loopCount = 0;
            Set<Integer> tempRecordIDs = new Set<Integer>();
            List<TransactionWrapper> transactionsWOErrors = new List<TransactionWrapper>();
            transactionsWOErrors.addAll(emsTransactions);
            transactionsWOErrors.addAll(nonemsTransactions);

            for (TransactionWrapper record : transactionsWOErrors) {
                tempRecordIDs.add(record.recordID);

                if (tempRecordIDs.size() == collectionLimit) {
                    loopCount++;
                    thousandBlocks.add(new LimitWrapper(tempRecordIDs, loopCount));
                    tempRecordIDs = new Set<Integer>();
                }
            }
            if (!tempRecordIDs.isEmpty()) {
                loopCount++;
                thousandBlocks.add(new LimitWrapper(tempRecordIDs, loopCount));
            }
        } else if (sectionToExport == 'transactions') {
            dataXML = prepareWorksheetXLMLForXLS(emsTransactions, false, new Set<String>{
                    'Template', 'Backup 1', 'Z_OPTION_GLSU_DESCRIPTION_CACHE'
            });
        } else if (sectionToExport == 'errors') {
            dataXML = prepareWorksheetXLMLForXLS(anomaliesAndErrors, true, new Set<String>{
                    'Backup 1'
            });
        } else if (sectionToExport == 'nonemstransactions') {
            dataXML = prepareWorksheetXLMLForXLS(nonemsTransactions, false, new Set<String>{
                    'Template', 'Backup 1', 'Z_OPTION_GLSU_DESCRIPTION_CACHE'
            });
        }
    }

    private List<String> prepareWorksheetXLMLForXLS(List<TransactionWrapper> records, Boolean includeComments, Set<String> worksheetNames) {
        List<String> worksheets = new List<String>();
        List<String> backupRows = new List<String>();
        String rowsWidth = '';
        Integer columnsCount = 0;
        List<String> templateRows = new List<String>();

        // ONLY for "Template" Worksheet
        if (worksheetNames.contains('Template')) {
            // Prepare <Column> tags which set Columns width
            for (Integer i = 0; i < columnsXMLCount; i++) {
                if (i == 6 || i == 8) {
                    rowsWidth += '<Column ss:Width="' + (columnsXMLWidth + 20) + '"/>';
                } else {
                    rowsWidth += '<Column ss:Width="' + columnsXMLWidth + '"/>';
                }
            }

            // Prepare Blue and Green cells with Data
            templateRows.add('<Row />');

            // Hidden row above Blue row //BKPF  BLART   BUKRS   BLDAT   BUDAT   WAERS   BKTXT   XBLNR   BELNR
            List<String> cells = new List<String>{
                    '<Row ss:Hidden="1">',
                    '<Cell ><Data ss:Type="String">BKPF</Data></Cell>',
                    '<Cell ><Data ss:Type="String">BLART</Data></Cell>',
                    '<Cell ><Data ss:Type="String">BUKRS</Data></Cell>',
                    '<Cell ><Data ss:Type="String">BLDAT</Data></Cell>',
                    '<Cell ><Data ss:Type="String">BUDAT</Data></Cell>',
                    '<Cell ><Data ss:Type="String">WAERS</Data></Cell>',
                    '<Cell ><Data ss:Type="String">BKTXT</Data></Cell>',
                    '<Cell ><Data ss:Type="String">XBLNR</Data></Cell>',
                    '<Cell ><Data ss:Type="String">BELNR</Data></Cell>',
                    '</Row>'
            };
            templateRows.add(String.join(cells, ''));

            // Blue header row
            cells = new List<String>{
                    '<Row >',
                    prepareCell('Bold', null, 'String', 'Header:'),
                    prepareCell('BlueCell', null, 'String', 'Document type'),
                    prepareCell('BlueCell', null, 'String', 'Company Code'),
                    prepareCell('BlueCell', null, 'String', 'Document Date'),
                    prepareCell('BlueCell', null, 'String', 'Posting Date'),
                    prepareCell('BlueCell', null, 'String', 'Currency'),
                    prepareCell('BlueCell', null, 'String', 'Doc.Header Text'),
                    prepareCell('BlueCell', null, 'String', 'Reference'),
                    prepareCell('BlueCell', null, 'String', 'Document Number'),
                    '</Row>'
            };
            templateRows.add(String.join(cells, ''));

            // Add data under Blue header row
            cells = new List<String>{
                    '<Row >',
                    '<Cell><Data ss:Type="String"></Data></Cell>',
                    '<Cell ss:StyleID="WhiteCell"><Data ss:Type="String"></Data></Cell>',
                    '<Cell ss:StyleID="WhiteCell"><Data ss:Type="String"></Data></Cell>',
                    '<Cell ss:StyleID="WhiteCell"><Data ss:Type="String"></Data></Cell>',
                    '<Cell ss:StyleID="WhiteCell"><Data ss:Type="String"></Data></Cell>',
                    '<Cell ss:StyleID="WhiteCell"><Data ss:Type="String"></Data></Cell>',
                    '<Cell ss:StyleID="WhiteCell"><Data ss:Type="String"></Data></Cell>',
                    '<Cell ss:StyleID="WhiteCell"><Data ss:Type="String"></Data></Cell>',
                    '<Cell ss:StyleID="WhiteCell"><Data ss:Type="String"></Data></Cell>',
                    '</Row>'
            };
            templateRows.add(String.join(cells, ''));

            templateRows.add('<Row />');

            // Hidden row above Green row //BSEG    NEWBS   NEWKO   (blank column)1 WRBTR   SGTXT   KOSTL   PROJK   PRCTR   BEWAR   ZUONR   MWSKZ   TXJCD   VBUND   VALUT
            cells = new List<String>{
                    '<Row ss:Hidden="1">',
                    '<Cell ><Data ss:Type="String">BSEG</Data></Cell>',
                    '<Cell ><Data ss:Type="String">NEWBS</Data></Cell>',
                    '<Cell ><Data ss:Type="String">NEWKO</Data></Cell>',
                    '<Cell ><Data ss:Type="String">(blank column)1</Data></Cell>',
                    '<Cell ><Data ss:Type="String">WRBTR</Data></Cell>',
                    '<Cell ><Data ss:Type="String">SGTXT</Data></Cell>',
                    '<Cell ><Data ss:Type="String">KOSTL</Data></Cell>',
                    '<Cell ><Data ss:Type="String">PROJK</Data></Cell>',
                    '<Cell ><Data ss:Type="String">PRCTR</Data></Cell>',
                    '<Cell ><Data ss:Type="String">BEWAR</Data></Cell>',
                    '<Cell ><Data ss:Type="String">ZUONR</Data></Cell>',
                    '<Cell ><Data ss:Type="String">MWSKZ</Data></Cell>',
                    '<Cell ><Data ss:Type="String">TXJCD</Data></Cell>',
                    '<Cell ><Data ss:Type="String">VBUND</Data></Cell>',
                    '<Cell ><Data ss:Type="String">VALUT</Data></Cell>',
                    '</Row>'
            };
            templateRows.add(String.join(cells, ''));

            // Green header row
            cells = new List<String>{
                    '<Row >',
                    prepareCell('Bold', null, 'String', 'Line Items:'),
                    prepareCell('GreenCell', null, 'String', 'Posting key'),
                    prepareCell('GreenCell', null, 'String', 'Account'),
                    prepareCell('GreenCell', null, 'String', 'Account Description'),
                    prepareCell('GreenCell', '=&#39;C:\\Program Files (x86)\\Z Option\\GLSU\\Z Option GLSU.xla&#39;!glsu_balance(R[1]C[-3]:R[2001]C[-3], R[1]C:R[2001]C, R[1]C[-4]:R[2001]C[-4], R[-3]C[1])', 'String', null),  // ;; //prepareCell('GreenCell', null, 'String', 'Amount'),
                    prepareCell('GreenCell', null, 'String', 'Text'),
                    prepareCell('GreenCell', null, 'String', 'Cost Center'),
                    prepareCell('GreenCell', null, 'String', 'WBS Element'),
                    prepareCell('GreenCell', null, 'String', 'Profit Center'),
                    prepareCell('GreenCell', null, 'String', 'Transactn Type'),
                    prepareCell('GreenCell', null, 'String', 'Assignment'),
                    prepareCell('GreenCell', null, 'String', 'Tax Code'),
                    prepareCell('GreenCell', null, 'String', 'Jurisdict. Code'),
                    prepareCell('GreenCell', null, 'String', 'Trading Partner'),
                    prepareCell('GreenCell', null, 'String', 'Value date'),
                    '</Row>'
            };
            templateRows.add(String.join(cells, ''));
        }

        if (worksheetNames.contains('Backup 1')) {
            // Prepare Column Names for Worksheet
            List<String> headerRow = new List<String>{
                    '<Row>'
            };
            for (String headerValue : csvHeaderColumns.split(',')) {
                headerRow.add(prepareCell(null, null, 'String', headerValue));
                columnsCount++;
            }
            if (includeComments) {
                columnsCount++;
                headerRow.add(prepareCell(null, null, 'String', 'Reason'));
            }
            headerRow.add('</Row>');
            backupRows.add(String.join(headerRow, ''));

            if (exportAll) {
                List<String> secondRowList = new List<String>{
                        '<Row>'
                };
                for (String srValue : secondRow.split(',')) {
                    secondRowList.add(prepareCell(null, null, 'String', srValue));
                }
                secondRowList.add('</Row>');
                backupRows.add(String.join(secondRowList, ''));
            }
        }

        // Prepare records Data
        List<String> recordValues;
        List<String> content;

        for (TransactionWrapper record : records) {
            recordValues = allTransactions.get(record.recordID).split(',');

            if (worksheetNames.contains('Template')) {
                content = new List<String>{
                        '<Row >',
                        prepareCell(null, '=IF(RC[4]=0, &quot;ignore&quot;, &quot;&quot;)', 'String', null),
                        String.format('<Cell ss:StyleID="WhiteCell"><Data ss:Type="String">{0}</Data></Cell>', new List<String>{
                                recordValues [14]
                        }),
                        String.format('<Cell ss:StyleID="WhiteCell"><Data ss:Type="Number">{0}</Data></Cell>', new List<String>{
                                recordValues [15]
                        }),
                        prepareCell('WhiteCell', '=&#39;C:\\Program Files (x86)\\Z Option\\GLSU\\Z Option GLSU.xla&#39;!glsu_description(RC[-1])', 'String', null),
                        String.format('<Cell ss:StyleID="WhiteCell"><Data ss:Type="Number">{0}</Data></Cell>', new List<String>{
                                recordValues [16]
                        }),
                        String.format('<Cell ss:StyleID="WhiteCell"><Data ss:Type="String">{0}</Data></Cell>', new List<String>{
                                recordValues [34]
                        }),
                        String.format('<Cell ss:StyleID="WhiteCell"><Data ss:Type="Number">{0}</Data></Cell>', new List<String>{
                                recordValues [19]
                        }),
                        '<Cell ss:StyleID="WhiteCell"><Data ss:Type="String"></Data></Cell>',
                        '<Cell ss:StyleID="WhiteCell"><Data ss:Type="String"></Data></Cell>',
                        '<Cell ss:StyleID="WhiteCell"><Data ss:Type="String"></Data></Cell>',
                        String.format('<Cell ss:StyleID="WhiteCell"><Data ss:Type="String">{0}</Data></Cell>', new List<String>{
                                recordValues [36]
                        }),
                        '<Cell ss:StyleID="WhiteCell"><Data ss:Type="String"></Data></Cell>',
                        '<Cell ss:StyleID="WhiteCell"><Data ss:Type="String"></Data></Cell>',
                        '<Cell ss:StyleID="WhiteCell"><Data ss:Type="String"></Data></Cell>',
                        '<Cell ss:StyleID="WhiteCell"><Data ss:Type="String"></Data></Cell>',
                        '</Row>'
                };

                // One record row is generated, add it to Rows
                templateRows.add(String.join(content, ''));
            }
        }

        // add template tab
        if (worksheetNames.contains('Template')) {
            String worksheet1 = tmplWorksheetXML.replace('{rows}', String.join(templateRows, ''));
            worksheet1 = worksheet1.replace('{tableStyle}', 'GreyCell');
            worksheet1 = worksheet1.replace('{rowsWidth}', rowsWidth);
            worksheet1 = worksheet1.replace('{columnsXMLCount}', columnsXMLCount.format());
            worksheet1 = worksheet1.replace('{nameWS}', 'Template');

            worksheets.add(worksheet1);
        }

        templateRows = null;

        for (TransactionWrapper record : records) {
            recordValues = allTransactions.get(record.recordID).split(',');

            if (worksheetNames.contains('Backup 1')) {
                content = new List<String>{
                        '<Row>'
                };

                for (String recordValue : recordValues) {
                    content.add(String.format('<Cell ss:StyleID="WhiteCell"><Data ss:Type="String">{0}</Data></Cell>', new List<String>{
                            recordValue
                    }));
                }
                if (includeComments) {
                    String comment = record.comment;
                    content.add(String.format('<Cell ss:StyleID="WhiteCell"><Data ss:Type="String">{0}</Data></Cell>', new List<String>{
                            comment
                    }));

                }
                content.add('</Row>');
                backupRows.add(String.join(content, ''));
            }
        }

        if (worksheetNames.contains('Backup 1') && exportAll) {
            // Adding Pre-Last Row in the File
            List<String> prelastRowList = new List<String>{
                    '<Row>'
            };
            for (String plrValue : prelastRow.split(',')) {
                prelastRowList.add(prepareCell(null, null, 'String', plrValue));
            }
            prelastRowList.add('</Row>');
            backupRows.add(String.join(prelastRowList, ''));

            // Adding Last Row in the File
            List<String> lastRowList = new List<String>{
                    '<Row>'
            };
            for (String lrValue : lastRow.split(',')) {
                lastRowList.add(prepareCell(null, null, 'String', lrValue));
            }
            lastRowList.add('</Row>');
            backupRows.add(String.join(lastRowList, ''));
        }

        // add backup tab
        if (worksheetNames.contains('Backup 1')) {
            String worksheet2 = tmplWorksheetXML.replace('{rows}', String.join(backupRows, ''));
            worksheet2 = worksheet2.replace('{tableStyle}', '');
            worksheet2 = worksheet2.replace('{rowsWidth}', '');
            worksheet2 = worksheet2.replace('{columnsXMLCount}', columnsCount.format());
            worksheet2 = worksheet2.replace('{nameWS}', 'Backup 1');

            worksheets.add(worksheet2);
        }

        if (worksheetNames.contains('Z_OPTION_GLSU_DESCRIPTION_CACHE')) {
            List<String> rows = new List<String>{
                    '<Row ><Cell ><Data ss:Type="String">NEWKO</Data></Cell></Row>',
                    '<Row ><Cell ><Data ss:Type="String">2286                    11221120</Data></Cell><Cell ><Data ss:Type="String">GST Receivable</Data></Cell></Row>',
                    '<Row ><Cell ><Data ss:Type="String">2286                    11221140</Data></Cell><Cell ><Data ss:Type="String">Quebec Sls Tax-Recov</Data></Cell></Row>',
                    '<Row ><Cell ><Data ss:Type="String">2286                    21220323</Data></Cell><Cell ><Data ss:Type="String">Accr Exp-General</Data></Cell></Row>',
                    '<Row ><Cell ><Data ss:Type="String">2286                    41710101</Data></Cell><Cell ><Data ss:Type="String">Travel-Business</Data></Cell></Row>',
                    '<Row ><Cell ><Data ss:Type="String">2286                    41811608</Data></Cell><Cell ><Data ss:Type="String">Consultancy Meetings</Data></Cell></Row>',
                    '<Row ><Cell ><Data ss:Type="String">2286                    41811618</Data></Cell><Cell ><Data ss:Type="String">Med OLA/Acc CHE Misc</Data></Cell></Row>',
                    '<Row ><Cell ><Data ss:Type="String">2286                    43119909</Data></Cell><Cell ><Data ss:Type="String">Fees & Grants-Genera</Data></Cell></Row>',
                    '<Row ><Cell ><Data ss:Type="String">2286                    43119910</Data></Cell><Cell ><Data ss:Type="String">Fees & Grants-Meetin</Data></Cell></Row>',
                    '<Row ><Cell ><Data ss:Type="String">2286                    43190177</Data></Cell><Cell ><Data ss:Type="String">OS Gen Consult-Exp</Data></Cell></Row>',
                    '<Row ><Cell ><Data ss:Type="String">2286                    43190303</Data></Cell><Cell ><Data ss:Type="String">Relocation</Data></Cell></Row>'
            };

            String worksheet3 = tmplWorksheetXML.replace('{rows}', String.join(rows, ''));
            worksheet3 = worksheet3.replace('{tableStyle}', '');
            worksheet3 = worksheet3.replace('{rowsWidth}', '');
            worksheet3 = worksheet3.replace('{columnsXMLCount}', '2');
            worksheet3 = worksheet3.replace('{nameWS}', 'Z_OPTION_GLSU_DESCRIPTION_CACHE');

            worksheets.add(worksheet3);
        }

        backupRows = null;

        return worksheets;
    }

    private String prepareCell(String styleId, String formula, String nameType, String data) {
        styleId = (styleId == '' || styleId == null) ? '' : ' ss:StyleID="' + styleId + '"';
        formula = (formula == '' || formula == null) ? '' : ' ss:Formula="' + formula + '"';
        nameType = (nameType == 'Number' || nameType == 'DateTime' || nameType == 'Boolean' || nameType == 'Error') ? nameType : 'String';
        data = (data == '' || data == null) ? '' : data;

        String cell = '';
        cell = tmplCellXML.replace('{attributeStyleID}', styleId);
        cell = cell.replace('{attributeFormula}', formula);
        cell = cell.replace('{nameType}', nameType);
        cell = cell.replace('{data}', data);

        return cell;
    }

    private void clearAllCollections() {
        anomaliesAndErrors = new List<TransactionWrapper>();
        emsTransactions = new List<TransactionWrapper>();
        nonemsTransactions = new List<TransactionWrapper>();
        allTransactions = new Map<Integer, String>();
        uniqueIDcontainer = new Set<Integer>();

        thousandBlocks = new List<LimitWrapper>();
        dataXML = new List<String>();
    }

    public void publish() {
        isFileUploaded = false;
        headersMap = new Map<String, Integer>();
        clearAllCollections();

        try {
            csvAsString = csvFileBody.toString();

            Utility_RowIterator iter = new Utility_RowIterator(csvAsString);
            Map<String, List<TransactionWrapper>> transactionsWOErrors = new Map<String, List<TransactionWrapper>>();
            Integer rowNum = 0;
            Integer lastInRow = 0;
            Integer prelastInRow = 0;
            while (iter.hasNext()) {
                String row = iter.next();

                if (rowNum == 0) {
                    csvHeaderColumns = row;
                    List<String> headers = row.split(',');
                    for (Integer j = 0; j < headers.size(); j++) {
                        headersMap.put(headers[j].toLowerCase(), j);
                    }
                } else if (rowNum == 1) {
                    // Skipping Second Row with data - this is not a Transaction Record
                    secondRow = row;
                } else {
                    List<String> rowValues = row.split(',');
                    String lineItemText = rowValues[headersMap.get('line item text')];
                    if (lineItemText == 'GST/HST Taxes') {
                        // Skipping Last and Pre-Last Row with data - these are not Transaction Records
                        lastRow = row;
                    } else if (lineItemText == 'QST Taxes') {
                        // Skipping Last and Pre-Last Row with data - these are not Transaction Records
                        prelastRow = row;
                    } else {
                        String travelName = rowValues[headersMap.get('event id/ems')];
                        String costCenterName = rowValues[headersMap.get('cost center')];

                        Decimal amount = (String.valueOf(rowValues[headersMap.get('amount')]).trim() == '') ? 0 : Decimal.valueOf(String.valueOf(rowValues[headersMap.get('amount')]).trim());
                        String hcpName = rowValues[headersMap.get('air passenger name')];
                        String costElement = rowValues[headersMap.get('gl code')];
                        Integer uniqueID = generateUniqueID();
                        String ticketID = rowValues[headersMap.get('ticket')];
                        String travellerType = rowValues[headersMap.get('traveler type')];

                        // Collection contains information about Data rows (<UniqueID, Data row>)
                        allTransactions.put(uniqueID, row);

                        if (String.isBlank(travelName) || String.isEmpty(travelName)) {
                            // Add to Non EMS Transaction section
                            nonemsTransactions.add(new TransactionWrapper(null, hcpName, costCenterName, costElement, amount, travellerType, ticketID, uniqueID));
                        } else {
                            if (transactionsWOErrors.containsKey(travelName)) {
                                List<TransactionWrapper> temp = transactionsWOErrors.get(travelName);
                                temp.add(new TransactionWrapper(travelName, hcpName, costCenterName, costElement, amount, travellerType, ticketID, uniqueID));
                                transactionsWOErrors.put(travelName, temp);
                            } else {
                                TransactionWrapper twRecord = new TransactionWrapper(travelName, hcpName, costCenterName, costElement, amount, travellerType, ticketID, uniqueID);
                                transactionsWOErrors.put(travelName, new List<TransactionWrapper>{
                                        twRecord
                                });
                            }
                        }
                    }
                }

                if (rowNum == (MAX_TRANSACTIONS_COUNT + 1)) {
                    // empty file was submitted
                    throw new CustomLimitException('The number of max transactions has been reached, please adjust the load file.');
                }

                rowNum++;
            }

            if (rowNum <= 4) {
                // empty file was submitted
                throw new CustomLimitException('File contains no information.');
            }

            List<EMS_Travel_gne__c> travels = [SELECT Name, EMS_Event_gne__c FROM EMS_Travel_gne__c WHERE Name IN:transactionsWOErrors.keySet()];
            Map<String, String> travelNames_evenIDs_InEMS = new Map<String, String>();
            for (EMS_Travel_gne__c travel : travels) {
                travelNames_evenIDs_InEMS.put(travel.Name, travel.EMS_Event_gne__c);
            }
            List<EMS_Budget_Allocation_gne__c> budgetAllocations = [SELECT Cost_Center_gne__c, EMS_Event_gne__c, Percentage_Contribution_gne__c FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c IN:travelNames_evenIDs_InEMS.values()];
            Map<String, List<EMS_Budget_Allocation_gne__c>> event_budgetAllocations = new Map<String, List<EMS_Budget_Allocation_gne__c>>();
            Map<String, Decimal> evendID_sumPercentages = new Map<String, Decimal>();
            for (EMS_Budget_Allocation_gne__c budgetAllocation : budgetAllocations) {
                String eventID = budgetAllocation.EMS_Event_gne__c;
                if (event_budgetAllocations.containsKey(eventID)) {
                    List<EMS_Budget_Allocation_gne__c> temp = event_budgetAllocations.get(eventID);
                    temp.add(budgetAllocation);
                    event_budgetAllocations.put(eventID, temp);

                    Decimal sumPercentages = evendID_sumPercentages.get(eventID);
                    sumPercentages += (Decimal) budgetAllocation.Percentage_Contribution_gne__c;
                    evendID_sumPercentages.put(eventID, sumPercentages);
                } else {
                    event_budgetAllocations.put(eventID, new List<EMS_Budget_Allocation_gne__c>{
                            budgetAllocation
                    });
                    evendID_sumPercentages.put(eventID, (Decimal) budgetAllocation.Percentage_Contribution_gne__c);
                }
            }

            List<TransactionWrapper> recordsToAddInEMSAnomaliesAndErrors = new List<TransactionWrapper>();
            List<TransactionWrapper> recordsToAddInEMSTransactions = new List<TransactionWrapper>();
            for (String travelNameInCSV : transactionsWOErrors.keySet()) {
                if (travelNames_evenIDs_InEMS.containsKey(travelNameInCSV)) { // Travel record exists in EMS
                    String eventId = travelNames_evenIDs_InEMS.get(travelNameInCSV);
                    if (event_budgetAllocations.containsKey(eventId)) {
                        List<EMS_Budget_Allocation_gne__c> bas = event_budgetAllocations.get(eventId);
                        if (bas.size() == 0) {
                            // No budget allocation for the specified cost center exists are not found in EMS,
                            // add to "EMS – errors & anomalies" view & to the "EMS Transaction" view
                            // This case is the same what we have "!event_budgetAllocations.containsKey(eventId)" condition satisfied
                        } else if (bas.size() == 1) {
                            // One Budget Allocations is found
                            String costCenterName_ba = bas[0].Cost_Center_gne__c;
                            List<TransactionWrapper> twList = transactionsWOErrors.get(travelNameInCSV);

                            for (TransactionWrapper twRecord : twList) {
                                String costCenterName_tr = twRecord.costCenter;
                                if (costCenterName_tr == costCenterName_ba) {
                                    TransactionWrapper newRecord_Transactions = twRecord.cloneRecord();
                                    newRecord_Transactions.recordID = generateUniqueID();
                                    recordsToAddInEMSTransactions.add(newRecord_Transactions);

                                    allTransactions.put(newRecord_Transactions.recordID, allTransactions.get(twRecord.recordID));
                                    allTransactions.remove(twRecord.recordID);
                                } else {
                                    // When System finds a valid T# with mismatched/missing Cost Centre(s) associated to the event
                                    // Add a comment to a record that goes to "Errors" section
                                    TransactionWrapper newRecord_AnomaliesAndError = twRecord.cloneRecord();
                                    newRecord_AnomaliesAndError.recordID = generateUniqueID();
                                    newRecord_AnomaliesAndError.setComment(commentCostCenterCorrection);
                                    recordsToAddInEMSAnomaliesAndErrors.add(newRecord_AnomaliesAndError);

                                    // Change Cost Center for record that goes to "EMS Transactions" section
                                    TransactionWrapper newRecord_Transactions = twRecord.cloneRecord();
                                    newRecord_Transactions.recordID = generateUniqueID();
                                    newRecord_Transactions.costCenter = costCenterName_ba;
                                    recordsToAddInEMSTransactions.add(newRecord_Transactions);

                                    allTransactions.put(newRecord_Transactions.recordID, allTransactions.get(twRecord.recordID));
                                    allTransactions.put(newRecord_AnomaliesAndError.recordID, allTransactions.get(twRecord.recordID));
                                    allTransactions.remove(twRecord.recordID);
                                }
                            }
                        } else {
                            // Two or more Budget Allocations are found
                            // Point 1.4.4c
                            // create cost centre split based on as many extra records are needed for the T number
                            Map<String, Decimal> costCenterName_amountPercentage = new Map<String, Decimal>();
                            for (EMS_Budget_Allocation_gne__c ba : bas) {
                                if (costCenterName_amountPercentage.containsKey(ba.Cost_Center_gne__c)) {
                                    // Summing Percentages for a single Cost Center
                                    Decimal currentPercentage = costCenterName_amountPercentage.get(ba.Cost_Center_gne__c);
                                    costCenterName_amountPercentage.put(ba.Cost_Center_gne__c, ba.Percentage_Contribution_gne__c + currentPercentage);
                                } else {
                                    costCenterName_amountPercentage.put(ba.Cost_Center_gne__c, ba.Percentage_Contribution_gne__c);
                                }
                            }

                            List<TransactionWrapper> twList = transactionsWOErrors.get(travelNameInCSV);
                            Decimal sumPercentages = evendID_sumPercentages.get(eventID);
                            if (sumPercentages == 0) {
                                continue; // Should not exist
                            }
                            if (costCenterName_amountPercentage.size() == 1) {
                                // There is one Cost Center for all Budget Allocations linked to Event
                                String costCenterName_ba = (new List<string>(costCenterName_amountPercentage.keySet()))[0];
                                Decimal amountPercentage = costCenterName_amountPercentage.get(costCenterName_ba);
                                for (TransactionWrapper twRecord : twList) {
                                    String costCenterName_tr = twRecord.costCenter;
                                    if (costCenterName_ba == costCenterName_tr) {
                                        TransactionWrapper newRecord_Transactions = twRecord.cloneRecord();
                                        newRecord_Transactions.recordID = generateUniqueID();
                                        newRecord_Transactions.amount = (twRecord.amount * (amountPercentage / sumPercentages)).setScale(2);
                                        recordsToAddInEMSTransactions.add(newRecord_Transactions);

                                        allTransactions.put(newRecord_Transactions.recordID, allTransactions.get(twRecord.recordID));
                                        allTransactions.remove(twRecord.recordID);
                                    } else {
                                        // Add a comment to a record that goes to "Errors" section
                                        TransactionWrapper newRecord_AnomaliesAndError = twRecord.cloneRecord();
                                        newRecord_AnomaliesAndError.recordID = generateUniqueID();
                                        newRecord_AnomaliesAndError.setComment(commentCostCenterCorrection);
                                        recordsToAddInEMSAnomaliesAndErrors.add(newRecord_AnomaliesAndError);

                                        // Add to "EMS Transactions"
                                        TransactionWrapper newRecord_Transactions = twRecord.cloneRecord();
                                        newRecord_Transactions.recordID = generateUniqueID();
                                        newRecord_Transactions.costCenter = costCenterName_ba;
                                        newRecord_Transactions.amount = (twRecord.amount * (amountPercentage / sumPercentages)).setScale(2);
                                        recordsToAddInEMSTransactions.add(newRecord_Transactions);

                                        allTransactions.put(newRecord_AnomaliesAndError.recordID, allTransactions.get(twRecord.recordID));
                                        allTransactions.put(newRecord_Transactions.recordID, allTransactions.get(twRecord.recordID));
                                        allTransactions.remove(twRecord.recordID);
                                    }
                                }
                            } else {
                                // Split on between Budget Allocations which have different cost centers
                                for (TransactionWrapper twRecord : twList) {
                                    String costCenterName_tr = twRecord.costCenter;
                                    Decimal amount = twRecord.amount;
                                    Boolean errorIsDefined = false;
                                    Integer counter = 1;
                                    Decimal sumAmount = 0;

                                    List<TransactionWrapper> twListWithErrors = new List<TransactionWrapper>();
                                    for (String costCenterName : costCenterName_amountPercentage.keySet()) {
                                        Decimal amountPercentage = costCenterName_amountPercentage.get(costCenterName);
                                        Decimal splittedAmount = amount * (amountPercentage / sumPercentages);

                                        Boolean theLastElement = (costCenterName_amountPercentage.size() == counter);

                                        if (costCenterName == costCenterName_tr) {
                                            if (errorIsDefined == false) {
                                                TransactionWrapper newRecord_AnomaliesAndError = twRecord.cloneRecord();
                                                newRecord_AnomaliesAndError.recordID = generateUniqueID();
                                                newRecord_AnomaliesAndError.setComment(commentBudgetSplitCorrection);
                                                twListWithErrors.add(newRecord_AnomaliesAndError);
                                                allTransactions.put(newRecord_AnomaliesAndError.recordID, allTransactions.get(twRecord.recordID));
                                                errorIsDefined = true;
                                            }

                                            TransactionWrapper newRecord_Transactions = twRecord.cloneRecord();
                                            if (theLastElement) {
                                                newRecord_Transactions.amount = amount - sumAmount;
                                            } else {
                                                newRecord_Transactions.amount = splittedAmount.setScale(2);
                                                sumAmount += splittedAmount.setScale(2);
                                            }
                                            newRecord_Transactions.recordID = generateUniqueID();
                                            recordsToAddInEMSTransactions.add(newRecord_Transactions);

                                            allTransactions.put(newRecord_Transactions.recordID, allTransactions.get(twRecord.recordID));
                                        } else {
                                            if (errorIsDefined == false) {
                                                TransactionWrapper newRecord_AnomaliesAndError = twRecord.cloneRecord();
                                                newRecord_AnomaliesAndError.recordID = generateUniqueID();

                                                // if costCenterName_tr value is included in CC from BAs then the comment should be the following
                                                if (costCenterName_amountPercentage.containsKey(costCenterName_tr)) {
                                                    newRecord_AnomaliesAndError.setComment(commentBudgetSplitCorrection);
                                                } else {
                                                    newRecord_AnomaliesAndError.setComment(commentCostCenterCorrection);
                                                }
                                                twListWithErrors.add(newRecord_AnomaliesAndError);
                                                allTransactions.put(newRecord_AnomaliesAndError.recordID, allTransactions.get(twRecord.recordID));
                                                errorIsDefined = true;
                                            }

                                            TransactionWrapper newRecord_Transactions = twRecord.cloneRecord();
                                            newRecord_Transactions.recordID = generateUniqueID();
                                            newRecord_Transactions.costCenter = costCenterName;
                                            if (theLastElement) {
                                                newRecord_Transactions.amount = amount - sumAmount;
                                            } else {
                                                newRecord_Transactions.amount = splittedAmount.setScale(2);
                                                sumAmount += splittedAmount.setScale(2);
                                            }
                                            recordsToAddInEMSTransactions.add(newRecord_Transactions);

                                            allTransactions.put(newRecord_Transactions.recordID, allTransactions.get(twRecord.recordID));
                                        }
                                        counter++;
                                    }

                                    if (!twListWithErrors.isEmpty()) {
                                        recordsToAddInEMSAnomaliesAndErrors.addAll(twListWithErrors);
                                    }
                                    allTransactions.remove(twRecord.recordID);
                                }
                            }
                        }
                    } else {
                        // System is unable to find a budget allocation associated to the event, yet a T# has been created
                        List<TransactionWrapper> twList = transactionsWOErrors.get(travelNameInCSV);
                        for (TransactionWrapper twRecord : twList) {
                            TransactionWrapper newRecord_AnomaliesAndError = twRecord.cloneRecord();
                            newRecord_AnomaliesAndError.recordID = generateUniqueID();
                            newRecord_AnomaliesAndError.setComment(commentCostCenterIncorrect);
                            recordsToAddInEMSAnomaliesAndErrors.add(newRecord_AnomaliesAndError);

                            // Add to "EMS Transactions"
                            TransactionWrapper newRecord_Transactions = twRecord.cloneRecord();
                            newRecord_Transactions.recordID = generateUniqueID();
                            recordsToAddInEMSTransactions.add(newRecord_Transactions);

                            allTransactions.put(newRecord_AnomaliesAndError.recordID, allTransactions.get(twRecord.recordID));
                            allTransactions.put(newRecord_Transactions.recordID, allTransactions.get(twRecord.recordID));
                            allTransactions.remove(twRecord.recordID);
                        }
                    }
                } else {
                    // When the Travel ID is not found in EMS, the record should go to "Anomalies and Errors" section
                    // AND to "EMS Transactions" sections

                    // When System is unable to match a T# with EMS Data
                    List<TransactionWrapper> twList = transactionsWOErrors.get(travelNameInCSV);
                    for (TransactionWrapper twRecord : twList) {
                        TransactionWrapper newRecord_AnomaliesAndError = twRecord.cloneRecord();
                        newRecord_AnomaliesAndError.recordID = generateUniqueID();
                        newRecord_AnomaliesAndError.setComment(commentTravelIncorrect);
                        recordsToAddInEMSAnomaliesAndErrors.add(newRecord_AnomaliesAndError);

                        TransactionWrapper newRecord_Transactions = twRecord.cloneRecord();
                        newRecord_Transactions.recordID = generateUniqueID();
                        newRecord_Transactions.amount = twRecord.amount;
                        newRecord_Transactions.costCenter = twRecord.costCenter;
                        recordsToAddInEMSTransactions.add(newRecord_Transactions);

                        allTransactions.put(newRecord_AnomaliesAndError.recordID, allTransactions.get(twRecord.recordID));
                        allTransactions.put(newRecord_Transactions.recordID, allTransactions.get(twRecord.recordID));
                        allTransactions.remove(twRecord.recordID);
                    }
                }
            }
            if (!recordsToAddInEMSAnomaliesAndErrors.isEmpty()) {
                correctDataRow(recordsToAddInEMSAnomaliesAndErrors);
                anomaliesAndErrors.addAll(recordsToAddInEMSAnomaliesAndErrors);
            }
            if (!recordsToAddInEMSTransactions.isEmpty()) {
                correctDataRow(recordsToAddInEMSTransactions);
                emsTransactions.addAll(recordsToAddInEMSTransactions);
            }

            isFileUploaded = true;
        } catch (CustomLimitException e) {
            clearAllCollections();
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage());
            ApexPages.addMessage(errorMessage);
        } catch (Exception e) {
            clearAllCollections();
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, 'An error has occured while importing data Please make sure input csv file is correct. Exception: ' + e.getMessage());
            ApexPages.addMessage(errorMessage);
        }
    }

    private void correctDataRow(List<TransactionWrapper> twList) {
        for (TransactionWrapper twRecord : twList) {
            String dataRow = allTransactions.get(twRecord.recordID);
            List<String> dataRowValues = dataRow.split(',');
            dataRowValues[headersMap.get('cost center')] = twRecord.costCenter;
            dataRowValues[headersMap.get('amount')] = String.valueOf(twRecord.amount);

            Set<String> localesToCheck = new Set<String>{
                    'en_CA',
                    'en_US'
            };
            if (localesToCheck.contains(UserInfo.getLocale())) {
                // Perform some checking

                String dateString = dataRowValues[headersMap.get('posting date')];
                Date theDate;
                try {
                    // parse works in the case of mm/dd/yyyy
                    theDate = Date.parse(dateString);
                } catch (Exception e) {
                    ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR, 'An error has occured while importing data. Please make sure input csv date values are correct. Exception: ' + e.getMessage());
                    ApexPages.addMessage(errorMessage);
                }
            }

            String changedDataRow = String.join(dataRowValues, ',');
            allTransactions.put(twRecord.recordID, changedDataRow);
        }
    }

    private Integer generateUniqueID() {
        if (uniqueIDcontainer.size() == 0) {
            uniqueIDcontainer.add(1);
            return 1;
        } else {
            Integer lastIndex = uniqueIDcontainer.size() - 1;
            Integer newID = (new List<Integer>(uniqueIDcontainer))[lastIndex] + 1;
            uniqueIDcontainer.add(newID);
            return newID;
        }
    }

    public class CustomLimitException extends Exception {
    }


    public class TransactionWrapper {
        public String travelID { get; private set; }
        public String hcp { get; private set; }
        public String costCenter { get; private set; }
        public String costElement { get; private set; }
        public Decimal amount { get; private set; }
        public Integer recordID { get; private set; }
        public String comment { get; private set; }
        public String travelerType { get; private set; }
        public String ticketID { get; private set; }

        public TransactionWrapper(String travelID, String hcp, String costCenter, String costElement, Decimal amount, String travelerType, String ticketID, Integer recordID) {
            this.travelID = travelID;
            this.hcp = hcp;
            this.costCenter = costCenter;
            this.costElement = costElement;
            this.amount = amount;
            this.recordID = recordID;
            this.travelerType = travelerType;
            this.ticketID = ticketID;
        }

        public TransactionWrapper cloneRecord() {
            TransactionWrapper newRecord = new TransactionWrapper(
                    this.travelID,
                    this.hcp,
                    this.costCenter,
                    this.costElement,
                    this.amount,
                    this.travelerType,
                    this.ticketID,
                    null
            );
            return newRecord;
        }

        public void setComment(String comment) {
            this.comment = comment;
        }
    }


    public class LimitWrapper {
        public Set<Integer> IDs { get; set; }
        public Integer blockNumber { get; set; }

        public LimitWrapper(Set<Integer> IDs, Integer i) {
            this.IDs = IDs;
            blockNumber = i;
        }
    }

    public with sharing class Utility_RowIterator implements Iterator<String>, Iterable<String> {
        private String m_Data;
        private Integer m_index = 0;
        private String m_rowDelimiter = '\n';

        public Utility_RowIterator(String fileData) {
            m_Data = fileData;
        }

        public Utility_RowIterator(String fileData, String rowDelimiter) {
            m_Data = fileData;
            m_rowDelimiter = rowDelimiter;
        }

        public Boolean hasNext() {
            return m_index < m_Data.length() ? true : false;
        }

        public String next() {
            Integer key = m_Data.indexOf(m_rowDelimiter, m_index);

            if (key == -1) {
                key = m_Data.length();
            }

            String row = m_Data.subString(m_index, key);
            m_index = key + 1;
            return row;
        }

        public Iterator<String> Iterator() {
            return this;
        }
    }
}