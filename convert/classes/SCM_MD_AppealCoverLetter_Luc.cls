/********************************************************************/
    // Recreated By      : Sridhar
    // Document Name     : LUC-CMGT-FAX-59b_Appeal_Cover_Letter_Luc
    // Type              : System Document
    // Word Template     : Appeal_Cover_Letter_Pat_Luc.doc   
    // Label in SF       : Appeal Cover Letter Pat Luc
    
/********************************************************************/
public class SCM_MD_AppealCoverLetter_Luc extends SCM_MergeDocument
{
    protected String patientIdLocal;
    protected String PhysicianId;
     
    public SCM_MD_AppealCoverLetter_Luc(String caseId, String argLookupId)
    {
        super(caseId, argLookupId);
        setRequireSystemDocUI(true); 
    }
         
    public override void createMergeFields() 
    {
        patientIdLocal = selectedCase.Patient_gne__r.Id; 
        PhysicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
        
        SCM_MF_PatientId patId = new SCM_MF_PatientId(selectedCase);
        this.mergeRecipientInfo.add(patId);
        
        
        // caseId
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
        
        //2.CR_Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        //3. CR_Fax        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
          
        //4. CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));        
        
        //5. Current Date Long key:'DateLong'
        this.mergeRecipientInfo.add(new SCM_MF_DateLong());
        
        //PatientFullName(key Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patientIdLocal)); 
       
        try {
        //7.PatientStAddresss
        this.mergeRecipientInfo.add(new SCM_MF_PatientAddress_Lucient(patientIdLocal));
        } catch (Exception ex) { SCM_LogError.sendEmail(ex,'PatientStAddresss');}
        
        try {
        //8.PatientCityStateZip         
        this.mergeRecipientInfo.add(new SCM_MF_PatientCityStateZip1(patientIdLocal));
        } catch (Exception ex) { SCM_LogError.sendEmail(ex,'PatientCityStateZip');}
        
        try {
        //9.PatientHomePhone
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.Patient_Home_Phone(patientIdLocal));
        } catch (Exception ex) { SCM_LogError.sendEmail(ex,'PatientHomePhone');}
        
        //10.PayorAppealContact
        this.mergeRecipientInfo.add(new  SCM_MF_PayorAppealContact(selectedCase.Id));
      
        //11.PhysicianLastName
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianLastName(PhysicianId));
     
        //12 DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(PatientIdLocal));
        
        //13 Comments        
        this.mergeFields.add(new SCM_MF_Comments());
        
        // 14.AppealSpecialist
        this.mergeRecipientInfo.add(new SCM_MF_AppealSpecialistCollection(selectedCase.Id));
        
    }
}