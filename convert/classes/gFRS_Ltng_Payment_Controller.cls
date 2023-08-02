public class gFRS_Ltng_Payment_Controller {
    public static list<MatchedBank> matchedBankDetails;
  
    @AuraEnabled
    public static userAndAppWrapper getCurrentFundingReqDetails(String applicationId){
        userAndAppWrapper userAppWrap = new userAndAppWrapper();
        gFRS_Ltng_Application__c appRec = gFRS_Ltng_Util_NoShare.fetchAppRec(applicationId);
        User userRec = [SELECT Id, Name FROM User WHERE Id =: userinfo.getuserid()];
        userAppWrap.userName = userRec.Name;
        userAppWrap.appRec = appRec;
        userAppWrap.isInternalReq = gFRS_Ltng_Util.isInternalRequest(appRec.Record_Type__c);
        return userAppWrap;
    
    }    
  
    @AuraEnabled
    public static userAndCopayAppWrapper getCopayFundingReqDetails(String applicationId){
        userAndCopayAppWrapper userAppWrap = new userAndCopayAppWrapper();
        gFRS_Ltng_CAF_Application__c appRec = gFRS_Ltng_Util_NoShare.fetchCopayAppRec(applicationId);
        User userRec = [SELECT Id, Name FROM User WHERE Id =: userinfo.getuserid()];
        userAppWrap.userName = userRec.Name;
        userAppWrap.appRec = appRec;
        return userAppWrap;
    
    }
    
    @AuraEnabled
    public static string getCostCenterDetails(String appId){
        gFRS_Ltng_Application__c appRecord = [SELECT Id, Name, Accountable_Employee_Internal__c FROM gFRS_Ltng_Application__c WHERE Id =: appId];
        User userRec = [SELECT Id, Name, External_ID_gne__c FROM User WHERE Id =: appRecord.Accountable_Employee_Internal__c];
        
        gFRS_EmployeeCostCenterWS.employeeCostCenterResponse_element response = null;
        try{
            system.debug('@@@ Inside getting cost center');
            gFRS_EmployeeCostCenterWS.GneCOMM_CostCenter_GFRS_O_1_LDAP_I_1_ServicesPort0 ws = new gFRS_EmployeeCostCenterWS.GneCOMM_CostCenter_GFRS_O_1_LDAP_I_1_ServicesPort0();
            ws.inputHttpHeaders_x = gFRS_util.createAuthenticationHeaderMap();
            ws.timeout_x = 60000;
            response = ws.employeeCostCenter(null, null, null, userRec.External_ID_gne__c, '1' );
            system.debug('@@@ Response status :'+response.MessageType);
            system.debug('@@@ Response :'+response);
            if(response.MessageType == 'Error' || response.MessageText == 'User not found in the system.'){
                return 'Error from SAP : '+response.MessageText;
            } else {
                return response.employeeDetails[0].costCenter.right(4);
            }
            
        } catch(Exception e){
            system.debug('@@ Exception ::'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
        
    }
    
    @AuraEnabled
    public static GFRS_Cost_Center_Code__c getNonAcctEmpCostCenter(String costCenter){

        try{
            GFRS_Cost_Center_Code__c costCenterRec = [SELECT Id, Name, Cost_Center__c FROM GFRS_Cost_Center_Code__c WHERE Cost_Center__c =: costCenter];
            return costCenterRec;
            
        } catch(Exception e){
            system.debug('@@ Exception  : '+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
        
    }    
    
    @AuraEnabled
    public static gFRS_Ltng_Application__c createOrUpdRequest(gFRS_Ltng_Application__c appInfoRec, String pmtType, String paymentOption, gFRS_Ltng_Vendor_Detail__c vendorRecord, String selectedVendor, list<MatchedLocation> vendorList, string country){
        system.debug('@@@ Rec Type : '+appInfoRec.Record_Type__c);
        try{
            Id vendorId;
            if(paymentOption == 'New Payment'){
                vendorRecord.gFRS_Organization__c = appInfoRec.Organization__c;
                if(country != 'United States'){
                    vendorRecord.Department_Chapter_Country__c = country;
                    vendorRecord.State__c = '';
                }
                upsert vendorRecord;
                
                appInfoRec.Vendor_Detail__c  = vendorRecord.Id;
                
                if(country == 'United States'){
                    if(pmtType == 'Bank Payment'){
                        appInfoRec.Payment_Method__c = 'ACH';
                    } else {
                        appInfoRec.Payment_Method__c = 'Check';
                    }
                } else {
                    appInfoRec.Payment_Method__c = 'Wire';
                }
                
                if(appInfoRec.Record_Type__c == 'Field Exhibits'){
                    appInfoRec.Selected_Tab_Val__c='cnfrm';  
                }
                
                appInfoRec.Payment_Info__c      = 'New';
                
                gFRS_Ltng_Util_NoShare.updateGfrsAPP(appInfoRec);
                
                vendorId = vendorRecord.Id;
            } else if(paymentOption == 'Existing Payment'){
                List<gFRS_Ltng_Vendor_Detail__c> vendorDetailRec = new List<gFRS_Ltng_Vendor_Detail__c>();
                vendorDetailRec = [SELECT Id, Name, Partner_Bank_Type__c FROM gFRS_Ltng_Vendor_Detail__c WHERE Vendor_ID__c =: selectedVendor Limit 1];
                
                if(vendorDetailRec.size() > 0){
                    
                    appInfoRec.Vendor_Detail__c         = vendorDetailRec[0].Id;
                    
                    if(country == 'United States'){
                        if(pmtType == 'Bank Payment'){
                            appInfoRec.Payment_Method__c = 'ACH';
                        } else {
                            appInfoRec.Payment_Method__c = 'Check';
                        }
                    } else {
                        if(pmtType == 'ACH'){
                            appInfoRec.Payment_Method__c = 'ACH';
                        } else {
                            appInfoRec.Payment_Method__c = 'Wire';
                        }
                    }
                    
                    if(appInfoRec.Record_Type__c == 'Field Exhibits'){
                        appInfoRec.Selected_Tab_Val__c='cnfrm';  
                    }
                                                                      
                    appInfoRec.Payment_Info__c = 'Existing';
                    
                    gFRS_Ltng_Util_NoShare.updateGfrsAPP(appInfoRec);
                    vendorId = vendorDetailRec[0].Id;
                } else {
                    gFRS_Ltng_Vendor_Detail__c vendorRec = new gFRS_Ltng_Vendor_Detail__c();
                        
                    for(MatchedLocation loc : vendorList){
                        if(loc.VendorId == selectedVendor){
                            vendorRec.gFRS_Organization__c          		= appInfoRec.Organization__c;
                            vendorRec.Name                          		= loc.City;
                            vendorRec.Vendor_ID__c                  		= loc.VendorId;
                            vendorRec.Address__c                    		= loc.Address;
                            vendorRec.City__c                       		= loc.City;
                            vendorRec.State__c                      		= loc.State;
                            vendorRec.Zip__c                        		= loc.Zip;
                            vendorRec.Department_Chapter_Country__c 		= loc.Country;
                            vendorRec.Payment_Method__c             		= loc.PaymentMethod;
                            
                            vendorRec.State_1__c              				= loc.State;
                            vendorRec.Zip_Code_1__c           				= loc.Zip;
                            vendorRec.City1__c                				= loc.city;
                            vendorRec.Vendor_Account_Group__c 				= loc.Parent_Account;
                            vendorRec.Country__c              				= loc.Country;
                            vendorRec.Street_4__c             				= loc.Street4;
                            vendorRec.Street_5__c             				= loc.Street5;
                            vendorRec.Vendor_Name_1__c        				= loc.NameLine1;
                            vendorRec.Vendor_Name_2__c        				= loc.NameLine2;
                            vendorRec.Vendor_Name_3__c        				= loc.NameLine3;
                            vendorRec.Vendor_Name_4__c        				= loc.NameLine4;
                            vendorRec.Vendor_Name__c          				= loc.Organization_Name;
                            vendorRec.PO_Box__c               				= loc.PoBox;
                            vendorRec.PO_Box_Postal_Code__c   				= loc.PoBoxPostalCode;
                            vendorRec.Payment_Block_Indicator__c             = loc.PaymentBlockIndicator;
                            vendorRec.Payment_Block_Description__c           = loc.PaymentBlockDescription;
                            vendorRec.Deletion_Flag_for_all_company_codes__c = loc.DeletionFlagAllArea;
                            vendorRec.CompanyCodeFor1000__c					= loc.CompanyCodeFor1000;
                            vendorRec.CompanyCodeFor1000Blocked__c			= loc.CompanyCodeFor1000Blocked;
                            vendorRec.CompanyCodeFor1010__c					= loc.CompanyCodeFor1010;
                            vendorRec.CompanyCodeFor1010Blocked__c			= loc.CompanyCodeFor1010Blocked;
                            
                            upsert vendorRec;
                            
                            appInfoRec.Vendor_Detail__c  = vendorRec.Id;
                            
                            if(country == 'United States'){
                                if(pmtType == 'Bank Payment'){
                                    appInfoRec.Payment_Method__c = 'ACH';
                                } else {
                                    appInfoRec.Payment_Method__c = 'Check';
                                }
                            } else {
                                if(pmtType == 'ACH'){
                                    appInfoRec.Payment_Method__c = 'ACH';
                                } else {
                                    appInfoRec.Payment_Method__c = 'Wire';
                                }
                            }
                            
                            if(appInfoRec.Record_Type__c == 'Field Exhibits'){
                                appInfoRec.Selected_Tab_Val__c='cnfrm';  
                            }
                                                                              
                            appInfoRec.Payment_Info__c = 'Existing';
                            
                            gFRS_Ltng_Util_NoShare.updateGfrsAPP(appInfoRec);
                            vendorId = vendorRec.Id;
                        }
                    }
                }
                
            }
            gFRS_Ltng_Application__c appRec = gFRS_Ltng_Util_NoShare.fetchAppRec(appInfoRec.Id);
            return appRec;
        }
        catch(Exception e){
            
            system.debug('@@ Exception :'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
    }

    @AuraEnabled
    public static List<finApproverWrapper> callCostCenterApprover(String amount,String expenseType,String maxCostCenter,String minCostCenter){
        try {
            gFRS_CostCenterApprovalWS.GneCOMM_CostCenter_GFRS_O_1_SAP_I_1_ServicesPort0 ws = new gFRS_CostCenterApprovalWS.GneCOMM_CostCenter_GFRS_O_1_SAP_I_1_ServicesPort0();
            ws.inputHttpHeaders_x = gFRS_util.createAuthenticationHeaderMap();
            ws.timeout_x = 60000;
            //-- do not pass the amount
            gFRS_CostCenterApprovalWS.costCenterApproverResponse_element response = ws.costCenterApprover( null, expenseType, maxCostCenter, minCostCenter);
            system.debug('@@@ Response : '+response);
            List<finApproverWrapper> FAwrapList = new List<finApproverWrapper>();
            
            for (gFRS_CostCenterApprovalWS.costCenterApprvers_element  CCA : response.costCenterApprvers) {
                finApproverWrapper FAwrap = new finApproverWrapper();
                FAwrap.costCenter 	= CCA.costCenter;
                FAwrap.level 		= CCA.level;
                FAwrap.firstName 	= CCA.firstName;
                FAwrap.lastName 	= CCA.lastName;
                FAwrap.amount 		= CCA.amount;
                FAwrap.unixId 		= CCA.unixId;
        
                FAwrapList.add(FAwrap);
            }
            return FAwrapList;
        }
        catch(Exception e){
            
            system.debug('@@ Exception :'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
        
    }
    
    public class finApproverWrapper {
        @AuraEnabled
        public String costCenter { get; set; }
        @AuraEnabled
        public String level { get; set; }
        @AuraEnabled
        public String firstName {get; set;}
        @AuraEnabled
        public String lastName {get; set;}
        @AuraEnabled
        public String amount {get; set;}
        @AuraEnabled
        public String unixId {get; set;}
        
    }
    
    @AuraEnabled
    public static void saveFADetails(String appId,String FAUnixId, string FALevel) {
        try {
            gFRS_Ltng_Application__c objAppRec = new gFRS_Ltng_Application__c();
            objAppRec.Id 		= appId;
            objAppRec.Selected_Tab_Val__c='cnfrm';  
            
            if(FAUnixId != null && FAUnixId != ''){
                gFRS_Ltng_Application__c applRecord = [SELECT Id, Name,Accountable_Employee_Internal__c,Record_Type_Name__c,Payment_from_accountable_emp_cost_center__c,Payment_Cost_Center__c,Requested_Amount__c,Pending_Action_from_gCOI__c FROM gFRS_Ltng_Application__c WHERE Id =:appId];
                user[] costCenterUser = [SELECT Id FROM User WHERE External_ID_gne__c = :FAUnixId LIMIT 1]; 
                
                if (costCenterUser.size() < 1) {
                    objAppRec.Pending_Action_from_gCOI__c = gFRS_Util.addMultiSelectItem( applRecord.Pending_Action_from_gCOI__c, 'Finance Approver does not exist in gFRS' );  
                } else {
                    objAppRec.Finance_Approver__c = costCenterUser[0].Id;
                    objAppRec.Finance_Approver_Level__c = FALevel;
                }
            }

            gFRS_Ltng_Util_NoShare.updateGfrsAPP(objAppRec);
        }
        catch(Exception e){
            
            system.debug('@@ Exception :'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }

    @AuraEnabled
    public static void createFoundationVendorRecord(gFRS_Ltng_Vendor_Detail__c vendorRecord,  gFRS_Ltng_Application__c applRec, String existingOrNew,  String selectedVendor, list<MatchedLocation> vendorList ){
        try{
            if(existingOrNew == 'New Payment'){
                vendorRecord.gFRS_Organization__c = applRec.Organization__c;
                vendorRecord.Name = vendorRecord.City__c;
                vendorRecord.Payment_Method__c ='C';
                insert vendorRecord;
                
                applRec.Vendor_Detail__c  = vendorRecord.Id; 
                applRec.Payment_Method__c = 'Check';
                                
                gFRS_Ltng_Util_NoShare.updateGfrsAPP(applRec);
                
            } else if(existingOrNew == 'Existing Payment'){
                List<gFRS_Ltng_Vendor_Detail__c> vendorDetailRec = new List<gFRS_Ltng_Vendor_Detail__c>();
                vendorDetailRec = [SELECT Id, Name FROM gFRS_Ltng_Vendor_Detail__c WHERE Vendor_ID__c =: selectedVendor Limit 1];
                
                if(vendorDetailRec.size() > 0){                    
                    applRec.Vendor_Detail__c  = vendorDetailRec[0].Id;
                    applRec.Payment_Method__c = 'Check';
                } else {
                    gFRS_Ltng_Vendor_Detail__c vendorRec = new gFRS_Ltng_Vendor_Detail__c();
                    
                    for(MatchedLocation loc : vendorList){
                        if(loc.VendorId == selectedVendor){
                            vendorRec.gFRS_Organization__c          = applRec.Organization__c;
                            vendorRec.Name                          = loc.City;
                            vendorRec.Vendor_ID__c                  = loc.VendorId;
                            vendorRec.Address__c                    = loc.Address;
                            vendorRec.City__c                       = loc.City;
                            vendorRec.State__c                      = loc.State;
                            vendorRec.Zip__c                        = loc.Zip;
                            vendorRec.Department_Chapter_Country__c = loc.Country;
                            
                            upsert vendorRec;
                            
                            applRec.Vendor_Detail__c  = vendorRec.Id;
                            applRec.Payment_Method__c = 'Check';
                            
                            applRec.Selected_Tab_Val__c='cnfrm';  
                            applRec.Payment_Info__c = 'Existing';
                            
                        }
                    }
                }
                    
                    if(!gFRS_Ltng_Util.isInternalRequest(applRec.Record_Type__c)){
                        applRec.Selected_Tab_Val__c='cnfrm';  
                    }
                    
                    gFRS_Ltng_Util_NoShare.updateGfrsAPP(applRec);
                }
                
            
        } catch(Exception e){
            system.debug('@@ Exception :'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    
    @AuraEnabled
    public static list<gFRS_Ltng_Vendor_Detail__c>  fetchFoundVendorDetails(String searchKey){
        try{
            List<gFRS_Ltng_Vendor_Detail__c> vendorDetails=[select id,Name,Organization_Tax_ID__c,Payment_Method__c,Organization_Name__c,gFRS_Organization__c,Address__c,Address2__c,City__c,State__c,Zip__c,Department_Chapter_Country__c from gFRS_Ltng_Vendor_Detail__c where Organization_Tax_ID__c=:searchKey];
            system.debug('vendor details'  +vendorDetails);
            return vendorDetails;  
        }
        catch(Exception e){
            system.debug('@@ Exception :'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    @AuraEnabled
    public static string  updatepayeeDetails(string vendorID , gFRS_Ltng_Application__c applRec){
        
         applRec.Vendor_Detail__c  = vendorID;
        if(!gFRS_Ltng_Util.isInternalRequest(applRec.Record_Type__c)){
            applRec.Selected_Tab_Val__c='cnfrm';  
        }
        try{
         gFRS_Ltng_Util_NoShare.updateGfrsAPP(applRec);
             return 'True';
        }
       catch(Exception e){
            system.debug('@@ Exception :'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
       
        
    }
    
    @AuraEnabled
    public static vendorWrapper createVendorRecord(gFRS_Ltng_Vendor_Detail__c vendorRecord, gFRS_Ltng_ACH_Details__c ACHRecord, gFRS_Ltng_Organization__c orgRecord, String pmtType, gFRS_Ltng_Application__c applRec, String existingOrNew, String vendPmtMethod, String chngPmtMethod, String selectedVendor, String partnerBankType, String newACHBankAcct, String orgHaveACH, list<MatchedLocation> vendorList, string country){
        try{
            Boolean sendVendorDetails = false;
            Boolean sendACHDetails = false;
            
            if(gFRS_Ltng_Util.isInternalRequest(applRec.Record_Type__c)){
                upsert orgRecord;
            }
            vendorWrapper vendorWrap = new vendorWrapper();
            Id AchIdVal;
            
            if(existingOrNew == 'New Payment'){
                vendorRecord.gFRS_Organization__c = applRec.Organization__c;
                if(country != 'United States'){
                    vendorRecord.Department_Chapter_Country__c = country;
                    vendorRecord.State__c = '';
                }
                upsert vendorRecord;
                sendVendorDetails = true;
                
                if(orgHaveACH == 'Yes'){
                    AchIdVal = encryptACH(vendorRecord.Id, ACHRecord, 'Non Copay');
                    if(applRec.Record_Type__c != 'Commercial Sponsorship'){
                        accountVerificationThruGiact(applRec.Id, ACHRecord.Bank_Account_Number__c, ACHRecord.Bank_Routing_ID__c, 'Non Copay');
                    }
                    
                    sendACHDetails = true;
                }
                
                applRec.Vendor_Detail__c  = vendorRecord.Id;
                
                if(country == 'United States'){
                    if(pmtType == 'Bank Payment'){
                        applRec.Payment_Method__c = 'ACH';
                    } else {
                        applRec.Payment_Method__c = 'Check';
                    }
                } else {
                    applRec.Payment_Method__c = 'Wire';
                }
                
                if(!gFRS_Ltng_Util.isInternalRequest(applRec.Record_Type__c)){
                    applRec.Selected_Tab_Val__c='cnfrm';  
                }
                
                applRec.Payment_Info__c         = 'New';
                applRec.ACH_Details_Rec_ID__c   = AchIdVal;
                applRec.Partner_Bank_Type__c    = '';
                
                if(applRec.Record_Type__c != 'Commercial Sponsorship'){
                    gFRS_Ltng_Util_NoShare.updateGfrsAPP(applRec);
                } else if(applRec.Record_Type__c == 'Commercial Sponsorship' && sendACHDetails == false){
                    gFRS_Ltng_Util_NoShare.updateGfrsAPP(applRec);
                    sendDetailsToVendorTeam(applRec, sendVendorDetails, sendACHDetails);
                } else {
                    String appRec = JSON.serialize(applRec);
                    accountVerificationThruGiactInternal(appRec, ACHRecord.Bank_Account_Number__c, ACHRecord.Bank_Routing_ID__c, 'Non Copay', sendVendorDetails, sendACHDetails);
                }
                
                vendorWrap.vendorId = vendorRecord.Id;
                vendorWrap.ACHId    = AchIdVal;
                
            } else if(existingOrNew == 'Existing Payment'){
                List<gFRS_Ltng_Vendor_Detail__c> vendorDetailRec = new List<gFRS_Ltng_Vendor_Detail__c>();
                vendorDetailRec = [SELECT Id, Name, Partner_Bank_Type__c FROM gFRS_Ltng_Vendor_Detail__c WHERE Vendor_ID__c =: selectedVendor Limit 1];
                //sendVendorDetails = true;
                
                if(vendorDetailRec.size() > 0){
                    
                    if(vendPmtMethod == 'C' && chngPmtMethod == 'Yes'){
                        AchIdVal = encryptACH(vendorDetailRec[0].Id, ACHRecord, 'Non Copay');
                        sendVendorDetails = true;
                        sendACHDetails = true;
                        if(applRec.Record_Type__c != 'Commercial Sponsorship'){
                            accountVerificationThruGiact(applRec.Id, ACHRecord.Bank_Account_Number__c, ACHRecord.Bank_Routing_ID__c, 'Non Copay');
                        }
                    }
                    
                    if(vendPmtMethod != 'C' && newACHBankAcct == 'Yes'){
                        AchIdVal = encryptACH(vendorDetailRec[0].Id, ACHRecord, 'Non Copay');
                        sendVendorDetails = true;
                        sendACHDetails = true;
                        if(applRec.Record_Type__c != 'Commercial Sponsorship'){
                            accountVerificationThruGiact(applRec.Id, ACHRecord.Bank_Account_Number__c, ACHRecord.Bank_Routing_ID__c, 'Non Copay');
                        }
                    }
                    
                    if(vendPmtMethod != 'C' && newACHBankAcct == 'No'){
                        applRec.Partner_Bank_Type__c = partnerBankType;
                        vendorDetailRec[0].Partner_Bank_Type__c = partnerBankType;
                        update vendorDetailRec;
                    } else {
                        if(country == 'United States'){
                            applRec.Partner_Bank_Type__c = '';
                        } else {
                            if(newACHBankAcct == 'Yes'){
                                applRec.Partner_Bank_Type__c = '';
                            } else {
                                applRec.Partner_Bank_Type__c = partnerBankType;
                                vendorDetailRec[0].Partner_Bank_Type__c = partnerBankType;
                                update vendorDetailRec;
                            }
                            
                        }
                    }
                    
                    applRec.Vendor_Detail__c        = vendorDetailRec[0].Id;
                    applRec.ACH_Details_Rec_ID__c   = AchIdVal;
                    
                    if(country == 'United States'){
                        if(pmtType == 'Bank Payment'){
                            applRec.Payment_Method__c = 'ACH';
                        } else {
                            applRec.Payment_Method__c = 'Check';
                        }
                    } else {
                        if(vendPmtMethod == 'A'){
                            applRec.Payment_Method__c = 'ACH';
                        } else {
                            applRec.Payment_Method__c = 'Wire';
                        }
                        
                    }
                    
                    if(!gFRS_Ltng_Util.isInternalRequest(applRec.Record_Type__c)){
                        applRec.Selected_Tab_Val__c='cnfrm';  
                    }
                    
                    applRec.Payment_Info__c = 'Existing';
                    
                    // gFRS_Ltng_Util_NoShare.updateGfrsAPP(applRec);
                    
                    if(applRec.Record_Type__c != 'Commercial Sponsorship'){
                        gFRS_Ltng_Util_NoShare.updateGfrsAPP(applRec);
                    } else if(applRec.Record_Type__c == 'Commercial Sponsorship' && sendACHDetails == false){
                        gFRS_Ltng_Util_NoShare.updateGfrsAPP(applRec);
                        //sendDetailsToVendorTeam(applRec, sendVendorDetails, sendACHDetails);
                    } else {
                        String appRec = JSON.serialize(applRec);
                        accountVerificationThruGiactInternal(appRec, ACHRecord.Bank_Account_Number__c, ACHRecord.Bank_Routing_ID__c, 'Non Copay', sendVendorDetails, sendACHDetails);
                    }
                    
                    vendorWrap.vendorId = vendorDetailRec[0].Id;
                    vendorWrap.ACHId    = AchIdVal;
                } else {
                    gFRS_Ltng_Vendor_Detail__c vendorRec = new gFRS_Ltng_Vendor_Detail__c();
                        
                    for(MatchedLocation loc : vendorList){
                        if(loc.VendorId == selectedVendor){
                            vendorRec.gFRS_Organization__c          		= applRec.Organization__c;
                            vendorRec.Name                          		= loc.City;
                            vendorRec.Vendor_ID__c                  		= loc.VendorId;
                            vendorRec.Address__c                    		= loc.Address;
                            vendorRec.City__c                       		= loc.City;
                            vendorRec.State__c                      		= loc.State;
                            vendorRec.Zip__c                        		= loc.Zip;
                            vendorRec.Department_Chapter_Country__c 		= loc.Country;
                            vendorRec.Payment_Method__c             		= loc.PaymentMethod;
                            
                            vendorRec.State_1__c              				= loc.State;
                            vendorRec.Zip_Code_1__c           				= loc.Zip;
                            vendorRec.City1__c                				= loc.city;
                            vendorRec.Vendor_Account_Group__c 				= loc.Parent_Account;
                            vendorRec.Country__c              				= loc.Country;
                            vendorRec.Street_4__c             				= loc.Street4;
                            vendorRec.Street_5__c             				= loc.Street5;
                            vendorRec.Vendor_Name_1__c        				= loc.NameLine1;
                            vendorRec.Vendor_Name_2__c        				= loc.NameLine2;
                            vendorRec.Vendor_Name_3__c        				= loc.NameLine3;
                            vendorRec.Vendor_Name_4__c        				= loc.NameLine4;
                            vendorRec.Vendor_Name__c          				= loc.Organization_Name;
                            vendorRec.PO_Box__c               				= loc.PoBox;
                            vendorRec.PO_Box_Postal_Code__c   				= loc.PoBoxPostalCode;
                            vendorRec.Payment_Block_Indicator__c             = loc.PaymentBlockIndicator;
                            vendorRec.Payment_Block_Description__c           = loc.PaymentBlockDescription;
                            vendorRec.Deletion_Flag_for_all_company_codes__c = loc.DeletionFlagAllArea;
                            vendorRec.CompanyCodeFor1000__c					= loc.CompanyCodeFor1000;
                            vendorRec.CompanyCodeFor1000Blocked__c			= loc.CompanyCodeFor1000Blocked;
                            vendorRec.CompanyCodeFor1010__c					= loc.CompanyCodeFor1010;
                            vendorRec.CompanyCodeFor1010Blocked__c			= loc.CompanyCodeFor1010Blocked;
                            
                            upsert vendorRec;
                            
                            
                            
                            if(vendPmtMethod == 'C' && chngPmtMethod == 'Yes'){
                                AchIdVal = encryptACH(vendorRec.Id, ACHRecord, 'Non Copay');
                                sendVendorDetails = true;
                                sendACHDetails = true;
                                if(applRec.Record_Type__c != 'Commercial Sponsorship'){
                                    accountVerificationThruGiact(applRec.Id, ACHRecord.Bank_Account_Number__c, ACHRecord.Bank_Routing_ID__c, 'Non Copay');
                                }
                            }
                            
                            if(vendPmtMethod != 'C' && newACHBankAcct == 'Yes'){
                                AchIdVal = encryptACH(vendorRec.Id, ACHRecord, 'Non Copay');
                                sendVendorDetails = true;
                                sendACHDetails = true;
                                if(applRec.Record_Type__c != 'Commercial Sponsorship'){
                                    accountVerificationThruGiact(applRec.Id, ACHRecord.Bank_Account_Number__c, ACHRecord.Bank_Routing_ID__c, 'Non Copay');
                                }
                            }
                            
                            if(vendPmtMethod != 'C' && newACHBankAcct == 'No'){
                                applRec.Partner_Bank_Type__c = partnerBankType;
                                vendorRec.Partner_Bank_Type__c = partnerBankType;
                                update vendorRec;
                            } else {
                                
                                if(country == 'United States'){
                                    applRec.Partner_Bank_Type__c = '';
                                } else {
                                    if(newACHBankAcct == 'Yes'){
                                        applRec.Partner_Bank_Type__c = '';
                                    } else {
                                        applRec.Partner_Bank_Type__c = partnerBankType;
                                        vendorRec.Partner_Bank_Type__c = partnerBankType;
                                        update vendorRec;
                                    }
                                    
                                }
                            }
                            
                            applRec.Vendor_Detail__c        = vendorRec.Id;
                            applRec.ACH_Details_Rec_ID__c   = AchIdVal;
                            
                            if(country == 'United States'){
                                if(pmtType == 'Bank Payment'){
                                    applRec.Payment_Method__c = 'ACH';
                                } else {
                                    applRec.Payment_Method__c = 'Check';
                                }
                            } else {
                                if(vendPmtMethod == 'A'){
                                    applRec.Payment_Method__c = 'ACH';
                                } else {
                                    applRec.Payment_Method__c = 'Wire';
                                }
                            }
                            
                            if(!gFRS_Ltng_Util.isInternalRequest(applRec.Record_Type__c)){
                                applRec.Selected_Tab_Val__c='cnfrm';  
                            }
                            
                            applRec.Payment_Info__c = 'Existing';
                            
                            // gFRS_Ltng_Util_NoShare.updateGfrsAPP(applRec);
                            
                            if(applRec.Record_Type__c != 'Commercial Sponsorship'){
                                gFRS_Ltng_Util_NoShare.updateGfrsAPP(applRec);
                            } else if(applRec.Record_Type__c == 'Commercial Sponsorship' && sendACHDetails == false){
                                gFRS_Ltng_Util_NoShare.updateGfrsAPP(applRec);
                                //sendDetailsToVendorTeam(applRec, sendVendorDetails, sendACHDetails);
                            } else {
                                String appRec = JSON.serialize(applRec);
                                accountVerificationThruGiactInternal(appRec, ACHRecord.Bank_Account_Number__c, ACHRecord.Bank_Routing_ID__c, 'Non Copay', sendVendorDetails, sendACHDetails);
                            }
                            
                            vendorWrap.vendorId = vendorRec.Id;
                            vendorWrap.ACHId    = AchIdVal;
                        }
                    }
                }
                
            }
            
            //generateACHForm(ACHRec.Id, applRec.Id);

            gFRS_Ltng_Util_NoShare.deleteTask(applRec.Id, 'Payment Method');  
            return vendorWrap;
            
        } catch(Exception e){
            system.debug('@@ Exception :'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    
    @future(callout=true)
    public static void accountVerificationThruGiactInternal(string appRec, string acctNumber, string routingID, string fundType, Boolean sendVendorDetails, Boolean sendACHDetails){
        try{
            gFRS_Ltng_Application__c applRec = (gFRS_Ltng_Application__c) JSON.deserialize(appRec, gFRS_Ltng_Application__c.class);
            GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
            String giactUserName = myOrgCS.Giact_User_Name__c;  
            String giactPassword = myOrgCS.Giact_Password__c;  
            String giactEndPoint = myOrgCS.Giact_Endpoint_URL__c;  
            String responseMessage;
            //String username = 'TRUDP-7XBXL-T0HUC-4TAP-M4RWP';
            //String password = 'helGb7-_pUivNkD';
            String tBody='{"UniqueId":"Giact Callout","Check":{"RoutingNumber": "'+routingID+'","AccountNumber":"'+acctNumber+'"},"Customer":{"EntityType": 0,"FirstName": "'+'Test'+'","LastName": "'+'Test'+'"},"GVerifyEnabled": true,"GAuthenticateEnabled": true}';
            Http http = new Http();	 
            HttpRequest  request = new HttpRequest();
            Blob headerValue = Blob.valueOf(giactUserName +':'+giactPassword);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            request.setHeader('Authorization',authorizationHeader);
            request.setMethod('POST');	 
            request.setHeader('Content-Length', '2000');
            request.setHeader('Content-Type', 'application/json');             
            request.setEndpoint(giactEndPoint);	                      
            request.setBody(tBody);	        
            HttpResponse response = http.send(request);	
            System.debug('response' + response.getBody());
            
            BankcheckWrapper finalResponse = (BankcheckWrapper) JSON.deserialize(response.getBody(), BankcheckWrapper.class);
            Integer ResponseCode = finalResponse.AccountResponseCode;
            System.debug('@@@ AccountResponseCode :'+ResponseCode);
            
            if(ResponseCode == 12 || ResponseCode == 14 || ResponseCode == 15){
                responseMessage = 'Account verification is successful';
            } else {
                responseMessage = 'Account verification is failed';
            }
            
            applRec.Giact_Response__c = responseMessage;
            
            gFRS_Ltng_Util_NoShare.updateGfrsAPP(applRec);
            sendDetailsToVendorTeam(applRec, sendVendorDetails, sendACHDetails);
            
        }
        catch(Exception e){
            System.debug('@@@ Error Message during Giact call out :'+e.getMessage());
        }        
    }
    
    @AuraEnabled
    public static void sendDetailsToVendorTeam(gFRS_Ltng_Application__c objAppRec, Boolean sendVendorDetails, Boolean sendACHDetails){
        User currentUserRec = [ SELECT Id, Email, Name FROM User WHERE Id = :(UserInfo.getUserId()) limit 1 ];
        gFRS_Ltng_Vendor_Detail__c location               = null;
        gFRS_Ltng_Organization__c objOrg                  = null;
        List<gFRS_Ltng_Application__c> fundingRequestsList = new List<gFRS_Ltng_Application__c>();
        
        GFRS_Ltng_OrgSettings__c orgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
        
        String targetEmailStr;
        if(orgCS.SAP_ContactList__c == '' || orgCS.SAP_ContactList__c == null){
            targetEmailStr   = System.Label.GFRS_SAP_ContactList;
        } else {
            targetEmailStr   = orgCS.SAP_ContactList__c;
        }
        
        String[] targetEmailList                          = targetEmailStr.split( ';' );
        
        try {
            location = [ SELECT Name, Vendor_Id__c, gFRS_Organization__r.Id, 
                        gFRS_Organization__r.Organization_Name__c, 
                        gFRS_Organization__r.Tax_Id__c, gFRS_Organization__r.Tax_Status__c, 
                        Vendor_Name__c, Address__c, Address2__c, City__c, State__c, Province__c,
                        Zip__c, Department_Chapter_Country__c 
                        FROM gFRS_Ltng_Vendor_Detail__c 
                        WHERE Id = :objAppRec.Vendor_Detail__c ];
        } catch(Exception e){
            //return 'Unable to find the location:';
            system.debug('@@ Unable to find the location:');
        }
        
        try
        {
            objOrg = [SELECT Id, gFRS_W9_Form_W_8BEN_Form__c
                      FROM gFRS_Ltng_Organization__c 
                      WHERE Id= : location.gFRS_Organization__r.Id];
        } catch(Exception e){
            system.debug('@@ Unable to find the org:');
        }
        
        
		//Gathering gFRS Application records that are assigned to given location, but only with Status != "Intake","Closed".
        fundingRequestsList = gFRS_Ltng_Util.getFundingRequestsByLocationId(objAppRec.Vendor_Detail__c);
        
        
        String targetEmailName = 'gFRS_Add_SAP_Location';
        EmailTemplate template = null;
        try {
            template = [ SELECT TemplateType, Subject, Name, Description, HtmlValue, Body 
                        FROM EmailTemplate 
                        WHERE DeveloperName = :targetEmailName limit 1 ];
        } catch(Exception e){ 
            template = null; 
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setUseSignature( true );
        mail.setSaveAsActivity(true);
        
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        
        if (objOrg.gFRS_W9_Form_W_8BEN_Form__c != null) {
            
            Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
            
            ContentVersion cv = [SELECT title,PathOnClient, FileType, versiondata FROM contentversion 
                                 WHERE ContentDocumentId =: objOrg.gFRS_W9_Form_W_8BEN_Form__c Limit 1 
                                ];
            Blob attBody = cv.VersionData;
            
            if (attBody != null) {
                att.setBody(attBody);
                att.setFileName(cv.title);
                att.setInline(false);
                att.setContentType('application/octet-stream');
                attachments.add(att);
            }
        }
        
        mail.setSubject(formatEmailSubject(template.Subject, location.Name));
        mail.setPlainTextBody( formatEmailText( template.Body, location, currentUserRec.Name, currentUserRec.Email, fundingRequestsList ));
        
        if(attachments.size() > 0){
            mail.setFileAttachments(attachments);
        }       
        
        List<String> ccAddresses = new List<String>{currentUserRec.Email};
            
        /* if(String.isNotBlank(orgCS.Vendor_Update_CC_Email__c)){
            ccAddresses.add(orgCS.Vendor_Update_CC_Email__c); 
        } */
        
        mail.setccAddresses(ccAddresses);
        mail.setToAddresses( targetEmailList ); 
        
        List<gFRS_Ltng_Application__c> fundingReq = new List<gFRS_Ltng_Application__c>();
        fundingReq = [SELECT Id, Name, ACH_Details_Rec_ID__c FROM gFRS_Ltng_Application__c WHERE Id = :objAppRec.Id AND ACH_Details_Rec_ID__c != null AND ACH_Details_Rec_ID__c != '' AND ACH_PDF_Sent_to_SAP__c = false AND Status__c != 'Intake' ];
        
        if(fundingReq.size() > 0){
            Integer count = 1;
            for(gFRS_Ltng_Application__c req : fundingReq){
                gFRS_Ltng_ACH_Details__c ACHDecryptedRec = new gFRS_Ltng_ACH_Details__c();
                gFRS_Ltng_ACH_Details__c ACHRec = [SELECT  Id,gFRS_Vendor_Detail__c,Account_Type__c,Payment_Method_UI__c,Bank_Routing_ID__c,Bank_Name__c,
                                                   Bank_Account_Number__c,IBAN__c,Account_Holder_Name__c,Payment_Information_Approver_Name__c,
                                                   Title__c,Do_you_require_intermediary_bank__c,Intermediary_Bank_Name__c,Intermediary_Bank_Country__c,
                                                   Intermediary_Bank_Account_Number__c,Intermediary_Bank_Swift_Code__c,Intermediary_Bank_Routing_ID__c 
                                                   FROM gFRS_Ltng_ACH_Details__c WHERE Id =: req.ACH_Details_Rec_ID__c];      
                
                PageReference ref = new PageReference('/apex/pages/gFRS_Ltng_ACHForm?id=' + ACHRec.Id + '&reqId=' + req.Id);
                ref.setRedirect(false);
                
                Messaging.EmailFileAttachment attch = new Messaging.EmailFileAttachment();
                Blob b = ref.getContent();
                attch.setBody(b);
                attch.setFileName('ACHForm '+count+'.pdf');
                attch.setInline(false);
                attch.setContentType('application/pdf');
                attachments.add(attch);
                
                //delete ACHDecryptedRec;
                
                count++;
                
            }
        }
        
        if(attachments.size() > 0){
            mail.setFileAttachments(attachments);
        }
        
        String serverURL = orgCS.Vendor_Update_CC_Email__c;       
        mail.setOrgWideEmailAddressId([
            SELECT Id, Address
            FROM OrgWideEmailAddress
            WHERE Address = :serverURL
            limit 1
        ][0].id);  
        
        List<Messaging.SendEmailResult> result1 = Messaging.sendEmail( new Messaging.SingleEmailMessage[]{ mail } );
    }
    
    public static String formatEmailSubject( String emailSubject, String payeeName) {
        if(emailSubject == null) {
            return null;
        }
        
        emailSubject = emailSubject.replace('[[PAYEE_NAME]]', gFRS_Util.blankValue(payeeName, ''));
        return emailSubject;
    }
    
    public static String formatEmailText( String emailText, gFRS_Ltng_Vendor_Detail__c location, string userName, string userEmail, List<gFRS_Ltng_Application__c> fundingRequestsList) {
        String TAG_ORGANIZATION_NAME       = '[[ORGANIZATION_NAME]]';
        String TAG_ORGANIZATION_TAX_ID     = '[[TAX_ID]]';
        String TAG_ORGANIZATION_TAX_STATUS = '[[TAX_STATUS]]';
        
        String TAG_VENDOR_ID               = '[[VENDOR_ID]]';
        String TAG_VENDOR_NAME             = '[[VENDOR_NAME]]';
        String TAG_VENDOR_ADDRESS          = '[[VENDOR_ADDRESS]]';
        String TAG_VENDOR_CITY             = '[[VENDOR_CITY]]';
        String TAG_VENDOR_STATE            = '[[VENDOR_STATE]]';
        String TAG_VENDOR_PROVINCE         = '[[PROVINCE]]';
        String TAG_VENDOR_ZIP              = '[[VENDOR_ZIP]]';
        String TAG_VENDOR_COUNTRY          = '[[VENDOR_COUNTRY]]';
        String TAG_USER_NAME               = '[[USER_NAME]]';
        String TAG_USER_EMAIL              = '[[USER_EMAIL]]';
        
        String TAG_REQUEST_IDS             = '[[REQUEST_IDS]]';
        String TAG_PAYEE_NAME              = '[[PAYEE_NAME]]';  
        
        if( emailText == null || location == null || userName == null || fundingRequestsList == null) return( null );
        
        String requestsListText = '';
        
        emailText = emailText.replace(TAG_ORGANIZATION_NAME,   gFRS_Util.blankValue( location.gFRS_Organization__r.Organization_Name__c, '' ));
        emailText = emailText.replace(TAG_ORGANIZATION_TAX_ID, gFRS_Util.blankValue( location.gFRS_Organization__r.Tax_Id__c, '' ));
        emailText = emailText.replace(TAG_ORGANIZATION_TAX_STATUS, gFRS_Util.blankValue( location.gFRS_Organization__r.Tax_Status__c, '' ));
        
        emailText = emailText.replace(TAG_VENDOR_ID,           gFRS_Util.blankValue( location.Vendor_Id__c, '' ));
        emailText = emailText.replace(TAG_VENDOR_NAME,         gFRS_Util.blankValue( location.Name, '' ));
        emailText = emailText.replace(TAG_VENDOR_ADDRESS,      location.Address2__c == null ? gFRS_Util.blankValue( location.Address__c, '' ) : gFRS_Util.blankValue( location.Address__c + ' ' + location.Address2__c, '' ));
        emailText = emailText.replace(TAG_VENDOR_CITY,         gFRS_Util.blankValue( location.City__c, '' ));
        emailText = emailText.replace(TAG_VENDOR_STATE,        gFRS_Util.blankValue( location.State__c, '' ));
        emailText = emailText.replace(TAG_VENDOR_PROVINCE,        gFRS_Util.blankValue( location.Province__c, '' ));
        emailText = emailText.replace(TAG_VENDOR_ZIP,          gFRS_Util.blankValue( location.Zip__c, '' ));
        emailText = emailText.replace(TAG_VENDOR_COUNTRY,      gFRS_Util.blankValue( location.Department_Chapter_Country__c, '' ));
        emailText = emailText.replace(TAG_USER_NAME,           userName);
        emailText = emailText.replace(TAG_USER_EMAIL,          userEmail);
        
        for(gFRS_Ltng_Application__c fundingRequest : fundingRequestsList){
            String giactResp = '';
            if(fundingRequest.Giact_Response__c != '' && fundingRequest.Giact_Response__c != null){
                giactResp = fundingRequest.Giact_Response__c;
            }
            requestsListText += fundingRequest.Record_Type__c + ': ' + fundingRequest.Name + '\n';
            requestsListText += 'Payment Contact Email Address' + ': ' + fundingRequest.Person_To_Whom_Payment_should_addressed__c + '\n';
            requestsListText += 'GIACT Response' + ': ' + giactResp + '\n\n';
        }
        
        emailText = emailText.replace(TAG_REQUEST_IDS, requestsListText);
        
        
        return( emailText );
    }
    
    @future(callout=true)
    public static void accountVerificationThruGiact(Id appId, string acctNumber, string routingID, string fundType){
        try{
            GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
            String giactUserName = myOrgCS.Giact_User_Name__c;  
            String giactPassword = myOrgCS.Giact_Password__c;  
            String giactEndPoint = myOrgCS.Giact_Endpoint_URL__c;  
            String responseMessage;
            //String username = 'TRUDP-7XBXL-T0HUC-4TAP-M4RWP';
            //String password = 'helGb7-_pUivNkD';
            String tBody='{"UniqueId":"Giact Callout","Check":{"RoutingNumber": "'+routingID+'","AccountNumber":"'+acctNumber+'"},"Customer":{"EntityType": 0,"FirstName": "'+'Test'+'","LastName": "'+'Test'+'"},"GVerifyEnabled": true,"GAuthenticateEnabled": true}';
            Http http = new Http();	 
            HttpRequest  request = new HttpRequest();
            Blob headerValue = Blob.valueOf(giactUserName +':'+giactPassword);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            request.setHeader('Authorization',authorizationHeader);
            request.setMethod('POST');	 
            request.setHeader('Content-Length', '2000');
            request.setHeader('Content-Type', 'application/json');             
            request.setEndpoint(giactEndPoint);	                      
            request.setBody(tBody);	        
            HttpResponse response = http.send(request);	
            System.debug('response' + response.getBody());
            
            BankcheckWrapper finalResponse = (BankcheckWrapper) JSON.deserialize(response.getBody(), BankcheckWrapper.class);
            Integer ResponseCode = finalResponse.AccountResponseCode;
            System.debug('@@@ AccountResponseCode :'+ResponseCode);
            
            gFRS_Ltng_Application__c 		applRec = new gFRS_Ltng_Application__c();
            gFRS_Ltng_CAF_Application__c 	CAFapplRec = new gFRS_Ltng_CAF_Application__c();
            
            if(ResponseCode == 12 || ResponseCode == 14 || ResponseCode == 15){
                responseMessage = 'Account verification is successful';
            } else {
                responseMessage = 'Account verification is failed';
            }
            
            if(fundType == 'Copay'){
                CAFapplRec.Id = appId;
                CAFapplRec.Giact_Response__c = responseMessage;
                
                gFRS_Ltng_Util_NoShare.updateCAFAPP(CAFapplRec);
            } else {
                applRec.Id = appId;
                applRec.Giact_Response__c = responseMessage;
                
                gFRS_Ltng_Util_NoShare.updateGfrsAPP(applRec);
            }
            
        }
        catch(Exception e){
            System.debug('@@@ Error Message during Giact call out :'+e.getMessage());
        }        
    }
    
    @AuraEnabled
    public static vendorWrapper createCopayVendorRecord(gFRS_Ltng_CAF_Vendor_Detail__c vendorRecord, gFRS_Ltng_ACH_Details__c ACHRecord, gFRS_Ltng_Organization__c orgRecord, String pmtType, gFRS_Ltng_CAF_Application__c applRec, String existingOrNew, String vendPmtMethod, String chngPmtMethod, String selectedVendor, String partnerBankType, String newACHBankAcct, String orgHaveACH, list<MatchedLocation> vendorList, string country){
        try{

            vendorWrapper vendorWrap = new vendorWrapper();
            Id AchIdVal;
            
            if(existingOrNew == 'New Payment'){
                vendorRecord.gFRS_Organization__c = applRec.gFRS_Organization__c;
                if(country != 'United States'){
                    vendorRecord.Country__c = country;
                    vendorRecord.State__c = '';
                }
                upsert vendorRecord;
                
                if(orgHaveACH == 'Yes'){
                    AchIdVal = encryptACH(vendorRecord.Id, ACHRecord, 'Copay');
                    accountVerificationThruGiact(applRec.Id, ACHRecord.Bank_Account_Number__c, ACHRecord.Bank_Routing_ID__c, 'Copay');
                }
                
                applRec.Vendor_Detail__c  = vendorRecord.Id;
                
                if(country == 'United States'){
                    if(pmtType == 'Bank Payment'){
                        applRec.Payment_Method__c = 'ACH';
                    } else {
                        applRec.Payment_Method__c = 'Check';
                    }
                } else {
                    applRec.Payment_Method__c = 'Wire';
                }
                
                applRec.SelectedTab__c='cnfrm';  
                
                applRec.Payment_Info__c         = 'New';
                applRec.ACH_Details_Rec_ID__c   = AchIdVal;
                applRec.Partner_Bank_Type__c    = '';
                
                gFRS_Ltng_Util_NoShare.updateCAFAPP(applRec);
                
                vendorWrap.vendorId = vendorRecord.Id;
                vendorWrap.ACHId    = AchIdVal;
                
            } else if(existingOrNew == 'Existing Payment'){
                List<gFRS_Ltng_CAF_Vendor_Detail__c> vendorDetailRec = new List<gFRS_Ltng_CAF_Vendor_Detail__c>();
                vendorDetailRec = [SELECT Id, Name, Partner_Bank_Type__c FROM gFRS_Ltng_CAF_Vendor_Detail__c WHERE Vendor_ID__c =: selectedVendor Limit 1];
                
                if(vendorDetailRec.size() > 0){
                    
                    if(vendPmtMethod == 'C' && chngPmtMethod == 'Yes'){
                        AchIdVal = encryptACH(vendorDetailRec[0].Id, ACHRecord, 'Copay');
                    }
                    
                    if(vendPmtMethod != 'C' && newACHBankAcct == 'Yes'){
                        AchIdVal = encryptACH(vendorDetailRec[0].Id, ACHRecord, 'Copay');
                    }
                    
                    if(vendPmtMethod != 'C' && newACHBankAcct == 'No'){
                        applRec.Partner_Bank_Type__c = partnerBankType;
                        vendorDetailRec[0].Partner_Bank_Type__c = partnerBankType;
                        update vendorDetailRec;
                    } else {
                        if(country == 'United States'){
                            applRec.Partner_Bank_Type__c = '';
                        } else {
                            if(newACHBankAcct == 'Yes'){
                                applRec.Partner_Bank_Type__c = '';
                            } else {
                                applRec.Partner_Bank_Type__c = partnerBankType;
                                vendorDetailRec[0].Partner_Bank_Type__c = partnerBankType;
                                update vendorDetailRec;
                            }
                            
                        }
                    }
                    
                    applRec.Vendor_Detail__c        = vendorDetailRec[0].Id;
                    applRec.ACH_Details_Rec_ID__c   = AchIdVal;
                    
                    if(country == 'United States'){
                        if(pmtType == 'Bank Payment'){
                            applRec.Payment_Method__c = 'ACH';
                        } else {
                            applRec.Payment_Method__c = 'Check';
                        }
                    } else {
                        if(vendPmtMethod == 'A'){
                            applRec.Payment_Method__c = 'ACH';
                        } else {
                            applRec.Payment_Method__c = 'Wire';
                        }
                    }
                    
                    applRec.SelectedTab__c = 'cnfrm';  
                    
                    applRec.Payment_Info__c = 'Existing';
                    
                    gFRS_Ltng_Util_NoShare.updateCAFAPP(applRec);
                    
                    vendorWrap.vendorId = vendorDetailRec[0].Id;
                    vendorWrap.ACHId    = AchIdVal;
                } else {
                    gFRS_Ltng_CAF_Vendor_Detail__c vendorRec = new gFRS_Ltng_CAF_Vendor_Detail__c();
                        
                    for(MatchedLocation loc : vendorList){
                        if(loc.VendorId == selectedVendor){
                            vendorRec.gFRS_Organization__c          = applRec.gFRS_Organization__c;
                            vendorRec.Name                          = loc.City;
                            vendorRec.Vendor_ID__c                  = loc.VendorId;
                            vendorRec.Address_1__c                  = loc.Address;
                            vendorRec.City__c                       = loc.City;
                            vendorRec.State__c                      = loc.State;
                            vendorRec.Zip__c                        = loc.Zip;
                            vendorRec.Country__c                    = loc.Country;
                            
                            upsert vendorRec;

                            if(vendPmtMethod == 'C' && chngPmtMethod == 'Yes'){
                                AchIdVal = encryptACH(vendorRec.Id, ACHRecord, 'Copay');
                            }
                            
                            if(vendPmtMethod != 'C' && newACHBankAcct == 'Yes'){
                                AchIdVal = encryptACH(vendorRec.Id, ACHRecord, 'Copay');
                            }
                            
                            if(vendPmtMethod != 'C' && newACHBankAcct == 'No'){
                                applRec.Partner_Bank_Type__c = partnerBankType;
                                vendorRec.Partner_Bank_Type__c = partnerBankType;
                                update vendorRec;
                            } else {
                                applRec.Partner_Bank_Type__c = '';
                                
                                if(country == 'United States'){
                                    applRec.Partner_Bank_Type__c = '';
                                } else {
                                    if(newACHBankAcct == 'Yes'){
                                        applRec.Partner_Bank_Type__c = '';
                                    } else {
                                        applRec.Partner_Bank_Type__c = partnerBankType;
                                        vendorRec.Partner_Bank_Type__c = partnerBankType;
                                        update vendorRec;
                                    }
                                    
                                }
                            }
                            
                            applRec.Vendor_Detail__c        = vendorRec.Id;
                            applRec.ACH_Details_Rec_ID__c   = AchIdVal;
                            
                            if(country == 'United States'){
                                if(pmtType == 'Bank Payment'){
                                    applRec.Payment_Method__c = 'ACH';
                                } else {
                                    applRec.Payment_Method__c = 'Check';
                                }
                            } else {
                                if(vendPmtMethod == 'A'){
                                    applRec.Payment_Method__c = 'ACH';
                                } else {
                                    applRec.Payment_Method__c = 'Wire';
                                }
                            }
                            
                            applRec.SelectedTab__c = 'cnfrm';  
                            
                            applRec.Payment_Info__c = 'Existing';
                            
                            gFRS_Ltng_Util_NoShare.updateCAFAPP(applRec);
                            
                            vendorWrap.vendorId = vendorRec.Id;
                            vendorWrap.ACHId    = AchIdVal;
                        }
                    }
                }
                
            }
            
            //generateACHForm(ACHRec.Id, applRec.Id);

            //gFRS_Ltng_Util_NoShare.deleteTask(applRec.Id);  
            return vendorWrap;
            
        } catch(Exception e){
            system.debug('@@ Exception :'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }    
    
    public static Id encryptACH(Id vendorId, gFRS_Ltng_ACH_Details__c ACHRecord, string typeOfReq){
        EncryptionKey__c keySetting = EncryptionKey__c.getOrgDefaults();
        
        if(String.isBlank(keySetting.aeskey__c)) {
            keySetting.aeskey__c = EncodingUtil.base64Encode(Crypto.generateAesKey(256));
            upsert keySetting;
        }
        
        Blob aesKey;
        //Blob ACHData;
        aesKey = EncodingUtil.base64Decode(keySetting.AesKey__c);
        
        gFRS_Ltng_ACH_Details__c ACHRec = new gFRS_Ltng_ACH_Details__c();
        
        if(String.isNotBlank(ACHRecord.Id)){
            ACHRec.Id = Id.valueOf(ACHRecord.Id);
        }
        
        if(typeOfReq == 'Non Copay'){
            ACHRec.gFRS_Vendor_Detail__c = vendorId;
        } else {
            ACHRec.gFRS_CAF_Vendor_Detail__c = vendorId;
        }
        
        ACHRec.Account_Type__c       = ACHRecord.Account_Type__c;
        ACHRec.Payment_Method_UI__c  = ACHRecord.Payment_Method_UI__c;
        system.debug('@@ Routing ID :'+ACHRecord.Bank_Routing_ID__c);
        Blob ACHData1 = Blob.valueOf(ACHRecord.Bank_Routing_ID__c);
        ACHRec.Bank_Routing_ID__c       = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', aesKey, ACHData1));
        Blob ACHData2 = Blob.valueOf(ACHRecord.Bank_Name__c);
        ACHRec.Bank_Name__c             = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', aesKey, ACHData2));
        Blob ACHData3 = Blob.valueOf(ACHRecord.Bank_Account_Number__c);
        ACHRec.Bank_Account_Number__c   = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', aesKey, ACHData3));
        Blob ACHData4 = Blob.valueOf(ACHRecord.IBAN__c);
        ACHRec.IBAN__c                  = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', aesKey, ACHData4));
        Blob ACHData5 = Blob.valueOf(ACHRecord.Account_Holder_Name__c);
        ACHRec.Account_Holder_Name__c   = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', aesKey, ACHData5));
        Blob ACHData6 = Blob.valueOf(ACHRecord.Payment_Information_Approver_Name__c);
        ACHRec.Payment_Information_Approver_Name__c = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', aesKey, ACHData6));
        Blob ACHData7 = Blob.valueOf(ACHRecord.Title__c);
        ACHRec.Title__c                 = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', aesKey, ACHData7));
        ACHRec.Do_you_require_intermediary_bank__c  = ACHRecord.Do_you_require_intermediary_bank__c;
        if(ACHRecord.Do_you_require_intermediary_bank__c == 'Yes'){
            Blob ACHData8 = Blob.valueOf(ACHRecord.Intermediary_Bank_Name__c);
            ACHRec.Intermediary_Bank_Name__c    = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', aesKey, ACHData8));
            Blob ACHData9 = Blob.valueOf(ACHRecord.Intermediary_Bank_Country__c);
            ACHRec.Intermediary_Bank_Country__c = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', aesKey, ACHData9));
            Blob ACHData10 = Blob.valueOf(ACHRecord.Intermediary_Bank_Account_Number__c);
            ACHRec.Intermediary_Bank_Account_Number__c      = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', aesKey, ACHData10));
            Blob ACHData11 = Blob.valueOf(ACHRecord.Intermediary_Bank_Swift_Code__c);
            ACHRec.Intermediary_Bank_Swift_Code__c          = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', aesKey, ACHData11));
            Blob ACHData12 = Blob.valueOf(ACHRecord.Intermediary_Bank_Routing_ID__c);
            ACHRec.Intermediary_Bank_Routing_ID__c          = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', aesKey, ACHData12));
        } else {
            ACHRec.Intermediary_Bank_Name__c            = '';
            ACHRec.Intermediary_Bank_Country__c         = '';
            ACHRec.Intermediary_Bank_Account_Number__c  = '';
            ACHRec.Intermediary_Bank_Swift_Code__c      = '';
            ACHRec.Intermediary_Bank_Routing_ID__c      = '';
        }
        
        upsert ACHRec;  
        
        /* system.debug('@@ Encrypted Routing ID :'+ACHRec.Bank_Routing_ID__c);
        Blob dest = EncodingUtil.base64Decode(ACHRec.Bank_Routing_ID__c);
        Blob decrypted = Crypto.decryptWithManagedIV('AES256', aesKey, dest);
        string finalText = decrypted.toString();
        system.debug('@@ Decrypted :'+finalText); */
        
        return ACHRec.Id;
    }

    @AuraEnabled
    public static list<MatchedLocation> getVendorDetails(String searchKey){
        list<MatchedLocation> matchedLocations = new List<MatchedLocation>();
        gFRS_Ltng_VendorLookup_SAP_WS.GneCOMM_VendorMaster_GFRS_I_1_V2_WSD_Vendor_Lookup_Port sapLookup = new gFRS_Ltng_VendorLookup_SAP_WS.GneCOMM_VendorMaster_GFRS_I_1_V2_WSD_Vendor_Lookup_Port();
        sapLookup.inputHttpHeaders_x = gFRS_Util.createAuthenticationHeaderMap();
        sapLookup.timeout_x = 60000;
        
        gFRS_Ltng_VendorLookup_SAP_WS.VendorLookupResponse response;
        
        try{
            response = sapLookup.VendorLookup( '', '', searchKey, '', '', '100' ); 
        } catch( Exception e ){
            system.debug('@@ Exception :'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj; 
        }
        system.debug('@@@ Response : '+response);
        matchedLocations = handleResponse(response);   
        return matchedLocations;
    }  
    
    public static list<MatchedLocation> handleResponse(gFRS_Ltng_VendorLookup_SAP_WS.VendorLookupResponse response) {
        try{
            list<MatchedLocation> matchedLocations = new list<MatchedLocation>();
            if ( response.MessageText != null ) {
                MatchedLocation l = new MatchedLocation();
                l.errorMsg = 'There is no vendor that matches your search criteria. Please try a different search.';
                matchedLocations.add(l);
                return matchedLocations;
            }
            
            if(response.VendorDetails != null){
                for (gFRS_Ltng_VendorLookup_SAP_WS.VendorDetails  d : response.VendorDetails) {
                    
                    system.debug('@@@ Value : '+d);
                    MatchedLocation l = new MatchedLocation();
                    
                    if(string.isNotBlank(d.NameLine1)){
                        l.Organization_Name = d.NameLine1;
                    }
                    
                    if(string.isNotBlank(d.NameLine2)){
                        l.Organization_Name = l.Organization_Name+' '+d.NameLine2;
                    }
                    
                    if(string.isNotBlank(d.NameLine3)){
                        l.Organization_Name = l.Organization_Name+' '+d.NameLine3;
                    }
                    
                    if(string.isNotBlank(d.NameLine4)){
                        l.Organization_Name = l.Organization_Name+' '+d.NameLine4;
                    }
                    
                    if(string.isNotBlank(d.TaxId)){
                        l.Tax_ID            = d.TaxId;
                    }
                    
                    if(string.isNotBlank(d.TelephoneExt) || string.isNotBlank(d.Telephone)){
                        l.Phone             = d.TelephoneExt+' '+d.Telephone;
                    }
                    
                    if(string.isNotBlank(d.AddressLine1)){
                        l.Address           = d.AddressLine1; 
                    }
                    
                    if(string.isNotBlank(d.City)){
                        l.City              = d.City;
                    }
                    
                    if(string.isNotBlank(d.State)){
                        l.State             = d.State;
                    }
                    
                    if(string.isNotBlank(d.Zip)){
                        l.Zip               = d.Zip;
                    }
                    
                    if(string.isNotBlank(d.PoBox)){
                        l.PoBox             = d.PoBox;
                    }
                    
                    if(string.isNotBlank(d.PoBoxPostalCode)){
                        l.PoBoxPostalCode   = d.PoBoxPostalCode; 
                    }
                    
                    if(string.isNotBlank(d.VendorID)){
                        l.VendorId          = d.VendorID;
                    }
                    
                    if(string.isNotBlank(d.PaymentMethod)){
                        l.PaymentMethod     = d.PaymentMethod;
                    }
                    
                    if(string.isNotBlank(d.Country)){
                        l.Country           = d.Country;
                    }
                    
                    if(string.isNotBlank(d.Street4)){
                        l.Street4           = d.Street4;
                    }
                    
                    if(string.isNotBlank(d.Street5)){
                        l.Street5           = d.Street5;
                    }
                    
                    if(string.isNotBlank(d.NameLine1)){
                        l.NameLine1         = d.NameLine1;
                    }
                    
                    if(string.isNotBlank(d.NameLine2)){
                        l.NameLine2         = d.NameLine2;
                    }
                    
                    if(string.isNotBlank(d.NameLine3)){
                        l.NameLine3         = d.NameLine3;
                    }
                    
                    if(string.isNotBlank(d.NameLine4)){
                        l.NameLine4         = d.NameLine4;
                    }
                    
                    if(string.isNotBlank(d.PostingBlockSpecifiedCompanyCode)){
                        l.PostingBlockSpecifiedCompanyCode  = d.PostingBlockSpecifiedCompanyCode;
                    }
                    
                    if(string.isNotBlank(d.PostingBlockAllCompanyCode)){
                        l.PostingBlockAllCompanyCode        = d.PostingBlockAllCompanyCode;
                    }
                    
                    if(string.isNotBlank(d.PaymentBlockIndicator)){
                        l.PaymentBlockIndicator             = d.PaymentBlockIndicator;
                    }
                    
                    if(string.isNotBlank(d.PaymentBlockDescription)){
                        l.PaymentBlockDescription           = d.PaymentBlockDescription;
                    }
                    
                    if(string.isNotBlank(d.DeletionFlagSelectedCompanyCode)){
                        l.DeletionFlagSelectedCompanyCode   = d.DeletionFlagSelectedCompanyCode;
                    }
                    
                    if(string.isNotBlank(d.DeletionFlagAllArea)){
                        l.DeletionFlagAllArea               = d.DeletionFlagAllArea;
                    }
                    
                    matchedLocations.add(l);
                }
            }
            
            return matchedLocations;
        } catch( Exception e ){
            system.debug('@@ Exception :'+e.getMessage());
            system.debug('@@ Exception Line :'+e.getLineNumber());
            return null; 
        }
    }

    @AuraEnabled
    public static gFRS_Ltng_ACH_Details__c getACHDetails(Id ACHRecordId){
        gFRS_Ltng_ACH_Details__c ACHRec = new gFRS_Ltng_ACH_Details__c();
        gFRS_Ltng_ACH_Details__c ACHDecryptedRec = new gFRS_Ltng_ACH_Details__c();

        try {
            ACHRec = [SELECT  Id,gFRS_Vendor_Detail__c,Account_Type__c,Payment_Method_UI__c,Bank_Routing_ID__c,Bank_Name__c,
                            Bank_Account_Number__c,IBAN__c,Account_Holder_Name__c,Payment_Information_Approver_Name__c,
                            Title__c,Do_you_require_intermediary_bank__c,Intermediary_Bank_Name__c,Intermediary_Bank_Country__c,
                            Intermediary_Bank_Account_Number__c,Intermediary_Bank_Swift_Code__c,Intermediary_Bank_Routing_ID__c 
                            FROM gFRS_Ltng_ACH_Details__c WHERE Id =: ACHRecordId];
            
            ACHDecryptedRec.Bank_Routing_ID__c                  = decryptACH(ACHRec.Bank_Routing_ID__c);
            ACHDecryptedRec.Bank_Name__c                        = decryptACH(ACHRec.Bank_Name__c);
            ACHDecryptedRec.Bank_Account_Number__c              = decryptACH(ACHRec.Bank_Account_Number__c);
            ACHDecryptedRec.IBAN__c                             = decryptACH(ACHRec.IBAN__c);
            ACHDecryptedRec.Account_Holder_Name__c              = decryptACH(ACHRec.Account_Holder_Name__c);
            ACHDecryptedRec.Account_Type__c                     = ACHRec.Account_Type__c;
            ACHDecryptedRec.Payment_Method_UI__c                = ACHRec.Payment_Method_UI__c;
            ACHDecryptedRec.Title__c                            = decryptACH(ACHRec.Title__c);
            ACHDecryptedRec.Do_you_require_intermediary_bank__c = ACHRec.Do_you_require_intermediary_bank__c;
            
            if(ACHRec.Do_you_require_intermediary_bank__c == 'Yes'){
                ACHDecryptedRec.Intermediary_Bank_Name__c           = decryptACH(ACHRec.Intermediary_Bank_Name__c);
                ACHDecryptedRec.Intermediary_Bank_Country__c        = decryptACH(ACHRec.Intermediary_Bank_Country__c);
                ACHDecryptedRec.Intermediary_Bank_Account_Number__c = decryptACH(ACHRec.Intermediary_Bank_Account_Number__c);
                ACHDecryptedRec.Intermediary_Bank_Swift_Code__c     = decryptACH(ACHRec.Intermediary_Bank_Swift_Code__c);
                ACHDecryptedRec.Intermediary_Bank_Routing_ID__c     = decryptACH(ACHRec.Intermediary_Bank_Routing_ID__c);
            }
            
            return ACHDecryptedRec;
            
        } catch( Exception e ){
            system.debug('@@ Exception :'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj; 
        }
    } 
    
    public static string decryptACH(string stringToDecrypt){
        EncryptionKey__c keySetting = EncryptionKey__c.getOrgDefaults();
        Blob aesKey = EncodingUtil.base64Decode(keySetting.AesKey__c);
        Blob decoder = EncodingUtil.base64Decode(stringToDecrypt);
        Blob decryptor = Crypto.decryptWithManagedIV('AES256', aesKey, decoder);
        string decryptedStr = decryptor.toString();
        return decryptedStr;
    }

    @AuraEnabled
    public static list<MatchedBank> getBankDetails(String vendorID){
        list<MatchedBank> matchedBanks = new List<MatchedBank>();
        GFRS_BankLookupSAP.GneCOMM_VendorMaster_GFRS_I_2_ServicesPort0 sapLookup = new GFRS_BankLookupSAP.GneCOMM_VendorMaster_GFRS_I_2_ServicesPort0();
        sapLookup.inputHttpHeaders_x = gFRS_Util.createAuthenticationHeaderMap();
        GFRS_BankLookupSAP.BankInfoLookupResponse_element response;
        try {
            response = sapLookup.BankInfoLookup(vendorID);
            
            GFRS_BankLookupSAP.BankInfoDetails_element[] BankInfoDetailsvar = response.BankInfoDetails;
            for(GFRS_BankLookupSAP.BankInfoDetails_element element : BankInfoDetailsvar){
                matchedbank m = new matchedBank();
                m.BankAccountNumberstring = element.BankAccountNumber; 
                m.BankInfoKeystring = element.BankInfoKey;  
                m.PartnerBankTypestring = element.PartnerBankType;
                m.Countrystring = element.Country;
                
                matchedbanks.add(m);
            }
            
            matchedBankDetails = matchedbanks;
            
            return matchedbanks;
        } catch( Exception e ){
            system.debug('@@ Exception :'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj; 
        }
    }     

    public class MatchedBank {
        @AuraEnabled public boolean isselected{get; set;}
        @AuraEnabled public string BankId  {get; set;}
        @AuraEnabled public String BankAccountNumberString { get; set; }
        @AuraEnabled public String BankInfoKeyString { get; set; }
        @AuraEnabled public String PartnerBankTypeString { get; set; }
        @AuraEnabled public String CountryString { get; set; }
        public MatchedBank(){
            this.isselected = false;
        }   
    }
    
    public class MatchedLocation {
        
        @AuraEnabled public String errorMsg { get; set; }
        @AuraEnabled public String Organization_Name { get; set; }
        @AuraEnabled public String Tax_ID            { get; set; }
        @AuraEnabled public String Organization_Type { get; set; }
        @AuraEnabled public String Phone             { get; set; }
        @AuraEnabled public String Parent_Account    { get; set; }
        @AuraEnabled public String Address           { get; set; }
        @AuraEnabled public String Tax_Status        { get; set; }
        @AuraEnabled public String City              { get; set; }
        @AuraEnabled public String State             { get; set; }
        @AuraEnabled public String Zip               { get; set; }
        @AuraEnabled public String PoBox             { get; set; }
        @AuraEnabled public String PoBoxPostalCode   { get; set; }
        @AuraEnabled public String VendorId          { get; set; }
        @AuraEnabled public String PaymentMethod     { get; set; }
        @AuraEnabled public String VendorName        { get; set; }
        @AuraEnabled public String Country           { get; set; }
        @AuraEnabled public String Street4           { get; set; }
        @AuraEnabled public String Street5           { get; set; }
        @AuraEnabled public String NameLine1         { get; set; }
        @AuraEnabled public String NameLine2         { get; set; }
        @AuraEnabled public String NameLine3         { get; set; }
        @AuraEnabled public String NameLine4         { get; set; }
        @AuraEnabled public String PostingBlockSpecifiedCompanyCode  { get; set; }
        @AuraEnabled public String PostingBlockAllCompanyCode        { get; set; }
        @AuraEnabled public String PaymentBlockIndicator             { get; set; }
        @AuraEnabled public String PaymentBlockDescription           { get; set; }
        @AuraEnabled public String DeletionFlagSelectedCompanyCode   { get; set; }
        @AuraEnabled public String DeletionFlagAllArea               { get; set; }
        @AuraEnabled public String CompanyCodeFor1000        		 { get; set; }
        @AuraEnabled public String CompanyCodeFor1000Blocked     	 { get; set; }
        @AuraEnabled public String CompanyCodeFor1010      			 { get; set; }
        @AuraEnabled public String CompanyCodeFor1010Blocked       	 { get; set; }
    }
    
    @AuraEnabled  
    public static List<picklistWrapper> getPicklistvalues(string objAPIName, string fieldAPIname) {
        list<picklistWrapper> returnValue = new list<picklistWrapper>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.sObjectType objType = schemaMap.get(objAPIName);
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        list < Schema.PicklistEntry > values = fieldMap.get(fieldAPIname).getDescribe().getPickListValues();

        for (Schema.PicklistEntry a: values) {
            picklistWrapper aa = new picklistWrapper();
            aa.pickListLabel = a.getLabel();
            aa.pickListValue = a.getValue();
            returnValue.add(aa);
        }
        system.debug('@@@ returnValue :'+returnValue);
        return returnValue;   
    }   
    
    public class picklistWrapper{
        @AuraEnabled 
        public string pickListLabel;
        @AuraEnabled 
        public string pickListValue;
        
    }
    
    public class vendorWrapper{
        @AuraEnabled 
        public Id vendorId;
        @AuraEnabled 
        public Id ACHId;
        
    }    
    
    public class userAndAppWrapper{
        @AuraEnabled 
        public string userName;
        @AuraEnabled 
        public gFRS_Ltng_Application__c appRec;
        @AuraEnabled 
        public Boolean isInternalReq;
        
    } 
    
    public class userAndCopayAppWrapper{
        @AuraEnabled 
        public string userName;
        @AuraEnabled 
        public gFRS_Ltng_CAF_Application__c appRec;
        
    }     

    @AuraEnabled
    public static void generateACHForm(Id ACHRecId, Id appId){
        generatePDF(ACHRecId,appId);    
    }
    
    @future(callout=true)
    public static void generatePDF(Id ACHRecId, Id appId){
        
        //PageReference ref = new PageReference('https://genentech--gfrsdev08.my.salesforce.com/apex/pages/gFRS_Ltng_ACHForm?id=' + vendorDetailId);
        PageReference ref = new PageReference('/apex/pages/gFRS_Ltng_ACHForm?id=' + ACHRecId);
        System.debug(ref);
        ContentVersion cont = new ContentVersion();
        cont.Title = 'Auto-generated ACH Form';
        cont.PathOnClient = 'file.pdf';
        cont.VersionData = ref.getContentAsPdf();
        cont.OwnerId = UserInfo.getUserId();
        cont.Origin = 'H';
        Insert cont;
        
        //After saved the Content Verison, get the ContentDocumentId
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cont.Id].ContentDocumentId;
        
        //Insert ContentDocumentLink
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = ACHRecId;//Add attachment parentId
        cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        Insert cDocLink;
       
        /*vendorObj.Bank_Account_Number__c = '';
        vendorObj.Intermediary__c = '';
        vendorObj.Intermediary_Bank_Routing_Number__c = '';
        update vendorObj; */
    }    
    
   
}