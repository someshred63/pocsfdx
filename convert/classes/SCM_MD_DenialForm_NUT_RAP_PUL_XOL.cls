/********************************************************************/
    // Developer Name    : Prabha
    // Document Name     : NUT - XOL - RAP - PUL - CMGT-FAX-52 - GATCF Denial Form.doc
    // PRODUCT GROUP     : Used for Growth Hormone / Nutropin, Raptiva, Pulmozyme, Xolair
    // Type              : System Document
    // Word Template     : GATCF Denial Form.doc    
    // Label in SF       : DenialForm 
    
/********************************************************************/

public class SCM_MD_DenialForm_NUT_RAP_PUL_XOL extends SCM_MergeDocument
{
       public SCM_MD_DenialForm_NUT_RAP_PUL_XOL(String caseId, String argLookupId) {
        super(caseId, argLookupId);
       }
    
    public override void createMergeFields() {
        String patientId = selectedCase.patient_gne__r.Id;
        String caseId= selectedCase.caseNumber;
        String phyId = selectedCase.Case_Treating_Physician_gne__c;
        
        //1. Case Number
        mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
        
        //2. GATCF_Phone 
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));   

        //3. GATCF_Fax 
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));   

        //4. DateShort 
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
         //5.Drug 
        this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedCase));
        
        //6.Product
        this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
        
         //7.SCM_MF_Product_ScientificName(selectedCase),'ProdScientific'
        this.mergeRecipientInfo.add(new SCM_MF_Product_ScientificName(selectedCase));
                
         //8.AgeBasedFullName
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedFullName(patientId));
        
        //9.AgeBasedStAddress
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedStAddress(patientId));
        
        //10.AgeBasedCityStateZip
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedCityStateZip(patientId));

        //Mail Stop
         this.mergeRecipientInfo.add(new SCM_MF_MailStop(selectedCase));
                                       
        //11. CaseWorker
        String recordType = selectedCase.RecordType.Name ;
        if (recordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
        }

    }
    

}