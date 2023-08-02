@isTest
public class EDM_PTD_List_View_Export_Ctrl_Test {
    
    @isTest
    public static void shouldGetExportListInSingleMode() {
        //given
        User usr = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        EDM_AABP_gne__c aabp = EDM_ABM_Test_Utils.getTestAABP('GROUP', usr, usr);
        insert aabp;
        EDM_IABP_gne__c iabp = createIABP(true, aabp.Id);
        EDM_IABP_gne__c iabp2 = createIABP(true, aabp.Id);
        createPTD(iabp.Id);
        createPTD(iabp2.Id);
        
        //when
        Test.setCurrentPage(Page.EDM_PTD_List_View_Export);
        ApexPages.currentPage().getParameters().put('parentExeSumId', iabp.Id);
        EDM_PTD_List_View_Export_Ctrl ctrl = new EDM_PTD_List_View_Export_Ctrl();
        
        //then
		System.assertEquals(1, ctrl.ptdFormatedToExport.size());
    }
    
    @isTest
    public static void shouldGetExportListInAllMode() {
        //given
        User usr = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        EDM_AABP_gne__c aabp = EDM_ABM_Test_Utils.getTestAABP('GROUP', usr, usr);
        insert aabp;
        EDM_IABP_gne__c iabp = createIABP(true, aabp.Id);
        EDM_IABP_gne__c iabp2 = createIABP(true, aabp.Id);
        createPTD(iabp.Id);
        createPTD(iabp2.Id);
        
        //when
        Test.setCurrentPage(Page.EDM_PTD_List_View_Export);
        EDM_PTD_List_View_Export_Ctrl ctrl = new EDM_PTD_List_View_Export_Ctrl();
        
        //then
		System.assertEquals(2, ctrl.ptdFormatedToExport.size());
    }
    
    @isTest
    public static void shouldSetNameToNoRecordsInSingleMode() {
        //given
        User usr = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
        EDM_AABP_gne__c aabp = EDM_ABM_Test_Utils.getTestAABP('GROUP', usr, usr);
        insert aabp;
        EDM_IABP_gne__c iabp = createIABP(true, aabp.Id);
        Test.setCurrentPage(Page.EDM_PTD_List_View_Export);
        ApexPages.currentPage().getParameters().put('parentExeSumId', iabp.Id);
        
        //when
        EDM_PTD_List_View_Export_Ctrl ctrl = new EDM_PTD_List_View_Export_Ctrl();
        
        //then
        System.assertEquals('no-records.xls', ctrl.docName);
    }
    
    @isTest
    public static void shouldSetNameToNoRecordsInAllMode() {
        //given
        Test.setCurrentPage(Page.EDM_PTD_List_View_Export);
        
        //when
        EDM_PTD_List_View_Export_Ctrl ctrl = new EDM_PTD_List_View_Export_Ctrl();
        
        //then
        System.assertEquals('no-records.xls', ctrl.docName);
        
        //some coverage
        ctrl.getHostName();
    }
    
    private static EDM_IABP_gne__c createIABP(Boolean isExeSum, Id parentAABP) {
        EDM_IABP_gne__c iabp = new EDM_IABP_gne__c();
        iabp.EDM_Type_of_Event_gne__c = 'CAB';
        iabp.EDM_Executive_Summary_gne__c = isExeSum;
        iabp.EDM_Meeting_Approach_gne__c = 'iAdvise';
        iabp.EDM_Estimated_Quarter_gne__c = 'Q1';
        iabp.EDM_Start_Date_gne__c = Date.today();
        iabp.EDM_End_Date_gne__c = Date.today();
        iabp.EDM_Meeting_Date_gne__c = Date.today();
        iabp.EDM_IABP_Version_gne__c = 0;
        List<User> ablead = EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABLEAD);
        if (ablead.size() > 0) {
            iabp.EDM_Primary_AB_Lead_gne__c = ablead[0].Id;
        }
        iabp.EDM_Parent_AABP_gne__c = parentAABP;
        iabp.EDM_Strategic_Context_gne__c = 'Context';
        iabp.EDM_Advisor_Selection_Criteria_gne__c = 'Criteria';
        iabp.EDM_Advisor_Selection_Duties_gne__c = 'Duties';
        iabp.EDM_ExeSum_Finalized_gne__c = System.today();
		insert iabp;
        return iabp;
    }
    
    private static EDM_Attachment_gne__c createPTD(Id parentExesumId) {
        EDM_Attachment_gne__c result =  new EDM_Attachment_gne__c(EDM_Parent_IABP_gne__c = parentExesumId, EDM_Pull_Through_Doc_gne__c = true);
        insert result;
        return result;
    }
}