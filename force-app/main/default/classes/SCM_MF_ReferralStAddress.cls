public class SCM_MF_ReferralStAddress extends SCM_MergeField{
    
    protected Case referral;
    protected Case selectedCase;
    string case_ID;
    
    
    public SCM_MF_ReferralStAddress(Case selectedCase){
        
        this.selectedCase = selectedCase ;
        case_ID=selectedCase.Id;          
        key = 'ReferralStAddress';             
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false; 
        className='SCM_MF_ReferralStAddress';   
        fieldValue=getFieldValue();
       
    }
    
    public override String getFieldValue() {
        String referredByType = selectedCase.Referred_By_Type_gne__c;
        string Address1 = '';
        
        if(referredByType.equalsIgnoreCase('Physician/MDO') || referredByType.equalsIgnoreCase('Nurse Practitioner') || referredByType.equalsIgnoreCase('Hospital')) 
        {
        	List<Case> referralList;
        	try
        	{
        		referralList= [Select c.Referral_Address_Line_1_gne__r.Name 
        		From Case c where c.id= :case_ID limit 100];
        	}
        	catch(Exception ex)
        	{
        		return '';
        	}        	
        	
          if(referralList.size()>=1) {
            referral = referralList[0]; 
            Address1 = referral.Referral_Address_Line_1_gne__r.Name; 
            Address1=(Address1==null)?'':Address1;
           }
            
        }
         return Address1;

    }

}