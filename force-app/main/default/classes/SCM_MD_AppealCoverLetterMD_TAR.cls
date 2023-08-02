/********************************************************************/
    // Developer Name    : Prabha
    // Document Name     : TAR-CMGT-FAX-59A_-_Appeal_Cover_Letter_MD.doc
    // PRODUCT GROUP     : Oncology / Tarceva
    // Type              : System Document
    // Word Template     : AppealCoverLetter_MD_TAR.doc    
    // Label in SF       : AppealCoverLetterMD_TAR
    
/********************************************************************/

public class SCM_MD_AppealCoverLetterMD_TAR extends SCM_MergeDocument 
{
public SCM_MD_AppealCoverLetterMD_TAR(String caseId, String argLookupId) {
        super(caseId, argLookupId);
        setRequireSystemDocUI(true);
    }
    
    public override void createMergeFields() {
        String patientId = selectedCase.patient_gne__r.Id;
        String caseId= selectedCase.caseNumber;
        String phyId = selectedCase.Case_Treating_Physician_gne__r.Id;
        
         // caseId
         this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
      
         //CR_Phone (key = CR_Phone)
         this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
     
         //CR_Fax (key = CR_Fax)
         this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
     
         //DateLong(DateLong)
         this.mergeRecipientInfo.add(new SCM_MF_DateLong()); 

        //5.PhysContactFullName  key = PhysContactFullName
         this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFullName(selectedCase));    
         //this.mergeRecipientInfo.add(new SCM_MF_PhysicianContact_FullName(selectedCase));
                
        //5.PhysicianFullName // KEY = Physician First Last Name
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(phyId));
        //this.mergeRecipientInfo.add(new SCM_MF_PhysicianFirstLastName(phyId));

        //6.PhysicianLastName //KEY = Physician Last Name 
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianLastName(phyId));
        //this.mergeRecipientInfo.add(new SCM_MF_PhysicianLastName(phyId));

        //7. Physician Title key = PhysicianTitle
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianTitle(phyId)); 
        //this.mergeRecipientInfo.add(new SCM_MF_Physician_Title(phyId));  

        //8. PhysicianStAddress key = Physician Street Address SCM_MF_PhysicianAddress_FieldFactory
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));
        //this.mergeRecipientInfo.add(new SCM_MF_PhysicianStAddress(phyId));

        //9. PhysicianCityStateZip key = Physician City State and Zip
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));
        //this.mergeRecipientInfo.add(new SCM_MF_PhysicianCityStateZip(phyId));

        //10.PhysContactPh key = PhysContactPh
        //this.mergeRecipientInfo.add(new SCM_MF_PhysicianConatcPhone(selectedCase));
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase));   
        
        //11.PatientFullName key = Patient_First_And_Last_Name
         this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patientId));
            
        //13.AppealSpecialist key = AppealSpecialist
        this.mergeRecipientInfo.add(new SCM_MF_AppealSpecialistCollection(selectedCase.Id));
            
        //UI_Comments
        this.mergeFields.add(new SCM_MF_Comments());
        
         this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedcase.Product_gne__c));
		this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedcase));         
         this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patientId));
        
        this.mergeImages.add(new SCM_MI_Logo(SelectedCase));


    }
}