@RestResource(urlMapping='/CustomerInteraction/*')
global class gFRS_CustomerInteractionService {
    
    
    @HttpPost
    global static id createCustomerInteraction() {
        
        try
        {

            RestRequest  req     = RestContext.request;   
            //Getting JSON String from request body
            String jsonInput  = req.requestBody.toString();
            //System.debug('jsonInput::::'+jsonInput);
            customerInteractionWrapper cInteractionRec = (customerInteractionWrapper)JSON.deserialize(jsonInput, customerInteractionWrapper.class);
            //System.debug('@@@'+cInteractionRec);
            gFRS_Ltng_Customer_Intraction__c cInsert=new gFRS_Ltng_Customer_Intraction__c();
            cInsert.First_Name__c=cInteractionRec.firstName;
            cInsert.Last_Name__c=cInteractionRec.lastName;
            cInsert.User_Name__c=cInteractionRec.userName;
            cInsert.Email__c=cInteractionRec.contactEmail;
            cInsert.Would_you_like_a_phone_call__c=cInteractionRec.phoneCallChk;
            cInsert.Phone_Number__c=cInteractionRec.phoneNumber;
            cInsert.Organization_Name__c=cInteractionRec.orgName;
            cInsert.gFRS_Request_Type__c=cInteractionRec.grantRqtType;
            cInsert.Grant_Request_Number__c=cInteractionRec.grantRqtNumber;
            cInsert.What_can_we_help_you_with__c=cInteractionRec.helpNeed;
            cInsert.Description__c=cInteractionRec.bDescription;
            cInsert.Source__c=' funding.gene.com';
            cInsert.Status__c='New';
            cInsert.RecordTypeId=Schema.SObjectType.gFRS_Ltng_Customer_Intraction__c.getRecordTypeInfosByName().get('External Customer').getRecordTypeId();
            
            insert cInsert;
            
            return cInsert.Id;
        }
        catch (exception e) {
            throw e;
        }
    }
   
    public class customerInteractionWrapper {
        
      
        Public String firstName;
        public String lastName;
        public String userName;
        public String contactEmail;
        public String phoneCallChk;
        public String phoneNumber;
        public String orgName;
        public String grantRqtType;
        public String grantRqtNumber;
        public String helpNeed;
        public String bDescription;
        
        
    }
 
    
}