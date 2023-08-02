public without sharing class GNE_CM_deletion_page1 {
    public GNE_CM_Deletion_Wizard__c DW_object{get;set;} 
    private GNE_CM_Deletion_Wizard_Support Control = new GNE_CM_Deletion_Wizard_Support();
    public Boolean pageflag{get;set;}

    List<String> childobjectupdate;
    /*public boolean disabledeleteval{get;set;}
    public boolean disablecancelval{get;set;}
    public boolean disabletext{get;set;}*/
    
    //public List<wrapperclass> wrappervariable {get;set;}
    public GNE_CM_deletion_page1(ApexPages.StandardController controller)  {
    	DW_object = (GNE_CM_Deletion_Wizard__c)controller.getRecord();
    }
    
    public boolean getflagcheck() {
        pageflag = ApexPages.hasMessages(ApexPages.Severity.warning);
        return pageflag ;  
    }
    
    public boolean getbacktomainpage() {
        pageflag = ApexPages.hasMessages(ApexPages.Severity.info);
        return pageflag ; 
    }
    
    public pagereference donothing() {
        /*disabledeleteval = false;
        disablecancelval = false;
        disabletext      = false; */
        control.finallistforpage.clear();
        pagereference page = Apexpages.currentpage();
        return page;
    }
    
    public pagereference homepage() {
        pagereference page = new pagereference('/home/home.jsp');
        return page;
    }
    
    public pagereference deletechild() {
        string exceptionvar;
        pagereference page ;
       
        childobjectupdate = control.finallistforpage; 
        control.deleteall(childobjectupdate);          
        exceptionvar = control.exceptionmessage;
        
        if(exceptionvar != null) {   
            page = new pagereference ('/apex/GNE_CM_Deltion_Exception');           
            page.setredirect(true);
            childobjectupdate.clear();
            return page;                  
        }  
        else {
            childobjectupdate.clear();
            /*disablecancelval = true;*/
            return null;
        }
    }
     
    public void deletemethod() {
        List<Id> patientIds = new List<Id>();
        List<patient_gne__c> PatientId = new List<patient_gne__c>();
        List<patient_address_gne__c> patientAddressId  = new List<patient_address_gne__c>();
        List<patient_contact_gne__c> PatientContactId  = new List<patient_contact_gne__c>();
        List<patient_program_gne__c> PatientProgramId  = new List<patient_program_gne__c>();
        List<Medical_history_gne__c> MedicalHistoryId  = new List<Medical_history_gne__c>();
        List<Case> CaseId = new List<Case>();
        List<Insurance_gne__c> InsuranceId = new List<Insurance_gne__c>();
        List<Shipment_gne__c> ShipmentId = new List<shipment_gne__c>();
        List<Benefit_Investigation_gne__c> BIId = new List<Benefit_Investigation_gne__c>();
        List<Prior_Authorization_gne__c> Priorauthlist = new List<Prior_Authorization_gne__c>();
        List<Fulfillment_gne__C> fulfillmentid = new List<Fulfillment_gne__C>();
        List<appeal_gne__c> AppealId = new List<appeal_gne__c>();
        List<appeal_level_gne__c> AppeallevelId = new List<appeal_level_gne__c>();
        List<GNE_CM_MPS_BRC_RituxanRA__c> BenefitReverificationId = new List<GNE_CM_MPS_BRC_RituxanRA__c>();
		List<GNE_CM_EBI_Request__c> eBIRequestId = new list <GNE_CM_EBI_Request__c>();
        List<GNE_CM_MPS_Practice_Agreement__c> practiceAgreementId = new List<GNE_CM_MPS_Practice_Agreement__c>();
        
        List<GNE_CM_Shipment_Monitoring_Email__c> shipmentMonitoringId = new List<GNE_CM_Shipment_Monitoring_Email__c>();
        
        String returnedsobject= DW_object.SObjects__c;
        String returnedid = DW_object.Id__c;
        
        patientId = [select Id,Patient_Id_gne__c,name  from Patient_gne__c where Patient_Id_gne__c =:returnedid  limit 1];
        patientAddressId = [select Id,Name from Patient_Address_gne__c where Name=:returnedid limit 1];
        PatientContactId = [select Id,Name from Patient_contact_gne__c where Name=:returnedid  limit 1];
        MedicalHistoryId = [select Id,Name from Medical_history_gne__c where Name=:returnedid  limit 1];
        CaseId = [select Id,CaseNumber from Case where CaseNumber =:returnedid  limit 1];
        BIId = [select id,name from benefit_investigation_gne__c where name =: returnedid  limit 1];
        InsuranceId = [select id,Name from Insurance_gne__c where Name=:returnedid  limit 1];
        ShipmentId = [select id,name from shipment_gne__c where name=: returnedid  limit 1];
        Priorauthlist = [select id,name from prior_authorization_gne__c where name =: returnedid  limit 1];
        PatientProgramId = [select id,name from patient_program_gne__c where name =: returnedid limit 1];
        fulfillmentid = [select id,name from Fulfillment_gne__C where name =: returnedid limit 1];
        practiceAgreementId = [select id,name from GNE_CM_MPS_Practice_Agreement__c where Name =: returnedid limit 1];
        AppealId = [select id,name from Appeal_gne__c where name =: returnedid limit 1];
        AppeallevelId = [select id,name from appeal_level_gne__c where name =: returnedid limit 1];
        BenefitReverificationId = [select id,name from GNE_CM_MPS_BRC_RituxanRA__c where name =: returnedid limit 1];
        eBIRequestId = [select id, name from GNE_CM_EBI_Request__c where name =: returnedid limit 1];
        shipmentMonitoringId = [select id, name from GNE_CM_Shipment_Monitoring_Email__c where name =: returnedid limit 1];
        
        if(returnedid!= null || returnedsobject!=null) {
            if(returnedsobject != null) {
                if(returnedid != null) {
                   /* if(returnedsobject != null && returnedid != '')
                    {
                          disabledeleteval= true;
                          disabletext = true;
                           disablecancelval = true;
                    }*/
                    System.debug('The Id value is'+ returnedid);                                          
                        
                    if(returnedsobject == 'Patient') {
                        //check for Patient Id: If patient ID is valid Call deletepatient method from GNE_CM_Deletion_Wizard class
                        if(patientId.size()>0) {
                            for(integer i =0;i<patientId.size();i++) {
                                patientIds.add(patientId[i].Id);
                            }
                            Control.deletepatientmethod(patientIds);  
                        }
                        else {
                            ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.Error,
                                    'Please check if the Patient Id is valid');
                            ApexPages.addMessage(Errormessage);
                        }
                    }
                    
                    if(returnedsobject == 'Shipment Monitoring Email') 
                    {
                        if(shipmentMonitoringId.size()>0) 
                        {
                            Control.deleteShipmentMonitoring(shipmentMonitoringId);  
                        }
                        else 
                        {
                            ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.Error,
                                    'Please check if the Shipment Monitoring Id is valid');
                            ApexPages.addMessage(Errormessage);
                        }
                    } 
                    
                    if(returnedsobject == 'Patient Address') {                           
                        //check for PatientAddress Id: If PatientAddress ID is valid Call deletepatientaddress method from  GNE_CM_Deletion_Wizard class
                        System.debug('The Id value is'+ returnedid); 
                        
                        if(patientAddressId.size()>0) {
                            Control.deletepatientaddress(patientAddressId);                                     
                        }                               
                        else {
                            ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.Error,
                                    'Please check if the Patient Address Id is valid');
                            ApexPages.addMessage(Errormessage);
                        }
                    }
                    
                    if(returnedsobject == 'Patient Contact') {
                        //check for PatientContact Id: If PatientAddress ID is valid Call deletePatientContact method from  GNE_CM_Deletion_Wizard class
                        System.debug('The Id value is'+ returnedid); 
                        
                        if(PatientContactId.size()>0) {
                            Control.deletepatientcontact(PatientContactId);  
                        }                               
                        else {
                            ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.Error,
                                    'Please check if the Patient Contact Id is valid');
                            ApexPages.addMessage(Errormessage);
                        }
                    }

                    if(returnedsobject == 'Patient Program') {
                        //check for PatientProgram Id: If PatientProgram ID is valid Call deletePatientProgram method from  GNE_CM_Deletion_Wizard class
                        System.debug('The Id value is'+ returnedid); 
                        
                        if(PatientProgramId.size()>0) {
                            Control.deletepatientprogram(PatientProgramId);  
                        }
                        else {
                            ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.Error,
                                    'Please check if the Patient Program Id is valid');
                            ApexPages.addMessage(Errormessage);
                        }
                    }

                    if(returnedsobject == 'Medical History') {
                        //check for Medical History: If Medical History ID is valid Call deleteMedicalHistorymethod method from  GNE_CM_Deletion_Wizard class
                        System.debug('The Id value is'+ returnedid); 
                        
                        if(MedicalHistoryId.size()>0) {
                            Control.deleteMedicalHistorymethod(MedicalHistoryId);  
                        }
                        else {
                            ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.Error,
                                    'Please check if the Medical History Id is valid');
                            ApexPages.addMessage(Errormessage);
                        }
                    }

                    if(returnedsobject == 'Case') {
                        //check for Case: If Case ID is valid Call deletecase method from  GNE_CM_Deletion_Wizard_look_children class
                        System.debug('The Id value is'+ returnedid); 
                        
                        if(CaseId.size()>0) {
                            Control.deleteCase(CaseId);  
                        }
                        else {
                            ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.Error,
                                    'Please check if the Case Id is valid');
                            ApexPages.addMessage(Errormessage);
                        } 
                    }

                    if(returnedsobject == 'Insurance') {
                        //check for Insurance: If Insurance ID is valid Call deleteInsurance method from  GNE_CM_Deletion_Wizard_look_children class
                        System.debug('The Id value is'+ returnedid); 
                        
                        if(InsuranceId.size()>0) {
                            Control.deleteInsurance(InsuranceId);  
                        }
                        else {
                            ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.Error,
                                    'Please check if the InsuranceId Id is valid');
                            ApexPages.addMessage(Errormessage);
                        } 
                    }
                         
                    if(returnedsobject == 'Shipment') {
                        //check for Shipment: If Shipment ID is valid Call deleteShipment method from  GNE_CM_Deletion_Wizard_look_children class
                        System.debug('The Id value is'+ returnedid); 
                        
                        if(ShipmentId.size()>0) {
                            Control.deleteShipment(ShipmentId);  
                        }
                        else {
                            ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.Error,
                                    'Please check if the ShipmentId Id is valid');
                            ApexPages.addMessage(Errormessage);
                        } 
                    }

                    if(returnedsobject == 'Benefit Investigation') {
                        //check for Benefit Investigation: If Benefit Investigation ID is valid Call deleteBI method from  GNE_CM_Deletion_Wizard_look_children class
                        System.debug('The Id value is'+ returnedid); 
    
                        if(BIId.size()>0) {
                            Control.deleteBI(BIId);  
                        }
                        else {
                            ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.Error,
                                    'Please check if the Benefit Investigation Id is valid');
                            ApexPages.addMessage(Errormessage);
                        } 
                    }
                        
                    if(returnedsobject == 'Prior Authorization') {
                        //check for Prior Authorization: If Prior Authorization ID is valid Call deletepriorauthorization method from  GNE_CM_Deletion_Wizard_look_children class
                        System.debug('The Id value is'+ returnedid); 
                        
                        if(Priorauthlist.size()>0) {
                            Control.deletepriorauthorization(Priorauthlist);  
                        }
                        else {
                            ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.Error,
                                    'Please check if the Prior Authorization Id is valid');
                            ApexPages.addMessage(Errormessage);
                        } 
                    }
                    
                    if(returnedsobject == 'fulfillment') {
                        //check for fulfillment: If fulfillment ID is valid Call deletefulfillment method from  GNE_CM_Deletion_Wizard_look_children class
                        System.debug('The Id value is'+ returnedid); 
                        
                        if(fulfillmentid.size()>0) {
                            Control.deletefulfillment(fulfillmentid);  
                        }
                        else {
                            ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.Error,
                                    'Please check if the fulfillment Id is valid');
                            ApexPages.addMessage(Errormessage);
                        } 
                    }

                    if(returnedsobject == 'Appeal') {
                        //check for Appeal: If Appeal ID is valid Call deletefulfillment method from  GNE_CM_Deletion_Wizard_look_children class
                        System.debug('The Id value is'+ returnedid); 
                        
                        if(AppealId.size()>0) {
                            Control.deleteAppeal(AppealId);  
                        }
                        else {
                            ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.Error,
                                    'Please check if the Appeal Id is valid');
                            ApexPages.addMessage(Errormessage);
                        } 
                    }

                    if(returnedsobject == 'Appeal Level') {
                        //check for AppeallevelId: If AppeallevelId ID is valid Call deletefulfillment method from  GNE_CM_Deletion_Wizard_look_children class
                        System.debug('The Id value is'+ returnedid); 
                        
                        if(AppeallevelId.size()>0) {
                            Control.deleteAppeallevel(AppeallevelId);  
                            AppeallevelId.clear();
                        }
                        else {
                            ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.Error,
                                    'Please check if the Appeal level Id is valid');
                            ApexPages.addMessage(Errormessage);
                        } 
                    }
                    
                    if(returnedsobject == 'Practice Agreement') {
                        //check for practiceAgreementId 
                        System.debug('The Id value is'+ returnedid); 
                        
                        if(practiceAgreementId.size()>0) {
                            Control.deletePracticeAgreement(practiceAgreementId);  
                        }
                        else {
                            ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.Error,
                                    'Please check if the practiceAgreementId is valid');
                            ApexPages.addMessage(Errormessage);
                        } 
                    }
                }
                else {
                    ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.Error,
                                    'Id canot be empty.Please enter the Id for the above record');
                    ApexPages.addMessage(Errormessage);
                }  // end of if(returnedid != null)
            }
            else {
                ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.Error,
                                    'Please choose atleast one object for the Id to delete. Object cannot be null');
                ApexPages.addMessage(Errormessage);
            }  // end of if(returnedsobject != null)               
        }
        else {
            ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.Error,
                                    'Please choose one Id and one object to proceed');
            ApexPages.addMessage(Errormessage);
        }   
    }  // end of deletemethod
}