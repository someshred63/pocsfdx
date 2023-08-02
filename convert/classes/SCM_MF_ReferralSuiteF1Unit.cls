public class SCM_MF_ReferralSuiteF1Unit extends  SCM_MergeField {   
	protected Case referral;
    protected Case selectedCase;
    string case_ID;
    
    
    public SCM_MF_ReferralSuiteF1Unit(Case selectedCase){
        
        this.selectedCase = selectedCase ;
        case_ID=selectedCase.Id;          
        key = 'ReferralSuiteF1Unit';             
        checked = false;
        displayCheck = false; 
        displayTextBox = false;
        displayLabel = false; 
        className='SCM_MF_ReferralSuiteF1Unit';   
        fieldValue=getFieldValue();
        }
     
       
    
    
    public override String getFieldValue() {
        String referredByType = selectedCase.Referred_By_Type_gne__c;
        string Address2 = '';
        if(referredByType.equalsIgnoreCase('Physician/MDO') || 
        referredByType.equalsIgnoreCase('Nurse Practitioner') || 
        referredByType.equalsIgnoreCase('Hospital')) 
        {
        List<Case> referralList;
        try
        {
	        referralList= [Select c.Referral_Address_Line_1_gne__r.Address_line_2_vod__c 
    	    From Case c where c.id= :case_ID limit 100];
        }
        catch(Exception ex)
        {
        	return '';        	
        }
          if(referralList.size()>=1) {
            referral = referralList[0]; 
            Address2 = referral.Referral_Address_Line_1_gne__r.Address_line_2_vod__c; 
            Address2=(Address2==null)?'':Address2;
           }
             
        }
         return Address2;

    }
	
	
	
	

}