public without sharing class gFRS_CalendarController {
   
    public gFRS_Calendar_Event__c eventHelper{get;set;}
        
   
    public gFRS_CalendarController(ApexPages.StandardController std){
        
        List<gFRS_Calendar_Preferences__c> userPref = [SELECT Disease_State__c,Venue_State__c,UserId__c,Zip_Code__c from gFRS_Calendar_Preferences__c where UserId__c =: UserInfo.getUserId() Limit 1];
        system.debug(userPref.size());
        eventHelper=new gFRS_Calendar_Event__c();
        if(!userPref.isEmpty()){
            system.debug(userPref);
            eventHelper.Disease_State_Helper__c = userPref.get(0).Disease_State__c;
            eventHelper.Venue_State_helper__c = userPref.get(0).Venue_State__c;
            eventHelper.Venue_Zip_Code__c = userPref.get(0).Zip_Code__c;
        }
    }
    
    public static String convertListToString(List<String> lst){
        
        Boolean isFirst=true;
        if(lst.size()>0){
            
            String outputString='(';
            for(String s :lst){
                if(isFirst){
                    outputString +='\''+String.escapeSingleQuotes(s)+'\'';
                    isFirst=false;
                }else{
                    outputString +=',\''+String.escapeSingleQuotes(s)+'\'';
                }
            }
            outputString +=')';
            return outputString;
            
        }
        return null;
    } 
    
    @RemoteAction
    public static void upsertUserPreferences(String deseseState,String venueStates,String zipCode){
        List<gFRS_Calendar_Preferences__c> userPref = [SELECT Disease_State__c,Venue_State__c,UserId__c,Zip_Code__c from gFRS_Calendar_Preferences__c where UserId__c =: UserInfo.getUserId() Limit 1];
        if(!userPref.isEmpty()){
            userPref.get(0).Disease_State__c = deseseState;
            userPref.get(0).Venue_State__c = venueStates;
            userPref.get(0).Zip_Code__c = zipCode;
            update userPref.get(0);
        }else{
            gFRS_Calendar_Preferences__c usrPrefCal= new gFRS_Calendar_Preferences__c();
            usrPrefCal.Disease_State__c= deseseState;
            usrPrefCal.Venue_State__c = venueStates;
            usrPrefCal.UserId__c = UserInfo.getUserId();
            usrPrefCal.Zip_Code__c = zipCode;
            insert usrPrefCal;
        }
    }
    
    @RemoteAction
    public static List<CalendarEventsWrapper> getEvents(List<String> deseseState,List<String> venueStates,String zipCode){
        system.debug('check if method executed :'+deseseState);
        List<CalendarEventsWrapper> eventsLstRemote = new List<CalendarEventsWrapper>();
        String currentInstance = URL.getSalesforceBaseUrl().toExternalForm();
        String convertedTaList = convertListToString(deseseState);
        String convertedVnameList = convertListToString(venueStates);
        String whereClause = convertedTaList != null ? 'where Disease_State__c in '+convertedTaList : '';
        whereClause = convertedVnameList !=null ? (whereClause == '' ? 'where Venue_State__c in '+convertedVnameList : whereClause+' and Venue_State__c in '+convertedVnameList) : whereClause;
        whereClause = zipCode !='' ? (whereClause == '' ? 'where Venue_Zip_Code__c = '+'\''+String.escapeSingleQuotes(zipCode)+'\'' : whereClause+' and Venue_Zip_Code__c = '+'\''+String.escapeSingleQuotes(zipCode)+'\'') : whereClause;
        //keep events which took place last year only older events are not shown up
        whereClause += whereClause == '' ? 'where CALENDAR_YEAR(End_Date__c) >= '+ String.valueOf(date.today().year()-1) : ' and CALENDAR_YEAR(End_Date__c) >= '+ String.valueOf(date.today().year()-1);
        //display only events which start date is after R5 production deployment initialy 6/29/2015
        GFRS_OrgSettings__c customSettings = GFRS_OrgSettings__c.getOrgDefaults();
        system.debug('***********getEvents method check if custom setting for start date is set:'+customSettings.Calendar_Start_Date__c);
        if(customSettings.Calendar_Start_Date__c != null){
            //if setting is not set events will not be filtered
            system.debug(customSettings.Calendar_Start_Date__c);
            whereClause += ' and Start_Date__c >= '+    DateTime.newInstance(customSettings.Calendar_Start_Date__c.year(),customSettings.Calendar_Start_Date__c.month(),customSettings.Calendar_Start_Date__c.day()).format('yyyy-MM-dd');
        }
        
        if(whereClause != '' && deseseState != null && venueStates != null && deseseState.size() != 0 && venueStates.size() != 0  ){
            String query = 'SELECT id,Title__c,Start_Date__c,End_Date__c,Program_Name__c FROM gFRS_Calendar_Event__c '+whereClause +' order by Start_Date__c asc';
            system.debug(query);
            for(gFRS_Calendar_Event__c gEvent : (List<gFRS_Calendar_Event__c>)Database.query(query)){
                //added +1 to gEvent.End_Date__c as a workaround as Calendar treats end date as not inclusive.
                eventsLstRemote.add(new CalendarEventsWrapper(gEvent.Title__c,gEvent.Start_Date__c,gEvent.End_Date__c+1,currentInstance+'/apex/gFRS_CalendarEventDetail?id='+gEvent.id));
            }
            String jsonEvents = JSON.serialize(eventsLstRemote);
            jsonEvents = jsonEvents.replace('endDate', 'end');
            system.debug(jsonEvents);
        }
        return eventsLstRemote;
    }
    
    public class CalendarEventsWrapper{
        public String title{get;set;}
        public Date start{get;set;}
        public Date endDate{get;set;}
        public String url{get;set;}
       
        
        public CalendarEventsWrapper(String cTitle,Date cStart,Date cEndDate,String cUrl){
            this.title=cTitle;
            this.start=cStart;
            this.endDate = cEndDate;
            this.url = cUrl;
        }
    }

}