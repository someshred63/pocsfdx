@isTest
public class GFRS_Ltng_Program_cntrl_Test {
  
   
    public static testMethod void programTestData(){
       gFRS_Ltng_Application__c gFRApp = new gFRS_Ltng_Application__c();
        gFRApp.Event_Program_Title__c = 'testApp1';
        Test.startTest();
        
        insert gFRApp;
        
        gFRS_Ltng_Program__c objProg = new gFRS_Ltng_Program__c();
        
        //objProg.gFRS_Application__c=gFRSObj.Id;
        objProg.gFRS_Program_Type__c='Live (in-person)';
        objProg.gFRS_Program_Live_Subtype__c='Satellite Symposium';
        objProg.gFRS_Start_Date__c=Date.Today()+80;
        objProg.gFRS_End_Date__c=Date.Today()+81;
        objProg.gFRS_Expected_number_of_attendees__c=10;
        
        List<gFRS_Ltng_Program_Audience_Group__c> listAudience1 = new List<gFRS_Ltng_Program_Audience_Group__c>();
        for(Integer i=0;i<5;i++){
            gFRS_Ltng_Program_Audience_Group__c objAudience1 = new gFRS_Ltng_Program_Audience_Group__c();
            //objAudience1.gFRS_Program__c= objProg2.id;
            objAudience1.gFRS_Credit_Hours__c= i;
            objAudience1.gFRS_Exp_Learners__c=i;
            objAudience1.gFRS_Expected_Learners_With_Credit__c=i;
            objAudience1.gFRS_Degree__c='Case Manager';
            listAudience1.add(objAudience1);
        }
        
        
        //insert objProg;
        gFRS_Ltng_Program__c objProg2 = new gFRS_Ltng_Program__c();
        objProg2.gFRS_Application__c=gFRApp.Id;
        objProg2.gFRS_Program_Type__c='Live (in-person)';
        objProg2.gFRS_Program_Live_Subtype__c='Satellite Symposium';
        objProg2.gFRS_Start_Date__c=Date.Today()+80;
        objProg2.gFRS_End_Date__c=Date.Today()+81;
        objProg2.gFRS_Expected_number_of_attendees__c=10;
        
        insert objProg2;
        
        List<gFRS_Ltng_Program__c> listProg = new List<gFRS_Ltng_Program__c>();
       
        gFRS_Ltng_Program__c objProg1 = new gFRS_Ltng_Program__c();
        objProg1.gFRS_Application__c=gFRApp.Id;
        objProg1.gFRS_Program_Type__c='Virtual (online)';
        objProg1.gFRS_Program_Subtype__c='Podcast';
        objProg1.gFRS_Start_Date__c=Date.Today()+80;
        objProg1.gFRS_End_Date__c=Date.Today()+81;
        objProg1.gFRS_Expected_number_of_attendees__c=23;
        listProg.add(objProg1);
        
        gFRS_Ltng_Program__c objProg4 = new gFRS_Ltng_Program__c();
        objProg4.gFRS_Application__c=gFRApp.Id;
        objProg4.gFRS_Program_Type__c='Enduring (physical media)';            
        objProg4.gFRS_Start_Date__c=Date.Today()+80;
        objProg4.gFRS_End_Date__c=Date.Today()+81;
        objProg4.gFRS_Expected_number_of_attendees__c=23;
        listProg.add(objProg4);
        
        gFRS_Ltng_Program__c objProg3 = new gFRS_Ltng_Program__c();
        objProg3.gFRS_Application__c=gFRApp.Id;
        objProg3.gFRS_Program_Type__c='Live (in-person)';
        objProg3.gFRS_Program_Live_Subtype__c='Satellite Symposium';            
        objProg3.gFRS_Start_Date__c=Date.Today()+80;
        objProg3.gFRS_End_Date__c=Date.Today()+81;
        objProg3.gFRS_Expected_number_of_attendees__c=23;
        listProg.add(objProg3);
        
        insert listProg;
        
        List<gFRS_Ltng_Program_Audience_Group__c> listAudience = new List<gFRS_Ltng_Program_Audience_Group__c>();
        for(Integer i=0;i<5;i++){
            gFRS_Ltng_Program_Audience_Group__c objAudience = new gFRS_Ltng_Program_Audience_Group__c();
            objAudience.gFRS_Program__c= objProg2.id;
            objAudience.gFRS_Credit_Hours__c= i;
            objAudience.gFRS_Exp_Learners__c=i;
            objAudience.gFRS_Expected_Learners_With_Credit__c=i;
            objAudience.gFRS_Degree__c='Case Manager';
            listAudience.add(objAudience);
        }
        insert listAudience;
        
        List<gFRS_Ltng_Request_Budget__c> listBudget = new List<gFRS_Ltng_Request_Budget__c>();
        gFRS_Ltng_Request_Budget__c objBudget = new gFRS_Ltng_Request_Budget__c();
        objBudget.gFRS_Application__c=gFRApp.Id;
        objBudget.Budget_Summary_Description__c='Live (in-person)';
        objBudget.Type__c ='Live (in-person)';
        listBudget.add(objBudget);
        
        gFRS_Ltng_Request_Budget__c objBudget1 = new gFRS_Ltng_Request_Budget__c();
        objBudget1.gFRS_Application__c=gFRApp.Id;
        objBudget1.Budget_Summary_Description__c='Enduring (physical media)';
        objBudget1.Type__c ='';
        listBudget.add(objBudget1);
        
        gFRS_Ltng_Request_Budget__c objBudget2 = new gFRS_Ltng_Request_Budget__c();
        objBudget2.gFRS_Application__c=gFRApp.Id;
        objBudget2.Budget_Summary_Description__c='Virtual (online)';
        objBudget2.Type__c ='';
        listBudget.add(objBudget2);
        
        insert listBudget;
        test.stopTest();
        
        GFRS_Ltng_Program_cntrl.getPicklistvalues('gFRS_Ltng_Program_Audience_Group__c', 'gFRS_Degree__c');
        GFRS_Ltng_Program_cntrl.getDependentMap(objProg2, 'gFRS_Program_Type__c', 'gFRS_Program_Subtype__c');
        GFRS_Ltng_Program_cntrl.getPrograms(gFRApp.Id);
        GFRS_Ltng_Program_cntrl.saveProgram(objProg, listAudience1, gFRApp.Id,'Independent Medical Education (CME)');
        GFRS_Ltng_Program_cntrl.updateProgram(objProg2, listAudience);
        GFRS_Ltng_Program_cntrl.getProgramChilds(objProg2.Id);        
        GFRS_Ltng_Program_cntrl.createBudgetRecords(gFRApp.Id);
        GFRS_Ltng_Program_cntrl.deleteProgram(listProg, gFRApp.Id, 'Live (in-person)');        
        GFRS_Ltng_Program_cntrl.deleteAttendees(listAudience);
        GFRS_Ltng_Program_cntrl.getExistingProgramsByType('Live (in-person)', gFRApp.Id);
        GFRS_Ltng_Program_cntrl.picklistWrapper  pw= new GFRS_Ltng_Program_cntrl.picklistWrapper();
        pw.pickListLabel='test';
        pw.pickListValue='test';
        GFRS_Ltng_Program_cntrl.PicklistEntryWrapper pe = new GFRS_Ltng_Program_cntrl.PicklistEntryWrapper();
        //pe.active = 'true';
        pe.value = 'test';
       // pe.defaultValue = 'none';
    }
    
}