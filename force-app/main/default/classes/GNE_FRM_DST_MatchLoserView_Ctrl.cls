/************************************************************
*  @author: Jaroslaw Laniecki, Billennium
*  Date: 2016-11-22
*  Description: This is a controller class for GNE_FRM_DST_MatchLoserView vfp.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/

public with sharing class GNE_FRM_DST_MatchLoserView_Ctrl {
    public DST_Match_Loser__c loser;
    private Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    private Schema.SObjectType leadSchema = schemaMap.get('DST_Match_Loser__c');
    private Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
    public Boolean isEditMode {get; private set;}
    public Boolean isReasonVisible {get;set;} 
    public Boolean disableButton {get;set;} 
    private ApexPages.StandardController stdController;
    private String tempStatus;
    private Id tempRequestAnalyst;
    private String editParam;
    public String viewParam {get;private set;}
    public string potentialCandidates {get;set;}
    
    public GNE_FRM_DST_MatchLoserView_Ctrl (ApexPages.StandardController stdController){
        this.stdController = stdController; 
        loser = (DST_Match_Loser__c)stdController.getRecord();
        tempStatus = loser.Mdm_Bundle_Status__c; 
        tempRequestAnalyst = loser.Request_Analyst_gne__c;
        initParams();
        potentialCandidates = getPotentialCandidates();
    }
    
    private void initParams(){
        disableButton = true;
        isEditMode = false;
        
        if(getEditVisible()){
            editParam = System.currentPageReference().getParameters().get('editMode');
            isEditMode = String.isEmpty(editParam) ? false : editParam == 'true' ? true : false;            
        }
        
        if(isEditMode && loser.Request_Analyst_gne__c == null){
            loser.Request_Analyst_gne__c = UserInfo.getUserId();
        }     
        isReasonVisible = loser == null ? false : loser.Mdm_Bundle_Status__c.equals(DST_Match_Loser_Helper.MDM_BUNDLE_STATUS_REJECTED);
        viewParam = System.currentPageReference().getParameters().get('viewParam');
    }

    public void editBundle(){
        isEditMode = true;  
        if(loser.Request_Analyst_gne__c == null){
            loser.Request_Analyst_gne__c = UserInfo.getUserId();
        }
    }
    
    public Boolean getEditVisible(){
        return isCorrectStatus(tempStatus);
    }
    
    public Boolean getExceptionVisible(){
        return loser == null ? false : loser.Mdm_Bundle_Status__c.equals(DST_Match_Loser_Helper.MDM_BUNDLE_STATUS_EXCEPTION);
    }
    
    public PageReference changeStatus(){
        isReasonVisible = loser == null ? false : loser.Mdm_Bundle_Status__c.equals(DST_Match_Loser_Helper.MDM_BUNDLE_STATUS_REJECTED);
        return null;
    }
    
    public PageReference enableButtons(){
        disableButton = false;
        return null;
    }
    
    public void cancelAction(){
        isEditMode = false; 
        loser.Mdm_Bundle_Status__c = tempStatus;
        loser.Request_Analyst_gne__c = tempRequestAnalyst;
        changeStatus();
    }
    
    public void saveBundle(){
        isEditMode = false;
        try {
            stdController.save();
        } catch (Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Problem during save record to DataBase: '+ex.getMessage()));
            isEditMode = true;
            loser.Mdm_Bundle_Status__c = tempStatus;
        }
        if(ApexPages.hasMessages()){
            isEditMode = true;
            loser.Mdm_Bundle_Status__c = tempStatus;
        } else{
            tempStatus = loser.Mdm_Bundle_Status__c;
            tempRequestAnalyst = loser.Request_Analyst_gne__c;
        }
        changeStatus();
    }
    
    public list<GNE_SFA2_List_View_Util.History> getHistories() {
        DST_Match_Loser__History [] history = [
            SELECT ParentId, OldValue, NewValue, IsDeleted, Id, Field, CreatedDate, CreatedById, CreatedBy.Name
            FROM DST_Match_Loser__History
            WHERE ParentId =: loser.Id
            ORDER BY CreatedDate DESC
        ];
        return GNE_SFA2_List_View_Util.getHistories(history, 'DST_Match_Loser__c');
    }
    
    private String getPotentialCandidates(){
        String results = '';
        Set<Id> ids = new Set<Id>();

        DST_Match_Loser__c[] lo = [
            SELECT (SELECT Id FROM  Potential_Winner_Candidates__r)
            FROM DST_Match_Loser__c
            WHERE Id =: loser.Id
        ];
        if(lo.isEmpty()) return null;    
        for(DST_Match_Winner__c win: lo[0].Potential_Winner_Candidates__r){
            ids.add(win.Id );
        }
        Boolean isFirst = true;
        for(Id i : ids){
            if(isFirst){
                isFirst = false;
                results += '\''+i+'\'';
            } else {
                results += ',\''+i+'\'';
            }            
        }

        return String.isEmpty(results) ? 'ID IN (\'\')' : 'ID IN ('+results+')';
    }
    
    private static Boolean isCorrectStatus(String status) {
        return new Set<String>{
            DST_Match_Loser_Helper.MDM_BUNDLE_STATUS_NEW,
            DST_Match_Loser_Helper.MDM_BUNDLE_STATUS_EXCEPTION,
            DST_Match_Loser_Helper.MDM_BUNDLE_STATUS_INPROGRESS
        }.contains(status);
    }
    
    public List<SelectOption> getAvailableDataStewards() {
        List<SelectOption> result = new List<SelectOption>();
        result.add(new SelectOption('', ''));
        result.addAll(GNE_SFA2_Util.getAvailableFrmDataStewards());
    	return result;
    }
}