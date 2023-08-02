@isTest
private class GlobalLoggingTest {

    static testMethod void error() {
        
        GlobalLogging logger = new GlobalLogging('GlobalLoggingTest');
          
        String loggedUser = UserInfo.getUserName();
        
        Test.startTest();
        
        logger.error(GlobalLogging.LEVEL_HIGH, GlobalLogging.TYPE_CLASS, 'test description', 'Test Object', 'TestId');
        logger.save();
        
        logger.errorAndSave(GlobalLogging.LEVEL_LOW, GlobalLogging.TYPE_CLASS, 'test description', 'Test Object2', 'TestId2');
                
        Test.stopTest();
        
        List<Error_log_gne__c> logsError = [SELECT 
        								Error_Level_gne__c,
        							  	Code_Type__c,
        							  	Snippet_Name__c,
        							  	User_Name__c,
        							  	Object_Name__c,			
        							  	Record_Id_gne__c,							
        							  	Error_Description__c
        							  FROM
        							  	Error_log_gne__c
        							  WHERE
        							  	Error_Level_gne__c = 'high' AND
        							  	Code_Type__c = 'Apex Class' AND
        							  	Snippet_Name__c = 'GlobalLoggingTest' AND
        							  	User_Name__c = :loggedUser AND
        							  	Object_Name__c = 'Test Object' AND
        							  	Record_Id_gne__c = 'TestId'];
        							  	
      	List<Error_log_gne__c> logsErrorAndSave = [SELECT 
        								Error_Level_gne__c,
        							  	Code_Type__c,
        							  	Snippet_Name__c,
        							  	User_Name__c, 
        							  	Object_Name__c,			
        							  	Record_Id_gne__c,							
        							  	Error_Description__c
        							  FROM
        							  	Error_log_gne__c
        							  WHERE
        							  	Error_Level_gne__c = 'low' AND
        							  	Code_Type__c = 'Apex Class' AND
        							  	Snippet_Name__c = 'GlobalLoggingTest' AND
        							  	User_Name__c = :loggedUser AND
        							  	Object_Name__c = 'Test Object2' AND
        							  	Record_Id_gne__c = 'TestId2'];
        							  	
        System.assertEquals(1, logsError.size()); 
        System.assertEquals(1, logsErrorAndSave.size());
        
    }
    
    static testMethod void warn() {
        
        GlobalLogging logger = new GlobalLogging('GlobalLoggingTest');   
        String loggedUser = UserInfo.getUserName();
        
        Test.startTest();
        
        logger.warn(GlobalLogging.LEVEL_HIGH, GlobalLogging.TYPE_CLASS, 'test description', 'Test Object', 'TestId');
        logger.save();
        
        logger.warnAndSave(GlobalLogging.LEVEL_LOW, GlobalLogging.TYPE_CLASS, 'test description', 'Test Object2', 'TestId2');
                
        Test.stopTest();
        
        List<Error_log_gne__c> logsWarn = [SELECT 
        								Error_Level_gne__c,
        							  	Code_Type__c,
        							  	Snippet_Name__c,
        							  	User_Name__c,
        							  	Object_Name__c,			
        							  	Record_Id_gne__c,							
        							  	Error_Description__c
        							  FROM
        							  	Error_log_gne__c
        							  WHERE
        							  	Error_Level_gne__c = 'high' AND
        							  	Code_Type__c = 'Apex Class' AND
        							  	Snippet_Name__c = 'GlobalLoggingTest' AND
        							  	User_Name__c = :loggedUser AND
        							  	Object_Name__c = 'Test Object' AND
        							  	Record_Id_gne__c = 'TestId'];
        							  	
      	List<Error_log_gne__c> logsWarnAndSave = [SELECT 
        								Error_Level_gne__c,
        							  	Code_Type__c,
        							  	Snippet_Name__c,
        							  	User_Name__c, 
        							  	Object_Name__c,			
        							  	Record_Id_gne__c,							
        							  	Error_Description__c
        							  FROM
        							  	Error_log_gne__c
        							  WHERE
        							  	Error_Level_gne__c = 'low' AND
        							  	Code_Type__c = 'Apex Class' AND
        							  	Snippet_Name__c = 'GlobalLoggingTest' AND
        							  	User_Name__c = :loggedUser AND
        							  	Object_Name__c = 'Test Object2' AND
        							  	Record_Id_gne__c = 'TestId2'];
        							  	
        System.assertEquals(1, logsWarn.size()); 
        System.assertEquals(1, logsWarnAndSave.size());
        
    }
    
    static testMethod void info() {
        
        GlobalLogging logger = new GlobalLogging('GlobalLoggingTest');   
        String loggedUser = UserInfo.getUserName();
        
        Test.startTest();
        
        logger.info(GlobalLogging.LEVEL_HIGH, GlobalLogging.TYPE_CLASS, 'test description', 'Test Object', 'TestId');
        logger.save();
        
        logger.infoAndSave(GlobalLogging.LEVEL_LOW, GlobalLogging.TYPE_CLASS, 'test description', 'Test Object2', 'TestId2');
                
        Test.stopTest();
        
        List<Error_log_gne__c> logsInfo = [SELECT 
        								Error_Level_gne__c,
        							  	Code_Type__c,
        							  	Snippet_Name__c,
        							  	User_Name__c,
        							  	Object_Name__c,			
        							  	Record_Id_gne__c,							
        							  	Error_Description__c
        							  FROM
        							  	Error_log_gne__c
        							  WHERE
        							  	Error_Level_gne__c = 'high' AND
        							  	Code_Type__c = 'Apex Class' AND
        							  	Snippet_Name__c = 'GlobalLoggingTest' AND
        							  	User_Name__c = :loggedUser AND
        							  	Object_Name__c = 'Test Object' AND
        							  	Record_Id_gne__c = 'TestId'];
        							  	
      	List<Error_log_gne__c> logsInfoAndSave = [SELECT 
        								Error_Level_gne__c,
        							  	Code_Type__c,
        							  	Snippet_Name__c,
        							  	User_Name__c, 
        							  	Object_Name__c,			
        							  	Record_Id_gne__c,							
        							  	Error_Description__c
        							  FROM
        							  	Error_log_gne__c
        							  WHERE
        							  	Error_Level_gne__c = 'low' AND
        							  	Code_Type__c = 'Apex Class' AND
        							  	Snippet_Name__c = 'GlobalLoggingTest' AND
        							  	User_Name__c = :loggedUser AND
        							  	Object_Name__c = 'Test Object2' AND
        							  	Record_Id_gne__c = 'TestId2'];
        							  	
        System.assertEquals(1, logsInfo.size()); 
        System.assertEquals(1, logsInfoAndSave.size());
        
    }
    
    static testMethod void debug() {
        
        GlobalLogging logger = new GlobalLogging('GlobalLoggingTest');   
        String loggedUser = UserInfo.getUserName();
        
        Test.startTest();
        
        logger.debug(GlobalLogging.LEVEL_HIGH, GlobalLogging.TYPE_CLASS, 'test description', 'Test Object', 'TestId');
        logger.save();
        
        logger.debugAndSave(GlobalLogging.LEVEL_LOW, GlobalLogging.TYPE_CLASS, 'test description', 'Test Object2', 'TestId2');
                
        Test.stopTest();
        
        List<Error_log_gne__c> logsDebug = [SELECT 
        								Error_Level_gne__c,
        							  	Code_Type__c,
        							  	Snippet_Name__c,
        							  	User_Name__c,
        							  	Object_Name__c,			
        							  	Record_Id_gne__c,							
        							  	Error_Description__c
        							  FROM
        							  	Error_log_gne__c
        							  WHERE
        							  	Error_Level_gne__c = 'high' AND
        							  	Code_Type__c = 'Apex Class' AND
        							  	Snippet_Name__c = 'GlobalLoggingTest' AND
        							  	User_Name__c = :loggedUser AND
        							  	Object_Name__c = 'Test Object' AND
        							  	Record_Id_gne__c = 'TestId'];
        							  	
      	List<Error_log_gne__c> logsDebugAndSave = [SELECT 
        								Error_Level_gne__c,
        							  	Code_Type__c,
        							  	Snippet_Name__c,
        							  	User_Name__c,
        							  	Object_Name__c,			
        							  	Record_Id_gne__c,							
        							  	Error_Description__c
        							  FROM
        							  	Error_log_gne__c
        							  WHERE
        							  	Error_Level_gne__c = 'low' AND
        							  	Code_Type__c = 'Apex Class' AND
        							  	Snippet_Name__c = 'GlobalLoggingTest' AND
        							  	User_Name__c = :loggedUser AND
        							  	Object_Name__c = 'Test Object2' AND
        							  	Record_Id_gne__c = 'TestId2'];
        							  	
        System.assertEquals(1, logsDebug.size()); 
        System.assertEquals(1, logsDebugAndSave.size());
        
    }
    
    static testMethod void fine() {
        
        GlobalLogging logger = new GlobalLogging('GlobalLoggingTest');   
        String loggedUser = UserInfo.getUserName();
        
        Test.startTest();
        
        logger.fine(GlobalLogging.LEVEL_HIGH, GlobalLogging.TYPE_CLASS, 'test description', 'Test Object', 'TestId');
        logger.save();
        
        logger.fineAndSave(GlobalLogging.LEVEL_LOW, GlobalLogging.TYPE_CLASS, 'test description', 'Test Object2', 'TestId2');
                
        Test.stopTest();
        
        List<Error_log_gne__c> logsFine = [SELECT 
        								Error_Level_gne__c,
        							  	Code_Type__c,
        							  	Snippet_Name__c,
        							  	User_Name__c,
        							  	Object_Name__c,			
        							  	Record_Id_gne__c,							
        							  	Error_Description__c
        							  FROM
        							  	Error_log_gne__c
        							  WHERE
        							  	Error_Level_gne__c = 'high' AND
        							  	Code_Type__c = 'Apex Class' AND
        							  	Snippet_Name__c = 'GlobalLoggingTest' AND
        							  	User_Name__c = :loggedUser AND
        							  	Object_Name__c = 'Test Object' AND
        							  	Record_Id_gne__c = 'TestId'];
        							  	
      	List<Error_log_gne__c> logsFineAndSave = [SELECT 
        								Error_Level_gne__c,
        							  	Code_Type__c,
        							  	Snippet_Name__c,
        							  	User_Name__c,
        							  	Object_Name__c,			
        							  	Record_Id_gne__c,							
        							  	Error_Description__c
        							  FROM
        							  	Error_log_gne__c
        							  WHERE
        							  	Error_Level_gne__c = 'low' AND
        							  	Code_Type__c = 'Apex Class' AND
        							  	Snippet_Name__c = 'GlobalLoggingTest' AND
        							  	User_Name__c = :loggedUser AND
        							  	Object_Name__c = 'Test Object2' AND
        							  	Record_Id_gne__c = 'TestId2'];
        							  	
        System.assertEquals(1, logsFine.size()); 
        System.assertEquals(1, logsFineAndSave.size());
        
    }
    
    static testMethod void finer() {
        
        GlobalLogging logger = new GlobalLogging('GlobalLoggingTest');   
        String loggedUser = UserInfo.getUserName();
        
        Test.startTest();
        
        logger.finer(GlobalLogging.LEVEL_HIGH, GlobalLogging.TYPE_CLASS, 'test description', 'Test Object', 'TestId');
        logger.save();
        
        logger.finerAndSave(GlobalLogging.LEVEL_LOW, GlobalLogging.TYPE_CLASS, 'test description', 'Test Object2', 'TestId2');
                
        Test.stopTest();
        
        List<Error_log_gne__c> logsFiner = [SELECT 
        								Error_Level_gne__c,
        							  	Code_Type__c,
        							  	Snippet_Name__c,
        							  	User_Name__c,
        							  	Object_Name__c,			
        							  	Record_Id_gne__c,							
        							  	Error_Description__c
        							  FROM
        							  	Error_log_gne__c
        							  WHERE
        							  	Error_Level_gne__c = 'high' AND
        							  	Code_Type__c = 'Apex Class' AND
        							  	Snippet_Name__c = 'GlobalLoggingTest' AND
        							  	User_Name__c = :loggedUser AND
        							  	Object_Name__c = 'Test Object' AND
        							  	Record_Id_gne__c = 'TestId'];
        							  	
      	List<Error_log_gne__c> logsFinerAndSave = [SELECT 
        								Error_Level_gne__c,
        							  	Code_Type__c,
        							  	Snippet_Name__c,
        							  	User_Name__c,
        							  	Object_Name__c,			
        							  	Record_Id_gne__c,							
        							  	Error_Description__c
        							  FROM
        							  	Error_log_gne__c
        							  WHERE
        							  	Error_Level_gne__c = 'low' AND
        							  	Code_Type__c = 'Apex Class' AND
        							  	Snippet_Name__c = 'GlobalLoggingTest' AND
        							  	User_Name__c = :loggedUser AND
        							  	Object_Name__c = 'Test Object2' AND
        							  	Record_Id_gne__c = 'TestId2'];
        							  	
        System.assertEquals(1, logsFiner.size()); 
        System.assertEquals(1, logsFinerAndSave.size());
        
    }
    
    static testMethod void finest() {
        
        GlobalLogging logger = new GlobalLogging('GlobalLoggingTest');   
        String loggedUser = UserInfo.getUserName();
        
        Test.startTest();
        
        logger.finest(GlobalLogging.LEVEL_HIGH, GlobalLogging.TYPE_CLASS, 'test description', 'Test Object', 'TestId');
        logger.save();
        
        logger.finestAndSave(GlobalLogging.LEVEL_LOW, GlobalLogging.TYPE_CLASS, 'test description', 'Test Object2', 'TestId2');
                
        Test.stopTest();
        
        List<Error_log_gne__c> logsFinest = [SELECT 
        								Error_Level_gne__c,
        							  	Code_Type__c,
        							  	Snippet_Name__c,
        							  	User_Name__c,
        							  	Object_Name__c,			
        							  	Record_Id_gne__c,							
        							  	Error_Description__c
        							  FROM
        							  	Error_log_gne__c
        							  WHERE
        							  	Error_Level_gne__c = 'high' AND
        							  	Code_Type__c = 'Apex Class' AND
        							  	Snippet_Name__c = 'GlobalLoggingTest' AND
        							  	User_Name__c = :loggedUser AND
        							  	Object_Name__c = 'Test Object' AND
        							  	Record_Id_gne__c = 'TestId'];
        							  	
      	List<Error_log_gne__c> logsFinestAndSave = [SELECT 
        								Error_Level_gne__c,
        							  	Code_Type__c,
        							  	Snippet_Name__c,
        							  	User_Name__c,
        							  	Object_Name__c,			
        							  	Record_Id_gne__c,							
        							  	Error_Description__c
        							  FROM
        							  	Error_log_gne__c
        							  WHERE
        							  	Error_Level_gne__c = 'low' AND
        							  	Code_Type__c = 'Apex Class' AND
        							  	Snippet_Name__c = 'GlobalLoggingTest' AND
        							  	User_Name__c = :loggedUser AND
        							  	Object_Name__c = 'Test Object2' AND
        							  	Record_Id_gne__c = 'TestId2'];
        							  	
        System.assertEquals(1, logsFinest.size()); 
        System.assertEquals(1, logsFinestAndSave.size());
        
    }
}