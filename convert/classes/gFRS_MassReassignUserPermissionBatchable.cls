global without sharing class gFRS_MassReassignUserPermissionBatchable implements Database.Batchable<sObject>{
	
	global Database.Querylocator start(Database.BatchableContext BC){     
	        String query = 'select ActorId, OriginalActorId,ProcessInstance.TargetObjectId from ProcessInstanceWorkItem where ProcessInstanceWorkItem.ProcessInstance.TargetObject.Type = \'GFRS_Funding_Request__c\' and ProcessInstanceWorkItem.ProcessInstance.status=\'Pending\'';  
	        return Database.getQueryLocator(query);
	    }
	    
	    global void execute(Database.BatchableContext BC, List<sObject> scope){
			Map<ID,ProcessInstanceWorkItem> processInstansItems = new Map<Id,ProcessInstanceWorkItem>();
			List<Id> fundinfRequestIDs                          = new List<ID>();
			Integer i                                           = 0;
			
	    	for(Sobject item:scope){
	    		ProcessInstanceWorkItem processItem=(ProcessInstanceWorkItem)item;
	    		processInstansItems.put(processItem.ProcessInstance.TargetObjectId,processItem);
	    		fundinfRequestIDs.add(processItem.ProcessInstance.TargetObjectId);
	    		i++;
	    	}
	    	
	    	List<gFRS_Funding_Request__Share> listOfFundingShares = new List<gFRS_Funding_Request__Share>();
	    	
	    	
	    	for(GFRS_Funding_Request__c objFR : [select (select AccessLevel, Id, ParentId, RowCause, UserOrGroupId from Shares),Id, Financial_Approver_3__c,Financial_Approver_1__c,Business_Reviewer_1__c,Business_Approver__c,Business_Approver_2__c,Business_Approver_3__c,Record_Type_Name__c,Foundation_Classified__c from GFRS_Funding_Request__c where id in : fundinfRequestIDs])
	        {
	       		Boolean recordEditable=false;
	       		Id userId=null;
	       		ProcessInstanceWorkItem processItemTmp=(ProcessInstanceWorkItem)processInstansItems.get(objFR.id);
	       		//if current is FA1 add edit Rights
	        	if(objFR.Record_Type_Name__c == 'Field Initiated Exhibits' &&  objFR.Financial_Approver_1__c == processItemTmp.ActorId){
	        		userId=objFR.Financial_Approver_1__c;
	        		recordEditable=true;
	        	}else if(objFR.Foundation_Classified__c == 'TRUE' && (processItemTmp.ActorId == objFR.Business_Reviewer_1__c || processItemTmp.ActorId == objFR.Business_Approver_2__c || processItemTmp.ActorId == objFR.Business_Approver_3__c)){
	        		userId=processItemTmp.ActorId;
	        		recordEditable=true;
	        	}else if(objFR.Foundation_Classified__c == 'FALSE' && (objFR.Record_Type_Name__c == 'Scientific Projects' || objFR.Record_Type_Name__c == 'Fellowships' || objFR.Record_Type_Name__c == 'HC Char' || objFR.Record_Type_Name__c == 'Philanthropic' ) &&  processItemTmp.ActorId == objFR.Business_Approver__c ){
	        		userId=processItemTmp.ActorId;
	        		recordEditable=true;
	        	}else{
	        		//get user from ProcessInstance - current approver - should have read rights 
	        		
	        		userId=processItemTmp.ActorId;
	        	}
	        	
	        	Boolean checkIfSharingExistForUser=false;
	        	gFRS_Funding_Request__Share recordSharingItem=null;
	        	for(gFRS_Funding_Request__Share recordSharing : objFR.Shares){
	        		if(recordSharing.UserOrGroupId == userId){
	        			checkIfSharingExistForUser=true;
	        			recordSharingItem=recordSharing;
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
	        			createManualSharingForFunding(userId,objFR.id,'Edit',listOfFundingShares);
	        		}else{
	        			createManualSharingForFunding(userId,objFR.id,'Read',listOfFundingShares);
	        		}
	        			
	        	}
	        	
	        }
	    	
			
			
			SavePoint sp = Database.setSavePoint();
			
			try{
				if(listOfFundingShares.Size()>0){
					Database.upsertResult[] srUpsertList = Database.upsert(listOfFundingShares,false);
					//upsert listOfFundingShares;
					for(Database.upsertResult upsResult:srUpsertList){
						if (!upsResult.isSuccess()) {
				            for(Database.Error err : upsResult.getErrors()) {
				                System.debug('The following error: Exception has occurred.');                    
				                System.debug(err.getStatusCode() + ': ' + err.getMessage());
				                System.debug('Sharing affected this error: ' + err.getFields());
				            }
				        }
					}
				} 
				
			}catch(System.DmlException dmlex)
	        {
	            system.debug('DML insert manual sharing exception'); 
	            for (Integer j = 0; j < dmlex.getNumDml(); j++)
	            {    
	                System.debug(dmlex.getDmlMessage(j)); 
	            }
	            
	            Database.rollback(sp);
	            return;
	        } 
	    }
	    global void finish(Database.BatchableContext BC){
        
    	}
    	
		
		/**
	    * @author GFRS Dev Team
	    * @date 19/11/2013
	    * @description pirvate method for set read manual sharing record for delegate user on funding request record.  
	    */
	    public void createManualSharingForFunding(Id userId, Id fundingId,String AccessLevel,List<gFRS_Funding_Request__Share> listOfFundingShares)
	    {
			gFRS_Funding_Request__Share requestShr = new gFRS_Funding_Request__Share();
			requestShr.ParentId                    = fundingId;
			requestShr.UserOrGroupId               = userId;
			requestShr.AccessLevel                 = AccessLevel;
			requestShr.RowCause                    = Schema.gFRS_Funding_Request__Share.RowCause.Manual;
	        
	        listOfFundingShares.add(requestShr);
	    }
}