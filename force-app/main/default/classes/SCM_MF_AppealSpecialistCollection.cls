// Created By Sridhar

//Join Case.CaseNumber to Insurance.Case_Insurance_gne__c to return a list of all the Insurances.
// For each Insurance get all Benefit Investigation.BI_Insurance_gne__c where equal to Insurance.ID and 
//filter the list of BI’s to those that have Appeals. 
// Take all the Appeals for all the BI and for all the Insurances and filter the list by Appeals that are associated to an Appeal Level that has status of “Pending*” 
//and take the Appeal Level.Appeal_Specialist_gne__c from the last modified Appeal Level object and join to User.Name and merge User.Name.
 
  
 
 public class SCM_MF_AppealSpecialistCollection extends SCM_MergeField 
  {
    
    private static List<String> InsuranceList;
    private List<Benefit_Investigation_gne__c> BIList;
    private List<Benefit_Investigation_gne__c> BIListFil = new List<Benefit_Investigation_gne__c>();
    private List<Appeal_Level_gne__c> AppealLevelList;
    private static String caseIdLocal;
    
    public SCM_MF_AppealSpecialistCollection(String caseId)
    {
        this.checked = false; 
        this.displayCheck = false;
        this.displayTextBox = false;
        this.displayLabel = true;
        this.IsRequired = false;
        this.key='AppealSpecialist';        
        this.className = 'SCM_MF_AppealSpecialistCollection';
        fieldValue = getFieldValue();
        caseIdLocal = caseId;
    }
    
    public override String getFieldValue()
    {    
        String returnString='';
        Appeal_Level_gne__c appLevelList;
        try{
        	appLevelList = [Select a.Appeal_Specialist_gne__r.Name
                           From Appeal_Level_gne__c a 
                           where (Appeal_Status_gne__c = 'Pending External Review' 
                           or Appeal_Status_gne__c = 'Pending Appeal' 
                           or Appeal_Status_gne__c = 'Pending Hearing' 
                           or Appeal_Status_gne__c = 'Pending Recert' 
                           or Appeal_Status_gne__c = 'Pending Telephone Appeal'
                           or Appeal_Status_gne__c = 'Pending Prior Auth'
                           or Appeal_Status_gne__c = 'Pending PA Appeal')  
                           and a.case_gne__c = :caseIdLocal
                           and a.Benefit_Investigation_gne__c <>''
                           and a.Appeal_ID_gne__c <>''
                           order by a.LastModifiedDate desc LIMIT 1];
         }catch(Exception e){
        	returnString='';
        	return returnString;	
        }                   
         if (appLevelList!= null )
             returnString = appLevelList.Appeal_Specialist_gne__r.Name ;
        
        return returnString;
        }
 }