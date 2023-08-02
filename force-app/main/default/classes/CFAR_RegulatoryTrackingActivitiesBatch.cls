global class CFAR_RegulatoryTrackingActivitiesBatch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT Id, frm_Trial_Status_ref_gne__c, IND_Required_gne__c, IRB_Required_gne__c, FSR_Required_gne__c, Capability_Assessment_Required__c FROM CFAR_Trial_gne__c WHERE frm_Trial_Status_ref_gne__c != \'Concluded\'');
    }

    global void execute(Database.BatchableContext context, List<CFAR_Trial_gne__c> trials) {
        List<CFAR_Regulatory_Document_Tracking_gne__c> newTrialTrackingActivities = new List<CFAR_Regulatory_Document_Tracking_gne__c>();

        List<CFAR_Regulatory_Document_Tracking_gne__c> existingTrialTrackingActivities = [SELECT Id, CFAR_Trial_gne__c, frm_Regulatory_Tracking_Activity_gne__c FROM CFAR_Regulatory_Document_Tracking_gne__c WHERE CFAR_Trial_gne__c IN :trials];
        Map<String, Id> trialToRdtsMap = new Map<String, Id>();
        for(CFAR_Regulatory_Document_Tracking_gne__c rdt : existingTrialTrackingActivities){
            trialToRdtsMap.put(rdt.frm_Regulatory_Tracking_Activity_gne__c, rdt.CFAR_Trial_gne__c);
        }

        Map<Id, List<String>> trialExistingRdtsMap = new Map<Id, List<String>>();
        for(CFAR_Trial_gne__c trial : trials){
            List<String> trialActivities = new List<String>();
            for(CFAR_Regulatory_Document_Tracking_gne__c existingTrialTrackingActivity : existingTrialTrackingActivities){
                if(existingTrialTrackingActivity.CFAR_Trial_gne__c == trial.Id){
                    trialActivities.add(existingTrialTrackingActivity.frm_Regulatory_Tracking_Activity_gne__c);
                }
            }
            trialExistingRdtsMap.put(trial.Id, trialActivities);
        }
        
        Set<String> initialTrackingActivitiesSet = new Set<String>{'Study Introduction Packet Sent', 'Protocol Approval Letter Sent', 
        'CV (Curriculum Vitae)', 'ML (Medical License)', 'IB Signature Page', 'clinicaltrials.gov', 'CTV Confirmation Email', 
        'CTV Safety Letter signed', 'Study Activation Letter', 'Final Enrollment Log', 'Final Drug Accountability Log', 
        'Final CTV Confirmation', 'Study Closure Letter Sent' ,'Study Closure Letter PI signed & returned'};
        Set<String> IRBActivitiesSet = new Set<String>{'IRB Approval Letter for Original Protocol', 'IRB Approved Protocol', 'IRB Closure Letter Received'};
        Set<String> INDActivitiesSet = new Set<String>{'Cross Reference Letter', '1571', 'FDA response to IND Submission (copy)', 'FDA Notification of Closure'};
        Set<String> FSRActivitiesSet = new Set<String>{'Final Study Report Received'};
        Set<String> CapAssessActivitiesSet = new Set<String>{'Capability Assessment Form Completed'};

        Map<String, Id> activitiesIdsMap = new Map<String, Id>();
        for(CFAR_Tracking_Activity_gne__c trackAct : [SELECT Name FROM CFAR_Tracking_Activity_gne__c WHERE Active_gne__c = true]){
            if(initialTrackingActivitiesSet.contains(trackAct.Name) || IRBActivitiesSet.contains(trackAct.Name) || INDActivitiesSet.contains(trackAct.Name) || FSRActivitiesSet.contains(trackAct.Name) || CapAssessActivitiesSet.contains(trackAct.Name)){
                activitiesIdsMap.put(trackAct.Name, trackAct.Id);
            }
        }
        List<CFAR_Team_Member_gne__c> teamMembers = [SELECT CFAR_Trial_ref_gne__c,Id FROM CFAR_Team_Member_gne__c WHERE CFAR_Trial_ref_gne__c IN :trials AND Function_Role_gne__c= 'PI = Primary (or Principal) Investigator'];
        Map<Id, Id> teamMembersToTrialIdsMap = new Map<Id, Id>();
        for (CFAR_Team_Member_gne__c tm : teamMembers) {
            teamMembersToTrialIdsMap.put(tm.CFAR_Trial_ref_gne__c, tm.Id);
        }
        
        for (CFAR_Trial_gne__c trial : trials) {
            if(trial.frm_Trial_Status_ref_gne__c != 'Concluded') {
                for (String initialTrackingActivity : initialTrackingActivitiesSet){
                    if(!trialExistingRdtsMap.get(trial.Id).contains(initialTrackingActivity) && activitiesIdsMap.get(initialTrackingActivity) != null){                  
                        newTrialTrackingActivities.add(new CFAR_Regulatory_Document_Tracking_gne__c(CFAR_Trial_gne__c = trial.id, Regulatory_Tracking_Activity_gne__c = activitiesIdsMap.get(initialTrackingActivity), Reg_Doc_Investigator_gne__c = teamMembersToTrialIdsMap.get(trial.Id)));
                    }
                }
                for (String indTrackingActivity : INDActivitiesSet) {
                    if(trial.IND_Required_gne__c == 'YES' && trialExistingRdtsMap != null && !trialExistingRdtsMap.get(trial.Id).contains(indTrackingActivity) && activitiesIdsMap.get(indTrackingActivity) != null){
                        newTrialTrackingActivities.add(new CFAR_Regulatory_Document_Tracking_gne__c(CFAR_Trial_gne__c = trial.id, Regulatory_Tracking_Activity_gne__c = activitiesIdsMap.get(indTrackingActivity), Reg_Doc_Investigator_gne__c = teamMembersToTrialIdsMap.get(trial.Id)));
                    }
                }
                for (String irbTrackingActivity : IRBActivitiesSet) {
                    if(trial.IRB_Required_gne__c == 'YES' && trialExistingRdtsMap!= null && !trialExistingRdtsMap.get(trial.Id).contains(irbTrackingActivity) && activitiesIdsMap.get(irbTrackingActivity) != null){
                        newTrialTrackingActivities.add(new CFAR_Regulatory_Document_Tracking_gne__c(CFAR_Trial_gne__c = trial.id, Regulatory_Tracking_Activity_gne__c = activitiesIdsMap.get(irbTrackingActivity), Reg_Doc_Investigator_gne__c = teamMembersToTrialIdsMap.get(trial.Id)));
                    }
                }
                for (String fsrTrackingActivity : FSRActivitiesSet) {
                    if(trial.FSR_Required_gne__c == 'YES' && trialExistingRdtsMap!= null && !trialExistingRdtsMap.get(trial.Id).contains(fsrTrackingActivity) && activitiesIdsMap.get(fsrTrackingActivity) != null){
                        newTrialTrackingActivities.add(new CFAR_Regulatory_Document_Tracking_gne__c(CFAR_Trial_gne__c = trial.id, Regulatory_Tracking_Activity_gne__c = activitiesIdsMap.get(fsrTrackingActivity), Reg_Doc_Investigator_gne__c = teamMembersToTrialIdsMap.get(trial.Id)));
                    }
                }
                for (String capAssessTrackingActivity : CapAssessActivitiesSet) {
                    if(trial.Capability_Assessment_Required__c == 'YES' && trialExistingRdtsMap!= null && !trialExistingRdtsMap.get(trial.Id).contains(capAssessTrackingActivity) && activitiesIdsMap.get(capAssessTrackingActivity) != null){
                        newTrialTrackingActivities.add(new CFAR_Regulatory_Document_Tracking_gne__c(CFAR_Trial_gne__c = trial.id, Regulatory_Tracking_Activity_gne__c = activitiesIdsMap.get(capAssessTrackingActivity), Reg_Doc_Investigator_gne__c = teamMembersToTrialIdsMap.get(trial.Id)));
                    }
                }
            }
        }
        CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String> {'CFAR_TrialTrigger'});
        insert newTrialTrackingActivities;
        CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String>());
        

    }
    global void finish(Database.BatchableContext context) {
        
    }
}