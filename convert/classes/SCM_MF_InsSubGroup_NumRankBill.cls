//Created By: Rajesh Sinha

public class SCM_MF_InsSubGroup_NumRankBill extends SCM_MF_InsuranceCollRankBill_Filter {
	public SCM_MF_InsSubGroup_NumRankBill(String CaseId){
	  super(CaseId);
	  key = 'InsSubGroup_NumRankBill';
	  this.checked = false;
      this.displayCheck = false;
      this.displayTextBox = false;
      this.displayLabel = false;
      className = 'SCM_MF_InsSubGroup_NumRankBill';
	}
	
	public override String getFieldValue(){    
	    
	    if ( patientInsRankBillFil != null && patientInsRankBillFil.Group_Num_gne__c != null)
	        return patientInsRankBillFil.Group_Num_gne__c;
	    else
	        return '';
	  }

}