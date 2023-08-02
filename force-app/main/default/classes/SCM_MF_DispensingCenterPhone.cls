//condition is as  follows
//Join Case.CaseNumber to Fulfillment.Case_Fulfillment_gne__c  and select Fulfillment. In_network_Phone_Number_gne__c AND Fulfillment. Out_network_Phone_Number_gne__c
   //-If Fulfillment.In_Network_Selected_Distributor_gne__c = Yes, Join Fulfillment. In_network_Phone_Number_gne__c to Account.ID and merge Account.Number
   //-If Fulfillment.Out_Network_Selected_Distributor_gne__c = Yes,  Join Fulfillment. Out_network_Phone_Number_gne__c to Account.ID and merge Account.Number
   //-If both = No OR Yes, then merge ""

public class SCM_MF_DispensingCenterPhone extends SCM_MergeField{

 public SCM_MF_DispensingCenterPhone(String caseId) {
		checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false; 
        this.className = 'SCM_MF_DispensingCenterPhone';
        this.key = 'DispPhone';
        try {
        List<Fulfillment_gne__c> fulList = [Select f.In_network_name_gne__c,f.Out_network_name_gne__c,f.Out_network_Selected_Distributor_gne__c, 
        f.Out_network_Phone_Number_gne__c,f.In_network_Phone_Number_gne__c, f.In_Network_Selected_Distributor_gne__c, 
        f.Case_Fulfillment_gne__r.CaseNumber, f.Case_Fulfillment_gne__c From Fulfillment_gne__c f where 
		f.Case_Fulfillment_gne__c=:caseId];
        
        fieldValue = '';
        
        List<Account> acList;
            
        if (! fulList.isEmpty()) {
        	
        	if (fulList[0].In_Network_Selected_Distributor_gne__c.equals(fulList[0].Out_Network_Selected_Distributor_gne__c))
                fieldValue = '';   
            
            else if (fulList[0].In_Network_Selected_Distributor_gne__c.equals('Yes'))
                acList = [select a.Phone from Account a where a.Id = :fulList[0].In_network_name_gne__c];
                if (acList!=null && !acList.isEmpty()) {
                    fieldValue = acList[0].Phone;
                }
                  
            else if (fulList[0].Out_Network_Selected_Distributor_gne__c.equals('Yes')) 
                acList = [select a.Phone  from Account a where a.Id = :fulList[0].Out_network_name_gne__c];
                if (acList!=null && !acList.isEmpty()) {
                    fieldValue = acList[0].Phone;
                }
                 
        }   
        if(fieldValue==null)
        fieldValue='';
        }
   	catch (Exception ex){
   	fieldValue =  '';
   	}
        
    }

    public override String getFieldValue() {
        return fieldValue;
    }
}