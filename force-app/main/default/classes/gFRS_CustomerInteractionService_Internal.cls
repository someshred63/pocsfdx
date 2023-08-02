@RestResource(urlMapping='/InternalCustomerInteraction/*')
global class gFRS_CustomerInteractionService_Internal {
    
    
    @HttpPost
    global static void createCustomerInteractionInternal() {
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try
        {
            
            List < Response > lstResponse = new List < Response > ();
            
            //RestRequest  req     = RestContext.request;   
            //Getting JSON String from request body
            String jsonInput  = req.requestBody.toString();
            //System.debug('jsonInput::::'+jsonInput);
            customerInteractionInternalWrapper cInteractionRec = (customerInteractionInternalWrapper)JSON.deserialize(jsonInput, customerInteractionInternalWrapper.class);
            //System.debug('@@@'+cInteractionRec);
            gFRS_Ltng_Customer_Intraction__c cInsert=new gFRS_Ltng_Customer_Intraction__c();
            cInsert.First_Name__c=cInteractionRec.firstName;
            cInsert.Last_Name__c=cInteractionRec.lastName;
            cInsert.User_Name__c=cInteractionRec.userName;
            cInsert.Email__c=cInteractionRec.contactEmail;
            cInsert.Role__c=cInteractionRec.role;
            cInsert.Would_you_like_a_phone_call__c=cInteractionRec.phoneCallChk;
            cInsert.Phone_Number__c=cInteractionRec.phoneNumber;
            cInsert.Name_of_the_organization_pursuing_opport__c=cInteractionRec.orgName;
            cInsert.gFRS_Request_Type__c=cInteractionRec.grantRqtType;
            cInsert.Grant_Request_Number__c=cInteractionRec.grantRqtNumber;
            cInsert.What_can_we_help_you_with__c=cInteractionRec.helpNeed;
            cInsert.Description__c=cInteractionRec.bDescription;
            cInsert.select_the_Business_Rationale__c=cInteractionRec.BusinessRationale;
            cInsert.Attachment_Link__c=cInteractionRec.attachmentLink;
            cInsert.Source__c='cmg.gene.com';
            cInsert.Status__c='New';
            cInsert.RecordTypeId=Schema.SObjectType.gFRS_Ltng_Customer_Intraction__c.getRecordTypeInfosByName().get('Internal Customer').getRecordTypeId();
            
            insert cInsert;
            
            lstResponse.add(new Response('Successfully Inserted', cInsert.Id));
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serializePretty(lstResponse));
            
        }
        catch (exception e) {
            System.debug('@@ Line Number'+e.getLineNumber());
            res.responseBody = Blob.valueOf('{ "errorMessage" : "' +e.getMessage()+'" }');
            res.statusCode = 400;
            throw e;  
        }
    }
    
    public class customerInteractionInternalWrapper {
        
        
        Public String firstName;
        public String lastName;
        public String userName;
        public String role;
        public String contactEmail;
        public String phoneCallChk;
        public String phoneNumber;
        public String orgName;
        Public String BusinessRationale;
        public String grantRqtType;
        public String grantRqtNumber;
        public String helpNeed;
        public String bDescription;
        public String attachmentLink;
        
        
        
    }
    
    public class Response {
        public String message;
        public String customerRec;
        public Response(String message, string customerRec) {
            this.message = message;
            this.customerRec = customerRec;
        }
    }
    
    
}