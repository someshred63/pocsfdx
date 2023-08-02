/****************************************************************************/    
    // Developer Name    : Shobha Rawat
    // Document Name     : RAP-CMGT-FAX-46A Family Intro Letter final
    // PRODUCT GROUP     : DERMATOLOGY/RAPTIVA
    // Type              : System Document
    // Word Template     : Family Intro Letter final.doc   
    // Label in SF       : Family Intro Letter final
/****************************************************************************/     
public class SCM_MD_FamilyIntroLetterFinal_Rap extends SCM_MergeDocument {
    public SCM_MD_FamilyIntroLetterFinal_Rap(String caseID,String argLookupID) {
        super(caseId, argLookupID);
    }

    public override void createMergeFields()  {
        string patientId = selectedCase.Patient_gne__c;
        String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
        
        //Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));

        //Patient Id              
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        //DateLong
        this.mergeRecipientInfo.add(new SCM_MF_DateLong());
        
        //CR_PhoneShort
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
        
        //CR_Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        //CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
        //AgeBasedFullName
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedFullName(patientId));
        
        //AgeBasedStAddress
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedStAddress(patientId));
        
        //AgeBasedCityStateZip(AgeBasedCityStateZip)
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedCityStateZip(patientId));
        
        //PhysicianLastName(Physician Last Name)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianLastName(physicianId));
        
        //ConfidNotice
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        
        //Mail Stop
        this.mergeRecipientInfo.add(new SCM_MF_MailStop(selectedCase));
    }   

}