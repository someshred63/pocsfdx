/************************************************************
*  @author: Krzysztof Leszek, Robert Kostusiak, Roche
*  Date: 14-September-2010 
*  Description: TISL - Clinical Trials API
*                          
*  Modification History
*  Date        Name                  Description
*  11/26/10   Michal Szewczyk        Add Contact Role field to the interface   
*  04/11/16   Tadeusz Hyzy           Commented validation of TherapeuticArea (lines 406-413), Phase (lines 394-401). Now it can take every value business wants.
*************************************************************/
global without sharing class GNE_TISL_ClinicalTrialAPI 
{       

    private static final String CONFIG_ITEM_NAME_STUDY_PHASE    = 'StudyPhaseList';                 // TISL Config - Custom Setting item name - used to store allowed study phase values (defined values in custom settings due to the fact that the field needed to be searchable via SOSL and picklist fields are not) 
    private static final String CONFIG_ITEM_NAME_STUDY_STATUS   = 'StudyStatusList';
    private static final String CONFIG_ITEM_NAME_STUDY_THER_AREA= 'StudyTherapeuticAreaList';  
    private static final String CTMS_SOURCE_SYSTEM_NAME         = 'Siebel';
    private static final String TW_SOURCE_SYSTEM_NAME           = 'TrialWorks';    
    private static final Integer MAX_COLLECTION_SIZE            = 10000;
    private static final Set<String> STUDY_PHASE_LIST;          // Allowed Study Phases
    private static final Set<String> STUDY_STATUS_LIST;         // Allowed Study Statuses
    private static final Set<String> STUDY_THER_AREA_LIST;      // Allowed Study Therapeutic Areas        
    private static final Set<String> STUDY_SOURCE_SYSTEM_LIST;  // Allowed Study Systems
    private static final Set<String> SITE_COUNTRY_LIST;         // Allowed Site Countries
    private static final Set<String> SITE_STATE_LIST;           // Allowed Site Country States
    private static final Set<String> SITE_STATUS_LIST;          // Allowed Site Statuses
    
    /**
    * Gets allowed values for Study Phase, Status, Therapeutic Areas and other picklists
    */         
    static { 
        // Study Phases
        Map<String, GNE_TISL_Config_Items_gne__c> configItemsMap = GNE_TISL_Config_Items_gne__c.getAll();                 
        if ((configItemsMap.containsKey(CONFIG_ITEM_NAME_STUDY_PHASE)) && (configItemsMap.get(CONFIG_ITEM_NAME_STUDY_PHASE).Configuration_Value_gne__c.length() > 0)) {                 
            List<String> configItemList = new List<String>(configItemsMap.get(CONFIG_ITEM_NAME_STUDY_PHASE).Configuration_Value_gne__c.split(';'));
            for (Integer i = 0; i < configItemList.size(); i++)                    
                configItemList[i] =  configItemList[i].trim();                                 
            STUDY_PHASE_LIST = new Set<String>(configItemList);
        } else STUDY_PHASE_LIST = new Set<String>();
                
        // Study Statuses
        if ((configItemsMap.containsKey(CONFIG_ITEM_NAME_STUDY_STATUS)) && (configItemsMap.get(CONFIG_ITEM_NAME_STUDY_STATUS).Configuration_Value_gne__c.length() > 0)) {                 
            List<String> configItemList = new List<String>(configItemsMap.get(CONFIG_ITEM_NAME_STUDY_STATUS).Configuration_Value_gne__c.split(';'));
            for (Integer i = 0; i < configItemList.size(); i++)                    
                configItemList[i] =  configItemList[i].trim();                                 
            STUDY_STATUS_LIST = new Set<String>(configItemList);
        } else STUDY_STATUS_LIST = new Set<String>();
        
        // Therapeutic Areas
        if ((configItemsMap.containsKey(CONFIG_ITEM_NAME_STUDY_THER_AREA)) && (configItemsMap.get(CONFIG_ITEM_NAME_STUDY_THER_AREA).Configuration_Value_gne__c.length() > 0)) {                 
            List<String> configItemList = new List<String>(configItemsMap.get(CONFIG_ITEM_NAME_STUDY_THER_AREA).Configuration_Value_gne__c.split(';'));
            for (Integer i = 0; i < configItemList.size(); i++)                    
                configItemList[i] =  configItemList[i].trim();                                 
            STUDY_THER_AREA_LIST = new Set<String>(configItemList);
        } else STUDY_THER_AREA_LIST = new Set<String>();
                   
        // Get allowed picklist values 
        Schema.DescribeFieldResult studySourceSystemDescribe= TISL_Clinical_Trial_gne__c.Source_System_gne__c.getDescribe();
        Schema.DescribeFieldResult siteCountryDescribe      = TISL_Site_gne__c.Site_Country_gne__c.getDescribe();
        Schema.DescribeFieldResult siteStateDescribe        = TISL_Site_gne__c.Site_State_gne__c.getDescribe();
        Schema.DescribeFieldResult siteStatusDescribe       = TISL_Site_gne__c.Site_Status_gne__c.getDescribe();
        STUDY_SOURCE_SYSTEM_LIST                            = getPickListValues(studySourceSystemDescribe.getPicklistValues());                     
        SITE_COUNTRY_LIST                                   = getPickListValues(siteCountryDescribe.getPicklistValues());
        SITE_STATE_LIST                                     = getPickListValues(siteStateDescribe.getPicklistValues());
        SITE_STATUS_LIST                                    = getPickListValues(siteStatusDescribe.getPicklistValues());                       
    }   
        
    global class StudyBatch {
        WebService List<Study> studyList;
    }

    global class Study {
        WebService String StudyNumber;
        WebService String GNEStudyNumber;
        WebService String StudyName; 
        WebService String StudyShortTitle; 
        WebService String StudyStatus;
        WebService String NCTNumber;  
        WebService String EudraCTNumber;
        WebService String ProductName; 
        WebService String ProductDescription;
        WebService String Phase;        
        WebService String TherapeuticArea;
        WebService String Diagnosis;      
        WebService String SourceSystemName;
        WebService String StudyContactName;
        WebService String StudyContactRole;
        WebService String StudyContactEmail;        
        WebService List<Site> siteList;            
    }            

    global class Site {
        WebService String SiteNumber;    
        WebService String SiteName;           
        WebService String SiteStatus; 
        WebService String SiteAddress;    
        WebService String SiteCity;      
        WebService String SiteCountry;   
        WebService String SiteState;     
        WebService String SiteZipCode;   
        WebService String SiteGeoLatitude;      
        WebService String SiteGeoLongitude;     
        WebService String SiteContactFirstName;   
        WebService String SiteContactLastName;
        WebService String SiteContactRole;   
        WebService String SiteContactPhone;     
        WebService String SiteContactEmail;  
        WebService String SiteContactUniqueId;     
    }  
     
    global class Response {
        WebService DateTime StartTime   = DateTime.now();
        WebService DateTime EndTime     = null;     
        WebService List<ErrorLog> errorList;
    }   
    
    global class ErrorLog {
        WebService String StudyNumber;
        WebService String ErrorCode;
        WebService String ErrorMessage;     
    }


    /**
    * Creates or Updates Clinical Trials including related Sites
    */                             
    Webservice static Response updateOrCreateClinicalTrialList (StudyBatch studyList) {
        
        Response apiResponse                                = new Response();
        List<ErrorLog> errorList                            = new List<ErrorLog>();         
        List<String> studyNumberIdList                      = new List<String>();
        List<String> gneStudyNumberIdList                   = new List<String>();
        List<TISL_Clinical_Trial_gne__c> clinicalTrialList  = new List<TISL_Clinical_Trial_gne__c>();
        List<TISL_Site_gne__c> tmpSiteList                  = new List<TISL_Site_gne__c>(); 
        List<List<TISL_Site_gne__c>> siteList               = new List<List<TISL_Site_gne__c>>();
        apiResponse.errorList                               = new List<ErrorLog>(); 
                                 
        SavePoint savePoint                                 = Database.setSavePoint();
        List<ErrorLog> studyErrorList                       = new List<ErrorLog>();
        ErrorLog err                                        = new ErrorLog(); 
        
        if (studyList.studyList != null) {                                  
            for(Study objStudy : studyList.studyList)
            {
                    studyNumberIdList.add(objStudy.StudyNumber);
                    if(objStudy.GNEStudyNumber != null)
                        gneStudyNumberIdList.add(objStudy.GNEStudyNumber);  
            }        
            
            // Remove already created studies
            List<TISL_Clinical_Trial_gne__c> createdStudyList = [SELECT Id, Trial_Number_gne__c FROM TISL_Clinical_Trial_gne__c
                                                                 WHERE Trial_Number_gne__c IN :studyNumberIdList OR 
                                                                 Trial_Status_gne__c NOT IN :STUDY_STATUS_LIST OR 
                                                                 (Trial_Number_gne__c IN :gneStudyNumberIdList AND Source_System_gne__c = 'TrialWorks') OR
                                                                 (LastModifiedDate < LAST_N_DAYS:152 AND Trial_Status_gne__c IN ('Clinical Closure', 'Prematurely Terminated'))];   //CR25 & CR30
            if (createdStudyList.size() > 0)          
                Database.DeleteResult[] deleteResults = Database.delete(createdStudyList, false);                                  
                                            
            for(Study objStudy : studyList.studyList) {
                if ((!STUDY_STATUS_LIST.isEmpty()) && (STUDY_STATUS_LIST.contains(objStudy.StudyStatus))) { 
                    err = verifyStudyObject(objStudy);   
                    if (err == null) {                      
                        TISL_Clinical_Trial_gne__c tmpStudy = new TISL_Clinical_Trial_gne__c(Trial_Number_gne__c = objStudy.StudyNumber);
                        clinicalTrialList.add(new TISL_Clinical_Trial_gne__c(Trial_Number_gne__c        = objStudy.StudyNumber,
                                                                             GNE_Trial_Number_gne__c    = objStudy.GNEStudyNumber,
                                                                             Trial_Full_Title_gne__c    = objStudy.StudyName, 
                                                                             Trial_Short_Title_gne__c   = objStudy.StudyShortTitle, 
                                                                             Trial_Status_gne__c        = objStudy.StudyStatus,
                                                                             NCT_Number_gne__c          = objStudy.NCTNumber,  
                                                                             EudraCT_Number_gne__c      = objStudy.EudraCTNumber,
                                                                             Product_Name_gne__c        = objStudy.ProductName,
                                                                             Product_Description_gne__c = objStudy.ProductDescription,
                                                                             Phase_gne__c               = objStudy.Phase,        
                                                                             Therapeutic_Area_gne__c    = objStudy.TherapeuticArea,
                                                                             Diagnosis_gne__c           = objStudy.Diagnosis,      
                                                                             Source_System_gne__c       = objStudy.SourceSystemName,
                                                                             Trial_Contact_Name_gne__c  = objStudy.StudyContactName,
                                                                             Trial_Contact_Role_gne__c  = objStudy.StudyContactRole,
                                                                             Trial_Contact_Email_gne__c  = objStudy.StudyContactEmail));
                        if (objStudy.siteList != null) {                                                                    
                            for(Site objSite : objStudy.siteList) {
                                err = verifySiteObject(objStudy.StudyNumber, objSite);
                                if (err == null) {                            
                                    if (tmpSiteList.size() > 9998) {
                                        siteList.add(tmpSiteList);
                                        tmpSiteList = new List<TISL_Site_gne__c>(); 
                                    }
                                    try {                               
                                        Decimal dLat = null;
                                        if ((objSite.SiteGeoLatitude != null) && (objSite.SiteGeoLatitude != ''))
                                            dLat = decimal.valueOf(objSite.SiteGeoLatitude);
                                        Decimal dLong = null;
                                        if ((objSite.SiteGeoLongitude != null) && (objSite.SiteGeoLongitude != ''))
                                            dLong = decimal.valueOf(objSite.SiteGeoLongitude);
                                        tmpSiteList.add(new TISL_Site_gne__c(Clinical_Trial_gne__r          = tmpStudy,
                                                                             Site_Number_gne__c              = objSite.SiteNumber,
                                                                             Site_Name_gne__c                = objSite.SiteName,           
                                                                             Site_Status_gne__c              = objSite.SiteStatus, 
                                                                             Site_Address_gne__c             = objSite.SiteAddress,    
                                                                             Site_City_gne__c                = objSite.SiteCity,      
                                                                             Site_Country_gne__c             = objSite.SiteCountry,   
                                                                             Site_State_gne__c               = objSite.SiteState,     
                                                                             Site_Zip_Code_gne__c            = objSite.SiteZipCode,   
                                                                             Site_Latitude_gne__c            = dLat,      
                                                                             Site_Longitude_gne__c           = dLong,     
                                                                             Site_Contact_First_Name_gne__c  = objSite.SiteContactFirstName,   
                                                                             Site_Contact_Last_Name_gne__c   = objSite.SiteContactLastName,
                                                                             Site_Contact_Role_gne__c        = objSite.SiteContactRole,
                                                                             Site_Contact_Phone_gne__c       = objSite.SiteContactPhone,     
                                                                             Site_Contact_Email_gne__c       = objSite.SiteContactEmail, 
                                                                             Site_Contact_Unique_Id_gne__c   = objSite.SiteContactUniqueId));
                                                                               
                                    } catch (Exception e) {
                                        err                 = new ErrorLog();                               
                                        err.StudyNumber     = objStudy.StudyNumber;
                                        err.ErrorCode       = 'Runtime';
                                        err.ErrorMessage    = e.getMessage();
                                        apiResponse.errorList.add(err);                         
                                    }
                                } else 
                                    apiResponse.errorList.add(err);                                                                                            
                            }
                        }
                    } else 
                        studyErrorList.add(err);
                }                                           
            }
        }
            
        // Upsert studies 
        siteList.add(tmpSiteList);        
        apiResponse.errorList.addAll(studyErrorList);
        if (clinicalTrialList.size() > 0) {
            List<ErrorLog> dmlErrList = executeDML(clinicalTrialList);
            studyErrorList.addAll(dmlErrList);
            if (studyErrorList.size() > 0) {
                Database.rollback(savePoint); 
                errorList = new List<ErrorLog>();
                for(ErrorLog objError : studyErrorList) {
                    Boolean isFound = false;    
                    Integer i = 0;
                    while ((i < studyList.studyList.size()) && (!isFound)) {    
                        if (studyList.studyList[i].StudyNumber == objError.StudyNumber)
                            isFound = true;
                        i++;
                    }   
                    if (isFound) 
                        studyList.studyList.remove(i-1);                            
                }
                apiResponse.errorList.addAll(dmlErrList);
                updateOrCreateClinicalTrialList(studyList);
            }                        
        }    
        // Upsert sites
        if ((studyErrorList.size() == 0) && (siteList.size() > 0)) {  
            for (List<TISL_Site_gne__c> tempSiteList : siteList)
                apiResponse.errorList.addAll(executeDML(tmpSiteList));
        }                
        apiResponse.EndTime = DateTime.now();         
        return apiResponse; 
    }
    
    
    /**
    * Executes upsert and returns failures in form of an error log list
    */  
    private static List<ErrorLog> executeDML(SObject[] obj) 
    {                
        List<ErrorLog> errList;
        ErrorLog error;
        try {                  
            errList = new List<ErrorLog>();   
            Database.UpsertResult[] results = Database.upsert(obj, false);
            if (results != null) {
                Integer iCount = 0;
                for (Database.UpsertResult result : results) {          
                    if (!result.isSuccess()) {                      
                        Database.Error[] errs = result.getErrors();            
                        for(Database.Error err : errs)                          
                            if (obj[iCount].getSObjectType() == TISL_Clinical_Trial_gne__c.sObjectType) {
                                TISL_Clinical_Trial_gne__c study = (TISL_Clinical_Trial_gne__c)obj[iCount];
                                error               = new ErrorLog();                               
                                error.StudyNumber   = study.Trial_Number_gne__c;
                                error.ErrorCode     = String.valueOf(err.getStatusCode());
                                error.ErrorMessage  = err.getMessage();
                                errList.add(error);
                                System.Debug('\n\n Error captured when processing study:' + study + '\n\n');
                                System.Debug('\n\n Study Number: ' + study.Trial_Number_gne__c + '\n\n');   
                                System.Debug('\n\n Error Code: ' + String.valueOf(err.getStatusCode()) + '\n\n');   
                                System.Debug('\n\n Error Message: ' + err.getMessage() + '\n\n');                                   
                            } else if (obj[iCount].getSObjectType() == TISL_Site_gne__c.sObjectType) {
                                TISL_Site_gne__c site = (TISL_Site_gne__c)obj[iCount];
                                String sState   = site.Site_State_gne__c;
                                String sZipCode = site.Site_Zip_Code_gne__c;
                                if (sState == null) sState = '';
                                if (sZipCode == null) sZipCode = '';
                                error               = new ErrorLog();                                 
                                error.StudyNumber   = 'Study:' + site.Clinical_Trial_gne__r.Trial_Number_gne__c + ',Site:' + site.Site_Name_gne__c + ',' + site.Site_City_gne__c + ',' + site.Site_Country_gne__c + ',' + sState + ',' + sZipCode;
                                error.ErrorCode     = String.valueOf(err.getStatusCode());
                                error.ErrorMessage  = err.getMessage();
                                errList.add(error);
                                System.Debug('\n\n Error captured when processing site: ' + site + '\n\n');
                                System.Debug('\n\n Site Situdy Number: ' + site.Clinical_Trial_gne__r.Trial_Number_gne__c + '\n\n');    
                                System.Debug('\n\n Error Code: ' + String.valueOf(err.getStatusCode()) + '\n\n');   
                                System.Debug('\n\n Error Message: ' + err.getMessage() + '\n\n');                                   
                            }                
                    }
                    iCount++;
                }                                  
            }            
        } catch (Exception e) { 
            error               = new ErrorLog(); 
            error.ErrorCode     = 'DML_EXCEPTION';
            error.ErrorMessage  = e.getMessage();
            errList.add(error);         
        } 
        return errList;
    }         
    
    
    /**
    * Retrieves picklist values 
    */    
    private static Set<String> getPickListValues(List<Schema.PicklistEntry> pickList) {
        Set<String> pickValues = new Set<String>();
        for (Schema.PicklistEntry entry : pickList) {
            if (entry.getValue() != null)
                pickValues.add(entry.getValue());
        }                       
        return pickValues;
    }


    /**
    * Verifies that the study message contains all required attributes and valid values in fields defined as picklist 
    */        
    private static ErrorLog verifyStudyObject(Study objStudy) {
        // Check if all required study attributes are not present and are valid if not add an error                 
        ErrorLog err;
        String sCode    = 'MISSING_ATTRIB';
        String sMessage = '';  

        if ((objStudy.StudyName == null) || (objStudy.StudyName == '')) {
            objStudy.StudyName = '';
            sMessage = 'StudyName';    
        }
        if ((objStudy.StudyStatus == null) ||(objStudy.StudyStatus == '')) {
            if (sMessage == '')
                sMessage = 'StudyStatus';
            else
                sMessage = sMessage + ',StudyStatus';                       
        }                                    
        if ((objStudy.SourceSystemName == null) || (objStudy.SourceSystemName == '')) {
            if (sMessage == '')
                sMessage = 'SourceSystemName';
            else
                sMessage = sMessage + ',SourceSystemName';                      
        } 
        if ((objStudy.StudyNumber == null) || (objStudy.StudyNumber == '')) {
            objStudy.StudyNumber = '';
            if (sMessage == '')
                sMessage = 'StudyNumber';
            else
                sMessage = sMessage + ',StudyNumber';                       
        }                                   
        if ((objStudy.Phase == null) || (objStudy.Phase == '')) {
            if (sMessage == '')
                sMessage = 'Phase';
            else
                sMessage = sMessage + ',Phase';                     
        }
        if ((objStudy.ProductName == null) || (objStudy.ProductName == '')) {
            if (sMessage == '')
                sMessage = 'ProductName';
            else
                sMessage = sMessage + ',ProductName';                       
        }                        
        if ((objStudy.Diagnosis == null) || (objStudy.Diagnosis == '')) {
            if (sMessage == '')
                sMessage = 'Diagnosis';
            else
                sMessage = sMessage + ',Diagnosis';                     
        }                                            
        if (sMessage != '') {
            err             = new ErrorLog();
            err.StudyNumber = objStudy.StudyNumber;
            err.ErrorCode   = sCode;
            err.ErrorMessage= 'Required attributes missing: ' + sMessage; 
        } else {
            // If all attributes present - check that are valid
            sCode = 'INVALID_PICKLIST_VALUE';
            //if ((!STUDY_STATUS_LIST.isEmpty()) && (!STUDY_STATUS_LIST.contains(objStudy.StudyStatus)))
            //    sMessage = 'StudyStatus';
			/*
            if ((!STUDY_PHASE_LIST.isEmpty()) && (!STUDY_PHASE_LIST.contains(objStudy.Phase))) {
                if (sMessage == '')
                    sMessage = 'Phase';
                else
                    sMessage = sMessage + ',Phase';                      
            }
			*/
            if ((!STUDY_SOURCE_SYSTEM_LIST.isEmpty()) && (!STUDY_SOURCE_SYSTEM_LIST.contains(objStudy.SourceSystemName))) {
                if (sMessage == '')
                    sMessage = 'SourceSystemName';
                else
                    sMessage = sMessage + ',SourceSystemName';                      
            }   
			/*
            if ((objStudy.TherapeuticArea != null) && (objStudy.TherapeuticArea != '') && (!STUDY_THER_AREA_LIST.isEmpty()) && (!STUDY_THER_AREA_LIST.contains(objStudy.TherapeuticArea))) {
                if (sMessage == '')
                    sMessage = 'TherapeuticArea';
                else
                    sMessage = sMessage + ',TherapeuticArea';                   
            }
			*/
            if (sMessage != '') {
                err             = new ErrorLog();       
                err.StudyNumber = objStudy.StudyNumber;
                err.ErrorCode   = sCode;
                err.ErrorMessage= 'Invalid picklist value in fields: ' + sMessage;      
            } else {
                // Check if other attributes are valid
                sCode = 'INVALID_ATTRIB_VALUE';
                if ((objStudy.NCTNumber != null) && (objStudy.NCTNumber != '') && (!objStudy.NCTNumber.startsWith('NCT'))) 
                    sMessage = 'NCTNumber';
                if (objStudy.SourceSystemName == TW_SOURCE_SYSTEM_NAME) {
                    if ((objStudy.EudraCTNumber != null) && (objStudy.EudraCTNumber != '')) {
                        if (sMessage == '')
                            sMessage = 'EudraCTNumber';
                        else
                            sMessage = sMessage + ',EudraCTNumber';                       
                    }
                    if ((objStudy.TherapeuticArea != null) && (objStudy.TherapeuticArea != '')) {
                        if (sMessage == '')
                            sMessage = 'TherapeuticArea';
                        else
                            sMessage = sMessage + ',TherapeuticArea';                       
                    }                    
                }                     
                if (sMessage != '') {
                    err             = new ErrorLog();
                    err.StudyNumber = objStudy.StudyNumber;
                    err.ErrorCode   = sCode;
                    err.ErrorMessage= 'Invalid value in: ' + sMessage; 
                }                               
            }                                           
        }   
        return err;
    } 
    
    
    /**
    * Vierifies that the site message contains all required attributes and valid values in fields defined as picklist 
    */            
    private static ErrorLog verifySiteObject(String sStudyNumber, Site objSite) {
        // Check if all required study attributes are not present and are valid if not add an error         
        ErrorLog err;
        String sCode    = 'MISSING_ATTRIB';
        String sMessage = '';  
 
        if ((objSite.SiteName == null) || (objSite.SiteName == '')) {
            objSite.SiteName = '';
            sMessage = 'SiteName';              
        }
        if ((objSite.SiteCity == null) || (objSite.SiteCity == '')) {
            objSite.SiteCity = '';
            if (sMessage == '')
                sMessage = 'SiteCity';
            else
                sMessage = sMessage + ',SiteCity';                      
        }
        if ((objSite.SiteCountry == null) || (objSite.SiteCountry == '')) {
            objSite.SiteCountry = '';
            if (sMessage == '')
                sMessage = 'SiteCountry';
            else
                sMessage = sMessage + ',SiteCountry';                       
        }   
        if ((objSite.SiteStatus == null) || (objSite.SiteStatus == '')) {
            objSite.SiteStatus = '';
            if (sMessage == '')
                sMessage = 'SiteStatus';
            else
                sMessage = sMessage + ',SiteStatus';                        
        }                                                                                                                        
        if (sMessage != '') {       
            if (objSite.SiteState == null) objSite.SiteState = '';
            if (objSite.SiteZipCode == null) objSite.SiteZipCode = '';          
            err             = new ErrorLog();
            err.StudyNumber = 'Study:' + sStudyNumber + ',Site:' + objSite.SiteName + ',' + objSite.SiteCity + ',' + objSite.SiteCountry + ',' + objSite.SiteState + ',' + objSite.SiteZipCode;
            err.ErrorCode   = sCode;
            err.ErrorMessage= 'Required site attributes missing: ' + sMessage; 
        } else {
            // If all site attributes present - check that are valid
            sCode = 'INVALID_PICKLIST_VALUE';
            if ((!SITE_COUNTRY_LIST.isEmpty()) && (!SITE_COUNTRY_LIST.contains(objSite.SiteCountry)))
                sMessage = 'SiteCountry';
            if ((objSite.SiteState != null) && (objSite.SiteState != '') && (!SITE_STATE_LIST.isEmpty()) && (!SITE_STATE_LIST.contains(objSite.SiteState))) {
                if (sMessage == '')
                    sMessage = 'SiteState';
                else
                    sMessage = sMessage + ',SiteState';                      
            }  
            if ((!SITE_STATUS_LIST.isEmpty()) && (!SITE_STATUS_LIST.contains(objSite.SiteStatus))) {
                if (sMessage == '')
                    sMessage = 'SiteStatus';
                else
                    sMessage = sMessage + ',SiteStatus';                      
            }   
            if (sMessage != '') {
                if (objSite.SiteState == null) objSite.SiteState = '';
                if (objSite.SiteZipCode == null) objSite.SiteZipCode = '';
                err             = new ErrorLog();       
                err.StudyNumber = 'Study:' + sStudyNumber + ',Site:' + objSite.SiteName + ',' + objSite.SiteCity + ',' + objSite.SiteCountry + ',' + objSite.SiteState + ',' + objSite.SiteZipCode;
                err.ErrorCode   = sCode;
                err.ErrorMessage= 'Invalid picklist value in fields: ' + sMessage;  
            }                                               
        }   
        return err;
    }     
    
    
    /**
    * Deletes study records (including related sites via cascade delete)
    */      
    Webservice static Response deleteClinicalTrials(Datetime esb_process_start_time, String source_system) 
    {
        Response apiResponse    = new Response();
        apiResponse.StartTime   = DateTime.now();
        apiResponse.errorList  = new List<ErrorLog>();  
        
        if ((esb_process_start_time != null) && (source_system != null) && (source_system != '')) {
            Integer iToDeleteCount = [SELECT count() FROM TISL_Clinical_Trial_gne__c
                                      WHERE Source_System_gne__c = :source_system AND LastModifiedDate < :esb_process_start_time];
                              
            while (((iToDeleteCount/MAX_COLLECTION_SIZE > 0) || ((iToDeleteCount/MAX_COLLECTION_SIZE == 0) && (System.Math.mod(iToDeleteCount, MAX_COLLECTION_SIZE) > 0))) &&
                    (System.Limits.getQueries() <= System.Limits.getLimitQueries())) {
                
                if (System.Limits.getQueries() < System.Limits.getLimitQueries()) {
                    List<TISL_Clinical_Trial_gne__c> studyList = [SELECT Id, Trial_Number_gne__c FROM TISL_Clinical_Trial_gne__c 
                                                                  WHERE Source_System_gne__c = :source_system AND LastModifiedDate < :esb_process_start_time];
                    if(studyList.size() > 0)
                    {
                        ErrorLog error;
                        Database.DeleteResult[] deleteResults = Database.delete(studyList, false);    
                        Integer iCount = 0;
                        for(Database.Deleteresult res : deleteResults)
                        {
                            if (!res.isSuccess())
                            {
                                Database.Error[] errs = res.getErrors();            
                                for(Database.Error err : errs)
                                {
                                    error = new ErrorLog(); 
                                    error.StudyNumber   = studyList[iCount].Trial_Number_gne__c;                                
                                    error.ErrorCode = String.valueOf(err.getStatusCode());
                                    error.ErrorMessage = err.getMessage();
                                    apiResponse.errorList.add(error);
                                }               
                            } else
                                iToDeleteCount--;
                            iCount++; 
                        }
                        
                    } 
                } else {
                    ErrorLog error      = new ErrorLog();
                    error.StudyNumber   = 'N/A';                                
                    error.ErrorCode     = 'QUERY_LIMIT';
                    error.ErrorMessage  = 'SFDC governor limit reached. Processed: ' + System.Limits.getDMLRows() + ' out of ' + iToDeleteCount;            
                    apiResponse.errorList.add(error);                   
                }
            }     
        } 
        apiResponse.EndTime = DateTime.now();
        return apiResponse;                                       
    }       
}