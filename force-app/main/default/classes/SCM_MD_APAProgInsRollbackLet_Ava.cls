/********************************************************************/
    // Developer Name    : Deepak Yadav
    // Document Name     : Final AVA-CMGT-FAX-69_APA Program
    //                     Insurance Rollback Letter.doc
    // PRODUCT GROUP     : Oncology / Avastin
    // Type              : System Document
    // Word Template     : APAProgramInsuranceRollbackLetter_Acastin.doc    
    // Label in SF       : APA Program Insurance Rollback Letter
    
/********************************************************************/
public class SCM_MD_APAProgInsRollbackLet_Ava extends SCM_MergeDocument {
        
    private String caseRecordType;
        
    public SCM_MD_APAProgInsRollbackLet_Ava(String caseID, String argLookupId) {
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
        
        //2. CR_Phone
        this.mergeRecipientInfo.add( new SCM_MF_Product_Phone_CR(selectedCase));
        
        //3. CR_Fax
        this.mergeRecipientInfo.add( new SCM_MF_Product_Fax_CR(selectedCase));
      
        /**
        //2 Avastin Fax
        // key = GATCF_Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
        
        //3 Avastin Phone
        // key = GATCF_Phone 
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
        */
        // 4 Current Date
        // key = Current_Date
        SCM_MF_CurrentDate currentDate = new SCM_MF_CurrentDate();      
        this.mergeRecipientinfo.add(currentDate);
        
        //5 First Year Date of first Date
        // key = Frst Year Date Of Frst Treat
        SCM_MF_MedHistoryFrstYearDateOfFrstTreat frstTreatDate = 
            new  SCM_MF_MedHistoryFrstYearDateOfFrstTreat(selectedCase.Medical_History_gne__r.id);
        string frstTreatDateVal = frstTreatDate.getFieldValue();
        frstTreatDate.fieldValue = frstTreatDateVal ;
        this.mergeRecipientinfo.add(frstTreatDate);
        
        caseRecordType = selectedCase.RecordType.Name ;
        caseRecordType = (caseRecordType == null)? '': caseRecordType;
        if(caseRecordType.equalsIgnoreCase('C&R - Continuous Care Case') || 
            caseRecordType.equalsIgnoreCase('C&R - Standard Case')) {
            // 6 case worker    
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
            // 6 case worker
            SCM_MF_FoundationSplName foundSpl=
                new SCM_MF_FoundationSplName(selectedCase.Foundation_Specialist_gne__r.Id);
            string foundSplVal = foundSpl.getFieldValue();          
            foundSplVal = foundSplVal.replace('&','');
            foundSplVal = foundSplVal.replace('?','');
            foundSpl.fieldValue = foundSplVal;
            foundSpl.key = 'Case worker';
            this.mergeRecipientInfo.add(foundSpl);
        }
        
        // 7 Patient Full Name
        SCM_MF_PatientFirstAndLastName patFullName =
                                new SCM_MF_PatientFirstAndLastName(selectedCase);
        String patFullNameVal = patFullName.getFieldValue();
        patFullName.fieldValue = patFullNameVal ;  
        //key = Patient_First_And_Last_Name                       
        this.mergeRecipientInfo.add(patFullName);
        
        //8 Physician Street Address
        // key = PhysicianStreetAddrs
        SCM_MF_PhysicianStreetAddress PhyStrtAddress = new SCM_MF_PhysicianStreetAddress(selectedCase);
        String PhyStrtAddressVal = PhyStrtAddress.getFieldValue();
        PhyStrtAddress.fieldValue = PhyStrtAddressVal ;                         
        this.mergeRecipientInfo.add(PhyStrtAddress);
        
        //9 Physician city State Zip
        // key =Physician City State and Zip
        SCM_MF_PhysicianCityStateZip cityStateZip =
             new SCM_MF_PhysicianCityStateZip(selectedCase.Case_Treating_Physician_gne__r.Id, 
             selectedCase.Address_gne__r.Id) ;
        String cityStateZipVal = cityStateZip.getFieldValue();
        cityStateZip.fieldValue = cityStateZipVal ;                         
        this.mergeRecipientInfo.add(cityStateZip);
        
        //10 Physician Full Name
        // key = Physician First Last Name
        SCM_MF_PhysicianFirstLastName physicianFullName = 
            new SCM_MF_PhysicianFirstLastName(selectedCase.Case_Treating_Physician_gne__r.Id);
        String physicianFullNameVal = physicianFullName.getFieldValue();
        physicianFullName.fieldValue = physicianFullNameVal ;                         
        this.mergeRecipientInfo.add(physicianFullName);
        
    }
}