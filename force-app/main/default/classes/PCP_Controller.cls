public class PCP_Controller {
    public static final String PROFILE_TYPE_EA_Admin = 'PCP EA Admin';
    String profileName = CPCM_Trigger_Helper.getCurrentUserProfileName(); 
    public void populatesubdetails(List<Political_Contribution_Requests__c> oldList , List<Political_Contribution_Requests__c> newList){
        
        List<User> approvers = [SELECT Id,IsActive, Email,External_ID_gne__c FROM User WHERE External_ID_gne__c IN ('joyr','wachterm','mayebeth','pizarros')];
        Map<String,Id> apprMap = new Map<String,Id>();
        for(User user:approvers){
            if(user.IsActive == true )
                apprMap.put(user.External_ID_gne__c,user.Id);
        }
        Set<Id> canIds = new Set<Id>();
        
        for(Political_Contribution_Requests__c req:newList){
            if(req.Candidate_PCP__c != null ){
                canIds.add(req.Candidate_PCP__c);
            }
        }
        
        for(Political_Contribution_Requests__c req:newList){
            if(req.Status__c == 'New'  ){
                req.Submitted_Date__c = system.today();
                req.User__c = UserInfo.getUserId() ;
            }
            //  if(req.Approver_Name__c != null ){
            //     req.Aprrover_Name_backend__c = '005700000020DkKAAU';
            if(req.Approver_Name__c != null  && apprMap.get(req.Approver_Name__c)!= null){
                req.Aprrover_Name_backend__c = apprMap.get(req.Approver_Name__c);
            }
            if(req.Approver_Name__c != null && apprMap.get(req.Approver_Name__c)== null){
                req.Aprrover_Name_backend__c = null;
            }
            if(req.Payment_Amount__c != null){
                req.Payment_Amount__c = null;
            }
        }
    }
    public void populateadmindetails(Map<Id,Political_Contribution_Requests__c> oldMap , List<Political_Contribution_Requests__c> newList){
        List<User> approvers = [SELECT Id,IsActive, Email,External_ID_gne__c FROM User WHERE External_ID_gne__c IN ('joyr','wachterm','mayebeth','pizarros')];
        Set<Id> canIds = new Set<Id>();   
        
        for(Political_Contribution_Requests__c req:newList){
            if(req.Candidate_PCP__c != null && oldMap.get(req.Id).Candidate_PCP__c != req.Candidate_PCP__c ){
                canIds.add(req.Candidate_PCP__c);
            }
        }    
        
        
        Map<String,Id> apprMap = new Map<String,Id>();
        for(User user:approvers){
            if(user.IsActive == true )
                apprMap.put(user.External_ID_gne__c,user.Id);
        }
        
        for(Political_Contribution_Requests__c req:newList){
            //    if(req.Approver_Name__c != null ){
            //     req.Aprrover_Name_backend__c = '005700000020DkKAAU';
            
            if(req.Approver_Name__c != null && apprMap.get(req.Approver_Name__c)!= null){
                req.Aprrover_Name_backend__c = apprMap.get(req.Approver_Name__c);
                
            }
            if(req.Approver_Name__c != null && apprMap.get(req.Approver_Name__c)== null){
                req.Aprrover_Name_backend__c = null;
            }
            if(req.Needs_Revision_checkbox__c == true && req.Status__c != oldMap.get(req.Id).Status__c){
                req.Needs_Revision_checkbox__c = false;
            }
            if(req.Status__c == 'New' && oldMap.get(req.Id).Status__c != 'New'){
                req.Submitted_Date__c = system.today();
                req.User__c = UserInfo.getUserId() ;
            }
            if(req.Status__c == 'Approval' && oldMap.get(req.Id).Status__c != 'Approval'  ){
                req.Admin_Review_Date__c = system.today();
                req.Admin_Reviewed_by__c = UserInfo.getUserId() ;
            }
            if(req.status__c == 'External Review' && oldMap.get(req.Id).Status__c != 'External Review'  ){
                req.Approved_Date__c = system.today();
                req.Approved_by__c = UserInfo.getUserId() ;
            }
            if(req.Status__c == 'Ok to Pay' && oldMap.get(req.Id).Status__c != 'Ok to Pay' ){
                req.Legal_Review_Date__c = system.today();
                req.Legal_Reviewed_by__c = UserInfo.getUserId() ;
            }
            if(req.Check__c != null && req.Check_Date__c != null  && req.Payment_Amount__c != null && req.Status__c != 'Check Issued' && req.Status__c == 'Ok to Pay'  ){
                req.Status__c = 'Check Issued';
            }        
            if(req.Status__c == 'Closed' && oldMap.get(req.Id).Status__c == 'Closed'){
                if(profileName!=PROFILE_TYPE_EA_Admin){ 
                    req.addError('You cannot edit a Closed Request');
                }
                else {
                    string comments=req.CPCM_Comments__c;
                    date checkvoided= req.CPCM_Date_Check_Voided__c, checkcleared=req.CPCM_Date_Check_Cleared__c;
                    req.CPCM_Comments__c=oldMap.get(req.Id).CPCM_Comments__c;
                    req.CPCM_Date_Check_Voided__c=oldMap.get(req.Id).CPCM_Date_Check_Voided__c;
                    req.CPCM_Date_Check_Cleared__c=oldMap.get(req.Id).CPCM_Date_Check_Cleared__c;
                    if(req != oldMap.get(req.Id))
                        req.addError('Only Date Check Voided, Date Check Cleared and Close Comments can be edited once a request has been closed.');
                    req.CPCM_Comments__c=comments;
                    req.CPCM_Date_Check_Voided__c=checkvoided;
                    req.CPCM_Date_Check_Cleared__c=checkcleared;
                }
            }
        }
    }
}