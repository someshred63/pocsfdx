public class GFRS_Ltng_Program_cntrl {
    @AuraEnabled
    public static gFRS_Ltng_Application__c fetchFundingReqDetails(String reqId){
        Id recId = Id.valueof(reqId);
        system.debug('Application Id is : '+recId);
        gFRS_Ltng_Application__c appRec = new gFRS_Ltng_Application__c();
        try{
            appRec = [SELECT Id, Name, What_are_you_seeking_funding_for__c, Target_audience__c, Organization__c, Information_Needed__c,
                      Sister_Parent_Org_Strategic_Promo_Mktg__c, Firewall_for_Strategic_Promo_Mktg__c, Preapplication__c,
                      Is_this_program_accredited__c, Org_the_Accreditor__c, Content_Development__c, Event_Program_Type__c,Event_program_sub_type__c,
                      Requested_Amount__c, Event_Program_Title__c, Therapeutic_Area__c, Disease_State__c,
                      Please_Specify_If_Disease_State_Other__c, Support_Purpose_Program_Description__c, Benefits_Exchanged_for_Funding__c,
                      Clinical_Practice_Guideline_Development__c, Associated_clinical_practice_guidelines__c,
                      Primary_Audience_Description__c, Addressed_by_this_Program_Initiative__c, Program_Objectives__c, Outcome_levels_to_be_achieved__c,
                      Other_Commercial_Supporters__c, If_known_List_Other_Supporters__c, Resubmission_of_Previous_Request__c, Resubmission_Request_Name__c,
                      Secondary_Invitations_BRC_s_Help_Request__c, Is_there_an_exhibit_opportunity_for_this__c, External_Tracking_Code__c, 
                      Opt_In_Process_for_Enduring_Materials__c, If_Yes_Please_Describe_Opt_In_Process__c, Will_You_be_Working_With_a_third_Party__c,Total_Overall_Budget__c,
                      Evaluation_Methodology__c, Unrestricted_Support_Request__c, Thank_You_Benifits__c, Non_Charitable_Amount__c,
                      Record_Type_Name__c, Print_Deadline__c, Print_Deadline_Date__c ,Funding_Sub_Type__c,Invite_Code__c
                      FROM gFRS_Ltng_Application__c WHERE Id =: recId];
            system.debug('Application record is : '+appRec);
            return appRec;
        }
        catch(Exception e){ 
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
    } 
    @AuraEnabled  
    public static List<picklistWrapper> getPicklistvalues(string objAPIName, string fieldAPIname) {        
        
        list<picklistWrapper> returnValue = new list<picklistWrapper>();
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objAPIName.toLowerCase()).getDescribe().fields.getMap();
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values = field_map.get(fieldAPIname).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            picklistWrapper aa = new picklistWrapper();
            aa.pickListLabel = a.getLabel();
            aa.pickListValue = a.getValue();
            returnValue.add(aa);
        }
        
        return returnValue;
        
    }
    
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        system.debug('controllingField' +controllingField);
        system.debug('dependentField' +dependentField);
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        system.debug('objType' +objType);
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    @AuraEnabled
    public static void saveProgram(gFRS_Ltng_Program__c objProgram , List<gFRS_Ltng_Program_Audience_Group__c> listAttdnee,String appId,String typeOfFunding){
       system.debug('ss'+objProgram);
        
        List<gFRS_Ltng_Program_Audience_Group__c> listAttd = new list<gFRS_Ltng_Program_Audience_Group__c>();
        
        Id programRcdTypeId;
        String recordtype;
        if(typeOfFunding =='Independent Medical Education (CME)'){
            recordtype ='CME-Program';
            if(objProgram.How_many_attendees_do_you_expect__c != '' && objProgram.How_many_attendees_do_you_expect__c != null){
                objProgram.Number_of_Attendees__c= Integer.valueOf(objProgram.How_many_attendees_do_you_expect__c);
            }
        }else if(typeOfFunding =='Community Giving'){
            recordtype ='Community Giving-Program';
            if(objProgram.How_many_attendees_do_you_expect__c != '' && objProgram.How_many_attendees_do_you_expect__c != null){
                objProgram.Number_of_Attendees__c= Integer.valueOf(objProgram.How_many_attendees_do_you_expect__c);
            }
        }else if(typeOfFunding =='Patient and Health Focused Giving'){
            recordtype ='Patient and Health FocusedProgram';
            if(objProgram.How_many_attendees_do_you_expect__c != '' && objProgram.How_many_attendees_do_you_expect__c != null){
                objProgram.Number_of_Attendees__c= Integer.valueOf(objProgram.How_many_attendees_do_you_expect__c);
            }
            
        }else if(typeOfFunding =='Scientific and Research Focused Giving'){
            recordtype ='Scientific and research focused program';
            if(objProgram.How_many_attendees_do_you_expect__c != '' && objProgram.How_many_attendees_do_you_expect__c != null){
                objProgram.Number_of_Attendees__c= Integer.valueOf(objProgram.How_many_attendees_do_you_expect__c);
            }
        }else if(typeOfFunding =='Education Focused Giving Graduate and Post-Graduate' ){
            recordtype ='Education focused giving program';
            if(objProgram.How_many_attendees_do_you_expect__c != '' && objProgram.How_many_attendees_do_you_expect__c != null){
                objProgram.Number_of_Attendees__c= Integer.valueOf(objProgram.How_many_attendees_do_you_expect__c);
            }
        }else if(typeOfFunding =='Education Focused Giving K-12'){
            recordtype ='Education Focused Giving K-12';
            if(objProgram.How_many_attendees_do_you_expect__c != '' && objProgram.How_many_attendees_do_you_expect__c != null){
                objProgram.Number_of_Attendees__c= Integer.valueOf(objProgram.How_many_attendees_do_you_expect__c);
            }
        } else if(typeOfFunding =='Foundation Undergraduate'){
            recordtype ='Foundation Undergraduate Program';
            if(objProgram.How_many_attendees_do_you_expect__c != '' && objProgram.How_many_attendees_do_you_expect__c != null){
                objProgram.Number_of_Attendees__c= Integer.valueOf(objProgram.How_many_attendees_do_you_expect__c);
            }
        }else if(typeOfFunding =='Foundation Safety Net Support'){
            recordtype ='Foundation Safety Net Support Program';
            if(objProgram.How_many_attendees_do_you_expect__c != '' && objProgram.How_many_attendees_do_you_expect__c != null){
                objProgram.Number_of_Attendees__c= Integer.valueOf(objProgram.How_many_attendees_do_you_expect__c);
            }
        }else if(typeOfFunding =='Field Exhibits'){
            recordtype ='Field Exhibits';
        }else if(typeOfFunding =='Corporate Memberships'){
            recordtype ='Corporate Memberships';
        }else if(typeOfFunding =='Commercial Sponsorship'){
            recordtype ='Commercial Sponsorship';
        }else if(typeOfFunding =='Non-Commercial Sponsorship'){
            recordtype ='Non-Commercial Sponsorship';
        }
        
        //gFRS_Ltng_Application__c gfrsApp=new gFRS_Ltng_Application__c();
        programRcdTypeId = Schema.SObjectType.gFRS_Ltng_Program__c.getRecordTypeInfosByName().get(recordtype).getRecordTypeId();
        system.debug('objProgram'+objProgram);
        system.debug('listAttdnee'+listAttdnee);
        system.debug('listAttdnee'+programRcdTypeId);
        system.debug('AppId'+appId);
        SavePoint sp = Database.setSavepoint();
        objProgram.gFRS_Application__c = appId;
        // objProgram.Selected_Tab_Val__c ='prgInfo';
        objProgram.RecordTypeId = programRcdTypeId;        
        try{
            //insert objProgram;
            gFRS_Ltng_Util_NoShare.updateProgram(objProgram);
        }
        catch(exception e){
            Database.rollback(sp);
            system.debug('@@@:::Msg:::'+e.getMessage());
            system.debug('@@@LineNum:::'+e.getLineNumber());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            system.debug('auraExceptionObj'+auraExceptionObj);
            throw auraExceptionObj; 
            
        }
        
        gFRS_Ltng_Compliance_Flag__c complFlag=[select id,gFRS_Application__c,gFRS_Program__c from gFRS_Ltng_Compliance_Flag__c WHERE gFRS_Application__c=:appId];
        
        complFlag.gFRS_Program__c=objProgram.Id;
        
        
        try{
            //update complFlag;
            gFRS_Ltng_Util_NoShare.updateComplianceFlagRec(complFlag);
        }
        catch(exception e){
            Database.rollback(sp);
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;  
        }
        
        if(typeOfFunding =='Independent Medical Education (CME)'){
            for(gFRS_Ltng_Program_Audience_Group__c progAudienObj : listAttdnee){
                progAudienObj.gFRS_Program__c=objProgram.id;
                listAttd.add(progAudienObj);
            }
            try{
                //insert listAttd;
                gFRS_Ltng_Util_NoShare.updatePgmAudGroupRec(listAttd);
            }
            catch(exception e){
                Database.rollback(sp);
                AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
                throw auraExceptionObj;  
            }
        }
        //PAR Approval Field Update in gFRS Application Object
        if(typeOfFunding =='Field Exhibits' || typeOfFunding =='Corporate Memberships' || typeOfFunding =='Commercial Sponsorship' || typeOfFunding =='Non-Commercial Sponsorship') {
            system.debug('ss');
            String idString;
            gFRS_Ltng_Application__c gfrsApp=[select id,name,Program_Venue_City__c from gFRS_Ltng_Application__c where id=:appId];
            if(objProgram.gFRS_Venue_City__c != null && objProgram.gFRS_Venue_City__c != ''){ 
                if(gfrsApp.Program_Venue_City__c ==null || gfrsApp.Program_Venue_City__c == ''){
                    gfrsApp.Program_Venue_City__c = objProgram.gFRS_Venue_City__c;
                }else{
                    gfrsApp.Program_Venue_City__c += ','+objProgram.gFRS_Venue_City__c;  
                }
                          system.debug('ss'+gfrsApp.Program_Venue_City__c);
  
            }
            try{
                //update gfrsApp;
                gFRS_Ltng_Util_NoShare.updateAppRecord(gfrsApp);
            }
            catch(exception e){
                Database.rollback(sp);
                AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
                throw auraExceptionObj;  
            }
        }
        System.debug('program obj@@@@'+objProgram);
        System.debug('listAttendee#####'+listAttdnee);
        
    }
        
    @AuraEnabled
    public static void updateProgramRecord(gFRS_Ltng_Program__c objProgram){
        SavePoint sp = Database.setSavepoint();
        //objProgram.Number_of_Attendees__c=Integer.valueOf(objProgram.How_many_attendees_do_you_expect__c);
        String finalVal;
        try{
            //update objProgram;
            
            gFRS_Ltng_Program__c programRec = [SELECT Id, Name, gFRS_Venue_City__c FROM gFRS_Ltng_Program__c WHERE Id =: objProgram.Id];
            gFRS_Ltng_Application__c gfrsApp=[select id,name,Program_Venue_City__c,Record_Type__c from gFRS_Ltng_Application__c where id=:objProgram.gFRS_Application__c];
            finalVal = gfrsApp.Program_Venue_City__c;
            if(gfrsApp.Record_Type__c =='Field Exhibits' || gfrsApp.Record_Type__c =='Corporate Memberships' || gfrsApp.Record_Type__c =='Commercial Sponsorship' || gfrsApp.Record_Type__c =='Non-Commercial Sponsorship') {
                String idString;
                system.debug('@@ before : '+gfrsApp.Program_Venue_City__c);
                system.debug('@@ Pgm City :'+objProgram.gFRS_Venue_City__c);
                if(gfrsApp.Record_Type__c !='Field Exhibits'){
                    objProgram.Number_of_Attendees__c=Integer.valueOf(objProgram.How_many_attendees_do_you_expect__c);
                }
                
                if(objProgram.gFRS_Venue_City__c !=null && objProgram.gFRS_Venue_City__c !=''){
                    String appStr = gfrsApp.Program_Venue_City__c;
                    string progStr=objProgram.gFRS_Venue_City__c;
                    
                    if(programRec.gFRS_Venue_City__c !=null && programRec.gFRS_Venue_City__c !=''){
                        finalVal = finalVal.replaceFirst( programRec.gFRS_Venue_City__c , progStr );
                    } else {
                        if(appStr !=null && appStr !=''){
                            finalVal += ',' + objProgram.gFRS_Venue_City__c;
                        } else {
                            finalVal = objProgram.gFRS_Venue_City__c;
                        }
                    }
                    
                    gfrsApp.Program_Venue_City__c = finalVal; 
                }
                system.debug('after '+gfrsApp.Program_Venue_City__c);
                //update gfrsApp;
                gFRS_Ltng_Util_NoShare.updateAppRecord(gfrsApp);
                gFRS_Ltng_Util_NoShare.updateProgram(objProgram);
        }
        }
        catch(exception e){
            Database.rollback(sp);
            system.debug('@@@:::Msg:::'+e.getMessage());
            system.debug('@@@LineNum:::'+e.getLineNumber());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            system.debug('auraExceptionObj'+auraExceptionObj);
            throw auraExceptionObj; 
            
        }
    }
    
    
    @AuraEnabled
    public static void updateProgram(gFRS_Ltng_Program__c objProgram , List<gFRS_Ltng_Program_Audience_Group__c> listAttdnee){
        List<gFRS_Ltng_Program_Audience_Group__c> listAttd = new list<gFRS_Ltng_Program_Audience_Group__c>();
        SavePoint sp = Database.setSavepoint();
        
        try{
            //update objProgram;
            gFRS_Ltng_Util_NoShare.updateProgram(objProgram);
        }
        catch(exception e){
            Database.rollback(sp);
            system.debug('@@@:::Msg:::'+e.getMessage());
            system.debug('@@@LineNum:::'+e.getLineNumber());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            system.debug('auraExceptionObj'+auraExceptionObj);
            throw auraExceptionObj; 
            
        }
        try{
            for(gFRS_Ltng_Program_Audience_Group__c progAudienObj : listAttdnee){
                //progAudienObj.gFRS_Program__c=objProgram.id;
                if(progAudienObj.Id == null){
                    progAudienObj.gFRS_Program__c=objProgram.id;
                }
                listAttd.add(progAudienObj);
            }
            upsert listAttdnee;
        }
        catch(exception e){
            Database.rollback(sp);
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;  
        }
    }
    
    @AuraEnabled
    public static void updatePatientProgram(gFRS_Ltng_Program__c objProgram , String appId){  
        List<gFRS_Ltng_Program__c> lstPrograrec = new List<gFRS_Ltng_Program__c>();
        gFRS_Ltng_Application__c appRec = new gFRS_Ltng_Application__c();
        try{
            appRec = [SELECT Id, Name, What_are_you_seeking_funding_for__c,Focus_Area__c                   
                      FROM gFRS_Ltng_Application__c WHERE Id =: appId];
            system.debug('Application record is : '+appRec);
            
        }
        catch(Exception e){ 
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
        System.debug('appId programs'+appId);
        List<gFRS_Ltng_Program__c> lstPrograms = [SELECT Id,gFRS_Program_Type__c,gFRS_Start_Date__c,gFRS_End_Date__c,gFRS_Venue_Name__c,gFRS_Venue_Country__c,
                                                  gFRS_Venue_City__c,gFRS_Venue_State__c,gFRS_Venue_Zip_Code__c,gFRS_Expected_number_of_attendees__c,
                                                  gFRS_Expected_of_Attendees_US_Based_HCPs__c,gFRS_Nbr_of_Grand_Round_Mtg_Series_Activ__c,gFRS_Number_of_speakers_faculty__c,
                                                  gFRS_Venue_Province_Region_Territory__c,gFRS_Venue_Type__c,gFRS_Program_Live_Subtype__c,gFRS_On_demand_Archived__c,gFRS_Live_Real_time__c,gFRS_Secondary_program_title__c,
                          
                                                  gFRS_Focus_Area__c,Do_designated_HCPs_have_the_appropriate__c,How_many_attendees_do_you_expect__c,Venue_associated_with_this_event_program__c,
                                                  gFRS_Sub_Focus_Area__c,What_thank_you_benefits_will_be_provid__c,gFRS_Expected_number_of_patients_served__c,Is_there_an_exhibit_opportunity_price__c,gFRS_Payment_to_a_Licensed_Physician__c,
                                                  gFRS_Focus_on_STEM_education__c,gFRS_Free_and_Reduced_Lunch__c,gFRS_Expected_number_of_teachers_engaged__c,gFRS_Expected_number_of_students_engaged__c,
                                                  gFRS_Criteria_to_Select_a_Fellow__c,gFRS_Fellowship_Opportunity_Publication__c,gFRS_Capacity_Building_Support_Expected__c,Financial_Assistance_Processes__c,Health_Screening_Broad_Audience__c,
                                                  Event_program_geographic_location__c,Scientific_Meeting_Broad_Audience__c,Title_1_school__c,Poc_teachers__c,PoC_youth_students__c,SubFocusArea__c  from gFRS_Ltng_Program__c Where gFRS_Application__c=:appId ORDER BY CreatedDate  ASC];
        System.debug('appId programs'+lstPrograms.size());
        if(lstPrograms.size()>1){
            for(gFRS_Ltng_Program__c objprog :lstPrograms){
                objprog.gFRS_Focus_Area__c = appRec.Focus_Area__c;
                lstPrograrec.add(objprog);
            }
        }
        System.debug('updated programs'+lstPrograrec);
        
        SavePoint sp = Database.setSavepoint();        
        try{
            update lstPrograrec;
        }
        catch(exception e){
            Database.rollback(sp);
            system.debug('@@@:::Msg:::'+e.getMessage());
            system.debug('@@@LineNum:::'+e.getLineNumber());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            system.debug('auraExceptionObj'+auraExceptionObj);
            throw auraExceptionObj; 
            
        }
        try{
            update objProgram;
        }
        catch(exception e){
            Database.rollback(sp);
            system.debug('@@@:::Msg:::'+e.getMessage());
            system.debug('@@@LineNum:::'+e.getLineNumber());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            system.debug('auraExceptionObj'+auraExceptionObj);
            throw auraExceptionObj; 
            
        }
    }
    @AuraEnabled
    public static List<gFRS_Ltng_Program__c> getPrograms(String appId){ 
        system.debug('appID###'+appId);
        try{
            return [SELECT Id,gFRS_Program_Type__c,name,gFRS_Program_Subtype__c,gFRS_Start_Date__c,gFRS_End_Date__c,gFRS_Venue_Name__c,gFRS_Venue_Country__c,Product_being_Promoted__c,Main_product_exhibited__c,
                    gFRS_Venue_City__c,gFRS_Venue_State__c,gFRS_Venue_Zip_Code__c,gFRS_Expected_number_of_attendees__c,gFRS_Application__r.Event_Program_Type__c,gFRS_Application__r.Event_program_sub_type__c,gFRS_Application__r.Benefits_Exchanged_for_Funding__c,
                    gFRS_Expected_of_Attendees_US_Based_HCPs__c,gFRS_Nbr_of_Grand_Round_Mtg_Series_Activ__c,gFRS_Number_of_speakers_faculty__c,Are_there_any_other_commercial_sponsors__c,
                    gFRS_Venue_Province_Region_Territory__c,gFRS_Venue_Type__c,gFRS_Web_URL__c,gFRS_Program_Live_Subtype__c,gFRS_On_demand_Archived__c,gFRS_Live_Real_time__c,gFRS_Secondary_program_title__c,
                    gFRS_Focus_Area__c,Do_designated_HCPs_have_the_appropriate__c,How_many_attendees_do_you_expect__c,Venue_associated_with_this_event_program__c,recordType.name,recordTypeId,
                    gFRS_Sub_Focus_Area__c,What_thank_you_benefits_will_be_provid__c,gFRS_Expected_number_of_patients_served__c,Is_there_an_exhibit_opportunity_price__c,gFRS_Payment_to_a_Licensed_Physician__c,
                    gFRS_Focus_on_STEM_education__c,gFRS_Free_and_Reduced_Lunch__c,gFRS_Expected_number_of_teachers_engaged__c,gFRS_Expected_number_of_students_engaged__c,Number_of_exhibit_tables_purchasing__c,
                    gFRS_Criteria_to_Select_a_Fellow__c,gFRS_Fellowship_Opportunity_Publication__c,gFRS_Capacity_Building_Support_Expected__c,Student_impact_by_program__c,Percentage_makeup_of_the_students_in_you__c,Start_Date_Formula__c,End_Date_Formula__c,
                    Financial_Assistance_Processes__c,Health_Screening_Broad_Audience__c,Public_Health_Other__c,Event_program_geographic_location__c,Scientific_Meeting_Broad_Audience__c,Title_1_school__c,Poc_teachers__c,PoC_youth_students__c,SubFocusArea__c,Number_of_Attendees__c,Health_Screening_Licensed_Personnel__c
                    from gFRS_Ltng_Program__c Where gFRS_Application__c=:appId ORDER BY CreatedDate  ASC];
        }
        catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    
    @AuraEnabled
    public static List<gFRS_Ltng_Program_Audience_Group__c> getProgramChilds(String progId){ 
        system.debug('appID###'+progId);
        try{
            return [SELECT Id,gFRS_Degree__c,gFRS_Specialty__c,gFRS_Credit_Type__c,gFRS_Credit_Hours__c,gFRS_Exp_Learners__c,
                    gFRS_Expected_Learners_With_Credit__c from gFRS_Ltng_Program_Audience_Group__c Where gFRS_Program__c=:progId];
        }
        catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    
    public static Integer getExistingProgramsByType(String deletedProgramType, Id applicationID){
        list<gFRS_Ltng_Program__c> programs = new list<gFRS_Ltng_Program__c>();
        try{
            programs = [SELECT Id, Name, gFRS_Program_Type__c FROM gFRS_Ltng_Program__c WHERE gFRS_Application__c =: applicationID];
            Integer programCountByType=0;
            for(gFRS_Ltng_Program__c prog: programs){
                if(prog.gFRS_Program_Type__c == deletedProgramType){
                    programCountByType++;
                    system.debug('Program Counter : '+programCountByType);
                }
            }
            return programCountByType;
        }
        catch(Exception e){ 
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
    }    
    
    @AuraEnabled
    public static void deleteProgram(List<gFRS_Ltng_Program__c> delProgRec, string appId, string pgmType){
        SavePoint sp = Database.setSavepoint();
        system.debug('Application Id : '+appId);
        system.debug('Pgm Type : '+pgmType);
        string finalVal;
        
        try{
            gFRS_Ltng_Application__c gfrsApp=[select id,name,Program_Venue_City__c,Record_Type__c from gFRS_Ltng_Application__c where id=:appId];
            if(gfrsApp.Record_Type__c =='Field Exhibits' || gfrsApp.Record_Type__c =='Corporate Memberships' || gfrsApp.Record_Type__c =='Commercial Sponsorship' || gfrsApp.Record_Type__c =='Non-Commercial Sponsorship') {
                String idString;
                system.debug('before'+gfrsApp.Program_Venue_City__c);
                for(gFRS_Ltng_Program__c prg:delProgRec){
                    if(prg.gFRS_Venue_City__c !=null && prg.gFRS_Venue_City__c !=''){
                        String appStr = gfrsApp.Program_Venue_City__c;
                        string progStr=prg.gFRS_Venue_City__c;
                        string replacestr=progStr;
                        finalVal=appStr.replace( replacestr , '' );
                        finalVal=finalVal.replace( ',,' , ',' );
                        finalVal = finalVal.removeStart(',');
                        gfrsApp.Program_Venue_City__c=finalVal;
                        
                    }
                }
                system.debug('after '+gfrsApp.Program_Venue_City__c);
                //update gfrsApp;
                gFRS_Ltng_Util_NoShare.updateAppRecord(gfrsApp);

            }
            //Delete delProgRec;
            gFRS_Ltng_Util_NoShare.deletePrograms(delProgRec);
            
            List<gFRS_Ltng_Request_Budget__c> potentialBudgetToDelete = new List<gFRS_Ltng_Request_Budget__c>();
            for(gFRS_Ltng_Request_Budget__c budget:[select Id, Type__c from gFRS_Ltng_Request_Budget__c where gFRS_Application__c = : appId]){
                if(budget.Type__c == pgmType ){
                    system.debug('Has budgets under this PGM');
                    potentialBudgetToDelete.add(budget);
                }
            }
            
            if(getExistingProgramsByType(pgmType, appId) == 0 && potentialBudgetToDelete.size()>0){
                system.debug('Deleting the budgets');
                Delete potentialBudgetToDelete;
            }             
            
        }
        catch(Exception e){
            
            Database.rollback(sp);
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }   
    
    @AuraEnabled
    public static List<gFRS_Ltng_Request_Budget__c> createBudgetRecords(string appId){ 
        SavePoint sp = Database.setSavepoint();
        gFRS_Ltng_Application__c gfrsApp =new gFRS_Ltng_Application__c();
        try{
            Boolean hasLiveBudget = false;
            Boolean hasWebinarBudget = false;
            Boolean hasEnduringBudget = false;
            String liveBudget = 'Live (in-person)';
            String enduringBudget = 'Digital or Printed Resources';
            String webBudget = 'Virtual (online)';
            Map<String, Boolean> mapExistingBudgets;
            mapExistingBudgets = new Map<String, Boolean>{
                liveBudget => false,
                    webBudget => false,
                    enduringBudget => false
                    };
                        
                        list<gFRS_Ltng_Request_Budget__c> fundingRequestBudgets = new list<gFRS_Ltng_Request_Budget__c>();
            fundingRequestBudgets = [
                SELECT Id, Name, Total_Amount__c, Budget_Summary_Description__c, Request_Delivery_Format__c,
                Type__c, Request_Name__c
                FROM gFRS_Ltng_Request_Budget__c
                WHERE gFRS_Application__c = :appId
            ];
            
            if(fundingRequestBudgets.size() > 0){
                for (gFRS_Ltng_Request_Budget__c b : fundingRequestBudgets) {
                    if (mapExistingBudgets.containsKey(b.Type__c)) {
                        mapExistingBudgets.put(b.Type__c, true);
                    }
                }                
            }
            
            list<gFRS_Ltng_Program__c> programs = new list<gFRS_Ltng_Program__c>();
            programs = [SELECT Id, gFRS_Program_Type__c FROM gFRS_Ltng_Program__c WHERE gFRS_Application__c =: appId];
            
            for (gFRS_Ltng_Program__c p : programs) {
                system.debug('in Pgm Loop');
                if (p.gFRS_Program_Type__c == webBudget && !mapExistingBudgets.get(webBudget)) {
                    hasWebinarBudget = true;
                    system.debug('has web Pgm');
                }
                if (p.gFRS_Program_Type__c == enduringBudget && !mapExistingBudgets.get(enduringBudget)) {
                    hasEnduringBudget = true;
                    system.debug('has enduring Pgm');
                }
                if (p.gFRS_Program_Type__c == liveBudget && !mapExistingBudgets.get(liveBudget)) {
                    hasLiveBudget = true;
                    system.debug('has Live Pgm');
                }
            }            
            
            gFRS_Ltng_Request_Budget__c liveBudgetRec = null;
            gFRS_Ltng_Request_Budget__c webinarBudgetRec = null;
            gFRS_Ltng_Request_Budget__c enduringBudgetRec = null;
            
            gFRS_Ltng_Request_Budget__c[] lBudgetsToInsert = new gFRS_Ltng_Request_Budget__c[]{};
                
                //-- save the budgets
                if (hasLiveBudget == true) {
                    liveBudgetRec = new gFRS_Ltng_Request_Budget__c(Budget_Summary_Description__c = 'Budget for Live Activity', gFRS_Application__c = appId, Type__c = liveBudget);
                    lBudgetsToInsert.add(liveBudgetRec);
                    system.debug('live Budget add');
                }
            if (hasWebinarBudget == true) {
                webinarBudgetRec = new gFRS_Ltng_Request_Budget__c(Budget_Summary_Description__c = 'Budget for virtual Activity', gFRS_Application__c = appId, Type__c = webBudget);
                lBudgetsToInsert.add(webinarBudgetRec);
                system.debug('web Budget add');
            }
            if (hasEnduringBudget == true) {
                enduringBudgetRec = new gFRS_Ltng_Request_Budget__c(Budget_Summary_Description__c = 'Budget for Enduring Activity', gFRS_Application__c = appId, Type__c = enduringBudget);
                lBudgetsToInsert.add(enduringBudgetRec);
                system.debug('enduring Budget add');
            }
            
            gfrsApp.id=appId;
            gfrsApp.Selected_Tab_Val__c='bgtInfo';
            gFRS_Ltng_Util_NoShare.updateGfrsAPP(gfrsApp);
            //update gfrsApp;
            upsert lBudgetsToInsert;
            
            return [Select id,name,Total_Amount__c,Type__c,gFRS_Application__c,(Select id,Category__c,Subcategory__c,Amount__c,Count__c,Explanation__c,gFRS_Request_Budget__c From FRS_Request_Budget_Line_Items__r) 
                    From gFRS_Ltng_Request_Budget__c Where gFRS_Application__c=:appId];
            
            
        }
        catch(Exception e){
            
            Database.rollback(sp);
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }       
    
    @AuraEnabled
    public static void deleteAttendees(List<gFRS_Ltng_Program_Audience_Group__c> attendeeRec){
        SavePoint sp = Database.setSavepoint();
        try{
        if(attendeeRec.size()>0){
            Delete attendeeRec;
            }
        }
        catch(Exception e){
            
            Database.rollback(sp);
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }   
    
    @AuraEnabled
    public static void deleteProgram(string appId){
        List<gFRS_Ltng_Program__c> delProgRec =[select id,Name from gFRS_Ltng_Program__c where gFRS_Application__c=:appId];
        SavePoint sp = Database.setSavepoint();
        system.debug('Application Id : '+appId);
        try{
            //Delete delProgRec;
            gFRS_Ltng_Util_NoShare.deletePrograms(delProgRec);
        }catch(Exception e){
            system.debug('@@ Into Catch block::::');
            
            system.debug('@@ Excep::'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
            //return null;
        }
    }
    
    public class PicklistEntryWrapper{
        public String isVisible {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }
    
    public class picklistWrapper{
        @AuraEnabled 
        public string pickListLabel{get;set;}
        @AuraEnabled 
        public string pickListValue{get;set;}
        
    }
    @AuraEnabled
    public static void updateGeneralPublic(string reqId,string genpub,string appexibit){
        System.debug('-reqId->'+reqId);
        System.debug('-genpub->'+genpub);
        gFRS_Ltng_Application__c gapp=[SELECT id,Open_to_public__c,Is_there_an_exhibit_opportunity_for_this__c FROM gFRS_Ltng_Application__c WHERE id=:reqId];
        gapp.Open_to_public__c=genpub;
        gapp.Is_there_an_exhibit_opportunity_for_this__c=appexibit;
        System.debug('-->');
        try{
            update gapp;
        }catch(Exception e){
            
            
            system.debug('@@ Excep::'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
            //return null;
        }
    }
    
}