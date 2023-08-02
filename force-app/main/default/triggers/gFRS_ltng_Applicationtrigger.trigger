trigger gFRS_ltng_Applicationtrigger on gFRS_Ltng_Application__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	
    GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
    if(myOrgCS.Application_Trigger_Switch__c == false){
        system.debug('@@@ Inside Trigger Switch');
        return;
    }
    
    gFRS_Ltng_ApplicationTriggerHandler handler = new gFRS_Ltng_ApplicationTriggerHandler();
    List<ContentDocument> listCD = new List<ContentDocument>();
    List<ContentDocument> listCD2 = new List<ContentDocument>();
    Map<Id,Id> cdMap = new Map<Id,Id>();
     
    //Before Insert
    if(Trigger.isInsert && Trigger.isBefore){
       // handler.updateRFIStaus(trigger.new,null);
    }
    //After Insert
    else if(Trigger.isInsert && Trigger.isAfter){
                    
    }
    //Before Update
    else if(Trigger.isUpdate && Trigger.isBefore){
       // handler.updateRFIStaus(trigger.new,trigger.oldMap);
        //handler.updatePaymentEmailNotification(trigger.new,trigger.oldMap);
    }
    //After Update
    else if(Trigger.isUpdate && Trigger.isAfter){  
        //handler.attachCompliancePDF(trigger.new,trigger.oldMap);
        handler.addApprAmountToOrg(trigger.new,trigger.oldMap);   
        handler.addSharingForApprovers(trigger.newMap,trigger.oldMap);  
        
        for (gFRS_Ltng_Application__c newRequest : trigger.newMap.values()) { 
            if((trigger.oldMap.get(newRequest.id).Sub_Status__c!=newRequest.Sub_Status__c) && (newRequest.Status__c == 'Processing & Disposition' && newRequest.Sub_Status__c == 'Approved-Awaiting LOA' && newRequest.External_Status__c == 'Approved-Awaiting LOA')){
                String jsonNewApp = JSON.serialize(newRequest);
                gFRS_Ltng_ApplicationTriggerHandler.generateDecisionFlagForBulkApproval(jsonNewApp);
                
            }
        }
        
        //handler.generateDecisionFlagForBulkApproval(trigger.newMap,trigger.oldMap);
        handler.createAppropriateTask(trigger.newMap,trigger.oldMap);
       // handler.createEvaluationTask(trigger.newMap,trigger.oldMap);
        gFRS_Ltng_PaymentUtil.releaseIBlock(trigger.newMap,trigger.oldMap);
        gFRS_Ltng_PaymentUtil.setSubStatusForPaymentsLoaChanged(trigger.newMap,trigger.oldMap);
        
         for(Integer i=0;i<trigger.new.size();i++){ 
            if(trigger.new[i].Status__c == 'Processing & Disposition' && trigger.new[i].Sub_Status__c == 'Approved-Awaiting LOA'&& trigger.new[i].External_Status__c == 'Approved-Awaiting LOA'){ 
                if(trigger.new[i].Record_Type__c != 'Field exhibits' && trigger.new[i].Shrink_Wrap_LOA__c == 'No' && trigger.new[i].Sub_Status__c != trigger.old[i].Sub_Status__c && trigger.new[i].External_Status__c != trigger.old[i].External_Status__c ){
                    gFRS_Ltng_Application__c gFRSApp = [Select id,Status__c,Sub_Status__c,RecordTypeId,RecordType.Name,Accountable_Employee_Role__c,Internal_Organization_Area__c,Benefits_Exchanged_for_Internal_Funding__c,Approved_Amount__c from gFRS_Ltng_Application__c  where Id = :trigger.new[i].Id];
                    if(gFRSApp.RecordType.Name == 'Commercial Sponsorship' || gFRSApp.RecordType.Name == 'Corporate Memberships' || gFRSApp.RecordType.Name == 'Non-Commercial Sponsorship'){
                         //gFRS_DocusignAttachPDF.InsertDocument(trigger.new[i].Id);
                        gFRS_DocusignAttachPDF_Internal.InsertDocument(trigger.new[i].Id);
                        SendToDocuSignController.SendNow(trigger.new[i].Id);
                        
                        if(gFRSApp.RecordType.Name == 'Corporate Memberships'){
                            String compliancedocumentName = 'Decision_Flags_' + trigger.new[i].Name;
                            gFRS_Ltng_Compliance_Flag_Util_FE.generatePDF(trigger.new[i].Id,compliancedocumentName);
                        } else {
                            String compliancedocumentName = 'Decision_Flags_' + trigger.new[i].Name;
                            gFRS_Ltng_Compliance_Flag_Util_Comm.generatePDF(trigger.new[i].Id,compliancedocumentName);
                        }
                        
                    }
                    
                    
                    if(gFRSApp.RecordType.Name == 'Independent Medical Education (CME)'){
                        gFRS_DocusignAttachPDF_CME.InsertDocument(trigger.new[i].Id,'');
                        SendToDocuSignController.SendNow(trigger.new[i].Id);
                    }
                    if(gFRSApp.RecordType.Name == 'Community Giving' || gFRSApp.RecordType.Name == 'Education Focused Giving K-12'){
                        gFRS_DocusignAttachPDF_CG_K12.InsertDocument(trigger.new[i].Id,'');
                        SendToDocuSignController.SendNow(trigger.new[i].Id);                        
                    }
                    if(gFRSApp.RecordType.Name == 'Patient and Health Focused Giving' || gFRSApp.RecordType.Name == 'Scientific and Research Focused Giving' || gFRSApp.RecordType.Name == 'Education Focused Giving Graduate and Post-Graduate'){
                        gFRS_DocusignAttachPDF_Pat_Sci_Edu.InsertDocument(trigger.new[i].Id,'');
                        SendToDocuSignController.SendNow(trigger.new[i].Id);
                    }
                    if(gFRSApp.RecordType.Name == 'Foundation Safety Net Support' || gFRSApp.RecordType.Name == 'Foundation Undergraduate'){
                        gFRS_DocusignAttachPDF_Foundation.InsertDocument(trigger.new[i].Id,'');
                        SendToDocuSignController.SendNow(trigger.new[i].Id);
                    }
                    //gFRS_DocusignSendAPI.sendwithDocusign(trigger.new[i].Id);
                    //SendToDocuSignController.SendNow(trigger.new[i].Id);
                }
            } else if(trigger.new[i].Status__c == 'Processing & Disposition' && trigger.new[i].Sub_Status__c == 'Process Payment' && trigger.new[i].External_Status__c == 'Approved'){
                if((trigger.new[i].Record_Type__c == 'Field exhibits' || trigger.new[i].Shrink_Wrap_LOA__c == 'Yes') && trigger.new[i].Sub_Status__c != trigger.old[i].Sub_Status__c && trigger.new[i].External_Status__c != trigger.old[i].External_Status__c ){
                    gFRS_DocusignAttachPDF_Internal.InsertDocument(trigger.new[i].Id);
                    String compliancedocumentName = 'Decision_Flags_' + trigger.new[i].Name;
                    gFRS_Ltng_Compliance_Flag_Util_FE.generatePDF(trigger.new[i].Id,compliancedocumentName);
                } else if(trigger.new[i].Sub_Status__c != trigger.old[i].Sub_Status__c && trigger.new[i].External_Status__c != trigger.old[i].External_Status__c){
                    List<gFRS_Ltng_Task__c> taskRecord = new List<gFRS_Ltng_Task__c>();
                    taskRecord = [SELECT Id, Action_Type__c, Status__c, gFRS_Application__c FROM gFRS_Ltng_Task__c WHERE Action_Type__c = 'Letter of Agreement(LOA)' AND Status__c = 'Open' AND gFRS_Application__c =: trigger.new[i].Id LIMIT 1];
                    
                    if(taskRecord.size() > 0){
                        taskRecord[0].Status__c = 'Completed';
                        gFRS_Ltng_Util_NoShare.updateTask(taskRecord[0]);
                    }
                    
                }
            }
             if(trigger.new[i].Executed_LOA_Document_ID__c != '' && trigger.new[i].Executed_LOA_Document_ID__c != trigger.old[i].Executed_LOA_Document_ID__c){
                 cdMap.put(trigger.new[i].Executed_LOA_Document_ID__c, trigger.new[i].OwnerId);
             }
        }
        if(cdMap.size() > 0){
            set<Id> userIDs = new set<Id>(cdMap.values());
            List<User> userListActivation = new List<User>();
            List<User> userList = [SELECT Id, Name, Isactive FROM User WHERE Id in :userIDs ];
            
            for(User U : userList){
                if(U.Isactive == false){
                    User userRec = new User();
                    userRec.Id 		 = U.Id;
                    userRec.Isactive = true;
                    userListActivation.add(userRec);
                }
            }
            
            if(userListActivation.size() > 0){
                //update userListActivation;
                System.enqueueJob(new gFRS_Ltng_ActivateUsers_ExecuteLOA(userListActivation,cdMap));
            } else {
                listCD = [SELECT Id, OwnerId FROM ContentDocument WHERE Id IN : cdMap.keySet()];
                for(ContentDocument CD : listCD){
                    CD.OwnerId = cdMap.get(CD.Id);
                    listCD2.add(CD);
                }
                update listCD2;
            }
            
        }
        
    }
    //Before Delete
    else if(Trigger.isDelete && Trigger.isBefore){
        
    }
    //After Delete
    else if(Trigger.isDelete && Trigger.isAfter){
        
    }
    //After Undelete
    else if(Trigger.isUnDelete){
        
    }
}