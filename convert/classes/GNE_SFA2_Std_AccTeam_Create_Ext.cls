/************************************************************
*  @author: Kaavya Karanam, Genentech
*  Date: 2013-03-25
*  Description: This is a controller extension for GNE_SFA2_Std_AccTeam_Create_Layout page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Std_AccTeam_Create_Ext { 

    public list <AccountTeamMember> teamRecords {get;set;}
    public GNE_SFA2_Std_AccTeam_Create_Ext(ApexPages.StandardController controller)
    {
        teamRecords =new list <AccountTeamMember>();
        teamRecords.add(new AccountTeamMember());
        teamRecords.add(new AccountTeamMember());
        teamRecords.add(new AccountTeamMember());
        teamRecords.add(new AccountTeamMember());
        teamRecords.add(new AccountTeamMember());
        String accountId = ApexPages.currentPage().getParameters().get('objectId');       
        for (AccountTeamMember tm : teamRecords)
        {
            tm.AccountId = accountId;          
        }
    }
    public PageReference cancelRecords() {
        PageReference cancelPage = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));   
        return cancelPage;         
    }
    
    //methods|functions
    public PageReference saveRecords ()
    { 
        List<AccountTeamMember> recordsToBeInserted= new List<AccountTeamMember>();
        Map<String,Boolean> duplicateMap = new Map<String,Boolean>();
        Boolean foundDuplicates = false;
        for (AccountTeamMember tm : teamRecords)
        {
            if(tm.UserId!= null){
                if(duplicateMap.containsKey(tm.UserId)){
                    tm.UserId.addError('Duplicate Values Not Allowed');
                    foundDuplicates = true;
                    continue;                
                }
                duplicateMap.put(tm.UserId,true);
                
                recordsToBeInserted.add(tm);
                if (tm.TeamMemberRole == null || tm.TeamMemberRole == '')
                {
                    System.debug('Inside Loop');
                    tm.TeamMemberRole.addError('You must enter a value');
                    return null;
                }                                
            }
            System.debug('***userId***'+tm.UserId);

        }
        if(foundDuplicates)
        {
            return null;
        }
        System.debug('Records to be inserted' + recordsToBeInserted);
        if(recordsToBeInserted.size() > 0){
            
            try{
            insert recordsToBeInserted;
            }
            catch(Exception e)
            {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
            }
        }
        PageReference returnPage = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));   
        return returnPage;     
    }
    
}