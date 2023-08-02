// Added By: Paras Sharma

public class SCM_MF_PolicyNumPA extends SCM_MF_InsuranceCollection{

	string retValue = '';
	private Benefit_Investigation_gne__c BI;
	private Prior_Authorization_gne__c PAuth;
	
	
	public SCM_MF_PolicyNumPA(String caseId) {
		super(caseId);
		
		key = 'Policy_Num';
		this.checked = false;
        this.displayCheck = false;
        this.displayTextBox = false;
        this.displayLabel = false;
        className = 'SCM_MF_PolicyNumPA';
        try {
        if(BIListFil.size() == 0){
        	retValue = '';
        }
        else if(BIListFil.size() >= 1){
        	PAuth = [Select p.Benefit_Investigation_gne__r.BI_Insurance_gne__r.Policy_Number_gne__c, 
        			 p.Benefit_Investigation_gne__c From Prior_Authorization_gne__c p
					 where p.id = : PA.Id];
			retValue = PAuth.Benefit_Investigation_gne__r.BI_Insurance_gne__r.Policy_Number_gne__c;
        }
        }catch(Exception ex){
        retValue = '';	
        }
	}
	
	public override String getFieldValue() {		
		if(retValue == null){
			retValue = '';
		}
		return retValue;
	}
}