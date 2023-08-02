public with sharing class CMT_Event_Summary_Controller
{
    private ApexPages.StandardController controller;
    private String agendaSortExp = 'CreatedDate'; //default sorting field for agenda related list
    private String agendaSortDirection = 'ASC';   //default sorting order for agenda related list
    private String gAgendaSortExp = 'CreatedDate'; //default sorting field for global agenda related list
    private String gAgendaSortDirection = 'ASC';   //default sorting order for global agenda related list
    private CMT_Meeting_gne__c currentMeeting; 
    public List<CMT_FranchiseToSession_gne__c> result { get; set; }
    public List<CMT_Franchise_gne__c> franchisesList {get; set;}
    public List<ResultWrapper> items { get; set; }
    public List<GlobalAgendaWrapper> gAitems {get; set;}
    public String meetingId { get; set; }
    public String redirectId { get; set; }
    public Boolean addInfo {get; set;}
    public Boolean addParking { get; private set; }
    public List<CMT_Information_gne__c> infos {get; set;}
    public String meetingTag {get; set;}
    public String environment {get; set;}
    public String message {get; set;}
    public String response {get; set;}
    
    // Tells whether adding more meet green objects is allowed for this meeting
    public Boolean isAddingMeetGreenPossible
    {
        get
        {
            CMT_Meeting_gne__c meeting = (CMT_Meeting_gne__c)controller.getRecord();
            // adding meet greens is possible only when there are none
            return meeting != null && (meeting.Meet_Greens__r == null || meeting.Meet_Greens__r.isEmpty());
        }
    }
    
    // Tells whether adding more shuttle objects is allowed for this meeting
    public Boolean isAddingShuttlePossible
    {
        get
        {
            CMT_Meeting_gne__c meeting = (CMT_Meeting_gne__c)controller.getRecord();
            // adding shuttle is possible only when there are not more than two already added
            return meeting != null && (meeting.Shuttles__r == null || meeting.Shuttles__r.size() < 2);
        }
    }
    
    public CMT_Event_Summary_Controller(ApexPages.StandardController controller) {
        this.controller = controller;
        
        // get current record
        currentMeeting = (CMT_Meeting_gne__c)controller.getRecord();
        getFranchises();
        
        addParking = true;
        
        if (currentMeeting != null)
        {
            result = [Select Franchise_gne__r.Name, 
                Session_gne__r.Start_Time_gne__c, Session_gne__r.End_Time_gne__c, 
                Session_gne__r.Location_gne__c, Session_gne__r.Room_Name_gne__c, Session_gne__r.Name, Session_gne__r.Description_gne__c, Session_gne__r.Id
                from CMT_FranchiseToSession_gne__c where Agenda_gne__r.Meeting_gne__c = :currentMeeting.Id];
            items = wrapResults(result);
            gAitems = wrapGresults();
            
            infos = new List<CMT_Information_gne__c>();
            infos = [Select Id from CMT_Information_gne__c where Meeting_gne__c =: currentMeeting.Id];
            if (infos.size()==0)
            {
                addInfo = true;
            }
            else
            {
                addInfo = false;
            }
            
            // parkings can be added only if none exist yet
            addParking = (currentMeeting.Parkings__r == null || currentMeeting.Parkings__r.isEmpty());
        }
        
        // fetch some collections which will be used
        //initCollections(currentMeeting);
    }
    
    public PageReference sendMessage()
    {
        if(message == '' || meetingTag == '' || environment == '')
        {
            response = 'Error: Message, Meeting Tag and Environment are required';
        }
        else
        {
            
            String url = 'http://commmtgs.appspot.com/send.html?message=' + Encodingutil.urlEncode(message, 'UTF-8') + '&tag=' + Encodingutil.urlEncode(meetingTag , 'UTF-8')+ '&env=' + Encodingutil.urlEncode(environment, 'UTF-8');
            Http http = new Http();
            Httprequest req = new Httprequest();    
            req.setMethod('GET');
            req.setEndpoint(url);
            Httpresponse resp = http.send(req);
            response = resp.getBody();
        }
        return null;
    }
    public PageReference initMeetingSummary()
    {
        meetingId = System.currentPageReference().getParameters().get('id');
        return null;
    }
    
    
    private List<CMT_Franchise_gne__c> getFranchises()
    {
        PageReference currentPageRef = System.currentPageReference();
        String meetingId = currentPageRef.getParameters().get('id');
        franchisesList = [Select Id, Name from CMT_Franchise_gne__c where Meeting_gne__c =: meetingId];
        return franchisesList;
    }
    private List<GlobalAgendaWrapper> wrapGresults()
    {
        PageReference currentPageRef = System.currentPageReference();
        String meetingId = currentPageRef.getParameters().get('id');
        List<CMT_FranchiseToSession_gne__c> allResults = [Select Franchise_gne__r.Name, 
                Session_gne__r.Start_Time_gne__c, Session_gne__r.End_Time_gne__c, 
                Session_gne__r.Location_gne__c, Session_gne__r.Room_Name_gne__c, Session_gne__r.Name, Session_gne__r.Description_gne__c, Session_gne__r.Id
                from CMT_FranchiseToSession_gne__c where Meeting_gne__c =: meetingId];
        gAitems = new List<GlobalAgendaWrapper>();
        Map<CMT_Session_gne__c, Set<String>> franchisesPerSession = new  Map<CMT_Session_gne__c, Set<String>>();
        
        for(CMT_FranchiseToSession_gne__c fts : allResults)
        {
            if(!franchisesPerSession.containsKey(fts.Session_gne__r))
            {
                franchisesPerSession.put(fts.Session_gne__r, new Set<String>());
            }
            franchisesPerSession.get(fts.Session_gne__r).add(fts.Franchise_gne__r.Name);
        }
        
       for(CMT_Session_gne__c sess : franchisesPerSession.keyset())
       {
            String tempFran ='';
            if(franchisesPerSession.get(sess).size() >  1 && sess != null)
            {
                GlobalAgendaWrapper gItem = new GlobalAgendaWrapper();
                gItem.gSessionName = sess.Name;
                if(sess.Start_Time_gne__c != null)
                {
                    gItem.gStartTime = sess.Start_Time_gne__c.format('MM/dd/yyyy hh:mm a', 'GMT'); 
                }
                if(sess.End_Time_gne__c != null)
                {
                    gItem.gEndTime = sess.End_Time_gne__c.format('MM/dd/yyyy hh:mm a', 'GMT'); 
                }
                gItem.gSessionId = sess.Id;
                gItem.gLocation = sess.Location_gne__c;
                gItem.gRoomName = sess.Room_Name_gne__c;
                gItem.gDescription = sess.Description_gne__c;
                for(String fran : franchisesPerSession.get(sess))
                {
                    tempFran += fran+', ';
                }
                Integer lastComa = tempFran.lastIndexOf(',');
                tempFran = tempFran.trim();
                gItem.gFranchises = tempFran.substring(0, lastComa);
                gAitems.add(gItem);
            }
       }
       return gAitems;
        
    }
    private List<ResultWrapper> wrapResults(List<CMT_FranchiseToSession_gne__c> results) {
        items = new List<ResultWrapper>();
        for (CMT_FranchiseToSession_gne__c res : results) {
            ResultWrapper item = new ResultWrapper();
            if (res.Franchise_gne__r.Name != null) {
                item.franchiseName = res.Franchise_gne__r.Name; 
            }
            if (res.Session_gne__r.Name != null) {
                item.sessionName = res.Session_gne__r.Name; 
            }
            if (res.Session_gne__r.Start_Time_gne__c != null)
            {
                item.startTime = res.Session_gne__r.Start_Time_gne__c.format('MM/dd/yyyy hh:mm a','GMT'); 
            }
            if (res.Session_gne__r.End_Time_gne__c != null)
            {
                item.endTime = res.Session_gne__r.End_Time_gne__c.format('MM/dd/yyyy hh:mm a','GMT');   
            }
            if (res.Session_gne__r.Location_gne__c != null) {
                item.location = res.Session_gne__r.Location_gne__c; 
            }
            if (res.Session_gne__r.Room_Name_gne__c!= null) {
                item.roomName = res.Session_gne__r.Room_Name_gne__c; 
            }
            if (res.Session_gne__r.Description_gne__c!= null) {
                item.description = res.Session_gne__r.Description_gne__c; 
            }
            
            items.add(item);
            
        }
        return items;
    }
    
    public String agendaSortExpression
    {
        get
        {
            return agendaSortExp;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == agendaSortExp) {
                agendaSortDirection = (agendaSortDirection == 'ASC')? 'DESC' : 'ASC';
            } else {
                agendaSortDirection = 'ASC';
            }
            agendaSortExp = value;
        }
    }

    public String getAgendaSortDirection()
    {
        //if no column is selected 
        if (agendaSortExpression == null || agendaSortExpression == '') {
            return 'ASC';
        } else {
            return agendaSortDirection;
        }
    }

    public void setAgendaSortDirection(String value)
    {  
        agendaSortDirection = value;
    }
    
    public String globalAgendaSortExpression
    {
        get
        {
            return gAgendaSortExp;
        }
        set
        {
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == gAgendaSortExp) {
                gAgendaSortDirection = (gAgendaSortDirection == 'ASC')? 'DESC' : 'ASC';
            } else {
                gAgendaSortDirection = 'ASC';
            }
            gAgendaSortExp = value;
        }
    }

    public String getGlobalAgendaSortDirection()
    {
        //if no column is selected 
        if (globalAgendaSortExpression == null || globalAgendaSortExpression == '') {
            return 'ASC';
        } else {
            return gAgendaSortDirection;
        }
    }

    public void setGlobalAgendaSortDirection(String value)
    {  
        gAgendaSortDirection = value;
    }
    
    // sort agenda items
    public PageReference sortAgenda()
    {
        SuperSort.sortList(items, agendaSortExp, agendaSortDirection);
        return null;
    }
    
    // sort global agenda items
    public PageReference sortGlobalAgenda() {
        System.debug('kwiatkol sortGlobalAgenda ' + gAgendaSortExp + ' ' + gAgendaSortDirection );
        SuperSort.sortList(gAitems, gAgendaSortExp, gAgendaSortDirection);
        return null;
    }
    
    // wrapper class used in sorting
    public class ResultWrapper implements IReflection {
        
        public String sessionName { get; set; }
        public String franchiseName { get; set; }
        public String name { get; set; }
        public String startTime { get; set; }
        public String endTime { get; set; }
        public String location { get; set; }
        public String roomName { get; set; }
        public String description {get; set;}
        
        public object getValue(String name) {
            object result = null;
            
            if(name == 'Session_gne__r.Name') {
                result = sessionName;
            } else if(name == 'Franchise_Name_gne__c') {
                result = franchiseName;
            } else if(name == 'Start_Time_gne__c') {
                result = startTime;
            } else if(name == 'End_Time_gne__c') {
                result = endTime;
            } else if(name == 'Location_gne__c') {
                result = location;
            } else if(name == 'Room_Name_gne__c') {
                result = roomName;
            } else if(name == 'Name') {
                result = name;
            } else if (description == 'Description_gne__c'){
                result = description;
            }
            
            return result;
        }
    }
    public class GlobalAgendaWrapper implements IReflection {
        
        public String gSessionId {get; set;}
        public String gFranchises {get; set;}
        public String gSessionName {get; set;}
        public String gStartTime {get; set;}
        public String gEndTime {get; set;}
        public String gLocation {get; set;}
        public String gRoomName {get; set;}
        public String gDescription {get; set;}
        
        public object getValue(String name) {
            object result = null;
            
            if(name == 'Session_gne__c') {
                result = gSessionId;
            } else if(name == 'Franchise_gne__c.Name') {
                result = gFranchises;
            } else if(name == 'Session_gne__r.Start_Time_gne__c') {
                result = gStartTime;
            } else if(name == 'Session_gne__r.End_Time_gne__c') {
                result = gEndTime;
            } else if(name == 'Session_gne__r.Location_gne__c') {
                result = gLocation;
            } else if(name == 'Session_gne__r.Room_Name_gne__c') {
                result = gRoomName;
            } else if(name == 'Session_gne__r.Description_gne__c') {
                result = gDescription;
            }
            
            return result;
        }
    }  
     
    public PageReference editMeetingInfo()
    {
        String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);  
        PageReference currentPageRef = System.currentPageReference();
        String meetingId = currentPageRef.getParameters().get('id');
        String redirectURL = partOneURL + 'apex/CMT_New_Meeting?id='+meetingId;
        if(meetingId != null || meetingId !='')
        {
            PageReference pageRef = new PageReference(redirectURL);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else
        {
            return null;
        }
    }
    public PageReference deleteMeeting()
    {
        delete currentMeeting;
        String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_All_Meetings';
        PageReference pageRef = new PageReference(redirectURL);
        pageRef.setRedirect(true);
        return pageRef;
    }
    public PageReference archiveMeeting()
    {
       	currentMeeting.Is_Archived__c=true;
       	update currentMeeting;
        return null;
    }
   
    public PageReference restoreMeeting()
    {
       	currentMeeting.Is_Archived__c=false;
       	update currentMeeting;
        return null;
    }
    
    public PageReference showAllMeetings()
    {
        String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        String redirectURL = partOneURL + 'apex/CMT_All_Meetings';
        PageReference pageRef = new PageReference(redirectURL);
        pageRef.setRedirect(true);
        return pageRef;
    }
    public PageReference addFranchise()
    {
        String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);  
        PageReference currentPageRef = System.currentPageReference();
        String meetingId = currentPageRef.getParameters().get('id');
        String redirectURL = partOneURL + 'apex/CMT_Franchise?mid='+meetingId;
        if(meetingId != null || meetingId !='')
        {
            PageReference pageRef = new PageReference(redirectURL);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else
        {
            return null;
        }
    }
    public PageReference editFranchise()
    {
        String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);  
        PageReference currentPageRef = System.currentPageReference();
        String franchiseId = currentPageRef.getParameters().get('frId');
        String meetingId = currentPageRef.getParameters().get('id');
        String redirectURL = partOneURL + 'apex/CMT_Franchise?id='+franchiseId+'&mid='+meetingId;
        if(franchiseId != null || franchiseId !='')
        {
            PageReference pageRef = new PageReference(redirectURL);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else
        {
            return null;
        }
    }
    public PageReference deleteFranchise()
    {
        PageReference currentPageRef = System.currentPageReference();
        String franchiseId = currentPageRef.getParameters().get('frId');
        String meetingId = currentPageRef.getParameters().get('id');
        List<CMT_Franchise_gne__c> tmpFranchise = new List<CMT_Franchise_gne__c>();
        tmpFranchise = [Select Id from CMT_Franchise_gne__c where Id =: franchiseId];
        
        List<CMT_FranchiseToSession_gne__c> frToSes = [Select Session_gne__c, Franchise_gne__c from CMT_FranchiseToSession_gne__c where Meeting_gne__c =: meetingId];
        Map<Id, Set<Id>> franchisesPerSession = new  Map<Id, Set<Id>>();
        for(CMT_FranchiseToSession_gne__c fts : frToSes)
        {
            if(!franchisesPerSession.containsKey(fts.Session_gne__c))
            {
                franchisesPerSession.put(fts.Session_gne__c, new Set<Id>());
            }
            franchisesPerSession.get(fts.Session_gne__c).add(fts.Franchise_gne__c);
        }
        List<Id> sessionIdsToRemove = new List<Id>();
        for(Id sessid : franchisesPerSession.keyset())
        {
            if(franchisesPerSession.get(sessid).contains(franchiseId) && franchisesPerSession.get(sessid).size() == 1)
            {
                sessionIdsToRemove.add(sessid);
            }
        }
        if(sessionIdsToRemove.size()>0)
        {
            List<CMT_Session_gne__c> sessionsToDel = [Select Id from CMT_Session_gne__c where Id IN :sessionIdsToRemove];
            delete sessionsToDel;
        }
        delete tmpFranchise;
        PageReference current = ApexPages.currentPage();
        current.getParameters().put('frId', null);
        current.setRedirect(true);
        return current;
        
    }
    public PageReference goToSessions()
    {
        String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);  
        PageReference currentPageRef = System.currentPageReference();
        String franchiseId = currentPageRef.getParameters().get('frId');
        String meetingId = currentPageRef.getParameters().get('id');
        String redirectURL = partOneURL + 'apex/CMT_Franchise_Sessions?fid='+franchiseId+'&mid='+meetingId;
        if(franchiseId != null || franchiseId !='')
        {
            PageReference pageRef = new PageReference(redirectURL);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else
        {
            return null;
        }
    }
    public PageReference addGlobalAgendaItem()
    {
        String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);  
        PageReference currentPageRef = System.currentPageReference();
        String meetingId = currentPageRef.getParameters().get('id');
        String redirectURL = partOneURL + 'apex/CMT_Global_Agenda?mid='+meetingId;
        if(meetingId != null || meetingId !='')
        {
            PageReference pageRef = new PageReference(redirectURL);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else
        {
            return null;
        }
    }
    public PageReference editGlobalAgendaItem()
    {
        String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);  
        PageReference currentPageRef = System.currentPageReference();
        String meetingId = currentPageRef.getParameters().get('id');
        String sessionId = currentPageRef.getParameters().get('sid');
        String redirectURL = partOneURL + 'apex/CMT_Global_Agenda?mid='+meetingId+'&sid='+sessionId;
        if(meetingId != null || meetingId !='')
        {
            PageReference pageRef = new PageReference(redirectURL);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else
        {
            return null;
        }
    }
    public PageReference deleteGlobalAgendaItem()
    {
        CMT_Session_gne__c sessiontoDel = new CMT_Session_gne__c();
        PageReference currentPageRef = System.currentPageReference();
        String sessionId = currentPageRef.getParameters().get('sid');
        sessiontoDel = [Select Id from CMT_Session_gne__c where Id =: sessionId];
        delete sessiontoDel;
        currentPageRef.setRedirect(true);
        return currentPageRef;
    }
    public PageReference viewGlobalAgendaItem()
    {
         String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);  
        PageReference currentPageRef = System.currentPageReference();
        String meetingId = currentPageRef.getParameters().get('id');
        String sessionId = currentPageRef.getParameters().get('sid');
        String redirectURL = partOneURL + 'apex/CMT_Global_Agenda_Item_View?mid='+meetingId+'&sid='+sessionId;
        if((meetingId != null || meetingId !='') &&(sessionId != null || sessionId !=''))
        {
            PageReference pageRef = new PageReference(redirectURL);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else
        {
            return null;
        }
    }
    
    // redirect to creating new event
    public PageReference addEvent()
    {
        return CMT_MiscUtils.sObjectEditPageRef(CMT_Event_gne__c.sObjectType, 'meetingId=' + meetingId);
    }
    
    // redirect to creating new exhibit
    public PageReference addExhibit()
    {
        return CMT_MiscUtils.sObjectEditPageRef(CMT_Exhibit_gne__c.sObjectType, 'meetingId=' + meetingId);
    }
    
    // redirect to creating new expo
    public PageReference addExpo()
    {
        return CMT_MiscUtils.sObjectEditPageRef(CMT_Expo_gne__c.sObjectType, 'meetingId=' + meetingId);
    }
    
    // redirect to creating new meet green
    public PageReference addMeetGreen()
    {
        return CMT_MiscUtils.sObjectEditPageRef(CMT_Meet_Green_gne__c.sObjectType, 'meetingId=' + meetingId);
    }
    
    // redirect to creating new contact category
    public PageReference initNewContactCategory()
    {
        return CMT_MiscUtils.sObjectEditPageRef(CMT_Contact_Category_gne__c.sObjectType, 'meetingId=' + meetingId);
    }
    
    // redirect to creating new contact category
    public PageReference initNewAbstractCategory()
    {
        return CMT_MiscUtils.sObjectEditPageRef(CMT_Abstract_Category_gne__c.sObjectType, 'meetingId=' + meetingId);
    }
    
    public PageReference viewFranchise()
    {
        String orgURL = ApexPages.currentPage().getUrl();
        Integer indexApex = orgURL.indexOf('apex');
        String partOneURL = orgURL.substring(0,indexApex);
        PageReference currentPageRef = System.currentPageReference();
        String franchiseId = currentPageRef.getParameters().get('frId');
        String meetingId = currentPageRef.getParameters().get('id');
        String redirectURL = partOneURL + 'apex/CMT_Franchise_View?mid='+meetingId+'&id='+franchiseId;
        if((meetingId != null || meetingId !='') && (franchiseId != null || franchiseId !=''))
        {
            PageReference pageRef = new PageReference(redirectURL);
            pageRef.setRedirect(true);
            return pageRef;
        }
        else
        {
            return null;
        }
    }
    
    public PageReference goToId()
    {
        PageReference pageRef = new PageReference('/' + this.redirectId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference goToEditId()
    {
        PageReference pageRef = new PageReference('/' + this.redirectId + '/e');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference deleteContactCategoryById()
    {
        CMT_Contact_Category_gne__c c = [SELECT Id FROM CMT_Contact_Category_gne__c WHERE Id = :this.redirectId];
        delete c;
        
        PageReference pageRef = new PageReference('/' + ((CMT_Meeting_gne__c)controller.getRecord()).Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference deleteAbstractCategoryById()
    {
        CMT_Abstract_Category_gne__c c = [SELECT Id FROM CMT_Abstract_Category_gne__c WHERE Id = :this.redirectId];
        delete c;
        
        PageReference pageRef = new PageReference('/' + ((CMT_Meeting_gne__c)controller.getRecord()).Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    // redirect to creating new contact category
    public PageReference addShuttle()
    {
        return CMT_MiscUtils.sObjectEditPageRef(CMT_Shuttle_gne__c.sObjectType, 'meetingId=' + meetingId);
    }
    
    // redirect to creating new contact category
    public PageReference showAllShuttles()
    {
        PageReference pageRef = new PageReference('/apex/' + CMT_Config.SHUTTLE_LIST + '?meetingId=' + ((CMT_Meeting_gne__c)controller.getRecord()).Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference deleteShuttleById()
    {
        CMT_Shuttle_gne__c c = [SELECT Id FROM CMT_Shuttle_gne__c WHERE Id = :this.redirectId];
        delete c;
        
        PageReference pageRef = new PageReference('/' + ((CMT_Meeting_gne__c)controller.getRecord()).Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference deleteExhibitById()
    {
        CMT_Exhibit_gne__c e = [SELECT Id FROM CMT_Exhibit_gne__c WHERE Id = :this.redirectId];
        delete e;
        
        PageReference pageRef = new PageReference('/' + ((CMT_Meeting_gne__c)controller.getRecord()).Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference deleteExpoById()
    {
        CMT_Expo_gne__c e = [SELECT Id FROM CMT_Expo_gne__c WHERE Id = :this.redirectId];
        delete e;
        
        PageReference pageRef = new PageReference('/' + ((CMT_Meeting_gne__c)controller.getRecord()).Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference deleteEventById()
    {
        CMT_Event_gne__c e = [SELECT Id FROM CMT_Event_gne__c WHERE Id = :this.redirectId];
        delete e;
        
        PageReference pageRef = new PageReference('/' + ((CMT_Meeting_gne__c)controller.getRecord()).Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference deleteMeetGreenById()
    {
        CMT_Meet_Green_gne__c m = [SELECT Id FROM CMT_Meet_Green_gne__c WHERE Id = :this.redirectId];
        delete m;
        
        PageReference pageRef = new PageReference('/' + ((CMT_Meeting_gne__c)controller.getRecord()).Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference deleteInfoById()
    {
        CMT_Information_gne__c i = [SELECT Id FROM CMT_Information_gne__c WHERE Id = :this.redirectId];
        delete i;
        
        PageReference pageRef = new PageReference('/' + ((CMT_Meeting_gne__c)controller.getRecord()).Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    // redirect to creating new contact category
    public PageReference addParking()
    {
        return CMT_MiscUtils.sObjectEditPageRef(CMT_Parking_gne__c.sObjectType, 'meetingId=' + meetingId);
    }
    
    // redirect to creating new contact category
    public PageReference showAllParkings()
    {
        PageReference pageRef = new PageReference('/apex/' + CMT_Config.PARKING_LIST + '?meetingId=' + ((CMT_Meeting_gne__c)controller.getRecord()).Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference deleteParkingById()
    {
        CMT_Parking_gne__c c = [SELECT Id FROM CMT_Parking_gne__c WHERE Id = :this.redirectId];
        delete c;
        
        PageReference pageRef = new PageReference('/' + ((CMT_Meeting_gne__c)controller.getRecord()).Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    // redirect to creating new contact category
    public PageReference addTaxiCompany()
    {
        return CMT_MiscUtils.sObjectEditPageRef(CMT_Taxi_Company_gne__c.sObjectType, 'meetingId=' + meetingId);
    }
    
    // redirect to creating new contact category
    public PageReference showAllTaxiCompanies()
    {
        PageReference pageRef = new PageReference('/apex/' + CMT_Config.TAXI_COMPANY_LIST + '?meetingId=' + ((CMT_Meeting_gne__c)controller.getRecord()).Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference deleteTaxiCompanyById()
    {
        CMT_Taxi_Company_gne__c c = [SELECT Id FROM CMT_Taxi_Company_gne__c WHERE Id = :this.redirectId];
        delete c;
        
        PageReference pageRef = new PageReference('/' + ((CMT_Meeting_gne__c)controller.getRecord()).Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference showAllContactCategories()
    {
        PageReference pageRef = new PageReference('/apex/' + CMT_Config.CONTACT_CATEGORY_LIST + '?meetingId=' + ((CMT_Meeting_gne__c)controller.getRecord()).Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference showAllAbstractCategories()
    {
        PageReference pageRef = new PageReference('/apex/' + CMT_Config.ABSTRACT_CATEGORY_LIST + '?meetingId=' + ((CMT_Meeting_gne__c)controller.getRecord()).Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference showAllMeetGreens()
    {
        PageReference pageRef = new PageReference('/apex/' + CMT_Config.MEET_GREEN_LIST + '?meetingId=' + ((CMT_Meeting_gne__c)controller.getRecord()).Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference showAllInformation()
    {
        PageReference pageRef = new PageReference('/apex/' + CMT_Config.INFORMATION_LIST + '?meetingId=' + ((CMT_Meeting_gne__c)controller.getRecord()).Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference showAllAnnouncements()
    {
        PageReference pageRef = new PageReference('/apex/' + CMT_Config.ANNOUNCEMENT_LIST + '?meetingId=' + ((CMT_Meeting_gne__c)controller.getRecord()).Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    // redirect to creating new contact category
    public PageReference addHotel()
    {
        return CMT_MiscUtils.sObjectEditPageRef(CMT_Hotel_gne__c.sObjectType, 'meetingId=' + meetingId);
    }
    
    // redirect to creating new contact category
    public PageReference addInformation()
    {
        return CMT_MiscUtils.sObjectEditPageRef(CMT_Information_gne__c.sObjectType, 'meetingId=' + meetingId);
    }
    
    // redirect to creating new contact category
    public PageReference showAllHotels()
    {
        PageReference pageRef = new PageReference('/apex/' + CMT_Config.HOTEL_LIST + '?meetingId=' + ((CMT_Meeting_gne__c)controller.getRecord()).Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    // redirect to creating new contact category
    public PageReference showAllEvents()
    {
        PageReference pageRef = new PageReference('/apex/' + CMT_Config.EVENT_LIST + '?meetingId=' + ((CMT_Meeting_gne__c)controller.getRecord()).Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    // redirect to creating new contact category
    public PageReference showAllExhibits()
    {
        PageReference pageRef = new PageReference('/apex/' + CMT_Config.EXHIBIT_LIST + '?meetingId=' + ((CMT_Meeting_gne__c)controller.getRecord()).Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    // redirect to creating new contact category
    public PageReference showAllExpos()
    {
        PageReference pageRef = new PageReference('/apex/' + CMT_Config.EXPO_LIST + '?meetingId=' + ((CMT_Meeting_gne__c)controller.getRecord()).Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference deleteHotelById()
    {
        CMT_Hotel_gne__c c = [SELECT Id FROM CMT_Hotel_gne__c WHERE Id = :this.redirectId];
        delete c;
        
        PageReference pageRef = new PageReference('/' + ((CMT_Meeting_gne__c)controller.getRecord()).Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    // redirect to creating new contact category
    public PageReference viewAgenda()
    {
        PageReference pageRef = new PageReference('/apex/' + CMT_Config.AGENDA_VIEW_PAGE + '?meetingId=' + ((CMT_Meeting_gne__c)controller.getRecord()).Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
}