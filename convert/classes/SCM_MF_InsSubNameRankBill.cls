//Created By: Rajesh Sinha

public class SCM_MF_InsSubNameRankBill extends SCM_MF_InsuranceCollRankBill_Filter{
	public SCM_MF_InsSubNameRankBill(String CaseId){
	  super(CaseId);
	  key = 'InsSubNameRankBill';
	  this.checked = false;
      this.displayCheck = false;
      this.displayTextBox = false;
      this.displayLabel = false;
      className = 'SCM_MF_InsSubNameRankBill';
	}
	
	public override String getFieldValue(){    
	    
	    if ( patientInsRankBillFil != null && patientInsRankBillFil.Subscriber_Name_gne__c != null)
	        return patientInsRankBillFil.Subscriber_Name_gne__c;
	    else
	        return ''; 
	  } 

}