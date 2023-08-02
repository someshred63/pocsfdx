public without sharing class EDM_Curriculum_SB_TriggerHelper {
    public static void onAfterInsert(List<Curriculum_Speaker_Bureau_gne__c> triggerNewList){
        updateParents(triggerNewList);
        createMemberTrainings(triggerNewList);
    }
    
    public static void onBeforeDelete(List<Curriculum_Speaker_Bureau_gne__c> triggerOldList){
        updateParents(triggerOldList);    
    }
    
    public static void onAfterUpdate(List<Curriculum_Speaker_Bureau_gne__c> triggerNewList){
        updateParents(triggerNewList);    
    }
    
    private static void updateParents(List<Curriculum_Speaker_Bureau_gne__c> listOfChildren){
        Set<Id> parentIds = new Set<Id>();
        for(Curriculum_Speaker_Bureau_gne__c child :listOfChildren){
            parentIds.add(child.Event_Curriculum_gne__c);
        }
        List<Event_Curriculum_gne__c> toUpdate = [SELECT Id FROM Event_Curriculum_gne__c WHERE Id IN :parentIds];
        if(toUpdate.size()>0){
            update toUpdate;
        }
    }

    private static void createMemberTrainings(List<Curriculum_Speaker_Bureau_gne__c> triggerNewList) {        
        List<Speaker_Training_gne__c> speakerTrainings = EDM_Speaker_Training_Util.getSpeakerTrainigs(triggerNewList);
        List<Speaker_Bureau_Membership_gne__c> speakerBureauMemberships = EDM_Speaker_Training_Util.getSBMs(speakerTrainings, triggerNewList);        
        Set<EDM_Speaker_Training_Util.MembershipTrainingIdentifier> existingTrainingsMTIs = EDM_Speaker_Training_Util.getExistingMTIs(speakerTrainings, speakerBureauMemberships);

        List<Member_Trainings_gne__c> newMemberTrainings = new List<Member_Trainings_gne__c>();

        for (Speaker_Bureau_Membership_gne__c sbm : speakerBureauMemberships) {
            for (Speaker_Training_gne__c st : speakerTrainings) {
                EDM_Speaker_Training_Util.MembershipTrainingIdentifier mtiToCheck = new EDM_Speaker_Training_Util.MembershipTrainingIdentifier(sbm.Id, st.Id);
                if (sbm.Bureau_Member_gne__c == st.Speaker_gne__c && !existingTrainingsMTIs.contains(mtiToCheck)) {
                    newMemberTrainings.add(getMemberTrainingFor(sbm.Id, st.Id));
                }
            }
        }

        insert newMemberTrainings;
    }

    private static Member_Trainings_gne__c getMemberTrainingFor(Id sbmId, Id stId) {
        Member_Trainings_gne__c memberTraining = new Member_Trainings_gne__c();
        memberTraining.Speaker_Bureau_Membership_gne__c = sbmId;
        memberTraining.Speaker_Training_gne__c = stId;
        return memberTraining;
    }
}