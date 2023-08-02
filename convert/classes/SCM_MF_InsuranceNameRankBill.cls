//Created By: Rajesh Sinha

public class SCM_MF_InsuranceNameRankBill extends SCM_MF_InsuranceCollRankBill_Filter {
	public SCM_MF_InsuranceNameRankBill(String CaseId){
	  super(CaseId);
	  key = 'InsuranceNameRankBill';
	  this.checked = false;
      this.displayCheck = false;
      this.displayTextBox = false;
      this.displayLabel = false;
      className = 'SCM_MF_InsuranceNameRankBill';
	}
   
	public override String getFieldValue(){    
	    
	    if ( patientInsRankBillFil != null && patientInsRankBillFil.Payer_gne__r.Name != null)
	        return patientInsRankBillFil.Payer_gne__r.Name;
	    else
	        return ''; 
	  } 

}