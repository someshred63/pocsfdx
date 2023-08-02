@isTest
private class GNE_TISL_Site_Test 
{
    static testMethod void GNE_TISL_Site_Dao_constructor_test()
    {
        GNE_TISL_Site_Dao dao = new GNE_TISL_Site_Dao(true);
        System.Assert(dao.ClassName == 'GNE_TISL_Site_Dao');
    }
    
    static testMethod void GNE_TISL_Site_Dao_getByPager_test()
    {
        GNE_TISL_ClinicalTrialAPI.StudyBatch testStudyBatch = new GNE_TISL_ClinicalTrialAPI.StudyBatch();
        testStudyBatch.studyList = new List<GNE_TISL_ClinicalTrialAPI.Study>();        
        GNE_TISL_ClinicalTrialAPI.Response response;

        GNE_TISL_ClinicalTrialAPI.Study testStudy = new GNE_TISL_ClinicalTrialAPI.Study();
        testStudy.StudyName = 'testStudy';
        testStudy.StudyNumber = 'testStudy';
        testStudy.StudyStatus = 'Active';
        testStudy.ProductName = 'testStudy';
        testStudy.ProductDescription = 'testStudyProductDescription';
        testStudy.Phase = 'Phase I';
        testStudy.Diagnosis = 'testStudy';
        testStudy.StudyContactName = 'testStudy';        
        testStudy.TherapeuticArea = 'Cardiovascular and Metabolic';
        testStudy.SourceSystemName = 'Siebel';
        testStudy.StudyShortTitle = 'testStudy';
        testStudy.NCTNumber = '';
        testStudy.EudraCTNumber = '';
        testStudy.siteList = new List<GNE_TISL_ClinicalTrialAPI.Site>();        

        GNE_TISL_ClinicalTrialAPI.Site testSite1 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite1.SiteName = 'testSite1';        
        testSite1.SiteGeoLatitude = '1';
        testSite1.SiteGeoLongitude = '1';
        testSite1.SiteStatus = 'Active';
        testSite1.SiteCity = 'testSite1';
        testSite1.SiteCountry = 'UNITED STATES';
        testSite1.SiteContactFirstName = 'testSite1';
        testSite1.SiteContactLastName = 'testSite1';
        testSite1.SiteContactPhone = '12345';
        testSite1.SiteContactEmail = 'test@Site1.mail';
        testSite1.SiteNumber = 'testSite1';    
        testSite1.SiteAddress = 'testSite1';    
        testSite1.SiteState = 'CA';     
        testSite1.SiteZipCode = 'testSite1';   
        testSite1.SiteContactUniqueId = 'testSite1'; 
        
        GNE_TISL_ClinicalTrialAPI.Site testSite2 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite2.SiteName = 'testSite2';        
        testSite2.SiteGeoLatitude = '2';
        testSite2.SiteGeoLongitude = '2';
        testSite2.SiteStatus = 'Active';
        testSite2.SiteCity = 'testSite2';
        testSite2.SiteCountry = 'UNITED STATES';
        testSite2.SiteContactFirstName = 'testSite2';
        testSite2.SiteContactLastName = 'testSite2';
        testSite2.SiteContactPhone = '12345';
        testSite2.SiteContactEmail = 'test@Site2.mail';     
        
        GNE_TISL_ClinicalTrialAPI.Site testSite3 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite3.SiteName = 'testSite3';
        testSite3.SiteGeoLatitude = '3';
        testSite3.SiteGeoLongitude = '3';
        testSite3.SiteStatus = 'Active';
        testSite3.SiteCity = 'testSite3';
        testSite3.SiteCountry = 'UNITED STATES';
        testSite3.SiteContactFirstName = 'testSite3';
        testSite3.SiteContactLastName = 'testSite3';
        testSite3.SiteContactPhone = '12345';
        testSite3.SiteContactEmail = 'test@Site3.mail';     
        
        testStudy.siteList.add(testSite1);
        testStudy.siteList.add(testSite2);
        testStudy.siteList.add(testSite3);
        testStudyBatch.studyList.add(testStudy);

        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        List<TISL_Clinical_Trial_gne__c> studyList = [select Id, Name, Trial_Number_gne__c, Phase_gne__c,
                                                      Trial_Status_gne__c, Product_Name_gne__c, Diagnosis_gne__c,
                                                      Trial_Contact_Name_gne__c, Therapeutic_Area_gne__c, Source_System_gne__c,
                                                      NCT_Number_gne__c, EudraCT_Number_gne__c, Trial_Short_Title_gne__c
                                                      from TISL_Clinical_Trial_gne__c where Trial_Number_gne__c IN ('testStudy')];
        GNE_TISL_Site_Pager pager = new GNE_TISL_Site_Pager();
        pager.TrialId = studyList[0].Id;
        GNE_TISL_Site_Dao dao = new GNE_TISL_Site_Dao(true);
        List<TISL_Site_gne__c> siteList = dao.getByPager(pager);
        System.Assert(siteList.size() == 3);
        System.Assert(siteList[0].Site_City_gne__c == 'testSite1');
        System.Assert(siteList[1].Site_City_gne__c == 'testSite2');
        System.Assert(siteList[2].Site_City_gne__c == 'testSite3');             
    }   
    
    static testMethod void GNE_TISL_Site_Dao_getAddresses_test()
    {
        GNE_TISL_ClinicalTrialAPI.StudyBatch testStudyBatch = new GNE_TISL_ClinicalTrialAPI.StudyBatch();
        testStudyBatch.studyList = new List<GNE_TISL_ClinicalTrialAPI.Study>();        
        GNE_TISL_ClinicalTrialAPI.Response response;

        GNE_TISL_ClinicalTrialAPI.Study testStudy = new GNE_TISL_ClinicalTrialAPI.Study();
        testStudy.StudyName = 'testStudy';
        testStudy.StudyNumber = 'testStudy';
        testStudy.StudyStatus = 'Active';
        testStudy.ProductName = 'testStudy';
        testStudy.ProductDescription = 'testStudyProductDescription';
        testStudy.Phase = 'Phase I';
        testStudy.Diagnosis = 'testStudy';
        testStudy.StudyContactName = 'testStudy';        
        testStudy.TherapeuticArea = 'Cardiovascular and Metabolic';
        testStudy.SourceSystemName = 'Siebel';
        testStudy.StudyShortTitle = 'testStudy';
        testStudy.NCTNumber = '';
        testStudy.EudraCTNumber = '';
        testStudy.siteList = new List<GNE_TISL_ClinicalTrialAPI.Site>();        

        GNE_TISL_ClinicalTrialAPI.Site testSite1 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite1.SiteName = 'testSite1';        
        testSite1.SiteGeoLatitude = '1';
        testSite1.SiteGeoLongitude = '1';
        testSite1.SiteStatus = 'Active';
        testSite1.SiteCity = 'testSite1';
        testSite1.SiteCountry = 'UNITED STATES';
        testSite1.SiteContactFirstName = 'testSite1';
        testSite1.SiteContactLastName = 'testSite1';
        testSite1.SiteContactPhone = '12345';
        testSite1.SiteContactEmail = 'test@Site1.mail';
        testSite1.SiteNumber = 'testSite1';    
        testSite1.SiteAddress = 'testSite1';    
        testSite1.SiteState = 'CA';     
        testSite1.SiteZipCode = 'testSite1';   
        testSite1.SiteContactUniqueId = 'testSite1'; 
        
        GNE_TISL_ClinicalTrialAPI.Site testSite2 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite2.SiteName = 'testSite2';        
        testSite2.SiteGeoLatitude = '2';
        testSite2.SiteGeoLongitude = '2';
        testSite2.SiteStatus = 'Active';
        testSite2.SiteCity = 'testSite2';
        testSite2.SiteCountry = 'UNITED STATES';
        testSite2.SiteContactFirstName = 'testSite2';
        testSite2.SiteContactLastName = 'testSite2';
        testSite2.SiteContactPhone = '12345';
        testSite2.SiteContactEmail = 'test@Site2.mail';
        testSite2.SiteState = 'CA';     
        testSite2.SiteZipCode = 'testSite2';   
        
        GNE_TISL_ClinicalTrialAPI.Site testSite3 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite3.SiteName = 'testSite3';
        testSite3.SiteGeoLatitude = '3';
        testSite3.SiteGeoLongitude = '3';
        testSite3.SiteStatus = 'Active';
        testSite3.SiteCity = 'testSite3';
        testSite3.SiteCountry = 'UNITED STATES';
        testSite3.SiteContactFirstName = 'testSite3';
        testSite3.SiteContactLastName = 'testSite3';
        testSite3.SiteContactPhone = '12345';
        testSite3.SiteContactEmail = 'test@Site3.mail';
        testSite3.SiteState = 'CA';     
        testSite3.SiteZipCode = 'testSite3';   
        
        testStudy.siteList.add(testSite1);
        testStudy.siteList.add(testSite2);
        testStudy.siteList.add(testSite3);
        testStudyBatch.studyList.add(testStudy);

        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        List<TISL_Clinical_Trial_gne__c> studyList = [select Id, Name, Trial_Number_gne__c, Phase_gne__c,
                                                      Trial_Status_gne__c, Product_Name_gne__c, Diagnosis_gne__c,
                                                      Trial_Contact_Name_gne__c, Therapeutic_Area_gne__c, Source_System_gne__c,
                                                      NCT_Number_gne__c, EudraCT_Number_gne__c, Trial_Short_Title_gne__c
                                                      from TISL_Clinical_Trial_gne__c where Trial_Number_gne__c IN ('testStudy')];
        GNE_TISL_Site_Pager pager = new GNE_TISL_Site_Pager();
        pager.TrialId = studyList[0].Id;
        GNE_TISL_Site_Dao dao = new GNE_TISL_Site_Dao(true);
        List<TISL_Site_gne__c> siteList = dao.getByPager(pager);
        String address = dao.getAddresses(pager);
        System.Assert(address <> null);
        System.Assert(address.contains('testSite1') == true);
        System.Assert(address.contains('testSite2') == true);
        System.Assert(address.contains('testSite3') == true);
    }

    static testMethod void GNE_TISL_Site_Dao_getStatesOrCountries_test()
    {
        GNE_TISL_ClinicalTrialAPI.StudyBatch testStudyBatch = new GNE_TISL_ClinicalTrialAPI.StudyBatch();
        testStudyBatch.studyList = new List<GNE_TISL_ClinicalTrialAPI.Study>();        
        GNE_TISL_ClinicalTrialAPI.Response response;

        GNE_TISL_ClinicalTrialAPI.Study testStudy = new GNE_TISL_ClinicalTrialAPI.Study();
        testStudy.StudyName = 'testStudy';
        testStudy.StudyNumber = 'testStudy';
        testStudy.StudyStatus = 'Active';
        testStudy.ProductName = 'testStudy';
        testStudy.ProductDescription = 'testStudyProductDescription';
        testStudy.Phase = 'Phase I';
        testStudy.Diagnosis = 'testStudy';
        testStudy.StudyContactName = 'testStudy';        
        testStudy.TherapeuticArea = 'Cardiovascular and Metabolic';
        testStudy.SourceSystemName = 'Siebel';
        testStudy.StudyShortTitle = 'testStudy';
        testStudy.NCTNumber = '';
        testStudy.EudraCTNumber = '';
        testStudy.siteList = new List<GNE_TISL_ClinicalTrialAPI.Site>();        

        GNE_TISL_ClinicalTrialAPI.Site testSite1 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite1.SiteName = 'testSite1';        
        testSite1.SiteGeoLatitude = '1';
        testSite1.SiteGeoLongitude = '1';
        testSite1.SiteStatus = 'Active';
        testSite1.SiteCity = 'testSite1';
        testSite1.SiteCountry = 'UNITED STATES';
        testSite1.SiteContactFirstName = 'testSite1';
        testSite1.SiteContactLastName = 'testSite1';
        testSite1.SiteContactPhone = '12345';
        testSite1.SiteContactEmail = 'test@Site1.mail';
        testSite1.SiteNumber = 'testSite1';    
        testSite1.SiteAddress = 'testSite1';    
        testSite1.SiteState = 'CA';     
        testSite1.SiteZipCode = 'testSite1';   
        testSite1.SiteContactUniqueId = 'testSite1'; 
        
        GNE_TISL_ClinicalTrialAPI.Site testSite2 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite2.SiteName = 'testSite2';        
        testSite2.SiteGeoLatitude = '2';
        testSite2.SiteGeoLongitude = '2';
        testSite2.SiteStatus = 'Active';
        testSite2.SiteCity = 'testSite2';
        testSite2.SiteCountry = 'MEXICO';
        testSite2.SiteContactFirstName = 'testSite2';
        testSite2.SiteContactLastName = 'testSite2';
        testSite2.SiteContactPhone = '12345';
        testSite2.SiteContactEmail = 'test@Site2.mail';
        testSite2.SiteState = 'PA';     
        testSite2.SiteZipCode = 'testSite2';   
        
        GNE_TISL_ClinicalTrialAPI.Site testSite3 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite3.SiteName = 'testSite3';
        testSite3.SiteGeoLatitude = '3';
        testSite3.SiteGeoLongitude = '3';
        testSite3.SiteStatus = 'Active';
        testSite3.SiteCity = 'testSite3';
        testSite3.SiteCountry = 'FRANCE';
        testSite3.SiteContactFirstName = 'testSite3';
        testSite3.SiteContactLastName = 'testSite3';
        testSite3.SiteContactPhone = '12345';
        testSite3.SiteContactEmail = 'test@Site3.mail';
        testSite3.SiteState = 'IN';     
        testSite3.SiteZipCode = 'testSite3';   
        
        testStudy.siteList.add(testSite1);
        testStudy.siteList.add(testSite2);
        testStudy.siteList.add(testSite3);
        testStudyBatch.studyList.add(testStudy);

        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        List<TISL_Clinical_Trial_gne__c> studyList = [select Id, Name, Trial_Number_gne__c, Phase_gne__c,
                                                      Trial_Status_gne__c, Product_Name_gne__c, Diagnosis_gne__c,
                                                      Trial_Contact_Name_gne__c, Therapeutic_Area_gne__c, Source_System_gne__c,
                                                      NCT_Number_gne__c, EudraCT_Number_gne__c, Trial_Short_Title_gne__c
                                                      from TISL_Clinical_Trial_gne__c where Trial_Number_gne__c IN ('testStudy')];
        GNE_TISL_Site_Pager pager = new GNE_TISL_Site_Pager();
        pager.TrialId = studyList[0].Id;
        pager.FilteredBy = 'State';
        GNE_TISL_Site_Dao dao = new GNE_TISL_Site_Dao(true);
        List<TISL_Site_gne__c> siteList = dao.getByPager(pager);
        List<String> result = dao.getStatesOrCountries(pager);
        System.Assert(result[0] == 'CA');
        System.Assert(result[1] == 'PA');
        System.Assert(result[2] == 'IN');
        pager.FilteredBy = 'Country';
        result.clear();
        result = dao.getStatesOrCountries(pager);
        System.Debug('ZZZZZZZZZZZZZZZZZZ ' + result);
        System.Assert(result[0] == 'UNITED STATES');
        System.Assert(result[1] == 'MEXICO');
        System.Assert(result[2] == 'FRANCE');
    }   
     
    static testMethod void GNE_TISL_Site_Pager_getByPager_test()
    {
        GNE_TISL_ClinicalTrialAPI.StudyBatch testStudyBatch = new GNE_TISL_ClinicalTrialAPI.StudyBatch();
        testStudyBatch.studyList = new List<GNE_TISL_ClinicalTrialAPI.Study>();        
        GNE_TISL_ClinicalTrialAPI.Response response;

        GNE_TISL_ClinicalTrialAPI.Study testStudy = new GNE_TISL_ClinicalTrialAPI.Study();
        testStudy.StudyName = 'testStudy';
        testStudy.StudyNumber = 'testStudy';
        testStudy.StudyStatus = 'Active';
        testStudy.ProductName = 'testStudy';
        testStudy.ProductDescription = 'testStudyProductDescription';
        testStudy.Phase = 'Phase I';
        testStudy.Diagnosis = 'testStudy';
        testStudy.StudyContactName = 'testStudy';        
        testStudy.TherapeuticArea = 'Cardiovascular and Metabolic';
        testStudy.SourceSystemName = 'Siebel';
        testStudy.StudyShortTitle = 'testStudy';
        testStudy.NCTNumber = '';
        testStudy.EudraCTNumber = '';
        testStudy.siteList = new List<GNE_TISL_ClinicalTrialAPI.Site>();        

        GNE_TISL_ClinicalTrialAPI.Site testSite1 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite1.SiteName = 'testSite1';        
        testSite1.SiteGeoLatitude = '1';
        testSite1.SiteGeoLongitude = '1';
        testSite1.SiteStatus = 'Active';
        testSite1.SiteCity = 'testSite1';
        testSite1.SiteCountry = 'UNITED STATES';
        testSite1.SiteContactFirstName = 'testSite1';
        testSite1.SiteContactLastName = 'testSite1';
        testSite1.SiteContactPhone = '12345';
        testSite1.SiteContactEmail = 'test@Site1.mail';
        testSite1.SiteNumber = 'testSite1';    
        testSite1.SiteAddress = 'testSite1';    
        testSite1.SiteState = 'CA';     
        testSite1.SiteZipCode = 'testSite1';   
        testSite1.SiteContactUniqueId = 'testSite1'; 
        
        GNE_TISL_ClinicalTrialAPI.Site testSite2 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite2.SiteName = 'testSite2';        
        testSite2.SiteGeoLatitude = '2';
        testSite2.SiteGeoLongitude = '2';
        testSite2.SiteStatus = 'Active';
        testSite2.SiteCity = 'testSite2';
        testSite2.SiteCountry = 'UNITED STATES';
        testSite2.SiteContactFirstName = 'testSite2';
        testSite2.SiteContactLastName = 'testSite2';
        testSite2.SiteContactPhone = '12345';
        testSite2.SiteContactEmail = 'test@Site2.mail';
        testSite2.SiteState = 'CA';     
        testSite2.SiteZipCode = 'testSite2';   
        
        GNE_TISL_ClinicalTrialAPI.Site testSite3 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite3.SiteName = 'testSite3';
        testSite3.SiteGeoLatitude = '3';
        testSite3.SiteGeoLongitude = '3';
        testSite3.SiteStatus = 'Active';
        testSite3.SiteCity = 'testSite3';
        testSite3.SiteCountry = 'UNITED STATES';
        testSite3.SiteContactFirstName = 'testSite3';
        testSite3.SiteContactLastName = 'testSite3';
        testSite3.SiteContactPhone = '12345';
        testSite3.SiteContactEmail = 'test@Site3.mail';
        testSite3.SiteState = 'CA';     
        testSite3.SiteZipCode = 'testSite3';   
        
        testStudy.siteList.add(testSite1);
        testStudy.siteList.add(testSite2);
        testStudy.siteList.add(testSite3);
        testStudyBatch.studyList.add(testStudy);

        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        List<TISL_Clinical_Trial_gne__c> studyList = [select Id, Name, Trial_Number_gne__c, Phase_gne__c,
                                                      Trial_Status_gne__c, Product_Name_gne__c, Diagnosis_gne__c,
                                                      Trial_Contact_Name_gne__c, Therapeutic_Area_gne__c, Source_System_gne__c,
                                                      NCT_Number_gne__c, EudraCT_Number_gne__c, Trial_Short_Title_gne__c
                                                      from TISL_Clinical_Trial_gne__c where Trial_Number_gne__c IN ('testStudy')];
        GNE_TISL_Site_Pager pager = new GNE_TISL_Site_Pager(true);
        pager.TrialId = studyList[0].Id;
        pager.FilteredBy = 'State';     
        System.Assert(pager.currSort == 'SiteName__c');
        List<SObject> lista = pager.getByPager(pager);
        System.Assert(lista.size() == 3);
    }    
     
    static testMethod void GNE_TISL_Site_Pager_getStatesOrCountries_test()
    {
        GNE_TISL_ClinicalTrialAPI.StudyBatch testStudyBatch = new GNE_TISL_ClinicalTrialAPI.StudyBatch();
        testStudyBatch.studyList = new List<GNE_TISL_ClinicalTrialAPI.Study>();        
        GNE_TISL_ClinicalTrialAPI.Response response;

        GNE_TISL_ClinicalTrialAPI.Study testStudy = new GNE_TISL_ClinicalTrialAPI.Study();
        testStudy.StudyName = 'testStudy';
        testStudy.StudyNumber = 'testStudy';
        testStudy.StudyStatus = 'Active';
        testStudy.ProductName = 'testStudy';
        testStudy.ProductDescription = 'testStudyProductDescription';
        testStudy.Phase = 'Phase I';
        testStudy.Diagnosis = 'testStudy';
        testStudy.StudyContactName = 'testStudy';        
        testStudy.TherapeuticArea = 'Cardiovascular and Metabolic';
        testStudy.SourceSystemName = 'Siebel';
        testStudy.StudyShortTitle = 'testStudy';
        testStudy.NCTNumber = '';
        testStudy.EudraCTNumber = '';
        testStudy.siteList = new List<GNE_TISL_ClinicalTrialAPI.Site>();        

        GNE_TISL_ClinicalTrialAPI.Site testSite1 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite1.SiteName = 'testSite1';        
        testSite1.SiteGeoLatitude = '1';
        testSite1.SiteGeoLongitude = '1';
        testSite1.SiteStatus = 'Active';
        testSite1.SiteCity = 'testSite1';
        testSite1.SiteCountry = 'UNITED STATES';
        testSite1.SiteContactFirstName = 'testSite1';
        testSite1.SiteContactLastName = 'testSite1';
        testSite1.SiteContactPhone = '12345';
        testSite1.SiteContactEmail = 'test@Site1.mail';
        testSite1.SiteNumber = 'testSite1';    
        testSite1.SiteAddress = 'testSite1';    
        testSite1.SiteState = 'CA';     
        testSite1.SiteZipCode = 'testSite1';   
        testSite1.SiteContactUniqueId = 'testSite1'; 
        
        GNE_TISL_ClinicalTrialAPI.Site testSite2 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite2.SiteName = 'testSite2';        
        testSite2.SiteGeoLatitude = '2';
        testSite2.SiteGeoLongitude = '2';
        testSite2.SiteStatus = 'Active';
        testSite2.SiteCity = 'testSite2';
        testSite2.SiteCountry = 'MEXICO';
        testSite2.SiteContactFirstName = 'testSite2';
        testSite2.SiteContactLastName = 'testSite2';
        testSite2.SiteContactPhone = '12345';
        testSite2.SiteContactEmail = 'test@Site2.mail';
        testSite2.SiteState = 'PA';     
        testSite2.SiteZipCode = 'testSite2';   
        
        GNE_TISL_ClinicalTrialAPI.Site testSite3 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite3.SiteName = 'testSite3';
        testSite3.SiteGeoLatitude = '3';
        testSite3.SiteGeoLongitude = '3';
        testSite3.SiteStatus = 'Active';
        testSite3.SiteCity = 'testSite3';
        testSite3.SiteCountry = 'FRANCE';
        testSite3.SiteContactFirstName = 'testSite3';
        testSite3.SiteContactLastName = 'testSite3';
        testSite3.SiteContactPhone = '12345';
        testSite3.SiteContactEmail = 'test@Site3.mail';
        testSite3.SiteState = 'IN';     
        testSite3.SiteZipCode = 'testSite3';   
        
        testStudy.siteList.add(testSite1);
        testStudy.siteList.add(testSite2);
        testStudy.siteList.add(testSite3);
        testStudyBatch.studyList.add(testStudy);

        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        List<TISL_Clinical_Trial_gne__c> studyList = [select Id, Name, Trial_Number_gne__c, Phase_gne__c,
                                                      Trial_Status_gne__c, Product_Name_gne__c, Diagnosis_gne__c,
                                                      Trial_Contact_Name_gne__c, Therapeutic_Area_gne__c, Source_System_gne__c,
                                                      NCT_Number_gne__c, EudraCT_Number_gne__c, Trial_Short_Title_gne__c
                                                      from TISL_Clinical_Trial_gne__c where Trial_Number_gne__c IN ('testStudy')];
        GNE_TISL_Site_Pager pager = new GNE_TISL_Site_Pager(true);
        pager.TrialId = studyList[0].Id;
        pager.FilteredBy = 'State';     
        pager.getByPager(pager);
        List<String> result = pager.getStatesOrCountries();     
        System.Assert(result.size() == 3);   
        System.Assert(result[0] == 'CA');
        System.Assert(result[1] == 'PA');
        System.Assert(result[2] == 'IN');
        pager.FilteredBy = 'Country';
        result.clear();
        result = pager.getStatesOrCountries();
        System.Assert(result[0] == 'UNITED STATES');
        System.Assert(result[1] == 'MEXICO');
        System.Assert(result[2] == 'FRANCE');
    }
    
    static testMethod void GNE_TISL_Site_Pager_getAddresses_test()
    {
        GNE_TISL_ClinicalTrialAPI.StudyBatch testStudyBatch = new GNE_TISL_ClinicalTrialAPI.StudyBatch();
        testStudyBatch.studyList = new List<GNE_TISL_ClinicalTrialAPI.Study>();        
        GNE_TISL_ClinicalTrialAPI.Response response;

        GNE_TISL_ClinicalTrialAPI.Study testStudy = new GNE_TISL_ClinicalTrialAPI.Study();
        testStudy.StudyName = 'testStudy';
        testStudy.StudyNumber = 'testStudy';
        testStudy.StudyStatus = 'Active';
        testStudy.ProductName = 'testStudy';
        testStudy.ProductDescription = 'testStudyProductDescription';
        testStudy.Phase = 'Phase I';
        testStudy.Diagnosis = 'testStudy';
        testStudy.StudyContactName = 'testStudy';        
        testStudy.TherapeuticArea = 'Cardiovascular and Metabolic';
        testStudy.SourceSystemName = 'Siebel';
        testStudy.StudyShortTitle = 'testStudy';
        testStudy.NCTNumber = '';
        testStudy.EudraCTNumber = '';
        testStudy.siteList = new List<GNE_TISL_ClinicalTrialAPI.Site>();        

        GNE_TISL_ClinicalTrialAPI.Site testSite1 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite1.SiteName = 'testSite1';        
        testSite1.SiteGeoLatitude = '1';
        testSite1.SiteGeoLongitude = '1';
        testSite1.SiteStatus = 'Active';
        testSite1.SiteCity = 'testSite1';
        testSite1.SiteCountry = 'UNITED STATES';
        testSite1.SiteContactFirstName = 'testSite1';
        testSite1.SiteContactLastName = 'testSite1';
        testSite1.SiteContactPhone = '12345';
        testSite1.SiteContactEmail = 'test@Site1.mail';
        testSite1.SiteNumber = 'testSite1';    
        testSite1.SiteAddress = 'testSite1';    
        testSite1.SiteState = 'CA';     
        testSite1.SiteZipCode = 'testSite1';   
        testSite1.SiteContactUniqueId = 'testSite1'; 
        
        GNE_TISL_ClinicalTrialAPI.Site testSite2 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite2.SiteName = 'testSite2';        
        testSite2.SiteGeoLatitude = '2';
        testSite2.SiteGeoLongitude = '2';
        testSite2.SiteStatus = 'Active';
        testSite2.SiteCity = 'testSite2';
        testSite2.SiteCountry = 'UNITED STATES';
        testSite2.SiteContactFirstName = 'testSite2';
        testSite2.SiteContactLastName = 'testSite2';
        testSite2.SiteContactPhone = '12345';
        testSite2.SiteContactEmail = 'test@Site2.mail';
        testSite2.SiteState = 'CA';     
        testSite2.SiteZipCode = 'testSite2';   
        
        GNE_TISL_ClinicalTrialAPI.Site testSite3 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite3.SiteName = 'testSite3';
        testSite3.SiteGeoLatitude = '3';
        testSite3.SiteGeoLongitude = '3';
        testSite3.SiteStatus = 'Active';
        testSite3.SiteCity = 'testSite3';
        testSite3.SiteCountry = 'UNITED STATES';
        testSite3.SiteContactFirstName = 'testSite3';
        testSite3.SiteContactLastName = 'testSite3';
        testSite3.SiteContactPhone = '12345';
        testSite3.SiteContactEmail = 'test@Site3.mail';
        testSite3.SiteState = 'CA';     
        testSite3.SiteZipCode = 'testSite3';   
        
        testStudy.siteList.add(testSite1);
        testStudy.siteList.add(testSite2);
        testStudy.siteList.add(testSite3);
        testStudyBatch.studyList.add(testStudy);

        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        List<TISL_Clinical_Trial_gne__c> studyList = [select Id, Name, Trial_Number_gne__c, Phase_gne__c,
                                                      Trial_Status_gne__c, Product_Name_gne__c, Diagnosis_gne__c,
                                                      Trial_Contact_Name_gne__c, Therapeutic_Area_gne__c, Source_System_gne__c,
                                                      NCT_Number_gne__c, EudraCT_Number_gne__c, Trial_Short_Title_gne__c
                                                      from TISL_Clinical_Trial_gne__c where Trial_Number_gne__c IN ('testStudy')];
        GNE_TISL_Site_Pager pager = new GNE_TISL_Site_Pager(true);
        pager.TrialId = studyList[0].Id;
        pager.FilteredBy = 'State';     
        pager.getByPager(pager);
        String result = pager.getAddresses();
        System.Assert(result.contains('testSite1') == true);
        System.Assert(result.contains('testSite2') == true);
        System.Assert(result.contains('testSite3') == true);
    }
    
    static testMethod void GNE_TISL_Site_Information_Controller_getFilters_test()
    {
        GNE_TISL_ClinicalTrialAPI.StudyBatch testStudyBatch = new GNE_TISL_ClinicalTrialAPI.StudyBatch();
        testStudyBatch.studyList = new List<GNE_TISL_ClinicalTrialAPI.Study>();        
        GNE_TISL_ClinicalTrialAPI.Response response;

        GNE_TISL_ClinicalTrialAPI.Study testStudy = new GNE_TISL_ClinicalTrialAPI.Study();
        testStudy.StudyName = 'testStudy';
        testStudy.StudyNumber = 'testStudy';
        testStudy.StudyStatus = 'Active';
        testStudy.ProductName = 'testStudy';
        testStudy.ProductDescription = 'testStudyProductDescription';
        testStudy.Phase = 'Phase I';
        testStudy.Diagnosis = 'testStudy';
        testStudy.StudyContactName = 'testStudy';        
        testStudy.TherapeuticArea = 'Cardiovascular and Metabolic';
        testStudy.SourceSystemName = 'Siebel';
        testStudy.StudyShortTitle = 'testStudy';
        testStudy.NCTNumber = '';
        testStudy.EudraCTNumber = '';
        testStudy.siteList = new List<GNE_TISL_ClinicalTrialAPI.Site>();        

        GNE_TISL_ClinicalTrialAPI.Site testSite1 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite1.SiteName = 'testSite1';        
        testSite1.SiteGeoLatitude = '1';
        testSite1.SiteGeoLongitude = '1';
        testSite1.SiteStatus = 'Active';
        testSite1.SiteCity = 'testSite1';
        testSite1.SiteCountry = 'UNITED STATES';
        testSite1.SiteContactFirstName = 'testSite1';
        testSite1.SiteContactLastName = 'testSite1';
        testSite1.SiteContactPhone = '12345';
        testSite1.SiteContactEmail = 'test@Site1.mail';
        testSite1.SiteNumber = 'testSite1';    
        testSite1.SiteAddress = 'testSite1';    
        testSite1.SiteState = 'CA';     
        testSite1.SiteZipCode = 'testSite1';   
        testSite1.SiteContactUniqueId = 'testSite1'; 
        
        GNE_TISL_ClinicalTrialAPI.Site testSite2 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite2.SiteName = 'testSite2';        
        testSite2.SiteGeoLatitude = '2';
        testSite2.SiteGeoLongitude = '2';
        testSite2.SiteStatus = 'Active';
        testSite2.SiteCity = 'testSite2';
        testSite2.SiteCountry = 'UNITED STATES';
        testSite2.SiteContactFirstName = 'testSite2';
        testSite2.SiteContactLastName = 'testSite2';
        testSite2.SiteContactPhone = '12345';
        testSite2.SiteContactEmail = 'test@Site2.mail';
        testSite2.SiteState = 'CA';     
        testSite2.SiteZipCode = 'testSite2';   

        testStudy.siteList.add(testSite1);
        testStudy.siteList.add(testSite2);
        testStudyBatch.studyList.add(testStudy);
        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        List<TISL_Clinical_Trial_gne__c> studyList = [select Id, Name, Trial_Number_gne__c, Phase_gne__c,
                                                      Trial_Status_gne__c, Product_Name_gne__c, Diagnosis_gne__c,
                                                      Trial_Contact_Name_gne__c, Therapeutic_Area_gne__c, Source_System_gne__c,
                                                      NCT_Number_gne__c, EudraCT_Number_gne__c, Trial_Short_Title_gne__c
                                                      from TISL_Clinical_Trial_gne__c where Trial_Number_gne__c IN ('testStudy')];
        
        PageReference opptyPage = new PageReference('/apex/GNE_TISL_Site_Information');
        Test.setCurrentPage(opptyPage);
        
        TISL_Clinical_Trial_gne__c obj = studyList[0];
        ApexPages.StandardController std = new ApexPages.StandardController(obj);
        GNE_TISL_Site_Information_Controller controller = new GNE_TISL_Site_Information_Controller(std);
        List<SelectOption> result = controller.getFilters();
        System.Assert(result <> null);
        System.Assert(result.size() == 2);
    }
        
    static testMethod void GNE_TISL_Site_Information_Controller_getStatesOrCountries_test()     
    {
        GNE_TISL_ClinicalTrialAPI.StudyBatch testStudyBatch = new GNE_TISL_ClinicalTrialAPI.StudyBatch();
        testStudyBatch.studyList = new List<GNE_TISL_ClinicalTrialAPI.Study>();        
        GNE_TISL_ClinicalTrialAPI.Response response;

        GNE_TISL_ClinicalTrialAPI.Study testStudy = new GNE_TISL_ClinicalTrialAPI.Study();
        testStudy.StudyName = 'testStudy';
        testStudy.StudyNumber = 'testStudy';
        testStudy.StudyStatus = 'Active';
        testStudy.ProductName = 'testStudy';
        testStudy.ProductDescription = 'testStudyProductDescription';
        testStudy.Phase = 'Phase I';
        testStudy.Diagnosis = 'testStudy';
        testStudy.StudyContactName = 'testStudy';        
        testStudy.TherapeuticArea = 'Cardiovascular and Metabolic';
        testStudy.SourceSystemName = 'Siebel';
        testStudy.StudyShortTitle = 'testStudy';
        testStudy.NCTNumber = '';
        testStudy.EudraCTNumber = '';
        testStudy.siteList = new List<GNE_TISL_ClinicalTrialAPI.Site>();        

        GNE_TISL_ClinicalTrialAPI.Site testSite1 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite1.SiteName = 'testSite1';        
        testSite1.SiteGeoLatitude = '1';
        testSite1.SiteGeoLongitude = '1';
        testSite1.SiteStatus = 'Active';
        testSite1.SiteCity = 'testSite1';
        testSite1.SiteCountry = 'UNITED STATES';
        testSite1.SiteContactFirstName = 'testSite1';
        testSite1.SiteContactLastName = 'testSite1';
        testSite1.SiteContactPhone = '12345';
        testSite1.SiteContactEmail = 'test@Site1.mail';
        testSite1.SiteNumber = 'testSite1';    
        testSite1.SiteAddress = 'testSite1';    
        testSite1.SiteState = 'CA';     
        testSite1.SiteZipCode = 'testSite1';   
        testSite1.SiteContactUniqueId = 'testSite1'; 
        
        GNE_TISL_ClinicalTrialAPI.Site testSite2 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite2.SiteName = 'testSite2';        
        testSite2.SiteGeoLatitude = '2';
        testSite2.SiteGeoLongitude = '2';
        testSite2.SiteStatus = 'Active';
        testSite2.SiteCity = 'testSite2';
        testSite2.SiteCountry = 'UNITED STATES';
        testSite2.SiteContactFirstName = 'testSite2';
        testSite2.SiteContactLastName = 'testSite2';
        testSite2.SiteContactPhone = '12345';
        testSite2.SiteContactEmail = 'test@Site2.mail';
        testSite2.SiteState = 'PA';     
        testSite2.SiteZipCode = 'testSite2';   

        testStudy.siteList.add(testSite1);
        testStudy.siteList.add(testSite2);
        testStudyBatch.studyList.add(testStudy);
        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        List<TISL_Clinical_Trial_gne__c> studyList = [select Id, Name, Trial_Number_gne__c, Phase_gne__c,
                                                      Trial_Status_gne__c, Product_Name_gne__c, Diagnosis_gne__c,
                                                      Trial_Contact_Name_gne__c, Therapeutic_Area_gne__c, Source_System_gne__c,
                                                      NCT_Number_gne__c, EudraCT_Number_gne__c, Trial_Short_Title_gne__c
                                                      from TISL_Clinical_Trial_gne__c where Trial_Number_gne__c IN ('testStudy')];
        
        PageReference opptyPage = new PageReference('/apex/GNE_TISL_Site_Information');
        Test.setCurrentPage(opptyPage);
        
        TISL_Clinical_Trial_gne__c obj = studyList[0];
        ApexPages.StandardController std = new ApexPages.StandardController(obj);
        GNE_TISL_Site_Information_Controller controller = new GNE_TISL_Site_Information_Controller(std);
        List<SelectOption> result = controller.getStatesOrCountries();
        System.Assert(result <> null);
        System.Assert(result.size() == 3);
    }
}