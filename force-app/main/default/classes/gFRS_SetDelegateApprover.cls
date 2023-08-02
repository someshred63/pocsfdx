/**
* @author GFRS Dev Team
* @date 29/08/2013
* @description gFRS_SetDelegateApprover class - Core class for process user delegation.
* Run in gFRS_SetDelegateApproverBatch class.
*/
public without sharing class gFRS_SetDelegateApprover implements gFRS_ISetDelegateApprover
{

    List<gFRS_Funding_Request__Share> listOfFundingShares = new List<gFRS_Funding_Request__Share>();
    
    /**
    * @author GFRS Dev Team
    * @date 29/08/2013
    * @description main constructor gFRS_SetDelegateApprover()  
    */
    public gFRS_SetDelegateApprover()
    {
    // main constructor. Do nothing
    }
    
    /**
    * @author GFRS Dev Team
    * @date 29/08/2013
    * @description processDelegateApprovers method - Main method for process user delegation. If any active delegation is set in GNE_User_Delegation__c object, method
    * takes all pending actions from ProcessWorkItem (for Funding Requests) for those users and re-assign workitems to delegate users. 
    */
    public void processDelegateApprovers(List<GNE_User_Delegation__c> listUserDelegations)
    {
      
      Map<Id,Id> userDelegationMap                          = new Map<Id,Id>();//User Id, Delegated User Id
      Map<Id,Id> requestMapFRIdOnUserID                     = new Map<Id, Id>();// map for link funding rquest id with user Id.
      List<ProcessInstanceWorkItem> listWorkItemsForUpdate  = New List<ProcessInstanceWorkItem>();
      List<GFRS_Funding_Request__c> fundingRequestForUpdate = New List<GFRS_Funding_Request__c>(); 
          
          for(GNE_User_Delegation__c obj : listUserDelegations)
          {
                userDelegationMap.put(obj.Username__c, obj.Delegated_User__c); // create map of delegate users
          }
           
          
          
          for(ProcessInstanceWorkItem workItem :
           [SELECT Id, ActorId, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem 
           WHERE ProcessInstance.Status='Pending' 
           //AND ProcessInstance.TargetObject.Type='gFRS_Funding_Request__c' -- updated as below to extend delegation to copay funding requests as well
           AND ProcessInstance.TargetObject.Type in ('gFRS_Funding_Request__c','gFRS_Copay_Funding_Request__c') // gFRS CoPay Dev - 12/27/2017
           AND ActorId IN :userDelegationMap.keySet()])
           {
               // add to request map with orginal users. Used for further FA3 update
               requestMapFRIdOnUserID.put(workItem.ProcessInstance.TargetObjectId,workItem.ActorId);
                
               id delegateUserID = userDelegationMap.get(workItem.ActorId);
               workItem.ActorId  = delegateUserID;

               listWorkItemsForUpdate.Add(workItem);
              
               //createManualSharingForFunding(delegateUserID, workItem.ProcessInstance.TargetObjectId);// grant access for delegate user for funding.
           }
          
       //Check if orginal approver user is FA3 in Funding request record.
       //If orginal user was FA3 - update Financial_Approver_3__c field with delegated id.
       for(GFRS_Funding_Request__c objFR : [SELECT (SELECT AccessLevel, Id, ParentId, RowCause, UserOrGroupId FROM Shares),Id, Financial_Approver_3__c,Financial_Approver_1__c,Business_Reviewer_1__c,Business_Approver__c,Business_Approver_2__c,Business_Approver_3__c,Record_Type_Name__c,Foundation_Classified__c,Business_Reviewer_Decision_Date__c,Business_Approver_2_Decision_Date__c,Business_Approver_3_Decision_Date__c,Business_Approver_Decision_Date__c,GC_Review_Decision_Date__c FROM GFRS_Funding_Request__c WHERE Id IN : requestMapFRIdOnUserID.keySet()])
       {
               Boolean recordEditable = false;
               Id userId              = null;

        	if((objFR.Record_Type_Name__c == 'Corporate Memberships' || objFR.Record_Type_Name__c == 'Exhibits & Other Promos' || objFR.Record_Type_Name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME) &&  objFR.Financial_Approver_3__c == requestMapFRIdOnUserID.get(objFR.id))
        	{
                objFR.Financial_Approver_3__c = userDelegationMap.get(objFR.Financial_Approver_3__c);//get delegated user id.
                userId                        = objFR.Financial_Approver_3__c;

        		fundingRequestForUpdate.add(objFR);
        		
        	}else if(objFR.Record_Type_Name__c == 'Field Initiated Exhibits' &&  objFR.Financial_Approver_1__c == requestMapFRIdOnUserID.get(objFR.id)){
                objFR.Financial_Approver_1__c = userDelegationMap.get(objFR.Financial_Approver_1__c);//get delegated user id.
                fundingRequestForUpdate.add(objFR);
                userId                        = objFR.Financial_Approver_1__c;
                recordEditable                = true;

        	}else if(objFR.Foundation_Classified__c == 'FALSE' && (objFR.Record_Type_Name__c == 'Scientific Projects' || objFR.Record_Type_Name__c == 'Fellowships' || objFR.Record_Type_Name__c == 'HC Char' || objFR.Record_Type_Name__c == 'Philanthropic' ) &&  objFR.Business_Approver__c == requestMapFRIdOnUserID.get(objFR.id)){
                objFR.Business_Approver__c = userDelegationMap.get(objFR.Business_Approver__c);//get delegated user id.
                fundingRequestForUpdate.add(objFR);
                userId                     = objFR.Business_Approver__c;
                recordEditable             = true;

        	}else if(objFR.Foundation_Classified__c == 'TRUE'){
        		
                Id userWhichSetDelegation    = requestMapFRIdOnUserID.get(objFR.id);
                Boolean isRequestAddedToList = false;
        		
        		if(objFR.Business_Reviewer_1__c == userWhichSetDelegation && objFR.GC_Review_Decision_Date__c != null && objFR.Business_Reviewer_Decision_Date__c == null){
        			objFR.Business_Reviewer_1__c =userDelegationMap.get(objFR.Business_Reviewer_1__c);//set delegated user id.
        			if(!isRequestAddedToList){
        				fundingRequestForUpdate.add(objFR);
        				isRequestAddedToList = true;
        			}
                    userId         = objFR.Business_Reviewer_1__c;
                    recordEditable = true;
        		}
        		if(objFR.Business_Approver_2__c == userWhichSetDelegation && objFR.Business_Approver_Decision_Date__c != null && objFR.Business_Approver_2_Decision_Date__c == null){
        			objFR.Business_Approver_2__c = userDelegationMap.get(objFR.Business_Approver_2__c);//set delegated user id.
        			if(!isRequestAddedToList){
        				fundingRequestForUpdate.add(objFR);
        				isRequestAddedToList=true;
        			}
                    userId         = objFR.Business_Approver_2__c;
                    recordEditable = true;
        		}
        		
        		if(objFR.Business_Approver_3__c == userWhichSetDelegation && objFR.Business_Approver_3_Decision_Date__c == null && objFR.Business_Approver_2_Decision_Date__c != null){
        			
        			objFR.Business_Approver_3__c =userDelegationMap.get(objFR.Business_Approver_3__c);//set delegated user id.
        			if(!isRequestAddedToList){
        				fundingRequestForUpdate.add(objFR);
        				isRequestAddedToList = true;
        			}
                    userId         = objFR.Business_Approver_3__c;
                    recordEditable = true;
        			
        		}
        		//This If must be as last one BA1 for FOUNDATION should have read permission but if any BR BA2 BA3 id the same then sharing would edit
        		if(objFR.Business_Approver__c == userWhichSetDelegation && objFR.Business_Reviewer_Decision_Date__c != null && objFR.Business_Approver_Decision_Date__c == null){
        			objFR.Business_Approver__c = userDelegationMap.get(objFR.Business_Approver__c);//set delegated user id.
        			if(!isRequestAddedToList){
        				fundingRequestForUpdate.add(objFR);
        				isRequestAddedToList = true;
        			}
        			userId=objFR.Business_Approver__c;
	        		system.debug('Set sharing for BA1');
        		}
        		
        	}else{
        		userId=userDelegationMap.get(requestMapFRIdOnUserID.get(objFR.id));
        	}
        	
        	Boolean checkIfSharingExistForUser=false;
        	gFRS_Funding_Request__Share recordSharingItem=null;
        	for(gFRS_Funding_Request__Share recordSharing : objFR.Shares){
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
	    	 
	    	 //update listWorkItemsForUpdate;
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
             Map<ID,GFRS_Funding_Request__c> requestWithErrorsMap = new Map<ID,GFRS_Funding_Request__c>(fundingRequestForUpdate);
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
			  	 for(GFRS_Funding_Request__c requestErrorItem:requestWithErrorsMap.values()){
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
                    GFRS_OrgSettings__c myOrgCS       = GFRS_OrgSettings__c.getOrgDefaults();
                    String emailAddress               = myOrgCS.SupportEmailGroup__c;
	                
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
    
    /**
    * @author GFRS Dev Team
    * @date 30/08/2013
    * @description pirvate method for set read manual sharing record for delegate user on funding request record.  
    */
    private void createManualSharingForFunding(Id userId, Id fundingId,String AccessLevel)
    {
        gFRS_Funding_Request__Share requestShr = new gFRS_Funding_Request__Share();
        requestShr.ParentId                    = fundingId;
        requestShr.UserOrGroupId               = userId;
        requestShr.AccessLevel                 = AccessLevel;
        requestShr.RowCause                    = Schema.gFRS_Funding_Request__Share.RowCause.Manual;
        
        listOfFundingShares.add(requestShr);
    }
}