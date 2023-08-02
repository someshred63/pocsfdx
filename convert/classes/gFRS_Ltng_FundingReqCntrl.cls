public class gFRS_Ltng_FundingReqCntrl {
   @AuraEnabled
    public static gFRS_Ltng_Application__c getCurrentFundingReqDetails(String objAPIName){
        system.debug('@@ App Id : '+objAPIName);
        Id rId = Id.valueOf(objAPIName);
        DescribeSObjectResult describeResult = rId.getSObjectType().getDescribe();      
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );	
        fieldNames.add('Organization__r.gFRS_Record_Type__c');
        fieldNames.add('Organization__r.Owner.Profile.Name');
        fieldNames.add('Organization__r.Tax_Id__c');
        String query =	  ' SELECT ' +	      String.join( fieldNames, ',' ) +	  ' FROM ' +	      describeResult.getName() +	  ' WHERE ' +	      ' id = :rId ' +	  ' LIMIT 1 '	;	
        // return generic list of sobjects or typecast to expected type	List<SObject> records = Database.query( query );
        gFRS_Ltng_Application__c ss=Database.query( query );
        return ss;
    
    }
    
    /*@AuraEnabled
    public static ApplicationInfo getApplicationPhaseStatus(Id reqId) {
		List<gFRS_Ltng_Application__c> reviewList  = [SELECT Id,Name,Status__c from gFRS_Ltng_Application__c Where (Status__c = 'Compliance' OR Status__c = 'Decision') and Id=:reqId];
        //gFRS_Ltng_Application__c request = fetchApplicationReq(reqId);
        ApplicationInfo info = new ApplicationInfo();
        if(reviewList.size() > 0){
            info.phase = 'Under';
        }
        return info;
    }
    public class ApplicationInfo {
        @AuraEnabled
        public String phase {get; set;}
    }*/
    
    @AuraEnabled
    public static string getApplicationPhaseStatus(Id reqId) {

        List<gFRS_Ltng_Application__c> reviewList  = [SELECT Id,Name,Status__c from gFRS_Ltng_Application__c Where (Status__c = 'Compliance' OR Status__c = 'Decision') AND Sub_Status__c !='RFI Sent' and Id=:reqId];
        List<gFRS_Ltng_Application__c> rfiList  = [SELECT Id,Name,Status__c from gFRS_Ltng_Application__c Where ((Status__c = 'Compliance' OR Status__c = 'Decision') AND Sub_Status__c ='RFI Sent') and Id=:reqId];
        List<gFRS_Ltng_Application__c> intPaymentList = [SELECT Id,Name,Status__c,Record_Type__c from gFRS_Ltng_Application__c Where Status__c = 'Processing & Disposition' and Sub_Status__c = 'Approved-Awaiting LOA' and (Record_Type__c='Field Exhibits' OR Record_Type__c='Corporate Memberships' OR Record_Type__c='Commercial Sponsorship' OR Record_Type__c='Non-Commercial Sponsorship')];
        List<gFRS_Ltng_Application__c> paymentList = [SELECT Id,Name,Status__c,LOA_Signed__c,(select Id,Name,Status__c from FRS_Payment_Historys__r) from gFRS_Ltng_Application__c Where (Status__c = 'Processing & Disposition') and Id IN (SELECT gFRS_Application__c FROM gFRS_Ltng_Payment_History__c where SAP_Payment_Document_ID__c ='') and LOA_Signed__c='Yes' and Id=:reqId];
        List<gFRS_Ltng_Application__c> draftList = [SELECT Name,Record_Type_Name__c,Sub_Status__c,Event_Program_Title__c,Selected_Tab_Val__c from gFRS_Ltng_Application__c 	Where (Sub_Status__c = 'Not Submitted' and Event_Program_Title__c !=null and Selected_Tab_Val__c != null) and Id=:reqId];
        
        List<gFRS_Ltng_Application__c> compGenIncList				=[SELECT Id,Name,Record_Type_Name__c,LOA_Signed__c from gFRS_Ltng_Application__c Where (Record_Type_Name__c !='Foundation Safety Net Support' AND Record_Type_Name__c !='Foundation Undergraduate') and   Id IN (SELECT gFRS_Application__c FROM gFRS_Ltng_Payment_History__c where SAP_Payment_Document_ID__c !='') and LOA_Signed__c='Yes' and Id=:reqId];
        List<gFRS_Ltng_Application__c> compGenIncList_notFunded 	=[SELECT Id,Name,Record_Type_Name__c,Status__c,Sub_Status__c from gFRS_Ltng_Application__c Where (Record_Type_Name__c !='Foundation Safety Net Support' AND Record_Type_Name__c !='Foundation Undergraduate') and (Status__c = 'Closed' and (Sub_Status__c ='Canceled' OR Sub_Status__c ='Denied')) and Id=:reqId];
        List<gFRS_Ltng_Application__c> compGenFounList 				=[SELECT Id,Name,Record_Type_Name__c,Status__c,Sub_Status__c from gFRS_Ltng_Application__c Where (Record_Type_Name__c ='Foundation Safety Net Support' or Record_Type_Name__c ='Foundation Undergraduate') and (Status__c = 'Closed' and (Sub_Status__c ='Approved')) and Id=:reqId];
        List<gFRS_Ltng_Application__c> compGenFounList_notFunded 	=[SELECT Id,Name,Record_Type_Name__c,Status__c,Sub_Status__c from gFRS_Ltng_Application__c Where (Record_Type_Name__c ='Foundation Safety Net Support' or Record_Type_Name__c ='Foundation Undergraduate') and (Status__c = 'Closed' and (Sub_Status__c ='Canceled' OR Sub_Status__c ='Denied')) and Id=:reqId];
        List<gFRS_Ltng_Application__c> compIntList 					=[SELECT Id,Name,Record_Type_Name__c,Status__c,Sub_Status__c from gFRS_Ltng_Application__c Where ((Status__c = 'Closed' and Sub_Status__c ='Approved') or (Status__c = 'Processing & Disposition' and Sub_Status__c ='Process Payment')) and Id=:reqId];
        List<gFRS_Ltng_Application__c> compIntList_notFunded 		=[SELECT Id,Name,Record_Type_Name__c,Status__c,Sub_Status__c from gFRS_Ltng_Application__c Where (Status__c = 'Closed' and (Sub_Status__c ='Canceled' OR Sub_Status__c ='Denied')) and Id=:reqId];
        
        string PhaseStatus;
        //Integer size = reviewList.size();
        //system.debug('size : '+size);
        if (reviewList.size() > 0) {	PhaseStatus = 'Under Review';	}
        else if (rfiList.size() > 0) {	PhaseStatus = 'Under Review - RFI';	}
        else if (draftList.size() > 0) {	PhaseStatus = 'Draft';	}
        else if (intPaymentList.size() > 0 || paymentList.size() > 0) {	PhaseStatus = 'Payment Pending';	}
        else if (compGenIncList.size() > 0 || compGenIncList_notFunded.size() > 0 || 
            compGenFounList.size() > 0 || compGenFounList_notFunded.size() > 0 || 
            compIntList.size() > 0 || compIntList_notFunded.size() > 0) {	PhaseStatus = 'Completed';	}
        //system.debug('PhaseStatus : '+PhaseStatus);
        return PhaseStatus;
        //return 'Under Review';
        
    }

    @AuraEnabled
    public static gFRS_Ltng_Application__c fetchFundingReqDetails(String reqId){
        Id recId = Id.valueof(reqId);
        system.debug('Application Id is : '+recId);
        gFRS_Ltng_Application__c appRec = new gFRS_Ltng_Application__c();
        appRec = [SELECT Id, Name, What_are_you_seeking_funding_for__c, Target_audience__c, Organization__c, Information_Needed__c,
                  Sister_Parent_Org_Strategic_Promo_Mktg__c, Firewall_for_Strategic_Promo_Mktg__c, 
                  Is_this_program_accredited__c, Org_the_Accreditor__c, Content_Development__c, 
                  Requested_Amount__c, Event_Program_Title__c, Therapeutic_Area__c, Disease_State__c,
                  Please_Specify_If_Disease_State_Other__c, Support_Purpose_Program_Description__c, 
                  Clinical_Practice_Guideline_Development__c, Associated_clinical_practice_guidelines__c,
                  Primary_Audience_Description__c, Addressed_by_this_Program_Initiative__c, Program_Objectives__c, Outcome_levels_to_be_achieved__c,
                  Other_Commercial_Supporters__c, If_known_List_Other_Supporters__c, Resubmission_of_Previous_Request__c, Resubmission_Request_Name__c,
                  Secondary_Invitations_BRC_s_Help_Request__c, Is_there_an_exhibit_opportunity_for_this__c, External_Tracking_Code__c, 
                  Opt_In_Process_for_Enduring_Materials__c, If_Yes_Please_Describe_Opt_In_Process__c, Will_You_be_Working_With_a_third_Party__c,Total_Overall_Budget__c,
                  Evaluation_Methodology__c, Unrestricted_Support_Request__c, Thank_You_Benifits__c, Non_Charitable_Amount__c,
                  Record_Type_Name__c, Print_Deadline__c, Print_Deadline_Date__c ,Funding_Sub_Type__c,Multi_year_grant__c,Request_Cloned__c
                  FROM gFRS_Ltng_Application__c WHERE Id =: recId];
        system.debug('Application record is : '+appRec);
        return appRec;
        
    } 
    
    /*
Method Name: createOrUpdRequest
Description: This method helps in updating Application Record.
*/
    @AuraEnabled
    public static gFRS_Ltng_Application__c createOrUpdRequest(gFRS_Ltng_Application__c appInfoRec){
        
        system.debug('@@@::OBJECT::ID:'+appInfoRec.Id);
        system.debug('@@@::OBJECT:::'+appInfoRec); 

        appInfoRec.Selected_Tab_Val__c = 'reqInfo';
        
        try{
            
            if(appInfoRec.Sister_Parent_Org_Strategic_Promo_Mktg__c != null && appInfoRec.Sister_Parent_Org_Strategic_Promo_Mktg__c != ''){

                gFRS_Ltng_Organization__c updateOrg = new gFRS_Ltng_Organization__c();

                updateOrg.Id = appInfoRec.Organization__c;

                updateOrg.gFRS_Sis_Parent_Org_Strategic_Promo_Mktg__c = appInfoRec.Sister_Parent_Org_Strategic_Promo_Mktg__c;
                if(appInfoRec.Sister_Parent_Org_Strategic_Promo_Mktg__c == 'No'){
                    updateOrg.gFRS_Firewall_for_Strategic_Promo_Mktg__c = null;
                } else {
                    updateOrg.gFRS_Firewall_for_Strategic_Promo_Mktg__c = appInfoRec.Firewall_for_Strategic_Promo_Mktg__c;                
                }
                
                update updateOrg;
                
            }            
            
            //Database.UpsertResult srList = Database.upsert(appInfoRec,false);
            gFRS_Ltng_Util_NoShare.updateGfrsAPP(appInfoRec);
            //system.debug('@@@ Database:::' + srList);
            //if(srList.isSuccess()){
                system.debug('@@@@:::Value of upsert record:::' + appInfoRec);
                system.debug('@@@@:::Value of upsert ID:::' + appInfoRec.id);
                
                if(appInfoRec.Will_You_be_Working_With_a_third_Party__c == 'No'){
                    list<gFRS_Ltng_Third_Party__c> thrdPartyRecs = new list<gFRS_Ltng_Third_Party__c>();
                    thrdPartyRecs = [SELECT Id, Name FROM gFRS_Ltng_Third_Party__c WHERE gFRS_Application__c =: appInfoRec.id];
                    system.debug('Inside Third party record check : ' + thrdPartyRecs.size());
                    if(thrdPartyRecs.size() > 0){
                        gFRS_Ltng_Util_NoShare.deleteThirdParty(thrdPartyRecs);
                    }
                }
                
               // Id recID = srList.getId();
                Id recID = appInfoRec.id;
                
                gFRS_Ltng_Application__c appRecord = [SELECT Id, Name FROM gFRS_Ltng_Application__c WHERE Id =: recID];
                return appRecord;
           // }else{
               // return null;
            //}
            
        }
        catch(Exception e){
            system.debug('@@ Into Catch block::::');
            
            system.debug('@@ Excep::'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
            //return null;
        }
        
    }
 @AuraEnabled
    public static List<gFRS_Ltng_Request_Budget__c > getCurrentBudgetReqDetails(String appRecId){
        Id rId = appRecId;        
        try{
        List<gFRS_Ltng_Request_Budget__c> listBudgets=[Select id,Name,Total_Amount__c,Type__c,gFRS_Application__c,(Select id,Category__c,Subcategory__c,Amount__c,Count__c,Explanation__c,gFRS_Request_Budget__c From FRS_Request_Budget_Line_Items__r) 
                    From gFRS_Ltng_Request_Budget__c Where gFRS_Application__c=:rId];
        system.debug('budgetrec'+listBudgets);
         return listBudgets;
 
        }
        catch(exception e){
            system.debug('exception'+e.getMessage());
            return null;
        }
    }
    @AuraEnabled  
    public static List<string> getPicklistvalues(string objAPIName, string fieldAPIname) {        
        list<string> options = new List<string>();
       // list<picklistWrapper> returnValue = new list<picklistWrapper>();
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objAPIName.toLowerCase()).getDescribe().fields.getMap();
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values = field_map.get(fieldAPIname).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {           
            options.add(a.getValue());
            
        }
        
        return options;
        
    } 
    
    
}