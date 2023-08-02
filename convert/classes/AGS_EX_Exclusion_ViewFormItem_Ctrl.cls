public with sharing class AGS_EX_Exclusion_ViewFormItem_Ctrl {

    public Id accountId {get; private set;}

    public Account accountWithCurrentExclusionStatus {get; private set;}
    public AGS_EX_Exclusion_Check_gne__c previousExclusionCheck {get; private set;}

    public Boolean isExclusionLinkVisible {
        get {
            return accountWithCurrentExclusionStatus.AGS_EX_Exclusion_Status_gne__c != 'Request Pending' &&
                    accountWithCurrentExclusionStatus.AGS_EX_Exclusion_Status_gne__c != 'In Process';
        }
    }

    public Boolean isExclusionNotChecked {
        get {
            return accountWithCurrentExclusionStatus.AGS_EX_Exclusion_Status_gne__c == 'Not Checked' ||
                    accountWithCurrentExclusionStatus.AGS_EX_Exclusion_Status_gne__c == 'Request Pending' ||
                    accountWithCurrentExclusionStatus.AGS_EX_Exclusion_Status_gne__c == 'In Process';
        }
    }

    public sObject parentObj {get; 
        set {
            parentObj = value;
            if (accountWithCurrentExclusionStatus == null) {
                accountWithCurrentExclusionStatus = (Account)parentObj;
            }
        }  
    }

    public Boolean showMessageWithRequestSent { get; private set; }

    public AGS_EX_Exclusion_ViewFormItem_Ctrl() {
        accountId = ApexPages.currentPage().getParameters().get('id');
        getPreviousExclusionStatus();
    }

    private void getPreviousExclusionStatus() {
        List<AGS_EX_Exclusion_Request_gne__c> lastExclusionRequests = [
                SELECT Id, AGS_EX_Request_Status_gne__c, (SELECT AGS_EX_Status_gne__c, AGS_EX_Check_Date_gne__c FROM AGS_EX_Exclusion_Checks__r)
                FROM AGS_EX_Exclusion_Request_gne__c
                WHERE AGS_EX_Account_Name_gne__c = :accountId
                order by CreatedDate desc
                limit 2
        ];
        if (lastExclusionRequests.size() > 1) {
            previousExclusionCheck = lastExclusionRequests[1].AGS_EX_Exclusion_Checks__r[0];
        }
    }

    public PageReference createRequest() {
        Boolean requestSent = AGS_EX_Exclusion_Utils.createRequest((Account)parentObj);
        showMessageWithRequestSent = requestSent;
        //to get fresh value of formula
        accountWithCurrentExclusionStatus = [SELECT AGS_EX_Exclusion_Status_gne__c, AGS_EX_Date_Checked_Exclusion_gne__c FROM Account WHERE Id = :accountId];
        getPreviousExclusionStatus();
        return null;
    }

    public String getSubmittedDate (){
        String retStr = '';
        if(accountWithCurrentExclusionStatus.AGS_EX_Exclusion_Status_gne__c == 'Request Pending' || accountWithCurrentExclusionStatus.AGS_EX_Exclusion_Status_gne__c == 'In Process') {
           
              List<AGS_EX_Exclusion_Request_gne__c> existingExclusionRequests = [SELECT Id, AGS_EX_Account_Name_gne__c,CreatedDate 
                                                                                FROM AGS_EX_Exclusion_Request_gne__c 
                                                                                WHERE 
                                                                                (AGS_EX_Request_Status_gne__c = 'Pending' OR AGS_EX_Request_Status_gne__c = 'In Progress')
                                                                              AND AGS_EX_Account_Name_gne__c = :accountId];
            if(!existingExclusionRequests.isEmpty()) {                  
                    retStr = '(Submitted on ' + existingExclusionRequests[0].CreatedDate.format('MM/dd/YYYY') +')';
            }                                                                                   
            
        }

        return retStr;
    }

    public class ExclusionHistory {
        String exclusion { get; set; }
        String exDate { get; set; }
        String exTime { get; set; }
    }

    public class ExclusionHistoryResult {
        @testVisible
        List<ExclusionHistory> historyItems { get; set; }
    }

    @RemoteAction
    public static ExclusionHistoryResult getExclusionHistory(String accountId) {
        List<AGS_EX_Exclusion_Check_gne__c> exclusions = [
                SELECT AGS_EX_Status_gne__c, AGS_EX_Check_Date_gne__c, AGS_EX_Account_Name_gne__c
                FROM AGS_EX_Exclusion_Check_gne__c
                WHERE AGS_EX_Exclusion_Request_gne__r.AGS_EX_Account_Name_gne__c =:accountId
                ORDER BY AGS_EX_Check_Date_gne__c desc];

        ExclusionHistoryResult result = new ExclusionHistoryResult();
        result.historyItems = getExclusionHistoryMap(exclusions);
        return result;
    }

    private static List<ExclusionHistory> getExclusionHistoryMap(List<AGS_EX_Exclusion_Check_gne__c> exclusions) {
        List<ExclusionHistory> result = new List<ExclusionHistory>();

        for (AGS_EX_Exclusion_Check_gne__c item : exclusions) {
            ExclusionHistory historyItem = new ExclusionHistory();
            historyItem.exDate = getFormattedDateOrTime(item.AGS_EX_Check_Date_gne__c,true);
            historyItem.exTime = getFormattedDateOrTime(item.AGS_EX_Check_Date_gne__c,false);
            historyItem.exclusion = item.AGS_EX_Status_gne__c;

            result.add(historyItem);

        }
        return result;
    }

    private static String getFormattedDateOrTime(DateTime toFormat,Boolean isDate){
        String formatedDate = String.valueOfGmt(toFormat);
        List<String> dateParts = formatedDate.split(' ');
        if(isDate) {
            return dateParts[0];
        }
        return dateParts[1];
    }
}