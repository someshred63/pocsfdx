global without sharing class GNE_Med_iPhone_GetMedAffairs 
{

    /*
    This is a webservice in SFDC that gets the list of MedAffair users (MSLs and MCLs).
    
    Author : Sandeep Kumar
    Created : 25 Jul 2011
    Last Modified : 25 Jul 2011
    Project : gMARS Phase 2
        
    */
    
    static final List<String> profileName = new List<String>{'GNE-MedAffairs-MSL','GNE-MedAffairs-MCL'} ;

     // response 
    global class Response {
        WebService DateTime StartTime = DateTime.now();
        WebService DateTime EndTime   = null;
        WebService String ErrorCode;
        WebService String ErrorMessage;
        WebService List<CallMSLParentRow> callMSLList;
    }
    
    
    global class MSLDetails
    {
        webservice String FirstName;
        webservice String LastName;
        webservice String Id;
        webservice Boolean isActive;
        webservice String Profile;
        webservice List<CallTas> tas;
    }
    
    global class CallMSLRows
    {
        webservice List<CallMSLAdded> added;
        webservice List<CallMSLUpdated> updated;
        webservice String allIds;
    
    }
    
    global class CallMSLParentRow
    {
        webservice List<CallMSLRows> rows;
    }
    
    global class CallMSLAdded
    {
        webservice List<MSLDetails> row;
    }
    
    global class CallMSLUpdated
    {
        webservice List<MSLDetails> row;
    }
    
    global class CallTas
    {
        webservice List<String> ta;
    }
    
    
    //global class CallMSLList
    //{
    //  webservice List<row> added;
    //  webservice List<row> updated;
    //  webservice List<String> allIds; 
    //}
    
    global class CallMSLs 
    {
        WebService DateTime CallDateTime;
    }
    
    
    //returns list of MedAffair users for innitial OR Delta load
    Webservice static Response MedAffairUsers (CallMSLs CallMSLs)
    {
        Response callResponse = new Response(); 
        
        List<MSLDetails> toAdd = new List<MSLDetails>();
        List<MSLDetails> toUpdate = new List<MSLDetails>();
        List<String> allActiveUsers = new List<String>();
        
        
        
        DateTime last_synch_date;
        
        List<Id> profileId = new List<Id>();
        List<Profile> profile = [Select id, Name from Profile where name IN :profileName];
        
        System.debug('ProfileNames: ' + profileName);
        
        try
        {
            if(CallMSLs.CallDateTime!=null)
            {
                last_synch_date = CallMSLs.CallDateTime;
            }
            
        
            //if profiles exists
            If(profile!=null && profile.size()>0)
            {
                for(Profile pr : profile)
                {
                    profileId.add(pr.Id);
                }
            }
            
            //get innitial load : get allusers
            if(last_synch_date == null) 
            {
                Set<Id> UserIds = new Set<Id>();
                
                Map<Id, User> myAllUser = new Map<Id, User>([Select Id, FirstName, LastName, isActive, ProfileId, Profile.Name from User where ProfileId IN :profileId AND isActive = true]); 
            

                    
                //get all Referral Roster / Referral Roster Details for the users
                List<Referral_Roster_gne__c> RefRoster = [Select r.First_Name_gne__c, r.Id, r.Last_Name_gne__c, r.Primary_OR_Secondary_gne__c, r.UnixId_Manager_gne__c, r.UnixId_User_gne__c, r.User_gne__c, 
                (Select Id, Product_TA_SubTA_gne__c, Referral_Roster_gne__c From Referral_Roster_Details__r   )       
                from Referral_Roster_gne__c r where User_gne__c IN : myAllUser.keySet()];
                
                //map userIds to Referral Roster
                Map<Id,Referral_Roster_gne__c> UserToRef = new Map<Id, Referral_Roster_gne__c>();
                if(RefRoster!=null && RefRoster.size()>0)
                {
                    for(Referral_Roster_gne__c rr : RefRoster)
                    {
                        if(rr.User_gne__c!=null)
                            UserToRef.put(rr.User_gne__c, rr);
                    }
                }
                    
                if(RefRoster!=null && RefRoster.size()>0)
                {
                    MSLDetails detAdd = new MSLDetails();
                    for(Referral_Roster_gne__c rr : RefRoster)
                    {
                        if(rr.User_gne__c!=null)
                        {
                            User us = myAllUser.get(rr.User_gne__c);
                            detAdd = new MSLDetails();
                                
                            detAdd = new MSLDetails();
                            detAdd.FirstName = us.FirstName;
                            detAdd.LastName = us.lastName;
                            detAdd.Id = us.Id;
                            detAdd.Profile = getProfileSuffix(us.Profile.Name);
                            detAdd.isActive = us.isActive;
                                
                            detAdd.tas = new List<CallTas>();
                            CallTas lstTas = new CallTas();
                            lstTas.ta = new List<String>();
                            
                            set<Id> setTas = new set<Id>();

                            List<Referral_Roster_Detail_gne__c> refDetail = rr.Referral_Roster_Details__r;
                                
                            if(refDetail!=null && refDetail.size()>0)
                            {
                                for(Referral_Roster_Detail_gne__c rd : refDetail)
                                {
                                    if(rd.Product_TA_SubTA_gne__c!=null && setTas.add(rd.Product_TA_SubTA_gne__c))
                                    {
                                        lstTas.ta.add(rd.Product_TA_SubTA_gne__c);
                                    }
                                }
                            }
                            detAdd.tas.add(lstTas);
                            toAdd.add(detAdd);
                        }
                    }
                }
            }
        
            
            // get delta load : get users that have been updated since last run
            if(last_synch_date!=null) 
            {
                /////////////////Starts get users added since last synch/////////////////////////////////
                toAdd = getCreatedList(profileId, last_synch_date);
                /////////////////Ends get users added since last synch/////////////////////////////////
                
                
                /////////////////Starts get users updated since last synch/////////////////////////////////
                //we do not need to send the updated section as all added or updated MSL roster records will be in the added section
                //toUpdate=getUpdatedList(profileId, last_synch_date); 
                /////////////////Ends get users updated since last synch/////////////////////////////////
                
                
                //get active user list. This list will determine if OTR needs to remove users in OTR that have been deleted(made inactive) in SFDC
                //List<User> myAllUser = [Select Id, FirstName, LastName, isActive, ProfileId, Profile.Name from User where ProfileId IN :profileId AND isActive = true]; 
                List<Referral_Roster_gne__c> myAllUser = [Select Id, User_gne__c from  Referral_Roster_gne__c where User_gne__c IN (Select Id from user where isActive = true AND ProfileId IN :profileId ) ] ;
                //if users exists
                if(myAllUser!=null && myAllUser.size()>0)
                {
                    for(Referral_Roster_gne__c us : myAllUser)
                    {
                        allActiveUsers.add(us.User_gne__c);
                    }
                }
            }
            
            CallMSLRows CallMSLRows = new CallMSLRows();

            CallMSLRows.added = new List<CallMSLAdded>();
            CallMSLAdded CallMSLAdded = new CallMSLAdded();
            CallMSLAdded.row = toAdd;
            CallMSLRows.added.add(CallMSLAdded);
            
            
            CallMSLRows.updated = new List<CallMSLUpdated>();
            CallMSLUpdated CallMSLUpdated = new CallMSLUpdated();
            CallMSLUpdated.row = toUpdate;
            CallMSLRows.updated.add(CallMSLUpdated);
        
            String joinAllIds = '';
            if(allActiveUsers!=null && allActiveUsers.size()>0)
            {
                for(String str : allActiveUsers)
                {
                    joinAllIds = joinAllIds + str + ',';
                }
                 
                Integer lastIndex = joinAllIds.lastIndexOf(',');
                if(lastIndex!=null && lastIndex!=-1)
                {
                    joinAllIds = joinAllIds.substring(0, lastIndex);
                }
            }
                    
            System.debug('AllIds length : ' + String.valueOf(allActiveUsers.size()) );
            CallMSLRows.allIds = joinAllIds;
            
            callResponse.callMSLList = new List<callMSLParentRow>();
            
            callMSLParentRow cpr = new callMSLParentRow();
            cpr.rows = new List<CallMSLRows>();
            cpr.rows.add(CallMSLRows);
            
            callResponse.callMSLList.add(cpr);
            
            
            //callResponse.ErrorMessage = 'hello no result';
            callResponse.EndTime = DateTime.now();
            
            System.debug('ResponseHere : ' + String.valueOf(callResponse));
            
            return callResponse;
        }
        catch(Exception ex)
        {
            callResponse.EndTime = DateTime.now();
            //callResponse.ErrorCode = 
            callResponse.ErrorMessage = ex.getMessage();
            callResponse.callMSLList = new List<callMSLParentRow>();
            return callResponse;
        }
        
        
    }
    
    static String getProfileSuffix(String val)
    {
        if(val!=null && val.contains('MSL-Manager'))
            return 'MSL Manager';
        else if(val!=null && val.contains('-MSL'))
            return 'MSL';
        else if(val!=null && val.contains('MCL-Manager'))
            return 'MCL Manager';
        else if(val!=null && val.contains('-MCL'))
            return 'MCL';
        else if(val!=null && val.contains('SP-Manager'))
            return 'SP Manager';
        else if(val!=null && val.contains('-SP'))
            return 'SP';
        else if(val!=null && val.contains('TISL-Manager'))
            return 'TISL MAnager';
        else if(val!=null && val.contains('-TISL'))
            return 'TISL';
        else
            return null;
    }
    
    
    //gets the MSL Roster list that is created or updated since last synch
    static List<MSLDetails> getCreatedList(List<Id> profileId, DateTime last_synch_date)
    {
        List<MSLDetails> toAdd = new List<MSLDetails>();
        
        //get list of active users in sfdc
        List<Referral_Roster_gne__c> lstUserRef = [Select id, User_gne__c  from Referral_Roster_gne__c];
        set<String> setUsR = new set<String>();
        if(lstUserRef!=null && lstUserRef.size()>0)
        {
            for(Referral_Roster_gne__c ur : lstUserRef)
            {
                setUsR.add(ur.User_gne__c);
            }
        }
        
        List<User> myUser = [Select Id, isActive from User where isActive = true AND Id IN :setUsR AND ( (createdDate >= :last_synch_date ) OR (CreatedDate < :last_synch_date AND LastModifiedDate >= :last_synch_date) )]; 
                
        List<Referral_Roster_gne__c> myRef = [Select Id, User_gne__c from Referral_Roster_gne__c where User_gne__r.isActive = true AND ( (createdDate >= :last_synch_date ) OR (CreatedDate < :last_synch_date AND LastModifiedDate >= :last_synch_date) )];

        List<Referral_Roster_Detail_gne__c> myRefDet = [Select Id, Product_TA_SubTA_gne__c, Referral_Roster_gne__c from Referral_Roster_Detail_gne__c where ( (createdDate >= :last_synch_date ) OR (CreatedDate < :last_synch_date AND LastModifiedDate >= :last_synch_date) )];
        
        Set<Id> setUserId = new Set<Id>();
        Set<Id> setRef = new Set<Id>();
        set<Id> setRefDet = new Set<Id>();
        if(myRefDet!=null && myRefDet.size()>0)
        {
            for(Referral_Roster_Detail_gne__c rd : myRefDet)
            {
                setRefDet.add(rd.Referral_Roster_gne__c);
            }
        }
            
        if(myRef!=null && myRef.size()>0)
        {
            for(Referral_Roster_gne__c rr : myRef)
            {
                setRefDet.add(rr.Id);
            }
        }
            
        if(myUser!=null && myUser.size()>0)
        {
            for(User us : myUser)
            {
                setUserId.add(us.Id);
            }
        }
    
        //get list of Referral Rosters updated since last synch for active users in sfdc
        List<Referral_Roster_gne__c> RefRoster = [Select Id, First_Name_gne__c, Last_Name_gne__c, Primary_OR_Secondary_gne__c, UnixId_Manager_gne__c, UnixId_User_gne__c, User_gne__c, 
                                                    User_gne__r.FirstName, User_gne__r.Id, User_gne__r.IsActive, User_gne__r.LastName, User_gne__r.ProfileId, User_gne__r.Profile.Name,
                                                    (Select Id, Product_TA_SubTA_gne__c, Referral_Roster_gne__c From Referral_Roster_Details__r ) from Referral_Roster_gne__c r where User_gne__r.IsActive = true AND (User_gne__c IN : setUserId OR Id IN :setRefDet ) ];
        
        
        if(RefRoster!=null && RefRoster.size()>0)
        {
            MSLDetails detAdd = new MSLDetails();
            //create User detail list
            for(Referral_Roster_gne__c rr : RefRoster)
            {
                User user = rr.User_gne__r;
                List<Referral_Roster_Detail_gne__c> RefDetail = rr.Referral_Roster_Details__r;
                set<Id> setTas = new set<Id>();
                
                detAdd = new MSLDetails();
                detAdd.FirstName = user.FirstName;
                detAdd.LastName = user.lastName;
                detAdd.Id = user.Id;
                detAdd.isActive = user.isActive;
                detAdd.Profile = getProfileSuffix(user.Profile.Name);
                
                detAdd.tas = new List<CallTas>();
                CallTas lstTas = new CallTas();
                lstTas.ta = new List<String>();
                
                if(RefDetail!=null && RefDetail.size()>0)
                {
                    for(Referral_Roster_Detail_gne__c rd : RefDetail)
                    {
                        if(rd.Product_TA_SubTA_gne__c!=null && setTas.add(rd.Product_TA_SubTA_gne__c))
                        {
                            lstTas.ta.add(rd.Product_TA_SubTA_gne__c);
                        }
                    }
                }
                detAdd.tas.add(lstTas);
                toAdd.add(detAdd);
            }
        }
        return toAdd;
    }
    
    
    
    /*
    static List<MSLDetails> getUpdatedList(List<Id> profileId, DateTime last_synch_date)
    {
        List<MSLDetails> toAdd = new List<MSLDetails>();
        
        //get list of active users in sfdc
        List<Referral_Roster_gne__c> lstUserRef = [Select id, User_gne__c  from Referral_Roster_gne__c];
        set<String> setUsR = new set<String>();
        if(lstUserRef!=null && lstUserRef.size()>0)
        {
            for(Referral_Roster_gne__c ur : lstUserRef)
            {
                setUsR.add(ur.User_gne__c);
            }
        }
        
        List<User> myUser = [Select Id, isActive from User where  isActive = true AND Id IN :setUsR AND CreatedDate < :last_synch_date AND LastModifiedDate >= :last_synch_date]; 
                
        List<Referral_Roster_gne__c> myRef = [Select Id, User_gne__c from Referral_Roster_gne__c where  User_gne__r.isActive = true AND User_gne__r.ProfileId IN :profileId AND CreatedDate < :last_synch_date AND LastModifiedDate >= :last_synch_date];

        List<Referral_Roster_Detail_gne__c> myRefDet = [Select Id, Product_TA_SubTA_gne__c, Referral_Roster_gne__c from Referral_Roster_Detail_gne__c where CreatedDate < :last_synch_date AND LastModifiedDate >= :last_synch_date];
       
        Set<Id> setUserId = new Set<Id>();
        Set<Id> setRef = new Set<Id>();
        set<Id> setRefDet = new Set<Id>();
        if(myRefDet!=null && myRefDet.size()>0)
        {
            for(Referral_Roster_Detail_gne__c rd : myRefDet)
            {
                setRefDet.add(rd.Referral_Roster_gne__c);
            }
        }
            
        if(myRef!=null && myRef.size()>0)
        {
            for(Referral_Roster_gne__c rr : myRef)
            {
                setRefDet.add(rr.Id);
            }
        }
            
        if(myUser!=null && myUser.size()>0)
        {
            for(User us : myUser)
            {
                setUserId.add(us.Id);
            }
        }
        
        //if(myRef!=null && myRef.size()>0)
        //{
        //  for(Referral_Roster_gne__c rr : myRef)
        //  {
        //      if(rr.User_gne__c!=null)
        //  {
        //      setUserId.add(rr.User_gne__c);
        //      }
        //  }
        //}
        
         //get list of Referral Rosters updated since last synch for active users in sfdc
        List<Referral_Roster_gne__c> RefRoster = [Select Id, First_Name_gne__c, Last_Name_gne__c, Primary_OR_Secondary_gne__c, UnixId_Manager_gne__c, UnixId_User_gne__c, User_gne__c, 
                                                    User_gne__r.FirstName, User_gne__r.Id, User_gne__r.IsActive, User_gne__r.LastName, User_gne__r.ProfileId, User_gne__r.Profile.Name,
                                                    (Select Id, Product_TA_SubTA_gne__c, Referral_Roster_gne__c From Referral_Roster_Details__r ) from Referral_Roster_gne__c r  where User_gne__r.isActive = true AND (User_gne__c IN : setUserId OR Id IN :setRefDet ) ];
        
        
        if(RefRoster!=null && RefRoster.size()>0)
        {
            MSLDetails detAdd = new MSLDetails();
            //create User detail list
            for(Referral_Roster_gne__c rr : RefRoster)
            {
                User user = rr.User_gne__r;
                List<Referral_Roster_Detail_gne__c> RefDetail = rr.Referral_Roster_Details__r;
                set<Id> setTas = new set<Id>();
                
                detAdd = new MSLDetails();
                detAdd.FirstName = user.FirstName;
                detAdd.LastName = user.lastName;
                detAdd.Id = user.Id;
                detAdd.isActive = user.isActive;
                detAdd.Profile = getProfileSuffix(user.Profile.Name);
                
                detAdd.tas = new List<CallTas>();
                CallTas lstTas = new CallTas();
                lstTas.ta = new List<String>();
                
                if(RefDetail!=null && RefDetail.size()>0)
                {
                    for(Referral_Roster_Detail_gne__c rd : RefDetail)
                    {
                        if(rd.Product_TA_SubTA_gne__c!=null && setTas.add(rd.Product_TA_SubTA_gne__c))
                        {
                            lstTas.ta.add(rd.Product_TA_SubTA_gne__c);
                        }
                    }
                }
                detAdd.tas.add(lstTas);
                toAdd.add(detAdd);
            }
        }
        return toAdd;
    }
    */
}