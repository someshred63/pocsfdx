Public Class GNE_CM_Deletion_Wizard_Support {
    public list<id> finallistforpage = new list<id>();
    List<task> ListofTaskIds= new List<task>();
    List<patient_gne__c> PatientList = new List<patient_gne__c>();
    List<Medical_History_gne__c> MedicalHistoryList = new List<Medical_History_gne__c>();        
    List<Patient_Contact_gne__c> PatientContactList = new List<Patient_Contact_gne__c>();
    List<Patient_address_gne__c> PatientAddressList = new List<Patient_Address_gne__c>();
    List<Patient_program_gne__c> PatientProgramList = new List<Patient_Program_gne__c>();
    List<GNE_CM_MPS_BRC_RituxanRA__c> BRList = new list <GNE_CM_MPS_BRC_RituxanRA__c>();
	List<GNE_CM_EBI_Request__c> eBIRequestList = new list <GNE_CM_EBI_Request__c>();
    List<GNE_CM_EBI_Benefit_Verification_Response__c> eBVResponseList = new list <GNE_CM_EBI_Benefit_Verification_Response__c>();
    List<Id> addActivitylist = new List<Id>();
    List<case> Caselist  = new List<Case>();
    List<shipment_gne__c> shipmentlist = new List<shipment_gne__c>();
    List<Insurance_gne__c> Insurancelist = new List<Insurance_gne__c>();
    List<Benefit_Investigation_gne__c> BIIdlist  = new List<Benefit_Investigation_gne__c>();
    List<Prior_Authorization_gne__c> PriorAuthlist= new List<Prior_Authorization_gne__c>();
    List<fulfillment_gne__c> fulfilllist = new List<fulfillment_gne__c>();
    List<GNE_CM_MPS_Practice_Agreement__c> practiceAgreements = new List<GNE_CM_MPS_Practice_Agreement__c>();
    List<Appeal_gne__c> Applist = new List<Appeal_gne__c>();
    List<Appeal_level_gne__c> Appllevelist = new list<Appeal_level_gne__c>();
    List<Task> testtasks = new List<task>();
    List<GNE_CM_Shipment_Monitoring_Email__c> shipmentMonitoringList = new List<GNE_CM_Shipment_Monitoring_Email__c>();
    public boolean childobjectflag; 
    public boolean parentflag;
    public boolean taskflag;
    public boolean disableMPSUser;
    public string exceptionmessage ;
    Id mpsUser = null;
    
    public void deletepatientmethod(List<Id> PatientId) {
        Patientlist = [select id,ownerid,Patient_ID_gne__c,name from patient_gne__c where Id =: PatientId];
        PatientContactList = [select Id,pat_con_Patient_gne__c,name,pat_con_Patient_gne__r.Name from patient_contact_gne__c where pat_con_Patient_gne__c =:PatientId]; 
        PatientAddressList = [select Id,Patient_gne__c,Patient_gne__r.name,name from Patient_Address_gne__c where Patient_gne__c =:PatientId];
        PatientProgramList = [select Id,Patient_gne__c,Patient_gne__r.name,name from Patient_Program_gne__c where Patient_gne__c=: PatientId];
        BRList = [select Id,Patient_Id_gne__c,Patient_Id_gne__r.name,name from GNE_CM_MPS_BRC_RituxanRA__c where Patient_Id_gne__c =:PatientId];
 		eBIRequestList = [select id,Patient_gne__c,Patient_gne__r.name,name from GNE_CM_EBI_Request__c where Patient_gne__c=: PatientId];
		eBVResponseList = [select id,Patient_gne__c,Patient_gne__r.name,name from GNE_CM_EBI_Benefit_Verification_Response__c where Patient_gne__c=: PatientId];
        MedicalHistoryList = [select Id,Patient_Med_Hist_gne__c,Patient_Med_Hist_gne__r.Name,name,ownerid from Medical_History_gne__c where Patient_Med_Hist_gne__c =:PatientId];           
        ListofTaskIds = [select id,whatid from task where whatid=: patientId ];
        
        if(PatientId.size()>0) { 
               /*for(integer i=0;i<Patientlist.size();i++)
                {                       
                    ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
                                                 Patientlist[i].name +' is the Patient related to the Patient Id ' +Patientlist[i].Patient_ID_gne__c);
                    ApexPages.addMessage(Errormessage);                  
                }*/
            if(ListofTaskIds.size()>0) {
                AddActivities(PatientId ,'Patient');
            }
            
                
            if(PatientContactList.size()>0) {           
                for(patient_contact_gne__c patientconlist : patientcontactlist) {
                    ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
                    		'Patient ' + PatientConlist.pat_con_Patient_gne__r.Name + ' has Contact ' + PatientConlist.Name + ' associated with it');
                    ApexPages.addMessage(Errormessage);
                }
            }
                  
            if(PatientAddressList.size()>0) {
                for(patient_address_gne__c patientaddress: Patientaddresslist) {
                    ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
							'Patient ' + patientaddress.Patient_gne__r.name + ' has Address ' + patientaddress.name + ' associated with it');
                    ApexPages.addMessage(Errormessage);  
                }
            }
             
            if(PatientProgramList.size()>0) {
                for(patient_program_gne__c patientprog : PatientProgramList) {
                    ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
                            'Patient ' + patientprog.Patient_gne__r.name + ' has Patient Program ' + patientprog.name + ' associated with it');
                    ApexPages.addMessage(Errormessage);
                }
            }
                 
            if(BRList.size()>0) {
                for(GNE_CM_MPS_BRC_RituxanRA__c BenefitReverification: BRList) {
                    ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
                            'Patient ' + BenefitReverification.Patient_Id_gne__r.name +' has Benefit Reverification ' + BenefitReverification.name + ' associated with it');
                    ApexPages.addMessage(Errormessage);  
                }
            }

            if(eBIRequestList.size()>0) {
                for(GNE_CM_EBI_Request__c eBIRequest: eBIRequestList) {
                    ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
                            'Patient ' + eBIRequest.Patient_gne__r.name +' has eBI Request ' + eBIRequest.name + ' associated with it');
                    ApexPages.addMessage(Errormessage);  
                }
            }

            if(eBVResponseList.size()>0) {
                for(GNE_CM_EBI_Benefit_Verification_Response__c eBVResponse: eBVResponseList) {
                    ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
                            'Patient ' + eBVResponse.Patient_gne__r.name +' has eBI Benefit Verification Response ' + eBVResponse.name + ' associated with it');
                    ApexPages.addMessage(Errormessage);  
                }
            }

              
            if(PatientContactList.size()>0 ||PatientProgramList.size()>0||PatientAddressList.size()>0 ||MedicalHistoryList.size()>0 ||
            					ListofTaskIds.size()>0 || BRList.size()>0 || eBIRequestList.size()>0 || eBVResponseList.size()>0) 
            {
                childobjectflag = true;
                for(Task tasklist : ListofTaskIds) {
                    finallistforpage.add(tasklist.Id);
                }

                for(patient_address_gne__c Patientaddress : PatientAddressList) {
                    finallistforpage.add(Patientaddress.Id);
                }

                for(patient_Contact_gne__c Patientcontact : PatientContactList) {
                    finallistforpage.add(Patientcontact.Id);
                }

                for(patient_program_gne__c Patientprog : PatientProgramList) {
                    finallistforpage.add(Patientprog.Id);
                }

                for(GNE_CM_MPS_BRC_RituxanRA__c BenefitReverification: BRList) {
                    finallistforpage.add(BenefitReverification.Id);
                }

                for(Medical_History_gne__c medical : MedicalHistoryList ) {
                    finallistforpage.add(medical.Id);
                }

                for(GNE_CM_EBI_Benefit_Verification_Response__c eBVResponse: eBVResponseList) {
                    finallistforpage.add(eBVResponse.Id);
                }
                
                for(GNE_CM_EBI_Request__c eBIRequest: eBIRequestList) {
                    finallistforpage.add(eBIRequest.Id);
                }
            }
            else {
                childobjectflag = false;
            }

           if(childobjectflag == false) {     
                for(integer i=0;i<Patientlist.size();i++) {                       
                    ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
                                        Patientlist[i].name +' is the Patient related to the Patient Id ' +Patientlist[i].Patient_ID_gne__c);
                    ApexPages.addMessage(Errormessage);                  
                }
            }
            
            if(MedicalHistoryList.size()>0) 
            {
                deleteMedicalHistorymethod(MedicalHistoryList);
            } 
            
            for(integer i=0;i<Patientlist.size();i++) {
                finallistforpage.add(Patientlist[i].Id);
            }
        }
    }  // end of deletepatientmethod
    
    public void deletePatientContact(List<Patient_Contact_gne__c> PatientContactId) {
        PatientContactList = [select id,pat_con_Patient_gne__r.Name,name from Patient_Contact_gne__c where Id in: PatientContactId];  
        
        if(PatientContactList .size()>0) {
            for(integer i=0;i<PatientContactList .size();i++) { 
                ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
                            'Patient ' + PatientContactList[i].pat_con_Patient_gne__r.Name + ' has Contact ' + PatientContactId[i].name + ' associated with it');
                ApexPages.addMessage(Errormessage);
                finallistforpage.add(PatientContactList[i].Id);
            }
        }
    }
    
    public void deletePatientAddress(List<Patient_Address_gne__c> PatientAddressId) {
        Patientaddresslist= [select id,Patient_gne__r.name,name from Patient_Address_gne__c where Id in: PatientAddressId];
        
        if(Patientaddresslist.size()>0) {
            for(integer i=0;i<Patientaddresslist.size();i++) {
                ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
                            'Patient ' + Patientaddresslist[i].Patient_gne__r.name + ' has Address ' + Patientaddresslist[i].name + ' associated with it');
                ApexPages.addMessage(Errormessage);
                finallistforpage.add(Patientaddresslist[i].Id);
            } 
        }
    }

    public void deletePatientprogram(List<Patient_program_gne__c> PatientprogramId) {
        PatientProgramList  = [select id,Patient_gne__r.name,name from Patient_program_gne__c where Id in: PatientprogramId];  
        
        if(PatientProgramList.size()>0) {
            for(integer i=0;i<PatientProgramList.size();i++) {
                ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
                            'Patient ' + PatientProgramList[i].Patient_gne__r.name + ' has Patient Program ' + PatientProgramList[i].name + ' associated with it');
                ApexPages.addMessage(Errormessage);
                finallistforpage.add(PatientProgramList[i].Id);                   
            }
        }
    }

    public void deleteMedicalHistorymethod(List<medical_history_gne__c> MHId) {
        List<Id> taskwhatid = new List<Id>();
        ListofTaskIds = [select id,whatid from task where whatid=: MHId ];
        MedicalHistoryList = [select Id,ownerid,name,patient_Med_Hist_gne__r.name from medical_history_gne__c where Id in: MHId];    
        Caselist = [select id,casenumber,Patient_gne__r.name,Medical_History_gne__c from case where Medical_History_gne__c in: MHId];

        if(MHId.size()>0) {   
            for(integer i=0;i<MedicalHistoryList .size();i++) {
                finallistforpage.add(MedicalHistoryList[i].Id);
                ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
                            'Patient ' + MedicalHistoryList[i].Patient_Med_Hist_gne__r.name + ' has Medical History ' + MedicalHistoryList[i].name + ' associated with it');
                ApexPages.addMessage(Errormessage);
            }       
         
            if(Caselist.size()>0) {    
                deletecase(Caselist);                     
            }
            
            if(ListofTaskIds.size()>0) {
                for(integer i=0;i<MedicalHistoryList.size();i++) {
                    taskwhatid.add(MedicalHistoryList[i].id);   
                }
                Addactivities(taskwhatid,'Medical History');
            }
             
            if( Caselist.size()>0) {
                childobjectflag = true;
                Parentflag = true;
                
                for(Case caselists : Caselist) {
                    finallistforpage.add(caselists.Id);
                }
                
                for(Task tasklist: ListofTaskIds) {
                    finallistforpage.add(tasklist.Id);
                }
            }
            else {
                childobjectflag = false;
                Parentflag = false;
            }
             
            if(childobjectflag == false && Parentflag == false) {
                for(integer i=0;i<MedicalHistoryList.size();i++) { 
                    ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
                            'Patient ' + MedicalHistoryList[i].Patient_Med_Hist_gne__r.name + ' has Medical History ' + MedicalHistoryList[i].name + ' associated with it');
                    ApexPages.addMessage(Errormessage);
                }
            }
        }
    }

    public void deletecase(List<case> CaseIdList) {
        List<Id> CaseId = new List<Id>();
        List<Id> taskwhatid = new list<Id>();
        List<string> Caseidstring = new List<String>();
        for(Case Caselistidlist : caseIdList) {
            Caseidstring.add( string.valueof(Caselistidlist.casenumber) );
            CaseId.add(Caselistidlist.Id);
        }
         
        Caselist   = [select Id,CaseNumber,Patient_gne__r.name from case where CaseNumber in: Caseidstring];    
        Insurancelist = [select Id,Case_Insurance_gne__c from Insurance_gne__c where Case_Insurance_gne__c=:CaseIdList];
        shipmentlist  = [select Id,Case_Shipment_gne__c from shipment_gne__c where Case_Shipment_gne__c=:CaseIdList];
        ListofTaskIds = [select id,whatid from task where whatid=: Caselist];
        fulfilllist = [select id,Case_Fulfillment_gne__c from fulfillment_gne__c where Case_Fulfillment_gne__c =: CaseIdList];
        BRList = [select Id,Patient_Id_gne__c,Patient_Id_gne__r.name,name, Case_gne__c from GNE_CM_MPS_BRC_RituxanRA__c where Case_gne__c=: CaseIdList];
        
        if(Caselist.size()>0) 
        {   
            if(ListofTaskIds.size()>0) {
                for(integer i=0;i<Caselist.size();i++) {
                taskwhatid.add(Caselist[i].id);  
                }
                Addactivities(taskwhatid , 'Case');
            }
            //added 04/23/2015
            for(GNE_CM_MPS_BRC_RituxanRA__c BenefitReverification : BRList) 
            {
            	finallistforpage.add(BenefitReverification.Id);
            }

            if(shipmentlist.size()>0) {
                deleteshipment(shipmentlist);
            }
              
            if(fulfilllist.size()>0) {
                deletefulfillment(fulfilllist);
            }
              
            if(Insurancelist.size()>0) {
                deleteInsurance(Insurancelist);
            }    
              
            if(Insurancelist.size()>0 || shipmentlist.size()>0 || fulfilllist.size()>0) {
                childobjectflag = true;
                Parentflag = true;   
            }
            else 
            {
                childobjectflag = false;
                Parentflag = false;
            }

			for(integer i=0;i<Caselist.size();i++) 
            {            
                finallistforpage.add(Caselist[i].Id);
                ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
                            'Patient ' + Caselist[i].Patient_gne__r.name + ' has Case ' + Caselist[i].casenumber + ' associated with it');
                ApexPages.addMessage(Errormessage);
            }            
            
            if(childobjectflag == false && parentflag == false) 
            {
                for(integer i=0;i<caselist.size();i++) { 
                    ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
                            'Patient ' + Caselist[i].Patient_gne__r.name + ' has Case ' + Caselist[i].casenumber + ' associated with it');
                    ApexPages.addMessage(Errormessage);
                }
            } 
        }
    }  // end of deletecase

    public void deleteShipment(List<Shipment_gne__c> ShipmentListId) {
        shipmentlist = [select Id, Name, Case_Shipment_gne__r.CaseNumber  from Shipment_gne__c where Id in: ShipmentListId];    
        shipmentMonitoringList = [select ID, Name, Shipment__r.Id from GNE_CM_Shipment_Monitoring_Email__c  where Shipment__r.Id in:ShipmentListId];
        System.debug('DZ monitoring list ' + shipmentMonitoringList);
        if(shipmentlist.size()>0) 
        {
        	if(shipmentMonitoringList.size() > 0)
            {
            	deleteShipmentMonitoring(shipmentMonitoringList);
            }  
            
            for(integer i=0;i<shipmentlist.size();i++) 
            {
                ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,'Case ' + shipmentlist[i].Case_Shipment_gne__r.CaseNumber + ' has Shipment ' + shipmentlist[i].name + ' associated with it');
                ApexPages.addMessage(Errormessage);
                finallistforpage.add(shipmentlist[i].Id); 
            } 
        }
    }
    
    public void deleteShipmentMonitoring(List<GNE_CM_Shipment_Monitoring_Email__c> shipmentMonitoringId)
    {
    	shipmentMonitoringList = [SELECT ID, Name, Shipment__r.Id, Shipment__r.Name, Shipment__r.Case_Shipment_gne__r.CaseNumber From GNE_CM_Shipment_Monitoring_Email__c  where id in:shipmentMonitoringId];
    	if(shipmentMonitoringList.size() > 0)
    	{
    		System.debug('DZ: shimpent monitoring emails: ' + shipmentMonitoringList);
    		
	    	for(GNE_CM_Shipment_Monitoring_Email__c shipmentMonitoringEmail : shipmentMonitoringList)
	    	{
	    		finallistforpage.add(shipmentMonitoringEmail.Id);
	    	}
    		
	    	for(integer i=0; i<shipmentMonitoringList.size(); i++) 
	        {
	        	ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,'Shipment ' + shipmentMonitoringList[i].Shipment__r.Name + ' has Shipment Monitoring Email ' + shipmentMonitoringList[i].name + ' associated with it');
	            ApexPages.addMessage(Errormessage);
	            finallistforpage.add(shipmentMonitoringList[i].Id); 
	        }
    	}           
    }
    
    public void deletefulfillment(List<fulfillment_gne__c> fulfillmentlist) {
        fulfilllist = [select Id,name,Case_Fulfillment_gne__r.casenumber from fulfillment_gne__c where Id in: fulfillmentlist];    
        
        if(fulfilllist.size()>0) {
            for(integer i=0;i<fulfilllist.size();i++) {
                ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
                            'Case ' + fulfilllist[i].Case_Fulfillment_gne__r.casenumber + ' has Fulfillment ' + fulfilllist[i].name + ' associated with it');
                ApexPages.addMessage(Errormessage);
                finallistforpage.add(fulfilllist[i].Id); 
            }                
        }
    }
    
    public void deletePracticeAgreementLocation(List<GNE_CM_MPS_Practice_Agreement_Location__c> practiceAgreementLocationList) {
        if(practiceAgreementLocationList != null) {
            for(integer i=0;i<practiceAgreementLocationList.size();i++) {
                /*ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
                                                     'Note: The Address Location Mappings related to this Practice Agreement will be deleted with this operation');
                ApexPages.addMessage(Errormessage);*/
                finallistforpage.add(practiceAgreementLocationList[i].Id);
            }
        }
    }
    
    public void deletePracticeAgreement(List<GNE_CM_MPS_Practice_Agreement__c> practiceAgreementList) {
        practiceAgreements = [select Id,name,  MPS_User__c, is_user__c, is_prescriber__c from GNE_CM_MPS_Practice_Agreement__c where Id in: practiceAgreementList];    
        List<GNE_CM_MPS_Practice_Agreement_Location__c> pracAgreeLocationList = [Select Id from GNE_CM_MPS_Practice_Agreement_Location__c where MPS_Practice_Agreement__c =: practiceAgreements[0].Id];                    
        if(pracAgreeLocationList != null && pracAgreeLocationList.size() > 0) {
            childobjectflag = true;
            parentflag = true;
            deletePracticeAgreementLocation(pracAgreeLocationList);
        }

        if(practiceAgreements != null && practiceAgreements.size() > 0) {
            for(integer i=0;i<practiceAgreements.size();i++) {
                ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
                                    'The Practice Agreement '+ practiceAgreements[i].Name   +' is being deleted.');
                ApexPages.addMessage(Errormessage);
                finallistforpage.add(practiceAgreements[i].Id);
            } 

            if(practiceAgreements[0].is_user__c == true) {
                disableMPSUser = true;
                mpsUser = (practiceAgreements[0].MPS_User__c);
            }
        }
        //delete practiceAgreements;      
                //TODO Kaavya
                //Delete practice agreement locations for the Id's
                //Delete practice agreements
                //Disable the SFDC User                 
    }  // end of deletePracticeAgreement   
     
    public void disableMPSUser() {
        if(mpsUser != null) {
            List<Id> ids = new List<Id>();
            ids.add(mpsUser);
            GNE_CM_MPS_CreateSFDCUser.EnableDisableUser(ids, false);
        }
    } 
     
    public void deleteInsurance(List<Insurance_gne__c> InsuranceIdlist) {
        BIIdlist= [select Id,BI_Insurance_gne__c from Benefit_Investigation_gne__c where BI_Insurance_gne__c=:InsuranceIdlist];
        Insurancelist  = [select Id,Case_Insurance_gne__r.CaseNumber,name from Insurance_gne__c where Id in: InsuranceIdlist];    
          
        if(BIIdlist.size()>0) 
        {
            childobjectflag = true;
            parentflag = true;
            deleteBI(BIIdlist);                        
        }
        else {
            childobjectflag = false;
            parentflag = false;
        }
        
        for(integer i=0;i<Insurancelist.size();i++) 
        {
            ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
                            'Case ' + Insurancelist[i].Case_Insurance_gne__r.CaseNumber + ' has Insurance ' + Insurancelist[i].name + ' associated with it');
            ApexPages.addMessage(Errormessage);
            finallistforpage.add(Insurancelist[i].Id);
        } 
          
        
        
        if(childobjectflag == false && parentflag == false) {
            for(integer i = 0; i <Insurancelist.size();i++) {
                ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
                            'Case ' + Insurancelist[i].Case_Insurance_gne__r.CaseNumber + ' has Insurance ' + Insurancelist[i].name + ' associated with it');
                ApexPages.addMessage(Errormessage);
            }
        }       
    }

    public void deleteBI(List<Benefit_Investigation_gne__c> BIlist) {
        PriorAuthlist= [select Id,Benefit_Investigation_gne__c from Prior_Authorization_gne__c where Benefit_Investigation_gne__c=:BIlist];
        BIIdlist = [select Id,name,BI_Insurance_gne__r.Name  from Benefit_Investigation_gne__c where Id in: BIlist];   
        Applist  = [select id,name from appeal_gne__c where Benefit_Investigation_gne__c in: BIList];       
         
        if( PriorAuthlist.size()>0) {   
            deletePriorauthorization(PriorAuthlist);
        }
          
        if(Applist.size()>0 ) {
            deleteAppeal(Applist);
        }
        
        for(integer i=0;i<BIIdlist.size();i++) {
            ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
                            'Insurance ' + BIIdlist[i].BI_Insurance_gne__r.Name + ' has Benefit Investigation ' + BIIdlist[i].name + ' associated with it');
            ApexPages.addMessage(Errormessage); 
            finallistforpage.add(BIlist[i].Id);
        }
        
        
        if(PriorAuthlist.size()>0 || Applist.size()>0 ) {
            childobjectflag = true;
            Parentflag = true;
        }
        else {
            childobjectflag = false;
            Parentflag = false;
        }
        
        if(childobjectflag == false && parentflag == false) {
            for(integer i=0;i<BIIdlist.size();i++) {
                ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
                            'Insurance ' + BIIdlist[i].BI_Insurance_gne__r.Name + ' has Benefit Investigation ' + BIIdlist[i].name + ' associated with it');
                ApexPages.addMessage(Errormessage);
            }
      
        } 
    }  // end of deleteBI
    
    public void deletePriorauthorization(List<Prior_Authorization_gne__c> Priorauth) {
        PriorAuthlist = [select Id,Benefit_Investigation_gne__r.name,name from Prior_Authorization_gne__c where Id in: Priorauth];    
        if(PriorAuthlist.size()>0) {
            for(integer i=0;i<PriorAuthlist.size();i++) {
                ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
                            'Benefit Investigation ' + PriorAuthlist[i].Benefit_Investigation_gne__r.Name + ' has Prior Authorization ' + PriorAuthlist[i].name + ' associated with it');
                ApexPages.addMessage(Errormessage);
                finallistforpage.add(PriorAuthlist[i].Id);
            }                
        }
    }
    
    public void deleteAppeal(List<Appeal_gne__c> Appeallist) {
        Applist = [select Id,name,Benefit_Investigation_gne__r.Name from Appeal_gne__c where Id in: Appeallist];    
        Appllevelist = [select id,name,Appeal_ID_gne__c from Appeal_level_gne__c where Appeal_ID_gne__c in : Appeallist];
        if(Applist.size()>0) 
        {
            if(Appllevelist.size()>0) {
                childobjectflag = true;
                parentflag = true;
                deleteAppeallevel(Appllevelist);                    
            }
            else {
                childobjectflag = false;
                parentflag = false;
            }
            
            for(integer i=0;i<Applist.size();i++) 
            {
                ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
                            'Benefit Investigation ' + Applist[i].Benefit_Investigation_gne__r.Name + ' has Appeal ' + Applist[i].name + ' associated with it');
                ApexPages.addMessage(Errormessage);
                finallistforpage.add(Applist[i].Id);
            }
            
            if(childobjectflag == false && parentflag == false) {
                for(integer i=0;i<Applist.size();i++) {
                    ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
                            'Benefit Investigation ' + Applist[i].Benefit_Investigation_gne__r.name + ' has Appeal ' + Applist[i].name + ' associated with it');
                    ApexPages.addMessage(Errormessage);
                } 
            }
        }
    }
    
    public void deleteAppeallevel(List<Appeal_level_gne__c> Appeallevellist) {
        Appllevelist = [select Id,name,Appeal_ID_gne__r.Name from Appeal_level_gne__c where Id in: Appeallevellist];
        
        if(Appllevelist.size()>0) {
            for(integer i=0;i<Appllevelist.size();i++) {
                ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.warning,
                            'Appeal ' + Appllevelist[i].Appeal_ID_gne__r.Name + ' has Appeal level ' + Appllevelist[i].name + ' associated with it');
                ApexPages.addMessage(Errormessage);
                finallistforpage.add(Appllevelist[i].Id); 
            }                
        }
    }

    public void AddActivities(List<Id> ListofWhatIds,string objectname) {
        ListofTaskIds= [select id,status,ownerid,recordtype.name from task
                        where whatid In:ListofWhatIds and status != 'completed' and recordtype.name =: 'CM Task'];
        testtasks = ListofTaskIds;
         
        if(ListofTaskIds.size() > 0) {
            if(ListofTaskIds.isempty() == false) {
                taskflag = true;
                ApexPages.Message Errormessage2 = new ApexPages.Message(ApexPages.Severity.warning,
                                    'There are open tasks associated with the ' + objectname +' .Please close all the open tasks');
                ApexPages.addMessage(Errormessage2);
             }  
             else { 
                for(integer i=0;i<ListofTaskIds.size();i++) {
                    finallistforpage.add(ListofTaskIds[i].Id);                       
                }
            }
        }
    }
    
    Public pagereference deleteall(List<Id> finalDeletionlist) {
        string idtemp;
        Map<Integer, List<Id>> mapOfDelList = new Map<Integer, List<Id>>();
       
        
        if(finalDeletionlist.size()>0) 
        {
        	Set<ID> uniqueFinalDeletionlist = new Set<ID>();
        	uniqueFinalDeletionlist.addAll(finalDeletionlist);
            finalDeletionlist = new List<Id>(uniqueFinalDeletionlist);
            //04/23/2015 commented out and replaced by keeping proper order of deleting (listToDelete order) 
            //finalDeletionlist.sort();
            mapOfDelList = splitList(finalDeletionlist);  
            if(taskflag == true) 
            {
                ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.info,
                                    'None of the records were deleted.Please close all the open tasks and try to delete the records again.' );
                ApexPages.addMessage(Errormessage);
            } 
            else 
            {              
                try 
                {
                	//System.debug('inside deletall: ' + finalDeletionlist);
                	Boolean success = false;
                    Savepoint sp = Database.setSavepoint();
                    
                    for(Integer key : mapOfDelList.keySet())
                    {
                        Database.DeleteResult[] delresult = Database.delete(mapOfDelList.get(key), true);
                        for(Database.DeleteResult deleteresult : delresult) 
                    	{
                            if(!deleteresult.isSuccess()) 
                            {
                                exceptionmethod(deleteresult);
                                success = false;
                                ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.info,
                                    'Deletion not completeted' + deleteresult);
                                ApexPages.addMessage(Errormessage);
                                Database.rollback(sp);
                                break;
                            }
                            else
                            {
                                success = true;
                                //System.debug('partly SUCCESS, map used: ' + mapOfDelList.get(key));
                                System.debug('partly SUCCESS:  ' + deleteresult);
                            }    
                     	}
                    }
                    
                    /*
                    Database.DeleteResult[] delresult = Database.delete(finalDeletionlist, true);
                     
                    for(Database.DeleteResult deleteresult : delresult) 
                    {
                        if(!deleteresult.isSuccess()) {
                            exceptionmethod(deleteresult);
                            success = false;
                            ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.info,
                                'Deletion not completeted' + deleteresult);
                        	ApexPages.addMessage(Errormessage);
                            break;
                        }
                        else 
                        {
                            success = true;
                            System.debug('deletall SUCCESS: ' + deleteresult);
                        }
                     }
                     */
                     if(success)
                     {
                    	ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.info,'Deletion complete');
                        ApexPages.addMessage(Errormessage);
                        
                     	if((disableMPSUser != null && disableMPSUser)) 
                        {
                            disableMPSUser();
                     	}   
                     }
                }
                catch(Exception ex) 
                {
                    System.debug('Exception Occured: Cannot delete record'+ ex);
                    ApexPages.Message Errormessage = new ApexPages.Message(ApexPages.Severity.info,
                                'Deletion not completed. Exception Occured: Cannot delete record: ' + ex);
                        ApexPages.addMessage(Errormessage);
                }
            }
            taskflag = false;   
        }
        return null;        
    }
            
    public void exceptionmethod(Database.DeleteResult ex) {  
        string exceptiontype;
        string currentuser;
        String deletedby;
        exceptionmessage = string.valueof(ex);
        //exceptiontype = ex.getTypeName();
        Deletion_Error_Log__c deletionlog = new Deletion_Error_Log__c();
        currentuser = UserInfo.getUserId();
        system.debug('current user is'+ currentuser);
        
        if(currentuser != '' || currentuser != null) {
            if(exceptionmessage != null) {   
                deletedby = [select username from user where id=: currentuser].username;
                deletionlog.Deleted_By__c = deletedby ;
                deletionlog.failure_reason__c = exceptionmessage;
                //deletionlog.type__c =exceptiontype;
                database.insert(deletionlog);
                exceptionmessage = ex.getErrors()[0].getMessage();
            }
        }
    }                                   

    public pagereference pageredir() {
        pagereference page = new pagereference('apex/exception');
        page.setredirect(true);
        return page;
    }
    
    /*	In special cases when there are more than 10 types of IDs in one list there is invoked system exception: 
    *	"Cannot delete recordSystem.TypeException: Cannot have more than 10 types in a single operation. Please reduce number of types in one operation."
    *	Method splitList return map of lists with size less or equal 10.
	*/
    private static Map<Integer, List<Id>> splitList(List<Id> finalDeletionlist)
    {
        Map<Integer, List<Id>> mapOfSplitedLists = new Map<Integer, List<Id>>();
        List<Id> splittedList = new List<Id>();
        Integer listSize = finalDeletionlist.size();
        Integer cnt = 0;
        Integer key = 1; 
        
        for(Id idToDelete : finalDeletionlist)
        {
            splittedList.add(idToDelete);
            cnt++;
            if(cnt > 9 && listSize > 9)
            {
                listSize = listSize  - cnt;
                mapOfSplitedLists.put(key,splittedList.clone());
                key++;
                cnt = 0;
                splittedList.clear();
            }
            else if(cnt == listSize)
            {
                mapOfSplitedLists.put(key,splittedList.clone());
            }
        }
        return mapOfSplitedLists;
    }
}