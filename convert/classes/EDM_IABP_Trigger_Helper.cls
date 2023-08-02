public with sharing class EDM_IABP_Trigger_Helper {
    public static void onBeforeInsert(List<EDM_IABP_gne__c> triggerOld, List<EDM_IABP_gne__c> triggerNew) {
        Map<Id, EDM_AABP_gne__c> parentAABPs = retrieveParentAABPs(triggerNew);
        generateTitle(triggerOld, triggerNew, parentAABPs);
        for (EDM_IABP_gne__c iabp : triggerNew) {
            if (iabp.EDM_Historical_gne__c == false && iabp.EDM_Executive_Summary_gne__c == false) {
                iabp.EDM_Type_for_Doc_gne__c = EDM_IABP_Utils.getTypeForDoc(iabp, parentAABPs.get(iabp.EDM_Parent_AABP_gne__c).EDM_Group_gne__c);
                iabp.EDM_ABS_Manager_gne__c = parentAABPs.get(iabp.EDM_Parent_AABP_gne__c).EDM_ABS_Manager_gne__c;
            }
        }
    }

    public static void onBeforeUpdate(List<EDM_IABP_gne__c> triggerOld, Map<Id,EDM_IABP_gne__c> triggerNew) {
        Map<Id, EDM_AABP_gne__c> parentAABPs = retrieveParentAABPs(triggerNew.values());
        generateTitle(triggerOld, triggerNew.values(), parentAABPs);
    }

    public static void onAfterInsert(List<EDM_IABP_gne__c> triggerOld, List<EDM_IABP_gne__c> triggerNew) {
        Map<Id, EDM_IABP_gne__c> snapsByParent = new Map<Id, EDM_IABP_gne__c>();
        for (EDM_IABP_gne__c snap : triggerNew) {
            if (snap.EDM_Historical_gne__c == true) {
                snapsByParent.put(snap.EDM_History_Parent_IABP_gn__c, snap);
            }
        }
        for (EDM_IABP_gne__c snap : snapsByParent.values()) {
            EDM_ABM_Utils.dupliacateSharings(snap.EDM_History_Parent_IABP_gn__c, snap.Id);
        }

        List<EDM_IABP_gne__c> parentIABPs = [SELECT Id, EDM_History_Previous_IABP_gne__c 
											FROM EDM_IABP_gne__c
											WHERE Id IN :snapsByParent.keySet()];
        for (EDM_IABP_gne__c parent : parentIABPs) {
        	parent.EDM_History_Previous_IABP_gne__c = snapsByParent.get(parent.Id).Id;
        }
        update parentIABPs;
    }

    public static void onAfterUpdate(Map<Id, EDM_IABP_gne__c> triggerOldMap, Map<Id, EDM_IABP_gne__c> triggerNewMap) {
        Set<Id> toSnapshotIds = new Set<Id>();
        Boolean increaseVersionNumber = false;
        for (EDM_IABP_gne__c iabp : triggerOldMap.values()) {
        	if ((iabp.EDM_Status_gne__c == 'IABP In Progress' || iabp.EDM_Status_gne__c == 'IABP Not Started') && triggerNewMap.get(iabp.Id).EDM_Status_gne__c == 'IABP Under Review') {
        		System.debug('$$ Add snap IF1: Submit to ABS');
                toSnapshotIds.add(iabp.Id);
            }
            else if (iabp.EDM_Status_gne__c == 'IABP Under Review' && triggerNewMap.get(iabp.Id).EDM_Status_gne__c == 'IABP In Progress') {
            	System.debug('$$ Add snap IF2: Return to ABL');
                toSnapshotIds.add(iabp.Id);
            }
            else if (iabp.EDM_Status_gne__c == 'IABP Submitted for Approval' && triggerNewMap.get(iabp.Id).EDM_Status_gne__c == 'IABP Approved') {
            	System.debug('$$ Add snap IF3: Approved in approval process');
                toSnapshotIds.add(iabp.Id);
            }
            else if (iabp.EDM_Status_gne__c == 'Revising Approved IABP' && triggerNewMap.get(iabp.Id).EDM_Status_gne__c == 'Re-Reviewing Approved IABP') {
            	System.debug('$$ Add snap IF4: Submit to ABS after approval');
                toSnapshotIds.add(iabp.Id);
            }
            else if (iabp.EDM_Status_gne__c == 'Re-Reviewing Approved IABP' && triggerNewMap.get(iabp.Id).EDM_Status_gne__c == 'Revising Approved IABP') {
            	System.debug('$$ Add snap IF5: Return to ABL after approval');
                toSnapshotIds.add(iabp.Id);
            }
            else if (iabp.EDM_Status_gne__c == 'Re-Reviewing Approved IABP' && triggerNewMap.get(iabp.Id).EDM_Status_gne__c == 'IABP Approved') {
            	System.debug('$$ Add snap IF6: Validate after approval');
                toSnapshotIds.add(iabp.Id);
            }
            else if ((iabp.EDM_ExeSum_Status_gne__c == 'Not Started' || iabp.EDM_ExeSum_Status_gne__c == 'Started') && triggerNewMap.get(iabp.Id).EDM_ExeSum_Status_gne__c == 'In Review') {
                System.debug('$$ Add snap IF7: Submit ExeSum to ABS');
                toSnapshotIds.add(iabp.Id);
            }
            else if (iabp.EDM_ExeSum_Status_gne__c == 'In Review' && triggerNewMap.get(iabp.Id).EDM_ExeSum_Status_gne__c == 'Started') {
                System.debug('$$ Add snap IF8:  Return ExeSum to ABL');
                toSnapshotIds.add(iabp.Id);
            }
            else if (iabp.EDM_Status_gne__c != 'Event Occurred' && triggerNewMap.get(iabp.Id).EDM_Status_gne__c == 'Event Occurred') {
                System.debug('$$ Add snap IF9:  Event Occurred');
                toSnapshotIds.add(iabp.Id);
            }
       	}        

       	for (Id iabpId : toSnapshotIds) {
            EDM_ABM_Utils.createSnapshot(iabpId);
        }

        snapshotPTDsWhenExeSumFinalized(triggerOldMap, triggerNewMap);
        snapshotCurrentStateForAttendees(triggerOldMap, triggerNewMap);
	}

    public static void onAfterDelete(Map<Id, EDM_IABP_gne__c> triggerOldMap) {
        deleteRecentlyChosenIabps(triggerOldMap);
    }

    private static void deleteRecentlyChosenIabps(Map<Id, EDM_IABP_gne__c> triggerOldMap) {
        List<EDM_Recently_Chosen_IABP_gne__c> toRemove = [
        SELECT Id 
        FROM EDM_Recently_Chosen_IABP_gne__c 
        WHERE EDM_IABP_gne__c IN :triggerOldMap.keySet()];

        delete toRemove;
    }

    private static Map<Id, EDM_AABP_gne__c> retrieveParentAABPs(List<EDM_IABP_gne__c> triggerNew) {
        Set<Id> parentAABPsId = new Set<Id>();

        for (EDM_IABP_gne__c newIABP : triggerNew) {
            if (newIABP.EDM_Historical_gne__c == false && newIABP.EDM_Executive_Summary_gne__c == false) {
                parentAABPsId.add(newIABP.EDM_Parent_AABP_gne__c);
            }
        }

        Map<Id, EDM_AABP_gne__c> parentAABPs = new Map<Id, EDM_AABP_gne__c>([SELECT EDM_Group_gne__c, EDM_Unit_gne__c, EDM_Team_gne__c, EDM_ABS_Manager_gne__c FROM EDM_AABP_gne__c WHERE Id IN :parentAABPsId]);
        return parentAABPs;
    }

    private static void generateTitle(List<EDM_IABP_gne__c> triggerOld, List<EDM_IABP_gne__c> triggerNew, Map<Id, EDM_AABP_gne__c> parentAABPs) {
        Set<Id> isEventTypeChange = new Set<Id>();
        if(triggerOld != null){
            for(Integer i = 0; i < triggerOld.size(); i++){
                EDM_IABP_gne__c newIABP = triggerNew[i];
                if (newIABP.EDM_Historical_gne__c == false && newIABP.EDM_Executive_Summary_gne__c == false) {
                    if(triggerOld[i].EDM_Type_of_Event_gne__c != newIABP.EDM_Type_of_Event_gne__c){
                        isEventTypeChange.add(newIABP.Id);
                    }
                }
            }
        }
        
        List<EDM_IABP_gne__c> children = [SELECT Id, Name, EDM_Year_gne__c, EDM_Event_Name_gne__c, EDM_Parent_AABP_gne__c, EDM_Ad_Hoc_Event_gne__c
                                            FROM EDM_IABP_gne__c 
                                            WHERE EDM_Parent_AABP_gne__c IN :parentAABPs.keySet()
                                            AND EDM_Historical_gne__c = false
                                            AND EDM_Executive_Summary_gne__c = false];
        Map<Id, List<EDM_IABP_gne__c>> aabpStructure = new Map<Id, List<EDM_IABP_gne__c>>();        
        for (Id i : parentAABPs.keySet()) {
            List<EDM_IABP_gne__c> c = new List<EDM_IABP_gne__c>();
            for (EDM_IABP_gne__c ia : children) {
                if (ia.EDM_Parent_AABP_gne__c == i) {
                    c.add(ia);
                }
            }
            aabpStructure.put(i, c);
        }

        for (EDM_IABP_gne__c newIABP : triggerNew) {
            if (newIABP.EDM_Historical_gne__c == false && newIABP.EDM_Executive_Summary_gne__c == false 
                && (String.isBlank(newIABP.EDM_Event_Name_gne__c) || isEventTypeChange.contains(newIABP.Id))
                && parentAABPs.get(newIABP.EDM_Parent_AABP_gne__c).EDM_Group_gne__c != null
                && parentAABPs.get(newIABP.EDM_Parent_AABP_gne__c).EDM_Unit_gne__c != null
                && parentAABPs.get(newIABP.EDM_Parent_AABP_gne__c).EDM_Team_gne__c != null) {
            	
                newIABP.EDM_Event_Name_gne__c = EDM_IABP_Utils.getEventTitle(newIABP, triggerNew, parentAABPs.get(newIABP.EDM_Parent_AABP_gne__c), aabpStructure.get(newIABP.EDM_Parent_AABP_gne__c));
            }
        }
    }

    private static void snapshotPTDsWhenExeSumFinalized(Map<Id, EDM_IABP_gne__c> triggerOldMap, Map<Id, EDM_IABP_gne__c> triggerNewMap) {
        Set<Id> justFinalizedExeSumIDs = new Set<Id>();
        for (EDM_IABP_gne__c newIabp : triggerNewMap.values()) {
            if (isExeSumAndHasJustBeenFinalized(newIabp, triggerOldMap)) {
                justFinalizedExeSumIDs.add(newIabp.Id);
            }
        }

        if (!justFinalizedExeSumIDs.isEmpty()) { 
            List<EDM_Attachment_gne__c> ptdsClonesToInsert = new List<EDM_Attachment_gne__c>();
            List<EDM_Attachment_gne__c> allPTDs = retrieveAllPTDs(justFinalizedExeSumIDs);

            List<EDM_Attachment_gne__c> ptdsToClone = getPTDsToClone(allPTDs);
            Set<Id> alreadyClonedIds = getAlreadyClonedIds(allPTDs);

            for (EDM_Attachment_gne__c ptdToClone : ptdsToClone) {
                if (!alreadyClonedIds.contains(ptdToClone.Id) && ptdToClone.EDM_System_Type_gne__c == null) {
                    ptdsClonesToInsert.add(getPtdClone(ptdToClone));
                }
            }

            insert ptdsClonesToInsert;
        }
    }

    private static Boolean isExeSumAndHasJustBeenFinalized(EDM_IABP_gne__c newIabp, Map<Id, EDM_IABP_gne__c> oldIabpsById) {
        return newIabp.EDM_Executive_Summary_gne__c 
                && (newIabp.EDM_ExeSum_Status_gne__c == 'Finalized' || newIabp.EDM_ExeSum_Status_gne__c == 'Complete') 
                && oldIabpsById.get(newIabp.Id) != null 
                && oldIabpsById.get(newIabp.Id).EDM_ExeSum_Status_gne__c != 'Finalized'
                && oldIabpsById.get(newIabp.Id).EDM_ExeSum_Status_gne__c != 'Complete';
    }

    private static List<EDM_Attachment_gne__c> retrieveAllPTDs(Set<Id> justFinalizedExeSumIDs) {
        List<Id> listOfIds = new List<Id>();
        listOfIds.addAll(justFinalizedExeSumIDs);
        String whereClause = 'EDM_Pull_Through_Doc_gne__c = true ';
        whereClause += ' AND EDM_Parent_IABP_gne__c IN ' + '(\'' + String.join(listOfIds, '\',\'') + '\')';
        String ptdQuery = EDM_ABM_Utils.getAllFieldsSOQL('EDM_Attachment_gne__c', whereClause);
        return (List<EDM_Attachment_gne__c>)Database.query(ptdQuery);
    }

    private static List<EDM_Attachment_gne__c> getPTDsToClone(List<EDM_Attachment_gne__c> allPTDs) {
        List<EDM_Attachment_gne__c> result = new List<EDM_Attachment_gne__c>();
        for (EDM_Attachment_gne__c ptd : allPTDs) {
            if (ptd.EDM_System_Type_gne__c == null) {
                result.add(ptd);
            }
        }
        return result;
    }

    private static Set<Id> getAlreadyClonedIds(List<EDM_Attachment_gne__c> allPTDs) {
        Set<Id> result = new Set<Id>();
        for (EDM_Attachment_gne__c ptd : allPTDs) {
            if (ptd.EDM_System_Type_gne__c == 'PTD_Snapshot') {
                result.add(ptd.EDM_PreSnap_Attachment__c);
            }
        }
        return result;
    }

    private static EDM_Attachment_gne__c getPtdClone(EDM_Attachment_gne__c ptdToClone) {
        EDM_Attachment_gne__c duplicate = ptdToClone.clone(false, true, false, true);
        duplicate.EDM_PreSnap_Attachment__c = ptdToClone.Id;
        duplicate.EDM_System_Type_gne__c = 'PTD_Snapshot';
        return duplicate;
    }

    private static void snapshotCurrentStateForAttendees(Map<Id, EDM_IABP_gne__c> triggerOldMap, Map<Id, EDM_IABP_gne__c> triggerNewMap) {
        Set<Id> iabpIds = new Set<Id>();
        for (EDM_IABP_gne__c iabp : triggerNewMap.values()) {            
            if (triggerOldMap.get(iabp.Id).EDM_Status_gne__c != 'Event Occurred' && iabp.EDM_Status_gne__c == 'Event Occurred') {
                iabpIds.add(iabp.Id);
            }
        }
        if (iabpIds.size() > 0) {
            List<EDM_Attendee_gne__c> attendees = [select id, 
                EDM_Current_Business_Classification_gne__c, EDM_Current_Business_Class_Role_gne__c, EDM_Current_Business_Classif_Date_gne__c,
                EDM_Current_Clinical_Classification_gne__c, EDM_Current_Clinical_Classif_Date_gne__c,
                EDM_Current_Exclusion_Status_gne__c, EDM_Current_Exclusion_Checked_Date_gne__c,
                EDM_Current_Clinical_Specialties_gne__c,
                EDM_Account_gne__c, EDM_Parent_IABP_gne__r.EDM_End_Date_gne__c
                from EDM_Attendee_gne__c where EDM_Parent_IABP_gne__c in :iabpIds];

            if (attendees.size() > 0) {
                Map<Id, Account> accounts = retrieveAttendeeAccounts(attendees);

                for (EDM_Attendee_gne__c att : attendees) {                    

                    if (accounts.get(att.EDM_Account_gne__c) != null) {
                        att.EDM_Current_Business_Classification_gne__c = accounts.get(att.EDM_Account_gne__c).EDM_Business_Classification_gne__c;
                        att.EDM_Current_Business_Class_Role_gne__c = accounts.get(att.EDM_Account_gne__c).EDM_Business_Cl_Role_gne__c;
                        att.EDM_Current_Clinical_Classification_gne__c = accounts.get(att.EDM_Account_gne__c).EDM_Clinical_Classification_gne__c;

                        if(System.today() > att.EDM_Parent_IABP_gne__r.EDM_End_Date_gne__c) {
                            AGS_EX_Exclusion_Check_gne__c exCheck = getCurrentExclusionCheck(att.EDM_Account_gne__c);
                            if(exCheck != null) {
                                att.EDM_Current_Exclusion_Status_gne__c = exCheck.AGS_EX_Status_gne__c;
                                att.EDM_Current_Exclusion_Checked_Date_gne__c = exCheck.AGS_EX_Check_Date_gne__c;
                            }
                        } else {
                            att.EDM_Current_Exclusion_Status_gne__c = accounts.get(att.EDM_Account_gne__c).AGS_EX_Exclusion_Status_gne__c;
                            att.EDM_Current_Exclusion_Checked_Date_gne__c = accounts.get(att.EDM_Account_gne__c).AGS_EX_Date_Checked_Exclusion_gne__c;
                        }
                        att.EDM_Current_Clinical_Specialties_gne__c = accounts.get(att.EDM_Account_gne__c).Specialties_gne__c;

                        att.EDM_Current_Business_Classif_Date_gne__c = accounts.get(att.EDM_Account_gne__c).EDM_Business_Classification_Date_gne__c;
                        att.EDM_Current_Clinical_Classif_Date_gne__c = accounts.get(att.EDM_Account_gne__c).EDM_Clinical_Classification_Date_gne__c;
                        
                        if (accounts.get(att.EDM_Account_gne__c).AGS_EX_Exclusion_Status_gne__c == 'Request Pending' || 
                            accounts.get(att.EDM_Account_gne__c).AGS_EX_Exclusion_Status_gne__c == 'In Process') {
                               
                            List<AGS_EX_Exclusion_Request_gne__c> existingExclusionRequests = [SELECT Id, AGS_EX_Account_Name_gne__c,CreatedDate 
                                                                                    FROM AGS_EX_Exclusion_Request_gne__c 
                                                                                    WHERE 
                                                                                    (AGS_EX_Request_Status_gne__c = 'Pending' OR AGS_EX_Request_Status_gne__c = 'In Progress')
                                                                                  AND AGS_EX_Account_Name_gne__c = :accounts.get(att.EDM_Account_gne__c).Id];
                            if(!existingExclusionRequests.isEmpty()) {
                                DateTime dT = existingExclusionRequests[0].CreatedDate;                  
                                att.EDM_Current_Exclusion_Checked_Date_gne__c = Date.newInstance(dT.year(), dT.month(), dT.day());                                
                            } else {
                                att.EDM_Current_Exclusion_Checked_Date_gne__c = accounts.get(att.EDM_Account_gne__c).AGS_EX_Date_Checked_Exclusion_gne__c;
                            }
                        }
                    }
                }

                update attendees;                
            }
        }
    }

    private static AGS_EX_Exclusion_Check_gne__c getCurrentExclusionCheck(String accountId) {
        List<AGS_EX_Exclusion_Request_gne__c> lastExclusionRequests = [
                SELECT Id, AGS_EX_Request_Status_gne__c, (SELECT AGS_EX_Status_gne__c, AGS_EX_Check_Date_gne__c FROM AGS_EX_Exclusion_Checks__r WHERE AGS_EX_Check_Date_gne__c = LAST_N_DAYS:365)
                FROM AGS_EX_Exclusion_Request_gne__c
                WHERE AGS_EX_Account_Name_gne__c = :accountId
                ORDER BY CreatedDate DESC
                LIMIT 1
        ];
        if (lastExclusionRequests.size() > 1) {
            return lastExclusionRequests[1].AGS_EX_Exclusion_Checks__r[0];
        }
        return null;
    }

    private static Map<Id, Account> retrieveAttendeeAccounts(List<EDM_Attendee_gne__c> attendees) {
        Set<Id> hcpIds = new Set<Id>();
        for (EDM_Attendee_gne__c att : attendees) {
            hcpIds.add(att.EDM_Account_gne__c);
        }
        Map<Id, Account> result = new Map<Id, Account>([SELECT id, EDM_Business_Classification_gne__c, EDM_Business_Classification_Date_gne__c,
                                                EDM_Clinical_Classification_gne__c, EDM_Clinical_Classification_Date_gne__c,
                                                AGS_EX_Exclusion_Status_gne__c, AGS_EX_Date_Checked_Exclusion_gne__c, EDM_Business_Cl_Role_gne__c,
                                                Specialties_gne__c
                                      FROM Account 
                                      WHERE id IN :hcpIds ]); 

        return result;
    }
}