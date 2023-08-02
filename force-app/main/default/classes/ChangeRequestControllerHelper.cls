global without sharing class ChangeRequestControllerHelper {
    
    public static void sendEmail(Change_Request_gne__c changeRequest, Boolean isNeedInfo, String requestorEmail) {
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {requestorEmail});
        mail.setSenderDisplayName('Data Change Request Team');
        mail.setBccSender(false);
        if(isNeedInfo){
            mail.setSubject('ACTION REQUIRED:  we need more information to process your data change request');
            mail.setHtmlBody('<b>DO NOT REPLY TO THIS EMAIL.  PLEASE SEE INSTRUCTIONS BELOW.</b><br/><br/><br/>Greetings,<br/>'+
                            '<br/><br/>In order to complete your data change request we need more information.  Please follow '+
                            'the below instructions.<br/><br/><br/>1.  Go to your SFA or CRM tool and click on the "Data Change'+
                            ' Requests" tab.<br/><br/>NOTE: Once on this tab, you can change views of the data by simply '+
                            'selecting the view of choice FROM the drop down box on upper left side of the screen.  Following '+
                            'are the available views:<br/><br/> - All Open Requests<br/> - All Requests<br/> - Requires '+
                            'Requestor Action<br/><br/>2.  Click on the the "Edit" link  next to "'+ changeRequest.Name +'"  to edit the request'+
                            ' with Status "Need Info"<br/><br/>NOTE:  do not click on the name of the Account as it will display'+
                            ' the Account Profile instead of the data change request made regarding that Account.)<br/><br/>'+
                            '3.  View the the "Notes" for a description of the information needed, and enter your response in the '+
                            '"New Note" box, then click "Save".  <br/><br/>4. The additional information needed to process your'+
                            ' request has now been submitted.<br/><br/>Thanks,<br/><br/>Data Change Request Team<br/>');

        }else{
            mail.setSubject('Your data change request has been completed.');
            mail.setSenderDisplayName('Data Change Request Team');
            String notes = '';
            if(changeRequest.new_note_gne__C != null){ 
                notes = 'Notes: "' + changeRequest.new_note_gne__c + '"<br/><br/>';
            }
            mail.setHtmlBody('<b>DO NOT REPLY TO THIS EMAIL.  PLEASE SEE INSTRUCTIONS BELOW.</b><br/><br/>Greetings,<br/>'+
                            '<br/>Your data change request ' + changeRequest.Name + ' has been completed.  ' + 
                            'The result of your request was <b>' + changeRequest.Approval_State__c + '</b>.<br/><br/>' +
                            notes +     
                            'If you are satisfied with the results, no action is required and your request will be automatically ' + 
                            'closed in 10 business days.<br/><br/>' + 
                            'If you are not satisfied with the results, please do the following:<br/><br/>' +
                            '1. Go to your SFA or CRM tool and click on the "Data Change Request" tab.<br/>' + 
                            '2. Go to the drop down box on upper left side of the screen called "View" and ' + 
                                'SELECT "Requires Requestor Action".<br/>' + 
                            '3. Click on the the link ' + changeRequest.Name + ' under "Change Request Name" to ' + 
                                'view the request that is ready to close.<br/>' +
                            '4. Click "Edit".<br/>' +
                            '5. Go to the "Status" field and SELECT "Disputed".<br/>' + 
                            '6. Type an explanation of the issue in the "Notes" box.<br/>' +
                            '7. Click "Save".<br/>' +
                            'We will investigate the identified dispute and work towards a resolution.<br/><br/>' + 
                            'Thanks,<br/><br/>' +
                            'Data Change Request Team<br/><br/>' ) ;
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    	
    }
    
    public static void sendEmail(Change_Request_gne__c changeRequest, Boolean isNeedInfo) {
        User requestor=[SELECT u.Email FROM User u WHERE u.Id=:changeRequest.CreatedById];
        sendEmail(changeRequest, isNeedInfo, requestor.email);
    }
    
    public static void sendRAEmail(Change_Request_gne__c changeRequest, String analystEmail) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {analystEmail});
        mail.setSenderDisplayName('Data Change Request Team');
        mail.setBccSender(false);
        mail.setSubject('ACTION REQUIRED: Data Change Request #'+ changeRequest.Name +' has been reassigned to you.');
        mail.setHtmlBody(   'Data Change Request #'+ changeRequest.Name +' has been reassigned to you.  Please find<br/>' +
                            'this request in the Data Change Request tab in SFDC and resolve it or<br/>' +
                            'reassign it to another request analyst.<br/>');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public static void sendRAEmail(Change_Request_gne__c changeRequest) {
        User analyst=[SELECT u.Email FROM User u WHERE u.Id=:changeRequest.Assigned_Analyst_gne__c];
        sendRAEmail(changeRequest, analyst.Email);
    }

    public static void sendHCPFMVTierRequestEmail(Change_Request_gne__c changeRequest) {
        List<GNE_SFA2_RCanada_DCR_Notification__c> notifications = GNE_SFA2_RCanada_DCR_Notification__c.getall().values();        
        List<String> userNames = new List<String>();
        for (GNE_SFA2_RCanada_DCR_Notification__c notif : notifications) {
            if (notif.Is_Active__c) {
                userNames.add(notif.Username__c);
            }
        }
        
        if (userNames.size() > 0) {
            Id template = [select id,Name from EmailTemplate where developername = 'GNE_SFA2_RCanada_DCR_Notification'].id;
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            List<User> users = [SELECT Id FROM User WHERE UserName in :userNames];
            
            for(User u : users){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTargetObjectId(u.Id);
                email.setWhatId(changeRequest.Id);
                email.setTemplateId(template);
                email.setSaveAsActivity(false);
                emails.add(email);
            }
            if(emails.size()>0){
                Messaging.sendEmail(emails);
            }
        }
    }
    
    public static void sendHCPUSLicensedPhysicianRequestEmail(Change_Request_gne__c changeRequest) {
        List<GNE_SFA2_RCanada_DCR_Notification__c> notifications = GNE_SFA2_RCanada_DCR_Notification__c.getall().values();        
        List<String> userNames = new List<String>();
        for (GNE_SFA2_RCanada_DCR_Notification__c notif : notifications) {
            if (notif.Is_Active__c) {
                userNames.add(notif.Username__c);
            }
        }

        if (userNames.size() > 0) {
            Id template = [select id,Name from EmailTemplate where developername = 'GNE_SFA2_US_DCR_Notification'].id;
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            List<User> users = [SELECT Id FROM User WHERE UserName in :userNames];
            
            for(User u : users){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTargetObjectId(u.Id);
                email.setWhatId(changeRequest.Id);
                email.setTemplateId(template);
                email.setSaveAsActivity(false);
                emails.add(email);
            }
            if(emails.size()>0){
                Messaging.sendEmail(emails);
            }
        }
    }
    
    public static Change_Request_gne__Share createChangeRequestShare(ID userOrGroupId, Change_Request_gne__c changeRequest, string  accessLevel, string rowCause) {
        //clearChangeRequestShare(userOrGroupId, changeRequest);
        Change_Request_gne__Share newShare = new Change_Request_gne__Share();
        newShare.ParentId = changeRequest.Id;
        newShare.UserOrGroupId = userOrGroupId;
        newShare.AccessLevel = accessLevel;
        newShare.RowCause = rowCause;
        return newShare;
    }
    
    public static Boolean clearChangeRequestShareByUserId(ID userOrGroupId, Change_Request_gne__c changeRequest) {
        Id crid=changeRequest.Id;
        List<Change_Request_gne__Share> oldShare = [SELECT crs.Id FROM Change_Request_gne__Share crs WHERE crs.UserOrGroupId=:userOrGroupId AND crs.ParentId=:crid];
        Boolean retVal=false;
        if(oldShare.size()>0) {
            retVal=true;
            delete oldShare;
        }
        return retVal;
    }
    
    public static Boolean clearChangeRequestShares(List<Id> changeRequestIdsToBeCleared){
        List<Change_Request_gne__Share> oldShares = [SELECT crs.Id FROM Change_Request_gne__Share crs WHERE crs.ParentId in :changeRequestIdsToBeCleared];
        Boolean retVal=false;
        if(oldShares.size()>0) {
            retVal=true;
            delete oldShares;
        }
        return retVal;
    }
    
    public static Change_Request_gne__Share[] getChangeRequestShare(ID userOrGroupId, Change_Request_gne__c changeRequest) {
        Id crid=changeRequest.Id;
        return [SELECT crs.Id FROM Change_Request_gne__Share crs WHERE crs.UserOrGroupId=:userOrGroupId AND crs.ParentId=:crid];
    }
    
    static string AnalystsQueueName='Data Change Request Analysts Queue';
    static string VendorQueueName='Data Change Request Vendors Queue';
    static string VendorQueueName1='Data Change Request Vendors Queue 1';
    static string VendorQueueName2='Data Change Request Vendors Queue 2';
    static string VendorGroupNames='Data Change Request Vendors Group,Data Change Request Vendors Group 1,Data Change Request Vendors Group 2';
    
    WebService static id getAnalystsQueueNameQueueID(){
        return [SELECT g.Id FROM Group g WHERE g.Name=:AnalystsQueueName].Id;
    }
    
    /*Return map with vendor type as key and queue id as value*/
    public static Map<String, Id>getVendorQueues(){
    	List<String>vendorQueueNames = new List<String>{VendorQueueName, VendorQueueName1, VendorQueueName2};
    	Map<String, Id>result = new Map<String, Id>();
    	for(Group g: [SELECT Id, Name FROM Group WHERE Name IN :vendorQueueNames]){
    		if(g.Name == VendorQueueName){
	    		result.put('ams', g.Id);
    		}else if (g.Name == VendorQueueName1){
    			result.put('bot', g.Id);
    		}else if (g.Name == VendorQueueName2){
    			result.put('generic', g.Id);
    		}
    	}
    	return result;
    }
    
    WebService static id getVendorQueueNameQueueID(Change_Request_gne__c changeRequest){
        String vqn;
        if(changeRequest.Vendor_Type_gne__c=='ams'){
        	vqn=VendorQueueName;
        }else if(changeRequest.Vendor_Type_gne__c=='bot'){
        	vqn=VendorQueueName1;
        }else if(changeRequest.Vendor_Type_gne__c=='generic'){
        	vqn=VendorQueueName2;
        }else{
        	return null;
        }
        return [SELECT g.Id FROM Group g WHERE g.Name=:vqn].Id;
    }
    
    WebService static Boolean isVendor(Id vendorId){
        List<String> vendorGroupsNames=VendorGroupNames.split(',',0);
        Set<id> vendorGroupsIds=(new Map<id,Group>([SELECT g.Id,g.Name FROM Group g WHERE g.Name in :vendorGroupsNames])).keySet();
        List<GroupMember> gms= [SELECT g.GroupId, g.UserOrGroupId FROM GroupMember g WHERE g.GroupId in :vendorGroupsIds AND g.UserOrGroupId=:vendorId ];
        return !gms.isEmpty();
    }
    
    @future
    Public static void CreateDataChangeRequestForGAPPayer(Id accountId){
        List<String> RecordTypesToTriggerDCRCreation=Utilities.getGlobalVariable('DataChangeRequestAccountRecordTypesToTriggerDCRGAPCreation').split(',',0);
        String justCreatedRecordTypeName=[SELECT RecordType.Name FROM Account WHERE Id=:accountId].RecordType.Name;
        Id recordTypeIdForSystemCreatedDCR=[SELECT Id FROM Recordtype WHERE Name='system Created' AND SobjectType='Change_Request_gne__c'].Id;
        for(String rt:RecordTypesToTriggerDCRCreation){
            if(rt==justCreatedRecordTypeName){
                Change_Request_gne__c cr=new Change_Request_gne__c(
                    RecordtypeId=recordTypeIdForSystemCreatedDCR,
                    Type_gne__c='system Created',
                    Description_gne__c='New GAP payer created',
                    Account_gne__c=accountId,
                    Vendor_Type_gne__c='sfdc',
                    Status_gne__c='Submitted',
                    OwnerID=ChangeRequestControllerHelper.getAnalystsQueueNameQueueID()
                    /*Apparently we can't use the workflow rule to change the ownership when the record is done by code.*/
                );
                insert cr;
                insert ChangeRequestControllerHelper.createChangeRequestShare([SELECT CreatedById FROM Account WHERE Id=:accountId].CreatedById,cr,'Read',Change_Request_gne__Share.RowCause.Original_Owner_gne__c);
                break;
            }
        }
    }
    
    @future
    Public static void moveBOTTicketsToVendorQueue(String ticketsIDs){
        List<string> dcrIds=ticketsIDs.split(',',0);
        List<Change_Request_gne__c> CRUpdates=[SELECT Id,Status_gne__c FROM Change_Request_gne__c WHERE id in :dcrIds];
        for(Change_Request_gne__c cr:CRUpdates) cr.Status_gne__c='Ready for Data Vendor';
        update CRUpdates;
    }
    
    // added to support september 2009 M&E 2009
    // PM Org Req #00002325
    // invoked FROM account after trigger 
    //@future    
    public static void  moveToAMSQueueOnAccountAMSIdUpdate (List<Id> acctIdList) {
        List<change_request_gne__c> dcrList
                            = [SELECT id, status_gne__c, ams_id_gne__c, ams_id_1_gne__c
                               FROM change_request_gne__c
                               WHERE        status_gne__c = 'Submitted'
                                        AND vendor_type_gne__c = 'ams'
                                        AND ams_id_gne__c != null
                                        AND Type_gne__c not in 
                                            ('Other Data Request',
                                             'HCO Remove Duplicate Organization',
                                             'HCP Remove Duplicate',
                                             'Duplicate Account')
                                         AND account_gne__c in :acctIdList 
                              ];

        for (change_request_gne__c dcr : dcrList) {
            dcr.ams_id_1_gne__c = dcr.ams_id_gne__c;
            dcr.status_gne__c   = 'Ready for Data Vendor';                        
        } 
        
        if ( dcrList.size() > 0 ){
            update dcrList;
        }
   }

    // invoked via visual force page     
    public static List<ApexPages.Message> moveToAMSQueue () {
	    // non duplicate DCRs       
        List<change_request_gne__c> dcrList
                            = [SELECT id, status_gne__c, ams_id_gne__c, ams_id_1_gne__c,
                                      Duplicate_Account_2_gne__c, ams_id_2_gne__c, 
                                      Duplicate_Account_3_gne__c, ams_id_3_gne__c,  
                                      Duplicate_Account_4_gne__c, ams_id_4_gne__c,  
                                      Duplicate_Account_5_gne__c, ams_id_5_gne__c,
                                      Type_gne__c   
                               FROM change_request_gne__c
                               WHERE        status_gne__c = 'Submitted'
                                        AND vendor_type_gne__c = 'ams'
                                        AND ams_id_gne__c != null
                                        AND Type_gne__c != null 
                                        AND Type_gne__c not in 
                                            ('Other Data Request',
                                             'Duplicate Account')
                               ];

        List<change_request_gne__c> nonDuplicateDCRList = new List<change_request_gne__c>();                               
        List<change_request_gne__c> duplicateDCRList = new List<change_request_gne__c>();                               
        
        List<ApexPages.Message> apexMessageList = new List<ApexPages.Message>();

        for (change_request_gne__c dcr : dcrList) {
            if ( dcr.Type_gne__c.contains('Duplicate') == false ) {
                dcr.ams_id_1_gne__c = dcr.ams_id_gne__c;
                dcr.status_gne__c   = 'Ready for Data Vendor';
                  
                String summary = 'DCR Id / Name ' +  dcr.Id + '/' + dcr.Name + ' Ready for Data Vendor.';
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info, summary, summary );
                apexMessageList.add ( msg); 
                  
                nonDuplicateDCRList.add ( dcr );
            } else {
               duplicateDCRList.add ( dcr );    
            }
        } 
        if ( nonDuplicateDCRList.size() > 0 ){
            update nonDuplicateDCRList; 
        }
        
    	// duplicate DCR processing:      
        Set<Id> acctIdSet = new Set<Id>();
        for (change_request_gne__c dcr : duplicateDCRList) {
            acctIdSet.add(dcr.duplicate_account_2_gne__c);
            acctIdSet.add(dcr.duplicate_account_3_gne__c);
            acctIdSet.add(dcr.duplicate_account_4_gne__c);
            acctIdSet.add(dcr.duplicate_account_5_gne__c);
        } 
           
        Map<Id, Account> amsIDMap = new Map<Id,Account>([SELECT id, ams_id_gne__c, name FROM account WHERE id in :acctIdSet]);
        
        List<change_request_gne__c> updateDuplicateDCRList = new List<change_request_gne__c>(); 
        for (change_request_gne__c dcr : duplicateDCRList) {            

            dcr.ams_id_2_gne__c = dcr.duplicate_account_2_gne__c != null ? amsIDMap.get(dcr.duplicate_account_2_gne__c).ams_id_gne__c:null;
            dcr.ams_id_3_gne__c = dcr.duplicate_account_3_gne__c != null ? amsIDMap.get(dcr.duplicate_account_3_gne__c).ams_id_gne__c:null;
            dcr.ams_id_4_gne__c = dcr.duplicate_account_4_gne__c != null ? amsIDMap.get(dcr.duplicate_account_4_gne__c).ams_id_gne__c:null;
            dcr.ams_id_5_gne__c = dcr.duplicate_account_5_gne__c != null ? amsIDMap.get(dcr.duplicate_account_5_gne__c).ams_id_gne__c:null;

            Boolean bReadyforVendor = true;
            dcr.ams_id_1_gne__c = dcr.ams_id_gne__c;

            if ( dcr.duplicate_account_2_gne__c != null ) 
                if ( dcr.ams_id_2_gne__c == null )
                    bReadyforVendor = false;
            
            if ( bReadyforVendor && dcr.duplicate_account_3_gne__c != null ) 
                if ( dcr.ams_id_3_gne__c == null )
                    bReadyforVendor = false;
            
            if ( bReadyforVendor && dcr.duplicate_account_4_gne__c != null ) 
                if ( dcr.ams_id_4_gne__c == null )
                    bReadyforVendor = false;

            if ( bReadyforVendor && dcr.duplicate_account_5_gne__c != null ) 
                if ( dcr.ams_id_5_gne__c == null )
                    bReadyforVendor = false;
                                    
            if ( bReadyforVendor ) {
                dcr.status_gne__c ='Ready for Data Vendor';
                updateDuplicateDCRList.add ( dcr );
                String summary = 'DCR Id / Name ' +  dcr.Id + '/' + dcr.Name + ' Ready for Data Vendor.';
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Info, summary, summary );
                apexMessageList.add ( msg); 
            }                
        } 
                        
        if ( updateDuplicateDCRList.size() > 0 ){
            update updateDuplicateDCRList;
        }
        return apexMessageList;         
   }
    
    public static Boolean amsDCRReadyForVendor (Change_Request_gne__c dcr) {
        Set<Id> acctIdSet = new Set<Id>();
        Boolean bReadyforVendor = true;
        try {
            RecordType rt = [SELECT id, name, DeveloperName FROM recordtype WHERE sobjecttype ='change_request_gne__c' AND Id = :dcr.recordTypeId];
            dcr.Type_gne__c = rt.Name;
            acctIdSet.add(dcr.account_gne__c);  
            
            if (rt.DeveloperName.equalsIgnoreCase ('HCP_Remove_Duplicate') || rt.DeveloperName.equalsIgnoreCase ('HCO_Remove_Duplicate_Organization')){
                acctIdSet.add(dcr.duplicate_account_2_gne__c);
                acctIdSet.add(dcr.duplicate_account_3_gne__c);
                acctIdSet.add(dcr.duplicate_account_4_gne__c);
                acctIdSet.add(dcr.duplicate_account_5_gne__c);
            }        
    
            Map<Id, Account> amsIDMap = new Map<Id,Account>([SELECT id, ams_id_gne__c, name FROM account WHERE id in :acctIdSet]);
            if ( dcr.account_gne__c != null && amsIDMap.get(dcr.account_gne__c).ams_id_gne__c == null){
            	bReadyforVendor = false;
            }
            if ( dcr.duplicate_account_2_gne__c != null && amsIDMap.get(dcr.duplicate_account_2_gne__c).ams_id_gne__c  == null){
                bReadyforVendor = false;
            }
            if ( dcr.duplicate_account_3_gne__c != null && amsIDMap.get(dcr.duplicate_account_3_gne__c).ams_id_gne__c  == null){
                bReadyforVendor = false;
            }
            if ( dcr.duplicate_account_4_gne__c != null && amsIDMap.get(dcr.duplicate_account_4_gne__c).ams_id_gne__c  == null){
                bReadyforVendor = false;
            }
            if ( dcr.duplicate_account_5_gne__c != null && amsIDMap.get(dcr.duplicate_account_5_gne__c).ams_id_gne__c  == null){
                bReadyforVendor = false;
            }
        } catch (Exception e) {                                                                 
            system.debug ( 'amsDCRReadyForVendor error message --> ' + e.getMessage());
        }
        system.debug ('amsDCRReadyForVendor return value -->'+ bReadyforVendor );
        return bReadyforVendor; 
    }   
}