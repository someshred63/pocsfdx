@isTest
private class GNE_TISL_ClinicalTrialAPI_Test 
{
    static testMethod void emptyStudyBatch() 
    {
        GNE_TISL_ClinicalTrialAPI.StudyBatch testStudyBatch = new GNE_TISL_ClinicalTrialAPI.StudyBatch();
        GNE_TISL_ClinicalTrialAPI.Response response;
        
        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        System.assert(response.errorList.size() == 0);        
    }
      
    static testMethod void oneEmptyStudyTest() 
    {
        GNE_TISL_ClinicalTrialAPI.StudyBatch testStudyBatch = new GNE_TISL_ClinicalTrialAPI.StudyBatch();
        GNE_TISL_ClinicalTrialAPI.Study testStudy = new GNE_TISL_ClinicalTrialAPI.Study();
        GNE_TISL_ClinicalTrialAPI.Response response;
        testStudyBatch.studyList = new List<GNE_TISL_ClinicalTrialAPI.Study>();
        testStudyBatch.studyList.add(testStudy);
        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        system.debug('\n\n oneEmptyStudyTest.response ' + response  + '\n\n');
        System.assert(response.StartTime <> null);
        System.assert(response.EndTime <> null);
        System.assert(response.errorList.size() == 0);
    }
 
    static testMethod void oneStudyTest() 
    {
        GNE_TISL_ClinicalTrialAPI.StudyBatch testStudyBatch = new GNE_TISL_ClinicalTrialAPI.StudyBatch();
        testStudyBatch.studyList = new List<GNE_TISL_ClinicalTrialAPI.Study>();        
        GNE_TISL_ClinicalTrialAPI.Response response;

        GNE_TISL_ClinicalTrialAPI.Study testStudy = new GNE_TISL_ClinicalTrialAPI.Study();
        testStudy.StudyName         = 'testStudyName';
        testStudy.StudyNumber       = 'testStudy1Number';
        testStudy.StudyStatus       = 'Active Not Recruiting';
        testStudy.ProductName       = 'testStudyProduct';
        testStudy.ProductDescription= 'testStudyProductDesc';
        testStudy.Phase             = 'Phase I';
        testStudy.Diagnosis         = 'testStudyDia';
        testStudy.StudyContactName  = 'testStudyContactName';
        testStudy.TherapeuticArea   = 'Cardiovascular and Metabolic';
        testStudy.SourceSystemName  = 'Siebel';
        testStudy.siteList = new List<GNE_TISL_ClinicalTrialAPI.Site>();
        testStudyBatch.studyList.add(testStudy);

        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        system.debug('\n\n oneStudyTest.response ' + response  + '\n\n');
        List<TISL_Clinical_Trial_gne__c> studyList = [select Id, Diagnosis_gne__c, EudraCT_Number_gne__c, Trial_Full_Title_gne__c,
                                                      Last_Updated_Date_Calc_gne__c, NCT_Number_gne__c, NCT_Number_Calc_gne__c,
                                                      Phase_gne__c, Product_Name_Calc_gne__c, Product_Description_gne__c,
                                                      Product_Name_gne__c, Trial_Short_Title_gne__c, Source_System_gne__c, Trial_Status_gne__c,
                                                      Therapeutic_Area_gne__c, Trial_Contact_Name_gne__c, Trial_Number_gne__c
                                                      from TISL_Clinical_Trial_gne__c where Trial_Number_gne__c IN ('testStudy1Number')];
        System.Assert(studyList.size() == 1);
        System.Assert(studyList[0].Trial_Number_gne__c          == 'testStudy1Number');
        System.Assert(studyList[0].Trial_Status_gne__c          == 'Active Not Recruiting');                
        System.Assert(studyList[0].Diagnosis_gne__c             == 'testStudyDia');
        System.Assert(studyList[0].EudraCT_Number_gne__c        == null);
        System.Assert(studyList[0].Trial_Full_Title_gne__c      == 'testStudyName');
        System.Assert(studyList[0].NCT_Number_gne__c            == null);
        System.Assert(studyList[0].Phase_gne__c                 == 'Phase I');
        System.Assert(studyList[0].Product_Name_gne__c          == 'testStudyProduct');
        System.Assert(studyList[0].Product_Description_gne__c   == 'testStudyProductDesc');
        System.Assert(studyList[0].Trial_Short_Title_gne__c     == null);                        
        System.Assert(studyList[0].Trial_Contact_Name_gne__c    == 'testStudyContactName');
        System.Assert(studyList[0].Therapeutic_Area_gne__c      == 'Cardiovascular and Metabolic');
        System.Assert(studyList[0].Source_System_gne__c         == 'Siebel');
        List<TISL_Site_gne__c> siteList = [select Id, Name, Clinical_Trial_gne__c from TISL_Site_gne__c where Clinical_Trial_gne__c = :studyList[0].Id];
        System.Assert(siteList.size() == 0);
    }
    
    static testMethod void oneStudyThreeSitesTest() 
    {
        GNE_TISL_ClinicalTrialAPI.StudyBatch testStudyBatch = new GNE_TISL_ClinicalTrialAPI.StudyBatch();
        testStudyBatch.studyList = new List<GNE_TISL_ClinicalTrialAPI.Study>();        
        GNE_TISL_ClinicalTrialAPI.Response response;

        GNE_TISL_ClinicalTrialAPI.Study testStudy = new GNE_TISL_ClinicalTrialAPI.Study();
        testStudy.StudyName         = 'testStudyName';
        testStudy.StudyNumber       = 'testStudyNumber';
        testStudy.StudyStatus       = 'Active Not Recruiting';
        testStudy.ProductName       = 'testStudyProduct';
        testStudy.ProductDescription= 'testStudyProductDesc';
        testStudy.Phase             = 'Phase I';
        testStudy.Diagnosis         = 'testStudyDia';
        testStudy.StudyContactName  = 'testStudyContactName';
        testStudy.StudyContactRole  = 'testStudyContactRole';
        testStudy.StudyContactEmail = 'testStudyContact@email.gene.com';
        testStudy.TherapeuticArea   = 'Cardiovascular and Metabolic';
        testStudy.SourceSystemName  = 'Siebel';
        testStudy.StudyShortTitle   = 'testStudyShortTitle';
        testStudy.NCTNumber         = 'NCTtestStudyNumber';
        testStudy.EudraCTNumber     = 'testStudyEudraCTNumber';
        testStudy.siteList = new List<GNE_TISL_ClinicalTrialAPI.Site>();        

        GNE_TISL_ClinicalTrialAPI.Site testSite1 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite1.SiteName              = 'testSite1';        
        testSite1.SiteGeoLatitude       = '0';
        testSite1.SiteGeoLongitude      = '1';
        testSite1.SiteStatus            = 'Active';
        testSite1.SiteCity              = 'testSite1';
        testSite1.SiteCountry           = 'UNITED STATES';
        testSite1.SiteContactFirstName  = 'testSite1FirstName';
        testSite1.SiteContactLastName   = 'testSite1LastName';
        testSite1.SiteContactRole       = 'testSite1Role';
        testSite1.SiteContactPhone      = '12345';
        testSite1.SiteContactEmail      = 'test@Site1.mail';
        testSite1.SiteNumber            = 'testSite1SiteNumber';    
        testSite1.SiteAddress           = 'testSite1SiteAddress';    
        testSite1.SiteState             = 'CA';     
        testSite1.SiteZipCode           = 'testSite1SiteZipCode';   
        testSite1.SiteContactUniqueId   = 'testSite1SiteContactUniqueId'; 
        
        GNE_TISL_ClinicalTrialAPI.Site testSite2 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite2.SiteName              = 'testSite2';        
        testSite2.SiteGeoLatitude       = '1';
        testSite2.SiteGeoLongitude      = '2';
        testSite2.SiteStatus            = 'Committed';
        testSite2.SiteCity              = 'testSite2';
        testSite2.SiteCountry           = 'POLAND';
        testSite2.SiteContactFirstName  = 'testSite2FirstName';
        testSite2.SiteContactLastName   = 'testSite2LastName';
        testSite2.SiteContactPhone      = '123456';
        testSite2.SiteContactEmail      = 'test@Site2.mail';     
        
        GNE_TISL_ClinicalTrialAPI.Site testSite3 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite3.SiteName              = 'testSite3';
        testSite3.SiteGeoLatitude       = '';
        testSite3.SiteGeoLongitude      = '';
        testSite3.SiteStatus            = 'Follow-Up';
        testSite3.SiteCity              = 'testSite3';
        testSite3.SiteCountry           = 'UNITED STATES';
        //testSite3.SiteContactFirstName  = 'testSite3FirstName'; - build 4 - became optional
        //testSite3.SiteContactLastName   = 'testSite3LastName';  - build 4 - became optional
        testSite3.SiteContactPhone      = '1234567891011121314151617181920212223232425262728';
        testSite3.SiteContactEmail      = 'test@Site3.mail';  
        testSite3.SiteAddress           = 'testSite3SiteAddress';    
        testSite3.SiteState             = 'WA';     
        testSite3.SiteZipCode           = 'testSite3SiteZipCode';   
        testSite3.SiteContactUniqueId   = 'testSite3SiteContactUniqueId';            
        
        testStudy.siteList.add(testSite1);
        testStudy.siteList.add(testSite2);
        testStudy.siteList.add(testSite3);
        testStudyBatch.studyList.add(testStudy);

        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        system.debug('\n\n oneStudyThreeSitesTest.response ' + response  + '\n\n');
        List<TISL_Clinical_Trial_gne__c> studyList = [select Id, Diagnosis_gne__c, EudraCT_Number_gne__c, Trial_Full_Title_gne__c,
                                                      Last_Updated_Date_Calc_gne__c, NCT_Number_gne__c, NCT_Number_Calc_gne__c,
                                                      Phase_gne__c, Product_Name_Calc_gne__c, Product_Description_gne__c,
                                                      Product_Name_gne__c, Trial_Short_Title_gne__c, Source_System_gne__c, Trial_Status_gne__c,
                                                      Therapeutic_Area_gne__c, Trial_Contact_Name_gne__c,Trial_Contact_Role_gne__c,Trial_Contact_Email_gne__c, Trial_Number_gne__c
                                                      from TISL_Clinical_Trial_gne__c where Trial_Number_gne__c IN ('testStudyNumber')];
        System.Assert(studyList.size() == 1);        
        System.Assert(studyList[0].Trial_Number_gne__c          == 'testStudyNumber');
        System.Assert(studyList[0].Trial_Status_gne__c          == 'Active Not Recruiting');
        System.Assert(studyList[0].Product_Name_gne__c          == 'testStudyProduct');
        System.Assert(studyList[0].Product_Description_gne__c   == 'testStudyProductDesc');
        System.Assert(studyList[0].Phase_gne__c                 == 'Phase I');
        System.Assert(studyList[0].Diagnosis_gne__c             == 'testStudyDia');                
        System.Assert(studyList[0].Trial_Contact_Name_gne__c    == 'testStudyContactName');
        System.Assert(studyList[0].Trial_Contact_Role_gne__c    == 'testStudyContactRole'); 
        System.Assert(studyList[0].Trial_Contact_Email_gne__c    == 'testStudyContact@email.gene.com'); 
        System.Assert(studyList[0].Therapeutic_Area_gne__c      == 'Cardiovascular and Metabolic');
        System.Assert(studyList[0].Source_System_gne__c         == 'Siebel');        
        System.Assert(studyList[0].NCT_Number_gne__c            == 'NCTtestStudyNumber');
        System.Assert(studyList[0].EudraCT_Number_gne__c        == 'testStudyEudraCTNumber');
        System.Assert(studyList[0].Trial_Short_Title_gne__c     == 'testStudyShortTitle');                        
        
        List<TISL_Site_gne__c> siteList = [select Id, Site_Name_gne__c, Clinical_Trial_gne__c, Site_Latitude_gne__c,
                                           Site_Longitude_gne__c, Site_Status_gne__c, Site_City_gne__c, 
                                           Site_Country_gne__c, Site_Contact_First_Name_gne__c, Site_Contact_Last_Name_gne__c,
                                           Site_Contact_Role_gne__c, Site_Contact_Phone_gne__c, Site_Contact_Email_gne__c, Site_Number_gne__c,
                                           Site_Address_gne__c, Site_State_gne__c, Site_Zip_Code_gne__c, Site_Contact_Unique_Id_gne__c
                                           from TISL_Site_gne__c where Clinical_Trial_gne__c = :studyList[0].Id];
        System.Assert(siteList.size() == 3);
    
        System.Assert(siteList[0].Site_Name_gne__c                  == 'testSite1');
        System.Assert(siteList[0].Site_Latitude_gne__c              == 0);
        System.Assert(siteList[0].Site_Longitude_gne__c             == 1);
        System.Assert(siteList[0].Site_Status_gne__c                == 'Active');
        System.Assert(siteList[0].Site_City_gne__c                  == 'testSite1');
        System.Assert(siteList[0].Site_Country_gne__c               == 'UNITED STATES');                
        System.Assert(siteList[0].Site_Contact_First_Name_gne__c    == 'testSite1FirstName');
        System.Assert(siteList[0].Site_Contact_Last_Name_gne__c     == 'testSite1LastName');
        System.Assert(siteList[0].Site_Contact_Role_gne__c          == 'testSite1Role');
        System.Assert(siteList[0].Site_Contact_Phone_gne__c         == '12345');         
        System.Assert(siteList[0].Site_Contact_Email_gne__c         == 'test@Site1.mail');
        System.Assert(siteList[0].Site_Number_gne__c                == 'testSite1SiteNumber');        
        System.Assert(siteList[0].Site_Address_gne__c               == 'testSite1SiteAddress');
        System.Assert(siteList[0].Site_State_gne__c                 == 'CA');
        System.Assert(siteList[0].Site_Zip_Code_gne__c              == 'testSite1SiteZipCode');
        System.Assert(siteList[0].Site_Contact_Unique_Id_gne__c     == 'testSite1SiteContactUniqueId');   
        
        System.Assert(siteList[1].Site_Name_gne__c                  == 'testSite2');
        System.Assert(siteList[1].Site_Latitude_gne__c              == 1);
        System.Assert(siteList[1].Site_Longitude_gne__c             == 2);        
        System.Assert(siteList[1].Site_Status_gne__c                == 'Committed');
        System.Assert(siteList[1].Site_City_gne__c                  == 'testSite2');
        System.Assert(siteList[1].Site_Country_gne__c               == 'POLAND');                
        System.Assert(siteList[1].Site_Contact_First_Name_gne__c    == 'testSite2FirstName');
        System.Assert(siteList[1].Site_Contact_Last_Name_gne__c     == 'testSite2LastName');
        System.Assert(siteList[1].Site_Contact_Phone_gne__c         == '123456');         
        System.Assert(siteList[1].Site_Contact_Email_gne__c         == 'test@Site2.mail');
        System.Assert(siteList[1].Site_Number_gne__c                == null);        
        System.Assert(siteList[1].Site_Address_gne__c               == null);
        System.Assert(siteList[1].Site_State_gne__c                 == null);
        System.Assert(siteList[1].Site_Zip_Code_gne__c              == null);
        System.Assert(siteList[1].Site_Contact_Unique_Id_gne__c     == null);     
        
        System.Assert(siteList[2].Site_Name_gne__c                  == 'testSite3');
        System.Assert(siteList[2].Site_Latitude_gne__c              == 1);
        System.Assert(siteList[2].Site_Longitude_gne__c             == 2);
        System.Assert(siteList[2].Site_Status_gne__c                == 'Follow-Up');
        System.Assert(siteList[2].Site_City_gne__c                  == 'testSite3');
        System.Assert(siteList[2].Site_Country_gne__c               == 'UNITED STATES');                
        //System.Assert(siteList[2].Site_Contact_First_Name_gne__c    == 'testSite3FirstName');- build 4 - became optional
        //System.Assert(siteList[2].Site_Contact_Last_Name_gne__c     == 'testSite3LastName'); - build 4 - became optional
        System.Assert(siteList[2].Site_Contact_Phone_gne__c         == '1234567891011121314151617181920212223232425262728');         
        System.Assert(siteList[2].Site_Contact_Email_gne__c         == 'test@Site3.mail');
        System.Assert(siteList[2].Site_Number_gne__c                == null);        
        System.Assert(siteList[2].Site_Address_gne__c               == 'testSite3SiteAddress');
        System.Assert(siteList[2].Site_State_gne__c                 == 'WA');
        System.Assert(siteList[2].Site_Zip_Code_gne__c              == 'testSite3SiteZipCode');
        System.Assert(siteList[2].Site_Contact_Unique_Id_gne__c     == 'testSite3SiteContactUniqueId');                                          
    }    
        
    static testMethod void twoStudiesEmptyAndNotEmpty() 
    {
        GNE_TISL_ClinicalTrialAPI.StudyBatch testStudyBatch = new GNE_TISL_ClinicalTrialAPI.StudyBatch();
        testStudyBatch.studyList = new List<GNE_TISL_ClinicalTrialAPI.Study>();        
        GNE_TISL_ClinicalTrialAPI.Response response;

        GNE_TISL_ClinicalTrialAPI.Study testStudy1 = new GNE_TISL_ClinicalTrialAPI.Study();
        testStudy1.StudyName        = 'testStudyName';
        testStudy1.StudyNumber      = 'testStudy1Number';
        testStudy1.StudyStatus      = 'Active Not Recruiting';
        testStudy1.ProductName      = 'testStudyProduct';
        //testStudy1.ProductDescription= 'testStudyProductDescription'; - build 4 - became optional
        testStudy1.Phase            = 'Phase I';
        testStudy1.Diagnosis        = 'testStudyDia';
        //testStudy1.StudyContactName = 'testStudyContactName'; - build 4 - became optional
        testStudy1.TherapeuticArea  = 'Cardiovascular and Metabolic';
        testStudy1.SourceSystemName = 'Siebel';
        testStudy1.StudyShortTitle  = 'testStudyShortTitle';
        testStudy1.NCTNumber        = 'NCTtestStudyNumber';
        testStudy1.EudraCTNumber    = 'testStudyEudraCTNumber';
        testStudy1.siteList = new List<GNE_TISL_ClinicalTrialAPI.Site>();
        
        GNE_TISL_ClinicalTrialAPI.Study testStudy2 = new GNE_TISL_ClinicalTrialAPI.Study();
        testStudy2.StudyName        = 'testStudy2Name';
        testStudy2.StudyNumber      = 'testStudy2Number';
        testStudy2.StudyStatus      = 'Active Recruiting';
        testStudy2.ProductName      = 'testStudy2Product';
        testStudy1.ProductDescription= 'testStudyProductDescription';
        testStudy2.Phase            = 'Phase II';
        testStudy2.Diagnosis        = 'testStudy2Dia';
        testStudy2.StudyContactName = 'testStudy2ContactNametestStudy2ContactNametestStudy2ContactName';
        testStudy2.SourceSystemName = 'TrialWorks';
        testStudy2.StudyShortTitle  = 'testStudy2ShortTitle';
        testStudy2.NCTNumber        = 'NCTtestStudy2Number';
        testStudy2.siteList = new List<GNE_TISL_ClinicalTrialAPI.Site>();        
        
        GNE_TISL_ClinicalTrialAPI.Site testSite1 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite1.SiteName              = 'testSite1';        
        testSite1.SiteGeoLatitude       = '1';
        testSite1.SiteGeoLongitude      = '1';
        testSite1.SiteStatus            = 'Active';
        testSite1.SiteCity              = 'testSite1';
        testSite1.SiteCountry           = 'UNITED STATES';
        testSite1.SiteContactFirstName  = 'testSite1FirstName';
        testSite1.SiteContactLastName   = 'testSite1LastName';
        testSite1.SiteContactPhone      = '12345';
        testSite1.SiteContactEmail      = 'test@Site1.mail';
        testSite1.SiteNumber            = 'testSite1SiteNumber';    
        testSite1.SiteAddress           = 'testSite1SiteAddress';    
        testSite1.SiteState             = 'CA';     
        testSite1.SiteZipCode           = 'testSite1SiteZipCode';   
        testSite1.SiteContactUniqueId   = 'testSite1SiteContactUniqueId'; 
        
        GNE_TISL_ClinicalTrialAPI.Site testSite2 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite2.SiteName              = 'testSite2';        
        testSite2.SiteGeoLatitude       = '2';
        testSite2.SiteGeoLongitude      = '2';
        testSite2.SiteStatus            = 'Committed';
        testSite2.SiteCity              = 'testSite2';
        testSite2.SiteCountry           = 'POLAND';
        testSite2.SiteContactFirstName  = 'testSite2FirstName';
        testSite2.SiteContactLastName   = 'testSite2LastName';
        testSite2.SiteContactPhone      = '123456';
        testSite2.SiteContactEmail      = 'test@Site2.mail';   
        
        testStudy2.siteList.add(testSite1);
        testStudy2.siteList.add(testSite2);
        testStudyBatch.studyList.add(testStudy1);
        testStudyBatch.studyList.add(testStudy2);
        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        system.debug('\n\n twoStudiesEmptyAndNotEmpty.response ' + response  + '\n\n');
        List<TISL_Clinical_Trial_gne__c> studyList = [select Id from TISL_Clinical_Trial_gne__c where Trial_Number_gne__c IN ('testStudy1Number', 'testStudy2Number') order by Trial_Number_gne__c asc];
        System.Assert(studyList.size() == 2);
        List<TISL_Site_gne__c> siteList = [select Id from TISL_Site_gne__c where Clinical_Trial_gne__c = :studyList[0].Id];
        system.debug('\n\n TTT ' + siteList);
        System.Assert(siteList.size() == 0);                            
        siteList = [select Id from TISL_Site_gne__c where Clinical_Trial_gne__c = :studyList[1].Id];
        System.Assert(siteList.size() == 2);
    }        
     
    static testMethod void twoStudiesWithSites() 
    {
        GNE_TISL_ClinicalTrialAPI.StudyBatch testStudyBatch = new GNE_TISL_ClinicalTrialAPI.StudyBatch();
        testStudyBatch.studyList = new List<GNE_TISL_ClinicalTrialAPI.Study>();        
        GNE_TISL_ClinicalTrialAPI.Response response;

        GNE_TISL_ClinicalTrialAPI.Study testStudy1 = new GNE_TISL_ClinicalTrialAPI.Study();
        testStudy1.StudyName        = 'testStudyName';
        testStudy1.StudyNumber      = 'testStudy1Number';
        testStudy1.StudyStatus      = 'Active Not Recruiting';
        testStudy1.ProductName      = 'testStudyProduct';
        testStudy1.Phase            = 'Phase I';
        testStudy1.Diagnosis        = 'testStudyDia';
        testStudy1.StudyContactName = 'testStudyContactName';
        testStudy1.SourceSystemName = 'TrialWorks';
        testStudy1.StudyShortTitle  = 'testStudyShortTitle';
        testStudy1.NCTNumber        = 'NCTtestStudyNumber';
        testStudy1.siteList = new List<GNE_TISL_ClinicalTrialAPI.Site>();
        
        GNE_TISL_ClinicalTrialAPI.Site testSite1 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite1.SiteName              = 'testSite1';        
        testSite1.SiteGeoLatitude       = '1';
        testSite1.SiteGeoLongitude      = '1';
        testSite1.SiteStatus            = 'Active';
        testSite1.SiteCity              = 'testSite1';
        testSite1.SiteCountry           = 'UNITED STATES';
        testSite1.SiteContactFirstName  = 'testSite1FirstName';
        testSite1.SiteContactLastName   = 'testSite1LastName';
        testSite1.SiteContactPhone      = '12345';
        testSite1.SiteContactEmail      = 'test@Site1.mail';
        testSite1.SiteNumber            = 'testSite1SiteNumber';    
        testSite1.SiteAddress           = 'testSite1SiteAddress';    
        testSite1.SiteState             = 'CA';     
        testSite1.SiteZipCode           = 'testSite1SiteZipCode';   
        testSite1.SiteContactUniqueId   = 'testSite1SiteContactUniqueId'; 
        
        GNE_TISL_ClinicalTrialAPI.Site testSite2 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite2.SiteName              = 'testSite2';        
        testSite2.SiteGeoLatitude       = '2';
        testSite2.SiteGeoLongitude      = '2';
        testSite2.SiteStatus            = 'Committed';
        testSite2.SiteCity              = 'testSite2';
        testSite2.SiteCountry           = 'POLAND';
        testSite2.SiteContactFirstName  = 'testSite2FirstName';
        testSite2.SiteContactLastName   = 'testSite2LastName';
        testSite2.SiteContactPhone      = '123456';
        testSite2.SiteContactEmail      = 'test@Site2.mail';   
        
        GNE_TISL_ClinicalTrialAPI.Study testStudy2 = new GNE_TISL_ClinicalTrialAPI.Study();
        testStudy2.StudyName        = 'testStudy2Name';
        testStudy2.GNEStudyNumber   = 'testStudy1Number';
        testStudy2.StudyNumber      = 'testStudy2Number';
        testStudy2.StudyStatus      = 'Active Recruiting';
        testStudy2.ProductName      = 'testStudy2Product';
        testStudy2.ProductDescription= 'testStudy2ProductDesc';
        testStudy2.Phase            = 'Phase II';
        testStudy2.Diagnosis        = 'testStudy2Dia';
        testStudy2.StudyContactName = 'testStudy2ContactName';
        testStudy2.TherapeuticArea  = 'Cardiovascular and Metabolic';
        testStudy2.SourceSystemName = 'Siebel';
        testStudy2.StudyShortTitle  = 'testStudy2ShortTitle';
        testStudy2.NCTNumber        = 'NCTtestStudy2Number';
        testStudy2.EudraCTNumber    = 'testStudy2EudraCTNumber';
        testStudy2.siteList = new List<GNE_TISL_ClinicalTrialAPI.Site>();        
        
        GNE_TISL_ClinicalTrialAPI.Site testSite3 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite3.SiteName              = 'testSite3';        
        testSite3.SiteGeoLatitude       = '3';
        testSite3.SiteGeoLongitude      = '3';
        testSite3.SiteStatus            = 'Feasibility';
        testSite3.SiteCity              = 'testSite3';
        testSite3.SiteCountry           = 'UNITED STATES';
        testSite3.SiteContactFirstName  = 'testSite3FirstName';
        testSite3.SiteContactLastName   = 'testSite3LastName';
        testSite3.SiteContactPhone      = '32345';
        testSite3.SiteContactEmail      = 'test@Site3.mail';
        testSite3.SiteNumber            = 'testSite3SiteNumber';    
        testSite3.SiteAddress           = 'testSite3SiteAddress';    
        testSite3.SiteState             = 'CA';     
        testSite3.SiteZipCode           = 'testSite3SiteZipCode';   
        testSite3.SiteContactUniqueId   = 'testSite3SiteContactUniqueId'; 
        
        GNE_TISL_ClinicalTrialAPI.Site testSite4 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite4.SiteName              = 'testSite4';        
        testSite4.SiteGeoLatitude       = '4';
        testSite4.SiteGeoLongitude      = '4';
        testSite4.SiteStatus            = 'Clinical Closure';
        testSite4.SiteCity              = 'testSite4';
        testSite4.SiteCountry           = 'POLAND';
        testSite4.SiteContactFirstName  = 'testSite4FirstName';
        testSite4.SiteContactLastName   = 'testSite4LastName';
        testSite4.SiteContactPhone      = '123456';
        testSite4.SiteContactEmail      = 'test@Site4.mail';   
        
        GNE_TISL_ClinicalTrialAPI.Site testSite5 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite5.SiteName              = 'testSite5';        
        testSite5.SiteGeoLatitude       = '5';
        testSite5.SiteGeoLongitude      = '5';
        testSite5.SiteStatus            = 'Clinical Closure';
        testSite5.SiteCity              = 'testSite5';
        testSite5.SiteCountry           = 'POLAND';
        testSite5.SiteContactFirstName  = 'testSite5FirstName';
        testSite5.SiteContactLastName   = 'testSite5LastName';
        testSite5.SiteContactPhone      = '123556';
        testSite5.SiteContactEmail      = 'test@Site5.mail';         

        testStudy1.siteList.add(testSite1);
        testStudy1.siteList.add(testSite2);
        testStudy2.siteList.add(testSite3);
        testStudy2.siteList.add(testSite4);
        testStudy2.siteList.add(testSite5);
        testStudyBatch.studyList.add(testStudy1);
        testStudyBatch.studyList.add(testStudy2);
        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        system.debug('\n\n twoStudiesWithSites.response ' + response  + '\n\n');
        List<TISL_Clinical_Trial_gne__c> studyList = [select Id, Name, Trial_Number_gne__c from TISL_Clinical_Trial_gne__c where Trial_Number_gne__c IN ('testStudy1Number', 'testStudy2Number')];
        System.Assert(studyList.size() == 2);
        List<TISL_Site_gne__c> siteList = [select Id, Clinical_Trial_gne__c from TISL_Site_gne__c where Clinical_Trial_gne__c = :studyList[0].Id];
        System.Assert(siteList.size() == 2); 
        System.Assert(siteList[0].Clinical_Trial_gne__c == studyList[0].Id);
        System.Assert(siteList[1].Clinical_Trial_gne__c == studyList[0].Id);        
        siteList = [select Id, Clinical_Trial_gne__c from TISL_Site_gne__c where Clinical_Trial_gne__c = :studyList[1].Id];
        System.Assert(siteList.size() == 3);
        System.Assert(siteList[0].Clinical_Trial_gne__c == studyList[1].Id);
        System.Assert(siteList[1].Clinical_Trial_gne__c == studyList[1].Id);
        System.Assert(siteList[2].Clinical_Trial_gne__c == studyList[1].Id);
    }     
    
    static testMethod void twoStudiesOneWithError() 
    {
        GNE_TISL_ClinicalTrialAPI.StudyBatch testStudyBatch = new GNE_TISL_ClinicalTrialAPI.StudyBatch();
        testStudyBatch.studyList = new List<GNE_TISL_ClinicalTrialAPI.Study>();        
        GNE_TISL_ClinicalTrialAPI.Response response;

        GNE_TISL_ClinicalTrialAPI.Study testStudy1 = new GNE_TISL_ClinicalTrialAPI.Study();
        testStudy1.StudyName        = 'testStudyName';
        testStudy1.StudyNumber      = 'testStudy1Number';
        testStudy1.StudyStatus      = 'Active Not Recruiting';
        testStudy1.ProductName      = 'testStudyProduct';
        testStudy1.ProductDescription= 'testStudyProductDesc';
        testStudy1.Phase            = 'Phase I';
        testStudy1.Diagnosis        = 'testStudyDia';
        testStudy1.StudyContactName = 'testStudyContactName';
        testStudy1.TherapeuticArea  = 'Cardiovascular and Metabolic';
        testStudy1.SourceSystemName = 'Siebel';
        testStudy1.StudyShortTitle  = 'testStudyShortTitle';
        testStudy1.NCTNumber        = 'NCTtestStudyNumber';
        testStudy1.EudraCTNumber    = 'testStudyEudraCTNumber';
        testStudy1.siteList = new List<GNE_TISL_ClinicalTrialAPI.Site>();
        
        GNE_TISL_ClinicalTrialAPI.Site testSite1 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite1.SiteName              = 'testSite1';        
        testSite1.SiteGeoLatitude       = '1';
        testSite1.SiteGeoLongitude      = '1';
        testSite1.SiteStatus            = 'Active';
        testSite1.SiteCity              = 'testSite1';
        testSite1.SiteCountry           = 'UNITED STATES';
        testSite1.SiteContactFirstName  = 'testSite1FirstName';
        testSite1.SiteContactLastName   = 'testSite1LastName';
        testSite1.SiteContactPhone      = '12345';
        testSite1.SiteContactEmail      = 'test@Site1.mail';
        testSite1.SiteNumber            = 'testSite1SiteNumber';    
        testSite1.SiteAddress           = 'testSite1SiteAddress';    
        testSite1.SiteState             = 'CA';     
        testSite1.SiteZipCode           = 'testSite1SiteZipCode';   
        testSite1.SiteContactUniqueId   = 'testSite1SiteContactUniqueId'; 
        
        GNE_TISL_ClinicalTrialAPI.Site testSite4 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite4.SiteName              = 'testSite4';        
        testSite4.SiteGeoLatitude       = '4';
        testSite4.SiteGeoLongitude      = '4';
        testSite4.SiteStatus            = 'Clinical Closure';
        testSite4.SiteCity              = 'testSite4';
        testSite4.SiteCountry           = 'POLAND';
        testSite4.SiteContactFirstName  = 'testSite4FirstName';
        testSite4.SiteContactLastName   = 'testSite4LastName';
        testSite4.SiteContactPhone      = '123456';
        testSite4.SiteContactEmail      = 'test@Site4.mail';    
        
        GNE_TISL_ClinicalTrialAPI.Study testStudy2 = new GNE_TISL_ClinicalTrialAPI.Study();
        testStudy2.StudyNumber          = 'testStudy2';
        testStudy2.StudyStatus          = 'testStudy2';
        testStudy2.ProductName          = 'testStudy2';
        testStudy2.TherapeuticArea      = 'testStudy2';
        testStudy2.siteList = new List<GNE_TISL_ClinicalTrialAPI.Site>();        

        GNE_TISL_ClinicalTrialAPI.Site testSite2 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite2.SiteName              = 'testSite2';        
        testSite2.SiteGeoLatitude       = '2';
        testSite2.SiteGeoLongitude      = '2';
        testSite2.SiteStatus            = 'Committed';
        testSite2.SiteCity              = 'testSite2';
        testSite2.SiteCountry           = 'POLAND';
        testSite2.SiteContactFirstName  = 'testSite2FirstName';
        testSite2.SiteContactLastName   = 'testSite2LastName';
        testSite2.SiteContactPhone      = '123456';
        testSite2.SiteContactEmail      = 'test@Site2.mail';   
        
        GNE_TISL_ClinicalTrialAPI.Site testSite3 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite3.SiteName              = 'testSite3';        
        testSite3.SiteGeoLatitude       = '3';
        testSite3.SiteGeoLongitude      = '3';
        testSite3.SiteStatus            = 'Feasibility';
        testSite3.SiteCity              = 'testSite3';
        testSite3.SiteCountry           = 'UNITED STATES';
        testSite3.SiteContactFirstName  = 'testSite3FirstName';
        testSite3.SiteContactLastName   = 'testSite3LastName';
        testSite3.SiteContactPhone      = '32345';
        testSite3.SiteContactEmail      = 'test@Site3.mail';
        testSite3.SiteNumber            = 'testSite3SiteNumber';    
        testSite3.SiteAddress           = 'testSite3SiteAddress';    
        testSite3.SiteState             = 'CA';     
        testSite3.SiteZipCode           = 'testSite3SiteZipCode';   
        testSite3.SiteContactUniqueId   = 'testSite3SiteContactUniqueId';       
        
        testStudy1.siteList.add(testSite1);
        testStudy1.siteList.add(testSite4);
        testStudy2.siteList.add(testSite2);
        testStudy2.siteList.add(testSite3);
        testStudyBatch.studyList.add(testStudy1);
        testStudyBatch.studyList.add(testStudy2);

        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        system.debug('\n\n twoStudiesOneWithError.response ' + response  + '\n\n');
        List<TISL_Clinical_Trial_gne__c> studyList = [select Id, Name, Trial_Number_gne__c from TISL_Clinical_Trial_gne__c where Trial_Number_gne__c IN ('testStudy1Number', 'testStudy2Number')];
        System.Assert(studyList.size() == 1);
        System.Assert(studyList[0].Trial_Number_gne__c == 'testStudy1Number');
        List<TISL_Site_gne__c> siteList = [select Id, Name, Clinical_Trial_gne__c, Site_Status_gne__c from TISL_Site_gne__c where Clinical_Trial_gne__c = :studyList[0].Id];
        System.Assert(siteList.size() == 2);                            
    }  
    
    static testMethod void updateTestStudy() 
    {
        TISL_Clinical_Trial_gne__c ct = new TISL_Clinical_Trial_gne__c(Trial_Number_gne__c  = 'testStudy1Number',
                                        Trial_Full_Title_gne__c     = 'testStudyName', 
                                        Trial_Short_Title_gne__c    = 'testStudyShortTitle', 
                                        Trial_Status_gne__c         = 'Active Not Recruiting',
                                        NCT_Number_gne__c           = 'NCT12345',  
                                        EudraCT_Number_gne__c       = '54321',
                                        Product_Name_gne__c         = 'TestProduct',
                                        Product_Description_gne__c  = 'TestProductDesc',  
                                        Phase_gne__c                = 'Phase I',        
                                        Therapeutic_Area_gne__c     = 'Cardiovascular and Metabolic',
                                        Diagnosis_gne__c            = 'D1',      
                                        Source_System_gne__c        = 'Siebel',
                                        Trial_Contact_Name_gne__c   = 'testContact');
        insert ct;      
    
        GNE_TISL_ClinicalTrialAPI.StudyBatch testStudyBatch = new GNE_TISL_ClinicalTrialAPI.StudyBatch();
        testStudyBatch.studyList = new List<GNE_TISL_ClinicalTrialAPI.Study>();        
        GNE_TISL_ClinicalTrialAPI.Response response;        
        
        GNE_TISL_ClinicalTrialAPI.Study testStudy1 = new GNE_TISL_ClinicalTrialAPI.Study();
        testStudy1.StudyName            = 'testStudyName_NEW';
        testStudy1.StudyNumber          = 'testStudy1Number';
        testStudy1.StudyStatus          = 'Active Not Recruiting';
        testStudy1.ProductName          = 'testStudyProduct_NEW';
        testStudy1.ProductDescription   = 'testStudyProductDesc_NEW';
        testStudy1.Phase                = 'Phase II';
        testStudy1.Diagnosis            = 'testStudyDia_NEW';
        testStudy1.StudyContactName     = 'testStudyContactName_NEW';
        testStudy1.TherapeuticArea      = 'Oncology';
        testStudy1.SourceSystemName     = 'Siebel';
        testStudy1.StudyShortTitle      = 'testStudyShortTitle_NEW';
        testStudy1.NCTNumber            = 'NCTtestStudyNumber_NEW';
        testStudy1.EudraCTNumber        = 'testStudyEudraCTNumber_NEW';
        
        testStudyBatch.studyList.add(testStudy1);
        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        system.debug('\n\n updateTestStudy.response ' + response  + '\n\n');
        List<TISL_Clinical_Trial_gne__c> studyList = [select Id, Diagnosis_gne__c, EudraCT_Number_gne__c, Trial_Full_Title_gne__c,
                                                      Last_Updated_Date_Calc_gne__c, NCT_Number_gne__c, NCT_Number_Calc_gne__c,
                                                      Phase_gne__c, Product_Name_Calc_gne__c, Product_Description_gne__c,
                                                      Product_Name_gne__c, Trial_Short_Title_gne__c, Source_System_gne__c, Trial_Status_gne__c,
                                                      Therapeutic_Area_gne__c, Trial_Contact_Name_gne__c, Trial_Number_gne__c
                                                      from TISL_Clinical_Trial_gne__c 
                                                      where Trial_Number_gne__c IN ('testStudy1Number')];
        System.Assert(studyList.size() == 1);
        System.Assert(studyList[0].Trial_Number_gne__c          == 'testStudy1Number');
        System.Assert(studyList[0].Trial_Status_gne__c          == 'Active Not Recruiting');                
        System.Assert(studyList[0].Diagnosis_gne__c             == 'testStudyDia_NEW');
        System.Assert(studyList[0].EudraCT_Number_gne__c        == 'testStudyEudraCTNumber_NEW');
        System.Assert(studyList[0].Trial_Full_Title_gne__c      == 'testStudyName_NEW');
        System.Assert(studyList[0].NCT_Number_gne__c            == 'NCTtestStudyNumber_NEW');
        System.Assert(studyList[0].Phase_gne__c                 == 'Phase II');
        System.Assert(studyList[0].Product_Name_gne__c          == 'testStudyProduct_NEW');
        System.Assert(studyList[0].Product_Description_gne__c   == 'testStudyProductDesc_NEW');
        System.Assert(studyList[0].Product_Name_Calc_gne__c     == 'testStudyProduct_NEW testStudyProductDesc_NEW');
        System.Assert(studyList[0].Trial_Short_Title_gne__c     == 'testStudyShortTitle_NEW');                        
        System.Assert(studyList[0].Trial_Contact_Name_gne__c    == 'testStudyContactName_NEW');
        System.Assert(studyList[0].Therapeutic_Area_gne__c      == 'Oncology');
        System.Assert(studyList[0].Source_System_gne__c         == 'Siebel');          
    }
    static testMethod void trialWorksTestStudy() 
    {
        TISL_Clinical_Trial_gne__c ct = new TISL_Clinical_Trial_gne__c(Trial_Number_gne__c  = 'testStudy1Number',
                                        Trial_Full_Title_gne__c     = 'testStudyName', 
                                        Trial_Short_Title_gne__c    = 'testStudyShortTitle', 
                                        Trial_Status_gne__c         = 'Active Not Recruiting',
                                        NCT_Number_gne__c           = 'NCT12345',  
                                        EudraCT_Number_gne__c       = '54321',
                                        Product_Name_gne__c         = 'TestProduct',
                                        Product_Description_gne__c  = 'TestProductDesc',  
                                        Phase_gne__c                = 'Phase I',        
                                        Therapeutic_Area_gne__c     = 'Cardiovascular and Metabolic',
                                        Diagnosis_gne__c            = 'D1',      
                                        Source_System_gne__c        = 'TrialWorks',
                                        Trial_Contact_Name_gne__c   = 'testContact');
        insert ct;      
    
        GNE_TISL_ClinicalTrialAPI.StudyBatch testStudyBatch = new GNE_TISL_ClinicalTrialAPI.StudyBatch();
        testStudyBatch.studyList = new List<GNE_TISL_ClinicalTrialAPI.Study>();        
        GNE_TISL_ClinicalTrialAPI.Response response;        
        
        GNE_TISL_ClinicalTrialAPI.Study testStudy1 = new GNE_TISL_ClinicalTrialAPI.Study();
        testStudy1.StudyName            = 'testStudyName_NEW';
        testStudy1.StudyNumber          = 'testStudy2Number';
        testStudy1.GNEStudyNumber       = 'testStudy1Number';
        testStudy1.StudyStatus          = 'Active Not Recruiting';
        testStudy1.ProductName          = 'testStudyProduct_NEW';
        testStudy1.ProductDescription   = 'testStudyProductDesc_NEW';
        testStudy1.Phase                = 'Phase II';
        testStudy1.Diagnosis            = 'testStudyDia_NEW';
        testStudy1.StudyContactName     = 'testStudyContactName_NEW';
        testStudy1.TherapeuticArea      = 'Oncology';
        testStudy1.SourceSystemName     = 'Siebel';
        testStudy1.StudyShortTitle      = 'testStudyShortTitle_NEW';
        testStudy1.NCTNumber            = 'NCTtestStudyNumber_NEW';
        testStudy1.EudraCTNumber        = 'testStudyEudraCTNumber_NEW';
        
        testStudyBatch.studyList.add(testStudy1);
        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        system.debug('\n\n updateTestStudy.response ' + response  + '\n\n');
        List<TISL_Clinical_Trial_gne__c> studyList = [select Id, Diagnosis_gne__c, EudraCT_Number_gne__c, Trial_Full_Title_gne__c,
                                                      Last_Updated_Date_Calc_gne__c, NCT_Number_gne__c, NCT_Number_Calc_gne__c,
                                                      Phase_gne__c, Product_Name_Calc_gne__c, Product_Description_gne__c,
                                                      Product_Name_gne__c, Trial_Short_Title_gne__c, Source_System_gne__c, Trial_Status_gne__c,
                                                      Therapeutic_Area_gne__c, Trial_Contact_Name_gne__c, Trial_Number_gne__c ,GNE_Trial_Number_gne__c
                                                      from TISL_Clinical_Trial_gne__c 
                                                      where Trial_Number_gne__c IN ('testStudy1Number','testStudy2Number')];
        System.Assert(studyList.size() == 1);
        System.Assert(studyList[0].Trial_Number_gne__c          == 'testStudy2Number');
        System.Assert(studyList[0].GNE_Trial_Number_gne__c     == 'testStudy1Number');
        System.Assert(studyList[0].Trial_Status_gne__c          == 'Active Not Recruiting');                
        System.Assert(studyList[0].Diagnosis_gne__c             == 'testStudyDia_NEW');
        System.Assert(studyList[0].EudraCT_Number_gne__c        == 'testStudyEudraCTNumber_NEW');
        System.Assert(studyList[0].Trial_Full_Title_gne__c      == 'testStudyName_NEW');
        System.Assert(studyList[0].NCT_Number_gne__c            == 'NCTtestStudyNumber_NEW');
        System.Assert(studyList[0].Phase_gne__c                 == 'Phase II');
        System.Assert(studyList[0].Product_Name_gne__c          == 'testStudyProduct_NEW');
        System.Assert(studyList[0].Product_Description_gne__c   == 'testStudyProductDesc_NEW');
        System.Assert(studyList[0].Product_Name_Calc_gne__c     == 'testStudyProduct_NEW testStudyProductDesc_NEW');
        System.Assert(studyList[0].Trial_Short_Title_gne__c     == 'testStudyShortTitle_NEW');                        
        System.Assert(studyList[0].Trial_Contact_Name_gne__c    == 'testStudyContactName_NEW');
        System.Assert(studyList[0].Therapeutic_Area_gne__c      == 'Oncology');
        System.Assert(studyList[0].Source_System_gne__c         == 'Siebel');          
    }
    
   static testMethod void errorsOnSites() 
    {
        GNE_TISL_ClinicalTrialAPI.StudyBatch testStudyBatch = new GNE_TISL_ClinicalTrialAPI.StudyBatch();
        testStudyBatch.studyList = new List<GNE_TISL_ClinicalTrialAPI.Study>();        
        GNE_TISL_ClinicalTrialAPI.Response response;

        GNE_TISL_ClinicalTrialAPI.Study testStudy1 = new GNE_TISL_ClinicalTrialAPI.Study();
        testStudy1.StudyName        = 'testStudyName';
        testStudy1.StudyNumber      = 'testStudy1Number';
        testStudy1.StudyStatus      = 'Active Not Recruiting';
        testStudy1.ProductName      = 'testStudyProduct';
        testStudy1.Phase            = 'Phase I';
        testStudy1.Diagnosis        = 'testStudyDia';
        testStudy1.StudyContactName = 'testStudyContactName';
        testStudy1.SourceSystemName = 'TrialWorks';
        testStudy1.StudyShortTitle  = 'testStudyShortTitle';
        testStudy1.NCTNumber        = 'NCTtestStudyNumber';
        testStudy1.siteList = new List<GNE_TISL_ClinicalTrialAPI.Site>();
        
        GNE_TISL_ClinicalTrialAPI.Site testSite1 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite1.SiteName              = 'testSite1';        
        testSite1.SiteGeoLatitude       = '1';
        testSite1.SiteGeoLongitude      = '1';
        testSite1.SiteStatus            = 'Active';
        testSite1.SiteCity              = 'testSite1';
        testSite1.SiteCountry           = 'UNITED STATES';
        testSite1.SiteContactFirstName  = 'testSite1FirstName';
        testSite1.SiteContactLastName   = 'testSite1LastName';
        testSite1.SiteContactPhone      = '12345';
        testSite1.SiteContactEmail      = 'test@Site1.mail';
        testSite1.SiteNumber            = 'testSite1SiteNumber';    
        testSite1.SiteAddress           = 'testSite1SiteAddress';    
        testSite1.SiteState             = 'CA';     
        testSite1.SiteZipCode           = 'testSite1SiteZipCode';   
        testSite1.SiteContactUniqueId   = 'testSite1SiteContactUniqueId'; 
        
        GNE_TISL_ClinicalTrialAPI.Study testStudy2 = new GNE_TISL_ClinicalTrialAPI.Study();
        testStudy2.StudyName        = 'testStudy2Name';
        testStudy2.StudyNumber      = 'testStudy2Number';
        testStudy2.StudyStatus      = 'Active Recruiting';
        testStudy2.ProductName      = 'testStudy2Product';
        testStudy2.Phase            = 'Phase II';
        testStudy2.Diagnosis        = 'testStudy2Dia';
        testStudy2.StudyContactName = 'testStudy2ContactName';
        testStudy2.SourceSystemName = 'TrialWorks';
        testStudy2.StudyShortTitle  = 'testStudy2ShortTitle';
        testStudy2.NCTNumber        = 'NCTtestStudy2Number';
        testStudy2.siteList = new List<GNE_TISL_ClinicalTrialAPI.Site>();        
        
        GNE_TISL_ClinicalTrialAPI.Site testSite3 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite3.SiteName              = 'testSite3';        
        testSite3.SiteGeoLatitude       = '3';
        testSite3.SiteGeoLongitude      = '3';
        testSite3.SiteStatus            = 'Feasibility';
        testSite3.SiteCity              = 'testSite3';
        testSite3.SiteCountry           = 'UNITED STATES';
        testSite3.SiteContactFirstName  = 'testSite3FirstName';
        testSite3.SiteContactLastName   = 'testSite3LastName';
        testSite3.SiteContactPhone      = '32345';
        testSite3.SiteContactEmail      = 'test@Site3.mail';
        testSite3.SiteNumber            = 'testSite3SiteNumber';    
        testSite3.SiteAddress           = 'testSite3SiteAddress';    
        testSite3.SiteState             = 'CA';     
        testSite3.SiteZipCode           = 'testSite3SiteZipCode';   
        testSite3.SiteContactUniqueId   = 'testSite3SiteContactUniqueId';   
        
        // Invalid Site State
        GNE_TISL_ClinicalTrialAPI.Site testSite4 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite4.SiteName              = 'testSite4';        
        testSite4.SiteGeoLatitude       = '4';
        testSite4.SiteGeoLongitude      = '4';
        testSite4.SiteStatus            = 'Clinical Closure';
        testSite4.SiteCity              = 'testSite4';
        testSite4.SiteState             = 'InvalidStateInvalidStateInvalidStateInvalidStateInvalidState';  
        testSite4.SiteCountry           = 'POLAND';
        testSite4.SiteContactFirstName  = 'testSite4FirstName';
        testSite4.SiteContactLastName   = 'testSite4LastName';
        testSite4.SiteContactPhone      = '123456';
        testSite4.SiteContactEmail      = 'test@Site4.mail';    
        
        GNE_TISL_ClinicalTrialAPI.Site testSite5 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite5.SiteName              = 'testSite5';        
        testSite5.SiteGeoLatitude       = '5';
        testSite5.SiteGeoLongitude      = '5';
        testSite5.SiteStatus            = 'Clinical Closure';
        testSite5.SiteCity              = 'testSite5';
        testSite5.SiteCountry           = 'POLAND';
        testSite5.SiteContactFirstName  = 'testSite5FirstName';
        testSite5.SiteContactLastName   = 'testSite5LastName';
        testSite5.SiteContactPhone      = '123556';
        testSite5.SiteContactEmail      = 'test@Site5.mail';      
        
        // Invalid Site Status 
        GNE_TISL_ClinicalTrialAPI.Site testSite6 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite6.SiteName              = 'testSite6';        
        testSite6.SiteGeoLatitude       = '6';
        testSite6.SiteGeoLongitude      = '6';
        testSite6.SiteStatus            = 'InvalidStatus';
        testSite6.SiteCity              = 'testSite6';
        testSite6.SiteCountry           = 'POLAND';
        testSite6.SiteContactFirstName  = 'testSite6FirstName';
        testSite6.SiteContactLastName   = 'testSite6LastName';
        testSite6.SiteContactPhone      = '123666';
        testSite6.SiteContactEmail      = 'test@Site6.mail';   
        
        // Missing required country attribute
        GNE_TISL_ClinicalTrialAPI.Site testSite7 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite7.SiteName              = 'testSite7';        
        testSite7.SiteGeoLatitude       = '7';
        testSite7.SiteGeoLongitude      = '7';
        testSite7.SiteStatus            = 'InvalidStatus';
        testSite7.SiteCity              = 'testSite7';
        testSite7.SiteContactFirstName  = 'testSite7FirstName';
        testSite7.SiteContactLastName   = 'testSite7LastName';
        testSite7.SiteContactPhone      = '123777';
        testSite7.SiteContactEmail      = 'test@Site7.mail';                     

        testStudy1.siteList.add(testSite1);
        testStudy2.siteList.add(testSite3);
        testStudy2.siteList.add(testSite4);
        testStudy2.siteList.add(testSite5);
        testStudy2.siteList.add(testSite6);
        testStudy2.siteList.add(testSite7);
        testStudyBatch.studyList.add(testStudy1);
        testStudyBatch.studyList.add(testStudy2);
        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        system.debug('\n\n errorsOnSites.response ' + response  + '\n\n');
        List<TISL_Clinical_Trial_gne__c> studyList = [select Id, Name, Trial_Number_gne__c from TISL_Clinical_Trial_gne__c where Trial_Number_gne__c IN ('testStudy1Number', 'testStudy2Number') order by Trial_Number_gne__c asc];
        System.Assert(studyList.size() == 2);
        List<TISL_Site_gne__c> siteList = [select Id, Name, Clinical_Trial_gne__c from TISL_Site_gne__c where Clinical_Trial_gne__c = :studyList[0].Id];
        System.Assert(siteList.size() == 1); 
        siteList = [select Id, Site_Name_gne__c, Clinical_Trial_gne__c, Site_Latitude_gne__c, Site_Longitude_gne__c, 
                    Site_Status_gne__c, Site_City_gne__c, Site_Country_gne__c, Site_Contact_First_Name_gne__c, Site_Contact_Last_Name_gne__c,
                    Site_Contact_Phone_gne__c, Site_Contact_Email_gne__c, Site_Number_gne__c, Site_Address_gne__c, 
                    Site_State_gne__c, Site_Zip_Code_gne__c, Site_Contact_Unique_Id_gne__c
                    from TISL_Site_gne__c where Clinical_Trial_gne__c = :studyList[1].Id order by Site_Name_gne__c asc];
        System.Assert(siteList.size() == 2);
        System.Assert(siteList[0].Site_Name_gne__c == 'testSite3');
        System.Assert(siteList[1].Site_Name_gne__c == 'testSite5');
    }     

    static testMethod void oneStudyTestValidExistsValidUpdate() 
    {
        GNE_TISL_ClinicalTrialAPI.StudyBatch testStudyBatch = new GNE_TISL_ClinicalTrialAPI.StudyBatch();
        testStudyBatch.studyList = new List<GNE_TISL_ClinicalTrialAPI.Study>();        
        GNE_TISL_ClinicalTrialAPI.Response response;

        GNE_TISL_ClinicalTrialAPI.Study testStudy = new GNE_TISL_ClinicalTrialAPI.Study();
        testStudy.StudyName         = 'testStudyName';
        testStudy.StudyNumber       = 'testStudyNumber';
        testStudy.StudyStatus       = 'Active Not Recruiting';
        testStudy.ProductName       = 'testStudyProduct';
        testStudy.ProductDescription= 'testStudyProductDesc';
        testStudy.Phase             = 'Phase I';
        testStudy.Diagnosis         = 'testStudyDia';
        testStudy.StudyContactName  = 'testStudyContactName';
        testStudy.StudyContactRole  = 'testStudyContactRole';
        testStudy.StudyContactEmail  = 'testStudyContact@email.gene.com';
        testStudy.TherapeuticArea   = 'Cardiovascular and Metabolic';
        testStudy.SourceSystemName  = 'Siebel';
        testStudy.StudyShortTitle   = 'testStudyShortTitle';
        testStudy.NCTNumber         = 'NCTtestStudyNumber';
        testStudy.EudraCTNumber     = 'testStudyEudraCTNumber';
        testStudy.siteList = new List<GNE_TISL_ClinicalTrialAPI.Site>();        

        GNE_TISL_ClinicalTrialAPI.Site testSite1 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite1.SiteName              = 'testSite1';        
        testSite1.SiteGeoLatitude       = '0';
        testSite1.SiteGeoLongitude      = '1';
        testSite1.SiteStatus            = 'Active';
        testSite1.SiteCity              = 'testSite1';
        testSite1.SiteCountry           = 'UNITED STATES';
        testSite1.SiteContactFirstName  = 'testSite1FirstName';
        testSite1.SiteContactLastName   = 'testSite1LastName';
        testSite1.SiteContactRole       = 'testSite1Role';
        testSite1.SiteContactPhone      = '12345';
        testSite1.SiteContactEmail      = 'test@Site1.mail';
        testSite1.SiteNumber            = 'testSite1SiteNumber';    
        testSite1.SiteAddress           = 'testSite1SiteAddress';    
        testSite1.SiteState             = 'CA';     
        testSite1.SiteZipCode           = 'testSite1SiteZipCode';   
        testSite1.SiteContactUniqueId   = 'testSite1SiteContactUniqueId'; 
        
        GNE_TISL_ClinicalTrialAPI.Site testSite2 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite2.SiteName              = 'testSite2';        
        testSite2.SiteGeoLatitude       = '1';
        testSite2.SiteGeoLongitude      = '2';
        testSite2.SiteStatus            = 'Committed';
        testSite2.SiteCity              = 'testSite2';
        testSite2.SiteCountry           = 'POLAND';
        testSite2.SiteContactFirstName  = 'testSite2FirstName';
        testSite2.SiteContactLastName   = 'testSite2LastName';
        testSite2.SiteContactPhone      = '123456';
        testSite2.SiteContactEmail      = 'test@Site2.mail';     
        
        GNE_TISL_ClinicalTrialAPI.Site testSite3 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite3.SiteName              = 'testSite3';
        testSite3.SiteGeoLatitude       = '';
        testSite3.SiteGeoLongitude      = '';
        testSite3.SiteStatus            = 'Follow-Up';
        testSite3.SiteCity              = 'testSite3';
        testSite3.SiteCountry           = 'UNITED STATES';
        //testSite3.SiteContactFirstName  = 'testSite3FirstName'; - build 4 - became optional
        //testSite3.SiteContactLastName   = 'testSite3LastName';  - build 4 - became optional
        testSite3.SiteContactPhone      = '1234567891011121314151617181920212223232425262728';
        testSite3.SiteContactEmail      = 'test@Site3.mail';  
        testSite3.SiteAddress           = 'testSite3SiteAddress';    
        testSite3.SiteState             = 'WA';     
        testSite3.SiteZipCode           = 'testSite3SiteZipCode';   
        testSite3.SiteContactUniqueId   = 'testSite3SiteContactUniqueId';            
        
        testStudy.siteList.add(testSite1);
        testStudy.siteList.add(testSite2);
        testStudy.siteList.add(testSite3);
        testStudyBatch.studyList.add(testStudy);
        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        
        testStudy.StudyStatus       = 'Active Recruiting';
        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        
        system.debug('\n\n oneStudyThreeSitesTest.response ' + response  + '\n\n');
        List<TISL_Clinical_Trial_gne__c> studyList = [select Id, Diagnosis_gne__c, EudraCT_Number_gne__c, Trial_Full_Title_gne__c,
                                                      Last_Updated_Date_Calc_gne__c, NCT_Number_gne__c, NCT_Number_Calc_gne__c,
                                                      Phase_gne__c, Product_Name_Calc_gne__c, Product_Description_gne__c,
                                                      Product_Name_gne__c, Trial_Short_Title_gne__c, Source_System_gne__c, Trial_Status_gne__c,
                                                      Therapeutic_Area_gne__c, Trial_Contact_Name_gne__c,Trial_Contact_Role_gne__c,Trial_Contact_Email_gne__c, Trial_Number_gne__c
                                                      from TISL_Clinical_Trial_gne__c where Trial_Number_gne__c IN ('testStudyNumber')];
        System.Assert(studyList.size() == 1);        
        System.Assert(studyList[0].Trial_Number_gne__c          == 'testStudyNumber');
        System.Assert(studyList[0].Trial_Status_gne__c          == 'Active Recruiting');
        System.Assert(studyList[0].Product_Name_gne__c          == 'testStudyProduct');
        System.Assert(studyList[0].Product_Description_gne__c   == 'testStudyProductDesc');
        System.Assert(studyList[0].Phase_gne__c                 == 'Phase I');
        System.Assert(studyList[0].Diagnosis_gne__c             == 'testStudyDia');                
        System.Assert(studyList[0].Trial_Contact_Name_gne__c    == 'testStudyContactName');
        System.Assert(studyList[0].Trial_Contact_Role_gne__c    == 'testStudyContactRole'); 
        System.Assert(studyList[0].Trial_Contact_Email_gne__c    == 'testStudyContact@email.gene.com'); 
        System.Assert(studyList[0].Therapeutic_Area_gne__c      == 'Cardiovascular and Metabolic');
        System.Assert(studyList[0].Source_System_gne__c         == 'Siebel');        
        System.Assert(studyList[0].NCT_Number_gne__c            == 'NCTtestStudyNumber');
        System.Assert(studyList[0].EudraCT_Number_gne__c        == 'testStudyEudraCTNumber');
        System.Assert(studyList[0].Trial_Short_Title_gne__c     == 'testStudyShortTitle');                        
        
        List<TISL_Site_gne__c> siteList = [select Id, Site_Name_gne__c, Clinical_Trial_gne__c, Site_Latitude_gne__c,
                                           Site_Longitude_gne__c, Site_Status_gne__c, Site_City_gne__c, 
                                           Site_Country_gne__c, Site_Contact_First_Name_gne__c, Site_Contact_Last_Name_gne__c,
                                           Site_Contact_Role_gne__c, Site_Contact_Phone_gne__c, Site_Contact_Email_gne__c, Site_Number_gne__c,
                                           Site_Address_gne__c, Site_State_gne__c, Site_Zip_Code_gne__c, Site_Contact_Unique_Id_gne__c
                                           from TISL_Site_gne__c where Clinical_Trial_gne__c = :studyList[0].Id];
        System.Assert(siteList.size() == 3);
    
        System.Assert(siteList[0].Site_Name_gne__c                  == 'testSite1');
        System.Assert(siteList[0].Site_Latitude_gne__c              == 0);
        System.Assert(siteList[0].Site_Longitude_gne__c             == 1);
        System.Assert(siteList[0].Site_Status_gne__c                == 'Active');
        System.Assert(siteList[0].Site_City_gne__c                  == 'testSite1');
        System.Assert(siteList[0].Site_Country_gne__c               == 'UNITED STATES');                
        System.Assert(siteList[0].Site_Contact_First_Name_gne__c    == 'testSite1FirstName');
        System.Assert(siteList[0].Site_Contact_Last_Name_gne__c     == 'testSite1LastName');
        System.Assert(siteList[0].Site_Contact_Role_gne__c          == 'testSite1Role');
        System.Assert(siteList[0].Site_Contact_Phone_gne__c         == '12345');         
        System.Assert(siteList[0].Site_Contact_Email_gne__c         == 'test@Site1.mail');
        System.Assert(siteList[0].Site_Number_gne__c                == 'testSite1SiteNumber');        
        System.Assert(siteList[0].Site_Address_gne__c               == 'testSite1SiteAddress');
        System.Assert(siteList[0].Site_State_gne__c                 == 'CA');
        System.Assert(siteList[0].Site_Zip_Code_gne__c              == 'testSite1SiteZipCode');
        System.Assert(siteList[0].Site_Contact_Unique_Id_gne__c     == 'testSite1SiteContactUniqueId');   
        
        System.Assert(siteList[1].Site_Name_gne__c                  == 'testSite2');
        System.Assert(siteList[1].Site_Latitude_gne__c              == 1);
        System.Assert(siteList[1].Site_Longitude_gne__c             == 2);        
        System.Assert(siteList[1].Site_Status_gne__c                == 'Committed');
        System.Assert(siteList[1].Site_City_gne__c                  == 'testSite2');
        System.Assert(siteList[1].Site_Country_gne__c               == 'POLAND');                
        System.Assert(siteList[1].Site_Contact_First_Name_gne__c    == 'testSite2FirstName');
        System.Assert(siteList[1].Site_Contact_Last_Name_gne__c     == 'testSite2LastName');
        System.Assert(siteList[1].Site_Contact_Phone_gne__c         == '123456');         
        System.Assert(siteList[1].Site_Contact_Email_gne__c         == 'test@Site2.mail');
        System.Assert(siteList[1].Site_Number_gne__c                == null);        
        System.Assert(siteList[1].Site_Address_gne__c               == null);
        System.Assert(siteList[1].Site_State_gne__c                 == null);
        System.Assert(siteList[1].Site_Zip_Code_gne__c              == null);
        System.Assert(siteList[1].Site_Contact_Unique_Id_gne__c     == null);     
        
        System.Assert(siteList[2].Site_Name_gne__c                  == 'testSite3');
        System.Assert(siteList[2].Site_Latitude_gne__c              == 1);
        System.Assert(siteList[2].Site_Longitude_gne__c             == 2);
        System.Assert(siteList[2].Site_Status_gne__c                == 'Follow-Up');
        System.Assert(siteList[2].Site_City_gne__c                  == 'testSite3');
        System.Assert(siteList[2].Site_Country_gne__c               == 'UNITED STATES');                
        //System.Assert(siteList[2].Site_Contact_First_Name_gne__c    == 'testSite3FirstName');- build 4 - became optional
        //System.Assert(siteList[2].Site_Contact_Last_Name_gne__c     == 'testSite3LastName'); - build 4 - became optional
        System.Assert(siteList[2].Site_Contact_Phone_gne__c         == '1234567891011121314151617181920212223232425262728');         
        System.Assert(siteList[2].Site_Contact_Email_gne__c         == 'test@Site3.mail');
        System.Assert(siteList[2].Site_Number_gne__c                == null);        
        System.Assert(siteList[2].Site_Address_gne__c               == 'testSite3SiteAddress');
        System.Assert(siteList[2].Site_State_gne__c                 == 'WA');
        System.Assert(siteList[2].Site_Zip_Code_gne__c              == 'testSite3SiteZipCode');
        System.Assert(siteList[2].Site_Contact_Unique_Id_gne__c     == 'testSite3SiteContactUniqueId');            
    }
    
    static testMethod void oneStudyTestValidExistsInvalidUpdate() 
    {
        GNE_TISL_ClinicalTrialAPI.StudyBatch testStudyBatch = new GNE_TISL_ClinicalTrialAPI.StudyBatch();
        testStudyBatch.studyList = new List<GNE_TISL_ClinicalTrialAPI.Study>();        
        GNE_TISL_ClinicalTrialAPI.Response response;

        GNE_TISL_ClinicalTrialAPI.Study testStudy = new GNE_TISL_ClinicalTrialAPI.Study();
        testStudy.StudyName         = 'testStudyName';
        testStudy.StudyNumber       = 'testStudyNumber';
        testStudy.StudyStatus       = 'Active Not Recruiting';
        testStudy.ProductName       = 'testStudyProduct';
        testStudy.ProductDescription= 'testStudyProductDesc';
        testStudy.Phase             = 'Phase I';
        testStudy.Diagnosis         = 'testStudyDia';
        testStudy.StudyContactName  = 'testStudyContactName';
        testStudy.StudyContactRole  = 'testStudyContactRole';
        testStudy.TherapeuticArea   = 'Cardiovascular and Metabolic';
        testStudy.SourceSystemName  = 'Siebel';
        testStudy.StudyShortTitle   = 'testStudyShortTitle';
        testStudy.NCTNumber         = 'NCTtestStudyNumber';
        testStudy.EudraCTNumber     = 'testStudyEudraCTNumber';
        testStudy.siteList = new List<GNE_TISL_ClinicalTrialAPI.Site>();        

        GNE_TISL_ClinicalTrialAPI.Site testSite1 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite1.SiteName              = 'testSite1';        
        testSite1.SiteGeoLatitude       = '0';
        testSite1.SiteGeoLongitude      = '1';
        testSite1.SiteStatus            = 'Active';
        testSite1.SiteCity              = 'testSite1';
        testSite1.SiteCountry           = 'UNITED STATES';
        testSite1.SiteContactFirstName  = 'testSite1FirstName';
        testSite1.SiteContactLastName   = 'testSite1LastName';
        testSite1.SiteContactRole       = 'testSite1Role';
        testSite1.SiteContactPhone      = '12345';
        testSite1.SiteContactEmail      = 'test@Site1.mail';
        testSite1.SiteNumber            = 'testSite1SiteNumber';    
        testSite1.SiteAddress           = 'testSite1SiteAddress';    
        testSite1.SiteState             = 'CA';     
        testSite1.SiteZipCode           = 'testSite1SiteZipCode';   
        testSite1.SiteContactUniqueId   = 'testSite1SiteContactUniqueId'; 
        
        GNE_TISL_ClinicalTrialAPI.Site testSite2 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite2.SiteName              = 'testSite2';        
        testSite2.SiteGeoLatitude       = '1';
        testSite2.SiteGeoLongitude      = '2';
        testSite2.SiteStatus            = 'Committed';
        testSite2.SiteCity              = 'testSite2';
        testSite2.SiteCountry           = 'POLAND';
        testSite2.SiteContactFirstName  = 'testSite2FirstName';
        testSite2.SiteContactLastName   = 'testSite2LastName';
        testSite2.SiteContactPhone      = '123456';
        testSite2.SiteContactEmail      = 'test@Site2.mail';     
        
        GNE_TISL_ClinicalTrialAPI.Site testSite3 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite3.SiteName              = 'testSite3';
        testSite3.SiteGeoLatitude       = '';
        testSite3.SiteGeoLongitude      = '';
        testSite3.SiteStatus            = 'Follow-Up';
        testSite3.SiteCity              = 'testSite3';
        testSite3.SiteCountry           = 'UNITED STATES';
        //testSite3.SiteContactFirstName  = 'testSite3FirstName'; - build 4 - became optional
        //testSite3.SiteContactLastName   = 'testSite3LastName';  - build 4 - became optional
        testSite3.SiteContactPhone      = '1234567891011121314151617181920212223232425262728';
        testSite3.SiteContactEmail      = 'test@Site3.mail';  
        testSite3.SiteAddress           = 'testSite3SiteAddress';    
        testSite3.SiteState             = 'WA';     
        testSite3.SiteZipCode           = 'testSite3SiteZipCode';   
        testSite3.SiteContactUniqueId   = 'testSite3SiteContactUniqueId';            
        
        testStudy.siteList.add(testSite1);
        testStudy.siteList.add(testSite2);
        testStudy.siteList.add(testSite3);
        testStudyBatch.studyList.add(testStudy);
        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        
        testStudy.StudyStatus       = 'Signed Protocol';
        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        
        system.debug('\n\n oneStudyThreeSitesTest.response ' + response  + '\n\n');
        List<TISL_Clinical_Trial_gne__c> studyList = [select Id, Diagnosis_gne__c, EudraCT_Number_gne__c, Trial_Full_Title_gne__c,
                                                      Last_Updated_Date_Calc_gne__c, NCT_Number_gne__c, NCT_Number_Calc_gne__c,
                                                      Phase_gne__c, Product_Name_Calc_gne__c, Product_Description_gne__c,
                                                      Product_Name_gne__c, Trial_Short_Title_gne__c, Source_System_gne__c, Trial_Status_gne__c,
                                                      Therapeutic_Area_gne__c, Trial_Contact_Name_gne__c,Trial_Contact_Role_gne__c,Trial_Contact_Email_gne__c, Trial_Number_gne__c
                                                      from TISL_Clinical_Trial_gne__c where Trial_Number_gne__c IN ('testStudyNumber')];
        System.Assert(studyList.size() == 0);                  
    }    
    
    static testMethod void oneStudyTestInvalidExistsValidUpdate() 
    {
        TISL_Clinical_Trial_gne__c ct = new TISL_Clinical_Trial_gne__c(Trial_Number_gne__c  = 'testStudyNumber',
                                        Trial_Full_Title_gne__c     = 'testStudyName', 
                                        Trial_Short_Title_gne__c    = 'testStudyShortTitle', 
                                        Trial_Status_gne__c         = 'Study # Generated',
                                        NCT_Number_gne__c           = 'NCT12345',  
                                        EudraCT_Number_gne__c       = '54321',
                                        Product_Name_gne__c         = 'TestProduct',
                                        Product_Description_gne__c  = 'TestProductDesc',  
                                        Phase_gne__c                = 'Phase I',        
                                        Therapeutic_Area_gne__c     = 'Cardiovascular and Metabolic',
                                        Diagnosis_gne__c            = 'D1',      
                                        Source_System_gne__c        = 'Siebel',
                                        Trial_Contact_Name_gne__c   = 'testContact');
        insert ct;        	
    	
        GNE_TISL_ClinicalTrialAPI.StudyBatch testStudyBatch = new GNE_TISL_ClinicalTrialAPI.StudyBatch();
        testStudyBatch.studyList = new List<GNE_TISL_ClinicalTrialAPI.Study>();        
        GNE_TISL_ClinicalTrialAPI.Response response;

        GNE_TISL_ClinicalTrialAPI.Study testStudy = new GNE_TISL_ClinicalTrialAPI.Study();
        testStudy.StudyName         = 'testStudyName';
        testStudy.StudyNumber       = 'testStudyNumber';
        testStudy.StudyStatus       = 'Active Not Recruiting';
        testStudy.ProductName       = 'testStudyProduct';
        testStudy.ProductDescription= 'testStudyProductDesc';
        testStudy.Phase             = 'Phase I';
        testStudy.Diagnosis         = 'testStudyDia';
        testStudy.StudyContactName  = 'testStudyContactName';
        testStudy.StudyContactRole  = 'testStudyContactRole';
        testStudy.TherapeuticArea   = 'Cardiovascular and Metabolic';
        testStudy.SourceSystemName  = 'Siebel';
        testStudy.StudyShortTitle   = 'testStudyShortTitle';
        testStudy.NCTNumber         = 'NCTtestStudyNumber';
        testStudy.EudraCTNumber     = 'testStudyEudraCTNumber';
        testStudy.siteList = new List<GNE_TISL_ClinicalTrialAPI.Site>();        

        GNE_TISL_ClinicalTrialAPI.Site testSite1 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite1.SiteName              = 'testSite1';        
        testSite1.SiteGeoLatitude       = '0';
        testSite1.SiteGeoLongitude      = '1';
        testSite1.SiteStatus            = 'Active';
        testSite1.SiteCity              = 'testSite1';
        testSite1.SiteCountry           = 'UNITED STATES';
        testSite1.SiteContactFirstName  = 'testSite1FirstName';
        testSite1.SiteContactLastName   = 'testSite1LastName';
        testSite1.SiteContactRole       = 'testSite1Role';
        testSite1.SiteContactPhone      = '12345';
        testSite1.SiteContactEmail      = 'test@Site1.mail';
        testSite1.SiteNumber            = 'testSite1SiteNumber';    
        testSite1.SiteAddress           = 'testSite1SiteAddress';    
        testSite1.SiteState             = 'CA';     
        testSite1.SiteZipCode           = 'testSite1SiteZipCode';   
        testSite1.SiteContactUniqueId   = 'testSite1SiteContactUniqueId'; 
        
        GNE_TISL_ClinicalTrialAPI.Site testSite2 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite2.SiteName              = 'testSite2';        
        testSite2.SiteGeoLatitude       = '1';
        testSite2.SiteGeoLongitude      = '2';
        testSite2.SiteStatus            = 'Committed';
        testSite2.SiteCity              = 'testSite2';
        testSite2.SiteCountry           = 'POLAND';
        testSite2.SiteContactFirstName  = 'testSite2FirstName';
        testSite2.SiteContactLastName   = 'testSite2LastName';
        testSite2.SiteContactPhone      = '123456';
        testSite2.SiteContactEmail      = 'test@Site2.mail';     
        
        GNE_TISL_ClinicalTrialAPI.Site testSite3 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite3.SiteName              = 'testSite3';
        testSite3.SiteGeoLatitude       = '';
        testSite3.SiteGeoLongitude      = '';
        testSite3.SiteStatus            = 'Follow-Up';
        testSite3.SiteCity              = 'testSite3';
        testSite3.SiteCountry           = 'UNITED STATES';
        //testSite3.SiteContactFirstName  = 'testSite3FirstName'; - build 4 - became optional
        //testSite3.SiteContactLastName   = 'testSite3LastName';  - build 4 - became optional
        testSite3.SiteContactPhone      = '1234567891011121314151617181920212223232425262728';
        testSite3.SiteContactEmail      = 'test@Site3.mail';  
        testSite3.SiteAddress           = 'testSite3SiteAddress';    
        testSite3.SiteState             = 'WA';     
        testSite3.SiteZipCode           = 'testSite3SiteZipCode';   
        testSite3.SiteContactUniqueId   = 'testSite3SiteContactUniqueId';            
        
        testStudy.siteList.add(testSite1);
        testStudy.siteList.add(testSite2);
        testStudy.siteList.add(testSite3);
        testStudyBatch.studyList.add(testStudy);
        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        
        testStudy.StudyStatus       = 'Active Recruiting';
        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        
        system.debug('\n\n oneStudyThreeSitesTest.response ' + response  + '\n\n');
        List<TISL_Clinical_Trial_gne__c> studyList = [select Id, Diagnosis_gne__c, EudraCT_Number_gne__c, Trial_Full_Title_gne__c,
                                                      Last_Updated_Date_Calc_gne__c, NCT_Number_gne__c, NCT_Number_Calc_gne__c,
                                                      Phase_gne__c, Product_Name_Calc_gne__c, Product_Description_gne__c,
                                                      Product_Name_gne__c, Trial_Short_Title_gne__c, Source_System_gne__c, Trial_Status_gne__c,
                                                      Therapeutic_Area_gne__c, Trial_Contact_Name_gne__c,Trial_Contact_Role_gne__c, Trial_Number_gne__c
                                                      from TISL_Clinical_Trial_gne__c where Trial_Number_gne__c IN ('testStudyNumber')];
        System.Assert(studyList.size() == 1);        
        System.Assert(studyList[0].Trial_Number_gne__c          == 'testStudyNumber');
        System.Assert(studyList[0].Trial_Status_gne__c          == 'Active Recruiting');
        System.Assert(studyList[0].Product_Name_gne__c          == 'testStudyProduct');
        System.Assert(studyList[0].Product_Description_gne__c   == 'testStudyProductDesc');
        System.Assert(studyList[0].Phase_gne__c                 == 'Phase I');
        System.Assert(studyList[0].Diagnosis_gne__c             == 'testStudyDia');                
        System.Assert(studyList[0].Trial_Contact_Name_gne__c    == 'testStudyContactName');
        System.Assert(studyList[0].Trial_Contact_Role_gne__c    == 'testStudyContactRole'); 
        System.Assert(studyList[0].Therapeutic_Area_gne__c      == 'Cardiovascular and Metabolic');
        System.Assert(studyList[0].Source_System_gne__c         == 'Siebel');        
        System.Assert(studyList[0].NCT_Number_gne__c            == 'NCTtestStudyNumber');
        System.Assert(studyList[0].EudraCT_Number_gne__c        == 'testStudyEudraCTNumber');
        System.Assert(studyList[0].Trial_Short_Title_gne__c     == 'testStudyShortTitle');                        
        
        List<TISL_Site_gne__c> siteList = [select Id, Site_Name_gne__c, Clinical_Trial_gne__c, Site_Latitude_gne__c,
                                           Site_Longitude_gne__c, Site_Status_gne__c, Site_City_gne__c, 
                                           Site_Country_gne__c, Site_Contact_First_Name_gne__c, Site_Contact_Last_Name_gne__c,
                                           Site_Contact_Role_gne__c, Site_Contact_Phone_gne__c, Site_Contact_Email_gne__c, Site_Number_gne__c,
                                           Site_Address_gne__c, Site_State_gne__c, Site_Zip_Code_gne__c, Site_Contact_Unique_Id_gne__c
                                           from TISL_Site_gne__c where Clinical_Trial_gne__c = :studyList[0].Id];
        System.Assert(siteList.size() == 3);
    
        System.Assert(siteList[0].Site_Name_gne__c                  == 'testSite1');
        System.Assert(siteList[0].Site_Latitude_gne__c              == 0);
        System.Assert(siteList[0].Site_Longitude_gne__c             == 1);
        System.Assert(siteList[0].Site_Status_gne__c                == 'Active');
        System.Assert(siteList[0].Site_City_gne__c                  == 'testSite1');
        System.Assert(siteList[0].Site_Country_gne__c               == 'UNITED STATES');                
        System.Assert(siteList[0].Site_Contact_First_Name_gne__c    == 'testSite1FirstName');
        System.Assert(siteList[0].Site_Contact_Last_Name_gne__c     == 'testSite1LastName');
        System.Assert(siteList[0].Site_Contact_Role_gne__c          == 'testSite1Role');
        System.Assert(siteList[0].Site_Contact_Phone_gne__c         == '12345');         
        System.Assert(siteList[0].Site_Contact_Email_gne__c         == 'test@Site1.mail');
        System.Assert(siteList[0].Site_Number_gne__c                == 'testSite1SiteNumber');        
        System.Assert(siteList[0].Site_Address_gne__c               == 'testSite1SiteAddress');
        System.Assert(siteList[0].Site_State_gne__c                 == 'CA');
        System.Assert(siteList[0].Site_Zip_Code_gne__c              == 'testSite1SiteZipCode');
        System.Assert(siteList[0].Site_Contact_Unique_Id_gne__c     == 'testSite1SiteContactUniqueId');   
        
        System.Assert(siteList[1].Site_Name_gne__c                  == 'testSite2');
        System.Assert(siteList[1].Site_Latitude_gne__c              == 1);
        System.Assert(siteList[1].Site_Longitude_gne__c             == 2);        
        System.Assert(siteList[1].Site_Status_gne__c                == 'Committed');
        System.Assert(siteList[1].Site_City_gne__c                  == 'testSite2');
        System.Assert(siteList[1].Site_Country_gne__c               == 'POLAND');                
        System.Assert(siteList[1].Site_Contact_First_Name_gne__c    == 'testSite2FirstName');
        System.Assert(siteList[1].Site_Contact_Last_Name_gne__c     == 'testSite2LastName');
        System.Assert(siteList[1].Site_Contact_Phone_gne__c         == '123456');         
        System.Assert(siteList[1].Site_Contact_Email_gne__c         == 'test@Site2.mail');
        System.Assert(siteList[1].Site_Number_gne__c                == null);        
        System.Assert(siteList[1].Site_Address_gne__c               == null);
        System.Assert(siteList[1].Site_State_gne__c                 == null);
        System.Assert(siteList[1].Site_Zip_Code_gne__c              == null);
        System.Assert(siteList[1].Site_Contact_Unique_Id_gne__c     == null);     
        
        System.Assert(siteList[2].Site_Name_gne__c                  == 'testSite3');
        System.Assert(siteList[2].Site_Latitude_gne__c              == 1);
        System.Assert(siteList[2].Site_Longitude_gne__c             == 2);
        System.Assert(siteList[2].Site_Status_gne__c                == 'Follow-Up');
        System.Assert(siteList[2].Site_City_gne__c                  == 'testSite3');
        System.Assert(siteList[2].Site_Country_gne__c               == 'UNITED STATES');                
        //System.Assert(siteList[2].Site_Contact_First_Name_gne__c    == 'testSite3FirstName');- build 4 - became optional
        //System.Assert(siteList[2].Site_Contact_Last_Name_gne__c     == 'testSite3LastName'); - build 4 - became optional
        System.Assert(siteList[2].Site_Contact_Phone_gne__c         == '1234567891011121314151617181920212223232425262728');         
        System.Assert(siteList[2].Site_Contact_Email_gne__c         == 'test@Site3.mail');
        System.Assert(siteList[2].Site_Number_gne__c                == null);        
        System.Assert(siteList[2].Site_Address_gne__c               == 'testSite3SiteAddress');
        System.Assert(siteList[2].Site_State_gne__c                 == 'WA');
        System.Assert(siteList[2].Site_Zip_Code_gne__c              == 'testSite3SiteZipCode');
        System.Assert(siteList[2].Site_Contact_Unique_Id_gne__c     == 'testSite3SiteContactUniqueId');            
    }    
    
    static testMethod void oneStudyTestInvalidExistsInvalidUpdate() 
    {
        TISL_Clinical_Trial_gne__c ct = new TISL_Clinical_Trial_gne__c(Trial_Number_gne__c  = 'testStudyNumber',
                                        Trial_Full_Title_gne__c     = 'testStudyName', 
                                        Trial_Short_Title_gne__c    = 'testStudyShortTitle', 
                                        Trial_Status_gne__c         = 'Study # Generated',
                                        NCT_Number_gne__c           = 'NCT12345',  
                                        EudraCT_Number_gne__c       = '54321',
                                        Product_Name_gne__c         = 'TestProduct',
                                        Product_Description_gne__c  = 'TestProductDesc',  
                                        Phase_gne__c                = 'Phase I',        
                                        Therapeutic_Area_gne__c     = 'Cardiovascular and Metabolic',
                                        Diagnosis_gne__c            = 'D1',      
                                        Source_System_gne__c        = 'Siebel',
                                        Trial_Contact_Name_gne__c   = 'testContact');
        insert ct;        	
    	
        GNE_TISL_ClinicalTrialAPI.StudyBatch testStudyBatch = new GNE_TISL_ClinicalTrialAPI.StudyBatch();
        testStudyBatch.studyList = new List<GNE_TISL_ClinicalTrialAPI.Study>();        
        GNE_TISL_ClinicalTrialAPI.Response response;

        GNE_TISL_ClinicalTrialAPI.Study testStudy = new GNE_TISL_ClinicalTrialAPI.Study();
        testStudy.StudyName         = 'testStudyName';
        testStudy.StudyNumber       = 'testStudyNumber';
        testStudy.StudyStatus       = 'On Hold';
        testStudy.ProductName       = 'testStudyProduct';
        testStudy.ProductDescription= 'testStudyProductDesc';
        testStudy.Phase             = 'Phase I';
        testStudy.Diagnosis         = 'testStudyDia';
        testStudy.StudyContactName  = 'testStudyContactName';
        testStudy.StudyContactRole  = 'testStudyContactRole';
        testStudy.TherapeuticArea   = 'Cardiovascular and Metabolic';
        testStudy.SourceSystemName  = 'Siebel';
        testStudy.StudyShortTitle   = 'testStudyShortTitle';
        testStudy.NCTNumber         = 'NCTtestStudyNumber';
        testStudy.EudraCTNumber     = 'testStudyEudraCTNumber';
        testStudy.siteList = new List<GNE_TISL_ClinicalTrialAPI.Site>();        

        GNE_TISL_ClinicalTrialAPI.Site testSite1 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite1.SiteName              = 'testSite1';        
        testSite1.SiteGeoLatitude       = '0';
        testSite1.SiteGeoLongitude      = '1';
        testSite1.SiteStatus            = 'Active';
        testSite1.SiteCity              = 'testSite1';
        testSite1.SiteCountry           = 'UNITED STATES';
        testSite1.SiteContactFirstName  = 'testSite1FirstName';
        testSite1.SiteContactLastName   = 'testSite1LastName';
        testSite1.SiteContactRole       = 'testSite1Role';
        testSite1.SiteContactPhone      = '12345';
        testSite1.SiteContactEmail      = 'test@Site1.mail';
        testSite1.SiteNumber            = 'testSite1SiteNumber';    
        testSite1.SiteAddress           = 'testSite1SiteAddress';    
        testSite1.SiteState             = 'CA';     
        testSite1.SiteZipCode           = 'testSite1SiteZipCode';   
        testSite1.SiteContactUniqueId   = 'testSite1SiteContactUniqueId'; 
        
        GNE_TISL_ClinicalTrialAPI.Site testSite2 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite2.SiteName              = 'testSite2';        
        testSite2.SiteGeoLatitude       = '1';
        testSite2.SiteGeoLongitude      = '2';
        testSite2.SiteStatus            = 'Committed';
        testSite2.SiteCity              = 'testSite2';
        testSite2.SiteCountry           = 'POLAND';
        testSite2.SiteContactFirstName  = 'testSite2FirstName';
        testSite2.SiteContactLastName   = 'testSite2LastName';
        testSite2.SiteContactPhone      = '123456';
        testSite2.SiteContactEmail      = 'test@Site2.mail';     
        
        GNE_TISL_ClinicalTrialAPI.Site testSite3 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite3.SiteName              = 'testSite3';
        testSite3.SiteGeoLatitude       = '';
        testSite3.SiteGeoLongitude      = '';
        testSite3.SiteStatus            = 'Follow-Up';
        testSite3.SiteCity              = 'testSite3';
        testSite3.SiteCountry           = 'UNITED STATES';
        //testSite3.SiteContactFirstName  = 'testSite3FirstName'; - build 4 - became optional
        //testSite3.SiteContactLastName   = 'testSite3LastName';  - build 4 - became optional
        testSite3.SiteContactPhone      = '1234567891011121314151617181920212223232425262728';
        testSite3.SiteContactEmail      = 'test@Site3.mail';  
        testSite3.SiteAddress           = 'testSite3SiteAddress';    
        testSite3.SiteState             = 'WA';     
        testSite3.SiteZipCode           = 'testSite3SiteZipCode';   
        testSite3.SiteContactUniqueId   = 'testSite3SiteContactUniqueId';            
        
        testStudy.siteList.add(testSite1);
        testStudy.siteList.add(testSite2);
        testStudy.siteList.add(testSite3);
        testStudyBatch.studyList.add(testStudy);
        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        
        system.debug('\n\n oneStudyThreeSitesTest.response ' + response  + '\n\n');
        List<TISL_Clinical_Trial_gne__c> studyList = [select Id, Diagnosis_gne__c, EudraCT_Number_gne__c, Trial_Full_Title_gne__c,
                                                      Last_Updated_Date_Calc_gne__c, NCT_Number_gne__c, NCT_Number_Calc_gne__c,
                                                      Phase_gne__c, Product_Name_Calc_gne__c, Product_Description_gne__c,
                                                      Product_Name_gne__c, Trial_Short_Title_gne__c, Source_System_gne__c, Trial_Status_gne__c,
                                                      Therapeutic_Area_gne__c, Trial_Contact_Name_gne__c,Trial_Contact_Role_gne__c, Trial_Number_gne__c
                                                      from TISL_Clinical_Trial_gne__c where Trial_Number_gne__c IN ('testStudyNumber')];
        System.Assert(studyList.size() == 0);        
    }            
    
    static testMethod void deleteStudies() 
    {
        List<TISL_Clinical_Trial_gne__c> studyList = [select Id, Name, Trial_Number_gne__c from TISL_Clinical_Trial_gne__c where Source_System_gne__c = 'Siebel' AND LastModifiedDate < :Date.today()];
        system.debug('\n\n deleteStudies.studyList ' + studyList.size()  + '\n\n');         
        GNE_TISL_ClinicalTrialAPI.Response response = GNE_TISL_ClinicalTrialAPI.deleteClinicalTrials(Date.today(), 'Siebel'); 
        System.AssertEquals(0, [select count() from TISL_Clinical_Trial_gne__c where Source_System_gne__c = 'Siebel' AND LastModifiedDate < :Date.today()]);
    }

    static testMethod void oneStudyThreeSitesGeoLocationTest() 
    {
        GNE_TISL_ClinicalTrialAPI.StudyBatch testStudyBatch = new GNE_TISL_ClinicalTrialAPI.StudyBatch();
        testStudyBatch.studyList = new List<GNE_TISL_ClinicalTrialAPI.Study>();        
        GNE_TISL_ClinicalTrialAPI.Response response;

        GNE_TISL_ClinicalTrialAPI.Study testStudy = new GNE_TISL_ClinicalTrialAPI.Study();
        testStudy.StudyName         = 'testStudyName';
        testStudy.StudyNumber       = 'testStudyNumber';
        testStudy.StudyStatus       = 'Active Not Recruiting';
        testStudy.ProductName       = 'testStudyProduct';
        testStudy.ProductDescription= 'testStudyProductDesc';
        testStudy.Phase             = 'Phase I';
        testStudy.Diagnosis         = 'testStudyDia';
        testStudy.StudyContactName  = 'testStudyContactName';
        testStudy.StudyContactRole  = 'testStudyContactRole';
        testStudy.StudyContactEmail = 'testStudyContact@email.gene.com';
        testStudy.TherapeuticArea   = 'Cardiovascular and Metabolic';
        testStudy.SourceSystemName  = 'Siebel';
        testStudy.StudyShortTitle   = 'testStudyShortTitle';
        testStudy.NCTNumber         = 'NCTtestStudyNumber';
        testStudy.EudraCTNumber     = 'testStudyEudraCTNumber';
        testStudy.siteList = new List<GNE_TISL_ClinicalTrialAPI.Site>();        

        GNE_TISL_ClinicalTrialAPI.Site testSite1 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite1.SiteName              = 'testSite1';        
        testSite1.SiteGeoLatitude       = '';
        testSite1.SiteGeoLongitude      = '';
        testSite1.SiteStatus            = 'Active';
        testSite1.SiteCity              = 'testSite1';
        testSite1.SiteCountry           = 'UNITED STATES';
        testSite1.SiteContactFirstName  = 'testSite1FirstName';
        testSite1.SiteContactLastName   = 'testSite1LastName';
        testSite1.SiteContactRole       = 'testSite1Role';
        testSite1.SiteContactPhone      = '12345';
        testSite1.SiteContactEmail      = 'test@Site1.mail';
        testSite1.SiteNumber            = 'testSite1SiteNumber';    
        testSite1.SiteAddress           = 'testSite1SiteAddress';    
        testSite1.SiteState             = 'CA';     
        testSite1.SiteZipCode           = 'testSite1SiteZipCode';   
        testSite1.SiteContactUniqueId   = 'testSite1SiteContactUniqueId';
        
        GNE_TISL_ClinicalTrialAPI.Site testSite2 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite2.SiteName              = 'testSite2';        
        testSite2.SiteGeoLatitude       = '12';
        testSite2.SiteGeoLongitude      = '22';
        testSite2.SiteNumber            = 'testSite1SiteNumber';    
        testSite2.SiteStatus            = 'Committed';
        testSite2.SiteCity              = 'testSite2';
        testSite2.SiteCountry           = 'POLAND';
        testSite2.SiteContactFirstName  = 'testSite2FirstName';
        testSite2.SiteContactLastName   = 'testSite2LastName';
        testSite2.SiteContactPhone      = '123456';
        testSite2.SiteContactEmail      = 'test@Site2.mail';     
        
        GNE_TISL_ClinicalTrialAPI.Site testSite3 = new GNE_TISL_ClinicalTrialAPI.Site();
        testSite3.SiteName              = 'testSite3';
        testSite3.SiteGeoLatitude       = '';
        testSite3.SiteGeoLongitude      = '';
        testSite3.SiteNumber            = 'testSite1SiteNumber';    
        testSite3.SiteStatus            = 'Follow-Up';
        testSite3.SiteCity              = 'testSite3';
        testSite3.SiteCountry           = 'UNITED STATES';
        //testSite3.SiteContactFirstName  = 'testSite3FirstName'; - build 4 - became optional
        //testSite3.SiteContactLastName   = 'testSite3LastName';  - build 4 - became optional
        testSite3.SiteContactPhone      = '1234567891011121314151617181920212223232425262728';
        testSite3.SiteContactEmail      = 'test@Site3.mail';  
        testSite3.SiteAddress           = 'testSite3SiteAddress';    
        testSite3.SiteState             = 'WA';     
        testSite3.SiteZipCode           = 'testSite3SiteZipCode';   
        testSite3.SiteContactUniqueId   = 'testSite3SiteContactUniqueId';            
        
        testStudy.siteList.add(testSite1);
        testStudy.siteList.add(testSite2);
        testStudy.siteList.add(testSite3);
        testStudyBatch.studyList.add(testStudy);

        response = GNE_TISL_ClinicalTrialAPI.updateOrCreateClinicalTrialList(testStudyBatch);
        system.debug('\n\n oneStudyThreeSitesTest.response ' + response  + '\n\n');
        List<TISL_Clinical_Trial_gne__c> studyList = [select Id, Diagnosis_gne__c, EudraCT_Number_gne__c, Trial_Full_Title_gne__c,
                                                      Last_Updated_Date_Calc_gne__c, NCT_Number_gne__c, NCT_Number_Calc_gne__c,
                                                      Phase_gne__c, Product_Name_Calc_gne__c, Product_Description_gne__c,
                                                      Product_Name_gne__c, Trial_Short_Title_gne__c, Source_System_gne__c, Trial_Status_gne__c,
                                                      Therapeutic_Area_gne__c, Trial_Contact_Name_gne__c,Trial_Contact_Role_gne__c,Trial_Contact_Email_gne__c, Trial_Number_gne__c
                                                      from TISL_Clinical_Trial_gne__c where Trial_Number_gne__c IN ('testStudyNumber')];
        System.Assert(studyList.size() == 1);        
        System.Assert(studyList[0].Trial_Number_gne__c          == 'testStudyNumber');
        System.Assert(studyList[0].Trial_Status_gne__c          == 'Active Not Recruiting');
        System.Assert(studyList[0].Product_Name_gne__c          == 'testStudyProduct');
        System.Assert(studyList[0].Product_Description_gne__c   == 'testStudyProductDesc');
        System.Assert(studyList[0].Phase_gne__c                 == 'Phase I');
        System.Assert(studyList[0].Diagnosis_gne__c             == 'testStudyDia');                
        System.Assert(studyList[0].Trial_Contact_Name_gne__c    == 'testStudyContactName');
        System.Assert(studyList[0].Trial_Contact_Role_gne__c    == 'testStudyContactRole'); 
        System.Assert(studyList[0].Trial_Contact_Email_gne__c    == 'testStudyContact@email.gene.com'); 
        System.Assert(studyList[0].Therapeutic_Area_gne__c      == 'Cardiovascular and Metabolic');
        System.Assert(studyList[0].Source_System_gne__c         == 'Siebel');        
        System.Assert(studyList[0].NCT_Number_gne__c            == 'NCTtestStudyNumber');
        System.Assert(studyList[0].EudraCT_Number_gne__c        == 'testStudyEudraCTNumber');
        System.Assert(studyList[0].Trial_Short_Title_gne__c     == 'testStudyShortTitle');                        
        
        List<TISL_Site_gne__c> siteList = [select Id, Site_Name_gne__c, Clinical_Trial_gne__c, Site_Latitude_gne__c,
                                           Site_Longitude_gne__c, Site_Status_gne__c, Site_City_gne__c, 
                                           Site_Country_gne__c, Site_Contact_First_Name_gne__c, Site_Contact_Last_Name_gne__c,
                                           Site_Contact_Role_gne__c, Site_Contact_Phone_gne__c, Site_Contact_Email_gne__c, Site_Number_gne__c,
                                           Site_Address_gne__c, Site_State_gne__c, Site_Zip_Code_gne__c, Site_Contact_Unique_Id_gne__c
                                           from TISL_Site_gne__c where Clinical_Trial_gne__c = :studyList[0].Id];
        System.Assert(siteList.size() == 3);
    
        System.Assert(siteList[0].Site_Name_gne__c                  == 'testSite1');
        System.Assert(siteList[0].Site_Latitude_gne__c              == 12);
        System.Assert(siteList[0].Site_Longitude_gne__c             == 22);
        System.Assert(siteList[0].Site_Status_gne__c                == 'Active');
        System.Assert(siteList[0].Site_City_gne__c                  == 'testSite1');
        System.Assert(siteList[0].Site_Country_gne__c               == 'UNITED STATES');                
        System.Assert(siteList[0].Site_Contact_First_Name_gne__c    == 'testSite1FirstName');
        System.Assert(siteList[0].Site_Contact_Last_Name_gne__c     == 'testSite1LastName');
        System.Assert(siteList[0].Site_Contact_Role_gne__c          == 'testSite1Role');
        System.Assert(siteList[0].Site_Contact_Phone_gne__c         == '12345');         
        System.Assert(siteList[0].Site_Contact_Email_gne__c         == 'test@Site1.mail');
        System.Assert(siteList[0].Site_Number_gne__c                == 'testSite1SiteNumber');        
        System.Assert(siteList[0].Site_Address_gne__c               == 'testSite1SiteAddress');
        System.Assert(siteList[0].Site_State_gne__c                 == 'CA');
        System.Assert(siteList[0].Site_Zip_Code_gne__c              == 'testSite1SiteZipCode');
        System.Assert(siteList[0].Site_Contact_Unique_Id_gne__c     == 'testSite1SiteContactUniqueId');   
        
        System.Assert(siteList[1].Site_Name_gne__c                  == 'testSite2');
        System.Assert(siteList[1].Site_Latitude_gne__c              == 12);
        System.Assert(siteList[1].Site_Longitude_gne__c             == 22);        
        System.Assert(siteList[1].Site_Status_gne__c                == 'Committed');
        System.Assert(siteList[1].Site_City_gne__c                  == 'testSite2');
        System.Assert(siteList[1].Site_Country_gne__c               == 'POLAND');                
        System.Assert(siteList[1].Site_Contact_First_Name_gne__c    == 'testSite2FirstName');
        System.Assert(siteList[1].Site_Contact_Last_Name_gne__c     == 'testSite2LastName');
        System.Assert(siteList[1].Site_Contact_Phone_gne__c         == '123456');         
        System.Assert(siteList[1].Site_Contact_Email_gne__c         == 'test@Site2.mail');
        System.Assert(siteList[1].Site_Number_gne__c                == 'testSite1SiteNumber');        
        System.Assert(siteList[1].Site_Address_gne__c               == null);
        System.Assert(siteList[1].Site_State_gne__c                 == null);
        System.Assert(siteList[1].Site_Zip_Code_gne__c              == null);
        System.Assert(siteList[1].Site_Contact_Unique_Id_gne__c     == null);     
        
        System.Assert(siteList[2].Site_Name_gne__c                  == 'testSite3');
        System.Assert(siteList[2].Site_Latitude_gne__c              == 12);
        System.Assert(siteList[2].Site_Longitude_gne__c             == 22);
        System.Assert(siteList[2].Site_Status_gne__c                == 'Follow-Up');
        System.Assert(siteList[2].Site_City_gne__c                  == 'testSite3');
        System.Assert(siteList[2].Site_Country_gne__c               == 'UNITED STATES');                
        //System.Assert(siteList[2].Site_Contact_First_Name_gne__c    == 'testSite3FirstName');- build 4 - became optional
        //System.Assert(siteList[2].Site_Contact_Last_Name_gne__c     == 'testSite3LastName'); - build 4 - became optional
        System.Assert(siteList[2].Site_Contact_Phone_gne__c         == '1234567891011121314151617181920212223232425262728');         
        System.Assert(siteList[2].Site_Contact_Email_gne__c         == 'test@Site3.mail');
        System.Assert(siteList[2].Site_Number_gne__c                == 'testSite1SiteNumber');        
        System.Assert(siteList[2].Site_Address_gne__c               == 'testSite3SiteAddress');
        System.Assert(siteList[2].Site_State_gne__c                 == 'WA');
        System.Assert(siteList[2].Site_Zip_Code_gne__c              == 'testSite3SiteZipCode');
        System.Assert(siteList[2].Site_Contact_Unique_Id_gne__c     == 'testSite3SiteContactUniqueId');                                          
    }
}