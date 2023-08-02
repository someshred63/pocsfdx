// Added By: Paras Sharma

public class SCM_MF_GroupNumPA extends SCM_MF_InsuranceCollection{

	string retValue = '';
	private Benefit_Investigation_gne__c BI;
	private Prior_Authorization_gne__c PAuth;
	
	
	public SCM_MF_GroupNumPA(String caseId) {
		super(caseId);
		
		key = 'Group_Num';
		this.checked = false;
        this.displayCheck = false;
        this.displayTextBox = false;
        this.displayLabel = false;
        className = 'SCM_MF_GroupNumPA';
        
        if(BIListFil.size() == 0){
        	retValue = '';
        }
        else if(BIListFil.size() >= 1){
        	try{
        		PAuth = [Select p.Benefit_Investigation_gne__r.BI_Insurance_gne__r.Group_Num_gne__c, 
        			 p.Benefit_Investigation_gne__c From Prior_Authorization_gne__c p
					 where p.id = : PA.Id];
        		
			retValue = PAuth.Benefit_Investigation_gne__r.BI_Insurance_gne__r.Group_Num_gne__c;
			}catch(Exception e){
        		retValue = '';
        	}
        }
	}
	
	public override String getFieldValue() {		
		if(retValue == null){
			retValue = '';
		}
		return retValue;
	}
}