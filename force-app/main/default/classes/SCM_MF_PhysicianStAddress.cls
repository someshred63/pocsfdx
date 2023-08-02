//Logic: Join Case.Address_gne__c to Address_vod__c.ID and merge Address_vod__c.Name
public class SCM_MF_PhysicianStAddress extends SCM_MergeField
{
    private string caseId;
    public SCM_MF_PhysicianStAddress(string caseId)
    {
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        Key='Physician Street Address';
        className = 'SCM_MF_PhysicianStAddress';
        this.caseId=caseId;
        
        
        List<Case> cases = [Select c.Address_gne__c From Case c where c.Id=:caseId];
        
        if (!cases.isEmpty()) {
            List<Address_vod__c> adds = [select a.Name from Address_vod__c a where a.Id =:cases[0].Address_gne__c];
            if (!adds.isEmpty())
                fieldValue = adds[0].Name;
                if (fieldValue == null)
                    fieldValue = '';
        }          
    }
 
    public override String getFieldValue() {
        return fieldValue;
    }              
}