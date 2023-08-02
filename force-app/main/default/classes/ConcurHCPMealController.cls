/**  
* Class: ConcurHCPMealController
* Description: Controller class for visual force page ConcurHCPMeal
**/
public class ConcurHCPMealController {

    //constructor    
    public ConcurHCPMealController() {
        bPageWait = true;
    }
    public Concur_Error_Log_gne__c error;
    public Concur_Error_Log_gne__c InfoLog;
    public static Boolean USE_LIGHTNING = true;
    public static Boolean getUSE_LIGHTNING() {
        return USE_LIGHTNING;
    }

    public Boolean getIsBookmark() {
        String strTime = ApexPages.currentPage().getParameters().get('TIMESTAMP');
        String strXUserID = ApexPages.currentPage().getParameters().get('xuserid');
        System.debug('-----strXUserID' + strXUserID);
        if (false && (strTime != null && strTime != '')) {

            Datetime dt = Datetime.valueOf(strTime);
            Datetime dtNow = System.now();
            Long bTime = dt.getTime();
            System.debug('Long Time:' + bTime);
            Long bTimeNow = dtNow.getTime();
            System.debug('Long Time Now:' + bTimeNow);
            System.debug('Diff:' + (bTimeNow - bTime));
            if ((bTimeNow - bTime) > 90000) {
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
//                return true;
            }
        }
        if (strXUserID != null && strXUserID != '') {
            for (String strId : strXUserID.split('@')) {
                List<All_User_Hierarchy_gne__c> listAUH = [SELECT User_External_Id_gne__c FROM All_User_Hierarchy_gne__c WHERE Persistent_Id_gne__c = :strId];
                if (listAUH.size() > 0) {
                    String strUser = listAUH[0].User_External_Id_gne__c;
                    for (String strUserId : UserInfo.getUserName().split('@')) {
                        if (strUserId == strUser) {
                            return false;
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
        return true;
    }

    public PageReference doWindowOpenError() {
        String strXUserID = ApexPages.currentPage().getParameters().get('xuserid');
        System.debug('-----strXUserID' + strXUserID);
        error = new Concur_Error_Log_gne__c(Class_Name_gne__c = 'ConcurHCPMealController',
                Error_Category_gne__c = 'bookmark',
                Error_Message_gne__c = 'Problem with URL- Window Opener',
                Method_Name_gne__c = 'getIsBookmark',
                Object_Name_gne__c = 'ConcurHCPMealController',
                System_Error_Message_gne__c = 'Invalid URL',
                Content_gne__c = ApexPages.currentPage().getUrl(),
                Item_Url_gne__c = '',
                XUserID_gne__c = strXUserID,
                Error_Code_gne__c = '801');
        insert error;
        return new PageReference('/apex/concur_errorpage?errorCode=801');
    }

    public Boolean getIsValidURL() {
        String strAmount = ApexPages.currentPage().getParameters().get('Amount');
        String strDate = ApexPages.currentPage().getParameters().get('TransactionDate');
        String strXUserID = ApexPages.currentPage().getParameters().get('xuserid');
        System.debug('-----strXUserID' + strXUserID);
        String strError = '';
        Boolean bError = false;
        if (strAmount != null && strAmount != '') {
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
            if (strDate != null && strDate != '') {
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
        if (!bError) {
            return false;
        }
        error = new Concur_Error_Log_gne__c(Class_Name_gne__c = 'ConcurHCPMealController',
                Error_Category_gne__c = 'URL',
                Error_Message_gne__c = 'No Amout 0r Date in URL',
                Method_Name_gne__c = 'getIsValidURL',
                Object_Name_gne__c = 'ConcurHCPMealController',
                System_Error_Message_gne__c = 'Invalid URL: ' + strError,
                Content_gne__c = ApexPages.currentPage().getUrl(),
                Item_Url_gne__c = '',
                XUserID_gne__c = strXUserID,
                Error_Code_gne__c = '810');
        return true;
    }

    public void LogError() {
        if (error != null) {
            insert error;
        }
    }
    // sub class to display rows in the list
    public class Results {
        public Boolean Selected { get; set; }
        public Call2_vod__c resultItem { get; set; }
        public String InteractionDate { get; set; }
        public String ChildAccount { get; set; }
        public Integer NumOfAttendees { get; set; }
        public Decimal AmountPerAttendee { get; set; }
    }

    // Concur_Expense_gne__c object to be stored from the URL parameters
    public Concur_Expense_gne__c objConCurExpense {
        get {
            if (objConCurExpense == null) {
                objConCurExpense = new Concur_Expense_gne__c();
            }
            return objConCurExpense;
        }
        set;
    }

    // Records displayed on visual force page table
    public List<Results> AllResults = new List<Results>();

    // Records place holder when no records from SOQL result
    public List<Results> dummyResults {
        get {
            if (dummyResults == null) {
                dummyResults = new List<Results>();
                Integer nCount = 0;
                for (nCount = 0; nCount < 6; nCount++) {
                    Results ee = new Results();
                    ee.Selected = false;
                    ee.resultItem = new Call2_vod__c();
                    ee.resultItem.Call_Datetime_vod__c = System.now();
                    ee.InteractionDate = null;
                    dummyResults.add(ee);
                }
            }
            return dummyResults;
        }
        set;
    }

    public List<Call2_vod__c> resultItems = new List<Call2_vod__c>();
    public Integer numOfMatchesFound { get; set; }
    public Integer numOfAttendees { get; set; }
    public String AmountperAttendee { get; set; }
    public Integer AttendeeCount { get; set; }
    public String startDateParam { get; set; }
    public String endDateParam { get; set; }
    public String spendUserAlias { get; set; }

    //private method to get expense date
    private Date getURLTransactionDate(String dateString) {
        String day = dateString.substring(dateString.lastIndexOf('-') + 1, dateString.length());
        String month = dateString.substring(dateString.indexOf('-') + 1, dateString.lastIndexOf('-'));
        String year = dateString.substring(0, dateString.indexOf('-'));
        String validDate = month + '/' + day + '/' + year;
        System.debug('------------valid date: ' + validDate);
        return Date.parse(validDate);
    }
    public Concur_Expense_gne__c CreateExpenseObject() {
        String strReportOwner = ApexPages.currentPage().getParameters().get('ReportOwner');
        System.debug('------------Report Owner: ' + strReportOwner);
        objConCurExpense = new Concur_Expense_gne__c();
        if (ApexPages.currentPage().getParameters().containsKey('ExpenseType')) {
            objConCurExpense.Expense_Type_gne__c = ApexPages.currentPage().getParameters().get('ExpenseType');
        }
        System.debug('------------Expense Type: ' + objConCurExpense.Expense_Type_gne__c);
        if (ApexPages.currentPage().getParameters().containsKey('ExpKey')) {
            objConCurExpense.ExpKey_gne__c = ApexPages.currentPage().getParameters().get('ExpKey');
        }
        System.debug('------------ExpKey: ' + objConCurExpense.ExpKey_gne__c);
        if (ApexPages.currentPage().getParameters().containsKey('itemurl')) {
            objConCurExpense.Item_Url_gne__c = ApexPages.currentPage().getParameters().get('itemurl');
        }
        System.debug('------------Item Url: ' + objConCurExpense.Item_Url_gne__c);
        System.debug('------------Report Creator: ' + ApexPages.currentPage().getParameters().get('ReportCreator'));
        if (ApexPages.currentPage().getParameters().containsKey('ReportCreator')) {
            if (ApexPages.currentPage().getParameters().get('ReportCreator') != 'null') {
                objConCurExpense.Report_Creator_gne__c = ApexPages.currentPage().getParameters().get('ReportCreator');
            }
        }
        if (ApexPages.currentPage().getParameters().containsKey('ReportOwner')) {
            if (ApexPages.currentPage().getParameters().get('ReportOwner') != 'null') {
                objConCurExpense.Report_Owner_gne__c = ApexPages.currentPage().getParameters().get('ReportOwner');
            }
        }
        if (ApexPages.currentPage().getParameters().containsKey('TransactionAmount')) {
            objConCurExpense.Transaction_Amount_gne__c = ApexPages.currentPage().getParameters().get('TransactionAmount');
        }
        System.debug('------------Transaction Amount: ' + objConCurExpense.Transaction_Amount_gne__c);
        if (ApexPages.currentPage().getParameters().containsKey('Amount')) {
            objConCurExpense.Amount_gne__c = ApexPages.currentPage().getParameters().get('Amount');
        }
        System.debug('------------Amount: ' + objConCurExpense.Amount_gne__c);
        if (ApexPages.currentPage().getParameters().containsKey('TransactionDate')) {
            objConCurExpense.Transaction_Date_gne__c = getURLTransactionDate(ApexPages.currentPage().getParameters().get('TransactionDate'));
        }
        System.debug('------------Transaction Date: ' + objConCurExpense.Transaction_Date_gne__c);
        if (ApexPages.currentPage().getParameters().containsKey('XUserID')) {
            objConCurExpense.XUserID_gne__c = ApexPages.currentPage().getParameters().get('XUserID');
        }
        System.debug('------------XUserID: ' + objConCurExpense.XUserID_gne__c);
        if (ApexPages.currentPage().getParameters().containsKey('LocationName')) {
            objConCurExpense.Expence_Location_gne__c = ApexPages.currentPage().getParameters().get('LocationName');
        }
        Id AliasId = objConCurExpense.Report_Owner_gne__c;
        if (AliasId == null) {
            // AliasId = '';
        }
        Alias = AliasId;
        spendUserAlias = '';
        if (AliasId != null) {
            List<User> listUsers = [SELECT Id, Alias FROM User WHERE Id = :AliasId LIMIT 1];
            if (listUsers.size() > 0) {
                spendUserAlias = listUsers[0].Alias;
            }
        }
        Date prevDay = Date.parse(getTransactionDate()).addDays(-2);
        startDateParam = prevDay.year() + '-' + prevDay.month() + '-' + prevDay.day();
        Date nextDay = Date.parse(getTransactionDate()).addDays(1);
        endDateParam = nextDay.year() + '-' + nextDay.month() + '-' + nextDay.day();
        return objConCurExpense;
    }

    // Record list for visual force page
    public List<Results> getAllResults() {
        // Do not process SOQL if the list is already populated
        if (AllResults.size() > 0) {
            return AllResults;
        }
        // Page refresh
        CreateExpenseObject();

        System.debug('getAllResults: ' + 'TransactionDate: ' + getTransactionDate() + ' Alias: ' + Alias);

        if (getTransactionDate() == null || Alias == null || getTransactionDate() == '' || Alias == '') {
            System.debug('------------Error in params');
            return AllResults;
        }
        //RunQuery();
        return AllResults;
    }

    public Boolean bPageWait { get; set; }
    public PageReference RunQuery() {
        system.debug('lk run query');
        bPageWait = false;
        if (getTransactionDate() == null || Alias == null || getTransactionDate() == '' || Alias == '') {
            System.debug('------------Error in params');
            return null;
        }
        Date prevDay = Date.parse(getTransactionDate()).addDays(-2000);
        Date nextDay = Date.parse(getTransactionDate()).addDays(100);
        System.debug('---prevDay: ' + prevDay);
        System.debug('---nextDay: ' + nextDay);
        System.debug('---Alias: ' + Alias);
        /* SHASHI START*/
        resultItems = [
                SELECT Name, Actual_Attendees_gne__c, Call_Datetime_vod__c,
                        Spend_User_gne__c, Account_vod__r.Name,
                        Planned_Attendees_gne__c, Account_vod__c, Parent_Call_vod__c,
                        Id, Spend_User_gne__r.Alias, RecordType.Name, (SELECT Account_vod__r.Name FROM Call2_vod__r WHERE Account_vod__r.Name != '' ORDER BY Account_vod__r.LastName LIMIT 1)
                FROM Call2_vod__c
                WHERE Parent_Call_vod__c = NULL AND IsDeleted = FALSE AND Interaction_Status_gne__c = 'Completed'
                AND Actual_Attendees_gne__c > 0
                AND DAY_ONLY(convertTimezone(Call_Datetime_vod__c)) >= :prevDay AND
                DAY_ONLY(convertTimezone(Call_Datetime_vod__c)) <= :nextDay
                AND (Spend_User_gne__c = :Alias OR OwnerId = :Alias)
                ORDER BY Call_Datetime_vod__c
        ];
        /* SHASHI END*/

        numOfMatchesFound = resultItems.size();
        System.debug('------------No. of records: ' + numOfMatchesFound);
        Integer i;
        i = 0;
        Decimal expenseAmount = 0.00;
        numOfAttendees = 0;
        AmountperAttendee = '0.00';
        String strExpAmt;
        if (objConCurExpense != null) {
            strExpAmt = objConCurExpense.Amount_gne__c;
        }
        Boolean bAmountFound = false;
        if (strExpAmt != null && strExpAmt != '') {
            expenseAmount = Decimal.valueOf(strExpAmt);
            expenseAmount.setScale(2);
            if (expenseAmount > 0.00) {
                bAmountFound = true;
            }
        }
        for (Call2_vod__c temp : resultItems) {
            Results ee = new Results();
            ee.Selected = false;
            ee.resultItem = temp;
            ee.InteractionDate = String.valueOf(temp.Call_Datetime_vod__c.date());
            ee.InteractionDate = temp.Call_Datetime_vod__c.date().format();

            List<Call2_vod__c> child = temp.Call2_vod__r;
            if (child != null && child.size() > 0) {
                ee.ChildAccount = child[0].Account_vod__r.Name;
            }
            if (resultItems[i].Actual_Attendees_gne__c != null && resultItems[i].Actual_Attendees_gne__c > resultItems[i].Planned_Attendees_gne__c) {
                ee.NumOfAttendees = Integer.valueOf(resultItems[i].Actual_Attendees_gne__c);
            } else {
                ee.NumOfAttendees = Integer.valueOf(resultItems[i].Planned_Attendees_gne__c);
            }

            if (expenseAmount > 0.00 && ee.NumOfAttendees > 0) {
                ee.AmountPerAttendee = expenseAmount / ee.NumOfAttendees;
            }
            AllResults.add(ee);
            i++;
        }
        return null;

    }

    //get all the entries with transaction date between +/-1 day from given transaction date
    public String getTransactionDateWithFormatting() {
        if (objConCurExpense != null) {
            Date d = objConCurExpense.Transaction_Date_gne__c;
            return d.format();
        }
        return null;
    }
    public String getTransactionDate() {
        if (objConCurExpense != null) {
            return objConCurExpense.Transaction_Date_gne__c.format();
        }
        return null;
    }

    public String Alias {
        get {
            if (Alias == null) {
                if (objConCurExpense != null) {
                    Alias = objConCurExpense.Report_Owner_gne__c;
                    if (Alias == null || Alias == '') {
                        Alias = objConCurExpense.Report_Creator_gne__c;
                    }
                }
            }
            return Alias;
        }
        set;
    }

    // Calculate expense amount per attendee and total expense displayed on page
    public String getExpenseAmount() {
        Decimal expenseAmount = 0.00;
        numOfAttendees = 0;
        AmountperAttendee = '0.00';
        String strExpAmt;
        if (objConCurExpense != null) {
            strExpAmt = objConCurExpense.Amount_gne__c;
        }
        Boolean bAmountFound = false;
        if (strExpAmt != null && strExpAmt != '') {
            expenseAmount = Decimal.valueOf(strExpAmt);
            expenseAmount = expenseAmount.setScale(2);
            if (expenseAmount > 0.00) {
                bAmountFound = true;
            }
        }
        for (Results objResult : AllResults) {
            if (objResult.Selected == true) {
                numOfAttendees = objResult.NumOfAttendees;
                AttendeeCount = numOfAttendees;
                if (objResult.AmountPerAttendee == null) {
                    return 'null';
                }
                Decimal temp = objResult.AmountPerAttendee;
                temp = temp.setScale(2);
                AmountperAttendee = String.valueOf(temp);
                break;
            }
        }
        System.debug('---------- Expense Amount: ' + String.valueOf(expenseAmount.setScale(2)));
        return String.valueOf(expenseAmount.setScale(2));
    }

    // Popup display property used on page
    public Boolean displayPopup { get; set; }

    // set display property to hide popup
    public void closePopup() {
        displayPopup = false;
    }

    // set display property to show popup
    public PageReference openPopup() {
        displayPopup = true;
        String expenseAmountResult = getExpenseAmount();
        if (expenseAmountResult == 'null') {
            error = new Concur_Error_Log_gne__c(Class_Name_gne__c = 'ConcurHCPMealController',
                    Error_Category_gne__c = 'Amount 0.00',
                    Error_Message_gne__c = 'Problem with Amount',
                    Method_Name_gne__c = 'RunQuery',
                    Object_Name_gne__c = 'ConcurHCPMealController',
                    System_Error_Message_gne__c = 'Amount equals 0',
                    Content_gne__c = ApexPages.currentPage().getUrl(),
                    Item_Url_gne__c = '',
                    XUserID_gne__c = ApexPages.currentPage().getParameters().get('XUserID'),
                    Error_Code_gne__c = '802');
            insert error;
            return new PageReference('/apex/concur_errorpage?errorCode=802');
        }
        PageReference currPage = ApexPages.currentPage();
        currPage.getParameters().putAll(ApexPages.currentPage().getParameters());
        System.debug('-------- Refresh page on popup');
        return null;
    }

    // Refresh page on popup window close for transaction create/edit    
    public PageReference RefreshPage() {
        PageReference currPage = ApexPages.currentPage();
        String TimeStamp = String.valueOf(System.now().year());
        TimeStamp += '-' + System.now().monthGmt();
        TimeStamp += '-' + System.now().dayGmt();
        Datetime dtNow = System.now();
        TimeStamp += ' ' + dtNow.hourGmt();
        TimeStamp += ':' + dtNow.minuteGmt();
        TimeStamp += ':' + dtNow.secondGmt();
        currPage.getParameters().putAll(ApexPages.currentPage().getParameters());
        currPage.getParameters().put('TIMESTAMP', TimeStamp);
        currPage.setRedirect(true);
        return currPage;
    }

    // CallStatus property used on page to close the main window
    public String CallStatus { get; set; }

    // Function to save the transaction and close the window
    public PageReference saveInfo() {
        displayPopup = false;
        try {
            System.debug('saveInfo(): Insert Concur_Expense_gne__c record...');
            //insert objConcurExpense;
            System.debug('saveInfo(): Insert record Concur_Expense_gne__c...');
            Concur_Expense_Post_gne__c expenseRec = null;
            for (Results objResult : AllResults) {
                if (objResult.Selected == true) {
                    System.debug('saveInfo(): Creating new Concur_Expense_post_gne__c record...');
                    expenseRec = new Concur_Expense_Post_gne__c();
                    expenseRec.Amount_gne__c = objConCurExpense.Amount_gne__c;
                    expenseRec.SFDC_Transaction_Date_gne__c = objConCurExpense.Transaction_Date_gne__c;
                    expenseRec.SFDC_Attendee_Count_gne__c = AttendeeCount;
                    expenseRec.SFDC_Expense_Type_gne__c = objConCurExpense.Expense_Type_gne__c;
                    getExpenseAmount();
                    expenseRec.Business_Purpose__c = AttendeeCount.format() + ' Attendees $' +
                            AmountperAttendee + '/pp ' +
                            objResult.resultItem.Account_vod__r.Name;
                    expenseRec.Interaction_Name_Aprimo_Site_ID_gne__c = objResult.resultItem.Name;
                    expenseRec.Expense_Status_gne__c = 'Link complete';
                    expenseRec.ExpKey_gne__c = objConCurExpense.ExpKey_gne__c;
                    expenseRec.Item_Url_gne__c = objConCurExpense.Item_Url_gne__c;
                    expenseRec.Transaction_Amount_gne__c = objConCurExpense.Transaction_Amount_gne__c;
                    expenseRec.XUserID_gne__c = objConCurExpense.XUserID_gne__c;
                    expenseRec.Expence_Location_gne__c = objConCurExpense.Expence_Location_gne__c;
                    break;
                }
            }
            if (expenseRec != null) {
                System.debug('saveInfo(): Inserting Concur_Expense_post_gne__c record...');
                System.debug('saveInfo(): Inserted Concur_Expense_post_gne__c record...');
                Concur_WebServicesCalls wsCall = new Concur_WebServicesCalls();
                CallStatus = 'SUCCESS';
                System.debug('saveInfo(): Before postExpenseReport webservice call...');
                CallStatus = wsCall.postExpenseReport(expenseRec, objConCurExpense.XUserID_gne__c, ApexPages.currentPage().getParameters().get('OwnerPersId'));
                insert objConCurExpense;
                expenseRec.Concur_Expense_gne__c = objConCurExpense.Id;
                expenseRec.Web_service_status_gne__c = CallStatus;
                insert expenseRec;
                System.debug('saveInfo(); After postExpenseReport webservice call...');
                if (!CallStatus.contains('SUCCESS')) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, CallStatus));
                }
                if (!CallStatus.contains('SUCCESS')) {
                    displayPopup = false;
                    PageReference errorPage = Page.Concur_ErrorPage;
                    errorPage.getParameters().put('errorCode', '900');
                    errorPage.setRedirect(true);
                    System.debug('-------- Web service call to post transaction not successfull.');
                    return errorPage;
                }
            }
        } catch (System.DmlException e) {
            System.debug('Exception in SaveInfo: ' + e.getMessage());
        } catch (System.NullPointerException e) {
            System.debug('Exception in SaveInfo: ' + e.getMessage());
        }
        return null;
    }
    public void doInsert() {

        if (getIsBookmark()) {
            LogError();
        }

        if (getIsValidURL()) {
            LogError();
        }

        String strXUserID = ApexPages.currentPage().getParameters().get('xuserid');
        InfoLog = new Concur_Error_Log_gne__c(Class_Name_gne__c = 'ConcurHCPMealController',
                Error_Category_gne__c = 'Sample URL for info',
                Error_Message_gne__c = 'Sample URL',
                Method_Name_gne__c = 'getIsBookmark',
                Object_Name_gne__c = 'ConcurHCPMealController',
                System_Error_Message_gne__c = 'URL',
                Content_gne__c = ApexPages.currentPage().getUrl(),
                Item_Url_gne__c = '',
                XUserID_gne__c = strXUserID,
                Error_Code_gne__c = '');
        insert InfoLog;
    }
}