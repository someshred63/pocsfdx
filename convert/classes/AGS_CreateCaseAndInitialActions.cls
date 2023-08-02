public class AGS_CreateCaseAndInitialActions {

    // Owner for the Cases
    QueueSobject OwnerQueue;
    QueueSobject CaseActionOwnerQueue;
    // List of Staging Table records BEFORE checking the Txn Amt
    Map<String, AGSCaseStagingTable_gne__c> UncheckedTxnAmt = new Map<String, AGSCaseStagingTable_gne__c>();
    // List of Staging Table records AFTER checking the Txn Amt
    List<AGSCaseStagingTable_gne__c> dmlist = new List<AGSCaseStagingTable_gne__c>();
    // Reason to its Record map
    Map<Id, AGS_CCO_Case_Reason__c> reason_map;
    //Reason Codes except the Reason_type__c = 'manual'
    Set<String> agg_codes = new Set<String>();
    // src_txn_ids from  AGS Staging Table for the records in dmlist
    Set<String> src_txn_id_set = new Set<String>();
    // String all  mdm_ids from AGS Staging Table for the records in dmlist
    Set<String> mdm_id_set = new Set<String>();
    // AGS Type flag INS and it's records map
    Map<String, List<AGSCaseStagingTable_gne__c>> instance_fix = new Map<String, List<AGSCaseStagingTable_gne__c>>();
    // AGS Type flag INS and it's records map
    Map<String, List<AGSCaseStagingTable_gne__c>> agsObj_map = new Map<String, List<AGSCaseStagingTable_gne__c>>();
    // Src TXn Id and Spend exp txn record map
    Map<String, List<AGS_Spend_Expense_Transaction_gne__c>> expense_map = new Map<String, List<AGS_Spend_Expense_Transaction_gne__c>>();
    // receipientId to receipient record map
    Map<Id, AGS_CCO_Case_Recipient_gne__c> ID_to_Recipient = new Map<Id, AGS_CCO_Case_Recipient_gne__c>();
    //Reason Name and its record map
    Map<String, AGS_CCO_Case_Reason__c> code_to_reason = new Map<String, AGS_CCO_Case_Reason__c>();
    //Receipient Name and  ID map
    Map<String, Id> Name_to_RecipientId = new Map<String, Id>();
    // Create CaseId to Source Txn Id Map
    Map<Id, List<String>> case_to_expense_map = new Map<Id, List<String>>();
    //Creating a set of CaseId available in the Junction object
    Set<Id> case_id_set = new Set<Id>();
    //Create a CaseId to Its Record Map
    Map<Id, AGS_Case_gne__c> ID_to_case = new Map<Id, AGS_Case_gne__c>();
    //Create a MDMId+RuleId to Case Map
    Map<String, AGS_Case_gne__c> aggregateCases_map = new Map<String, AGS_Case_gne__c>();
    //List of Junction records existing for the staging Table records
    List<AGSSpendCCOCase_gne__c> junction_list = new List<AGSSpendCCOCase_gne__c>();
    //Create Juntion when Case exist
    Map<String, String> juntionCreateWhenExist = new Map<String, String>();
    //Spend Expense populate List
    Map<String, AGS_Spend_Expense_Transaction_gne__c> populateSpendList = new Map<String, AGS_Spend_Expense_Transaction_gne__c>();
    //Create for other instances then 1C
    Map<String, AGS_Case_gne__c> junctionForOtherInstancesCases = new Map<String, AGS_Case_gne__c>();
    // List of New Cases created
    Map<String, AGS_Case_gne__c> newCaseslist = new Map<String, AGS_Case_gne__c>();
    // List of System Reopen Actions incase of System reopen cases
    List<AGS_Case_Action_gne__c> systemReopenAction = new List<AGS_Case_Action_gne__c>();
    //New junction records for the newly created cases
    List<AGSSpendCCOCase_gne__c> createJunctionlist = new List<AGSSpendCCOCase_gne__c>();
    //Set of CaseId available in the newly created Junction object
    Set<Id> caseid_set_Resolver = new Set<Id>();
    // List of Junction records for the newly created cases
    List<AGSSpendCCOCase_gne__c> junction_set_Resolver = new List<AGSSpendCCOCase_gne__c>();
    //Create junction ID's from createJunctionlist
    Set<Id> junction_set = new Set<Id>();
    //  Creating a Map ID to Case
    Map<Id, AGS_Case_gne__c> cases ;
    //List to set the System Reopen Case  Status  and analyst response level
    List<AGS_Case_gne__c> casesToSystemReopen = new List<AGS_Case_gne__c>() ;
    //Record Name to its record map
    Map<String, RecordType> RecTypes_map = new Map<String, RecordType>();
    //Junction List With All user heirarchy Spend user Id so that resolver can be set
    List<AGSSpendCCOCase_gne__c> juncWith_allUser = new List<AGSSpendCCOCase_gne__c>();
    //Write To The Error Log wether success or failure
    List<AGS_Error_Log__c> ErrorLogSuccess = new List<AGS_Error_Log__c>();
    List<AGS_Error_Log__c> ErrorLogFailure = new List<AGS_Error_Log__c>();
    // Batch ID
    final String batchId { get; private set; }
    //Get details of the Junction
    List<AGSSpendCCOCase_gne__c> justCreatedjunction;
    //Get Detils of the Cases
    List<AGS_Case_gne__c> justCreatedCases;

    public AGS_CreateCaseAndInitialActions(final Id jobId) {
        batchId = jobId;
    }

    public void createCase(List<AGS_Provisional_Case_gne__c> caseCreateData) {
        Savepoint Savepoint = Database.setSavepoint();
        Set<String> CaseCreateKey = new Set<String>();
        try {
            OwnerQueue = [SELECT Id, QueueId FROM QueueSobject WHERE SobjectType = :'AGS_Case_gne__c'];
            CaseActionOwnerQueue = [SELECT Id, QueueId FROM QueueSobject WHERE SobjectType = :'AGS_Case_Action_gne__c'];

            // Loop through the DummyCase records and add to  a Set
            for (AGS_Provisional_Case_gne__c dummyRecord : caseCreateData) {
                CaseCreateKey.add(dummyRecord.AGS_PC_Key_gne__c);
            }
            // For each Provisional Case bring the relevant AGS Staging Table record
            for (AGSCaseStagingTable_gne__c st : [SELECT Id,Name,AGS_Staging_Key_gne__c,AGS_Case_Creation_status_gne__c, AGS_Type_Flag_gne__c, AGS_Txn_Amount_gne__c, AGS_SRC_Txn_ID_gne__c,AGS_RuleID_gne__c, AGS_MDM_ID_gne__c, AGS_Brand_gne__c FROM AGSCaseStagingTable_gne__c WHERE AGS_Case_Creation_status_gne__c = 'Unprocessed' AND AGS_TxnAmountCheck_Status_gne__c = 'None'AND AGS_Staging_Key_gne__c IN :CaseCreateKey]) {
                String key = st.AGS_Type_Flag_gne__c + st.AGS_Staging_Key_gne__c + st.AGS_SRC_Txn_ID_gne__c;
                if (!UncheckedTxnAmt.containsKey(key)) {
                    UncheckedTxnAmt.put(key, st);
                }
            }

            if (UncheckedTxnAmt.size() > 0) {
                // Compare the Txn amt of Staging table data and the relevant Spend Exp txn
                checkTxnAmt(caseCreateData);
                // Seperate the Staging table data based on the Type flag
                seperateINS_AGG_Data();
                // Populate Rec Types, Expense List, Receipient List, Exisiting Case details, Exisiting junction details,
                makingDataReady_forCaseCreation(caseCreateData);
                //Create Instance Case
                instance_CaseCreation (caseCreateData);
                // Create Aggregate Case
                aggregate_CaseCreation (caseCreateData);
                // Insert Newly created Cases, Insert System Reopen,  Insert System reopn Action , Create and  Insert Junction
                createJunction_andInsertCase(caseCreateData);
                // For the Spend User set All user Hierarchy details and Update the AGSSpendCCO(Junction)
                setSpendUserFromAllUserHierarchy();
                // Set problem Severity , Analyst severity , Case status for Instance and Aggregate
                setAnalyst_Resolver();
                // Set Please validate data and Aggregate recommended Spending Limit reached and Insert
                setInitial_CaseActions();
            } else {
                // No data
                List<AGS_Error_Log__c> ErrorNoData = new List<AGS_Error_Log__c>();
                for (AGS_Provisional_Case_gne__c dum : caseCreateData) {
                    AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c = batchId, Class_Name__c = 'AGS_CreateCaseAndInitialActions',
                            Custom_Error_Message__c = 'No AGS Case Staging Table Data for Provisional Case Record :  ' + dum.Name, Error_Type__c = 'Failure', Error_Category_gne__c = 'No Data', Method_Name__c = 'createCase', Object_Name__c = 'AGS Provisional Case');
                    ErrorNoData.add(el);
                }
                insert ErrorNoData;
                updateCase_CreateStatus (dmlist, caseCreateData, 'Failed') ;
                System.debug('AGS_Error_Log__c ' + ErrorNoData);
            }
        } catch (CaseCreationException ce) {
            insert ErrorLogFailure;
            System.debug(ce.getStackTraceString());
            System.debug('Failed On Case Creation : ' + ce.getMessage() + ' line: ' + ce.getLineNumber());
        } catch (Exception e) {
            Database.rollback (Savepoint);
            insert ErrorLogFailure;
            System.debug(e.getStackTraceString());
            System.debug('Failed On Case Creation : ' + e.getMessage() + ' line: ' + e.getLineNumber());
        }
    }

    public void makingDataReady_forCaseCreation(List<AGS_Provisional_Case_gne__c> caseCreateData) {
        try {

            populate_RecordTypes();
            populate_ReasonCodes();
            populate_ExpenseList();
            if (!dmlist.isEmpty() && dmlist[0].AGS_RuleID_gne__c != '1C') {
                populate_ReceipientList();
            }
            populate_CaseMaps_FromJunction();
            if (!dmlist.isEmpty() && dmlist[0].AGS_RuleID_gne__c != '1C') {
                populate_CaseToRecord_FromJunction();
            }
        } catch (Exception e) {
            for (AGS_Provisional_Case_gne__c dum : caseCreateData) {
                AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c = batchId, Class_Name__c = 'AGS_CreateCaseAndInitialActions', System_Error_Message__c = e.getMessage() + 'line: ' + e.getLineNumber(),
                        Custom_Error_Message__c = 'Related Expense, Reason,Recepient,Case- Data could not be pulled in for Provisional Case Record :  ' + dum.Name, Error_Type__c = 'Failure', Error_Category_gne__c = 'No Data', Method_Name__c = 'makingDataReady_forCaseCreation', Object_Name__c = 'AGS Provisional Case');
                ErrorLogFailure.add(el);
            }
            System.debug('FAILED ON LIST CREATION: ' + e.getMessage());
            throw e;
        }
    }
    public void populate_RecordTypes() {
        List<RecordType> RecType = new List<RecordType>([SELECT Name, Id FROM RecordType WHERE Name LIKE 'AGS%']);
        for (RecordType rec : RecType) {
            if (!RecTypes_map.containsKey(rec.Name)) {
                RecTypes_map.put(rec.Name, rec);
            }
        }
    }

    public void populate_CaseToRecord_FromJunction() {
        ID_to_case = new Map<Id, AGS_Case_gne__c>([
                SELECT Name,Analyst_gne__r.Email,Resolver_gne__c, Inactive_resolver__c,Inactive_resolver__r.Active_gne__c, Reason_gne__r.Reason_Type__c,Id,Problem_Severity_Level_cco_gne__c,AGS_Case_Reason_Code_gne__c,Reason_gne__c, Reason_Type_gne__c, Aggregate_Recipient_MDM_ID_gne__c,
                        Case_Status_gne__c, Case_Closed_Reason_gne__c, Expense_Transaction_Total_gne__c, Brand_gne__c
                FROM AGS_Case_gne__c
                WHERE (CreatedDate = THIS_YEAR OR CreatedDate = LAST_YEAR) AND Id IN :case_id_set
        ]);

        for (AGS_Case_gne__c a_case : ID_to_case.values()) {
            if (a_case.Aggregate_Recipient_MDM_ID_gne__c != null && a_case.AGS_Case_Reason_Code_gne__c != null) {
                aggregateCases_map.put(ID_to_Recipient.get(a_case.Aggregate_Recipient_MDM_ID_gne__c).Name + reason_map.get(a_case.Reason_gne__c).Name, a_case);
                System.debug('Agg Case Map :' + aggregateCases_map);
            }
        }
    }

    public void populate_CaseMaps_FromJunction() {
        // Query junction table based on mdm_id_set and agg_codes to receive all related cases
        junction_list = [
                SELECT Id, MDM_ID__c, AGS_Case_gne__c, AGS_Case_gne__r.Name, Source_Transaction_ID_gne__c,
                        AGS_Spend_Expense_Transaction_gne__c,Reason_Code__c, AGS_Spend_Expense_Transaction_Amount_gne__c,Case_Status__c,
                        AGS_Spend_Transaction_ID__c
                FROM AGSSpendCCOCase_gne__c
                WHERE (CreatedDate = THIS_YEAR OR CreatedDate = LAST_YEAR) AND MDM_ID__c IN :mdm_id_set AND Reason_Code__c IN :agg_codes
        ];

        for (AGSSpendCCOCase_gne__c jun : junction_list) {
            if (!case_to_expense_map.containsKey(jun.AGS_Case_gne__c)) {
                case_to_expense_map.put(jun.AGS_Case_gne__c, new List<String>());
            }
            case_to_expense_map.get(jun.AGS_Case_gne__c).add(jun.Source_Transaction_ID_gne__c);
        }

        for (AGSSpendCCOCase_gne__c junction : junction_list) {
            if (!case_id_set.contains(junction.AGS_Case_gne__c)) {
                case_id_set.add(junction.AGS_Case_gne__c);
            }
        }
    }

    public void populate_ReceipientList() {
        List<AGS_CCO_Case_Recipient_gne__c> recipient_list = new List<AGS_CCO_Case_Recipient_gne__c>();

        // Query for all case rcepients based on the name (mdmId)
        recipient_list = [SELECT Id,Name FROM AGS_CCO_Case_Recipient_gne__c WHERE Name IN :mdm_id_set];
        System.debug('Recipient List:' + recipient_list);
        // Loop through the  case receipients and add the Id and its record to the Map
        for (AGS_CCO_Case_Recipient_gne__c recipient : recipient_list) {
            if (!ID_to_Recipient.keySet().contains(recipient.Id)) {
                ID_to_Recipient.put(recipient.Id, recipient);
            }
            if (!Name_to_RecipientId.containsKey(recipient.Name)) {
                Name_to_RecipientId.put(recipient.Name, recipient.Id);
            }
        }
    }

    public void populate_ExpenseList() {
        List<AGS_Spend_Expense_Transaction_gne__c> expense_list = new List<AGS_Spend_Expense_Transaction_gne__c>();
        // Based on the src_txn_id query for the relevant records in AGS_Spend_Expense_Transaction_gne__c
        expense_list = [
                SELECT Name,Source_Transaction_ID_gne__c, Primary_Recipient_gne__c, Id
                FROM
                        AGS_Spend_Expense_Transaction_gne__c
                WHERE Source_Transaction_ID_gne__c IN :src_txn_id_set
        ];

        System.debug ('The expense List size :' + expense_list.size());

        // Loop through the src_txn_id list and add the src_txn and its Spend exp Txn record to a Map
        for (AGS_Spend_Expense_Transaction_gne__c aset : expense_list) {

            //code after change:
            String keyOfSourceTransaction = aset.Source_Transaction_ID_gne__c.split('~')[0];

            if (!expense_map.containsKey(keyOfSourceTransaction)) {
                expense_map.put(keyOfSourceTransaction, new List<AGS_Spend_Expense_Transaction_gne__c>{
                        aset
                });
            } else {
                expense_map.get(keyOfSourceTransaction).add(aset);
            }

            populateSpendList.put(aset.Source_Transaction_ID_gne__c, aset);

            // before change code:
            //expense_map.put(aset.Source_Transaction_ID_gne__c,aset);
        }

    }
    public void populate_ReasonCodes() {

        // Query for all the Case Reasons and keep in the reason_map,Reason Name and its Record
        reason_map = new Map<Id, AGS_CCO_Case_Reason__c>([SELECT Id,Name,Reason_Type__c, Default_Problem_Severity__c FROM AGS_CCO_Case_Reason__c WHERE Reason_Type__c != 'manual']);

        for (AGS_CCO_Case_Reason__c reason : reason_map.values()) {
            if (!code_to_reason.keySet().contains(reason.Name)) {
                code_to_reason.put(reason.Name, reason);
            }
            if (!agg_codes.contains(reason.Name)) agg_codes.add(reason.Name);
        }

    }
    public void checkTxnAmt(List<AGS_Provisional_Case_gne__c> caseCreateData) {
        List<AGSCaseStagingTable_gne__c> agsObj_unequalTxnAmt = new List<AGSCaseStagingTable_gne__c>();
        Set<String> src_txnId_set = new Set<String>();
        List<AGS_Spend_Expense_Transaction_gne__c> unchecked_Expense_list = new List<AGS_Spend_Expense_Transaction_gne__c>();
        try {
            // Looping through AgsObj (DM Data) and seperate the Data
            for (AGSCaseStagingTable_gne__c ao : UncheckedTxnAmt.values()) {
                src_txnId_set.add(ao.AGS_SRC_Txn_ID_gne__c);
            }
            // Based on the src_txn_id query for the relevant records in AGS_Spend_Expense_Transaction_gne__c
            unchecked_Expense_list = [
                    SELECT Name, Source_Transaction_ID_gne__c, Allocated_Transaction_Amount_gne__c, Primary_Recipient_gne__c, Id
                    FROM
                            AGS_Spend_Expense_Transaction_gne__c
                    WHERE Source_Transaction_ID_gne__c IN :src_txnId_set
            ];

            Decimal total_Allocated_Txn = 0;

            for (AGSCaseStagingTable_gne__c ags : UncheckedTxnAmt.values()) {

                for (AGS_Spend_Expense_Transaction_gne__c exp : unchecked_Expense_list) {
                    if (ags.AGS_SRC_Txn_ID_gne__c.equals(exp.Source_Transaction_ID_gne__c)) {
                        total_Allocated_Txn += exp.Allocated_Transaction_Amount_gne__c;

                    }
                }
            }
            for (AGSCaseStagingTable_gne__c ags : UncheckedTxnAmt.values()) {

                Boolean isAmt_WithIn_Limits = true;
                if (!ignoreTxnLimits(ags.AGS_RuleID_gne__c)) {
                    isAmt_WithIn_Limits = Allocated_Txn_WithIn_Limits (ags.AGS_Txn_Amount_gne__c, total_Allocated_Txn, ags.AGS_Type_Flag_gne__c);
                }
                if (isAmt_WithIn_Limits) {
                    ags.AGS_TxnAmountCheck_Status_gne__c = 'Matched';
                    dmlist.add (ags);
                    agsObj_unequalTxnAmt.add(ags);
                } else {
                    ags.AGS_TxnAmountCheck_Status_gne__c = 'Did Not Match';
                    ags.AGS_Case_Creation_status_gne__c = 'Failed';
                    agsObj_unequalTxnAmt.add(ags);
                    AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c = batchId, Class_Name__c = 'AGS_CreateCaseAndInitialActions',
                            Custom_Error_Message__c = 'Txn Amount did not Match For : ' + ags.Name, Error_Type__c = 'Failure', Error_Category_gne__c = 'Txn Amt', Method_Name__c = 'checkTxnAmt', Object_Name__c = 'AGS Case Staging Table');
                    insert el;
                    updateCase_CreateStatus (dmlist, caseCreateData, 'Failed') ;
                }
            }

            if (agsObj_unequalTxnAmt.size() > 0) {
                update agsObj_unequalTxnAmt;
            }
        } catch (DmlException e) {
            for (AGSCaseStagingTable_gne__c stagingRecord : agsObj_unequalTxnAmt) {
                AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c = batchId, Class_Name__c = 'AGS_CreateCaseAndInitialActions', System_Error_Message__c = e.getMessage(),
                        Custom_Error_Message__c = 'Txn Amount could not be checked  For the Staging table record : ' + stagingRecord.Name, Error_Type__c = 'Failure', Error_Category_gne__c = 'Txn Amt', Method_Name__c = 'checkTxnAmt', Object_Name__c = 'AGS Case Staging Table');
                ErrorLogFailure.add(el);
            }
            System.debug('I failed on Updating unMatched Txn Amt Records of Staging Table  : ' + e.getMessage());
            throw e;
        }
    }

    public void seperateINS_AGG_Data() {
        try {
            for (AGSCaseStagingTable_gne__c ao : dmlist) {
                /* AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c=batchId,Class_Name__c='AGS_CreateCaseAndInitialActions',
                    Custom_Error_Message__c='Entered Seperate INS-AGG' + ao.Name,Error_Type__c='Success',Error_Category_gne__c= 'Batch Entry',Method_Name__c='seperateINS_AGG_Data',Object_Name__c='AGS Provisional Case');
                    insert el;*/
                src_txn_id_set.add(ao.AGS_SRC_Txn_ID_gne__c);
                mdm_id_set.add(ao.AGS_MDM_ID_gne__c);
                String newInsKey = ao.AGS_MDM_ID_gne__c + ao.AGS_RuleID_gne__c + '_' + ao.AGS_SRC_Txn_ID_gne__c.split('~')[0];
                //Seperate the Data based on the 'INS' Type Flag
                if (ao.AGS_Type_Flag_gne__c == 'INS') {
                    if (!instance_fix.containsKey(newInsKey)) {
                        instance_fix.put(newInsKey, new List<AGSCaseStagingTable_gne__c>());
                    }
                    instance_fix.get(newInsKey).add(ao);
                }
                System.debug('instance_fix = ' + instance_fix);

                //Seperate the Data based on the 'AGG'Type Flag
                if (ao.AGS_Type_Flag_gne__c == 'AGG') {
                    if (!agsObj_map.containsKey(ao.AGS_MDM_ID_gne__c + ao.AGS_RuleID_gne__c)) {
                        agsObj_map.put(ao.AGS_MDM_ID_gne__c + ao.AGS_RuleID_gne__c, new List<AGSCaseStagingTable_gne__c>());
                    }
                    agsObj_map.get(ao.AGS_MDM_ID_gne__c + ao.AGS_RuleID_gne__c).add(ao);
                }
            }
            System.debug('INS_Cases IN THIS BATCH: ' + instance_fix.values().size());
            System.debug('AGG_Cases IN THIS BATCH: ' + agsObj_map.keySet().size());

        } catch (Exception e) {
            System.debug(e);
        }
    }

    public Boolean Allocated_Txn_WithIn_Limits(Decimal txnAmount, Decimal Allocated_TxnAmount, String agsTypeFlag) {
        Boolean isTxnAmtInLimits = false;

        if (agsTypeFlag == 'INS') {
            isTxnAmtInLimits = (Allocated_TxnAmount == txnAmount) ? true : false;
        }
        if (agsTypeFlag == 'AGG') {
            isTxnAmtInLimits = (((Allocated_TxnAmount - 0.50) < txnAmount) && (txnAmount < (Allocated_TxnAmount + .50))) ? true : false;
        }

        return isTxnAmtInLimits;
    }

    private Boolean ignoreTxnLimits(String ruleType) {
        List<AGS_Config__mdt> config = [SELECT AGS_Txn_Type_No_Limit_Validation__c FROM AGS_Config__mdt WHERE DeveloperName = 'AGS_Txn_Type_No_Limit_Validation'];

        Set<String> ignoredRuleTypes;
        if (config.isEmpty()) {
            ignoredRuleTypes = new Set<String> ();
        } else {
            ignoredRuleTypes = new Set<String>(config.get(0).AGS_Txn_Type_No_Limit_Validation__c.split(';'));
        }
        return ignoredRuleTypes.contains(ruleType);
    }

    public void instance_CaseCreation(List<AGS_Provisional_Case_gne__c> caseCreateData) {

        for (String instance_key : instance_fix.keySet()) {
            List<AGSCaseStagingTable_gne__c> cur_InsObjs = instance_fix.get(instance_key);
            AGSCaseStagingTable_gne__c cur_InsObj = cur_InsObjs[0];
            System.debug('instance_key = ' + instance_key);
            Boolean new_case = true;
            AGS_Case_gne__c current_case;
            try {
                for (AGSSpendCCOCase_gne__c ag_x : junction_list) {
                    String test_key = ag_x.MDM_ID__c + ag_x.Reason_Code__c + '_' + ag_x.Source_Transaction_ID_gne__c.split('~')[0];
                    System.debug('ag_x = ' + ag_x);
                    if (ID_to_case.containsKey(ag_x.AGS_Case_gne__c)) {
                        current_case = ID_to_case.get(ag_x.AGS_Case_gne__c);
                    }

                    if (current_case != null) {
                        if (current_case.Id == ag_x.AGS_Case_gne__c && instance_key == test_key) {

                            new_case = false;
                            if (current_case.Case_Status_gne__c != 'Closed') {
                                updateCase_CreateStatus (dmlist, caseCreateData, 'Case Exists') ;
                                AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c = batchId, Class_Name__c = 'AGS_CreateCaseAndInitialActions',
                                        Custom_Error_Message__c = ' Open Instance Case Exists  :' + current_case.Name + ' AGS Case Staging Table Record No :' + cur_InsObj.Name, Error_Type__c = 'Success', Error_Category_gne__c = 'Case Exists', Method_Name__c = 'instance_CaseCreation', Object_Name__c = 'AGS Case');
                                ErrorLogSuccess.add(el);
                                System.debug('AGS_Error_Log__c  :' + el);

                            }
                            if (current_case.Case_Status_gne__c == 'Closed' && current_case.Case_Closed_Reason_gne__c != 'No Issue') {
                                updateCase_CreateStatus (dmlist, caseCreateData, 'Case Exists') ;
                                AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c = batchId, Class_Name__c = 'AGS_CreateCaseAndInitialActions',
                                        Custom_Error_Message__c = ' Closed Instance Case - Already Exists  :' + current_case.Name + ' AGS Case Staging Table Record No :' + cur_InsObj.Name, Error_Type__c = 'Success', Error_Category_gne__c = 'Case Exists', Method_Name__c = 'instance_CaseCreation', Object_Name__c = 'AGS Case');
                                ErrorLogSuccess.add(el);
                                System.debug('AGS_Error_Log__c  :' + el);

                            }
                            if (current_case.Case_Status_gne__c == 'Closed' && current_case.Case_Closed_Reason_gne__c == 'No Issue') {
                                current_case.Case_Status_gne__c = 'System Reopen - Pending Analysis';
                                if (current_case.Analyst_Response_Level_cco_gne__c != 'High' && current_case.Problem_Severity_Level_cco_gne__c != 'High') {
                                    current_case.Analyst_Response_Level_cco_gne__c = 'Medium';
                                    current_case.Problem_Severity_Level_cco_gne__c = 'Medium';
                                }
                                current_case.Case_Closed_Reason_gne__c = null;
                                current_case.RecordTypeId = RecTypes_map.get('AGS Case Per Instance RecordType').Id;
                                casesToSystemReopen.add(current_case);
                                systemReopenAction.add(AGS_CaseUtility.addNewSystem_Reopen(current_case, 'System Reopen Per Instance Case Post Case Creation', RecTypes_map));

                            }
                        }
                    }
                }
                if (new_case) {

                    if (cur_InsObj.AGS_RuleID_gne__c.equals('1C')) {

                        String keyOfSTRTXN = cur_InsObj.AGS_SRC_Txn_ID_gne__c.split('~')[0];

                        List<AGS_Case_gne__c> ags = [SELECT Id,Transaction_Source_Id__c FROM AGS_Case_gne__c WHERE Transaction_Source_Id__c = :keyOfSTRTXN AND Reason_gne__r.Name = :cur_InsObj.AGS_RuleID_gne__c];
                        System.debug('ags = ' + ags);
                        if (ags.isEmpty()) {

                            current_case = new AGS_Case_gne__c(
                                    Reason_gne__c = code_to_reason.get(cur_InsObj.AGS_RuleID_gne__c).Id,
                                    Expense_Transaction_Total_gne__c = cur_InsObj.AGS_Txn_Amount_gne__c,
                                    OwnerId = OwnerQueue.QueueId,
                                    //Aggregate_Recipient_MDM_ID_gne__c = Name_to_RecipientId.get(cur_InsObj.AGS_MDM_ID_gne__c),
                                    Problem_Severity_Level_cco_gne__c = code_to_reason.get(cur_InsObj.AGS_RuleID_gne__c).Default_Problem_Severity__c,
                                    Brand_gne__c = cur_InsObj.AGS_Brand_gne__c,
                                    Transaction_Source_Id__c = keyOfSTRTXN
                            );

                            newCaseslist.put(keyOfSTRTXN, current_case);
                            System.debug('newCaseslist = ' + newCaseslist);
                        } else {
                            juntionCreateWhenExist.put(ags.get(0).Id, expense_map.get(keyOfSTRTXN)[0].Id);
                            System.debug('juntionCreateWhenExist = ' + juntionCreateWhenExist);
                        }
                    } else {
                        current_case = new AGS_Case_gne__c(
                                Reason_gne__c = code_to_reason.get(cur_InsObj.AGS_RuleID_gne__c).Id,
                                Expense_Transaction_Total_gne__c = cur_InsObj.AGS_Txn_Amount_gne__c,
                                OwnerId = OwnerQueue.QueueId,
                                Aggregate_Recipient_MDM_ID_gne__c = Name_to_RecipientId.get(cur_InsObj.AGS_MDM_ID_gne__c),
                                Problem_Severity_Level_cco_gne__c = code_to_reason.get(cur_InsObj.AGS_RuleID_gne__c).Default_Problem_Severity__c,
                                Brand_gne__c = cur_InsObj.AGS_Brand_gne__c
                        );

                        junctionForOtherInstancesCases.put(cur_InsObj.AGS_SRC_Txn_ID_gne__c, current_case);
                    }
                }
            } catch (Exception e) {
                System.debug('FAILED ON INS Case Creation: ' + e.getMessage());
                AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c = batchId, Class_Name__c = 'AGS_CreateCaseAndInitialActions', System_Error_Message__c = e.getMessage(),
                        Custom_Error_Message__c = ' Instance Case could not be Created For the Staging table record : ' + cur_InsObj.Name, Error_Type__c = 'Failure', Error_Category_gne__c = 'Case Not Created', Method_Name__c = 'instance_CaseCreation', Object_Name__c = 'AGS Case Staging Table');
                ErrorLogFailure.add(el);
                throw e;
            }
        }
    }
    public void aggregate_CaseCreation(List<AGS_Provisional_Case_gne__c> caseCreateData) {
        Integer countDebug = 0;
        System.debug('We are going to loop: ' + agsObj_map.keySet().size());

        for (String cur_agsObjjKey : agsObj_map.keySet()) {

            List<AGSCaseStagingTable_gne__c> cur_agsObjs = agsObj_map.get(cur_agsObjjKey);
            AGSCaseStagingTable_gne__c cur_agsObj = cur_agsObjs[0];

            AGS_Case_gne__c current_case = (aggregateCases_map.containsKey(cur_agsObjjKey)) ? aggregateCases_map.get(cur_agsObjjKey) : null;

            Boolean new_case = true;
            try {
                if (current_case != null) {
                    System.debug('Aggregate Case Exists ');
                    countDebug++;
                    new_case = false;
                    Boolean result = false;
                    if (current_case.Problem_Severity_Level_cco_gne__c == 'Low' && current_case.AGS_Case_Reason_Code_gne__c == cur_agsObj.AGS_RuleID_gne__c) {
                        System.debug('current_Case.Reason_gne__c' + current_case.Reason_gne__c);
                        System.debug('cur_agsObj.AGS_RuleID_gne__c' + cur_agsObj.AGS_RuleID_gne__c);
                        for (AGSCaseStagingTable_gne__c agsObject : cur_agsObjs) {
                            if (case_to_expense_map.containsKey(current_case.Id)) {
                                List <String> case_to_SrcTxn = case_to_expense_map.get(current_case.Id);
                                for (String src : case_to_SrcTxn) {
                                    if (src == agsObject.AGS_SRC_Txn_ID_gne__c) {
                                        result = true;
                                        AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c = batchId, Class_Name__c = 'AGS_CreateCaseAndInitialActions',
                                                Custom_Error_Message__c = 'Aggregate Case Already Exists  :' + current_case.Name + 'Source Txn ID  :' + agsObject.AGS_SRC_Txn_ID_gne__c + ' Provisional Case Id = ' + agsObject.Id, Error_Type__c = 'Success', Error_Category_gne__c = 'Case Exists', Method_Name__c = 'aggregate_CaseCreation', Object_Name__c = 'AGS Case');
                                        ErrorLogSuccess.add(el);
                                        System.debug('We found an Existing Agg Case With Low Severity ..Did we get same Txns?  : ' + result);
                                        updateCase_CreateStatus (dmlist, caseCreateData, 'Case Exists') ;
                                        break;
                                    }
                                }
                            }
                            if (result) {
                                System.debug('Coming out of Staging Data :' + result);
                                break;
                            }
                        }
                    } if (!result) {
                        new_case = true;
                    }

                }
                if (new_case) {

                    String keyOfSTRTXN = cur_agsObj.AGS_SRC_Txn_ID_gne__c.split('~')[0];

                    current_case = new AGS_Case_gne__c(
                            Reason_gne__c = code_to_reason.get(cur_agsObj.AGS_RuleID_gne__c).Id,
                            Expense_Transaction_Total_gne__c = cur_agsObj.AGS_Txn_Amount_gne__c,
                            OwnerId = OwnerQueue.QueueId,
                            Aggregate_Recipient_MDM_ID_gne__c = Name_to_RecipientId.get(cur_agsObj.AGS_MDM_ID_gne__c),
                            Problem_Severity_Level_cco_gne__c = code_to_reason.get(cur_agsObj.AGS_RuleID_gne__c).Default_Problem_Severity__c,
                            Brand_gne__c = cur_agsObj.AGS_Brand_gne__c
                    );

                    newCaseslist.put(keyOfSTRTXN, current_case);

                }
            } catch (Exception e) {
                System.debug('FAILED ON AGG Case Creation: ' + e.getMessage());
                AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c = batchId, Class_Name__c = 'AGS_CreateCaseAndInitialActions', System_Error_Message__c = e.getMessage(),
                        Custom_Error_Message__c = 'Aggregate Case could not be Created  For the Staging table record :  ' + cur_agsObj.Name, Error_Type__c = 'Failure', Error_Category_gne__c = 'Case Not Created', Method_Name__c = 'aggregate_CaseCreation', Object_Name__c = 'AGS Case ');
                ErrorLogFailure.add(el);
                throw e;
            }
        }

    }
    public void setInitial_CaseActions() {
        //List of Case Actions to be Inserted
        Map<Id, AGS_Case_Action_gne__c> caseActions = new Map<Id, AGS_Case_Action_gne__c>();
        Set<String> user_set = new Set<String>();

        try {

            List<AGS_Case_Action_gne__c> caseAction;
            if (!juncWith_allUser.isEmpty()) {
                caseAction = [SELECT Id,Name FROM AGS_Case_Action_gne__c WHERE AGS_Case_gne__c = :cases.get(juncWith_allUser[0].AGS_Case_gne__c).Id];
            }

            if (caseAction == null || caseAction.isEmpty()) {

                Id noSpendUser = [SELECT u.Id FROM User u WHERE External_ID_gne__c = :Utilities.noSpendUser].Id;
                // Instance Rule
                for (AGSSpendCCOCase_gne__c ju : juncWith_allUser) {
                    AGS_Case_gne__c caseObj = cases.get(ju.AGS_Case_gne__c);
                    if (caseObj.Reason_Type_gne__c == 'Instance Rule' && ju.AGS_Expense_Transaction_Spend_UserID_gne__c != null
                            && ju.User_from_AllUserHeirarchy__c != null && ju.AGS_Spend_Expense_Trans_Infq_User_gne__c != 'Yes') {
                        if (caseObj.AGS_Case_Reason_Code_gne__c != '1H' && caseObj.AGS_Case_Reason_Code_gne__c != '1I' && caseObj.AGS_Case_Reason_Code_gne__c != '1J' && caseObj.AGS_Case_Reason_Code_gne__c != '1K') {
                            if (!ju.User_from_AllUserHeirarchy__r.Active_gne__c) {
                                caseObj.Resolver_gne__c = noSpendUser;
                            }
                            caseActions.put(caseObj.Resolver_gne__c, AGS_CaseUtility.addPleaseValidateData(caseObj, 'Please Validate Data', RecTypes_map));
                        }
                    }
                }
                // Aggregation Rule
                for (AGSSpendCCOCase_gne__c j : juncWith_allUser) {
                    if (j.AGS_Expense_Transaction_Spend_UserID_gne__c != null && j.User_from_AllUserHeirarchy__c != null && j.User_from_AllUserHeirarchy__r.Active_gne__c) {
                        if (!user_set.contains(j.AGS_Expense_Transaction_Spend_UserID_gne__c)) {
                            user_set.add(j.AGS_Expense_Transaction_Spend_UserID_gne__c);

                        }
                    } else {
                        if (!user_set.contains(noSpendUser)) {
                            user_set.add(noSpendUser);

                        }
                    }
                }
                List<User> user_list = new List<User>([SELECT Id FROM User WHERE Id IN :user_set]);

                for (AGS_Case_gne__c cas : cases.values()) {

                    for (AGSSpendCCOCase_gne__c j : juncWith_allUser) {

                        if (cas.Reason_Type_gne__c == 'Aggregation Rule' && (cas.Problem_Severity_Level_cco_gne__c == 'Low' || cas.AGS_Case_Reason_Code_gne__c.startsWith('2'))) {
                            if (cases.keySet().contains(j.AGS_Case_gne__c)) {
                                for (Integer i = 0; i < user_list.size(); i++) {
                                    cas.Resolver_gne__c = user_list[i].Id;
                                    caseActions.put(cas.Resolver_gne__c, AGS_CaseUtility.addNewAggReco_SpendingLimitReached(cas, 'Aggregate Recommended Spending Limit Reached', RecTypes_map));
                                    user_list.remove(i);
                                }
                            }

                        }
                    }
                }

                if (caseActions.size() > 0) {
                    List<User> case_actions_owners = [SELECT Id,IsActive,Profile_Name_gne__c FROM User WHERE Id IN :caseActions.keySet()];
                    for (User usr : case_actions_owners) {
                        if (!usr.IsActive) {
                            if (usr.Profile_Name_gne__c == 'GNE-INFREQUENT-USER') {
                                caseActions.get(usr.Id).OwnerId = CaseActionOwnerQueue.QueueId;
                                caseActions.get(usr.Id).Inactive_Owner_gne__c = usr.Id;
                            } else {
                                caseActions.get(usr.Id).OwnerId = noSpendUser;
                            }
                        }
                    }
                    insert caseActions.values();
                }
            }
        } catch (DmlException e) {
            for (AGS_Case_Action_gne__c ca : caseActions.values()) {
                AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c = batchId, Class_Name__c = 'AGS_CreateCaseAndInitialActions', System_Error_Message__c = e.getMessage(),
                        Custom_Error_Message__c = 'Failed on Inserting Case Actions ' + ca.Action_gne__c + ' AGS CASE ID = ' + ca.AGS_Case_gne__c, Error_Type__c = 'Failure',
                        Error_Category_gne__c = 'Initial Case Actions', Method_Name__c = 'setInitial_CaseActions', Object_Name__c = 'AGS Case ');
                ErrorLogFailure.add(el);
            }
            System.debug('I failed on Inserting Case Actions : ' + e.getMessage());
            throw e;
        }
        try {
            if (ErrorLogSuccess.size() > 0) {
                insert ErrorLogSuccess;
            }
        } catch (DmlException e) {
            System.debug('Could Not insert Error Log Success File');
        }
    }
    public void updateCase_CreateStatus(List<AGSCaseStagingTable_gne__c> updateAgs, List<AGS_Provisional_Case_gne__c> updateDummy, String status) {

        try {
            for (AGSCaseStagingTable_gne__c ags : updateAgs) {
                ags.AGS_Case_Creation_status_gne__c = status;

            }
            for (AGS_Provisional_Case_gne__c dum : updateDummy) {
                dum.AGS_CaseCreation_status_gne__c = status;

            }
            update (updateAgs);
            update (updateDummy);
        } catch (DmlException e) {
            for (AGSCaseStagingTable_gne__c ags : updateAgs) {

                AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c = batchId, Class_Name__c = 'AGS_CreateCaseAndInitialActions', System_Error_Message__c = e.getMessage(),
                        Custom_Error_Message__c = 'Failed on Updating AGS Case Staging Table ' + ags.Name + ' Id = ' + ags.Id, Error_Type__c = 'Failure',
                        Error_Category_gne__c = 'Update Status', Method_Name__c = 'updateCase_CreateStatus', Object_Name__c = 'AGS Case Staging Table');
                ErrorLogFailure.add(el);
            }
            for (AGS_Provisional_Case_gne__c dum : updateDummy) {
                AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c = batchId, Class_Name__c = 'AGS_CreateCaseAndInitialActions', System_Error_Message__c = e.getMessage(),
                        Custom_Error_Message__c = 'Failed on Updating AGS Provisional Case' + dum.AGS_PC_MDM_ID_gne__c + 'Rule ID = ' + dum.AGS_PC_Rule_ID_gne__c + ' Name = ' + dum.Name, Error_Type__c = 'Failure',
                        Error_Category_gne__c = 'Update Status', Method_Name__c = 'updateCase_CreateStatus', Object_Name__c = 'AGS Provisional Case ');
                ErrorLogFailure.add(el);
            }
            System.debug('FAILURE updating Status' + e.getMessage());
            throw e;
        }
    }
    public void setAnalyst_Resolver() {
        cases = new Map<Id, AGS_Case_gne__c>([SELECT Id, Expense_Transaction_Total_gne__c, Analyst_gne__r.Email, Resolver_gne__c, Name,Reason_Type_gne__c,AGS_Case_Reason_Code_gne__c, Case_Status_gne__c,Inactive_resolver__c,Inactive_resolver__r.Active_gne__c,Resolver_gne__r.IsActive, AGS_CCO_Case_Reason_Threshold_Min_gne__c,Problem_Severity_Level_cco_gne__c,Analyst_Response_Level_cco_gne__c FROM AGS_Case_gne__c WHERE (CreatedDate = THIS_YEAR OR CreatedDate = LAST_YEAR) AND Id IN :caseid_set_Resolver]);
        //starts updated by sandeep
        Id ccoManager = [SELECT Id FROM User WHERE External_ID_gne__c = :Utilities.ccoManager].Id;
        Id cco = [SELECT Id FROM All_User_Hierarchy_gne__c WHERE User_External_Id_gne__c = :Utilities.ccoManager].Id;
        //ends updated by sandeep
        juncWith_allUser = [
                SELECT Id, MDM_ID__c, AGS_Case_gne__c, AGS_Case_gne__r.Name,Source_Transaction_ID_gne__c,User_External_ID__c, Spend_Transaction_Amounts_gne__c,User_from_AllUserHeirarchy__c,User_from_AllUserHeirarchy__r.Active_gne__c,
                        AGS_Spend_Expense_Transaction_gne__c, AGS_Spend_Expense_Transaction_gne__r.Name, Reason_Code__c,Case_Resolver_gne__c, AGS_Spend_Expense_Transaction_Amount_gne__c,Case_Status__c, AGS_Spend_Expense_Trans_Infq_User_gne__c,
                        AGS_Spend_Transaction_ID__c,AGS_Expense_Transaction_Spend_UserID_gne__c
                FROM AGSSpendCCOCase_gne__c
                WHERE (CreatedDate = THIS_YEAR OR CreatedDate = LAST_YEAR) AND Id IN :junction_set
        ];
        try {
            for (AGSSpendCCOCase_gne__c junc : juncWith_allUser) {
                if (cases.containsKey(junc.AGS_Case_gne__c)) {
                    AGS_Case_gne__c caseObj = cases.get(junc.AGS_Case_gne__c);
                    if (caseObj.Case_Status_gne__c == 'Imported-New') {

                        if (caseObj.Reason_Type_gne__c == 'Instance Rule') {

                            if (junc.User_from_AllUserHeirarchy__c != null && junc.AGS_Expense_Transaction_Spend_UserID_gne__c != null) {
                                setResolverAndCaseStatus(caseObj, junc.AGS_Expense_Transaction_Spend_UserID_gne__c, junc.User_from_AllUserHeirarchy__c, 'Open');
                            }
                            if (junc.User_from_AllUserHeirarchy__c == null && junc.AGS_Expense_Transaction_Spend_UserID_gne__c == null) {
                                setResolverAndCaseStatus(caseObj, ccoManager, cco, 'Open - Pending Manual Analysis');
                            }
                            if (junc.User_from_AllUserHeirarchy__c == null && junc.AGS_Expense_Transaction_Spend_UserID_gne__c != null) {
                                setResolverAndCaseStatus(caseObj, ccoManager, cco, 'Open - Pending Manual Analysis');
                            }
                            //Assign Default severity based on Amount

                            if (isLowSeverityCase(caseObj, junc)) {
                                caseObj.Problem_Severity_Level_cco_gne__c = 'Low';
                                caseObj.Analyst_Response_Level_cco_gne__c = 'Low';
                            }

                            if (isMediumSeverityCase(caseObj, junc)) {
                                caseObj.Problem_Severity_Level_cco_gne__c = 'Medium';
                                caseObj.Analyst_Response_Level_cco_gne__c = 'Medium';
                                caseObj.Case_Status_gne__c = 'Open - Pending Manual Analysis';
                            }

                            if (isHighSeverityCase(caseObj, junc)) {
                                caseObj.Problem_Severity_Level_cco_gne__c = 'High';
                                caseObj.Analyst_Response_Level_cco_gne__c = 'High';
                                caseObj.Case_Status_gne__c = 'Open - Pending Manual Analysis';
                            }

                            // If infrequent User
                            if (junc.AGS_Spend_Expense_Trans_Infq_User_gne__c == 'Yes') {
                                caseObj.Infrequent_User__c = true;
                                caseObj.Case_Status_gne__c = 'Open - Pending Manual Analysis';
                            }
                            // If infrequent User, Analyst response medium and case status as below
                            if (junc.AGS_Spend_Expense_Trans_Infq_User_gne__c == 'Yes' && caseObj.Analyst_Response_Level_cco_gne__c != 'High' && caseObj.Problem_Severity_Level_cco_gne__c != 'High') {
                                caseObj.Analyst_Response_Level_cco_gne__c = 'Medium';
                                caseObj.Problem_Severity_Level_cco_gne__c = 'Medium';
                            }

                        }
                        if (junc.User_from_AllUserHeirarchy__c == null && junc.AGS_Expense_Transaction_Spend_UserID_gne__c == null) {
                            AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c = batchId, Class_Name__c = 'AGS_CreateCaseAndInitialActions',
                                    Custom_Error_Message__c = 'No Spend User on : ' + junc.AGS_Case_gne__r.Name + 'Related Exp Txn is : ' + junc.AGS_Spend_Expense_Transaction_gne__r.Name, Error_Type__c = 'Failure', Error_Category_gne__c = 'No Spend USer', Method_Name__c = 'setAnalyst_Resolver', Object_Name__c = 'AGS Spend CCO');
                            ErrorLogSuccess.add(el);
                        }
                        if (junc.User_from_AllUserHeirarchy__c == null && junc.AGS_Expense_Transaction_Spend_UserID_gne__c == null) {
                            AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c = batchId, Class_Name__c = 'AGS_CreateCaseAndInitialActions',
                                    Custom_Error_Message__c = 'Spend User not Active : ' + junc.AGS_Case_gne__r.Name + 'Related Exp Txn is :' + junc.AGS_Spend_Expense_Transaction_gne__r.Name, Error_Type__c = 'Failure', Error_Category_gne__c = 'Spend USer not Active', Method_Name__c = 'setAnalyst_Resolver', Object_Name__c = 'AGS Spend CCO');
                            ErrorLogSuccess.add(el);
                        }
                        if (caseObj.Reason_Type_gne__c == 'Aggregation Rule') {
                            if (caseObj.AGS_Case_Reason_Code_gne__c == '2A' || caseObj.AGS_Case_Reason_Code_gne__c == '3A' || caseObj.AGS_Case_Reason_Code_gne__c == '6A'
                                    || caseObj.AGS_Case_Reason_Code_gne__c == '3B' || caseObj.AGS_Case_Reason_Code_gne__c == '3C') {

                                setAggregateCaseFields(caseObj, cco, ccoManager, 'Open', 'Low', 'Low');
                            }
                            if (caseObj.AGS_Case_Reason_Code_gne__c == '2B' || caseObj.AGS_Case_Reason_Code_gne__c == '3D') {

                                setAggregateCaseFields(caseObj, cco, ccoManager, 'Open', 'Medium', 'Medium');
                            }
                            if (caseObj.AGS_Case_Reason_Code_gne__c == '2C' || caseObj.AGS_Case_Reason_Code_gne__c == '3E') {

                                setAggregateCaseFields(caseObj, cco, ccoManager, 'Open', 'High', 'High');
                            }
                        }
                    }
                }
                Database.UpsertResult[] upsResults = Database.upsert(cases.values(), true);
                System.debug(upsResults);
            }
        } catch (DmlException e) {
            for (AGSSpendCCOCase_gne__c junc : juncWith_allUser) {
                AGS_Case_gne__c caseObj = cases.get(junc.AGS_Case_gne__c);
                AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c = batchId, Class_Name__c = 'AGS_CreateCaseAndInitialActions', System_Error_Message__c = e.getMessage(),
                        Custom_Error_Message__c = 'Case could not be updated with Severity, Resolver ' + caseObj.Name, Error_Type__c = 'Failure', Error_Category_gne__c = 'Set Analyst,Severity', Method_Name__c = 'setAnalyst_Resolver', Object_Name__c = 'AGS Case ');
                ErrorLogFailure.add(el);
            }
            throw e;
        }
    }
    public void createJunction_andInsertCase(List<AGS_Provisional_Case_gne__c> caseCreateData) {
        //Exception e1 = new Exception();

        try {
            if (newCaseslist.size() > 0 || junctionForOtherInstancesCases.size() > 0) {
                //Insert the new cases so we can have ID'S for them
                if (newCaseslist.size() > 0) {
                    insert(newCaseslist.values());
                    justCreatedCases = new List<AGS_Case_gne__c> ([
                            SELECT Name,Analyst_gne__r.Email,Resolver_gne__c, Inactive_resolver__c,Inactive_resolver__r.Active_gne__c,Reason_gne__r.Reason_Type__c,Id,Problem_Severity_Level_cco_gne__c,AGS_Case_Reason_Code_gne__c,Reason_gne__c, Reason_Type_gne__c, Aggregate_Recipient_MDM_ID_gne__c,
                                    Case_Status_gne__c, Case_Closed_Reason_gne__c, Expense_Transaction_Total_gne__c, Brand_gne__c
                            FROM AGS_Case_gne__c
                            WHERE (CreatedDate = THIS_YEAR OR CreatedDate = LAST_YEAR) AND Id IN :newCaseslist.values()
                    ]);
                }
                if (junctionForOtherInstancesCases.size() > 0) {
                    insert(junctionForOtherInstancesCases.values());
                    justCreatedCases = new List<AGS_Case_gne__c> ([
                            SELECT Name,Analyst_gne__r.Email,Resolver_gne__c, Inactive_resolver__c,Inactive_resolver__r.Active_gne__c,Reason_gne__r.Reason_Type__c,Id,Problem_Severity_Level_cco_gne__c,AGS_Case_Reason_Code_gne__c,Reason_gne__c, Reason_Type_gne__c, Aggregate_Recipient_MDM_ID_gne__c,
                                    Case_Status_gne__c, Case_Closed_Reason_gne__c, Expense_Transaction_Total_gne__c, Brand_gne__c
                            FROM AGS_Case_gne__c
                            WHERE (CreatedDate = THIS_YEAR OR CreatedDate = LAST_YEAR) AND Id IN :junctionForOtherInstancesCases.values()
                    ]);
                }
                updateCase_CreateStatus (dmlist, caseCreateData, 'Processed') ;
            }
        } catch (Exception e) {
            for (AGS_Case_gne__c newCase : justCreatedCases) {
                AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c = batchId, Class_Name__c = 'AGS_CreateCaseAndInitialActions', System_Error_Message__c = e.getMessage(),
                        Custom_Error_Message__c = 'Could Not insert new Case List  ', Error_Type__c = 'Failure',
                        Error_Category_gne__c = 'Case Not Created', Method_Name__c = 'createJunction_andInsertCase', Object_Name__c = 'AGS Case');
                ErrorLogFailure.add(el);
            }
            System.debug('FAILURE CREATING NEW CASES: ' + e.getMessage());
            updateCase_CreateStatus (dmlist, caseCreateData, 'Failed') ;
            throw e;
        }
        try {
            if (casesToSystemReopen.size() > 0) {
                update (casesToSystemReopen);
                /*for (AGS_Case_gne__c  reopen :casesToSystemReopen ){
                        AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c=batchId,Class_Name__c='AGS_CreateCaseAndInitialActions',
                        Custom_Error_Message__c='Case System Reopened Successfully' + 'Case No   :' +reopen.Name+  'Case Total   :'  + reopen.Expense_Transaction_total_gne__c,Error_Type__c='Success',Error_Category_gne__c ='Case Exists',Method_Name__c='createJunction_andInsertCase',Object_Name__c='AGS Case');
                        ErrorLogSuccess.add(el);
                    }*/
            }
        } catch (DmlException e) {
            for (AGS_Case_gne__c reopen : casesToSystemReopen) {
                AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c = batchId, Class_Name__c = 'AGS_CreateCaseAndInitialActions', System_Error_Message__c = e.getMessage(),
                        Custom_Error_Message__c = 'Instance Case Could not be System Reopened' + 'Case No   :' + reopen.Name + 'Case Total   :' + reopen.Expense_Transaction_Total_gne__c, Error_Type__c = 'Failure', Error_Category_gne__c = 'Case Exists', Method_Name__c = 'createJunction_andInsertCase', Object_Name__c = 'AGS Case');
                ErrorLogFailure.add(el);
            }
            System.debug('I failed on Updating System Reopen Cases : ' + e.getMessage());
            throw e;
        }
        try {
            if (systemReopenAction.size() > 0) {
                insert systemReopenAction;
                updateCase_CreateStatus (dmlist, caseCreateData, 'Processed') ;
            }
        } catch (Exception e) {
            System.debug('FAILURE REOPENING INSTANCE CASE:' + e.getMessage());
            updateCase_CreateStatus (dmlist, caseCreateData, 'Failed-Reopening') ;
            for (AGS_Case_Action_gne__c reopen : systemReopenAction) {
                AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c = batchId, Class_Name__c = 'AGS_CreateCaseAndInitialActions', System_Error_Message__c = e.getMessage(),
                        Custom_Error_Message__c = 'System Reopen Case Action could not be Created : ' + reopen.Name, Error_Type__c = 'Failure', Error_Category_gne__c = 'Case Exists', Method_Name__c = 'createJunction_andInsertCase', Object_Name__c = 'AGS Case');
                ErrorLogFailure.add(el);
            }
            throw new CaseCreationException(e);
        }

        try {
            for (String key : newCaseslist.keySet()) {

                String caseId = newCaseslist.get(key).Id;

                List<AGS_Spend_Expense_Transaction_gne__c> spendTran = expense_map.get(key);
                for (AGS_Spend_Expense_Transaction_gne__c trans : spendTran) {
                    createJunctionlist.add(new AGSSpendCCOCase_gne__c(AGS_Case_gne__c = caseId,
                            AGS_Spend_Expense_Transaction_gne__c = trans.Id));
                }
            }

            for (String csKey : juntionCreateWhenExist.keySet()) {
                createJunctionlist.add(new AGSSpendCCOCase_gne__c(AGS_Case_gne__c = csKey,
                        AGS_Spend_Expense_Transaction_gne__c = juntionCreateWhenExist.get(csKey)));

            }
            for (String key : junctionForOtherInstancesCases.keySet()) {
                String caseId = junctionForOtherInstancesCases.get(key).Id;

                String spendId = populateSpendList.get(key).Id;

                createJunctionlist.add(new AGSSpendCCOCase_gne__c(AGS_Case_gne__c = caseId,
                        AGS_Spend_Expense_Transaction_gne__c = spendId));
            }

            if (createJunctionlist.size() > 0) {
                insert(createJunctionlist);
                justCreatedjunction = new List<AGSSpendCCOCase_gne__c>([
                        SELECT Id, User_from_AllUserHeirarchy__c, MDM_ID__c, AGS_Case_gne__c, AGS_Case_gne__r.Name, Source_Transaction_ID_gne__c,User_External_ID__c, Spend_Transaction_Amounts_gne__c,AGS_Expense_Transaction_Spend_UserID_gne__c,
                                AGS_Spend_Expense_Transaction_gne__c,AGS_Spend_Expense_Transaction_gne__r.Name, Reason_Code__c,Reason_Type_gne__c,
                                Case_Resolver_gne__c, AGS_Spend_Expense_Transaction_Amount_gne__c,Case_Status__c, AGS_Spend_Expense_Trans_Infq_User_gne__c,
                                AGS_Spend_Transaction_ID__c
                        FROM AGSSpendCCOCase_gne__c
                        WHERE (CreatedDate = THIS_YEAR OR CreatedDate = LAST_YEAR) AND Id IN :createJunctionlist
                ]);

                if (juntionCreateWhenExist.size() > 0) {
                    updateCase_CreateStatus (dmlist, caseCreateData, 'Processed');
                }
            }
        } catch (Exception e) {
            System.debug('FAILURE CREATING JUNCTIONS:' + e.getMessage());
            for (AGSSpendCCOCase_gne__c ju : justCreatedjunction) {
                AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c = batchId, Class_Name__c = 'AGS_CreateCaseAndInitialActions', System_Error_Message__c = e.getMessage(),
                        Custom_Error_Message__c = 'Junction Object could not be Created Successfully' + 'Case No   :' + ju.AGS_Case_gne__r.Name + 'Spend Exp Txn    :' + ju.AGS_Spend_Expense_Transaction_gne__r.Name, Error_Type__c = 'Failure', Error_Category_gne__c = 'Case Not Created', Method_Name__c = 'createJunction_andInsertCase', Object_Name__c = 'AGS Spend CCO');
                ErrorLogFailure.add(el);
            }
            throw e;
        }

    }
    public void setAggregateCaseFields(AGS_Case_gne__c caseObj, Id cco, Id ccoManager, String caseStatus, String problemSeverity, String analystResponse) {

        caseObj.Inactive_resolver__c = cco;
        caseObj.Resolver_gne__c = ccoManager;
        caseObj.Case_Status_gne__c = caseStatus;
        caseObj.Problem_Severity_Level_cco_gne__c = problemSeverity;
        caseObj.Analyst_Response_Level_cco_gne__c = analystResponse;
    }
    public void setResolverAndCaseStatus(AGS_Case_gne__c caseObj, Id ccoManager, Id cco, String caseStatus) {
        caseObj.Resolver_gne__c = ccoManager;
        caseObj.Inactive_resolver__c = cco;
        caseObj.Case_Status_gne__c = caseStatus;
    }
    public Boolean isLowSeverityCase(AGS_Case_gne__c caseObj, AGSSpendCCOCase_gne__c junc) {
        Boolean isLowSeverity = false;
        isLowSeverity = ((junc.Spend_Transaction_Amounts_gne__c - caseObj.AGS_CCO_Case_Reason_Threshold_Min_gne__c) <= Decimal.valueOf(system.Label.Severity_Amount)
                && caseObj.AGS_Case_Reason_Code_gne__c != '1F'
                && caseObj.AGS_Case_Reason_Code_gne__c != '1G'
                && caseObj.AGS_Case_Reason_Code_gne__c != '1H'
                && caseObj.AGS_Case_Reason_Code_gne__c != '1I'
                && caseObj.AGS_Case_Reason_Code_gne__c != '1J'
                && caseObj.AGS_Case_Reason_Code_gne__c != '1K'
                && caseObj.Analyst_Response_Level_cco_gne__c != 'Medium'
                && caseObj.Analyst_Response_Level_cco_gne__c != 'High');
        return isLowSeverity;
    }
    public Boolean isHighSeverityCase(AGS_Case_gne__c caseObj, AGSSpendCCOCase_gne__c junc) {
        Boolean isHighSeverity = false;
        if (caseObj.AGS_Case_Reason_Code_gne__c != '1H' && caseObj.AGS_Case_Reason_Code_gne__c != '1I' && caseObj.AGS_Case_Reason_Code_gne__c != '1J' && caseObj.AGS_Case_Reason_Code_gne__c != '1K') {
            isHighSeverity = (((junc.Spend_Transaction_Amounts_gne__c - caseObj.AGS_CCO_Case_Reason_Threshold_Min_gne__c) > Decimal.valueOf(system.Label.Severity_Amount))
                    || caseObj.AGS_Case_Reason_Code_gne__c == '1F'
                    || caseObj.AGS_Case_Reason_Code_gne__c == '1G');
        }
        return isHighSeverity;
    }

    public Boolean isMediumSeverityCase(AGS_Case_gne__c caseObj, AGSSpendCCOCase_gne__c junc) {
        Boolean isMediumSeverity = false;
        isMediumSeverity = (caseObj.AGS_Case_Reason_Code_gne__c == '1H' || caseObj.AGS_Case_Reason_Code_gne__c == '1I' || caseObj.AGS_Case_Reason_Code_gne__c == '1J' || caseObj.AGS_Case_Reason_Code_gne__c == '1K');
        return isMediumSeverity;
    }

    public void setSpendUserFromAllUserHierarchy() {
        Set<String> unixJunction_set = new Set<String>();
        Map<String, All_User_Hierarchy_gne__c> allUsers = new Map<String, All_User_Hierarchy_gne__c>();
        //Update Junction Object with All user herarchy users
        List<AGSSpendCCOCase_gne__c> juncUpdate_allUser = new List<AGSSpendCCOCase_gne__c>();
        try {
            // Set the User from All user Hierarchy
            for (AGSSpendCCOCase_gne__c junction : createJunctionlist) {
                if (!junction_set.contains(junction.Id)) {
                    junction_set.add(junction.Id);
                }
                if (!caseid_set_Resolver.contains(junction.AGS_Case_gne__c)) {
                    caseid_set_Resolver.add(junction.AGS_Case_gne__c);
                }
            }
            cases = new Map<Id, AGS_Case_gne__c>([SELECT Id,Name, Infrequent_User__c, Expense_Transaction_Total_gne__c, Analyst_gne__r.Email,Reason_Type_gne__c,AGS_Case_Reason_Code_gne__c, Case_Status_gne__c,Inactive_resolver__c,Inactive_resolver__r.Active_gne__c,Resolver_gne__r.IsActive, AGS_CCO_Case_Reason_Threshold_Min_gne__c,Problem_Severity_Level_cco_gne__c,Analyst_Response_Level_cco_gne__c FROM AGS_Case_gne__c WHERE (CreatedDate = THIS_YEAR OR CreatedDate = LAST_YEAR) AND Id IN :caseid_set_Resolver]);

            junction_set_Resolver = [
                    SELECT Id, MDM_ID__c, AGS_Case_gne__c,AGS_Case_gne__r.Name, Source_Transaction_ID_gne__c,User_External_ID__c, Spend_Transaction_Amounts_gne__c,AGS_Expense_Transaction_Spend_UserID_gne__c,
                            AGS_Spend_Expense_Transaction_gne__c,Reason_Code__c,Reason_Type_gne__c,
                            Case_Resolver_gne__c, AGS_Spend_Expense_Transaction_Amount_gne__c,Case_Status__c, AGS_Spend_Expense_Trans_Infq_User_gne__c,
                            AGS_Spend_Transaction_ID__c
                    FROM AGSSpendCCOCase_gne__c
                    WHERE (CreatedDate = THIS_YEAR OR CreatedDate = LAST_YEAR) AND Id IN :junction_set
            ];

            for (AGSSpendCCOCase_gne__c junc : junction_set_Resolver) {
                if (!unixJunction_set.contains(junc.User_External_ID__c)) {
                    unixJunction_set.add(junc.User_External_ID__c);
                }
            }
            // Users from All User Heirarchy
            List <All_User_Hierarchy_gne__c> externalID = new List <All_User_Hierarchy_gne__c> ([SELECT Id, Name, Active_gne__c, User_External_Id_gne__c, All_User_Hierarchy_Level1_gne__c, All_User_Hierarchy_Level2_gne__c,FirstName_gne__c,LastName_gne__c FROM All_User_Hierarchy_gne__c WHERE User_External_Id_gne__c IN :unixJunction_set AND Active_gne__c = true AND User_External_Id_gne__c != null]);

            for (All_User_Hierarchy_gne__c ex : externalID) {
                if (!allUsers.containsKey(ex.User_External_Id_gne__c.toLowerCase())) {
                    allUsers.put(ex.User_External_Id_gne__c.toLowerCase(), ex);
                }
            }

            for (AGSSpendCCOCase_gne__c junc : junction_set_Resolver) {
                if (junc.User_External_ID__c != null) {
                    if (allUsers.containsKey(junc.User_External_ID__c.toLowerCase())) {
                        junc.User_from_AllUserHeirarchy__c = allUsers.get(junc.User_External_ID__c.toLowerCase()).Id;
                        juncUpdate_allUser.add(junc);
                    }
                }
            }
            if (juncUpdate_allUser.size() > 0) {
                update (juncUpdate_allUser);
            }
        } catch (DmlException e) {
            System.debug('I failed on Updating Junction with All User Herarchy Spend User ID : ' + e.getMessage());
            for (AGSSpendCCOCase_gne__c junc : junction_set_Resolver) {
                AGS_Error_Log__c el = new AGS_Error_Log__c(Batch_Id__c = batchId, Class_Name__c = 'AGS_CreateCaseAndInitialActions', System_Error_Message__c = e.getMessage(),
                        Custom_Error_Message__c = 'Could Not update the Spend Users with All User Hierarchy details  : ' + junc.AGS_Case_gne__r.Name, Error_Type__c = 'Failure', Error_Category_gne__c = 'Update Spend User Info', Method_Name__c = 'setSpendUserFromAllUserHierarchy', Object_Name__c = 'AGS Spend CCO');
                ErrorLogFailure.add(el);
            }
            throw e;
        }
    }

    class CaseCreationException extends Exception {

    }
}