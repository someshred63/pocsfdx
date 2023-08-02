/************************************************************
*  @author: Kishore Chandolu
*  Date: 2013-01-31
*  Description: This is a controller class for GNE_SFA2_SBureau_Membership page.
*   
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_SBureau_Membership_Ctrl extends GNE_SFA2_List_View_Base_Controller{
    
    public GNE_SFA2_List_View_Base_Controller thisController { get; set; }
    public String bureauId{get;set;}
    Map<String,String> sbmIds;
    public String retParentInfo{get;set;}
    public String exclusionStatus{get;set;}
    public Boolean hasBureauId {
        get {
            return bureauId != null;
        }
    }
    public String additionalConditionForViews {
        get {
            return bureauId != null ? 'Speaker_Bureau_ID_gne__c = \'' + bureauId + '\'' : '';
        }
    }
    private Speaker_Bureau_gne__c bureau;
    public String bureauName {
        get {
            return bureau.name;
        }
    }
    public String nextYearBureau {
        get {
            List<Speaker_Bureau_gne__c> nybureau = new List<Speaker_Bureau_gne__c>([select Id from Speaker_Bureau_gne__c where Last_Year_Speaker_Bureau_gne__c=:bureauId]);
            if(!nybureau.isEmpty()){
                return nybureau[0].Id;
            } else {
                return '';
            }
        }
    }
    public Boolean areValid{get;set;}
    public String selected{get;set;}
    Map<ID,Speaker_Bureau_Membership_gne__c> membersBaseMap{get;set;}
    private EDM_Multiple_Nomination_Wrapper__c nominationWrapper{get;set;}
    public String wrapperId{get;set;}

    public Boolean classificationValid { get; set; }
    public Boolean areTheSameType { get; set; }
    public Boolean enoughMembersLeft { get; set; }
    public Boolean typeIsNULL { get; private set; }
    public Boolean skipClassificationAndExclusion { get; set; }

    public String predefinedListOfColumnsForListView { get; private set; }

    public PageReference newClick() {
        return null;
    }
    
    public GNE_SFA2_SBureau_Membership_Ctrl() {
        super('Speaker_Bureau_Membership_gne__c');
        nominationWrapper = new EDM_Multiple_Nomination_Wrapper__c();
        thisController = this;
        bureauId = ApexPages.currentPage().getParameters().get('br_id');
        if (hasBureauId) {
            bureau = [select Id, Name, Account_gne__c, Approved_Speakers_gne__c, Aprimo_Bureau_ID_gne__c, Aprimo_ID_gne__c, Brands_gne__c, Contracted_Speakers_gne__c, CreatedById, 
                  CreatedDate, Inactive_Speakers_gne__c, IsDeleted, IsLocked, Last_Year_Speaker_Bureau_gne__c, LastModifiedById, LastModifiedDate, MayEdit, 
                  Nominated_Speakers_gne__c, OwnerId, Region_Code_gne__c, Rejected_Speakers_gne__c, Removed_Speakers_gne__c, Speaker_Bureau_ID_gne__c, 
                  Speaker_Bureau_Lead_gne__c, Speaker_Bureau_Type_gne__c, Speaker_Bureau_Year_gne__c, Speaker_Category_gne__c, SystemModstamp, Therapeutic_Areas_gne__c, 
                  Total_of_Canceled_Programs_gne__c, Total_of_Closed_Programs_gne__c, Total_of_Completed_Programs_gne__c, Total_of_Confirmed_Programs_gne__c, 
                  Total_of_Dropped_Programs_gne__c, Total_of_Speaker_Programs_gne__c, Total_of_Speakers_gne__c, Total_On_Hold_Programs_gne__c, Total_Pending_Programs__c, 
                  Vendor_ID_gne__c from Speaker_Bureau_gne__c where id=:bureauId];

            typeIsNULL = bureau.Speaker_Bureau_Type_gne__c == null;
        }

        predefinedListOfColumnsForListView = '';
        if (GNE_SFA2_Util.isTLSUser())
            predefinedListOfColumnsForListView = 'Name,Bureau_Member_gne__c,Bureau_Member_Professional_Type__c,Speaker_Status_gne__c,Speaker_Scope_Formula_gne__c,Completed_Programs_gne__c,Upcoming_Programs_gne__c,Total_Programs_gne__c';

        Map<String,String> paramsMap = new Map<String,String>(ApexPages.currentPage().getParameters());
        String wrapperId = ApexPages.currentPage().getParameters().get('wrapperId');
        if(wrapperId!=null && wrapperId!=''){
            nominationWrapper = [Select id,EDM_Multiple_Nomination_Ids__c,EDM_Multiple_Nomination_Start_Ids__c from EDM_Multiple_Nomination_Wrapper__c where id = :wrapperId];           
            if(nominationWrapper.EDM_Multiple_Nomination_Start_Ids__c != null)
                selected = nominationWrapper.EDM_Multiple_Nomination_Start_Ids__c;
            else   
                selected = nominationWrapper.EDM_Multiple_Nomination_Ids__c;
        }
        retParentInfo='&parentRecordType='+ApexPages.currentPage().getParameters().get('parentRecordType');
        enoughMembersLeft = true;
    } 
    
    private Boolean excludedAccountExists(){
        System.debug('#Selected: ' + selected);
        List<String> ids = selected.split(';');
    	List<Speaker_Bureau_Membership_gne__c> al = new List<Speaker_Bureau_Membership_gne__c>(
            [SELECT Id, 
                Bureau_Member_gne__r.Professional_Type_gne__c,
                Bureau_Member_gne__r.AGS_EX_Exclusion_Status_base_gne__c 
            FROM 
                Speaker_Bureau_Membership_gne__c 
            WHERE 
                Id IN :ids AND
                Bureau_Member_gne__r.Professional_Type_gne__c != 'Patient Ambassador' AND
                Bureau_Member_gne__r.AGS_EX_Exclusion_Status_base_gne__c = 'Excluded']);

        System.debug('#ALSIZE: ' + al.size() + ' ' + al);
    	if (al.isEmpty())
            return false;
        return true;
    }

    private Boolean sbmOfDifferentTypeSelected() {
        List<String> ids = selected.split(';');
        Set<String> types = new Set<String>();

        for (Speaker_Bureau_Membership_gne__c sbm : [SELECT Id, 
                                                        Bureau_Member_gne__r.Professional_Type_gne__c
                                                    FROM 
                                                        Speaker_Bureau_Membership_gne__c 
                                                    WHERE 
                                                        Id IN :ids]) {
            String temp = sbm.Bureau_Member_gne__r.Professional_Type_gne__c;
            if (String.isNotBlank(temp))
                types.add(temp);

        }
        if (types.size() > 1 && types.contains('Patient Ambassador'))
            return true;
        else
            return false;
    }

    private Boolean notClassifiedAccountExists() {
        System.debug('#Selected: ' + selected);
        List<String> ids = selected.split(';');
        List<Speaker_Bureau_Membership_gne__c> al = new List<Speaker_Bureau_Membership_gne__c>();

        if (bureau.Speaker_Bureau_Type_gne__c == 'Clinical') {
            al = [SELECT Id, 
                    Bureau_Member_gne__r.Professional_Type_gne__c,
                    Bureau_Member_gne__r.EDM_Clinical_Classification_gne__c
                  FROM 
                    Speaker_Bureau_Membership_gne__c 
                  WHERE 
                    Id IN :ids AND
                    Bureau_Member_gne__r.Professional_Type_gne__c != 'Patient Ambassador' AND
                    Bureau_Member_gne__r.EDM_Clinical_Classification_gne__c = 'Not Classified'];
        } else if (bureau.Speaker_Bureau_Type_gne__c == 'Business') {
            al = [SELECT Id,  
                    Bureau_Member_gne__r.Professional_Type_gne__c,
                    Bureau_Member_gne__r.EDM_Business_Classification_gne__c
                  FROM 
                    Speaker_Bureau_Membership_gne__c 
                  WHERE 
                    Id IN :ids AND
                    Bureau_Member_gne__r.Professional_Type_gne__c != 'Patient Ambassador' AND
                    Bureau_Member_gne__r.EDM_Business_Classification_gne__c = 'Not Classified'];
        }
         
        System.debug('#ALSIZE: ' + al.size() + ' ' + al);
        if (al.isEmpty())
            return false;
        return true;
    }

    private Map<Id, Account> getSelectedBureauMembers() {
        List<Account> sbMembers = [SELECT Id FROM Account WHERE Id IN (SELECT Bureau_Member_gne__c FROM Speaker_Bureau_Membership_gne__c WHERE Speaker_Bureau_ID_gne__c = :nextYearBureau)];
        return new Map<Id, Account>(sbMembers);
    }

    private Enum TypeOfNomination {Other, NextYear}

    public void setValidationVariablesForOther() {
        setValidationVariables(TypeOfNomination.Other);
    }

    public void setValidationVariablesForNextYear() {
        setValidationVariables(TypeOfNomination.NextYear);
    }

    private void setValidationVariables(TypeOfNomination typeOfNominat) {

    	areValid = !excludedAccountExists();
        classificationValid = !notClassifiedAccountExists();
        areTheSameType = !sbmOfDifferentTypeSelected();

        system.debug(areValid + '$$' + classificationValid);
        if (areValid && classificationValid && areTheSameType) {

            nominationWrapper.EDM_Multiple_Nomination_Ids__c=selected;
            nominationWrapper.EDM_Multiple_Nomination_Start_Ids__c = selected;

            List<String> sbmIds=selected.split(';');

            List<Speaker_Bureau_Membership_gne__c> sbmList = new List<Speaker_Bureau_Membership_gne__c>(
                    [SELECT Bureau_Member_gne__c, Bureau_Member_gne__r.Professional_Type_gne__c
                     FROM Speaker_Bureau_Membership_gne__c
                     WHERE Id IN :sbmIds]);

            Set<String> allAccounts = new Set<String>();
            skipClassificationAndExclusion = false;
            for (Speaker_Bureau_Membership_gne__c sbm : sbmList) {
                allAccounts.add(sbm.Bureau_Member_gne__c);
                if (sbm.Bureau_Member_gne__r.Professional_Type_gne__c == 'Patient Ambassador')
                    skipClassificationAndExclusion = true;
            }
            System.debug('$$ 1 allAccounts: ' + allAccounts);

            if (typeOfNominat == TypeOfNomination.NextYear) {
                //check if any of selected accounts are members of target bureau
                Set<Id> accIds = getSelectedBureauMembers().keySet();
                for (String accId : allAccounts) {
                    if (accIds.contains(accId)) {
                        //remove from EDM_Multiple_Nomination_Ids__c
                        allAccounts.remove(accId);
                    }
                }
                System.debug('$$ 2 allAccounts: ' + allAccounts);
            }

            Map<Id, Speaker_Bureau_Membership_gne__c> tmpMap = new Map<Id, Speaker_Bureau_Membership_gne__c>();
            
            for (Speaker_Bureau_Membership_gne__c sbm : sbmList) {
                if (allAccounts.contains(sbm.Bureau_Member_gne__c)) {
                    tmpMap.put(sbm.Id, sbm);
                }
            }

            nominationWrapper.EDM_Multiple_Nomination_Ids__c = String.join(new List<Id>(tmpMap.keySet()), ';');
            System.debug('EDM_Multiple_Nomination_Ids__c: ' + nominationWrapper.EDM_Multiple_Nomination_Ids__c);            
            if (tmpMap.size() >= 2) {
                enoughMembersLeft = true;
                upsert nominationWrapper;
                wrapperId = nominationWrapper.id;
                List<Account> accountsWithExcusionToBeCompleted = 
                        [SELECT Id, AGS_EX_Exclusion_Status_base_gne__c
                         FROM Account 
                         WHERE id in :allAccounts and 
                            AGS_EX_Exclusion_Status_base_gne__c in ('Not checked', 'Check pending', 'In Process')];
                Set<String> accountExclusionStatuses = new Set<String>();
                for (Account accountExNotCompleted : accountsWithExcusionToBeCompleted) {
                    accountExclusionStatuses.add(accountExNotCompleted.AGS_EX_Exclusion_Status_base_gne__c);
                }
                if (!accountsWithExcusionToBeCompleted.isEmpty() && accountExclusionStatuses.contains('Not checked')) {
                    exclusionStatus = 'To Be Completed';                    
                }
                else if (!accountsWithExcusionToBeCompleted.isEmpty()) {
                    exclusionStatus = 'Request Submitted';
                } 
                else {
                    exclusionStatus = 'Done';
                }
            }
            else if (tmpMap.size() == 1) {
                enoughMembersLeft = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'All but one of the selected accounts are already members of target bureau. To nominate an individual speaker please start from the speaker�s account detail page.'));
            }
            else {
                enoughMembersLeft = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'All of the selected accounts are already members of target bureau.'));
            }

            
        }
    }

    public String getSBMIDs(){
        String s = '';
        Integer i = 0;
        System.debug('##SBMID: '+sbmIds);
        if(sbmIds!=null && !sbmIds.isEmpty()){
            for(String sbm : sbmIds.keySet()){
                if(i>0) s+=';';
                s+=sbmIds.get(sbm);
                i++;
            }
        }
        return s;
    }

    public void checkValidationForApprove(){
        system.debug('#Selected: '+selected);
        List<String> ids = selected.split(';');
        List<Speaker_Bureau_Membership_gne__c> sbms = [SELECT id, Speaker_Status_gne__c FROM Speaker_Bureau_Membership_gne__c 
                                              WHERE Id IN :ids AND Speaker_Status_gne__c IN ('Nominated', 'Removed')];
        areValid = sbms.size() == ids.size();
        if(areValid){
            for(Speaker_Bureau_Membership_gne__c sbm :sbms){
                sbm.Speaker_Status_gne__c = 'Approved';
            }
            update sbms;
        }
    }

    public void checkValidationForRemove(){
        system.debug('#Selected: '+selected);
        List<String> ids = selected.split(';');
        List<Speaker_Bureau_Membership_gne__c> sbms = [SELECT id, Speaker_Status_gne__c FROM Speaker_Bureau_Membership_gne__c 
                                              WHERE Id IN :ids AND Speaker_Status_gne__c IN ('Nominated', 'Approved')];
        areValid = sbms.size() == ids.size();
        if(areValid){
            for(Speaker_Bureau_Membership_gne__c sbm :sbms){
                sbm.Speaker_Status_gne__c = 'Removed';
            }
            update sbms;
        }
    }
    
    public PageReference exportToExcel() {
        PageReference exportPR = new PageReference('/apex/GNE_SFA2_SBM_Export?br_id=' + bureauId);
        exportPR.setredirect(false);
        return exportPR;
    }
}