/********************************************************************/
    // Developer Name    : Sanat Gersappa
    // Document Name     : LUC-CMGT-FAX-51b GATCF Approval Form Patient
    // PRODUCT GROUP     : LUCENTIS
    // Type              : System Document
    // Word Template     : GATCFApprovalFormPat.doc   
    // Label in SF       : GATCFApprovalFormPat
/********************************************************************/
public class SCM_MD_GATCFApprovalPat_Luc extends SCM_MergeDocument {
    public SCM_MD_GATCFApprovalPat_Luc(String caseID,String argLookupID) {
        super(caseId, argLookupID);
    }

    public override void createMergeFields() {
        String patId = selectedCase.Patient_gne__r.Id;
        String phyId = selectedCase.Case_Treating_Physician_gne__r.Id;
        String recordType = selectedCase.RecordType.Name;
        
        //Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
        
        // Patient Id - for metadata
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));

        //LUC_GATCF_Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
        
        //LUC_GATCF_Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
         
        //Current Date
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());

        //AgeBasedFullName
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedFullName(patId));
        
        //AgeBasedStAddress
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedStAddress(patId));
        
        //AgeBasedCityStateZip
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedCityStateZip(patId));

        //Patient Full Name
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patId));

        //Mail Stop
         this.mergeRecipientInfo.add(new SCM_MF_MailStop(selectedCase));
         
        //Case Worker
        if (recordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
        }
    }
}