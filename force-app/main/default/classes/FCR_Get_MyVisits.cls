@RestResource(urlMapping='/FCR/getVisits/*')
global class FCR_Get_MyVisits {

    @HttpPost
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId) {
        return iPhone_Commons_gne.buildResponse(
            new GetVisitsResponseBuilder(),
            new RequestArgs(unixId, lastSyncDate )            
        );
    }
    
    class GetVisitsResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {
        public iPhone_Commons_gne.RestResponse build(Object args) {
            RequestArgs reqArgs = (RequestArgs)args;
            List<MyVisitWrapper> visits = new List<MyVisitWrapper>();
            Set<String> externalIds = new Set<String>();
            for(Visit_gne__c visit :getVisits(reqArgs.unixId)) {
                MyVisitWrapper mww = new MyVisitWrapper(visit);
                if(!visit.ChecksIn__r.isEmpty()) {
                    MyVisitWrapper checkinWrapp = new MyVisitWrapper(visit.ChecksIn__r[0]);
                    mww.checkin = checkinWrapp;
                    updateExternalIds(externalIds, checkinWrapp);
                }
                if(!visit.Development_Goals__r.isEmpty())mww.goals = FCR_Upsert_Visit_gne.createDevGoalWrappers(visit.Development_Goals__r);
                if(!visit.Network_Priorities__r.isEmpty())mww.nets = FCR_Upsert_Visit_gne.createNetworkPriorityWrappers(visit.Network_Priorities__r);
                if(!visit.Appointments__r.isEmpty())mww.aps = FCR_Upsert_Visit_gne.createAppointmentWrappers(visit.Appointments__r);
                visits.add(mww);  
                updateExternalIds(externalIds, mww);
            }   
            
            DeltaRecordsResponse response = new DeltaRecordsResponse(visits);
            updateRecords(response, externalIds);
            
            return response;
        }
        
        private void updateRecords(DeltaRecordsResponse response, Set<String> externalIds) {
            Map<String, FCR_UserPeepsStructure> unixId2Peep = new Map<String, FCR_UserPeepsStructure>();
            Set<String> managers = new Set<String>();
            for(FCR_Peep_gne__c peep: [
                SELECT UserUnixId__c, Department_Code_gne__c, Department_Name_gne__c, Email_gne__c, Employment_Type_gne__c, First_Name_gne__c, Full_Name_gne__c, Job_Title_gne__c, 
                    Last_Name_gne__c, Location_gne__c, Location_Id_gne__c, Manager_gne__c, LastModifiedDate, CreatedDate, Mobile_Phone_Number_gne__c, Phone_Number_gne__c, Google_Id_gne__c
                FROM FCR_Peep_gne__c 
                WHERE UserUnixId__c IN :externalIds
            ]) {
                unixId2Peep.put(peep.UserUnixId__c, new FCR_UserPeepsStructure(peep));
                if(peep.Manager_gne__c != null && !externalIds.contains(peep.Manager_gne__c)) {
                    managers.add(peep.Manager_gne__c);
                }
            }
            if (!managers.isEmpty()) {
                for(FCR_Peep_gne__c peep: [
                    SELECT UserUnixId__c, Department_Code_gne__c, Department_Name_gne__c, Email_gne__c, Employment_Type_gne__c, First_Name_gne__c, Full_Name_gne__c, Job_Title_gne__c,
                        Last_Name_gne__c, Location_gne__c, Location_Id_gne__c, Manager_gne__c, LastModifiedDate, CreatedDate, Mobile_Phone_Number_gne__c, Phone_Number_gne__c, Google_Id_gne__c
                    FROM FCR_Peep_gne__c 
                    WHERE UserUnixId__c IN :managers
                ]) {
                    unixId2Peep.put(peep.UserUnixId__c, new FCR_UserPeepsStructure(peep));                    
                }
            }
            for(MyVisitWrapper rec : response.visits) {
                if(String.isNotEmpty(rec.getPm()))rec.pmPeep = unixId2Peep.get(rec.getPm());
                if(String.isNotEmpty(rec.getCs()))rec.asPeep = unixId2Peep.get(rec.getAs());
                if(String.isNotEmpty(rec.getCs()))rec.csPeep = unixId2Peep.get(rec.getCs());

                if(rec.csPeep !=null && rec.csPeep.managerUnixId != null && unixId2Peep.get(rec.csPeep.managerUnixId) != null) {
                    rec.csPeep.manager = unixId2Peep.get(rec.csPeep.managerUnixId);
                }

                if(rec.checkin != null) {
                    MyVisitWrapper temp = (MyVisitWrapper)rec.checkin;
                    temp.csPeep = unixId2Peep.get(temp.getCs());
                    rec.checkin = temp;
                }
            }
        }
        
        private void updateExternalIds(Set<String> externalIds,MyVisitWrapper mww) {
            if(String.isNotEmpty(mww.getPm()))externalIds.add(mww.getPm());
            if(String.isNotEmpty(mww.getCs()))externalIds.add(mww.getCs());
            if(String.isNotEmpty(mww.getAs()))externalIds.add(mww.getAs());
        }
        
        private Set<String> getMyPeepEmployees(String unixId) {
            Set<String> result = new Set<String>();
            for(FCR_Peep_gne__c peep : [SELECT UserUnixId__c FROM FCR_Peep_gne__c WHERE Manager_gne__c = :unixId] ) {
                result.add(peep.UserUnixId__c);
            }
            System.debug('result >> '+result);
            return result;
        }
        
        private List<Visit_gne__c> getVisits(String unixId) {
            return [
                SELECT Name, Clinical_Specialist_gne__r.External_Id_gne__c, Assigned_to_gne__r.External_Id_gne__c, End_Date_gne__c, Field_Visit__c, Location_gne__c,Notes_gne__c, Proxy_Manager_gne__r.External_Id_gne__c,
                    Start_Date_gne__c, Status_gne__c, Summary_gne__c, Type_gne__c, Visit_Type__c,RequestId_gne__c,Request_Status_gne__c, CreatedByUnixId__c, Assigned_to_UnixId__c,Clinical_Specialist_By_UnixId__c, Proxy_Manager_By_Unix_Id__c,
                	(
                        SELECT Name, Clinical_Specialist_gne__r.External_Id_gne__c, Assigned_to_gne__r.External_Id_gne__c, End_Date_gne__c, Field_Visit__c, Location_gne__c,Notes_gne__c, Proxy_Manager_gne__r.External_Id_gne__c,
                    		Start_Date_gne__c, Status_gne__c, Summary_gne__c, Type_gne__c, Visit_Type__c,RequestId_gne__c, Request_Status_gne__c, CreatedByUnixId__c,Assigned_to_UnixId__c,Clinical_Specialist_By_UnixId__c, Proxy_Manager_By_Unix_Id__c
                        FROM ChecksIn__r
                    ),
                    (
                        SELECT Category_gne_pl__c, Notes_gne__c, Visit_gne__c, RequestId_gne__c FROM Development_Goals__r
                    ),
                    (
                        SELECT Category_gne_pl__c, Notes_gne__c, Visit_gne__c, RequestId_gne__c FROM Network_Priorities__r
                    ),
                    (
                        SELECT Account_gne__c, Notes_gne__c, Visit_gne__c, RequestId_gne__c FROM Appointments__r
                    )
                FROM Visit_gne__c 
                WHERE Assigned_to_UnixId__c = :unixId
                    OR Clinical_Specialist_By_UnixId__c = :unixId OR Clinical_Specialist_By_UnixId__c IN :getMyPeepEmployees(unixId)
                    OR Proxy_Manager_By_Unix_Id__c = :unixId
                    OR CreatedByUnixId__c = :unixId 
            ];
        }
    }
    
    
    public class MyVisitWrapper extends FCR_Upsert_Visit_gne.ManageVisitWrapper {
        public MyVisitWrapper(Visit_gne__c visit) {
            super(visit);
        }        
    }
    
    public class RequestArgs extends iPhone_Commons_gne.DeltaArgs {
        public RequestArgs(String unixId, String lastSyncDate) {
            super(lastSyncDate, unixId, null, null, null);
        }               
    }    
    
    public class DeltaRecordsResponse extends iPhone_Commons_gne.RestResponse {
        public MyVisitWrapper[] visits;

        public DeltaRecordsResponse(MyVisitWrapper[] visits) {
            this.visits = visits;     

        }
    }
}