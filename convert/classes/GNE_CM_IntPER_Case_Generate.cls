public class GNE_CM_IntPER_Case_Generate 
{
    
    private static Map<Id, Address_vod__c> getAddresses(Patient_Enrollment_Request_gne__c patenrol)
    { 
        if(patenrol != null) {
            List<Id> addressesIds = new List<Id>();
            if (patenrol.Case_Address_gne__c != null) {
                addressesIds.add(patenrol.Case_Address_gne__c);
            }
            if (patenrol.Case_Referred_By_Party_Address_gne__c != null) {
                addressesIds.add(patenrol.Case_Referred_By_Party_Address_gne__c);
            }
            if (addressesIds.size() > 0) {
                return new Map<Id, Address_vod__c>(
                    [
                     SELECT Name, Address_1_gne__c, Address_line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c 
                     FROM Address_vod__c 
                     WHERE Id in :addressesIds
                    ]);
            }
        }
        return new Map<Id, Address_vod__c>();
    }

    private static Map<String, List<GNE_CM_Case_Owner_FRM_Alignment__c>> getFRMAlignments(List<Address_vod__c> addresses, Set<String> products){
        List<String> zipCodes = new List<String>();
        for (Address_vod__c address : addresses) {
            zipCodes.add(address.Zip_vod__c);
        }
        Map<String, List<GNE_CM_Case_Owner_FRM_Alignment__c>> result = new Map<String, List<GNE_CM_Case_Owner_FRM_Alignment__c>>();
        if(zipCodes.size() > 0 && products.size() > 0) {
            List<GNE_CM_Case_Owner_FRM_Alignment__c> frmAlignments = GNE_CM_FRM_Alignment_Helper.searchForFRMAlignment(zipCodes, new List<String>(products));
            for (GNE_CM_Case_Owner_FRM_Alignment__c frmAlignment : frmAlignments) {
                String compositeKey = frmAlignment.GNE_CM_FRM_Zip_gne__c + frmAlignment.GNE_CM_Product_gne__c;
                if (result.get(compositeKey) == null) {
                    result.put(compositeKey, new List<GNE_CM_Case_Owner_FRM_Alignment__c>());
                }
                result.get(compositeKey).add(frmAlignment);
            }
            System.debug(LoggingLevel.error, 'FRM Alignments Size: ' + frmAlignments.size());
        }
        return result;
    }
    
    class ProductCases
    {
        public ProductCases(String prod)
        {
            product=prod;
        }
        public String product { get; set; }
        public Case cnrCase { get; set; }
        public Case gesCase { get; set; }
        public Case gatcfCase { get; set; }
    }

    // ================================================
    // Fetch list of sure start campaigns
    static  Map<String, Campaign> getSureStartMap()
    {
        Map<String, Campaign> mapSureStart=new Map<String, Campaign>();
        
        for (Campaign c : [SELECT Id, Brand_gne__c 
                            FROM Campaign 
                            WHERE (Applied_To_gne__c='Physician' AND Name IN ('Xolair Starter Kit')) OR
                                (Applied_To_gne__c='Patient' AND Name IN ('Sure Start', 'Start Now')) OR
                                (Applied_To_gne__c='Patient' AND Name IN ('Avastin Patient Assistance Program'))])
        {
            if (c.Brand_gne__c!=null)
            {
                mapSureStart.put(c.Brand_gne__c, c);
            }
        }
        return mapSureStart;
    }
    
    // ================================================
    // Populate fields common to all cases
    static Case GenerateBaseCase(String recordTypeName,
        String patientId, 
        Patient_Enrollment_Request_gne__c patenrol, 
        Medical_History_gne__c mh,
        String status,
        String product,
        Map<Id, Address_vod__c> addresses)
    {
        Case baseCase=new Case();

        // ================================================
        // Base Case fields
        baseCase.RecordTypeId=Case.SObjectType.getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        baseCase.Patient_gne__c=patientId;
        //baseCase.Patient_Enrollment_Request_gne__c=patenrol.Id;
        baseCase.Medical_History_gne__c=mh.Id;
        
        baseCase.Product_gne__c=product;
        baseCase.Status=status;
        
        // ===============================================
        // Insurance
        baseCase.Insurance__c=patenrol.Insurance_Note_gne__c;
        
        // ===============================================
        // STAT/Standard BI
        baseCase.Perform_Stat_BI_gne__c=patenrol.Perform_Stat_BI_gne__c; //(patenrol.Perform_Stat_BI_gne__c=='Yes' ? 'Yes' : null);
        baseCase.Perform_Standard_BI_gne__c=patenrol.Perform_Standard_BI_gne__c; //(patenrol.Perform_Standard_BI_gne__c=='Yes' ? 'Yes' : null);
        
        // ================================================
        // Enrollment Stuff
        if (patenrol.Case_Enrollment_Form_Rec_gne__c!=null) 
        {
            baseCase.Enrollment_Form_Rec_gne__c=patenrol.Case_Enrollment_Form_Rec_gne__c;
        }
        baseCase.Enrollment_Form_Time_Received_gne__c=System.now();
        
        
        if (patenrol.Case_Enroll_Comp_Original_Receipt_gne__c!=null)
        {
            baseCase.Enroll_Comp_Original_Receipt_gne__c=patenrol.Case_Enroll_Comp_Original_Receipt_gne__c;
        }
        else
        {
            baseCase.Enroll_Comp_Original_Receipt_gne__c=patenrol.Case_Enrollment_Not_Complete_Reason_gne__c==null ? 'Yes' : 'No';
        }
        baseCase.Enrollment_Not_Complete_Reason_gne__c=patenrol.Case_Enrollment_Not_Complete_Reason_gne__c;

        // set No ICD9 if applicable
        Boolean isCoPay=(!(patenrol.Benefits_Investigation_Prior_Auth_gne__c ||
                patenrol.GATCF_Eligibility_Screening_gne__c ||
                patenrol.Appeals_Support_gne__c ||
                patenrol.GATCF_Patient_Assistance_gne__c) && patenrol.Co_pay_Assistance_gne__c);
                
        if (!isCoPay)
        {
            if (mh.ICD9_Code_1_gne__r.ICD9_Code_gne__c=='999.99')
            {
                baseCase.Enroll_Comp_Original_Receipt_gne__c='No';
                if (baseCase.Enrollment_Not_Complete_Reason_gne__c!=null)
                {
                    if (!baseCase.Enrollment_Not_Complete_Reason_gne__c.contains('No Diagnosis Code'))
                    {
                        baseCase.Enrollment_Not_Complete_Reason_gne__c+=';No Diagnosis Code';
                    }
                }
                else
                {
                    baseCase.Enrollment_Not_Complete_Reason_gne__c='No Diagnosis Code';
                }
            }
        }
                    
                
        // ================================================
        // Prescriber fields
        baseCase.Case_Treating_Physician_gne__c=patenrol.Prescriber_gne__c;
        baseCase.Address_gne__c=patenrol.Case_Address_gne__c;
        baseCase.Practice_gne__c=patenrol.Case_Practice_gne__c;
        baseCase.Facility_gne__c=patenrol.Case_Facility_gne__c;
        
        Address_vod__c prAddr = null;
        if (addresses.containsKey(baseCase.Address_gne__c)) 
        {
            prAddr = addresses.get(baseCase.Address_gne__c);
        }
        // populate of one has been spec'd
        if (prAddr!=null)
        {
            baseCase.Mailbox_gne__c=prAddr.Address_line_2_vod__c;
            baseCase.City_gne__c=prAddr.City_vod__c;
            baseCase.State_Treating_Physician_gne__c=prAddr.State_vod__c;
            baseCase.Zip_gne__c=prAddr.Zip_vod__c;      
        }
        
        
        // ================================================
        // Referred by fields
        baseCase.Referred_By_Type_gne__c=patenrol.Case_Referred_By_Type_gne__c;
        baseCase.Referred_By_Date_gne__c=patenrol.Case_Referral_by_Date_gne__c; //System.today();
        baseCase.Referred_By_Person_gne__c=patenrol.Case_Referral_By_Person_gne__c;
            
        if (baseCase.Referred_By_Type_gne__c=='Patient')
        {
            baseCase.Referred_By_Person_gne__c='Referred By Patient';
        }
        else if (baseCase.Referred_By_Type_gne__c == 'Hospital' ||
                    baseCase.Referred_By_Type_gne__c == 'Distributor' ||
                    baseCase.Referred_By_Type_gne__c == 'Nurse Practitioner' ||
                    baseCase.Referred_By_Type_gne__c == 'Physician/MDO') 
        {
            baseCase.Referred_By_Party_gne__c=patenrol.Case_Referred_By_Party_gne__c;
            baseCase.Referral_Address_Line_1_gne__c=patenrol.Case_Referred_By_Party_Address_gne__c;
            
            
            if (addresses.containsKey(baseCase.Referral_Address_Line_1_gne__c))
            {
                Address_vod__c a = addresses.get(baseCase.Referral_Address_Line_1_gne__c); 
                baseCase.Referral_Address_Line_2_gne__c=a.Address_line_2_vod__c;
                baseCase.Referral_City_gne__c=a.City_vod__c;
                baseCase.Referral_State_gne__c=a.State_vod__c;
                baseCase.Referral_Zip_gne__c=a.Zip_vod__c;
            }
        }
        
        // referral reason
        baseCase.case_referral_reason_gne__c=patenrol.Case_Referral_Reason_gne__c;
        // contact patient
        baseCase.OK_to_Contact_Patient_gne__c=patenrol.OK_to_Contact_Patient__c;
        
        if(recordTypeName == 'C&R - Standard Case') 
        {
            baseCase.DDS_Appeal_Request_gne__c = patenrol.Appeals_Support_gne__c;
            baseCase.DDS_BI_Request_gne__c = patenrol.Benefits_Investigation_Prior_Auth_gne__c; 
            baseCase.DDS_Copay_Card_Request_gne__c = patenrol.Co_pay_Assistance_gne__c;
            baseCase.DDS_Copay_Refer_Request_gne__c = patenrol.Co_pay_Assistance_gne__c;
            baseCase.DDS_Copay_Infusion_Card_Request_gne__c = product==System.Label.GNE_CM_Ocre_Product_Name ? patenrol.Co_pay_Assistance_gne__c : false;
            baseCase.DDS_GES_Request_gne__c = patenrol.GATCF_Eligibility_Screening_gne__c;
            baseCase.DDS_GATCF_Request_gne__c = patenrol.GATCF_Patient_Assistance_gne__c;
        }
        
        return baseCase;    
    }

    // ================================================
    // Helpers to create related insurance records
    public static Insurance_gne__c generateInsurance(String patientId, Patient_Enrollment_Request_gne__c patenrol, String caseId)
    {
        Insurance_gne__c insNew=generateInsuranceBase(patientId, patenrol, caseId);
        if (insNew!=null)
        {
            insert insNew;
        }
        return insNew;
    }
    
    public static Insurance_gne__c generateInsuranceBase(String patientId, Patient_Enrollment_Request_gne__c patenrol, String caseId)
    {
        Insurance_gne__c insNew = null;
        // if we have 
        if (patenrol!=null)
        {
            //Patient_Enrollment_Request_gne__c per=lstPER[0];
            // create Insurance record
            insNew = new Insurance_gne__c();
            insNew.Case_Insurance_gne__c = caseId;
            insNew.Payer_gne__c = patenrol.Primary_Payer_gne__c;
            insNew.Patient_Insurance_gne__c=patientId;
            //PS: 10/09/2013 Start
            if(patenrol.Subscriber_First_Name_gne__c != null && patenrol.Subscriber_First_Name_gne__c != '')
              insNew.Subscriber_First_Name_gne__c = patenrol.Subscriber_First_Name_gne__c;
            if(patenrol.PI_Subscriber_Name_gne__c != null && patenrol.PI_Subscriber_Name_gne__c != '')
               insNew.Subscriber_Name_gne__c = patenrol.PI_Subscriber_Name_gne__c;
            insNew.Subscriber_DOB_gne__c =patenrol.Subscriber_DOB_gne__c; 
            //PS: 10/09/2013 End
            insNew.Subscriber_Num_gne__c=patenrol.PI_Subscriber_ID_gne__c;
            insNew.Patient_Relationship_to_Subscriber_gne__c=patenrol.Relationship_to_Patient_Insurance_gne__c;
            insNew.Payer_Ph_Provided_by_Customer_gne__c=patenrol.PI_Phone_gne__c;
            
            insNew.Plan_Type_gne__c=patenrol.Insurance_Plan_Type_gne__c;
            insNew.Plan_gne__c=patenrol.Plan_Product_gne__c;
            insNew.Plan_Product_Type_gne__c=patenrol.Insurance_Plan_Product_Type_gne__c;

            insNew.Rank_gne__c=patenrol.Insurance_Rank_gne__c;
        }
        
        return insNew;
    }
    
    // ================================================
    // Generate C&R Case
    public static Case generateCaseCNR(String patientId, 
                                            Patient_Enrollment_Request_gne__c patenrol,  
                                            Medical_History_gne__c mh,
                                            String product,
                                            String reimSpec)
    {
        
        Map<Id, Address_vod__c> addresses = getAddresses(patenrol);
        Case cnrCase=generateCaseCNRBase(patientId, 
                                            patenrol, 
                                            mh,
                                            product,
                                            reimSpec,
                                            getSureStartMap(), addresses, getFRMAlignments(addresses.values(), new Set<String>{product}));
        insert cnrCase;
        
        if (patenrol.Primary_Payer_gne__c!=null)
        {
            generateInsurance(patientId, patenrol, cnrCase.Id);
        }
        
        
        return cnrCase;
    }
    
    public static Case generateCaseCNRBase(String patientId, 
                                            Patient_Enrollment_Request_gne__c patenrol, 
                                            Medical_History_gne__c mh,
                                            String product,
                                            String reimSpec,
                                            Map<String, Campaign> mapSureStart,
                                            Map<Id, Address_vod__c> addresses,
                                            Map<String, List<GNE_CM_Case_Owner_FRM_Alignment__c>> frmAlignments)
    {
        Case cnrCase=GenerateBaseCase('C&R - Standard Case', 
                                        patientId,
                                        patenrol,
                                        mh,
                                        'Active',
                                        product, 
                                        addresses);
                
        // ================================================
        // C&R specific
        cnrCase.Case_Manager__c=patenrol.Case_Manager_gne__c;
        cnrCase.OwnerId=patenrol.Case_Manager_gne__c;
        cnrCase.Reimbursement_Specialist_gne__c=reimSpec; //patenrol.Case_Reimbursement_Specialist_gne__c;
        cnrCase.Cvg_gne__c='Pending Case Review / New Referral';
        
        /*
        if (patenrol.Co_pay_Assistance_gne__c)
        {
            if (!(patenrol.Benefits_Investigation_Prior_Auth_gne__c ||
                patenrol.GATCF_Eligibility_Screening_gne__c ||
                patenrol.Appeals_Support_gne__c ||
                patenrol.GATCF_Patient_Assistance_gne__c))
            {
                //co pay only
                cnrCase.Cvg_gne__c='Co-pay Service';
                //cnrCase.Enroll_Comp_Original_Receipt_gne__c='Yes';
                //cnrCase.Enrollment_Not_Complete_Reason_gne__c=null;
                //cnrCase.case_referral_reason_gne__c='Co-pay Assistance Only';
            }
        }
        */
        
        // set up other user lookups
        List<GNE_CM_Case_Owner_FRM_Alignment__c> caseAlignList = frmAlignments.get(cnrCase.Zip_gne__c + cnrCase.Product_gne__c);
        if(caseAlignList != null && caseAlignList.size() == 1)
        {
            cnrCase.Secondary_Case_Manager_gne__c = caseAlignList[0].GNE_CM_Secondary_Case_Manager_gne__c;
            cnrCase.FRM_gne__c = caseAlignList[0].GNE_CM_FRM_gne__c;
            cnrCase.CS_gne__c = caseAlignList[0].GNE_CM_CS_gne__c;
        }
        
        // Special Programs
        if ((patenrol.Starter_Dosage_Erivedge_gne__c!=null && mapSureStart.containsKey(product) && product=='Erivedge') ||
                (patenrol.Starter_Dosage_Tarceva_gne__c!=null && mapSureStart.containsKey(product) && product=='Tarceva') ||
                (patenrol.Starter_Dosage_Zelboraf_gne__c!=null && mapSureStart.containsKey(product) && product=='Zelboraf') ||
                (patenrol.Starter_Dosage_Cotellic_gne__c!=null && mapSureStart.containsKey(product) && product=='Cotellic') ||
                (patenrol.Starter_Dosage_Boomerang_gne__c!=null && mapSureStart.containsKey(product) && product=='Esbriet') ||
                (patenrol.XOLAIR_Starter_Program_Prescription_gne__c == 'Yes' && mapSureStart.containsKey(product) && product=='Xolair') ||
                (patenrol.Avastin_APA__c == 'Yes' && mapSureStart.containsKey(product) && product=='Avastin') ||
                (patenrol.Starter_Dosage_Alecensa_gne__c!=null && mapSureStart.containsKey(product) && product=='Alecensa') ||
                (mh.Starter_Prescription_Type__c!=null && mapSureStart.containsKey(product) && product==System.Label.GNE_CM_Venetoclax_Product_Name) ||
                (mh.OCRE_Starter_Program_gne__c=='Yes' && mapSureStart.containsKey(product) && product==System.Label.GNE_CM_OCRE_Product_Name))
        {
            cnrCase.Special_Program_Name_gne__c=mapSureStart.get(product).Id;
            cnrCase.Date_Enrolled_gne__c=System.today();
            cnrCase.Enrolled_By_gne__c=UserInfo.getUserId();
        }   
        //PS: 10/08/2013 Start  
        if(patenrol.Starter_Rx_gne__c == 'Yes' && product=='Actemra Subcutaneous')
        {          
            List<Campaign> camp = new  List<Campaign>();         
            camp = [Select id from Campaign where name='ACTFast' limit 1];              
            if(camp != null && camp.size() > 0)
            {
             cnrCase.Special_Program_Name_gne__c=camp[0].Id;            
            }  
             cnrCase.Date_Enrolled_gne__c=System.today();
             cnrCase.Enrolled_By_gne__c=UserInfo.getUserId();           
        }
        //PS: 10/08/2013 End    
        return cnrCase;
    }
    
    /*
    */
    // ================================================
    // Generate GATCF Case
    public static Case generateCaseGATCF(String patientId, 
                                            Patient_Enrollment_Request_gne__c patenrol,  
                                            Medical_History_gne__c mh,
                                            String product,
                                            String cnrCaseId)
    {
        User gatcfUser=[SELECT Id, Username FROM User WHERE Alias='GATCF'];
        Map<Id, Address_vod__c> addresses = getAddresses(patenrol);
        Case gatcfCase=generateCaseGATCFBase(patientId, 
                                            patenrol, 
                                            mh,
                                            product,
                                            cnrCaseId,
                                            gatcfUser, addresses, getFRMAlignments(addresses.values(), new Set<String>{product}));
        insert gatcfCase;
        return gatcfCase;
    }   
    
    public static Case generateCaseGATCFBase(String patientId, 
                                            Patient_Enrollment_Request_gne__c patenrol, 
                                            Medical_History_gne__c mh,
                                            String product,
                                            String cnrCaseId,
                                            User gatcfUser, 
                                            Map<Id, Address_vod__c> addresses,
                                            Map<String, List<GNE_CM_Case_Owner_FRM_Alignment__c>> frmAlignments)
    {
        
        Case gatcfCase=GenerateBaseCase('GATCF - Standard Case', 
                                        patientId,
                                        patenrol,
                                        mh,
                                        'Active',
                                        product,
                                        addresses); 
        
        // set up other user lookups
        List<GNE_CM_Case_Owner_FRM_Alignment__c> caseAlignList = frmAlignments.get(gatcfCase.Zip_gne__c + gatcfCase.Product_gne__c);
        if(caseAlignList != null && caseAlignList.size() == 1)
        {
            gatcfCase.GNE_CM_Secondary_Foundation_Specialist__c = caseAlignList[0].GNE_CM_Secondary_Foundation_Specialist__c;
            gatcfCase.FRM_gne__c = caseAlignList[0].GNE_CM_FRM_gne__c;
            gatcfCase.CS_gne__c = caseAlignList[0].GNE_CM_CS_gne__c;
        }
        
        // ================================================
        // GATCF specific
        gatcfCase.Foundation_Specialist_gne__c=gatcfUser.Id;
        gatcfCase.Related_C_R_Case_gne__c=cnrCaseId;
        gatcfCase.GATCF_Status_gne__c='Pending Case Review';
        //gatcfCase.Enroll_SMN_Form_Signed_Date_gne__c=System.today();
        gatcfCase.Enrollment_Form_Time_Received_gne__c=System.today();
        
        if (gatcfCase.Product_gne__c=='Herceptin')
        {
            gatcfCase.Roll_Up_Infuisons_To_gne__c='Case';
        }
        return gatcfCase;
    }
        

    // ================================================
    // Generate GES Case
    public static Case generateCaseGES(String patientId, 
                                            Patient_Enrollment_Request_gne__c patenrol,
                                            Medical_History_gne__c mh,
                                            String product,
                                            String cnrCaseId)
    {
        User gatcfUser=[SELECT Id, Username FROM User WHERE Alias='GATCF'];
        Case gesCase=generateCaseGESBase(patientId, 
                                            patenrol, 
                                            mh,
                                            product,
                                            cnrCaseId,
                                            gatcfUser, 
                                            getAddresses(patenrol));
                                            
        insert gesCase;
        return gesCase;
    }
    
    public static Case generateCaseGESBase(String patientId, 
                                            Patient_Enrollment_Request_gne__c patenrol, 
                                            Medical_History_gne__c mh,
                                            String product,
                                            String cnrCaseId,
                                            User gatcfUser, 
                                            Map<Id, Address_vod__c> addresses)
    {

        Case gesCase=GenerateBaseCase('GATCF - Eligibility Screening', 
                                        patientId,
                                        patenrol,
                                        mh,
                                        'Active',
                                        product,
                                        addresses); 
                                        
        // ================================================
        // GES specific
        gesCase.Foundation_Specialist_gne__c=gatcfUser.Id;
        gesCase.Related_C_R_Case_gne__c=cnrCaseId;
        gesCase.GES_Status_gne__c='Pending Case Review';
        gesCase.case_referral_reason_gne__c='GATCF Eligibility Screening';
        gesCase.Enroll_SMN_Form_Signed_Date_gne__c=System.today();
        gesCase.Enrollment_Form_Time_Received_gne__c=System.today();

        return gesCase;
    }
    
    public static List<Case> generateCases(Map<String,List<String>> caseSelection, 
                                            String patientId, 
                                            Patient_Enrollment_Request_gne__c patenrol, 
                                            Map<String,String> mapMH)
    {
        return generateCases(caseSelection, patientId, patenrol, mapMH, new Map<String,String>());
    }


    public static List<Case> generateCases(Map<String,List<String>> caseSelection, 
                                            String patientId, 
                                            Patient_Enrollment_Request_gne__c patenrol, 
                                            Map<String,String> mapMH,
                                            Map<String,String> mapReimSpec)
    {
        // map to keep track of case types per product
        Map<String, ProductCases> mapProductCases=new Map<String, ProductCases>();
        Map<String, Medical_History_gne__c> mapMedHist=new Map<String, Medical_History_gne__c>([SELECT Id, ICD9_Code_1_gne__r.ICD9_Code_gne__c, RecordType.Name, Starter_Prescription_Type__c, OCRE_Starter_Program_gne__c FROM Medical_History_gne__c WHERE Id in :mapMH.values()]);
        
        
        // lists for DML Ops
        List<Case> lstInsCases=new List<Case>();
        List<Case> lstUpdCases=new List<Case>();
        List<Insurance_gne__c> lstInsInsur=new List<Insurance_gne__c>();
        
        // Sure Start Map   
        Map<String, Campaign> mapSureStart=getSureStartMap();
        
        // default GATCF user
        User gatcfUser=[SELECT Id, Username FROM User WHERE Alias='GATCF'];
        
        Map<Id, Address_vod__c> addresses = getAddresses(patenrol);
        
        Map<String, List<GNE_CM_Case_Owner_FRM_Alignment__c>> frmAlignments = getFRMAlignments(addresses.values(), caseSelection.keyset());
        
        // for each product create the correct case types
        for (String product : caseSelection.keyset())
        {
            ProductCases pc=new ProductCases(product);
            mapProductCases.put(product, pc);
            
            // get the actual product form multiple case instances i.e. Lucentis:1, Lucentis:2, ....
            // strip off the :n suffix
            String productRoot=product.split('_')[0];


            for (String caseType : caseSelection.get(product))
            {
                if (caseType == 'GATCF - Standard Case')
                {
                    pc.gatcfCase = generateCaseGATCFBase(patientId, 
                                            patenrol, 
                                            mapMedHist.get(mapMH.get(product)),
                                            productRoot,
                                            null,
                                            gatcfUser,
                                            addresses,
                                            frmAlignments);
                    lstInsCases.add(pc.gatcfCase);                              
                }
                else if (caseType == 'GATCF - Eligibility Screening' && product != 'Actemra Subcutaneous')
                {                   
                    pc.gesCase = generateCaseGESBase(patientId, 
                                            patenrol, 
                                            mapMedHist.get(mapMH.get(product)),
                                            productRoot,
                                            null,
                                            gatcfUser,
                                            addresses);                 
                    lstInsCases.add(pc.gesCase);
                }
                else if (caseType == 'C&R - Standard Case')
                {
                    pc.cnrCase = generateCaseCNRBase(patientId, 
                                            patenrol, 
                                            mapMedHist.get(mapMH.get(product)),
                                            productRoot,
                                            mapReimSpec.get(product),
                                            mapSureStart,
                                            addresses,
                                            frmAlignments);
                    lstInsCases.add(pc.cnrCase);
                }
            }
        }


        insert lstInsCases;
        
        
        for (String product : mapProductCases.keyset())
        {
            ProductCases pc=mapProductCases.get(product);
            
            // create insurance
            if (pc.cnrCase!=null && patenrol.Primary_Payer_gne__c!=null)
            {
                Insurance_gne__c insNew=generateInsuranceBase(patientId, patenrol, pc.cnrCase.Id);
                if (insNew!=null)
                {
                    lstInsInsur.add(insNew);
                }
            }
            // hookup Related_C_R_Case_gne__c
            if (pc.cnrCase!=null && pc.gesCase!=null)
            {
                pc.gesCase.Related_C_R_Case_gne__c=pc.cnrCase.Id;
                lstUpdCases.add(pc.gesCase);
            }
        }
        // update related CNR
        update lstUpdCases;

        // insert insurance
        insert lstInsInsur;
        
        // return  the new cases
        return lstInsCases;
    }

}