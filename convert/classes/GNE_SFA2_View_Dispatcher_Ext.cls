/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2012-12-03 
*  This is SFA2 View Dispatcher controller
*    
*  Modification History
*  Date        Name        Description
1. 25.01.2013  Lukasz Bieniawski Added support for url parameters passing
2. 15.01.2016  Waclaw Smaga  Added support for archived tasks
*************************************************************/

public with sharing class GNE_SFA2_View_Dispatcher_Ext {
    private String sObjectType;
    private String sObjectId;
    private String urlParameters;
    private String sObjectURLId;    
    private Boolean isSFA2User;    
    private UserRecordAccess recordAccess;
    private String userProfile;
    
    public GNE_SFA2_View_Dispatcher_Ext(ApexPages.StandardController stdController){
        sObjectURLId =  System.currentPageReference().getParameters().get('id');
        Boolean isTask = sObjectURLId.startsWith(Task.sobjecttype.getDescribe().getKeyPrefix());
        recordAccess = [ SELECT RecordId, HasReadAccess  FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :sObjectURLId LIMIT 1 ];
        userProfile = GNE_SFA2_Util.getCurrentUserProfileName();
        if(recordAccess != null && recordAccess.HasReadAccess == true) {
            if (isTask) {
                sObjectType = 'Task';
                sObjectId = sObjectURLId;
            }
            else {
                sObjectType = String.valueOf(stdController.getRecord().getSObjectType());            
                sObjectId = stdController.getRecord().Id;
            }

            System.PageReference pageReference = System.currentPageReference();
            if (pageReference != null){
                Map<String,String> parameters = pageReference.getParameters();
                if (sObjectType == 'Account'){
                	if (parameters == null){
                		parameters = new Map<String,String>();
                	}
                	// Determines view mode for the GNE_SFA2_Account page
                	if (!parameters.containsKey('sfdc.override')){
                		parameters.put('sfdc.override', '1');
                	}
                }
                if (parameters != null && parameters.size() > 0){
                    urlParameters = '?';
                    for (String key : parameters.keyset()){
                        if (urlParameters != '?'){
                            urlParameters += '&';
                        }                        
                        urlParameters += String.format('{0}={1}', new String[]{key, parameters.get(key)});
                    }
                }
           }    
       }        
    }
    
    public PageReference doRedirect(){
        isSFA2User = GNE_SFA2_Util.isSFA2UserForUI();
        Boolean isgCollaborate = isgCollaborateMode();

        if(GNE_SFA2_Util.isEsbrietCrmUser() || GNE_SFA2_Util.isSfaCCUser()) {
            if(sObjectType == 'Call2_vod__c'){
                PageReference pageref = new PageReference('/apex/GNE_MCCO_CRM_Interaction?id=' + sObjectId + '&sfdc.override=1');
                pageref.setredirect(true);
                return pageref;
            } else if(sObjectType == 'Contact'){
                PageReference pageref = new PageReference('/apex/GNE_MCCO_CRM_Contact?id=' + sObjectId + '&sfdc.override=1');
                pageref.setredirect(true);
                return pageref;
            }
        }

        // for all SFA2 users open SFA2 custom page
        if(isSFA2User || isgCollaborate){

            //if user doesn't have the record level access, need to redirect to the Access Denied page.
            if(recordAccess != null && recordAccess.HasReadAccess==false) {
                PageReference pageref = new PageReference('/apex/GNE_SFA2_Access_Denied');
                pageref.setredirect(true);
                return pageref;
            }            
    
            if(sObjectType == 'Account'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Account');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Contact'){
                // for PersonAccount contacts we should display PersonAccount instead of Contact
                List<Account> contactPersonAccountList = [SELECT Id FROM Account WHERE PersonContactId = :sObjectId limit 1];
                if(contactPersonAccountList != null && contactPersonAccountList.size() > 0){
                    PageReference pageref = new PageReference('/apex/GNE_SFA2_Account_Layout?id='+contactPersonAccountList[0].Id);
                    pageref.setredirect(true);
                    return pageref;
                }else{
                    String pageUrl = getPageUrlFormated('GNE_SFA2_Contact_Layout');
                    PageReference pageref = new PageReference(pageUrl);
                    pageref.setredirect(true);
                    return pageref;
                }
            } else if (sObjectType == 'Address_vod__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Address_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Change_Request_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_DCR_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Issue_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_IRF_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Time_Off_Territory_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_ToT_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'IRF_Case_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_IRF_Case_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Affiliation_vod__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Affiliation_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Account_Plan_vod__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Account_Plan_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Account_Team_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Account_Team_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Educational_Background_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Edu_Backgnd_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Qualifications_Capabilities_Assess_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Qualif_Capab_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            }  else if (sObjectType == 'Advocacy_Assessment_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Advoc_Assess_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            }  else if (sObjectType == 'TSF_vod__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_TSF_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            }  else if (sObjectType == 'ProfileID_License_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_PID_License_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'questionnaireBureau_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_BCoverage_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Curriculum_Module_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_CModule_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Product_vod__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_PCatalog_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Product_Strategy_vod__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_PStrategy_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Product_Tactic_vod__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_PTactics_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Product_Plan_vod__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Product_Plan_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Speaker_Bureau_Product_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_ProductTeam_layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Membership_Contracts_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_MContract_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Speaker_Contract_Line_Item_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_SC_Line_Item_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Speaker_Contract_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_SContract_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Event_Bureaus_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_EBureau_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Product_Metrics_vod__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Brand_Aff_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Event_Attendee_vod__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_EventAttendee_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Speaker_Training_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_STraining_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Curriculum_Speaker_Bureau_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_SBCurriculum_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Speaker_Bureau_Membership_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_SBMembership_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Event_Curriculum_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_EventCurclmBureau_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Event_Curriculum_Join_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_ECurriculum_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Speaker_Bureau_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_SpeakerBureau');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Member_Trainings_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Membership_Training_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Medical_Event_vod__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_MedicalEvent_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Account_External_Id_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Acc_Ext_Id_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Task'){
                String pageUrl;
                Task taskToGoTo = [SELECT Id, IsArchived FROM Task WHERE Id = :sObjectURLId ALL ROWS];
                if (taskToGoTo.IsArchived) {
                    pageUrl = '/' + sObjectId + '?nooverride=1';
                }
                else {
                    pageUrl = getPageUrlFormated('GNE_SFA2_Task_Layout');
                }
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Survey_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Edit_Survey_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
             }else if (sObjectType == 'Questionnaire_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Questionnaire_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Key_Message_vod__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Key_Message_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'CADS_Account_Address_Issues_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_CADS_Issue_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Referral_Assignment_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Referral_Layout');
                PageReference pageref = new PageReference(pageUrl);                                             
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Time_off_Territory_Day_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_ToT_Day_Layout');
                PageReference pageref = new PageReference(pageUrl);                                             
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'ART_Site_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_ART_Site_Layout');
                PageReference pageref = new PageReference(pageUrl);                                             
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'ART_Issue_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_ART_Issue_Layout');
                PageReference pageref = new PageReference(pageUrl);                                             
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'ART_Team_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_ART_Team_Layout');
                PageReference pageref = new PageReference(pageUrl);                                             
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Account_Goal_and_Objective_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Account_Goal_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Account_Product_Objective_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Account_Product_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Account_Tactic_vod__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Account_Tactic_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            }else if (sObjectType == 'Question_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Question_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'QuestionnaireAccount_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Questionnaire_Account_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Medical_Communication_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Med_Comm_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Call2_Discussion_vod__c'){
                // We have to query parent call
                String parentCallId = [SELECT Call2_vod__c FROM Call2_Discussion_vod__c WHERE Id = :sObjectId limit 1][0].Call2_vod__c;
                PageReference pageref = new PageReference('/apex/GNE_SFA2_Interaction_Layout?id='+parentCallId);
                pageref.setredirect(true);
                return pageref;            
            }else if (sObjectType == 'Call2_Detail_vod__c'){
                // We have to query parent call
                String parentCallId = [SELECT Call2_vod__c FROM Call2_Detail_vod__c WHERE Id = :sObjectId limit 1][0].Call2_vod__c;
                Boolean editMode = false;
                String retUrl = null;
                if (String.isNotBlank(urlParameters)){
                    String editModeMask = 'editMode=true';
                    editMode = urlParameters.containsIgnoreCase(editModeMask);
                    if (editMode){
                        retUrl = urlParameters.substringAfter(editModeMask);                        
                    }
                }    
                String url = !editMode ? ('/apex/GNE_SFA2_Interaction_Layout?id='+parentCallId) : ('/apex/GNE_SFA2_Interaction_Edit_Create?id='+parentCallId);
                if (String.isNotBlank(retUrl)){
                    url += retUrl;
                }
                PageReference pageref = new PageReference(url);
                pageref.setredirect(true);
                return pageref;            
            } else if (sObjectType == 'Call2_vod__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Interaction_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;        
            } else if (sObjectType == 'Copay_Card_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_CopayCard_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            }else if (sObjectType == 'Comment_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Comment_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            }else if (sObjectType == 'Tumor_Board_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Tumor_Board_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            }else if(sObjectType=='Benefit_Design_vod__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Benefit_Design_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref; 
            }else if(sObjectType=='Question_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Question_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;                   
            }else if(sObjectType=='CONGA_Event_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_PROSPECT_Event_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;                   
            }else if(sObjectType=='CONGA_Event_Location_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_PROSPECT_Location_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;                   
            }else if(sObjectType=='CONGA_Sponsor_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_PROSPECT_Sponsor_Layout');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;                   
            }
        } else {
            // NOT SFA2 users and custom pages overrided view
            if (sObjectType == 'Account'){
                String pageUrl = getPageUrlFormated('GNE_SFA2_Account');
                PageReference pageref = new PageReference(pageUrl);
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Change_Request_gne__c'){
                PageReference pageref = new PageReference('/apex/GNEViewDCR?id='+sObjectId);
                pageref.setredirect(true);
                return pageref;            
            } else if (sObjectType == 'CADS_Account_Address_Issues_gne__c'){
                String pageUrl = getPageUrlFormated('CADS_Account_Address_Issues_View');
                PageReference pageref = new Pagereference(pageUrl);                 
                pageref.setredirect(true);
                return pageref;
            } else if (sObjectType == 'Referral_Assignment_gne__c'){
                String pageUrl = getPageUrlFormated('GNE_ViewReferralPage');
                PageReference pageref = new Pagereference(pageUrl);                 
                pageref.setredirect(true);
                return pageref;
            } else if(sObjectType == 'Call2_vod__c' && (userProfile.startsWith('GNE-CM-') || userProfile.equalsIgnoreCase('GNE-AGS-CCO-Analyst')
                                                        || userProfile.equalsIgnoreCase('GNE-AGS-CCO-Manager')
                                                        || userProfile.equalsIgnoreCase('GNE-AGS-CCO-TempAnalyst'))){

                PageReference pageref = new PageReference('/apex/AGS_Interaction_Details_gne?id='+sObjectId);
                pageref.setredirect(true);
                return pageref;
            } else if(sObjectType == 'Call2_vod__c' && (userProfile.equalsIgnoreCase('GNE-MCCO-AM') || userProfile.equalsIgnoreCase('GNE-MCCO-Kaiser'))){
                PageReference pageref = new PageReference('/apex/GNE_MCCO_CRM_Interaction?id=' + sObjectId + '&sfdc.override=1');
                pageref.setredirect(true);
                return pageref;
            } else if(sObjectType == 'Contact' && (userProfile.startsWithIgnoreCase('GNE-MCCO-'))){
                PageReference pageref = new PageReference('/apex/GNE_MCCO_CRM_Contact?id=' + sObjectId + '&sfdc.override=1');
                pageref.setredirect(true);
                return pageref;
            } else if(sObjectType == 'Survey_gne__c' && (userProfile.equalsIgnoreCase('GNE-MCCO-AM') || userProfile.equalsIgnoreCase('GNE-MCCO-Kaiser'))){
                PageReference pageref = new PageReference('/apex/GNE_MCCO_CRM_Edit_Survey?id=' + sObjectId + '&sfdc.override=1');
                pageref.setredirect(true);
                return pageref;
            } else if(sObjectType == 'Affiliation_vod__c' ){
                PageReference pageref = new PageReference('/apex/GNE_SFA2_Affiliation_Detail?id=' + sObjectId + '&sfdc.override=1');
                pageref.setredirect(true);
                return pageref;
            } else { // NOT SFA2 users and standard layout
                PageReference pageref = new PageReference('/'+sObjectId+'?nooverride=1');
                pageref.setredirect(true);
                return pageref;
            } 
            
        }
        return null;
    }
    
    private String getPageUrlFormated(String vfPageName){
        String pageUrl;
        if (!String.isBlank(urlParameters)){
            pageUrl = String.format('/apex/{0}{1}', new String[]{vfPageName, urlParameters});
        } else {
            pageUrl = String.format('/apex/{0}?id={1}', new String[]{vfPageName, sObjectId});
        }
        return pageUrl;               
    }

    private Boolean isgCollaborateMode() {
        Boolean result = false;
        
        if(!String.isEmpty(System.currentPageReference().getParameters().get('gCollaborate')) && System.currentPageReference().getParameters().get('gCollaborate') == 'true') {
            List<SFA2_User_Sales_Roster_gne__c> userSalesRoster = getUserSalesRosters();
            if(!userSalesRoster.isEmpty()) {
                List<GNE_SFA2_User_App_Context_gne__c> userAppContect = [SELECT App_Name_gne__c, Brand_gne__c, Role_gne__c, Run_in_SFA2_UI_gne__c, SFA2_Mode_gne__c FROM GNE_SFA2_User_App_Context_gne__c WHERE SetupOwnerId =: UserInfo.getUserId()];
                if(userAppContect.get(0).App_Name_gne__c != 'SFA-US' || userAppContect.get(0).App_Name_gne__c != 'MCCO' || userAppContect.get(0).App_Name_gne__c != 'TLCRM' || userAppContect.get(0).App_Name_gne__c != 'MedAffairs') {
                    userAppContect.get(0).App_Name_gne__c = userSalesRoster.get(0).Sales_Roster_gne__r.Type_gne__c;
                    userAppContect.get(0).Brand_gne__c = userSalesRoster.get(0).Sales_Roster_gne__r.Brand_Name_gne__c;
                    userAppContect.get(0).Role_gne__c = userSalesRoster.get(0).Role_gne__c;
                    userAppContect.get(0).Run_in_SFA2_UI_gne__c = true;
                    userAppContect.get(0).SFA2_Mode_gne__c = true;

                    update userAppContect;
                }
                result = true;
            }
        }
        return result;
    }

    private List<SFA2_User_Sales_Roster_gne__c> getUserSalesRosters() {
        return [SELECT Sales_Roster_gne__r.Type_gne__c, Sales_Roster_gne__r.Brand_Name_gne__c, Role_gne__c FROM SFA2_User_Sales_Roster_gne__c WHERE Sales_Roster_gne__r.Type_gne__c IN ('SFA-US', 'MCCO', 'TLCRM', 'MedAffairs') AND User_gne__c =: UserInfo.getUserId()];
    }
}