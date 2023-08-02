//Added by Sanat Gersappa
//Logic - Join Case.CaseNumber to Shipment.Case_Shipment_gne__c and select the last modified shipment to merge 
// “of ” Shipment.Quantity_1_gne__c “ vial(s)”

public class SCM_MF_ShipDetail extends SCM_MergeField {
    public SCM_MF_ShipDetail(Case selectedCase) {
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        key = 'ShipDetail';
        try
        {
	        List<Shipment_gne__c> shipList = [select c.Quantity_1_gne__c
	            from Shipment_gne__c c
	            where c.Case_Shipment_gne__c = :selectedCase.Id
	            order by c.LastModifiedDate desc];
	            
	        if (!shipList.isEmpty()) {
	            fieldValue = 'of ' + shipList[0].Quantity_1_gne__c + ' vial(s)';
	        }
	        else {
	            fieldValue = '';
	        }
        }
        catch (Exception e)
        {
            System.debug('SCM_MF_ShipDetail...Error Message:' + e.getMessage());
            fieldValue = '';
        }
    
    }
    
    public override String getFieldValue() {
        return fieldValue;
    }   
}