@isTest
private class EMS_BCD_Data_Processor_Test {

    // When the Travel ID is not found in EMS, the record should go to "Anomalies and Errors" section
    @isTest static void publishAnomaliesAndErrors_test() {
        String myData = 'Invoice Date,Currency,Invoice,Header Text,Text,Posting Key,Vendor Number,Total Invoice,Tax,Calculate Tax,Tax Code,Payment Method,Assignment,Line Item Text,Posting Key 1,GL Code,Amount,Tax1,Jurisdiction,Cost Center,Order,Project,Profit Center,Posting Date,Reference,Ticket,Charge Date,Charge Description,Employee ID,Air Ticket Issuer,Air Routing,Class of Service,Transaction Type,Air Departure Date,Air Passenger Name,Federal Tax ID,Event ID/EMS,Traveler Type,Booker Name\n08/03/2015,CAD,CITI AUG,CITIBANK AUG2015,XXXXXXXXXXX24820,31,90304036,325532.05,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n,,,,,,,,,,,,,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015,40,41811618,45,,,807220,,,,03/10/2015,XXXXXXXXXXX24820,67417477,02/04/2015,,505569,IATA,YEG YYZ YOW YEG YYC,ECONOMY,ORIGINAL,02/09/2015,²&éèçà$ù€§µ° CAMPBELL  ALANA,,T0000000601,HCP,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015\n,,,,,,,,,,,,,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015,40,41811618,45,,,807220,,,,03/10/2015,XXXXXXXXXXX24820,67419215,02/04/2015,,505569,IATA,YEG YYZ YOW YEG YYC,ECONOMY,ORIGINAL,02/09/2015,²&éèçà$ù€§µ° CAMPBELL  ALANA,,,HCP,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015\n,,,,,,,,,,,,,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015,40,41811618,276.52,,,807220,,,,03/10/2015,XXXXXXXXXXX24820,6774124707,02/04/2015,,505569,AIR CANADA,YEG YYZ YOW YEG YYC,ECONOMY,EXCHANGE,02/09/2015,²&éèçà$ù€§µ° CAMPBELL  ALANA,,ABCD DBCA,HCP,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015\n,,,,,,,,,,,,,GST/HST Taxes,40,11221120, 11234.15 ,,,,,,,08/06/2015,,,,,,,,,,,,,,,\n,,,,,,,,,,,,,QST Taxes,40,11221140, 1095.76 ,,,,,,,08/06/2015,,,,,,,,,,,,,,,';
        Blob myFile = Blob.valueof(myData);

        Test.startTest();
        EMS_BCD_Data_Processor ctrl = new EMS_BCD_Data_Processor();
        ctrl.csvFileBody = myFile;
        ctrl.publish();

        // errors section - xls
        ctrl.sectionToExport = 'errors';
        ctrl.exportType = 'xls';
        PageReference exportPage = ctrl.openExportPage();
        System.assertEquals(ctrl.fileName, 'EMS Anomalies and Errors - ' + DateTime.now().format('MM/dd/yyyy'));

        Test.setCurrentPage(exportPage);
        System.assert(exportPage.getUrl().contains('/apex/EMS_BCD_Data_ExportXLS'));
        ctrl.prepareData();

        Test.stopTest();
    }

    @isTest static void publishAll_test() {
        String myData = 'Invoice Date,Currency,Invoice,Header Text,Text,Posting Key,Vendor Number,Total Invoice,Tax,Calculate Tax,Tax Code,Payment Method,Assignment,Line Item Text,Posting Key 1,GL Code,Amount,Tax1,Jurisdiction,Cost Center,Order,Project,Profit Center,Posting Date,Reference,Ticket,Charge Date,Charge Description,Employee ID,Air Ticket Issuer,Air Routing,Class of Service,Transaction Type,Air Departure Date,Air Passenger Name,Federal Tax ID,Event ID/EMS,Traveler Type,Booker Name\n08/03/2015,CAD,CITI AUG,CITIBANK AUG2015,XXXXXXXXXXX24820,31,90304036,325532.05,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n,,,,,,,,,,,,,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015,40,41811618,45,,,807220,,,,03/10/2015,XXXXXXXXXXX24820,67417477,02/04/2015,,505569,IATA,YEG YYZ YOW YEG YYC,ECONOMY,ORIGINAL,02/09/2015,²&éèçà$ù€§µ° CAMPBELL  ALANA,,T0000000601,HCP,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015\n,,,,,,,,,,,,,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015,40,41811618,45,,,807220,,,,03/10/2015,XXXXXXXXXXX24820,67419215,02/04/2015,,505569,IATA,YEG YYZ YOW YEG YYC,ECONOMY,ORIGINAL,02/09/2015,²&éèçà$ù€§µ° CAMPBELL  ALANA,,,HCP,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015\n,,,,,,,,,,,,,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015,40,41811618,276.52,,,807220,,,,03/10/2015,XXXXXXXXXXX24820,6774124707,02/04/2015,,505569,AIR CANADA,YEG YYZ YOW YEG YYC,ECONOMY,EXCHANGE,02/09/2015,²&éèçà$ù€§µ° CAMPBELL  ALANA,,ABCD DBCA,HCP,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015\n,,,,,,,,,,,,,GST/HST Taxes,40,11221120, 11234.15 ,,,,,,,08/06/2015,,,,,,,,,,,,,,,\n,,,,,,,,,,,,,QST Taxes,40,11221140, 1095.76 ,,,,,,,08/06/2015,,,,,,,,,,,,,,,';
        Blob myFile = Blob.valueof(myData);

        Test.startTest();
        EMS_BCD_Data_Processor ctrl = new EMS_BCD_Data_Processor();
        ctrl.csvFileBody = myFile;
        ctrl.publish();

        // Publish All
        ctrl.sectionToExport = 'allwoerrors';
        ctrl.exportType = 'csv';
        PageReference exportPage = ctrl.openExportPage();
        System.assertEquals(ctrl.fileName, 'All - ' + DateTime.now().format('MM/dd/yyyy'));

        Test.setCurrentPage(exportPage);
        System.assert(exportPage.getUrl().contains('/apex/EMS_BCD_Data_ExportCSV'));
        ctrl.prepareData();

        Test.stopTest();
    }

    @isTest static void publishTrasactions_onebudget_ccisnotok_test() {
        String etype = 'Consulting Meetings';
        String esubtype = 'Informal consulting';
        Decimal amount = 100;

        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        System.assertNotEquals(null, pmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', 1, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        // Product budget
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createMultipleProductBudgets(0, amount * 10, pmUser, costCenters)[0];
        // Event
        EMS_Event__c event = EMS_Test_Util.createEvents('Unplanned', pmUser, etype, esubtype, Date.today() + 1, Date.today() + 3, amount * 2, 1)[0];
        // Budgets
        EMS_Budget_Allocation_gne__c ba1 = new EMS_Budget_Allocation_gne__c(
                Allocated_Budget_gne__c = amount * (0.546),
                Percentage_Contribution_gne__c = 1,
                Budget_Deductions_gne__c = 0,
                EMS_Event_gne__c = event.Id,
                RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                EMS_Product_Budget_gne__c = pb.Id
        );
        insert ba1;
        // Travel
        EMS_Travel_gne__c travel = new EMS_Travel_gne__c(EMS_Event_gne__c = event.Id);
        insert travel;
        travel = [SELECT Name, EMS_Event_gne__c FROM EMS_Travel_gne__c WHERE Id = :travel.Id LIMIT 1];

        String myData =
                'Invoice Date,Currency,Invoice,Header Text,Text,Posting Key,Vendor Number,Total Invoice,Tax,Calculate Tax,Tax Code,Payment Method,Assignment,Line Item Text,Posting Key 1,GL Code,Amount,Tax1,Jurisdiction,Cost Center,Order,Project,Profit Center,Posting Date,Reference,Ticket,Charge Date,Charge Description,Employee ID,Air Ticket Issuer,Air Routing,Class of Service,Transaction Type,Air Departure Date,Air Passenger Name,Federal Tax ID,Event ID/EMS,Traveler Type,Booker Name\n' +
                        '08/03/2015,CAD,CITI AUG,CITIBANK AUG2015,XXXXXXXXXXX24820,31,90304036,325532.05,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n' +
                        ',,,,,,,,,,,,,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015,40,41811618,45,,,807220,,,,03/10/2015,XXXXXXXXXXX24820,67417477,02/04/2015,,505569,IATA,YEG YYZ YOW YEG YYC,ECONOMY,ORIGINAL,02/09/2015,²&éèçà$ù€§µ° CAMPBELL  ALANA,,' + travel.Name + ',HCP,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015\n' +
                        ',,,,,,,,,,,,,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015,40,41811618,45,,,807220,,,,03/10/2015,XXXXXXXXXXX24820,67419215,02/04/2015,,505569,IATA,YEG YYZ YOW YEG YYC,ECONOMY,ORIGINAL,02/09/2015,²&éèçà$ù€§µ° CAMPBELL  ALANA,,,HCP,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015\n' +
                        ',,,,,,,,,,,,,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015,40,41811618,276.52,,,807220,,,,03/10/2015,XXXXXXXXXXX24820,6774124707,02/04/2015,,505569,AIR CANADA,YEG YYZ YOW YEG YYC,ECONOMY,EXCHANGE,02/09/2015,²&éèçà$ù€§µ° CAMPBELL  ALANA,,ABCD DBCA,HCP,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015\n' +
                        ',,,,,,,,,,,,,GST/HST Taxes,40,11221120, 11234.15 ,,,,,,,08/06/2015,,,,,,,,,,,,,,,\n' +
                        ',,,,,,,,,,,,,QST Taxes,40,11221140, 1095.76 ,,,,,,,08/06/2015,,,,,,,,,,,,,,,';
        Blob myFile = Blob.valueof(myData);


        Test.startTest();
        EMS_BCD_Data_Processor ctrl = new EMS_BCD_Data_Processor();
        ctrl.csvFileBody = myFile;
        ctrl.publish();

        // Publish All
        ctrl.sectionToExport = 'transactions';
        ctrl.exportType = 'xls';
        PageReference exportPage = ctrl.openExportPage();
        System.assertEquals(ctrl.fileName, 'EMS Transactions - ' + DateTime.now().format('MM/dd/yyyy'));

        Test.setCurrentPage(exportPage);
        System.assert(exportPage.getUrl().contains('/apex/EMS_BCD_Data_ExportXLS'));
        ctrl.prepareData();

        Test.stopTest();
    }

    @isTest static void publishTrasactions_onebudget_ccisok_test() {
        String etype = 'Consulting Meetings';
        String esubtype = 'Informal consulting';
        Decimal amount = 100;

        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        System.assertNotEquals(null, pmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', 1, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        // Product budget
        EMS_Budget_Product_gne__c pb = EMS_Test_Util.createMultipleProductBudgets(0, amount * 10, pmUser, costCenters)[0];
        // Event
        EMS_Event__c event = EMS_Test_Util.createEvents('Unplanned', pmUser, etype, esubtype, Date.today() + 1, Date.today() + 3, amount * 2, 1)[0];
        // Budgets
        EMS_Budget_Allocation_gne__c ba1 = new EMS_Budget_Allocation_gne__c(
                Allocated_Budget_gne__c = amount * (0.546),
                Percentage_Contribution_gne__c = 1,
                Budget_Deductions_gne__c = 0,
                EMS_Event_gne__c = event.Id,
                RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                EMS_Product_Budget_gne__c = pb.Id,
                Cost_Center_gne__c = costCenters[0].Name
        );
        insert ba1;
        // Travel
        EMS_Travel_gne__c travel = new EMS_Travel_gne__c(EMS_Event_gne__c = event.Id);
        insert travel;
        travel = [SELECT Name, EMS_Event_gne__c FROM EMS_Travel_gne__c WHERE Id = :travel.Id LIMIT 1];

        String myData =
                'Invoice Date,Currency,Invoice,Header Text,Text,Posting Key,Vendor Number,Total Invoice,Tax,Calculate Tax,Tax Code,Payment Method,Assignment,Line Item Text,Posting Key 1,GL Code,Amount,Tax1,Jurisdiction,Cost Center,Order,Project,Profit Center,Posting Date,Reference,Ticket,Charge Date,Charge Description,Employee ID,Air Ticket Issuer,Air Routing,Class of Service,Transaction Type,Air Departure Date,Air Passenger Name,Federal Tax ID,Event ID/EMS,Traveler Type,Booker Name\n' +
                        '08/03/2015,CAD,CITI AUG,CITIBANK AUG2015,XXXXXXXXXXX24820,31,90304036,325532.05,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n' +
                        ',,,,,,,,,,,,,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015,40,41811618,45,,,' + ba1.Cost_Center_gne__c + ',,,,03/10/2015,XXXXXXXXXXX24820,67417477,02/04/2015,,505569,IATA,YEG YYZ YOW YEG YYC,ECONOMY,ORIGINAL,02/09/2015,²&éèçà$ù€§µ° CAMPBELL  ALANA,,' + travel.Name + ',HCP,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015\n' +
                        ',,,,,,,,,,,,,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015,40,41811618,45,,,' + ba1.Cost_Center_gne__c + ',,,,03/10/2015,XXXXXXXXXXX24820,67419215,02/04/2015,,505569,IATA,YEG YYZ YOW YEG YYC,ECONOMY,ORIGINAL,02/09/2015,²&éèçà$ù€§µ° CAMPBELL  ALANA,,,HCP,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015\n' +
                        ',,,,,,,,,,,,,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015,40,41811618,276.52,,,' + ba1.Cost_Center_gne__c + ',,,,03/10/2015,XXXXXXXXXXX24820,6774124707,02/04/2015,,505569,AIR CANADA,YEG YYZ YOW YEG YYC,ECONOMY,EXCHANGE,02/09/2015,²&éèçà$ù€§µ° CAMPBELL  ALANA,,ABCD DBCA,HCP,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015\n' +
                        ',,,,,,,,,,,,,GST/HST Taxes,40,11221120, 11234.15 ,,,,,,,08/06/2015,,,,,,,,,,,,,,,\n' +
                        ',,,,,,,,,,,,,QST Taxes,40,11221140, 1095.76 ,,,,,,,08/06/2015,,,,,,,,,,,,,,,';
        Blob myFile = Blob.valueof(myData);


        Test.startTest();
        EMS_BCD_Data_Processor ctrl = new EMS_BCD_Data_Processor();
        ctrl.csvFileBody = myFile;
        ctrl.publish();

        // Publish All
        ctrl.sectionToExport = 'transactions';
        ctrl.exportType = 'xls';
        PageReference exportPage = ctrl.openExportPage();
        System.assertEquals(ctrl.fileName, 'EMS Transactions - ' + DateTime.now().format('MM/dd/yyyy'));

        Test.setCurrentPage(exportPage);
        System.assert(exportPage.getUrl().contains('/apex/EMS_BCD_Data_ExportXLS'));
        ctrl.prepareData();

        Test.stopTest();
    }


    @isTest static void publishTrasactions_twobudgets_difcostcenters_test() {
        String etype = 'Consulting Meetings';
        String esubtype = 'Informal consulting';
        Decimal amount = 100;

        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        System.assertNotEquals(null, pmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', 2, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        // Product budget
        List<EMS_Budget_Product_gne__c> pbs = EMS_Test_Util.createMultipleProductBudgets(0, amount * 10, pmUser, costCenters);
        // Event
        EMS_Event__c event = EMS_Test_Util.createEvents('Unplanned', pmUser, etype, esubtype, Date.today() + 1, Date.today() + 3, amount * 2, 1)[0];
        // Budgets
        EMS_Budget_Allocation_gne__c ba1 = new EMS_Budget_Allocation_gne__c(
                Allocated_Budget_gne__c = amount * (0.546),
                Percentage_Contribution_gne__c = 1,
                Budget_Deductions_gne__c = 0,
                EMS_Event_gne__c = event.Id,
                RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                EMS_Product_Budget_gne__c = pbs[0].Id,
                Cost_Center_gne__c = costCenters[0].Name
        );
        EMS_Budget_Allocation_gne__c ba2 = new EMS_Budget_Allocation_gne__c(
                Allocated_Budget_gne__c = amount * (1 - 0.546),
                Percentage_Contribution_gne__c = 1,
                Budget_Deductions_gne__c = 0,
                EMS_Event_gne__c = event.Id,
                RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                EMS_Product_Budget_gne__c = pbs[1].Id,
                Cost_Center_gne__c = costCenters[1].Name
        );
        insert new List<EMS_Budget_Allocation_gne__c>{
                ba1, ba2
        };
        // Travel
        EMS_Travel_gne__c travel = new EMS_Travel_gne__c(EMS_Event_gne__c = event.Id);
        insert travel;
        travel = [SELECT Name, EMS_Event_gne__c FROM EMS_Travel_gne__c WHERE Id = :travel.Id LIMIT 1];

        String myData =
                'Invoice Date,Currency,Invoice,Header Text,Text,Posting Key,Vendor Number,Total Invoice,Tax,Calculate Tax,Tax Code,Payment Method,Assignment,Line Item Text,Posting Key 1,GL Code,Amount,Tax1,Jurisdiction,Cost Center,Order,Project,Profit Center,Posting Date,Reference,Ticket,Charge Date,Charge Description,Employee ID,Air Ticket Issuer,Air Routing,Class of Service,Transaction Type,Air Departure Date,Air Passenger Name,Federal Tax ID,Event ID/EMS,Traveler Type,Booker Name\n' +
                        '08/03/2015,CAD,CITI AUG,CITIBANK AUG2015,XXXXXXXXXXX24820,31,90304036,325532.05,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n' +
                        ',,,,,,,,,,,,,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015,40,41811618,45,,,' + ba1.Cost_Center_gne__c + ',,,,03/10/2015,XXXXXXXXXXX24820,67417477,02/04/2015,,505569,IATA,YEG YYZ YOW YEG YYC,ECONOMY,ORIGINAL,02/09/2015,²&éèçà$ù€§µ° CAMPBELL  ALANA,,' + travel.Name + ',HCP,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015\n' +
                        ',,,,,,,,,,,,,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015,40,41811618,45,,,' + ba1.Cost_Center_gne__c + ',,,,03/10/2015,XXXXXXXXXXX24820,67419215,02/04/2015,,505569,IATA,YEG YYZ YOW YEG YYC,ECONOMY,ORIGINAL,02/09/2015,²&éèçà$ù€§µ° CAMPBELL  ALANA,,,HCP,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015\n' +
                        ',,,,,,,,,,,,,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015,40,41811618,276.52,,,' + ba1.Cost_Center_gne__c + ',,,,03/10/2015,XXXXXXXXXXX24820,6774124707,02/04/2015,,505569,AIR CANADA,YEG YYZ YOW YEG YYC,ECONOMY,EXCHANGE,02/09/2015,²&éèçà$ù€§µ° CAMPBELL  ALANA,,ABCD DBCA,HCP,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015\n' +
                        ',,,,,,,,,,,,,GST/HST Taxes,40,11221120, 11234.15 ,,,,,,,08/06/2015,,,,,,,,,,,,,,,\n' +
                        ',,,,,,,,,,,,,QST Taxes,40,11221140, 1095.76 ,,,,,,,08/06/2015,,,,,,,,,,,,,,,';
        Blob myFile = Blob.valueof(myData);


        Test.startTest();
        EMS_BCD_Data_Processor ctrl = new EMS_BCD_Data_Processor();
        ctrl.csvFileBody = myFile;
        ctrl.publish();

        // Publish All
        ctrl.sectionToExport = 'transactions';
        ctrl.exportType = 'xls';
        PageReference exportPage = ctrl.openExportPage();
        System.assertEquals(ctrl.fileName, 'EMS Transactions - ' + DateTime.now().format('MM/dd/yyyy'));

        Test.setCurrentPage(exportPage);
        System.assert(exportPage.getUrl().contains('/apex/EMS_BCD_Data_ExportXLS'));
        ctrl.prepareData();

        Test.stopTest();
    }

    @isTest static void publishTrasactions_twobudgets_samecostcenters_test() {
        String etype = 'Consulting Meetings';
        String esubtype = 'Informal consulting';
        Decimal amount = 100;

        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        System.assertNotEquals(null, pmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', 1, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        // Product budget
        List<EMS_Budget_Product_gne__c> pbs = EMS_Test_Util.createMultipleProductBudgets(0, amount * 10, pmUser, costCenters);
        // Event
        EMS_Event__c event = EMS_Test_Util.createEvents('Unplanned', pmUser, etype, esubtype, Date.today() + 1, Date.today() + 3, amount * 2, 1)[0];
        // Budgets
        EMS_Budget_Allocation_gne__c ba1 = new EMS_Budget_Allocation_gne__c(
                Allocated_Budget_gne__c = amount * (0.546),
                Percentage_Contribution_gne__c = 1,
                Budget_Deductions_gne__c = 0,
                EMS_Event_gne__c = event.Id,
                RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                EMS_Product_Budget_gne__c = pbs[0].Id,
                Cost_Center_gne__c = costCenters[0].Name
        );
        EMS_Budget_Allocation_gne__c ba2 = new EMS_Budget_Allocation_gne__c(
                Allocated_Budget_gne__c = amount * (1 - 0.546),
                Percentage_Contribution_gne__c = 1,
                Budget_Deductions_gne__c = 0,
                EMS_Event_gne__c = event.Id,
                RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                EMS_Product_Budget_gne__c = pbs[0].Id,
                Cost_Center_gne__c = costCenters[0].Name
        );
        insert new List<EMS_Budget_Allocation_gne__c>{
                ba1, ba2
        };
        // Travel
        EMS_Travel_gne__c travel = new EMS_Travel_gne__c(EMS_Event_gne__c = event.Id);
        insert travel;
        travel = [SELECT Name, EMS_Event_gne__c FROM EMS_Travel_gne__c WHERE Id = :travel.Id LIMIT 1];

        String myData =
                'Invoice Date,Currency,Invoice,Header Text,Text,Posting Key,Vendor Number,Total Invoice,Tax,Calculate Tax,Tax Code,Payment Method,Assignment,Line Item Text,Posting Key 1,GL Code,Amount,Tax1,Jurisdiction,Cost Center,Order,Project,Profit Center,Posting Date,Reference,Ticket,Charge Date,Charge Description,Employee ID,Air Ticket Issuer,Air Routing,Class of Service,Transaction Type,Air Departure Date,Air Passenger Name,Federal Tax ID,Event ID/EMS,Traveler Type,Booker Name\n' +
                        '08/03/2015,CAD,CITI AUG,CITIBANK AUG2015,XXXXXXXXXXX24820,31,90304036,325532.05,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n' +
                        ',,,,,,,,,,,,,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015,40,41811618,45,,,' + ba1.Cost_Center_gne__c + ',,,,03/10/2015,XXXXXXXXXXX24820,67417477,02/04/2015,,505569,IATA,YEG YYZ YOW YEG YYC,ECONOMY,ORIGINAL,02/09/2015,²&éèçà$ù€§µ° CAMPBELL  ALANA,,' + travel.Name + ',HCP,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015\n' +
                        ',,,,,,,,,,,,,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015,40,41811618,45,,,' + ba1.Cost_Center_gne__c + ',,,,03/10/2015,XXXXXXXXXXX24820,67419215,02/04/2015,,505569,IATA,YEG YYZ YOW YEG YYC,ECONOMY,ORIGINAL,02/09/2015,²&éèçà$ù€§µ° CAMPBELL  ALANA,,,HCP,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015\n' +
                        ',,,,,,,,,,,,,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015,40,41811618,276.52,,,' + ba1.Cost_Center_gne__c + ',,,,03/10/2015,XXXXXXXXXXX24820,6774124707,02/04/2015,,505569,AIR CANADA,YEG YYZ YOW YEG YYC,ECONOMY,EXCHANGE,02/09/2015,²&éèçà$ù€§µ° CAMPBELL  ALANA,,ABCD DBCA,HCP,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015\n' +
                        ',,,,,,,,,,,,,GST/HST Taxes,40,11221120, 11234.15 ,,,,,,,08/06/2015,,,,,,,,,,,,,,,\n' +
                        ',,,,,,,,,,,,,QST Taxes,40,11221140, 1095.76 ,,,,,,,08/06/2015,,,,,,,,,,,,,,,';
        Blob myFile = Blob.valueof(myData);


        Test.startTest();
        EMS_BCD_Data_Processor ctrl = new EMS_BCD_Data_Processor();
        ctrl.csvFileBody = myFile;
        ctrl.publish();

        // Publish All
        ctrl.sectionToExport = 'transactions';
        ctrl.exportType = 'xls';
        PageReference exportPage = ctrl.openExportPage();
        System.assertEquals(ctrl.fileName, 'EMS Transactions - ' + DateTime.now().format('MM/dd/yyyy'));

        Test.setCurrentPage(exportPage);
        System.assert(exportPage.getUrl().contains('/apex/EMS_BCD_Data_ExportXLS'));
        ctrl.prepareData();

        Test.stopTest();
    }

    @isTest static void publishTrasactions_twobudgets_filewithincorrectcc_test() {
        String etype = 'Consulting Meetings';
        String esubtype = 'Informal consulting';
        Decimal amount = 100;

        Id pmUser = EMS_Test_Util.findExistingUser('PM', null)[0];
        System.assertNotEquals(null, pmUser);

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Commercial Product', 1, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        // Product budget
        List<EMS_Budget_Product_gne__c> pbs = EMS_Test_Util.createMultipleProductBudgets(0, amount * 10, pmUser, costCenters);
        // Event
        EMS_Event__c event = EMS_Test_Util.createEvents('Unplanned', pmUser, etype, esubtype, Date.today() + 1, Date.today() + 3, amount * 2, 1)[0];
        // Budgets
        EMS_Budget_Allocation_gne__c ba1 = new EMS_Budget_Allocation_gne__c(
                Allocated_Budget_gne__c = amount * (0.546),
                Percentage_Contribution_gne__c = 1,
                Budget_Deductions_gne__c = 0,
                EMS_Event_gne__c = event.Id,
                RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                EMS_Product_Budget_gne__c = pbs[0].Id,
                Cost_Center_gne__c = costCenters[0].Name
        );
        EMS_Budget_Allocation_gne__c ba2 = new EMS_Budget_Allocation_gne__c(
                Allocated_Budget_gne__c = amount * (1 - 0.546),
                Percentage_Contribution_gne__c = 1,
                Budget_Deductions_gne__c = 0,
                EMS_Event_gne__c = event.Id,
                RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                EMS_Product_Budget_gne__c = pbs[0].Id,
                Cost_Center_gne__c = costCenters[0].Name
        );
        insert new List<EMS_Budget_Allocation_gne__c>{
                ba1, ba2
        };
        // Travel
        EMS_Travel_gne__c travel = new EMS_Travel_gne__c(EMS_Event_gne__c = event.Id);
        insert travel;
        travel = [SELECT Name, EMS_Event_gne__c FROM EMS_Travel_gne__c WHERE Id = :travel.Id LIMIT 1];

        String myData =
                'Invoice Date,Currency,Invoice,Header Text,Text,Posting Key,Vendor Number,Total Invoice,Tax,Calculate Tax,Tax Code,Payment Method,Assignment,Line Item Text,Posting Key 1,GL Code,Amount,Tax1,Jurisdiction,Cost Center,Order,Project,Profit Center,Posting Date,Reference,Ticket,Charge Date,Charge Description,Employee ID,Air Ticket Issuer,Air Routing,Class of Service,Transaction Type,Air Departure Date,Air Passenger Name,Federal Tax ID,Event ID/EMS,Traveler Type,Booker Name\n' +
                        '08/03/2015,CAD,CITI AUG,CITIBANK AUG2015,XXXXXXXXXXX24820,31,90304036,325532.05,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n' +
                        ',,,,,,,,,,,,,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015,40,41811618,45,,,807220,,,,03/10/2015,XXXXXXXXXXX24820,67417477,02/04/2015,,505569,IATA,YEG YYZ YOW YEG YYC,ECONOMY,ORIGINAL,02/09/2015,²&éèçà$ù€§µ° CAMPBELL  ALANA,,' + travel.Name + ',HCP,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015\n' +
                        ',,,,,,,,,,,,,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015,40,41811618,45,,,807220,,,,03/10/2015,XXXXXXXXXXX24820,67419215,02/04/2015,,505569,IATA,YEG YYZ YOW YEG YYC,ECONOMY,ORIGINAL,02/09/2015,²&éèçà$ù€§µ° CAMPBELL  ALANA,,,HCP,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015\n' +
                        ',,,,,,,,,,,,,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015,40,41811618,276.52,,,807220,,,,03/10/2015,XXXXXXXXXXX24820,6774124707,02/04/2015,,505569,AIR CANADA,YEG YYZ YOW YEG YYC,ECONOMY,EXCHANGE,02/09/2015,²&éèçà$ù€§µ° CAMPBELL  ALANA,,ABCD DBCA,HCP,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015\n' +
                        ',,,,,,,,,,,,,GST/HST Taxes,40,11221120, 11234.15 ,,,,,,,08/06/2015,,,,,,,,,,,,,,,\n' +
                        ',,,,,,,,,,,,,QST Taxes,40,11221140, 1095.76 ,,,,,,,08/06/2015,,,,,,,,,,,,,,,';
        Blob myFile = Blob.valueof(myData);


        Test.startTest();
        EMS_BCD_Data_Processor ctrl = new EMS_BCD_Data_Processor();
        ctrl.csvFileBody = myFile;
        ctrl.publish();

        // Publish All
        ctrl.sectionToExport = 'transactions';
        ctrl.exportType = 'xls';
        PageReference exportPage = ctrl.openExportPage();
        System.assertEquals(ctrl.fileName, 'EMS Transactions - ' + DateTime.now().format('MM/dd/yyyy'));

        Test.setCurrentPage(exportPage);
        System.assert(exportPage.getUrl().contains('/apex/EMS_BCD_Data_ExportXLS'));
        ctrl.prepareData();

        Test.stopTest();
    }

    @isTest static void publishNonemstransactions_test() {
        String myData = 'Invoice Date,Currency,Invoice,Header Text,Text,Posting Key,Vendor Number,Total Invoice,Tax,Calculate Tax,Tax Code,Payment Method,Assignment,Line Item Text,Posting Key 1,GL Code,Amount,Tax1,Jurisdiction,Cost Center,Order,Project,Profit Center,Posting Date,Reference,Ticket,Charge Date,Charge Description,Employee ID,Air Ticket Issuer,Air Routing,Class of Service,Transaction Type,Air Departure Date,Air Passenger Name,Federal Tax ID,Event ID/EMS,Traveler Type,Booker Name\n08/03/2015,CAD,CITI AUG,CITIBANK AUG2015,XXXXXXXXXXX24820,31,90304036,325532.05,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,\n,,,,,,,,,,,,,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015,40,41811618,45,,,807220,,,,03/10/2015,XXXXXXXXXXX24820,67417477,02/04/2015,,505569,IATA,YEG YYZ YOW YEG YYC,ECONOMY,ORIGINAL,02/09/2015,²&éèçà$ù€§µ° CAMPBELL  ALANA,,T0000000601,HCP,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015\n,,,,,,,,,,,,,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015,40,41811618,45,,,807220,,,,03/10/2015,XXXXXXXXXXX24820,67419215,02/04/2015,,505569,IATA,YEG YYZ YOW YEG YYC,ECONOMY,ORIGINAL,02/09/2015,²&éèçà$ù€§µ° CAMPBELL  ALANA,,,HCP,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015\n,,,,,,,,,,,,,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015,40,41811618,276.52,,,807220,,,,03/10/2015,XXXXXXXXXXX24820,6774124707,02/04/2015,,505569,AIR CANADA,YEG YYZ YOW YEG YYC,ECONOMY,EXCHANGE,02/09/2015,²&éèçà$ù€§µ° CAMPBELL  ALANA,,ABCD DBCA,HCP,²&éèçà$ù€§µ° CAMPBELL/ALANA YEG YYZ YOW YEG YYC 02/09/2015\n,,,,,,,,,,,,,GST/HST Taxes,40,11221120, 11234.15 ,,,,,,,08/06/2015,,,,,,,,,,,,,,,\n,,,,,,,,,,,,,QST Taxes,40,11221140, 1095.76 ,,,,,,,08/06/2015,,,,,,,,,,,,,,,';
        Blob myFile = Blob.valueof(myData);

        Test.startTest();
        EMS_BCD_Data_Processor ctrl = new EMS_BCD_Data_Processor();
        ctrl.csvFileBody = myFile;
        ctrl.publish();

        // Publish All
        ctrl.sectionToExport = 'nonemstransactions';
        ctrl.exportType = 'xls';
        PageReference exportPage = ctrl.openExportPage();
        System.assertEquals(ctrl.fileName, 'Non EMS Transactions - ' + DateTime.now().format('MM/dd/yyyy'));

        Test.setCurrentPage(exportPage);
        System.assert(exportPage.getUrl().contains('/apex/EMS_BCD_Data_ExportXLS'));
        ctrl.prepareData();

        Test.stopTest();
    }
}