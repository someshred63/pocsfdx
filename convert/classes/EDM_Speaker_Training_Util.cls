public without sharing class EDM_Speaker_Training_Util {

    public static List<Speaker_Training_gne__c> getSpeakerTrainigs(List<Curriculum_Speaker_Bureau_gne__c> curriculumBureauJunctions) {
        Set<Id> curriculumIds = getIdSetFromList('Event_Curriculum_gne__c', curriculumBureauJunctions);
        return retrieveSpeakerTrainingsFor(curriculumIds);
    }

    public static List<Speaker_Training_gne__c> getSpeakerTrainigs(List<Speaker_Bureau_Membership_gne__c> sbms) {
        List<Speaker_Bureau_gne__c> speakerBureaus = getSpeakerBureausFrom(sbms);
        List<Curriculum_Speaker_Bureau_gne__c> curriculumBureauJunctions = new List<Curriculum_Speaker_Bureau_gne__c>();
        for (Speaker_Bureau_gne__c sb : speakerBureaus) {
            curriculumBureauJunctions.addAll(sb.Curriculum_Speaker_Bureau_s__r);
        }
        return getSpeakerTrainigs(curriculumBureauJunctions);
    }

    public static List<Speaker_Bureau_Membership_gne__c> getSBMs(List<Speaker_Training_gne__c> speakerTrainings, List<Curriculum_Speaker_Bureau_gne__c> curriculumBureauJunctions) {
        Set<Id> speakerIds = getIdSetFromList('Speaker_gne__c', speakerTrainings);
        Set<Id> bureauIds = getIdSetFromList('Speaker_Bureau_gne__c', curriculumBureauJunctions);
        return retrieveSBMsFor(bureauIds, speakerIds);
    }

    public static Set<MembershipTrainingIdentifier> getExistingMTIs(List<Speaker_Training_gne__c> speakerTrainings, List<Speaker_Bureau_Membership_gne__c> speakerBureauMemberships) {
        List<Member_Trainings_gne__c> existingMemberTrainings = retrieveExistingMemberTrainingsFor(speakerTrainings, speakerBureauMemberships);
        return getMTIsFor(existingMemberTrainings);
    }

    public static Member_Trainings_gne__c getMemberTrainingFor(Id sbmId, Id stId) {
        Member_Trainings_gne__c memberTraining = new Member_Trainings_gne__c();
        memberTraining.Speaker_Bureau_Membership_gne__c = sbmId;
        memberTraining.Speaker_Training_gne__c = stId;
        return memberTraining;
    }

    private static List<Speaker_Bureau_gne__c> getSpeakerBureausFrom(List<Speaker_Bureau_Membership_gne__c> sbms) {
        Set<Id> sbIds = getIdSetFromList('Speaker_Bureau_ID_gne__c', sbms);
        return [SELECT Id, (SELECT Id, Event_Curriculum_gne__c FROM Curriculum_Speaker_Bureau_s__r) FROM Speaker_Bureau_gne__c WHERE Id = :sbIds];
    }

    private static Set<Id> getIdSetFromList(String idFieldName, List<SObject> objList) {
        Set<Id> result = new Set<Id>();
        for (SObject item : objList) {
            result.add((Id)item.get(idFieldName));
        }
        return result;
    }

    private static Set<MembershipTrainingIdentifier> getMTIsFor(List<Member_Trainings_gne__c> memberTrainings) {        
        Set<MembershipTrainingIdentifier> result = new Set<MembershipTrainingIdentifier>();
        for (Member_Trainings_gne__c item : memberTrainings) {
            result.add(new MembershipTrainingIdentifier(item.Speaker_Bureau_Membership_gne__c, item.Speaker_Training_gne__c));
        }

        return result;
    }

    private static List<Speaker_Bureau_Membership_gne__c> retrieveSBMsFor(Set<Id> bureauIds, Set<Id> speakerIds) {
        return [SELECT Id, Bureau_Member_gne__c FROM Speaker_Bureau_Membership_gne__c
                WHERE Speaker_Bureau_ID_gne__c IN :bureauIds
                    AND Bureau_Member_gne__c IN :speakerIds];
    }    

    private static List<Member_Trainings_gne__c> retrieveExistingMemberTrainingsFor(List<Speaker_Training_gne__c> speakerTrainings, List<Speaker_Bureau_Membership_gne__c> speakerBureauMemberships) {
        return [SELECT Speaker_Bureau_Membership_gne__c, Speaker_Training_gne__c FROM Member_Trainings_gne__c
                WHERE Speaker_Bureau_Membership_gne__c IN :speakerBureauMemberships
                    AND Speaker_Training_gne__c IN :speakerTrainings];
    }

    private static List<Speaker_Training_gne__c> retrieveSpeakerTrainingsFor(Set<Id> curriculumIds) {
        return [SELECT Id, Speaker_gne__c FROM Speaker_Training_gne__c 
        		WHERE Event_Curriculum_gne__c IN :curriculumIds];
    }

    public class MembershipTrainingIdentifier {
        private String speakerBureauMembershipId;
        private String speakerTrainingId;

        public MembershipTrainingIdentifier(String speakerBureauMembershipId, String speakerTrainingId) {
            this.speakerBureauMembershipId = speakerBureauMembershipId;
            this.speakerTrainingId = speakerTrainingId;
        }

        public Boolean equals(Object obj) {
            if (obj instanceof MembershipTrainingIdentifier) {
                MembershipTrainingIdentifier compareTo = (MembershipTrainingIdentifier)obj;
                return (speakerBureauMembershipId.equals(compareTo.speakerBureauMembershipId) 
                        && speakerTrainingId.equals(compareTo.speakerTrainingId));
            }
            return false;
        }

        public Integer hashCode() {
            return (speakerBureauMembershipId + speakerTrainingId).hashcode();
        }
    }    
}