public without sharing class GNE_ViewReferralHistory
{
  
  /* This class is used for creating a Referral.
  Referral is a Medical Communication request to an MSL. The Referral is identified as a Medical communication
  request with a recordType Referral.
  
  
  */
  
   
  
  
  Boolean isEditable = false;
  Boolean isClosed = false;
  Boolean isAssigned = false;
  String strReferralName = '';
  
  User currentUser = new User();
    
  Medical_Communication_gne__c objReferral = null;
  Referral_Assignment_gne__c objReferralAssignment = null;
  
  private final ApexPages.StandardController stdController =null;
  
  public boolean getIsMedAffairProfileUser()
    {
        System.debug('Inside getCurrentUser: --> ');
        if(currentUser !=null && (currentUser.Profile_Name_gne__c.contains(GNE_Referral_Utils.MedAffairProfile) || currentUser.Profile_Name_gne__c.contains(GNE_Referral_Utils.SysAdminProfile)) && (!currentUser.Profile_Name_gne__c.contains(GNE_Referral_Utils.TISLProfile)))
        {
            return true;
        }
        else{
            return false;
        }
    }
  public Medical_Communication_gne__c getReferral()
  {
    return objReferral;
  }
  
  public Referral_Assignment_gne__c getReferralAssignment()
  {
    return objReferralAssignment;
  }
  public GNE_ViewReferralHistory (ApexPages.StandardController stdController) {
    
        this.stdController = stdController;    
        System.debug (ApexPages.currentPage() + ' page constructor.');
        
        
        Medical_Communication_gne__c objMedComm = (Medical_Communication_gne__c)  stdController.getRecord();
        objReferral = [Select Account_gne__c, Account_Medcom_gne__c, Account_Referral_gne__c, Address_Name_gne__c, Assigned_To_gne__c, Assigned_To_Id_gne__c, Comments_Referral_gne__c, CreatedById, CreatedDate, Email_gne__c, Fax_gne__c, Follow_up_Method_gne__c, Id, Medical_Question_gne__c, Molecule_gne__c, Name, OwnerId, Phone_gne__c, Priority_gne__c, Product_gne__c, RecordTypeId, Referral_Assignment_gne__c, Referral_Assignment_gne__r.Account_gne__c, Referral_Assignment_gne__r.AccountId_gne__c, Referral_Assignment_gne__r.Assigned_To_gne__c, Referral_Assignment_gne__r.CreatedById, Referral_Assignment_gne__r.CreatedDate, Referral_Assignment_gne__r.Follow_up_Method_gne__c, Referral_Assignment_gne__r.Id, Referral_Assignment_gne__r.Medical_Request_gne__c, Referral_Assignment_gne__r.Molecule_gne__c, Referral_Assignment_gne__r.Name, Referral_Assignment_gne__r.OwnerId, Referral_Assignment_gne__r.Priority_gne__c, Referral_Assignment_gne__r.Product_gne__c, Referral_Assignment_gne__r.Status_Email_Date_gne__c, Referral_Assignment_gne__r.Status_Email_gne__c, Referral_Assignment_gne__r.Status_Referral_Date_gne__c, Referral_Assignment_gne__r.Status_Referral_gne__c, Referral_Assignment_gne__r.TA_SubTA_gne__c, Referral_History_gne__c, 
            Requested_Completion_Date_gne__c, Requested_By_gne__c, Status_Referral_Date_gne__c, Status_Referral_Email_Date_gne__c, Status_Referral_Email_gne__c, Status_Referral_gne__c, TA_SubTA_gne__c, Unsolicited_Request_Verified_By_gne__c, Unsolicited_Request_Verified_Date_gne__c from Medical_Communication_gne__c where id = :objMedComm.Id];
        if(objReferral != null && objReferral.Referral_Assignment_gne__c != null){
            objReferralAssignment = [Select Account_gne__c, AccountId_gne__c, Assigned_To_gne__c, CreatedById, CreatedDate, Follow_up_Method_gne__c, Id,Revised_Requested_Completion_Date_gne__c, Medical_Request_gne__c, Medical_Request_gne__r.Account_gne__c, Medical_Request_gne__r.Account_Medcom_gne__c, Medical_Request_gne__r.Account_Referral_gne__c, Medical_Request_gne__r.Address_Name_gne__c, Medical_Request_gne__r.Assigned_To_gne__c, Medical_Request_gne__r.Assigned_To_Id_gne__c, Medical_Request_gne__r.Comments_Referral_gne__c, Medical_Request_gne__r.CreatedById, Medical_Request_gne__r.CreatedDate, Medical_Request_gne__r.Email_gne__c, Medical_Request_gne__r.Fax_gne__c, Medical_Request_gne__r.Follow_up_Method_gne__c, Medical_Request_gne__r.Id, Medical_Request_gne__r.Medical_Question_gne__c, Medical_Request_gne__r.Molecule_gne__c, Medical_Request_gne__r.Name, Medical_Request_gne__r.OwnerId, Medical_Request_gne__r.Phone_gne__c, Medical_Request_gne__r.Priority_gne__c, Medical_Request_gne__r.Product_gne__c, Medical_Request_gne__r.RecordTypeId, Medical_Request_gne__r.Referral_Assignment_gne__c, Medical_Request_gne__r.Referral_History_gne__c,        
        Medical_Request_gne__r.Requested_By_gne__c, Medical_Request_gne__r.Requested_Completion_Date_gne__c, 
        Medical_Request_gne__r.Status_Referral_Date_gne__c, Medical_Request_gne__r.Status_Referral_Email_Date_gne__c, Medical_Request_gne__r.Status_Referral_Email_gne__c, Medical_Request_gne__r.Status_Referral_gne__c, Medical_Request_gne__r.TA_SubTA_gne__c, Medical_Request_gne__r.Unsolicited_Request_Verified_By_gne__c, Medical_Request_gne__r.Unsolicited_Request_Verified_Date_gne__c, Molecule_gne__c, Name, OwnerId, Priority_gne__c, Product_gne__c, Status_Email_Date_gne__c, Status_Email_gne__c, Status_Referral_Date_gne__c, Status_Referral_gne__c, TA_SubTA_gne__c from Referral_Assignment_gne__c where Id =: objReferral.Referral_Assignment_gne__c];
        
            currentUser=GNE_Referral_Utils.getCurrentUser(UserInfo.getUserId());
            System.debug('UserInfo.getUserId(): --> ' + UserInfo.getUserId());
            System.debug('currentUser.Profile_Name_gne__c: --> ' + currentUser.Profile_Name_gne__c);
            
            
            loadRefHistory();
            loadRefComments();           
        
        }
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
    
    /*
    public referralAssignmentWrapper(Datetime dt,String act,String actBy,Id assignedTo){      
      Datetime = dt;
      strAction = act;
      strActionBy = actBy;
      strAssignedToId = assignedTo;
    }
    */
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
    
    
    if(lstReferralAssignments.size() >0)
        lstReferralAssignments.clear();
    String refHistoryRecords=(String)objReferral.Referral_History_gne__c;
    System.debug('refHistoryRecords: ' + refHistoryRecords);
    String[] lstRefAssRecs = new List<String> ();
    if(refHistoryRecords != null)
        lstRefAssRecs = refHistoryRecords.split(';');
    System.debug('lstRefAssRecs: ' + lstRefAssRecs);
    String[] lstSepRefAssRec = new List<String> ();

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
    
    //return lstReferralAssignments; 
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
    if(objReferral.Comments_Referral_gne__c != null){
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
    
    //return lstReferralComments; 
  }
  
  
  //-------------------------------------------------------------------------------------------------------------
 }