/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2012-12-14
*  Description: This is a controller extension for GNE_SFA2_Account_Layout page
*  
*  Modification History
*  Date        Name        Description
*  2015-06-24  Wac?aw Smaga     Adding custom Speaker Burau Membership Related List
*            
*************************************************************/
public with sharing class GNE_SFA2_Account_Ext extends GNE_SFA2_DynamicVFLoader {

    public String defaultCollapsConfig { get; private set; } //not used, to remove in march 2016

    public GNE_SFA2_Account_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Account_Layout');
        // we have to put all possible included pages into the map with "false" value to fix sf bug with maps on vf pages
        visualforceIncludesMap.put('GNE_SFA2_ViewRHPage', false);
        visualforceIncludesMap.put('GNE_SFA2_Ratings_Layout', false);
        visualforceIncludesMap.put('GNE_SFA2_Territory_Alignment_Layout', false);
        visualforceIncludesMap.put('GNE_SFA2_Activase_Questions_Layout', false);
        visualforceIncludesMap.put('GNE_SFA2_RepSpecific_Layout', false);
        visualforceIncludesMap.put('GNE_SFA2_TherapeuticAreas_Layout', false);
        visualforceIncludesMap.put('GNE_SFA2_EventParticipation_Layout', false);
        visualforceIncludesMap.put('GNE_SFA2_InfluenceMetrics_Layout', false);   
        visualforceIncludesMap.put('GNE_SFA2_TargetsAndTiers_Layout', false);
        visualforceIncludesMap.put('GNE_SFA2_Planned_Frequency_Layout', false);
        visualforceIncludesMap.put('GNE_SFA2_Record_History_Page', false);        
        visualforceIncludesMap.put('GNE_SFA2_Revegy_Account_Layout', false);
        visualforceIncludesMap.put('GNE_SFA2_PREP_Testing_Information', false);
        visualforceIncludesMap.put('GNE_SFA2_PREP_Testing_Objectives', false);        
    }
    
    //View Page Button Actions       
    public PageReference edit(){
        Pagereference pageref = new pagereference('/apex/GNE_SFA2_Account_Edit_Create_Layout?id='+myObject.Id);
        GNE_SFA2_User_App_Context_gne__c userApplicationContext = GNE_SFA2_Util.getUserApplicationContext();
        if(userApplicationContext != null && userApplicationContext.App_Name_gne__c == 'SFA-Canada') {
            if(userApplicationContext.Role_gne__c == 'Manager' || userApplicationContext.Role_gne__c == 'TS' || userApplicationContext.Role_gne__c == 'OPS') {
                pageref.getParameters().put('canadaAccountType', String.valueOf(myObject.get('Account_Type_gne__c')));
            } else if(userApplicationContext.Role_gne__c == 'RAMA') {
                pageref.getParameters().put('canadaAccountType', String.valueOf(myObject.get('Account_Type_RAMA_gne__c')));
            }
        }
        pageref.setredirect(true);
        return pageref;
    }    

    public PageReference editClick(){
        Pagereference pageref = new pagereference('/apex/GNE_SFA2_Account_Edit_Create_Layout?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }   
    
    /*public PageReference deleteClick(){
        pagereference pageref = new pagereference('/home/home.jsp');
        pageref.setredirect(true);
        return pageref;
    }*/

    public PageReference addContactClick(){
        //String buttonURL = '/003/e?accid='+myObject.Id+'&RecordType=0127000000015bi&ent=Contact';
        Id recTypeId = [Select id From RecordType where DeveloperName='AssociatedContactRecordType' and SobjectType='Contact'].id;
        Pagereference pageref = new Pagereference('/apex/GNE_SFA2_Contact_Edit_Create_Layout');
        pageref.getParameters().put('accountId', myObject.id);
        pageref.getParameters().put('recordTypeId', recTypeId);
        pageref.getParameters().put('retURL', myObject.id);
        pageref.setredirect(true);
        return pageref;
    }
    
    //for canada
    public PageReference addContactCanClick(){
        Id recTypeId = [Select id From RecordType where DeveloperName='GNE_SFA_Canada' and SobjectType='Contact'].id;
        Pagereference pageref = new Pagereference('/apex/GNE_SFA2_Contact_Edit_Create_Layout');
        pageref.getParameters().put('accountId', myObject.id);
        pageref.getParameters().put('recordTypeId', recTypeId);
        pageref.getParameters().put('retURL', myObject.id);
        pageref.setredirect(true);
        return pageref;
    }

    public PageReference recordACallClick(){
        pagereference pageref = Page.GNE_SFA2_Interaction;
        pageref.getParameters().put('accountId', myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }

    public PageReference dataChangeRequestClick(){
        String sbcURL = '';
        PageReference pageref;
        if(GNE_SFA2_Util.isCanadaUser()) {
            pageref = ApexPages.currentPage();
        } else {
            sbcURL = '/apex/GNE_SFA2_AccountDCR?id='+myObject.Id;
            pageref = new pagereference(sbcURL);
            pageref.setredirect(true);
        }
        return pageref;
    }
    
    /* Should be changed when implementation of buttons will be finished
    public PageReference assignTerritoryClick(){

    }

    public PageReference newProfessionalClick(){

    }
    
    public PageReference mergeContactsClick(){
    //As of 2/19/2013, the merge Contacts button is decided not to be implemented after confirming with the BA.
    }
    */        
    
    public Boolean getIsMenuVisible() {
        return !GNE_SFA2_Util.isCanadaINFUUser();
    }
    
    public PageReference viewTerritoriesClick(){
        String truncatedId = myObject.Id;
        String newId= truncatedId.Substring(0,truncatedId.length()-3);
        String sbcURL = '/apex/GNE_SFA2_Report_layout';       
        PageReference pageref=new PageReference(sbcURL);
        pageref.getparameters().put('id','00O70000001mLQz' );
        pageref.getparameters().put('pv0',newId );
        pageref.setredirect(true);
        return pageref;
    }
    
    public PageReference allAffiliationsInteractionClick(){
        String repUrl = GNE_SFA2_ThreeSixtyDegreeController.runThreeSixtyDegreeReport(myObject.Id);
        Pagereference pageref = new pagereference(repUrl);
        pageref.setredirect(true);
        return pageref;
    }     

    public PageReference medicalCommunicationsClick(){
        String sbcURL = '/apex/GNE_SFA2_Create_MedComm_Layout?acctId='+myObject.id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    }
    
    public PageReference medicalReferralsClick(){
        String sbcURL = '/apex/GNE_SFA2_Referral?accountId='+myObject.id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    }
    
    public PageReference addAffiliationClick(){
        String sbcURL = '/apex/GNE_SFA2_Affiliation_Edit_Create_Layout?CF00N70000001tDNo_lkid='+myObject.id+'&save_new=1&sfdc.override=1&retUrl=%2F'+myObject.id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    }
    
    public PageReference addAddressClick(){
        String sbcURL;
      
      	if([SELECT Id FROM Account WHERE Id = :myObject.id AND Region_Code_gne__c = 1].isEmpty()) {
        	sbcURL = '/apex/GNE_SFA2_Account_Address_Search?retUrl=%2F'+myObject.id+'&accountId='+myObject.id+'&CF00N70000001tDKx_lkid='+myObject.id+'&sfdc.override=1';
      	} else {
        	sbcURL = Page.GNE_SFA2_SBC.getUrl() + '?accountId='+myObject.id;
      	}
        
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    }

    public PageReference licenseIssueClick(){
        String sbcURL = '/apex/GNE_SFA2_LicenseIssueDCR?id='+myObject.Id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    } 

    public PageReference newDoCLocationClick(){
        String sbcURL = '/apex/GNE_SFA2_Account_DoC_Layout?DoCId='+myObject.Id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    } 

    public PageReference addAttachmentsClick(){
        String sbcURL = '/apex/GNE_SFA2_UploadAttachment?Id='+myObject.Id+'&retURL=%2F'+myObject.Id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    }

    public PageReference viewAttachmentsClick(){
        String sbcURL = '/apex/GNE_SFA2_Attachment_layout?Id='+myObject.Id+'&retURL=%2F'+myObject.Id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
        return null;
    }
    
    public PageReference viewHierarchyClick(){
        String sbcURL = '/apex/GNE_SFA2_Account_Hierarchy_Layout?Id='+myObject.Id+'&retURL=%2F'+myObject.Id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
        return null;
    }
    /*
    public PageReference nominateToBureauClick(){
        String sbcURL = '/apex/GNE_SFA2_Account_Layout?id='+myObject.Id;
        Account objAcc=[Select Classification_gne__c from Account where Id =:myObject.Id];
        if(objAcc.Classification_gne__c == '' || objAcc.Classification_gne__c ==null ){
            String error='The selected person does not have a classification and the nomination cannot proceed at this time.Please submit a classification request with the person\'s CV to Medical Affairs at speakerclassification-d@gene.com. Medical Affairs will classify the person, update the required field, and notify you. Once this is completed you may nominate the person to the bureau.';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,error));
            return null;
        }else{
            isAccountClassification = true;
            sbcURL = '/apex/GNE_SFA2_Bureau_Account_Nomination?id='+myObject.Id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    }
    
    }
    */
        
    public PageReference accountCalendarClick(){
        String sbcURL = '/apex/GNE_SFA2_MyCalendar?id=' + myObject.Id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    }

    public PageReference updateClassificationClick(){
        String sbcURL = '/apex/EDM_Cl_Req_Review_Edit_Create?accountId=' + myObject.Id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    }

    public PageReference classificationLogClick(){
        String sbcURL = '/apex/EDM_Classif_Requests_Log_List?accountId=' + myObject.Id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    }
    
    //relatedList Custom Buttons
            
    public override PageReference callMethod(String methodName){
    	PageReference result = null;
        if('newHospitalDepartmentClick'.compareTo(methodName) == 0){
            result = newHospitalDepartmentClick(); 
        } else if('newHospitalDepartmentCanadaClick'.compareTo(methodName) == 0){
            result = newHospitalDepartmentCanadaClick(); 
        } else if('newSurveyClick'.compareTo(methodName) == 0){
            result = newSurveyClick(); 
        } else if('newDoCLocationClick'.compareTo(methodName) == 0){
            result = newDoCLocationClick(); 
        } else if('medicalCommunicationsClick'.compareTo(methodName) == 0){
            result = medicalCommunicationsClick(); 
        } else if('medicalReferralsClick'.compareTo(methodName) == 0){
            result = medicalReferralsClick(); 
        } else if('addAffiliationClick'.compareTo(methodName) == 0){
            result = addAffiliationClick(); 
        } else if('addAddressClick'.compareTo(methodName) == 0){
            result = addAddressClick(); 
        } else if('addAccountTeam'.compareTo(methodName) == 0){
            result = addAccountTeam(); 
        } else if('addBAMAccountTeam'.compareTo(methodName) == 0){
            result = addBAMAccountTeam(); 
        } else if('addFPMDistributor'.compareTo(methodName) == 0){
            result = addFPMDistributor(); 
        } else if('addHINNumberFPM'.compareTo(methodName) == 0){
            result = addHINNumberFPM(); 
        } else if('addAttachment'.compareTo(methodName) == 0){
            result = addAttachmentsClick();
        } else if('deleteAllTeams'.compareTo(methodName) == 0){
            result = deleteAllTeams(); 
        } else if('addSocietyMembershipClick'.compareTo(methodName) == 0){
            result = addSocietyMembershipClick(); 
        } else {
        	result = super.callMethod(methodName);	
        }
        
        return result;
     }
     
     public PageReference addSocietyMembershipClick() {
    	Pagereference pageref = new Pagereference('/apex/GNE_SFA2_AccSocMem_Edit_Create?retUrl=%2F'+myObject.id+'&accountId='+myObject.id);
        pageref.setredirect(true);
        return pageref;
     }
    
     private PageReference newHospitalDepartmentCanadaClick(){

        System.debug('**my action method department has been called');
        PageReference pageref = new PageReference('/apex/GNE_SFA2_Account_Edit_Create_Layout?sfacanadaparentId='+myObject.Id+'&recordTypeName=GNE_SFA_Roche_Canada_Hospital_Depatment&retURL=%2F'+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }

     private PageReference newHospitalDepartmentClick(){

        System.debug('**my action method department has been called');
        PageReference pageref = new PageReference('/apex/GNE_SFA2_Account_Edit_Create_Layout?sfacanadaparentId='+myObject.Id+'&recordTypeName=HospitalDepartment_vod&retURL=%2F'+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }

     private PageReference newSurveyClick(){
        System.debug('**my action method department has been called');
        PageReference pageref = new PageReference('/apex/GNE_SFA2_Create_Survey_Layout?objectId='+myObject.Id+'&retURL=%2F'+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }


    private PageReference addAccountTeam(){
        String sbcURL = '/apex/GNE_SFA2_Std_AccTeam_Create_Layout?objectId='+myObject.Id+'&retURL=%2F'+myObject.Id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    }    

    private PageReference addBAMAccountTeam(){
        String sbcURL = '/apex/GNE_SFA2_Account_Team_Edit_Create_Layout?objectId='+myObject.Id+'&retURL=%2F'+myObject.Id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    }

    private PageReference addFPMDistributor(){
        String sbcURL = '/apex/GNE_SFA2_Distributor_Edit_Create?accountId='+myObject.Id+'&retURL=%2F'+myObject.Id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    }

    private PageReference addHINNumberFPM(){
        String sbcURL = '/apex/GNE_SFA2_HIN_Edit_Create_Layout?accountId='+myObject.Id+'&retURL=%2F'+myObject.Id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    }

    private Pagereference deleteAllTeams(){
        try{       
            List<AccountTeamMember> existingTeams = [SELECT Id From AccountTeamMember where AccountId =: myObject.Id];
            if(existingTeams.size()>0){
                delete existingTeams;
            }
        }
        catch(Exception ex){
             return GNE_SFA2_Util.redirectToErrorPage('You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.', Apexpages.currentPage().getUrl(), ex.getMessage());           
        }
        String sbcURL = '/apex/GNE_SFA2_Account_Layout?Id='+myObject.Id;
        pagereference pageref = new pagereference(sbcURL);
        pageref.setredirect(true);
        return pageref;
    }
    
    public Component.Apex.PageBlockButtons getAccountCustomButtons(){
        return getAllCustomButtons(GNE_SFA2_Util.getUserApplicationContext(),  myObjectType, recordTypeName, myObject.id);
    }    
    
    private Component.Apex.PageBlockButtons getAllCustomButtons(GNE_SFA2_User_App_Context_gne__c userApplicationContext, String objectName, String recordTypeName, Id objectId){
        if(userApplicationContext != null && objectName != null && recordTypeName != null){
            List<SFA2_Configuration_Object_Detail_gne__c> buttonConfigurations = getUIConfigurationObjectDetails(userApplicationContext, objectName, recordTypeName, BUTTON);
            UserRecordAccess userRecordAccess = GNE_SFA2_Util.getUserRecordAccess(UserInfo.getUserId(), objectId);
            
            Component.Apex.PageBlockButtons dynamicPageBlockButtons = new Component.Apex.PageBlockButtons();
            dynamicPageBlockButtons.location = 'top';
            for(SFA2_Configuration_Object_Detail_gne__c buttonConfiguration : buttonConfigurations) {                               
               Component.Apex.CommandButton dynamicButton = new Component.Apex.CommandButton();               
               dynamicButton.value = buttonConfiguration.Label_gne__c;
               dynamicButton.disabled = buttonConfiguration.Is_Read_Only_gne__c;
               dynamicButton.style = buttonConfiguration.Style_gne__c;
               if (buttonConfiguration.Label_gne__c == 'View Attachments') {
                   dynamicButton.id = 'view-Attachments';
               }
               if(buttonConfiguration.Attributes_gne__c != null && buttonConfiguration.Attributes_gne__c.contains('action')){
                    dynamicButton.expressions.action = '{!'+buttonConfiguration.Attributes_gne__c.substringBetween('action=',';')+'}';
               }
               if(buttonConfiguration.Attributes_gne__c != null && buttonConfiguration.Attributes_gne__c.contains('styleClass')){
                    dynamicButton.styleClass = buttonConfiguration.Attributes_gne__c.substringBetween('styleClass=',';');
               }
               if(buttonConfiguration.Attributes_gne__c != null && buttonConfiguration.Attributes_gne__c.contains('dir')){
                    dynamicButton.dir = buttonConfiguration.Attributes_gne__c.substringBetween('dir=',';');
               }
               if(buttonConfiguration.Attributes_gne__c != null && buttonConfiguration.Attributes_gne__c.contains('onclick')){
                    if(!buttonConfiguration.Attributes_gne__c.substringBetween('onclick=',';').containsAny('{!$Profile.Name}')) {
                        dynamicButton.onclick = buttonConfiguration.Attributes_gne__c.substringBetween('onclick=',';');
                    } else {
                        String profileName = GNE_SFA2_Util.getCurrentUserProfileName();
                        dynamicButton.onclick = buttonConfiguration.Attributes_gne__c.substringBetween('onclick=',';').replace('{!$Profile.Name}', profileName);
                    }
               }
               if(buttonConfiguration.Attributes_gne__c != null && buttonConfiguration.Attributes_gne__c.contains('rerender')){
                    dynamicButton.rerender = new Set<String>(buttonConfiguration.Attributes_gne__c.substringBetween('rerender=',';').split(','));
               }
               if(buttonConfiguration.Attributes_gne__c != null && buttonConfiguration.Attributes_gne__c.contains('immediate')){
                    if(buttonConfiguration.Attributes_gne__c != null && buttonConfiguration.Attributes_gne__c.substringBetween('immediate=',';') == 'true'){
                        dynamicButton.immediate = true;
                    } else {
                        dynamicButton.immediate = false;
                    } 
               }
               if (buttonConfiguration.API_Name_gne__c != null &&
               		((buttonConfiguration.API_Name_gne__c.equalsIgnoreCase('Edit') && !userRecordAccess.HasEditAccess)
               		|| (buttonConfiguration.API_Name_gne__c.equalsIgnoreCase('Delete') && !userRecordAccess.HasDeleteAccess)
               		|| (buttonConfiguration.API_Name_gne__c.equalsIgnoreCase('Share') && !userRecordAccess.HasTransferAccess))){
                    if (String.isNotBlank(dynamicButton.style)){
                    	dynamicButton.style += '; display: none;';
                    } else {
                    	dynamicButton.style = 'display: none;';
                    }
                }
               dynamicPageBlockButtons.childComponents.add(dynamicButton);
            }
            return dynamicPageBlockButtons;
        }else{
            return new Component.Apex.PageBlockButtons();
        }
    }

    public String getNominationStatus(){
        return ApexPages.currentPage().getParameters().get('nomination');
    }
    public String getExclusionStatus(){
        return [Select AGS_EX_Exclusion_Status_gne__c from account where id=:myObject.Id].AGS_EX_Exclusion_Status_gne__c;
    }

    //Custom SBM RL
    public String SelectedMembershipID { get; set; }
    public Integer HistorySize { get; set; }
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
    public List<Speaker_Bureau_Membership_gne__c> getMemberships() {
        return [SELECT 
                    Id, 
                    Name, 
                    Speaker_Bureau_ID_gne__c, 
                    Speaker_Bureau_ID_gne__r.Name, 
                    Speaker_Scope_gne__c, 
                    Speaker_Status_gne__c 
                FROM Speaker_Bureau_Membership_gne__c 
                WHERE Bureau_Member_gne__c = :myObject.Id];
    }

    public List<HistoryWrapper> getSBMHistoryForMembership() {
        List<HistoryWrapper> result = new List<HistoryWrapper>();
        List<EDM_SBM_Classification_History_gne__c> clHistory = 
                [SELECT 
                    EDM_Classification_Type_gne__c, 
                    EDM_Classification_Scope__c,
                    CreatedDate, 
                    EDM_Download_CV_gne__c, 
                    EDM_Speaker_Bureau_Membership_gne__c
                FROM EDM_SBM_Classification_History_gne__c 
                WHERE EDM_Speaker_Bureau_Membership_gne__c = :SelectedMembershipID
                ORDER BY CreatedDate DESC];

        for (EDM_SBM_Classification_History_gne__c ch : clHistory) {
            result.add(new HistoryWrapper(ch));
        }

        HistorySize = result.size();
        return result;
    }

    public Boolean getIsEditHidden() {

        if (relatedListAttributes.containsKey('Speaker_Bureau_Membership_gne__c') && relatedListAttributes.get('Speaker_Bureau_Membership_gne__c').hideEditLink) {
            return true;
        }
        else {
            return false;
        }
    }

    public Boolean getIsSpeakerBureauMembershipInitiallyCollapsed() {
        return relatedListAttributes.containsKey('Speaker_Bureau_Membership_gne__c') &&
            relatedListAttributes.get('Speaker_Bureau_Membership_gne__c').initiallyCollapsed;
    }
}