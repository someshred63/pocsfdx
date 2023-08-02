public virtual class SCM_MD_Standard extends SCM_MergeDocument {

    public SCM_MD_Standard(String caseID, String argLookupId) {
        super(caseID, argLookupId);
    }
    
    public virtual override void createMergeFields() {
        // Case_Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
        
        // Patient Id
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));

        // CR_Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        // CR_PhoneShort
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(selectedCase));
    
        // CR_Fax        
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
          
        // CR_URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase)); 

        // AccessSolutions
        this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
        
        // From 
        this.mergeRecipientInfo.add(new SCM_MF_FaxFrom(selectedCase, selectedCase.RecordType.Name));
        
        // Ext
        this.mergeRecipientInfo.add(new SCM_MF_FaxExtn(selectedCase, selectedCase.RecordType.Name)); 
        
        // Current_Date
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        // ConfidNotice
        this.mergeRecipientInfo.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));

        // caseworker
        this.mergeRecipientInfo.add(new SCM_MF_CaseWorker(selectedCase));
        
        // DateLong
        this.mergeRecipientInfo.add(new SCM_MF_DateLong());

        // ReferralCityStateZip
        this.mergeRecipientInfo.add(SCM_MF_ReferralFieldFactory.ReferralCityStateZip(selectedCase));
        
        // Patient_First_And_Last_Name
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
        
        // PatientFirstName
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstName(selectedCase.Patient_gne__r.Id));

        // Patient_DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.patient_gne__r.Id));

        // PatientAddressCityStateZip
        this.mergeRecipientInfo.add(new SCM_MF_PatAddressCityStateZip(selectedCase.patient_gne__r.Id));

        // PatientPrimeConFullName
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimaryConFullName(selectedCase.patient_gne__r.Id));

        // Relationship
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientRelationship(selectedCase.patient_gne__r.Id));
        
        // PatientPrimeConHmPh
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimeConHmPh(selectedCase.patient_gne__r.Id));

        // PatientPrimeConWkPh
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimeConHmPh(selectedCase.patient_gne__r.Id));

        // Physician First Last Name
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(selectedCase.Case_Treating_Physician_gne__r.Id));

        // PhysicianFullAddress
        this.mergeRecipientInfo.add(new SCM_MF_PhysicianFullAddress(selectedCase));

        // PhysicianStreetAddrs
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));

        // PhyCityStateZip
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));

        // PhysicianOfficePhone
        this.mergeRecipientInfo.add(new SCM_MF_PhysicianOfficePhone(selectedCase));

        // PhysicianOfficeFax
        this.mergeRecipientInfo.add(new SCM_MF_PhysicianOfficeFax(selectedCase));
        
        // PhysContactFullName
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFullName(selectedCase));

        // PhysContactPh
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(selectedCase));

        // PhysContactFax
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax(selectedCase));

        // FacilityName
        this.mergeRecipientInfo.add(new SCM_MF_FacilityName(selectedCase));

        // FacilityAddress
        this.mergeRecipientInfo.add(new SCM_MF_FacilityAddress(selectedCase));

        // FacilityContact
        this.mergeRecipientInfo.add(new SCM_MF_FacilityContact(selectedCase));

        // FacilityPhone
        this.mergeRecipientInfo.add(new SCM_MF_FacilityPhone(selectedCase));
        
        // FacilityFax
        this.mergeRecipientInfo.add(new SCM_MF_FacilityFax(selectedCase));
        
        // Product
        this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));
        
        // Drug
        this.mergeFields.add(new SCM_MF_Product_DrugName(selectedCase));
        
        // CommentField
        this.mergeFields.add(new SCM_MF_Comments());
    }
    
    //public override void getLatestValues()
    //{
    //}

}