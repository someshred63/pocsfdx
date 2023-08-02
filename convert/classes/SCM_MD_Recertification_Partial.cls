public class SCM_MD_Recertification_Partial extends SCM_MergeDocument {
public SCM_MD_Recertification_Partial(String caseID, String argLookupId,Date BatchCreation) {
        super(caseID, argLookupId);
        createddate = BatchCreation;
    }
    private date createddate;
    public void redoMergefields(){
    	this.createMergeFields();
    }
    
    public override void createMergeFields() {
    	createddate = date.today();
    	this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
    	
    	List<Prior_Authorization_gne__c > pas = [Select id,Benefit_Investigation_gne__r.Bi_Insurance_gne__r.Payer_gne__r.Name,  Benefit_Investigation_gne__r.Bi_Insurance_gne__r.Rank_gne__c,Benefit_Investigation_gne__r.Prior_Authorization_Required_Formula_gne__c,Recertification_Date_gne__c,PA_Effective_Date_gne__c
From Prior_Authorization_gne__c b 
where 	Benefit_Investigation_gne__r.Case_BI_gne__r.id = :SelectedCase.Id and Recertification_Date_gne__c >= :createddate.addDays(45) and Recertification_Date_gne__c <= :createddate.addDays(60)
    	];
    
    SCM_MergeRepeater mrpt = new SCM_MergeRepeater();
    mergeRepeaters = new list<SCM_MergeRepeater>();
    mrpt.repeaterItems = new list<SCM_MergeRepeaterItem>();
    mrpt.targetTextBox = 'matrix';
    
    	for(Prior_Authorization_gne__c pa : pas) {
    	
    		SCM_MergeRepeaterItem mi = new 	SCM_MergeRepeaterItem();
    	
    		mi.mergeFields = new list<ScM_MergeField>();
    	
    		mi.mergeFields.add(new  SCM_MF_PatientId(selectedCase));
    
    		mi.mergeFields.add(new  SCM_MF_Recert_PAEffectDate(pa));
    
    		mi.mergeFields.add(new  SCM_MF_Recert_PARecertDate(pa));
    		mi.mergeFields.add(SCM_MF_Insurance_Factory.SubscriberIDSMN(selectedCase,'1'));
    		
    		mi.mergeFields.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(SelectedCase.Patient_gne__c));
    
    		mi.mergeFields.add(SCM_MF_PatientFieldFactory.PatientDOB(SelectedCase.Patient_gne__c));
    
    		mi.mergeFields.add(new SCM_MF_InsuranceNameRecertRpt(pa.Benefit_Investigation_gne__r.Bi_Insurance_gne__r));
    
    		mi.mergeFields.add(new SCM_MF_AA_InsuranceByRank(SelectedCase,'Secondary'));
    
    		mi.mergeFields.add(new SCM_MF_AA_InsuranceByRank(SelectedCase,'Tertiary'));
    
    		mi.mergeFields.add(SCM_MF_Fulfillment_Factory.DispensingCenter(SelectedCase.Id));
    
    		SCM_MergeField Phone = SCM_MF_Fulfillment_Factory.DispensingContactPhone(SelectedCase.Id);
    		if (Phone.fieldvalue != ''){
    			Phone.fieldvalue = 'Phone:'+ Phone.fieldvalue;
    		}
    		mi.mergeFields.add(Phone);
    		SCM_MergeField Fax = SCM_MF_Fulfillment_Factory.FulFillmentFaxNumber_BI(SelectedCase.Id);
    		if (fax.fieldvalue != ''){
    			fax.fieldvalue = 'Fax:'+ fax.fieldvalue;
    		}
    		mi.mergeFields.add(Fax);
    		
    		mi.mergeFields.add(New SCM_MF_PanExperationDate(SelectedCase,selectedCase.Product_gne__c));
    		mrpt.repeaterItems.add(mi);
    	
    	}
    	this.mergeRepeaters.add(mrpt);
    }
}