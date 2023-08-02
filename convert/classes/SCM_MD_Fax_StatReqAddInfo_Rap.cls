public class SCM_MD_Fax_StatReqAddInfo_Rap extends SCM_MergeDocument implements IStandardComboBox
 {
       private SCM_MergeSection UI_Additional_Docs;
       private SCM_MergeSection Data; 
       private SCM_MergeSection UI_InitialRequest_Sec;
       private SCM_MergeSection UI_NoAction_Sect; 
        
       private SCM_MergeFieldCheckbox UI_SMN;
       private SCM_MergeFieldCheckbox UI_InitialHistoryPhysical;
       private SCM_MergeFieldCheckbox UI_TreatPlan;
       private SCM_MergeFieldCheckbox UI_Officevisitnotes;
       private SCM_MergeFieldCheckbox UI_PCPREferral;
       private SCM_MergeFieldCheckbox UI_Prescription;
       private SCM_MergeFieldCheckbox UI_PriorAuthform;
       private SCM_MergeFieldCheckbox UI_Pan;
       private SCM_MergeFieldCheckbox UI_BSA;
       private SCM_MergeFieldCheckbox UI_PriorTreat;
       private SCM_MergeFieldCheckbox UI_PASI;
       private SCM_MergeFieldCheckbox UI_QualityofLifesur;
       private SCM_MergeFieldCheckbox UI_Noaction;
       private SCM_MergeField UI_InitialRequestDate;
       private SCM_MergeField UI_InitialRequest;
       
    
    //Checkbox + Textbox
       private SCM_MergeFieldCheckbox UI_Other;
            
    //Textboxes
     private SCM_MergeField  TEXT1;
     private SCM_MF_OtherDocuments  TEXT2;
         
 
public SCM_MD_Fax_StatReqAddInfo_Rap(String caseId, String argLookupId)

    {
        super(caseId, argLookupId);
    }

    public override void createMergeFields()
     {
        String caseRecordType = selectedCase.RecordType.Name;
        String physicianId  = selectedCase.Case_Treating_Physician_gne__r.Id;
        String patientNumber = selectedCase.Patient_gne__r.Patient_Id_gne__c;
        String productName = selectedCase.Product_gne__c;   
        
        //1. Case Number (Case_Number)
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));          
         
        //2. Patient Number (Patient Id)
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase)); 
        
        //6. Attn (ATTN_Attn)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(physicianId));
        
        //7. Addressed To 
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(physicianId));
        
        //7. Recname (Physician First Last Name)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName(physicianId));
       
        //8. Recfax (RECFAX_Fax)
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(physicianId));
        
        //9. From   (From)        
        this.mergeRecipientInfo.add(new SCM_MF_FaxFrom(selectedCase, caseRecordType));
                
        //10. Extension    (Ext)     
        this.mergeRecipientInfo.add(new SCM_MF_FaxExtn(selectedCase, caseRecordType)); 
        
        // Phone short (CR_PhoneShort)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR_Short(productName));
 
        //3. Cr_Phone (CR_Phone)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Phone_CR(selectedCase));
        
        //4. Cr_Fax (CR_Fax)
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_CR(selectedCase));
        
        //5. Cr_URL (CR_URL)
        this.mergeRecipientInfo.add(new SCM_MF_Product_URL_CR(selectedCase));
         
         //Date short (Current_Date)
         this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
         
         //12. Patient Full Name (Patient_First_And_Last_Name)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientFirstAndLastName(selectedCase.Patient_gne__r.Id));
        
         //13. DOB (Patient_DOB)
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(patientNumber));
        
        //15. Privacy notice (PrivacyNotice)
        this.mergeFields.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
        
            
         //17.ConfidNotice (ConfidNotice)
         this.mergeFields.add(new SCM_MF_Product_ConfidentialityNotice(selectedCase));
        
        //Form Info
        SCM_MergeFieldGroup formInformation1 = new SCM_MergeFieldGroup();
        formInformation1.headerText = 'Form Information';               
        formInformation1.key = 'UI_InitialRequest';
        
        //Initial request (InitialRequest)
        SCM_MergeField UI_InitialRequest = new SCM_MergeField();
        UI_InitialRequest.key = 'InitialRequest';
        UI_InitialRequest.checked = false;
        UI_InitialRequest.displayCheck = false;
        UI_InitialRequest.displayTextBox = false;
        UI_InitialRequest.displayLabel = true;
        UI_InitialRequest.IsRequired = false;
        UI_InitialRequest.label = 'Access Solutions submitted documentation for authorization on ';
        UI_InitialRequest.isNewLine = true;
        UI_InitialRequest.totalWidth = '350';
        formInformation1.subFields.add(UI_InitialRequest);
        
        UI_InitialRequestDate = new SCM_MergeField();
        UI_InitialRequestDate.key = 'InitialRequestDate';
        UI_InitialRequestDate.checked = false;
        UI_InitialRequestDate.displayCheck = false;
        UI_InitialRequestDate.displayTextBox = true;
        UI_InitialRequestDate.displayLabel = false;
        UI_InitialRequestDate.IsRequired = false;
        //UI_InitialRequestDate.label = 'Initial Request';
        UI_InitialRequestDate.isNewLine = false;
        UI_InitialRequestDate.fieldType = SCM_MergeField.Fieldtypes.dateField;
        UI_InitialRequestDate.fieldValue='';
        UI_InitialRequestDate.totalWidth = '120';
        UI_InitialRequestDate.width = '60';

        formInformation1.subFields.add(UI_InitialRequestDate);

        SCM_MergeField UI_InitialRequest1 = new SCM_MergeField();
        UI_InitialRequest1.key = 'InitialRequest1';
        UI_InitialRequest1.checked = false;
        UI_InitialRequest1.displayCheck = false;
        UI_InitialRequest1.displayTextBox = false;
        UI_InitialRequest1.displayLabel = true;
        UI_InitialRequest1.IsRequired = false;
        UI_InitialRequest1.label = 'Authorization for Raptiva (Efalizumab) is still pending.\r\n\r\n\r\n';
        UI_InitialRequest1.isNewLine = true;
        UI_InitialRequest1.totalWidth = '340';
        formInformation1.subFields.add(UI_InitialRequest1);
        
         //No action is required
        UI_Noaction = new SCM_MergeFieldCheckbox('UI_Noaction','No action required');       
        UI_Noaction.fieldValue ='No action required';
        UI_Noaction.totalWidth = '200';
        UI_Noaction.totalHeight = '50';
        UI_Noaction.isNewLine = true;
        formInformation1.subFields.add(UI_Noaction);
        
     
        //Additional docs
        SCM_MergeFieldGroup formInformation = new SCM_MergeFieldGroup();
        formInformation.headerText = 'Medical Information';               
        formInformation.key = 'Additional_Inf_Reqd';
        
         //Merge Sections    
        UI_NoAction_Sect = new SCM_MergeSection();        
        UI_NoAction_Sect.key = 'UI_NoActionReq';
        this.mergeSections.add(UI_NoAction_Sect);
        
        
        UI_InitialRequest_Sec = new SCM_MergeSection();        
        UI_InitialRequest_Sec.key = 'UI_InitialRequest_Sect';
        this.mergeSections.add(UI_InitialRequest_Sec);
        
        UI_Additional_Docs = new SCM_MergeSection();        
        UI_Additional_Docs.key = 'UI_Additional_Docs';
        this.mergeSections.add(UI_Additional_Docs);
        
        
        this.mergeFields.add(formInformation1);   
                  
        this.mergeFields.add(formInformation);           
        
        //UI_SMN
        UI_SMN = new SCM_MergeFieldCheckbox('UI_SMN','SMN(attached)');       
        UI_SMN.fieldValue ='SMN(attached)\r\n';
        UI_SMN.totalWidth = '600';
        UI_SMN.isNewLine = true;  
        formInformation.subFields.add(UI_SMN);
        
        //UI_InitialHistoryPhysical
        UI_InitialHistoryPhysical = new SCM_MergeFieldCheckbox('UI_InitialHistoryPhysical','History & Physical');       
        UI_InitialHistoryPhysical.fieldValue ='History & Physical\r\n';
        UI_InitialHistoryPhysical.totalWidth = '600';
        UI_InitialHistoryPhysical.isNewLine = true;  
        formInformation.subFields.add(UI_InitialHistoryPhysical);
         
        //Treatment Plan
        UI_TreatPlan = new SCM_MergeFieldCheckbox('UI_TreatPlan','Treatment Plan');       
        UI_TreatPlan.fieldValue ='Treatment Plan\r\n';
        UI_TreatPlan.totalWidth = '600';
        UI_TreatPlan.isNewLine = true;  
        formInformation.subFields.add(UI_TreatPlan);
        
        //Office visit notes
        UI_Officevisitnotes = new SCM_MergeFieldCheckbox('UI_Officevisitnotes','Office Visit Notes');       
        UI_Officevisitnotes.fieldValue ='Office Visit Notes\r\n';
        UI_Officevisitnotes.totalWidth = '600';
        UI_Officevisitnotes.isNewLine = true;  
        formInformation.subFields.add(UI_Officevisitnotes);
        
        //PCPREferral
        UI_PCPREferral = new SCM_MergeFieldCheckbox('UI_PCPREferral','PCP Referral');       
        UI_PCPREferral.fieldValue ='PCP Referral\r\n';
        UI_PCPREferral.totalWidth = '600';
        UI_PCPREferral.isNewLine = true;  
        formInformation.subFields.add(UI_PCPREferral);
        
        //Prescription
        UI_Prescription = new SCM_MergeFieldCheckbox('UI_Prescription','Prescription');       
        UI_Prescription.fieldValue ='Prescription\r\n';
        UI_Prescription.totalWidth = '600';
        UI_Prescription.isNewLine = true;  
        formInformation.subFields.add(UI_Prescription);
        
        //Prior Auth form
        UI_PriorAuthform = new SCM_MergeFieldCheckbox('UI_PriorAuthform','Prior Authorization Form(attached)');       
        UI_PriorAuthform.fieldValue ='Prior Authorization Form(attached)\r\n';
        UI_PriorAuthform.totalWidth = '600';
        UI_PriorAuthform.isNewLine = true;  
        formInformation.subFields.add(UI_PriorAuthform);
        
        //Pan
        UI_Pan = new SCM_MergeFieldCheckbox('UI_Pan','Patient Authorization Notice of Release of Information');       
        UI_Pan.fieldValue ='Patient Authorization Notice of Release of Information\r\n';
        UI_Pan.totalWidth = '600';
        UI_Pan.isNewLine = true;  
        formInformation.subFields.add(UI_Pan);
        
        //BSA
        UI_BSA = new SCM_MergeFieldCheckbox('UI_BSA','Body Surface Area(BSA)');       
        UI_BSA.fieldValue ='Body Surface Area(BSA)\r\n';
        UI_BSA.totalWidth = '600';
        UI_BSA.isNewLine = true;  
        formInformation.subFields.add(UI_BSA);
        
        //Prior Treat
        UI_PriorTreat = new SCM_MergeFieldCheckbox('UI_PriorTreat','Prior Treatmenst(s)');       
        UI_PriorTreat.fieldValue ='Prior Treatmenst(s)\r\n';
        UI_PriorTreat.totalWidth = '600';
        UI_PriorTreat.isNewLine = true;  
        formInformation.subFields.add(UI_PriorTreat);
                                                                 
        //PASI
        UI_PASI = new SCM_MergeFieldCheckbox('UI_PASI','PASI Score');       
        UI_PASI.fieldValue ='PASI Score\r\n';
        UI_PASI.totalWidth = '600';
        UI_PASI.isNewLine = true;  
        formInformation.subFields.add(UI_PASI);
        
        //Quality of Life survey
        UI_QualityofLifesur = new SCM_MergeFieldCheckbox('UI_QualityofLifesur','Quality of Life Survey');       
        UI_QualityofLifesur.fieldValue ='Quality of Life Survey\r\n';
        UI_QualityofLifesur.totalWidth = '600';
        UI_QualityofLifesur.isNewLine = true;  
        formInformation.subFields.add(UI_QualityofLifesur);
        
        //Other
        UI_Other = new SCM_MergeFieldCheckbox('UI_Other','Other');       
        UI_Other.fieldValue ='Other';
        UI_Other.totalWidth = '80';
        formInformation.subFields.add(UI_Other);
        
               
        TEXT1 = new SCM_MergeField();
        TEXT1.key = 'UI_Other_Txt';
        TEXT1.isNewLine = false;
        TEXT1.displayCheck = false;
        TEXT1.displayLabel = false;
        TEXT1.displayTextBox = true;
        TEXT1.isRequired = false;
        TEXT1.requireNewLineInTemplate = true;
        //TEXT1.totalWidth = '220';
        formInformation.subFields.add(TEXT1);
       
         //16.UI_Comments(Key CommentField)
         this.mergeFields.add(new SCM_MF_Comments()); 
        
     }
     
     public override void getLatestValues()
      {    
             if(UI_Noaction.checked == false)
             {
                UI_NoAction_Sect.visible = false;
             }
             else
             {
                UI_NoAction_Sect.visible = true;
             }
            
            if(UI_InitialRequestDate.getMergeValue()==null || 
                UI_InitialRequestDate.getMergeValue()==''|| UI_InitialRequestDate.getFieldValue() == null ||
                UI_InitialRequestDate.getFieldValue() == '')
                UI_InitialRequest_Sec.visible = false;
            else
                UI_InitialRequest_Sec.visible = true;
                
             String strMergeValue = UI_InitialRequestDate.mergeValue;
             
             if(strMergeValue.length() == 0)
                UI_InitialRequest_Sec.visible = false;
            else
                UI_InitialRequest_Sec.visible = true;
            
            if(UI_InitialHistoryPhysical.checked == false &&
               UI_SMN.checked == false && 
               UI_TreatPlan.checked == false &&
               UI_Officevisitnotes.checked == false &&
               UI_PCPREferral.checked == false &&
               UI_PriorAuthform.checked == false && 
               UI_Prescription.checked == false && 
               UI_PriorTreat.checked == false &&
               UI_Pan.checked == false && 
               UI_BSA.checked == false &&  
               UI_PASI.checked == false &&
               UI_QualityofLifesur.checked == false &&  
               UI_Noaction.checked == false)
            {
                UI_Additional_Docs.visible = false;
            }
            else
            {
                UI_Additional_Docs.visible = true;
            }
           if(UI_Other.checked == false){
                TEXT1.mergeValue = '';
              }
           // if(UI_InitialRequestDate.fieldValue == ''){
           //     .visible = false;
          //  }
          
         //  if(UI_InitialRequest.fieldValue == ''){
          //     UI_InitialRequest.visible = false;
         //   }
                       
      }
     
 }