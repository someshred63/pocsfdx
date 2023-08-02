/********************************************************************/
    // Developer Name    : Shobha Rawat
    // Document Name     : Consolidated NUT-PUL-XOL-RAP-RA CMGT-FAX-64 GATCF Denial Spanish final
    // Type              : System Document
    // Word Template     : CMGT-FAX-64-GTCF-DenialSpanish-NUTPULXOLRAPRA.doc    
    // Label in SF       : GATCF Denial Spanish
     
/********************************************************************/

public class SCM_MD_GATCF_DenSpa_PulNutRapRaXol extends SCM_MergeDocument{
     public SCM_MD_GATCF_DenSpa_PulNutRapRaXol(String caseID,String argLookupID) {
        super(caseId, argLookupID);
    }

    public override void createMergeFields()  {
        string pid = selectedCase.Patient_gne__c;
        String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
        
        // 0 Case Number(Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));   
        
        // 1 Patient Number(Patient Id)
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase)); 
        
        // 2 CurrentDate(Current_Date)
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());        
            
        // 3 GATCF_Phone (GATCF_Phone)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
          
        // 4 GATCF_Fax (GATCF_Fax)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
        
        //5. FullName(AgeBasedFullName)
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedFullName(pid) );
        
        //6. AgeBasedSt(AgeBasedStAddress)
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedStAddress(pid) );
        
        //7. AgeBasedCityStateZip(AgeBasedCityStateZip)
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedCityStateZip(pid) );
        
        // 8 Patient Full Name(Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(pid) );
       
        // 9 Product Name(Product)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
        
        // 10 ProdScientific (ProdScientific)
        this.mergeRecipientInfo.add(new SCM_MF_Product_ScientificName(selectedCase) );
        
        //11.Case Worker(caseworker)
        this.mergeRecipientInfo.add(new SCM_MF_CaseWorker(selectedCase)); 
        
        //12 GATCF_DisclaimerS(GATCF Disclaimer)
        this.mergeRecipientInfo.add(new SCM_MF_GATCFDisclaimerSp());
        
        this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedCase));
        
        //Mail Stop
        this.mergeRecipientInfo.add(new SCM_MF_MailStop(selectedCase));
    }
}