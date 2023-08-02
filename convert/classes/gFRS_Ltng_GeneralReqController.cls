/*****************************************************************************************************************************
CLASS NAME : gFRS_Ltng_GeneralReqController
DESCRIPTION: 

DATE            DEVELOPER           PURPOSE
-----------------------------------------------------------------------------------------------------------------------------
09-Sep-2020     Sudhakar            Created as controller class for gFRS_Ltng_General_Request component.

******************************************************************************************************************************/

public without sharing class gFRS_Ltng_GeneralReqController {
    /*
Method Name:createRequest
Description: This method helps in creating Application Record.
*/
    @AuraEnabled
    public static gFRS_Ltng_Application__c createOrUpdRequest(gFRS_Ltng_Application__c appInfoRec){
        
        Id appRcdTypeId;
        system.debug('@@@::OBJECT::ID:'+appInfoRec.Id);
        system.debug('@@@::OBJECT:::'+appInfoRec.Primary_Audience__c); 
        
        //appRcdTypeId = Schema.SObjectType.gFRS_Ltng_Application__c.getRecordTypeInfosByName().get('Independent Medical Education (CME)').getRecordTypeId();
        //appInfoRec.RecordTypeId = appRcdTypeId;
        //if(appInfoRec.Will_You_be_Working_With_a_third_Party__c =='Yes'){
        //    appInfoRec.Selected_Tab_Val__c='thrdPartyDetls';
        // }else{
        
        appInfoRec.Selected_Tab_Val__c='prgInfo';  
        
        
        // }
        try{
            if(appInfoRec.Sister_Parent_Org_Strategic_Promo_Mktg__c != null && appInfoRec.Sister_Parent_Org_Strategic_Promo_Mktg__c != ''){
                system.debug('appInfoRec.Organization__c'+appInfoRec.Organization__c);
                gFRS_Ltng_Organization__c updateOrg=new gFRS_Ltng_Organization__c();
                system.debug('appInfoRec.Organization__c'+appInfoRec.Organization__c);
                updateOrg.Id=appInfoRec.Organization__c;
                // updateOrg.gFRS_Strategic_Promo_Mkt_Rltd_Services__c=appInfoRec.Strategic_Promo_Mkt_Related_Services__c;                
                updateOrg.gFRS_Sis_Parent_Org_Strategic_Promo_Mktg__c=appInfoRec.Sister_Parent_Org_Strategic_Promo_Mktg__c;
                if(appInfoRec.Sister_Parent_Org_Strategic_Promo_Mktg__c == 'No'){
                    updateOrg.gFRS_Firewall_for_Strategic_Promo_Mktg__c = null;
                } else {
                    updateOrg.gFRS_Firewall_for_Strategic_Promo_Mktg__c=appInfoRec.Firewall_for_Strategic_Promo_Mktg__c;                
                }
                
                update updateOrg;     
                
                
            }
            
            //Database.UpsertResult srList = Database.upsert(appInfoRec,false);
            Database.UpsertResult srList = gFRS_Ltng_Util_NoShare.updateAppRec(appInfoRec);
            system.debug('@@@ Database:::' + srList);
            if(srList.isSuccess()){
                
                system.debug('@@@@:::Value of upsert record:::' + appInfoRec);
                system.debug('@@@@:::Value of upsert ID:::' + appInfoRec.id);
                Id recID = srList.getId();
                
                list<gFRS_Ltng_Compliance_Flag__c> listComplFlag = new list<gFRS_Ltng_Compliance_Flag__c>();
                
                listComplFlag = [SELECT Id, name FROM gFRS_Ltng_Compliance_Flag__c WHERE gFRS_Application__c =: recID];
                
                if(listComplFlag.size() > 0){
                    //nothing to do
                } else {
            //    gFRS_Ltng_Program__c gfrsProgram=[select id,gFRS_Application__c from gFRS_Ltng_Program__c where gFRS_Application__c=:recID LIMIT 1];
                    gFRS_Ltng_Compliance_Flag__c complFlag = new gFRS_Ltng_Compliance_Flag__c();
                    complFlag.gFRS_Application__c = recID;
                    complFlag.Organization__c = appInfoRec.Organization__c;
                 
                    insert complFlag;                    
                }
                gFRS_Ltng_Application__c appRec = [SELECT Id, Name, Benefits_Exchanged_for_Funding__c FROM gFRS_Ltng_Application__c WHERE Id =: appInfoRec.Id];
                if(gFRS_Ltng_Util.isInternalRequest(appInfoRec.Record_Type__c)){
                    if(appInfoRec.Event_program_sub_type__c != 'International' ){
                        List<gFRS_Ltng_Program__c> pgmList = new List<gFRS_Ltng_Program__c>();
                        pgmList = [SELECT Id, Name, gFRS_Program_Type__c, gFRS_Venue_Name__c, gFRS_Venue_City__c, gFRS_Venue_State__c, gFRS_Venue_Zip_Code__c, gFRS_Venue_Country__c, gFRS_Venue_Province_Region_Territory__c, gFRS_Web_URL__c, How_many_attendees_do_you_expect__c, gFRS_Expected_of_Attendees_US_Based_HCPs__c, Main_product_exhibited__c, Product_being_Promoted__c FROM gFRS_Ltng_Program__c WHERE gFRS_Application__c =: appInfoRec.Id];
                        
                        if(pgmList.size() > 0){
                            for(gFRS_Ltng_Program__c pgm : pgmList){
                                pgm.gFRS_Expected_of_Attendees_US_Based_HCPs__c = null;

                                if(appInfoRec.Record_Type__c == 'Corporate Memberships' && !appRec.Benefits_Exchanged_for_Funding__c.contains('Exhibit space')){
                                    pgm.gFRS_Program_Type__c                        = '';
                                    pgm.gFRS_Venue_Name__c                          = '';
                                    pgm.gFRS_Venue_City__c                          = '';
                                    pgm.gFRS_Venue_State__c                         = '';
                                    pgm.gFRS_Venue_Zip_Code__c                      = null;
                                    pgm.gFRS_Venue_Country__c                       = '';
                                    pgm.gFRS_Venue_Province_Region_Territory__c     = '';
                                    pgm.gFRS_Web_URL__c                             = '';
                                    pgm.How_many_attendees_do_you_expect__c         = '';
                                    pgm.Main_product_exhibited__c                   = '';
                                    pgm.Product_being_Promoted__c                   = '';
                                }
                            }
                            gFRS_Ltng_Util_NoShare.updatePrograms(pgmList);
                        }
                    }
                    
                    /* if((appInfoRec.Record_Type__c == 'Corporate Memberships' || appInfoRec.Record_Type__c == 'Commercial Sponsorship') && appInfoRec.Benefits_Exchanged_for_Funding__c.indexOf('Exhibit space') == -1){
                        List<gFRS_Ltng_Program__c> programList = new List<gFRS_Ltng_Program__c>();
                        programList = [SELECT Id, Name, gFRS_Program_Type__c, gFRS_Venue_Name__c, gFRS_Venue_City__c, gFRS_Venue_State__c, gFRS_Venue_Zip_Code__c, gFRS_Venue_Country__c, gFRS_Venue_Province_Region_Territory__c, gFRS_Web_URL__c, How_many_attendees_do_you_expect__c, gFRS_Expected_of_Attendees_US_Based_HCPs__c, Main_product_exhibited__c, Product_being_Promoted__c FROM gFRS_Ltng_Program__c WHERE gFRS_Application__c =: appInfoRec.Id];
                        if(programList.size() > 0){
                            for(gFRS_Ltng_Program__c pgm : programList){
                                pgm.gFRS_Program_Type__c                        = '';
                                pgm.gFRS_Venue_Name__c                          = '';
                                pgm.gFRS_Venue_City__c                          = '';
                                pgm.gFRS_Venue_State__c                         = '';
                                pgm.gFRS_Venue_Zip_Code__c                      = null;
                                pgm.gFRS_Venue_Country__c                       = '';
                                pgm.gFRS_Venue_Province_Region_Territory__c     = '';
                                pgm.gFRS_Web_URL__c                             = '';
                                pgm.How_many_attendees_do_you_expect__c         = '';
                                pgm.gFRS_Expected_of_Attendees_US_Based_HCPs__c = null;
                                pgm.Main_product_exhibited__c                   = '';
                                pgm.Product_being_Promoted__c                   = '';
                            }
                            gFRS_Ltng_Util_NoShare.updatePrograms(programList);
                        }
                    } */
                }
                
                gFRS_Ltng_Application__c appRecord = [SELECT Id, Name, Selected_Tab_Val__c, Focus_Area__c FROM gFRS_Ltng_Application__c WHERE Id =: recID];
                return appRecord;
            }else{
                system.debug('@@@ Error while updating request');
                for(Database.Error err : srList.getErrors()) {
                    System.debug('@@@ The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('@@@ fields that affected this error: ' + err.getFields());
                }                
                return null;
            }
            
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
    public static void UpdateRFIRequest(gFRS_Ltng_Application__c appInfoRec){
        //system.debug('appInfoRec'+appInfoRec.Id);
        gFRS_Ltng_Util_NoShare.updateGfrsAPP(appInfoRec);
    }
    @AuraEnabled
    public static gFRS_Ltng_Application__c createOrUpdComplianceFlagRequest(String RecordId,string orgId){
        
        
        try{
            gFRS_Ltng_Application__c appInfoRec =[select id,Sister_Parent_Org_Strategic_Promo_Mktg__c,Record_Type__c,Will_You_be_Working_With_a_third_Party__c,Firewall_for_Strategic_Promo_Mktg__c,Strategic_Promo_Mkt_Related_Services__c,Organization__c from gFRS_Ltng_Application__c WHERE Id =: RecordId];
            if(appInfoRec.Record_Type__c =='Independent Medical Education (CME)'){
                system.debug(appInfoRec.Will_You_be_Working_With_a_third_Party__c);
                if(appInfoRec.Will_You_be_Working_With_a_third_Party__c == 'No'){
                        list<gFRS_Ltng_Third_Party__c> gfThirdParty=[select id,gFRS_Application__c from gFRS_Ltng_Third_Party__c where gFRS_Application__c =:RecordId];
                        system.debug('gfThirdParty'+gfThirdParty);
                    if(gfThirdParty.size()>0){
                        system.debug('inside');
                            delete gfThirdParty;
                        }
                        system.debug('gfThirdPartyafter'+gfThirdParty);

                    }
                if(appInfoRec.Sister_Parent_Org_Strategic_Promo_Mktg__c != null && appInfoRec.Sister_Parent_Org_Strategic_Promo_Mktg__c != ''){
                    
                    system.debug('appInfoRec.Organization__c'+appInfoRec.Organization__c);
                    gFRS_Ltng_Organization__c updateOrg=new gFRS_Ltng_Organization__c();
                    system.debug('appInfoRec.Organization__c'+appInfoRec.Organization__c);
                    updateOrg.Id=appInfoRec.Organization__c;
                    // updateOrg.gFRS_Strategic_Promo_Mkt_Rltd_Services__c=appInfoRec.Strategic_Promo_Mkt_Related_Services__c;                
                    updateOrg.gFRS_Sis_Parent_Org_Strategic_Promo_Mktg__c=appInfoRec.Sister_Parent_Org_Strategic_Promo_Mktg__c;
                    if(appInfoRec.Sister_Parent_Org_Strategic_Promo_Mktg__c == 'No'){
                        updateOrg.gFRS_Firewall_for_Strategic_Promo_Mktg__c = null;
                    } else {
                        updateOrg.gFRS_Firewall_for_Strategic_Promo_Mktg__c=appInfoRec.Firewall_for_Strategic_Promo_Mktg__c;                
                    }
                    
                    update updateOrg;      
                } 
            }
            
            
            list<gFRS_Ltng_Compliance_Flag__c> listComplFlag = new list<gFRS_Ltng_Compliance_Flag__c>();
            
            listComplFlag = [SELECT Id, name FROM gFRS_Ltng_Compliance_Flag__c WHERE gFRS_Application__c =: RecordId];
            
            if(listComplFlag.size() > 0){
                //nothing to do
            } else {
       //     gFRS_Ltng_Program__c gfrsProgram=[select id,gFRS_Application__c from gFRS_Ltng_Program__c where gFRS_Application__c=:RecordId LIMIT 1];
                gFRS_Ltng_Compliance_Flag__c complFlag = new gFRS_Ltng_Compliance_Flag__c();
                complFlag.gFRS_Application__c = RecordId;
                complFlag.Organization__c = orgId;
               
                
                insert complFlag;                    
            }
            
            gFRS_Ltng_Application__c appRecord = [SELECT Id, Name, Preapplication__c, Selected_Tab_Val__c, Focus_Area__c FROM gFRS_Ltng_Application__c WHERE Id =: RecordId];
            system.debug('@@@ Pre app Id : '+appRecord.Preapplication__c);
            if(appRecord.Preapplication__c != null){
                gFRS_Ltng_Pre_Application__c preApp = [SELECT Id, Name, Preapptoappcreatecheck__c FROM gFRS_Ltng_Pre_Application__c WHERE Id =:appRecord.Preapplication__c];
                preApp.Preapptoappcreatecheck__c = true;
                preApp.Full_Application__c = appRecord.Id;
                update preApp;
            }
            return appRecord;
        } catch(Exception e){
            system.debug('@@ Into Catch block::::');
            
            system.debug('@@ Excep::'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
            //return null;
        }
    }
    @AuraEnabled
    public static gFRS_Ltng_Program__c createOrUpdFoundationRequest(gFRS_Ltng_Application__c appInfoRec , gFRS_Ltng_Program__c programObj,String typeOfFunding){
        
        Id appRcdTypeId;
        system.debug('funding type@@@'+typeOfFunding);
        
        appInfoRec.Selected_Tab_Val__c = 'demographicId';  
        
        try{
            
            //Database.UpsertResult srList = Database.upsert(appInfoRec,false);
            Database.UpsertResult srList = gFRS_Ltng_Util_NoShare.updateAppRec(appInfoRec);
            system.debug('@@@ Database:::' + srList);
            if(srList.isSuccess()){
                system.debug('@@@@:::Value of upsert record:::' + appInfoRec);
                system.debug('@@@@:::Value of upsert ID:::' + appInfoRec.id);
                Id recID = srList.getId();
                
                Id programRcdTypeId;
                String recordtype;
                if(typeOfFunding =='Foundation Undergraduate'){
                    recordtype ='Foundation Undergraduate Program';
                }else if(typeOfFunding =='Foundation Safety Net Support'){
                    recordtype ='Foundation Safety Net Support Program';
                }        
                
                programRcdTypeId = Schema.SObjectType.gFRS_Ltng_Program__c.getRecordTypeInfosByName().get(recordtype).getRecordTypeId();
                
                SavePoint sp = Database.setSavepoint();
                programObj.gFRS_Application__c = recID;
                programObj.RecordTypeId = programRcdTypeId;
                
                try{
                    //upsert programObj;
                    gFRS_Ltng_Util_NoShare.updateProgram(programObj);
                } catch(exception e){
                    Database.rollback(sp);
                    system.debug('@@@:::Msg:::'+e.getMessage());
                    system.debug('@@@LineNum:::'+e.getLineNumber());
                    AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
                    system.debug('auraExceptionObj'+auraExceptionObj);
                    throw auraExceptionObj; 
                }
                
                list<gFRS_Ltng_Compliance_Flag__c> listComplFlag = new list<gFRS_Ltng_Compliance_Flag__c>();
                
                listComplFlag = [SELECT Id, name FROM gFRS_Ltng_Compliance_Flag__c WHERE gFRS_Application__c =: recID];
                
                if(listComplFlag.size() > 0){
                    //nothing to do
                } else {
               // gFRS_Ltng_Program__c gfrsProgram=[select id,gFRS_Application__c from gFRS_Ltng_Program__c where gFRS_Application__c=:recID LIMIT 1];
                    gFRS_Ltng_Compliance_Flag__c complFlag = new gFRS_Ltng_Compliance_Flag__c();
                    complFlag.gFRS_Application__c = recID;
                    complFlag.Organization__c = appInfoRec.Organization__c;
                    
                    
                    insert complFlag;                    
                }
                
                 gFRS_Ltng_Application__c appRecord = [SELECT Id, Name, Preapplication__c, Selected_Tab_Val__c, Focus_Area__c FROM gFRS_Ltng_Application__c WHERE Id =:recID];
            system.debug('@@@ Pre app Id : '+appRecord.Preapplication__c);
            if(appRecord.Preapplication__c != null){
                gFRS_Ltng_Pre_Application__c preApp = [SELECT Id, Name, Preapptoappcreatecheck__c FROM gFRS_Ltng_Pre_Application__c WHERE Id =:appRecord.Preapplication__c];
                preApp.Preapptoappcreatecheck__c = true;
                preApp.Full_Application__c = appRecord.Id;
                update preApp;
            }
            
                
                return [select id,Name,gFRS_Application__c,gFRS_End_Date__c,gFRS_Start_Date__c,Are_any_students_impacted_by_Program__c,Student_impact_by_program__c from gFRS_Ltng_Program__c where gFRS_Application__c =:recID ];
            }else{
                system.debug('@@@ Error while updating request');
                for(Database.Error err : srList.getErrors()) {
                    System.debug('@@@ The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('@@@ fields that affected this error: ' + err.getFields());
                }                
                return null;
            }
            
           
            
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
    public static reqPgmWrapper getCurrentFundingReqDetails(String objAPIName){
        try{
            Id rId = objAPIName;
            DescribeSObjectResult describeResult = rId.getSObjectType().getDescribe();      
            List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );  
            String query =    ' SELECT ' +        String.join( fieldNames, ',' ) +    ' FROM ' +          describeResult.getName() +      ' WHERE ' +         ' id = :rId ' +     ' LIMIT 1 '   ;   
            // return generic list of sobjects or typecast to expected type List<SObject> records = Database.query( query );
            gFRS_Ltng_Application__c req = Database.query( query );
            gFRS_Ltng_Program__c pgm = [SELECT Id, Name, gFRS_Start_Date__c, gFRS_End_Date__c, Are_any_students_impacted_by_Program__c, Student_impact_by_program__c FROM gFRS_Ltng_Program__c WHERE gFRS_Application__c =: rId limit 1];
            reqPgmWrapper reqPgm = new reqPgmWrapper();
            reqPgm.requestRec = req;
            reqPgm.programRec = pgm;
            return reqPgm;            
        } catch(Exception e){
            system.debug('@@ Into Catch block::::');
            
            system.debug('@@ Excep::'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
            //return null;
        }
        
    } 
    
    @AuraEnabled
    public static Boolean getOrgRequests(String orgID){
        try{
            Id organizationId = orgID;
            List<gFRS_Ltng_Application__c> appList = new List<gFRS_Ltng_Application__c>();
            appList = [SELECT Id, Name FROM gFRS_Ltng_Application__c WHERE Organization__c =: organizationId AND Requested_Amount__c > 500000 AND (Status__c = 'Processing & Disposition' OR Sub_Status__c = 'Approved')];
            if(appList.size() > 0){
                return true; 
            } else {
                return false;
            }
            
        } catch(Exception e){
            system.debug('@@ Excep::'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
        
    }     
    
    @AuraEnabled
    public static Id getRecTypeId(String recType){
        if(recType != null){
            Id appRcdTypeId = Schema.SObjectType.gFRS_Ltng_Application__c.getRecordTypeInfosByName().get(recType).getRecordTypeId();
            return appRcdTypeId;
        }else{
            return null;
        }
    }    
    
    @AuraEnabled
    public static gFRS_Ltng_Organization__c getOrgDetails(Id orgId){
        
        //return [Select id,name,gFRS_Program_Type__c From gFRS_Ltng_Program__c Where gFRS_Application__c='aKP3C0000004CN5WAM'];
        System.debug('@@@ Rec Id '+orgId);
        return [Select id,name,gFRS_Firewall_for_Strategic_Promo_Mktg__c,gFRS_Sis_Parent_Org_Strategic_Promo_Mktg__c,
                gFRS_Strategic_Promo_Mkt_Rltd_Services__c 
                From gFRS_Ltng_Organization__c Where Id=:orgId]; // gFRS_Application__c='aKP3C0000004CN5WAM' LIMIT 1
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
        system.debug('picklist values ' +options);
        return options;
        
    }
    @AuraEnabled
    public static void deleteProgram(string appId){
        List<gFRS_Ltng_Program__c> delProgRec =[select id,Name from gFRS_Ltng_Program__c where gFRS_Application__c=:appId];
        SavePoint sp = Database.setSavepoint();
        system.debug('Application Id : '+appId);
        try{
            Delete delProgRec;
        }catch(Exception e){
            system.debug('@@ Into Catch block::::');
            
            system.debug('@@ Excep::'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
            //return null;
        }
    }
    public class picklistWrapper{
        @AuraEnabled 
        public string pickListLabel{get;set;}
        @AuraEnabled 
        public string pickListValue{get;set;}
        
    }
    public class reqPgmWrapper{
        @AuraEnabled 
        public gFRS_Ltng_Application__c requestRec{get;set;}
        @AuraEnabled 
        public gFRS_Ltng_Program__c programRec{get;set;}
        
    }    
    
    @AuraEnabled 
    public static user getCurrentUser(){
        User u = [select id,Name from User where id =: userInfo.getUserId()];
        return u;
    }
    
    @AuraEnabled 
    public static user getAcctEmpployee(Id userId){
        User u = [select id,Name from User where id =: userId];
        return u;
    }    
    
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
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
    public class PicklistEntryWrapper{
        public String isVisible {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }
    
    @AuraEnabled
    public static Integer getProgramCount(Id applicationId){
        List<gFRS_Ltng_Program__c> pgmList = new List<gFRS_Ltng_Program__c>();
        pgmList = [select id, Name from gFRS_Ltng_Program__c where gFRS_Application__c=:applicationId];        
        
        return pgmList.size();
    }
    @AuraEnabled
    public static void updateAppwithRFPId(String appId,String rfpId){
        if(String.isNotEmpty(rfpId)){
           gFRS_Ltng_Application__c gfrsapp=[SELECT Id,RFP_Title_Id__c FROM gFRS_Ltng_Application__c WHERE Id=:appId];
           gfrsapp.RFP_Title_Id__c =rfpId;
           update gfrsapp;
        }
    }
}