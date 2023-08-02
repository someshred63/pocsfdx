@isTest
private class EMS_Payment_Request_Edit_Create_Test {
    private static Integer BATCH_SIZE = 1;
    private static final RecordType paymentRequestRT = [SELECT Id FROM RecordType WHERE SObjectType = 'EMS_Speaker_Role_gne__c' AND Name = 'HCP/HCO Payment Request' LIMIT 1];

    @isTest static void opening_page_by_paymentRequest_id_test() {
        String etype = 'Learning Programs';
        String esubtype = 'OLA Implementation';
        Decimal amount = 100;

        List<Id> mmUsers = EMS_Test_Util.findExistingUser('MM', null);
        System.assertNotEquals(0, mmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Medical Product', BATCH_SIZE, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        EMS_Budget_Product_gne__c productBudget = EMS_Test_Util.createMultipleProductBudgets(0, amount * 10, mmUsers[0], costCenters)[0];
        EMS_Event__c event = EMS_Test_Util.createEvents('Awaiting Signature from HCP', mmUsers[0], etype, esubtype, Date.today() + 1, Date.today() + 3, amount * 2, BATCH_SIZE)[0];

        EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                Allocated_Budget_gne__c = amount,
                Budget_Owner_gne__c = mmUsers[0],
                Percentage_Contribution_gne__c = 100,
                Budget_Deductions_gne__c = 0,
                EMS_Event_gne__c = event.Id,
                RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                EMS_Product_Budget_gne__c = productBudget.Id,
                Status_gne__c = 'Approved'
        );
        insert budgetAllocation;

        Account accountHCP = EMS_Test_util.createAndInsertAccount('New HCP Account', 'Account');
        EMS_Speaker_Role_gne__c paymentRequest = EMS_Test_Util.createPaymentRequest(paymentRequestRT.Id, event.Id, accountHCP.Id);
        Decimal transactionAmount = amount / 4;
        EMS_Transaction_gne__c transactionGroup = EMS_Test_Util.createTransaction(
                'Transaction Group',
                paymentRequest.Id,
                event.Id,
                transactionAmount,
                null,
                null
        );

        PageReference pyamentPage = Page.EMS_Payment_Request_Edit_Create_Layout;
        Test.startTest();
        // to avoid Too many SOQL queries: 101 do insert inside test
        insert transactionGroup;
        EMS_Transaction_gne__c transactionRecord = EMS_Test_Util.createTransaction(
                'Transaction',
                paymentRequest.Id,
                event.Id,
                transactionAmount,
                transactionGroup.Id,
                costCenters[0].Id
        );
        // insert child transaction - "Transaction"
        insert transactionRecord;

        Test.setCurrentPage(pyamentPage);
        // id is EMS_Speaker_Role_gne__c ID
        pyamentPage.getParameters().put('id', paymentRequest.Id);
        pyamentPage.getParameters().put('retURL', EncodingUtil.urlEncode(Page.EMS_Home.getUrl(), 'UTF-8'));
        EMS_Payment_Request_Edit_Create_Ext mainCtrl = new EMS_Payment_Request_Edit_Create_Ext();

        System.assert(mainCtrl.paymentRequest.Id == paymentRequest.Id);

        Test.stopTest();
    }

    @isTest static void opening_page_by_event_id_test() {
        // it will prepare a new paymentRequest record

        String etype = 'Learning Programs';
        String esubtype = 'OLA Implementation';
        Decimal amount = 100;

        List<Id> mmUsers = EMS_Test_Util.findExistingUser('MM', null);
        System.assertNotEquals(0, mmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Medical Product', BATCH_SIZE, true);
        EMS_Test_Util.createPossibleBudgetAllocationMapping(etype, esubtype, costCenters[0]);

        EMS_Budget_Product_gne__c productBudget = EMS_Test_Util.createMultipleProductBudgets(0, amount * 10, mmUsers[0], costCenters)[0];
        EMS_Event__c event = EMS_Test_Util.createEvents('Awaiting Signature from HCP', mmUsers[0], etype, esubtype, Date.today() + 1, Date.today() + 3, amount * 2, BATCH_SIZE)[0];

        EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                Allocated_Budget_gne__c = amount,
                Budget_Owner_gne__c = mmUsers[0],
                Percentage_Contribution_gne__c = 100,
                Budget_Deductions_gne__c = 0,
                EMS_Event_gne__c = event.Id,
                RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                EMS_Product_Budget_gne__c = productBudget.Id,
                Status_gne__c = 'Approved'
        );
        insert budgetAllocation;
        // add an account
        Account accountHCP = EMS_Test_util.createAndInsertAccount('New HCP Account', 'Account');
        // add a tax code
        EMS_Tax_Code_gne__c simpleTaxCode = new EMS_Tax_Code_gne__c(
                Name = 'I0 (Tax - Exempt)',
                Order_gne__c = 1,
                Tax_Percentage_gne__c = 5.000,
                Cost_Element_gne__c = '11221120',
                Start_Date_gne__c = Date.today().addDays(-5),
                RecordTypeId = EMS_Tax_Code_gne__c.getSObjectType().getDescribe().getRecordTypeInfosByName().get('Sales Tax Code').getRecordTypeId()
        );
        insert simpleTaxCode;


        Test.startTest();
        PageReference pyamentPage = Page.EMS_Payment_Request_Edit_Create_Layout;
        Test.setCurrentPage(pyamentPage);
        pyamentPage.getParameters().put('objectId', event.Id);

        EMS_Payment_Request_Edit_Create_Ext mainCtrl = new EMS_Payment_Request_Edit_Create_Ext();
        System.assert(mainCtrl.paymentRequest.Id == null);
        System.assert(mainCtrl.paymentRequest.Requestor_gne__c == event.Event_Requestor_gne__c);
        System.assert(mainCtrl.paymentRequest.RecordTypeId == EMS_Speaker_Role_gne__c.getSObjectType().getDescribe().getRecordTypeInfosByName().get('HCP/HCO Payment Request').getRecordTypeId());

        PageReference newPage;
        // validating save method
        // vendorId is not populated
        try {
            newPage = mainCtrl.save();
            System.assert(newPage == null);
        } catch (Exception e) {
            System.assert(e.getMessage().contains('You must enter a value'));
        }
        // vendorId is populated, though no transactions exist
        mainCtrl.paymentRequest.Vendor_ID_gne__c = '90100053';
        try {
            newPage = mainCtrl.save();
            System.assert(newPage == null);
        } catch (Exception e) {
            System.assert(e.getMessage().contains('You have to create at least one transaction to submit a payment'));
        }

        mainCtrl.createTransactionGroup();
        newPage = mainCtrl.save(); // HCP_gne__c.addError('You must enter a value');
        System.assert(newPage == null);
        mainCtrl.paymentRequest.HCP_gne__c = accountHCP.Id;

        newPage = mainCtrl.save(); // Cost_Element_gne__c.addError('You must enter a value');
        System.assert(newPage == null);
        mainCtrl.transactionGroupList.get(0).trans.Cost_Element_gne__c = '58899099';
        mainCtrl.transactionGroupList.get(0).trans.Fee_Amount_gne__c = amount / 10;

        mainCtrl.totalAmount = mainCtrl.transactionGroupList.get(0).trans.Fee_Amount_gne__c;
        for (Integer i = 0; i < mainCtrl.transactionGroupList.get(0).transactions.size(); i++) {
            mainCtrl.transactionGroupList.get(0).transactions[i].Cost_Element_gne__c = mainCtrl.transactionGroupList.get(0).trans.Cost_Element_gne__c;
            mainCtrl.transactionGroupList.get(0).transactions[i].Fee_Amount_gne__c = mainCtrl.transactionGroupList.get(0).trans.Fee_Amount_gne__c;
        }
        for (Integer i = 0; i < mainCtrl.transactionGroupList.get(0).taxLines.size(); i++) {
            mainCtrl.transactionGroupList.get(0).taxLines[i].Fee_Amount_gne__c = (mainCtrl.transactionGroupList.get(0).trans.Fee_Amount_gne__c * simpleTaxCode.Tax_Percentage_gne__c) / 100;
        }
        for (Integer i = 0; i < mainCtrl.taxSummaryGroup.transactions.size(); i++) {
            mainCtrl.taxSummaryGroup.transactions[i].Fee_Amount_gne__c = (mainCtrl.transactionGroupList.get(0).trans.Fee_Amount_gne__c * simpleTaxCode.Tax_Percentage_gne__c) / 100;
        }
        newPage = mainCtrl.save();
        System.assertNotEquals(newPage, null);

        List<SelectOption> rtList = mainCtrl.getRecordTypes();
        System.assert(rtList.size() > 0);

        Test.stopTest();
    }

    @isTest static void opening_page_by_gsd_event_id_test() {
        String etype = 'GD';
        String esubtype = 'Grant in Aid Education - Institution / Organization';
        String gsdBudgetType = 'Support for Research Projects';
        Decimal amount = 100;

        List<Id> mmUsers = EMS_Test_Util.findExistingUser('MM', null);
        System.assertNotEquals(0, mmUsers.size());

        List<EMS_Cost_Center_gne__c> costCenters = EMS_Test_Util.createCostCenters('Medical Department', BATCH_SIZE, true);
        EMS_Event_Configuration_gne__c config = EMS_Test_Util.createEventConfiguration(etype, esubtype);

        EMS_Possible_Budget_Allocation_gne__c pba = EMS_Test_Util.preparePossibleBudgetAllocationMapping(config, costCenters[0]);
        pba.GSD_Type_gne__c = gsdBudgetType;
        pba.Honorarium_gne__c = true;
        insert pba;

        EMS_Budget_Product_gne__c productBudget = EMS_Test_Util.createMultipleProductBudgets(0, amount * 10, mmUsers[0], costCenters)[0];
        EMS_Event__c event = EMS_Test_Util.createEvents('Awaiting Signature from HCP', mmUsers[0], etype, esubtype, Date.today() + 1, Date.today() + 3, amount * 2, BATCH_SIZE)[0];

        EMS_Budget_Allocation_gne__c budgetAllocation = new EMS_Budget_Allocation_gne__c(
                Allocated_Budget_gne__c = amount,
                Budget_Owner_gne__c = mmUsers[0],
                Percentage_Contribution_gne__c = 100,
                Budget_Deductions_gne__c = 0,
                EMS_Event_gne__c = event.Id,
                RecordTypeId = EMS_Test_Util.baRecordTypesMap.get('Product Budget Allocation'),
                EMS_Product_Budget_gne__c = productBudget.Id,
                Status_gne__c = 'Approved'
        );
        insert budgetAllocation;

        // create tax code
        EMS_Tax_Code_gne__c simpleTaxCode = new EMS_Tax_Code_gne__c(
                Name = 'I1 (BC GST/PST)',
                Order_gne__c = 2,
                Cost_Element_gne__c = '11221120',
                Start_Date_gne__c = Date.today().addDays(-5),
                Tax_Percentage_gne__c = 5.00,
                RecordTypeId = EMS_Tax_Code_gne__c.getSObjectType().getDescribe().getRecordTypeInfosByName().get('Sales Tax Code').getRecordTypeId()
        );
        insert simpleTaxCode;

        // create GSD Details
        Account hcpAccount = EMS_Test_Util.createAndInsertAccount('HCP Canada');
        EMS_GSD_Detail__c gsdDetails = EMS_Test_Util.prepareGSDDetail(event.Id, System.today(), hcpAccount.Id);
        gsdDetails.GSD_Type_gne__c = gsdBudgetType;
        insert gsdDetails;

        // run the test
        Test.startTest();
        PageReference pyamentPage = Page.EMS_Payment_Request_Edit_Create_Layout;
        Test.setCurrentPage(pyamentPage);
        pyamentPage.getParameters().put('objectId', event.Id);

        EMS_Payment_Request_Edit_Create_Ext mainCtrl = new EMS_Payment_Request_Edit_Create_Ext();
        System.assert(mainCtrl.paymentRequest.Id == null);
        // for GSD events, the record type is being set automatically to 'HCP/HCO Payment Request'
        System.assert(mainCtrl.paymentRequest.RecordTypeId == EMS_Speaker_Role_gne__c.getSObjectType().getDescribe().getRecordTypeInfosByName().get('HCP/HCO Payment Request').getRecordTypeId());

        System.assertEquals(mainCtrl.taxSummaryGroup, null);
        // adding one transaction 
        mainCtrl.createTransactionGroup();
        System.assertNotEquals(mainCtrl.taxSummaryGroup, null);
        // the size is 1, because one row of transaction group was added by invoking createTransactionGroup() method
        System.assertEquals(mainCtrl.transactionGroupList.size(), 1);
        // the size is 1, because there is only one EMS_Tax_Code_gne__c with "I1 (BC GST/PST)" name
        Integer firstRecordRowIndex = 0;
        System.assert(mainCtrl.transactionGroupList.get(firstRecordRowIndex).taxLines.size() == 1);
        System.assert(mainCtrl.transactionGroupList.get(firstRecordRowIndex).transactions.size() == 1);
        System.assert(mainCtrl.transactionGroupList.get(firstRecordRowIndex).trans.Fee_Amount_gne__c == 0);
        System.assert(mainCtrl.transactionGroupList.get(firstRecordRowIndex).trans.Tax_gne__c == simpleTaxCode.Tax_Percentage_gne__c);

        // cahnge tax amount // all amount calculations occur in javascript
        Decimal inputAmount = amount / 10;
        Decimal taxPercentage = mainCtrl.transactionGroupList.get(firstRecordRowIndex).trans.Tax_gne__c;
        mainCtrl.transactionGroupList.get(firstRecordRowIndex).trans.Fee_Amount_gne__c = inputAmount;
        mainCtrl.transactionGroupList.get(firstRecordRowIndex).trans.Cost_Element_gne__c = mainCtrl.transactionGroupList.get(firstRecordRowIndex).getCostElements().get(0).getLabel();
        mainCtrl.transactionGroupList.get(firstRecordRowIndex).transactions[0].Fee_Amount_gne__c = inputAmount;
        mainCtrl.transactionGroupList.get(firstRecordRowIndex).taxLines[0].Fee_Amount_gne__c = inputAmount * (taxPercentage / 100);

        Decimal totalAmountFirstRow = mainCtrl.transactionGroupList.get(firstRecordRowIndex).trans.Fee_Amount_gne__c + mainCtrl.transactionGroupList.get(firstRecordRowIndex).taxLines[0].Fee_Amount_gne__c;
        System.assertEquals(totalAmountFirstRow, amount / 10 + amount / 10 * (simpleTaxCode.Tax_Percentage_gne__c / 100));


        // adding GSD transaction
        mainCtrl.addGSDayment();
        taxPercentage = mainCtrl.transactionGroupList.get(firstRecordRowIndex + 1).trans.Tax_gne__c;
        inputAmount = mainCtrl.transactionGroupList.get(firstRecordRowIndex + 1).trans.Fee_Amount_gne__c;

        System.assertEquals(mainCtrl.transactionGroupList.size(), 2);
        mainCtrl.transactionGroupList.get(firstRecordRowIndex + 1).trans.Cost_Element_gne__c = mainCtrl.transactionGroupList.get(firstRecordRowIndex + 1).getCostElements().get(0).getLabel();
        //mainCtrl.transactionGroupList.get(firstRecordRowIndex+1).trans.Fee_Amount_gne__c // autopopulated
        mainCtrl.transactionGroupList.get(firstRecordRowIndex + 1).transactions[0].Fee_Amount_gne__c = mainCtrl.transactionGroupList.get(firstRecordRowIndex + 1).trans.Fee_Amount_gne__c;
        mainCtrl.transactionGroupList.get(firstRecordRowIndex + 1).taxLines[0].Fee_Amount_gne__c = (inputAmount * taxPercentage) / 100;
        Decimal totalAmountSecondRow = mainCtrl.transactionGroupList.get(firstRecordRowIndex + 1).trans.Fee_Amount_gne__c + mainCtrl.transactionGroupList.get(firstRecordRowIndex + 1).taxLines[0].Fee_Amount_gne__c;
        System.assertEquals(totalAmountSecondRow, inputAmount + inputAmount * (simpleTaxCode.Tax_Percentage_gne__c / 100));

        mainCtrl.totalAmount = totalAmountFirstRow + totalAmountSecondRow;
        mainCtrl.paymentRequest.Vendor_ID_gne__c = '90100053';
        mainCtrl.paymentRequest.HCP_gne__c = hcpAccount.Id;
        PageReference afterSavePage = mainCtrl.save();
        System.assertNotEquals(afterSavePage, null);


        Test.stopTest();
    }
    

    /*
    EMS_Tax_Code_gne__c simpleTaxCode1 = new EMS_Tax_Code_gne__c(
        Name = '03 - Non-Taxable Travel Exp',
        Order_gne__c = 1,
        Cost_Element_gne__c = '11221120',
        Start_Date_gne__c = Date.today().addDays(-5),
        RecordTypeId = EMS_Tax_Code_gne__c.getSObjectType().getDescribe().getRecordTypeInfosByName().get('Non-resident Tax Code').getRecordTypeId()
    );
    */

    /*
    mainCtrl.paymentRequest.RecordTypeId = EMS_Speaker_Role_gne__c.getSObjectType().getDescribe().getRecordTypeInfosByName().get('iHCP Payment Request').getRecordTypeId();
    mainCtrl.onRecordTypeChange();
    System.assert(mainCtrl.paymentRequest.Non_Res_Tax_gne__c == simpleTaxCode.Name);
    */

    /*
    EMS_International_Speaker_gne__c ihcp = EMS_Test_Util.createAndInsertIHCP('Jim','Morrison');
    pyamentPage.getParameters().put('ihcpId', ihcp.Id);
    */
}