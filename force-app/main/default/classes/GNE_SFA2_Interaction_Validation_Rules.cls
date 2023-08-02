/************************************************************
*  @author: Sreedhar Karukonda
*  Date: 12/13/2012
*  Description: This class GNE_SFA2_Interaction_Validation_Rules handles Validations on Call2_vod__c object on DML operations
*  This class is being used in GNE_SFA2_Interaction_Trigger trigger
*
*  Modification History
*  Date         Name        Description
*  07.29.2013   kozminsl    Fix validation rules, add meal opt out requirements.
*  20.02.2014   hrycenkm    Refactoring code.
*
*************************************************************/

public without sharing class GNE_SFA2_Interaction_Validation_Rules {

    public static void OnBeforeDelete (List<Call2_vod__c> triggerOld) {
        if(!GNE_SFA2_Util.isMergeMode()) {
            completedInteractionsValidation(triggerOld);
            beforeDeleteCallValidation(triggerOld);
        }
    }

    public static void OnBeforeUpdate (List<Call2_vod__c> triggerOld, List<Call2_vod__c> triggerNew) {
        if(!GNE_SFA2_Util.isMergeMode()) {
	        interactionObjectiveValidation(triggerNew);
	        interactionLocationValidation(triggerNew);
	        interactionTypeValidation(triggerNew);
	        interactionCompletedValidation(triggerNew);
	        interactionMealExpCityStateValidation(triggerNew);
	        interactionMealExpLocationValidation(triggerNew);
	        interactionMealExpenseObjectiveValidation(triggerNew);
	        interactionAttendeeValidation(triggerNew);
	        interactionProductValidation(triggerNew);
	        interactionVisitDescriptionValidation(triggerNew);
	        interactionVisitReasonValidation(triggerNew);
	        interactionExternalReferralValidation(triggerNew);
	        interactionCustomerPresentValidation(triggerNew);
        }
    }

    public static void OnBeforeInsert (List<Call2_vod__c> triggerNew) {
        if(!GNE_SFA2_Util.isMergeMode()) {
	        interactionObjectiveValidation(triggerNew);
	        interactionLocationValidation(triggerNew);
	        interactionTypeValidation(triggerNew);
	        interactionCompletedValidation(triggerNew);
	        interactionMealExpCityStateValidation(triggerNew);
	        interactionMealExpLocationValidation(triggerNew);
	        interactionMealExpenseObjectiveValidation(triggerNew);
	        interactionAttendeeValidation(triggerNew);
	        interactionProductValidation(triggerNew);
	        interactionVisitDescriptionValidation(triggerNew);
	        interactionVisitReasonValidation(triggerNew);
	        interactionExternalReferralValidation(triggerNew);
	        interactionCustomerPresentValidation(triggerNew);
        }
    }

    public static Set<String> objectiveProfileName {
        get{
            if (objectiveProfileName == null) {
                List<GNE_SFA2_Interaction_Objective_Profiles__c> interactionObjectiveSettings = GNE_SFA2_Interaction_Objective_Profiles__c.getall().values();
                objectiveProfileName = new Set<String>();
                for (GNE_SFA2_Interaction_Objective_Profiles__c iop : interactionObjectiveSettings) {
                    objectiveProfileName.add(iop.Profile_Name__c);
                }
            }
            return objectiveProfileName;
        }
    }

    public static Set<String> locationProfileName {
        get{
            if (locationProfileName == null) {
                List<GNE_SFA2_Interaction_Location_Profiles__c> interactionLocationSettings = GNE_SFA2_Interaction_Location_Profiles__c.getall().values();
                locationProfileName = new Set<String>();
                for (GNE_SFA2_Interaction_Location_Profiles__c ilp : interactionLocationSettings) {
                    locationProfileName.add(ilp.Profile_Name__c);
                }
            }
            return locationProfileName;
        }
    }

    private static Set<String> mealExpLocationProfileName {
        get{
            if (mealExpLocationProfileName == null) {
                List<GNE_SFA2_Interaction_Locate_Exp_Profiles__c> mealExpLocationSettings = GNE_SFA2_Interaction_Locate_Exp_Profiles__c.getall().values();
                mealExpLocationProfileName = new Set<String>();
                for (GNE_SFA2_Interaction_Locate_Exp_Profiles__c melp : mealExpLocationSettings) {
                    mealExpLocationProfileName.add(melp.Profile_Name__c);
                }
            }
            return mealExpLocationProfileName;
        }
    }

    private static Set<String> mealExpCityStateProfileName {
        get{
            if (mealExpCityStateProfileName == null) {
                List<GNE_SFA2_Interaction_City_State_Profiles__c> mealExpCityStateSettings = GNE_SFA2_Interaction_City_State_Profiles__c.getall().values();
                mealExpCityStateProfileName = new Set<String>();
                for (GNE_SFA2_Interaction_City_State_Profiles__c mecs : mealExpCityStateSettings) {
                    mealExpCityStateProfileName.add(mecs.Profile_Name__c);
                }
            }
            return mealExpCityStateProfileName;
        }
    }

    public static void completedInteractionsValidation(List<Call2_vod__c> triggerOld) {
        String profileName = [SELECT Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
        for (Call2_vod__c call : triggerOld) {
            if (call.Completed_gne__c == true && !GNE_SFA2_Interaction_Util.isExtendedCanadaUser(profileName)) {
                if (String.isBlank(call.Parent_Call_vod__c)) {
                    call.addError(Label.GNE_SFA2_ErrMsg_Cannot_Delete_Completed_Interaction);
                } else if(!GNE_SFA2_Interaction_Trigger_Helper.isAllowDeleteAttendeeMode()){
                    call.addError(Label.GNE_SFA2_ErrMsg_Cannot_Delete_Completed_Child_Interaction);
                }
            }
        }
    }

    private static void interactionObjectiveValidation(List<Call2_vod__c> callsList) {
        for (Call2_vod__c call : callsList) {
            if (String.isEmpty(call.Detailed_Products_vod__c) && !GNE_SFA2_Interaction_Trigger_Helper.isOtrRequest()) {
                String currentUserProfileName = GNE_SFA2_Util.getCurrentUserProfileName();
                if (locationProfileName.contains(currentUserProfileName) && call.Completed_gne__c == true) {
                    call.addError(Label.GNE_SFA2_ErrMsg_Interaction_Objectives_Specified);
                    call.Detailed_Products_vod__c.addError(Label.GNE_SFA2_ErrMsg_Interaction_Objectives_Specified);
                } else if (objectiveProfileName.contains(currentUserProfileName) && currentUserProfileName.contains('GNE-TLS')) {
                    call.addError(Label.GNE_SFA2_ErrMsg_Interaction_Objectives_Specified);
                    call.Detailed_Products_vod__c.addError(Label.GNE_SFA2_ErrMsg_Interaction_Objectives_Specified);
                }
                else if (objectiveProfileName.contains(currentUserProfileName) && !currentUserProfileName.contains('GNE-TLS')) {
                    call.addError(Label.GNE_SFA2_ErrMsg_Product_Discussion_Specified);
                    call.Detailed_Products_vod__c.addError(Label.GNE_SFA2_ErrMsg_Product_Discussion_Specified);
                }
            }
        }
    }

    private static void interactionLocationValidation(List<Call2_vod__c> callsList) {
        for (Call2_vod__c call : callsList) {
            if (String.isEmpty(call.Interaction_Location_gne__c) && locationProfileName.contains(GNE_SFA2_Util.getCurrentUserProfileName())) {
                call.Interaction_Location_gne__c.addError(Label.GNE_SFA2_ErrMsg_Interaction_Location_Required);
            }
        }
    }

    private static void interactionTypeValidation(List<Call2_vod__c> callsList) {
        for (Call2_vod__c call : callsList) {
            if (call.Interaction_Type_gne__c != 'Planned' && call.Account_Plan_vod__c != null) {
                call.Account_Plan_vod__c.addError(Label.GNE_SFA2_ErrMsg_FRM_Interaction_Type_Validation);
            }

            if (call.Interaction_Type_gne__c == '1:1' && !String.isEmpty(call.Group_Meeting_Topic_gne__c)) {
                call.Actual_Attendees_gne__c.addError(Label.GNE_SFA2_ErrMsg_Group_Meeting_Value);
            }
        }
    }

    private static void interactionCompletedValidation(List<Call2_vod__c> callsList) {
        for (Call2_vod__c call : callsList) {
            if (call.Completed_gne__c == true && call.Call_Datetime_vod__c != null
             && call.Call_Datetime_vod__c.date() > System.today().addDays(GNE_SFA2_Interaction_Trigger_Helper.isOtrRequest() ? 1 : 0)) {
                call.Completed_gne__c.addError(Label.GNE_SFA2_ErrMsg_Interaction_GNE_COMPLETED);
            }
        }
    }

    private static void interactionMealExpenseObjectiveValidation(List<Call2_vod__c> callsList) {
        for (Call2_vod__c call : callsList) {
            if (call.Meal_Expense_gne__c == true && String.isEmpty(call.Detailed_Products_vod__c)) {
                call.Detailed_Products_vod__c.addError(Label.GNE_SFA2_ErrMsg_AGS_Must_Have_Product);
            }
        }
    }

    private static void interactionMealExpLocationValidation(List<Call2_vod__c> callsList) {
        for (Call2_vod__c call : callsList) {
            if (call.Meal_Expense_gne__c == true && String.isEmpty(call.Interaction_Location_gne__c) && mealExpLocationProfileName.contains(GNE_SFA2_Util.getCurrentUserProfileName())) {
                call.Interaction_Location_gne__c.addError(Label.GNE_SFA2_ErrMsg_MedAffairs_Meal_Validation);
            }

            if (call.Meal_Expense_gne__c == true && String.isEmpty(call.Interaction_Location_gne__c) && !GNE_SFA2_Interaction_Trigger_Helper.isOtrRequest() && GNE_SFA2_Inter_Location_Nature_Profiles__c.getAll().containsKey(GNE_SFA2_Util.getCurrentUserProfileName())) {
                call.Interaction_Location_gne__c.addError(Label.GNE_SFA2_ErrMsg_Meal_Location_Validation);
            } 
        }
    }

    private static void interactionMealExpCityStateValidation(List<Call2_vod__c> callsList) {
        for (Call2_vod__c call : callsList) {
            if ( call.Meal_Expense_gne__c == true && mealExpCityStateProfileName.contains(GNE_SFA2_Util.getCurrentUserProfileName()) && (String.isEmpty(call.City_gne__c) || String.isEmpty(call.State_gne__c))) {
                if (String.isEmpty(call.City_gne__c)) {
                    call.City_gne__c.addError(Label.GNE_SFA2_ErrMsg_City_not_null_if_Meal_Exp_true);
                } else {
                    call.State_gne__c.addError(Label.GNE_SFA2_ErrMsg_City_not_null_if_Meal_Exp_true);
                }
            }
        }
    }

    private static void interactionProductValidation(List<Call2_vod__c> callsList) {
        if (!GNE_SFA2_RCanada_SkipProdValid_Profiles__c.getAll().keyset().contains(GNE_SFA2_Util.getCurrentUserProfileName().toUpperCase())) {
            for (Call2_vod__c call : callsList) {
                if (GNE_SFA2_Util.getCurrentUserProfileName().toUpperCase().contains('CANADA')) {
                    if (!String.isEmpty(call.Sample_Card_vod__c) && call.Completed_gne__c == false) {
                        call.addError(Label.GNE_SFA2_ErrMsg_With_Sample_Disbursement_Should_be_COMPLETED);
                    }
                    if (call.Completed_gne__c == true && String.isEmpty(call.Detailed_products_vod__c) && !GNE_SFA2_Util.isCanadaSAMUser() && !GNE_SFA2_Util.isCanadaRAMA() && !GNE_SFA2_Util.isCanadaINFUUser()) {
                        call.addError(Label.GNE_SFA2_ErrMsg_Completed_Call_Need_Atleast_one_Product);
                    }
                }
            }
        }
    }

    private static void interactionVisitDescriptionValidation(List<Call2_vod__c> callsList) {
        if (GNE_SFA2_Util.getCurrentUserProfileName().toUpperCase().contains('MEDAFFAIRS')) {
            for (Call2_vod__c call : callsList) {
                if (call.RecordType.Name != 'Meeting Brief_vod' && call.Primary_Interaction_Reason_gne__c == 'Proactive' && call.Visit_Reason_gne__c == 'Advice Seeking Meeting' && String.isEmpty(call.Visit_Reason_Description_gne__c)) {
                    call.addError(Label.GNE_SFA2_ErrMsg_VisitReasonDesc_Must_Be_Selected);
                }
            }
        }
    }

    private static void interactionAttendeeValidation(List<Call2_vod__c> callsList) {
        for (Call2_vod__c call : callsList) {
            if (call.Attendees_vod__c == null) {
                call.Attendees_vod__c = 0;
            }

            if (call.Meal_Expense_gne__c == true) {
                if (call.Planned_Attendees_gne__c == null || call.Planned_Attendees_gne__c < 1) {
                    call.Planned_Attendees_gne__c.addError(Label.GNE_SFA2_Planned_Attnd_Greater_1_Label);
                } else if (call.HCP_OR_Attendee_Meal_Opt_Out_gne__c == true && (call.Actual_Attendees_gne__c == null || call.Actual_Attendees_gne__c < 1)) {
                    call.Actual_Attendees_gne__c.addError(Label.GNE_SFA2_Actual_Attnd_Greater_0_Label);
                } else if (call.HCP_OR_Attendee_Meal_Opt_Out_gne__c == false && (call.Actual_Attendees_gne__c == null || call.Actual_Attendees_gne__c < 1 || call.Actual_Attendees_gne__c < call.Attendees_vod__c)) {
                    call.Actual_Attendees_gne__c.addError(Label.GNE_SFA2_Actual_Attnd_Greater_1_Label);
                }
            } else {
                if ((call.Planned_Attendees_gne__c != 0.0 && call.Planned_Attendees_gne__c != null) || (call.Actual_Attendees_gne__c != 0.0 && call.Actual_Attendees_gne__c != null)) {
                    call.Meal_Expense_gne__c.addError(Label.Meal_Expense_Required_Label);
                }
            }
        }
    }

    private static void beforeDeleteCallValidation(List<Call2_vod__c> triggerOld) {

        Profile userProfile = [SELECT PermissionsModifyAllData FROM Profile WHERE Id = : UserInfo.getProfileId() LIMIT 1];
        List<Id> callIds = new List<Id>();

        for (Call2_vod__c call : triggerOld) {
            if (call.Status_vod__c == 'Saved_vod' && (!String.isEmpty(call.Sample_Send_Card_vod__c) || !String.isEmpty(call.Sample_Card_vod__c))) {
                call.Status_vod__c.addError(Label.GNE_SFA2_Calls_with_submitted_disbursements_Error);
            }

            if (call.Signature_Date_vod__c != null && !userProfile.PermissionsModifyAllData) {
                call.Signature_Date_vod__c.addError(Label.Signed_Call_Delete_Lock_Label);
            }

            if (call.Status_vod__c == 'Submitted_vod' || call.Parent_Call_vod__r.Status_vod__c == 'Submitted_vod') {
                call.addError(Label.GNE_SFA2_Submitted_Call_Delete_Error);
            } else {
                callIds.add (call.Id);
            }
        }

        if (!callIds.isEmpty()) {
            try {
                List <Call2_vod__c> childCallsToDelete = [SELECT Id FROM Call2_vod__c WHERE Parent_Call_vod__c IN : callIds];
                if (!childCallsToDelete.isEmpty()) {
                    delete childCallsToDelete;
                }
            } catch (DMLException ex) {
                triggerOld.get(0).Id.addError(ex.getMessage());
            }
        }
    }

    private static void interactionVisitReasonValidation(List<Call2_vod__c> callsList) {
        if (GNE_SFA2_RCanadaVisitReasonMSL_Profiles__c.getAll().keyset().contains(GNE_SFA2_Util.getCurrentUserProfileName().toUpperCase())) {
            for (Call2_vod__c call : callsList) {
                if (call.Completed_gne__c && String.isBlank(call.Visit_Reason_RCanada_MSL_gne__c)) {
                    call.Visit_Reason_RCanada_MSL_gne__c.addError(Label.GNE_SFA2_ErrMsg_Interaction_Visit_Reason_Required);
                }
            }
        }
    }

    private static void interactionExternalReferralValidation(List<Call2_vod__c> callsList) {
        for (Call2_vod__c call : callsList) {
            if (call.Is_Referral_gne__c) {
                if (call.Referral_Requested_Date_gne__c == null) {
                    call.Referral_Requested_Date_gne__c.addError('Referral Requested Date: You must enter a value.');
                }
                if (String.isEmpty(call.Referral_Source_gne__c)) {
                    call.Referral_Source_gne__c.addError('Referral Source: You must enter a value.');
                }
                if (String.isEmpty(call.Referral_Requested_By_gne__c) && String.isNotEmpty(call.Referral_Source_gne__c) && (call.Referral_Source_gne__c.equalsIgnoreCase('TLL') || call.Referral_Source_gne__c.equalsIgnoreCase('MSL') || call.Referral_Source_gne__c.equalsIgnoreCase('Field Sales'))) {
                    call.Referral_Requested_By_gne__c.addError('Referral Requested By: You must enter a value.');
                }
                if (String.isNotEmpty(call.Referral_Source_gne__c) && call.Referral_Source_gne__c.equalsIgnoreCase('Other') && String.isEmpty(call.Other_Referral_Source_gne__c)) {
                    call.Other_Referral_Source_gne__c.addError('Other Referral Source: You must enter a value.');
                }
            }
        }
    }

    private static void interactionCustomerPresentValidation(List<Call2_vod__c> callsList) {
        if (GNE_SFA2_Interaction_Util.getIsMSLORMCLUser() == false) {
            return;
        }

        Set<Id> medAffairRecordTypes = new Set<Id>();
        for (Schema.RecordTypeInfo r : Call2_vod__c.SObjectType.getDescribe().getRecordTypeInfos()) {
            medAffairRecordTypes.add(r.getRecordTypeId());
        }

        for (Call2_vod__c call : callsList) {
            if (medAffairRecordTypes.contains(call.RecordTypeId) && call.Interaction_Type_gne__c == 'Group' && call.Customers_gne__c == null) {
                call.Customers_gne__c.addError(Label.GNE_SFA2_ErrMsg_Interaction_Customer_Present_ByGroup_Required);
            }
        }
    }
}