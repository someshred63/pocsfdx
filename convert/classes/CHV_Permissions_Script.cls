public class CHV_Permissions_Script{
   
    public static void applyPermissionSet(){
   
        /* Permission Set Assignment List */
        List<PermissionSetAssignment> PSA = new List<PermissionSetAssignment>();
        Integer assignmnetCount = 0;
                
        Map<String, String> Permissions = new Map<String, String>();

		Permissions.put('aderj','CHV_View_All_PS');
		Permissions.put('mash','CHV_View_All_PS');
		Permissions.put('vasher','CHV_View_All_PS');
		Permissions.put('bobbaer','CHV_View_All_PS');
		Permissions.put('bakerp1','CHV_View_All_PS');
		Permissions.put('jeffrbak','CHV_View_All_PS');
		Permissions.put('lisetteb','CHV_View_All_PS');
		Permissions.put('barhoumd','CHV_View_All_PS');
		Permissions.put('giandom','CHV_View_All_PS');
		Permissions.put('jbennett','CHV_View_All_PS');
		Permissions.put('tbenson','CHV_View_All_PS');
		Permissions.put('sharonkc','CHV_View_All_PS');
		Permissions.put('jbren','CHV_View_All_PS');
		Permissions.put('jennydb','CHV_View_All_PS');
		Permissions.put('vbrown','CHV_View_All_PS');
		Permissions.put('sbrusky','CHV_View_All_PS');
		Permissions.put('lcarman','CHV_View_All_PS');
		Permissions.put('christk2','CHV_View_All_PS');
		Permissions.put('coel','CHV_View_All_PS');
		Permissions.put('lcombs','CHV_View_All_PS');
		Permissions.put('lcover','CHV_View_All_PS');
		Permissions.put('saskia','CHV_View_All_PS');
		Permissions.put('cutlers','CHV_View_All_PS');
		Permissions.put('kdaniusi','CHV_View_All_PS');
		Permissions.put('jdemello','CHV_View_All_PS');
		Permissions.put('deroiad','CHV_View_All_PS');
		Permissions.put('dimaiom','CHV_View_All_PS');
		Permissions.put('dipietrd','CHV_View_All_PS');
		Permissions.put('ccrews','CHV_View_All_PS');
		Permissions.put('markmd','CHV_View_All_PS');
		Permissions.put('bfailing','CHV_View_All_PS');
		Permissions.put('farnumj','CHV_View_All_PS');
		Permissions.put('rmini','CHV_View_All_PS');
		Permissions.put('afranco','CHV_View_All_PS');
		Permissions.put('froniur1','CHV_View_All_PS');
		Permissions.put('ggerold','CHV_View_All_PS');
		Permissions.put('gilljaij','CHV_View_All_PS');
		Permissions.put('gilmoret','CHV_View_All_PS');
		Permissions.put('jewelg','CHV_View_All_PS');
		Permissions.put('cgraham','CHV_View_All_PS');
		Permissions.put('dgraham','CHV_View_All_PS');
		Permissions.put('mgreene','CHV_View_All_PS');
		Permissions.put('twylag','CHV_View_All_PS');
		Permissions.put('haugerm','CHV_View_All_PS');
		Permissions.put('bhedberg','CHV_View_All_PS');
		Permissions.put('heintzj','CHV_View_All_PS');
		Permissions.put('hentgesj','CHV_View_All_PS');
		Permissions.put('hilemanm','CHV_View_All_PS');
		Permissions.put('brianbh','CHV_View_All_PS');
		Permissions.put('hoskins','CHV_View_All_PS');
		Permissions.put('davidlh','CHV_View_All_PS');
		Permissions.put('marissai','CHV_View_All_PS');
		Permissions.put('shantik','CHV_View_All_PS');
		Permissions.put('kofald','CHV_View_All_PS');
		Permissions.put('kryzanj','CHV_View_All_PS');
		Permissions.put('bhavnak','CHV_View_All_PS');
		Permissions.put('lagasseg','CHV_View_All_PS');
		Permissions.put('landryc','CHV_View_All_PS');
		Permissions.put('mlanning','CHV_View_All_PS');
		Permissions.put('slasorsa','CHV_View_All_PS');
		Permissions.put('blaw','CHV_View_All_PS');
		Permissions.put('lohrers','CHV_View_All_PS');
		Permissions.put('mlowe','CHV_View_All_PS');
		Permissions.put('nancyem','CHV_View_All_PS');
		Permissions.put('vmos','CHV_View_All_PS');
		Permissions.put('jonm','CHV_View_All_PS');
		Permissions.put('richarjm','CHV_View_All_PS');
		Permissions.put('mchughm1','CHV_View_All_PS');
		Permissions.put('millerm1','CHV_View_All_PS');
		Permissions.put('molettif','CHV_View_All_PS');
		Permissions.put('catherim','CHV_View_All_PS');
		Permissions.put('tamaralm','CHV_View_All_PS');
		Permissions.put('lmoore','CHV_View_All_PS');
		Permissions.put('novelloj','CHV_View_All_PS');
		Permissions.put('odonnelt','CHV_View_All_PS');
		Permissions.put('osmulskp','CHV_View_All_PS');
		Permissions.put('adriennm','CHV_View_All_PS');
		Permissions.put('pfolsgrj','CHV_View_All_PS');
		Permissions.put('mphelan','CHV_View_All_PS');
		Permissions.put('dusti','CHV_View_All_PS');
		Permissions.put('mprygoda','CHV_View_All_PS');
		Permissions.put('pylep','CHV_View_All_PS');
		Permissions.put('mujeeb','CHV_View_All_PS');
		Permissions.put('rajaramv','CHV_View_All_PS');
		Permissions.put('mriese','CHV_View_All_PS');
		Permissions.put('rodgersr','CHV_View_All_PS');
		Permissions.put('grumb','CHV_View_All_PS');
		Permissions.put('kfabros','CHV_View_All_PS');
		Permissions.put('roberjsa','CHV_View_All_PS');
		Permissions.put('santoj37','CHV_View_All_PS');
		Permissions.put('sariskys','CHV_View_All_PS');
		Permissions.put('wsawicki','CHV_View_All_PS');
		Permissions.put('aishas','CHV_View_All_PS');
		Permissions.put('gschneid','CHV_View_All_PS');
		Permissions.put('jonathrs','CHV_View_All_PS');
		Permissions.put('shahsri','CHV_View_All_PS');
		Permissions.put('sheehaj1','CHV_View_All_PS');
		Permissions.put('kens','CHV_View_All_PS');
		Permissions.put('lisads','CHV_View_All_PS');
		Permissions.put('sonin','CHV_View_All_PS');
		Permissions.put('stephrst','CHV_View_All_PS');
		Permissions.put('msuto','CHV_View_All_PS');
		Permissions.put('dorothyu','CHV_View_All_PS');
		Permissions.put('vershure','CHV_View_All_PS');
		Permissions.put('pamelama','CHV_View_All_PS');
		Permissions.put('audrey','CHV_View_All_PS');
		Permissions.put('deepav','CHV_View_All_PS');
		Permissions.put('mwatrous','CHV_View_All_PS');
		Permissions.put('jweise','CHV_View_All_PS');
		Permissions.put('womblek','CHV_View_All_PS');
		Permissions.put('jamesy','CHV_View_All_PS');
		Permissions.put('zymowski','CHV_View_All_PS');
  
      
        
        /* Permission Set Name, ID Map */
        List<PermissionSet> Perm = [select Name, id from PermissionSet where Name = 'CHV_Super_User_PS' Or Name = 'CHV_View_All_PS' Or Name = 'CHV_View_Limited_PS'];
        Map<String, String> AllPermissionSets = new Map<String, String>();
        
        for(PermissionSet a : Perm){
           AllPermissionSets.put(a.Name,a.id);
        }
        
        /* Permissions User List */
        Set <String> AllUsers = new Set<String>();
        AllUsers = Permissions.keySet();
         
        
          
        /* Please Note : 2 Checks Made in the loop below. 
           a) If a UserName / UserId is not found in the User table, the record will be skipped.
           b) If a user is already assigned to the respective Permission Set, a second assignment request will be skipped.
        */
            
        List<User> UserId = [select id, External_ID_gne__c from User where External_ID_gne__c in : AllUsers and isActive = true];
        List<PermissionSetAssignment> PermAssignments = [select AssigneeId from PermissionSetAssignment where AssigneeId in : UserId and PermissionSetId in : Perm];
  
        Map<String, String> SelectAssignmnets = new Map<String, String>();
  
      	for(PermissionSetAssignment a : PermAssignments){
           SelectAssignmnets.put(a.AssigneeId,'true');
        }
 
            
        if(!UserID.isEmpty())
        {
            for(User i : UserId){
                if(SelectAssignmnets.get(i.id) == null){
                    PSA.add(new PermissionSetAssignment(AssigneeId = i.id, PermissionSetId = AllPermissionSets.get(Permissions.get(i.External_ID_gne__c))));
                }
            }
        }
       
        try {
           insert PSA;
        } catch (DmlException e) {
            System.debug('Error Processing The Permission Set Assginment' + e);
            // Process exception here 
        }

        System.debug('Apply Permission Set');
 }
    
    
    
    public static void applyPublicGroups(){
        /* Permission Set Assignment List */
        List<GroupMember> GA = new List<GroupMember>();
        
        Integer assignmnetCount = 0;
                
        Map<String, String> GroupAssignments = new Map<String, String>();

		GroupAssignments.put('aderj','CHV_View_All_Group');
		GroupAssignments.put('mash','CHV_View_All_Group');
		GroupAssignments.put('vasher','CHV_View_All_Group');
		GroupAssignments.put('bobbaer','CHV_View_All_Group');
		GroupAssignments.put('bakerp1','CHV_View_All_Group');
		GroupAssignments.put('jeffrbak','CHV_View_All_Group');
		GroupAssignments.put('lisetteb','CHV_View_All_Group');
		GroupAssignments.put('barhoumd','CHV_View_All_Group');
		GroupAssignments.put('giandom','CHV_View_All_Group');
		GroupAssignments.put('jbennett','CHV_View_All_Group');
		GroupAssignments.put('tbenson','CHV_View_All_Group');
		GroupAssignments.put('sharonkc','CHV_View_All_Group');
		GroupAssignments.put('jbren','CHV_View_All_Group');
		GroupAssignments.put('jennydb','CHV_View_All_Group');
		GroupAssignments.put('vbrown','CHV_View_All_Group');
		GroupAssignments.put('sbrusky','CHV_View_All_Group');
		GroupAssignments.put('lcarman','CHV_View_All_Group');
		GroupAssignments.put('christk2','CHV_View_All_Group');
		GroupAssignments.put('coel','CHV_View_All_Group');
		GroupAssignments.put('lcombs','CHV_View_All_Group');
		GroupAssignments.put('lcover','CHV_View_All_Group');
		GroupAssignments.put('saskia','CHV_View_All_Group');
		GroupAssignments.put('cutlers','CHV_View_All_Group');
		GroupAssignments.put('kdaniusi','CHV_View_All_Group');
		GroupAssignments.put('jdemello','CHV_View_All_Group');
		GroupAssignments.put('deroiad','CHV_View_All_Group');
		GroupAssignments.put('dimaiom','CHV_View_All_Group');
		GroupAssignments.put('dipietrd','CHV_View_All_Group');
		GroupAssignments.put('ccrews','CHV_View_All_Group');
		GroupAssignments.put('markmd','CHV_View_All_Group');
		GroupAssignments.put('bfailing','CHV_View_All_Group');
		GroupAssignments.put('farnumj','CHV_View_All_Group');
		GroupAssignments.put('rmini','CHV_View_All_Group');
		GroupAssignments.put('afranco','CHV_View_All_Group');
		GroupAssignments.put('froniur1','CHV_View_All_Group');
		GroupAssignments.put('ggerold','CHV_View_All_Group');
		GroupAssignments.put('gilljaij','CHV_View_All_Group');
		GroupAssignments.put('gilmoret','CHV_View_All_Group');
		GroupAssignments.put('jewelg','CHV_View_All_Group');
		GroupAssignments.put('cgraham','CHV_View_All_Group');
		GroupAssignments.put('dgraham','CHV_View_All_Group');
		GroupAssignments.put('mgreene','CHV_View_All_Group');
		GroupAssignments.put('twylag','CHV_View_All_Group');
		GroupAssignments.put('haugerm','CHV_View_All_Group');
		GroupAssignments.put('bhedberg','CHV_View_All_Group');
		GroupAssignments.put('heintzj','CHV_View_All_Group');
		GroupAssignments.put('hentgesj','CHV_View_All_Group');
		GroupAssignments.put('hilemanm','CHV_View_All_Group');
		GroupAssignments.put('brianbh','CHV_View_All_Group');
		GroupAssignments.put('hoskins','CHV_View_All_Group');
		GroupAssignments.put('davidlh','CHV_View_All_Group');
		GroupAssignments.put('marissai','CHV_View_All_Group');
		GroupAssignments.put('shantik','CHV_View_All_Group');
		GroupAssignments.put('kofald','CHV_View_All_Group');
		GroupAssignments.put('kryzanj','CHV_View_All_Group');
		GroupAssignments.put('bhavnak','CHV_View_All_Group');
		GroupAssignments.put('lagasseg','CHV_View_All_Group');
		GroupAssignments.put('landryc','CHV_View_All_Group');
		GroupAssignments.put('mlanning','CHV_View_All_Group');
		GroupAssignments.put('slasorsa','CHV_View_All_Group');
		GroupAssignments.put('blaw','CHV_View_All_Group');
		GroupAssignments.put('lohrers','CHV_View_All_Group');
		GroupAssignments.put('mlowe','CHV_View_All_Group');
		GroupAssignments.put('nancyem','CHV_View_All_Group');
		GroupAssignments.put('vmos','CHV_View_All_Group');
		GroupAssignments.put('jonm','CHV_View_All_Group');
		GroupAssignments.put('richarjm','CHV_View_All_Group');
		GroupAssignments.put('mchughm1','CHV_View_All_Group');
		GroupAssignments.put('millerm1','CHV_View_All_Group');
		GroupAssignments.put('molettif','CHV_View_All_Group');
		GroupAssignments.put('catherim','CHV_View_All_Group');
		GroupAssignments.put('tamaralm','CHV_View_All_Group');
		GroupAssignments.put('lmoore','CHV_View_All_Group');
		GroupAssignments.put('novelloj','CHV_View_All_Group');
		GroupAssignments.put('odonnelt','CHV_View_All_Group');
		GroupAssignments.put('osmulskp','CHV_View_All_Group');
		GroupAssignments.put('adriennm','CHV_View_All_Group');
		GroupAssignments.put('pfolsgrj','CHV_View_All_Group');
		GroupAssignments.put('mphelan','CHV_View_All_Group');
		GroupAssignments.put('dusti','CHV_View_All_Group');
		GroupAssignments.put('mprygoda','CHV_View_All_Group');
		GroupAssignments.put('pylep','CHV_View_All_Group');
		GroupAssignments.put('mujeeb','CHV_View_All_Group');
		GroupAssignments.put('rajaramv','CHV_View_All_Group');
		GroupAssignments.put('mriese','CHV_View_All_Group');
		GroupAssignments.put('rodgersr','CHV_View_All_Group');
		GroupAssignments.put('grumb','CHV_View_All_Group');
		GroupAssignments.put('kfabros','CHV_View_All_Group');
		GroupAssignments.put('roberjsa','CHV_View_All_Group');
		GroupAssignments.put('santoj37','CHV_View_All_Group');
		GroupAssignments.put('sariskys','CHV_View_All_Group');
		GroupAssignments.put('wsawicki','CHV_View_All_Group');
		GroupAssignments.put('aishas','CHV_View_All_Group');
		GroupAssignments.put('gschneid','CHV_View_All_Group');
		GroupAssignments.put('jonathrs','CHV_View_All_Group');
		GroupAssignments.put('shahsri','CHV_View_All_Group');
		GroupAssignments.put('sheehaj1','CHV_View_All_Group');
		GroupAssignments.put('kens','CHV_View_All_Group');
		GroupAssignments.put('lisads','CHV_View_All_Group');
		GroupAssignments.put('sonin','CHV_View_All_Group');
		GroupAssignments.put('stephrst','CHV_View_All_Group');
		GroupAssignments.put('msuto','CHV_View_All_Group');
		GroupAssignments.put('dorothyu','CHV_View_All_Group');
		GroupAssignments.put('vershure','CHV_View_All_Group');
		GroupAssignments.put('pamelama','CHV_View_All_Group');
		GroupAssignments.put('audrey','CHV_View_All_Group');
		GroupAssignments.put('deepav','CHV_View_All_Group');
		GroupAssignments.put('mwatrous','CHV_View_All_Group');
		GroupAssignments.put('jweise','CHV_View_All_Group');
		GroupAssignments.put('womblek','CHV_View_All_Group');
		GroupAssignments.put('jamesy','CHV_View_All_Group');
		GroupAssignments.put('zymowski','CHV_View_All_Group');


        
        /* Group Name, ID Map */
        List<Group> grp = [select Name, id from Group where Name = 'CHV_Super_User_Group' Or Name = 'CHV_View_All_Group' Or Name = 'CHV_View_Limited_Group'];
        Map<String, String> AllGroups = new Map<String, String>();
        
        for(Group a : grp){
           AllGroups.put(a.Name,a.id);
        }
        
        /* Permissions User List */
        Set <String> AllUsers = new Set<String>();
        AllUsers = GroupAssignments.keySet();
       
       
        
        /* Please Note : 2 Checks Made in the loop below. 
           a) If a UserName / UserId is not found in the User table, the record will be skipped.
           b) If a user is already assigned to the respective Group, a second assignment request will be skipped.
        */
            
        List<User> UserId = [select id, External_ID_gne__c from User where External_ID_gne__c in : AllUsers and isActive = true];
 		List<GroupMember> grpAssignments = [select UserOrGroupId from GroupMember where UserOrGroupId in : UserId and GroupId in : grp];
  
        Map<String, String> SelectMembers = new Map<String, String>();
  
      	for(GroupMember a : grpAssignments){
           SelectMembers.put(a.UserOrGroupId,'true');
        }
      
        if(!UserID.isEmpty())
        {
            for(User i : UserId){
                if(SelectMembers.get(i.id) == null){
                    GA.add(new GroupMember(UserOrGroupId = i.id, GroupId = AllGroups.get(GroupAssignments.get(i.External_ID_gne__c))));
                }
            }
        }
        
        try {
           insert GA;
        } catch (DmlException e) {
            System.debug('Error Processing The Group Assginment' + e);
            // Process exception here 

        }
        
        System.debug('Apply Public Group');
    }
}