public class gFRS_Ltng_SetDelegateApprover {
    
    List<gFRS_Ltng_Application__Share> listOfFundingShares = new List<gFRS_Ltng_Application__Share>();
    
    public void processDelegateApprovers(List<GNE_User_Delegation__c> listUserDelegations)
    {
        
        Map<Id,Id> userDelegationMap                          = new Map<Id,Id>();//User Id, Delegated User Id
        Map<Id,Id> requestMapFRIdOnUserID                     = new Map<Id, Id>();// map for link funding rquest id with user Id.
        List<ProcessInstanceWorkItem> listWorkItemsForUpdate  = New List<ProcessInstanceWorkItem>();
        List<gFRS_Ltng_Application__c> fundingRequestForUpdate = New List<gFRS_Ltng_Application__c>(); 
        
        for(GNE_User_Delegation__c obj : listUserDelegations)
        {
            userDelegationMap.put(obj.Username__c, obj.Delegated_User__c); // create map of delegate users
        }
        
        
        
        for(ProcessInstanceWorkItem workItem :
            [SELECT Id, ActorId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem 
             WHERE ProcessInstance.Status='Pending' 
             //AND ProcessInstance.TargetObject.Type='gFRS_Funding_Request__c' -- updated as below to extend delegation to copay funding requests as well
             AND ProcessInstance.TargetObject.Type in ('gFRS_Ltng_Application__c') 
             AND ActorId IN :userDelegationMap.keySet()])
        {
            // add to request map with orginal users. Used for further FA3 update
            requestMapFRIdOnUserID.put(workItem.ProcessInstance.TargetObjectId,workItem.ActorId);
            
            id delegateUserID = userDelegationMap.get(workItem.ActorId);
            workItem.ActorId  = delegateUserID;
            
            listWorkItemsForUpdate.Add(workItem);
            
            //createManualSharingForFunding(delegateUserID, workItem.ProcessInstance.TargetObjectId);// grant access for delegate user for funding.
        }
        
        
        for(gFRS_Ltng_Application__c objFR : [SELECT (SELECT AccessLevel, Id, ParentId, RowCause, UserOrGroupId FROM Shares),Id,
                                              Business_Approver__c,Record_Type_Name__c,Finance_Approver__c,Finance_Manager__c,Financial_Approver_1__c
                                              FROM gFRS_Ltng_Application__c WHERE Id IN : requestMapFRIdOnUserID.keySet()])
        {
            Boolean recordEditable = false;
            Id userId              = null;
            
            if(objFR.Record_Type_Name__c == 'Field Exhibits' &&  objFR.Business_Approver__c == requestMapFRIdOnUserID.get(objFR.id))
            {
                objFR.Business_Approver__c = userDelegationMap.get(objFR.Business_Approver__c);//get delegated user id.
                userId                        = objFR.Business_Approver__c;
                
                fundingRequestForUpdate.add(objFR);
                
            }else if(objFR.Record_Type_Name__c == 'Commercial Sponsorship' || objFR.Record_Type_Name__c == 'Non-Commercial Sponsorship'
                     || objFR.Record_Type_Name__c == 'Corporate Memberships')
            {
                System.debug('@@@@ Dev Env'+objFR.Record_Type_Name__c);
                
                if(objFR.Business_Approver__c == requestMapFRIdOnUserID.get(objFR.id))
                {
                    System.debug('@@@@ Dev Env Bussiness Approver'+objFR.Business_Approver__c);
                    
                    objFR.Business_Approver__c = userDelegationMap.get(objFR.Business_Approver__c);//get delegated user id.
                    // fundingRequestForUpdate.add(objFR);
                    
                    userId                        = objFR.Business_Approver__c;
                    recordEditable                = true;
                    
                }
                if(objFR.Finance_Approver__c == requestMapFRIdOnUserID.get(objFR.id))
                {
                    
                    objFR.Finance_Approver__c = userDelegationMap.get(objFR.Finance_Approver__c);//get delegated user id.
                    // fundingRequestForUpdate.add(objFR);
                    
                    userId                        = objFR.Finance_Approver__c;
                    recordEditable                = true; 
                    
                }
                if(objFR.Finance_Manager__c == requestMapFRIdOnUserID.get(objFR.id))
                {
                    
                    objFR.Finance_Manager__c = userDelegationMap.get(objFR.Finance_Manager__c);//get delegated user id.
                    //fundingRequestForUpdate.add(objFR);
                    
                    userId                        = objFR.Finance_Approver__c;
                    recordEditable                = true;
                    
                }
                fundingRequestForUpdate.add(objFR);  
                
            }
            else{
                userId=userDelegationMap.get(requestMapFRIdOnUserID.get(objFR.id));
            }
            
            Boolean checkIfSharingExistForUser=false;
            gFRS_Ltng_Application__Share recordSharingItem=null;
            for(gFRS_Ltng_Application__Share recordSharing : objFR.Shares){
                if(recordSharing.UserOrGroupId == userId){
                    checkIfSharingExistForUser =true;
                    recordSharingItem          =recordSharing;
                    break;
                }
            }
            if(checkIfSharingExistForUser){
                if(recordEditable && recordSharingItem.RowCause != 'Owner'){
                    recordSharingItem.AccessLevel='Edit';
                    listOfFundingShares.add(recordSharingItem);
                }
            }else{
                if(recordEditable){
                    createManualSharingForFunding(userId,objFR.id,'Edit');
                }else{
                    createManualSharingForFunding(userId,objFR.id,'Read');
                }
                
            }
            
            
        }
        
        
        String outMessage='';
        // Re assign to delegated    
        
        if(listWorkItemsForUpdate.Size()>0){
            Database.SaveResult[] srWorkItemUpdate= Database.update(listWorkItemsForUpdate,false);
            for(Database.SaveResult upResult:srWorkItemUpdate){
                if (!upResult.isSuccess()) {
                    for(Database.Error err : upResult.getErrors()) {
                        outMessage = outMessage+'The following error: Exception has occurred while work Item update\n';
                        outMessage = outMessage+err.getStatusCode() + ': ' + err.getMessage()+err.getFields()+'\n';
                        outMessage = outMessage+'\n following work Item can not be updated: '+upResult.getId();
                        System.debug('The following error: Exception has occurred while work Item update');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('following work Item can not be updated: ' +upResult.getId());
                    }
                }
            }
            
            update listWorkItemsForUpdate;
        }	  
        
        
        
        //adding shares  
        if(listOfFundingShares.Size()>0){
            Database.upsertResult[] srUpsertList = Database.upsert(listOfFundingShares,false);
            //upsert listOfFundingShares;
            for(Database.upsertResult upsResult:srUpsertList){
                if (!upsResult.isSuccess()) {
                    for(Database.Error err : upsResult.getErrors()) {
                        outMessage =outMessage+'The following error: Exception has occurred while adding sharing\n';
                        outMessage =outMessage+err.getStatusCode() + ': ' + err.getMessage()+err.getFields()+'\n';
                        
                        System.debug('The following error: Exception has occurred while adding sharing');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        
                        
                    }
                }
            }
        }
        //update funding requests
        if(fundingRequestForUpdate.Size()>0){
            
            //Database.SaveResult[] srFundingRequestUpdate         = Database.update(fundingRequestForUpdate,false);
            
            Map<ID,gFRS_Ltng_Application__c> requestWithErrorsMap = new Map<ID,gFRS_Ltng_Application__c>(fundingRequestForUpdate);
            String requestIdsSeparated                           = '';
            Database.SaveResult[] srFundingRequestUpdate         = Database.update(fundingRequestForUpdate,false);
            
            for(Database.SaveResult upResult:srFundingRequestUpdate){
                if (!upResult.isSuccess()) {
                    for(Database.Error err : upResult.getErrors()) {
                        outMessage = outMessage+'The following error: Exception has occurred while funding request update\n';
                        outMessage = outMessage+err.getStatusCode() + ': ' + err.getMessage()+err.getFields()+'\n';                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage() +err.getFields());
                        System.debug('following funding request record can not be updated: '+upResult.getId());
                        
                    }
                }else if(upResult.isSuccess()){
                    if(upResult.getId()!= null){
                        requestWithErrorsMap.remove(upResult.getId());
                    }
                }
            }
            if(requestWithErrorsMap.values().size()>0){
                outMessage =outMessage+'\n <b>Above errors occurs for following funding requests Ids<\b>\n';
                for(gFRS_Ltng_Application__c requestErrorItem:requestWithErrorsMap.values()){
                    outMessage =outMessage+'\n'+requestErrorItem.id+',';
                }
            } 
            
        }
        
        if(outMessage != ''){
            try{
                String orgName = UserInfo.getUserName().substringAfterLast('.')+'( '+Userinfo.getOrganizationId()+' )';
                
                System.debug('preparing message to sent with notification');
                String subject                    = 'Problems with GFRS delegation schedule job on '+orgName +' environment';
                Id senderId                       = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address='fundingrequestsystem-donotreply-d@gene.com' limit 1][0].id;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                List<String> addressList          = new List<String>();
                //GFRS_OrgSettings__c myOrgCS       = GFRS_OrgSettings__c.getOrgDefaults();
                String emailAddress               =  'mylavarv@gene.com,cheedals@gene.com';//myOrgCS.SupportEmailGroup__c;
                
                addressList.addAll(emailAddress.split(','));
                
                mail.setToAddresses(addressList);
                mail.setSubject( subject );
                mail.setHtmlBody(outMessage);
                mail.setOrgWideEmailAddressId(senderId);
                
                Messaging.sendEmail(new Messaging.SingleEmailMessage []{mail},false);
            }catch(Exception err){
                system.debug(err.getMessage());
            }
        } 	        
    } 
    
    
    private void createManualSharingForFunding(Id userId, Id fundingId,String AccessLevel)
    {
        gFRS_Ltng_Application__Share requestShr = new gFRS_Ltng_Application__Share();
        requestShr.ParentId                    = fundingId;
        requestShr.UserOrGroupId               = userId;
        requestShr.AccessLevel                 = AccessLevel;
        requestShr.RowCause                    = Schema.gFRS_Ltng_Application__Share.RowCause.Manual;
        
        listOfFundingShares.add(requestShr);
    }
    
}