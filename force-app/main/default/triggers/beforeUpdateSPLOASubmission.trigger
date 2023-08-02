trigger beforeUpdateSPLOASubmission on C_Ops_SPLOA_Request__c (before update) {
    C_Ops_SPLOA_Request__c  sploa= trigger.new[0];    
    C_Ops_SPLOA_Request__c oldRequest = trigger.old[0];
    map<String,String> permissionSet =  new Map<String,String>();
    for(PermissionSetAssignment listOfPer :[SELECT Assignee.Name,Assignee.Id FROM PermissionSetAssignment where 
                                            PermissionSet.Name='C_Ops_SPLOA_Super_User' or PermissionSet.Name='C_Ops_SPLOA_Regular_User' 
                                            or PermissionSet.Name='C_Ops_SPLOA_IT_Support_User' or PermissionSet.Name='C_Ops_SPLOA_Contract_Integration'or PermissionSet.Name= 'C_Ops_SPLOA_dnabler']){
                                                permissionSet.put(listOfPer.Assignee.Id,listOfPer.Assignee.Name);
                                            }
    
    Map<String,Schema.SObjectType> reqGlobalDescribeMap = Schema.getGlobalDescribe();
    Schema.SObjectType reqsObjectType =reqGlobalDescribeMap.get('C_Ops_SPLOA_Request__c');
    Schema.DescribeSObjectResult reqResult = reqsObjectType.getDescribe();
    Map<String,Schema.SObjectField> reqObjectFieldMap = reqResult.fields.getMap();
    List<String> changedfields = new List<String>();
    if(userInfo.getUserId() == '0050g000006f0NBAAY')
        return; 
    for(String field: reqObjectFieldMap.keyset() ){
        if(sploa.get(field)!= oldRequest.get(field)){
            changedfields.add(field);
        }    
    }
    
    system.debug(changedfields);
    if(trigger.IsUpdate ){ 
        
        if(oldRequest.C_Ops_SPLOA_Request_Status__c=='Processed' && sploa.C_Ops_SPLOA_Request_Status__c == 'Re-Opened' && sploa.Assign_To__c == userInfo.getUserId() &&changedfields.size()==1){
            sploa.Status_Category__c='';
            sploa.Processed_Date__c=null;
        }        
        else if(oldRequest.C_Ops_SPLOA_Request_Status__c=='Denied' ){        
            //Part of ROBOCOPS-364 - On a Denied request allow non-readonly C-Ops users to assign the request to her/himself and update denial reason.
            if(sploa.C_Ops_SPLOA_Request_Status__c == 'Re-Opened' &&  string.isblank(sploa.Denial_Reason__c) && sploa.Date_Denied_If_Applicable__c!=oldRequest.Date_Denied_If_Applicable__c  ){
                sploa.Status_Category__c='';
            }
            if(String.isBlank(sploa.Assign_To__c) && oldRequest.C_Ops_SPLOA_Request_Status__c != sploa.C_Ops_SPLOA_Request_Status__c ){
                sploa.addError('The request needs to be assigned to a team member.' );  
            }
        }
        else{
            //user doesn't have IAP permissionset to update
            if(!permissionSet.ContainsKey(userInfo.getUserId())){
                sploa.addError('You are not authorized to update this submission');
            }           
            else if( sploa.Assign_To__c == userInfo.getUserId() && changedfields.size() == 1 && changedfields[0] == 'C_Ops_IAP_Executed_Access_Type__c'&& (oldRequest.C_Ops_SPLOA_Request_Status__c=='Denied' || oldRequest.C_Ops_SPLOA_Request_Status__c=='Processed' || oldRequest.C_Ops_SPLOA_Request_Status__c=='Expired'))
            {
                sploa.addError('You cannot update a completed request');
            }
            else if(sploa.C_Ops_SPLOA_Request_Status__c != 'Re-Opened') {
                if(String.isNotBlank(sploa.Assign_To__c) && !permissionSet.ContainsKey(sploa.Assign_To__c)){
                    sploa.addError('This user is not authorized to be assigned to a IAP submission');
                }else if(sploa.Assign_To__c != userInfo.getUserId()){
                    if(oldRequest.C_Ops_SPLOA_Request_Status__c==null || oldRequest.C_Ops_SPLOA_Request_Status__c == 'New') {
                        if(sploa.C_Ops_SPLOA_Request_Status__c!=oldRequest.C_Ops_SPLOA_Request_Status__c && sploa.C_Ops_SPLOA_Request_Status__c != 'In Process')
                            sploa.addError('This IAP request status should be set to In Process');
                       // else sploa.C_Ops_SPLOA_Request_Status__c = 'In Process';
                    }
                    if(String.isBlank(sploa.Assign_To__c) && oldRequest.C_Ops_SPLOA_Request_Status__c != sploa.C_Ops_SPLOA_Request_Status__c ){
                      sploa.addError('The request needs to be assigned to a team member.' );  
                    }
                    
                }
                if (sploa.C_Ops_SPLOA_Request_Status__c=='Denied' && (sploa.Denial_Reason__c==null || sploa.Denial_Reason__c.trim() =='')){
                    sploa.addError('Please select a Denial Reason before canceling this request');
                }else if(sploa.C_Ops_SPLOA_Request_Status__c!='Denied' && sploa.C_Ops_SPLOA_Request_Status__c!='Re-Opened' &&
                         ((sploa.Denial_Reason__c!=null && sploa.Denial_Reason__c.trim().length()>0) ||
                          sploa.Date_Denied_If_Applicable__c!=null )){
                              sploa.addError('You cannot select a Denial Reason or Date/Time Denied for a request that is not denied');
                          }else if( oldRequest.C_Ops_SPLOA_Request_Status__c!=null && oldRequest.C_Ops_SPLOA_Request_Status__c!='New' && oldRequest.C_Ops_SPLOA_Request_Status__c!='Processed' && oldRequest.C_Ops_SPLOA_Request_Status__c!='Denied' && sploa.C_Ops_SPLOA_Request_Status__c=='New'){
                              sploa.addError('You cannot change request status from '+oldRequest.C_Ops_SPLOA_Request_Status__c+' to New');
                          }
                else if(oldRequest.C_Ops_SPLOA_Request_Status__c!=null && oldRequest.C_Ops_SPLOA_Request_Status__c!='New' && sploa.C_Ops_SPLOA_Request_Status__c=='New'){
                    sploa.addError('You cannot change request status from '+oldRequest.C_Ops_SPLOA_Request_Status__c+' to New');
                }else if(sploa.C_Ops_SPLOA_Request_Status__c==null || sploa.C_Ops_SPLOA_Request_Status__c == 'New'){
                    sploa.C_Ops_SPLOA_Request_Status__c = 'In Process';
                }else if(sploa.C_Ops_SPLOA_Request_Status__c=='Denied' && sploa.Denial_Reason__c!=null && sploa.Denial_Reason__c.trim().length()>0 ){
                    sploa.Date_Denied_If_Applicable__c=system.now();
                }                    
                
            }
            
        }  
    }
   
    if(trigger.IsUpdate && trigger.IsBefore){
        C_Ops_Submitted_Req_Controller cont = new C_Ops_Submitted_Req_Controller();
        cont.clearfieldsuponstatuschange(trigger.new,trigger.old);
    }
    
     
    
    private Boolean changedRequest(){
        if(sploa.Denial_Reason__c!=oldRequest.Denial_Reason__c || 
           sploa.Date_Denied_If_Applicable__c !=oldRequest.Date_Denied_If_Applicable__c ||
           sploa.Is_This_IDN__c!= oldRequest.Is_This_IDN__c ||
           sploa.C_Ops_IAP_Executed_Access_Type__c!=oldRequest.C_Ops_IAP_Executed_Access_Type__c
          )    return true;
        else return false;
        
    }
    
    private Boolean isITSupportUser(){
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        String proflieName = PROFILE[0].Name;
        if(proflieName =='System Administrator' || proflieName =='GNE-SYS-Support' || proflieName =='GNE-LWO-CUSTOPS' || proflieName =='C-Ops SPLOA Profile') 
            return true;
        else   return false;
    }
    
}