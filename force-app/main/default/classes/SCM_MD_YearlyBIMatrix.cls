public class SCM_MD_YearlyBIMatrix extends SCM_MergeDocument {
public SCM_MD_YearlyBIMatrix(String caseID, String argLookupId) {
        super(caseID, argLookupId);
       
    }
   SCM_MergeField Phone;
   SCM_MergeField Fax;
   SCM_MergeField Subid1;
   SCM_MergeField Subid2;
   SCM_MergeField Subid3;
    
    public override void createMergeFields() {
    
    	this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
    	

    
    SCM_MergeRepeater mrpt = new SCM_MergeRepeater();
    mergeRepeaters = new list<SCM_MergeRepeater>();
    mrpt.repeaterItems = new list<SCM_MergeRepeaterItem>();
    mrpt.targetTextBox = 'matrix';
    
    	
    	
    		SCM_MergeRepeaterItem mi = new 	SCM_MergeRepeaterItem();
    	
    		mi.mergeFields = new list<ScM_MergeField>();
    	
    		mi.mergeFields.add(new  SCM_MF_PatientId(selectedCase));
    Prior_Authorization_gne__c pa = new Prior_Authorization_gne__c();
  try {
   pa =  [Select id,Benefit_Investigation_gne__r.Bi_Insurance_gne__r.Payer_gne__r.Name,  Benefit_Investigation_gne__r.Bi_Insurance_gne__r.Rank_gne__c,Benefit_Investigation_gne__r.Prior_Authorization_Required_Formula_gne__c,Recertification_Date_gne__c,PA_Effective_Date_gne__c
From Prior_Authorization_gne__c b 
where 	Benefit_Investigation_gne__r.Case_BI_gne__r.id = :SelectedCase.Id order by Recertification_Date_gne__c asc limit 1];
  }
  catch (exception ex){
    			pa = new Prior_Authorization_gne__c();
  }
  	
    		if (pa == null ){
    			pa = new Prior_Authorization_gne__c();	
    		}
    		mi.mergeFields.add(new  SCM_MF_Recert_PAEffectDate(pa));
    
    		mi.mergeFields.add(new  SCM_MF_Recert_PARecertDate(pa));
    		Subid1 = SCM_MF_Insurance_Factory.SubscriberIDSMN(selectedCase,'1');
    		mi.mergeFields.add(Subid1);
    		Subid2 =SCM_MF_Insurance_Factory.SubscriberIDSMN(selectedCase,'2');
 			mi.mergeFields.add(Subid2);
 			Subid3 =SCM_MF_Insurance_Factory.SubscriberIDSMN(selectedCase,'3');
 			mi.mergeFields.add(Subid3);   		
    		mi.mergeFields.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(SelectedCase.Patient_gne__c));
    
    		mi.mergeFields.add(SCM_MF_PatientFieldFactory.PatientDOB(SelectedCase.Patient_gne__c));
    
    		mi.mergeFields.add(new SCM_MF_InsuranceNameRecertRpt(pa.Benefit_Investigation_gne__r.Bi_Insurance_gne__r));

			mi.mergeFields.add(new SCM_MF_AA_InsuranceByRank(SelectedCase,'Primary'));    
    		mi.mergeFields.add(new SCM_MF_AA_InsuranceByRank(SelectedCase,'Secondary'));
    
    		mi.mergeFields.add(new SCM_MF_AA_InsuranceByRank(SelectedCase,'Tertiary'));
    
    		mi.mergeFields.add(SCM_MF_Fulfillment_Factory.DispensingCenter(SelectedCase.Id));
    		Phone = SCM_MF_Fulfillment_Factory.DispensingContactPhone(SelectedCase.Id);
    		mi.mergeFields.add(Phone);
    		Fax = SCM_MF_Fulfillment_Factory.FulFillmentFaxNumber_BI(SelectedCase.Id);
    		mi.mergeFields.add(Fax);
    		
    		mi.mergeFields.add(New SCM_MF_PanExperationDate(SelectedCase,selectedCase.Product_gne__c));
    		mrpt.repeaterItems.add(mi);
    		if (Phone.fieldValue != null && Phone.fieldValue != '')
     	{
     		Phone.fieldValue = 'Phone:' + Phone.fieldValue;	
     	}
     	if (Fax.fieldValue != null && Fax.fieldValue != '')
     	{
     		Fax.fieldValue = 'Fax:' + Fax.fieldValue;	
     	}
     	if (Subid1.fieldValue != null && Subid1.fieldValue != '')
     	{
     		Subid1.fieldValue = '-' + Subid1.fieldValue;	
     	}
     	if (Subid2.fieldValue != null && Subid2.fieldValue != '')
     	{
     		Subid2.fieldValue = '-' + Subid2.fieldValue;	
     	}
     	if (Subid3.fieldValue != null && Subid3.fieldValue != '')
     	{
     		Subid3.fieldValue = '-' + Subid3.fieldValue;	
     	}
    	
    	this.mergeRepeaters.add(mrpt);
    }
     public override void getLatestValues()  {
     
     
     }
     
}