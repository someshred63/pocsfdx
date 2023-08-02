/************************************************************
*  @author: Sreedhar Karukonda
*  Date: 12/13/2012
*  Description: This class GNE_SFA2_Interaction_Field_Updates handles field updates on Call2_vod__c object on DML operations
*  This class is being used in GNE_SFA2_Interaction_Trigger trigger
*
*  Modification History
*  Date         Name        Description
*  24.02.2014   hrycenkm    Refactoring code.
*************************************************************/

public without sharing class GNE_SFA2_Interaction_Field_Updates {

    public static void onBeforeInsert (List<Call2_vod__c> triggerNew) {
        if (!GNE_SFA2_Util.isMergeMode()) {
            completedInteraction(triggerNew);
            plannedInteraction(triggerNew);
            removeCompletedCheckbox(triggerNew);
            assignMedAffairsInteractionRecordType(triggerNew);
            //setInOfficeInteractionLocationforFRMprofiles(triggerNew);
            updatePrepStatus(null, triggerNew);
            setCreatorProfile(triggerNew);
            if(GNE_SFA2_Interaction_Util.PARENT_CALL_UPDATE_MODE != true) {
                updateCompletedDate(triggerNew);
                interactionProcessAfterInsertUpdate(null, triggerNew, true);
            }
            if(GNE_SFA2_Util.isCanadaRAMA()) {
                synchronizeInteractionTypeForRAMA(null, triggerNew);
            }
        }
    }

    public static void onBeforeUpdate (Map<Id, Call2_vod__c> triggerOldMap,  List<Call2_vod__c> triggerNew) {
        if (!GNE_SFA2_Util.isMergeMode()) {
            completedInteraction(triggerNew);
            removeCompletedCheckbox(triggerNew);
            assignMedAffairsInteractionRecordType(triggerNew);
            //setInOfficeInteractionLocationforFRMprofiles(triggerNew);
            updatePrepStatus(triggerOldMap, triggerNew);
            if(GNE_SFA2_Interaction_Util.PARENT_CALL_UPDATE_MODE != true) {
                updateCompletedDate(triggerNew);
                interactionProcessAfterInsertUpdate(triggerOldMap, triggerNew, false);
            }
            if(GNE_SFA2_Util.isCanadaRAMA()) {
                synchronizeInteractionTypeForRAMA(triggerOldMap, triggerNew);
            }
        }
    }

    private static void completedInteraction(List<Call2_vod__c> triggerNew) {
        for (Call2_vod__c call : triggerNew) {
            if (call.Completed_gne__c == true) {
                call.Interaction_Status_gne__c = 'Completed';
            }
        }
    }

    private static void plannedInteraction(List<Call2_vod__c> triggerNew) {
        for (Call2_vod__c call : triggerNew) {
            if (String.isEmpty(call.Interaction_Status_gne__c) && call.Completed_gne__c != true) {
                call.Interaction_Status_gne__c = 'Planned';
            }
        }
    }

    private static void removeCompletedCheckbox(List<Call2_vod__c> triggerNew) {
        for (Call2_vod__c call : triggerNew) {
            if (call.Completed_gne__c == false && call.Interaction_Status_gne__c == 'Completed') {
                call.Interaction_Status_gne__c = 'Planned';
            }
        }
    }

    private static void assignMedAffairsInteractionRecordType(List<Call2_vod__c> triggerNew) {
        Id medAffairRecordTypeId = null;
        Set<Id> medAffairRecordTypes = new Set<Id>();
        for(Schema.RecordTypeInfo r : Call2_vod__c.SObjectType.getDescribe().getRecordTypeInfos()){
            if(r.getName().toUpperCase().contains('MEDAFFAIRS')) {
            	medAffairRecordTypes.add(r.getRecordTypeId());
            }

            if(r.getName() == 'MedAffairs Interaction'){
                medAffairRecordTypeId = r.getRecordTypeId();
            }
        }
        for (Call2_vod__c call : triggerNew) {
            if (medAffairRecordTypes.contains(call.RecordTypeId) && call.Completed_gne__c == true) {
                if(String.isNotBlank(medAffairRecordTypeId)) {
                    call.RecordTypeId = medAffairRecordTypeId;
                } else {
                    call.addError('MedAffairs Interaction Record Type is not created for Call2_vod__c');
                }
            }
        }
    }

    /*private static void setInOfficeInteractionLocationforFRMprofiles(List<Call2_vod__c> triggerNew) {
        Set<String> frmProfilesSet = GNE_SFA2_FRM_Profiles_prefixes_gne__c.getAll().keySet();
        for (String profilePrefix : frmProfilesSet) {
            if (GNE_SFA2_Util.getCurrentUserProfileName().contains(profilePrefix)) {
                for (Call2_vod__c call : triggerNew) {
                    call.Interaction_Location_gne__c = 'Face to Face: In Office';
                }
            }
        }
    }*/

    private static void updateCompletedDate(List<Call2_vod__c> triggerNew) {
        for (Call2_vod__c call : triggerNew) {
            if (call.Completed_gne__c && call.Date_Completed_gne__c == null) {
                call.Date_Completed_gne__c = Date.today();
            } else if (!call.Completed_gne__c) {
                call.Date_Completed_gne__c = null;
            }
        }
    }

    private static void interactionProcessAfterInsertUpdate(Map<Id, Call2_vod__c> triggerOldMap, List<Call2_vod__c> triggerNew, Boolean isInsert) {
        Map <Id, Call2_vod__c> calls = null;
        for (Call2_vod__c call : triggerNew) {
        	if(call.Territory_vod__c == null || call.Territory_Id_gne__c == null){
				Territory2 callTerritory = GNE_SFA2_Interaction_Util.getInteractionTerritory();
				if(callTerritory != null){
					call.Territory_vod__c = callTerritory.Name;
					call.Territory_Id_gne__c = callTerritory.Id;
				}
			}

            if (!String.isEmpty(call.Attendee_Type_vod__c) && !String.isEmpty(call.Entity_Reference_Id_vod__c)) {
                if (call.Attendee_Type_vod__c == 'Person_Account_vod' || call.Attendee_Type_vod__c == 'Group_Account_vod') {
                    call.Account_vod__c = call.Entity_Reference_Id_vod__c;
                    call.Entity_Reference_Id_vod__c = null;
                } else if (call.Attendee_Type_vod__c == 'Contact_vod') {
                    call.Contact_vod__c = call.Entity_Reference_Id_vod__c;
                    call.Entity_Reference_Id_vod__c = null;
                } else if (call.Attendee_Type_vod__c == 'User_vod') {
                    call.User_vod__c = call.Entity_Reference_Id_vod__c;
                    call.Entity_Reference_Id_vod__c = null;
                } else if (call.Attendee_Type_vod__c == 'Event_vod') {
                    call.Medical_Event_vod__c = call.Entity_Reference_Id_vod__c;
                    call.Entity_Reference_Id_vod__c = null;
                }
            }

            if (call.Call_Datetime_vod__c != null) {
                call.Call_Date_vod__c = Date.newInstance(call.Call_Datetime_vod__c.year(), call.Call_Datetime_vod__c.month(), call.Call_Datetime_vod__c.day());
            } else if (call.Call_Datetime_vod__c == null && call.Call_Date_vod__c == null) {
                call.Call_Date_vod__c = System.today();
            }

            if (call.Status_vod__c == 'Submitted_vod' && call.Call_Date_vod__c > System.today())  {
                call.Status_vod__c.addError(System.Label.Submit_Future_Call_Not_Allowed_Label);
            }

            if (call.Unlock_vod__c == true) {
                GNE_SFA2_Interaction_Util.updateAction = true;
                call.Status_vod__c = 'Saved_vod';
                call.Unlock_vod__c = false;
                call.Submitted_By_Mobile_vod__c = false;
            }

            if (!isInsert) {
                if (triggerOldMap.get(call.Id).Status_vod__c == 'Saved_vod' && (triggerOldMap.get(call.Id).Signature_vod__c != null || triggerOldMap.get(call.Id).Sample_Card_vod__c != null || triggerOldMap.get(call.Id).Sample_Send_Card_vod__c != null)) {
                    if (call.OwnerId != triggerOldMap.get(call.Id).OwnerId) {
                        call.OwnerId = triggerOldMap.get(call.Id).OwnerId;
                    }
                }

                if (triggerOldMap.get(call.Id).Status_vod__c == 'Submitted_vod' && call.OverrIde_Lock_vod__c == false) {
                    if(calls == null) {
                        calls = new Map <Id, Call2_vod__c>([SELECT Id, OverrIde_Lock_vod__c, (SELECT Name, Id FROM Call2_vod__r) FROM Call2_vod__c WHERE Id IN : triggerNew]);
                    }

                    if(calls.get(call.Id).OverrIde_Lock_vod__c == false) {
                        call.Status_vod__c.addError(System.Label.GNE_SFA2_Submitted_Call_Update_error);
                    }
                }

                call.No_Disbursement_vod__c = false;
                call.OverrIde_Lock_vod__c = false;
                if (call.Status_vod__c == 'Submitted_vod' &&  GNE_SFA2_Interaction_Util.updateAction == false && GNE_SFA2_Interaction_Util.insertAction == false) {
                    call.Status_vod__c = 'Saved_vod';
                }
            }
        }
    }

    private static void updatePrepStatus(Map<Id, Call2_vod__c> oldCallMap,  List<Call2_vod__c> newCallList) {
        for(Call2_vod__c call : newCallList) {
            if(call.Account_vod__c!=null && (!call.Completed_gne__c || oldCallMap==null || !oldCallMap.get(call.Id).Completed_gne__c) && GNE_SFA2_PREP_Util.isPrepInteraction(call)
            	&& (!GNE_SFA2_Interaction_Trigger_Helper.isOtrRequest()	|| (GNE_SFA2_Interaction_Trigger_Helper.isOtrRequest() && (!call.Completed_gne__c || String.isBlank(call.PREP_Status_gne__c))))) {
               	call.PREP_Status_gne__c = String.isNotBlank(call.PREP_Account_Status_calc_gne__c) ? call.PREP_Account_Status_calc_gne__c : GNE_SFA2_PREP_Util.PREP_STATUS_RED;
            } else if(call.Account_vod__c==null && String.isNotBlank(call.PREP_Status_gne__c)) {
                call.PREP_Status_gne__c = null;
            }
        }
    }

    private static void setCreatorProfile(List<Call2_vod__c> calls) {
        Set<Id> creatorIds = new Set<Id>();

        for(Call2_vod__c call : calls) {
            if(String.isBlank(call.CreatedBy_Profile_gne__c)) {
                creatorIds.add(getCreatorId(call));
            }
        }

        Map<Id,String> profileNamesMap = new Map<Id,String>();

        if(creatorIds.size()==1 && creatorIds.contains(UserInfo.getUserId())) {
            profileNamesMap.put(UserInfo.getUserId(), GNE_SFA2_Util.getCurrentUserProfileName());
        } else if(!creatorIds.isEmpty()) {
            Map<Id,String> userToProfileMap = GNE_SFA2_Interaction_Trigger_Helper.getUserToProfileNameMap(creatorIds);

            for(Id userId : creatorIds) {
                profileNamesMap.put(userId, userToProfileMap.get(userId));
            }
        }

        if(!profileNamesMap.isEmpty()) {
            for(Call2_vod__c call : calls) {
                if(String.isBlank(call.CreatedBy_Profile_gne__c)) {
                    call.CreatedBy_Profile_gne__c = profileNamesMap.get(getCreatorId(call));
                }
            }
        }
    }

    private static Id getCreatorId(Call2_vod__c call) {
        return call.OwnerId!=null && call.OwnerId.getSObjectType() == User.sObjectType ? call.OwnerId : call.CreatedById!=null ? call.CreatedById : UserInfo.getUserId();
    }

    private static void synchronizeInteractionTypeForRAMA(Map<Id, Call2_vod__c> triggerOldMap,  List<Call2_vod__c> triggerNew) {
        if (triggerOldMap == null) {
            //insert
            for(Call2_vod__c call : triggerNew) {
                if (String.isBlank(call.Interaction_Type_RAMA_gne__c)) {
                    call.Interaction_Type_RAMA_gne__c = call.Interaction_Type_gne__c;
                } else {
                    call.Interaction_Type_gne__c = call.Interaction_Type_RAMA_gne__c;
                }
            }
        } else {
            //update
            for(Call2_vod__c call : triggerNew) {
                if (triggerOldMap.get(call.Id).Interaction_Type_RAMA_gne__c == call.Interaction_Type_RAMA_gne__c) {
                    call.Interaction_Type_RAMA_gne__c = call.Interaction_Type_gne__c;
                } else {
                    call.Interaction_Type_gne__c = call.Interaction_Type_RAMA_gne__c;
                }
            }
        }
    }
}