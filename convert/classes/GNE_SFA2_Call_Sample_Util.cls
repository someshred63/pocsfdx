public without sharing class GNE_SFA2_Call_Sample_Util {
	public static Map<Id,Call2_vod__c> CallAfterInsert = new Map<Id,Call2_vod__c>();
  	public static String userProfile = GNE_SFA2_Util.getCurrentUserProfileName();
  	
  	public static boolean firstRun = true; 
	public static Map<String, String> loadMessages(){
		Map<String, String> messageLabels = new Map<String, String>();
		messageLabels.put('GNE_SFA2_ErrMsg_Quantity_More_Than_Zero', Label.GNE_SFA2_ErrMsg_Quantity_More_Than_Zero);
		messageLabels.put('GNE_SFA2_ErrMsg_Gift_Compliance_Message', Label.GNE_SFA2_ErrMsg_Gift_Compliance_Message);
		messageLabels.put('GNE_SFA2_ErrMsg_Submitted_Call_Can_Not_Be_Updated', Label.GNE_SFA2_ErrMsg_Submitted_Call_Can_Not_Be_Updated);
		messageLabels.put('GNE_SFA2_ErrMsg_Submitted_Call_Can_Not_Be_Deleted', Label.GNE_SFA2_ErrMsg_Submitted_Call_Can_Not_Be_Deleted);
		return messageLabels;
	}
	
  @future 
  public static void updateCallDiscussion(List<Id> temp) {
   List<Call2_Discussion_vod__c> tempList = [Select id from Call2_Discussion_vod__c where Id in :temp];
   update tempList;
    
  }  
  
  public static Boolean isCurrentUserUseEDM()
  {
  	 if( userProfile.startsWith('GNE-TLS') || userProfile.startsWith('GNE-MCCO-FRM') || userProfile.startsWith('GNE-MedAffairs') || userProfile.startsWith('GNE-SFA-OCC') || userProfile.startsWith('GNE-SFA-CC') || userProfile.startsWith('GNE-SFA-HCV-RCC'))
  	    return true;
  	 else
  	    return false;
  }
  
  public static Boolean createSPvalidation(Call2_Discussion_vod__c recForValidation){
    //GNE-TLS
    if(userProfile.startsWith('GNE-TLS')){
      if(recForValidation.Activity_gne__c == '1:1 Training/Deck Update' 
             && recForValidation.Call2_vod__r.Completed_gne__c == true
             && recForValidation.Event_Curriculum_gne__c != null 
             && recForValidation.Call2_vod__r.Account_vod__c != null
             && recForValidation.Call2_vod__r.Interaction_Location_gne__c != null) return true;
    else
      return false;
    
    }
    //GNE-MCCO-FRM (All FRM groups)
    else if (userProfile.startsWith('GNE-MCCO-FRM')){
      if(recForValidation.Call2_vod__r.Interaction_Type_gne__c == '1:1 Training/Deck Update' 
             && recForValidation.Call2_vod__r.Completed_gne__c == true
             && recForValidation.Event_Curriculum_gne__c != null 
             && recForValidation.Call2_vod__r.Account_vod__c != null) return true;
    else
      return false;
    }
    //GNE-MedAffairs-MSL
    else if (userProfile.startsWith('GNE-MedAffairs')){
      if(recForValidation.Call2_vod__r.Interaction_Type_gne__c == '1:1'
             && recForValidation.Call2_vod__r.Visit_Reason_gne__c == 'Speaker Training'
             && recForValidation.Call2_vod__r.Completed_gne__c == true 
             && recForValidation.Event_Curriculum_gne__c != null 
             && recForValidation.Call2_vod__r.Account_vod__c != null ) return true;
    else
      return false;
    }
    //GNE-SFA-OCC (All OCC groups)
    else if (userProfile.startsWith('GNE-SFA-OCC') || userProfile.startsWith('GNE-SFA-CC')){
      if(recForValidation.Activity_gne__c == '1:1 Training/Deck Update' 
             && recForValidation.Call2_vod__r.Completed_gne__c == true
             && recForValidation.Event_Curriculum_gne__c != null 
             && recForValidation.Call2_vod__r.Account_vod__c != null) return true;
    else
      return false;
    }
    //RCC groups
    else if (userProfile.startsWith('GNE-SFA-HCV-RCC')){
      if(recForValidation.Activity_gne__c == '1:1 Training/Deck Update' 
             && recForValidation.Call2_vod__r.Completed_gne__c == true
             && recForValidation.Event_Curriculum_gne__c != null 
             && recForValidation.Call2_vod__r.Account_vod__c != null ) return true;
    else
      return false;
    }
    else{
      return false;
    }
  }
  public static String determineDeliveryMethod(){
	    if(userProfile.startsWith('GNE-MCCO-FRM') || userProfile.startsWith('GNE-MedAffairs') ){
	      return '1:1 Training/Deck Update';
	    }
    	else{
    		return '1:1 Training/Deck Update';
  		}
  }
  
  public static boolean isLocked (String Id, Map <Id,Call2_vod__c> calls) {
        Call2_vod__c call = calls.get(Id);
        
        if (call != null && call.Parent_Call_vod__r != null && call.Parent_Call_vod__r.Status_vod__c == 'Submitted_vod'){
        	return true;
        } 
        if(call != null && call.Status_vod__c == 'Submitted_vod') return true;
            return false;
    }
 
 public static Map <Id,Call2_vod__c> getCallMap (List <String> callIds) {
        Map <Id, Call2_vod__c> calls = 
                new Map <Id, Call2_vod__c> (
                        [Select Id, Name,Parent_Call_vod__r.Status_vod__c, Status_vod__c, Override_Lock_vod__c, OwnerId, Call_Date_vod__c  
                        From Call2_vod__c
                        Where Id in :callIds]);
        return calls;       
 }
 
 public static String concatanateWithDelimiter(String account, String product, String User) {
        String tmpAccount;
        if (account != null && account.length() > 15)
        	tmpAccount = account.substring(0,15);
        else 
        	tmpAccount = account;
        return tmpAccount+'__'+product+'__'+user+'__';
}
public static String getLimitId(String account, String product, String User) {
        String tmpAccount;
        if (account != null && account.length() > 15)
        	tmpAccount = account.substring(0,15);
        else 
        	tmpAccount = account;
        return tmpAccount+'__'+product+'__'+user+'__';
}

public static Sample_Limit_Transaction_vod__c createTransactionRecord ( Call2_Sample_vod__c callSample, Sample_Limit_vod__c checkLimit, Call2_vod__c call) {
 	String ownerId = null;
    Date CallDate = null;
    String callName = null;
    String callId = null;
    if (call != null) {
    	ownerId = call.OwnerId;
        CallDate = call.Call_Date_vod__c;
        callName = call.Name;
        callId = call.Id;
    }
 	Sample_Limit_Transaction_vod__c sampleLimitTransaction = new Sample_Limit_Transaction_vod__c();
 		System.debug ('crow=' + callSample);
 	
	// Call information
	sampleLimitTransaction.Call2_Id_vod__c = callId;
	sampleLimitTransaction.Call_Name_vod__c =  callName; 
	sampleLimitTransaction.Call2_vod__c = callId;
							
	sampleLimitTransaction.Lot_vod__c = callSample.Lot_vod__c;
	sampleLimitTransaction.Quantity_To_Disperse_vod__c = callSample.Quantity_vod__c;
	
	if (checkLimit != null) {
		if ( checkLimit.Product_vod__c != null) {
			sampleLimitTransaction.Product_vod__c = checkLimit.Product_vod__c;
			sampleLimitTransaction.Product_Id_vod__c = checkLimit.Product_vod__c;
			sampleLimitTransaction.Product_Name_vod__c = checkLimit.Product_vod__r.Name;
		}
								
		if (checkLimit.Account_vod__c != null) {
			sampleLimitTransaction.Account_vod__c = checkLimit.Account_vod__c;
			sampleLimitTransaction.Account_Id_vod__c = checkLimit.Account_vod__c;
			sampleLimitTransaction.Account_Name_vod__c = checkLimit.Account_vod__r.Formatted_Name_vod__c; 
		}
								
		sampleLimitTransaction.Disbursed_Quantity_vod__c = checkLimit.Disbursed_Quantity_vod__c;
		sampleLimitTransaction.Start_Date_vod__c = checkLimit.Start_Date_vod__c;
		sampleLimitTransaction.End_Date_vod__c = checkLimit.End_Date_vod__c;
		sampleLimitTransaction.Group_Id_vod__c = checkLimit.Group_Id_vod__c;
		sampleLimitTransaction.Enforce_Limit_vod__c = checkLimit.Enforce_Limit_vod__c;
		sampleLimitTransaction.Limit_Quantity_vod__c = checkLimit.Limit_Quantity_vod__c;
		sampleLimitTransaction.Reason_vod__c = callSample.Name;
		sampleLimitTransaction.Remaining_Quantity_vod__c = checkLimit.Remaining_Quantity_vod__c;
		sampleLimitTransaction.Sample_Limit_vod__c = checkLimit.Id;
		sampleLimitTransaction.Sample_Limit_Id_vod__c = checkLimit.Id;
		sampleLimitTransaction.Sample_Limit_Name_vod__c = checkLimit.Name;
		sampleLimitTransaction.Sample_Limit_Type_vod__c = checkLimit.Sample_Limit_Type_vod__c;
		if (checkLimit.User_vod__c != null) {
			sampleLimitTransaction.User_vod__c = checkLimit.User_vod__c;
			sampleLimitTransaction.User_Id_vod__c =  checkLimit.User_vod__c;
			sampleLimitTransaction.User_Name_vod__c = checkLimit.User_vod__r.Username;
		}
	}							

 	return sampleLimitTransaction;	
 }
 
 
}