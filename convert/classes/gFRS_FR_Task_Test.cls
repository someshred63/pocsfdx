/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */

@isTest
private class gFRS_FR_Task_Test {

  @isTest(SeeAllData = true)
  static void fundingRequestTaskRFIOrganization() {
    GFRS_Funding_Request__c objRequest;
    SetUpTestObjects testObjects = new  SetUpTestObjects();
    testObjects.createRequest(gFRS_TestCreationUtils.RT_FR_CORPORATE_MEMBERSHIPS_NAME, 'Organization');
    Map<Id, gFRS_Funding_Request__c> lTasks = new Map<Id, gFRS_Funding_Request__c>();

    //Check GFRS_OrgSettings for BU-Ta Mapping
    objRequest = testObjects.objRequestCORPORATE;
    objRequest.Sub_Status__c = 'RFI';
    update objRequest;

    lTasks = new Map<Id, gFRS_Funding_Request__c>(
      [select (select Subject__c, CreatedDate, gFRS_Funding_Request__c, Description__c, Action_Type__c, Status__c, RFI_Link__c
               from gFRS_Tasks__r where status__c != 'Closed') from GFRS_Funding_Request__c where id = :objRequest.id]);

    System.assertEquals(true, gFRS_FR_Task_Test.checkIfContainsTask(objRequest.id , 'RFI', lTasks));
    string rfiLink = gFRS_FR_Task_Test.checkRfiLink(objRequest.id , 'RFI', lTasks);
    System.assertEquals(true, rfiLink.contains('gFRS_Org_Info'));
  }

  @isTest(SeeAllData = true)
  static void fundingRequestTaskRFIApplication() {
    GFRS_Funding_Request__c objRequest;
    SetUpTestObjects testObjects = new  SetUpTestObjects();
    testObjects.createRequest(gFRS_TestCreationUtils.RT_FR_CORPORATE_MEMBERSHIPS_NAME, 'Application');
    Map<Id, gFRS_Funding_Request__c> lTasks = new Map<Id, gFRS_Funding_Request__c>();

    //Check GFRS_OrgSettings for BU-Ta Mapping

    objRequest = testObjects.objRequestCORPORATE;
    objRequest.Sub_Status__c = 'RFI';
    update objRequest;

    lTasks = new Map<Id, gFRS_Funding_Request__c>(
      [select (select Subject__c, CreatedDate, gFRS_Funding_Request__c, Description__c, Action_Type__c, Status__c, RFI_Link__c
               from gFRS_Tasks__r where status__c != 'Closed') from GFRS_Funding_Request__c where id = :objRequest.id]);

    System.assertEquals(true, gFRS_FR_Task_Test.checkIfContainsTask(objRequest.id , 'RFI', lTasks));
    string rfiLink = gFRS_FR_Task_Test.checkRfiLink(objRequest.id , 'RFI', lTasks);
    System.assertEquals(true, rfiLink.contains('GFRS_Application'));
  }

  @isTest(SeeAllData = true)
  static void fundingRequestTaskRFIProgram() {
    GFRS_Funding_Request__c objRequest;
    SetUpTestObjects testObjects = new  SetUpTestObjects();
    testObjects.createRequest(gFRS_TestCreationUtils.RT_FR_CORPORATE_MEMBERSHIPS_NAME, 'Program');
    Map<Id, gFRS_Funding_Request__c> lTasks = new Map<Id, gFRS_Funding_Request__c>();

    //Check GFRS_OrgSettings for BU-Ta Mapping
    objRequest = testObjects.objRequestCORPORATE;
    objRequest.Sub_Status__c = 'RFI';
    update objRequest;

    lTasks = new Map<Id, gFRS_Funding_Request__c>(
      [select (select Subject__c, CreatedDate, gFRS_Funding_Request__c, Description__c, Action_Type__c, Status__c, RFI_Link__c
               from gFRS_Tasks__r where status__c != 'Closed') from GFRS_Funding_Request__c where id = :objRequest.id]);

    System.assertEquals(true, gFRS_FR_Task_Test.checkIfContainsTask(objRequest.id , 'RFI', lTasks));
    string rfiLink = gFRS_FR_Task_Test.checkRfiLink(objRequest.id , 'RFI', lTasks);
    System.assertEquals(true, rfiLink.contains('gFRS_Program'));
  }

  @isTest(SeeAllData = true)
  static void fundingRequestTaskRFIBudget() {
    GFRS_Funding_Request__c objRequest;
    SetUpTestObjects testObjects = new  SetUpTestObjects();
    testObjects.createRequest(gFRS_TestCreationUtils.RT_FR_CORPORATE_MEMBERSHIPS_NAME, 'Budget');
    Map<Id, gFRS_Funding_Request__c> lTasks = new Map<Id, gFRS_Funding_Request__c>();

    //Check GFRS_OrgSettings for BU-Ta Mapping
    objRequest = testObjects.objRequestCORPORATE;
    objRequest.Sub_Status__c = 'RFI';
    update objRequest;

    lTasks = new Map<Id, gFRS_Funding_Request__c>(
      [select (select Subject__c, CreatedDate, gFRS_Funding_Request__c, Description__c, Action_Type__c, Status__c, RFI_Link__c
               from gFRS_Tasks__r where status__c != 'Closed') from GFRS_Funding_Request__c where id = :objRequest.id]);

    System.assertEquals(true, gFRS_FR_Task_Test.checkIfContainsTask(objRequest.id , 'RFI', lTasks));
    string rfiLink = gFRS_FR_Task_Test.checkRfiLink(objRequest.id , 'RFI', lTasks);
    System.assertEquals(true, rfiLink.contains('gFRS_Budget'));
  }

  @isTest(SeeAllData = true)
  static void fundingRequestTaskLOA() {
    GFRS_Funding_Request__c objRequest;
    SetUpTestObjects testObjects = new  SetUpTestObjects();
    testObjects.createRequest(gFRS_TestCreationUtils.RT_FR_IMED_NAME, 'Budget');
    Map<Id, gFRS_Funding_Request__c> lTasks = new Map<Id, gFRS_Funding_Request__c>();

    //Check GFRS_OrgSettings for BU-Ta Mapping
    objRequest = testObjects.objRequestIMED;
    objRequest.Status__c = 'Processing & Disposition';
    objRequest.Sub_Status__c = 'Approved-Awaiting LOA';
    update objRequest;

    lTasks = new Map<Id, gFRS_Funding_Request__c>(
      [select (select Subject__c, CreatedDate, gFRS_Funding_Request__c, Description__c, Action_Type__c, Status__c, RFI_Link__c
               from gFRS_Tasks__r where status__c != 'Closed') from GFRS_Funding_Request__c where id = :objRequest.id]);

    System.assertEquals(true, gFRS_FR_Task_Test.checkIfContainsTask(objRequest.id , 'LOA', lTasks));

  }

  @isTest(SeeAllData = true)
  static void fundingRequestTaskIMEDStatusReport() {
    GFRS_Funding_Request__c objRequest;
    SetUpTestObjects testObjects = new  SetUpTestObjects();
    testObjects.createRequest(gFRS_TestCreationUtils.RT_FR_IMED_NAME, 'Budget');
    Map<Id, gFRS_Funding_Request__c> lTasks = new Map<Id, gFRS_Funding_Request__c>();

    //Creating status report task for imed
    objRequest = testObjects.objRequestIMED;
    objRequest.Status__c = 'Processing & Disposition';
    objRequest.Sub_Status__c = 'Approved-Status Updates/Outcomes';
    update objRequest;

    lTasks = new Map<Id, gFRS_Funding_Request__c>(
      [select (select Subject__c, CreatedDate, gFRS_Funding_Request__c, Description__c, Action_Type__c, Status__c, RFI_Link__c
               from gFRS_Tasks__r where status__c != 'Closed') from GFRS_Funding_Request__c where id = :objRequest.id]);

    System.assertEquals(true, gFRS_FR_Task_Test.checkIfContainsTask(objRequest.id , 'Status Report', lTasks));
  }

  @isTest(SeeAllData = true)
  static void fundingRequestTaskFellowshipsStatusReport() {
    GFRS_Funding_Request__c objRequest;
    SetUpTestObjects testObjects = new  SetUpTestObjects();
    Map<Id, gFRS_Funding_Request__c> lTasks = new Map<Id, gFRS_Funding_Request__c>();

    //Creating status report task for fellowship
    testObjects.createRequest(gFRS_TestCreationUtils.RT_FR_FELLOWSHIPS_NAME, 'Budget');
    objRequest = testObjects.objRequestFELLOWSHIPS;
    objRequest.Status__c = 'Processing & Disposition';
    objRequest.Sub_Status__c = 'Approved-Status Updates/Outcomes';
    update objRequest;

    lTasks = new Map<Id, gFRS_Funding_Request__c>(
      [select (select Subject__c, CreatedDate, gFRS_Funding_Request__c, Description__c, Action_Type__c, Status__c, RFI_Link__c
               from gFRS_Tasks__r where status__c != 'Closed') from GFRS_Funding_Request__c where id = :objRequest.id]);

    System.assertEquals(true, gFRS_FR_Task_Test.checkIfContainsTask(objRequest.id , 'Status Report', lTasks));
  }

  @isTest(SeeAllData = true)
  static void fundingRequestTaskOutcomes() {
    GFRS_Funding_Request__c objRequest;
    SetUpTestObjects testObjects = new  SetUpTestObjects();
    testObjects.createRequest(gFRS_TestCreationUtils.RT_FR_IMED_NAME, 'Budget');
    Map<Id, gFRS_Funding_Request__c> lTasks = new Map<Id, gFRS_Funding_Request__c>();

    //Creating Outcomes task for IMED

    objRequest = testObjects.objRequestIMED;
    objRequest.Status__c = 'Processing & Disposition';
    objRequest.Sub_Status__c = 'Approved-Status Updates/Outcomes';
    update objRequest;

    lTasks = new Map<Id, gFRS_Funding_Request__c>(
      [select (select Subject__c, CreatedDate, gFRS_Funding_Request__c, Description__c, Action_Type__c, Status__c, RFI_Link__c
               from gFRS_Tasks__r where status__c != 'Closed') from GFRS_Funding_Request__c where id = :objRequest.id]);

    System.assertEquals(true, gFRS_FR_Task_Test.checkIfContainsTask(objRequest.id , 'Outcomes', lTasks));
  }

  @isTest(SeeAllData = true)
  static void fundingRequestTaskEvaluationScientific() {
    GFRS_Funding_Request__c objRequest;
    SetUpTestObjects testObjects = new  SetUpTestObjects();
    testObjects.createRequest(gFRS_TestCreationUtils.RT_FR_SCIENTIFIC_PROJECTS_NAME, 'Budget');
    Map<Id, gFRS_Funding_Request__c> lTasks = new Map<Id, gFRS_Funding_Request__c>();

    //Creating Evaluation task for Scientific Projects
    objRequest = testObjects.objRequestSCIENTIFIC_PROJECTS;
    objRequest.Status__c = 'Processing & Disposition';
    objRequest.Sub_Status__c = 'Approved-Program Evaluations';
    update objRequest;

    lTasks = new Map<Id, gFRS_Funding_Request__c>(
      [select (select Subject__c, CreatedDate, gFRS_Funding_Request__c, Description__c, Action_Type__c, Status__c, RFI_Link__c
               from gFRS_Tasks__r where status__c != 'Closed') from GFRS_Funding_Request__c where id = :objRequest.id]);

    System.assertEquals(true, gFRS_FR_Task_Test.checkIfContainsTask(objRequest.id , 'Evaluations', lTasks));
  }

  @isTest(SeeAllData = true)
  static void fundingRequestTaskEvaluationFellowships() {
    GFRS_Funding_Request__c objRequest;
    SetUpTestObjects testObjects = new  SetUpTestObjects();
    Map<Id, gFRS_Funding_Request__c> lTasks = new Map<Id, gFRS_Funding_Request__c>();

    //Creating Evaluation task for Fellowships
    System.debug(LoggingLevel.ERROR, 'before insert objRequestFELLOWSHIPS: ' + Limits.getQueries());
    testObjects.createRequest(gFRS_TestCreationUtils.RT_FR_FELLOWSHIPS_NAME, 'Budget');
    System.debug(LoggingLevel.ERROR, 'after insert objRequestFELLOWSHIPS: ' + Limits.getQueries());
    objRequest = testObjects.objRequestFELLOWSHIPS;
    objRequest.Status__c = 'Processing & Disposition';
    objRequest.Sub_Status__c = 'Approved-Program Evaluations';
    System.debug(LoggingLevel.ERROR, 'before update objRequestFELLOWSHIPS: ' + Limits.getQueries());
    update objRequest;
    System.debug(LoggingLevel.ERROR, 'after update objRequestFELLOWSHIPS: ' + Limits.getQueries());
    lTasks = new Map<Id, gFRS_Funding_Request__c>(
      [select (select Subject__c, CreatedDate, gFRS_Funding_Request__c, Description__c, Action_Type__c, Status__c, RFI_Link__c
               from gFRS_Tasks__r where status__c != 'Closed') from GFRS_Funding_Request__c where id = :objRequest.id]);

    System.assertEquals(true, gFRS_FR_Task_Test.checkIfContainsTask(objRequest.id , 'Evaluations', lTasks));
  }

  @isTest(SeeAllData = true)
  static void fundingRequestTaskEvaluationPhilantropic() {
    GFRS_Funding_Request__c objRequest;
    System.debug(LoggingLevel.ERROR, 'Before Update 1: ' + Limits.getQueries());
    SetUpTestObjects testObjects = new  SetUpTestObjects();
    testObjects.createRequest(gFRS_TestCreationUtils.RT_FR_PHILANTHROPIC_NAME, 'Budget');
    Map<Id, gFRS_Funding_Request__c> lTasks = new Map<Id, gFRS_Funding_Request__c>();

    //Creating Evaluation task for Philanthropic
    objRequest = testObjects.objRequestPHILANTHROPIC;
    objRequest.Status__c = 'Processing & Disposition';
    objRequest.Sub_Status__c = 'Approved-Program Evaluations';
    System.debug(LoggingLevel.ERROR, 'Before Update 2: ' + Limits.getQueries());
    update objRequest;

    System.debug(LoggingLevel.ERROR, 'Update 1: ' + Limits.getQueries());
    lTasks = new Map<Id, gFRS_Funding_Request__c>(
      [select (select Subject__c, CreatedDate, gFRS_Funding_Request__c, Description__c, Action_Type__c, Status__c, RFI_Link__c
               from gFRS_Tasks__r where status__c != 'Closed') from GFRS_Funding_Request__c where id = :objRequest.id]);

    System.assertEquals(true, gFRS_FR_Task_Test.checkIfContainsTask(objRequest.id , 'Evaluations', lTasks));
  }

  @isTest(SeeAllData = true)
  static void fundingRequestTaskEvaluationHCChar() {
    GFRS_Funding_Request__c objRequest;
    System.debug(LoggingLevel.ERROR, 'Before Update 1: ' + Limits.getQueries());
    SetUpTestObjects testObjects = new  SetUpTestObjects();
    Map<Id, gFRS_Funding_Request__c> lTasks = new Map<Id, gFRS_Funding_Request__c>();

    //Creating Evaluation task for HC Char
    testObjects.createRequest(gFRS_TestCreationUtils.RT_FR_HC_CHAR_NAME, 'Budget');
    objRequest = testObjects.objRequestHC_CHAR;
    objRequest.Status__c = 'Processing & Disposition';
    objRequest.Sub_Status__c = 'Approved-Program Evaluations';
    update objRequest;

    System.debug(LoggingLevel.ERROR, 'Update 2: ' + Limits.getQueries());
    lTasks = new Map<Id, gFRS_Funding_Request__c>(
      [select (select Subject__c, CreatedDate, gFRS_Funding_Request__c, Description__c, Action_Type__c, Status__c, RFI_Link__c
               from gFRS_Tasks__r where status__c != 'Closed') from GFRS_Funding_Request__c where id = :objRequest.id]);

    System.assertEquals(true, gFRS_FR_Task_Test.checkIfContainsTask(objRequest.id , 'Evaluations', lTasks));
  }

  @isTest(SeeAllData = true)
  static void fundingRequestTaskReconcilation() {
    GFRS_Funding_Request__c objRequest;
    SetUpTestObjects testObjects = new  SetUpTestObjects();
    testObjects.createRequest(gFRS_TestCreationUtils.RT_FR_IMED_NAME, 'Budget');
    Map<Id, gFRS_Funding_Request__c> lTasks = new Map<Id, gFRS_Funding_Request__c>();

    //Creating Outcomes task for IMED
    objRequest = testObjects.objRequestIMED;
    objRequest.Status__c = 'Processing & Disposition';
    objRequest.Sub_Status__c = 'Reconciliation Required';
    update objRequest;

    lTasks = new Map<Id, gFRS_Funding_Request__c>(
      [select (select Subject__c, CreatedDate, gFRS_Funding_Request__c, Description__c, Action_Type__c, Status__c, RFI_Link__c
               from gFRS_Tasks__r where status__c != 'Closed') from GFRS_Funding_Request__c where id = :objRequest.id]);

    System.assertEquals(true, gFRS_FR_Task_Test.checkIfContainsTask(objRequest.id , 'Reconciliation', lTasks));
    //For IMED if Sub_Status__c='Reconciliation Required' also outcomes status will should be created
    System.assertEquals(true, gFRS_FR_Task_Test.checkIfContainsTask(objRequest.id , 'Outcomes', lTasks));
  }

  @isTest(SeeAllData = true)
  static void fundingRequestTaskRefund() {
    GFRS_Funding_Request__c objRequest;
    SetUpTestObjects testObjects = new  SetUpTestObjects();
    testObjects.createRequest(gFRS_TestCreationUtils.RT_FR_IMED_NAME, 'Budget');
    Map<Id, gFRS_Funding_Request__c> lTasks = new Map<Id, gFRS_Funding_Request__c>();

    //Creating Outcomes task for IMED
    objRequest = testObjects.objRequestIMED;
    objRequest.Sub_Status__c = 'Refund Required';
    update objRequest;

    lTasks = new Map<Id, gFRS_Funding_Request__c>(
      [select (select Subject__c, CreatedDate, gFRS_Funding_Request__c, Description__c, Action_Type__c, Status__c, RFI_Link__c
               from gFRS_Tasks__r where status__c != 'Closed') from GFRS_Funding_Request__c where id = :objRequest.id]);

    System.assertEquals(true, gFRS_FR_Task_Test.checkIfContainsTask(objRequest.id , 'Refund', lTasks));
    //For IMED if Sub_Status__c='Reconciliation Required' also outcomes status will should be created
  }

  public static Boolean checkIfContainsTask(id reqId, string taskType, Map<Id, gFRS_Funding_Request__c> lTasks) {
    if (lTasks != null) {
      for (gFRS_Tasks__c taskItem : lTasks.get(reqId).gFRS_Tasks__r ) {
        if (taskItem.Action_Type__c != null && taskItem.Action_Type__c == taskType) {
          return true;
        }
      }
    } else {
      return false;
    }
    return false;
  }
  public static string checkRfiLink(id reqId, string taskType, Map<Id, gFRS_Funding_Request__c> lTasks) {
    if (lTasks != null) {
      for (gFRS_Tasks__c taskItem : lTasks.get(reqId).gFRS_Tasks__r ) {
        if (taskItem.Action_Type__c != null && taskItem.Action_Type__c == taskType && taskItem.RFI_Link__c != null) {
          return taskItem.RFI_Link__c;
        }
      }
    } else {
      return '';
    }
    return '';
  }

  private class SetUpTestObjects {
    public Account objAccount;
    public Contact objContact;
    public User objUser;

    public List<GFRS_Funding_Request__c> objListRequest = new List<GFRS_Funding_Request__c>();

    public GFRS_Funding_Request__c objRequestCORPORATE;
    public GFRS_Funding_Request__c objRequestEXHIBITS;
    public GFRS_Funding_Request__c objRequestFELLOWSHIPS;
    public GFRS_Funding_Request__c objRequestINITIATED_EXHIBITS;
    public GFRS_Funding_Request__c objRequestHC_CHAR;
    public GFRS_Funding_Request__c objRequestIMED;
    public GFRS_Funding_Request__c objRequestPHILANTHROPIC;
    public GFRS_Funding_Request__c objRequestSCIENTIFIC_PROJECTS;

    public GFRS_Organization__c objOrg;
    public GFRS_Location__c objLoc;

    public SetUpTestObjects() {
      //this.objAccount = gFRS_TestCreationUtils.createAccount( gFRS_TestCreationUtils.makeUnique( 'accTest' ));
      System.debug(LoggingLevel.ERROR, 'iN SetUpTestObjects: ' + Limits.getQueries());
      String gFRSAccountRecordTypeId = [select id from RecordType where SobjectType = 'Account' and Name = 'gFRS'].id;
      this.objAccount = new Account( Name = gFRS_TestCreationUtils.makeUnique( 'accTest' ), RecordTypeId = gFRSAccountRecordTypeId);
      insert this.objAccount;
      System.debug(LoggingLevel.ERROR, 'after insert objAccount: ' + Limits.getQueries());

      this.objOrg = gFRS_TestCreationUtils.createOrganization2( '99-9999912', this.objAccount.id );
      insert this.objOrg;
      System.debug(LoggingLevel.ERROR, 'after insert objOrg: ' + Limits.getQueries());

      this.objLoc = gFRS_TestCreationUtils.createLocation( 'accTestLocation', this.objOrg.id );
      insert this.objloc;
      System.debug(LoggingLevel.ERROR, 'after insert objloc: ' + Limits.getQueries());

      //objContact = gFRS_TestCreationUtils.createContact(objAccount);

      objContact = new Contact(
        FirstName = 'Test',
        LastName = 'Test',
        Email = 'test@test.com',
        Phone = '555-555-555',
        AccountID = objAccount.Id
      );

      insert objContact;
      System.debug(LoggingLevel.ERROR, 'after insert objContact: ' + Limits.getQueries());

      objUser = gFRS_TestCreationUtils.createUser(objContact, 'testEmail@test.com');
      insert objUser;
      System.debug(LoggingLevel.ERROR, 'after insert objUser: ' + Limits.getQueries());


    }

    public void createRequest(String recordType, String rfiType) {

      if (recordType.equals(gFRS_TestCreationUtils.RT_FR_CORPORATE_MEMBERSHIPS_NAME)) {
        objRequestCORPORATE = gFRS_TestCreationUtils.createFundingRequestWithTA( gFRS_TestCreationUtils.RT_FR_CORPORATE_MEMBERSHIPS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, 'Oncology', 'Breast Cancer', rfiType, objOrg.id, objLoc.id );
        insert objRequestCORPORATE;
        System.debug(LoggingLevel.ERROR, 'after insert objRequestCORPORATE: ' + Limits.getQueries());
      } else if (recordType.equals(gFRS_TestCreationUtils.RT_FR_EXHIBITS_OTHER_PROMOS_NAME)) {
        objRequestEXHIBITS = gFRS_TestCreationUtils.createFundingRequestWithTA( gFRS_TestCreationUtils.RT_FR_EXHIBITS_OTHER_PROMOS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, 'Ophthalmology', 'Blindness', rfiType, objOrg.id, objLoc.id );
        objRequestEXHIBITS.Funding_Sub_Type__c = 'Exhibit Booth';
        insert objRequestCORPORATE;
        System.debug(LoggingLevel.ERROR, 'after insert objRequestCORPORATE: ' + Limits.getQueries());
      } else if (recordType.equals(gFRS_TestCreationUtils.RT_FR_FELLOWSHIPS_NAME)) {
        objRequestFELLOWSHIPS = gFRS_TestCreationUtils.createFundingRequestWithTA( gFRS_TestCreationUtils.RT_FR_FELLOWSHIPS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, 'Cardiology', 'Cholesterol', rfiType, objOrg.id, objLoc.id );
        insert objRequestFELLOWSHIPS;
      } else if (recordType.equals(gFRS_TestCreationUtils.RT_FR_FIELD_INITIATED_EXHIBITS_NAME)) {
        objRequestINITIATED_EXHIBITS = gFRS_TestCreationUtils.createFundingRequestWithTA( gFRS_TestCreationUtils.RT_FR_FIELD_INITIATED_EXHIBITS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, 'Transplantation', 'Kidney Transplantation', rfiType, objOrg.id, objLoc.id );
        insert objRequestINITIATED_EXHIBITS;
        System.debug(LoggingLevel.ERROR, 'after insert objRequestINITIATED_EXHIBITS: ' + Limits.getQueries());
      } else if (recordType.equals(gFRS_TestCreationUtils.RT_FR_HC_CHAR_NAME)) {
        objRequestHC_CHAR = gFRS_TestCreationUtils.createFundingRequestWithTA( gFRS_TestCreationUtils.RT_FR_HC_CHAR, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, 'Oncology', 'Breast Cancer', rfiType, objOrg.id, objLoc.id );
        insert objRequestHC_CHAR;
        System.debug(LoggingLevel.ERROR, 'after insert objRequestHC_CHAR: ' + Limits.getQueries());
      } else if (recordType.equals(gFRS_TestCreationUtils.RT_FR_IMED_NAME)) {
        objRequestIMED = gFRS_TestCreationUtils.createFundingRequestWithTA( gFRS_TestCreationUtils.RT_FR_IMED, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, 'Ophthalmology', 'Blindness', rfiType, objOrg.id, objLoc.id );
        insert objRequestIMED;
        System.debug(LoggingLevel.ERROR, 'after insert objRequestIMED: ' + Limits.getQueries());
      } else if (recordType.equals(gFRS_TestCreationUtils.RT_FR_PHILANTHROPIC_NAME)) {
        objRequestPHILANTHROPIC = gFRS_TestCreationUtils.createFundingRequestWithTA( gFRS_TestCreationUtils.RT_FR_PHILANTHROPIC, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, 'Cardiology', 'Cholesterol', rfiType, objOrg.id, objLoc.id );
        insert objRequestPHILANTHROPIC;
        System.debug(LoggingLevel.ERROR, 'after insert objRequestPHILANTHROPIC: ' + Limits.getQueries());
      } else if (recordType.equals(gFRS_TestCreationUtils.RT_FR_SCIENTIFIC_PROJECTS_NAME)) {
        objRequestSCIENTIFIC_PROJECTS = gFRS_TestCreationUtils.createFundingRequestWithTA( gFRS_TestCreationUtils.RT_FR_SCIENTIFIC_PROJECTS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, 'Transplantation', 'Kidney Transplantation', rfiType, objOrg.id, objLoc.id );
        insert objRequestSCIENTIFIC_PROJECTS;
        System.debug(LoggingLevel.ERROR, 'after insert objRequestSCIENTIFIC_PROJECTS: ' + Limits.getQueries());
      }
    }
  }
}