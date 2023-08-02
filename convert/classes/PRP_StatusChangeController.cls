public class PRP_StatusChangeController {
    /**
* @author Vijay Dharoor
* @date 6/29/21
* @description to change status of PRP application by clicking 'Approve' Button.
**/
    public static String emailFlag;
    public static final String PENDING_APPROVAL = 'Pending Approval';
    public static final String APPROVED = 'Approved';
    public static final String WITH_CUSTOMER = 'With Customer';
    public static final String ESIGNATURE = 'ESignature';
    public static final String TP_UPDATE = 'TP Update';
    public static final String IN_PROGRESS = 'In Progress';
    public static final String TERMINATED = 'Terminated';
    public static final String BLANK_SPACE = '';
    public static final String CLOSED = 'Closed';
    public static final String COMPLETE = 'Complete';
    public static final String ON_HOLD = 'On Hold';
    
    @AuraEnabled
    public static void changeStatusToApprove(String recordId)
    {
        PRP_Request__c prp = new PRP_Request__c(Id = recordId);
        PRP_Request__c prp1 = new PRP_Request__c();
        PRP_Request__c prp2 = new PRP_Request__c();
        List<String> consolidatedEmailId = new List<String>();
        List<String> consolidatedccAddress = new List<String>();
        
        prp1 = [
            SELECT Id, Prior_Owner_Value__c, Owner.Email 
            FROM PRP_Request__c 
            WHERE Id=:recordId 
            LIMIT 1
        ];
        
        try
        {
            if (prp1.Prior_Owner_Value__c != null)
            {
                User usr = new User();
                usr = [SELECT Id, IsActive, Email FROM User WHERE Id = :prp1.Prior_Owner_Value__c];
                prp.Request_Status__c = APPROVED;
                prp.Is_Validated__c = true;
                prp.OwnerId = prp1.Prior_Owner_Value__c;
                emailFlag = APPROVED.toLowerCase();
                
                if (string.isNotEmpty(usr.Email)) 
                {
                    consolidatedEmailId.add(usr.Email);
                }
                
                consolidatedEmailId.add(usr.Email);
                
                update prp;
                
                if (consolidatedEmailId.size()>0)
                {
                    prp2 = [SELECT Id, Prior_Owner_Value__c, Owner.Email FROM PRP_Request__c WHERE Id = :recordId LIMIT 1];
                    consolidatedccAddress.add(prp2.Owner.Email);
                    PRP_EmailUtils.sendEmail(recordId,consolidatedEmailId,emailFlag,consolidatedccAddress);
                    PRP_EmailUtils.createEmails(recordId,usr.Email);
                }
            }else{
                prp.Request_Status__c = APPROVED;
                prp.Is_Validated__c = true;
                update prp;
            }
        }
        catch(exception exp)
        {
            System.debug('Error: ' + exp.getMessage());
            String errorMessage = exp.getMessage();
            Integer occurence;
            if (exp.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
            {
                System.debug('PJ -- errorMessage: ' + errorMessage);
                System.debug('PJ -- errorMessage.length: ' + errorMessage.length());
                occurence = errorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 34;
                System.debug('PJ -- occurence: ' + occurence);
                errorMessage = errorMessage.mid(occurence, errorMessage.length());
                System.debug('PJ -- errorMessage: ' + errorMessage);
                occurence = errorMessage.lastIndexOf(':');
                System.debug('PJ -- occurence: ' + occurence);
                errorMessage = errorMessage.mid(0, occurence);
                System.debug('PJ -- errorMessage: ' + errorMessage);
            }
            throw new AuraHandledException(errorMessage);
        }
    }
    
    /**
* @author :Rabindranath
* @date 11/02/21
* @description: to change status of PRP application by clicking 'Pending Approval' Button.
**/
    @AuraEnabled
    public static void changeStatusToPendingApproval(String recordId,Boolean flag)
    {
        List<String> consolidatedEmailId = new List<String>();
        List<String> consolidatedccAddress = new List<String>();
        String userEmail = '';
        
        try
        {
            if (flag == false )
            {
                PRP_Request__c prpRequest = new PRP_Request__c(Id = recordId);
                prpRequest.Request_Status__c = PENDING_APPROVAL;
                update prpRequest;
            }
            else
            {
                List<PRP_Request__c> prpRequests = new List<PRP_Request__c>();
                List<User> usr = new List<User>();
                PRP_Request__c prpRequest = new PRP_Request__c(id=recordId);
                
                prpRequests = [
                    SELECT Id, CMS_ID__c, Owner.Email, EWorkflow__c, Effective_Date__c, Request_Type__c, 
                    Approver_Name__c, Product_Name__c, OwnerId 
                    FROM PRP_Request__c 
                    WHERE Id=:recordId 
                    LIMIT 1
                ];
                
                if (prpRequests?.size() > 0) 
                {
                    usr = [SELECT Id, IsActive, Email FROM User WHERE UserName=:prpRequests[0].Approver_Name__c LIMIT 1];
                    
                    prpRequest.Request_Status__c = PENDING_APPROVAL;
                    prpRequest.Prior_Owner_Value__c = prpRequests[0].OwnerId;
                    emailFlag = PENDING_APPROVAL.toLowerCase();
                    
                    if (usr?.size() > 0)
                    {
                        prpRequest.ownerId = usr[0].Id;
                        userEmail = usr[0].Email;
                    }
                    
                    if (string.isNotEmpty(userEmail))
                    {
                        consolidatedEmailId.add(userEmail);
                    }
                    
                    if (string.isNotEmpty(prpRequests[0].Owner.Email))
                    {
                        consolidatedccAddress.add(prpRequests[0].Owner.Email);
                    }
                    
                    update prpRequest;
                    
                    if (consolidatedEmailId.size()>0)
                    {
                        PRP_EmailUtils.sendEmail(recordId, consolidatedEmailId, emailFlag, consolidatedccAddress);
                        PRP_EmailUtils.createEmails(recordId, userEmail);
                    }
                }
            }
        }
        catch (DmlException ex) {
            throw new AurahandledException(ex.getDmlMessage(0));
        } 
        catch(exception exp)
        {
            String errorMessage = exp.getMessage();
            Integer occurence;
            if (exp.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))
            {
                System.debug('PJ -- errorMessage: ' + errorMessage);
                System.debug('PJ -- errorMessage.length: ' + errorMessage.length());
                occurence = errorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 34;
                System.debug('PJ -- occurence: ' + occurence);
                errorMessage = errorMessage.mid(occurence, errorMessage.length());
                System.debug('PJ -- errorMessage: ' + errorMessage);
                occurence = errorMessage.lastIndexOf(':');
                System.debug('PJ -- occurence: ' + occurence);
                errorMessage = errorMessage.mid(0, occurence);
                System.debug('PJ -- errorMessage: ' + errorMessage);
            }

            throw new AuraHandledException(errorMessage);
        }
    }
    
    /**
* @author :Rabindranath
* @date 11/02/21
* @description : to retrieve the CMS id and effective date info.
**/
    @AuraEnabled
    public static PRP_Request__c retrievePRPInfo(String recordId)
    {
        try
        {
            List<PRP_Request__c> prpRequests = new List<PRP_Request__c>();
            
            prpRequests = [
                SELECT Id, CMS_ID__c, Effective_Date__c, EWorkflow__c, Request_Type__c, Approver_Name__c,
                Product_Name__c, Status_Category__c,ContractId1__c,ContractId1__r.Name, Contract_ID__c, OwnerId,Is_Validated__c 
                FROM PRP_Request__c 
                WHERE Id=:recordId 
                LIMIT 1
            ];
            
            if (prpRequests?.size() > 0)
            {
                return prpRequests[0];
            } 
            else 
            {
                return null;
            }
        }
        catch(exception exp)
        {
            throw new AuraHandledException(exp.getMessage());
        }
    }
    
    /**
* @author :Rabindranath
* @date 11/02/21
* @description : to retrieve the Approver name info.
**/
    @AuraEnabled
    public static boolean retrieveapproverInfo(String recordId){
        Boolean isUserActive = false;
        try
        {
            List<PRP_Request__c> prpRequests = new List<PRP_Request__c>();
            List<User> usr = new List<User>();
            
            prpRequests = [SELECT Id, Approver_Name__c, Product_Name__c FROM PRP_Request__c WHERE Id=: recordId LIMIT 1];
            
            if (prpRequests?.size() > 0){
                //Changed criteria from Name to UserName
                usr = [SELECT Id, IsActive FROM User WHERE UserName=:prpRequests[0].Approver_Name__c LIMIT 1];
                if (usr?.size() > 0){
                    isUserActive = usr[0].IsActive;
                }
            }
            
            return isUserActive;
        }
        catch(exception exp)
        {
            throw new AuraHandledException(exp.getMessage());
        }
    }
    
    /**
* @author Vijay Dharoor
* @date 6/29/21
* @description to change status of PRP application by clicking 'ESignature' Button.
**/
    @AuraEnabled
    public static void updateStaCatToWithCust(String recordId)
    {
        try
        {
            PRP_Request__c prp = new PRP_Request__c(Id = recordId);
            prp.Status_Category__c = WITH_CUSTOMER;
            prp.Request_Status__c = ESIGNATURE;
            
            update prp;
        }
        catch(exception exp)
        {
            throw new AuraHandledException(exp.getMessage());
        }
    }
    
    /**
* @author Vijay Dharoor
* @date 6/29/21
* @description to change status of PRP application by clicking 'TP Update' Button.
**/
    @AuraEnabled
    public static void changeStatusToTPUpdate(String recordId)
    {
        try
        {
            PRP_Request__c prp = new PRP_Request__c(Id = recordId);
            prp.Request_Status__c = TP_UPDATE;
            prp.Status_Category__c = IN_PROGRESS;
            prp.TP_Update_Date__c = System.today();
            
            update prp;
        }
        catch(exception exp)
        {
            throw new AuraHandledException(exp.getMessage());
        }
    }
    
    /**
* @author Vijay Dharoor
* @date 6/29/21
* @description to change status of PRP application by clicking 'Terminate' Button.
**/
    @AuraEnabled
    public static void changeStatusToTerminate(String recordId)
    {
        try
        {
            PRP_Request__c prp = new PRP_Request__c(Id=recordId);
            prp.Request_Status__c = TERMINATED;
            prp.Status_Category__c = BLANK_SPACE;
            
            update prp;
        }
        catch (DmlException ex) {
            throw new AurahandledException(ex.getDmlMessage(0));
        } 
        catch(exception exp){
            throw new AuraHandledException(exp.getMessage());
        }
    }
    
    /**
* @author Vijay Dharoor
* @date 6/29/21
* @description to change status of PRP application by clicking 'Closed' Button.
**/
    @AuraEnabled
    public static void updateStaCatToCompleted(String recordId, String statusCategory, Boolean chkbxVal, String contractID)
    {
        System.debug('@@@@!!'+chkbxVal);
       System.debug('@@@@Category!!'+statusCategory);
        List<String> consolidatedEmailId = new List<String>();
        List<String> consolidatedccAddress = new List<String>();
        
        try
        {
            PRP_Request__c  prpRequest = [
                SELECT Id, Status_Category__c, BEM__c, BEM__r.Email__c, Owner.Email 
                FROM PRP_Request__c 
                WHERE Id=:recordId
            ];
            
            PRP_Request__c prp = new PRP_Request__c(Id=recordId); 
            prp.Request_Status__c = CLOSED;
            prp.Status_Category__c = statusCategory;
            prp.Is_Validated__c = chkbxVal;
            prp.ByPassValidation__c=true; // Setting it to true so that VR doesn't imterfere during the update from aura component.
			update prp;
            // Setting the Bypass validation flag to false to enable the VR.
      		 PRP_Request__c prp1 = new PRP_Request__c(Id=recordId);
            prp1.ByPassValidation__c=false;
            update prp1;
            /* Commenting this as part of ROBOCOPS-1356
if(string.isNotEmpty(prpRequest.BEM__r.Email__c)){
consolidatedEmailId.add(prpRequest.BEM__r.Email__c);
consolidatedccAddress.add(prpRequest.Owner.Email);
}
*/
            
            /*Commenting this as part of ROBOCOPS-1356
if(consolidatedEmailId.size()>0 && prp.Request_Status__c =='Closed' && prp.Status_Category__c=='Complete' ){
PRP_EmailUtils.sendEmail(recordId,consolidatedEmailId,'',consolidatedccAddress);
PRP_EmailUtils.createEmails(recordId,prpRequest.BEM__r.Email__c);
}
*/
        }
        catch (DmlException ex) {
            throw new AurahandledException(ex.getDmlMessage(0));
        } 
        catch(exception exp){
            throw new AuraHandledException(exp.getMessage());
        }

        
    }
    
    /**
* @author Vijay Dharoor
* @date 6/29/21
* @description to change status of PRP application by clicking 'On Hold' Button.
**/
    @AuraEnabled
    public static void updateReqStaToOnHold(String recordId, String reasonCode)
    {
        try
        {
            PRP_Request__c prp = new PRP_Request__c(Id=recordId);
            prp.Request_Status__c = ON_HOLD;
            prp.Reason_Codes__c = reasonCode;
            update prp;
        }
        catch(exception exp)
        {
            throw new AuraHandledException(exp.getMessage());
        }
    }
    
    
    @AuraEnabled  
    public static List<picklistWrapper> findPicklistOptions(string objAPIName, string fieldAPIname) 
    {
        list<picklistWrapper> returnValue = new list<picklistWrapper>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        // Get the object type of the SObject.
        Schema.sObjectType objType = schemaMap.get(objAPIName);
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values = fieldMap.get(fieldAPIname).getDescribe().getPickListValues();
        //pickListFieldWrapper picklistDetails = new pickListFieldWrapper();
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            picklistWrapper aa = new picklistWrapper();
            aa.pickListLabel = a.getLabel();
            aa.pickListValue = a.getValue();
            returnValue.add(aa);
        }
        system.debug('*****returnValue'+returnValue);
        return returnValue;
    }
    
    public class picklistWrapper
    {
        @AuraEnabled 
        public string pickListLabel;
        @AuraEnabled 
        public string pickListValue; 
    }
}