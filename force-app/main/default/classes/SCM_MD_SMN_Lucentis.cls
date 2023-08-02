// Created  By: Reji Joseph
// Document No: LUC-CMGT-FAX-38 SMN Form Analysis
 
public class SCM_MD_SMN_Lucentis extends SCM_MergeDocument{

    protected String patientIdLocal;
    protected String caseIdLocal;
    
    public SCM_MD_SMN_Lucentis(String caseId, String argLookupId)
    {
        super(caseId,argLookupId);   
    }
    
    public override void createMergeFields()
    {   
        //patientIdLocal = ;
        caseIdLocal = selectedCase.Id;

        try{
        
        //1. Case Number (CaseID)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase)); 
        
        this.mergeRecipientInfo.addall(SCM_MF_PatientFieldFactory.GetAllNames(selectedCase.Patient_gne__c)); 
        this.mergeRecipientInfo.addall(SCM_MF_Physician_FieldFactory.GetAllNames(selectedCase.Case_Treating_Physician_gne__c));
        this.mergeRecipientInfo.addall(SCM_MF_PatientAddressFactory.GetAll(selectedCase.Patient_gne__c));
        this.mergeRecipientInfo.addall(SCM_MF_PhysicianAddress_FieldFactory.GetAll(selectedcase.id));
        this.mergeRecipientInfo.addall(SCM_MF_PatientContact_FieldFactory.GetAllNames(selectedCase.Patient_gne__c));
        
        // adding this getting the details in the metadata
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
        
        //-------------------------------------------------------------------------------------------
        //2. CR Phone
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
     
        //-------------------------------------------------------------------------------------------    
        //3. CR Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        //-------------------------------------------------------------------------------------------         
        //4. URL
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
        
        }catch (Exception ex) {SCM_LogError.sendEmail(ex,'SCM_MD_SMN_Lucentis - Group 1');} try{
        
        //-------------------------------------------------------------------------------------------         
        //5. Patient Last Name
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientLastName(selectedCase.Patient_gne__r.Id));      
             
        //-----------------------------------------------------------------------------------------
        //6. Patient First Name
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstName(selectedCase.Patient_gne__r.Id));

        //-----------------------------------------------------------------------------------------
        //7. PatientStAddress1
        this.mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientAddressLine1(selectedCase.Patient_gne__r.Id));
        
        //-----------------------------------------------------------------------------------------
        //8. PatientCityStateZip
        mergeRecipientInfo.add(SCM_MF_PatientAddressFactory.PatientCityStateZip(selectedCase.Patient_gne__r.Id));

        //-----------------------------------------------------------------------------------------
        //9. Patient Home Phone
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientHomePhone(selectedCase.Patient_gne__r.Id));

        //9.5 Patient Work Phone
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientWorkPhone(selectedCase.Patient_gne__r.Id));

        //-----------------------------------------------------------------------------------------
        //10. Date of Birth (MM/DD/YR)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(selectedCase.Patient_gne__r.Id));        
        }catch (Exception ex) {SCM_LogError.sendEmail(ex,'SCM_MD_SMN_Lucentis - Group 2');} try{
        //11. Male
        mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientGenderCheckBoxMale(selectedCase.Patient_gne__r.Id));
        
        //-----------------------------------------------------------------------------------------
        //12. Female    
        mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientGenderCheckBoxFemale(selectedCase.Patient_gne__r.Id));
        
        //12.3 PatientPrimeConFullName
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimaryConFullName(selectedCase.Patient_gne__r.Id));
        
        //12.6 PatientPrimeConRelationship
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientRelationship(selectedCase.Patient_gne__r.Id));
        
        //12.7 PatientPrimeConHmPh
        this.mergeRecipientInfo.add(SCM_MF_PatientContact_FieldFactory.PatientPrimeConHmPh(selectedCase.Patient_gne__r.Id));
        
        }catch (Exception ex) {SCM_LogError.sendEmail(ex,'SCM_MD_SMN_Lucentis - Group 3');} try{
        
        //-----------------------------------------------------------------------------------------
        //13. Insurance Name SMN
        mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceNameSMN(selectedCase, '1'));
        
        //-----------------------------------------------------------------------------------------
        //14. Insurance Phone SMN
        mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsurancePhoneSMN(selectedCase, '1'));

        //-----------------------------------------------------------------------------------------
        //15. Subscriber Name SMN
        mergeRecipientInfo.add(SCM_MF_Insurance_Factory.SubscriberNameSMN(selectedCase, '1'));
        
        //-----------------------------------------------------------------------------------------
        //16. Subsriber ID SMN
        mergeRecipientInfo.add(SCM_MF_Insurance_Factory.SubscriberIDSMN(selectedCase, '1'));
        
        //-----------------------------------------------------------------------------------------
        //17. GroupNumbSMN
        mergeRecipientInfo.add(SCM_MF_Insurance_Factory.GroupNumSMN(selectedCase, '1'));
        
        //-----------------------------------------------------------------------------------------
        //18. Insurance Employer SMN
        mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceEmployerSMN(selectedCase, '1'));
        
        //-----------------------------------------------------------------------------------------
        //19. Insurance Name SMN
        mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceNameSMN(selectedCase, '2'));
        
        //-----------------------------------------------------------------------------------------
        //20. Insurance Phone SMN
        mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsurancePhoneSMN(selectedCase, '2'));

        //-----------------------------------------------------------------------------------------
        //21. Subscriber Name SMN
        mergeRecipientInfo.add(SCM_MF_Insurance_Factory.SubscriberNameSMN(selectedCase, '2'));
        
        //-----------------------------------------------------------------------------------------
        //22. Subsriber ID SMN
        mergeRecipientInfo.add(SCM_MF_Insurance_Factory.SubscriberIDSMN(selectedCase, '2'));
        
        //-----------------------------------------------------------------------------------------
        //23. GroupNumbSMN
        mergeRecipientInfo.add(SCM_MF_Insurance_Factory.GroupNumSMN(selectedCase, '2'));
        
        //-----------------------------------------------------------------------------------------
        //24. Insurance Employer SMN
        mergeRecipientInfo.add(SCM_MF_Insurance_Factory.InsuranceEmployerSMN(selectedCase, '2'));
        
        }catch (Exception ex) {SCM_LogError.sendEmail(ex,'SCM_MD_SMN_Lucentis - Group 4');} try{
        
        //-----------------------------------------------------------------------------------------
        //25. Physician Full Name
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        //-----------------------------------------------------------------------------------------
        //26. Physician DEA#
        this.mergeRecipientInfo.add(new SCM_MF_PhysicianDEA(selectedCase.Case_Treating_Physician_gne__r.Id));

        //-----------------------------------------------------------------------------------------
        //27. Physician Tax ID
        this.mergeRecipientInfo.add(new SCM_MF_PhysicianProfileTax(selectedCase.Case_Treating_Physician_gne__r.Id));
        
        }catch (Exception ex) {SCM_LogError.sendEmail(ex,'SCM_MD_SMN_Lucentis - Group 5');} try{
        
        //-----------------------------------------------------------------------------------------
        //28. Physician StAddress
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_Street(selectedcase.id));

        //-----------------------------------------------------------------------------------------
        //29. Physician CityStateZip
        this.mergeRecipientInfo.add(SCM_MF_PhysicianAddress_FieldFactory.PhysicianAddress_CityStateZip(selectedcase.id));

        //-----------------------------------------------------------------------------------------
        //30. Physician Phone 
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactPhone(SelectedCase));

        //-----------------------------------------------------------------------------------------
        //31. Physician Fax
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFax(SelectedCase));

        //-----------------------------------------------------------------------------------------
        //32. Physician Full Name
        this.mergeRecipientInfo.add(SCM_MF_PhysicianContactFactory.PhysicianContactFullName(SelectedCase));
        
        }catch (Exception ex) {SCM_LogError.sendEmail(ex,'SCM_MD_SMN_Lucentis - Group 6');}try{

        //-----------------------------------------------------------------------------------------
        //33. Physician License Id
        this.mergeRecipientInfo.add(new SCM_MF_PhysicianLicenceID(selectedCase));

        //-----------------------------------------------------------------------------------------
        //34. ProviderNPI
        this.mergeRecipientInfo.add(new SCM_MF_ProviderNPI(selectedCase.Case_Treating_Physician_gne__r.Id));

        //-----------------------------------------------------------------------------------------
        //35. FacilityNPI
        this.mergeRecipientInfo.add(new SCM_MF_FacilityNPI(selectedCase));
        
        }catch (Exception ex) {SCM_LogError.sendEmail(ex,'SCM_MD_SMN_Lucentis - Group 7');} 
    }  
}