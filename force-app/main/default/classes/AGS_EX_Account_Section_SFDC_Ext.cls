public without sharing class AGS_EX_Account_Section_SFDC_Ext {

    private Account currentAccount;

    public Account accountWithCurrentExclusionStatus {get; private set;}
    public Boolean isExclusionNotChecked { 
        get { 
            return accountWithCurrentExclusionStatus.AGS_EX_Exclusion_Status_gne__c == 'Not Checked' || 
                    accountWithCurrentExclusionStatus.AGS_EX_Exclusion_Status_gne__c == 'Request Pending' ||
                    accountWithCurrentExclusionStatus.AGS_EX_Exclusion_Status_gne__c == 'In Process';
        }
    }


    public Boolean isUserCCOAnalyst { get; set; }
    public Boolean isUserCCGExclusions { get; set; }
    

    public String redirectUrl {public get; private set;}
    public Boolean shouldRedirect {public get; private set;}

    public Boolean showMessageWithRequestSent { get; private set; }


    public AGS_EX_Account_Section_SFDC_Ext(ApexPages.StandardController stdController) {
        this.currentAccount = (Account)stdController.getRecord();

        accountWithCurrentExclusionStatus = currentAccount;

        String profileName = [SELECT Name FROM profile WHERE id = :userinfo.getProfileId()].Name;
        isUserCCOAnalyst = profileName == 'GNE-AGS-CCO-Analyst';
        isUserCCGExclusions = profileName == 'GNE-AGS-CCG-Exclusions';

        showMessageWithRequestSent = false;
    }

    public String getSubmittedDate (){
        String retStr = '';

        if(accountWithCurrentExclusionStatus.AGS_EX_Exclusion_Status_gne__c == 'Request Pending' || accountWithCurrentExclusionStatus.AGS_EX_Exclusion_Status_gne__c == 'In Process') {
           
              List<AGS_EX_Exclusion_Request_gne__c> existingExclusionRequests = [SELECT Id, AGS_EX_Account_Name_gne__c,CreatedDate 
                                                                                FROM AGS_EX_Exclusion_Request_gne__c 
                                                                                WHERE 
                                                                                (AGS_EX_Request_Status_gne__c = 'Pending' OR AGS_EX_Request_Status_gne__c = 'In Progress')
                                                                              AND AGS_EX_Account_Name_gne__c = :currentAccount.id];
            if(!existingExclusionRequests.isEmpty()) {                  
                    retStr = '(Submitted on ' + existingExclusionRequests[0].CreatedDate.format('MM/dd/YYYY') +')';
            }                                                                                   
            
        }

        return retStr;
    }

    public PageReference createRequest() {
        Boolean requestSent = AGS_EX_Exclusion_Utils.createRequest(currentAccount);
        showMessageWithRequestSent = requestSent;
        //to get fresh value of formula
        accountWithCurrentExclusionStatus = [SELECT AGS_EX_Exclusion_Status_gne__c, AGS_EX_Date_Checked_Exclusion_gne__c FROM Account WHERE Id = :currentAccount.Id];
        return null;
    }

    public PageReference createExclusionCheck() {
        shouldRedirect = true;
        redirectUrl = '/apex/AGS_EX_Exclusion_Update_SFDC?accId=' + currentAccount.Id;
        return null;
    }
}