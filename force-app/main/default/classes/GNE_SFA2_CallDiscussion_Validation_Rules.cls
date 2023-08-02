/************************************************************
*  @author: Marta Malinowska
*  Date: 11/06/2014
*  Description: This class GNE_SFA2_CallDiscussion_Validation_Rules handles Validations on Call2_Discussion_vod__c object on DML operations
*  This class is being used in GNE_SFA2_Call_Discussion_Trigger trigger
*  
*  Modification History
*  Date      Name        Description
*            
*************************************************************/

public without sharing class GNE_SFA2_CallDiscussion_Validation_Rules {
    public final static Integer newOTRVersion = 405;
    
    public static void OnBeforeUpdate(Map<Id,Call2_Discussion_vod__c> oldCallMap,  Map<Id, Call2_Discussion_vod__c> newCallDiscussionMap){
        callDiscussionObservationValidation(newCallDiscussionMap.values());
    }
    
    public static void OnBeforeInsert(List<Call2_Discussion_vod__c> newCallDiscussionList){
        callDiscussionObservationValidation(newCallDiscussionList);
    }
    
    private static void callDiscussionObservationValidation(List<Call2_Discussion_vod__c> callDiscussionList){
        
        if (GNE_SFA2_Util.getCurrentUserProfileName().startsWith('GNE-TLS')){
            for(Call2_Discussion_vod__c callDiscussion : callDiscussionList){
                Boolean isObservationRequired = !GNE_SFA2_Util.isOldOTRVersion(callDiscussion.iPhone_Request_Id_gne__c, newOTRVersion);
                if(isObservationRequired && callDiscussion.Event_gne__c && callDiscussion.Activity_gne__c == 'Compliance Coaching' && String.isBlank(callDiscussion.Observation_gne__c)){
                    callDiscussion.Observation_gne__c.addError(Label.GNE_SFA2_ErrMsg_CallDiscussion_Observation_Required);                  
                }
                if(String.isNotBlank(callDiscussion.Observation_gne__c) && (!callDiscussion.Event_gne__c || callDiscussion.Activity_gne__c != 'Compliance Coaching')){
                    callDiscussion.Observation_gne__c.addError(Label.GNE_SFA2_ErrMsg_CallDiscussion_EventRelated_And_ComplianceCoaching_Required); 
                }
                if( GNE_SFA2_Interaction_Util.isTLLInteractionForSBT(callDiscussion) && String.isBlank(callDiscussion.Event_Curriculum_gne__c) ){
                    callDiscussion.Event_Curriculum_gne__c.addError(Label.GNE_SFA2_ErrMsg_CallDiscussion_Curriculum_Required); 
                }
            }
        }    
    }
    
}