//Added: Paras Sharma
//Document: CMGT-FAX-01 - GATCF Tab - Information / Documentation Retrieval
//Lucentis
            
public class SCM_MD_Fax_GATCFTabInfoDocRet_Luc extends SCM_MergeDocument implements IStandardComboBox {

    protected String caseId;
    protected String PatientId;
    protected String PhysicianId;
    
    public SCM_MD_Fax_GATCFTabInfoDocRet_Luc(String caseID, String argLookupId) {
            super(caseID, argLookupId);
            caseId = caseID;
        }
        
    public override void createMergeFields() {
       
         PhysicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
         PatientId = selectedCase.patient_gne__r.id;
         String recordType = selectedCase.RecordType.Name;
         
         //ATTN:
         this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(PhysicianId));    
        
        // Addressed To        
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(PhysicianId));
        
        // Fax No
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(PhysicianId));

        // Case Number
        SCM_MF_CaseNumber casNum = new SCM_MF_CaseNumber(selectedCase);
        this.mergeRecipientInfo.add(casNum);
        
        // Patient Id
        SCM_MF_PatientId patId = new SCM_MF_PatientId(selectedCase);
        this.mergeRecipientInfo.add(patId);
        
        //Ext & From
        if (recordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));
        }
         
        // Date
        SCM_MF_CurrentDate curDate = new SCM_MF_CurrentDate();
        this.mergeRecipientInfo.add(curDate);
        
        // PatientFullName
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(PatientId));
         
        // DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(PatientId));
        
        //3.GATCF_Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
        
        //4. GATCF_Fax        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
          
        //5. GATCF_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_GATCF(selectedCase)); 
        
        // PrivacyNotice 
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
        
        
        /////////-------Second Screen ------
        this.mergeFields.add(new SCM_MFG_AdditionalInfoReq_Luc());
        
        SCM_MF_Comments  comments = new SCM_MF_Comments();
        this.mergeFields.add(comments);
    
    }
}