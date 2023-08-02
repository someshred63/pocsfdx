public class AccountLicenseDCRController {

    String recordTypeId = null;
    Account acct        = null;     

    public AccountLicenseDCRController(ApexPages.StandardController stdController) {       
        SObject sobjectInstance = stdController.getRecord();        
        if ( sobjectInstance.getsObjectType() ==  Account.sObjectType  ) {
            acct = [select id, name from account   
                    where id  = : (Id) sobjectInstance.get('id') ];            
        }        
        System.debug ('initialized AccountLicenseDCRController ');
    }

    public static String getRedirectURLForLicenseDCR (Account acct) {                
        String recordTypeId   = getRecordTypeId('Change_Request_gne__c', 
                                                'License/Sampleability Info');                                                
        String accountFieldId = getChangeRequestAccountFieldId();                
        String prefix  = Schema.SObjectType.Change_Request_gne__c.getKeyPrefix();
        String fieldId = getChangeRequestAccountFieldId();
        String redirectURL = '/' + prefix   + '/e?RecordType=' + 
                             recordTypeId   + '&' + 
                             'CF' + accountFieldId + '_lkid=' +  acct.Id  + '&' +                                         
                             'CF' + accountFieldId + '='       + acct.Name ; 
        return redirectURL;  
    }

    public PageReference getLicenseDCRLayout() {
        String url = AccountLicenseDCRController.getRedirectURLForLicenseDCR(acct);        
        PageReference pageRef = new PageReference(url);              
        return pageRef.setRedirect(true);       
    }
    
    // configuration step for field Id  
    static String getChangeRequestAccountFieldId() {        
        Environment_Variables__c envRecord = 
                [select value__c from Environment_Variables__c
                 where     Type__c         = 'Other' 
                       and Environment__c  = 'all'
                       and key__c = 'DataChangeRequest.Account_gne__c.FieldId'];

        return envRecord.value__c;                                  
    }
    
    // record type Id 
    static String getRecordTypeId ( String objectName, String recordTypeName ) {
        RecordType rt = [select id from recordType 
                           where     sobjectType = :objectName 
                                 and name        = :recordTypeName ];
        return (String) rt.Id;
    }

}