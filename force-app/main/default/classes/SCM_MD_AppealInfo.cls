public class SCM_MD_AppealInfo extends SCM_MergeDocument { 


   public SCM_MD_AppealInfo(String caseId, String argLookupId){
    
        super(caseId, argLookupId);
    }

    public override void createMergeFields() {
    	
    //1.CaseID
    this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
    
    //2.PatientID
    this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
    
    //3.CR_Phone ( key CR_Phone)
    this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
    
    //CR_PhoneShort
    this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
    
    //4.CR_Fax (key CR_Fax)
    this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
    
    //5.CR_URL ( key CR_URL)
    this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
    
    	this.mergeimages.add(new SCM_MI_LOGO(selectedCase));
  		this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
  		
  		
  		this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
  		this.mergeRecipientInfo.add(new SCM_MF_Product_ScientificName(selectedCase));	
    	this.mergeFields.add(SCM_MF_ReferralFieldFactory.ReferredBy(selectedCase));
    	// Current Date (key Current_Date)
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        this.mergeFields.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(selectedCase.Case_Treating_Physician_gne__c));
        this.mergeFields.add(SCM_MF_ReferralFieldFactory.ReferredDate(selectedCase));
       
    	this.mergeFields.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__c));
    	
    	this.mergeFields.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__c));
    	
    	
    	List<Appeal_Level_gne__c> appealLevelList = [select Benefit_Investigation_gne__r.Contact_Name_Appeal_4_gne__c,
    	Benefit_Investigation_gne__r.Contact_Name_Appeal_3_gne__c,
    	Benefit_Investigation_gne__r.Contact_Name_Appeal_2_gne__c,
    	Benefit_Investigation_gne__r.Contact_Name_Appeal_1_gne__c,
    	Benefit_Investigation_gne__r.Phone_Appeal_1_gne__c,
    	Benefit_Investigation_gne__r.Phone_Appeal_2_gne__c,
    	Benefit_Investigation_gne__r.Phone_Appeal_3_gne__c,
    	Benefit_Investigation_gne__r.Phone_Appeal_4_gne__c,
    	Benefit_Investigation_gne__r.Fax_Appeal_1_gne__c,
    	Benefit_Investigation_gne__r.Fax_Appeal_2_gne__c,
    	Benefit_Investigation_gne__r.Fax_Appeal_3_gne__c,
    	Benefit_Investigation_gne__r.Fax_Appeal_4_gne__c,
    	Benefit_Investigation_gne__r.Attention_Appeal_1_gne__c,
    	Benefit_Investigation_gne__r.Attention_Appeal_2_gne__c,
    	Benefit_Investigation_gne__r.Attention_Appeal_3_gne__c,
    	Benefit_Investigation_gne__r.Attention_Appeal_4_gne__c,
    	Benefit_Investigation_gne__r.Appeal_Level_1_Deadline_Criteria_gne__c,
    	Benefit_Investigation_gne__r.Appeal_Level_2_Deadline_Criteria_gne__c,
    	Benefit_Investigation_gne__r.Appeal_Level_3_Deadline_Criteria_gne__c,
    	Benefit_Investigation_gne__r.Appeal_Level_4_Deadline_Criteria_gne__c,
    	Benefit_Investigation_gne__r.AddrLine1_Appeal_1_gne__c ,
    	Benefit_Investigation_gne__r.AddrLine1_Appeal_2_gne__c ,
    	Benefit_Investigation_gne__r.AddrLine1_Appeal_3_gne__c ,
    	Benefit_Investigation_gne__r.AddrLine1_Appeal_4_gne__c ,
    	Benefit_Investigation_gne__r.AddrLine2_Appeal_1_gne__c ,
    	Benefit_Investigation_gne__r.AddrLine2_Appeal_2_gne__c ,
    	Benefit_Investigation_gne__r.AddrLine2_Appeal_3_gne__c ,
    	Benefit_Investigation_gne__r.AddrLine2_Appeal_4_gne__c ,
    	Benefit_Investigation_gne__r.City_Appeal_1_gne__c ,
    	Benefit_Investigation_gne__r.City_Appeal_2_gne__c ,
    	Benefit_Investigation_gne__r.City_Appeal_3_gne__c ,
    	Benefit_Investigation_gne__r.City_Appeal_4_gne__c ,
    	Benefit_Investigation_gne__r.State_Appeal_1_gne__c ,
    	Benefit_Investigation_gne__r.State_Appeal_2_gne__c ,
    	Benefit_Investigation_gne__r.State_Appeal_3_gne__c ,
    	Benefit_Investigation_gne__r.State_Appeal_4_gne__c ,
    	Benefit_Investigation_gne__r.Zip_Appeal_1_gne__c ,
    	Benefit_Investigation_gne__r.Zip_Appeal_2_gne__c ,
    	Benefit_Investigation_gne__r.Zip_Appeal_3_gne__c ,
    	Benefit_Investigation_gne__r.Zip_Appeal_4_gne__c ,
    	Benefit_Investigation_gne__r.Level_1_Estimated_Appeal_TAT_gne__c ,
    	Benefit_Investigation_gne__r.Level_2_Estimated_Appeal_TAT_gne__c ,
    	Benefit_Investigation_gne__r.Level_3_Estimated_Appeal_TAT_gne__c ,
    	Benefit_Investigation_gne__r.Level_4_Estimated_Appeal_TAT_gne__c ,
    	Benefit_Investigation_gne__r.Appointment_of_Representative_gne__c ,
    	Benefit_Investigation_gne__r.AOR_Comments_gne__c ,
    	Benefit_Investigation_gne__r.Peer_to_Peer_Review_Available_gne__c ,
    	Benefit_Investigation_gne__r.Peer_to_Peer_Phone_gne__c ,
    	Benefit_Investigation_gne__r.Peer_to_Peer_Contact_Department_gne__c ,
    	Benefit_Investigation_gne__r.Appeal_Application_Form_gne__c ,
    	Benefit_Investigation_gne__r.External_Review_Form_gne__c ,
    	Benefit_Investigation_gne__r.Peer_to_Peer_Estimated_TAT_gne__c ,
    	Benefit_Investigation_gne__r.Peer_to_Peer_Comments_gne__c ,
    	Benefit_Investigation_gne__r.BI_Insurance_gne__r.Self_Funded_gne__c,
    	Level_of_Appeal_gne__c,id,Benefit_Investigation_gne__r.Payer_BI_gne__r.Name,Appeal_ID_gne__r.Num_of_Appeal_Levels_Allowed_gne__c from Appeal_Level_gne__c where Benefit_Investigation_gne__r.Case_BI_gne__r.Id = :selectedCase.id and Print_on_Appeal_Report_gne__c =true  order by LastModifiedDate  desc limit 1];
    	Appeal_Level_gne__c appealLevel = null;
    	Appeal_gne__c appeal = null;
    	Benefit_Investigation_gne__c BI = null;
    	Insurance_gne__c Ins = null;
    	
    	if (appealLevelList.size() > 0){
    		appealLevel = appealLevelList[0];
			BI = appealLevel.Benefit_Investigation_gne__r;
			Ins = BI.BI_Insurance_gne__r;
			appeal = appealLevel.Appeal_ID_gne__r;
    	}
    	
    	integer level = 0;
    	
    	if (appealLevel != null){
    		if (appealLevel.Level_of_Appeal_gne__c != null && appealLevel.Level_of_Appeal_gne__c != ''){
    			if(appealLevel.Level_of_Appeal_gne__c == 'External') {
    				level = 5;
    			}
    			else {
    				level = integer.valueOf(appealLevel.Level_of_Appeal_gne__c);
    			}
    		}
    	}
    	
    	this.mergeRecipientInfo.add(new SCM_MF_BI_Payer(BI));
    	this.mergeFields.add(SCM_MF_Appeal_FieldFactory.AppealLevel(appealLevel));
    	this.mergeFields.add(SCM_MF_Appeal_FieldFactory.NumberOfAppeals(appeal));
    	this.mergeFields.add(SCM_MF_BI_FieldFactory.AppealApplicationForm(BI));
    	this.mergeFields.add(SCM_MF_BI_FieldFactory.ExternalReviewForm(BI));
    	
    	this.mergeFields.add(SCM_MF_BI_FieldFactory.AppealContact(BI, Level));
    	this.mergeFields.add(SCM_MF_BI_FieldFactory.AppealAddress(BI, Level));
    	this.mergeFields.add(SCM_MF_BI_FieldFactory.AppealPhone(BI, Level));
    	this.mergeFields.add(SCM_MF_BI_FieldFactory.AppealFax(BI, Level));
    	this.mergeFields.add(SCM_MF_BI_FieldFactory.AppealAttention(BI, Level));
    	this.mergeFields.add(SCM_MF_BI_FieldFactory.AppealDeadlineCriteria(BI, Level));
    	this.mergeFields.add(SCM_MF_BI_FieldFactory.AppealCity(BI, Level));
    	this.mergeFields.add(SCM_MF_BI_FieldFactory.AppealState(BI, Level));
    	this.mergeFields.add(SCM_MF_BI_FieldFactory.AppealZip(BI, Level));
    	this.mergeFields.add(SCM_MF_BI_FieldFactory.AppealZip(BI, Level));
    	this.mergeFields.add(SCM_MF_BI_FieldFactory.AppealLevel1TAT(BI, Level));
    	this.mergeFields.add(SCM_MF_BI_FieldFactory.AppointmentofRepresentative(BI));
    	this.mergeFields.add(SCM_MF_BI_FieldFactory.AppealComments(BI));
    	this.mergeFields.add(SCM_MF_BI_FieldFactory.P2Preview(BI));
    	this.mergeFields.add(SCM_MF_BI_FieldFactory.P2PPhone(BI));
    	this.mergeFields.add(SCM_MF_BI_FieldFactory.P2PContact(BI));
    	this.mergeFields.add(SCM_MF_BI_FieldFactory.P2PTAT(BI));
		this.mergeFields.add(SCM_MF_BI_FieldFactory.P2PComments(BI));
		this.mergeFields.add(SCM_MF_Insurance_Factory.SelfFunded(Ins));
    } 
}