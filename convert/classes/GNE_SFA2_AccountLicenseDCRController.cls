public with sharing class GNE_SFA2_AccountLicenseDCRController {

    String recordTypeId = null;
    Account acct        = null;     

    public GNE_SFA2_AccountLicenseDCRController(ApexPages.StandardController stdController) {       
        SObject sobjectInstance = stdController.getRecord();        
        if ( sobjectInstance.getsObjectType() ==  Account.sObjectType  ) {
            acct = [select id, name from account   
                    where id  = : (Id) sobjectInstance.get('id') ];            
        }        
        System.debug ('initialized AccountLicenseDCRController ');
    }

    private String getRedirectURLForLicenseDCR (Account acct) {               
        String recordTypeId   = getRecordTypeId('Change_Request_gne__c', 
                                                'License/Sampleability Info');      
        String vfpName = GNE_SFA2_Util.isCCCrmUser() ? 'GNE_CRM_DCR_Create_Layout':'GNE_SFA2_DCR_Create_Layout';
        String redirectURL = '/apex/' + vfpName +'?RecordTypeId=' + recordTypeId + 
        					 '&AccountId=' +  acct.Id + '&retURL=/'+ acct.Id;         

        return redirectURL;  
    }

    public PageReference getLicenseDCRLayout() {
        String url = getRedirectURLForLicenseDCR(acct);        
        PageReference pageRef = new PageReference(url);              
        return pageRef.setRedirect(true);       
    }
    
    // record type Id 
    private String getRecordTypeId ( String objectName, String recordTypeName ) {
        RecordType rt = [select id from recordType 
                           where     sobjectType = :objectName 
                                 and name        = :recordTypeName ];
        return (String) rt.Id;
    }

}