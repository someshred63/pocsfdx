public with sharing class ConcurHCPProgramLogistics {

    public ConcurHCPProgramLogistics(){
        bPageWait = true;
    }
   
    public class Result{
        public Boolean Selected {get; set; }
        public Event_Attendee_vod__c resultItem {get; set;}
    }
    
    public Concur_Error_Log_gne__c error;
    public Concur_Error_Log_gne__c InfoLog;
    
    public Boolean getIsBookmark(){
        String strTime = ApexPages.currentPage().getParameters().get('TIMESTAMP');
        String strXUserID = ApexPages.currentPage().getParameters().get('xuserid');
        if (strTime != null && strTime != ''){

            DateTime dt = DateTime.valueOf(strTime);
            DateTime dtNow = System.now();
            Long bTime = dt.getTime();
            Long bTimeNow = dtNow.getTime();
            if ((bTimeNow - bTime) > 90000){
                error = new Concur_Error_Log_gne__c(Class_Name_gne__c='ConcurHCPMealController', 
                                                                            Error_Category_gne__c='bookmark',
                                                                            Error_Message_gne__c='Problem with URL- Timestemp',
                                                                            Method_Name_gne__c= 'getIsBookmark', 
                                                                            Object_Name_gne__c='ConcurHCPMealController',
                                                                            System_Error_Message_gne__c='Invalid URL',
                                                                            Content_gne__c=ApexPages.currentPage().getURL(),
                                                                            Item_Url_gne__c='',
                                                                            XUserID_gne__c=strXUserID,
                                                                            Error_Code_gne__c='800');
               return true;
            }
        }
        if (strXUserID != null && strXUserID != ''){
            for(String strId : strXUserID.split('@')){
                List<All_User_Hierarchy_gne__c> listAUH = [Select User_External_Id_gne__c From All_User_Hierarchy_gne__c Where Persistent_Id_gne__c = :strId];
                if (listAUH.size() > 0){
                    String strUser = listAUH[0].User_External_Id_gne__c;
                    for(String strUserId : UserInfo.getUserName().split('@')){
                        if (strUserId == strUser){
                            return false;
                        }
                    }
                }
            }
        }
        error = new Concur_Error_Log_gne__c(Class_Name_gne__c='ConcurHCPMealController', 
                                                                    Error_Category_gne__c='bookmark',
                                                                    Error_Message_gne__c='Problem with URL- report creator is different',
                                                                    Method_Name_gne__c= 'getIsBookmark', 
                                                                    Object_Name_gne__c='ConcurHCPMealController',
                                                                    System_Error_Message_gne__c='Invalid URL',
                                                                    Content_gne__c=ApexPages.currentPage().getURL(),
                                                                    Item_Url_gne__c='',
                                                                    XUserID_gne__c=strXUserID,
                                                                    Error_Code_gne__c='800');
        return true;
      }
      public PageReference doWindowOpenError(){
        String strTime = ApexPages.currentPage().getParameters().get('TIMESTAMP');
        String strXUserID = ApexPages.currentPage().getParameters().get('xuserid');
        system.debug('-----strXUserID'+strXUserID );
        error = new Concur_Error_Log_gne__c(Class_Name_gne__c='ConcurHCPMealController', 
                                                                    Error_Category_gne__c='bookmark',
                                                                    Error_Message_gne__c='Problem with URL- Window Opener',
                                                                    Method_Name_gne__c= 'getIsBookmark', 
                                                                    Object_Name_gne__c='ConcurHCPMealController',
                                                                    System_Error_Message_gne__c='Invalid URL',
                                                                    Content_gne__c=ApexPages.currentPage().getURL(),
                                                                    Item_Url_gne__c='',
                                                                    XUserID_gne__c=strXUserID,
                                                                    Error_Code_gne__c='800');
        insert error;
        return new PageReference('/apex/concur_errorpage?errorCode=800');
    }
      
      public Boolean getIsValidURL(){
        String strAmount = ApexPages.currentPage().getParameters().get('Amount');
        String strDate = ApexPages.currentPage().getParameters().get('TransactionDate');
        String strXUserID = ApexPages.currentPage().getParameters().get('xuserid');
        system.debug('-----strXUserID'+strXUserID );
        String strError = '';
        Boolean bError = false;
        if (strAmount != null && strAmount != ''){
            try{
                Double dAmount = Double.valueOf(strAmount);
                if(dAmount <= 0.000){
                    bError = true;
                    strError = 'Amount is zero.';
                }
            }
            catch(System.TypeException e){
                bError = true;
                strError = e.getMessage();
            }
        }
        else{
            bError = true;
            strError = 'Amount is null.';
        }
        if (!bError){
            if (strDate != null && strDate != ''){
                try{
                    Date dt = Date.valueOf(strDate);
                }
                catch(System.TypeException e){
                    bError = true;
                    strError = e.getMessage();
                }
            }
            else{
                bError = true;
                strError = 'Date is null.';
            }
        }
        if (!bError){
            return false;
        }
        error = new Concur_Error_Log_gne__c(Class_Name_gne__c='ConcurHCPMealController', 
                                                                    Error_Category_gne__c='URL',
                                                                    Error_Message_gne__c='Problem with URL',
                                                                    Method_Name_gne__c= 'getIsValidURL', 
                                                                    Object_Name_gne__c='ConcurHCPMealController',
                                                                    System_Error_Message_gne__c='Invalid URL: ' + strError,
                                                                    Content_gne__c=ApexPages.currentPage().getURL(),
                                                                    Item_Url_gne__c='',
                                                                    XUserID_gne__c=strXUserID,
                                                                    Error_Code_gne__c='810');
        return true;
      }
    public void LogError(){
          if(error != null){
              insert error;
          }   
      }
    public Concur_Expense_gne__c objConCurExpense{
        get{
            if (objConcurExpense == null){
                objConcurExpense = new Concur_Expense_gne__c();
            }
            return objConcurExpense;
        }
        set;
    }
    
    private Date getURLTransactionDate(String dateString)
    {
            if (dateString != null && dateString != ''){
            String day = dateString.substring(dateString.lastIndexOf('-')+1,dateString.length());
            String month = dateString.substring(dateString.indexOf('-')+1,dateString.lastIndexOf('-'));
            String year = dateString.substring(0,dateString.indexOf('-'));
            String validDate = month + '/' + day + '/' + year;
            system.debug('------------validdate'+validDate);
            return date.parse(validDate);
        }
        return System.today();
    }
    
    public list<Result> resultItems = new list<Result>();
    public Integer numOfMatchesFound {get; set;}
    public boolean displayPopup {get; set;}
    
    public list<Result> dummyResults{
        get{
            if (dummyResults == null){
                dummyResults = new list<Result>();
                Integer nCount = 0;
                for (nCount = 0; nCount < 6; nCount++){
                    Result ee = new Result();
                    ee.resultItem = new Event_Attendee_vod__c();
                    dummyResults.add(ee);
                }
            }
            return dummyResults;
        }
        set;
    }
    
    public Concur_Expense_gne__c CreateExpenseObject(){
        String  strReportOwner = ApexPages.currentPage().getParameters().get('ReportOwner');

        objConcurExpense = new Concur_Expense_gne__c();
        if (ApexPages.currentPage().getParameters().containsKey('ExpenseType'))
            objConcurExpense.Expense_Type_gne__c = ApexPages.currentPage().getParameters().get('ExpenseType');
        if (ApexPages.currentPage().getParameters().containsKey('ExpKey'))
            objConcurExpense.ExpKey_gne__c = ApexPages.currentPage().getParameters().get('ExpKey');
        if (ApexPages.currentPage().getParameters().containsKey('itemurl'))
            objConcurExpense.Item_Url_gne__c = ApexPages.currentPage().getParameters().get('itemurl');
        if (ApexPages.currentPage().getParameters().containsKey('ReportCreator')){
            if (ApexPages.currentPage().getParameters().get('ReportCreator') != 'null')
                objConcurExpense.Report_Creator_gne__c = ApexPages.currentPage().getParameters().get('ReportCreator');
        }
        if (ApexPages.currentPage().getParameters().containsKey('ReportOwner')){
            if (ApexPages.currentPage().getParameters().get('ReportOwner') != 'null')
                objConcurExpense.Report_Owner_gne__c = ApexPages.currentPage().getParameters().get('ReportOwner');
        }
        if (ApexPages.currentPage().getParameters().containsKey('TransactionAmount'))
            objConcurExpense.Transaction_Amount_gne__c = ApexPages.currentPage().getParameters().get('TransactionAmount');
        if (ApexPages.currentPage().getParameters().containsKey('Amount'))
            objConcurExpense.Amount_gne__c = ApexPages.currentPage().getParameters().get('Amount');
        if (ApexPages.currentPage().getParameters().containsKey('TransactionDate'))
            objConcurExpense.Transaction_Date_gne__c = getURLTransactionDate(ApexPages.currentPage().getParameters().get('TransactionDate'));
        if (ApexPages.currentPage().getParameters().containsKey('XUserID'))
            objConcurExpense.XUserID_gne__c = ApexPages.currentPage().getParameters().get('XUserID');
        if (ApexPages.currentPage().getParameters().containsKey('LocationName'))
            objConcurExpense.Expence_Location_gne__c = ApexPages.currentPage().getParameters().get('LocationName');
        Id AliasId = objConcurExpense.Report_Owner_gne__c;
        Alias = AliasId;
        return objConcurExpense;
    }
    
    public Boolean bPageWait{get; set;}
    public list<Result> getresultItems(){
        // Do not process SOQL if the list is already populated
        if (resultItems.size() > 0)
            return resultItems;
        CreateExpenseObject();
        System.debug('getAllResults: ' + 'TransactionDate: ' + getTransactionDate() + ' Alias: ' + Alias);

        if (getTransactionDate() == null || Alias == null || getTransactionDate() == '' || Alias == ''){
            return resultItems;
        }
        Date prevDay = date.parse(getTransactionDate()).addDays(-2);
        Date nextDay = Date.parse(getTransactionDate()).addDays(1);
        return resultItems;
    }
    
    public PageReference RunQuery(){
        bPageWait = false;
        System.debug('getAllResults: ' + 'TransactionDate: ' + getTransactionDate() + ' Alias: ' + Alias);

        if (getTransactionDate() == null || Alias == null || getTransactionDate() == '' || Alias == ''){
            return null;
        }
        Date prevDay = date.parse(getTransactionDate()).addDays(-2);
        Date nextDay = Date.parse(getTransactionDate()).addDays(1);
        for(List<Event_Attendee_vod__c> items : [select Id, Name, Status_vod__c, Medical_Event_vod__c, Attendee_vod__c, 
                                                    User_vod__c, Account_vod__c, Attendee_Type_vod__c, 
                                                    Event_Attendee_External_Id_gne__c, Start_Date_vod__c, Event_Name_gne__c,
                                                    Event_Type_gne__c, Start_Date_gne__c, Event_Status_gne__c, 
                                                    Medical_Event_vod__r.site_id_gne__c, Medical_Event_vod__r.name, 
                                                    Medical_Event_vod__r.location_gne__c, 
                                                    Medical_Event_vod__r.start_date_vod__c, Medical_Event_vod__r.city_name_gne__c, 
                                                    Medical_Event_vod__r.state_province_code_gne__c, User_vod__r.Alias  
                                                    From Event_Attendee_vod__c 
                                                    Where Medical_Event_vod__r.Event_Type_gne__c='Speaker Program' and 
                                                    Medical_Event_vod__r.status_gne__c in ('Occurred', 'Closed', 'Cancelled') and 
                                                    User_vod__c = :Alias and Medical_Event_vod__r.Parent_Medical_Event_gne__c != null and  
                                                    Medical_Event_vod__r.start_date_vod__c >= :prevDay and 
                                                    Medical_Event_vod__r.start_date_vod__c <= :nextDay order by Start_Date_vod__c Desc]){
            for(Event_Attendee_vod__c item : items){
                Result ee = new Result();
                ee.resultItem = item;
                resultItems.add(ee);
            }
        }
        
        numOfMatchesFound = resultItems.size();
        return null;
    
    }    
    public String getTransactionDateWithFormatting(){
        if (objConcurExpense != null){
            Date d = objConcurExpense.Transaction_date_gne__c;
            return d.format();
        }
        return null;
    }

    public String getTransactionDate()
    {
        if (objConcurExpense != null){
            Date d = objConcurExpense.Transaction_date_gne__c;
            return d.format();
        }
        return null;
    }

    public string alias{
        get{
            if(Alias == null){
                 if (objConcurExpense != null){
                     Alias = objConcurExpense.Report_Creator_gne__c;
                 }
            }
            return alias;
         }
         set;
    }    
    public String Amount{
        get{
            if(Amount == null){
                if (objConcurExpense != null){
                    Amount = objConcurExpense.Transaction_Amount_gne__c;
                }
            }
            return Amount;
        }
        set;
    }

    public String getExpenseAmount(){
        Decimal expenseAmount = 0.00;
        String strExpAmt;
        if (objConcurExpense != null)
            strExpAmt = objConcurExpense.Amount_gne__c;
        Boolean bAmountFound = false;
        if (strExpAmt != null && strExpAmt != ''){
            expenseAmount = Decimal.valueOf(strExpAmt);
            expenseAmount.setScale(2);
            if (expenseAmount > 0.00){
                bAmountFound = true;
            }
        }
        return String.valueOf(expenseAmount.setScale(2));
    }

    public PageReference openPopup(){
        displayPopup = true;
        return null;
    }
    
    public String CallStatus{ get; set; }
    
    public pageReference saveInfo(){
        displayPopup = false;
        try{
            Concur_Expense_post_gne__c expenseRec = null;
            for (result objResult : resultItems){
                if (objResult.Selected== true){
                    expenseRec = new Concur_Expense_post_gne__c();
                    expenseRec.Amount_gne__c = objConcurExpense.Amount_gne__c;
                    expenseRec.SFDC_Transaction_Date_gne__c = objConcurExpense.Transaction_Date_gne__c;
                    expenseRec.SFDC_Expense_Type_gne__c = objConcurExpense.Expense_Type_gne__c;
                    expenseRec.Business_Purpose__c = objResult.resultItem.Medical_Event_vod__r.Name;
                    expenseRec.Interaction_Name_Aprimo_Site_ID_gne__c = objResult.resultItem.Medical_Event_vod__r.Site_ID_gne__c;
                    expenseRec.Expense_Status_gne__c = 'Link complete';
                    expenseRec.ExpKey_gne__c = objConcurExpense.ExpKey_gne__c;
                    expenseRec.Item_url_gne__c = objConcurExpense.Item_Url_gne__c;
                    expenseRec.Transaction_Amount_gne__c = objConcurExpense.Transaction_Amount_gne__c;
                    expenseRec.XUserId_gne__c = objConcurExpense.XUserID_gne__c;
                    expenseRec.Expence_Location_gne__c = objConcurExpense.Expence_Location_gne__c;                    
                    break;
                }
            }
            if (expenseRec != null){
                Concur_WebservicesCalls wsCall = new Concur_WebservicesCalls();
                CallStatus = 'SUCCESS';
                CallStatus = wsCall.postExpenseReport(expenseRec,objConcurExpense.XUserID_gne__c,ApexPages.currentPage().getParameters().get('OwnerPersId'));
                insert objConcurExpense;
                expenseRec.Concur_Expense_gne__c = objConcurExpense.Id;
                expenseRec.Web_service_status_gne__c = CallStatus;
                insert expenseRec;
                if (!CallStatus.contains('SUCCESS')){
                    ApexPAges.addMessage(new ApexPages.Message(ApexPages.Severity.Info, CallStatus));
                   }
                if (!CallStatus.contains('SUCCESS')){
                    displayPopup = false;
                    PageReference errorPage = Page.Concur_ErrorPage;
                    errorPage.getParameters().put('errorCode', '900');
                    errorPage.setRedirect(true);
                    return errorPage;
                }
            }
        }
        catch (System.DMLException e){
            System.debug('Exception in SaveInfo: ' + e.getMessage());
           }
        catch(System.NullPointerException e){
            System.debug('Exception in SaveInfo: ' + e.getMessage());
           }
        return null;
    }
    
    public void closePopup() {
        displayPopup = false;
    }
  public void doInsert(){
    
         if(getIsBookmark()){
             LogError();
         }
         if(getIsValidURL()){
             LogError();
         }
         
        String strXUserID = ApexPages.currentPage().getParameters().get('xuserid');
        InfoLog = new Concur_Error_Log_gne__c(Class_Name_gne__c='ConcurHCPMealController', 
                                                                    Error_Category_gne__c='info',
                                                                    Error_Message_gne__c='URL',
                                                                    Method_Name_gne__c= 'getIsBookmark', 
                                                                    Object_Name_gne__c='ConcurHCPMealController',
                                                                    System_Error_Message_gne__c='URL',
                                                                    Content_gne__c=ApexPages.currentPage().getURL(),
                                                                    Item_Url_gne__c='',
                                                                    XUserID_gne__c=strXUserID,
                                                                    Error_Code_gne__c='');
        insert InfoLog;
    }
}