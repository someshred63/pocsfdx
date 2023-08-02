/************************************************************
*  @author: Lukasz Bieniawski
*  Date: 2015-01-13	
*  Description: Class being used to manage deleted records
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/

public with sharing class GNE_SFA2_Deleted_Records_Util {
	
	public static void onBeforeDelete(List<SObject> triggerOld, Schema.SObjectType objectType){		
		cacheOTRDeletedRecordsDetails(triggerOld, objectType);
	}
		
	public static void onAfterDelete(List<SObject> triggerOld, Schema.SObjectType objectType){		
		createOTRDeletedRecords(triggerOld, objectType);
	}
	
	private static Map<Schema.SObjectType, String> objectTypeToOtrObjectNameMap;
	private static Map<String, Map<Id, SObject>> objectDetailsOtrCache;
	
	public static String getOtrObjectNameForObjectType(Schema.SObjectType objectType){
		if (objectTypeToOtrObjectNameMap == null || objectTypeToOtrObjectNameMap.size() == 0){
			objectTypeToOtrObjectNameMap = new Map<Schema.SObjectType, String>{
				Account.getSObjectType() => 'GneAccount',
				Address_vod__c.getSObjectType() => 'GneAddress',
				Affiliation_vod__c.getSObjectType() => 'GneAffiliatedObject',
				Call2_Detail_vod__c.getSObjectType() => 'GneInteractionDetail',
				Call2_Discussion_vod__c.getSObjectType() => 'GneInteractionDiscussion',
				Call2_Key_Message_vod__c.getSObjectType() => 'GneInteractionKeyMessage',
				Call2_Sample_vod__c.getSObjectType() => 'GneInteractionSample',
				Change_Request_gne__c.getSObjectType() => 'GneDataChangeRequest',
				Distributor_fpm_gne__c.getSObjectType() => 'GneDistributorInfo',
				Event_Attendee_vod__c.getSObjectType() => 'GneMedicalEventParticipation',
				HIN_Number_fpm_gne__c.getSObjectType() => 'GneHinNumber',
				Call2_vod__c.getSObjectType() => 'GneInteraction',
				Medical_Communication_gne__c.getSObjectType() => 'GneMedComm',
				Call_PFG_Detail_gne__c.getSObjectType() => 'GneInteractionDetailPFG',
				SFA2_PFG_Product_Limit_gne__c.getSObjectType() => 'GnePFGProduct',
				Speaker_Bureau_Membership_gne__c.getSObjectType() => 'GneSpeakerBureau',
				Targets_and_Tiers_can_gne__c.getSObjectType() => 'GneTargetTier',
				TSF_vod__c.getSObjectType() => 'GneAccountTerritory',
				ProfileID_License_gne__c.getSObjectType() => 'GneUSLicense',
				Prescriber_License_gne__c.getSObjectType() => 'GneLicense',
				SFA2_Account_Society_Membership_gne__c.getSObjectType() => 'GneAccountSocietyLeadership',
				SFA2_PREP_Account_Testing_Info_gne__c.getSObjectType() => 'GnePrepTestingInfo',
				MCE_gne__c.getSObjectType() => 'GneMCE',
				FRM_HCO_Mapping_gne__c.getSObjectType() => 'GneAccountMapping',
        		Call2_Interaction_Detail_vod__c.getSObjectType() => 'GneInteractionVisitReasonDetail',			
        		Call2_Category_vod__c.getSObjectType() => 'GneInteractionCategory',
                Call2_Threat_vod__c.getSObjectType() => 'GneInteractionCompetitiveThreat',
				TDDD_License_gne__c.getSObjectType() => 'GneTDDDLicense'
			};			
		}
		return objectTypeToOtrObjectNameMap.get(objectType);
	}
	
	public static Map<Id, SObject> getobjectDetailsFromOtrCache(String otrObjectName){
		Map<Id, SObject> result = new Map<Id, SObject>();
		if (objectDetailsOtrCache != null && objectDetailsOtrCache.containsKey(otrObjectName)){
			result = objectDetailsOtrCache.get(otrObjectName);
		}
		return result;
	}
	
	private static void clearOtrObjectDetailsCache(String otrObjectName){
		if (objectDetailsOtrCache != null && objectDetailsOtrCache.containsKey(otrObjectName)){
			objectDetailsOtrCache.remove(otrObjectName);
		}
	}
		
    private static void cacheOTRDeletedRecordsDetails(List<SObject> triggerOld, Schema.SObjectType objectType){
        String otrObjectName = getOtrObjectNameForObjectType(objectType);
        if (String.isBlank(otrObjectName)){
            return;
        }
        if (objectDetailsOtrCache == null){
            objectDetailsOtrCache = new Map<String, Map<Id, SObject>>();
        }
        if (objectType == Call2_vod__c.getSObjectType()){
            String callSamplesOtrObjName = getOtrObjectNameForObjectType(Call2_Sample_vod__c.getSObjectType());			
            objectDetailsOtrCache.put(callSamplesOtrObjName, new Map<Id, Call2_Sample_vod__c>());
            for (Call2_vod__c sObjectRow : [
                SELECT Id,(SELECT Id, Account_vod__c FROM Call2_Sample_vod__r)
                FROM Call2_vod__c WHERE Id IN :triggerOld
            ]){				
                objectDetailsOtrCache.get(callSamplesOtrObjName).putAll(sObjectRow.Call2_Sample_vod__r);
            }
        } else if (objectType == Call2_Detail_vod__c.getSObjectType()){
            objectDetailsOtrCache.put(otrObjectName, new Map<Id, Call2_Detail_vod__c>(
                [SELECT id, Call2_vod__r.Account_vod__c FROM Call2_Detail_vod__c WHERE id IN :triggerOld])
                                     );
        } else if (objectType == Call2_Discussion_vod__c.getSObjectType()){
            objectDetailsOtrCache.put(otrObjectName, new Map<Id, Call2_Discussion_vod__c>(
                [SELECT id, Call2_vod__r.Account_vod__c FROM Call2_Discussion_vod__c WHERE id IN :triggerOld])
                                     );
        } else if (objectType == SFA2_PFG_Product_Limit_gne__c.getSObjectType()){
            objectDetailsOtrCache.put(otrObjectName, new Map<Id, SFA2_PFG_Product_Limit_gne__c>(
                [SELECT id, Product_gne__r.Manufacturer_gne__c FROM SFA2_PFG_Product_Limit_gne__c WHERE id IN :triggerOld])
                                     );
        } else if (objectType == Call2_Interaction_Detail_vod__c.getSObjectType()){
            objectDetailsOtrCache.put(otrObjectName, new Map<Id, Call2_Interaction_Detail_vod__c>(
                [SELECT id, Call2_vod__r.Account_vod__c FROM Call2_Interaction_Detail_vod__c WHERE id IN :triggerOld])
                                     );
        } else if (objectType == Call2_Category_vod__c.getSObjectType()){
            objectDetailsOtrCache.put(otrObjectName, new Map<Id, Call2_Category_vod__c>(
                [SELECT id, Call2_vod__r.Account_vod__c FROM Call2_Category_vod__c WHERE id IN :triggerOld])
                                     );
        } else if (objectType == Call2_Threat_vod__c.getSObjectType()) {
            objectDetailsOtrCache.put(otrObjectName, new Map<Id,Call2_Threat_vod__c>(
                [SELECT Id, Call2_vod__r.Account_vod__c FROM Call2_Threat_vod__c WHERE Id IN :triggerOld]
            ));
		}
    }
	
	private static void createOTRDeletedRecords(List<SObject> deletedRecords, Schema.SObjectType objectType){
		String otrObjectName = getOtrObjectNameForObjectType(objectType);
		if(deletedRecords == null || deletedRecords.isEmpty() || objectType == null || String.isBlank(otrObjectName)){
			return;
        }        
        List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
        
        if (objectType == Account.getSObjectType()){
        	deletedRecordsList = getDeletedAccounts(deletedRecords, otrObjectName);        	
        } else if (objectType == Address_vod__c.getSObjectType()){
        	deletedRecordsList = getDeletedAddresses(deletedRecords, otrObjectName);        	
        } else if (objectType == Affiliation_vod__c.getSObjectType()){
        	deletedRecordsList = getDeletedAffiliations(deletedRecords, otrObjectName);
        } else if (objectType == Call2_Detail_vod__c.getSObjectType()){
        	deletedRecordsList = getDeletedCallDetails(deletedRecords, otrObjectName);
        } else if (objectType == Call2_Discussion_vod__c.getSObjectType()){
        	deletedRecordsList = getDeletedCallDiscussions(deletedRecords, otrObjectName);
        } else if (objectType == Call2_Key_Message_vod__c.getSObjectType()){
        	deletedRecordsList = getDeletedCallKeyMessages(deletedRecords, otrObjectName);
        } else if (objectType == Call2_Sample_vod__c.getSObjectType()){
        	deletedRecordsList = getDeletedCallSamples(deletedRecords, otrObjectName);
        } else if (objectType == Change_Request_gne__c.getSObjectType()){
        	deletedRecordsList = getDeletedDataChangeRequests(deletedRecords, otrObjectName);
        } else if (objectType == Distributor_fpm_gne__c.getSObjectType()){
        	deletedRecordsList = getDeletedFPMDistributors(deletedRecords, otrObjectName);
        } else if (objectType == Event_Attendee_vod__c.getSObjectType()){
        	deletedRecordsList = getDeletedEventAttendies(deletedRecords, otrObjectName);
        } else if (objectType == HIN_Number_fpm_gne__c.getSObjectType()){
        	deletedRecordsList = getDeletedFPMHinNumbers(deletedRecords, otrObjectName);
        } else if (objectType == Call2_vod__c.getSObjectType()){
        	deletedRecordsList = getDeletedInteractions(deletedRecords, otrObjectName);
        } else if (objectType == Medical_Communication_gne__c.getSObjectType()){
        	deletedRecordsList = getDeletedMedicalCommunications(deletedRecords, otrObjectName);
        } else if (objectType == Call_PFG_Detail_gne__c.getSObjectType()){
        	deletedRecordsList = getDeletedCallPfgDetails(deletedRecords, otrObjectName);
        } else if (objectType == SFA2_PFG_Product_Limit_gne__c.getSObjectType()){
        	deletedRecordsList = getDeletedCallPfgProductLimits(deletedRecords, otrObjectName);
        } else if (objectType == Speaker_Bureau_Membership_gne__c.getSObjectType()){
        	deletedRecordsList = getDeletedSpeakerBureausMemberships(deletedRecords, otrObjectName);
        } else if (objectType == Targets_and_Tiers_can_gne__c.getSObjectType()){
        	deletedRecordsList = getDeletedTargetAndTiers(deletedRecords, otrObjectName);
        } else if (objectType == TSF_vod__c.getSObjectType()){
        	deletedRecordsList = getDeletedTsfs(deletedRecords, otrObjectName);
        } else if (objectType == ProfileID_License_gne__c.getSObjectType()){
        	deletedRecordsList = getDeletedProfileIdLicenses(deletedRecords, otrObjectName);
        } else if (objectType == SFA2_Account_Society_Membership_gne__c.getSObjectType()){
        	deletedRecordsList = getDeletedAccountSocietiesMemberships(deletedRecords, otrObjectName);
        } else if (objectType == SFA2_PREP_Account_Testing_Info_gne__c.getSObjectType()){
        	deletedRecordsList = getDeletedPrepAccountTestingInfos(deletedRecords, otrObjectName);
        } else if (objectType == MCE_gne__c.getSObjectType()){
          deletedRecordsList = getDeletedMCEs(deletedRecords, otrObjectName);
        } else if (objectType == FRM_HCO_Mapping_gne__c.getSObjectType()){
          deletedRecordsList = getDeletedMappings(deletedRecords, otrObjectName);
        } else if (objectType == Prescriber_License_gne__c.getSObjectType()){
          deletedRecordsList = getDeletedLicenses(deletedRecords, otrObjectName);
        } else if (objectType == Call2_Interaction_Detail_vod__c.getSObjectType()){
          deletedRecordsList = getDeletedCallInteractionDetails(deletedRecords, otrObjectName);
        } else if (objectType == Call2_Category_vod__c.getSObjectType()){
          deletedRecordsList = getDeletedCallCategories(deletedRecords, otrObjectName);
        } else if (objectType == Call2_Threat_vod__c.getSObjectType()){
          deletedRecordsList = getDeletedCallThreats(deletedRecords, otrObjectName);
        } else if (objectType == TDDD_License_gne__c.getSObjectType()){
			deletedRecordsList = getDeletedTdddLicenses(deletedRecords, otrObjectName);
		}
        
        if (!deletedRecordsList.isEmpty()){
        	insert deletedRecordsList;
        }
    }
    
    private static List<OTR_Deleted_Record_gne__c> getDeletedAccounts(List<SObject> deletedRecords, String otrObjectName){
    	List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
    	for (Account sObjRecord : (List<Account>)deletedRecords){
       		deletedRecordsList.add(
       			new OTR_Deleted_Record_gne__c(
       				Object_name__c = otrObjectName,
       				Deleted_Record_Id__c = sobjRecord.Id,
   					Parent_Account_Id_gne__c = sobjRecord.Id
        		) 
        	);
        }
        return deletedRecordsList;
    }
    
    private static List<OTR_Deleted_Record_gne__c> getDeletedAddresses(List<SObject> deletedRecords, String otrObjectName){
    	List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
    	for (Address_vod__c sObjRecord : (List<Address_vod__c>)deletedRecords){
        	deletedRecordsList.add(
        		new OTR_Deleted_Record_gne__c(
        			Object_name__c = otrObjectName,
        			Deleted_Record_Id__c = sobjRecord.Id,
   					Parent_Account_Id_gne__c = sobjRecord.Account_vod__c
        		) 
        	);
        }
        return deletedRecordsList;
    }
    
    private static List<OTR_Deleted_Record_gne__c> getDeletedAffiliations(List<SObject> deletedRecords, String otrObjectName){
    	List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
    	for (Affiliation_vod__c sObjRecord : (List<Affiliation_vod__c>)deletedRecords){
       		deletedRecordsList.add(
       			new OTR_Deleted_Record_gne__c(
       				Object_name__c = otrObjectName,
       				Deleted_Record_Id__c = sobjRecord.Id,
   					Parent_Account_Id_gne__c = sobjRecord.From_Account_vod__c
       			)        			 
       		);        		
       	}
        return deletedRecordsList;
    }
    
    private static List<OTR_Deleted_Record_gne__c> getDeletedCallDetails(List<SObject> deletedRecords, String otrObjectName){
    	List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
    	Map<Id, SObject> callDetailsWithParentCall = getobjectDetailsFromOtrCache(otrObjectName);
    	if (callDetailsWithParentCall.isEmpty()){
    		return deletedRecordsList;
    	}
        for (Call2_Detail_vod__c sObjRecord : (List<Call2_Detail_vod__c>)deletedRecords){
        	Call2_Detail_vod__c callWithParent = (Call2_Detail_vod__c)callDetailsWithParentCall.get(sObjRecord.id);
        	if(callWithParent.Call2_vod__r.Account_vod__c == null) {
        		continue;
        	}	        
          	deletedRecordsList.add(
          		new OTR_Deleted_Record_gne__c(
           			Object_name__c = otrObjectName,
           			Deleted_Record_Id__c = callWithParent.Id,
           			Parent_Account_Id_gne__c = callWithParent.Call2_vod__r.Account_vod__c
           		)
           	);
	    }
	    clearOtrObjectDetailsCache(otrObjectName);
	    return deletedRecordsList;
    }

    private static List<OTR_Deleted_Record_gne__c> getDeletedCallInteractionDetails(List<SObject> deletedRecords, String otrObjectName){
      List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
      Map<Id, SObject> callDetailsWithParentCall = getobjectDetailsFromOtrCache(otrObjectName);
      if (callDetailsWithParentCall.isEmpty()){
        return deletedRecordsList;
      }
        for (Call2_Interaction_Detail_vod__c sObjRecord : (List<Call2_Interaction_Detail_vod__c>)deletedRecords){
          Call2_Interaction_Detail_vod__c callWithParent = (Call2_Interaction_Detail_vod__c)callDetailsWithParentCall.get(sObjRecord.id);
          if(callWithParent.Call2_vod__r.Account_vod__c == null) {
            continue;
          }         
            deletedRecordsList.add(
              new OTR_Deleted_Record_gne__c(
                Object_name__c = otrObjectName,
                Deleted_Record_Id__c = callWithParent.Id,
                Parent_Account_Id_gne__c = callWithParent.Call2_vod__r.Account_vod__c
              )
            );
      }
      clearOtrObjectDetailsCache(otrObjectName);
      return deletedRecordsList;
    }

    private static List<OTR_Deleted_Record_gne__c> getDeletedCallCategories(List<SObject> deletedRecords, String otrObjectName){
      List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
      Map<Id, SObject> callDetailsWithParentCall = getobjectDetailsFromOtrCache(otrObjectName);
      if (callDetailsWithParentCall.isEmpty()){
        return deletedRecordsList;
      }
        for (Call2_Category_vod__c sObjRecord : (List<Call2_Category_vod__c>)deletedRecords){
          Call2_Category_vod__c callWithParent = (Call2_Category_vod__c)callDetailsWithParentCall.get(sObjRecord.id);
          if(callWithParent.Call2_vod__r.Account_vod__c == null) {
            continue;
          }         
            deletedRecordsList.add(
              new OTR_Deleted_Record_gne__c(
                Object_name__c = otrObjectName,
                Deleted_Record_Id__c = callWithParent.Id,
                Parent_Account_Id_gne__c = callWithParent.Call2_vod__r.Account_vod__c
              )
            );
      }
      clearOtrObjectDetailsCache(otrObjectName);
      return deletedRecordsList;
    }
    
    private static List<OTR_Deleted_Record_gne__c> getDeletedCallThreats(List<SObject> deletedRecords, String otrObjectName) {
        List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
        Map<Id, SObject> callDetailsWithParentCall = getobjectDetailsFromOtrCache(otrObjectName);
        if (callDetailsWithParentCall.isEmpty()){
            return deletedRecordsList;
        }
        for (Call2_Threat_vod__c sObjRecord : (List<Call2_Threat_vod__c>)deletedRecords){
            Call2_Threat_vod__c callWithParent = (Call2_Threat_vod__c)callDetailsWithParentCall.get(sObjRecord.id);
            if(callWithParent.Call2_vod__r.Account_vod__c == null) {
                continue;
            }         
            deletedRecordsList.add(
                new OTR_Deleted_Record_gne__c(
                    Object_name__c = otrObjectName,
                    Deleted_Record_Id__c = callWithParent.Id,
                    Parent_Account_Id_gne__c = callWithParent.Call2_vod__r.Account_vod__c
                )
            );
        }
        clearOtrObjectDetailsCache(otrObjectName);
        return deletedRecordsList;
    }
    
    private static List<OTR_Deleted_Record_gne__c> getDeletedCallDiscussions(List<SObject> deletedRecords, String otrObjectName){
    	List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
    	Map<Id, SObject> callDiscussionsWithParentCall = getobjectDetailsFromOtrCache(otrObjectName);
    	if (callDiscussionsWithParentCall.isEmpty()){
    		return deletedRecordsList;
    	}    	
		for(Call2_Discussion_vod__c sObjRecord : (List<Call2_Discussion_vod__c>)deletedRecords){
			Call2_Discussion_vod__c callWithParent = (Call2_Discussion_vod__c)callDiscussionsWithParentCall.get(sObjRecord.id);
        	if(callWithParent.Call2_vod__r.Account_vod__c == null) {
        		continue;
        	}			
			deletedRecordsList.add(
				new OTR_Deleted_Record_gne__c(
					Object_name__c = otrObjectName, 
					Deleted_Record_Id__c = sObjRecord.Id,					
					Parent_Account_Id_gne__c = callWithParent.Call2_vod__r.Account_vod__c
				)
			);
		}
		clearOtrObjectDetailsCache(otrObjectName);
        return deletedRecordsList;
    }
    
    private static List<OTR_Deleted_Record_gne__c> getDeletedCallKeyMessages(List<SObject> deletedRecords, String otrObjectName){
    	List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
    	for (Call2_Key_Message_vod__c sObjRecord : (List<Call2_Key_Message_vod__c>)deletedRecords){
       		deletedRecordsList.add(
       			new OTR_Deleted_Record_gne__c(
       				Object_name__c = otrObjectName,
       				Deleted_Record_Id__c = sobjRecord.Id,
   					Parent_Account_Id_gne__c = sobjRecord.Account_vod__c
       			)       			
       		);        		
       	}
        return deletedRecordsList;
    }
    
    private static List<OTR_Deleted_Record_gne__c> getDeletedCallSamples(List<SObject> deletedRecords, String otrObjectName){
    	List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
    	for (Call2_Sample_vod__c sObjRecord : (List<Call2_Sample_vod__c>)deletedRecords){
       		deletedRecordsList.add(
       			new OTR_Deleted_Record_gne__c(
       				Object_name__c = otrObjectName,
       				Deleted_Record_Id__c = sobjRecord.Id,
   					Parent_Account_Id_gne__c = sobjRecord.Account_vod__c
       			)       			
       		);        		
       	}
        return deletedRecordsList;
    }
    
    private static List<OTR_Deleted_Record_gne__c> getDeletedDataChangeRequests(List<SObject> deletedRecords, String otrObjectName){
    	List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
    	for (Change_Request_gne__c sObjRecord : (List<Change_Request_gne__c>)deletedRecords){
       		deletedRecordsList.add(
       			new OTR_Deleted_Record_gne__c(
       				Object_name__c = otrObjectName,
       				Deleted_Record_Id__c = sobjRecord.Id,
   					Parent_Account_Id_gne__c = sobjRecord.Account_gne__c
       			)       			
       		);        		
       	}
        return deletedRecordsList;
    }
    
    private static List<OTR_Deleted_Record_gne__c> getDeletedFPMDistributors(List<SObject> deletedRecords, String otrObjectName){
    	List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
    	for (Distributor_fpm_gne__c sObjRecord : (List<Distributor_fpm_gne__c>)deletedRecords){
       		deletedRecordsList.add(
       			new OTR_Deleted_Record_gne__c(
       				Object_name__c = otrObjectName,
       				Deleted_Record_Id__c = sobjRecord.Id,
   					Parent_Account_Id_gne__c = sobjRecord.Account_ref_gne__c
       			)       			
       		);        		
       	}
        return deletedRecordsList;
    }
    
    private static List<OTR_Deleted_Record_gne__c> getDeletedEventAttendies(List<SObject> deletedRecords, String otrObjectName){
    	List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
    	for (Event_Attendee_vod__c sObjRecord : (List<Event_Attendee_vod__c>)deletedRecords){
       		deletedRecordsList.add(
       			new OTR_Deleted_Record_gne__c(
       				Object_name__c = otrObjectName,
       				Deleted_Record_Id__c = sobjRecord.Id,
   					Parent_Account_Id_gne__c = sobjRecord.Account_vod__c
       			)       			
       		);        		
       	}
        return deletedRecordsList;
    }
    
    private static List<OTR_Deleted_Record_gne__c> getDeletedFPMHinNumbers(List<SObject> deletedRecords, String otrObjectName){
    	List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
    	for (HIN_Number_fpm_gne__c sObjRecord : (List<HIN_Number_fpm_gne__c>)deletedRecords){
       		deletedRecordsList.add(
       			new OTR_Deleted_Record_gne__c(
       				Object_name__c = otrObjectName,
       				Deleted_Record_Id__c = sobjRecord.Id,
   					Parent_Account_Id_gne__c = sobjRecord.Account_ref_gne__c
       			)       			
       		);        		
       	}
        return deletedRecordsList;
    }
    
    private static List<OTR_Deleted_Record_gne__c> getDeletedInteractions(List<SObject> deletedRecords, String otrObjectName){
    	List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();    	
    	for (Call2_vod__c sObjRecord : (List<Call2_vod__c>)deletedRecords){
    		if(sObjRecord.Parent_Call_vod__c!=null){
    			otrObjectName = 'GneInteractionAttendee';
    		}
       		deletedRecordsList.add(
       			new OTR_Deleted_Record_gne__c(
       				Object_name__c = otrObjectName,
       				Deleted_Record_Id__c = sobjRecord.Id,
   					Parent_Account_Id_gne__c = sobjRecord.Account_vod__c
       			)
       		);       		
       	}
       	String otrChildObjectName = getOtrObjectNameForObjectType(Call2_Sample_vod__c.sObjectType);
       	Map<Id, SObject> callSamplesWithParentCall = getobjectDetailsFromOtrCache(otrChildObjectName);
       	if (callSamplesWithParentCall.size() > 0){
       		deletedRecordsList.addAll(getDeletedCallSamples(callSamplesWithParentCall.values(), otrChildObjectName));
       	}
       	clearOtrObjectDetailsCache(otrChildObjectName);
        return deletedRecordsList;
    }
    
    private static List<OTR_Deleted_Record_gne__c> getDeletedMedicalCommunications(List<SObject> deletedRecords, String otrObjectName){
    	List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
    	for (Medical_Communication_gne__c sObjRecord : (List<Medical_Communication_gne__c>)deletedRecords){
    		deletedRecordsList.add(
       			new OTR_Deleted_Record_gne__c(
       				Object_name__c = otrObjectName,
       				Deleted_Record_Id__c = sobjRecord.Id,
   					Parent_Account_Id_gne__c = sobjRecord.Account_gne__c
       			)       			
       		);
       	}
        return deletedRecordsList;
    }
    
    private static List<OTR_Deleted_Record_gne__c> getDeletedCallPfgDetails(List<SObject> deletedRecords, String otrObjectName){
    	List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
    	for (Call_PFG_Detail_gne__c sObjRecord : (List<Call_PFG_Detail_gne__c>)deletedRecords){
    		deletedRecordsList.add(
       			new OTR_Deleted_Record_gne__c(
       				Object_name__c = otrObjectName,
       				Deleted_Record_Id__c = sobjRecord.Id,
   					Parent_Account_Id_gne__c = sobjRecord.Account_gne__c
       			)       			
       		);        		
       	}
        return deletedRecordsList;
    }
    
    private static List<OTR_Deleted_Record_gne__c> getDeletedCallPfgProductLimits(List<SObject> deletedRecords, String otrObjectName){
    	List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
    	Map<Id, SObject> productLimitWithParentProductAccount = getobjectDetailsFromOtrCache(otrObjectName);
    	if (productLimitWithParentProductAccount.isEmpty()){
    		return deletedRecordsList;
    	}
    	for (SFA2_PFG_Product_Limit_gne__c sObjRecord : (List<SFA2_PFG_Product_Limit_gne__c>)deletedRecords){
    		SFA2_PFG_Product_Limit_gne__c obWithParentAccount = (SFA2_PFG_Product_Limit_gne__c)productLimitWithParentProductAccount.get(sObjRecord.Id);
    		if (obWithParentAccount.Product_gne__r.Manufacturer_gne__c == null){
    			continue;
    		}
    		deletedRecordsList.add(
       			new OTR_Deleted_Record_gne__c(
       				Object_name__c = otrObjectName,
       				Deleted_Record_Id__c = sobjRecord.Id,
   					Parent_Account_Id_gne__c = obWithParentAccount.Product_gne__r.Manufacturer_gne__c
       			)       			
       		);        		
       	}
       	clearOtrObjectDetailsCache(otrObjectName);
        return deletedRecordsList;
    }
    
    private static List<OTR_Deleted_Record_gne__c> getDeletedSpeakerBureausMemberships(List<SObject> deletedRecords, String otrObjectName){
    	List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
    	for (Speaker_Bureau_Membership_gne__c sObjRecord : (List<Speaker_Bureau_Membership_gne__c>)deletedRecords){
    		deletedRecordsList.add(
       			new OTR_Deleted_Record_gne__c(
       				Object_name__c = otrObjectName,
       				Deleted_Record_Id__c = sobjRecord.Id,
   					Parent_Account_Id_gne__c = sobjRecord.Bureau_Member_gne__c
       			)       			
       		);        		
       	}
        return deletedRecordsList;
    }
    
    private static List<OTR_Deleted_Record_gne__c> getDeletedTargetAndTiers(List<SObject> deletedRecords, String otrObjectName){
    	List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
    	for (Targets_and_Tiers_can_gne__c sObjRecord : (List<Targets_and_Tiers_can_gne__c>)deletedRecords){
    		deletedRecordsList.add(
       			new OTR_Deleted_Record_gne__c(
       				Object_name__c = otrObjectName,
       				Deleted_Record_Id__c = sobjRecord.Id,
   					Parent_Account_Id_gne__c = sobjRecord.Account_can_gne__c
       			)       			
       		);        		
       	}
        return deletedRecordsList;
    }
    
    private static List<OTR_Deleted_Record_gne__c> getDeletedTsfs(List<SObject> deletedRecords, String otrObjectName){
    	List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
    	for (TSF_vod__c sObjRecord : (List<TSF_vod__c>)deletedRecords){
    		deletedRecordsList.add(
       			new OTR_Deleted_Record_gne__c(
       				Object_name__c = otrObjectName,
       				Deleted_Record_Id__c = sobjRecord.Id,
   					Parent_Account_Id_gne__c = sobjRecord.Account_vod__c
       			)       			
       		);        		
       	}
        return deletedRecordsList;
    }
    
    private static List<OTR_Deleted_Record_gne__c> getDeletedProfileIdLicenses(List<SObject> deletedRecords, String otrObjectName){
    	List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
    	for (ProfileID_License_gne__c sObjRecord : (List<ProfileID_License_gne__c>)deletedRecords){
    		deletedRecordsList.add(
       			new OTR_Deleted_Record_gne__c(
       				Object_name__c = otrObjectName,
       				Deleted_Record_Id__c = sobjRecord.Id,
   					Parent_Account_Id_gne__c = sobjRecord.Account_Name_gne__c
       			)       			
       		);        		
       	}
        return deletedRecordsList;
    }
    
    private static List<OTR_Deleted_Record_gne__c> getDeletedLicenses(List<SObject> deletedRecords, String otrObjectName){
    	List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
    	for (Prescriber_License_gne__c sObjRecord : (List<Prescriber_License_gne__c>)deletedRecords){
    		deletedRecordsList.add(
       			new OTR_Deleted_Record_gne__c(
       				Object_name__c = otrObjectName,
       				Deleted_Record_Id__c = sobjRecord.Id,
   					Parent_Account_Id_gne__c = sobjRecord.Account_gne__c
       			)       			
       		);        		
       	}
        return deletedRecordsList;
    }

	private static List<OTR_Deleted_Record_gne__c> getDeletedTdddLicenses(List<SObject> deletedRecords, String otrObjectName){
		List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
		for (TDDD_License_gne__c sObjRecord : (List<TDDD_License_gne__c>)deletedRecords){
			deletedRecordsList.add(
					new OTR_Deleted_Record_gne__c(
							Object_name__c = otrObjectName,
							Deleted_Record_Id__c = sobjRecord.Id,
							Parent_Account_Id_gne__c = sobjRecord.Account_gne__c
					)
			);
		}
		return deletedRecordsList;
	}


    private static List<OTR_Deleted_Record_gne__c> getDeletedAccountSocietiesMemberships(List<SObject> deletedRecords, String otrObjectName){
    	List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
    	for (SFA2_Account_Society_Membership_gne__c sObjRecord : (List<SFA2_Account_Society_Membership_gne__c>)deletedRecords){
    		deletedRecordsList.add(
       			new OTR_Deleted_Record_gne__c(
       				Object_name__c = otrObjectName,
       				Deleted_Record_Id__c = sobjRecord.Id,
   					Parent_Account_Id_gne__c = sobjRecord.Account_gne__c
       			)       			
       		);        		
       	}
        return deletedRecordsList;
    }
    
    private static List<OTR_Deleted_Record_gne__c> getDeletedPrepAccountTestingInfos(List<SObject> deletedRecords, String otrObjectName){
    	List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
    	for (SFA2_PREP_Account_Testing_Info_gne__c sObjRecord : (List<SFA2_PREP_Account_Testing_Info_gne__c>)deletedRecords){
    		deletedRecordsList.add(
       			new OTR_Deleted_Record_gne__c(
       				Object_name__c = otrObjectName,
       				Deleted_Record_Id__c = sobjRecord.Id,
   					Parent_Account_Id_gne__c = sobjRecord.Account_gne__c
       			)       			
       		);        		
       	}
        return deletedRecordsList;
    }
    
    private static List<OTR_Deleted_Record_gne__c> getDeletedMCEs(List<SObject> deletedRecords, String otrObjectName) {
      List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
      for (MCE_gne__c sObjRecord : (List<MCE_gne__c>)deletedRecords){
        deletedRecordsList.add(
          new OTR_Deleted_Record_gne__c(
            Object_name__c = otrObjectName,
            Deleted_Record_Id__c = sobjRecord.Id,
            Parent_Account_Id_gne__c = sobjRecord.Account_gne__c
        ));            
      }
      
      return deletedRecordsList;
    }
    
    private static List<OTR_Deleted_Record_gne__c> getDeletedMappings(List<SObject> deletedRecords, String otrObjectName) {
      List<OTR_Deleted_Record_gne__c> deletedRecordsList = new List<OTR_Deleted_Record_gne__c>();
      for (FRM_HCO_Mapping_gne__c sObjRecord : (List<FRM_HCO_Mapping_gne__c>)deletedRecords){
        deletedRecordsList.add(
          new OTR_Deleted_Record_gne__c(
            Object_name__c = otrObjectName,
            Deleted_Record_Id__c = sobjRecord.Id,
            Parent_Account_Id_gne__c = sobjRecord.FRM_HCO_Account_gne__c
        ));            
      }
      
      return deletedRecordsList;
    }
    
}