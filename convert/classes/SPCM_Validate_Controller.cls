public with sharing class SPCM_Validate_Controller {
    
        public Boolean displayPopup {get; set;}

        private SPCM_ApprovalProcessConfig processConfig;
        private GNE_BusinessRoleConfig roleConfig;
        private SPCM_ApprovalManager approvalMgr;
        private Map<string, string> usersMap = new Map<string, string>();


    public SPCM_Validate_Controller() {
        processConfig = new SPCM_ApprovalProcessConfig();
        roleConfig = new GNE_BusinessRoleConfig();
        approvalMgr = new SPCM_ApprovalManager(roleConfig, processConfig);
        displayPopup = false;
        
    }

    public void TogglePopup()
    {
        displayPopup = !displayPopup;
    }



    public SPCM_Approval_Process_Level__c[] GetValidateCarsCuts()
    {
        SPCM_Approval_Process_Level__c[] CARS_CUTS_levels = 
        GetAllProcessLevels('SPCM_CARS_Contract_Summary_Form__c', 2);
        
        for(SPCM_Approval_Process_Level__c level : CARS_CUTS_levels)
        {
            String error = SPCM_CARSContractSummaryFormUtils.GetErrorsForLevel(level);
            level.Comments__c = error == null ? 'OK' : error;
        }
        return CARS_CUTS_levels;
    }
    
    public BaseWrapper[] GetValidateCarsIcfr()
    {
        SPCM_CARSICFRSignOffUtils CARSICFRSignOffUtils = new SPCM_CARSICFRSignOffUtils();
        List<BaseWrapper> CarsIcfrLevels = new List<BaseWrapper>();
        

                CarsIcfrLevels.Add( new BaseWrapper(1, 'Monthly', 
                CARSICFRSignOffUtils.GetErrorsForLevel1('Monthly', approvalMgr)));
                CarsIcfrLevels.Add( new BaseWrapper(1, 'Annual', 
                CARSICFRSignOffUtils.GetErrorsForLevel1('Annual',  approvalMgr)));
        CarsIcfrLevels.Add( new BaseWrapper(2, '', 
                CARSICFRSignOffUtils.GetErrorsForLevel2( approvalMgr)));
        CarsIcfrLevels.Add( new BaseWrapper(3, '', 
            CARSICFRSignOffUtils.GetErrorsForLevel3( approvalMgr)));
        CarsIcfrLevels.Add( new BaseWrapper(4, '', 
            CARSICFRSignOffUtils.GetErrorsForLevel4(approvalMgr)));        
        
                return CarsIcfrLevels;
    }

    public BaseWrapper[] GetValidateCarsPayments()
    {
        SPCM_CARSPaymentPacketUtils CARSPaymentPacketUtils = new  SPCM_CARSPaymentPacketUtils();
        List<BaseWrapper> carsPaymentsLevels = new List<BaseWrapper>();
        Map<Id, Id> ApproverMap = CARSPaymentPacketUtils.InitializeApproverMap();
        Id approver;
        for (Id key : ApproverMap.keySet()) {
            approver = key;//ApproverMap.get(key);
            break;
        }
        List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels('SPCM_CARS_Payment_Packet__c', 1);
        // level 1
        if (processLevels.size() > 0)
        {
            for (SPCM_Approval_Process_Level__c processLevel : processLevels)
            {
                carsPaymentsLevels.Add(new BaseWrapper(1, processLevel.name, CARSPaymentPacketUtils.GetErrorsForLevel1(approver, processLevels)));
            }
        }
        else {
            carsPaymentsLevels.Add(new BaseWrapper(1, '', CARSPaymentPacketUtils.GetErrorsForLevel1(approver, processLevels)));
        }
        
        Map<Id, Id> Approver2Map = CARSPaymentPacketUtils.InitializeLevel2ApproverMap();
        Id approver2;
        for (Id key : Approver2Map.keySet()) {
            approver2 = key;//ApproverMap.get(key);
            break;
        }
        // level 2
        processLevels = approvalMgr.GetProcessLevels('SPCM_CARS_Payment_Packet__c', 2);
        if (processLevels.size() > 0) {
            for (SPCM_Approval_Process_Level__c processLevel : processLevels) {
                carsPaymentsLevels.Add(new BaseWrapper(2, processLevel.name, CARSPaymentPacketUtils.GetErrorsForLevel2(approver2, processLevels)));
            }
        }
        else {
            carsPaymentsLevels.Add(new BaseWrapper(2, '', CARSPaymentPacketUtils.GetErrorsForLevel2(approver2, processLevels)));
        }


		Map<Id, Id> Approver3Map = CARSPaymentPacketUtils.InitializeLevel3ApproverMap();
        Id approver3;
        for (Id key : Approver3Map.keySet()) {
            approver3 = key;//ApproverMap.get(key);
            break;
        }
        // level 3
        processLevels = approvalMgr.GetProcessLevels('SPCM_CARS_Payment_Packet__c', 3);
        if (processLevels.size() > 0)
        {
            for (SPCM_Approval_Process_Level__c processLevel : processLevels)
            {
            	carsPaymentsLevels.Add(new BaseWrapper(3, processLevel.name, CARSPaymentPacketUtils.GetErrorsForLevel3(approver3, processLevels)));
            }
        }
        else{
            carsPaymentsLevels.Add(new BaseWrapper(3, '', CARSPaymentPacketUtils.GetErrorsForLevel3( '', processLevels, approvalMgr)));
        }
        
        // level 4
        processLevels = approvalMgr.GetProcessLevels('SPCM_CARS_Payment_Packet__c', 4);
        if (processLevels.size() > 0)
        {
            for (SPCM_Approval_Process_Level__c processLevel : processLevels)
            {
                carsPaymentsLevels.Add(new BaseWrapper(4, processLevel.name, CARSPaymentPacketUtils.GetErrorsForLevel4( processLevels, approvalMgr)));
            }
        }
        else{
            carsPaymentsLevels.Add(new BaseWrapper(4, '', CARSPaymentPacketUtils.GetErrorsForLevel4( processLevels, approvalMgr)));
        }
        
        // level 5
        processLevels = approvalMgr.GetProcessLevels('SPCM_CARS_Payment_Packet__c', 5);
        if (processLevels.size() > 0)
        {
            for (SPCM_Approval_Process_Level__c processLevel : processLevels)
            {
                carsPaymentsLevels.Add(new BaseWrapper(5, processLevel.name, CARSPaymentPacketUtils.GetErrorsForLevel5( processLevels, approvalMgr)));
            }
        }
        else{
            carsPaymentsLevels.Add(new BaseWrapper(5, '', CARSPaymentPacketUtils.GetErrorsForLevel5( processLevels, approvalMgr)));
        }
        
        // level 6
        processLevels = approvalMgr.GetProcessLevels('SPCM_CARS_Payment_Packet__c', 6);
        if (processLevels.size() > 0)
        {
            for (SPCM_Approval_Process_Level__c processLevel : processLevels)
            {
                carsPaymentsLevels.Add(new BaseWrapper(6, processLevel.name, CARSPaymentPacketUtils.GetErrorsForLevel6( processLevels, approvalMgr)));
            }
        }
        else{
            carsPaymentsLevels.Add(new BaseWrapper(6, '', CARSPaymentPacketUtils.GetErrorsForLevel6( processLevels, approvalMgr)));
        }
        
        // level 7
        processLevels = approvalMgr.GetProcessLevels('SPCM_CARS_Payment_Packet__c', 7);
        if (processLevels.size() > 0)
        {
            for (SPCM_Approval_Process_Level__c processLevel : processLevels)
            {
                carsPaymentsLevels.Add(new BaseWrapper(7, processLevel.name, CARSPaymentPacketUtils.GetErrorsForLevel7( processLevels, approvalMgr)));
            }
        }
        else{
            carsPaymentsLevels.Add(new BaseWrapper(7, '', CARSPaymentPacketUtils.GetErrorsForLevel7( processLevels, approvalMgr)));
        }
        
        // level 8
        processLevels = approvalMgr.GetProcessLevels('SPCM_CARS_Payment_Packet__c', 8);
        if (processLevels.size() > 0)
        {
            for (SPCM_Approval_Process_Level__c processLevel : processLevels)
            {
                carsPaymentsLevels.Add(new BaseWrapper(8, processLevel.name,
                CARSPaymentPacketUtils.GetErrorsForLevel8(approver2, processLevels)));
            }
        }
        else{
            carsPaymentsLevels.Add(new BaseWrapper(8, '', CARSPaymentPacketUtils.GetErrorsForLevel8(approver2, processLevels)));
        }
        
        return carsPaymentsLevels;

    }
    
    public BaseWrapper[] GetValidateMedicaidPayments()
    {
        SPCM_MedicaidPaymentPacketUtils MedicaidPaymentPacketUtils = new SPCM_MedicaidPaymentPacketUtils();
        List<BaseWrapper> MedicaidPaymentsLevels = new List<BaseWrapper>();
        
        // level 1
        List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels('SPCM_Medicaid_Payment_Packet__c', 1);
        Integer i = 0;
        do{
            string region = [select name from SPCM_Region__c where id = :processLevels[i].Region__c][0].name;
            string usersString = processLevels.isEmpty() ? '' : GetUsersForBusinessRole(processLevels[i].Business_Role__r.name); 
            MedicaidPaymentsLevels.Add(new BaseWrapper(1, processLevels.isEmpty() ? '' : processLevels[i].name, MedicaidPaymentPacketUtils.GetErrorsForLevel1(processLevels, processLevels[i],approvalMgr), 
                region, processLevels[i].Medicaid_States__c, processLevels.isEmpty() ? '' : processLevels[i].business_role__r.name, usersString));
        }while (++i < processLevels.size());
 

        // level 2
        processLevels = approvalMgr.GetProcessLevels('SPCM_Medicaid_Payment_Packet__c', 2);
        i = 0;
        do{
            string usersString = processLevels.isEmpty() ? '' : GetUsersForBusinessRole(processLevels[i].Business_Role__r.name); 
            MedicaidPaymentsLevels.Add(new BaseWrapper(2, processLevels.isEmpty() ? '' : processLevels[i].name, MedicaidPaymentPacketUtils.GetErrorsForLevel2(processLevels, processLevels[i],approvalMgr), 
                '', processLevels[i].Medicaid_States__c, processLevels.isEmpty() ? '' : processLevels[i].business_role__r.name, usersString));
        }while (++i < processLevels.size());

 
        // levels 3-6
        for (integer p = 3; p <= 6; p++)
        {
            processLevels = approvalMgr.GetProcessLevels('SPCM_Medicaid_Payment_Packet__c', p);
            i = 0;
            do{
                string usersString = processLevels.isEmpty() ? '' : GetUsersForBusinessRole(processLevels[i].Business_Role__r.name); 
                MedicaidPaymentsLevels.Add(new BaseWrapper(p, processLevels.isEmpty() ? '' : processLevels[i].name, MedicaidPaymentPacketUtils.GetErrorsForLevel3456(processLevels, processLevels[i],approvalMgr), 
                    '', '', processLevels.isEmpty() ? '' : processLevels[i].business_role__r.name, usersString));
            }while (++i < processLevels.size());
        }
        
        return MedicaidPaymentsLevels;
    }
    


    public BaseWrapper[] GetValidateGPPayments()
    {
        SPCM_GPPaymentPacketUtils GPPaymentPacketUtils = new SPCM_GPPaymentPacketUtils();
        List<BaseWrapper> GPPaymentsLevels = new List<BaseWrapper>();
        
        // levels 1-5
        for (integer p = 1; p <= 5; p++)
        {
            List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels('SPCM_GP_Payment_Packet__c', p);
            Integer i = 0;
            do{
                string usersString = processLevels.isEmpty() ? '' : GetUsersForBusinessRole(processLevels[i].Business_Role__r.name); 
                GPPaymentsLevels.Add(new BaseWrapper(1, processLevels.isEmpty() ? '' : processLevels[i].name, GPPaymentPacketUtils.GetErrorsForLevel12345(processLevels, approvalMgr, p),
                    processLevels.isEmpty() ? '' : processLevels[i].business_role__r.name, usersString));
            } while (++i < processLevels.size());
        }
        
        return GPPaymentsLevels;
    }
    
    public BaseWrapper[] GetValidateMCCApprovals()
    {
        SPCM_MCCApprovalSheetUtils MCCApprovalSheetUtils = new SPCM_MCCApprovalSheetUtils();
        List<BaseWrapper> MCCApprovalSheetLevels = new List<BaseWrapper>();
        

        // level 1
        List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels('SPCM_MCC_Approval_Sheet__c', 1);
        Integer i = 0;
        do{
            string usersString = processLevels.isEmpty() ? '' : GetUsersForBusinessRole(processLevels[i].Business_Role__r.name); 
            MCCApprovalSheetLevels.Add(new BaseWrapper(1, processLevels.isEmpty() ? '' : processLevels[i].name, MCCApprovalSheetUtils.GetErrorsForLevel1(processLevels), 
                '',processLevels.isEmpty() ? '' : processLevels[i].business_role__r.name, usersString));
        }while (++i < processLevels.size());
        
                
        // level 2
        processLevels = approvalMgr.GetProcessLevels('SPCM_MCC_Approval_Sheet__c', 2);
        i = 0;
        do{
            string usersString = processLevels.isEmpty() ? '' : GetUsersForBusinessRole(processLevels[i].Business_Role__r.name); 
            MCCApprovalSheetLevels.Add(new BaseWrapper(2, processLevels.isEmpty() ? '' : processLevels[i].name, MCCApprovalSheetUtils.GetErrorsForLevel2478(processLevels, approvalMgr), 
                '', processLevels.isEmpty() ? '' : processLevels[i].business_role__r.name, usersString));
        }while (++i < processLevels.size());
        
        // level 3
        processLevels = approvalMgr.GetProcessLevels('SPCM_MCC_Approval_Sheet__c', 3);
        i = 0;
        do{ 
            string usersString = processLevels.isEmpty() ? '' : GetUsersForBusinessRole(processLevels[i].Business_Role__r.name); 
            MCCApprovalSheetLevels.Add(new BaseWrapper(3, processLevels.isEmpty() ? '' : processLevels[i].name,
                                                               MCCApprovalSheetUtils.GetErrorsForLevel3(processLevels, processLevels.isEmpty() ? null : processLevels[i], approvalMgr),
                                                               processLevels.isEmpty() ? '' : processLevels[i].Account_Team__c, processLevels.isEmpty() ? 
                                                               '' : processLevels[i].business_role__r.name, usersString));
        }while (++i < processLevels.size());

                // level 4
        processLevels = approvalMgr.GetProcessLevels('SPCM_MCC_Approval_Sheet__c', 4);
        i = 0;
        do{
            string usersString = processLevels.isEmpty() ? '' : GetUsersForBusinessRole(processLevels[i].Business_Role__r.name); 
            MCCApprovalSheetLevels.Add(new BaseWrapper(4, processLevels.isEmpty() ? '' : processLevels[i].name, MCCApprovalSheetUtils.GetErrorsForLevel2478(processLevels, approvalMgr),
             '', processLevels.isEmpty() ? '' : processLevels[i].business_role__r.name, usersString));
        }while (++i < processLevels.size());
        
                // level 5
        processLevels = approvalMgr.GetProcessLevels('SPCM_MCC_Approval_Sheet__c', 5);
        i = 0;
        do{
            string usersString = processLevels.isEmpty() ? '' : GetUsersForBusinessRole(processLevels[i].Business_Role__r.name); 
            MCCApprovalSheetLevels.Add(new BaseWrapper(5, processLevels.isEmpty() ? '' : processLevels[i].name, MCCApprovalSheetUtils.GetErrorsForLevel5(processLevels),
             '', processLevels.isEmpty() ? '' : processLevels[i].business_role__r.name, usersString));
        }while (++i < processLevels.size());
                
                // level 6
        processLevels = approvalMgr.GetProcessLevels('SPCM_MCC_Approval_Sheet__c', 6);
        i = 0;
        do{
            string usersString = processLevels.isEmpty() ? '' : GetUsersForBusinessRole(processLevels[i].Business_Role__r.name); 
            MCCApprovalSheetLevels.Add(new BaseWrapper(6, processLevels.isEmpty() ? '' : processLevels[i].name, MCCApprovalSheetUtils.GetErrorsForLevel6(processLevels, approvalMgr), 
                '', processLevels.isEmpty() ? '' : processLevels[i].business_role__r.name, usersString));
        }while (++i < processLevels.size());
        
                // level 7
        processLevels = approvalMgr.GetProcessLevels('SPCM_MCC_Approval_Sheet__c', 7);
        i = 0;
        do{
            string usersString = processLevels.isEmpty() ? '' : GetUsersForBusinessRole(processLevels[i].Business_Role__r.name); 
            MCCApprovalSheetLevels.Add(new BaseWrapper(7, processLevels.isEmpty() ? '' : processLevels[i].name, MCCApprovalSheetUtils.GetErrorsForLevel2478(processLevels, approvalMgr), 
                '', processLevels.isEmpty() ? '' : processLevels[i].business_role__r.name, usersString));
        }while (++i < processLevels.size());
        
                // level 8
        processLevels = approvalMgr.GetProcessLevels('SPCM_MCC_Approval_Sheet__c', 8);
        i = 0;
        do{
            string usersString = processLevels.isEmpty() ? '' : GetUsersForBusinessRole(processLevels[i].Business_Role__r.name); 
            MCCApprovalSheetLevels.Add(new BaseWrapper(8, processLevels.isEmpty() ? '' : processLevels[i].name, MCCApprovalSheetUtils.GetErrorsForLevel2478(processLevels, approvalMgr),
             '', processLevels.isEmpty() ? '' : processLevels[i].business_role__r.name, usersString));
        }while (++i < processLevels.size());
        
        return MCCApprovalSheetLevels;
    }
    
    
    private string GetUsersForBusinessRole(string businesRoleName)
    {
            string usersString = ''; 
            if (usersMap.isEmpty())
            {
                List<User_Business_Role_gne__c> users = [select Business_Role_gne__c, user_gne__r.name,
                 user_gne__r.isActive from User_Business_Role_gne__c where Business_Role_gne__c in :businessRolesList];
                for (User_Business_Role_gne__c u : users){
                    if (!usersMap.containsKey(u.Business_Role_gne__c))
                        usersMap.put(u.Business_Role_gne__c, '');
                    usersMap.put(u.Business_Role_gne__c, usersMap.get(u.Business_Role_gne__c) +
                         (u.user_gne__r.isActive ? (u.user_gne__r.Name + ', ') : ('<s>' + u.user_gne__r.Name + '</s>, ')));
                }
            }

            return usersMap.get(businesRoleName) == null ? '' : usersMap.get(businesRoleName).removeEnd(', ');
    }

    public BaseWrapper[] GetValidateMCCException()
    {
        SPCM_MCCExceptionSheetUtils MCCExceptionSheetUtils = new SPCM_MCCExceptionSheetUtils();
        List<BaseWrapper> MCCExceptionSheetLevels = new List<BaseWrapper>();
        

        // level 1
        List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels('SPCM_MCC_Exception_Sheet__c', 1);
        Integer i = 0;
        do{ 
            string usersString = processLevels.isEmpty() ? '' : GetUsersForBusinessRole(processLevels[i].Business_Role__r.name); 
            MCCExceptionSheetLevels.Add(new BaseWrapper(1, processLevels.isEmpty() ? '' : processLevels[i].name, MCCExceptionSheetUtils.GetErrorsForLevel1(processLevels),
             '', processLevels.isEmpty() ? '' : processLevels[i].business_role__r.name, usersString));
        }while (++i < processLevels.size());
        
                
        // level 2
        processLevels = approvalMgr.GetProcessLevels('SPCM_MCC_Exception_Sheet__c', 2);
        i = 0;
        do{
            string usersString = processLevels.isEmpty() ? '' : GetUsersForBusinessRole(processLevels[i].Business_Role__r.name); 
            MCCExceptionSheetLevels.Add(new BaseWrapper(2, processLevels.isEmpty() ? '' : processLevels[i].name, MCCExceptionSheetUtils.GetErrorsForLevel2(processLevels), 
                '', processLevels.isEmpty() ? '' : processLevels[i].business_role__r.name, usersString));
        }while (++i < processLevels.size());
        
        // level 3
        processLevels = approvalMgr.GetProcessLevels('SPCM_MCC_Exception_Sheet__c', 3);
        i = 0;
        do{ 
            string usersString = processLevels.isEmpty() ? '' : GetUsersForBusinessRole(processLevels[i].Business_Role__r.name); 
            MCCExceptionSheetLevels.Add(new BaseWrapper(3, processLevels.isEmpty() ? '' : processLevels[i].name,
                                                               MCCExceptionSheetUtils.GetErrorsForLevel3(processLevels, processLevels.isEmpty() ? null : processLevels[i], approvalMgr),
                                                               processLevels.isEmpty() ? '' : processLevels[i].Account_Team__c, processLevels.isEmpty() ? '' : processLevels[i].business_role__r.name, usersString));
        }while (++i < processLevels.size());

                // level 4
        processLevels = approvalMgr.GetProcessLevels('SPCM_MCC_Exception_Sheet__c', 4);
        i = 0;
        do{
            string usersString = processLevels.isEmpty() ? '' : GetUsersForBusinessRole(processLevels[i].Business_Role__r.name); 
            MCCExceptionSheetLevels.Add(new BaseWrapper(4, processLevels.isEmpty() ? '' : processLevels[i].name, MCCExceptionSheetUtils.GetErrorsForLevel4(processLevels, approvalMgr),
             '', processLevels.isEmpty() ? '' : processLevels[i].business_role__r.name, usersString));
        }while (++i < processLevels.size());
        
                // level 5
        processLevels = approvalMgr.GetProcessLevels('SPCM_MCC_Exception_Sheet__c', 5);
        i = 0;
        do{
            string usersString = processLevels.isEmpty() ? '' : GetUsersForBusinessRole(processLevels[i].Business_Role__r.name); 
            MCCExceptionSheetLevels.Add(new BaseWrapper(5, processLevels.isEmpty() ? '' : processLevels[i].name, MCCExceptionSheetUtils.GetErrorsForLevel5(processLevels, approvalMgr),
             '', processLevels.isEmpty() ? '' : processLevels[i].business_role__r.name, usersString));
        }while (++i < processLevels.size());
                
                // level 6
        processLevels = approvalMgr.GetProcessLevels('SPCM_MCC_Exception_Sheet__c', 6);
        i = 0;
        do{
            string usersString = processLevels.isEmpty() ? '' : GetUsersForBusinessRole(processLevels[i].Business_Role__r.name); 
            MCCExceptionSheetLevels.Add(new BaseWrapper(6, processLevels.isEmpty() ? '' : processLevels[i].name, MCCExceptionSheetUtils.GetErrorsForLevel6(processLevels, approvalMgr),
             '', processLevels.isEmpty() ? '' : processLevels[i].business_role__r.name, usersString));
        }while (++i < processLevels.size());
        
                // level 7
        processLevels = approvalMgr.GetProcessLevels('SPCM_MCC_Exception_Sheet__c', 7);
        i = 0;
        do{
            string usersString = processLevels.isEmpty() ? '' : GetUsersForBusinessRole(processLevels[i].Business_Role__r.name); 
            MCCExceptionSheetLevels.Add(new BaseWrapper(7, processLevels.isEmpty() ? '' : processLevels[i].name, MCCExceptionSheetUtils.GetErrorsForLevel7(processLevels, approvalMgr),
             '', processLevels.isEmpty() ? '' : processLevels[i].business_role__r.name, usersString));
        }while (++i < processLevels.size());
        
                // level 8
        processLevels = approvalMgr.GetProcessLevels('SPCM_MCC_Exception_Sheet__c', 8);
        i = 0;
        do{
            string usersString = processLevels.isEmpty() ? '' : GetUsersForBusinessRole(processLevels[i].Business_Role__r.name); 
            MCCExceptionSheetLevels.Add(new BaseWrapper(8, processLevels.isEmpty() ? '' : processLevels[i].name, MCCExceptionSheetUtils.GetErrorsForLevel8(processLevels, approvalMgr),
             '', processLevels.isEmpty() ? '' : processLevels[i].business_role__r.name, usersString));
        }while (++i < processLevels.size());
        
        return MCCExceptionSheetLevels;
    }
    
    
    public BaseWrapper[] GetValidateMCCTracking()
    {
        SPCM_MCCTrackingSheetUtils MCCTrackingSheetUtils = new SPCM_MCCTrackingSheetUtils();
        List<BaseWrapper> MCCTrackingSheetLevels = new List<BaseWrapper>();
        

        // level 1
        List<SPCM_Approval_Process_Level__c> processLevels = approvalMgr.GetProcessLevels('SPCM_MCC_Tracking_Sheet__c', 1);
        Integer i = 0;
        do{
            string usersString = processLevels.isEmpty() ? '' : GetUsersForBusinessRole(processLevels[i].Business_Role__r.name); 
            MCCTrackingSheetLevels.Add(new BaseWrapper(1, processLevels.isEmpty() ? '' : processLevels[i].name, MCCTrackingSheetUtils.GetErrorsForLevel1(processLevels),
             '', processLevels.isEmpty() ? '' : processLevels[i].business_role__r.name, usersString));
        }while (++i < processLevels.size());
                
        return MCCTrackingSheetLevels;
    }


    private SPCM_Approval_Process_Level__c[] GetAllProcessLevels(String objectType, Decimal levels)
    {
        List<SPCM_Approval_Process_Level__c> res = new List<SPCM_Approval_Process_Level__c>();
        for(integer i = 1; i <= levels; i ++)
        {
            res.addAll(approvalMgr.GetProcessLevels(objectType, i));
        }
        return res;
    }


    private List<string> businessRolesList = new List<string> { 'C-Ops Channel Manager', 'C-Ops Contract Manager', 'C-Ops Executive',
        'C-Ops Group Channel Manager', 'C-Ops Group Manager', 'C-Ops Group Payer Manager', 'C-Ops Payer Manager', 'Channel Strategy Mgmt Exective',
        'GP eWorkflow Executive', 'MCC Contract Manager', 'MCC Executive', 'MCC Manager', 'MCCO Executive', 'Medicaid Contract Analyst Region 1',
        'Medicaid Contract Analyst Region 2', 'Medicaid Contract Analyst Region 3', 'Medicaid Contract Analyst', 'Medicaid Executive',
        'Medicaid Principal Contract Analyst', 'Operations Manager PFT', 'Payer Account Mgmt Executive', 'Channel Strategy Mgmt Executive',
        'Customer operations executive', 'SPCM Delegated Approver', 'SPCM Executive' , 'EC IT Support', 'EC SFDC IT Administrator',
         'SPCM Systems Administrator', 'Access Solutions Executive', 'GP eWorkflow Manager', 'Managed Care Legal', 'Medicaid Manager'};


    
    public virtual class BaseWrapper
    {
        public Integer LevelNumber {get; set;}
        public string LevelName {get; set;}
        public string Error {get; set;}
        public string Frequency {get; set;}
        public string BusinessRole {get; set;}
        public string Users {get; set;}
        public string States {get; set;}
        public string Region {get; set;}
        public string TeamSegment {get; set;}
        public BaseWrapper(Integer lvl, string name, string err)
        {
            LevelNumber = lvl;
            Error = err;
            LevelName = name;
        }
        public BaseWrapper(Integer lvl, string name, string freq, string err)
        {
            LevelNumber = lvl;
            Frequency = freq;
            Error = err;
            LevelName = name;
        }
        public BaseWrapper(Integer lvl, string name, string err, string role, string usr)
        {
            LevelNumber = lvl;
            Error = err;
            LevelName = name;
            BusinessRole = role;
            Users = usr;
        }
        public BaseWrapper(Integer lvl, string name, string err, string seg, string role, string usr)
        {
            LevelNumber = lvl;
            Error = err;
            LevelName = name;
            TeamSegment = seg;
            BusinessRole = role;
            Users = usr;
        }
        public BaseWrapper(Integer lvl, string name, string err, string reg, string sta, string role, string usr)
        {
            LevelNumber = lvl;
            Error = err;
            LevelName = name;
            States = sta;
            Region = reg;
            BusinessRole = role;
            Users = usr;
        }
    }
    
  

}