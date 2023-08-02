public with sharing class GNE_VDST_AttendeeSfdcIdSynch implements Database.Batchable<SObject>, Database.Stateful {

    private static final String MERGE_OBJECT = 'Person Account';
    private static final String MERGE_STATUS = 'Processed';
    private Date startDate;
    public String vIds;

    public GNE_VDST_AttendeeSfdcIdSynch(Date startDate) {
        this.startDate = startDate;
        this.vIds = '';
    }

    public void execute(Database.BatchableContext param1, List<SObject> param2) {
        Map<Id, Id> looserToWinnerId = new Map<Id, Id>();
        List<CORE_Merge_Candidate__c> mergeCandidates = (List<CORE_Merge_Candidate__c>) param2;
        for (CORE_Merge_Candidate__c mergeCandidate : mergeCandidates) {
            looserToWinnerId.put(mergeCandidate.Id_gne__c, mergeCandidate.Master_Id_gne__c);
        }
        List<VDST_EventPrtcpntAccnt_gne__c> attendeesToUpdate = [
                SELECT Id, GNE_SFDC_ID_gne__c
                FROM VDST_EventPrtcpntAccnt_gne__c
                WHERE GNE_SFDC_ID_gne__c IN :looserToWinnerId.keySet()
                AND GNE_SFDC_ID_gne__c != :looserToWinnerId.values()
                AND GNE_SFDC_ID_gne__c != NULL
        ];
        for (VDST_EventPrtcpntAccnt_gne__c attendee : attendeesToUpdate) {
            vIds += attendee.Id + '; sfdcId old: ' + attendee.GNE_SFDC_ID_gne__c + '; new: ' + looserToWinnerId.get(attendee.GNE_SFDC_ID_gne__c) + '\n';
            attendee.GNE_SFDC_ID_gne__c = looserToWinnerId.get(attendee.GNE_SFDC_ID_gne__c);
        }
        System.debug(attendeesToUpdate);
        update attendeesToUpdate;
    }

    public void finish(Database.BatchableContext param1) {
        System.debug('Result:\n' + vIds);
    }

    public Iterable<SObject> start(Database.BatchableContext param1) {
        return [
                SELECT Id_gne__c, Master_Id_gne__c
                FROM CORE_Merge_Candidate__c
                WHERE Object_Name_calc_gne__c = :MERGE_OBJECT AND Status_gne__c = :MERGE_STATUS AND Error_Codes_gne__c = NULL
                AND Processed_Date_gne__c >= :startDate
                ORDER BY CreatedDate DESC
        ];
    }
}