/********************************************************************/
    // Developer Name    : Reji\Prabha
    // Document Name     : LUC-CMGT-FAX-12 Denial of Coverage.doc
    // PRODUCT GROUP     : Opthalmology / Lucentis
    // Type              : Fax Coversheet
    // Word Template     : Fax_12_Denial_Of_Coverage.doc    
    // Label in SF       : Fax 12 Denial Of Coverage
    
/********************************************************************/
public class SCM_MD_Fax_DenialOfCoverage_Luc extends SCM_MergeDocument implements IStandardComboBox {
    protected String caseId;
    
    private SCM_MergeSection referredToMergeSection1;
    private SCM_MergeSection referredToMergeSection2;
    private SCM_MergeSection referredToMergeSection3;
    private SCM_MergeSection referredToMergeSection4;
    private SCM_MFG_Denial_Lucentis_Documentation DocGroup;
    SCM_MergeFieldCheckbox chk1;
    SCM_MergeFieldCheckbox chk2;
    SCM_MergeFieldCheckbox chk3;
    
    public SCM_MD_Fax_DenialOfCoverage_Luc(String caseId, String argLookupId) {
        
        super(caseId, argLookupId);
        
        caseId = caseId;
    }

    public override void createMergeFields() {
       
        //Case number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
    
        //Patient Id
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));    

        //CR_Phone
        this.mergeRecipientInfo.add( new SCM_MF_Product_Phone_CR(selectedCase));
        
        //CR_Fax
        this.mergeRecipientInfo.add( new SCM_MF_Product_Fax_CR(selectedCase));
        
        // CR_URL
        this.mergeRecipientInfo.add( new SCM_MF_Product_URL_CR(selectedCase));   

        // Attn:
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        // To RECNAME_To:
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(selectedCase.Case_Treating_Physician_gne__r.Id) );
        
        // Fax RECFAX_Fax
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        // From    
scm_mf_caseWorker cw = new scm_mf_caseWorker(selectedcase);
   		cw.displayTextBox = true;
        cw.displayLabel = true;
        cw.label = 'From:';
        cw.key = 'From';    
        this.mergeRecipientInfo.add(cw);
        
        // Ext #
        this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__c) );
        
        // CurrentDate
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        // Patient name
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.patient_gne__r.Id));
                
        // Patient DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.patient_gne__r.Id));

        // Privacy Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
        
        // Confidentiality Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        
        //Denial Reason
        this.mergeRecipientInfo.add(new SCM_MF_BI_DenialReason(selectedCase.Id));

        // *****************  Second page  *****************
   
            
        DocGroup = new SCM_MFG_Denial_Lucentis_Documentation();
       
        this.mergeFields.add(DocGroup);

        SCM_MergeFieldGroup referredToFieldGroup = new SCM_MergeFieldGroup();

        referredToMergeSection1 = new SCM_MergeSection();
        referredToMergeSection1.key = 'referred_to_1';
        referredToMergeSection2 = new SCM_MergeSection();
        referredToMergeSection2.key = 'referred_to_2';
        referredToMergeSection3 = new SCM_MergeSection();
        referredToMergeSection3.key = 'referred_to_3';
 referredToMergeSection4 = new SCM_MergeSection();
        referredToMergeSection4.key = 'additional_docs';
        referredToFieldGroup.label = 'Referred To';
        referredToFieldGroup.headerText = 'Referred To';             
        referredToFieldGroup.key = 'referred_to';
        referredToFieldGroup.isFieldGroup = true;

        //LUC_ReferredtoGATCF
        chk1 = new SCM_MergeFieldCheckbox('LUC_ReferredtoGATCF', 'Access Solutions has referred this case to the Genentech® Access to Care Foundation for review.');
        chk1.setfieldValue('? LUCENTIS Access Solutions has referred this case to the Genentech? Access to Care Foundation for review. \r\n');
        chk1.totalWidth = '900';
        referredToFieldGroup.subFields.add(chk1);

        //LUC_ReferredtoAppeals          
        chk2 = new SCM_MergeFieldCheckbox('LUC_ReferredtoAppeals', 'Access Solutions has referred this case to the Appeals Department for review.');
        chk2.setfieldValue('? LUCENTIS Access Solutions has referred this case to the Appeals Department for review. \r\n');
        chk2.totalWidth = '900';
        referredToFieldGroup.subFields.add(chk2);
        
        // LUC_FaxDenialLetter
        SCM_MF_Product_Phone_CR productPhoneCR = new SCM_MF_Product_Phone_CR(selectedCase);
        chk3 = new SCM_MergeFieldCheckbox('LUC_FaxDenialLetter', 'Please fax the denial letter to Access Solutions.');
        chk3.setfieldValue('? The Payer has indicated a denial letter has been sent to your office. Please fax the denial letter to LUCENTIS Access Solutions @ ' + productPhoneCR.fieldValue + '. \r\n');
        chk3.totalWidth = '900';
        referredToFieldGroup.subFields.add(chk3);      

        this.mergeSections.add(referredToMergeSection1);
        this.mergeSections.add(referredToMergeSection2);
        this.mergeSections.add(referredToMergeSection3);
         this.mergeSections.add(referredToMergeSection4);
        this.mergeFields.add(referredToFieldGroup);

        // Comments
        this.mergeFields.add(new SCM_MF_Comments());
    }
    
    public override void getLatestValues()
    {
        referredToMergeSection1.visible = chk1.checked;
        referredToMergeSection2.visible = chk2.checked;
        referredToMergeSection3.visible = chk3.checked;
        boolean found = false;
         for(SCM_mergeField mf:DocGroup.subfields) {
        if (mf.checked == true ) {

                    
        found = true;
            
        }
        if (mf.key == 'OtherDoc1' || mf.key == 'OtherDoc2' || mf.key == 'OtherDoc3') {
            if (mf.fieldvalue != null) {
            found = true;   
            }
        }   
        }
      
         referredToMergeSection4.visible = found;
    }

}