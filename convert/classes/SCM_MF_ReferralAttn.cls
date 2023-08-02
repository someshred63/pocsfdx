// Added By: Deepak Yadav
// Logic:If Case.Referred_By_Type_gne__c =Physician/MDO OR Nurse Practictioner
//		 Join Case. Referred_By_Party_gne__c to Account.ID and join Account.ID to Contact.HCP_gne__c.  Filter contacts which are associated to referred by location  on the case by using Case.Address_gne to return a list of Contact objects.
//		 If Case.Case_Type_gne__c = ("C&R - Standard" OR "C&R - Continuous Care") then 
//	     If Contact.Is_Primary_for_gne__c  = “C&R” 
//	     If 0, merge then last modified Contact.C_R_Specific_gne__c = T, else “”
//       If 1, merge Contact.Full_Name_gne__c
//       If > 1, choose last modified and merge Contact.Full_Name_gne__c, Else merge ""
//		 If Case.Case_Type_gne__c = "GATCF - Standard" then
//       If Contact.Is_Primary_for_gne__c  = “GATCF” 
//       If 0, merge then last modified Contact.GATCF_Specific_gne__c = T, else “”
//       If 1, merge Contact.Contact.Full_Name_gne__c
//       If > 1, choose last modified and merge Contact.Full_Name_gne__c, Else merge ""
//
//		If Case.Referred_By_Type_gne__c = Hospital
//      Merge Case.Referred_By_Person_gne__c
//      Else, merge “”  


public class SCM_MF_ReferralAttn extends SCM_MergeField {
    
    private Case selected_Case ;
    public SCM_MF_ReferralAttn(Case selectedCase){
        
        this.selected_Case= selectedCase ;
        key = 'ReferralAttn';             
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false; 
        className='SCM_MF_ReferralAttn';   
        fieldValue = GetReferralAttnValue();
    }
    public override String getFieldvalue() {
        return fieldValue;
    }
    
    private string GetReferralAttnValue() {
    	string returnString ='' ;
    	String referredByType = selected_Case.Referred_By_Type_gne__c;    	
    	referredByType = (referredByType == null) ? '': referredByType;
    	String recordType  = selected_Case.RecordType.Name;    	
    	recordType  = (recordType  == null) ? '': recordType ;
    	
    	try
    	{
    	if(referredByType.equalsIgnoreCase('Physician/MDO') || referredByType.equalsIgnoreCase('Nurse Practitioner') ) {
    		List<Contact > ListContact = [Select  c.LastName, c.FirstName From Contact c where c.Is_Primary_for_gne__c='C&R' 
    		and c.Address_gne__c=:selected_Case.Address_gne__c
    		and c.HCP_gne__r.Id=:selected_Case.Referred_By_Party_gne__r.Id
    		order by c.LastModifiedDate desc LiMIT 500 ];
           
           if (recordType.equalsIgnoreCase('C&R - Standard Case') || recordType.equalsIgnoreCase('C&R - Continuous Care Case')) {
           		if(ListContact.size() == 0){
           			 List<Contact > Listtrue = [Select c.LastName, c.FirstName From Contact c where c.Address_gne__c=:selected_Case.Address_gne__c
           			 and c.HCP_gne__r.Id=:selected_Case.Referred_By_Party_gne__r.Id and c.C_R_Specific_gne__c=true
           			 order by c.LastModifiedDate desc LiMIT 1 ];   
           			 if (Listtrue.Size() >=1 ) {                                  
                		returnString=Listtrue[0].FirstName;
                		if(returnString != '' || returnString != null) { returnString = returnString + ' '; }
                		returnString = returnString + ((Listtrue[0].LastName == null)? '': Listtrue[0].LastName );                			
                	 }                	                                
           		}
           		else if(ListContact.size() >= 1){
           			returnString=ListContact[0].FirstName;
           			if(returnString != '' || returnString != null) { returnString = returnString + ' '; }
                	returnString = returnString + ((ListContact[0].LastName == null)? '': ListContact[0].LastName );  
           		}
           }
           else if (recordType.equalsIgnoreCase('GATCF - Standard Case')) {
           		List<Contact > List1 = [Select c.LastName, c.FirstName From Contact c where c.Is_Primary_for_gne__c='GATCF' and 
           		c.Address_gne__c=:selected_Case.Address_gne__c
           		and c.HCP_gne__r.Id=:selected_Case.Referred_By_Party_gne__r.Id
           		order by c.LastModifiedDate desc LiMIT 500 ]; 
           		if(List1.SIZE()>=1) {
           			returnString=List1[0].FirstName;
           			if(returnString != '' || returnString != null) { returnString = returnString + ' '; }
                	returnString = returnString + ((List1[0].LastName == null)? '': List1[0].LastName );
           		}
           		else if(List1.SIZE() == 0) {           			 
           			List<Contact > Listtrue1 = [Select c.LastName, c.FirstName From Contact c where 
           			c.Address_gne__c=:selected_Case.Address_gne__c 
           			and c.HCP_gne__r.Id=:selected_Case.Referred_By_Party_gne__r.Id 
           			and  c.GATCF_Specific_gne__c=true
           			order by c.LastModifiedDate desc LiMIT 500 ];
           			
           			if(Listtrue1.Size() >= 1) {
           				returnString=Listtrue1[0].FirstName;
           				if(returnString != '' || returnString != null) { returnString = returnString + ' '; }
           				returnString = returnString + ((Listtrue1[0].LastName == null)? '': Listtrue1[0].LastName );
           			}
           		} 
           }   		
        }
    	else if (referredByType.equalsIgnoreCase('Hospital')) {
    		returnString = selected_Case.Referred_By_Person_gne__c ;
    	} 
    	}
    	catch(Exception ex)
    	{
    		return '';
    	}   	
    	returnString = (returnString == null)?'': returnString;
    	return returnString ;   	
    	
    }
}