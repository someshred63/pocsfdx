//Testing
public class SCM_MD_Fax_ClaimsFollowUp extends SCM_MergeDocument implements IStandardComboBox{
    public SCM_MD_Fax_ClaimsFollowUp(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }

    public override void createMergeFields() {
        //Logo    
        this.mergeimages.add(new SCM_MI_Logo(selectedCase));

        // Case number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
        
        // Patient Id
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));  
    
        // CR_Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        // CR_Fax        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
          
        // CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase)); 
        
        // Drug
        this.mergeRecipientInfo.add(new SCM_MF_Drug(selectedCase)); 

        // Attn
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(selectedCase.Case_Treating_Physician_gne__r.Id));   
        
        // AddressedTo
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(selectedCase.Case_Treating_Physician_gne__r.Id));
                
        // Fax
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(selectedCase.Case_Treating_Physician_gne__r.Id));
             
        // Ext & From
        if (selectedCase.RecordType.Name.equals('C&R - Standard Case') || selectedCase.RecordType.Name.equals('C&R - Continuous Care Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (selectedCase.RecordType.Name.equals('GATCF - Standard Case')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));
        }

        // Current Date
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
                
        // Patient name
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.patient_gne__r.Id));

        // Patient DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.patient_gne__r.Id));
        
        // Privacy Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
        
        // Confidentiality Notice
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));

        // Referral Date
        this.mergeRecipientInfo.add(SCM_MF_ReferralFieldFactory.ReferredDate(selectedCase));

        // Second page
        this.mergeFields.add(new SCM_MF_Comments());
        
        //AccessSolutions
        this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
        
        // Confidentiality Notice box
        
        SCM_MergeSection ConfidentialityNoticeMergeSection = new SCM_MergeSection();
        ConfidentialityNoticeMergeSection.key = 'LucentisFooter';
        ConfidentialityNoticeMergeSection.visible = (selectedCase.Product_gne__c.ToLowerCase() == 'lucentis') ? true : false;

        this.mergeSections.add(ConfidentialityNoticeMergeSection);
        
    } 
}