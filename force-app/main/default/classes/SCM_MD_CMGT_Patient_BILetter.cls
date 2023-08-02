//********************************************************************/
    // Developer Name    : Vinod
    // Document Name     : Final CMGT-FAX-72 - Patient BI Letter Analysis.doc
    // PRODUCT GROUP     : Raptiva – Growth Hormone / Nutropin
    // Type              : System document
    // Word Template     :  Patient_BI_Letter.doc   
    // Label in SF       : Patient BI Letter
    
//********************************************************************/
 
public class SCM_MD_CMGT_Patient_BILetter extends SCM_MergeDocument
{ 
   protected string streetVal = '';
   private SCM_MergeSection TotalCopayShow;
   private SCM_MergeSection InjectionTrainingInstructions;
   
   public SCM_MD_CMGT_Patient_BILetter(String caseID, String argLookupId)
    {
            super(caseID, argLookupId);
            caseId = caseID;            
    }
       
    public override void createMergeFields()  
    {
        //1 Case ID
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
        
        //2 Patient ID
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        // Date (DateLong)
        this.mergeRecipientInfo.add(new SCM_MF_DateLong());
        
        //CR_Phone
       	this.mergeRecipientInfo.add(new SCM_MF_CR_Phone(selectedCase));
        
         //CR_PhoneShort
       	this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
       
        
        //CR_Fax
        this.mergeRecipientInfo.add(new SCM_MF_CR_Fax(selectedCase));
        
        //CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_CR_URL(selectedCase));
         
        //logo
         this.mergeimages.add(new SCM_MI_LOGO(selectedCase));

        String patId = selectedCase.Patient_gne__r.Id;
        //AgeBasedFullName
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedFullName(patId));
        
        //AgeBasedStAddress
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedStAddress(patId));
        
        //AgeBasedCityStateZip
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedCityStateZip(patId));
        
        //Patient full name (Patient_First_And_Last_Name)
       	this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
        
        //7. Physician Full Name (Physician First Last Name)
    	this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        //product name with condition(Product)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase)); 
       
        //drugvial
        this.mergeRecipientInfo.add(new SCM_MF_DrugVial(selectedCase.Medical_History_gne__c));
        
        //CaseWorker
 		String recordType = selectedCase.RecordType.Name ;
        if (recordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
        }
                
        //27 DispensingCenter(Dispensing Center)
        this.mergeRecipientInfo.add(SCM_MF_Fulfillment_Factory.DispensingCenter(selectedCase.id));
        
        //Dispensing phone
        SCM_MF_DispensingCenterPhone dispPhone=new SCM_MF_DispensingCenterPhone(selectedCase.Id);
        this.mergeRecipientInfo.add(dispPhone);
        
        //Dispensing fax
        SCM_MF_DispensingFax dispFax=new SCM_MF_DispensingFax(selectedCase.Id);
        this.mergeRecipientInfo.add(dispFax);
        
        //Totalcopay
        SCM_MF_TotalCopay copay=new SCM_MF_TotalCopay(selectedCase);
         this.mergeRecipientInfo.add(copay);
        
        //InjectionTrainer
        SCM_MF_InjectionTrainer injTrainer=new SCM_MF_InjectionTrainer(selectedCase.CaseNumber);
        this.mergeRecipientInfo.add(injTrainer);
        
        //InjectionTrainingSource
         SCM_MF_InjectionTrainingSource injTrainerSrc=new SCM_MF_InjectionTrainingSource(selectedCase.CaseNumber);
        this.mergeRecipientInfo.add(injTrainerSrc);
        
        //TotalCopay/InjectionTrainingInstructions
         TotalCopayShow = new SCM_MergeSection(); 
        TotalCopayShow.key='TotalCopayShow';
        this.mergeSections.add(TotalCopayShow);
        
        
        InjectionTrainingInstructions= new SCM_MergeSection(); 
        InjectionTrainingInstructions.key='InjectionTrainingInstructions';
        this.mergeSections.add(InjectionTrainingInstructions);
      
        //repeater bi info
        SCM_MergeRepeater rpt = new SCM_MergeRepeater();
        mergeRepeaters = new list<SCM_MergeRepeater>(); 
        
         SCM_MF_BenifitInvestigation objBi = new SCM_MF_BenifitInvestigation();
         list<Benefit_Investigation_gne__c> bis=objBi.BenefitInvestigationgnec(selectedCase); 
         
         
         list<SCM_MergeRepeaterItem> rptii = new list<SCM_MergeRepeaterItem>();
         rpt.repeaterItems = rptii;
         rpt.targetTextBox = 'repeater';
         
          for (Benefit_Investigation_gne__c bi:bis){
        	SCM_MergeRepeaterItem rptI = new SCM_MergeRepeaterItem();
        	rptI.mergeFields = new list<ScM_MergeField>();
        	
        	//Insurance name
        	rptI.mergeFields.add(new SCM_MF_InsuranceName_BI(bi));
      
        	
        	//Benefit type
        	rptI.mergeFields.add(new SCM_MF_BenifitType(bi));
        	
        	//PtDeduct
        	rptI.mergeFields.add(new SCM_MF_PtDeductAmt(bi));
        	
        	//PatCostShares
        	rptI.mergeFields.add(new SCM_MF_BI_PatientCostShare(bi));
        	
        
        
        	//Maxout pocket year
        	rptI.mergeFields.add(new SCM_MF_MaxOutPocketYearAmt(bi));
        	  
        	//RecertDate
        	rptI.mergeFields.add(new SCM_MF_RecertDate(bi));
        	  	
        	rpt.repeaterItems.add(rptI);
        }
        
		this.mergeRepeaters.add(rpt);
        
       
    } 
     
     public override void getLatestValues() {
       try {
     
	     if(selectedCase.CoPay_Percent_gne__c==null && selectedCase.CoPay_Amount_gne__c==null)
		     TotalCopayShow.visible =false;
	     else
		      TotalCopayShow.visible =true;

		  boolean decider=true;
	      List <Fulfillment_gne__c> fullfillmentList=[Select f.LastModifiedDate,f.Injection_Training_Provided_By_gne__c, f.Case_Fulfillment_gne__r.CaseNumber, 
	                                                  f.Case_Fulfillment_gne__c From Fulfillment_gne__c f
	      where f.Case_Fulfillment_gne__r.CaseNumber=:selectedCase.CaseNumber order by f.LastModifiedDate desc LIMIT 1];
	     
	     if(fullfillmentList.Size()>0)
	     {
		      if(fullfillmentList[0].Injection_Training_Provided_By_gne__c==null || fullfillmentList[0].Injection_Training_Provided_By_gne__c=='Already Trained')
		      {
		       decider=false;
		      }
		      else
		      {
		      //do nothing
		      }
	     }
	     else
	     {
	      decider=false;
	     }
	     InjectionTrainingInstructions.visible=decider;
	     } 
   	catch (Exception ex){
   		InjectionTrainingInstructions.visible=false;
   	}
    }
}