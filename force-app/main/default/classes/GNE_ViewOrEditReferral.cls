public without sharing class GNE_ViewOrEditReferral 
{
  
  /* 
    This class is used to edit and view Referral.
    Referral is a Medical Communication request to an MSL. The Referral is identified as a Medical communication
  request with a recordType Referral.
  
    Author : Sweta Khalasi
    Created : 01 Jul 2011
    Last Modified : 24 Aug 2011
    Project : gMARS Phase 2
  
  */
  
  List<Schema.SObjectField> fTokens = new List<Schema.SObjectField>();
  Schema.SObjectType schemaSObject=null;
  Map<String, Schema.SObjectField> fMap = new Map<String, Schema.SObjectField>();
  List<string> lstStatus = new List<string> ();
  
  Medical_Communication_gne__c objReferralProxy;
  Referral_Assignment_gne__c objReferralAssignmentProxy;
  
  public Medical_Communication_gne__c getReferralProxyObject()
  {
    return objReferralProxy;
  }
  public Referral_Assignment_gne__c getReferralAssignmentProxyObject()
  {
    return objReferralAssignmentProxy;
  }
  public String selectedStatus{get; set;} 
  
  public List<SelectOption> getStatusList() 
    {               
        List<SelectOption> options=new List<SelectOption>();
            
        System.debug('lstStatus: --> ' + lstStatus);      
        if(lstStatus!=null && lstStatus.size()>0)
        {
          for(string strStatus: lstStatus)
          {
            if(strStatus != null)
                options.add(new SelectOption(strStatus, strStatus));    
          }
        }
        
        return options;
    }
    public String Comments{get; set;}
  public void loadStatusList(String strCurrentStatus)
  {
    System.debug('inside loadStatusList: --> ' + strCurrentStatus + ' : ' + GNE_Referral_Utils.strRefObjectName);
    schemaSObject = Schema.getGlobalDescribe().get(GNE_Referral_Utils.strRefObjectName);
    fMap = schemaSObject.getDescribe().fields.getMap() ;
    fTokens = fMap.values();
    //System.debug('Object Name: --> ' + GNE_Referral_Utils.strRefObjectName + ' No. Of fields in this object: --> ' + fTokens.size());
    Schema.DescribeFieldResult f=null;
    PicklistEntry[] picklistValues =null;
    
    for( Integer i = 0 ; i < fTokens.size() ; i++ ){
        f = fTokens.get(i).getDescribe();
        //System.debug('f.getType(): ' + f.getType());
        if(f.getName() == GNE_Referral_Utils.strStatusField && f.getType() == Schema.DisplayType.Picklist){
            picklistValues = f.getPicklistValues();
            //System.debug('picklistValues: --> ' + picklistValues);
            lstStatus = new string[picklistValues.size()];
            for( Integer j = 0 ; j < picklistValues.size() ; j++ ){
                if(picklistValues[j].isActive()){
                    //System.debug('picklistValues[j].getLabel(): --> ' + picklistValues[j].getLabel());
                    if(strCurrentStatus == GNE_Referral_Utils.strAssigned){
                        if(picklistValues[j].getLabel() == GNE_Referral_Utils.strAssigned)
                            {lstStatus.add(0,picklistValues[j].getLabel());}
                        if(picklistValues[j].getLabel() == GNE_Referral_Utils.strAcknowledged)
                            {lstStatus.add(1,picklistValues[j].getLabel());}
                    }else if(strCurrentStatus == GNE_Referral_Utils.strAcknowledged){
                        if(picklistValues[j].getLabel() != GNE_Referral_Utils.strAssigned)
                            {
                                if(picklistValues[j].getLabel() == GNE_Referral_Utils.strAcknowledged)
                                    {lstStatus.add(0,picklistValues[j].getLabel());}
                                else
                                    lstStatus.add(picklistValues[j].getLabel());
                            }
                    }else
                    {
                        lstStatus.add(picklistValues[j].getLabel());
                    }
                                
                }
            }
        }
        f = null;
        schemaSObject = null;
    }
    //System.debug('lstStatus: --> ' + lstStatus);
  }
  
  
  //String MCLProfile = 'GNE-MedAffairs-MCL';
  //String MSLProfile = 'GNE-MedAffairs-MSL';
  
  Boolean isEditable = false;
  Boolean isClosed = false;
  Boolean isAssigned = false;
  String strReferralName = '';
  String strMedCommName = '';
  
  User currentUser = new User();
    
  public String errMessage{get; set;}
  Referral_Assignment_gne__c referralAssignment = null;
  Referral_Assignment_gne__c referralAssignmentCopy = null;
  Medical_Communication_gne__c objReferral = null;
  String SearchFldCopy = '';
  Id SearchIdCopy = null;
  private final ApexPages.StandardController stdController =null;
  
  public boolean getIsMedAffairProfileUser()
    {
        System.debug('Inside getIsMedAffairProfileUser: --> ');
        if(currentUser !=null && currentUser.Profile_Name_gne__c !=null && currentUser.Profile_Name_gne__c !='' &&(currentUser.Profile_Name_gne__c.contains(GNE_Referral_Utils.MedAffairProfile) || currentUser.Profile_Name_gne__c.contains(GNE_Referral_Utils.SysAdminProfile)) && (!currentUser.Profile_Name_gne__c.contains(GNE_Referral_Utils.TISLProfile)))
        {
            return true;
        }
        else{
            return false;
        }
        
    }
  public String SearchFld { get; set; }
  public Id SearchId { get; set; }
  public GNE_ViewOrEditReferral (ApexPages.StandardController stdController) {
    
        this.stdController = stdController;    
        //System.debug (ApexPages.currentPage() + ' page constructor.');
        
        //instantiate proxy object
        objReferralProxy = new Medical_Communication_gne__c();
        objReferralAssignmentProxy = new Referral_Assignment_gne__c();
        
        
        Referral_Assignment_gne__c refAssignment = (Referral_Assignment_gne__c)  stdController.getRecord();
        referralAssignment = [Select Account_gne__c, AccountId_gne__c, Assigned_To_gne__c, Assigned_To_gne__r.Id, Assigned_To_gne__r.Name, Assigned_To_Manager_gne__c, Referral_Assigned_Manager_Email_gne__c, Referral_Assigned_User_Email_gne__c, CreatedById, CreatedDate, Follow_up_Method_gne__c, Id,Revised_Requested_Completion_Date_gne__c,Referral_Link_gne__c, Medical_Request_gne__c, Medical_Request_gne__r.Account_gne__c, Medical_Request_gne__r.Account_Medcom_gne__c, Medical_Request_gne__r.Account_Referral_gne__c, Medical_Request_gne__r.Address_Line_1_gne__c, Medical_Request_gne__r.Assigned_To_gne__c, Medical_Request_gne__r.Assigned_To_Id_gne__c, Medical_Request_gne__r.Comments_Referral_gne__c, Medical_Request_gne__r.CreatedById, Medical_Request_gne__r.CreatedDate, Medical_Request_gne__r.Email_gne__c, Medical_Request_gne__r.Fax_gne__c, Medical_Request_gne__r.Follow_up_Method_gne__c, Medical_Request_gne__r.Id, Medical_Request_gne__r.Medical_Question_gne__c,Medical_Request_gne__r.Molecule_Name_gne__c,Medical_Request_gne__r.Product_Name_gne__c,Medical_Request_gne__r.TA_SubTA_Name_gne__c, Medical_Request_gne__r.Molecule_gne__c, Medical_Request_gne__r.Name, Medical_Request_gne__r.OwnerId, Medical_Request_gne__r.Phone_gne__c,Medical_Request_gne__r.Phone_1_gne__c, Medical_Request_gne__r.Priority_gne__c, Medical_Request_gne__r.Product_gne__c, Medical_Request_gne__r.RecordTypeId, Medical_Request_gne__r.Referral_Assignment_gne__c, Medical_Request_gne__r.Referral_History_gne__c,         
        Medical_Request_gne__r.Requested_By_gne__c,Medical_Request_gne__r.Referral_Source_gne__c,Medical_Request_gne__r.Is_MedComm_gne__c, Medical_Request_gne__r.Requested_Completion_Date_gne__c, 
        Medical_Request_gne__r.Status_Referral_Date_gne__c, Medical_Request_gne__r.Status_Referral_Email_Date_gne__c, Medical_Request_gne__r.Status_Referral_Email_gne__c, Medical_Request_gne__r.Status_Referral_gne__c, Medical_Request_gne__r.TA_SubTA_gne__c, Medical_Request_gne__r.Unsolicited_Request_Verified_By_gne__c,Medical_Request_gne__r.Unsolicited_Request_Verified_gne__c, Medical_Request_gne__r.Unsolicited_Request_Verified_Date_gne__c, Molecule_gne__c, Name, OwnerId, Priority_gne__c, Product_gne__c, Status_Email_Date_gne__c, Status_Email_gne__c, Status_Referral_Date_gne__c,Escalation_Status_gne__c,Due_Date_gne__c, Status_Referral_gne__c, TA_SubTA_gne__c from Referral_Assignment_gne__c where Id =: refAssignment.Id];
        
        if(referralAssignment!=null){
            strReferralName = referralAssignment.Name;
            objReferralAssignmentProxy.Assigned_To_gne__c = referralAssignment.Assigned_To_gne__c;
            SearchFld = referralAssignment.Assigned_To_gne__r.Name;
            SearchId = referralAssignment.Assigned_To_gne__r.Id;
            
            referralAssignmentCopy = new Referral_Assignment_gne__c(Assigned_To_gne__c = referralAssignment.Assigned_To_gne__c, Medical_Request_gne__c=referralAssignment.Medical_Request_gne__c,Status_Referral_gne__c=referralAssignment.Status_Referral_gne__c,OwnerId=referralAssignment.OwnerId,Revised_Requested_Completion_Date_gne__c=referralAssignment.Revised_Requested_Completion_Date_gne__c );
            SearchFldCopy = referralAssignment.Assigned_To_gne__r.Name;
            SearchIdCopy = referralAssignment.Assigned_To_gne__c;
            if(referralAssignment.Medical_Request_gne__c!=null){
                objReferral = [Select Account_gne__c, Account_Medcom_gne__c, Account_Referral_gne__c, Address_Line_1_gne__c, Assigned_To_gne__c, Assigned_To_Id_gne__c, Comments_Referral_gne__c, CreatedById, CreatedDate, Email_gne__c, Fax_gne__c, Follow_up_Method_gne__c, Id, Medical_Question_gne__c, Molecule_Name_gne__c,Product_Name_gne__c,TA_SubTA_Name_gne__c,Molecule_gne__c, Name, OwnerId, Phone_gne__c,Phone_1_gne__c, Priority_gne__c, Product_gne__c, RecordTypeId, Referral_Assignment_gne__c, Referral_Assignment_gne__r.Account_gne__c, Referral_Assignment_gne__r.AccountId_gne__c, Referral_Assignment_gne__r.Assigned_To_gne__c,Referral_Assignment_gne__r.Assigned_To_Manager_gne__c, Referral_Assignment_gne__r.Referral_Assigned_Manager_Email_gne__c, Referral_Assignment_gne__r.Referral_Assigned_User_Email_gne__c, Referral_Assignment_gne__r.CreatedById, Referral_Assignment_gne__r.CreatedDate, Referral_Assignment_gne__r.Follow_up_Method_gne__c, Referral_Assignment_gne__r.Id, Referral_Assignment_gne__r.Medical_Request_gne__c, Referral_Assignment_gne__r.Molecule_gne__c, Referral_Assignment_gne__r.Name, Referral_Assignment_gne__r.OwnerId, Referral_Assignment_gne__r.Priority_gne__c, Referral_Assignment_gne__r.Product_gne__c, Referral_Assignment_gne__r.Status_Email_Date_gne__c, Referral_Assignment_gne__r.Status_Email_gne__c, Referral_Assignment_gne__r.Status_Referral_Date_gne__c,Referral_Assignment_gne__r.Due_Date_gne__c, Referral_Assignment_gne__r.Status_Referral_gne__c, Referral_Assignment_gne__r.TA_SubTA_gne__c, Referral_History_gne__c,             
                Requested_Completion_Date_gne__c, Requested_By_gne__c,Referral_Source_gne__c,Is_MedComm_gne__c, Status_Referral_Date_gne__c, Status_Referral_Email_Date_gne__c, Status_Referral_Email_gne__c, Status_Referral_gne__c, TA_SubTA_gne__c, Unsolicited_Request_Verified_By_gne__c,Unsolicited_Request_Verified_gne__c, Unsolicited_Request_Verified_Date_gne__c from Medical_Communication_gne__c where id = :referralAssignment.Medical_Request_gne__c];
                strMedCommName = objReferral.Name;
                
                objReferralProxy.Unsolicited_Request_Verified_gne__c = objReferral.Unsolicited_Request_Verified_gne__c;
                if((String)objReferral.Unsolicited_Request_Verified_By_gne__c != null)
                    objReferralProxy.Unsolicited_Request_Verified_By_gne__c = objReferral.Unsolicited_Request_Verified_By_gne__c;
                if(String.valueOf(objReferral.Unsolicited_Request_Verified_Date_gne__c) != null)
                    objReferralProxy.Unsolicited_Request_Verified_Date_gne__c = objReferral.Unsolicited_Request_Verified_Date_gne__c;
                
            }
            errMessage='hello';
            
            currentUser=GNE_Referral_Utils.getCurrentUser(UserInfo.getUserId());
            //If status is Assigned, than do not allow user to alow edit any thing untill acknowledge
            isAssigned = isReferralAssigned();
            //Once verified by an MSL, the unsolicited request verified by field cannot be updated.
            isEditable = isUnsolicitedIsEditable();
            
            
            //To display Referral history
            loadRefHistory();
            //To display Referral Comments
            loadRefComments();
            loadStatusList(referralAssignment.Status_Referral_gne__c);
            
        }
    }
  public PageReference edit() {
  
    PageReference p = null;
    //A Closed or Fulfilled referral cannot be edited.
    if(!isClosed){  
        try{
            p=Page.GNE_EditReferralPage;
            p.setRedirect(true);
            p.getParameters().put('id',referralAssignment.Id);
        }
        catch (Exception e) {
            //p = Page.failure;
            System.debug('Error on the page:' + e);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error on the page:' + e));
            return null;
        }
    }
    else{
        System.debug('A Closed or Fulfilled referral cannot be edited.');
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'A Closed or Fulfilled referral cannot be edited.'));        
        return null;
        }
    return p;
    
  }
    public Boolean getIsClosed()
  {
    return isClosed;
  }
    
  public GNE_ViewOrEditReferral()
  {
    
  }
  
  public Boolean isReferralAssigned()
  {
    
    System.debug('inside isReferralAssigned:');    
    //System.debug('(String)referralAssignment.Status_Referral_gne__c:' + (String)referralAssignment.Status_Referral_gne__c);
    if(currentUser.Profile_Name_gne__c.contains(GNE_Referral_Utils.SysAdminProfile)){
        isClosed = false;
    }
    else if((String)referralAssignment.Status_Referral_gne__c 
    !=GNE_Referral_Utils.strAcknowledged && (String)referralAssignment.Status_Referral_gne__c != GNE_Referral_Utils.strAssigned){
        isClosed = true;
    }
    else{
        if(currentUser.Profile_Name_gne__c.contains(GNE_Referral_Utils.MSLManagerProfile)){
            isClosed = false;
        }
        else if(referralAssignment.OwnerId != UserInfo.getUserId())
            isClosed = true;
        else
            isClosed = false;
    }
    
    if((String)referralAssignment.Status_Referral_gne__c == GNE_Referral_Utils.strAssigned){
        //System.debug('inside if loop:');
        return true;
    }
    else{
        //System.debug('inside else loop:');
        return false;
    }
  }
  public Boolean getisAssigned()
  {
    return isAssigned;
  }
  public Boolean getIsEditable()
  {
    return isEditable;
  }
  public String getReferralName()
  {
    return strReferralName;
  }
  public String getMedCommName()
  {
    return strMedCommName;
  }
  
  public Boolean isUnsolicitedIsEditable()
  {
    
    System.debug('inside getUnsolicitedIsEditable:');
    if(objReferral != null){
        //once Unsolicited_Request_Verified_gne__c is true than it can not be edited again
        //System.debug('objReferral.Unsolicited_Request_Verified_gne__c:' + objReferral.Unsolicited_Request_Verified_gne__c);
        //System.debug('(String)objReferral.Unsolicited_Request_Verified_By_gne__c:' + (String)objReferral.Unsolicited_Request_Verified_By_gne__c);
        //System.debug('String.valueOf(objReferral.Unsolicited_Request_Verified_Date_gne__c):' + String.valueOf(objReferral.Unsolicited_Request_Verified_Date_gne__c));
        if(objReferral.Unsolicited_Request_Verified_gne__c && (String)objReferral.Unsolicited_Request_Verified_By_gne__c != null && String.valueOf(objReferral.Unsolicited_Request_Verified_Date_gne__c) != null){
            //System.debug('inside if loop:');
            return false;
        }
        else{
            //System.debug('inside else loop:');
            if(!isAssigned){
                    objReferralProxy.Unsolicited_Request_Verified_By_gne__c = UserInfo.getUserId();
                    objReferralProxy.Unsolicited_Request_Verified_Date_gne__c = Date.today();
                    return true;
            }
            else
                return false;
        }
    }else
    {
        return false;
    }
  }
  
  public Boolean isStatusAndAssignedToChanged()
  {
  
    System.debug('Inside isStatusAndAssignedToChanged:');
    //System.debug('selectedStatus:' + selectedStatus);
    //System.debug('(String)referralAssignmentCopy.Status_Referral_gne__c:' + (String)referralAssignmentCopy.Status_Referral_gne__c);
    //System.debug('SearchId:' + SearchId);
    //System.debug('(String)referralAssignmentCopy.Assigned_To_gne__c:' + (String)referralAssignmentCopy.Assigned_To_gne__c);
            
    
    if(selectedStatus != null && selectedStatus != (String)referralAssignmentCopy.Status_Referral_gne__c){    
        //if((String)objReferralAssignmentProxy.Assigned_To_gne__c != null && (String)objReferralAssignmentProxy.Assigned_To_gne__c!= (String)referralAssignmentCopy.Assigned_To_gne__c){
        if((String)SearchId != null && (String)SearchId!= (String)referralAssignmentCopy.Assigned_To_gne__c){
            return true;
        }else{
            return false;
        }   
    }
    else{
        return false;
    }
  }
  
  public Boolean isVerified()
  {
    System.debug('inside isVerified:');
    if(!isEditable)
        return true;
    if(objReferral != null){
        
        //Referral can not be fullfill unless it gets verified.
        //if(((String)referralAssignment.Status_Referral_gne__c !=GNE_Referral_Utils.strAcknowledged && (String)referralAssignment.Status_Referral_gne__c != GNE_Referral_Utils.strAssigned && (String)referralAssignment.Status_Referral_gne__c !=GNE_Referral_Utils.strClosedHCPUnresponsive && (String)referralAssignment.Status_Referral_gne__c != GNE_Referral_Utils.strClosedNotVerifiable) && (String)objReferral.Unsolicited_Request_Verified_By_gne__c == null && String.valueOf(objReferral.Unsolicited_Request_Verified_Date_gne__c) == null && (!objReferral.Unsolicited_Request_Verified_gne__c)){
        if(selectedStatus != null && (selectedStatus !=GNE_Referral_Utils.strAcknowledged && selectedStatus != GNE_Referral_Utils.strAssigned && selectedStatus !=GNE_Referral_Utils.strClosedHCPUnresponsive && selectedStatus != GNE_Referral_Utils.strClosedNotVerifiable) && (String)objReferralProxy.Unsolicited_Request_Verified_By_gne__c == null && String.valueOf(objReferralProxy.Unsolicited_Request_Verified_Date_gne__c) == null && (!objReferralProxy.Unsolicited_Request_Verified_gne__c)){
            return false;
        }
        else{
            return true;
        }
    }
    else{
        return true;
    }
  }
  
  public Medical_Communication_gne__c getReferral()
  {
    return objReferral;
  }
  
  public Referral_Assignment_gne__c getReferralAssignment()
  {
    return referralAssignment;
  }
  public Referral_Assignment_gne__c getNewReferralAssignment(Id objNewRefAssId)
  {
    System.debug('Inside getNewReferralAssignment:');
    //System.debug('objNewRefAssId: ' + objNewRefAssId);
    Referral_Assignment_gne__c objNewReferralAssignment = new Referral_Assignment_gne__c();
    try{
        objNewReferralAssignment = [Select Account_gne__c, AccountId_gne__c, Assigned_To_gne__c, Assigned_To_gne__r.Id, Assigned_To_gne__r.Name,Assigned_To_Manager_gne__c, Referral_Assigned_Manager_Email_gne__c, Referral_Assigned_User_Email_gne__c, CreatedById, CreatedDate, Follow_up_Method_gne__c, Id,Referral_Link_gne__c,Revised_Requested_Completion_Date_gne__c, Medical_Request_gne__c, Medical_Request_gne__r.Account_gne__c, Medical_Request_gne__r.Account_Medcom_gne__c, Medical_Request_gne__r.Account_Referral_gne__c, Medical_Request_gne__r.Address_Line_1_gne__c, Medical_Request_gne__r.Assigned_To_gne__c, Medical_Request_gne__r.Assigned_To_Id_gne__c, Medical_Request_gne__r.Comments_Referral_gne__c, Medical_Request_gne__r.CreatedById, Medical_Request_gne__r.CreatedDate, Medical_Request_gne__r.Email_gne__c, Medical_Request_gne__r.Fax_gne__c, Medical_Request_gne__r.Follow_up_Method_gne__c, Medical_Request_gne__r.Id, Medical_Request_gne__r.Medical_Question_gne__c, Medical_Request_gne__r.Molecule_Name_gne__c,Medical_Request_gne__r.Product_Name_gne__c,Medical_Request_gne__r.TA_SubTA_Name_gne__c,Medical_Request_gne__r.Molecule_gne__c, Medical_Request_gne__r.Name, Medical_Request_gne__r.OwnerId, Medical_Request_gne__r.Phone_gne__c,Medical_Request_gne__r.Phone_1_gne__c, Medical_Request_gne__r.Priority_gne__c, Medical_Request_gne__r.Product_gne__c, Medical_Request_gne__r.RecordTypeId, Medical_Request_gne__r.Referral_Assignment_gne__c, Medical_Request_gne__r.Referral_History_gne__c,             
            Medical_Request_gne__r.Requested_By_gne__c,Medical_Request_gne__r.Referral_Source_gne__c,Medical_Request_gne__r.Is_MedComm_gne__c,Medical_Request_gne__r.Requested_Completion_Date_gne__c, 
            Medical_Request_gne__r.Status_Referral_Date_gne__c, Medical_Request_gne__r.Status_Referral_Email_Date_gne__c, Medical_Request_gne__r.Status_Referral_Email_gne__c, Medical_Request_gne__r.Status_Referral_gne__c, Medical_Request_gne__r.TA_SubTA_gne__c, Medical_Request_gne__r.Unsolicited_Request_Verified_By_gne__c,Medical_Request_gne__r.Unsolicited_Request_Verified_gne__c, Medical_Request_gne__r.Unsolicited_Request_Verified_Date_gne__c, Molecule_gne__c, Name, OwnerId, Priority_gne__c, Product_gne__c, Status_Email_Date_gne__c, Status_Email_gne__c, Status_Referral_Date_gne__c,Escalation_Status_gne__c,Due_Date_gne__c, Status_Referral_gne__c, TA_SubTA_gne__c from Referral_Assignment_gne__c where Id =: objNewRefAssId];
    }
    catch (Exception e) {
        //System.debug('Error in getNewReferralAssignment:' + e);
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error on the page:' + e));
        return null;
    }
    //System.debug('objNewReferralAssignment: ' + objNewReferralAssignment);
    return objNewReferralAssignment;
  }
  
  
  public PageReference cancel() {
        PageReference p = null;     
        
        p=Page.GNE_MyReferralsPage;
        p.setRedirect(true);
        //p.getParameters().put('RefId',newReferral.id);
        
        //forward to referral view
        //p = new PageReference('/'+ referralAssignment.Id);
        return p;
    }
  public PageReference save() {
    
    PageReference p = null;
    Boolean blnIsReferralUpdated = false;
    Boolean blnIsReferralAssignmentUpdated = false;
    Boolean blnIsReassigned = false;
    Boolean blnIsStatusChanged = false;
    String refHistory=(String)objReferral.Referral_History_gne__c;
    String strDate = 'Date = ';
    String strAction = 'Action = ';
    String strActionBy = 'Action By = ';
    String strAssignedTo = 'Assigned To = ';
    String strEnd = ';';
    String strComma = ', ';
    String refStatus='';
    //Referral_Assignment_gne__c newReferralAssignment =null;
    Referral_Assignment_gne__c newObjReferralAssignment =null;
    
    String strAssignedUserName='';
    String strAssignedUserRole='';
    String strAssignedUserNameRole='';      
    String[] lstUserNameAndRole = new List<String> ();
    DateTime dueDate = datetime.now();
    List<User> lstUserIds = new List<User> ();
    String strComment = '';
    //String strCommentActionBy = 'Created By: ' + UserInfo.getName() + ' (' + datetime.now().format() + ')' + ',@,';
    String strCommentActionBy = 'Created By: ' + UserInfo.getName() + ' (' + datetime.now().format(GNE_Referral_Utils.strPSTFormat,GNE_Referral_Utils.strPST) + ')' + ',@,';
    //System.debug('strCommentActionBy:' + strCommentActionBy);  
    GNE_Referral_Utils.isMedicalReferral = true;    
    if((String)objReferral.Comments_Referral_gne__c != null)
        strComment = (String)objReferral.Comments_Referral_gne__c;
    //System.debug('strComment:' + strComment);
    Savepoint sp1=null;
    Boolean isEmailSent = false;
    Boolean isRequestVerified = false;
    String strHistory = (String)objReferral.Referral_History_gne__c;
    Id MSLQueueId = null;
    User assignedUser = new User();
    Boolean isReAssigned = false;
    User assignedUserManager = new User();
    User finalAssignedUser = new User();
    Map<String,User> mapUserId = new Map<String,User> ();
    List<string> lstAssignmentErrors = new List<string> ();
    
    if(lstAssignmentErrors != null && lstAssignmentErrors.size() >0 )
        lstAssignmentErrors.clear();
    //System.debug('referralAssignment.Revised_Requested_Completion_Date_gne__c: ' + referralAssignment.Revised_Requested_Completion_Date_gne__c);
    //System.debug('SearchFld: ' + SearchFld);
    //System.debug('SearchId: ' + SearchId);
    //System.debug('SearchFldCopy: ' + SearchFldCopy);
    //System.debug('SearchIdCopy: ' + SearchIdCopy);
    
    if(SearchFld == ''){
        //System.debug('Please enter the value for Assigned To field.');
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter the value for Assigned To field.'));
        GNE_Referral_Utils.isMedicalReferral = false;
        return null;
    }
    //if ((String)SearchFld != null && SearchFld !='' && SearchFld != SearchFldCopy){
    if ((String)SearchFld != null && SearchFld !='' && (SearchFld != SearchFldCopy || SearchId != SearchIdCopy)){
        lstUserIds = GNE_Referral_Utils.getAssignedUser(SearchFld,'Edit');
        //System.debug('lstUserIds: ' + lstUserIds);
        if (lstUserIds != null && lstUserIds.size() >0)
        {
            if(lstUserIds.size() ==1){
                SearchId = lstUserIds[0].Id;
                SearchFld = lstUserIds[0].Name;
            }else
            {
                System.debug('Multiple User found. Click Lookup icon at Assigned To Field to refine the search.:');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Multiple User found. Click Lookup icon at Assigned To Field to refine the search.'));
                GNE_Referral_Utils.isMedicalReferral = false;
                return null;
            }
        }else
        {
            System.debug('No User found. Click Lookup icon at Assigned To Field to select appropriate user.:');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No User found. Click Lookup icon at Assigned To Field to select appropriate user.'));
            GNE_Referral_Utils.isMedicalReferral = false;
            return null;
        }       
    }
    
    //Revised Completion Date Should be greater than today.
    if(referralAssignment.Revised_Requested_Completion_Date_gne__c != null && referralAssignment.Revised_Requested_Completion_Date_gne__c != referralAssignmentCopy.Revised_Requested_Completion_Date_gne__c && referralAssignment.Revised_Requested_Completion_Date_gne__c < Date.today()){
        System.debug('Revised Completion Date Should be greater than today.');
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Revised Completion Date Should be greater than today.'));
        GNE_Referral_Utils.isMedicalReferral = false;
        return null;
    }
    else{
        //A Closed or Fulfilled referral cannot be edited.
        if(!isClosed){
            try{
                //get Referral due date
                dueDate = GNE_Referral_Utils.getDueDate(datetime.now(),(String)objReferral.Priority_gne__c);
                //System.debug('datetime.now(): ' + datetime.now());
                //System.debug('dueDate: ' + dueDate);
                //System.debug('dueDate PST Time --->:' + dueDate.format(GNE_Referral_Utils.strGMTFormat,GNE_Referral_Utils.strPST));
                //System.debug('(String)referralAssignmentCopy.Assigned_To_gne__c:' + (String)referralAssignmentCopy.Assigned_To_gne__c);
                //Get user name and role for assigned user
                strAssignedUserNameRole = GNE_Referral_Utils.getUserNameAndRole((String)referralAssignmentCopy.Assigned_To_gne__c);
                if(lstUserNameAndRole.size() >0)
                    lstUserNameAndRole.clear();
                if(strAssignedUserNameRole != ''){
                    lstUserNameAndRole = strAssignedUserNameRole.split(',',2);
                    //System.debug('lstUserNameAndRole: ' + lstUserNameAndRole);
                    if(lstUserNameAndRole.size() >0){
                        strAssignedUserName =lstUserNameAndRole[0];
                        strAssignedUserRole =lstUserNameAndRole[1];                     
                    }
                }
                sp1 = Database.setSavepoint();
                //Once verified , the unsolicited request verified by field cannot be updated.
                if(isEditable){
                    if(objReferralProxy.Unsolicited_Request_Verified_gne__c){
                        isRequestVerified = true;
                        objReferral.Unsolicited_Request_Verified_gne__c = objReferralProxy.Unsolicited_Request_Verified_gne__c;
                        objReferral.Unsolicited_Request_Verified_By_gne__c = UserInfo.getUserId();
                        objReferral.Unsolicited_Request_Verified_Date_gne__c = Date.today();
                        blnIsReferralUpdated=true;                  
                        refHistory = refHistory + datetime.now().format(GNE_Referral_Utils.strPSTFormat,GNE_Referral_Utils.strPST) + strComma + GNE_Referral_Utils.strRequestVerified +  strComma + UserInfo.getName() + strComma + strAssignedUserName + strComma + (String)referralAssignmentCopy.Assigned_To_gne__c + strComma + strAssignedUserRole + strComma + (String)referralAssignmentCopy.Status_Referral_gne__c + strEnd;
                    }
                    else{
                        objReferralProxy.Unsolicited_Request_Verified_By_gne__c = null;
                        objReferralProxy.Unsolicited_Request_Verified_Date_gne__c = null;
                    }
                }
                //System.debug('Comments:' + Comments);
                if((String)Comments != null && (String)Comments !=''){
                    if(strComment != '')
                        {
                            strComment = strCommentActionBy + Comments + ',#,' + strComment;                }
                    else
                        {
                            strComment = strCommentActionBy + Comments + ',#,';
                        }
                    objReferral.Comments_Referral_gne__c = strComment;
                    //System.debug('objReferral.Comments_Referral_gne__c:' + objReferral.Comments_Referral_gne__c);
                    blnIsReferralUpdated=true;
                }
                //If Revised Requested Completion Date is entered than put the status in Referral history
                if(referralAssignment.Revised_Requested_Completion_Date_gne__c != null && referralAssignment.Revised_Requested_Completion_Date_gne__c != referralAssignmentCopy.Revised_Requested_Completion_Date_gne__c){
                    
                    blnIsReferralAssignmentUpdated=true;
                    blnIsReferralUpdated=true;
                    refHistory = refHistory + datetime.now().format(GNE_Referral_Utils.strPSTFormat,GNE_Referral_Utils.strPST) + strComma + GNE_Referral_Utils.strCompletionDateUpdate +  strComma + UserInfo.getName() + strComma + strAssignedUserName + strComma + (String)referralAssignmentCopy.Assigned_To_gne__c + strComma + strAssignedUserRole + strComma + (String)referralAssignmentCopy.Status_Referral_gne__c + strEnd;
                }
                
                System.debug('Successfully Updated 2.1:');
                //If status changed than put the status in Referral history
                if(selectedStatus != null && selectedStatus != (String)referralAssignmentCopy.Status_Referral_gne__c){
                    System.debug('Successfully Updated 2.1.1:');
                    referralAssignment.Status_Referral_gne__c = selectedStatus;
                    referralAssignment.Status_Referral_Date_gne__c = datetime.now();
                    //referralAssignment.Due_Date_gne__c = dueDate;
                    blnIsReferralAssignmentUpdated=true;
                    blnIsReferralUpdated=true;
                    blnIsStatusChanged = true;
                    refStatus = selectedStatus;
                    refHistory = refHistory + datetime.now().format(GNE_Referral_Utils.strPSTFormat,GNE_Referral_Utils.strPST) + strComma + GNE_Referral_Utils.strStatusUpdate +  strComma + UserInfo.getName() + strComma + strAssignedUserName + strComma + (String)referralAssignmentCopy.Assigned_To_gne__c + strComma + strAssignedUserRole + strComma + selectedStatus + strEnd;
                
                }
                //Any MSL in the chain can verify. This naturally means that the asignee can reassign to another without verifying but only after acknowledging.
                if(isVerified()){
                    if(!isStatusAndAssignedToChanged()){
                        //System.debug('Successfully Updated 3 Assigned_To_gne__c:' + (String)referralAssignment.Assigned_To_gne__c);
                        //System.debug('Successfully Updated old copy Assigned_To_gne__c:' + (String)referralAssignmentCopy.Assigned_To_gne__c);
                        //System.debug('Successfully Updated proxy Assigned_To_gne__c:' + (String)SearchId);
                        if((String)SearchId != null && (String)SearchId != (String)referralAssignmentCopy.Assigned_To_gne__c){                      
                        //if((String)objReferralAssignmentProxy.Assigned_To_gne__c != null && (String)objReferralAssignmentProxy.Assigned_To_gne__c!= (String)referralAssignmentCopy.Assigned_To_gne__c){                       
                            //Manual Assignment on edit                     
                            assignedUser = GNE_Referral_Utils.getCurrentUser(SearchId);
                            if(assignedUser != null){
                                GNE_Referral_Utils.loadUserProfileType(assignedUser);
                                if(GNE_Referral_Utils.isMCL || GNE_Referral_Utils.isMSL){
                                    //objReferralAssignmentProxy.Assigned_To_gne__c = GNE_Referral_Utils.getManualAssigned(assignedUser.Id,dueDate);
                                    SearchId = GNE_Referral_Utils.getManualAssigned(assignedUser.Id,dueDate);
                                    //if((String)objReferralAssignmentProxy.Assigned_To_gne__c == null){
                                    if((String)SearchId == null){
                                        isReAssigned = false;
                                        //System.debug('User not found: ');
                                        lstAssignmentErrors.add((String)assignedUser.name + ' is not available, please asign to someone else.');
                                    }else{
                                        isReAssigned = true;                                
                                    }
                                }else if(GNE_Referral_Utils.isManager){
                                    if(GNE_Referral_Utils.isOnVacation(assignedUser.Id,dueDate)){
                                        isReAssigned = false;
                                        //System.debug('Manager is on vacation: ');
                                        lstAssignmentErrors.add((String)assignedUser.name + ' is out of office, please asign to someone else.');
                                    }else{
                                        isReAssigned = true;
                                        //objReferralAssignmentProxy.Assigned_To_gne__c = assignedUser.Id;
                                        SearchId = assignedUser.Id;
                                    }
                                }else{
                                    isReAssigned = false;
                                    //System.debug('assigned to non-MedAffair user: ');
                                    lstAssignmentErrors.add('Referral can not be assigned to non-MedAffair user, please asign to MedAffair user.');
                                }
                            }else{
                                isReAssigned = false;
                                //System.debug('inactive user: ');
                                lstAssignmentErrors.add('Referral can not be assigned to inactive user, please asign to someone else.');
                            }
                            if(isReAssigned){
                                //--------------------------------------------------------------------------------
                                //strAssignedUserNameRole = GNE_Referral_Utils.getUserNameAndRole((String)objReferralAssignmentProxy.Assigned_To_gne__c);
                                strAssignedUserNameRole = GNE_Referral_Utils.getUserNameAndRole((String)SearchId);
                                if(lstUserNameAndRole.size() >0)
                                        lstUserNameAndRole.clear();
                                if(strAssignedUserNameRole != ''){                              
                                    lstUserNameAndRole = strAssignedUserNameRole.split(',',2);
                                    //System.debug('lstUserNameAndRole: ' + lstUserNameAndRole);
                                    if(lstUserNameAndRole.size() >0){
                                        strAssignedUserName =lstUserNameAndRole[0];
                                        strAssignedUserRole =lstUserNameAndRole[1];                     
                                    }
                                }
                                System.debug('Successfully Updated 3:');
                                blnIsReferralAssignmentUpdated=true;
                                blnIsReferralUpdated=true;
                                blnIsReassigned=true;
                                refHistory = refHistory + datetime.now().format(GNE_Referral_Utils.strPSTFormat,GNE_Referral_Utils.strPST) + strComma + GNE_Referral_Utils.strReassigned +  strComma + UserInfo.getName() + strComma + strAssignedUserName + strComma + (String)SearchId + strComma + strAssignedUserRole + strComma + GNE_Referral_Utils.strAssigned + strEnd;
                                //--------------------------------------------------------------------------------
                            }else{
                                if(lstAssignmentErrors != null && lstAssignmentErrors.size() >0){
                                    //System.debug('GNE_Referral_Utils.setErrorMessage(lstAssignmentErrors)');
                                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,GNE_Referral_Utils.setErrorMessage(lstAssignmentErrors)));
                                    //System.debug('lstAssignmentErrors: ' + lstAssignmentErrors);
                                    
                                    for (String strErrMsg : lstAssignmentErrors)
                                    {
                                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,strErrMsg));
                                    }
                                    Database.rollback(sp1);
                                    GNE_Referral_Utils.isMedicalReferral = false;
                                    return null;
                                }
                            }
                        }
                        if(blnIsReassigned){
                            System.debug('Successfully Updated 4.1:');
                            MSLQueueId = GNE_Referral_Utils.getMSLQueueId(GNE_Referral_Utils.ReferralReassignedQueueName);
                            mapUserId = GNE_Referral_Utils.getAssignedManagerUser(SearchId);
                            if(mapUserId != null && mapUserId.size()>0){
                                if(mapUserId.containsKey('ManagerId')){
                                    assignedUserManager = mapUserId.get('ManagerId');
                                }
                                if(mapUserId.containsKey('UserId')){
                                    finalAssignedUser = mapUserId.get('UserId');
                                }                               
                            }
                            referralAssignment.OwnerId = SearchId;
                            referralAssignment.Assigned_To_gne__c=SearchId;                         
                            referralAssignment.Referral_Assigned_User_Email_gne__c=finalAssignedUser.Email;                         
                            referralAssignment.Due_Date_gne__c=dueDate;
                            referralAssignment.Status_Referral_gne__c = GNE_Referral_Utils.strAssigned;
                            referralAssignment.Status_Referral_Date_gne__c = datetime.now();
                            referralAssignment.Revised_Requested_Completion_Date_gne__c = null;
                            referralAssignment.Status_Email_gne__c = null;
                            referralAssignment.Status_Email_Date_gne__c = null;
                            referralAssignment.Escalation_Status_gne__c = false;
                            
                            //objReferral.Unsolicited_Request_Verified_gne__c = false;
                            //objReferral.Unsolicited_Request_Verified_By_gne__c = null;
                            //objReferral.Unsolicited_Request_Verified_Date_gne__c = null;
                            
                            if(assignedUserManager != null){
                                referralAssignment.Assigned_To_Manager_gne__c=assignedUserManager.Id;
                                referralAssignment.Referral_Assigned_Manager_Email_gne__c=assignedUserManager.Email;                                
                            }else{
                                referralAssignment.Assigned_To_Manager_gne__c=null;
                                referralAssignment.Referral_Assigned_Manager_Email_gne__c=null;
                            }
                            blnIsReferralUpdated=true;
                            blnIsReferralAssignmentUpdated=true;
                            //objReferral.Referral_Assignment_gne__c = newReferralAssignment.Id;
                            
                            strReferralName = referralAssignment.Name;
                            strMedCommName = objReferral.Name;
                            //System.debug('SearchId:' + SearchId);
                            //System.debug('referralAssignment.Status_Referral_gne__c:' + referralAssignment.Status_Referral_gne__c);
                            p = new PageReference('/'+ referralAssignment.Id);
                            //p = new PageReference('/'+ newReferralAssignment.Id);
                            System.debug('Successfully forwarded:');
                        }
                        else{
                            System.debug('Successfully Updated 4.2:');
                            strReferralName = referralAssignment.Name;
                            strMedCommName = objReferral.Name;
                            p = new PageReference('/'+ referralAssignment.Id);  
                        }
                        if(blnIsReferralUpdated){
                            System.debug('Successfully Updated 5: refHistory: ' + refHistory);
                            objReferral.Referral_History_gne__c=refHistory;
                            System.debug('Successfully Updated 5: objReferral: ' + objReferral);
                            update objReferral;
                        }
                        if(blnIsReferralAssignmentUpdated){
                            System.debug('Successfully Updated 6:');
                            System.debug('Successfully Updated 6: referralAssignment: ' + referralAssignment);
                            update referralAssignment;
                        }
                        if(isRequestVerified){
                            if(GNE_Referral_Utils.sendReferralEmail(referralAssignment,objReferral,GNE_Referral_Utils.strRequestVerified)){
                                System.debug('Successfully Referral Verified Email sent:');
                                referralAssignment.Status_Email_gne__c = GNE_Referral_Utils.strStatusUnsolicitedRequestVerifiedEmail;
                                referralAssignment.Status_Email_Date_gne__c = datetime.now();
                                blnIsReferralAssignmentUpdated=true;
                                //update referralAssignment;
                            }
                            else{
                                System.debug('Email Not sent:');
                            }
                        }
                        if(blnIsStatusChanged){                                            
                            if(GNE_Referral_Utils.sendReferralEmail(referralAssignment,objReferral,refStatus)){
                                System.debug('Successfully updated Referral Email sent:');
                                referralAssignment.Status_Email_gne__c = GNE_Referral_Utils.getStatusEmail(referralAssignment.Status_Referral_gne__c);
                                referralAssignment.Status_Email_Date_gne__c = datetime.now();
                                blnIsReferralAssignmentUpdated=true;
                                //update referralAssignment;
                            }
                            else{
                                System.debug('Email Not sent:');
                            }
                        }
                        if(blnIsReferralAssignmentUpdated){
                            System.debug('Successfully Updated 6:');
                            System.debug('Successfully Updated 6: referralAssignment: ' + referralAssignment);
                            update referralAssignment;
                        }
                        if(blnIsReassigned){
                            //if(GNE_Referral_Utils.sendReferralEmail(newReferralAssignment,objReferral,GNE_Referral_Utils.strReassigned)){
                            if(GNE_Referral_Utils.sendReferralEmail(referralAssignment,objReferral,GNE_Referral_Utils.strReassigned)){
                                System.debug('Successfully Reassigned Referral Email sent:');
                                referralAssignment.Status_Email_gne__c = GNE_Referral_Utils.getStatusEmail(GNE_Referral_Utils.strAssigned);
                                referralAssignment.Status_Email_Date_gne__c = datetime.now();
                                update referralAssignment;
                            }
                            else{
                                System.debug('Email Not sent:');
                            }
                        }
                        referralAssignmentCopy = referralAssignment;
                        
                        System.debug('Successfully Referral Creation Email sent:'); 
                            
                        System.debug('Successfully Updated:');            
                    }
                    else{
                        System.debug('You cannot reassign and close the referral at the same time. Please either close or reasign the referral.');
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You cannot reassign and close the referral at the same time. Either close or reasign the referral.'));
                        Database.rollback(sp1);
                        GNE_Referral_Utils.isMedicalReferral = false;
                        return null;
                    }
                }
            else{
                    System.debug('Unsolicited Request Verified must be checked to close a Referral.');
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Unsolicited Request Verified must be checked to close a Referral.'));
                    Database.rollback(sp1);
                    GNE_Referral_Utils.isMedicalReferral = false;
                    return null;
                }
                
            }
            catch (Exception e) {
                System.debug('Error on the page:' + e);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error on the page:' + e));
                Database.rollback(sp1);
                GNE_Referral_Utils.isMedicalReferral = false;
                return null;
            }
        }
        else
        {
            System.debug('A Closed or Fulfilled referral cannot be edited.');
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'A Closed or Fulfilled referral cannot be edited.'));
            GNE_Referral_Utils.isMedicalReferral = false;
            return null;
        }
    }
    
   
    
    GNE_Referral_Utils.isMedicalReferral = false;
    return p;
    
  }
  
  //-------------------------------------------------------------------------------------------------------------
  private List<referralAssignmentWrapper> lstReferralAssignments = new List<referralAssignmentWrapper>();
  
  public class referralAssignmentWrapper{
    
    public String strDateTime {get;set;}
    public String strAction {get;set;}
    public String strActionBy {get;set;}
    public String strAssignedToId {get;set;}
    public String strAssignedToRole {get;set;}
    public String strStatus {get;set;}
    
    
    public referralAssignmentWrapper(String dt,String act,String actBy,String assignedTo,String role,String status){      
      strDateTime = dt;
      strAction = act;
      strActionBy = actBy;
      strAssignedToId = assignedTo;
      strAssignedToRole = role;
      strStatus = status;
    }
  }
  
  public referralAssignmentWrapper[] getRefHistory(){
    return lstReferralAssignments;
  }
  public void loadRefHistory(){
    System.debug('inside getRefHistory: ');
    String strDateTime='';
    String strAction='';
    String strActionBy='';
    String strAssignedToId='';
    String strAssignedToRole='';
    String strStatus='';
    
    String refHistoryRecords='';
    String[] lstRefAssRecs = new List<String> ();
    String[] lstSepRefAssRec = new List<String> ();
    
    if(lstReferralAssignments.size() >0)
        lstReferralAssignments.clear();
    if(objReferral != null && objReferral.Referral_History_gne__c != null && (String)objReferral.Referral_History_gne__c !='' ){
    
        refHistoryRecords=(String)objReferral.Referral_History_gne__c;
        System.debug('refHistoryRecords: ' + refHistoryRecords);
        
        if(refHistoryRecords != null)
            lstRefAssRecs = refHistoryRecords.split(';');
        System.debug('lstRefAssRecs: ' + lstRefAssRecs);
        

        for (String refHist : lstRefAssRecs) {
            if(lstSepRefAssRec.size() >0)
                lstSepRefAssRec.clear();
            System.debug('refHist: ' + refHist);
            lstSepRefAssRec = refHist.split(',');
            System.debug('lstSepRefAssRec: ' + lstSepRefAssRec);
            if (lstSepRefAssRec[0] != null)
                strDateTime = lstSepRefAssRec[0];
            if (lstSepRefAssRec[1] != null)
                strAction = lstSepRefAssRec[1];
            if (lstSepRefAssRec[2] != null)
                strActionBy = lstSepRefAssRec[2];
            if (lstSepRefAssRec[3] != null)
                strAssignedToId = lstSepRefAssRec[3];
            if (lstSepRefAssRec.size() > 5){
                if(lstSepRefAssRec[5] != null)
                    strAssignedToRole = lstSepRefAssRec[5];
            }
            if (lstSepRefAssRec.size() > 6){
                if(lstSepRefAssRec[6] != null)
                    strStatus = lstSepRefAssRec[6];
            }
            lstReferralAssignments.add(new referralAssignmentWrapper(strDateTime,strAction,strActionBy,strAssignedToId,strAssignedToRole,strStatus));
        }
    }
  }
  
  
  //-------------------------------------------------------------------------------------------------------------
  
  //-------------------------------------------------------------------------------------------------------------
  private List<referralCommentsWrapper> lstReferralComments = new List<referralCommentsWrapper>();
  
  public class referralCommentsWrapper{
    
    public String strActionBy {get;set;}
    public String strAction {get;set;}    
    
    public referralCommentsWrapper(String actBy,String act){
      strActionBy = actBy;
      strAction = act;    
    }
  }
  
  public referralCommentsWrapper[] getRefComments(){
    return lstReferralComments;
  }
  public void loadRefComments(){
    System.debug('inside loadRefComments: ');
    String strActionBy='';
    String strAction='';
    
    if(lstReferralComments.size() >0)
        lstReferralComments.clear();
    if(objReferral != null && objReferral.Comments_Referral_gne__c != null && (String)objReferral.Comments_Referral_gne__c !='' ){
    //if(objReferral.Comments_Referral_gne__c != null){
        String refCommentRecords=(String)objReferral.Comments_Referral_gne__c;
        System.debug('refCommentRecords: ' + refCommentRecords);
        String[] lstRefCommRecs = new List<String> ();
        lstRefCommRecs = refCommentRecords.split(',#,');
        System.debug('lstRefCommRecs: ' + lstRefCommRecs);
        String[] lstSepRefCommRec = new List<String> ();

        for (String refComm : lstRefCommRecs) {
            System.debug('lstSepRefCommRec.size(): ' + lstSepRefCommRec.size());
            if(lstSepRefCommRec.size() >0)
                lstSepRefCommRec.clear();
            System.debug('refComm: ' + refComm);
            lstSepRefCommRec = refComm.split(',@,');
            System.debug('lstSepRefCommRec.size(): ' + lstSepRefCommRec.size());
            System.debug('lstSepRefCommRec: ' + lstSepRefCommRec);
            if (lstSepRefCommRec[0] != null)
                strActionBy = lstSepRefCommRec[0];
            if(lstSepRefCommRec.size() >1){
                if (lstSepRefCommRec[1] != null)
                    strAction = lstSepRefCommRec[1];
            }
            lstReferralComments.add(new referralCommentsWrapper(strActionBy,strAction));
        }
    }
  }
  
  //-------------------------------------------------------------------------------------------------------------
 }