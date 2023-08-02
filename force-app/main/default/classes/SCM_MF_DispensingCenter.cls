public class SCM_MF_DispensingCenter extends SCM_MergeField {
    public SCM_MF_DispensingCenter(String caseNumber) {
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false; 
        this.className = 'SCM_MF_DispensingCenter';
        this.key = 'Dispensing Center';
                
        List<Fulfillment_gne__c> fulList = [select f.In_network_name_gne__c,
            f.Out_network_name_gne__c, f.In_Network_Selected_Distributor_gne__c,
            f.Out_Network_Selected_Distributor_gne__c
            from Fulfillment_gne__c f
            where f.Case_Fulfillment_gne__c = :caseNumber];
        
        fieldValue = '';
        
        List<Account> acList;

        if (! fulList.isEmpty() && 
              fulList[0].Out_Network_Selected_Distributor_gne__c != null &&
              fulList[0].In_Network_Selected_Distributor_gne__c != null) 
        {
            if (fulList[0].In_Network_Selected_Distributor_gne__c.equals('Yes')&& fulList[0].Out_Network_Selected_Distributor_gne__c.equals('No'))
                acList = [select a.Name from Account a where a.Id = :fulList[0].In_network_name_gne__c];
                if (acList!=null && !acList.isEmpty()) {
                    fieldValue = acList[0].Name;
                }
            else if (fulList[0].Out_Network_Selected_Distributor_gne__c.equals('Yes')&&fulList[0].In_Network_Selected_Distributor_gne__c.equals('No') ) 
                acList = [select a.Name from Account a where a.Id = :fulList[0].Out_network_name_gne__c];
                if (acList!=null && !acList.isEmpty()) {
                    fieldValue = acList[0].Name;
                }
            else if (fulList[0].In_Network_Selected_Distributor_gne__c.equals(fulList[0].Out_Network_Selected_Distributor_gne__c))
                fieldValue = '';   
        }   
        
     
     if (fieldValue==null)
            {
                fieldValue = '';
            }
           
    }
    

    public override String getFieldValue() {
        return fieldValue;
    }
}