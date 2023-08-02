/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-08-20
*  Description: This is a helper class for handling Affiliation field updates
*  Test class: GNE_SFA2_Affiliation_Trigger_Test
*    
*  Modification History
*  Date        Name                 Description
*************************************************************/
public without sharing class GNE_SFA2_Affiliation_Field_Updates {
    
    /**
     * Change Affiliation Owner changes the affiliation owner name by GNE-Affiliation-Queue for all the affiliation except
     * all GNE-CM and all GNE-LWO groups.
     * Respective sharing rules to view the affliation by brands are created and assigned to GNE-View-All-Brands-Users-Data-Group and GNE-Non-Brand-Filter-Group
     */
    private static void changeAffiliationOwner(List<Affiliation_vod__c> triggerNew) {
        String currentUserProfile = GNE_SFA2_Util.getCurrentUserProfileName();
        Map<String, GNE_SFA2_Affiliation_Ownership_Rules__c> ownershipRules = GNE_SFA2_Affiliation_Ownership_Rules__c.getAll();
        Set<String> queueNames = new Set<String>();
        Set<String> territoryNames = new Set<String>();
        Set<String> groupNames = new Set<String>();
        for(GNE_SFA2_Affiliation_Ownership_Rules__c rule : ownershipRules.values()) {
            if(rule.Group_Type__c == 'Queue') {
                queueNames.add(rule.Group_Name__c);
            } else if(rule.Group_Type__c == 'Group') {
                groupNames.add(rule.Group_Name__c);
            } else if(rule.Group_Type__c == 'Territory') {
                territoryNames.add(rule.Group_Name__c);
            }
        }
        // select necessary groups
        Map<String, Id> queueGroupNameToId = new Map<String, Id>();
        Map<String, Id> territoryGroupNameToId = new Map<String, Id>();
        Map<String, Id> groupGroupNameToId = new Map<String, Id>();
        List<Group> queueGroups = [ SELECT Name, Id FROM Group WHERE Name IN :queueNames AND Type = 'Queue' ];
        List<Group> territoryGroups = [ SELECT Name, Id FROM Group WHERE Name IN :queueNames AND Type = 'Territory' ];
        List<Group> groupGroups = [ SELECT Name, Id FROM Group WHERE Name IN :queueNames AND Type = 'Group' ];
        
        for(Group g : queueGroups) {
            queueGroupNameToId.put(g.Name, g.Id);
        }
        
        for(Group g : territoryGroups) {
            territoryGroupNameToId.put(g.Name, g.Id);
        }
        
        for(Group g : groupGroups) {
            groupGroupNameToId.put(g.Name, g.Id);
        }
        
        for(Affiliation_vod__c affiliation : triggerNew) {
            for(GNE_SFA2_Affiliation_Ownership_Rules__c rule : ownershipRules.values()) {
                if(rule.Not_contains__c && currentUserProfile.contains(rule.Profile_name_condition__c)) {                   
                    if(rule.Group_Type__c == 'Queue') {
                        affiliation.OwnerId = queueGroupNameToId.get(rule.Group_Name__c);
                    } else if(rule.Group_Type__c == 'Group') {
                        affiliation.OwnerId = groupGroupNameToId.get(rule.Group_Name__c);
                    } else if(rule.Group_Type__c == 'Territory') {
                        affiliation.OwnerId = territoryGroupNameToId.get(rule.Group_Name__c);
                    }
                } else if(!currentUserProfile.toUpperCase().contains('CANADA') && !currentUserProfile.toUpperCase().contains('FPM') && !rule.Profile_name_condition__c.contains('CM') && !rule.Profile_name_condition__c.contains('MCCO-AM')){
                    if(rule.Group_Type__c == 'Queue') {
                        affiliation.OwnerId = queueGroupNameToId.get(rule.Group_Name__c);
                    } else if(rule.Group_Type__c == 'Group') {
                        affiliation.OwnerId = groupGroupNameToId.get(rule.Group_Name__c);
                    } else if(rule.Group_Type__c == 'Territory') {
                        affiliation.OwnerId = territoryGroupNameToId.get(rule.Group_Name__c);
                    }
                }
            }
                System.debug('current Owner Id'+affiliation.OwnerId+''+affiliation.Owner.Name);
        }
        

        
        /*
        // for GNE-MCCO-CFT use CFT specific affiliation queue  
        List<Group> grpCFT= null;
        if(Util.CurrentUserProfileName.contains(Util.cftProfileName)){
            grpCFT = [ SELECT Id, Name, OwnerID FROM Group WHERE Name LIKE :Util.cftQueueName AND Type = :Util.strQueue LIMIT 1 ];
        }
        for(Affiliation_vod__c affiliation : triggerNew) {
            if(Util.CurrentUserProfileName.contains(Util.cftProfileName)){
                affiliation.OwnerId = grpCFT[0].Id;
            } else if (Util.CurrentUserProfileName.toUpperCase().contains('CANADA')) { 
                //Do not change owner it will managed by sharing grule If owned by user in PRF_GRP_SFA_CANADA share for read with PRF_GRP_SFA_CANADA
            } else if(! (Util.CurrentUserProfileName.contains(Util.GNECMProfileName) ||  Util.CurrentUserProfileName.contains(Util.GNELWOProfileName))) {  
               affiliation.OwnerId = Util.GNEAffiliationOwnerQueueNameId;
            }
        }
        */
    }
    
    private static void updateDrugField(List<Affiliation_vod__c> triggerNew) {
       Set<Id> childAffiliationIds = new Set<Id>();
       for (Affiliation_vod__c affiliation : triggerNew){
            if(affiliation.Child_affiliation_vod__c != null) {
                childAffiliationIds.add(affiliation.Child_affiliation_vod__c);
            }
       }
       Map<Id, Affiliation_vod__c> childAffiliations  = new Map<Id, Affiliation_vod__c>([SELECT Id, Drug_gne__c FROM Affiliation_vod__c WHERE Id IN :childAffiliationIds]);
       for (Affiliation_vod__c affiliation : triggerNew) {
            if(affiliation.Child_affiliation_vod__c != null && childAffiliations.containsKey(affiliation.Child_affiliation_vod__c)) {
                affiliation.Drug_gne__c = childAffiliations.get(affiliation.Child_affiliation_vod__c).Drug_gne__c;
            }
       }
    }
    
    public static List<Affiliation_vod__c> updateExternalId(List<Affiliation_vod__c> triggerNew) {
        List<Affiliation_vod__c> changedRecs = new List<Affiliation_vod__c>();
        
        for (Affiliation_vod__c affiliation : triggerNew) {
            String oldValue = String.isNotBlank(affiliation.External_Id_vod__c) ? affiliation.External_Id_vod__c : '';
        	affiliation.External_Id_vod__c = GNE_Account_Affiliation_Dao.createExternalId(affiliation);
        	String newValue = String.isNotBlank(affiliation.External_Id_vod__c) ? affiliation.External_Id_vod__c : '';
        	
        	if(!oldValue.equals(newValue)) {
        	    changedRecs.add(affiliation);
        	}
        }
        
        return changedRecs;
    }

    private static void updatePrimaryFlagFPM(List<Affiliation_vod__c> triggerOld, List<Affiliation_vod__c> triggerNew){
        Boolean oldIsNull = triggerOld == null;
        List<Affiliation_vod__c> primaryAffiliations = new List<Affiliation_vod__c>();
        List<Id> fromList = new List<Id>();
        for(Integer i = 0; i < triggerNew.size(); i++){
            if((oldIsNull || triggerOld[i].Primary_fpm_gne__c==false) && triggerNew[i].Primary_fpm_gne__c==true){
                primaryAffiliations.add(triggerNew[i]);
                if(triggerNew[i].From_Account_vod__c != null){
                    fromList.add(triggerNew[i].From_Account_vod__c);
                } else {
                    fromList.add(triggerNew[i].From_Contact_vod__c);
                }
            }
        }
        if(!primaryAffiliations.isEmpty() && !fromList.isEmpty()){
            List<Affiliation_vod__c> noLongerPrimaryAffiliations = [SELECT Id, Primary_fpm_gne__c 
                                                                    FROM Affiliation_vod__c 
                                                                    WHERE Primary_fpm_gne__c = true 
                                                                    AND (From_Account_vod__c IN :fromList OR From_Contact_vod__c IN :fromList) 
                                                                    AND Id NOT IN :triggerNew];
            for(Affiliation_vod__c aff : noLongerPrimaryAffiliations){
                aff.Primary_fpm_gne__c = false;
            }
            if(!noLongerPrimaryAffiliations.isEmpty()){
                update noLongerPrimaryAffiliations;
            }
        }
    }

    private static void updateAffTypeToDefaultValue(List<Affiliation_vod__c> triggerNew){
        for(Affiliation_vod__c aff : triggerNew) {
            if(String.isBlank(aff.Affiliation_Type_gne__c)) {
                aff.Affiliation_Type_gne__c = 'AFFILIATION';
            }
        }
    }


    
    public static void onBeforeUpdate(List<Affiliation_vod__c> triggerOld, List<Affiliation_vod__c> triggerNew) {
       if(!GNE_SFA2_Util.isMergeMode()) {
           updateExternalId(triggerNew);
           updateDrugField(triggerNew);
	       updatePrimaryFlagFPM(triggerOld, triggerNew);
           updateAffTypeToDefaultValue(triggerNew);
       }
    }
    
    public static void onBeforeInsert(List<Affiliation_vod__c> triggerNew) {
       if(!GNE_SFA2_Util.isMergeMode()) {
	       updateExternalId(triggerNew);
           updateDrugField(triggerNew);
	       changeAffiliationOwner(triggerNew);
	       updatePrimaryFlagFPM(null, triggerNew);
           updateAffTypeToDefaultValue(triggerNew);
       }
    }
}