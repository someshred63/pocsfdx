global without sharing class GNE_Med_iPhone_CreateReferral {

    /* 
    This is a webservice in SFDC that is used by iPhone and SFDC to create Referral.
    Referral is a Medical Communication request to an MSL. The Referral is identified as a Medical communication
  request with a recordType Referral.
  
    Author : Sweta Khalasi
    Created : 01 Jul 2011
    Last Modified : 24 Aug 2011
    Project : gMARS Phase 2
  
  */
    global class ReferralInfo  implements iPhoneBase.RequestTestable {
        WebService String RequestId;
        WebService Id AccountId;
        WebService Id AddressId;
        WebService String MedicalQuestion;
        WebService String FollowupMethod;
        WebService Id ProductId;
        WebService Id MoleculeId;
        WebService Id TA_SubTAId;
        WebService Date RequestedCompletionDate;
        WebService String Priority;
        WebService Id RequestedById;
        WebService Boolean isMedComm;
        WebService Id UserId;
        WebService Id AssignedToId;
        WebService String phone;
        WebService Boolean isOtrRequest;
        WebService Date RevisedCompletionDate;
        WebService String Status;
        WebService String Comment;
        WebService String RecordId;
        WebService String Language;

        public ReferralInfo(){}
        
        public void testRequest() {
            GNE_Med_iPhone_CreateReferral.intCreateReferral(this, new Response());
        }
    }
    
    // response 
    global class Response {
        WebService DateTime StartTime = DateTime.now();
        WebService DateTime EndTime   = null;
        WebService String ErrorMessage;
        Medical_Communication_gne__c newReferral = null;
        Referral_Assignment_gne__c newReferralAssignment = null;
        public Response(){}
        public Medical_Communication_gne__c getResponseReferral(){
            return newReferral;
        }
        public Referral_Assignment_gne__c getResponseReferralAssignment(){
            return newReferralAssignment;
        }
        public void setResponseReferral(Medical_Communication_gne__c newRef){
            newReferral = newRef;
        }
        public void setResponseReferralAssignment(Referral_Assignment_gne__c newReferralAss){
            newReferralAssignment = newReferralAss;
        }
    }
    
    public GNE_Med_iPhone_CreateReferral(){}
    WebService static void getDemo()
    {
        System.debug('Inside getDemo webservice:');
        System.debug('UserInfo.getName(): ' + UserInfo.getName());
    }
    WebService static List<Address_vod__c> getAddresses(Id AccId)
    {
        System.debug('Inside getAddresses webservice:');
        List<Address_vod__c> lstAddresses = new List<Address_vod__c>();     
        lstAddresses = [Select Id, Account_vod__c, Name, Inactive_vod__c, Active_Flag_gne__c, City_vod__c, Country_gen__c, State_vod__c, Fax_vod__c, Fax_2_vod__c, Phone_1_Ext_gne__c, Phone_2_Ext_gne__c, Phone_2_vod__c, Phone_vod__c, Email_gne__c, License_Status_vod__c, License_vod__c, Address_1_gne__c, Address_line_2_vod__c, Address_Line_3_gne__c, Address_Line_4_gne__c, Address_Type_gne__c from Address_vod__c where Account_vod__c = :AccId And Inactive_vod__c = false];
        System.debug('Inside getAddresses lstAddresses:' + lstAddresses);
        return lstAddresses;
    }
    
    WebService static Response createReferral(ReferralInfo refInfo){
        return createReferral(refInfo, true);
    }
    
    WebService static Response upsertReferralOldWayCanada(ReferralInfo refInfo){
        return upsertReferralOldWayCanada(refInfo, true);
    }

    public static Response createReferral(ReferralInfo refInfo, Boolean logErrorMode){
        Response callResponse = new Response();
        SavePoint savePoint = Database.setSavePoint();
        
        try {
            callResponse = intCreateReferral(refInfo, callResponse);
        } catch(Exception e) {
            Database.rollback (savePoint);
            callResponse.ErrorMessage = e.getMessage();
            callResponse.setResponseReferral(new Medical_Communication_gne__c());
            callResponse.setResponseReferralAssignment(new Referral_Assignment_gne__c());
            
            if(logErrorMode) {
                iPhoneBase.handleException(e, UserInfo.getUserId(), (refInfo.isOtrRequest==true ? 'OTR' : null),
                        'Create Referral', GNE_Med_iPhone_CreateReferral.ReferralInfo.class, refInfo.RequestId, refInfo, 
                        '[MedCommCreateReferral] Error while creating Referral');
            }
        }
        
        callResponse.EndTime = DateTime.now();
        return callResponse;
    }
    
    public static Response intCreateReferral(ReferralInfo refInfo, Response callResponse) {
        if(String.isNotBlank(refInfo.RequestId)) {
            List<Medical_Communication_gne__c>medCommRecords = iPhone_DAO.getMedicalCommunicationByRequestId(refInfo.RequestId);
            
            if(!medCommRecords.isEmpty()) {
                Referral_Assignment_gne__c referral = iPhone_DAO.getReferralAssignmentById(medCommRecords.get(0).Referral_Assignment_gne__c);
                callResponse.ErrorMessage = '';
                callResponse.setResponseReferral(medCommRecords.get(0));
                callResponse.setResponseReferralAssignment(referral);
                callResponse.EndTime = DateTime.now();
                return callResponse;
            }
        }
        
        List<String> lstFieldValidationErrors = new List<string> ();
        Medical_Communication_gne__c newReferral = new Medical_Communication_gne__c();
        Referral_Assignment_gne__c newReferralAssignment = new Referral_Assignment_gne__c();
        
        String strAssignedUserName='';
        String strAssignedUserRole='';
        String strAddressState='';
        Map<String,Id> mapRefId = new Map<String,Id> ();
        User assignedUser = new User();
        
        User assignedUserManager = new User();
        User finalAssignedUser = new User();
        Map<String,User> mapUserId = new Map<String,User> ();
        
        Boolean isAssigned = false;
        GNE_Referral_Utils.isMedicalReferral = true;
        
        try{
            newReferral.RecordTypeId = GNE_Referral_Utils.getReferralRecordType().id;
            
            if(String.isNotBlank(refInfo.AccountId)){
                newReferral.Account_gne__c = refInfo.AccountId;
                newReferral.Account_Referral_gne__c = refInfo.AccountId;
                if(String.isNotBlank(refInfo.AddressId)){
                    Address_vod__c objAddress = GNE_Referral_Utils.getAddressInfo(refInfo.AddressId, refInfo.AccountId);
                    System.debug('Inside createReferral objAddress: ' + objAddress);
                    if(objAddress != null){
                        newReferral.Address_Line_1_gne__c=objAddress.Name;
                        newReferral.Address_Line_2_gne__c=objAddress.Address_line_2_vod__c;
                        newReferral.Address_Line_3_gne__c=objAddress.Address_Line_3_gne__c;
                        newReferral.Address_Line_4_gne__c=objAddress.Address_Line_4_gne__c;
                        newReferral.City_gne__c=objAddress.City_vod__c;
                        newReferral.Country_gne__c=objAddress.Country_gen__c;
                        
                        if(String.isNotBlank(objAddress.State_vod__c)) {
                            strAddressState = objAddress.State_vod__c;
                            newReferral.State_gne__c = strAddressState;
                        }
                        
                        if(String.isNotBlank(objAddress.Email_gne__c)) {
                            newReferral.Email_gne__c=objAddress.Email_gne__c;
                        }
                        
                        if(String.isNotBlank(objAddress.Phone_vod__c)) {
                            newReferral.Phone_gne__c=objAddress.Phone_vod__c;
                        }
                        
                        if(String.isNotBlank(refInfo.phone)) {
                            newReferral.Phone_gne__c=refInfo.phone;
                        }
                            
                        if(String.isNotBlank(objAddress.Phone_2_vod__c)) {
                            newReferral.Phone_1_gne__c=objAddress.Phone_2_vod__c;
                        }
                        
                        if(String.isNotBlank(objAddress.Fax_vod__c)) {
                            newReferral.Fax_gne__c=objAddress.Fax_vod__c;
                        } else if(String.isNotBlank(objAddress.Fax_2_vod__c)){
                            newReferral.Fax_gne__c=objAddress.Fax_2_vod__c;
                        }
                        
                        /*truncating the zip code to 5 since the medcomm interface cannot handle zip code chars greater than 5 chars*/
                        if(String.isNotBlank(objAddress.Zip_vod__c)){
                            newReferral.Zip_gne__c=objAddress.Zip_vod__c.substring(0,5);
                        }
                        if(String.isNotBlank(objAddress.Zip_4_vod__c)){
                            newReferral.Zip_4_gne__c=objAddress.Zip_4_vod__c;
                        }                       
                    }else{
                        lstFieldValidationErrors.add('Address not available.');
                    }
                }else{
                    lstFieldValidationErrors.add('Address cannot be blank.');
                }
            }else{
                lstFieldValidationErrors.add('Account can not be blank.');
            }
            if(String.isNotBlank(refInfo.Priority)){
                newReferral.Priority_gne__c=refInfo.Priority;
            }else{
                lstFieldValidationErrors.add('Priority can not be blank.');
            }           
            if(String.isNotBlank(refInfo.RequestId)){
                newReferral.iphone_request_id_gne__c=refInfo.RequestId;         
            }
            DateTime dueDate = GNE_Referral_Utils.getDueDate(datetime.now(),(String)newReferral.Priority_gne__c);
            
            if(String.isNotBlank(refInfo.MedicalQuestion)){
                newReferral.Medical_Question_gne__c=refInfo.MedicalQuestion;
            }else{
                lstFieldValidationErrors.add('Question/Request can not be blank.');
            }
            if(String.isNotBlank(refInfo.FollowupMethod)){
                newReferral.Follow_up_Method_gne__c=refInfo.FollowupMethod;
            }else{
                lstFieldValidationErrors.add('Follow-up Method can not be blank.');
            }
            if(String.isNotBlank(refInfo.ProductId))
                newReferral.Product_gne__c=refInfo.ProductId;
            if(String.isNotBlank(refInfo.MoleculeId))
                newReferral.Molecule_gne__c=refInfo.MoleculeId;
            if(String.isNotBlank(refInfo.TA_SubTAId)){
                newReferral.TA_SubTA_gne__c=refInfo.TA_SubTAId;
                if(String.isNotBlank(refInfo.RequestedById)){
                    newReferral.Requested_By_gne__c=refInfo.RequestedById;
                    newReferral.Is_MedComm_gne__c=refInfo.isMedComm;
                    newReferral.Referral_Source_gne__c = GNE_Referral_Utils.getReferralSource(refInfo.RequestedById);
                }else{
                    if(refInfo.isMedComm){
                        newReferral.Is_MedComm_gne__c=refInfo.isMedComm;
                        newReferral.Referral_Source_gne__c = GNE_Referral_Utils.getMedCommReferralSource();
                    }else{
                        refInfo.RequestedById = UserInfo.getUserId();
                        newReferral.Is_MedComm_gne__c=refInfo.isMedComm;
                        newReferral.Requested_By_gne__c=UserInfo.getUserId();
                        newReferral.Referral_Source_gne__c = GNE_Referral_Utils.getReferralSource(UserInfo.getUserId());
                    }                   
                }
                if(String.isNotBlank(refInfo.AssignedToId)){
                    //Manual Assignment
                    assignedUser = GNE_Referral_Utils.getCurrentUser(refInfo.AssignedToId);
                    GNE_Referral_Utils.loadUserProfileType(assignedUser);
                    if(assignedUser != null){
                        if(GNE_Referral_Utils.isMCL || GNE_Referral_Utils.isMSL){
                            refInfo.AssignedToId = GNE_Referral_Utils.getManualAssigned(assignedUser.Id,dueDate);
                            if(String.isBlank(refInfo.AssignedToId)){
                                isAssigned = false;
                                System.debug('User not found: ');
                                lstFieldValidationErrors.add('Referral can not be assigned to inactive user, please asign to someone else.');
                            }else{
                                //assignedUserManager = GNE_Referral_Utils.getAssignedManagerUser(refInfo.AssignedToId);
                                //mapUserId = GNE_Referral_Utils.getAssignedManagerUser(refInfo.AssignedToId);
                                isAssigned = true;                              
                            }
                        }else if(GNE_Referral_Utils.isManager){
                            if(GNE_Referral_Utils.isOnVacation(assignedUser.Id,dueDate)){
                                isAssigned = false;
                                System.debug('Manager is on vacation: ');
                                lstFieldValidationErrors.add((String)assignedUser.name + ' is out of office, please asign to someone else.');
                            }else{
                                isAssigned = true;
                                refInfo.AssignedToId = assignedUser.Id;
                                //assignedUserManager = GNE_Referral_Utils.getAssignedManagerUser(refInfo.AssignedToId);
                                //mapUserId = GNE_Referral_Utils.getAssignedManagerUser(refInfo.AssignedToId);
                            }
                        }else{
                            isAssigned = false;
                            System.debug('assigned to non-MedAffair user: ');
                            lstFieldValidationErrors.add('Referral can not be assigned to non-MedAffair user, please asign to MedAffair user.');
                        }
                    }else{
                        isAssigned = false;
                        System.debug('inactive user: ');
                        lstFieldValidationErrors.add('Referral can not be assigned to inactive user, please asign to someone else.');
                    }
                    System.debug('(String)refInfo.AssignedToId: ' + (String)refInfo.AssignedToId);
                }else{
                    //Auto Assignment
                    assignedUser = GNE_Referral_Utils.getCurrentUser(UserInfo.getUserId());
                    GNE_Referral_Utils.recursiveCount = 0;
                    refInfo.AssignedToId = GNE_Referral_Utils.getAutoAssigned(refInfo.TA_SubTAId, strAddressState, assignedUser, dueDate);
                    System.debug('(String)refInfo.AssignedToId: ' + (String)refInfo.AssignedToId);
                    if(String.isBlank(refInfo.AssignedToId)){
                        isAssigned = false;
                        lstFieldValidationErrors.add('MSL not found for selected TA-SubTA, so please do manual assignment.');
                    }else{
                        isAssigned = true;                      
                    }
                }
                if(isAssigned){
                    Id oldAssignedId = refInfo.AssignedToId;
                    refInfo.AssignedToId = GNE_Referral_Utils.getAssignedIncludingToT(refInfo.AssignedToId);
                                
                    String strAssignedUserNameRole = GNE_Referral_Utils.getUserNameAndRole((String)refInfo.AssignedToId);
                    String[] lstUserNameAndRole = strAssignedUserNameRole.split(',',2);
                    System.debug('lstUserNameAndRole: ' + lstUserNameAndRole);
                    if(lstUserNameAndRole.size() >0){
                        strAssignedUserName =lstUserNameAndRole[0];
                        strAssignedUserRole =lstUserNameAndRole[1];                     
                    }
                    
                    Boolean isReasigned = !((String)oldAssignedId).equals((String)refInfo.AssignedToId);
                    
                    String dateTimeText = datetime.now().format(GNE_Referral_Utils.strPSTFormat,GNE_Referral_Utils.strPST);
                    //newReferral.Referral_History_gne__c=datetime.now().format() + ',' + GNE_Referral_Utils.strCreated + ',' + UserInfo.getName() + ',' + strAssignedUserName + ',' + (String)refInfo.AssignedToId + ',' + strAssignedUserRole + ',' + GNE_Referral_Utils.strAssigned + ';';
                    newReferral.Referral_History_gne__c= GNE_Referral_Utils.createHistoryInfo(dateTimeText, 
                        isReasigned ? GNE_Referral_Utils.strReassigned : GNE_Referral_Utils.strCreated,
                        strAssignedUserName,
                        refInfo.AssignedToId, strAssignedUserRole);
                    
                    // If we switched from MSL which is on vacation, store this info in history
                    if(isReasigned) {
                        strAssignedUserNameRole = GNE_Referral_Utils.getUserNameAndRole((String)oldAssignedId);
                        lstUserNameAndRole = strAssignedUserNameRole.split(',',2);
                        System.debug('lstUserNameAndRole On ToT: ' + lstUserNameAndRole);
                        if(lstUserNameAndRole.size() >0){
                            strAssignedUserName =lstUserNameAndRole[0];
                            strAssignedUserRole =lstUserNameAndRole[1];
                            
                            newReferral.Referral_History_gne__c = GNE_Referral_Utils.createHistoryInfo(dateTimeText, 
                                                                    GNE_Referral_Utils.strCreated,
                                                                    strAssignedUserName, oldAssignedId, strAssignedUserRole) +
                                                                  newReferral.Referral_History_gne__c;                     
                        }
                    }
                    
                    newReferralAssignment.OwnerId = refInfo.AssignedToId;
                    newReferralAssignment.Assigned_To_gne__c = refInfo.AssignedToId;
                    mapUserId = GNE_Referral_Utils.getAssignedManagerUser(refInfo.AssignedToId);
                    if(mapUserId != null && mapUserId.size()>0){
                        if(mapUserId.containsKey('ManagerId')){
                            assignedUserManager = mapUserId.get('ManagerId');
                        }
                        if(mapUserId.containsKey('UserId')){
                            finalAssignedUser = mapUserId.get('UserId');
                        }                               
                    }
                    if(assignedUserManager != null){
                        newReferralAssignment.Assigned_To_Manager_gne__c = assignedUserManager.Id;
                        newReferralAssignment.Referral_Assigned_Manager_Email_gne__c = assignedUserManager.Email;
                    }
                    if(finalAssignedUser != null){
                        newReferralAssignment.Referral_Assigned_User_Email_gne__c = finalAssignedUser.Email;
                    }
                    
                    System.debug('String.valueOf(refInfo.RequestedCompletionDate):' + String.valueOf(refInfo.RequestedCompletionDate));
                    if(refInfo.RequestedCompletionDate != null)
                        newReferral.Requested_Completion_Date_gne__c=refInfo.RequestedCompletionDate;
                    
                    insert newReferral;
                    mapRefId.put(GNE_Referral_Utils.strObjectName,newReferral.Id);
                    
                    newReferralAssignment.Medical_Request_gne__c = newReferral.Id;          
                    newReferralAssignment.Status_Referral_gne__c = GNE_Referral_Utils.strAssigned;
                    newReferralAssignment.Status_Referral_Date_gne__c = datetime.now();
                    newReferralAssignment.Due_Date_gne__c = dueDate;
                    newReferralAssignment.Status_Email_gne__c = GNE_Referral_Utils.strStatusSendEmail;
                    newReferralAssignment.Status_Email_Date_gne__c = datetime.now();
                    insert newReferralAssignment;
                    mapRefId.put(GNE_Referral_Utils.strRefObjectName,newReferralAssignment.Id);
                    System.debug('Successfully inserted Referral Assignment:');
                    
                    newReferral.Referral_Assignment_gne__c = newReferralAssignment.Id;
                    update newReferral;
                    System.debug('Successfully updated Referral:' + newReferral); 
                    
                    System.debug('UserInfo.getUserId(): ' + UserInfo.getUserId());
                    
                    System.debug('Successfully inserted Referral Assignment :' + newReferralAssignment); 
                    if(GNE_Referral_Utils.sendReferralEmail(newReferralAssignment,newReferral,GNE_Referral_Utils.strAssigned)){
                        System.debug('Successfully Referral Creation Email sent:');
                        newReferralAssignment.Status_Email_gne__c = GNE_Referral_Utils.strStatusAssignedEmail;
                        newReferralAssignment.Status_Email_Date_gne__c = datetime.now();
                        update newReferralAssignment;
                    }
                    else{
                        System.debug('Email Not sent:');
                        lstFieldValidationErrors.add('Due to some error Assigned Email not sent so DML Rollback.');
                    }                       
                }
            }else{
                lstFieldValidationErrors.add('TA-SubTAId can not be blank.');
            }
            
            
            
            if(lstFieldValidationErrors != null && lstFieldValidationErrors.size() >0){
                String strErrorMessage = GNE_Referral_Utils.setErrorMessage(lstFieldValidationErrors);
                System.debug('strErrorMessage : ' + strErrorMessage);
                throw new CreateReferralException(strErrorMessage); 
            }else{
                String strErrorMessage = '';
                System.debug('strErrorMessage : ' + strErrorMessage);
                callResponse.ErrorMessage = strErrorMessage;
                callResponse.setResponseReferral(newReferral);
                callResponse.setResponseReferralAssignment(newReferralAssignment);
                callResponse.EndTime = DateTime.now();
                System.debug('ResponseHere : ' + String.valueOf(callResponse));
            }       
            
        } finally {
            GNE_Referral_Utils.isMedicalReferral = false;
        }
        
        return callResponse;
    }
    

    public static Response upsertReferralOldWayCanada(ReferralInfo refInfo, Boolean logErrorMode){
        Response callResponse = new Response();
        SavePoint savePoint = Database.setSavePoint();
        
        try {
            callResponse = intUpsertReferralOldWayCanada(refInfo, callResponse);
        } catch(Exception e) {
            Database.rollback (savePoint);
            callResponse.ErrorMessage = e.getMessage();
            callResponse.setResponseReferral(new Medical_Communication_gne__c());
            callResponse.setResponseReferralAssignment(new Referral_Assignment_gne__c());
            
            if(logErrorMode) {
                iPhoneBase.handleException(e, UserInfo.getUserId(), (refInfo.isOtrRequest==true ? 'OTR' : null),
                        'Upsert Referral Old Way Canada', GNE_Med_iPhone_CreateReferral.ReferralInfo.class, refInfo.RequestId, refInfo, 
                        '[MedCommUpsertReferralOldWayCanada] Error while upserting Referral');
            }
        }
        
        callResponse.EndTime = DateTime.now();
        return callResponse;
    }
    
    public static Response intUpsertReferralOldWayCanada(ReferralInfo refInfo, Response callResponse) {
        Boolean isEditMode = false;

        Set<String> allowedStatusesForUpdate = new Set<String>{
            GNE_SFA2_ReferralUtil.REFERRAL_STATUS_ASSIGNED,
            GNE_SFA2_ReferralUtil.REFERRAL_STATUS_ACKNOWLEDGED_CANADA
        };
        
        List<Medical_Communication_gne__c> medCommRecordsDB = new List<Medical_Communication_gne__c>();
        Referral_Assignment_gne__c referralDB = new Referral_Assignment_gne__c();
        
        if (String.isNotBlank(refInfo.RecordId)){
            if (refInfo.IsOtrRequest){
                medCommRecordsDB = iPhone_DAO.getMedicalCommunicationById(refInfo.RecordId);
                if(!medCommRecordsDB.isEmpty()) {
                   referralDB = iPhone_DAO.getReferralAssignmentById(medCommRecordsDB.get(0).Referral_Assignment_gne__c);
                }
            } else {
                referralDB = iPhone_DAO.getReferralAssignmentById(refInfo.RecordId);
                medCommRecordsDB = iPhone_DAO.getMedicalCommunicationById(referralDB.Medical_Request_gne__c);
            }
        } else if (String.isNotBlank(refInfo.RequestId)){
            medCommRecordsDB = iPhone_DAO.getMedicalCommunicationByRequestId(refInfo.RequestId);
            if(!medCommRecordsDB.isEmpty()) {
                referralDB = iPhone_DAO.getReferralAssignmentById(medCommRecordsDB.get(0).Referral_Assignment_gne__c);
            }
        }

        if (!medCommRecordsDB.isEmpty() && referralDB != null){
            if (GNE_SFA2_Util.isCanadaOpsUser() || ((UserInfo.getUserId() == referralDB.Assigned_To_gne__c || GNE_SFA2_Util.isCanadaDirectorUser() || GNE_SFA2_Util.isCanadaRMLUser()) && allowedStatusesForUpdate.contains(referralDB.Status_Referral_gne__c))) {
                isEditMode = true;
            } else {
                callResponse.ErrorMessage = 'You do not have the level of access necessary to perform the operation you requested.';
                callResponse.setResponseReferral(medCommRecordsDB.get(0));
                callResponse.setResponseReferralAssignment(referralDB);
                callResponse.EndTime = DateTime.now();
                return callResponse;
            }
        }
        
        List<String> lstFieldValidationErrors = new List<string>(); 
        
        Medical_Communication_gne__c referral = new Medical_Communication_gne__c();
        Referral_Assignment_gne__c referralAssignment = new Referral_Assignment_gne__c();
        
        if (isEditMode) {
            referral = medCommRecordsDB.get(0);
            referralAssignment = referralDB;
        }
                
        String strAssignedUserName='';
        String strAssignedUserRole='';
        Map<String,Id> mapRefId = new Map<String,Id> ();
        User assignedUser = new User();
                        
        Boolean isAssigned = false;
        Boolean isReassigned = false;
        Boolean isStatusChanged = false;
        Boolean blnIsReferralAssignmentUpdated = false;
        GNE_Referral_Utils.isMedicalReferral = true;
        
        try{
            if (!isEditMode) {
                referral.RecordTypeId = GNE_Referral_Utils.getReferralRecordType().id;
                if (String.isBlank(refInfo.AccountId)) {
                    lstFieldValidationErrors.add('Account can not be blank.');
                } else {
                    referral.Account_gne__c = refInfo.AccountId;
                    referral.Account_Referral_gne__c = refInfo.AccountId;

                    if (String.isBlank(refInfo.AddressId)) {
                        lstFieldValidationErrors.add('Address cannot be blank.');
                    } else {
                        Address_vod__c objAddress = GNE_Referral_Utils.getAddressInfo(refInfo.AddressId, refInfo.AccountId);
                        if(objAddress == null){
                            lstFieldValidationErrors.add('Address not available.');
                        } else {
                            referral.Address_Line_1_gne__c=objAddress.Name;
                            referral.Address_Line_2_gne__c=objAddress.Address_line_2_vod__c;
                            referral.Address_Line_3_gne__c=objAddress.Address_Line_3_gne__c;
                            referral.Address_Line_4_gne__c=objAddress.Address_Line_4_gne__c;
                            referral.City_gne__c=objAddress.City_vod__c;
                            referral.Country_gne__c=objAddress.Country_gen__c;
                            
                            if (String.isNotBlank(objAddress.Province_can_gne__c)){
                            	referral.Province_can_gne__c = objAddress.Province_can_gne__c;
                            }
                            
                            if(String.isNotBlank(objAddress.State_vod__c)) {
                                referral.State_gne__c = objAddress.State_vod__c;
                            }
                            
                            if(String.isNotBlank(objAddress.Email_gne__c)) {
                                referral.Email_gne__c=objAddress.Email_gne__c;
                            }
                            
                            if(String.isNotBlank(objAddress.Phone_vod__c)) {
                                referral.Phone_gne__c=objAddress.Phone_vod__c;
                            }
                            
                            if(String.isNotBlank(refInfo.phone)) {
                                referral.Phone_gne__c=refInfo.phone;
                            }
                            
                            if (String.isNotBlank(objAddress.Account_vod__r.Cell_Phone_gne__c)){
                            	referral.Phone_1_gne__c=objAddress.Account_vod__r.Cell_Phone_gne__c;
                            } else if(String.isNotBlank(objAddress.Phone_2_vod__c)) {
                                referral.Phone_1_gne__c=objAddress.Phone_2_vod__c;
                            }
                            
                            if(String.isNotBlank(objAddress.Fax_vod__c)) {
                                referral.Fax_gne__c=objAddress.Fax_vod__c;
                            } else if(String.isNotBlank(objAddress.Fax_2_vod__c)){
                                referral.Fax_gne__c=objAddress.Fax_2_vod__c;
                            }
                            
                            if(String.isNotBlank(objAddress.Zip_vod__c)){                                
                                referral.Zip_gne__c=objAddress.Zip_vod__c.length() >=5 ? objAddress.Zip_vod__c.substring(0,5) : objAddress.Zip_vod__c;
                            }
                            if(String.isNotBlank(objAddress.Zip_4_vod__c)){
                                referral.Zip_4_gne__c=objAddress.Zip_4_vod__c;
                            }                       
                        }
                    }
                }
                if(String.isNotBlank(refInfo.Priority)){
                    referral.Priority_gne__c=refInfo.Priority;
                }else{
                    lstFieldValidationErrors.add('Priority can not be blank.');
                }
                if(String.isNotBlank(refInfo.MedicalQuestion)){
                    referral.Medical_Question_gne__c=refInfo.MedicalQuestion;
                }else{
                    lstFieldValidationErrors.add('Question/Request can not be blank.');
                }
                if(String.isNotBlank(refInfo.FollowupMethod)){
                    referral.Follow_up_Method_gne__c=refInfo.FollowupMethod;
                }else{
                    lstFieldValidationErrors.add('Follow-up Method can not be blank.');
                }
                if(String.isNotBlank(refInfo.ProductId)){
                    referral.Product_gne__c=refInfo.ProductId;
                }
                if(String.isNotBlank(refInfo.MoleculeId)){
                    referral.Molecule_gne__c=refInfo.MoleculeId;
                }
                if(refInfo.RequestedCompletionDate != null){
                    referral.Requested_Completion_Date_gne__c=refInfo.RequestedCompletionDate;
                }
                if (String.isNotBlank(refInfo.Language)){
                    referral.Language_of_Preference_can_gne__c = refInfo.Language;
                }
                if (String.isBlank(refInfo.RequestedById)){
                    refInfo.RequestedById = UserInfo.getUserId();
                }
                
                referral.Requested_By_gne__c=refInfo.RequestedById;
                referral.Is_MedComm_gne__c=refInfo.isMedComm;
                referral.Referral_Source_gne__c = GNE_Referral_Utils.getReferralSource(refInfo.RequestedById);
            }
            
            if(String.isNotBlank(refInfo.RequestId)){
                referral.iphone_request_id_gne__c=refInfo.RequestId;         
            }            
            if (String.isBlank(refInfo.AssignedToId)){
                lstFieldValidationErrors.add('Referral must be assigned to RCanada-SFA-MSL user.');
                isAssigned = false;
            } else {
                assignedUser = GNE_Referral_Utils.getCurrentUser(refInfo.AssignedToId);
                GNE_Referral_Utils.loadUserProfileType(assignedUser);
                if(assignedUser != null && GNE_Referral_Utils.isMSLCanada){
                    refInfo.AssignedToId = assignedUser.Id;
                    isAssigned = true;
                } else{
                    isAssigned = false;
                    lstFieldValidationErrors.add('Referral can not be assigned to non-RCanada-MSL user, please asign to RCanada-SFA-MSL user.');
                }
            }

            isReassigned = isEditMode && isAssigned && referralAssignment.Assigned_To_gne__c != refInfo.AssignedToId;
	        
            if (isEditMode) {
                isStatusChanged = referralAssignment.Status_Referral_gne__c != refInfo.Status; 
	        }	
            if(isReassigned && isStatusChanged && !GNE_SFA2_Util.isCanadaOpsUser()){
                isAssigned = false;
                lstFieldValidationErrors.add('Status cannot be changed during referral reassignment.');
            }
            
            if(isAssigned){
            	String refStatus = (!isEditMode || (isEditMode && !GNE_SFA2_Util.isCanadaOpsUser() && isReassigned)) ? GNE_Referral_Utils.strAssigned : refInfo.Status;
                String dateTimeText = datetime.now().format(GNE_Referral_Utils.strPSTFormat,GNE_Referral_Utils.strPST);
                if (!isEditMode || isReassigned || isStatusChanged){
                    String strAssignedUserNameRole = GNE_Referral_Utils.getUserNameAndRole((String)refInfo.AssignedToId);
                    String[] lstUserNameAndRole = strAssignedUserNameRole.split(',', 2);
                    if(lstUserNameAndRole.size() > 0){
                        strAssignedUserName =lstUserNameAndRole[0];
                        strAssignedUserRole =lstUserNameAndRole[1];
                    }
                    //referral.Referral_History_gne__c=datetime.now().format() + ',' + GNE_Referral_Utils.strCreated + ',' + UserInfo.getName() + ',' + strAssignedUserName + ',' + (String)refInfo.AssignedToId + ',' + strAssignedUserRole + ',' + GNE_Referral_Utils.strAssigned + ';';
                    
                    referral.Referral_History_gne__c = !isEditMode 
                        ? GNE_Referral_Utils.createHistoryInfo(
                            dateTimeText, 
                            GNE_Referral_Utils.strAssigned,
                            strAssignedUserName,
                            refInfo.AssignedToId, 
                            strAssignedUserRole,
                            refStatus)
                        : GNE_Referral_Utils.createHistoryInfo(
                            dateTimeText, 
                            (isReassigned ? GNE_Referral_Utils.strReassigned : refInfo.Status),
                            strAssignedUserName,
                            refInfo.AssignedToId, 
                            strAssignedUserRole,
                            refStatus) + 
                            referral.Referral_History_gne__c;
                }

                if (String.isNotBlank(refInfo.Comment)) {
                    String prevStrComment = referral.Comments_Referral_gne__c;
                    referral.Comments_Referral_gne__c = GNE_Referral_Utils.createCommentsInfo(dateTimeText, refInfo.Comment, prevStrComment);
                }
                
                upsert referral;
                mapRefId.put(GNE_Referral_Utils.strObjectName,referral.Id);
                
                referralAssignment.Medical_Request_gne__c = referral.Id;
                referralAssignment.Assigned_To_gne__c = refInfo.AssignedToId;
                referralAssignment.Referral_Assigned_User_Email_gne__c = assignedUser.email;
                referralAssignment.Assigned_To_Manager_gne__c = assignedUser.ManagerId;
                referralAssignment.Referral_Assigned_Manager_Email_gne__c = assignedUser.Manager != null ? assignedUser.Manager.Email : null;
                if (isEditMode) {
                    referralAssignment.Revised_Requested_Completion_Date_gne__c = refInfo.RevisedCompletionDate;
                }
                referralAssignment.Status_Referral_gne__c = refStatus;

                if (!isEditMode || isStatusChanged){
                    referralAssignment.Status_Referral_Date_gne__c = datetime.now();
                }

                if (!isEditMode || ((isReassigned || isStatusChanged) && referralAssignment.Status_Referral_gne__c == GNE_Referral_Utils.strAssigned)){
                    referralAssignment.Due_Date_gne__c = GNE_Referral_Utils.getDueDate(datetime.now(),(String)referral.Priority_gne__c + '_Canada');
                    referralAssignment.Escalation_Status_gne__c = false;
                }
                                
                upsert referralAssignment;
                mapRefId.put(GNE_Referral_Utils.strRefObjectName,referralAssignment.Id);
                                
                referral.Referral_Assignment_gne__c = referralAssignment.Id;
                update referral;

                if ((!isEditMode || (isReassigned && referralAssignment.Status_Referral_gne__c == GNE_Referral_Utils.strAssigned)) && GNE_Referral_Utils.sendReferralEmail(referralAssignment,referral,GNE_Referral_Utils.strAssigned)){
                    referralAssignment.Status_Email_gne__c = GNE_Referral_Utils.strStatusAssignedEmail;
                    referralAssignment.Status_Email_Date_gne__c = datetime.now();
                    blnIsReferralAssignmentUpdated = true;
                } else if (isStatusChanged && GNE_Referral_Utils.sendReferralEmail(referralAssignment,referral,referralAssignment.Status_Referral_gne__c)){
                    referralAssignment.Status_Email_gne__c = GNE_Referral_Utils.getStatusEmail(referralAssignment.Status_Referral_gne__c);
                    referralAssignment.Status_Email_Date_gne__c = datetime.now();
                    blnIsReferralAssignmentUpdated = true;
                }

                if(blnIsReferralAssignmentUpdated){
                    update referralAssignment;
                }                
            }
            
            if (lstFieldValidationErrors.size() > 0){
                String strErrorMessage = GNE_Referral_Utils.setErrorMessage(lstFieldValidationErrors);
                throw new CreateReferralException(strErrorMessage); 
            }else{
                String strErrorMessage = '';
                callResponse.ErrorMessage = strErrorMessage;
                callResponse.setResponseReferral(referral);
                callResponse.setResponseReferralAssignment(referralAssignment);
                callResponse.EndTime = DateTime.now();
            }
        } finally {
            GNE_Referral_Utils.isMedicalReferral = false;
        }
        
        return callResponse;
    }

    public class CreateReferralException extends Exception {}
    
    TestMethod static void testReferralCreate() {
        ReferralInfo info = new ReferralInfo();
        Response callResponse = GNE_Med_iPhone_CreateReferral.createReferral(info);
        System.assert(callResponse.newReferral != null);
    }
}