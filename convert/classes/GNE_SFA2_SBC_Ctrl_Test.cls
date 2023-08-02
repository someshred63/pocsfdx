@isTest
private class GNE_SFA2_SBC_Ctrl_Test {   
    static String strJSON = '{"appContext":{"role":null,"isSfa2Mode":false,"currentUser":{"timeZone":"America/Los_Angeles","profileName":"System Administrator","profileId":"00e70000000txFhAAI","name":"Jaroslaw Laniecki","isTls":null,"isSfaBrand":false,'+
        '"isSbm":null,"isFrm":null,"isCrm":null,"isCanada":false,"isBam":null,"id":"00523000000YNGVAA4"},"brand":null,"appName":null},"recordDescribe":{"sObjectType":"SFASearchStrings_gne__c","sObjectLabel":"SFASearchStrings","recordType":null,'+
        '"recordName":null,"recordId":null,"recordAccess":{"readAccess":true,"editAccess":true,"deleteAccess":true},"recId":null},"config":{"mode":"Edit"},"isSfaBrandUser":false,"sbcMode":"hcoSearch","hcpSearchRecId":"a3j230000009Pz6AAE",'+
        '"hcoSearchRecId":"a3j230000009a3pAAA","teamCodes":["HEM","IFRM"],"searchData":{"hco":{"searchMode":"NameAddress","searchFields":[{"properties":null,"name":"OrgName_gne__c","label":"Organization Name","attributes":null,'+
        '"attributeFlags":null,"value":"TEST Merge 001","required":false,"readOnly":false,"placeholder":null,"order":null,"mode":["New","Edit","View"],"hidden":null,"helpText":"Enter ....","displayValue":null,'+
        '"describe":{"updateable":true,"type":"string","sObjectType":"SFASearchStrings_gne__c","showNone":null,"restrictedPicklist":false,"relationshipName":null,"referenceTo":[],"picklistValues":[],"permissionable":true,"nillable":true,'+
        '"name":"OrgName_gne__c","lookupData":null,"length":255,"label":"Organization Name","inlineHelpText":"Enter ... ","htmlFormatted":false,"dependentPicklist":false,"createable":true,"controllingField":null,"caseSensitive":false,'+
        '"calculated":false}},{"properties":null,"name":"Street_gne__c","label":"Street Address","attributes":null,"attributeFlags":null,"value":"4502 Medical Drive","required":false,"readOnly":false,"placeholder":null,"order":null,'+
        '"mode":["New","Edit","View"],"hidden":null,"helpText":"Enter...","displayValue":null,'+
        '"describe":{"updateable":true,"type":"string","sObjectType":"SFASearchStrings_gne__c","showNone":null,"restrictedPicklist":false,"relationshipName":null,"referenceTo":[],"picklistValues":[],"permissionable":true,'+
        '"nillable":true,"name":"Street_gne__c","lookupData":null,"length":80,"label":"Address Line 1","inlineHelpText":"Enter ","htmlFormatted":false,"dependentPicklist":false,"createable":true,"controllingField":null,'+
        '"caseSensitive":false,"calculated":false}},{"properties":null,"name":"City_gne__c","label":"City","attributes":null,"attributeFlags":null,"value":"SAN ANTONIO","required":false,"readOnly":false,'+
        '"placeholder":null,"order":null,"mode":["New","Edit","View"],"hidden":null,"helpText":"Enter the city.","displayValue":null,"describe":{"updateable":true,"type":"string","sObjectType":"SFASearchStrings_gne__c",'+
        '"showNone":null,"restrictedPicklist":false,"relationshipName":null,"referenceTo":[],"picklistValues":[],"permissionable":true,"nillable":true,"name":"City_gne__c","lookupData":null,"length":40,"label":"City",'+
        '"inlineHelpText":"Enter the city.","htmlFormatted":false,"dependentPicklist":false,"createable":true,"controllingField":null,"caseSensitive":false,"calculated":false}},{"properties":null,"name":"State_gne__c","label":"State",'+
        '"attributes":null,"attributeFlags":null,"value":"CA","required":true,"readOnly":false,"placeholder":null,"order":null,"mode":["New","Edit","View"],"hidden":null,"helpText":"Select...","displayValue":null,'+
        '"describe":{"updateable":true,"type":"picklist","sObjectType":"SFASearchStrings_gne__c","showNone":null,"restrictedPicklist":false,"relationshipName":null,"referenceTo":[],'+
        '"picklistValues":[{"value":"AK","label":"AK","defaultValue":false,"active":true}],"permissionable":true,"nillable":true,"name":"State_gne__c","lookupData":null,"length":255,"label":"State",'+
        '"inlineHelpText":"Select..","htmlFormatted":false,"dependentPicklist":false,"createable":true,"controllingField":null,"caseSensitive":false,"calculated":false}},'+
        '{"properties":null,"name":"Zip_gne__c","label":"Zip Code","attributes":null,"attributeFlags":null,"value":"78229","required":false,"readOnly":false,"placeholder":null,"order":null,"mode":["New","Edit","View"],'+
        '"hidden":null,"helpText":"Enter ...","displayValue":null,"describe":{"updateable":true,"type":"string","sObjectType":"SFASearchStrings_gne__c","showNone":null,"restrictedPicklist":false,"relationshipName":null,"referenceTo":[],'+
        '"picklistValues":[],"permissionable":true,"nillable":true,"name":"Zip_gne__c","lookupData":null,"length":40,"label":"Zip Code","inlineHelpText":"Enter ","htmlFormatted":false,'+
        '"dependentPicklist":false,"createable":true,"controllingField":null,"caseSensitive":false,"calculated":false}}]}}}';
    
    static String strInputJSON = 
        '{"appContext":{"role":null,"isSfa2Mode":false,"currentUser":{"timeZone":"America/Los_Angeles","profileName":"System Administrator","profileId":"00e70000000txFhAAI","name":"Jaroslaw Laniecki","isTls":null,"isSfaBrand":false,'+
        '"isSbm":null,"isFrm":null,"isCrm":null,"isCanada":false,"isBam":null,"id":"00523000000YNGVAA4"},"brand":null,"appName":null},"recordDescribe":{"sObjectType":"SFASearchStrings_gne__c","sObjectLabel":"SFASearchStrings",'+
        '"recordType":null,"recordName":null,"recordId":null,"recordAccess":{"readAccess":true,"editAccess":true,"deleteAccess":true},"recId":null},"config":{"mode":"Edit"},"isPopupMode":false,"isSfaBrandUser":false,"sbcMode":"hcoCreate",'+
        '"accountTypesMap":{"hco":{"default":{"ssn":"ams","recordTypeId":"0127000000015UkAAI","accountType":"Physician Practice"},"UNION":{"ssn":"sfdc","recordTypeId":"01270000000HfoeAAC","accountType":"Union"},'+
        '"TPA":{"ssn":"sfdc","recordTypeId":"01270000000Du3sAAC","accountType":"TPA"},"SERVICE PROVIDER":{"ssn":"ams","recordTypeId":"0127000000015UkAAI","accountType":"Service Provider"},'+
        '"SPECIALTY PHARMACY":{"ssn":"ams","recordTypeId":"012700000001BA0AAM","accountType":"Specialty Pharmacy"},"SPECIALTY DISTRIBUTOR":{"ssn":"ams","recordTypeId":"012700000001BA0AAM","accountType":"Specialty Distributor"},'+
        '"PUBLICATION":{"ssn":"ams","recordTypeId":"0127000000015V0AAI","accountType":"Publication"},"PRISON":{"ssn":"ams","recordTypeId":"0127000000015UkAAI","accountType":"Prison"},'+
        '"PROFESSIONAL ORGANIZATION":{"ssn":"ams","recordTypeId":"0127000000015UzAAI","accountType":"Professional Organization"},"PHYSICIAN PRACTICE":{"ssn":"ams","recordTypeId":"0127000000015UkAAI","accountType":"Physician Practice"},'+
        '"PHARMACY":{"ssn":"ams","recordTypeId":"0127000000015UsAAI","accountType":"Pharmacy"},"DRUG MANUFACTURER / PHARMA COMPANY":{"ssn":"ams","recordTypeId":"0127000000015UsAAI","accountType":"Drug Manufacturer / Pharma Company"},'+
        '"PBM":{"ssn":"bot","recordTypeId":"01270000000Du3rAAC","accountType":"PBM"},"NETWORK":{"ssn":"sfdc","recordTypeId":"012700000001DygAAE","accountType":"Network"},'+
        '"MULTI-SERVICE HEALTHCARE":{"ssn":"ams","recordTypeId":"0127000000015UkAAI","accountType":"Multi-Service HealthCare"},"MISCELLANEOUS":{"ssn":"ams","recordTypeId":"0127000000015UkAAI","accountType":"Miscellaneous"},'+
        '"MEDICAL CLAIMS ASSISTANCE":{"ssn":"bot","recordTypeId":"0127000000015UlAAI","accountType":"Medical Claims Assistance"},"LABORATORY":{"ssn":"ams","recordTypeId":"0127000000015UzAAI","accountType":"Laboratory"},'+
        '"IPA":{"ssn":"ams","recordTypeId":"01270000000Du3pAAC","accountType":"IPA"},"INFORMATION PROVIDER":{"ssn":"sfdc","recordTypeId":"01270000000DvqcAAC","accountType":"Information Provider"},'+
        '"INDEMNITY":{"ssn":"sfdc","recordTypeId":"01270000000Du3qAAC","accountType":"Indemnity"},"HOSPITAL":{"ssn":"ams","recordTypeId":"0127000000015UjAAI","accountType":"Hospital"},'+
        '"HEALTH PLAN ASSOCIATION":{"ssn":"sfdc","recordTypeId":"01270000000DvqbAAC","accountType":"Health Plan Association"},"GROUP PURCHASING ORGANIZATION":{"ssn":"ams","recordTypeId":"012700000001RAZAA2",'+
        '"accountType":"Group Purchasing Organization"},"EXTENDED CARE":{"ssn":"ams","recordTypeId":"0127000000015UjAAI","accountType":"Extended Care"},"EMPLOYER GROUP":{"ssn":"sfdc","recordTypeId":"01270000000Du3nAAC","accountType":"Employer Group"},'+
        '"EMPLOYER / SPONSOR":{"ssn":"sfdc","recordTypeId":"01270000000Du3nAAC","accountType":"Employer / Sponsor"},"EMPLOYER (NON-SPONSOR)":{"ssn":"sfdc","recordTypeId":"01270000000HfosAAC","accountType":"Employer (Non-Sponsor)"},'+
        '"DISTRIBUTOR/WHOLESALE PURCHASER":{"ssn":"ams","recordTypeId":"012700000001BA0AAM","accountType":"Distributor/Wholesale Purchaser"},"DISEASE MANAGEMENT ORGANIZATION":{"ssn":"sfdc","recordTypeId":"01270000000DvqZAAS","accountType":"Disease Management Organization"},'+
        '"COALITION":{"ssn":"sfdc","recordTypeId":"01270000000HfodAAC","accountType":"Coalition"},"COMPANY":{"ssn":"ams","recordTypeId":"0127000000015hnAAA","accountType":"Company"},'+
        '"CLINIC":{"ssn":"ams","recordTypeId":"0127000000015UkAAI","accountType":"Clinic"},"BOARD":{"ssn":"ams","recordTypeId":"0127000000015UvAAI","accountType":"Board"},'+
        '"BENEFIT CONSULTANT":{"ssn":"sfdc","recordTypeId":"01270000000Hfo3AAC","accountType":"Benefit Consultant"},"ASSISTANCE PROGRAM":{"ssn":"sfdc","recordTypeId":"01270000000Du3mAAC","accountType":"Assistance Program"},'+
        '"ADMINISTRATIVE SYSTEM":{"ssn":"ams","recordTypeId":"0127000000015UzAAI","accountType":"Administrative System"},"ACADEMIC INSTITUTION":{"ssn":"ams","recordTypeId":"0127000000015UyAAI","accountType":"Academic Institution"},'+
        '"PAYER":{"ssn":"bot","recordTypeId":"0127000000015UlAAI","accountType":"Payer"}},"hcp":{"default":{"ssn":null,"recordTypeId":"0127000000015UoAAI","accountType":null}}},'+
        '"territoriesMap":{"04T70000000KytSEAS":{"name":"002F303-ID,MT,WY,CO","id":"04T70000000KytSEAS","groupId":"00G70000001Y1C3EAK"},"04T700000000L5kEAE":{"name":"00RC205-ATLANTA-CHARLOTTE","id":"04T700000000L5kEAE","groupId":"00G70000002OWBJEA4"}},'+
        '"createInputFields":[{"properties":null,"name":"Name","label":"Organization Name","attributes":null,"attributeFlags":null,"value":"TEST Merge 001","required":true,"readOnly":false,"placeholder":null,"order":null,"mode":["New","Edit","View"],'+
        '"hidden":null,"helpText":"Enter the full legal name of this HCO.","displayValue":null,"describe":{"updateable":true,"type":"string","sObjectType":"Account","showNone":null,"restrictedPicklist":false,"relationshipName":null,"referenceTo":[],'+
        '"picklistValues":[],"permissionable":false,"nillable":true,"name":"Name","lookupData":null,"length":255,"label":"Name","inlineHelpText":"Enter the full legal name of this HCO.","htmlFormatted":false,"dependentPicklist":false,"createable":true,'+
        '"controllingField":null,"caseSensitive":false,"calculated":false}},{"properties":null,"name":"Account_Type_gne__c","label":"Account Type","attributes":null,"attributeFlags":null,"value":"Academic Institution","required":true,"readOnly":false,'+
        '"placeholder":null,"order":null,"mode":["New","Edit","View"],"hidden":null,"helpText":"Select a type for this Account.","displayValue":null,"describe":{"updateable":true,"type":"picklist","sObjectType":"Account","showNone":null,'+
        '"restrictedPicklist":false,"relationshipName":null,"referenceTo":[],"picklistValues":[{"value":"Academic Institution","label":"Academic Institution","defaultValue":false,"active":true},{"value":"Administrative System","label":"Administrative System",'+
        '"defaultValue":false,"active":true},{"value":"Assistance Program","label":"Assistance Program","defaultValue":false,"active":true},{"value":"Benefit Consultant","label":"Benefit Consultant","defaultValue":false,"active":true},'+
        '{"value":"Board","label":"Board","defaultValue":false,"active":true},{"value":"Clinic","label":"Clinic","defaultValue":false,"active":true},{"value":"Coalition","label":"Coalition","defaultValue":false,"active":true},'+
        '{"value":"Company","label":"Company","defaultValue":false,"active":true},{"value":"Disease Management Organization","label":"Disease Management Organization","defaultValue":false,"active":true},'+
        '{"value":"Distributor/Wholesale Purchaser","label":"Distributor/Wholesale Purchaser","defaultValue":false,"active":true},{"value":"Drug Manufacturer / Pharma Company","label":"Drug Manufacturer / Pharma Company","defaultValue":false,"active":true},'+
        '{"value":"Employer (Non-Sponsor)","label":"Employer (Non-Sponsor)","defaultValue":false,"active":true},{"value":"Employer / Sponsor","label":"Employer / Sponsor","defaultValue":false,"active":true},'+
        '{"value":"Employer Group","label":"Employer Group","defaultValue":false,"active":true},{"value":"Extended Care","label":"Extended Care","defaultValue":false,"active":true},{"value":"Group Purchasing Organization","label":"Group Purchasing Organization",'+
        '"defaultValue":false,"active":true},{"value":"Health Plan Association","label":"Health Plan Association","defaultValue":false,"active":true},{"value":"Hospital","label":"Hospital","defaultValue":false,"active":true},'+
        '{"value":"IPA","label":"IPA","defaultValue":false,"active":true},{"value":"Indemnity","label":"Indemnity","defaultValue":false,"active":true},{"value":"Information Provider","label":"Information Provider","defaultValue":false,"active":true},'+
        '{"value":"Laboratory","label":"Laboratory","defaultValue":false,"active":true},{"value":"Medical Claims Assistance","label":"Medical Claims Assistance","defaultValue":false,"active":true},'+
        '{"value":"Miscellaneous","label":"Miscellaneous","defaultValue":false,"active":true},{"value":"Multi-Service HealthCare","label":"Multi-Service HealthCare","defaultValue":false,"active":true},'+
        '{"value":"Network","label":"Network","defaultValue":false,"active":true},{"value":"PBM","label":"PBM","defaultValue":false,"active":true},{"value":"Payer","label":"Payer","defaultValue":false,"active":true},'+
        '{"value":"Pharmacy","label":"Pharmacy","defaultValue":false,"active":true},{"value":"Physician Practice","label":"Physician Practice","defaultValue":false,"active":true},{"value":"Prison","label":"Prison","defaultValue":false,"active":true},'+
        '{"value":"Professional Organization","label":"Professional Organization","defaultValue":false,"active":true},{"value":"Publication","label":"Publication","defaultValue":false,"active":true},'+
        '{"value":"Service Provider","label":"Service Provider","defaultValue":false,"active":true},{"value":"Specialty Distributor","label":"Specialty Distributor","defaultValue":false,"active":true},'+
        '{"value":"Specialty Pharmacy","label":"Specialty Pharmacy","defaultValue":false,"active":true},{"value":"TPA","label":"TPA","defaultValue":false,"active":true},{"value":"Union","label":"Union","defaultValue":false,"active":true}],'+
        '"permissionable":true,"nillable":true,"name":"Account_Type_gne__c","lookupData":null,"length":255,"label":"Account Type","inlineHelpText":"Select a type for this Account.","htmlFormatted":false,"dependentPicklist":false,'+
        '"createable":true,"controllingField":null,"caseSensitive":false,"calculated":false}},{"properties":null,"name":"Name","label":"Street Address","attributes":null,"attributeFlags":null,"value":"4502 Medical Drive",'+
        '"required":true,"readOnly":false,"placeholder":null,"order":null,"mode":["New","Edit","View"],"hidden":null,"helpText":"Enter the...","displayValue":null,'+
        '"describe":{"updateable":true,"type":"string","sObjectType":"Address_vod__c","showNone":null,"restrictedPicklist":false,"relationshipName":null,"referenceTo":[],"picklistValues":[],"permissionable":false,"nillable":true,'+
        '"name":"Name","lookupData":null,"length":80,"label":"Street Address","inlineHelpText":"Enter the primary address line for this account address.","htmlFormatted":false,"dependentPicklist":false,"createable":true,'+
        '"controllingField":null,"caseSensitive":false,"calculated":false}},{"properties":null,"name":"Address_line_2_vod__c","label":"Suite/Floor/Unit","attributes":null,"attributeFlags":null,"value":"6","required":false,"readOnly":false,"placeholder":null,'+
        '"order":null,"mode":["New","Edit","View"],"hidden":null,"helpText":"Optionally, enter a secondary address line for this account address.","displayValue":null,"describe":{"updateable":true,"type":"string","sObjectType":"Address_vod__c",'+
        '"showNone":null,"restrictedPicklist":false,"relationshipName":null,"referenceTo":[],"picklistValues":[],"permissionable":true,"nillable":true,"name":"Address_line_2_vod__c","lookupData":null,"length":100,'+
        '"label":"Suite/Floor/Unit","inlineHelpText":"Optionally, enter a secondary address line for this account address.","htmlFormatted":false,"dependentPicklist":false,"createable":true,"controllingField":null,'+
        '"caseSensitive":false,"calculated":false}},{"properties":null,"name":"City_vod__c","label":"City","attributes":null,"attributeFlags":null,"value":"SAN ANTONIO","required":true,"readOnly":false,'+
        '"placeholder":null,"order":null,"mode":["New","Edit","View"],"hidden":null,"helpText":"Enter the city for this account address.","displayValue":null,"describe":{"updateable":true,"type":"string","sObjectType":"Address_vod__c",'+
        '"showNone":null,"restrictedPicklist":false,"relationshipName":null,"referenceTo":[],"picklistValues":[],"permissionable":true,"nillable":true,"name":"City_vod__c","lookupData":null,"length":40,"label":"City",'+
        '"inlineHelpText":"Enter the city for this account address.","htmlFormatted":false,"dependentPicklist":false,"createable":true,"controllingField":null,"caseSensitive":false,"calculated":false}},'+
        '{"properties":null,"name":"State_vod__c","label":"State","attributes":null,"attributeFlags":null,"value":"TX","required":true,"readOnly":false,"placeholder":null,"order":null,"mode":["New","Edit","View"],'+
        '"hidden":null,"helpText":"Select the state for this account address.","displayValue":null,"describe":{"updateable":true,"type":"picklist","sObjectType":"Address_vod__c","showNone":null,"restrictedPicklist":false,'+
        '"relationshipName":null,"referenceTo":[],"picklistValues":[{"value":"AL","label":"AL","defaultValue":false,"active":true},{"value":"AK","label":"AK","defaultValue":false,"active":true}],'+
        '"permissionable":true,"nillable":true,"name":"State_vod__c","lookupData":null,"length":255,"label":"State","inlineHelpText":"Select the state for this account address.",'+
        '"htmlFormatted":false,"dependentPicklist":true,"createable":true,"controllingField":"Country_gen__c","caseSensitive":false,"calculated":false}},'+
        '{"properties":null,"name":"Zip_vod__c","label":"Zip Code","attributes":null,"attributeFlags":null,"value":"78229","required":true,"readOnly":false,"placeholder":null,"order":null,'+
        '"mode":["New","Edit","View"],"hidden":null,"helpText":"Enter from 3 to 5 digits. Optionally the 9 digit Zip code with a dash is allowed.","displayValue":null,'+
        '"describe":{"updateable":true,"type":"string","sObjectType":"Address_vod__c","showNone":null,"restrictedPicklist":false,"relationshipName":null,"referenceTo":[],"picklistValues":[],'+
        '"permissionable":true,"nillable":true,"name":"Zip_vod__c","lookupData":null,"length":20,"label":"Zip","inlineHelpText":"Enter from 3 to 5 digits. Optionally the 9 digit Zip code with a dash is allowed.",'+
        '"htmlFormatted":false,"dependentPicklist":false,"createable":true,"controllingField":null,"caseSensitive":false,"calculated":false}},{"properties":null,"name":"territory","label":"Territory","attributes":null,'+
        '"attributeFlags":null,"value":"04T700000000L5kEAE","required":false,"readOnly":false,"placeholder":null,"order":null,"mode":["New","Edit","View"],"hidden":null,"helpText":"....",'+
        '"displayValue":null,"describe":{"updateable":true,"type":"picklist","sObjectType":null,"showNone":null,"restrictedPicklist":false,"relationshipName":null,"referenceTo":null,'+
        '"picklistValues":[{"value":"04T700000000L5kEAE","label":"00RC205-ATLANTA-CHARLOTTE","defaultValue":false,"active":true},{"value":"04T70000000KytSEAS","label":"002F303-ID,MT,WY,CO","defaultValue":false,"active":true},'+
        '{"value":null,"label":"--Do Not Align--","defaultValue":false,"active":true}],"permissionable":true,"nillable":true,"name":"territory","lookupData":null,"length":null,"label":null,"inlineHelpText":"....",'+
        '"htmlFormatted":false,"dependentPicklist":false,"createable":true,"controllingField":null,"caseSensitive":false,"calculated":null}}]}';
    
    @isTest
    static void initTest() {
        GNE_FRM_TestData.ForGNE_SFA2_SBC_Ctrl_Test testData = new GNE_FRM_TestData.ForGNE_SFA2_SBC_Ctrl_Test();
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_Account_SBC');
        Test.setCurrentPage(pageRef);
        Test.startTest();
            System.runAs(testData.frmUser) {
                GNE_SFA2_SBC_Ctrl controller = new GNE_SFA2_SBC_Ctrl();        	
            }
        Test.stopTest();
        
    }
    
    @isTest
    static void test_StandardController() { 
        GNE_FRM_TestData.ForGNE_SFA2_SBC_Ctrl_Test testData = new GNE_FRM_TestData.ForGNE_SFA2_SBC_Ctrl_Test();
        Account testAccount = GNE_FRM_TestUtilities.createAccount('Winner Account', 'FRM_HCO','Pharmacy', true);
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_Account_SBC');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
            System.runAs(testData.frmUser) {
                ApexPages.StandardController sc = new ApexPages.StandardController(testAccount);
                GNE_SFA2_SBC_Ctrl controller = new GNE_SFA2_SBC_Ctrl(sc);   	
            }
        Test.stopTest();   
    }
    
    @isTest
    static void testRemoteAction_Search_ExceptionInJson() {
        GNE_FRM_TestData.ForGNE_SFA2_SBC_Ctrl_Test testData = new GNE_FRM_TestData.ForGNE_SFA2_SBC_Ctrl_Test();
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_Account_SBC');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
            System.runAs(testData.frmUser) {
                GNE_SFA2_SBC_Ctrl.search('null to force Exception');   	
            }
        Test.stopTest();      

    }
    
    @isTest
    static void testRemoteAction_Search() {
        GNE_FRM_TestData.ForGNE_SFA2_SBC_Ctrl_Test testData = new GNE_FRM_TestData.ForGNE_SFA2_SBC_Ctrl_Test();
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_Account_SBC');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
            System.runAs(testData.frmUser) {
                GNE_SFA2_SBC_Ctrl.search(strJSON);   	
            }
        Test.stopTest();   
    }
    
    @isTest
    static void testRemoteAction_searchMore() { 
        GNE_FRM_TestData.ForGNE_SFA2_SBC_Ctrl_Test testData = new GNE_FRM_TestData.ForGNE_SFA2_SBC_Ctrl_Test();
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_Account_SBC');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
            System.runAs(testData.frmUser) {
                GNE_SFA2_SBC_Ctrl.searchMore(strJSON);   	
            }
        Test.stopTest();   
    }
    
    @isTest
    static void test_getDispatcherOtherPage() {
        GNE_FRM_TestData.ForGNE_SFA2_SBC_Ctrl_Test testData = new GNE_FRM_TestData.ForGNE_SFA2_SBC_Ctrl_Test();
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_Account_SBC');
        Test.setCurrentPage(pageRef);
        PageReference tempPR;
        
        Test.startTest();
            System.runAs(testData.frmUser) {
                GNE_SFA2_SBC_Ctrl controller = new GNE_SFA2_SBC_Ctrl();  
                tempPR = controller.getDispatcherOtherPage();   	
            }
        Test.stopTest();  
        System.assertEquals('/apex/gne_account_search_create', tempPR.getUrl());        
    }
    
    @isTest
    static void test_getDispatcherOtherPage_isCreateAddressMode() {
        GNE_FRM_TestData.ForGNE_SFA2_SBC_Ctrl_Test testData = new GNE_FRM_TestData.ForGNE_SFA2_SBC_Ctrl_Test();
        Account testAccount = GNE_FRM_TestUtilities.createAccount('Winner Account', 'FRM_HCO','Pharmacy', true);
        insert new GNE_SFA2_MCCO_CRM_Profiles__c(Name = 'GNE-Field');
        
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_Address_SBC');
        Test.setCurrentPage(pageRef);
        
        PageReference tempPR;
        
        Test.startTest();
            System.runAs(testData.frmUser) {
                GNE_SFA2_SBC_Ctrl controller = new GNE_SFA2_SBC_Ctrl();  
                tempPR = controller.getDispatcherOtherPage();   	
            }
        Test.stopTest();  
        Boolean result = tempPR.getUrl().contains('/apex/gne_crm_address_edit_create');
        System.assertEquals(true, result);        
    }
    
    @isTest
    static void testRemoteAction_createAccount() { 
        GNE_FRM_TestData.ForGNE_SFA2_SBC_Ctrl_Test testData = new GNE_FRM_TestData.ForGNE_SFA2_SBC_Ctrl_Test();
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_Account_SBC');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
            System.runAs(testData.frmUser) {
                GNE_SFA2_SBC_Ctrl.createAccount(strInputJSON);   	
            }
        Test.stopTest();   
    }
    
    @isTest
    static void testRemoteAction_upsertAccountFromMdm() { 
        GNE_FRM_TestData.ForGNE_SFA2_SBC_Ctrl_Test testData = new GNE_FRM_TestData.ForGNE_SFA2_SBC_Ctrl_Test();
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_Account_SBC');
        Test.setCurrentPage(pageRef);
        
        Test.startTest();
            System.runAs(testData.frmUser) {
                GNE_SFA2_SBC_Ctrl.upsertAccountFromMdm(strInputJSON);   	
            }
        Test.stopTest();   
    }
}