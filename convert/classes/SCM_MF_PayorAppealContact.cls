// Created By Sridhar

//Join Case.CaseNumber to Insurance.Case_Insurance_gne__c to return a list of all the Insurances. 
// For each Insurance get all Benefit Investigation.BI_Insurance_gne__c where equal to Insurance.ID and filter 
//the list of BI’s to those that have Appeals.  Take all the Appeals for all the BI and for all the Insurances and
// filter the list by Appeals that are associated to an Appeal Level that has status of “Pending*” and 
//find the last modified Appeal Level object.  
//If Appeal Level = 1 then merge BI.Contact_Name_Appeal_1_gne__c
//If Appeal Level = 2 then merge BI.Contact_Name_Appeal_2_gne__c
//If Appeal Level = 3 then merge BI.Contact_Name_Appeal_3_gne__c
//If Appeal Level = 4 then merge BI.Contact_Name_Appeal_4_gne__c
//Else, select BI.Contact_Name_Appeal_4_gne__c 

  public class SCM_MF_PayorAppealContact extends SCM_MergeField 
  {

    private static String caseIdLocal;
    
    public SCM_MF_PayorAppealContact(String caseId)
    {
        this.checked = false; 
        this.displayCheck = false;
        this.displayTextBox = false;
        this.displayLabel = true;
        this.IsRequired = false;
        this.key='PayorAppealContact';        
        this.className = 'SCM_MF_PayorAppealContact';
        fieldValue = getFieldValue();
        caseIdLocal = caseId;
    }
    
     public override String getFieldValue()
    {    
        String returnString='';
        
        List<Appeal_Level_gne__c> ap;
        
        try{
        	ap = [Select a.Level_of_Appeal_gne__c,
        				   a.Benefit_Investigation_gne__r.Contact_Name_Appeal_4_gne__c,
        				   a.Benefit_Investigation_gne__r.Contact_Name_Appeal_3_gne__c, 
        				   a.Benefit_Investigation_gne__r.Contact_Name_Appeal_2_gne__c, 
        				   a.Benefit_Investigation_gne__r.Contact_Name_Appeal_1_gne__c
                           From Appeal_Level_gne__c a 
                           where (Appeal_Status_gne__c = 'Pending External Review' 
                           or Appeal_Status_gne__c = 'Pending Appeal' 
                           or Appeal_Status_gne__c = 'Pending Hearing' 
                           or Appeal_Status_gne__c = 'Pending Recert' 
                           or Appeal_Status_gne__c = 'Pending Telephone Appeal' 
                           or Appeal_Status_gne__c = 'Pending PA Appeal')  
                           and a.case_gne__c = :caseIdLocal
                           and a.Benefit_Investigation_gne__c <>''
                           and a.Appeal_ID_gne__c <>''
                           order by a.LastModifiedDate desc LIMIT 1];
        }catch(Exception e){
        	returnString =  '';
        	return returnString;
        }
           if (ap.isEmpty())
           		returnString =  '';
           else if (ap[0].Level_of_Appeal_gne__c == '1')
               returnString = ap[0].Benefit_Investigation_gne__r.Contact_Name_Appeal_1_gne__c;
           else if(ap[0].Level_of_Appeal_gne__c == '2')
               returnString = ap[0].Benefit_Investigation_gne__r.Contact_Name_Appeal_2_gne__c;
           else if (ap[0].Level_of_Appeal_gne__c == '3')
               returnString = ap[0].Benefit_Investigation_gne__r.Contact_Name_Appeal_3_gne__c;
           else 
           	   returnString = ap[0].Benefit_Investigation_gne__r.Contact_Name_Appeal_4_gne__c;                                    
           if ( returnstring == null)
           	   returnstring ='';
            
          return returnString;
        }
 }