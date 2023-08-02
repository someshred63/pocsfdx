/**
 * Created by kozminsl on 08.07.2019.
 */

public with sharing class ConcurInteractionsCtrl {
    private static final Integer TIME_LIMIT = 90000;
    private static final String NO_SHOW_TYPE = 'Canceled/No Show';
    private static final String INTERACTION_TYPE = 'Engagement';

    public String callId { get; set; }
    public String ownerPersistentId { get; set; }
    public String mode { get; set; }
    public User spendUser { get; set; }
    public String spendUserId { get; set; }
    public Concur_Expense_gne__c expense { get; set; }
    public String expenseJSON { get; set; }
    public Date transactionDate { get; set; }
    public String transactionAmount { get; set; }

    public ConcurInteractionsCtrl() {
        String strXUserID = ApexPages.currentPage().getParameters().get('xuserid');
        ownerPersistentId = ApexPages.currentPage().getParameters().get('OwnerPersId');
        if (String.isNotBlank(ownerPersistentId)) {
            spendUserId = ownerPersistentId.split('@').get(0);
        }
        if (String.isNotBlank(strXUserID)) {
            for (String strId : strXUserID.split('@')) {
                List<All_User_Hierarchy_gne__c> listAUH = [SELECT User_External_Id_gne__c FROM All_User_Hierarchy_gne__c WHERE Persistent_Id_gne__c = :strId];
                if (listAUH.size() > 0) {
                    String strUser = listAUH[0].User_External_Id_gne__c;
                    Boolean isCorrectUser = false;
                    for (String strUserId : UserInfo.getUserName().split('@')) {
                        if (strUserId == strUser) {
                            isCorrectUser = true;
                        }
                    }
                    if (!isCorrectUser) {
                        throw new InteractionException('Problem with URL - report creator is different.');
                    }
                }
            }
        }
        List<All_User_Hierarchy_gne__c> listAUH = [SELECT User_External_Id_gne__c FROM All_User_Hierarchy_gne__c WHERE Persistent_Id_gne__c = :spendUserId ORDER BY CreatedDate DESC LIMIT 1];
        if (!listAUH.isEmpty()) {
            List<User> users = [SELECT Id, External_ID_gne__c FROM User WHERE External_ID_gne__c = :listAUH.get(0).User_External_Id_gne__c];
            if (!users.isEmpty()) {
                spendUser = users.get(0);
            }
        }

        if (spendUser == null) {
            spendUser = [SELECT Id, External_ID_gne__c FROM User WHERE Id = :UserInfo.getUserId()];
        }

        String strReportOwner = ApexPages.currentPage().getParameters().get('ReportOwner');
        System.debug('------------Report Owner: ' + strReportOwner);
        expense = new Concur_Expense_gne__c();
        expense.Expense_Type_gne__c = ApexPages.currentPage().getParameters().get('ExpenseType');
        expense.ExpKey_gne__c = ApexPages.currentPage().getParameters().get('ExpKey');
        expense.Item_Url_gne__c = ApexPages.currentPage().getParameters().get('itemurl');
        expense.Report_Creator_gne__c = ApexPages.currentPage().getParameters().get('ReportCreator');
        expense.Report_Owner_gne__c = ApexPages.currentPage().getParameters().get('ReportOwner');
        transactionDate = Utility.formatDate_newformat(ApexPages.currentPage().getParameters().get('TransactionDate'));
        transactionAmount = ApexPages.currentPage().getParameters().get('TransactionAmount');
        expense.Transaction_Amount_gne__c = transactionAmount;
        expense.Amount_gne__c = ApexPages.currentPage().getParameters().get('Amount');
        expense.Transaction_Date_gne__c = transactionDate;
        expense.XUserID_gne__c = strXUserID;
        expense.Expence_Location_gne__c = ApexPages.currentPage().getParameters().get('LocationName');
        expenseJSON = JSON.serialize(expense);
    }

    private User initSpendUser(String userPersistenceId) {
        User user;
        List<All_User_Hierarchy_gne__c> listAUH = [SELECT User_External_Id_gne__c FROM All_User_Hierarchy_gne__c WHERE Persistent_Id_gne__c = :userPersistenceId ORDER BY CreatedDate DESC LIMIT 1];
        if (!listAUH.isEmpty()) {
            String unixId = listAUH.get(0).User_External_Id_gne__c;
            String strResult = UserManager.activateSFUser(unixId, true);
            if (!Utility.isNull(strResult) && strResult.indexOf('Error') == -1) {
                user = Database.query('SELECT Id  FROM User WHERE External_ID_gne__c = \'' + unixId + '\' AND UserType =\'Standard\' LIMIT 1');
            }
        }
        return user;
    }

    @AuraEnabled
    public static Boolean isVeevaCrmUser() {
        Boolean isVeevaUser = false;
        if (isVeevaEnabled()) {
            Profile profile = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];
            if (profile.Name == 'GNE-Field') {
                isVeevaUser = true;
            }
        }
        return isVeevaUser;
    }

    public static Boolean isVeevaEnabled() {
        GNE_Foun_Misc_Config_Items_gne__c config = GNE_Foun_Misc_Config_Items_gne__c.getValues('VeevaEnabled');
        return config != null ? Boolean.valueOf(config.Configuration_Value_gne__c) : false;
    }

    @AuraEnabled
    public static List<RowWrapper> getInteractions(String transactionDateJSON, String spendUser, Double expenseAmount) {
        IRecordLtng.subscribeVeevaAccounts(spendUser);
        List<RowWrapper> result = new List<RowWrapper>();
        System.debug('transactionDateJSON: ' + transactionDateJSON);
        Date transactionDate = Date.valueOf(transactionDateJSON);
        System.debug(spendUser);
        Date prevDay = transactionDate.addDays(-2);
        Date nextDay = transactionDate.addDays(1);
        System.debug('---prevDay: ' + prevDay);
        System.debug('---nextDay: ' + nextDay);
        System.debug('---Alias: ' + spendUser);
        for (Call2_vod__c call : [
                SELECT Name, Actual_Attendees_gne__c, Call_Datetime_vod__c, Call_Date_vod__c, Interaction_Type_gne__c,
                        Spend_User_gne__c, Account_vod__r.Name, Customers_gne__c,
                        Planned_Attendees_gne__c, Account_vod__c, Parent_Call_vod__c,
                        Id, Spend_User_gne__r.Alias, RecordType.DeveloperName, RecordType.Name, (SELECT Account_vod__r.Name FROM Call2_vod__r WHERE Account_vod__r.Name != '' ORDER BY Account_vod__r.LastName LIMIT 1)
                FROM Call2_vod__c
                WHERE Parent_Call_vod__c = NULL AND IsDeleted = FALSE AND Interaction_Status_gne__c = 'Completed'
                AND Actual_Attendees_gne__c > 0
                AND DAY_ONLY(convertTimezone(Call_Datetime_vod__c)) >= :prevDay AND
                DAY_ONLY(convertTimezone(Call_Datetime_vod__c)) <= :nextDay
                AND (Spend_User_gne__c = :spendUser OR OwnerId = :spendUser)
                ORDER BY Call_Datetime_vod__c DESC, CreatedDate DESC
        ]) {
            result.add(new RowWrapper(call));
        }
        for (Call_No_Show_Spend__c call : [
                SELECT Id, Name, Actual_Attendees__c, Planned_Attendees__c, Reason__c, Spend_User__c, Transaction_Date__c
                FROM Call_No_Show_Spend__c
                WHERE Transaction_Date__c >= :prevDay AND
                Transaction_Date__c <= :nextDay
                AND (Spend_User__c = :spendUser OR OwnerId = :spendUser)
                ORDER BY Transaction_Date__c DESC, CreatedDate DESC
        ]) {
            result.add(new RowWrapper(call));
        }

        return result;
    }

    public PageReference validate() {
        PageReference result;
        Concur_Error_Log_gne__c error = isBookmark();
        if (error != null) {
            insert error;
            result = new PageReference('/apex/concur_errorpage?errorCode=' + error.Error_Code_gne__c);
        }
        Concur_Error_Log_gne__c errorUrl = isValidURL();
        if (errorUrl != null) {
            insert errorUrl;
            result = new PageReference('/apex/concur_errorpage?errorCode=' + errorUrl.Error_Code_gne__c);
        }
        String strXUserID = ApexPages.currentPage().getParameters().get('xuserid');
        if (result == null) {
            String spendUserId = ApexPages.currentPage().getParameters().get(ownerPersistentId);
            if (String.isNotBlank(spendUserId)) {
                spendUserId = spendUserId.split('@').get(0);
            }
            initSpendUser(spendUserId);
        }
        insertLog('ConcurInteractionsCtrl', 'Sample URL for info', 'Sample URL', 'getIsBookmark', 'ConcurHCPMealController', 'URL', ApexPages.currentPage().getUrl(), strXUserID);
        return result;
    }

    @Future
    public static void insertLog(String className, String category, String message, String methodName, String objectName, String systemMessage, String content, String userId) {
        Concur_Error_Log_gne__c infoLog = new Concur_Error_Log_gne__c(Class_Name_gne__c = className,
                Error_Category_gne__c = category,
                Error_Message_gne__c = message,
                Method_Name_gne__c = methodName,
                Object_Name_gne__c = objectName,
                System_Error_Message_gne__c = systemMessage,
                Content_gne__c = content,
                Item_Url_gne__c = '',
                XUserID_gne__c = userId,
                Error_Code_gne__c = '');
        insert infoLog;
    }

    public Concur_Error_Log_gne__c isBookmark() {
        Concur_Error_Log_gne__c error = null;
        String strTime = ApexPages.currentPage().getParameters().get('TIMESTAMP');
        String strXUserID = ApexPages.currentPage().getParameters().get('xuserid');
        System.debug('-----strXUserID' + strXUserID);
        if (String.isNotBlank(strTime)) {
            Long bTime = Datetime.valueOf(strTime).getTime();
            Long bTimeNow = System.now().getTime();
            System.debug('Diff:' + (bTimeNow - bTime));
            if ((bTimeNow - bTime) > TIME_LIMIT) {
                error = new Concur_Error_Log_gne__c(Class_Name_gne__c = 'ConcurHCPMealController',
                        Error_Category_gne__c = 'bookmark',
                        Error_Message_gne__c = 'Problem with URL- Timestemp',
                        Method_Name_gne__c = 'getIsBookmark',
                        Object_Name_gne__c = 'ConcurHCPMealController',
                        System_Error_Message_gne__c = 'Invalid URL',
                        Content_gne__c = ApexPages.currentPage().getUrl(),
                        Item_Url_gne__c = '',
                        XUserID_gne__c = strXUserID,
                        Error_Code_gne__c = '800');
                return error;
            }
        }
        if (String.isNotBlank(strXUserID)) {
            for (String strId : strXUserID.split('@')) {
                List<All_User_Hierarchy_gne__c> listAUH = [SELECT User_External_Id_gne__c FROM All_User_Hierarchy_gne__c WHERE Persistent_Id_gne__c = :strId];
                if (listAUH.size() > 0) {
                    String strUser = listAUH[0].User_External_Id_gne__c;
                    for (String strUserId : UserInfo.getUserName().split('@')) {
                        if (strUserId == strUser) {
                            return null;
                        }
                    }
                }
            }
        }
        error = new Concur_Error_Log_gne__c(Class_Name_gne__c = 'ConcurHCPMealController',
                Error_Category_gne__c = 'bookmark',
                Error_Message_gne__c = 'Problem with URL- report creator is different',
                Method_Name_gne__c = 'getIsBookmark',
                Object_Name_gne__c = 'ConcurHCPMealController',
                System_Error_Message_gne__c = 'Invalid URL',
                Content_gne__c = ApexPages.currentPage().getUrl(),
                Item_Url_gne__c = '',
                XUserID_gne__c = strXUserID,
                Error_Code_gne__c = '800');
        return error;
    }

    public Concur_Error_Log_gne__c isValidURL() {
        Concur_Error_Log_gne__c error;
        String strAmount = ApexPages.currentPage().getParameters().get('Amount');
        String strDate = ApexPages.currentPage().getParameters().get('TransactionDate');
        String strXUserID = ApexPages.currentPage().getParameters().get('xuserid');
        System.debug('-----strXUserID' + strXUserID);
        String strError = '';
        Boolean bError = false;
        if (String.isNotBlank(strAmount)) {
            try {
                Double dAmount = Double.valueOf(strAmount);
                if (dAmount <= 0.000) {
                    bError = true;
                    strError = 'Amount is zero.';
                }
            } catch (System.TypeException e) {
                bError = true;
                strError = e.getMessage();
            }
        } else {
            bError = true;
            strError = 'Amount is null.';
        }
        if (!bError) {
            if (String.isNotBlank(strDate)) {
                try {
                    Date.valueOf(strDate);
                } catch (System.TypeException e) {
                    bError = true;
                    strError = e.getMessage();
                }
            } else {
                bError = true;
                strError = 'Date is null.';
            }
        }
        if (bError) {
            error = new Concur_Error_Log_gne__c(Class_Name_gne__c = 'ConcurHCPMealController',
                    Error_Category_gne__c = 'URL',
                    Error_Message_gne__c = 'No Amount or Date in URL',
                    Method_Name_gne__c = 'getIsValidURL',
                    Object_Name_gne__c = 'ConcurHCPMealController',
                    System_Error_Message_gne__c = 'Invalid URL: ' + strError,
                    Content_gne__c = ApexPages.currentPage().getUrl(),
                    Item_Url_gne__c = '',
                    XUserID_gne__c = strXUserID,
                    Error_Code_gne__c = '810');
        }
        return error;
    }

    @AuraEnabled
    public static String saveExpense(String interactionJSON, String expenseJSON, String ownerPersistentId) {
        System.debug('expenseJSON: ' + expenseJSON);
        System.debug('interactionJSON: ' + interactionJSON);
        Concur_Expense_gne__c expense = (Concur_Expense_gne__c) JSON.deserialize(expenseJSON, Concur_Expense_gne__c.class);
        RowWrapper interaction = (RowWrapper) JSON.deserialize(interactionJSON, RowWrapper.class);
        System.debug('Concur_Expense_gne__c: ' + expense);
        System.debug('saveInfo(): Creating new Concur_Expense_post_gne__c record...');
        Concur_Expense_Post_gne__c expenseRec = new Concur_Expense_Post_gne__c();
        expenseRec.Amount_gne__c = expense.Amount_gne__c;
        expenseRec.SFDC_Transaction_Date_gne__c = expense.Transaction_Date_gne__c;
        Integer attendeeCount = interaction.numOfAttendees;
        Decimal amountPerAttendee = 0.00;
        Decimal expenseAmount = 0.00;
        String strExpAmt = expense.Amount_gne__c;
        if (strExpAmt != null && strExpAmt != '') {
            expenseAmount = Decimal.valueOf(strExpAmt);
            expenseAmount.setScale(2);
        }
        if (expenseAmount > 0.00 && attendeeCount > 0) {
            amountPerAttendee = expenseAmount / attendeeCount;
            amountPerAttendee = amountPerAttendee.setScale(2);
        }

        expenseRec.SFDC_Attendee_Count_gne__c = attendeeCount;
        expenseRec.SFDC_Expense_Type_gne__c = expense.Expense_Type_gne__c;
        expenseRec.Business_Purpose__c = 'PP  $' + amountPerAttendee +
                ', # Planned ' + interaction.plannedAttendees +
                ', # Actual ' + interaction.actualAttendees +
                ', # HCPs ' + interaction.numOfHCPs +
                ', ' + (interaction.interactionType == 'In-Office' ? 'In-Off' : 'Out-Off' );

        expenseRec.Interaction_Name_Aprimo_Site_ID_gne__c = interaction.interactionName;
        expenseRec.Expense_Status_gne__c = 'Link complete';
        expenseRec.ExpKey_gne__c = expense.ExpKey_gne__c;
        expenseRec.Item_Url_gne__c = expense.Item_Url_gne__c;

        expenseRec.Transaction_Amount_gne__c = expense.Transaction_Amount_gne__c;
        expenseRec.XUserID_gne__c = expense.XUserID_gne__c;
        expenseRec.Expence_Location_gne__c = expense.Expence_Location_gne__c;
        System.debug('expenseRec: ' + expenseRec);
        System.debug('saveInfo(): Inserted Concur_Expense_post_gne__c record...');
        Concur_WebServicesCalls wsCall = new Concur_WebServicesCalls();
        System.debug('saveInfo(): Before postExpenseReport webservice call...');
        String postStatus = wsCall.postExpenseReport(expenseRec, expense.XUserID_gne__c, ownerPersistentId);
        insert expense;
        expenseRec.Concur_Expense_gne__c = expense.Id;
        expenseRec.Web_service_status_gne__c = postStatus;
        insert expenseRec;
        System.debug('saveInfo(); After postExpenseReport webservice call...');
        System.debug('postStatus: ' + postStatus);
        if (!postStatus.contains('SUCCESS')) {
            throw new InteractionException('Cannot save interaction in Concur.');
        }
        return postStatus;
    }

    class InteractionException extends Exception {

    }

// sub class to display rows in the list
    public class RowWrapper {
        @AuraEnabled
        public String interactionName {
            get;
            set;
        }

        @AuraEnabled
        public String interactionType {
            get;
            set;
        }

        @AuraEnabled
        public String interactionId {
            get;
            set;
        }
        @AuraEnabled
        public String accountName {
            get;
            set;
        }
        @AuraEnabled
        public String childAccount {
            get;
            set;
        }
        @AuraEnabled
        public String interactionDate { get; set; }
        @AuraEnabled
        public String interactionRecordType {
            get;
            set;
        }
        @AuraEnabled
        public String type {
            get;
            set;
        }
        @AuraEnabled
        public Integer plannedAttendees {
            get;
            set;
        }
        @AuraEnabled
        public Integer actualAttendees {
            get;
            set;
        }
        @AuraEnabled
        public Integer numOfAttendees {
            get;
            set;
        }
        @AuraEnabled
        public Integer numOfHCPs {
            get;
            set;
        }

        public RowWrapper(Call2_vod__c call) {
            this.interactionName = call.Name;
            this.interactionId = call.Id;
            this.interactionDate = call.Call_Datetime_vod__c.date().format();
            this.accountName = call.Account_vod__r.Name;
            this.interactionRecordType = call.RecordType.DeveloperName;
            List<Call2_vod__c> child = call.Call2_vod__r;
            if (child != null && child.size() > 0) {
                this.childAccount = child[0].Account_vod__r.Name;
            }
            this.actualAttendees = call.Actual_Attendees_gne__c != null ? Integer.valueOf(call.Actual_Attendees_gne__c) : 0;
            this.plannedAttendees = Integer.valueOf(call.Planned_Attendees_gne__c);
            this.numOfHCPs  = Integer.valueOf(call.Customers_gne__c);
            this.numOfAttendees = Math.max(this.actualAttendees, this.plannedAttendees);
            this.type = INTERACTION_TYPE;
            this.interactionType = call.Interaction_Type_gne__c;
        }

        public RowWrapper(Call_No_Show_Spend__c call) {
            this.interactionName = call.Name;
            this.interactionId = call.Id;
            this.interactionDate = call.Transaction_Date__c.format();
            this.actualAttendees = Integer.valueOf(call.Actual_Attendees__c);
            this.plannedAttendees = Integer.valueOf(call.Planned_Attendees__c);
            this.numOfAttendees = Math.max(this.actualAttendees, this.plannedAttendees);
            this.numOfHCPs = 0;
            this.type = NO_SHOW_TYPE;
        }
    }
}