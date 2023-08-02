// Created  By: Reji Joseph
// Doc Name: System Document
// PRODUCT GROUP: OPTHALMOLOGY
// LUC-CMGT-FAX-59a Appeal Cover Letter MD
 
public class SCM_MD_ACL_MD_Luc extends SCM_MergeDocument{

    protected String patientIdLocal;
    protected String cseId;
    protected String physId;
    
    public SCM_MD_ACL_MD_Luc(String caseId, String argLookupId)
    { 
        super(caseId,argLookupId);
        setRequireSystemDocUI(true);             
    }
    
    public override void createMergeFields()
    {   
        patientIdLocal = selectedCase.Patient_gne__r.Id;   
       
        //1. Case Number (CaseID) 
 
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 

   		//-------------------------------------------------------------------------------------------
        //2. CR Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
     
        //-------------------------------------------------------------------------------------------    
        //3. CR Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        //-------------------------------------------------------------------------------------------         
        //4. URL		
		this.mergeRecipientInfo.add(new SCM_MF_Product_URL_GATCF(selectedCase));  

        //-------------------------------------------------------------------------------------------
        //5. Current Date Long key:'DateLong'
        this.mergeRecipientInfo.add(new SCM_MF_DateLong());

        //-----------------------------------------------------------------------------------------
        //Get Case.RecordType
        String CaseType = selectedCase.RecordType.Name;

        //-----------------------------------------------------------------------------------------
        //6. Physician Contact Full Name (key:'PhysContactFullName')
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFullName(selectedCase) );
        
        //-----------------------------------------------------------------------------------------
        //7. Physician Full Name     
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(selectedCase.Case_Treating_Physician_gne__r.Id));   
        
        //-----------------------------------------------------------------------------------------
        //8. Physician Last Name (key:'Physician Last Name')
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianLastName(selectedCase.Case_Treating_Physician_gne__r.Id));   

        //-----------------------------------------------------------------------------------------
        //9. Physician Title
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianTitle(selectedCase.Case_Treating_Physician_gne__r.Id));      

        //-----------------------------------------------------------------------------------------
        //10. Physician StAddress key:'PhysicianStreetAddrs'
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));       
     
        //-----------------------------------------------------------------------------------------
        //11. Physician CityStateZip
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));

        //-----------------------------------------------------------------------------------------
        //12. Physician Phone (key 'Phy_Ph') 
        //this.mergeRecipientInfo.add( new SCM_MF_PhysicianPhoneSMN_Luc(selectedCase.Case_Treating_Physician_gne__r.Id, CaseType));
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase)); 
        
        //-----------------------------------------------------------------------------------------
        //13 PatientFullName
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.patient_gne__r.id));
         
        //-----------------------------------------------------------------------------------------
        //14. Patient DOB        
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.patient_gne__r.id));
        
        
        //-----------------------------------------------------------------------------------------
        //15. Comments        
        this.mergeFields.add(new SCM_MF_Comments()); 

        //-----------------------------------------------------------------------------------------
        //16. AppealSpecilist
        this.mergeRecipientInfo.add(new SCM_MF_AppealSpecialistCollection(selectedCase.Id));
        
    }
  
}