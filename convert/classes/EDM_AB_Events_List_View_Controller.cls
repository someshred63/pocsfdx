public with sharing class EDM_AB_Events_List_View_Controller extends GNE_SFA2_List_View_Base_Controller {

    public GNE_SFA2_List_View_Base_Controller thisController { get; set; }
    public Boolean isABPManager{get;set;}
    public String accountId { get; set; }
    public String additionalConditionForViews{get;set;}

    public String recordTypeName {get; set;}
    public String myObjectType {get; set;} 
    public GNE_SFA2_RL_Component_AttributesWrapper attributesWrapper { get; set; }
    public Boolean isRLRendered { get; set; }

    public List<EDM_Recently_Chosen_IABP_gne__c> recentlyChosen { get; private set; }

    public EDM_AB_Events_List_View_Controller () {
        super('EDM_IABP_gne__c');
        thisController = this;

        accountId = ApexPages.currentPage().getParameters().get('account');
        isABPManager = EDM_ABM_Utils.hasPermissionSet(EDM_ABM_Utils.ABS);
        isRLRendered = false;

        List<Id> excludedIabpsIds = getExcludedIabpIdsForRecentlyChosen(accountId);

        recentlyChosen = retrieveRecentlyChosenWithout(excludedIabpsIds);
        
        excludedIabpsIds = getExcludedIabpIdsForListView(excludedIabpsIds);

        additionalConditionForViews = ' EDM_Status_gne__c!=\'Canceled\' AND EDM_Historical_gne__c = false AND EDM_Executive_Summary_gne__c = false ';

        if (excludedIabpsIds.size() > 0) {
            additionalConditionForViews += ' AND Id NOT IN (\'' + String.join(excludedIabpsIds, '\',\'') + '\') ';
        }
    }

    public PageReference createEdit(){
        return null;
    }

    public PageReference initRL() {
        GNE_SFA2_User_App_Context_gne__c userApplicationContext = GNE_SFA2_Util.getUserApplicationContext();
        Account parentAccount = [SELECT Id, RecordTypeId, Name FROM Account WHERE Id = :accountId];
        List<Schema.RecordTypeInfo> sobjectRecordTypes = GNE_SFA2_Application_Cache.describeObject(String.valueOf(parentAccount.getSObjectType())).getRecordTypeInfos();
        myObjectType = String.valueOf(parentAccount.getSObjectType());
        if (sobjectRecordTypes.size() == 1 || parentAccount.get('RecordTypeId') == null) {
            recordTypeName = '';
        } else {
            recordTypeName = [SELECT DeveloperName FROM RecordType WHERE id = :(String)parentAccount.get('RecordTypeId')].DeveloperName;
        }
        
        List<SFA2_Configuration_Object_Detail_gne__c> details = getUIConfigurationObjectDetails(userApplicationContext, myObjectType, recordTypeName, 'Related List');
        String attributes = '';
        for (SFA2_Configuration_Object_Detail_gne__c detail : details) {
            if (detail.Label_gne__c == 'Advisory Boards') {
                attributes = detail.Attributes_gne__c;
                break;
            }
        }

        if (!String.isBlank(attributes)) {
            attributesWrapper = new GNE_SFA2_RL_Component_AttributesWrapper(attributes);
        }
        else {
            System.debug('$$ RL Configuration not found');
        }

        isRLRendered = true;

        return null;
    }

    private List<SFA2_Configuration_Object_Detail_gne__c> getUIConfigurationObjectDetails(GNE_SFA2_User_App_Context_gne__c userApplicationContext, String objectApiName, String recordTypeName, String elementType){
            return [SELECT API_Name_gne__c, Label_gne__c, Attributes_gne__c, Is_Required_gne__c,
                            Is_Read_Only_gne__c, Order_gne__c, Type_gne__c, Style_gne__c , Availability_Mode_gne__c                                                                                      
                    FROM SFA2_Configuration_Object_Detail_gne__c
                    WHERE Type_gne__c = :elementType
                        AND Configuration_Object_ref_gne__r.Object_Name_gne__c = :objectApiName
                        AND Configuration_Object_ref_gne__r.Role_gne__c = :userApplicationContext.Role_gne__c
                        AND Configuration_Object_ref_gne__r.Brand_gne__c = :userApplicationContext.Brand_gne__c
                        AND Configuration_Object_ref_gne__r.Application_Type__c = :userApplicationContext.App_Name_gne__c
                        AND Configuration_Object_ref_gne__r.Record_Type_gne__c = :recordTypeName
                        AND Configuration_Object_ref_gne__r.Is_Active_gne__c = true
                        AND Configuration_Object_ref_gne__r.Configuration_Type_gne__c='Page' 
                        AND Is_Active_gne__c = true 
                   ORDER BY Order_gne__c, API_Name_gne__c];
    }

    @TestVisible
    private List<Id> getExcludedIabpIdsForRecentlyChosen(Id accountId) {
        List<Id> result = new List<Id>();

        List<Id> finalizedIds = new List<Id>();
        List<EDM_Spend_gne__c> finalizedSpends = isABPManager ? retrieveFinalizedSpends() : new List<EDM_Spend_gne__c>();        
        List<EDM_IABP_gne__c> finalizedExeSums = !isABPManager ? retrieveFinalzedExeSums() : new List<EDM_IABP_gne__c>();                

        for (EDM_IABP_gne__c exes : finalizedExeSums) {
            finalizedIds.add(exes.EDM_Parent_IABP_gne__c);
        }

        for (EDM_Spend_gne__c spend : finalizedSpends) {
            finalizedIds.add(spend.EDM_Parent_IABP_gne__c);
        }
        result.addAll(finalizedIds);

        List<EDM_Attendee_gne__c> attendees = retrieveParticipationForAccount(accountId);
        List<Id> currentIabpsIds = new List<Id>();
        for (EDM_Attendee_gne__c item : attendees) {
            currentIabpsIds.add(item.EDM_Parent_IABP_gne__c);
        }
        result.addAll(currentIabpsIds);
        return result;
    }

    private List<Id> getExcludedIabpIdsForListView(List<Id> alreadyExcludedIds) {
        List<Id> result = new List<Id>();
        result.addAll(alreadyExcludedIds);
        for (EDM_Recently_Chosen_IABP_gne__c item : recentlyChosen) {
            result.add(item.EDM_IABP_gne__c);
        }
        return result;
    }

    private List<EDM_Attendee_gne__c> retrieveParticipationForAccount(Id accountId) {
        return [SELECT EDM_Parent_IABP_gne__c FROM EDM_Attendee_gne__c WHERE EDM_Account_gne__c = :accountId];
    }

    private List<EDM_IABP_gne__c> retrieveFinalzedExeSums() {
        return [SELECT EDM_Parent_IABP_gne__c FROM EDM_IABP_gne__c 
                   WHERE EDM_Executive_Summary_gne__c = true 
                       AND EDM_Historical_gne__c = false
                       AND EDM_ExeSum_Status_gne__c IN ('Finalized', 'Complete')];
    }
    
    private List<EDM_Spend_gne__c> retrieveFinalizedSpends() {
        return [SELECT EDM_Parent_IABP_gne__c
                FROM EDM_Spend_gne__c
                WHERE EDM_Spend_Status_gne__c IN ('Save & Finalize')];
    }

    private List<EDM_Recently_Chosen_IABP_gne__c> retrieveRecentlyChosenWithout(List<Id> excludedIabpsIds) {
        return [SELECT EDM_IABP_gne__c, EDM_User_gne__c,
                    EDM_IABP_gne__r.EDM_Group_gne__c, EDM_IABP_gne__r.EDM_Name_gne__c, EDM_IABP_gne__r.EDM_Parent_AABP_gne__r.EDM_Team_gne__c,
                    EDM_IABP_gne__r.EDM_Parent_AABP_gne__r.EDM_Unit_gne__c, EDM_IABP_gne__r.EDM_Year_gne__c,
                    EDM_IABP_gne__r.EDM_Type_of_Event_gne__c, EDM_IABP_gne__r.EDM_Start_Date_gne__c, EDM_IABP_gne__r.EDM_Location_gne__c
                FROM EDM_Recently_Chosen_IABP_gne__c 
                WHERE EDM_User_gne__c = :UserInfo.getUserId()
                    AND EDM_IABP_gne__c NOT IN :excludedIabpsIds
                    AND EDM_IABP_gne__c != NULL
                ORDER BY LastModifiedDate DESC
                LIMIT 5];
    }
}