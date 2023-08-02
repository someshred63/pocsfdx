public with sharing virtual class GNE_CM_MHRA_Case_PDF_Controller 
{
	public transient String objectName {get;set;}
    public transient Case caseRecord { get; set; }
    public transient Patient_gne__c patRecord { get; set; }
    public transient Medical_History_gne__c mhRecord { get; set; }
    public transient Patient_Enrollment_Request_gne__c perRecord { get; set; }
    public transient Contact contactRecord { get; set; }
    
    public transient List<Case> perjetaCasesList { get; set; }
    public transient List<Case> herceptinCasesList { get; set; }
    public transient List<Insurance_gne__c> insurancesList { get; set; }
    public transient List<Benefit_Investigation_gne__c> BIList{get;set;}
    public transient List<Appeal_gne__c> appealsList { get; set; } 
    public transient List<Fulfillment_gne__c> fulfillmentsList { get; set; }
    public transient List<Shipment_gne__c> shipmentRequestsList { get; set; }
    public transient List<Shipment_gne__c> shipmentsList { get; set; }
    public transient List<Infusion_gne__c> infusionsList { get; set; }
    public transient List<Claim_gne__c> claimsList { get; set; }
    public transient List<Alternative_Funding_gne__c> additionalSupportsList { get; set; }
    public transient List<Hotline_gne__c> hotlinesList { get; set; }
    public transient List<Task> openActivityList { get; set; }
    public transient List<Task> activityHistoryList { get; set; }
    public transient List<Appeal_Level_gne__c > appealLevelsList { get; set; }
    public transient List<Patient_Program_gne__c> patientProgramsList { get; set; }
    public transient List<Patient_Address_gne__c> patientAddressList { get; set; }
    public transient List<Patient_Contact_gne__c> patientContactList { get; set; }
    public transient List<Alternative_Funding_Action_gne__c> additionalSupportActionsList { get; set; }
    public transient List<Date_of_Service_gne__c> dateOfServicesList { get; set; }
    public transient List<Coverage_gne__c> coveragesList { get; set; }
    public transient List<CM_Error_Log_gne__c> errorLogsList { get; set; }
    public transient List<GNE_CM_EBI_Specialty_Pharmacy__c> ebiSPList { get; set; }
    public transient List<Account> accountList { get; set; }
    public transient List<Address_vod__c> addressList { get; set; }
    public transient List<Special_Program_gne__c> specProgramList { get; set; }
    public transient List<Call2_vod__c> callList { get; set; }
    public transient List<Transaction_File_Staging_gne__c> trFileStgngList { get; set; }
    public transient List<Survey_Staging_gne__c> surveyStgngList { get; set; }
    public transient List<Prior_Authorization_gne__c> priorAuthList { get; set; }
    public transient List<GNE_CM_Requested_Services__c> requestedSvcList { get; set; }
    public transient List<MPS_Infusion_Attestation_gne__c> infAttList { get; set; }
    public transient List<MPS_Insurance_Attestation_gne__c> insAttList { get; set; }
    public transient List<Market_Insight_gne__c> mktInsList { get; set; }
    public transient List<Identified_Distibutor_gne__c> idDistList { get; set; }
    public transient List<GNE_CM_MPS_ARX_ePAN_Management__c> ePANList { get; set; }
    public transient List<GNE_CM_MPS_ARX_eSMN_Management__c> eSMNList { get; set; }
    public transient List<BRC_RituxanRA_Archive__c> brList { get; set; }


    public transient List<String> caseFields { get; set; }
    public transient List<String> patFields { get; set; }
    public transient List<String> mhFields { get; set; }
    public transient List<String> perFields { get; set; }
    public transient List<String> contactFields { get; set; }
    public transient List<String> insurancesFields { get; set; }
    public transient List<String> BIFields{get;set;}
    public transient List<String> appealsFields { get; set; } 
    public transient List<String> fulfillmentsFields { get; set; }
    public transient List<String> shipmentFields { get; set; }
    public transient List<String> infusionsFields { get; set; }
    public transient List<String> claimsFields { get; set; }
    public transient List<String> additionalSupportsFields { get; set; }
    public transient List<String> hotlinesFields { get; set; }
    public transient List<String> appealLevelsFields { get; set; }
    public transient List<String> patientProgramsFields { get; set; }
    public transient List<String> patientAddressFields { get; set; }
    public transient List<String> patientContactFields { get; set; }
    public transient List<String> additionalSupportActionsFields { get; set; }
    public transient List<String> dateOfServicesFields { get; set; }
    public transient List<String> coveragesFields { get; set; }
    public transient List<String> errorLogsFields { get; set; }
    public transient List<String> ebiSPFields { get; set; }
    public transient List<String> taskFields { get; set; }
    public transient List<String> accountFields { get; set; }
    public transient List<String> specProgramFields { get; set; }
    public transient List<String> callFields { get; set; }
    public transient List<String> trFileStgngFields { get; set; }
    public transient List<String> surveyStgngFields { get; set; }
    public transient List<String> priorAuthFields { get; set; }
    public transient List<String> requestedSvcFields { get; set; }
    public transient List<String> infAttFields { get; set; }
    public transient List<String> insAttFields { get; set; }
    public transient List<String> mktInsFields { get; set; }
    public transient List<String> idDistFields { get; set; }
    public transient List<String> ePANFields { get; set; }
    public transient List<String> eSMNFields { get; set; }
    public transient List<String> brFields { get; set; }
    
    public transient Map<String, String> caseLabels { get; set; }
    public transient Map<String, String> patLabels { get; set; }
    public transient Map<String, String> mhLabels { get; set; }
    public transient Map<String, String> perLabels { get; set; }
    public transient Map<String, String> contactLabels { get; set; }
    public transient Map<String, String> insurancesLabels { get; set; }
    public transient Map<String, String> biLabels { get; set; }
    public transient Map<String, String> appealsLabels { get; set; }
    public transient Map<String, String> fulfillmentsLabels { get; set; }
    public transient Map<String, String> shipmentLabels { get; set; }
    public transient Map<String, String> infusionsLabels { get; set; }
    public transient Map<String, String> claimsLabels { get; set; }
    public transient Map<String, String> additionalSupportsLabels { get; set; }
    public transient Map<String, String> hotlinesLabels { get; set; }
    public transient Map<String, String> appealLevelsLabels { get; set; }
    public transient Map<String, String> patientProgramsLabels { get; set; }
    public transient Map<String, String> patientAddressLabels { get; set; }
    public transient Map<String, String> patientContactLabels { get; set; }
    public transient Map<String, String> additionalSupportActionsLabels { get; set; }
    public transient Map<String, String> dateOfServicesLabels { get; set; }
    public transient Map<String, String> coveragesLabels { get; set; }
    public transient Map<String, String> errorLogsLabels { get; set; }
    public transient Map<String, String> ebiSPLabels { get; set; }
    public transient Map<String, String> taskLabels { get; set; }
    public transient Map<String, String> accountLabels { get; set; }
    public transient Map<String, String> specProgramLabels { get; set; }
    public transient Map<String, String> callLabels { get; set; }
    public transient Map<String, String> trFileStgngLabels { get; set; }
    public transient Map<String, String> surveyStgngLabels { get; set; }
    public transient Map<String, String> priorAuthLabels { get; set; }
    public transient Map<String, String> requestedSvcLabels { get; set; }
    public transient Map<String, String> infAttLabels { get; set; }
    public transient Map<String, String> insAttLabels { get; set; }
    public transient Map<String, String> mktInsLabels { get; set; }
    public transient Map<String, String> idDistLabels { get; set; }
    public transient Map<String, String> ePANLabels { get; set; }
    public transient Map<String, String> eSMNLabels { get; set; }
    public transient Map<String, String> brLabels { get; set; }

    public Set<String> fields2Hide=new Set<String> { 'Id', 'Name', 'CaseNumber', 'Subject', 'IsDeleted', 'IsLocked', 'MayEdit', 'SpringCM_PoC__c'};

    public GNE_CM_MHRA_Case_PDF_Controller (ApexPages.StandardController stdController) 
    {
        string caseId = stdController.getId();
        system.debug('>>>>>>>>>>>>>>>> CASE ID: '+caseId);
        
        // load in our labels
        caseLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Case');
        patLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Patient_gne__c');
        mhLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Medical_History_gne__c');
        perLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Patient_Enrollment_Request_gne__c');
        contactLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Contact');
        
        insurancesLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Insurance_gne__c');
        biLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Benefit_Investigation_gne__c');
        appealsLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Appeal_gne__c');
        fulfillmentsLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Fulfillment_gne__c');
        shipmentLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Shipment_gne__c');
        infusionsLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Infusion_gne__c');
        claimsLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Claim_gne__c');
        additionalSupportsLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Alternative_Funding_gne__c');
        hotlinesLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Hotline_gne__c');
        appealLevelsLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Appeal_Level_gne__c');
        patientProgramsLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Patient_Program_gne__c');
        patientAddressLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Patient_Address_gne__c');
        patientContactLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Patient_Contact_gne__c');
        additionalSupportActionsLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Alternative_Funding_Action_gne__c');
        dateOfServicesLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Date_of_Service_gne__c');
        coveragesLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Coverage_gne__c');
        errorLogsLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('CM_Error_Log_gne__c');
        ebiSPLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('GNE_CM_EBI_Specialty_Pharmacy__c');
        taskLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Task');
        accountLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Account');
        specProgramLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Special_Program_gne__c');
        callLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Call2_vod__c');
        trFileStgngLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Transaction_File_Staging_gne__c');
        surveyStgngLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Survey_Staging_gne__c');
        priorAuthLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Prior_Authorization_gne__c');
        requestedSvcLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('GNE_CM_Requested_Services__c');
        infAttLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('MPS_Infusion_Attestation_gne__c');
        insAttLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('MPS_Insurance_Attestation_gne__c');
        mktInsLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Market_Insight_gne__c');
        idDistLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('Identified_Distibutor_gne__c');
        ePANLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('GNE_CM_MPS_ARX_ePAN_Management__c');
        eSMNLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('GNE_CM_MPS_ARX_eSMN_Management__c');
        brLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('BRC_RituxanRA_Archive__c');


        openActivityList = new List<Task>();
        activityHistoryList = new List<Task>();
        
        patientProgramsList =  new List<Patient_Program_gne__c>();

        caseFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Case');
        patFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Patient_gne__c');
        mhFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Medical_History_gne__c');
        perFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Patient_Enrollment_Request_gne__c');
        contactFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Contact');

        insurancesFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Insurance_gne__c');
        BIFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Benefit_Investigation_gne__c');
        appealsFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Appeal_gne__c');
        fulfillmentsFields= GNE_CM_MHRA_Case_Util.getSObjectFieldList('Fulfillment_gne__c');
        shipmentFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Shipment_gne__c');
        infusionsFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Infusion_gne__c');
        claimsFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Claim_gne__c');
        additionalSupportsFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Alternative_Funding_gne__c');
        hotlinesFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Hotline_gne__c');
        appealLevelsFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Appeal_Level_gne__c');
        patientProgramsFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Patient_Program_gne__c');
        patientAddressFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Patient_Address_gne__c');
        patientContactFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Patient_Contact_gne__c');
        additionalSupportActionsFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Alternative_Funding_Action_gne__c');
        dateOfServicesFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Date_of_Service_gne__c');
        coveragesFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Coverage_gne__c');
        errorLogsFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('CM_Error_Log_gne__c');
        ebiSPFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('GNE_CM_EBI_Specialty_Pharmacy__c');
        taskFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Task');
        accountFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Account');
        specProgramFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Special_Program_gne__c');
        callFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Call2_vod__c');
        trFileStgngFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Transaction_File_Staging_gne__c');
        surveyStgngFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Survey_Staging_gne__c');
        priorAuthFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Prior_Authorization_gne__c');
        requestedSvcFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('GNE_CM_Requested_Services__c');
        infAttFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('MPS_Infusion_Attestation_gne__c');
        insAttFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('MPS_Insurance_Attestation_gne__c');
        mktInsFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Market_Insight_gne__c');
        idDistFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('Identified_Distibutor_gne__c');
        ePANFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('GNE_CM_MPS_ARX_ePAN_Management__c');
        eSMNFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('GNE_CM_MPS_ARX_eSMN_Management__c');
        brFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('BRC_RituxanRA_Archive__c');
 
        // sort
        caseFields.sort();
        patFields.sort();
        mhFields.sort();
        perFields.sort();
        insurancesFields.sort();
        BIFields.sort();
        appealsFields.sort();
        fulfillmentsFields.sort();
        shipmentFields.sort();
        infusionsFields.sort();
        claimsFields.sort();
        additionalSupportsFields.sort();
        hotlinesFields.sort();
        taskFields.sort();
        appealLevelsFields.sort();
        patientProgramsFields.sort();
        patientAddressFields.sort();
        patientContactFields.sort();
        additionalSupportActionsFields.sort();
        dateOfServicesFields.sort();
        coveragesFields.sort();
        errorLogsFields.sort();
        ebiSPFields.sort();
        contactFields.sort();
        accountFields.sort();
        specProgramFields.sort();
        callFields.sort();
        trFileStgngFields.sort();
        surveyStgngFields.sort();
        priorAuthFields.sort();
        requestedSvcFields.sort();
        infAttFields.sort();
        insAttFields.sort();
        mktInsFields.sort();
        idDistFields.sort();
        ePANFields.sort();
        eSMNFields.sort();
        brFields.sort();


        // push the 'Name' field to the top
        caseFields.add(0, 'CaseNumber');
        patFields.add(0, 'Name');
        mhFields.add(0, 'Name');
        perFields.add(0, 'Name');
        insurancesFields.add(0, 'Name');
        BIFields.add(0, 'Name');
        appealsFields.add(0, 'Name');
        fulfillmentsFields.add(0, 'Name');
        shipmentFields.add(0, 'Name');
        infusionsFields.add(0, 'Name');
        claimsFields.add(0, 'Name');
        additionalSupportsFields.add(0, 'Name');
        hotlinesFields.add(0, 'Name');
        taskFields.add(0, 'Subject');
        appealLevelsFields.add(0, 'Name');
        patientProgramsFields.add(0, 'Name');
        patientAddressFields.add(0, 'Name');
        patientContactFields.add(0, 'Name');
        additionalSupportActionsFields.add(0, 'Name');
        dateOfServicesFields.add(0, 'Name');
        coveragesFields.add(0, 'Name');
        errorLogsFields.add(0, 'Name');
        ebiSPFields.add(0, 'Name');
        contactFields.add(0, 'Name');
        accountFields.add(0, 'Name');
        specProgramFields.add(0, 'Name');
        callFields.add(0, 'Name');
        trFileStgngFields.add(0, 'Name');
        surveyStgngFields.add(0, 'Name');
        priorAuthFields.add(0, 'Name');
        requestedSvcFields.add(0, 'Name');
        infAttFields.add(0, 'Name');
        insAttFields.add(0, 'Name');
        mktInsFields.add(0, 'Name');
        idDistFields.add(0, 'Name');
        ePANFields.add(0, 'Name');
        eSMNFields.add(0, 'Name');
        brFields.add(0, 'Name');
       
        
        caseRecord = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Case', caseFields, 'id', caseId));
        
        if (caseRecord.ContactId != null)
        {
            contactRecord = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Contact', contactFields, 'id', caseRecord.ContactId));
        }
        
        if (caseRecord.Patient_gne__c != null)
        {
            patRecord = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Patient_gne__c', patFields, 'id', caseRecord.Patient_gne__c));
            patientProgramsList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Patient_Program_gne__c', patientProgramsFields, 'Patient_gne__c', caseRecord.Patient_gne__c));
            patientAddressList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Patient_Address_gne__c', patientAddressFields, 'Patient_gne__c', caseRecord.Patient_gne__c));
            patientContactList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Patient_Contact_gne__c', patientContactFields, 'pat_con_Patient_gne__c', caseRecord.Patient_gne__c));
        }
        
        if(caseRecord.Medical_History_gne__c != null)
        {
            mhRecord = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Medical_History_gne__c', mhFields, 'id', caseRecord.Medical_History_gne__c));
        }
        
        if (caseRecord.Patient_Enrollment_Request_gne__c!=null)
        {
            perRecord = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Patient_Enrollment_Request_gne__c', perFields, 'id', caseRecord.Patient_Enrollment_Request_gne__c));
            eSMNList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('GNE_CM_MPS_ARX_eSMN_Management__c', eSMNFields, 'Patient_Enrollment_Request__c', caseRecord.Patient_Enrollment_Request_gne__c));
        }
        else 
        {
            eSMNList = new List<GNE_CM_MPS_ARX_eSMN_Management__c>();
        }

        perjetaCasesList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Case',caseFields, 'Combo_Therapy_Case_gne__c', caseId));
        herceptinCasesList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Case',caseFields, 'Combo_Therapy_Child_Case_gne__c', caseId));
        insurancesList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Insurance_gne__c',insurancesFields, 'Case_Insurance_gne__c', caseId));
        BIList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Benefit_Investigation_gne__c', BIFields, 'Case_BI_gne__c', caseId));
        appealsList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Appeal_gne__c',appealsFields, 'Case_Appeal_gne__c', caseId));
        fulfillmentsList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Fulfillment_gne__c',fulfillmentsFields, 'Case_Fulfillment_gne__c', caseId));
        shipmentRequestsList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Shipment_gne__c',shipmentFields, 'Case_Shipment_Request_gne__c', caseId));
        shipmentsList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Shipment_gne__c',shipmentFields, 'Case_Shipment_gne__c', caseId));

        infusionsList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Infusion_gne__c',infusionsFields, 'Case_gne__c', caseId));
        claimsList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Claim_gne__c',claimsFields, 'Case_gne__c', caseId));
        additionalSupportsList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Alternative_Funding_gne__c', additionalSupportsFields, 'Case_gne__c', caseId));
        hotlinesList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Hotline_gne__c',hotlinesFields, 'Related_Case_gne__c', caseId));
        appealLevelsList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Appeal_Level_gne__c',appealLevelsFields, 'Appeal_ID_gne__r.Case_Appeal_gne__c', caseId));
        additionalSupportActionsList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Alternative_Funding_Action_gne__c', additionalSupportActionsFields, 'Alternative_Funding_ID_gne__r.Case_gne__r.Id', caseId));
        dateOfServicesList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Date_of_Service_gne__c', dateOfServicesFields, 'Appeal_Level_gne__r.Appeal_ID_gne__r.Case_Appeal_gne__c', caseId));
        coveragesList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Coverage_gne__c', coveragesFields, 'Benefit_Investigation_gne__r.BI_Insurance_gne__r.Case_Insurance_gne__c', caseId));
        

        if (caseRecord.Patient_Enrollment_Request_gne__c!=null)
        {
            ebiSPList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('GNE_CM_EBI_Specialty_Pharmacy__c',  ebiSPFields, 'EBI_Rule_Result_Set_gne__r.Payer_Result_gne__r.EBI_Benefit_Verification_Response_gne__r.Request_gne__r.case_gne__c', caseId)+ ' OR EBI_Rule_Result_Set_gne__r.Payer_Result_gne__r.EBI_Benefit_Verification_Response_gne__r.Request_gne__r.PER_gne__c= \'' + caseRecord.Patient_Enrollment_Request_gne__c + '\'');
        }
        else
        {
            ebiSPList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('GNE_CM_EBI_Specialty_Pharmacy__c',  ebiSPFields, 'EBI_Rule_Result_Set_gne__r.Payer_Result_gne__r.EBI_Benefit_Verification_Response_gne__r.Request_gne__r.case_gne__c', caseId));
        }
        
        String additionalConsitionErrorLogs = ' OR Duplicate_of_Case__c  = \'' + caseId + '\'';
        if(caseRecord.Patient_gne__c != null)
        {
            additionalConsitionErrorLogs += ' OR Duplicate_of_Patient_ID__c = \'' + caseRecord.Patient_gne__c + '\'';
        }
        if(caseRecord.Medical_History_gne__c != null)
        {
            additionalConsitionErrorLogs += ' OR Duplicate_of_Medical_History__c = \'' + caseRecord.Medical_History_gne__c + '\'';
        }
        
        errorLogsList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('CM_Error_Log_gne__c', errorLogsFields, 'Case_Number__c', caseId) + additionalConsitionErrorLogs);
        
        accountList = GNE_CM_MHRA_Case_Util.initAccountObject(caseRecord, accountFields);
        addressList = GNE_CM_MHRA_Case_Util.initAddressObject(caseRecord, accountList, new List<String> {'Id', 'Name'});

    
        String specProgramSOQL = GNE_CM_MHRA_Case_Util.getListOfSObjectList('Special_Program_gne__c', specProgramFields, 'Prescriber_gne__c');
        specProgramList = Database.query(specProgramSOQL.replace('XXXXXXXXXXXXXXX','accountList'));


        Map<Id, Profile> profiles = new Map<Id, Profile>([SELECT Id, Name FROM Profile WHERE name like 'GNE-MCCO-FRM%']);
        set<id> profileIds = profiles.keySet();
        String callQuery = 'SELECT ' + GlobalUtils.implode(callFields, ', ') + ' FROM Call2_vod__c WHERE (Account_vod__c IN: accountList';
        
        callQuery += ' OR DEA_Address_vod__c IN: addressList'+
                     ' OR Parent_Address_vod__c IN: addressList'+
                     ' OR Ship_To_Address_vod__c IN: addressList)';
        callQuery += ' AND Owner.ProfileId IN: profileIds';
        
        callList = Database.query(callQuery);  

        if (caseRecord.Patient_gne__c!=null) {
            trFileStgngList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Transaction_File_Staging_gne__c', trFileStgngFields, 'Patient_Program_gne__r.Patient_gne__c', caseRecord.Patient_gne__c));
            surveyStgngList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Survey_Staging_gne__c', surveyStgngFields, 'Transaction_File_Staging_gne__r.Patient_Program_gne__r.Patient_gne__c', caseRecord.Patient_gne__c));
        }
        priorAuthList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Prior_Authorization_gne__c', priorAuthFields, 'Benefit_Investigation_gne__r.Case_BI_gne__c', caseId));
        requestedSvcList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('GNE_CM_Requested_Services__c', requestedSvcFields, 'Case_gne__c', caseId));
        infAttList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('MPS_Infusion_Attestation_gne__c', infAttFields, 'Case_gne__c', caseId));
        insAttList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('MPS_Insurance_Attestation_gne__c', insAttFields, 'Case_gne__c', caseId));
        mktInsList = Database.query('SELECT ' + GlobalUtils.implode(mktInsFields, ', ') + ' FROM Market_Insight_gne__c WHERE Id IN (SELECT Market_Insight_gne__c FROM Insight_Case_Association_gne__c WHERE Case_gne__c=:caseId)');  
        idDistList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('Identified_Distibutor_gne__c', idDistFields, 'Fulfilment_Number_gne__r.Case_Fulfillment_gne__c', caseId));
        ePANList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('GNE_CM_MPS_ARX_ePAN_Management__c', ePANFields, 'Case__c', caseId));
        if (caseRecord.Patient_Enrollment_Request_gne__c!=null) {
            ePANList.addAll((List<GNE_CM_MPS_ARX_ePAN_Management__c>) Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('GNE_CM_MPS_ARX_ePAN_Management__c', ePANFields, 'Patient_Enrollment_Request__c', caseRecord.Patient_Enrollment_Request_gne__c)));
        }
        brList = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('BRC_RituxanRA_Archive__c', brFields, 'Case_gne__c', caseId));

        Set<String> whatIds=new Set<String> { caseId };

        if (caseRecord.Patient_gne__c!=null) {
            whatIds.add(caseRecord.Patient_gne__c);
        }
        
        GNE_CM_MHRA_Case_Util.addIds2Set(whatIds, priorAuthList);
        GNE_CM_MHRA_Case_Util.addIds2Set(whatIds, insurancesList);
        GNE_CM_MHRA_Case_Util.addIds2Set(whatIds, BIList);
        GNE_CM_MHRA_Case_Util.addIds2Set(whatIds, shipmentsList);
        GNE_CM_MHRA_Case_Util.addIds2Set(whatIds, shipmentRequestsList);
        GNE_CM_MHRA_Case_Util.addIds2Set(whatIds, perjetaCasesList);
        GNE_CM_MHRA_Case_Util.addIds2Set(whatIds, herceptinCasesList);
        GNE_CM_MHRA_Case_Util.addIds2Set(whatIds, appealsList);
        GNE_CM_MHRA_Case_Util.addIds2Set(whatIds, fulfillmentsList);
        GNE_CM_MHRA_Case_Util.addIds2Set(whatIds, infusionsList);
        GNE_CM_MHRA_Case_Util.addIds2Set(whatIds, appealsList);
        GNE_CM_MHRA_Case_Util.addIds2Set(whatIds, appealLevelsList);
        GNE_CM_MHRA_Case_Util.addIds2Set(whatIds, claimsList);
        GNE_CM_MHRA_Case_Util.addIds2Set(whatIds, additionalSupportsList);
        GNE_CM_MHRA_Case_Util.addIds2Set(whatIds, hotlinesList);
        GNE_CM_MHRA_Case_Util.addIds2Set(whatIds, additionalSupportActionsList);
        GNE_CM_MHRA_Case_Util.addIds2Set(whatIds, dateOfServicesList);
        GNE_CM_MHRA_Case_Util.addIds2Set(whatIds, coveragesList);

        for (Task t : Database.query('SELECT ' + GlobalUtils.implode(taskFields, ', ') + ' FROM Task WHERE WhatId IN :whatIds ORDER BY ActivityDate ALL ROWS'))
        {
            if (t.isClosed)
            {
                activityHistoryList.add(t);
            }
            else
            {
                openActivityList.add(t);
            }
        }

    }

    public String getCallHeader() {
        String ret='';
        for (String fld : callFields) 
        {
            if (ret!='') 
            {
                ret+=',';
            }
            ret+='"' + callLabels.get(fld) + '"';
        }
        return ret;
    }

    public List<String> getCallRows() {
        List<String> lstRet=new List<String>();

        for (Call2_vod__c cl : callList) 
        {
            String ret='';
            for (String fld : callFields) 
            {
                if (ret!='') 
                {
                    ret+=',';
                }
                Object val=cl.get(fld);
                ret+='"' + (val==null ? '' : val) + '"';
            }
            lstRet.add(ret);
        }
        return lstRet;
    }    
}