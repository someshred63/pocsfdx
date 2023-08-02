/********************************************************************/
    // Developer Name    : Prabha
    // Document Name     : CMGT-FAX-02_MESSAGE_FROM_GATCF.doc
    // PRODUCT GROUP     : ACTIVASE, AVASTIN, HERCEPTIN, LUCENTIS, NUTROPIN, PULMOZYME, RAPTIVA, RITUXAN, RITUXAN RA, TARCEVA, TNKASE, XOLAIR
    // Type              : Fax Coversheet
    // Word Template     : Message_from_GATCF.doc    
    // Label in SF       : Message from GATCF
    
/********************************************************************/
public class SCM_MD_Fax_MessageFromGATCF extends SCM_MergeDocument implements IStandardComboBox {
   private SCM_MergeField mf1 ;
   private SCM_MergeSection UI_Acknowledgment;
   private SCM_MergeSection UI_PatientApproved;
   private SCM_MergeSection UI_PatientDenied;
   private SCM_MergeSection UI_PatientObtainedIns;
   private SCM_MergeSection UI_CaseClosedtoGATCF;
   private SCM_MergeSection UI_AdversEvents;
   private String selectedOption;
     
   private string patNameVal2;
   private string GATCF_Phone;
   private string productNm;

   public SCM_MD_Fax_MessageFromGATCF(String caseId, String argLookupId) {
       super(caseId, argLookupId);
   }
        
    public override void createMergeFields() {
        String patientId = selectedCase.patient_gne__r.Id;
        String physicianId = selectedCase.Case_Treating_Physician_gne__r.Id;
        String recordType = selectedCase.RecordType.Name;
        
        //Case Number
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
        
        //Patient Id
        this.mergeRecipientInfo.add(new SCM_MF_PatientId(selectedCase));
       
        //GATCF_Phone
        SCM_MF_Product_Phone_GATCF phone = new SCM_MF_Product_Phone_GATCF(selectedCase);
        this.mergeRecipientInfo.add(phone);
        
        //GATCF_Fax
        this.mergeRecipientInfo.add(new SCM_MF_Product_Fax_GATCF(selectedCase));
        
        //GATCF_URL
         this.mergeRecipientInfo.add(new SCM_MF_Product_URL_GATCF(selectedCase));

        //Product Name
        SCM_MF_Product_Name product = new SCM_MF_Product_Name(selectedCase);
        
        this.mergeRecipientInfo.add(new SCM_MF_Product_AccessSolutions(selectedCase.Product_gne__c));
        this.mergeRecipientInfo.add(product);

        //Drug 
        this.mergeRecipientInfo.add(new SCM_MF_Product_DrugName(selectedCase));
        
        //DrugType
        this.mergeRecipientInfo.add(new SCM_MF_Product_DrugType(selectedCase));
        
        //Attn
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.ATTN_PhysicianContactName(physicianId));
        
        //Recname
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFirstLastName_Textbox(physicianId));       
        
        //Recfax
        this.mergeRecipientInfo.add(SCM_MF_Physician_FieldFactory.PhysicianFax(physicianId));               
        //Ext & From
        if (recordType.startsWith('C&R')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Case_Manager__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Case_Manager__r.Id));
        }
        else if (recordType.startsWith('GATCF')) {
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerFromFirstAndLastName(selectedCase.Foundation_Specialist_gne__r.Id));
            this.mergeRecipientInfo.add(SCM_MF_CaseManager_FieldFactory.CaseManagerExtension(selectedCase.Foundation_Specialist_gne__r.Id));
        }
                
        //DateShort
        this.mergeRecipientInfo.add(new SCM_MF_CurrentDate());
        
        //PatientFullName
        SCM_MergeField patientName = SCM_MF_PatientFieldFactory.PatientFirstAndLastName(patientId);
        this.mergeRecipientInfo.add(patientName);
        
        //Patient DOB
        this.mergeRecipientInfo.add(SCM_MF_PatientFieldFactory.PatientDOB(patientId));
        
        //PrivacyNotice
        this.mergeRecipientInfo.add(new SCM_MF_Product_PrivacyNotice(selectedCase));
              
        //second page
                
        patNameVal2 = patientName.getFieldValue();
        GATCF_Phone = phone.getFieldValue();
        productNm = product.getFieldValue();
        
        mf1 = new SCM_MergeField();
        mf1.displayRadio = true;
        mf1.displayLabel = false;
        mf1.displayCheck = false;
        mf1.displayTextbox = false;
        mf1.IsRequired = false;
        mf1.fieldValue = '';
        mf1.isFormField = false;

        mf1.selectionItems.add(new SelectOption('Acknowledgement\r\nThank you for referring '+ patNameVal2                 
                + ' to Genentech Access to Care Foundation.The case is currently under review.'
                + ' \r\nAs part of our continuing effort to provide optimal customer service,'
                + ' I have been assigned to this case and can assist you with any questions.'
                + ' \r\nShould you have any questions, please contact me at ' + GATCF_Phone
                + '.','Acknowledgement' ));
                
        mf1.selectionItems.add(new SelectOption('PatientApproved\r\nGenentech Access to Care'
                + ' Foundation is pleased to inform you that your patient, '+ patNameVal2 
                + ', has been approved to receive '+ productNm +'. A shipment of '+ productNm +' will be'
                + ' coordinated with the patient.\r\nThis approval will remain effective until'
                + ' therapy is discontinued, the patient obtains insurance coverage for '+ productNm +','
                + ' or the patient fails to meet other program requirements.','Patient Approved'));
                
        mf1.selectionItems.add(new SelectOption('PatientDenied\r\nGenentech Access to Care' 
                + ' Foundation regrets to inform you that we will not be able to provide' 
                + ' assistance with '+ productNm +' for your patient ' + patNameVal2 +'.\r\n'
                + ' Unfortunately, assistance is only available to patients meeting the'
                + ' program requirements.\r\nWe are sorry that we cannot provide assistance'
                + ' at this time.', 'Patient Denied'));
        
        mf1.selectionItems.add(new SelectOption('PatientObtainedInsurance/Referred to'
                + ' Genentech Access Solutions\r\nYour patient has obtained insurance;'
                + ' therefore, the case has now been referred to '+ productNm +' Access Solutions'
                + ' to assist with the reimbursement process.  Please contact '+ productNm +' Access'
                + ' Solutions at '+ GATCF_Phone +' at anytime if you have any questions'
                + ' concerning the authorization process for your patient.',
                'Patient Obtained Insurance'));
                
        mf1.selectionItems.add(new SelectOption('Case Closed to Genentech Access to Care'
                + ' Foundation\r\nPlease note that the Genentech Access to Care Foundation'
                + ' case for your patient, '+ patNameVal2 + ', will close in two weeks unless'
                + ' the requested documentation is received. We have not had any response from'
                + ' the patient after at least three requests for additional information.', 
                'Case Closed to GATCF'));
                        
        mf1.selectionItems.add(new SelectOption(' ','None'));
        mf1.fieldValue= ' ';
             
        mf1.setKey('RadioButtonValue');
        this.mergeFields.add(mf1);  
                         
        UI_Acknowledgment=new SCM_MergeSection();
        UI_Acknowledgment.key='UI_Acknowledgement';
        UI_Acknowledgment.visible = false;
        this.mergeSections.add(UI_Acknowledgment);
        
        UI_PatientApproved=new SCM_MergeSection();
        UI_PatientApproved.key='UI_PatientApproved';
        UI_PatientApproved.visible = false;
        this.mergeSections.add(UI_PatientApproved);
        
        UI_PatientDenied=new SCM_MergeSection();
        UI_PatientDenied.key='UI_PatientDenied';
        UI_PatientDenied.visible = false;
        this.mergeSections.add(UI_PatientDenied);
        
        UI_PatientObtainedIns=new SCM_MergeSection();
        UI_PatientObtainedIns.key='UI_PatientObtainedIns';
        UI_PatientObtainedIns.visible = false;
        this.mergeSections.add(UI_PatientObtainedIns);
        
        UI_CaseClosedtoGATCF= new SCM_MergeSection();
        UI_CaseClosedtoGATCF.key='UI_CaseClosedtoGATCF';
        UI_CaseClosedtoGATCF.visible = false;
        this.mergeSections.add(UI_CaseClosedtoGATCF);  
        
        UI_AdversEvents = new SCM_MergeSection();
        UI_AdversEvents.key = 'UI_AdverseEvents';
        UI_AdversEvents.visible = false;
        this.mergeSections.Add(UI_AdversEvents);         
        
        //Comments
        this.mergeFields.add(new SCM_MF_Comments());
    }
    
   public override void getLatestValues() {
       if(mf1.getMergeValue().startsWith(' ')) {
       
       }

     else
      if (mf1.getMergeValue().startsWith('Acknowledgement')) {
            UI_Acknowledgment.visible = true;
            UI_PatientApproved.visible = false;
            UI_PatientDenied.visible = false;
            UI_PatientObtainedIns.visible = false;
            UI_CaseClosedtoGATCF.visible = false;
        }
    
        else if (mf1.getMergeValue().startsWith('PatientApproved')) {
            UI_PatientApproved.visible = true;
            UI_Acknowledgment.visible = false;
            UI_PatientDenied.visible = false;
            UI_PatientObtainedIns.visible = false;
            UI_CaseClosedtoGATCF.visible = false;
            UI_AdversEvents.visible = true;
        }
        else if (mf1.getMergeValue().startsWith('PatientDenied')) {
            UI_PatientDenied.visible = true;
            UI_Acknowledgment.visible = false;
            UI_PatientApproved.visible = false;
            UI_PatientObtainedIns.visible = false;
            UI_CaseClosedtoGATCF.visible = false;
        }
        else if (mf1.getMergeValue().startsWith('PatientObtainedInsurance')) {
            UI_PatientObtainedIns.visible = true;
            UI_Acknowledgment.visible = false;
            UI_PatientApproved.visible = false;
            UI_PatientDenied.visible = false;
            UI_CaseClosedtoGATCF.visible = false;
        }
        else if (mf1.getMergeValue().startsWith('Case Closed')) {
            UI_CaseClosedtoGATCF.visible = true;
            UI_Acknowledgment.visible = false;
            UI_PatientApproved.visible = false;
            UI_PatientDenied.visible = false;
            UI_PatientObtainedIns.visible = false;
        }
    }     
}