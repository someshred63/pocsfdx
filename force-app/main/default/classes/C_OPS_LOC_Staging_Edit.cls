public class C_OPS_LOC_Staging_Edit {

    public C_Ops_LOC_Request_Staging__C myStgRequest {get; set;}
    private boolean errorEncountered;
    private string  errorText; 
    private string oldStatus;

    public C_OPS_LOC_Staging_Edit(ApexPages.StandardController controller) {
        this.myStgRequest = (C_OPS_LOC_REQUEST_STAGING__C)controller.getRecord(); 
        errorEncountered = false;
        
        myStgRequest = [SELECT id, assigned_to__C, ownerid, Request_Status__c,Request_Status_Comments__c  from C_OPS_LOC_REQUEST_STAGING__C where id =: myStgRequest.ID LIMIT 1]; 
        if(myStgRequest !=null) oldStatus=myStgRequest.Request_Status__c;
    }
    
    public PageReference saveEdit(){
    
        Group g = [SELECT ID from group where name = 'C-Ops User group' LIMIT 1];
        List<GroupMember> confirmedUsers  = [SELECT ID, userOrGroupId from GroupMember where groupId =: g.Id]; 
        
        List<String> onlyIDs = new List<String>(); 
        
        for(groupMember u : confirmedUsers){
            
            onlyIds.add(u.userorgroupid); 
        }
        
        Group c_ops_group;
        c_ops_group = [SELECT name, id from GROUP where name = 'LOC Request Queue' LIMIT 1];
                    
        id queueGroupId = c_ops_group.id; 
        
        //Jie - if assigned user in not in the C-Ops user group, no change can be made to record. Error out.
        if(!onlyIds.contains(UserInfo.getUserId())){                 
                    errorEncountered = TRUE;
                    errorText = 'Only members of the C-Ops User Group may change status of this request. Click Cancel to go back.'; 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorText ));
        }
        else if (oldStatus =='LOC Requests Created') {
                    errorEncountered = TRUE; 
                    errorText = 'This staging request has been processing successfully. No status change can be made to this record. Click Cancel to go back.'; 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorText ));
        } else if (myStgRequest.Request_Status__c =='New') myStgRequest.assigned_to__C=NULL;
        
        if(errorEncountered){            
            return ApexPages.currentPage();
        }else {                               
                update myStgRequest;              
                PageReference newPage = New PageReference('/' + myStgRequest.Id);
                newPage.setRedirect(true);
                return newPage;   
         } 
         
    }
    
    public PageReference cancelEdit () {
        PageReference newPage = new PageReference('/' + myStgRequest.Id); 
        newPage.setRedirect(true);
            return newPage;
    }

}