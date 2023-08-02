global without sharing class gFRS_LOAUserPermissionBatchable implements Database.Batchable<sObject>{
	global Database.Querylocator start(Database.BatchableContext BC){     
	        String query = 'select id,Authorized_Signer__c,Signing_Authority_Email__c from gfrs_funding_request__c where Sub_Status__c=\'Approved-Awaiting LOA\' and LOA_Signed__c!=\'Yes\'';  
	        return Database.getQueryLocator(query);
	    }
	    
	    global void execute(Database.BatchableContext BC, List<sObject> scope){
			List<GFRS_Funding_Request__c> fundingRequestItems    = new List<GFRS_Funding_Request__c>();
			List<GFRS_Funding_Request__c> fundingRequestToUpdate = new List<GFRS_Funding_Request__c>();
			Map<String,ID> fundingAuthUserEmailMap               = new Map<String,ID>();
			List<Id> fundinfRequestIDs                           = new List<ID>();
			Integer i                                            = 0;
	    	for(Sobject item:scope){
	    		GFRS_Funding_Request__c tmpItem = (GFRS_Funding_Request__c)item;

	    		fundingRequestItems.add((GFRS_Funding_Request__c)item);
	    		fundinfRequestIDs.add(tmpItem.id);

	    		if(tmpItem.Signing_Authority_Email__c != null && !fundingAuthUserEmailMap.containsKey(tmpItem.Signing_Authority_Email__c)){
	    			fundingAuthUserEmailMap.put(tmpItem.Signing_Authority_Email__c,tmpItem.id);
	    		}	
	    		i++;
	    	}
	    	Map<String,List<ID>> userMap=new Map<String,List<ID>>();
	    	for(User userItem:[select id,email from user where email in: fundingAuthUserEmailMap.keySet()]){
	    		if(!userMap.containsKey(userItem.email)){
	    			userMap.put(userItem.email,new ID []{userItem.id});
	    		}else{
	    			List<ID> tmpListOfPotentialAuthorizedSigners = userMap.get(userItem.email);
	    			userMap.remove(userItem.email);
	    			tmpListOfPotentialAuthorizedSigners.add(userItem.id);
	    			userMap.put(userItem.email,tmpListOfPotentialAuthorizedSigners);
	    		}
	    	}
			List<GFRS_Funding_Request__Share> shareItems = [select ParentId,UserOrGroupId from GFRS_Funding_Request__Share  where RowCause ='Manual' and AccessLevel='Edit' and ParentId in: fundinfRequestIDs];

			Map<id,list<id>> userGroupRequests = new Map<id,list<id>>();
			
			for(GFRS_Funding_Request__Share item:shareItems){
				if(userGroupRequests.containsKey(item.UserOrGroupId)){
				
					if(!checkIfListContainsId(userGroupRequests.get(item.UserOrGroupId),item.ParentId)){
						userGroupRequests.get(item.UserOrGroupId).add(item.ParentId);
					}
				}else{
					userGroupRequests.put(item.UserOrGroupId,new id [] {item.ParentId});
				}
			}
			
			List<gFRS_Funding_Request__Share> requestShrs  = new List<gFRS_Funding_Request__Share>();
			
			for(GFRS_Funding_Request__c item : fundingRequestItems){
				if(item.Authorized_Signer__c == null && userMap.containsKey(item.Signing_Authority_Email__c)){

					Boolean checkIfAurhorizedSignerWasSet = false;

					for(Id userId:userMap.get(item.Signing_Authority_Email__c)){

						item.Authorized_Signer__c = userId;

						if(!checkIfAurhorizedSignerWasSet){
							checkIfAurhorizedSignerWasSet=true;
							fundingRequestToUpdate.add(item);
						}	
						
						if(!checkIfUserHaveSharing(item.Authorized_Signer__c,item.id,userGroupRequests)){

							gFRS_Funding_Request__Share requestShr = new gFRS_Funding_Request__Share();
							requestShr.ParentId                    = item.id;
							requestShr.UserOrGroupId               = item.Authorized_Signer__c;
							requestShr.AccessLevel                 = 'Edit';
							requestShr.RowCause                    = Schema.gFRS_Funding_Request__Share.RowCause.Manual;

					        requestShrs.add(requestShr);
					        if(userGroupRequests.containsKey(item.Authorized_Signer__c)){
					        	userGroupRequests.get(item.Authorized_Signer__c).add(item.id);
					        }else{
					        	userGroupRequests.put(item.Authorized_Signer__c,new id [] {item.id});
					        }
						}
					}
					
				}
				else if(!checkIfUserHaveSharing(item.Authorized_Signer__c,item.id,userGroupRequests)){

					gFRS_Funding_Request__Share requestShr = new gFRS_Funding_Request__Share();
					requestShr.ParentId                    = item.id;
					requestShr.UserOrGroupId               = item.Authorized_Signer__c;
					requestShr.AccessLevel                 = 'Edit';
					requestShr.RowCause                    = Schema.gFRS_Funding_Request__Share.RowCause.Manual;
			        requestShrs.add(requestShr);

			        if(userGroupRequests.containsKey(item.Authorized_Signer__c)){
			        	userGroupRequests.get(item.Authorized_Signer__c).add(item.id);
			        }else{
			        	userGroupRequests.put(item.Authorized_Signer__c,new id [] {item.id});
			        }
				}
				
			}
			
			
			String outMessage                                    ='';
			Map<ID,GFRS_Funding_Request__c> requestWithErrorsMap =new Map<ID,GFRS_Funding_Request__c>(fundingRequestToUpdate);

			if(fundingRequestToUpdate.size()>0){
				Database.SaveResult [] fundingUpdateResult =Database.update(fundingRequestToUpdate,false);
				for(Database.SaveResult sr : fundingUpdateResult){
		                //system.debug(sr.isSuccess());
		                if(!sr.isSuccess()){
		                	system.debug(sr.getErrors().size());
		                    for(Database.Error err:sr.getErrors()){
			                    system.debug(err.getMessage());
			                    outMessage=outMessage+err.getMessage()+'<//br>';
		                    }
		                    
		                    
		                }else if(sr.isSuccess()){
				        	if(sr.getId()!= null){
				        		requestWithErrorsMap.remove(sr.getId());
				        	}
			        	}
		    	}
		    	if(requestWithErrorsMap.values().size()>0){
				  	 outMessage =outMessage+'<//br> <b>Above errors occurs for following funding requests Ids<\b>';
				  	 for(GFRS_Funding_Request__c requestErrorItem:requestWithErrorsMap.values()){
				  	 	outMessage =outMessage+'<//br>'+requestErrorItem.id+',';
				  	 }
			  	}
					
			}
			
			Database.SaveResult[] lsr = Database.insert(requestShrs,false);
			
			for(Database.SaveResult sr : lsr){
			            
		                //system.debug(sr.isSuccess());
		                if(!sr.isSuccess()){
		                	system.debug(sr.getErrors().size());
		                    for(Database.Error err:sr.getErrors()){
			                    system.debug(err.getMessage());
		                    }
		                    
		                }
		    }
		    
		    if(outMessage != ''){
			    try{
						String orgName                    = UserInfo.getUserName().substringAfterLast('.')+'( '+Userinfo.getOrganizationId()+' )';	        			
						String subject                    = 'Problems occurse while setting Authorized Signer under job '+orgName +' sanbox';
						Id senderId                       = [select id, Address from OrgWideEmailAddress where Address='fundingrequestsystem-donotreply-d@gene.com' limit 1][0].id;
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
	        			system.debug('Exception occurs while sending email notification');
	        			system.debug(err.getMessage());
	        		}
			    }
				
			
	    }
	    global void finish(Database.BatchableContext BC){
        
    	}
    	
    	public Boolean checkIfListContainsId(List<id> listOfIds,id itemId ){
			for(id iter:listOfIds){
			   if(iter==itemId){
			   		return true;
			   }
			}
			return false;
		}
		
		public Boolean checkIfUserHaveSharing(id userId,id objectItemId,Map<id,list<id>> userGroupRequests){
			for(id itemUser:userGroupRequests.keySet()){
				for(id itemFR:userGroupRequests.get(itemUser)){
					if(userId==itemUser && objectItemId== itemFR){
						return true;
					}	
				}
			}
			return false;
		}

}