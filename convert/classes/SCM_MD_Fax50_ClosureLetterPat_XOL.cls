/********************************************************************/
    // Developer Name    : Vishwanath
    // Document Name     : XOL-CMGT-FAX-49 Closure Letter for MD final
    // PRODUCT GROUP     : Xolair
    // Type              : System document
    // Word Template     : Closure Letter For MD_Xol  
    // Label in SF       : Closure Letter For MD
    
/********************************************************************/

 
public class SCM_MD_Fax50_ClosureLetterPat_XOL extends SCM_MergeDocument
 {
 	   
 
public SCM_MD_Fax50_ClosureLetterPat_XOL(String caseId, String argLookupId)

    {
        super(caseId, argLookupId);
    }

    public override void createMergeFields()
     {
     	String patientNumber = selectedCase.Patient_gne__r.Patient_Id_gne__c;
     	String patId = selectedCase.Patient_gne__r.Id;
     	String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
     	String caseRecordType = selectedCase.RecordType.Name;
     	
     	//Case Number (Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));   
        
        //Cr_Phone (CR_Phone)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        //Cr_Fax (CR_Fax)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        //Cr_URL (CR_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
        //DateLong - (DateLong)
        this.mergeRecipientInfo.add(new SCM_MF_DateLong());
     	
     	//AgeBasedFullName(AgeBasedFullName)
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedFullName(patId));
        
        //AgeBasedStAddress(AgeBasedStAddress)
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedStAddress(patId));
        
        //AgeBasedCityStateZip(AgeBasedCityStateZip)
        this.mergeRecipientInfo.add(SCM_MF_AgeBasedFactory.AgeBasedCityStateZip(patId));
       	
       	//Patient Full name - (Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
        
        //Physicain Last Name - (Physician First Last Name)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(physicianId));
        
       //3 CaseWorker(From)        
        caseRecordType = selectedCase.RecordType.Name ;
        caseRecordType = (caseRecordType == null)? '': caseRecordType;
        if(caseRecordType.equalsIgnoreCase('C&R - Continuous Care Case') || caseRecordType.equalsIgnoreCase('C&R - Standard Case')) 
        { 
        this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
         
        }        
        if(caseRecordType.equalsIgnoreCase('GATCF - Standard Case')) 
        {
         this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
        }
        this.mergeimages.add(new SCM_MI_LOGO(selectedCase));
  		this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
  		this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
  		this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedCase));
  		this.mergeRecipientInfo.add(new SCM_MF_XolairPlus(selectedCase.Product_gne__c));
  		 
  		this.mergeRecipientInfo.add(new SCM_MF_Product_ScientificName(selectedCase));	      
        //Confide notice - (ConfidNotice)
         this.mergeFields.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));        
    
       	
     }
 }