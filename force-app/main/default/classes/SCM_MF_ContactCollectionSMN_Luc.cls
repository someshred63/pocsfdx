// Added by Reji Joseph
 
//	Join Case.Case_Treating_Physician_gne__c to Account.ID and join Account.ID to 
//	Contact.HCP_gne__c.  Filter contacts which are associated to treating location on 
//	the case by using Case.Address_gne to return a list of Contact objects.
	
//	If Case.Case_Type_gne__c = ("C&R - Standard" OR "C&R - Continuous Care") then 
//   		If Contact.Is_Primary_for_gne__c  = “C&R” 
//      		If 0, merge then last modified Contact.C&R Specific = T, else “”
//       			If 1, merge Contact.Phone/Fax/Full_Name_gne__c
//       				If > 1, choose last modified and merge Contact.Phone, Else merge ""
//	If Case.Case_Type_gne__c = "GATCF - Standard" then
// 		If Contact.Is_Primary_for_gne__c  = “GATCF” 
//    		If 0, merge then last modified Contact.GATCF_Specific_gne__c = T, else “”
//     			If 1, merge Contact.Phone/Fax/Full_Name_gne__c
//     				If > 1, choose last modified and merge Contact.Phone, Else merge ""

public virtual class SCM_MF_ContactCollectionSMN_Luc extends SCM_MergeField {
	
	protected Contact contactDetails;
	
    public SCM_MF_ContactCollectionSMN_Luc (String AccountId, String CaseType)
    {
    	checked=false;
    	displayCheck=false;
    	displayTextBox=false;
    	displayLabel=false;
    	Key='Contact Collection SMN Lucentis'; 
    	className='SCM_MF_ContactCollectionSMN_Luc';

 System.Debug('----------------------------------------------------------------------------------------------------------');
        System.Debug(' Supere AccountId = ' + AccountId); 
        // 001S0000002fYFVIA2
        System.Debug('----------------------------------------------------------------------------------------------------------');
       		    	
    	
    	
    	if (CaseType.equals('C&R - Standard Case') || CaseType.equals('C&R - Continuous Care Case'))  
    		{
			   List<Contact> contactList1 = [Select  c.Id, c.AccountId, c.HCP_gne__c, c.Is_Primary_for_gne__c, c.Primary_Contact_gne__c,
					c.Zip_4_gne__c, c.Website_gne__c, c.Type_gne__c, c.State_gne__c,  c.Phone, c.Name, 
					c.LastName, c.LastModifiedDate, c.HomePhone,  c.FirstName, c.Fax, c.Email, c.Contact_Type_gne__c, 
					c.Contact_Category_gne__c, c.City__c, c.Address_gne__c, c.Address_Type_gne__c, c.Address_1_gne__c, c.Address_2_gne__c  
					From Contact c
					where c.HCP_gne__c =: AccountId and c.Is_Primary_for_gne__c in ('C&R') 
					order by c.LastModifiedDate desc 
					limit 100];
					
				if (contactList1.size() == 0)
					{
						contactDetails = null;
					}
				else if (contactList1.size() >= 1)
					{
						contactDetails = contactList1[0]; 
					}
    		}
    		
    	else if (CaseType.equals('GATCF - Standard Case'))
    		{
			   List<Contact> contactList2 = [Select  c.Id, c.AccountId, c.HCP_gne__c, c.Is_Primary_for_gne__c, c.Primary_Contact_gne__c,
					c.Zip_4_gne__c, c.Website_gne__c, c.Type_gne__c, c.State_gne__c,  c.Phone, c.Name, 
					c.LastName, c.LastModifiedDate, c.HomePhone,  c.FirstName, c.Fax, c.Email, c.Contact_Type_gne__c, 
					c.Contact_Category_gne__c, c.City__c, c.Address_gne__c, c.Address_Type_gne__c, c.Address_1_gne__c, c.Address_2_gne__c  
					From Contact c
					where c.HCP_gne__c =: AccountId and c.Is_Primary_for_gne__c in ('GATCF')
					order by c.LastModifiedDate desc 
					limit 100];
					
				if (contactList2.size() == 0)
					{
						contactDetails = null;
					}
				else if (contactList2.size() >= 1)
					{
						contactDetails = contactList2[0]; 
					}					
    		} 		
    }
}