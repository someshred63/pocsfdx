/*****************************************************************************************************************************
CLASS NAME: 
DESCRIPTION: 
LOGS: Maintain atleast last 5 logs

DATE            DEVELOPER           PURPOSE
-----------------------------------------------------------------------------------------------------------------------------
12-Aug-2020     Vikram              Created as controller class for gFRS_OrgDetailsFormControllers cmp.
24-Aug-2020     Vikram              Updated to validate Internal and External User login access.

******************************************************************************************************************************/


public class GFRS_Ltng_OrgInformationDetailsCntrl { 
    
    /*
Method Name:getOrginfobyTaxId
Description: This method will help in checking Tax id in SFDC and if not available will call in Guide Star 
*/
    @AuraEnabled
    public static finalResWrapper getOrginfobyTaxId(String taxId,String strCntry){
        finalResWrapper finalResponse=new finalResWrapper();
        List<gFRS_Ltng_Organization__c> orginfo = new List<gFRS_Ltng_Organization__c>();
        gFRS_Ltng_Organization__c crtIrgRcd = new gFRS_Ltng_Organization__c();
        Id orgRcdTypeId = null;
        String orgRcdTypeName = null;
        String strTrackRcd = null;
        try{
            
            if(String.isNotBlank(taxId)){            
                orginfo=[Select id,Country__c,Tax_Id__c,Tax_Status__c,Organization_Name__c,Type__c,Mission_Statement__c,Parent_Org_Name__c,gFRS_W_8BEN_E_Form__c,
                         gFRS_W9_Form_W_8BEN_Form__c,ACCME_Accreditation_Form__c,gFRS_Form_990_for_the_previous_two_year__c,gFRS_Tax_Status_501_c_3_Determination_Le__c,Additional_Document__c,
                         gFRS_org_sole_proprietor_single_memb_LLC__c,gFRS_Is_Ch_Foundation_of_a_group_practic__c,OwnerId,gFRS_Certification_Ackn__c,
                         Street__c,Number_of_Employees__c,City__c,Operational_Budget__c,State__c,Zip_Code__c,Website_Address__c,Province__c,If_other_please_specify__c,
                         gFRS_Organization_Purchase__c,gFRS_Organization_Prescribe__c,gFRS_Organization_Develop__c,gFRS_Organization_Owned__c,                       
                         Parent_Organization_Tax_ID__c,recordType.name,recordTypeId,gFRS_How_many_physicians_are_in_the_grou__c,gFRS_Do_you_have_W_8BEN_Status__c,
                         Does_your_organization_have_commitment__c,Does_your_org_have_established_policies__c,Is_your_org_led_by_a_person_of_color__c,Percentage_of_women_in_your_workforce__c,
                         Percentage_of_women_in_your_leadership__c,People_of_color_percentage_in_workforce__c,People_of_color_percentage_in_leadership__c,
                         Explanation_relating_to_sole_proprietor__c,Commitments_or_provide_a_web_link__c,Org_Medicare_guideline_development__c,Accreditations_received__c
                         From gFRS_Ltng_Organization__c where Tax_Id__c=:taxId LIMIT 1];
                
                
                System.debug('orginfo'+orginfo); 
                
                If(orginfo !=null && orginfo.size()>0){  //Checking in Salesforce back end
                    if(string.isBlank(orginfo[0].recordType.name)){
                        System.debug('orginfo'+orginfo[0].recordType.name+':::::Org Purc:::::'+orginfo[0].gFRS_Organization_Purchase__c);
                        system.debug('Error::::');
                        finalResponse.message = 'error';
                        return finalResponse;
                    }else{
                        finalResponse.guideResponse=null;
                        finalResponse.orgResponse=orginfo[0];
                        finalResponse.orglocation=null;
                        finalResponse.taxIdPullStatus='SFDC';
                        finalResponse.currentRcdTyp = orginfo[0].recordType.name; 
                        finalResponse.loggedInnUsr = getUsrProfileName();
                        finalResponse.isDescriptionEditable = gFRS_Ltng_Util_NoShare.getSubmitedRequestUnderOrg(orginfo[0].id) < 1;
                        System.debug('@@ finalResponse.orgResponse'+finalResponse.orgResponse);
                        return finalResponse;
                    }
                }else{ // Calling guide star
                    
                    //Validate TAX ID in TIN-CHECK
                    //String strResult = GFRS_Ltng_OrgInfo_Helper.getTinChkStatus(taxId,'');
                    if(strCntry != 'United States'){
                        finalResponse.message = 'NON USA TAX ID - NEW RECORDS ACCESS';
                        finalResponse.loggedInnUsr = getUsrProfileName();
                        return finalResponse;
                    }else{
                        finalResponse = getTaxIdInfo_GudStr(taxId);
                        if(finalResponse != null){
                            
                            finalResponse.loggedInnUsr = getUsrProfileName();
                            system.debug('@@@:::'+finalResponse.loggedInnUsr);
                            if(finalResponse.loggedInnUsr == 'GNE-GFRS-External Applicant' || finalResponse.loggedInnUsr == 'GNE-GFRS-External Requestor'){
                                orgRcdTypeId = Schema.SObjectType.gFRS_Ltng_Organization__c.getRecordTypeInfosByName().get('External').getRecordTypeId();
                                system.debug('@@::External ID::::'+orgRcdTypeId);
                                orgRcdTypeName = 'External';
                                strTrackRcd = 'Created By Eternal User';
                            }else {
                                orgRcdTypeId = Schema.SObjectType.gFRS_Ltng_Organization__c.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
                                system.debug('@@::Internal ID::::'+orgRcdTypeId);
                                orgRcdTypeName = 'Internal';
                                strTrackRcd = 'Created By Internal User';
                            }                    
                            
                            if(finalResponse != null){
                                crtIrgRcd.Tax_Id__c = taxId;
                                crtIrgRcd.Organization_Name__c = finalResponse.guideResponse.organizationname;
                                //crtIrgRcd.Organization_Name__c = 'GFRS HOLDING ACCOUNT';
                                crtIrgRcd.Mission_Statement__c = finalResponse.guideResponse.mission;
                                crtIrgRcd.Website_Address__c = finalResponse.guideResponse.websiteurl;
                                crtIrgRcd.City__c = finalResponse.guideResponse.city;
                                crtIrgRcd.Zip_Code__c = (finalResponse.guideResponse.zip);
                                crtIrgRcd.State__c = finalResponse.guideResponse.state;
                                crtIrgRcd.Street__c = finalResponse.guideResponse.addressline1;
                                crtIrgRcd.Operational_Budget__c = Decimal.valueOf(finalResponse.guideResponse.totalrevenue);
                                crtIrgRcd.Number_of_Employees__c = finalResponse.guideResponse.noOfEmps;
                                
                                if(orgRcdTypeId != null){
                                    crtIrgRcd.recordtypeId = orgRcdTypeId;
                                }
                                if(crtIrgRcd != null){
                                    
                                    //insert crtIrgRcd;
                                    finalResponse.orgResponse=crtIrgRcd;
                                    finalResponse.taxIdPullStatus='GUIDE STAR';
                                    system.debug('@@:::record type check::'+crtIrgRcd);
                                    system.debug('@@:::record type check::'+crtIrgRcd.RecordTypeId);
                                    system.debug('@@:::record type check::'+crtIrgRcd.recordType.Name);
                                    if(orgRcdTypeId != null){
                                        finalResponse.currentRcdTyp = orgRcdTypeName;
                                    }
                                    return finalResponse;
                                }
                            }
                        }else{
                            finalResponse=new finalResWrapper();
                            finalResponse.message = 'Error';
                            return finalResponse;
                        }
                    }
                }
                return finalResponse;
            }else{
                return finalResponse;
            }
        }
        catch(Exception e){
            system.debug('@@@ Exception'+e.getMessage()+'@@libe::'+e.getLineNumber());   
            //AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            //throw auraExceptionObj;    
            finalResponse.message = 'Data not Found';
            return finalResponse;
        }
        
    }
    
    /*
Method Name:getOrginfo
Description: This method will help in fetching the Org information
*/
    @AuraEnabled
    public static gFRS_Ltng_Organization__c getOrginfo(String orgId){
        gFRS_Ltng_Organization__c orginfo = new gFRS_Ltng_Organization__c();
        try{
            
            orginfo = [Select id,Country__c,Tax_Id__c,Tax_Status__c,Organization_Name__c,Type__c,Mission_Statement__c,Parent_Org_Name__c,gFRS_W_8BEN_E_Form__c,
                       gFRS_W9_Form_W_8BEN_Form__c,ACCME_Accreditation_Form__c,gFRS_Form_990_for_the_previous_two_year__c,gFRS_Tax_Status_501_c_3_Determination_Le__c,Additional_Document__c,
                       gFRS_org_sole_proprietor_single_memb_LLC__c,gFRS_Is_Ch_Foundation_of_a_group_practic__c,OwnerId,gFRS_Certification_Ackn__c,
                       Street__c,Number_of_Employees__c,City__c,Operational_Budget__c,State__c,Zip_Code__c,Website_Address__c,Province__c,
                       gFRS_Organization_Purchase__c,gFRS_Organization_Prescribe__c,gFRS_Organization_Develop__c,gFRS_Organization_Owned__c,If_other_please_specify__c,
                       Parent_Organization_Tax_ID__c,recordType.name,recordTypeId,gFRS_How_many_physicians_are_in_the_grou__c,gFRS_Do_you_have_W_8BEN_Status__c,
                       Percentage_of_women_in_your_leadership__c,People_of_color_percentage_in_workforce__c,People_of_color_percentage_in_leadership__c,
                       Does_your_organization_have_commitment__c,Does_your_org_have_established_policies__c,Is_your_org_led_by_a_person_of_color__c,Percentage_of_women_in_your_workforce__c,
                       Explanation_relating_to_sole_proprietor__c,Org_Diversity1__c,Commitments_or_provide_a_web_link__c,Org_Medicare_guideline_development__c,Accreditations_received__c
                       From gFRS_Ltng_Organization__c where id=:orgId];
            
            return orginfo;
            
        }
        catch(Exception e){
            system.debug('@@@ Exception while fectching Org Info : '+e.getMessage()+'@@libe::'+e.getLineNumber());   
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;    
        }
        
    } 
    
    /*
Method Name:getOrginfo
Description: This method will help in fetching the Org information along with External/Internal user detail for RFI
*/
    @AuraEnabled
    public static orgDetailsWrapperRFI getOrginfoRFI(String orgId){
        gFRS_Ltng_Organization__c orginfo = new gFRS_Ltng_Organization__c();
        try{
            orgDetailsWrapperRFI orgWrapRFI = new orgDetailsWrapperRFI();
            
            orginfo = [Select id,Country__c,Tax_Id__c,Tax_Status__c,Organization_Name__c,Type__c,Mission_Statement__c,Parent_Org_Name__c,gFRS_W_8BEN_E_Form__c,
                       gFRS_W9_Form_W_8BEN_Form__c,gFRS_Form_990_for_the_previous_two_year__c,gFRS_Tax_Status_501_c_3_Determination_Le__c,Additional_Document__c,
                       gFRS_org_sole_proprietor_single_memb_LLC__c,gFRS_Is_Ch_Foundation_of_a_group_practic__c,OwnerId,gFRS_Certification_Ackn__c,
                       Street__c,Number_of_Employees__c,City__c,Operational_Budget__c,State__c,Zip_Code__c,Website_Address__c,gFRS_Record_Type__c,If_other_please_specify__c,
                       gFRS_Organization_Purchase__c,gFRS_Organization_Prescribe__c,gFRS_Organization_Develop__c,gFRS_Organization_Owned__c,Province__c,
                       Parent_Organization_Tax_ID__c,recordType.name,recordTypeId,gFRS_How_many_physicians_are_in_the_grou__c,gFRS_Do_you_have_W_8BEN_Status__c,
                       Percentage_of_women_in_your_leadership__c,People_of_color_percentage_in_workforce__c,People_of_color_percentage_in_leadership__c,
                       Does_your_organization_have_commitment__c,Does_your_org_have_established_policies__c,Is_your_org_led_by_a_person_of_color__c,Percentage_of_women_in_your_workforce__c,
                       Explanation_relating_to_sole_proprietor__c,Commitments_or_provide_a_web_link__c,Org_Medicare_guideline_development__c,Accreditations_received__c
                       From gFRS_Ltng_Organization__c where id=:orgId];
            
            orgWrapRFI.orgDetails = orginfo;
            
            Profile prof = [Select Id, Name from Profile where Id =: userinfo.getProfileid()];
            
            if(prof.Name == 'GNE-GFRS-External Applicant' || prof.Name == 'GNE-GFRS-External Requestor'){
                orgWrapRFI.isExternal = true;
            } else {
                orgWrapRFI.isExternal = false;
            }            
            
            return orgWrapRFI;
            
        }
        catch(Exception e){
            system.debug('@@@ Exception while fectching Org Info in RFI : '+e.getMessage()+'@@libe::'+e.getLineNumber());   
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;    
        }
        
    }
    
    @AuraEnabled
    public static orgWrapper retrieveOrgDetails(String orgId){
        Id rId = Id.valueOf(orgId);
        DescribeSObjectResult describeResult = rId.getSObjectType().getDescribe();      
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );  
        String query =    ' SELECT ' +        String.join( fieldNames, ',' ) +    ' FROM ' +          describeResult.getName() +      ' WHERE ' +         ' id = :rId ' +     ' LIMIT 1 '   ;   
        
        gFRS_Ltng_Organization__c org = Database.query( query );
        
        orgWrapper orgWrap = new orgWrapper();
        orgWrap.orgDetails = org;
        orgWrap.isDescriptionEditable = gFRS_Ltng_Util_NoShare.getSubmitedRequestUnderOrg(rId) < 1;
        return orgWrap;        
    }
    
    /*
Method Name: orgDetailsFetchIfAny
Description: This method will help in fetching the Org information if already exists under the logged in user
*/
    @AuraEnabled
    public static orgDetailsWrapper orgDetailsFetchIfAny(){
        Profile p = [Select Id, Name from Profile where Id =: userinfo.getProfileid()];
        String pname = p.name;
        orgDetailsWrapper orgWrap = new orgDetailsWrapper();
        Contact userContact = null; 
        userContact = gFRS_Ltng_Util_NoShare.getUserContact(UserInfo.getUserId());
        
        if(Test.isRunningTest()){
            User urObj = [SELECT Contact.Id, Contact.AccountId, Contact.Account.Id, Contact.Account.Name, Contact.gFRS_Organization2__c, Contact.gFRS_Organization2__r.Id, Contact.gFRS_Organization2__r.Organization_Name__c FROM User WHERE contact.id != null];
            userContact = urObj.Contact;
        }
        
        if (userContact != null) {
            try {
                gFRS_Ltng_Organization__c userOrg = gFRS_Ltng_Util_NoShare.getContactOrganization(userContact);
                if(userOrg == null){
                    orgWrap.isTaxInfoEditable = true;
                    orgWrap.isDescriptionEditable = true;
                    orgWrap.orgDetails = null;
                    if(pname == 'GNE-GFRS-External Applicant' || pname == 'GNE-GFRS-External Requestor'){
                        orgWrap.isExternal = true;
                    } else {
                        orgWrap.isExternal = false;
                    }
                    
                    return orgWrap;
                } else {
                    orgWrap.orgDetails = getOrginfo(userOrg.Id);
                    orgWrap.isTaxInfoEditable = false;
                    orgWrap.isDescriptionEditable = gFRS_Ltng_Util_NoShare.getSubmitedRequestUnderOrg(userOrg.Id) < 1;
                    if(pname == 'GNE-GFRS-External Applicant' || pname == 'GNE-GFRS-External Requestor'){
                        orgWrap.isExternal = true;
                    } else {
                        orgWrap.isExternal = false;
                    }
                    
                    return orgWrap;
                }
            } catch(Exception e){
                system.debug('@@@ Exception while fectching Org Info : '+e.getMessage()+'@@libe::'+e.getLineNumber());   
                AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
                throw auraExceptionObj;    
            }
        } else {
            orgWrap.isTaxInfoEditable = true;
            orgWrap.isDescriptionEditable = true;
            orgWrap.orgDetails = null;
            if(pname == 'GNE-GFRS-External Applicant' || pname == 'GNE-GFRS-External Requestor'){
                orgWrap.isExternal = true;
            } else {
                orgWrap.isExternal = false;
            }
            
            return orgWrap;
        }        
        
    } 
    
    public class orgDetailsWrapper{
        @AuraEnabled 
        public Boolean isTaxInfoEditable{get;set;}
        @AuraEnabled 
        public Boolean isDescriptionEditable{get;set;}
        @AuraEnabled 
        public gFRS_Ltng_Organization__c orgDetails{get;set;}
        @AuraEnabled 
        public Boolean isExternal{get;set;}        
        
    }
    
    
    public class orgWrapper{
        @AuraEnabled 
        public gFRS_Ltng_Organization__c orgDetails{get;set;}  
        @AuraEnabled 
        public Boolean isDescriptionEditable{get;set;}  
        
    }    
    
    public class orgDetailsWrapperRFI{
        @AuraEnabled 
        public gFRS_Ltng_Organization__c orgDetails{get;set;}
        @AuraEnabled 
        public Boolean isExternal{get;set;}        
        
    }    
    
    /*
Class Name:finalResWrapper
Description: This Class helps to wrap Org record information and helps to populate on UI 
*/
    public class finalResWrapper{
        @AuraEnabled public guideStarWrapperRes guideResponse{get;set;}
        @AuraEnabled public gFRS_Ltng_Organization__c orgResponse{get;set;}
        @AuraEnabled public GFRS_Location__c orglocation{get;set;}  
        @AuraEnabled public String message{get;set;} 
        @AuraEnabled public String taxIdPullStatus {get;set;}
        @AuraEnabled public String loggedInnUsr {get;set;}
        @AuraEnabled public String currentRcdTyp {get;set;} 
        @AuraEnabled public Boolean isDescriptionEditable {get;set;}
    } 
    
    
    public class guideStarWrapperRes{        
        @AuraEnabled public String organizationname{get;set;}
        @AuraEnabled public String mission{get;set;}
        @AuraEnabled public String websiteurl{get;set;}
        @AuraEnabled public String totalrevenue{get;set;}
        @AuraEnabled public String addressline1{get;set;}
        @AuraEnabled public String addressline2{get;set;}
        @AuraEnabled public String city{get;set;}
        @AuraEnabled public String zip{get;set;}
        @AuraEnabled public String state{get;set;}
        @AuraEnabled public String name{get;set;}
        @AuraEnabled public Decimal noOfEmps{get;set;}        
    }
    
    
    
    
    
    /*
Method Name:getTaxIdInfo_GudStr
Description: This method will help making a rest callout passing TaxId as input parameter and get response from guide star.
*/
    public static finalResWrapper getTaxIdInfo_GudStr(String taxId){
        finalResWrapper finalResponse=new finalResWrapper();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');//93-1137247
        req.setEndpoint('https://apidata.guidestar.org/Premier/v2/'+taxId+'?Subscription-Key=35f802459e114ec382e4a08f68a34f8e');
        //req.setEndpoint('https://apidata.guidestar.org/Premier/v2/'+taxId+'?Subscription-Key=ddf058f36f1e4d59b6e12a35710b06cb');
        //req.setEndpoint('https://apidata.guidestar.org/charitycheck/v1/'+taxId+'?Subscription-Key=ddf058f36f1e4d59b6e12a35710b06cb');  
        req.setTimeout(120000);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('@@@'+res);
        System.debug('@@@ Result'+res.getBody());
        if(res.getStatusCode() == 200){
            system.debug('@@@:::Inside:::status:');
            
            //JSON2Apex_GuideStar guidefinalResponse = (JSON2Apex_GuideStar) JSON.deserialize(res.getBody(), JSON2Apex_GuideStar.class);
            //JSON2Apex guidefinalResponse = (JSON2Apex) JSON.deserialize(res.getBody(), JSON2Apex.class);
            //gFRS_Ltng_GuideStarWrapper guidefinalResponse = (gFRS_Ltng_GuideStarWrapper) JSON.deserialize(res.getBody(), gFRS_Ltng_GuideStarWrapper.class);
            JSON2ApexV3 guidefinalResponse = JSON2ApexV3.parse(res.getBody());
            system.debug('@@ after parse:::');
            guideStarWrapperRes guideres=new guideStarWrapperRes();
            guideres.organizationname=guidefinalResponse.Data.summary.organization_name;
            //system.debug('@@:::'+Financials.Financials.most_recent_year_financials.total_revenue);
            guideres.mission=guidefinalResponse.Data.summary.mission;
            guideres.websiteurl=guidefinalResponse.Data.summary.website_url;
            guideres.totalrevenue=String.valueOf(guidefinalResponse.Data.financials.most_recent_year_financials.total_revenue);
            guideres.addressline1=guidefinalResponse.Data.summary.address_line_1;
            guideres.addressline2=guidefinalResponse.Data.summary.address_line_2;
            guideres.city=guidefinalResponse.Data.summary.city;
            guideres.zip=guidefinalResponse.Data.summary.zip;
            guideres.state=guidefinalResponse.Data.summary.state;
            guideres.name=guidefinalResponse.Data.summary.contact_name;
            guideres.noOfEmps = guidefinalResponse.Data.operations.no_of_employees;
            finalResponse.guideResponse=guideres;
            finalResponse.orgResponse=null;
            finalResponse.orglocation=null;   
            return finalResponse;
        }else{
            return null;
        }
    }

        /*
Method Name:crtorUpdOrgInfo
Description: This method helps in updating or creating Org Rcd.
*/
    @AuraEnabled
    public static void UpdOrgInfo(gFRS_Ltng_Organization__c orgInfoRec){
        try{
            update orgInfoRec;
            
           String strAccName = null;
            
            Id usrId = Userinfo.getUserId();
            User usrObj = [Select Id,name,Contact.AccountId,Contact.Account.Name from User where Id =: usrId];
            if(usrObj != null){
                strAccName = UsrObj.Contact.Account.Name;
                if(String.isNotBlank(orgInfoRec.Organization_Name__c) && String.isNotEmpty(strAccName) && strAccName != null){
                    
                    if(strAccName != orgInfoRec.Organization_Name__c){
                        gFRS_Ltng_Util_NoShare.upAccNamewithOrgName(orgInfoRec,usrId);
                    }
                }
            }            
        } catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
    }
    
    /*
Method Name:crtorUpdOrgInfo
Description: This method helps in updating or creating Org Rcd.
*/
    @AuraEnabled
    public static finalResWrapper crtorUpdOrgInfo(gFRS_Ltng_Organization__c orgInfoRec){
        system.debug('Entered method call::::');
        finalResWrapper finalResponse=new finalResWrapper();
        // SavePoint sp = Database.setSavepoint();
        String strUsrPrf = getUsrProfileName();
        String cntRcdTyp;
        Id orgRcdTypeId;
        String strAccName = null;
        Boolean boolUpdAccName = false;
        Boolean boolVal;
        Id UsrCntAccId;
        Account accObj;
        system.debug('@@@:::'+strUsrPrf);
        system.debug('@@@::OBJECT::ID:'+orgInfoRec.Id);
        system.debug('@@@::OBJECT:::'+orgInfoRec); 
        Id usrId = Userinfo.getUserId();
        User usrObj = [Select Id,name,Contact.AccountId,Contact.Account.Name from User where Id =: usrId];
        if(usrObj != null){
            strAccName = UsrObj.Contact.Account.Name;
            if(String.isNotBlank(orgInfoRec.Organization_Name__c) && String.isNotEmpty(strAccName) && strAccName != null){
                system.debug('1');
                if(strAccName != orgInfoRec.Organization_Name__c){
                    system.debug('2');
                    boolUpdAccName = true;
                    UsrCntAccId = usrObj.Contact.AccountId;
                }
            }
        }
        system.debug('@@@::Acc Name::::'+strAccName);
        if(strUsrPrf == 'GNE-GFRS-External Applicant' || strUsrPrf == 'GNE-GFRS-External Requestor'){
            if(orgInfoRec.recordType.name == 'Internal' || String.isBlank(orgInfoRec.OwnerId)){
                orgInfoRec.OwnerId = UserInfo.getUserId();
            }
            orgRcdTypeId = Schema.SObjectType.gFRS_Ltng_Organization__c.getRecordTypeInfosByName().get('External').getRecordTypeId();
            orgInfoRec.RecordTypeId = orgRcdTypeId;
            cntRcdTyp = 'External';
        }else {
            if(String.isBlank(orgInfoRec.OwnerId)){
                orgInfoRec.OwnerId = UserInfo.getUserId();
            }
            orgRcdTypeId = Schema.SObjectType.gFRS_Ltng_Organization__c.getRecordTypeInfosByName().get('Internal').getRecordTypeId();
            orgInfoRec.RecordTypeId = orgRcdTypeId;
            cntRcdTyp = 'Internal';              
        }
        
        try{
            Schema.SObjectField ftoken = gFRS_Ltng_Organization__c.Fields.Tax_Id__c;
            Database.UpsertResult srList = Database.upsert(orgInfoRec,ftoken,false);
            system.debug('@@@ Database:::'+srList);
            if(srList.isSuccess()){
                orgInfoRec.id = srList.getId();
                system.debug('@@@@:::Value of upsert record:::'+orgInfoRec);
                system.debug('@@@@:::Value of upsert ID:::'+orgInfoRec.id);
                finalResponse.orgResponse = orgInfoRec; //Obj Info & Track Status
                finalResponse.loggedInnUsr = strUsrPrf; //User Profile
                finalResponse.currentRcdTyp =cntRcdTyp ;
                finalResponse.message = 'Success';
                system.debug('bool:::'+boolUpdAccName);
                if(boolUpdAccName && cntRcdTyp == 'External'){
                    //boolVal = gFRS_Ltng_Util_NoShare.upAccNamewithOrgName(UsrCntAccId,orgInfoRec.Organization_Name__c);
                    
                    boolVal = gFRS_Ltng_Util_NoShare.upAccNamewithOrgName(orgInfoRec,usrId);
                    system.debug('3::::'+boolVal);
                    if(boolVal){
                        finalResponse.message = 'Success';   
                    }else{
                        finalResponse.message = 'Error';
                    }
                    /*accObj = new Account();
accObj.id = UsrCntAccId;
accObj.Name = orgInfoRec.Organization_Name__c;
update accObj;*/
                }
                
                return finalResponse;
            }else{
                system.debug('@@@ Errors'+srList.getErrors());
                finalResponse.message = 'Error';
                return finalResponse;
            }
            
            
            
        }
        catch(Exception e){
            system.debug('@@ Into Catch block::::');
            //Database.rollback(sp);
            system.debug('@@ Excep::'+e.getMessage());
            system.debug('@@ Excep::'+e.getLineNumber());
            //AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            //throw auraExceptionObj;              
            finalResponse.message = 'Error';
            return finalResponse;
            //return null;
        }
        
    }
    
    /*
Method Name:updateUserContact
Description: This method will update user contact
*/
    @AuraEnabled
    public static boolean updateUserContact(string orgIdVal, string orgName){
        boolean updStatus = gFRS_Ltng_Util_NoShare.updateUserContact(orgIdVal, orgName);
        
        return updStatus;
    }    
    
    /*
Method Name:saveChunk
Description: This method will validate if file Id exist and make call to append or update attachment w.r.t the parentID record.
*/
    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId,String typOfFile,String status) {
        gFRS_Ltng_Organization__c obj;
        String oldrcdFile = null;
        system.debug('@@parentId::'+parentId+':::Filename::::'+fileName);
        system.debug('@@@:typOfFile:::::'+typOfFile);
        system.debug('@@@:::contentType::::'+contentType);
        system.debug('@@@:::base64Data::::'+base64Data);
        if(String.isNotEmpty(parentId)){
            obj = [Select id,gFRS_W9_Form_W_8BEN_Form__c,gFRS_Form_990_for_the_previous_two_year__c,Country__c,
                   gFRS_Tax_Status_501_c_3_Determination_Le__c,gFRS_W_8BEN_E_Form__c,Additional_Document__c From gFRS_Ltng_Organization__c
                   where id=: parentId];
            system.debug('@@@:::obj:::'+obj);
            if(typOfFile == 'W9 Form'){
                oldrcdFile = obj.gFRS_W9_Form_W_8BEN_Form__c; 
            }else if(typOfFile == '501 Form'){
                oldrcdFile = obj.gFRS_Tax_Status_501_c_3_Determination_Le__c;
            }else if(typOfFile == '990 Form'){
                oldrcdFile = obj.gFRS_Form_990_for_the_previous_two_year__c;
            }else if(typOfFile == 'W8 Form'){
                oldrcdFile = obj.gFRS_W_8BEN_E_Form__c;
            }
        }
        
        if(status != 'completed'){
            if (fileId == '') {
                fileId = saveTheFile(parentId, fileName, base64Data, contentType,oldrcdFile,typOfFile);
                system.debug('@@@:::'+fileId);
            } else {
                fileId = appendToFile(fileId, base64Data);
            }            
        } else {
            fileId = saveTheContentVersion(parentId, fileName, base64Data, contentType,oldrcdFile,typOfFile, fileId);
            if(fileId != null && String.isNotBlank(typOfFile)){
                
                if(typOfFile == 'W9 Form'){
                    //obj.id = parentId;
                    obj.gFRS_W9_Form_W_8BEN_Form__c = Id.valueOf(fileId);
                }else if(typOfFile == '501 Form'){
                    //obj.id = parentId;
                    obj.gFRS_Tax_Status_501_c_3_Determination_Le__c = Id.valueOf(fileId);
                }else if(typOfFile == '990 Form'){
                    //obj.id = parentId;
                    obj.gFRS_Form_990_for_the_previous_two_year__c = Id.valueOf(fileId);
                }else if(typOfFile == 'W8 Form'){
                    //obj.id = parentId;
                    obj.gFRS_W_8BEN_E_Form__c = Id.valueOf(fileId);
                }else if(typOfFile == 'AdditionalDoc'){
                    //obj.id = parentId;
                    obj.Additional_Document__c = Id.valueOf(fileId);
                }
                update obj;
                
                
            }            
        }

        return Id.valueOf(fileId);
    }
    
    @AuraEnabled
    public static Id updateOrgInfo(Id orgId, Id docId, string docType, string contentType) {
        gFRS_Ltng_Organization__c orgRecord = new gFRS_Ltng_Organization__c();
        orgRecord.Id = orgId;
        
        if(docType == 'W9 Form'){
            orgRecord.gFRS_W9_Form_W_8BEN_Form__c = docId;
        } else if(docType == 'ACCME Form'){
            orgRecord.ACCME_Accreditation_Form__c = docId;
        } else if(docType == 'Additional Doc'){
            orgRecord.Additional_Document__c = docId;
        }
        
        if(docType != 'Additional Doc'){
            orgRecord.gFRS_OCR_Batch_Process_Status__c = 'Ready for processing';
            
            gFRS_OCR_Forms__c frmRcd = new gFRS_OCR_Forms__c();
            //frmRcd.gFRS_Document_ID__c = String.valueOf(cVersion.id); //cDocLink.ContentDocumentId;
            frmRcd.gFRS_Document_ID__c = String.valueOf(docId);
            frmRcd.gFRS_Form_Organization__c = orgId;
            frmRcd.gFRS_Type_of_Form__c = docType;
            frmRcd.gFRS_Extension__c = contentType;
            frmRcd.gFRS_Status_of_CreateBatch__c  = 'Ready to Process';
            frmRcd.gFRS_Attachment_Name__c = orgId+'_'+docType;
            //Name, Type of file, status of createBatch
            insert frmRcd;
            system.debug('@@@::::frmRcd::::'+frmRcd);                
        }
        
        update orgRecord;
        
        return docId;
    }
    
    /*
Method Name:saveTheFile
Description: This method will append attachment based on parentId
*/
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType,String oldrcdFile,String typOfFile) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        try{
            Attachment attach = new Attachment();
            attach.parentId = parentId;
            attach.OwnerId = UserInfo.getUserId();
            attach.Body = EncodingUtil.base64Decode(base64Data);
            attach.Name = fileName;
            attach.ContentType = contentType;
            
            insert attach;
            
            //Insert ContentVersion
            /* ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            cVersion.PathOnClient = attach.Name;//File name with extention
            cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
            cVersion.OwnerId = attach.OwnerId;//Owner of the file
            cVersion.Title = attach.Name;//Name of the file
            cVersion.VersionData = attach.Body;//File content
            Insert cVersion;
            
            //After saved the Content Verison, get the ContentDocumentId
            Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            
            //Insert ContentDocumentLink
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
            cDocLink.LinkedEntityId = attach.ParentId;//Add attachment parentId
            cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
            Insert cDocLink;
            
            if(typOfFile != 'AdditionalDoc'){
                gFRS_Ltng_Organization__c obj = [Select id,gFRS_OCR_Batch_Process_Status__c from gFRS_Ltng_Organization__c where id=: parentId];
                obj.gFRS_OCR_Batch_Process_Status__c = 'Ready for processing';
                update obj;
                
                gFRS_OCR_Forms__c frmRcd = new gFRS_OCR_Forms__c();
                frmRcd.gFRS_Document_ID__c = String.valueOf(cVersion.id); //cDocLink.ContentDocumentId;
                system.debug('@@:::linkId:::'+cDocLink.LinkedEntityId);
                frmRcd.gFRS_Form_Organization__c = parentId;
                frmRcd.gFRS_Type_of_Form__c = typOfFile;
                frmRcd.gFRS_Extension__c = contentType;
                frmRcd.gFRS_Status_of_CreateBatch__c  = 'Ready to Process';
                frmRcd.gFRS_Attachment_Name__c = parentId+'_'+typOfFile;
                //Name, Type of file, status of createBatch
                insert frmRcd;
                system.debug('@@@::::frmRcd::::'+frmRcd);                
            }
            
            system.debug('@@@ value of :::'+cDocLink);
            return cDocLink.ContentDocumentId; */
            return attach.Id;
            
        } catch(Exception ex){
            system.debug('@@@ exception::'+ex.getMessage());
            return null;
        }

    }

    public static Id saveTheContentVersion(Id parentId, String fileName, String base64Data, String contentType,String oldrcdFile,String typOfFile, Id fileId) {
        //base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        try{
            Attachment attach = new Attachment();
            attach = [SELECT Id, Name, parentId, OwnerId, Body, ContentType FROM Attachment WHERE Id =: fileId];
            /* attach.parentId = parentId;
            attach.OwnerId = UserInfo.getUserId();
            attach.Body = EncodingUtil.base64Decode(base64Data);
            attach.Name = fileName;
            attach.ContentType = contentType; */
            
            //insert attach;
            
            //Insert ContentVersion
            ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            cVersion.PathOnClient = attach.Name;//File name with extention
            cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
            cVersion.OwnerId = attach.OwnerId;//Owner of the file
            cVersion.Title = attach.Name;//Name of the file
            cVersion.VersionData = attach.Body;//File content
            Insert cVersion;
            
            //After saved the Content Verison, get the ContentDocumentId
            Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            
            //Insert ContentDocumentLink
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
            cDocLink.LinkedEntityId = attach.ParentId;//Add attachment parentId
            cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
            Insert cDocLink;
            
            if(typOfFile != 'AdditionalDoc'){
                gFRS_Ltng_Organization__c obj = [Select id,gFRS_OCR_Batch_Process_Status__c from gFRS_Ltng_Organization__c where id=: parentId];
                obj.gFRS_OCR_Batch_Process_Status__c = 'Ready for processing';
                update obj;
                
                gFRS_OCR_Forms__c frmRcd = new gFRS_OCR_Forms__c();
                frmRcd.gFRS_Document_ID__c = String.valueOf(cVersion.id); //cDocLink.ContentDocumentId;
                system.debug('@@:::linkId:::'+cDocLink.LinkedEntityId);
                frmRcd.gFRS_Form_Organization__c = parentId;
                frmRcd.gFRS_Type_of_Form__c = typOfFile;
                frmRcd.gFRS_Extension__c = contentType;
                frmRcd.gFRS_Status_of_CreateBatch__c  = 'Ready to Process';
                frmRcd.gFRS_Attachment_Name__c = parentId+'_'+typOfFile;
                //Name, Type of file, status of createBatch
                insert frmRcd;
                system.debug('@@@::::frmRcd::::'+frmRcd);                
            }
            
            system.debug('@@@ value of :::'+cDocLink);
            delete attach;
            return cDocLink.ContentDocumentId;
            
        } catch(Exception ex){
            system.debug('@@@ exception::'+ex.getMessage());
            return null;
        }

    }    
    
    /*
Method Name:appendToFile
Description: Update existing Attachment logic
*/
    private static Id appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id =: fileId
        ];
        
        String existingBody = EncodingUtil.base64Encode(a.Body);
        
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
        
        update a;
        
        return a.Id;
    }
    
    /*
Method Name:getUsrProfileName
Description: This method helps in getting Loogged in user profile
*/
    public static String getUsrProfileName(){
        Id usrId = UserInfo.getProfileId();
        if(usrId != null){
            List<Profile> lstPrf = [Select Name from Profile where Id =: usrId];
            system.debug('@@@:::Name of profile:::'+lstPrf[0].Name);
            return lstPrf[0].Name;
        }
        return null;
    }
    
    
    
    
    
    @AuraEnabled  
    public static List<picklistWrapper> getPicklistvalues(string objAPIName, string fieldAPIname) {
        list<picklistWrapper> returnValue = new list<picklistWrapper>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        // Get the object type of the SObject.
        Schema.sObjectType objType = schemaMap.get(objAPIName);
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values = fieldMap.get(fieldAPIname).getDescribe().getPickListValues();
        
        
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            picklistWrapper aa = new picklistWrapper();
            aa.pickListLabel = a.getLabel();
            aa.pickListValue = a.getValue();
            returnValue.add(aa);
        }
        system.debug('*****returnValue'+returnValue);
        return returnValue;
        
        
    }
    
    
    public class picklistWrapper{
        @AuraEnabled 
        public string pickListLabel;
        @AuraEnabled 
        public string pickListValue;
        
    }
    
    @AuraEnabled
    public static Boolean deleteContentDoc(Id contentDocID, Id orgRecId, string fileName) {
        
        try{
            List<ContentDocument> entries = [SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id =:contentDocID]; 
            delete entries;
            
            gFRS_Ltng_Organization__c obj = [Select id,gFRS_W9_Form_W_8BEN_Form__c,ACCME_Accreditation_Form__c,gFRS_Form_990_for_the_previous_two_year__c,
                                             gFRS_Tax_Status_501_c_3_Determination_Le__c,gFRS_W_8BEN_E_Form__c,Additional_Document__c From gFRS_Ltng_Organization__c
                                             where id=: orgRecId];
            
            if(fileName == 'W9'){
                obj.gFRS_W9_Form_W_8BEN_Form__c = '';
                obj.gFRS_W_8BEN_E_Form__c = '';
                update obj;  
                
                List<gFRS_OCR_Forms__c> frmRcd = [SELECT Id FROM gFRS_OCR_Forms__c WHERE gFRS_Form_Organization__c =: orgRecId];
                delete frmRcd;
            } else if (fileName == 'ACCME Form'){
                obj.ACCME_Accreditation_Form__c = '';
                update obj;   
                
                List<gFRS_OCR_Forms__c> frmRcd = [SELECT Id FROM gFRS_OCR_Forms__c WHERE gFRS_Form_Organization__c =: orgRecId];
                delete frmRcd;
            } else if (fileName == 'AdditionalDoc'){
                obj.Additional_Document__c = '';
                update obj;            
            }
            
            
            system.debug('@@@ Content Doc deleted');
            return true;
        }catch(Exception e){
            system.debug('@@@ Content Doc deletion failure');
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
        
    }    
    
    @AuraEnabled
    public static List<ContentDocument> getContentDocs(Id arecordId) {
        /*
        Attachment attach = [SELECT Id, Name, Body, ContentType, ParentId From Attachment WHERE id=:arecordId];

        //Insert ContentVersion
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = attach.Name;//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = attach.OwnerId;//Owner of the file
        cVersion.Title = attach.Name;//Name of the file
        cVersion.VersionData = attach.Body;//File content
        Insert cVersion;

        //After saved the Content Verison, get the ContentDocumentId
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;

        //Insert ContentDocumentLink
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = attach.ParentId;//Add attachment parentId
        cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'InternalUsers';//AllUsers, InternalUsers, SharedUsers
        Insert cDocLink;

        List<ContentDocument> entries = [SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id IN :CDIdList]; 
        system.debug('entries'+entries);
        return entries;
        */
        
        try {
            System.debug('**getContentDocs(): ' + arecordId);
            // Retrieve documents in system context
            List<ContentDocumentLink> cdLinks = GFRS_Ltng_OrgDocumentUtil.getContentDocumentLinks(arecordId, UserInfo.getUserId()); 
            if (cdLinks == null || cdLinks.isEmpty()) {
                return new List<ContentDocument>();
            }
            Set<Id> documentIds = new Set<Id> (); 
            for (ContentDocumentLink cdLink : cdLinks) { 
                documentIds.add(cdLink.ContentDocumentId); 
            } 
            List<ContentDocument> documents = [
                SELECT Id, Title, FileType, CreatedBy.Name, ContentSize FROM ContentDocument WHERE Id IN :documentIds
            ];
            System.debug('**Documents: ' + documents);
            return documents;
        } catch(Exception e) {
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;
        }
    }
    
    @AuraEnabled
    public static gFRS_Ltng_Application__c getApplicattionRecord(string  appId) {
        try{
            return [select id,Name,Record_Type_Name__c,RFI_Previous_Status__c,RFI_Previous_Sub_Status__c,Date_Submitted__c,PAR_approval_Status__c,
                    Event_Program_Title__c,First_Name__c,Last_Name__c,Email_Address__c,Requested_Amount__c,Business_Approver_2__c,
                    Organization__r.Organization_Name__c,Organization__r.Annual_PAR_Approval__c,Organization__r.Type__c,Preapplication__c,
                    Payment_from_accountable_emp_cost_center__c,Funding_Sub_Type__c,Payment_Cost_Center__c,Invite_Code__c,Accountable_Employee_Internal__c,Is_Legal__c,Title__c,
                    (select id,name,gFRS_Start_Date__c,gFRS_End_Date__c from FRS_Programs__r)
                    from gFRS_Ltng_Application__c where id=:appId];
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
    }  
    
    
    @AuraEnabled
    public static list<gFRS_Ltng_Organization__c> getCustomLinkdtls(String recordId) {
        try{
            list<gFRS_Ltng_Organization__c> CustomLinkdtls=new list<gFRS_Ltng_Organization__c>();
            CustomLinkdtls= [SELECT id,gFRS_Change_Request_Owner__c,gFRS_ACGME_Website__c,gFRS_Reconciliation_Refund_Details__c FROM gFRS_Ltng_Organization__c WHERE Id =: recordId];
            system.debug('CustomLinkdtls'+CustomLinkdtls);
            return CustomLinkdtls;
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
    }
    @AuraEnabled
    public static void getDeleteRecord(String recordId) {
        try{ 
            system.debug('recordId'+recordId);
            gFRS_Ltng_Vendor_Detail__c venRec=[select id,name from gFRS_Ltng_Vendor_Detail__c where id =: recordId];
            delete venRec;
            
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
    }
    @AuraEnabled
    public static Integer bankVerification(String fName,String  lName,String accNumber,String rutNumber){
        try{
            String responseMessage;
            String username = '9M0CMN-EQWPF-96L6P2-U7XK-L37CQ-91IDJ';
            String password = '-VvDWYIcocJ_5T4bzk';
            String tBody='{"UniqueId":"sample string 1","Check":{"RoutingNumber": "'+rutNumber+'","AccountNumber":"'+accNumber+'"},"Customer":{"EntityType": 0,"FirstName": "'+fName+'","LastName": "'+lName+'"},"GVerifyEnabled": true,"GAuthenticateEnabled": true}';
            
            Http http = new Http();  
            HttpRequest  request = new HttpRequest();
            Blob headerValue = Blob.valueOf(username +':'+password);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            request.setHeader('Authorization',authorizationHeader);
            request.setMethod('POST');   
            request.setHeader('Content-Length', '2000');
            request.setHeader('Content-Type', 'application/json');             
            request.setEndpoint('https://sandbox.api.giact.com/verificationservices/web_api/inquiries_v5_8');                         
            request.setBody(tBody);         
            HttpResponse response = http.send(request); 
            String messgae=response.getBody();
            BankcheckWrapper finalResponse = (BankcheckWrapper) JSON.deserialize(response.getBody(), BankcheckWrapper.class);
            Integer ResponseCode=finalResponse.VerificationResponse;
            String finalbdy=response.getBody();
            //System.debug('@@@'+ResponseCode);
            return ResponseCode;
        }
        catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    @AuraEnabled
    public static string updateAppRecord(String recordId){
        gFRS_Ltng_Application__c gfrsApp=new gFRS_Ltng_Application__c();
        gfrsApp.Id=recordId;
        gfrsApp.Selected_Tab_Val__c='cnfrm';
        //update gfrsApp;
        gFRS_Ltng_Util_NoShare.updateGfrsAPP(gfrsApp);
        return gfrsApp.Id;
    }
    
    @AuraEnabled
    public static void updateAppRecordForLagallyAuth(string appId,string draftRecordType){    
                
        system.debug('@@@ Record Type : '+draftRecordType);
        if(draftRecordType=='Independent Medical Education (CME)'){
            string val='draftLOA';
            gFRS_Ltng_Application__c loaRec = [SELECT Id, Name FROM gFRS_Ltng_Application__c WHERE Id =:appId];
            gFRS_DocusignAttachPDF_CME.InsertDocument(loaRec.Id,val);  
            
        }else if(draftRecordType=='Community Giving' ||draftRecordType=='Education Focused Giving K-12'){
            string val='draftLOA';
            gFRS_Ltng_Application__c loaRec = [SELECT Id, Name FROM gFRS_Ltng_Application__c WHERE Id =:appId];
            gFRS_DocusignAttachPDF_CG_K12.InsertDocument(loaRec.Id,val);   
        }else if(draftRecordType =='Patient and Health Focused Giving' || draftRecordType =='Scientific and Research Focused Giving' || draftRecordType =='Education Focused Giving Graduate and Post-Graduate'){
            string val='draftLOA';
            gFRS_Ltng_Application__c loaRec = [SELECT Id, Name FROM gFRS_Ltng_Application__c WHERE Id =:appId];
            gFRS_DocusignAttachPDF_Pat_Sci_Edu.InsertDocument(loaRec.Id,val);  
        }else if(draftRecordType =='Foundation Safety Net Support' || draftRecordType =='Foundation Undergraduate'){
            string val='draftLOA';
            gFRS_Ltng_Application__c loaRec = [SELECT Id, Name FROM gFRS_Ltng_Application__c WHERE Id =:appId];
            gFRS_DocusignAttachPDF_Foundation.InsertDocument(loaRec.Id,val);  
        }
    }
    
    @AuraEnabled
    public static gFRS_Ltng_Application__c updateAppRecordconfirm(gFRS_Ltng_Application__c objAppRec, Boolean isInternalReq,string draftRecordType){
        
        //update gfrsApp;
        try{
            if(isInternalReq == true){
                gFRS_Ltng_Application__c applRecord = [SELECT Id, Name,Accountable_Employee_Internal__c,Record_Type_Name__c,Payment_from_accountable_emp_cost_center__c,Payment_Cost_Center__c,Requested_Amount__c,Pending_Action_from_gCOI__c FROM gFRS_Ltng_Application__c WHERE Id =:objAppRec.Id];
                User userRec = [SELECT Id, Name, External_ID_gne__c FROM User WHERE Id =: applRecord.Accountable_Employee_Internal__c];
                
                gFRS_EmployeeCostCenterWS.employeeCostCenterResponse_element response = null;
                
                system.debug('@@@ Inside getting cost center');
                gFRS_EmployeeCostCenterWS.GneCOMM_CostCenter_GFRS_O_1_LDAP_I_1_ServicesPort0 ws = new gFRS_EmployeeCostCenterWS.GneCOMM_CostCenter_GFRS_O_1_LDAP_I_1_ServicesPort0();
                ws.inputHttpHeaders_x = gFRS_util.createAuthenticationHeaderMap();
                ws.timeout_x = 60000;
                response = ws.employeeCostCenter(null, null, null, userRec.External_ID_gne__c, '1' );
                system.debug('@@@ Response status :'+response.MessageType);
                system.debug('@@@ Response :'+response);
                if(response.MessageType == 'Error' || response.MessageText == 'User not found in the system.'){
                    objAppRec.Pending_Action_from_gCOI__c = gFRS_Util.addMultiSelectItem( applRecord.Pending_Action_from_gCOI__c, 'Business Approver does not exist in gFRS' );
                }
                
                if(applRecord.Record_Type_Name__c == 'Field Exhibits'){
                    string managerUnixId = response.employeeDetails[0].managerUnixId;
                    User[] userManager = [SELECT Id FROM User WHERE External_ID_gne__c = :managerUnixId LIMIT 1];
                    
                    if(userManager.size() < 1){
                        objAppRec.Pending_Action_from_gCOI__c = gFRS_Util.addMultiSelectItem( applRecord.Pending_Action_from_gCOI__c, 'Business Approver does not exist in gFRS' );
                    } else {
                        objAppRec.Business_Approver__c = userManager[0].Id;
                    }
                } else {
                    objAppRec.Business_Approver__c = applRecord.Accountable_Employee_Internal__c;
                }
                
                String financeManagerUnixId = '';
                String costCenter;
                
                if(applRecord.Payment_from_accountable_emp_cost_center__c == 'Yes'){
                    costCenter = response.employeeDetails[0].costCenter;
                    costCenter = costCenter.right(4);
                    objAppRec.Payment_Cost_Center__c = response.employeeDetails[0].costCenter.right(4);
                } else {
                    costCenter = applRecord.Payment_Cost_Center__c;
                }
                objAppRec.Accountable_Employee_Cost_Center__c = response.employeeDetails[0].costCenter.right(4);
                objAppRec.Approved_Amount__c                  = applRecord.Requested_Amount__c;
                
                system.debug('@@@ costCenter : '+costCenter);
                if(applRecord.Record_Type_Name__c != 'Field Exhibits'){
                    String CC ='%' + costCenter;
                    system.debug('@@ CC :'+CC);
                    List<gFRS_Ltng_Finance_Manager_CostCenter__c> FMCC = new List<gFRS_Ltng_Finance_Manager_CostCenter__c>();
                    FMCC = [SELECT Id, Finance_Manager_Unix_ID__c,Finance_Manager_Name__c FROM gFRS_Ltng_Finance_Manager_CostCenter__c WHERE Cost_Center__c Like :CC LIMIT 1];
                    if(FMCC.size() > 0){
                        financeManagerUnixId = FMCC[0].Finance_Manager_Name__c;
                    }
                    
                    if(financeManagerUnixId == null || financeManagerUnixId == ''){
                        objAppRec.Pending_Action_from_gCOI__c = gFRS_Util.addMultiSelectItem( applRecord.Pending_Action_from_gCOI__c, 'Cost Center & Finance Manager mapping not available' );
                    } else {
                        user[] userRecord = [SELECT Id FROM User WHERE External_ID_gne__c = :financeManagerUnixId LIMIT 1];
                        if(userRecord.size() < 1){
                            objAppRec.Pending_Action_from_gCOI__c = gFRS_Util.addMultiSelectItem( applRecord.Pending_Action_from_gCOI__c, 'Finance Manager does not exist in gFRS' );
                        } else {
                            objAppRec.Finance_Manager__c = userRecord[0].Id;
                        }
                        
                    }
                
                    /* gFRS_CostCenterApprovalWS.costCenterApproverResponse_element result = null;
                    
                    result = callCostCenterApprover( String.valueOf( applRecord.Requested_Amount__c ), 'CC', costCenter, costCenter );
                    
                    if(  result.MessageType == 'Error' ){
                        if( result.MessageText != null && result.MessageText.contains( 'NO_APPROVERS_FOR_COST_CENTER' )){
                            objAppRec.Pending_Action_from_gCOI__c = gFRS_Util.addMultiSelectItem( applRecord.Pending_Action_from_gCOI__c, 'Cost Center does not exist in SAP' );  
                        } else {
                            System.debug( 'Error Message from CostCenterApprover web service:' + result.MessageText );
                            objAppRec.Pending_Action_from_gCOI__c = gFRS_Util.addMultiSelectItem( applRecord.Pending_Action_from_gCOI__c, 'Web Service does not respond' );  
                        }
                    } else {
                        System.debug( '@@ Message Text :' + result.MessageText );
                        ---comment if(result.MessageText.contains( 'NO_APPROVERS_FOR_COST_CENTER' )){
                            return 'Error from SAP : No Approvers found';
                        }
                        if( result.MessageType == 'Failed'){
                            return 'Error from SAP : '+result.MessageText;
                        } ---comment
                        
                        if(( result.MessageText != null && result.MessageText.contains( 'NO_APPROVERS_FOR_COST_CENTER' )) || ( result.costCenterApprvers == null || result.costCenterApprvers.size() == 0 )){
                             objAppRec.Pending_Action_from_gCOI__c = gFRS_Util.addMultiSelectItem( applRecord.Pending_Action_from_gCOI__c, 'Cost Center does not exist in SAP' );  
                        } else {
                            for (gFRS_CostCenterApprovalWS.costCenterApprvers_element  CCA : result.costCenterApprvers) {
                                
                                if(CCA.amount!=null){
                                    if(applRecord.Requested_Amount__c > decimal.valueOf(CCA.amount)){
                                        //nothing to do
                                    } else {
                                        user[] costCenterUser = [SELECT Id FROM User WHERE External_ID_gne__c = :CCA.unixId LIMIT 1];
                                        if(costCenterUser.size() < 1){
                                            objAppRec.Pending_Action_from_gCOI__c = gFRS_Util.addMultiSelectItem( applRecord.Pending_Action_from_gCOI__c, 'Finance Approver does not exist in gFRS' );  
                                        } else {
                                            objAppRec.Finance_Approver__c = costCenterUser[0].Id;
                                        }
                                        break;
                                    }
                                }
                            }                               
                        }
                    } */  
                }                                     
            }
            
            if(objAppRec.Email_Address__c != null && objAppRec.Email_Address__c != ''){
                List<User> AuthorizedSigners = new List<User>();
                AuthorizedSigners = gFRS_Ltng_Util_NoShare.userByEmail(objAppRec.Email_Address__c);

                if (AuthorizedSigners.size() > 0) {
                    objAppRec.Authorized_Signer__c = AuthorizedSigners[0].Id;
                }
            }
            gFRS_Ltng_Util_NoShare.updateGfrsAPP(objAppRec);
            
            list<gFRS_Ltng_Task__c> taskRFI = new list<gFRS_Ltng_Task__c>();
            taskRFI = [SELECT Id, Name, Status__c, Action_Type__c FROM gFRS_Ltng_Task__c WHERE gFRS_Application__c =: objAppRec.Id AND Action_Type__c = 'RFI' AND Status__c != 'Completed'];
            if(taskRFI.size() > 0){
                gFRS_Ltng_Task__c taskRFIRec = taskRFI[0];
                taskRFIRec.Status__c = 'Completed';
                gFRS_Ltng_Util_NoShare.updateTask(taskRFIRec);            
            } 
            
            
            // Begin-Code Added for Internal Draft LOA -16/11/2021--Veera Mylavarapu
            system.debug('objAppRec.Record_Type__c'+draftRecordType);
            if(taskRFI.size() == 0){
                if(isInternalReq == true)
                {
                    gFRS_Ltng_Application__c loaRec = [SELECT Id, Name, Record_Type__c, Payment_Info__c, Vendor_Detail__c FROM gFRS_Ltng_Application__c WHERE Id =:objAppRec.Id];
                    gFRS_Ltng_createDraftLOAinternal.createLOAInternal(loaRec);
                    if(loaRec.Record_Type__c == 'Commercial Sponsorship' && loaRec.Payment_Info__c == 'New'){
                        
                    gFRS_Ltng_Vendor_Detail__c Accvendor = new gFRS_Ltng_Vendor_Detail__c();
                    Accvendor.Id =loaRec.Vendor_Detail__c;
                    Accvendor.Request_for_New_Vendor_sent_pending__c = true;                    
                    upsert Accvendor; 
                        sendDetailsToVendorTeam(loaRec);
                    }
                }else if(draftRecordType=='Independent Medical Education (CME)'){
                    string val='draftLOA';
                    gFRS_Ltng_Application__c loaRec = [SELECT Id, Name FROM gFRS_Ltng_Application__c WHERE Id =:objAppRec.Id];
                    gFRS_DocusignAttachPDF_CME.InsertDocument(loaRec.Id,val);  
                    
                }else if(draftRecordType=='Community Giving' ||draftRecordType=='Education Focused Giving K-12'){
                    string val='draftLOA';
                    gFRS_Ltng_Application__c loaRec = [SELECT Id, Name FROM gFRS_Ltng_Application__c WHERE Id =:objAppRec.Id];
                    gFRS_DocusignAttachPDF_CG_K12.InsertDocument(loaRec.Id,val);   
                }else if(draftRecordType =='Patient and Health Focused Giving' || draftRecordType =='Scientific and Research Focused Giving' || draftRecordType =='Education Focused Giving Graduate and Post-Graduate'){
                    string val='draftLOA';
                    gFRS_Ltng_Application__c loaRec = [SELECT Id, Name FROM gFRS_Ltng_Application__c WHERE Id =:objAppRec.Id];
                    gFRS_DocusignAttachPDF_Pat_Sci_Edu.InsertDocument(loaRec.Id,val);  
                }else if(draftRecordType =='Foundation Safety Net Support' || draftRecordType =='Foundation Undergraduate'){
                    string val='draftLOA';
                    gFRS_Ltng_Application__c loaRec = [SELECT Id, Name,Vendor_Detail__c FROM gFRS_Ltng_Application__c WHERE Id =:objAppRec.Id];
                    gFRS_DocusignAttachPDF_Foundation.InsertDocument(loaRec.Id,val);  
                    gFRS_Ltng_Vendor_Detail__c Accvendor = new gFRS_Ltng_Vendor_Detail__c();
                    Accvendor.Id =loaRec.Vendor_Detail__c;
                    Accvendor.Is_foundation_payment__c='Yes';                    
                    upsert Accvendor;
                }
            }
            // End
            
            
            //return 'Success';
            return objAppRec;
            
        } catch(Exception e){
            system.debug('@@ Exception ::'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }       
        
    }
    
    @AuraEnabled
    public static void sendDetailsToVendorTeam(gFRS_Ltng_Application__c objAppRec){
        User currentUserRec = [ SELECT Id, Email, Name FROM User WHERE Id = :(UserInfo.getUserId()) limit 1 ];
        gFRS_Ltng_Vendor_Detail__c location               = null;
        gFRS_Ltng_Organization__c objOrg                  = null;
        List<gFRS_Ltng_Application__c> fundingRequestsList = new List<gFRS_Ltng_Application__c>();
        
        GFRS_Ltng_OrgSettings__c orgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
        
        String targetEmailStr;
        if(orgCS.SAP_ContactList__c == '' || orgCS.SAP_ContactList__c == null){
            targetEmailStr   = System.Label.GFRS_SAP_ContactList;
        } else {
            targetEmailStr   = orgCS.SAP_ContactList__c;
        }
        
        String[] targetEmailList                          = targetEmailStr.split( ';' );
        
        try {
            location = [ SELECT Name, Vendor_Id__c, gFRS_Organization__r.Id, 
                        gFRS_Organization__r.Organization_Name__c, 
                        gFRS_Organization__r.Tax_Id__c, gFRS_Organization__r.Tax_Status__c, 
                        Vendor_Name__c, Address__c, Address2__c, City__c, State__c, Province__c,
                        Zip__c, Department_Chapter_Country__c 
                        FROM gFRS_Ltng_Vendor_Detail__c 
                        WHERE Id = :objAppRec.Vendor_Detail__c ];
        } catch(Exception e){
            //return 'Unable to find the location:';
            system.debug('@@ Unable to find the location:');
        }
        
        try
        {
            objOrg = [SELECT Id, gFRS_W9_Form_W_8BEN_Form__c
                      FROM gFRS_Ltng_Organization__c 
                      WHERE Id= : location.gFRS_Organization__r.Id];
        } catch(Exception e){
            system.debug('@@ Unable to find the org:');
        }
        
        
		//Gathering gFRS Application records that are assigned to given location, but only with Status != "Intake","Closed".
        fundingRequestsList = gFRS_Ltng_Util.getFundingRequestsByLocationId(objAppRec.Vendor_Detail__c);
        
        
        String targetEmailName = 'gFRS_Add_SAP_Location';
        EmailTemplate template = null;
        try {
            template = [ SELECT TemplateType, Subject, Name, Description, HtmlValue, Body 
                        FROM EmailTemplate 
                        WHERE DeveloperName = :targetEmailName limit 1 ];
        } catch(Exception e){ 
            template = null; 
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setUseSignature( true );
        mail.setSaveAsActivity(true);
        
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        
        if (objOrg.gFRS_W9_Form_W_8BEN_Form__c != null) {
            
            Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
            
            ContentVersion cv = [SELECT title,PathOnClient, FileType, versiondata FROM contentversion 
                                 WHERE ContentDocumentId =: objOrg.gFRS_W9_Form_W_8BEN_Form__c Limit 1 
                                ];
            Blob attBody = cv.VersionData;
            
            if (attBody != null) {
                att.setBody(attBody);
                att.setFileName(cv.title);
                att.setInline(false);
                att.setContentType('application/octet-stream');
                attachments.add(att);
            }
        }
        
        mail.setSubject(formatEmailSubject(template.Subject, location.Name));
        mail.setPlainTextBody( formatEmailText( template.Body, location, currentUserRec.Name, currentUserRec.Email, fundingRequestsList ));
        
        if(attachments.size() > 0){
            mail.setFileAttachments(attachments);
        }       
        
        //List<String> ccAddresses = new List<String>{currentUserRec.Email};
        List<String> ccAddresses = new List<String>();
  
        /* if(String.isNotBlank(orgCS.Vendor_Update_CC_Email__c)){
            ccAddresses.add(orgCS.Vendor_Update_CC_Email__c); 
        }
        ccAddresses.add(System.Label.gFRS_FPO_Team_DL);
        mail.setccAddresses(ccAddresses); */
        
        mail.setToAddresses( targetEmailList ); 
        
        String serverURL = orgCS.Vendor_Update_CC_Email__c;       
        mail.setOrgWideEmailAddressId([
            SELECT Id, Address
            FROM OrgWideEmailAddress
            WHERE Address = :serverURL
            limit 1
        ][0].id);  
        
        List<Messaging.SendEmailResult> result1 = Messaging.sendEmail( new Messaging.SingleEmailMessage[]{ mail } );
    }
    
    public static String formatEmailSubject( String emailSubject, String payeeName) {
        if(emailSubject == null) {
            return null;
        }
        
        emailSubject = emailSubject.replace('[[PAYEE_NAME]]', gFRS_Util.blankValue(payeeName, ''));
        return emailSubject;
    }
    
    public static String formatEmailText( String emailText, gFRS_Ltng_Vendor_Detail__c location, string userName, string userEmail, List<gFRS_Ltng_Application__c> fundingRequestsList) {
        String TAG_ORGANIZATION_NAME       = '[[ORGANIZATION_NAME]]';
        String TAG_ORGANIZATION_TAX_ID     = '[[TAX_ID]]';
        String TAG_ORGANIZATION_TAX_STATUS = '[[TAX_STATUS]]';
        
        String TAG_VENDOR_ID               = '[[VENDOR_ID]]';
        String TAG_VENDOR_NAME             = '[[VENDOR_NAME]]';
        String TAG_VENDOR_ADDRESS          = '[[VENDOR_ADDRESS]]';
        String TAG_VENDOR_CITY             = '[[VENDOR_CITY]]';
        String TAG_VENDOR_STATE            = '[[VENDOR_STATE]]';
        String TAG_VENDOR_PROVINCE         = '[[PROVINCE]]';
        String TAG_VENDOR_ZIP              = '[[VENDOR_ZIP]]';
        String TAG_VENDOR_COUNTRY          = '[[VENDOR_COUNTRY]]';
        String TAG_USER_NAME               = '[[USER_NAME]]';
        String TAG_USER_EMAIL              = '[[USER_EMAIL]]';
        
        String TAG_REQUEST_IDS             = '[[REQUEST_IDS]]';
        String TAG_PAYEE_NAME              = '[[PAYEE_NAME]]';  
        
        if( emailText == null || location == null || userName == null || fundingRequestsList == null) return( null );
        
        String requestsListText = '';
        
        emailText = emailText.replace(TAG_ORGANIZATION_NAME,   gFRS_Util.blankValue( location.gFRS_Organization__r.Organization_Name__c, '' ));
        emailText = emailText.replace(TAG_ORGANIZATION_TAX_ID, gFRS_Util.blankValue( location.gFRS_Organization__r.Tax_Id__c, '' ));
        emailText = emailText.replace(TAG_ORGANIZATION_TAX_STATUS, gFRS_Util.blankValue( location.gFRS_Organization__r.Tax_Status__c, '' ));
        
        emailText = emailText.replace(TAG_VENDOR_ID,           gFRS_Util.blankValue( location.Vendor_Id__c, '' ));
        emailText = emailText.replace(TAG_VENDOR_NAME,         gFRS_Util.blankValue( location.Name, '' ));
        emailText = emailText.replace(TAG_VENDOR_ADDRESS,      location.Address2__c == null ? gFRS_Util.blankValue( location.Address__c, '' ) : gFRS_Util.blankValue( location.Address__c + ' ' + location.Address2__c, '' ));
        emailText = emailText.replace(TAG_VENDOR_CITY,         gFRS_Util.blankValue( location.City__c, '' ));
        emailText = emailText.replace(TAG_VENDOR_STATE,        gFRS_Util.blankValue( location.State__c, '' ));
        emailText = emailText.replace(TAG_VENDOR_PROVINCE,        gFRS_Util.blankValue( location.Province__c, '' ));
        emailText = emailText.replace(TAG_VENDOR_ZIP,          gFRS_Util.blankValue( location.Zip__c, '' ));
        emailText = emailText.replace(TAG_VENDOR_COUNTRY,      gFRS_Util.blankValue( location.Department_Chapter_Country__c, '' ));
        emailText = emailText.replace(TAG_USER_NAME,           userName);
        emailText = emailText.replace(TAG_USER_EMAIL,          userEmail);
        
        for(gFRS_Ltng_Application__c fundingRequest : fundingRequestsList){
            String giactResp = '';
            if(fundingRequest.Giact_Response__c != '' && fundingRequest.Giact_Response__c != null){
                giactResp = fundingRequest.Giact_Response__c;
            }
            requestsListText += fundingRequest.Record_Type__c + ': ' + fundingRequest.Name + '\n';
            requestsListText += 'Payment Contact Email Address' + ': ' + fundingRequest.Person_To_Whom_Payment_should_addressed__c + '\n';
            requestsListText += 'GIACT Response' + ': ' + giactResp + '\n\n';
        }
        
        emailText = emailText.replace(TAG_REQUEST_IDS, requestsListText);
        
        
        return( emailText );
    }
    
     @AuraEnabled
    public static void updateRFIAppRecordconfirm(gFRS_Ltng_Application__c objAppRec){         
            gFRS_Ltng_Util_NoShare.updateGfrsAPP(objAppRec);
            list<gFRS_Ltng_Task__c> taskRFI = new list<gFRS_Ltng_Task__c>();
            taskRFI = [SELECT Id, Name, Status__c, Action_Type__c FROM gFRS_Ltng_Task__c WHERE gFRS_Application__c =: objAppRec.Id AND Action_Type__c = 'RFI' AND Status__c != 'Completed'];
            if(taskRFI.size() > 0){
                gFRS_Ltng_Task__c taskRFIRec = taskRFI[0];
                taskRFIRec.Status__c = 'Completed';
                gFRS_Ltng_Util_NoShare.updateTask(taskRFIRec);            
            } 
    }
    
    
    public static gFRS_CostCenterApprovalWS.costCenterApproverResponse_element callCostCenterApprover(String amount,String expenseType,String maxCostCenter,String minCostCenter){
        gFRS_CostCenterApprovalWS.GneCOMM_CostCenter_GFRS_O_1_SAP_I_1_ServicesPort0 ws = new gFRS_CostCenterApprovalWS.GneCOMM_CostCenter_GFRS_O_1_SAP_I_1_ServicesPort0();
        ws.inputHttpHeaders_x = gFRS_util.createAuthenticationHeaderMap();
        ws.timeout_x = 60000;
        //-- do not pass the amount
        return ws.costCenterApprover( null, expenseType, maxCostCenter, minCostCenter);
    }    
    
    @AuraEnabled
    public static gFRS_Ltng_Vendor_Detail__c getPaymentDtls(String appId){
        system.debug('appid'+appId);
        gFRS_Ltng_Vendor_Detail__c gfrsVendtls=new gFRS_Ltng_Vendor_Detail__c();
        gfrsVendtls=[select Id,Name,gFRS_Application__c,Department_Do_you_have_PO_Box__c,gFRS_Payment_Type__c from gFRS_Ltng_Vendor_Detail__c where gFRS_Application__c =:appId];
        return gfrsVendtls;
    }
    
    @AuraEnabled
    public static gFRS_Ltng_Program__c getProgramDtls(String appId){
        system.debug('appid'+appId);
        gFRS_Ltng_Program__c gfrsProgram=new gFRS_Ltng_Program__c();
        gfrsProgram=[select Id,Name,gFRS_Start_Date__c from gFRS_Ltng_Program__c where gFRS_Application__c =:appId limit 1];
        return gfrsProgram;
    }
     @AuraEnabled
    public static list<gFRS_Ltng_Program__c> getProgramList(String appId){
        system.debug('appid'+appId);
        list<gFRS_Ltng_Program__c> gfrsProgram=new list<gFRS_Ltng_Program__c>();
        gfrsProgram=[select Id,Name,gFRS_Start_Date__c from gFRS_Ltng_Program__c where gFRS_Application__c =:appId];
        return gfrsProgram;
    }
    @AuraEnabled
    public static List<SelectOptionObj> getOrgTypePicklistDetails() {
        List<SelectOptionObj> picklistOptions = new List<SelectOptionObj>();
        try {
            Schema.DescribeFieldResult fieldResult = gFRS_Ltng_Organization__c.Type__c.getDescribe(); 
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            SelectOptionObj option = null;
            for (Schema.PicklistEntry pickListVal : ple) {
                option = new SelectOptionObj(pickListVal.getLabel(), pickListVal.getValue(), pickListVal.isDefaultValue());
                picklistOptions.add(option);
            }
            
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return picklistOptions;
    }
    public class SelectOptionObj {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }
        @AuraEnabled
        public Boolean isDefault {get; set;}
        
        public SelectOptionObj(String label, String val,Boolean isDefault) {
            this.label = label;
            this.value = val;
            this.isDefault = isDefault;
        }
    }
    @AuraEnabled 
    public static List<contentDocument> fetchContentDocument(){
        return [Select id,Title,FileType,CreatedBy.Name,ContentSize From contentDocument WHERE Id ='0693C000000w40VQAQ'];
    }
    @AuraEnabled 
    public static gFRS_Ltng_Organization__c fetchOrgDetails(String orgid){
        return [select id,gFRS_Restricted_Access__c,Funding_Type_Specific_Restricted_Access__c,OrgRadio41__c,OrgRadio42__c,OrgRadio43__c,OrgRadio44__c,OrgRadio45__c,Org_Diversity1__c,Org_Diversity2__c,Org_Diversity3__c,Org_Diversity4__c,Org_Diversity5__c,Org_Diversity6__c,Org_Diversity7__c,OrgRadio1__c,OrgRadio2__c,OrgRadio3__c,OrgRadio4__c,OrgRadio5__c,OrgRadio6__c,OrgRadio7__c,OrgRadio8__c,OrgRadio9__c,OrgRadio10__c,OrgRadio11__c,OrgRadio12__c,OrgRadio13__c,OrgRadio14__c,OrgRadio15__c,OrgRadio16__c,OrgRadio17__c,OrgRadio18__c,OrgRadio19__c,OrgRadio20__c,OrgRadio21__c,OrgRadio22__c,OrgRadio23__c,OrgRadio24__c,OrgRadio25__c,OrgRadio26__c,OrgRadio27__c,OrgRadio28__c,OrgRadio29__c,OrgRadio30__c,OrgRadio31__c,OrgRadio32__c,OrgRadio33__c,OrgRadio34__c,OrgRadio35__c,OrgRadio36__c,OrgRadio37__c from gFRS_Ltng_Organization__c WHERE Id=:orgid];
    }
    @AuraEnabled 
    public static void saveOrgDiversity(gFRS_Ltng_Organization__c orggfrs){
     try{
     update orggfrs;
        }
        catch(Exception e){
    AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
    throw auraExceptionObj;              
} 
    }
    
    @AuraEnabled 
    public static boolean checkOrgFiscalYear(id orgid){
        Boolean isvalid;
        Integer count=[select count() from gFRS_Ltng_CAF_Application__c WHERE gFRS_Organization__c=:orgid and Status__c!='Intake'];
        if(count>0){
            isvalid=true;
        }else{
            isvalid=false;
        }
        return isvalid;
        
    }
    @AuraEnabled 
    public static void saveAppSurvey(String appId,String Field1,String Field2,String Field3,String Field4){
        try{
            gFRS_Ltng_App_Submission_Survey__c appsurevy=new gFRS_Ltng_App_Submission_Survey__c();
            appsurevy.gFRS_Application__c=appId;
            appsurevy.How_would_you_rate_your_overall_experien__c=Field1;
            appsurevy.Rate_Application_Process__c=Field2;
            appsurevy.What_specific_improvements__c=Field3;
            appsurevy.Survey_Type__c=Field4;
            insert appsurevy;
            if(String.isNotEmpty(appsurevy.Id)){
                gFRS_Ltng_Application__c gfrsapp=[SELECT ID,gFRS_Application_Submission_Survey__c FROM gFRS_Ltng_Application__c WHERE ID=:appId LIMIT 1];
                gfrsapp.gFRS_Application_Submission_Survey__c=appsurevy.Id;
                update gfrsapp;
            }
        }
        catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
    }
    @AuraEnabled 
    public static gFRS_Ltng_App_Submission_Survey__c getAppSurvey(Id appId){
       gFRS_Ltng_App_Submission_Survey__c appsurvey=[select Id,Name,gFRS_Application__c,Survey_Type__c,To_what_extent_do_you_agree_or_disagree__c, Please_explain_the_reason_for_your_score__c, How_would_you_rate_your_overall_experien__c, Rate_Application_Process__c, Rate_Grant_Operaions_Support_Teams__c, What_specific_improvements__c from gFRS_Ltng_App_Submission_Survey__c WHERE gFRS_Application__c=:appId];
        return appsurvey;
    }
    @AuraEnabled 
    public static String checkShutdownRule(String recordtype){
        try{

            Boolean isShutdown=false;
            String shutdownMessage;
            
            gFRS2_0_Shutdown_Rule__c shutdownRule=gFRS_Ltng_Util.checkShutdownRule(recordtype);
            if(shutdownRule != null) {
                isShutdown = true;
                shutdownMessage = shutdownRule.Message__c;
            }
            System.debug('MEssage1>'+shutdownMessage);
            return shutdownMessage;
        }
        catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
    }
    @AuraEnabled
    public static User getUserInfo(){
        try{
            String userId = UserInfo.getUserId();
            User User = [SELECT Id, Name, Alias FROM User WHERE Id =:userId];
            return User;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage()); 
        }
    }
}