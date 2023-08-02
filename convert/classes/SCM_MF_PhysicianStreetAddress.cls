//Added by Sanat Gersappa
//Logic : Join Case.Address_gne__c to Address_vod__c.ID and merge Address_vod__c.Address_1_gne__c
public class SCM_MF_PhysicianStreetAddress extends SCM_MergeField {
    public SCM_MF_PhysicianStreetAddress(Case selectedCase) {
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        key = 'PhysicianStreetAddrs';    	
        String address = selectedCase.Address_gne__c;

        List<Address_vod__c> addList = [select c.Address_1_gne__c
            from Address_vod__c c
            where c.Id = :address];
        
        if (!addList.isEmpty() && addList[0].Address_1_gne__c != null) 
            fieldValue = addList[0].Address_1_gne__c;
        else
            fieldValue = '';        
    }
    
    public override String getFieldValue() {
        return fieldValue;
    }
}