//Created By: Rajesh Sinha

public class SCM_MF_InsSubscriberIDRankBill extends SCM_MF_InsuranceCollRankBill_Filter {
	
	public SCM_MF_InsSubscriberIDRankBill(String CaseId){
	  super(CaseId);
	  key = 'InsSubscriberIDRankBill';
	  this.checked = false;
      this.displayCheck = false;
      this.displayTextBox = false;
      this.displayLabel = false;
      className = 'SCM_MF_InsSubscriberIDRankBill';
	}
	
	public override String getFieldValue(){    
	    
	    if ( patientInsRankBillFil != null && patientInsRankBillFil.Subscriber_Num_gne__c != null)
	        return patientInsRankBillFil.Subscriber_Num_gne__c;
	    else
	        return '';
	  }

}