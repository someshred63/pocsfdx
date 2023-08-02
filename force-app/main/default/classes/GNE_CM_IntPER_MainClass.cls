public without sharing class GNE_CM_IntPER_MainClass extends GNE_CM_IntPER_MainClass_Base 
{ 
    public static Integer MAX_INSURANCE_NO = 3;       
    public String patEmailAdd {get; set;}  
    public Boolean adrsSameAsPat { get; set; }
    public String patFirstName{ get; set; }
    public String patLastName{get; set;} 
    public string refDate { get; set; }
    public string ensmnformrecDate { get; set; }
    public Id patient_enrollment_Id{get; set;}
    public Boolean error_pat_zip{ get; set; }
    public Boolean error_pat_email{ get; set; }
    public Boolean error_dob{ get; set; }
    public Boolean error_patPh{ get; set; }
    public Boolean error_pat_name{ get; set; }
    public Boolean error_patWPh{ get; set; }
    public Boolean error_patOPh{ get; set; }
    public Boolean error_insPrPh{ get; set; } 
    public Boolean error_insSecPh{ get; set; }
    
    public Patient_gne__c patient{ get; set; }
    public List<Patient_gne__c> patientList{get; set;}
    public string PatRecId;
    public string PatOrigin;
    public string specPharmNotes {get; set;}
    
    // Multiselect Component 
    public SelectOption[] selectedReasons {get; set;}
    public SelectOption[] allReasons {get; set;}
    public SelectOption[] selectedPanReasons {get; set;}
    public SelectOption[] allPanReasons {get; set;}
    
    //Case Section 
    public string hiddenPatientAddressCountry {get; set;}
    public boolean CR_case {get; set;}
    public boolean CR_GES_case {get; set;}
    public boolean GATCF_case {get; set;}
       
    //  Patient address and Patient Contact        
    public List<Patient_Contact_gne__c> lstPatContact { get; set; }
    public List<Patient_Address_gne__c> lstPatAddress { get; set; }
    public Patient_Contact_gne__c patConObj { get; set; }
    public Patient_Address_gne__c patAddressObj { get; set; }
    public boolean flagNewAddress { get; set; }
    public boolean flagNewContact { get; set; }
    public Boolean newCaseRedirect {get; set;}
    public boolean btnPatAddFlag { get; set; }
    public boolean btnPatConFlag { get; set; }
    public String enrollmentNotCompleteReason {get; set;}
    public String panNotCompleteReason {get; set;}
    public List<wrapPatAddress> lstwrapPatAddress { get; set; } 
    public List<wrapPatContact> lstwrapPatContact { get; set; }
    public string isEditValue { get; set; }
    public string isEditValuePatCon { get; set; }

    // Insurance
    public List<Insurance_gne__c> lstInsurance { get; set; }
    public Insurance_gne__C insuranceObj { get; set; }
    public boolean flagNewInsurance { get; set; }
    public boolean btnInsuranceFlag { get; set; }
    public List<InsuranceWrapper> insuranceWrappers { get; set; }
    public Integer currentInsuranceIndex { get; set; }
    public List<String> errorMessages { get; set; }
    public Integer insIndex = 0;

    // Misc
    public boolean sameAsPrescriber { get; set; }
    public boolean donotCreateAddress { get; set; }
    public boolean isPegasysCR { get; set; }

    // Constructor of the class
    public GNE_CM_IntPER_MainClass (ApexPages.StandardController controller)
    {
        initPlaceHolderValues();  
        flagNewAddress = false;
        flagNewContact = false;
        btnPatAddFlag  = true;
        btnPatConFlag  = true;
        adrsSameAsPat = false;
        btnInsuranceFlag = true;
        flagNewInsurance = false;
        isPegasysCR = false;

        // init flage
        CR_case = false;
        CR_GES_case = false;
        GATCF_case = false;
        
       // store DateTime into variables            
        DateTime currentDatetime = datetime.now();
        refDate = currentDatetime.format('MM/dd/yyyy');
        ensmnformrecDate = currentDatetime.format('MM/dd/yyyy h:mm a');  
        
        lstPatAddress = new List<Patient_Address_gne__c>();
        lstwrapPatAddress = new List<wrapPatAddress>();
        
        lstPatContact = new List<Patient_Contact_gne__c>();
        lstwrapPatContact = new List<wrapPatContact>();

        lstInsurance = new List<Insurance_gne__c>();
        insuranceWrappers = new List<InsuranceWrapper>();        
        
        PatRecId = ApexPages.currentpage().getParameters().get('patId');
        patOrigin = ApexPages.currentpage().getParameters().get('Origin');

        if (PatRecId != null)
        {
            lstPatAddress = getPatientAddressData(PatRecId);
            getPatAddressData();
            
            lstPatContact = getPatientContactData(PatRecId);
            getPatientContact();
        }
        patConObj       = new Patient_Contact_gne__c();
        patAddressObj   = new Patient_Address_gne__c(); 
        insuranceObj    = new Insurance_gne__c();

        patenrol = (Patient_Enrollment_Request_gne__c)controller.getRecord();                 
        date patEnrollDate;
        patenrol = new Patient_Enrollment_Request_gne__c();   

        patient_enrollment_Id = ApexPages.currentPage().getParameters().get('id');  
        
        if (patient_enrollment_Id != null)
        {    
            Map<String,sObjectField> fields = Schema.sobjectType.Patient_Enrollment_Request_gne__c.fields.getMap();
            List<sObjectField> pat_enroll_fields = new List<sObjectField>(); 
            pat_enroll_fields = fields.values();
            
            String query='select ';
            for (sObjectField f:pat_enroll_fields)
            {
                query+=String.valueOf(f)+',';
            }
            
            Integer indexOfComma = query.lastIndexOf(',');          
            
            query=query.subString(0,indexOfComma);
            
            query += ' from Patient_Enrollment_Request_gne__c where id =: patient_enrollment_Id';
            List<Patient_Enrollment_Request_gne__c> enrollments = Database.query(query);
            
            if (enrollments.size() > 0)
            {
                patenrol = enrollments[0];  
                
                patEmailAdd = patenrol.Email_Address_gne__c;
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Enrollment Request with given ID could not be found'));
                return;
            }                       
            
            /*   preferenceSettings = GNE_CM_MPS_User_Preferences_Utils.getMPSPreferencesBySFDCUser(UserInfo.getUserId());
                if (patOrigin == 'reenroll' ){ 
            patenrol = GNE_CM_MPS_User_Preferences_Utils.loadReimbursementClinicalContactStoredData(patenrol, preferenceSettings);
            System.debug('Loaded enrollment: ' + patenrol);
            }           */
        } 
        else
        {
            
            Map<String,String> params=ApexPages.currentPage().getParameters();

            String product = params.get('product');
            patenrol = GNE_CM_MPS_ReEnroll.reEnrollPatient(PatRecId, product);    
            // create one if we don't have it
            if (patenrol==null)
            {
                patenrol = new Patient_Enrollment_Request_gne__c();
                patenrol.Patient_gne__c=PatRecId;
                
                // do not use default
                patenrol.Place_of_Administration_gne__c=null;
            }
            // null out insurance fields 
            patenrol.PER_Source_gne__c='Intake';
            patenrol.Is_Patient_Insured_gne__c=null;
            patenrol.Primary_Payer_gne__c=null;
            patenrol.Subscriber_First_Name_gne__c=null;//PS: 10/09/2013
            patenrol.Subscriber_DOB_gne__c=null;//PS: 10/09/2013
            patenrol.PI_Subscriber_Name_gne__c=null;
            patenrol.PI_Subscriber_ID_gne__c=null;
            patenrol.Relationship_to_Patient_Insurance_gne__c=null;
            patenrol.PI_Phone_gne__c=null;          
            patenrol.Insurance_Plan_Type_gne__c=null;
            patenrol.Plan_Product_gne__c=null;
            patenrol.Insurance_Plan_Product_Type_gne__c=null;
            patenrol.Insurance_Rank_gne__c=null;    
            patenrol.Case_Enroll_Comp_Original_Receipt_gne__c=null;        
            patenrol.Product_gne__c=product;
            // clear prescriber
            patenrol.Prescriber_gne__c = null;
            patenrol.Case_Address_gne__c =  null;
            patenrol.Indicate_Patient_s_Therapy_gne__c=patenrol.CM_Indicate_Patient_s_Therapy_gne__c=params.get('therapyBioInfu');
            patenrol.Indicate_Patient_s_Therapy_BioOncOra_gne__c=params.get('therapyBioOral');
            patenrol.Indicate_Patient_s_therapy_Rheum_gne__c=patenrol.CM_Indicate_Patient_s_therapy_Rheum_gne__c=params.get('therapyRheum');    
            patenrol.Indicate_Patient_s_therapy_Lytics_gne__c= params.get('therapyLytics'); 
            
        }
        
        // Populate Patient Address     
        List<Patient_Address_gne__c> lstPatAdd = lstPrimePatAddress(PatRecId);            
        if (lstPatAdd != null && lstPatAdd.size() > 0)
        {
            patenrol.Street_gne__c      = lstPatAdd[0].Address_Line_1_gne__c;
            patenrol.Street2_gne__c     = lstPatAdd[0].Address_Line_2_gne__c;
            hiddenPatientAddressCountry = lstPatAdd[0].Country_gne__c;
            patenrol.City_gne__c        = lstPatAdd[0].City_gne__c;
            patenrol.Zip__c             = lstPatAdd[0].Zip_gne__c;
            patenrol.State_gne__c       = lstPatAdd[0].State_gne__c;
            patenrol.Home_Phone_gne__c  = lstPatAdd[0].Phone_gne__c;
            // Set default Country for an empty address
        } else {
            hiddenPatientAddressCountry = 'USA';
        }
        
        // Populate Patient object    
        patientList = [Select id , pat_first_name_gne__c, Name, Suffix_gne__c, pat_home_phone_gne__c, 
                            pat_dob_gne__c, pat_gender_gne__c,pat_email_gne__c , Full_Name_gne__c ,
                            PAN_Form_1_Product_gne__c , PAN_Form_2_Product_gne__c , 
                            PAN_Form_1_Expiration_Date_gne__c,PAN_Form_Rec_gne__c,
                            PAN_Form_2_Rec_gne__c,PAN_Form_2_Signed_gne__c,
                            PAN_Form_2_Exipration_Date_gne__c,PAN_Form_Signed_gne__c,
                            PAN_Form_1_Consent_Received_gne__c, PAN_Form_1_Phone_Number_gne__c,
                            PAN_Form_2_Consent_Received_gne__c, PAN_Form_2_Phone_Number_gne__c,
                            pat_other_phone_gne__c, pat_other_phone_type_gne__c,Preferred_Language_gne__c,ssn_gne__c,
                            Note_gne__c, Mid_Initial_gne__c, OK_to_Contact_Patient_gne__c, pat_work_phone_gne__c
                        from Patient_gne__c 
                        where id=:PatRecId];
                                
        if (patientList.size() > 0)
        {
            patient=patientList[0];
            
            patenrol.Last_Name_gne__c = patient.Name;
            patenrol.First_Name_gne__c = patient.pat_first_name_gne__c;
            patenrol.DOB_gne__c = patient.pat_dob_gne__c!= null ? Datetime.newInstance(patient.pat_dob_gne__c, Time.newInstance(0,0,0,0)).format('MM/dd/yyyy') : null;
            patenrol.Gender__c = patient.pat_gender_gne__c;
            patenrol.Suffix_gne__c = patient.Suffix_gne__c;
            patenrol.Home_Phone_gne__c = patient.pat_home_phone_gne__c;
            patenrol.PAN_Form_1_Product_gne__c = patient.PAN_Form_1_Product_gne__c;
            patenrol.PAN_Form_2_Product_gne__c = patient.PAN_Form_2_Product_gne__c;            
            patenrol.PAN_Form_1_Rec_gne__c              =  patient.PAN_Form_Rec_gne__c;
            patenrol.PAN_Form_2_Rec_gne__c              =  patient.PAN_Form_2_Rec_gne__c;
            patenrol.PAN_Form_1_Signed_gne__c           =  patient.PAN_Form_Signed_gne__c;
            patenrol.PAN_Form_2_Signed_gne__c           =  patient.PAN_Form_2_Signed_gne__c;
            patenrol.PAN_Form_1_Consent_Received_gne__c =  patient.PAN_Form_1_Consent_Received_gne__c;
            patenrol.PAN_Form_1_Phone_Number_gne__c     =  patient.PAN_Form_1_Phone_Number_gne__c;
            patenrol.PAN_Form_2_Consent_Received_gne__c =  patient.PAN_Form_2_Consent_Received_gne__c;
            patenrol.PAN_Form_2_Phone_Number_gne__c     =  patient.PAN_Form_2_Phone_Number_gne__c;            
            patenrol.Other_Phone_gne__c                 =  patient.pat_other_phone_gne__c;
            patenrol.Preferred_Language_gne__c          =  patient.Preferred_Language_gne__c;
            patenrol.Other_Phone_Type_gne__c            =  patient.pat_other_phone_type_gne__c;
            patenrol.SSN_gne__c                         =  patient.ssn_gne__c;
            patenrol.Work_or_Cell_Phone_gne__c          =  patient.pat_work_phone_gne__c;
            patenrol.OK_to_Contact_Patient__c           =  patient.OK_to_Contact_Patient_gne__c;
            patenrol.Mid_Initial_gne__c                 =  patient.Mid_Initial_gne__c;
            patEmailAdd = patient.pat_email_gne__c;
            patFirstName = GlobalUtils.escapeForJS(patient.pat_first_name_gne__c);
            patLastName = GlobalUtils.escapeForJS(patient.Name);
        } 
        
        // MultiSelect
        selectedPanReasons = new List<SelectOption>();
        selectedReasons =  new List<SelectOption>();        
        
        if (patenrol.Case_Enrollment_Not_Complete_Reason_gne__c!=null)
        {
            for (string s : patenrol.Case_Enrollment_Not_Complete_Reason_gne__c.split(';'))
            {                   
                if (s.toLowerCase().contains('pan')) 
                {
                    selectedPanReasons.add(new SelectOption(s, s));
                } 
                selectedReasons.add(new SelectOption(s, s));
            }
        }
        
        // Use current Case values
        Schema.DescribeFieldResult fieldResult = Case.Enrollment_Not_Complete_Reason_gne__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        
        allPanReasons = new List<SelectOption>();
        
        allReasons = new List<SelectOption>();            
        
        // really hate to do this but there's no (good) way 
        // to get record type specific picklist values in apex
        for (string s : new List<String> {
                                'In Grace Period - Old PAN version',
                                'In Grace Period - Old SMN version',
                                'Invalid Rx',
                                'Invalid SMN',
                                'Missing Pt Info',
                                'No Financial Info Recd',
                                'No Diagnosis Code',
                                'No Insurance Info',
                                'No PAN Received',
                                'No Service Boxes Checked',
                                'No SMN',
                                'Old Version of PAN',
                                'Old Version of SMN',
                                'Pages Missing from Fax',
                                'PAN expired',
                                'PAN Not Signed/Dated',
                                'Provider Info Missing',
                                'SMN Signature Missing',
                                'Unnecessary Document Received',
                                'Zelboraf Sent to the wrong fax number'})                               
        
        {
            
            if (s.toLowerCase().contains('pan')) 
            {
                if (s != 'In Grace Period - Old PAN version'){
                allPanReasons.add(new SelectOption(s, s));}
            } 
            
            allReasons.add(new SelectOption(s, s));
            //allPanReasons.add(new SelectOption(p, p));
        }   
                         
        allPanReasons.sort();
        allReasons.sort();

// DSO 12/11/2014 PFS-1863, Pegasys sunset for C&R                    
        if (patenrol.Product_gne__c == 'Pegasys') 
        {
            isPegasysCR=true;
            GATCF_case=true; // set GATCF to checked as default for Pegasys
        }


    }  // end of constructor      
        
    public String productList { get; set; }        
    public List<String> productNameList { get; set; }  
    public Map<String, String> productLabelMap { get; set; }  
   
    public List<Case> CRSList { get; set; }     
    
    public override void componentControllerSetupComplete(String product) {
        GNE_CM_IntPer_MH_Base_Ctrllr compCtrllr=getComponentControllerMap().get(product);
        
        CRSList=new List<Case>();
        rxMap = new Map<String,String>();
        productNameList = new List<String>();
        productLabelMap = new Map<String, String>();
        productList='';
        for (String s : compCtrllr.getMHKeys())
        {
            productList += (productList!='' ? ';' : '');
            productList += s;
            
            CRSList.add(new Case(Product_gne__c=s));

            rxMap.put(s, '');
            productNameList.add(s);

            if (s=='Lucentis_1')
                productLabelMap.put(s, 'Lucentis OD');
            else if (s=='Lucentis_2')
                productLabelMap.put(s, 'Lucentis OS');
            else if (s=='Activase_1')
                productLabelMap.put(s, 'Activase');
            else if (s=='Activase_2')
                productLabelMap.put(s, 'Cathflo Activase 2mg');
            else if (s=='TNKase_1')
                productLabelMap.put(s, 'TNKase');
            else 
                productLabelMap.put(s, s);

        }
    }
            

    // Insert/Update patient & Insert/Update PER & Insert/update MH & Insert cases

    public PageReference insertPatPerMhCase()
    {
        Boolean isincomplete=false;
        Boolean checkZip_Pat = true;
        Boolean checkEmail_Pat = true;
        Boolean chekDob = true;
        Boolean checkPatPh = true;
        Boolean checkPatWPh = true;
        Boolean checkInsPrPh = true;                 
        error_patWPh = false;
        error_patPh = false;
        error_patOPh = false;
        error_insPrPh = false;
        error_insSecPh = false;
        error_pat_zip = false;
        error_dob = false;
        error_Pat_Name = false; 
        Boolean InvalidFormatFlag = false;
        
        Savepoint sp = Database.setSavepoint();
        
        try 
        {   
            // will add messages for errors
            testCaseComplete(CR_case, CR_GES_case, GATCF_case, patenrol);
            
            // validate zip format 
            if (patenrol.Zip__c != Null)
            {
                checkzip_pat = validateZip(patenrol.Zip__c);
                if (!checkzip_pat)
                {
                    error_pat_zip = true;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Patient Zip: Invalid format.');
                    ApexPages.addMessage(myMsg);
                }
                else
                {
                    error_pat_zip = false;
                }
            }
            
            //   validate email format
            if (patEmailAdd!= null)
            {        
                patEmailAdd= patEmailAdd.replace(' ','');
            }  
            
            if (patEmailAdd != Null && patEmailAdd != '' )
            {
                checkEmail_pat = GNE_CM_MPS_Utils.validateEmail(patEmailAdd);
                system.debug('INSISE CHECK EMAIL:::');
                if (!checkEmail_pat)
                {
                    system.debug('INSISE INVALID EMAIL:::' + error_pat_email);
                    error_pat_email = true;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Patient Email: Invalid format.');
                    ApexPages.addMessage(myMsg);
                }
                else
                {
                    error_pat_email = false;
                    patenrol.Email_Address_gne__c = patEmailAdd;               
                }
            }
            else
            { 
                patenrol.Email_Address_gne__c = null;
            }
            
            // validate DOB format 
            if  (patenrol.DOB_gne__c!=null && patenrol.DOB_gne__c!='')
            {
                if (!GNE_CM_MPS_Utils.checkForDate(patenrol.DOB_gne__c)) 
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Date of Birth: Invalid Date.'));
                }
                else if (Date.parse(patenrol.DOB_gne__c) >= System.Today())
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Date of Birth: Must be in the past.'));
                }
            }                        

            // validate Home Phone Number  format 
            if (patenrol.Home_Phone_gne__c != Null)
            {
                system.debug('HOME PHONE::::: ' + patenrol.Home_Phone_gne__c);
                checkPatPh = GNE_CM_MPS_Utils.validatePhone(patenrol.Home_Phone_gne__c);
                if (!checkPatPh)
                {
                    error_patPh = true;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Patient Home Phone: Invalid format.');
                    ApexPages.addMessage(myMsg);
                }
                else
                {
                    error_patPh = false;                
                }
            }
            
            
            // validate  work phone  Number  format 
            if (patenrol.Work_or_Cell_Phone_gne__c != Null)
            {
                system.debug('HOME PHONE::::: ' + patenrol.Home_Phone_gne__c);
                checkPatWPh = GNE_CM_MPS_Utils.validatePhone(patenrol.Work_or_Cell_Phone_gne__c);
                if (!checkPatWPh)
                {
                    error_patWPh = true;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Patient Work Phone: Invalid format.');
                    ApexPages.addMessage(myMsg);
                }
                else 
                {
                    error_patWPh = false;                
                }
            }
            
            // validate  other phone  Number  format 
            if (patenrol.Other_Phone_gne__c != Null)
            {
                if (!GNE_CM_MPS_Utils.validatePhone(patenrol.Other_Phone_gne__c))
                {
                    error_patOPh = true;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Patient Other Phone: Invalid format.');
                    ApexPages.addMessage(myMsg);
                }
                else 
                {
                    error_patOPh = false;                
                }
            }
            
            // validate  primary isurance  phone  Number  format 
            
            
            if (patenrol.PI_Phone_gne__c != Null)
            {
                checkInsPrPh = GNE_CM_MPS_Utils.validatePhone(patenrol.PI_Phone_gne__c);
                if (!checkInsPrPh)
                {
                    error_insPrPh = true;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error,'Primary Insurance Phone: Invalid format.');
                    ApexPages.addMessage(myMsg);
                }
                else
                {
                    error_insPrPh = false;                
                }
            }
           
            if (ApexPages.hasMessages() || error_pat_zip || error_dob  || error_patPh || error_patWPh)
            {
                return null;
            }
            else
            {
                // Update Patient record
                patient.pat_dob_gne__c     =  (patenrol.DOB_gne__c!=null && patenrol.DOB_gne__c!='') ? date.parse(patenrol.DOB_gne__c) : null;  
                patient.Mid_Initial_gne__c =  patenrol.Mid_Initial_gne__c;
                
                patient.Name = patenrol.Last_Name_gne__c;
                
                // patient=30 chars, per=80 chars
                patient.pat_first_name_gne__c  = GNE_CM_MPS_ReEnroll.truncateValue(patenrol.First_Name_gne__c, Patient_gne__c.pat_first_name_gne__c.getDescribe());
                
                patient.Suffix_gne__c = patenrol.Suffix_gne__c;
                
                patient.pat_gender_gne__c  =  Patenrol.Gender__c;
                patient.pat_home_phone_gne__c = patenrol.Home_Phone_gne__c;
                patient.pat_work_phone_gne__c = patenrol.Work_or_Cell_Phone_gne__c;
                patient.pat_other_phone_type_gne__c = patenrol.Other_Phone_Type_gne__c;
                patient.pat_other_phone_gne__c = patenrol.Other_Phone_gne__c;
                patient.Preferred_Language_gne__c = patenrol.Preferred_Language_gne__c;
                
                patient.Is_yes_is_death_disease_progression_gne__c=patenrol.Is_yes_is_death_disease_progression_gne__c;
                patient.pat_patient_deceased_gne__c=patenrol.Is_Patient_Deceased_gne__c;                
                patient.pat_email_gne__c = patEmailAdd;             
                patient.OK_to_Contact_Patient_gne__c = patenrol.OK_to_Contact_Patient__c;          
                patient.ssn_gne__c = String.valueof(patenrol.SSN_gne__c);
                patient.Preferred_Language_gne__c = patenrol.Preferred_Language_gne__c;
                patient.PAN_Form_1_Product_gne__c =  patenrol.PAN_Form_1_Product_gne__c ;
                patient.PAN_Form_2_Product_gne__c =  patenrol.PAN_Form_2_Product_gne__c ;         
                patient.PAN_Form_Rec_gne__c = patenrol.PAN_Form_1_Rec_gne__c ;
                patient.PAN_Form_2_Rec_gne__c = patenrol.PAN_Form_2_Rec_gne__c ;
                patient.PAN_Form_Signed_gne__c = patenrol.PAN_Form_1_Signed_gne__c ;        
                patient.PAN_Form_2_Signed_gne__c = patenrol.PAN_Form_2_Signed_gne__c;
                patient.PAN_Form_1_Consent_Received_gne__c  =  patenrol.PAN_Form_1_Consent_Received_gne__c;  
                patient.PAN_Form_1_Phone_Number_gne__c      =  patenrol.PAN_Form_1_Phone_Number_gne__c;
                patient.PAN_Form_2_Consent_Received_gne__c  =  patenrol.PAN_Form_2_Consent_Received_gne__c;
                patient.PAN_Form_2_Phone_Number_gne__c      =  patenrol.PAN_Form_2_Phone_Number_gne__c; 
                
                patient.Welcome_Call_Spoke_to_Pt_Pt_Contact_gne__c      =  patenrol.Welcome_Call_Spoke_to_Pt_Pt_Contact_gne__c; 
                patient.Welcome_Call_Reason_gne__c      =  patenrol.Welcome_Call_Reason_gne__c; 
                patient.Welcome_Call_Date_gne__c      =  patenrol.Welcome_Call_Date_gne__c; 
                patient.BR_Opt_in_gne__c = patenrol.OCRE_Benefits_Reverification_gne__c;
                patient.BR_Expiration_Date_gne__c = patenrol.OCRE_BR_Expiration_Date_gne__c;
                
                //if state is NULL set default expiry date               
            	if (patenrol.State_gne__c ==null) {
                GNE_CM_PAN_Expiration_Years__c p = GNE_CM_PAN_Expiration_Years__c.getValues('DFLT');
                integer dfltExp =1;
                
                if (p != null) 
                	dfltExp = Integer.valueOf(p.Number_of_Years__c);
                	
                if (patenrol.PAN_Form_1_Signed_gne__c!=null )
                    patient.PAN_Form_1_Expiration_Date_gne__c = patenrol.PAN_Form_1_Signed_gne__c.addYears(dfltExp); 
                                
                if (patenrol.PAN_Form_2_Signed_gne__c!=null)               
                    patient.PAN_Form_2_Exipration_Date_gne__c = patenrol.PAN_Form_2_Signed_gne__c.addYears(dfltExp);
                                 
            	}
                
                database.update(patient);  
                       
                patenrol.PAN_Incomplete_Reason_gne__c = saveMS(selectedPanReasons);                
                patenrol.Case_Enrollment_Not_Complete_Reason_gne__c = saveMS(selectedReasons);  
                patenrol.Email_Address_gne__c  =  patEmailAdd;
                patenrol.Status__c = 'Processed by Intake';
                patenrol.Specialty_Pharmacy_Note_gne__c = specPharmNotes;
                
                /* The intake per is no longer used
                   after the case is created
                if (patenrol.Id!=null) 
                {
                    database.update(patenrol); 
                }
                else
                {
                    database.insert(patenrol); 
                }    
                */ 
            }
            
            // update/insert patient primary address record. 
            
            List<Patient_Address_gne__c> perToPatAddressList  = lstPrimePatAddress(PatRecId);                     
            if (perToPatAddressList != null && perToPatAddressList.size() > 0) 
            {
                Patient_Address_gne__c perToPatAddressUpdate = perToPatAddressList[0];
                perToPatAddressUpdate.Address_Line_1_gne__c = patenrol.Street_gne__c;
                perToPatAddressUpdate.Address_Line_2_gne__c = patenrol.Street2_gne__c;
                perToPatAddressUpdate.Country_gne__c = hiddenPatientAddressCountry ;
                perToPatAddressUpdate.City_gne__c = patenrol.City_gne__c;
                perToPatAddressUpdate.Zip_gne__c =  patenrol.Zip__c;
                perToPatAddressUpdate.State_gne__c =  patenrol.State_gne__c;
                perToPatAddressUpdate.Phone_gne__c = patenrol.Home_Phone_gne__c; 
                perToPatAddressUpdate.Type_gne__c=perToPatAddressUpdate.Type_gne__c==null ? 'Home' : perToPatAddressUpdate.Type_gne__c;
                database.update(perToPatAddressUpdate);
            }
            else
            {
                Patient_Address_gne__c perToPatAddressInsert = new Patient_Address_gne__c();
                perToPatAddressInsert.Patient_gne__c = PatRecId;
                perToPatAddressInsert.Address_Line_1_gne__c = patenrol.Street_gne__c;
                perToPatAddressInsert.Address_Line_2_gne__c = patenrol.Street2_gne__c;
                perToPatAddressInsert.Country_gne__c = hiddenPatientAddressCountry ;
                perToPatAddressInsert.City_gne__c = patenrol.City_gne__c;
                perToPatAddressInsert.Zip_gne__c =  patenrol.Zip__c;
                perToPatAddressInsert.State_gne__c =  patenrol.State_gne__c;
                perToPatAddressInsert.Phone_gne__c = patenrol.Home_Phone_gne__c;           
                perToPatAddressInsert.Primary_Address_gne__c = 'Yes';
                perToPatAddressInsert.Type_gne__c='Home';                
                if (!donotCreateAddress && patenrol.State_gne__c != null)
                {
                    database.insert(perToPatAddressInsert);
                }
            } 
            
            GNE_CM_IntPer_MH_Base_Ctrllr compCtrllr=getComponentControllerMap().get(patenrol.Product_gne__c);
            Map<String,String> mHIdProductMap = null;      
            
            if (compCtrllr.validateInput())
            {
	            if (!compCtrllr.medicalHistoryFetchFromDB) 
	            {
	            	compCtrllr.medicalHistory = compCtrllr.medicalHistory.clone(); 
	            }
                // make sure the GNE_CM_medical_history_trigger fires
                GNE_CM_case_trigger_monitor.resetTriggerInProcessTrig1();              
                mHIdProductMap=compCtrllr.saveMH();            
                
            }
            else
            {
                return null;    
            }
            
            // Case creation code
            Map<String,List<String>> generateCasesMap = new Map<String,List<String>>();  
            List<String> selectedcaseList = new List<String>();
            
            Set<String> productListSet = new Set<String>();
            
            if (CR_case == true)
            {
                selectedcaseList.add('C&R - Standard Case');
            }
            
            if (CR_GES_case == true)
            {
                selectedcaseList.add('C&R - Standard Case');
                selectedcaseList.add('GATCF - Eligibility Screening');
            }
            if (GATCF_case == true)
            {
                selectedcaseList.add('GATCF - Standard Case');
            }
            
            
            for (String eachproduct : mHIdProductMap.keyset())
            {                   
                generateCasesMap.put(eachproduct, selectedcaseList);                         
            }
            
            // 
            // create a map for Reimbursment Spec
            Map<String,String> mapReimSpec=new Map<String,String>();
            // PFS-1350: 
            String genericRSUserId=GNE_CM_Task_Queue_Mgmt_Helper.getRSGenericUserId();
            
            for (Case cs : CRSList)
            {
                // PFS-1350: 
                mapReimSpec.put(cs.Product_gne__c, genericRSUserId);
                /* PFS-1350:  not used with RS Queue
                if (cs.Reimbursement_Specialist_gne__c!=null)
                {
                    mapReimSpec.put(cs.Product_gne__c, cs.Reimbursement_Specialist_gne__c);
                }
                */
            }
            
            // create cases
            List<Case> cases = GNE_CM_IntPer_Case_Generate.generateCases(generateCasesMap, PatRecId, patenrol, mHIdProductMap, mapReimSpec);
            
            // insurances are only inserted for C&R cases
            if (CR_case || CR_GES_Case)
            {
                // find C&R case on the list
                Id crCaseRecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('C&R - Standard Case').getRecordTypeId();
                Set<Id> crCaseIds = new Set<Id>();

                for (Case c : cases)
                {
                    if (c.recordTypeId == crCaseRecordTypeId)
                    {
                        crCaseIds.add(c.Id);
                    }
                }
                
                if (crCaseIds == null)
                {
                    throw new GNE_CM_Exception('C&R case not created although selected');
                }
                // insert insurances
                insertInsurances(this.insuranceWrappers, crCaseIds);
            }
        }
        catch(Exception e)
        { 
            ApexPages.addMessages(e);
            Database.rollback(sp); // mainly to rollback the case creation, if insurance fails we don't want cases.
            return null;
        }
        PageReference patPage = new PageReference('/' + PatRecId);
        patPage.setRedirect(true);              
        return patPage;
    }
    
    /**
     * Inserts insurances and binds them to the specified case.
     */ 
    private void insertInsurances (List<InsuranceWrapper> wrappers, Set<Id> caseIds)
    {
        List<Insurance_gne__c> unwrappedInsurance = new List<Insurance_gne__c>();
        List<Insurance_gne__c> insurancesToInsert = new List<Insurance_gne__c>();

        for (InsuranceWrapper wrapper : wrappers)
        {
            wrapper.insuranceObjWrap.Case_Insurance_gne__c = null;
            unwrappedInsurance.add(wrapper.insuranceObjWrap);
        }

        for (Id cId : caseIds)
        {
            List<Insurance_gne__c> clonedInsurances = new List<Insurance_gne__c>(unwrappedInsurance.deepClone());

            for (Insurance_gne__c ins : clonedInsurances)
            {
                ins.Case_Insurance_gne__c = cId;
                insurancesToInsert.add(ins);
            }
        }
        insert insurancesToInsert;
    }
    
    // Method for cancel button 
    
    public PageReference cancelIntake()
    {
        try
        {
            PageReference p = new PageReference('/apex/GNE_CM_Patient_Search');
            p.setRedirect(true);
            return p;
        }
        catch (Exception e)
        {
            ApexPages.addMessages(e);  
            return null;
        }
    }

        
    public static Map<String,String> testCaseComplete(Boolean cr, Boolean crges, Boolean gatcf, Patient_Enrollment_Request_gne__c per)
    {
        Map<String,String> mapErrs=new  Map<String,String>();
        
        if (!(cr || crges || gatcf))
        {
            mapErrs.put('CR_Case', 'Required field.');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,' Please select at least one case type.'));
        }

        if ((crges && (cr || gatcf)))
        {
            mapErrs.put('CR_GES_case', 'Invalid combination.');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,' C&R/GES can only be selected by itself.'));
        }

        if (cr || crges || gatcf)
        {
            if (per.Prescriber_gne__c==null)
            {
                mapErrs.put('Prescriber_gne__c', 'Invalid combination.');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select a Prescriber.'));
            }

            if (per.Case_Referral_by_Date_gne__c==null)
            {
                mapErrs.put('Case_Referral_by_Date_gne__c', 'Required Field.');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Referred By Date: Please enter a value.'));
            }

            if (per.Case_Referred_By_Type_gne__c==null)
            {
                mapErrs.put('Case_Referred_By_Type_gne__c', 'Required Field.');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Referred By Type: Please enter a value.'));
            }

            if (per.Case_Referral_Reason_gne__c==null)
            {
                mapErrs.put('Case_Referral_Reason_gne__c', 'Required Field.');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Referred By Reason: Please enter a value.'));
            }
            /**/
            if (per.Case_Enrollment_Form_Rec_gne__c==null)
            {
                mapErrs.put('Case_Enrollment_Form_Rec_gne__c', 'Required Field.');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Enroll / SMN Form Rec: Please enter a value.'));
            }
            
            if (per.Case_Enroll_Comp_Original_Receipt_gne__c==null)
            {
                mapErrs.put('Case_Enroll_Comp_Original_Receipt_gne__c', 'Required Field.');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Enroll Complete Upon Original Receipt: Please enter a value.'));
            }

            if ((per.Case_Referred_By_Type_gne__c == 'Hospital' ||
                    per.Case_Referred_By_Type_gne__c == 'Distributor' ||
                    per.Case_Referred_By_Type_gne__c == 'Nurse Practitioner' ||
                    per.Case_Referred_By_Type_gne__c == 'Physician/MDO') && per.Case_Referred_By_Party_gne__c==null)
            {
                mapErrs.put('Case_Referred_By_Type_gne__c', 'Required Field.');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select a Referred by Party.'));
            }
        
        }

        if (cr || crges)
        {
            if (per.Case_Manager_gne__c==null)
            {
                mapErrs.put('Case_Manager_gne__c', 'Required Field.');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select a Case Manger.'));
            }
        }
        
        return mapErrs;
    }        
        
    // Wrapper class for Patient Address 
    
    public class wrapPatAddress
    {
            public Patient_Address_gne__c patAddObjWrap{ get; set; }
            public boolean editFlagPatAddress { get; set; }
            public boolean saveFlagPatAddress { get; set; }
            public boolean editFlagPatAddressLink { get; set; }
            public boolean saveFlagPatAddressLink { get; set; }
            public wrapPatAddress(Patient_Address_gne__c patAddObjWrap)
            {
                    this.patAddObjWrap = patAddObjWrap;
                    editFlagPatAddress = true;
                    saveFlagPatAddress = false;
                    editFlagPatAddressLink = true;
                    saveFlagPatAddressLink = false;
            }
    }
    
    // Getting Patient Address info 
    
    public List<Patient_Address_gne__c> getPatientAddressData(string patientId)
    {
            List<Patient_Address_gne__c> lstPatAdd = [Select Type_gne__c,Address_Line_1_gne__c,Address_Line_2_gne__c,Other_Phone_gne__c,Phone_gne__c,Primary_Address_gne__c,City_gne__c,Country_gne__c,Zip_gne__c,State_gne__c from Patient_Address_gne__c  where Patient_gne__c = :patientId];
            return lstPatAdd;
    }
    
    
    
    public List<Patient_Address_gne__c> lstPatAddress(string patId)
    {
            List<Patient_Address_gne__c> lstPatAdd = [Select id,Name,Type_gne__c,Address_Line_1_gne__c,Address_Line_2_gne__c,City_gne__c,Country_gne__c,Other_Phone_gne__c,Patient_gne__c,Patient_gne__r.pat_gender_gne__c,Phone_gne__c,State_gne__c,Zip_gne__c from Patient_Address_gne__c where Patient_gne__c = : patId order by createddate desc limit 1]; 
            return lstPatAdd;
    } 
    
    public List<Patient_Address_gne__c> lstPrimePatAddress(string patId)
    {               
            List<Patient_Address_gne__c> lstPrimePatAdd  = [Select id,Name,Type_gne__c,Address_Line_1_gne__c,Address_Line_2_gne__c,City_gne__c,Country_gne__c,Other_Phone_gne__c,Patient_gne__c,Patient_gne__r.pat_gender_gne__c,Phone_gne__c,State_gne__c,Zip_gne__c from Patient_Address_gne__c where Patient_gne__c = : patId and Primary_Address_gne__c = 'Yes' order by createddate desc limit 1];                               
            return lstPrimePatAdd;
    }
    
    
    // Adding each address to lstwrapPatAddress 
    
    public void getPatAddressData()
    {
            if (lstPatAddress != null && lstPatAddress.size() > 0)
            {
                    for (Patient_Address_gne__c patAdd : lstPatAddress)
                    {               
                if (patAdd.Primary_Address_gne__c != 'Yes')
                { 
                    // RM Added to filter out primary address from the list
                                    wrapPatAddress wrap = new wrapPatAddress(patAdd);
                                    lstwrapPatAddress.add(wrap);
                            }
                    }
            }
    }
    
    // Method for New Patient Addres Button 
    
    public PageReference newPatAddress()
    {
            flagNewAddress = true;
            btnPatAddFlag  = false;
            patAddressObj = new Patient_Address_gne__c();
            patAddressObj.Address_Line_1_gne__c = '';
            patAddressObj.Address_Line_2_gne__c = '';
            patAddressObj.City_gne__c = '';
            patAddressObj.Country_gne__c = 'USA';
            patAddressObj.Zip_gne__c = '';
            patAddressObj.Phone_gne__c = null;
            return null;
    }
    
    
    // Method to save New Patient Record 
    
    public PageReference saveNewPatAddress()
    {
            flagNewAddress = false;
            btnPatAddFlag  = true;
            if (PatRecId != null)   
            {
                    if (patAddressObj.Type_gne__c != null ||
                                    patAddressObj.Address_Line_1_gne__c != null ||
                                    patAddressObj.Address_Line_2_gne__c != null ||
                                    patAddressObj.City_gne__c != null ||
                                    patAddressObj.Country_gne__c != null ||
                                    patAddressObj.Zip_gne__c != null ||
                                    patAddressObj.Phone_gne__c != null
                                    ) {
                            patAddressObj.Patient_gne__c = PatRecId;
                            patAddressObj.Primary_Address_gne__c = 'No';                                
                            insert patAddressObj;
                            lstwrapPatAddress.clear();
                            lstPatAddress  = getPatientAddressData(PatRecId);
                            getPatAddressData();
                    } else {
                            return null;
                    }
            }
            return null;
    }
    
    // Method to cancel new patient record 
    
    public PageReference CancelNewPatAddress()
    {
            btnPatAddFlag = true;
            flagNewAddress = false;
            return null;
    }
    
    
    // Method for edit existing patient record
    
    public PageReference editMethodPatAddress()
    {
            btnPatAddFlag = false;
            if (lstwrapPatAddress != null && lstwrapPatAddress.size() > 0)
            {
                    for (wrapPatAddress obj : lstwrapPatAddress)
                    {
                            if (isEditValue == obj.patAddObjWrap.id)
                            {
                                    obj.editFlagPatAddress = false;
                                    obj.saveFlagPatAddress = true;
                                    obj.editFlagPatAddressLink = false;
                                    obj.saveFlagPatAddressLink = true;
                            }
                            if (isEditValue != obj.patAddObjWrap.id)
                            {
                                    obj.editFlagPatAddressLink = false;
                                    obj.saveFlagPatAddressLink = false;
                            }
                    }
            }
            
            return null;
    }
    
    // Method for save  existing patient record 
    
    public PageReference saveMethodPatAddress()
    {
            List<Patient_Address_gne__c> lstPatAddToUpdate = new List<Patient_Address_gne__c>();
            if (lstwrapPatAddress != null && lstwrapPatAddress.size() > 0)
            {
                    for (wrapPatAddress obj : lstwrapPatAddress)
                    {
                            if (isEditValue == obj.patAddObjWrap.id)
                            {
                                    obj.editFlagPatAddress = true;
                                    obj.saveFlagPatAddress = false;
                                    obj.editFlagPatAddressLink = true;
                                    obj.saveFlagPatAddressLink = false;
                                    Patient_Address_gne__c pat = new Patient_Address_gne__c(id = obj.patAddObjWrap.id);
                                    pat.Type_gne__c            = obj.patAddObjWrap.Type_gne__c;
                                    pat.Address_Line_1_gne__c  = obj.patAddObjWrap.Address_Line_1_gne__c;
                                    pat.Address_Line_2_gne__c  = obj.patAddObjWrap.Address_Line_2_gne__c;
                                    pat.Country_gne__c         = obj.patAddObjWrap.Country_gne__c;
                                    pat.City_gne__c            = obj.patAddObjWrap.City_gne__c;
                                    pat.State_gne__c           = obj.patAddObjWrap.State_gne__c;
                                    pat.Zip_gne__c             = obj.patAddObjWrap.Zip_gne__c;
                                    pat.Phone_gne__c           = obj.patAddObjWrap.Phone_gne__c;
                                    lstPatAddToUpdate.add(pat);
                            }
                            if (isEditValue != obj.patAddObjWrap.id){
                                    obj.editFlagPatAddressLink = true;
                                    obj.saveFlagPatAddressLink = false;
                            }
                    }
                    btnPatAddFlag = true;
            }
            if (lstPatAddToUpdate != null && lstPatAddToUpdate.size() > 0)
            {
                    update lstPatAddToUpdate;
                    lstwrapPatAddress.clear();
                    lstPatAddress  = getPatientAddressData(PatRecId);
                    getPatAddressData();
            }
            return null;
    }
    
    // Method for cancel existing patient record 
    
    public PageReference CancelBtnEdit()
    {
            if (lstwrapPatAddress != null && lstwrapPatAddress.size() > 0)
            {
                    for (wrapPatAddress obj : lstwrapPatAddress)
                    {
                            if (isEditValue == obj.patAddObjWrap.id)
                            {
                                    obj.editFlagPatAddress = true;
                                    obj.saveFlagPatAddress = false;
                                    obj.editFlagPatAddressLink = true;
                                    obj.saveFlagPatAddressLink = false; 
                            }
                            if (isEditValue != obj.patAddObjWrap.id){
                                    obj.editFlagPatAddressLink = true;
                                    obj.saveFlagPatAddressLink = false;
                            }
                    }
                    btnPatAddFlag = true;
                    lstwrapPatAddress.clear();
                    lstPatAddress  = getPatientAddressData(PatRecId);
                    getPatAddressData();
            }
            return null;
    }
    
   
    public class wrapPatContact
    {
            public Patient_Contact_gne__c patConObjWrap{ get; set; }
            public boolean editFlagPatContact { get; set; }
            public boolean saveFlagPatContact { get; set; }
            public boolean editFlagPatContactLink { get; set; }
            public boolean saveFlagPatContactLink { get; set; }
            public wrapPatContact(Patient_Contact_gne__c patConObjWrap)
            {
                    this.patConObjWrap = patConObjWrap;
                    editFlagPatContact = true;
                    saveFlagPatContact = false;
                    editFlagPatContactLink = true;
                    saveFlagPatContactLink = false;
            }
    }
    
    public void getPatientContact()
    {
            if (lstPatContact != null && lstPatContact.size() > 0)
            {
                    for (Patient_Contact_gne__c pat : lstPatContact)
                    {
                            wrapPatContact wrap = new wrapPatContact(pat);
                            lstwrapPatContact.add(wrap);    
                    }
            }
    }
    public List<Patient_Contact_gne__c> getPatientContactData(string patientId)
    {
            List<Patient_Contact_gne__c> lstPatCon = [Select Id,Name,pat_con_Street_gne__c,pat_con_Mail_Box_gne__c,pat_con_City_gne__c ,pat_con_Home_Phone_gne__c,pat_con_Contact_Type_gne__c, pat_con_Relationship_to_Patient_gne__c,LAST_NAME_CONT_gne__c,pat_con_Email_gne__c,First_Name_gne__c,pat_con_State_gne__c,pat_con_Zip_gne__c,Country_gne__c,  pat_con_VIP_Note_gne__c from Patient_Contact_gne__c  where pat_con_Patient_gne__c = :patientId];
            return lstPatCon;
            
    }
    public PageReference newPatContact()
    {
            flagNewContact = true;
            btnPatConFlag  = false;
            adrsSameAsPat = false;
            patConObj = new Patient_Contact_gne__c();
            patConObj.pat_con_Contact_Type_gne__c = null;
            patConObj.pat_con_Relationship_to_Patient_gne__c = null;
            patConObj.First_Name_gne__c = null;
            patConObj.LAST_NAME_CONT_gne__c = null;
            patConObj.pat_con_Street_gne__c = null;
            patConObj.pat_con_Mail_Box_gne__c = null;
            patConObj.pat_con_City_gne__c = null;
            patConObj.pat_con_State_gne__c = null;
            patConObj.pat_con_Zip_gne__c = null;
            patConObj.Country_gne__c = 'USA';
            patConObj.pat_con_Home_Phone_gne__c = null;
            patConObj.pat_con_VIP_Note_gne__c=null;
            return null;
    }
    public PageReference saveNewPatContact()
    {
            flagNewContact = false;
            btnPatConFlag  = true;
            if (PatRecId != null)
            {
                    if (patConObj.First_Name_gne__c != null &&
                                    patConObj.LAST_NAME_CONT_gne__c != null
                                    ) {
                            patConObj.pat_con_Patient_gne__c = PatRecId;
                            insert patConObj;
                            lstwrapPatContact.clear();
                            lstPatContact  = getPatientContactData(PatRecId);
                            getPatientContact();
                    } else {
                            return null;
                    }
            }
            return null;
    }
    public PageReference CancelNewPatContact()
    {
            flagNewContact = false;
            btnPatConFlag  = true;
            return null;
    }
    public PageReference editMethodPatContact()
    {
            btnPatConFlag = false;
            if (lstwrapPatContact != null && lstwrapPatContact.size() > 0)
            {
                    for (wrapPatContact obj : lstwrapPatContact)
                    {
                            if (isEditValuePatCon == obj.patConObjWrap.id)
                            {
                                    obj.editFlagPatContact = false;
                                    obj.saveFlagPatContact = true;
                                    obj.editFlagPatContactLink = false;
                                    obj.saveFlagPatContactLink = true;
                            }
                            if (isEditValuePatCon != obj.patConObjWrap.id)
                            {
                                    obj.editFlagPatContactLink = false;
                                    obj.saveFlagPatContactLink = false;
                            }
                    }
            }
            
            return null;
    }
    
    public PageReference saveMethodPatContact()
    {
            List<Patient_Contact_gne__c> lstPatConToUpdate = new List<Patient_Contact_gne__c>();
            if (lstwrapPatContact != null && lstwrapPatContact.size() > 0)
            {
                    for (wrapPatContact obj : lstwrapPatContact)
                    {
                            if (isEditValuePatCon == obj.patConObjWrap.id)
                            {
                                    obj.editFlagPatContact = true;
                                    obj.saveFlagPatContact = false;
                                    obj.editFlagPatContactLink = true;
                                    obj.saveFlagPatContactLink = false;
                                    Patient_Contact_gne__c pat                              = new Patient_Contact_gne__c(id = obj.patConObjWrap.id);
                                    pat.pat_con_Contact_Type_gne__c                         = obj.patConObjWrap.pat_con_Contact_Type_gne__c;
                                    pat.pat_con_Relationship_to_Patient_gne__c              = obj.patConObjWrap.pat_con_Relationship_to_Patient_gne__c;
                                    pat.First_Name_gne__c                                   = obj.patConObjWrap.First_Name_gne__c;
                                    pat.LAST_NAME_CONT_gne__c                               = obj.patConObjWrap.LAST_NAME_CONT_gne__c;
                                    pat.pat_con_Street_gne__c                               = obj.patConObjWrap.pat_con_Street_gne__c;
                                    pat.pat_con_Mail_Box_gne__c                             = obj.patConObjWrap.pat_con_Mail_Box_gne__c;
                                    pat.pat_con_City_gne__c                                 = obj.patConObjWrap.pat_con_City_gne__c;
                                    pat.pat_con_State_gne__c                                = obj.patConObjWrap.pat_con_State_gne__c;
                                    pat.pat_con_Zip_gne__c                                  = obj.patConObjWrap.pat_con_Zip_gne__c;
                                    pat.Country_gne__c                                      = obj.patConObjWrap.Country_gne__c;
                                    pat.pat_con_Home_Phone_gne__c                           = obj.patConObjWrap.pat_con_Home_Phone_gne__c;
                                    pat.pat_con_VIP_Note_gne__c                             = obj.patConObjWrap.pat_con_VIP_Note_gne__c;
                                    lstPatConToUpdate.add(pat);
                            }
                            if (isEditValuePatCon != obj.patConObjWrap.id){
                                    obj.editFlagPatContactLink = true;
                                    obj.saveFlagPatContactLink = false;
                            }
                    }
                    btnPatConFlag = true;
            }
            if (lstPatConToUpdate != null && lstPatConToUpdate.size() > 0)
            {
                    update lstPatConToUpdate;
                    lstwrapPatContact.clear();
                    lstPatContact  = getPatientContactData(PatRecId);
                    getPatientContact();
            }
            return null;
    }
    
    
    public PageReference CancelBtnEditPatCon()
    {
            if (lstwrapPatContact != null && lstwrapPatContact.size() > 0)
            {
                    for (wrapPatContact obj : lstwrapPatContact)
                    {
                            if (isEditValuePatCon == obj.patConObjWrap.id)
                            {
                                    obj.editFlagPatContact = true;
                                    obj.saveFlagPatContact = false;
                                    obj.editFlagPatContactLink = true;
                                    obj.saveFlagPatContactLink = false;
                            }
                            if (isEditValuePatCon != obj.patConObjWrap.id){
                                    obj.editFlagPatContactLink = true;
                                    obj.saveFlagPatContactLink = false;
                            }
                    }
                    btnPatConFlag = true;
                    lstwrapPatContact.clear();
                    lstPatContact  = getPatientContactData(PatRecId);
                    getPatientContact();
            }
            return null;
    }

    // Wrapper block for Insurance
    public class InsuranceWrapper
    {
        public Insurance_gne__c insuranceObjWrap{ get; set; }
        public boolean editFlagInsurance { get; set; }
        public boolean saveFlagInsurance { get; set; }
        public boolean editFlagInsuranceLink { get; set; }
        public boolean saveFlagInsuranceLink { get; set; }
        public Integer index { get; set; }
        
        public InsuranceWrapper(Insurance_gne__c insuranceObjWrap)
        {
            this.insuranceObjWrap = insuranceObjWrap;
            editFlagInsurance = true;
            saveFlagInsurance = false;
            editFlagInsuranceLink = true;
            saveFlagInsuranceLink = false;
        }
    }
    
    /**
     * Initialize insurance wrappers from insurance list.
     */
    public List<InsuranceWrapper> initInsuranceWrappers()
    {
        if (lstInsurance != null && lstInsurance.size() > 0)
        {
            for (Insurance_gne__c ins : lstInsurance)
            {
                InsuranceWrapper wrap = new InsuranceWrapper(ins);
                insuranceWrappers.add(wrap);    
            }
        }
        return insuranceWrappers;
    }

    /**
     * Method called when new insurance form is displayed
     */
    public PageReference newInsurance()
    {
        errorMessages = new List<String>();

        if (insuranceWrappers.size() >= MAX_INSURANCE_NO) 
        {
            errorMessages.add('The maximum of three insurances can be added');
        }
        else
        {
            flagNewInsurance = true;
            btnInsuranceFlag  = false;
            
            // create insurance object
            insuranceObj = new Insurance_gne__c();
        }
        return null;
    }

    public PageReference saveNewInsurance()
    {
        flagNewInsurance = false;
        btnInsuranceFlag  = true;
        if (PatRecId != null)
        {
            if (insuranceObj.Rank_gne__c != null && insuranceObj.Payer_gne__c != null)
            {
                insuranceObj.Patient_Insurance_gne__c = PatRecId;
                
                // add wrapped insurance to list
                InsuranceWrapper wrapper = new InsuranceWrapper(insuranceObj);
                insIndex++;
                wrapper.index = insIndex; 
                insuranceWrappers.add(wrapper);
            }
            else
            {
                return null;
            }
        }
        return null;
    }

    public PageReference cancelNewInsurance()
    {
            flagNewInsurance = false;
            btnInsuranceFlag  = true;
            return null;
    }

    public PageReference editInsurance()
    {
        btnInsuranceFlag = false;
        errorMessages = new List<String>();

        if (insuranceWrappers != null && insuranceWrappers.size() > 0)
        {
            for (InsuranceWrapper obj : insuranceWrappers)
            {
                if (currentInsuranceIndex == obj.index)
                {
                    obj.editFlagInsurance = false;
                    obj.saveFlagInsurance = true;
                    obj.editFlagInsuranceLink = false;
                    obj.saveFlagInsuranceLink = true;
                }
                else
                {
                    obj.editFlagInsuranceLink = false;
                    obj.saveFlagInsuranceLink = false;
                }
            }
        }
        return null;
    }

    public PageReference deleteInsurance()
    {
        errorMessages = new List<String>();
        List<InsuranceWrapper> remainingInsurances = new List<InsuranceWrapper>();

        if (insuranceWrappers != null && insuranceWrappers.size() > 0)
        {
            for (InsuranceWrapper wrapper : insuranceWrappers)
            {
                if (currentInsuranceIndex != wrapper.index) {
                    remainingInsurances.add(wrapper);
                }
            }
            insuranceWrappers = remainingInsurances;
        }
        return null;
    }
    
    public PageReference saveInsurance()
    {
        errorMessages = new List<String>();
        List<InsuranceWrapper> updatedInsurances = new List<InsuranceWrapper>(); 
        if (insuranceWrappers != null && insuranceWrappers.size() > 0)
        {
            for (InsuranceWrapper wrapper : insuranceWrappers)
            {
                if (currentInsuranceIndex == wrapper.index)
                {
                    wrapper.editFlagInsurance = true;
                    wrapper.saveFlagInsurance = false;
                    wrapper.editFlagInsuranceLink = true;
                    wrapper.saveFlagInsuranceLink = false;
                }
                else
                {
                    wrapper.editFlagInsuranceLink = true;
                    wrapper.saveFlagInsuranceLink = false;
                }
                
                updatedInsurances.add(wrapper);
            }
            
            insuranceWrappers = updatedInsurances;
            btnInsuranceFlag = true;
        }
        return null;
    }
    
    public PageReference cancelBtnEditInsurance()
    {
        if (insuranceWrappers != null && insuranceWrappers.size() > 0)
        {
            for (InsuranceWrapper obj : insuranceWrappers)
            {
                if (currentInsuranceIndex == obj.index)
                {
                    obj.editFlagInsurance = true;
                    obj.saveFlagInsurance = false;
                    obj.editFlagInsuranceLink = true;
                    obj.saveFlagInsuranceLink = false;
                }
                else
                {
                    obj.editFlagInsuranceLink = true;
                    obj.saveFlagInsuranceLink = false;
                }
            }
            btnInsuranceFlag = true;
        }
        return null;
    }

    public String saveMS( List<SelectOption> optionsList )
    {
        string optionVals = '';
        Boolean first = true;
        for (SelectOption so : optionsList) {
            if (!first) {
                optionVals += ';';
            }          
            optionVals += so.getValue();
            first = false;
        }       
        return optionVals;
    } 
    
    //   validation method for Zip code format 5 && 5-4  
    public static Boolean validateZip(String zip)
    {           
       Pattern zipPatternFive = Pattern.compile('^([0-9]{5})$');
       Pattern zipPatternTen = Pattern.compile('^([0-9]{5}-[0-9]{4})$');
       Matcher zipMatcherfive = zipPatternFive.matcher(zip);
       Matcher zipMatcherTen =  zipPatternTen.matcher(zip);
       if (zipMatcherfive != null)
       {
            if (zipMatcherfive.matches() || zipMatcherTen.matches())
         {
            return true;
           } 
        }
        return false;
    } 
  
      // to Convert date into Salesforce date format
    private String convert_date_apiformat (String InDate){
        String[] datestringsarray;
        datestringsarray = InDate.split('/');
        return datestringsarray[2] + '-' + datestringsarray[0] + '-' + datestringsarray[1] + ' 00:00:00';
    }
}