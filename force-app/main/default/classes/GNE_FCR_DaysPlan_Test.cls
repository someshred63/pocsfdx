@isTest
private class GNE_FCR_DaysPlan_Test {    
    static testMethod void testDaysPlan(){
        String Id = createDaysPlanRecord();
        system.debug('Id returned'+Id);
        RestContext.request.requestURI = '/FCRWebservice/DaysPlan/' + Id;
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_DaysPlan_Webservice.doGet());
        System.assertEquals(1,response.records.size());
        System.assertEquals(true,response.success);
        RestContext.request.requestURI = '/FCRWebservice/DaysPlan/' + Id;
        response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_DaysPlan_Webservice.doPut('summary test',date.newinstance(2013,8,2),76,null,'dm test','field test',null,'localguid_test','','info backup test','other accounts test','previous cs test',''));
        System.assertEquals(true,response.success);
        deleteDaysPlanRecord(Id);
    }

    static testMethod void testActionPlan(){
        String DaysPlanId = createDaysPlanRecord();
        String Id = createActionPlanRecord(DaysPlanId);
        RestContext.request.requestURI = '/FCRWebservice/ActionPlan/' + Id;
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_ActionPlan_Webservice.doGet());
        System.assertEquals(1,response.records.size());
        System.assertEquals(true,response.success);
        RestContext.request.requestURI = '/FCRWebservice/ActionPlan/' + Id;
        response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_ActionPlan_Webservice.doPut('description 2',DaysPlanId,2,'localguid_test','status test','title test'));
        System.assertEquals(true,response.success);
        deleteActionPlanRecord(Id);
        deleteDaysPlanRecord(DaysPlanId);        
    }

    static testMethod void testDaysPlanAccount(){
        String DaysPlanId = createDaysPlanRecord();        
        String Id = createDaysPlanAccountRecord(DaysPlanId);
        RestContext.request.requestURI = '/FCRWebservice/DaysPlanAccount/' + Id;
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_DaysPlanAccount_Webservice.doGet());
        System.assertEquals(1,response.records.size());
        System.assertEquals(true,response.success);
        RestContext.request.requestURI = '/FCRWebservice/DaysPlanAccount/' + Id;
        response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_DaysPlanAccount_Webservice.doPut(null,DaysPlanId,'territory test','localguid_test'));
        System.assertEquals(true,response.success);
        deleteDaysPlanAccountRecord(Id);
        deleteDaysPlanRecord(DaysPlanId);          
    }

    static testMethod void testJobCompetency(){
        String DaysPlanId = createDaysPlanRecord();        
        String Id = createJobCompetencyRecord(DaysPlanId);
        RestContext.request.requestURI = '/FCRWebservice/JobCompetency/' + Id;
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_JobCompetency_Webservice.doGet());
        System.assertEquals(1,response.records.size());
        System.assertEquals(true,response.success);
        RestContext.request.requestURI = '/FCRWebservice/JobCompetency/' + Id;
        response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_JobCompetency_Webservice.doPut('assess5','assess2','assess3','assess4','clarify1','clarify2','clarify3','clarify4','execute1','execute2','execute3','execute4',DaysPlanId,'localguid_test'));
        System.assertEquals(true,response.success);
        deleteJobCompetencyRecord(Id);
        deleteDaysPlanRecord(DaysPlanId);
    }
    
    static testMethod void testPTPSummary(){
        String DaysPlanId = createDaysPlanRecord();        
        Datetime currentDate = datetime.now();
        String dateString = ''+currentDate;
        String Id = createPTPSummaryRecord(DaysPlanId);        
        System.debug('current date string'+dateString+currentDate);
        RestContext.request.requestURI = '/FCRWebservice/PTPSummary/' + Id;
        //RestContext.request.addParameter('TimeStamp',dateString);
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_PTPSummary_Webservice.doGet());
        System.debug('response PTP'+response);
        System.assertEquals(1,response.records.size());
        System.assertEquals(true,response.success);
        RestContext.request.requestURI = '/FCRWebservice/PTPSummary/' + Id;        
        response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_PTPSummary_Webservice.doPut(10,20,30,10,20,30,DaysPlanId,'Notes test',10,20,30,10,20,30,'gp1','gp2','gp3','localguid_test'));
        System.assertEquals(true,response.success);
        deletePTPSummaryRecord(Id);
        deleteDaysPlanRecord(DaysPlanId);
    }
    
     static testMethod void testListActionPlan(){
        System.RestContext.request = new RestRequest();
        String Id = createDaysPlanRecord();
        String listRecord = createActionPlanRecord(Id);        
        RestContext.request.requestURI = '/FCRWebservice/ListActionPlan/'+Id;
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_ListActionPlan_Webservice.doGet());
        System.assertEquals(1,response.records.size());
        System.assertEquals(true,response.success);
        deleteActionPlanRecord(listRecord);
        deleteDaysPlanRecord(Id);                     
     }

     static testMethod void testListDaysPlanAccount(){
        System.RestContext.request = new RestRequest();
        String Id = createDaysPlanRecord();        
        String listRecord = createDaysPlanAccountRecord(Id);                
        RestContext.request.requestURI = '/FCRWebservice/ListDaysPlanAccount/'+Id;
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_ListDaysPlanAccount_Webservice.doGet());
        system.debug('response list'+response);
        System.assertEquals(1,response.records.size());
        System.assertEquals(true,response.success);
        deleteDaysPlanAccountRecord(listRecord);
        deleteDaysPlanRecord(Id);                     
     }
     
     /*static testMethod void testListDaysPlanJA(){
        System.RestContext.request = new RestRequest();
        String Id = createDaysPlanRecord();
        RestContext.request.requestURI = '/FCRWebservice/ListFcrJobAccountabilities/' + Id;
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_ListFCR_JA_Webservice.doGet());
        System.assertEquals(5,response.records.size());
        System.assertEquals(true,response.success);             
     } */    

     static testMethod void testListJobCompetency(){
        System.RestContext.request = new RestRequest();
        String Id = createDaysPlanRecord();
        String listRecord = createJobCompetencyRecord(Id);                        
        RestContext.request.requestURI = '/FCRWebservice/ListJobCompetency/' + Id;
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_ListJobCompetency_Webservice.doGet());
        System.assertEquals(1,response.records.size());
        System.assertEquals(true,response.success);             
        deleteJobCompetencyRecord(listRecord);
        deleteDaysPlanRecord(Id); 
     }

     static testMethod void testListPTPSummary(){
        System.RestContext.request = new RestRequest();
        String Id = createDaysPlanRecord();
        String listRecord = createPTPSummaryRecord(Id);                                        
        RestContext.request.requestURI = '/FCRWebservice/ListPTPSummary/' + Id;
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_ListPTPSummary_Webservice.doGet());
        System.assertEquals(1,response.records.size());
        System.assertEquals(true,response.success);
        deletePTPSummaryRecord(listRecord);
        deleteDaysPlanRecord(Id);              
     }
     
     /**** Static Functions *****/
     static String createDaysPlanRecord(){
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/FCRWebservice/DaysPlan';
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_DaysPlan_Webservice.doPost('summary test',date.newinstance(2013,8,2),30,null,'dm test','field test',null,'localguid_test','','info backup test','other accounts test','previous cs test',''));
        system.debug(response);
        System.assertEquals(true,response.success,response);
        String Id = response.records.get(0).Id;
        system.debug('Id created'+Id);
        return Id;     
     }

     static void deleteDaysPlanRecord(String Id){        
        System.RestContext.request = new RestRequest();        
        RestContext.request.requestURI = '/FCRWebservice/DaysPlan/' + Id;
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_DaysPlan_Webservice.doDelete());
        System.assertEquals(0,response.records.size());
        System.assertEquals(true,response.success);     
     }

     static String createPTPSummaryRecord(String daysPlanId){
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/FCRWebservice/PTPSummary';
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_PTPSummary_Webservice.doPost(10,20,76,10,20,30,daysPlanId,'Notes test',10,20,30,10,20,30,'gp1','gp2','gp3','localguid_test'));
        system.debug(response);
        System.assertEquals(true,response.success,response);
        String Id = response.records.get(0).Id;
        return Id;     
     }

     static void deletePTPSummaryRecord(String Id){        
        System.RestContext.request = new RestRequest();        
        RestContext.request.requestURI = '/FCRWebservice/PTPSummary/' + Id;
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_PTPSummary_Webservice.doDelete());
        System.assertEquals(0,response.records.size());
        System.assertEquals(true,response.success);   
     }
     
     static String createActionPlanRecord(String daysPlanId){
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/FCRWebservice/ActionPlan';
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_ActionPlan_Webservice.doPost('description test',daysPlanId,3,'localguid_test','status test','title test'));
        system.debug(response);
        System.assertEquals(true,response.success,response);
        String Id = response.records.get(0).Id;
        return Id;     
     }

     static void deleteActionPlanRecord(String Id){        
        System.RestContext.request = new RestRequest();        
        RestContext.request.requestURI = '/FCRWebservice/ActionPlan/' + Id;
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_ActionPlan_Webservice.doDelete());
        System.assertEquals(0,response.records.size());
        System.assertEquals(true,response.success);    
     }     

     static String createJobCompetencyRecord(String daysPlanId){
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/FCRWebservice/JobCompetency';
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_JobCompetency_Webservice.doPost('assess1','assess2','assess3','assess4','clarify1','clarify2','clarify3','clarify4','execute1','execute2','execute3','execute4',daysPlanId,'localguid_test'));
        system.debug(response);
        System.assertEquals(true,response.success,response);
        String Id = response.records.get(0).Id;
        return Id;     
     }

     static void deleteJobCompetencyRecord(String Id){        
        System.RestContext.request = new RestRequest();        
        RestContext.request.requestURI = '/FCRWebservice/JobCompetency/' + Id;
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_JobCompetency_Webservice.doDelete());
        System.assertEquals(0,response.records.size());
        System.assertEquals(true,response.success);   
     }
/*
     static Id createDaysPlanJARecord(){
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/FCRWebservice/DaysPlan';
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_DaysPlan_Webservice.doPost('summary test',date.newinstance(2013,8,2),76,'00570000001DapE','dm test','field test','aDGV00000004C9B','localguid_test','','info backup test','other accounts test','previous cs test',''));
        system.debug(response);
        System.assertEquals(true,response.success,response);
        String Id = response.records.get(0).Id;
        return Id;     
     }

     static void deleteDaysPlanJARecord(String Id){        
        System.RestContext.request = new RestRequest();        
        RestContext.request.requestURI = '/FCRWebservice/DaysPlan/' + Id;
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_DaysPlan_Webservice.doDelete());
        System.assertEquals(0,response.records.size());
        System.assertEquals(true,response.success);     
     }*/

     static String createDaysPlanAccountRecord(String daysPlanId){
        System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/FCRWebservice/DaysPlanAccount';
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_DaysPlanAccount_Webservice.doPost(null,daysPlanId,'territory test2','localguid_test'));
        system.debug(response);
        System.assertEquals(true,response.success,response);
        String Id = response.records.get(0).Id;
        return Id;     
     }

     static void deleteDaysPlanAccountRecord(String Id){        
        System.RestContext.request = new RestRequest();        
        RestContext.request.requestURI = '/FCRWebservice/DaysPlanAccount/' + Id;
        GNE_FCR_Util.SObjectRestResponse response = ((GNE_FCR_Util.SObjectRestResponse)GNE_FCR_DaysPlanAccount_Webservice.doDelete());
        System.assertEquals(0,response.records.size());
        System.assertEquals(true,response.success);    
     }              
}