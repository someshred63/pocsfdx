public class SCM_MD_Fax_GATCFAppFormMD_Luc extends SCM_MergeDocument {
    public SCM_MD_Fax_GATCFAppFormMD_Luc(String caseId, String argLookupId) {
        super(caseId, argLookupId);
    }

    public override void createMergeFields() {
        String phyId = selectedCase.Case_Treating_Physician_gne__r.Id;
        String patientId = selectedCase.patient_gne__r.Id;
        
        //Case Number
        SCM_MF_CaseNumber caseNumber = new SCM_MF_CaseNumber(selectedCase);
        mergeRecipientInfo.add(caseNumber);
        
        // Patient Id - for metadata
        SCM_MF_PatientId patId = new SCM_MF_PatientId(selectedCase);
        this.mergeRecipientInfo.add(patId); 

        //GATCF_Phone
        mergeRecipientInfo.add(new SCM_MF_Product_Phone_GATCF(selectedCase));
        
        //GATCF_Fax
        mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
         
        //Current Date
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        this.mergeRecipientInfo.add(new SCM_MF_DateLong());

        //Physician Full Name
        //SCM_MF_PhysicianFirstMidAndLastName phyFullName = new SCM_MF_PhysicianFirstMidAndLastName(phyId);
        //phyFullName.key = 'PhysicianFullName';
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstMidAndLastName_Invisible(phyId));
        
        //Physician Street Address
        //SCM_MF_PhysicianStreetAddress phyStreetAddrs = new SCM_MF_PhysicianStreetAddress(selectedCase);
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));
        
        //Physician City State Zip
        //SCM_MF_PhysicianCityStateZip phyCityStateZip = new SCM_MF_PhysicianCityStateZip(phyId);
        //phyCityStateZip.key = 'PhysicianCityStateZip';
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));
        
        //PhysContactFax
       // SCM_MF_PhysicianContactFax phyContFax = 
       //     new SCM_MF_PhysicianContactFax(selectedCase.Case_Treating_Physician_gne__r.Id);
       // phyContFax.label='Fax:';
       // phyContFax.setKey('PhysicianFax');
       // string phyContFaxVal = phyContFax.getFieldValue();
       // phyContFax.setFieldValue(phyContFaxVal);        
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax(selectedCase));
        
        //Patient Full Name
        //SCM_MF_PatientFirstAndLastName patientFirstAndLastName = 
        //    new SCM_MF_PatientFirstAndLastName(selectedCase);
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstMiddleAndLastName(patientId));
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patientId));

        //Ship Detail
        //SCM_MF_ShipDetail shipDetail = new SCM_MF_ShipDetail(selectedCase);
        //this.mergeRecipientInfo.add(shipDetail);
        
         this.mergeRecipientInfo.add(SCM_MF_ShipmentDetail_FieldFactory.DocumentNumber(selectedCase));  
         this.mergeRecipientInfo.add(SCM_MF_ShipmentDetail_FieldFactory.PurchaseNumber(selectedCase));            
        //Case Worker
        //Get Case.RecordType
        String recordType = selectedCase.RecordType.Name;
              
        //Case Worker

        if (recordType.equals('C&R - Standard Case') || recordType.equals('C&R - Continuous Care Case')) {
            SCM_MergeField caseMangName=SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id);
            caseMangName.displayTextBox = false;
            caseMangName.displayLabel = false;
            this.mergeRecipientInfo.add(caseMangName);
         
        }
        else if (recordType.equals('GATCF - Standard Case')) {
            SCM_MergeField caseMangName=SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id);
            caseMangName.displayTextBox = false;
            caseMangName.displayLabel = false;
            this.mergeRecipientInfo.add(caseMangName);
           
        }  
 
         //Mail Stop
         this.mergeRecipientInfo.add(new SCM_MF_MailStop(selectedCase));       
        
        this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedCase));
        this.mergeRecipientInfo.add(new SCM_MF_Product_DrugType(selectedCase));
        this.mergeRecipientInfo.add(new SCM_MF_Product_ScientificName(selectedCase));
        this.mergeRecipientInfo.add(new SCM_MF_Product_Name(selectedCase));        
         
    }
}