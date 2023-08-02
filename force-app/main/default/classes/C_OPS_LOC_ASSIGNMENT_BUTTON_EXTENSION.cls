public with sharing class C_OPS_LOC_ASSIGNMENT_BUTTON_EXTENSION {

    public C_Ops_LOC_Request__c myRequest {set; get;}
    public C_Ops_LOC_Request_Staging__C myStgRequest {set; get;}
    public  id recordID {public get; private set;} 
    private boolean errorEncountered;
    private boolean isStagingRequest; 
    private string  errorText; 
    
    public C_OPS_LOC_ASSIGNMENT_BUTTON_EXTENSION(ApexPages.StandardController stdController) {
        
        SObjectType sObjectType = stdController.getRecord().getSObjectType(); 
        
        if(sObjectType == C_OPS_LOC_REQUEST__C.sObjectType){
            
            this.myRequest = (C_Ops_LOC_Request__c)stdController.getRecord(); 
            errorEncountered = false;
            recordID = myRequest.Id;     
            myRequest = [SELECT id, assign_to__c, ownerid, Request_Status__c from C_Ops_LOC_Request__C where id =: recordID  LIMIT 1]; 
            isStagingRequest = FALSE; 
        }
        
        else if(sObjectType == C_OPS_LOC_Request_Staging__C.sObjectType){
            
            this.myStgRequest = (C_OPS_LOC_REQUEST_STAGING__C)stdController.getRecord(); 
            errorEncountered = false;
            recordID = myStgRequest.ID; 
            myStgRequest = [SELECT id, assigned_to__C, ownerid, Request_Status__c from C_OPS_LOC_REQUEST_STAGING__C where id =: recordID LIMIT 1]; 
            isStagingRequest = TRUE; 
        }
        
    }
   
    public PageReference assignRequest(){ 
        errorEncountered = false;
        // BELOW SECTION IS SAME FOR BOTH TYPES
        //first up, grab all the members c-ops public user group
        Group g = [SELECT ID from group where name = 'C-Ops User group' LIMIT 1];
        List<GroupMember> confirmedUsers  = [SELECT ID, userOrGroupId from GroupMember where groupId =: g.Id]; 
        
        List<ID> onlyIDs = new List<String>(); 
        
        for(groupMember u : confirmedUsers){
            
            onlyIds.add(u.userorgroupid); 
        }
        
        //Seems this piece of code is not used
        Group c_ops_group;
        c_ops_group = [SELECT name, id from GROUP where name = 'LOC Request Queue' LIMIT 1];
                    
        id queueGroupId = c_ops_group.id; 
        
        //Jie - if assigned user in not in the C-Ops user group, error out
        if(!onlyIds.contains(UserInfo.getUserId())){ // if they aren't in the public group bounce them out
                    
                    errorEncountered = TRUE;
                    errorText = 'Only members of the C-Ops User Group may change assignments on this request.'; 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorText ));
        }else{
            if(!isStagingRequest){
                //LOC submission can't be assign to anyone not in the C-Ops User group
                if(myRequest.assign_to__c!=null && (!onlyIds.contains(myRequest.assign_to__c))){
                    errorEncountered = TRUE;
                    errorText = 'Assigned Users must be members of the C-Ops Public User Group.'; 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorText ));
                }
                if (myRequest.OwnerId != queueGroupId) myRequest.OwnerId = queueGroupId;  
                if(myRequest.Request_Status__c=='Processed'|| myRequest.Request_Status__c=='Unable to Process') {
                    errorEncountered = TRUE;
                    errorText = 'This LOC request\' status is '+myRequest.Request_Status__c+' it is closed. You can\'t change its assignment.'; 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorText ));
                }
                else if(myRequest.assign_to__c== NULL)     myRequest.Request_Status__c ='New'; 
                else   myRequest.Request_Status__c ='Assigned'; 
            
            } else {
                //LOC submission staging
               
                if (myStgRequest.OwnerId != queueGroupId) myStgRequest.OwnerId = queueGroupId;
                if (myStgRequest.Request_Status__c =='LOC Requests Created') {
                    errorEncountered = TRUE; 
                    errorText = 'This staging request has been processing successfully. No assignment change can be made to this record.'; 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorText ));
                }
                else if(myStgRequest.Request_Status__c == 'Pending'){               
                    errorEncountered = TRUE; 
                    errorText = 'This staging request is assigned to someone and on Pending status. Please make sure your team is not processing its data file. Then you need to change its status to New before you can reassign this request to yourself or someone else.'; 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorText ));               
                }else if(myStgRequest.assigned_to__C!=NULL) {
                    
                    if(!onlyIds.contains(myStgRequest.assigned_to__C)){
                        errorEncountered = TRUE;
                        errorText = 'Assigned Users must be members of the C-Ops Public User Group.'; 
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorText ));
                    } else   myStgRequest.Request_Status__c='Pending';
                }
                else myStgRequest.Request_Status__c='New';
                
            }
        
        }

        
        if(errorEncountered){
            
            return ApexPages.currentPage();
        }
        else{ //all is well, update the record and head on back to the request page 
            
            if(!isStagingRequest){
                
                update myRequest;
                
                PageReference newPage = New PageReference('/' + myRequest.Id);
                newPage.setRedirect(true);
                return newPage;    
            }
            
            else if(isStagingRequest){
                                
                update myStgRequest;
                
                PageReference newPage = New PageReference('/' + myStgRequest.Id);
                newPage.setRedirect(true);
                return newPage;   
            }
        }
        
        return null; 
    }
    
    public pageReference takeMeBack(){
        
        if(!isStagingRequest){
            
            PageReference newPage = New PageReference('/' + myRequest.Id);
            newPage.setRedirect(true);
            return newPage;    
        }
        
        else if(isStagingRequest){
            
            PageReference newPage = new PageReference('/' + myStgRequest.Id); 
            newPage.setRedirect(true); 
            return newPage;
        }
        
        return null;
    }
  
}