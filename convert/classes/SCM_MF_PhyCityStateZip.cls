public class SCM_MF_PhyCityStateZip extends SCM_MergeField
{
	private string caseId;
	public SCM_MF_PhyCityStateZip(string caseId)
    {
    	checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        Key='PhyCityStateZip';
        className = 'SCM_MF_PhyCityStateZip';
        this.caseId=caseId;
                
    }
    
    public override String getFieldValue()
    {
	List<Case> caseList=[Select c.Address_gne__r.State_vod__c, c.Address_gne__r.Zip_vod__c, c.Address_gne__r.City_vod__c
					 From Case c where c.id=:caseId];
	Case phyCityStateZip4 = caseList[0];
	String phyCity = phyCityStateZip4.Address_gne__r.City_vod__c; 
	String phyState = phyCityStateZip4.Address_gne__r.State_vod__c;
	String phyZip4 = phyCityStateZip4.Address_gne__r.Zip_vod__c;
	String concat=phyCity+' '+phyState+' '+phyZip4;
	concat=(concat==null)?'':concat;
        return concat;
    }
	
}