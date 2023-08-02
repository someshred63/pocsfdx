@isTest(seealldata = false)
public class Test_Elf_Scheduler {

    Public static List<sObject> testEventLogFiles;
    
    @isTest static void testElf_Scheduler(){
        User testUser = new User();
        testUser.LastName = 'testUser';
        testUser.TimeZoneSidKey = 'America/Los_Angeles'; 
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.Email = 'test@test.com';
        testUser.UserName = 'test@wxyzthisisatest.com';
        testUser.Alias = 'test';
        testUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1][0].Id;
        insert testUser;
        
        //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


        String orgID = userInfo.getOrganizationID();

        String userId = testUser.Id;

        DateTime timeIsNow = System.Now();
        Integer yr = timeIsNow.Year();
        Integer mo = timeIsNow.Month();
        Integer dy = timeIsNow.Day(); 
        Integer datePartOfTimeStamp = yr + mo + dy;
            //Date testDate = Date.NewInstance(yr, mo, dy);
            //DateTime testDateTime = System.Now().addHours(-24);

        Date testDate = date.NewInstance(2014, 9, 21);
        Time testTime = system.now().time();
        DateTime testDateTime = DateTime.newInstance(testDate, testTime);

        testEventLogFiles = new List<sObject>();

        String testBlobString = '"EVENT_TYPE","TIMESTAMP","REQUEST_ID","ORGANIZATION_ID","USER_ID","RUN_TIME","CLIENT_IP","URI","REQUEST_STATUS","API_TYPE","API_VERSION","CLIENT_NAME","METHOD_NAME","ENTITY_NAME","ROWS_PROCESSED","REQUEST_SIZE","RESPONSE_SIZE","QUERY"\n"API","20140920000104.331","3t8ez0UKrL4Q7rH5ThI0J-","00Do0000000ZMlq","005o0000000xXC0","43","66.192.10.162","Api","","T","31.0","","insert","MetadataContainer","1","402","202",""\n"API","20140920000104.486","3t8ez0FGbGN6lj-Ufx3Xhk","00Do0000000ZMlq","005o0000000xXC0","77","66.192.10.162","Api","","T","31.0","","insert","ApexClassMember,ContainerAsyncRequest","0","1152","203",""';

        Blob testBlob = Blob.ValueOf(testBlobString);

            //testEventLogFile.LogFile = testBlob;

        sObject testEventLogFile = new EventLogFile(EventType = 'API', LogDate = testDateTime, LogFile = testBlob);

        testEventLogFiles.add(testEventLogFile);

        //%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        system.runAs(testUser){

            SFDC2Insights__c s2i = new SFDC2Insights__c(Advanced_Data__c = true,
                                                        Name = 'thisisatest', 
                                                        Custom_Event__c = 'thisisatest', 
                                                        Max_Insights_Intake__c = 1000, 
                                                        NR_Account_ID__c = 'thisistest',
                                                        Integratio_Running_User_Username__c = 'sleibenath@gmail.com');
            insert s2i;

            Id mylf = testEventLogFiles[0].Id;

            ELF_PT__C test_elf_pt = new ELF_PT__c(Log_File_Id__c = mylf, Last_Reported_Event__c=-1, EoF__c=false);
            Insert test_elf_pt;
                        
            Test.startTest();
            Elf_Scheduler m = new Elf_Scheduler();
            DateTime nowPlus2Min = system.now().addMinutes(+2);
            String nowMin = string.valueOf(nowPlus2Min.minute());
            String nowHr = string.valueOf(nowPlus2Min.hour());
            String nowDy = string.valueOf(nowPlus2Min.day());
            String nowMo = string.valueOf(nowPlus2Min.month());
            String nowYr = string.valueOf(nowPlus2Min.year());
            String sched = '0 ' + nowMin + ' ' + nowHr + ' ' + nowDy + ' ' + nowMo + ' ? ' + nowYr;
            String jobID = system.schedule('Test Initiate Elf Scheduler', sched , m);
            Test.stopTest();
        }
    }

    @isTest static void testElf_SchedulerScheduled(){
        User testUser = new User();
        testUser.LastName = 'testUser';
        testUser.TimeZoneSidKey = 'America/Los_Angeles'; 
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.Email = 'test@test.com';
        testUser.UserName = 'test@wxyzthisisatest.com';
        testUser.Alias = 'test';
        testUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1][0].Id;
        insert testUser;

         //WhenDidYouRun__c, HourRun__c, DidYouRun__c FROM SchedulerRun
        system.runAs(testUser){

            SFDC2Insights__c s2i = new SFDC2Insights__c(Advanced_Data__c = true,
                                                        Name = 'thisisatest', 
                                                        Custom_Event__c = 'thisisatest', 
                                                        Max_Insights_Intake__c = 1000, 
                                                        NR_Account_ID__c = 'thisistest');
            insert s2i;
            
            String orgID = userInfo.getOrganizationID();

            String userId = testUser.Id;

            DateTime timeIsNow = System.Now();
            Integer yr = timeIsNow.Year();
            Integer mo = timeIsNow.Month();
            Integer dy = timeIsNow.Day(); 
            Integer datePartOfTimeStamp = yr + mo + dy;
            //Date testDate = Date.NewInstance(yr, mo, dy);
            //DateTime testDateTime = System.Now().addHours(-24);

            Date testDate = date.NewInstance(2014, 9, 21);
            Time testTime = system.now().time();
            DateTime testDateTime = DateTime.newInstance(testDate, testTime);

            testEventLogFiles = new List<sObject>();

            String testBlobString = '"EVENT_TYPE","TIMESTAMP","REQUEST_ID","ORGANIZATION_ID","USER_ID","RUN_TIME","CLIENT_IP","URI","REQUEST_STATUS","API_TYPE","API_VERSION","CLIENT_NAME","METHOD_NAME","ENTITY_NAME","ROWS_PROCESSED","REQUEST_SIZE","RESPONSE_SIZE","QUERY"\n"API","20140920000104.331","3t8ez0UKrL4Q7rH5ThI0J-","00Do0000000ZMlq","005o0000000xXC0","43","66.192.10.162","Api","","T","31.0","","insert","MetadataContainer","1","402","202",""\n"API","20140920000104.486","3t8ez0FGbGN6lj-Ufx3Xhk","00Do0000000ZMlq","005o0000000xXC0","77","66.192.10.162","Api","","T","31.0","","insert","ApexClassMember,ContainerAsyncRequest","0","1152","203",""';

            Blob testBlob = Blob.ValueOf(testBlobString);

            //testEventLogFile.LogFile = testBlob;

            sObject testEventLogFile = new EventLogFile(EventType = 'API', LogDate = testDateTime, LogFile = testBlob);

            testEventLogFiles.add(testEventLogFile);

            Id mylf = testEventLogFiles[0].Id;

            ELF_PT__C test_elf_pt = new ELF_PT__c(Log_File_Id__c = mylf, Last_Reported_Event__c=-1, EoF__c=false);
            Insert test_elf_pt;
            
            Test.startTest();
            Elf_Scheduler m = new Elf_Scheduler();
            DateTime nowPlus2Min = system.now().addMinutes(+2);
            String nowMin = string.valueOf(nowPlus2Min.minute());
            String nowHr = string.valueOf(nowPlus2Min.hour());
            String nowDy = string.valueOf(nowPlus2Min.day());
            String nowMo = string.valueOf(nowPlus2Min.month());
            String nowYr = string.valueOf(nowPlus2Min.year());
            String sched = '0 ' + nowMin + ' ' + nowHr + ' ' + nowDy + ' ' + nowMo + ' ? ' + nowYr;
            String jobID = system.schedule('Test Initiate Elf Scheduler', sched , m);
            Test.stopTest();
        }
    } 

 /*   @isTest static void testElf_BatchLauncher(){
        User testUser = new User();
        testUser.LastName = 'testUser';
        testUser.TimeZoneSidKey = 'America/Los_Angeles'; 
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.Email = 'test@test.com';
        testUser.UserName = 'test@wxyzthisisatest.com';
        testUser.Alias = 'test';
        testUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1][0].Id;
        insert testUser;

        system.runAs(testUser){

            SFDC2Insights__c s2i = new SFDC2Insights__c(Advanced_Data__c = true,
                                                        Name = 'thisisatest', 
                                                        Custom_Event__c = 'thisisatest', 
                                                        Max_Insights_Intake__c = 1000, 
                                                        NR_Account_ID__c = 'thisistest');
            insert s2i;

            DateTime timeIsNow = System.Now();
            Integer yr = timeIsNow.Year();
            Integer mo = timeIsNow.Month();
            Integer dy = timeIsNow.Day(); 
            Integer datePartOfTimeStamp = yr + mo + dy;
            //Date testDate = Date.NewInstance(yr, mo, dy);
            //DateTime testDateTime = System.Now().addHours(-24);

            Date testDate = date.NewInstance(2014, 9, 21);
            Time testTime = system.now().time();
            DateTime testDateTime = DateTime.newInstance(testDate, testTime);

            testEventLogFiles = new List<sObject>();

            String testBlobString = '"EVENT_TYPE","TIMESTAMP","REQUEST_ID","ORGANIZATION_ID","USER_ID","RUN_TIME","CLIENT_IP","URI","REQUEST_STATUS","API_TYPE","API_VERSION","CLIENT_NAME","METHOD_NAME","ENTITY_NAME","ROWS_PROCESSED","REQUEST_SIZE","RESPONSE_SIZE","QUERY","API","20140920000104.331","3t8ez0UKrL4Q7rH5ThI0J-","00Do0000000ZMlq","005o0000000xXC0","43","66.192.10.162","Api","","T","31.0","","insert","MetadataContainer","1","402","202","","API","20140920000104.486","3t8ez0FGbGN6lj-Ufx3Xhk","00Do0000000ZMlq","005o0000000xXC0","77","66.192.10.162","Api","","T","31.0","","insert","ApexClassMember,ContainerAsyncRequest","0","1152","203",""';

            Blob testBlob = Blob.ValueOf(testBlobString);

            //testEventLogFile.LogFile = testBlob;

            sObject testEventLogFile = new EventLogFile(EventType = 'API', LogDate = testDateTime, LogFile = testBlob);

            testEventLogFiles.add(testEventLogFile);

            //Create ElfInfo Lines
            elf_Info.create_elf_Info();

            LogFile_Info__c lfi1 = new LogFile_Info__c( Name = 'This is a Test', of_Events__c = 3, Events_Reported__c = 0, Id__c = '30ATo00000004CIFGA2', LogFile_Type__c = 'API');
            insert lfi1;
            
            EventLogFilePollingHistory__c elfph = new EventLogFilePollingHistory__c();
            elfph.Name = 'Manual Event Log Polling';
            elfph.pollingTime__c = System.now();
            insert elfph;

            Test.startTest();
            String query = 'SELECT CreatedById, CreatedDate, EventType, Id, LastModifiedDate, LogDate, LogFile, LogFileContentType, LogFileLength FROM EventLogFile WHERE CreatedDate < TOMORROW'; 
            ELF_BatchLauncher b = new ELF_BatchLauncher(query, elfph.Id); 
            database.executebatch(b);
            Test.stopTest();
        }
    } 
*/

}