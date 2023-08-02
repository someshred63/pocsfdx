/******************************************************************************************
*  @author: Tadeusz Hyzy, Roche (contractor)
*  @email: tadeusz.hyzy@contractors.roche.com   
*  Created: 2014-10-06
*  LastModified: 2014-10-08
*  Project: OTR2
*  Description: REST Webservice, Create or Update Contact.             
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneCreateUpdateContact/*')
global with sharing class iPhone_Create_Update_Contact_gne {
    
    @HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String contactId, String accountId, String requestId, String firstName, String lastName, String title, String titleOther, String email, String phone, String cellPhone, Boolean active, String inactiveReason) {
        return iPhone_Commons_gne.executeAlterData(
            new UpdateContactExecutor(),
            new UpdateContactArg(contactId, accountId, requestId, firstName, lastName, title, titleOther, email, phone, cellPhone, active, inactiveReason)
        );
    }
    
    class UpdateContactArg implements iPhone_Commons_gne.BaseArgs {
    	
        final String contactId;
        final String accountId;  
        final String requestId;
        final String firstName;
        final String lastName;
        final String title;
        final String titleOther;
        final String email;
        final String phone;
        final String cellPhone;
        final Boolean active;
        final String inactiveReason;
        
        public UpdateContactArg(String contactId, String accountId, String requestId, String firstName, String lastName, String title, String titleOther, String email, String phone, String cellPhone, Boolean active, String inactiveReason) {
            this.contactId      = contactId;
            this.accountId      = accountId;
            this.requestId		= requestId;
            this.firstName      = firstName;
            this.lastName       = lastName;
            this.title          = title;
            this.titleOther 	= titleOther;
            this.email          = email;
            this.phone          = phone;
            this.cellPhone      = cellPhone;
            this.active         = active;
            this.inactiveReason = inactiveReason;
        }
        
        public String getIPhoneRequestId() {
            return null;
        }

    }
    
    public without sharing class UpdateContactExecutor implements iPhone_Commons_gne.Runnable {
        
        public Object run(Object obj) {
            UpdateContactArg arg = (UpdateContactArg)obj;
            Id contactId = upsertStatus(arg.contactId, arg.accountId, arg.requestId, arg.firstName, arg.lastName, arg.title, arg.titleOther, arg.email, arg.phone, arg.cellPhone, arg.active, arg.inactiveReason);
            return contactId;
        }
                
        private Id upsertStatus(String contactId, String accountId, String requestId, String firstName, String lastName, String title, String titleOther, String email, String phone, String cellPhone, Boolean active, String inactiveReason) {
            
            // Check values are empty
            checkHasValue('lastName', lastName);
            checkHasValue('active', active);
                        
            // Check if contactId or accountId are empty
            if(!iPhone_StringUtil.hasValue(contactId) && !iPhone_StringUtil.hasValue(accountId)) {
            	throw new iPhone_Commons_gne.IPhoneException('Values : contactId (update) or accountId (insert) is null or empty.');
            }
            
            // Only check activeReason when Contact is not Active and Title field when Contact is Active
            if(!active) {
                checkHasValue('inactiveReason', inactiveReason);
            } else {
                checkHasValue('title', title);
            }
                        
            // Only check titleOther when Title is set to "Other"
            if(title == 'Other') {
                checkHasValue('titleOther', titleOther);
            }
            
            Contact contactObj = new Contact();
		
			// If contactId is not null we populate Contact with data and then update it
			if(iPhone_StringUtil.hasValue(contactId)) {
	            contactObj = iPhone_DAO.getContactById(contactId);
	            if(contactObj == null) {
	            	throw new iPhone_Commons_gne.IPhoneException('Cannot find Contact object with Id : ' + contactId);
	            }
	            system.debug('Found Contact: ' + contactObj);
			}
			
			// Check if we insert Contact or we need to update Contact
            contactObj.FirstName                = firstName;
            contactObj.LastName                 = lastName;
            contactObj.Title_gne__c             = title;
            contactObj.Title             		= titleOther;
            contactObj.Email                    = email;
            contactObj.Phone                    = phone;
            contactObj.Cell_Phone_frm_gne__c    = cellPhone;
            contactObj.Active_gne__c            = active;
            contactObj.Inactive_Reason__c       = inactiveReason;
                
            // Only if we insert Contact add AccountId
            if(!iPhone_StringUtil.hasValue(contactId)) {
        		contactObj.AccountId = [SELECT Id, RecordTypeId FROM Account WHERE Id = : accountId].Id;
            }
                
            upsert contactObj;
            system.debug('Created / Updated Contact: ' + contactObj);
            
            return contactObj.Id;

        }
        
        private void checkHasValue(String valueName, String value) {
            if(!iPhone_StringUtil.hasValue(value)) {
                String message = 'Value: ' + valueName + ' is null or empty.'; 
                throw new iPhone_Commons_gne.IPhoneException(message);  
            }
        }

        private void checkHasValue(String valueName, Boolean value) {
            if(value == null) {
                String message = 'Value: ' + valueName + ' is null or empty.'; 
                throw new iPhone_Commons_gne.IPhoneException(message);  
            }
        }

    }   
        
}