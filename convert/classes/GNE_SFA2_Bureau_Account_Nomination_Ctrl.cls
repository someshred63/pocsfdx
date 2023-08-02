public class GNE_SFA2_Bureau_Account_Nomination_Ctrl extends GNE_SFA2_List_View_Base_Controller{  

    private Id accountId;
    public String selectedYear {set; get;}
    public String selectedBureau {get; set;}
    public Account account{get;set;}
    public Boolean multiple{get;set;}
    public List<String> sbmids{get;set;}
    public String returnSBMIds{get;set;}
    public Boolean showPopupMessageOrError {get; private set;}
    private Boolean showConfirmationPopupAttr = false;
    private Boolean showErrorAttr = false;
    public Boolean existNotClassifiedAccounts{get;set;}
    public String exclusionStatus{get;set;}
    public String parentBureauType;
    String speakerBureauType;
    String wrapperId{get;set;}

    public Boolean skipClassificationAndExclusion { get; private set; }

    private Set<String> allAccounts;
    private String parentBureauID;
    private List<Speaker_Bureau_Membership_gne__c> sbmList;

    public GNE_SFA2_Bureau_Account_Nomination_Ctrl() {
        super('Speaker_Bureau_gne__c');
        showErrorAttr = false;
        try{
            multiple = Boolean.valueOf(ApexPages.currentPage().getParameters().get('multiple'));
        }catch(Exception e){
            System.debug('Single Nomination');
            multiple = false;
        }
        if(multiple){
            returnSBMIds = '';
            returnSBMIds += '=' + ApexPages.currentPage().getParameters().get('retBureau') + '&parentObjectName=Speaker_Bureau_gne__c&parentRecordType=' + ApexPages.currentPage().getParameters().get('parentRecordType');
            wrapperId = ApexPages.currentPage().getParameters().get('wrapperId');
            if(wrapperId != null && wrapperId != ''){
                returnSBMIds += '&wrapperId=' + wrapperId;
                sbmids = [SELECT EDM_Multiple_Nomination_Ids__c FROM EDM_Multiple_Nomination_Wrapper__c WHERE Id = :wrapperId].EDM_Multiple_Nomination_Ids__c.split(';');
            } else {
                sbmids = new List<String>();
            }
            sbmList = [SELECT Bureau_Member_gne__c, Bureau_Member_gne__r.Professional_Type_gne__c FROM Speaker_Bureau_Membership_gne__c WHERE Id IN :sbmIds];

            allAccounts = new Set<String>();
            for(Speaker_Bureau_Membership_gne__c sbm : sbmList){
                allAccounts.add(sbm.Bureau_Member_gne__c);
            }

            List<Account> accountsWithoutExcusion = new List<Account>(); 
            List<Account> accountsWithPendingExcusionOrInProcess = new List<Account>();
            skipClassificationAndExclusion = true;
            for (Account a : [SELECT Id, Professional_Type_gne__c, AGS_EX_Exclusion_Status_base_gne__c FROM Account WHERE Id IN :allAccounts]) {
                if (a.AGS_EX_Exclusion_Status_base_gne__c == 'Not checked')
                    accountsWithoutExcusion.add(a);
                else if (a.AGS_EX_Exclusion_Status_base_gne__c == 'Check pending' || a.AGS_EX_Exclusion_Status_base_gne__c == 'In Process')
                    accountsWithPendingExcusionOrInProcess.add(a);
                
                if (a.Professional_Type_gne__c != 'Patient Ambassador')
                    skipClassificationAndExclusion = false;
                
                // not checking if excluded, becauase it was chacked earlier in a process - on GNE_SFA2_SBMembership page
            }

            if(!accountsWithoutExcusion.isEmpty()){
                exclusionStatus = 'Not checked';
            } else if(!accountsWithPendingExcusionOrInProcess.isEmpty()) {
                exclusionStatus = 'Check pending';
            } else {
                exclusionStatus = 'Verified and clear';
            }
            try{
                parentBureauID = ApexPages.currentPage().getParameters().get('retBureau');
                parentBureauType = [SELECT Speaker_Bureau_Type_gne__c FROM Speaker_Bureau_Gne__c WHERE Id = :parentBureauID LIMIT 1].Speaker_Bureau_Type_gne__c;
            } catch (Exception ex){
                system.debug('No parent Bureau found: ' + ex);
            }
        }
        if(!multiple){
            accountId = ApexPages.currentPage().getParameters().get('id');
            account = [SELECT id, Name, AGS_EX_Exclusion_Status_base_gne__c, EDM_Clinical_Classification_gne__c, EDM_Business_Classification_gne__c, Professional_Type_gne__c FROM Account WHERE Id = :accountId];
        }
        showPopupMessageOrError = false;
    }

    public Boolean getIsNotCC() {
        return !GNE_SFA2_Util.isSfaCCUser();
    }

    public PageReference next() {                
        if(account != null && account.Professional_Type_gne__c == 'Patient Ambassador') {
            PageReference pRef = new PageReference('/apex/GNE_SFA2_SBMembership_Nominate_Layout?act_id=' + accountId + '&spb_id=' + selectedBureau + '&create_flag=1&retURL=/' + accountId);
            return pRef.setRedirect(true);
        }

        showPopupMessageOrError = true;
        showErrorAttr = true;
        showConfirmationPopupAttr = true;
        if (!String.isEmpty(selectedBureau)) {
            speakerBureauType = [select Speaker_Bureau_Type_gne__c from Speaker_Bureau_gne__c where id = :selectedBureau].Speaker_Bureau_Type_gne__c;
            showErrorAttr = false;
        }
        if(multiple){
            existNotClassifiedAccounts = checkIfExistsNotClassfiedAccount();
            Set<Id> accIds = getSelectedBureauMembers().keySet();
            for (String accId : allAccounts) {
                if (accIds.contains(accId)) {
                    //remove from EDM_Multiple_Nomination_Ids__c
                    allAccounts.remove(accId);
                }
            }
            EDM_Multiple_Nomination_Wrapper__c mnw = [SELECT EDM_Multiple_Nomination_Ids__c FROM EDM_Multiple_Nomination_Wrapper__c WHERE Id = :wrapperId];
            Map<Id, Speaker_Bureau_Membership_gne__c> tmpMap = new Map<Id, Speaker_Bureau_Membership_gne__c>();
            for (Speaker_Bureau_Membership_gne__c sbm : sbmList) {
                if (allAccounts.contains(sbm.Bureau_Member_gne__c)) {
                    tmpMap.put(sbm.Id, sbm);
                }
            }

            mnw.EDM_Multiple_Nomination_Ids__c = String.join(new List<Id>(tmpMap.keySet()), ';');
            System.debug('EDM_Multiple_Nomination_Ids__c: ' + mnw.EDM_Multiple_Nomination_Ids__c);            
            if (tmpMap.size() >= 2) {
                update mnw;
            }
            else if (tmpMap.size() == 1) {
                showPopupMessageOrError = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'All but one of the selected accounts are already members of target bureau. To nominate an individual speaker please start from the speaker’s account detail page.'));
            }
            else {
                showPopupMessageOrError = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'All of the selected accounts are already members of target bureau.'));
            }
        }
        return null;
    }

    public PageReference cancel() {
        if(!multiple){
            PageReference pRef = new PageReference('/' + accountId);
            return pRef.setRedirect(true);
        } else {
            PageReference pRef = new PageReference('/apex/GNE_SFA2_SBMembership?br_id' + returnSBMIds);
            return pRef.setRedirect(true);
        }
    }
    
    public List<SelectOption> getYear_Options() { 
        List<SelectOption> yearOptions = new List<SelectOption>();
        yearOptions.add(new SelectOption('', '--Select a Year--'));
        
        Integer currentYear = Date.Today().Year();
        List<Integer> years = new List<Integer> {currentYear, currentYear + 1};

        for (Integer year : years) {
            yearOptions.add(new SelectOption('' + year, '' + year));
        }

        return yearOptions;
    }
    
    //Creates and returns a list of selectOptions with bureaus in which the user is not already a member
    public List<SelectOption> getSpeaker_Bureau_Options() {
        List<SelectOption> bureauOptions =  new List<SelectOption>();
        bureauOptions.add(new SelectOption('', '--Select a Bureau--'));

        if (selectedYear != null) {
            system.debug('222:'+selectedYear);
            Set<ID> memberOf = new Set<ID>();
            List<Speaker_Bureau_gne__c> myBureaus = new List<Speaker_Bureau_gne__c>();
            if(!multiple){
                memberOf = getMembershipForAccountInSelectedYear();
                myBureaus = [SELECT Id, Name FROM Speaker_Bureau_gne__c 
                             WHERE Speaker_bureau_year_gne__c = :selectedYear 
                                AND Speaker_Bureau_Type_gne__c != null
                                AND Id NOT IN :memberOf ORDER BY Name];
            } else {
                memberOf = getMembershipForMultipleAccountInSelectedYear();
                //myBureaus = [SELECT Id, Name FROM Speaker_Bureau_gne__c WHERE Speaker_bureau_year_gne__c = :selectedYear 
                //            AND Id NOT IN :memberOf AND Speaker_Bureau_Type_gne__c = :parentBureauType ORDER BY Name];
                myBureaus = [SELECT Id, Name FROM Speaker_Bureau_gne__c WHERE 
                            Speaker_bureau_year_gne__c = :selectedYear 
                            AND Speaker_Bureau_Type_gne__c = :parentBureauType 
                            AND Speaker_Bureau_Type_gne__c != null 
                            AND Id != :parentBureauID
                            ORDER BY Name];
            }

            system.debug('111:'+myBureaus);
            for (Speaker_Bureau_gne__c sb : myBureaus) {
                bureauOptions.add(new SelectOption(sb.Id, sb.Name));
            }
        }
        return bureauOptions;
    }

    private Set<ID> getMembershipForMultipleAccountInSelectedYear(){
        Set<ID> memberOf = new Set<ID>();
        Set<ID> currMembers = new Set<ID>();
        List<Speaker_Bureau_Membership_gne__c> members = [SELECT Bureau_Member_gne__c FROM Speaker_Bureau_Membership_gne__c 
                                 WHERE Id in :sbmids];
        for(Speaker_Bureau_Membership_gne__c sbm : members){
            currMembers.add(sbm.Bureau_Member_gne__c);
        }
        List<Speaker_Bureau_Membership_gne__c> memberships = [
            SELECT Speaker_Bureau_ID_gne__c FROM Speaker_Bureau_Membership_gne__c 
            WHERE Bureau_Member_gne__c in :currMembers AND
                Speaker_Bureau_ID_gne__r.Speaker_Bureau_Year_gne__c = :selectedYear AND
                Speaker_Status_gne__c in ('Nominated', 'Approved', 'Removed', 'Pending')];
        if (!memberships.isEmpty()) {
            for (Speaker_Bureau_Membership_gne__c bm : memberships) {
                memberOf.add(bm.Speaker_Bureau_ID_gne__c);
            }
        }

        return memberOf;
    }

    private Set<ID> getMembershipForAccountInSelectedYear() {
        Set<ID> memberOf = new Set<ID>();
        List<Speaker_Bureau_Membership_gne__c> memberships = [
            SELECT Speaker_Bureau_ID_gne__c FROM Speaker_Bureau_Membership_gne__c 
            WHERE Bureau_Member_gne__c = :accountId AND
                Speaker_Bureau_ID_gne__r.Speaker_Bureau_Year_gne__c = :selectedYear AND
                Speaker_Status_gne__c in ('Nominated', 'Approved', 'Removed', 'Pending')];
     
        if (!memberships.isEmpty()) {
            for (Speaker_Bureau_Membership_gne__c bm : memberships) {
                memberOf.add(bm.Speaker_Bureau_ID_gne__c);
            }
        }

        return memberOf;
    }

    public String getEDMClassification() {
        
        if(multiple) return '';
        

        return EDM_Classification_Utils.getEDMClassification(account, speakerBureauType);
    }

    public Boolean checkIfExistsNotClassfiedAccount(){
        Set<ID> currMembers = new Set<ID>();
        List<Speaker_Bureau_Membership_gne__c> members = [SELECT Bureau_Member_gne__c FROM Speaker_Bureau_Membership_gne__c 
                                 WHERE Id in :sbmids];
        for(Speaker_Bureau_Membership_gne__c sbm : members){
            currMembers.add(sbm.Bureau_Member_gne__c);
        }
        List<Account> al;
        if(speakerBureauType=='Clinical'){
            al = [SELECT Id FROM Account WHERE Professional_Type_gne__c != 'Patient Ambassador' AND EDM_Clinical_Classification_gne__c = 'Not Classified' AND Id IN :currMembers];
        } else {
            al = [SELECT Id FROM Account WHERE Professional_Type_gne__c != 'Patient Ambassador' AND EDM_Business_Classification_gne__c = 'Not Classified' AND Id IN :currMembers];
        } 
        if(al.size()==0){
            return false;
        }
        return true;
    }

    private Map<Id, Account> getSelectedBureauMembers() {
        List<Account> sbMembers = [SELECT Id FROM Account WHERE Id IN (SELECT Bureau_Member_gne__c FROM Speaker_Bureau_Membership_gne__c WHERE Speaker_Bureau_ID_gne__c = :selectedBureau)];
        return new Map<Id, Account>(sbMembers);
    }

    public PageReference redirectToCRM() {
        if (GNE_SFA2_Util.isCCCrmUser() ) {
			PageReference npr = new PageReference('/apex/GNE_CRM_Bureau_Account_Nomination?Id='+accountId);
            npr.setRedirect(true);
            return npr;
		}
		return null;
    }
    
    //TO DO add conditions
    public Boolean getShowConfirmationPopup() {
        return !showErrorAttr && showConfirmationPopupAttr;
        //return false;
    }
    
    public Boolean getShowErrorAttr() {
        return showErrorAttr;
    }
    
    public PageReference nextWindow() {
        PageReference npr = new PageReference('/apex/GNE_CRM_SBMembership_Nominate_Layout?act_id=' + accountId + '&spb_id=' + selectedBureau + '&create_flag=1&retURL=/' +accountId);
        npr.setRedirect(true);
        return npr;
    }
    
    public String getNominatetoBureauTableInfo() {
        String result = '';
        if(multiple) {
            result = '<table cellspacing="0" cellpadding="10" >'+
                '<tr><td><b>Speaker Criteria</b></td><td style="color: #CC0000;">To Be Completed</td></tr>'+
                '<tr><td><b>Exclusion Check</b></td>' +  getExclusionCheckValueForTableInfo(Account.AGS_EX_Exclusion_Status_base_gne__c) +'</tr>'+
                '<tr><td><b>Classification</b></td><td style="color:green">Done</td></tr></table>';
            
        } else {
            ClassificationValue classificationInfo = getClassificationValueForTableInfo(getEDMClassification());
            result = '<table cellspacing="0" cellpadding="10" >'+
                '<tr><td><b>Speaker Criteria</b></td><td style="color: #CC0000;">To Be Completed</td></tr>'+
                '<tr><td><b>Exclusion Check</b></td>' +  getExclusionCheckValueForTableInfo(Account.AGS_EX_Exclusion_Status_base_gne__c) +'</tr>'+
                '<tr><td><b>Classification</b></td><td>' + classificationInfo.result +'</td></tr></table>' + (classificationInfo.additionalInfo != null ? classificationInfo.additionalInfo : '');
        }
        return result;
    }
    
    private String getExclusionCheckValueForTableInfo(String exclusionStatus) {
        String result = '';
        if (exclusionStatus == 'Not checked' || exclusionStatus == '') result = '<td class="important"> To Be Completed</td>';
        else if(exclusionStatus == 'Check pending')  result = '<td style="color:black">Request Submitted</td>';
        else if(exclusionStatus == 'Verified and clear' || exclusionStatus == 'Sanctioned but legal approved') result = '<td style="color:green">Done</td>';
        return result;
    }
    
    private ClassificationValue getClassificationValueForTableInfo(String classification) {
        ClassificationValue returnObject = new ClassificationValue();
        if (isAccountEDMClassified(classification)) {
            returnObject.result = '<span style="color:green">Done</span>';
            return returnObject;
        } else if (classification == 'Classification Pending') {
            returnObject.result = 'Request Submitted';
            return returnObject;
        } else {
            returnObject.result = '<span style="color: #CC0000;">To Be Completed</span>';
            returnObject.additionalInfo = '<p style="color: #CC0000;text-align: center;">CV required to complete Classification!</p>';
            return returnObject;                
        }
    }
    
    private Class ClassificationValue{
        String result;
        String additionalInfo;
    }
    
    private Boolean isAccountEDMClassified(String classification) {
        Set<String> validStatuses = new Set<String>{'Community', 'Regional', 'National', 'Global'};
        return validStatuses.contains(classification);
    }
}