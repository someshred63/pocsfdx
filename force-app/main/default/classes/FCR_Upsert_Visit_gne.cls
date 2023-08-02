@RestResource(urlMapping='/FCR/upsertVisit/*')
global with sharing class FCR_Upsert_Visit_gne {
    //private static final String userExternalId = getUnixId(UserInfo.getUserId());
    @HttpPost
     global static iPhone_Commons_gne.RestResponse processRequest(String unixId, ManageVisitRequest request) {
        return iPhone_Commons_gne.buildResponse(
                new UserVisitsResponseBuilder(),
                new RequestArgs(unixId, request)
        );
    }
    
    private static String getUnixId(String userId) {
        return [SELECT External_Id_gne__c FROM User WHERE Id = :userId LIMIT 1].External_Id_gne__c;
    }
    
    public static List<ManageVisitWrapper> createManageVisitWrappers(Visit_gne__c[] visits) {
        List<ManageVisitWrapper> result = new List<ManageVisitWrapper>();
        for(Visit_gne__c app: visits) {
            result.add( new ManageVisitWrapper(app));
        }            
        
        return result;
    }
    
    public static List<ManageDevelopmentGoalWrapper> createDevGoalWrappers (List<Development_Goal_gne__c>  goals) {
        List<ManageDevelopmentGoalWrapper> result = new List<ManageDevelopmentGoalWrapper> ();
        for(Development_Goal_gne__c app: goals) {
            result.add( new ManageDevelopmentGoalWrapper(app));
        }
        
        return result;
    }    
    
    public static List<ManageNetworkPriorityWrapper> createNetworkPriorityWrappers(List<Network_Priority_gne__c> nets) {
        List<ManageNetworkPriorityWrapper> result = new List<ManageNetworkPriorityWrapper> ();
        for(Network_Priority_gne__c app: nets) {
            result.add( new ManageNetworkPriorityWrapper(app));
        }
        
        return result;
    }
    
    public static List<ManageAppointmentWrapper> createAppointmentWrappers(List<Appointment_gne__c> appointments) {
        List<ManageAppointmentWrapper> result = new List<ManageAppointmentWrapper> ();
        for(Appointment_gne__c app: appointments) {
            result.add( new ManageAppointmentWrapper(app));
        }
        
        return result;
    }
    
    class UserVisitsResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {
        public iPhone_Commons_gne.RestResponse build(Object args){
            RequestArgs reqArgs = (RequestArgs)args;
            ManageVisitWrapper mww = reqArgs.visitWrap;
            String unixId = reqArgs.unixId;
            Set<String> requestIds = new Set<String>();
            requestIds.add(mww.rid);
            if(mww.checkin != null)requestIds.add(mww.checkin.rid);

            Map<String, Visit_gne__c> requestId2DeletedVisit = new Map<String, Visit_gne__c>();
            Map<String, Visit_gne__c> requestId2ExisitingVisit = new Map<String, Visit_gne__c>();
            for(Visit_gne__c v : [SELECT Id, RequestId_gne__c, isDeleted, CreatedByUnixId__c FROM Visit_gne__c WHERE  RequestId_gne__c IN : requestIds ALL ROWS]) {
                if(v.isDeleted) requestId2DeletedVisit.put(v.RequestId_gne__c, v );
                else requestId2ExisitingVisit.put(v.RequestId_gne__c, v );
            }
            if(requestId2DeletedVisit.keySet().contains(mww.rid)) {
                mww.Id = null;
                return new DeltaRecordsResponse(mww);
            }

            
            Visit_gne__c visit = createVisitEntry(mww, unixId, requestId2ExisitingVisit);
            System.debug(' visit '+visit);
            Savepoint sp = Database.setSavepoint();

            try{
                System.debug(visit);
                visit.Id= null;
                upsert visit RequestId_gne__c;               
          
                mww.Id = visit.Id;
                mww.cByUnix = visit.CreatedByUnixId__c;
                
                prepareAndExecuteDML(mww, requestId2DeletedVisit, unixId, requestId2ExisitingVisit);
                
            } catch (Exception ex) {
                Database.rollback(sp);
                return new DeltaRecordsResponse(ex);
            }

            return new DeltaRecordsResponse(mww);
        }
        
        private void prepareAndExecuteDML(ManageVisitWrapper mww, Map<String, Visit_gne__c> requestId2DeletedVisit, String unixId, Map<String, Visit_gne__c> requestId2ExisitingVisit) {
            List<FCR_Peep_gne__c> peepsForProcess = new List<FCR_Peep_gne__c>();
            System.debug('mww >> '+mww);
            Map<String, FCR_UserPeepsStructure> peepsStructure = mww.getPeepsStructure();
            List<Appointment_gne__c> appointments = new List<Appointment_gne__c>();
            List<Development_Goal_gne__c> goals = new List<Development_Goal_gne__c>();
            List<Network_Priority_gne__c> nets = new List<Network_Priority_gne__c>();
            if(mww.aps != null && !mww.aps.isEmpty()) {
                appointments = createAppointmentsEntry(mww.aps, mww.Id);
                upsert appointments RequestId_gne__c;
                mww.aps = createAppointmentWrappers(appointments);
            }
            Database.delete([SELECT Id FROM Appointment_gne__c WHERE Visit_gne__c = :mww.Id AND Id NOT IN :appointments]);
            
            if(mww.goals != null && !mww.goals.isEmpty()) {
                goals = createDevGoalsEntry(mww.goals, mww.Id);
                upsert goals RequestId_gne__c;
                mww.goals = createDevGoalWrappers(goals);
            }
            Database.delete([SELECT Id FROM Development_Goal_gne__c WHERE Visit_gne__c = :mww.Id AND Id NOT IN :goals]);
            
            if(mww.nets != null && !mww.nets.isEmpty()) {
                nets = createNetworkPriorityEntry(mww.nets, mww.Id);
                upsert nets RequestId_gne__c;
                mww.nets = createNetworkPriorityWrappers(nets);
            }
            Database.delete([SELECT Id FROM Network_Priority_gne__c WHERE Visit_gne__c = :mww.Id AND Id NOT IN :nets]);
            
            if(mww.checkin != null){
                if(!requestId2DeletedVisit.keySet().contains(mww.checkin.rid)) {
                    Visit_gne__c checkin = createVisitEntry(mww.checkin, unixId, requestId2ExisitingVisit);
                    checkin.Field_Visit__c = mww.Id;
                    peepsStructure.putAll(mww.checkin.getPeepsStructure());
                    
                    upsert checkin RequestId_gne__c;
                    
                    mww.checkin.Id = checkin.Id;
                    mww.checkin.cByUnix = checkin.CreatedByUnixId__c;
                } else {
                    mww.checkin.Id = null;
				}                              
            }
            if(!peepsStructure.isEmpty()) {
                List<FCR_Peep_gne__c> toUpsert = new List<FCR_Peep_gne__c>();
                Map<String, FCR_Peep_gne__c> existingPeeps = new Map<String, FCR_Peep_gne__c>();
                for(FCR_Peep_gne__c fp : [SELECT UserUnixId__c, Manager_gne__c FROM FCR_Peep_gne__c WHERE UserUnixId__c IN :peepsStructure.keySet()]) {
                    existingPeeps.put(fp.UserUnixId__c, fp);
                }
                for(String fpUnixId : peepsStructure.keySet()) {
                    if(existingPeeps.containsKey(fpUnixId) ) continue;
                    FCR_Peep_gne__c peep = FCR_UserPeepsStructure.createPeepEntry(peepsStructure.get(fpUnixId));
                    peep.Do_Not_Delete__c = true;
                    toUpsert.add(peep);
                }
                
                Database.upsert(toUpsert, FCR_Peep_gne__c.UserUnixId__c, true);                
            }
        }    
                
        private Visit_gne__c createVisitEntry(ManageVisitWrapper mww, String unixId, Map<String, Visit_gne__c> requestId2ExisitingVisit) {
            Visit_gne__c existingVisit = requestId2ExisitingVisit.get(mww.rid) != null ? requestId2ExisitingVisit.get(mww.rid) : null;
            String temUnixId = (existingVisit != null && existingVisit.CreatedByUnixId__c != null) ? existingVisit.CreatedByUnixId__c : unixId;
            Visit_gne__c visit = new Visit_gne__c();
            visit.Clinical_Specialist_gne__c = (mww.cs != null) ? getUserId(mww.cs) : null;
            visit.Clinical_Specialist_By_UnixId__c  = (mww.cs != null) ? mww.cs : null;
            visit.Proxy_Manager_gne__c = (mww.pm != null)  ? getUserId(mww.pm) : null;
            visit.Proxy_Manager_By_Unix_Id__c = (mww.pm != null) ? mww.pm  : null;
            visit.Assigned_to_gne__c = (mww.assigned != null) ? getUserId(mww.assigned) : null;
            visit.Assigned_to_UnixId__c = (mww.assigned != null) ? mww.assigned : null;
            if(mww.endd != null) visit.End_Date_gne__c = DateTime.valueofGmt(mww.endd);               
            visit.Location_gne__c = mww.loc;
            visit.Notes_gne__c = mww.note;         
            if(mww.startd != null)visit.Start_Date_gne__c = DateTime.valueofGmt(mww.startd);
            visit.Status_gne__c = mww.stat;
            visit.Summary_gne__c = mww.summ;
            visit.Type_gne__c = mww.type; 
            visit.RequestId_gne__c = mww.rid;
            visit.Visit_Type__c = mww.vtype;
            visit.Request_Status_gne__c = mww.rStat;
            visit.CreatedByUnixId__c = temUnixId;
            visit.LastModifiedByUnixId__c = unixId;
            
            return visit;
        }
        
        private String getUserId(String UnixId) {
            List<User> users = [SELECT Id FROM User WHERE External_Id_gne__c = :UnixId LIMIT 1];
            return users.isEmpty() ? null : users[0].Id;
        }
        
        private Long getTime(String dateTimeString) {
            return String.isNotBlank(dateTimeString) ? ((DateTime)JSON.deserialize('"' + dateTimeString + '"', DateTime.class)).getTime() : null; 
        }
        
        private List<Development_Goal_gne__c> createDevGoalsEntry(ManageDevelopmentGoalWrapper [] goals, String visitId) {
            List<Development_Goal_gne__c> result = new List<Development_Goal_gne__c> ();
            for(ManageDevelopmentGoalWrapper rec: goals){
                Development_Goal_gne__c app = new Development_Goal_gne__c();
                app.Visit_gne__c = visitId;
                app.Category_gne_pl__c = rec.cat;
                app.Notes_gne__c = rec.note;  
                app.RequestId_gne__c = rec.rid;
               
                result.add(app);
            }
            
            return result;
        }  
                    
        private List<Appointment_gne__c> createAppointmentsEntry(ManageAppointmentWrapper [] aps, String visitId) {
            List<Appointment_gne__c> appointments = new List<Appointment_gne__c>();
            for(ManageAppointmentWrapper apw: aps){
                Appointment_gne__c app = new Appointment_gne__c();
                app.Visit_gne__c = visitId;
                app.Account_gne__c = apw.ac;
                app.Notes_gne__c = apw.note;  
                app.RequestId_gne__c = apw.rid;
               
                appointments.add(app);
            }
            
            return appointments;
        }
        
        private List<Network_Priority_gne__c> createNetworkPriorityEntry(ManageNetworkPriorityWrapper [] nets, String visitId) {
            List<Network_Priority_gne__c> result = new List<Network_Priority_gne__c> ();
            for(ManageNetworkPriorityWrapper rec: nets){
                Network_Priority_gne__c app = new Network_Priority_gne__c();
                app.Visit_gne__c = visitId;
                app.Category_gne_pl__c = rec.cat;
                app.Notes_gne__c = rec.note;  
                app.RequestId_gne__c = rec.rid;
               
                result.add(app);
            }
            
            return result;
        }
    }    
       
    global class ManageVisitRequest implements iPhone_Commons_gne.BaseArgs {
        public String unixId;
        public Boolean isPfgMode;
        public ManageVisitWrapper visit;
        
        public String getIPhoneRequestId(){
            return visit !=null ? visit.rid : null;
        }        
        
        public System.Type getRequestType() {
            return ManageVisitRequest.class;
        }
    }
    
    private virtual class RecordWrapper {
        private String id;
        private String rid; //RequestId_gne__c
    }
    
    public virtual class ManageVisitWrapper extends RecordWrapper {
        private String cs; //Clinical_Specialist_gne__c
        private String endd;//End_Date_gne__c
        private String fv;//Field_Visit__c
        private String loc;//Location_gne__c
        private String note;//Notes_gne__c
        private String pm;//Proxy_Manager_gne__c
        private String startd;//Start_Date_gne__c
        private String stat;//Status_gne__c
        private String summ;//Summary_gne__c
        private String type;//Type_gne__c
        private String assigned; //Assigned_to_gne__c
        private String vtype; //Visit_Type__c
        private String cByUnix; //CreatedByUnixId__c        
        private String rStat; //Request_Status_gne__c
        public List<ManageAppointmentWrapper> aps;
        public List<ManageDevelopmentGoalWrapper> goals;
        public List<ManageNetworkPriorityWrapper> nets;
        public ManageVisitWrapper checkIn;
        public FCR_UserPeepsStructure csPeep;
        public FCR_UserPeepsStructure pmPeep;
        public FCR_UserPeepsStructure asPeep;
        private Map<String, FCR_UserPeepsStructure> peeps;
        
        public ManageVisitWrapper() { }
        
        public ManageVisitWrapper(Visit_gne__c vis) {
            this.Id = vis.Id;
            this.cs = (vis.Clinical_Specialist_By_UnixId__c != null) ? vis.Clinical_Specialist_By_UnixId__c : null;            
            this.endd = vis.End_Date_gne__c != null ? vis.End_Date_gne__c.formatGMT('yyyy-MM-dd HH:mm:ss') : null;
            this.fv = vis.Field_Visit__c;
            this.loc = vis.Location_gne__c;
            this.note = vis.Notes_gne__c;
            this.pm = (vis.Proxy_Manager_By_Unix_Id__c != null) ? vis.Proxy_Manager_By_Unix_Id__c : null;
            this.startd = vis.Start_Date_gne__c != null ? vis.Start_Date_gne__c.formatGMT('yyyy-MM-dd HH:mm:ss') : null;
            this.stat = vis.Status_gne__c;
            this.summ = vis.Summary_gne__c;
            this.type = vis.Type_gne__c;
            this.assigned = (vis.Assigned_to_UnixId__c!= null) ? vis.Assigned_to_UnixId__c: null;
            this.vtype = vis.Visit_Type__c;
            this.cByUnix = vis.CreatedByUnixId__c;
            this.rid = vis.RequestId_gne__c;
            this.rStat = vis.Request_Status_gne__c;
        }
                
        public String getPm() {
            return pm;
        }
        
        public String getCs() {
            return cs;
        }
        
        public String getAs() {
            return assigned;
        }        
        
        public Map<String, FCR_UserPeepsStructure> getPeepsStructure() {
            Map<String, FCR_UserPeepsStructure> peepsStr = new Map<String, FCR_UserPeepsStructure>();
            if(csPeep != null) {
                peepsStr.put(csPeep.userId, csPeep);
            } 
            if(pmPeep != null) {
                peepsStr.put(pmPeep.userId, pmPeep);
            } 
            if(asPeep != null) {
                peepsStr.put(asPeep.userId, asPeep);
            } 
            return peepsStr;
        }
    }
    
    private class ManageAppointmentWrapper extends RecordWrapper {
        private String ac; //Account_gne__c
        private String note; //Notes_gne__c
        private String vId; //Visit_gne__c
        
        public ManageAppointmentWrapper(Appointment_gne__c app) {
            this.ac = app.Account_gne__c;
            this.note = app.Notes_gne__c;
            this.vId = app.Visit_gne__c;
            this.Id = app.Id;
            this.rid = app.RequestId_gne__c;
        }        
    }
    
    private class ManageDevelopmentGoalWrapper extends RecordWrapper {
        private String cat; //Category_gne_pl__c
        private String note; //Notes_gne__c
        private String vId; //Visit_gne__c
        
        public ManageDevelopmentGoalWrapper(Development_Goal_gne__c devGoal) {
            this.cat = devGoal.Category_gne_pl__c;
            this.note = devGoal.Notes_gne__c;
            this.vId = devGoal.Visit_gne__c;
            this.Id = devGoal.Id;
            this.rid = devGoal.RequestId_gne__c;
        }        
    }
    
    private class ManageNetworkPriorityWrapper extends RecordWrapper {
        private String cat; //Category_gne_pl__c
        private String note; //Notes_gne__c
        private String vId; //Visit_gne__c
        
        public ManageNetworkPriorityWrapper(Network_Priority_gne__c netPri) {
            this.cat = netPri.Category_gne_pl__c;
            this.note = netPri.Notes_gne__c;
            this.vId = netPri.Visit_gne__c;
            this.Id = netPri.Id;
            this.rid = netPri.RequestId_gne__c;
        }        
    }

    public class UserVisitRecord {
        ManageVisitWrapper visit;
        
        public UserVisitRecord(ManageVisitWrapper visit) {
            this.visit = visit;
        }        
    }
    
    public class RequestArgs extends iPhone_Commons_gne.DeltaArgs {
        public ManageVisitWrapper visitWrap;
        public RequestArgs(String unixId, ManageVisitRequest request) {
            super(null, unixId, null, null, null);
            this.visitWrap = request.visit;
        }
    }    
    
    public class DeltaRecordsResponse extends iPhone_Commons_gne.RestResponse {
        public ManageVisitWrapper visit;
        public DeltaRecordsResponse(ManageVisitWrapper visit) {
            this.visit = visit;           
        }
        public DeltaRecordsResponse(Exception ex) {
            this.setErrorStatus(ex);
        }
    }
}