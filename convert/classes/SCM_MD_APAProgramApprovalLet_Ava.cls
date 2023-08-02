/***********************************************************************************/
    // Developer Name    : Deepak Yadav
    // Document Name     : Final AVA-CMGT-FAX-67_APA_Program_Approval_Letter.doc    
    // PRODUCT GROUP     : Oncology / Avastin
    // Type              : System Document
    // Word Template     : APAProgramApprovalLetter_Avastin.doc     
    // Label in SF       : APA Program Approval Letter
    
/***********************************************************************************/
public class SCM_MD_APAProgramApprovalLet_Ava extends SCM_MergeDocument {
        
    private String caseRecordType;
        
    public SCM_MD_APAProgramApprovalLet_Ava(String caseID, String argLookupId) {
        super(caseID, argLookupId);  
    }
    
    public override void createMergeFields() {
        // 0 Case Number
        //key  =Case_Number
        SCM_MF_CaseNumber caseNumber = new SCM_MF_CaseNumber(selectedCase);     
        this.mergeRecipientInfo.add(caseNumber);          
         
        // 1 Patient Number
        SCM_MF_PatientId patientID = new SCM_MF_PatientId(selectedCase);
        this.mergeRecipientInfo.add(patientId);
        
        //2 Avastin Fax
        // key = CR_Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        //3 Avastin Phone
        // key = CR_Phone  
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        // 4 Current Date
        // key = Current_Date
        //Date Long
        this.mergeRecipientInfo.add(new SCM_MF_DateLong());
      
        // 5 case worker 
        caseRecordType = selectedCase.RecordType.Name ;
        caseRecordType = (caseRecordType == null)? '': caseRecordType;
        if (caseRecordType.startsWith('C&R')) {
        	this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
        }
        else if (caseRecordType.startsWith('GATCF')) {
        	this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
        }
        
        /**
        caseRecordType = selectedCase.RecordType.Name ;
        caseRecordType = (caseRecordType == null)? '': caseRecordType;
        if(caseRecordType.equalsIgnoreCase('C&R - Continuous Care Case') || 
            caseRecordType.equalsIgnoreCase('C&R - Standard Case')) {
            // 5 case worker    
            SCM_MF_CaseMangFirstAndLastName casMang = 
                new SCM_MF_CaseMangFirstAndLastName(selectedCase.Case_Manager__r.Id);
            string casMangVal = casMang.getFieldValue();
            casMangVal = casMangVal.replace('&','');
            casMangVal = casMangVal.replace('?','');
            casMang.fieldValue = casMangVal;
            casMang.key = 'Case worker';
            this.mergeRecipientInfo.add(casMang);
            
        }
        
        if(caseRecordType.equalsIgnoreCase('GATCF - Standard Case')) {
            // 5 case worker
            SCM_MF_FoundationSplName foundSpl=
                new SCM_MF_FoundationSplName(selectedCase.Foundation_Specialist_gne__r.Id);
            string foundSplVal = foundSpl.getFieldValue();          
            foundSplVal = foundSplVal.replace('&','');
            foundSplVal = foundSplVal.replace('?','');
            foundSpl.fieldValue = foundSplVal;
            foundSpl.key = 'Case worker';
            this.mergeRecipientInfo.add(foundSpl);
        }
        */
        
        // 6 Patient Full Name
        //key = Patient_First_And_Last_Name
        /**
        SCM_MF_PatientFirstAndLastName patFullName =
                                new SCM_MF_PatientFirstAndLastName(selectedCase);
        String patFullNameVal = patFullName.getFieldValue();
        patFullName.fieldValue = patFullNameVal ;
        this.mergeRecipientInfo.add(patFullName);
    	*/
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.patient_gne__r.Id) );
	
        
         //7 Physician Street Address
        // key = PhysicianStreetAddrs
        /**
        SCM_MF_PhysicianStreetAddress PhyStrtAddress = new SCM_MF_PhysicianStreetAddress(selectedCase);
        String PhyStrtAddressVal = PhyStrtAddress.getFieldValue();
        PhyStrtAddress.fieldValue = PhyStrtAddressVal ;                         
        this.mergeRecipientInfo.add(PhyStrtAddress);
      	*/
		this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));
	
        
        //8 Physician city State Zip
        // key = Physician City State and Zip
       /**
        SCM_MF_PhysicianCityStateZip cityStateZip =
             new SCM_MF_PhysicianCityStateZip(selectedCase.Case_Treating_Physician_gne__r.Id, 
             selectedCase.Address_gne__r.Id) ;
        String cityStateZipVal = cityStateZip.getFieldValue();
        cityStateZip.fieldValue = cityStateZipVal ;                         
        this.mergeRecipientInfo.add(cityStateZip);
  		*/
     	this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));
	
        
        //9 Physician Full Name
        // key = Physician First Last Name
        /**
        SCM_MF_PhysicianFirstLastName physicianFullName = 
            new SCM_MF_PhysicianFirstLastName(selectedCase.Case_Treating_Physician_gne__r.Id);
        String physicianFullNameVal = physicianFullName.getFieldValue();
        physicianFullName.fieldValue = physicianFullNameVal ;                         
        this.mergeRecipientInfo.add(physicianFullName);
        */
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(selectedCase.Case_Treating_Physician_gne__r.Id));
   
        // 10 PhysicianTitle
        // key = Physician Title
        /**
        SCM_MF_PhysicianTitle physicianTitle = 
            new SCM_MF_PhysicianTitle(selectedCase.Case_Treating_Physician_gne__r.Id);
        String physicianTitleVal = physicianTitle.getFieldValue();
        physicianTitle.fieldValue = physicianTitleVal ;                         
        this.mergeRecipientInfo.add(physicianTitle);            
    	*/
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianTitle(selectedCase.Case_Treating_Physician_gne__r.Id));
   
    }
}