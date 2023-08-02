/********************************************************************/
    // Developer Name    : Sridhar
    // Document Name     : Nut-CMGT-FAX-12 – Denial of Coverage
    // PRODUCT GROUP     : Nutropin
    // Type              : FaxCoverSheet
    // Word Template     : 
   
/********************************************************************/    


public class SCM_MD_Fax_DenialOfCoverage_Nut extends SCM_MergeDocument implements IStandardComboBox  { 


    //Merge sections
    private SCM_MergeSection UI_Additional_Docs;
    private SCM_MergeSection UI_NUT_ReferredtoGATCF;
    private SCM_MergeSection UI_NUT_ReferredtoAppeals;
    private SCM_MergeSection UI_NUT_FaxDenialLetter;
 
    private SCM_MergeFieldCheckbox Checkbox1;
    private SCM_MergeFieldCheckbox Checkbox2;
    private SCM_MergeFieldCheckbox Checkbox3;
    private SCM_MergeFieldCheckbox Checkbox4;
    private SCM_MergeFieldCheckbox Checkbox5;
    private SCM_MergeFieldCheckbox Checkbox6;
    private SCM_MergeFieldCheckbox Checkbox7;
    private SCM_MergeFieldCheckbox Checkbox8;
    private SCM_MergeFieldCheckbox Checkbox9;
    private SCM_MergeFieldCheckbox Checkbox10;
    private SCM_MergeFieldCheckbox Checkbox11;

    private SCM_MergeFieldCheckbox UI_Other;
    private SCM_MF_OtherDocuments  OtherDoc1;
    private SCM_MF_OtherDocuments  OtherDoc2;
    private SCM_MF_OtherDocuments  OtherDoc3;
   
    private SCM_MergeFieldCheckbox UI_NUT_RefAppchk;
    private SCM_MergeFieldCheckbox UI_NUT_RefchkGATCF;
    private SCM_MergeFieldCheckbox UI_NUT_FaxDenLetchk;
 
  public SCM_MD_Fax_DenialOfCoverage_Nut(String caseId, String argLookupId){
    
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
    
    //6.ATTN (key ATTN_Attn)
    this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id));
   
    //7.RECNAME_FACPHY(key RECNAME_Name)     
    this.mergeRecipientInfo.add(new SCM_MF_FaxAdrsTo(selectedCase.Case_Treating_Physician_gne__r.Id));
    //this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(selectedCase.Case_Treating_Physician_gne__r.Id));
    //this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstMidAndLastName(selectedCase.Case_Treating_Physician_gne__r.Id));
    
    //8.RECFAX (key RECFAX_Fax)
    this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax_RECFAX(selectedcase));
    
    //9.From //10.Ext 
      String recordType = selectedCase.RecordType.Name;
         
        if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.equals('GATCF - Standard Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));           
        }  
    
    //11.DateShort
    this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
   
    //12.PatientFullName(key Patient_First_And_Last_Name)
    this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
   
    //13.DOB(key Patient_DOB)
    this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));
    
    //14.DRUG (key DRUG)
    //this.mergeRecipientInfo.add(new SCM_MF_DRUG2(selectedCase));
   	this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedCase.Product_gne__c));
    
    //15.PrivacyNotice
    this.mergeFields.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
   
   
    //17.ConfidNotice
    this.mergeFields.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
 

    //Denial Reason (key DenialReason)
        this.mergeRecipientInfo.add(new SCM_MF_BI_DenialReason(selectedCase.Id));

     //---------------Second screen-----------------
        SCM_MergeFieldGroup docu = new SCM_MergeFieldGroup();
        docu.label = 'Documentation:';
        docu.headerText = 'The following additional document(s) are required by the Payer';       
        docu.key = 'Documentation';
  


    //Merge Sections       
         
        UI_Additional_Docs = new SCM_MergeSection();        
        UI_Additional_Docs.key = 'UI_Additional_Docs';
        this.mergeSections.add(UI_Additional_Docs);
        
      //only check boxes
       //UI_SMNComplete
        Checkbox1 = 	new SCM_MergeFieldCheckbox('UI_SMNComplete', 'SMN (Completed)');		
		Checkbox1.fieldValue = 'SMN (Completed) \r\n';
        Checkbox1.totalWidth = '165';
        Checkbox1.isNewLine = true;
        docu.subFields.add(Checkbox1);
        
       
        
       //UI_HisPhysTreat
         Checkbox2 = new SCM_MergeFieldCheckbox('UI_HisPhysTreat', 'History/Physical/Treatment Plan');		
		Checkbox2.fieldValue = 'History/Physical/Treatment Plan \r\n';
        Checkbox2.totalWidth = '220';
        Checkbox2.isNewLine = false;
        docu.subFields.add(Checkbox2);
        
        //UI_GrowthChart
      Checkbox3 = new SCM_MergeFieldCheckbox('UI_GrowthChart', 'Growth Chart');		
		Checkbox3.fieldValue = 'Growth Chart \r\n';
        Checkbox3.totalWidth = '180';
        Checkbox3.isNewLine = false;
        docu.subFields.add(Checkbox3);
        
         //UI_KaryotypeResults
         Checkbox4 = new SCM_MergeFieldCheckbox('UI_KaryotypeResults', 'Karyotype Results');		
		Checkbox4.fieldValue = 'Karyotype Results \r\n';
        Checkbox4.totalWidth = '165';
        Checkbox4.isNewLine = true;
        docu.subFields.add(Checkbox4);
       
       
        //UI_ProgressNotes
         Checkbox5 = 	new SCM_MergeFieldCheckbox('UI_ProgressNotes', 'Progress Notes');		
		Checkbox5.fieldValue = 'Progress Notes \r\n';
        Checkbox5.totalWidth = '220';
        Checkbox5.isNewLine = false;
        docu.subFields.add(Checkbox5);
        
       //UI_Prescription
         Checkbox6 = new SCM_MergeFieldCheckbox('UI_Prescription', 'Prescription');		
		Checkbox6.fieldValue = 'Prescription \r\n';
        Checkbox6.totalWidth = '180';
        Checkbox6.isNewLine = false;
        docu.subFields.add(Checkbox6);
       
       //UI_BoneAgeReport
         Checkbox7 = new SCM_MergeFieldCheckbox('UI_BoneAgeReport', 'BoneAgeReport');		
		Checkbox7.fieldValue = 'BoneAgeReport \r\n';
        Checkbox7.totalWidth = '165';
        Checkbox7.isNewLine = true;
        docu.subFields.add(Checkbox7);       
      
       //UI_RenalFunctResults
        Checkbox8 = new SCM_MergeFieldCheckbox('UI_RenalFunctResults', 'Renal Function Results(CRI Only)');		
		Checkbox8.fieldValue = 'Renal Function Results(CRI Only) \r\n';
        Checkbox8.totalWidth = '220';
        Checkbox8.isNewLine = false;
        docu.subFields.add(Checkbox8);   
            
      //UI_StimTestReport
        Checkbox9 = new SCM_MergeFieldCheckbox('UI_StimTestReport', 'Stim Test(s) Report(s)');		
		Checkbox9.fieldValue = 'Stim Test(s) Report(s) \r\n';
        Checkbox9.totalWidth = '180';
        Checkbox9.isNewLine = false;
        docu.subFields.add(Checkbox9);     
        
       //UI_PrioAuthForm
         Checkbox10 = new SCM_MergeFieldCheckbox('UI_PrioAuthForm', 'Prior Authorization Form');		
		Checkbox10.fieldValue = 'Prior Authorization Form (signed & completed) \r\n';
        Checkbox10.totalWidth = '165';
        Checkbox10.isNewLine = true;
        docu.subFields.add(Checkbox10);   
        
         //UI_PCPReferral    
         Checkbox11 = new SCM_MergeFieldCheckbox('UI_PCPReferral', 'PCP Referral');		
		Checkbox11.fieldValue = 'PCP Referral \r\n';
        Checkbox11.totalWidth = '220';
        Checkbox11.isNewLine = false;
        docu.subFields.add(Checkbox11);   
        
      
    	// UI_Other
        //UI_Other = new SCM_MergeFieldCheckbox('Other','Other');       
        //UI_Other.fieldValue ='Other';
        //UI_Other.totalWidth = '65';
        //UI_Other.isNewLine = true;
        //docu.subFields.add(UI_Other);
        
        OtherDoc1 = new SCM_MF_OtherDocuments('OtherDoc1', '');
        OtherDoc1.label = 'Other Documentation :';       
        OtherDoc1.totalWidth = '400';
        OtherDoc1.isNewLine = true;
        docu.subFields.add(OtherDoc1);
        
        OtherDoc2 = new SCM_MF_OtherDocuments('OtherDoc2', '');
        OtherDoc2.totalWidth = '400';
        OtherDoc2.isNewLine = true;
        docu.subFields.add(OtherDoc2);
        
        OtherDoc3 = new SCM_MF_OtherDocuments('OtherDoc3', '');
        OtherDoc3.totalWidth = '400';
        OtherDoc3.isNewLine = true;
        docu.subFields.add(OtherDoc3);
        
        
        this.mergeFields.add(docu);
    //.........................................................................
    	
    	SCM_MergeFieldGroup referredTo  = new SCM_MergeFieldGroup();
        referredTo .label = 'Referred To:';
        referredTo .key = 'Referred To';
        
        //MergeSection
        
        //UI_NUT_ReferredtoGATCF
      	UI_NUT_ReferredtoGATCF = new SCM_MergeSection();        
        UI_NUT_ReferredtoGATCF.key = 'UI_NUT_ReferredtoGATCF';
        this.mergeSections.add(UI_NUT_ReferredtoGATCF);  
        
        //UI_NUT_ReferredtoAppeals
        
        UI_NUT_ReferredtoAppeals = new SCM_MergeSection();        
        UI_NUT_ReferredtoAppeals.key = 'UI_NUT_ReferredtoAppeals';
        this.mergeSections.add(UI_NUT_ReferredtoAppeals);  
          
       //UI_NUT_FaxDenialLetter    
    	 UI_NUT_FaxDenialLetter = new SCM_MergeSection();        
        UI_NUT_FaxDenialLetter.key = 'UI_NUT_FaxDenialLetter';
        this.mergeSections.add(UI_NUT_FaxDenialLetter);  
        
         UI_NUT_RefchkGATCF = 
                new SCM_MergeFieldCheckbox('UI_NUT_RefchkGATCF', ' Access Solutions has referred this case to the Genentech® Access to Care Foundation[GATCF] for review.');       
        UI_NUT_RefchkGATCF.fieldValue = '';        
        UI_NUT_RefchkGATCF.totalWidth = '600';
        UI_NUT_RefchkGATCF.isNewLine = true;       
        referredTo .subFields.add(UI_NUT_RefchkGATCF); 
        
        
        UI_NUT_RefAppchk = 
                new SCM_MergeFieldCheckbox('UI_NUT_RefAppchk', 'Access Solutions has referred this case to the Appeals Department for review.');       
        UI_NUT_RefAppchk.fieldValue = '';        
        UI_NUT_RefAppchk.totalWidth = '650';
        UI_NUT_RefAppchk.isNewLine = true;       
        referredTo .subFields.add(UI_NUT_RefAppchk); 

    	
    	
       UI_NUT_FaxDenLetchk = 
                new SCM_MergeFieldCheckbox('UI_NUT_FaxDenLetchk', 'Please fax the denial letter to Access Solutions .');       
        UI_NUT_FaxDenLetchk.fieldValue = '';        
        UI_NUT_FaxDenLetchk.totalWidth = '500';
        UI_NUT_FaxDenLetchk.isNewLine = true;       
        referredTo .subFields.add(UI_NUT_FaxDenLetchk); 
       	
      this.mergeFields.add(referredTo ); 
        
    //16.UI_Comments(Key CommentField)
    this.mergeFields.add(new SCM_MF_Comments());
   
      
    	
    }
    
     public override void getLatestValues() {
     	
        UI_NUT_ReferredtoGATCF.visible = UI_NUT_RefchkGATCF.checked;
        UI_NUT_ReferredtoAppeals.visible = UI_NUT_RefAppchk.checked;
        UI_NUT_FaxDenialLetter.visible = UI_NUT_FaxDenLetchk.checked;
        
       if(Checkbox1.checked == false && Checkbox2.checked == false && Checkbox3.checked == false && Checkbox4.checked == false 
       && Checkbox5.checked == false && Checkbox6.checked == false && Checkbox7.checked == false && Checkbox8.checked == false 
       && Checkbox9.checked == false && Checkbox10.checked == false && Checkbox11.checked == false )
       {
       	UI_Additional_Docs.visible = false;
       	
       }
       else
       {
       UI_Additional_Docs.visible = true;
       }
       
       //if(UI_Other.checked == false){
       //     	OtherDoc1.mergeValue = '';
       //     	OtherDoc2.mergeValue = '';
       //     	OtherDoc3.mergeValue = '';}
     }
       
}