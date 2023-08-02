/************************************************************
*  @author: Kishore Chandolu
*  Date: 2013-01-31
*  Description: This is a controller class for GNE_SFA2_SBMembership_Layout page.
*   
*  Modification History
*  Date         Name          Description
*  2015-06-24   Wac�aw Smaga  Adding classification history popup
*************************************************************/
public without sharing class GNE_SFA2_SBureau_Membership_Controller extends GNE_SFA2_DynamicVFLoader {   
    public List<Survey_Response_gne__c> surveyResponses {get;set;}
    public Boolean surveyFound {get;set;}

    private Map<String, Set<String>> possibleStatusChanges;
    public Speaker_Bureau_Membership_gne__c sbmRecord {get;set;}
    public String classification { get; set; }
    public Date classificationDate { get; set; }


    public GNE_SFA2_SBureau_Membership_Controller(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_SBMembership_Layout');
        Boolean isException = false;
        surveyFound = false;
        try{
            Id surveyId = [SELECT Survey_gne__c FROM Speaker_Bureau_Membership_gne__c WHERE Id = :myObject.Id LIMIT 1].Survey_gne__c;
            surveyResponses = [SELECT Full_Title_gne__c, Selected_Label_gne__c FROM Survey_Response_gne__c WHERE Survey_gne__c = :surveyId ORDER BY Position_gne__c];
            surveyFound = surveyResponses.size() > 0;
        } catch(Exception ex){
            isException = true;
        }

        Speaker_Bureau_Membership_gne__c sbm = [SELECT
                                                    Bureau_Member_gne__c,
                                                    Speaker_Category_gne__c,
                                                    Speaker_Bureau_ID_gne__c,
                                                    EDM_Bureau_Type_gne__c,
                                                    Bureau_Member_gne__r.EDM_Business_Classification_gne__c,
                                                    Bureau_Member_gne__r.EDM_Business_Classification_Date_gne__c,
                                                    Bureau_Member_gne__r.EDM_Clinical_Classification_gne__c,
                                                    Bureau_Member_gne__r.EDM_Clinical_Classification_Date_gne__c
                                                FROM
                                                    Speaker_Bureau_Membership_gne__c
                                                WHERE
                                                    Id = :myObject.Id
                                                LIMIT 1];

        if(!surveyFound || isException){
            try{
                Id surveyId = [SELECT Id FROM Survey_gne__c WHERE Account__c =: sbm.Bureau_Member_gne__c
                                                                    AND Speaker_Nomination_Category_gne__c =: sbm.Speaker_Category_gne__c
                                                                    AND Questionnaire_gne__r.Ready_for_use_gne__c = FALSE
                                                                    AND Speaker_Bureau_gne__c =: sbm.Speaker_Bureau_ID_gne__c].Id;
                                                                    
                surveyResponses = [SELECT Full_Title_gne__c, Selected_Label_gne__c FROM Survey_Response_gne__c WHERE Survey_gne__c = :surveyId ORDER BY Position_gne__c];
            } catch(Exception exc){
                surveyResponses = new List<Survey_Response_gne__c>();
            }
        }
        surveyFound = surveyResponses.size() > 0;
        SBMHistory = getSBMHistoryForMembership();
        sbmRecord = [SELECT Id, Speaker_Status_gne__c FROM Speaker_Bureau_Membership_gne__c WHERE Id = :myObject.Id LIMIT 1];

        if (String.isNotBlank(sbm.Bureau_Member_gne__c)) {
            switch on sbm.EDM_Bureau_Type_gne__c {
                when 'Business' {
                    classification = sbm.Bureau_Member_gne__r.EDM_Business_Classification_gne__c;
                    classificationDate = sbm.Bureau_Member_gne__r.EDM_Business_Classification_Date_gne__c;
                }
                when 'Clinical' {
                    classification = sbm.Bureau_Member_gne__r.EDM_Clinical_Classification_gne__c;
                    classificationDate = sbm.Bureau_Member_gne__r.EDM_Clinical_Classification_Date_gne__c;
                }
            }
        }
        
        possibleStatusChanges = new Map<String, Set<String>>();
        possibleStatusChanges.put('', new Set<String>{'Pending', 'Rejected', 'Nominated'});
        possibleStatusChanges.put('Nominated', new Set<String>{'Approved', 'Removed', 'Excluded'});
        possibleStatusChanges.put('Approved', new Set<String>{'Removed', 'Excluded'});
        possibleStatusChanges.put('Removed', new Set<String>{'Approved', 'Excluded'});
        possibleStatusChanges.put('Excluded', new Set<String>{'Approved', 'Removed', 'Nominated'});
        possibleStatusChanges.put('Rejected', new Set<String>{'Nominated', 'Pending', 'Excluded'});
        possibleStatusChanges.put('Pending', new Set<String>{'Nominated', 'Excluded'});

    }
    
    public PageReference edit(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_SBMembership_Edit_Create_Layout?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }

    private PageReference newSurveyClick(){
        PageReference pageref = new PageReference('/apex/GNE_SFA2_Create_Survey_Layout?objectId='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }
    
    //relatedList Custom Buttons     
    public override PageReference callMethod(String methodName){ 
        if('newSurveyClick'.compareTo(methodName) == 0){
            return newSurveyClick(); 
        }
        return super.callMethod(methodName);      
    }

    public Boolean getCanChangeStatus(){
        Set<String> availableConfigs = new Set<String>{ 'TLCRM_AB-SB-Admin', 'TLCRM_SpeakerBureauLead' };
        GNE_SFA2_User_App_Context_gne__c userApplicationContext = GNE_SFA2_Util.getUserApplicationContext();
        String userMapping = userApplicationContext.App_Name_gne__c + '_' + userApplicationContext.Role_gne__c;
        return availableConfigs.contains(userMapping);
    }

    public Boolean getCanApprove(){
        Set<String> possibleChanges = possibleStatusChanges.get(sbmRecord.Speaker_Status_gne__c);
        if(possibleChanges != null){
            return possibleChanges.contains('Approved');
        }
        return false;
    }
    
    public Boolean getCanRemove(){
        Set<String> possibleChanges = possibleStatusChanges.get(sbmRecord.Speaker_Status_gne__c);
        if(possibleChanges != null){
            return possibleChanges.contains('Removed');
        }
        return false;
    }

    public PageReference approve(){
        sbmRecord.Speaker_Status_gne__c = 'Approved';
        update sbmRecord;
        return null;
    }
    
    public PageReference remove(){
        sbmRecord.Speaker_Status_gne__c = 'Removed';
        update sbmRecord;
        return null;
    }

    
    //SBM History popup
    public List<HistoryWrapper> SBMHistory { get; set; }
    public class HistoryWrapper {
        public String SpeakerClassification { get; private set; }
        public String HDate { get; private set; }
        public String HTime { get; private set; }
        public String CVLink { get; private set; }
        public HistoryWrapper(EDM_SBM_Classification_History_gne__c historyObject) {
            String formatedDT = historyObject.CreatedDate.format('MM/dd/yyyy hh:mm:ss a');
            this.SpeakerClassification = historyObject.EDM_Classification_Type_gne__c + ' - ' + historyObject.EDM_Classification_Scope__c;
            this.HDate = formatedDT.split(' ')[0];
            this.HTime = formatedDT.split(' ')[1] + ' ' + formatedDT.split(' ')[2];
            this.CVLink = historyObject.EDM_Download_CV_gne__c;
        }
    }

    private List<HistoryWrapper> getSBMHistoryForMembership() {
        List<HistoryWrapper> result = new List<HistoryWrapper>();
        List<EDM_SBM_Classification_History_gne__c> clHistory = 
                [SELECT 
                    EDM_Classification_Type_gne__c, 
                    EDM_Classification_Scope__c,
                    CreatedDate, 
                    EDM_Download_CV_gne__c, 
                    EDM_Speaker_Bureau_Membership_gne__c
                FROM EDM_SBM_Classification_History_gne__c 
                WHERE EDM_Speaker_Bureau_Membership_gne__c = :myObject.Id
                ORDER BY CreatedDate DESC];

        for (EDM_SBM_Classification_History_gne__c ch : clHistory) {
            result.add(new HistoryWrapper(ch));
        }
        return result;
    }
}