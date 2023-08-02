/************************************************************
*  @author: Krzysztof Wilczek, Roche
*  Date: 2011-06-03
*  Description: 
*  Helper class for Request Assignment  
*  Modification History
*  Date        Name        Description
*            
//Modified by Shweta B: 6/9/2011 - Added logic to identify if urgent & today queue activities (both) exists then 
//assign only those queue activities and do not assign anything from the regular queue.     

//Modified by Lukasz K: 2011-08-01 - Added new parameter to getWorkAssigments method - current hour
*************************************************************/

public without sharing class GNE_CM_Request_Assignment_Helper 
{   
    public static Boolean skipProfileValidation = false;
    //constants:
    public static final String REQUEST_ASSIGNMENT_VALID_PROFILE = 'GNE_CM_Queue_Request_Assignment_User_Profiles';
    public static final String REQUEST_ASSIGNMENT_MONITORING = 'GNE_CM_Request_Assignment_Monitoring';
    public static final String REQUEST_ASSIGNMENT_NOT_COUNT = 'CM_TASK_SUBJECT_NOT_COUNTED';    
    private static final String URGENT_QUEUE = GNE_CM_Task_Queue_Mgmt_Helper.QueueNames.Urgent.name();
    private static final String TODAY_QUEUE = GNE_CM_Task_Queue_Mgmt_Helper.QueueNames.Today.name();
    private static final String REGULAR_QUEUE = GNE_CM_Task_Queue_Mgmt_Helper.QueueNames.Regular.name();
    private static final String SUCCESS_STATE = GNE_CM_Task_Queue_Mgmt_Helper.ProcessingStatuses.Successful.name();
    
    //public static List<Task> getWorkAssignments(Id currentUserId, Id genericUserId, Integer currentHour)
    public static List<Task> getWorkAssignments(Map<String, List<Environment_Variables__c>> envVarMultiValues, Id currentUserId, Id genericUserId, Integer currentHour)
    {
        //List<Task> result = new List<Task>();
        List<Task> update_result = new List<Task>();
        //Set<Integer> allTimeZones = new Set<Integer>();
        Set<Integer> validTimeZone = new Set<Integer>();
        Set<Integer> validTimeZone_Urgent_Today = new Set<Integer>();   
        List<Task> urgentList = new List<Task>();
        List<Task> todayList = new List<Task>();
        List<Task> Urgent_task = new List<Task>();
        List<Task> Regular_Task_list_SQ_VTZ = new List<Task>();
        List<Task> Regular_Task_list_SQ_ATZ = new List<Task>();
        List<Task> Today_task = new List<Task>();
        List<Task> Regular_Task_List = new List<Task>();
        List<Task> Past_Due_Regular_task = new List<Task>();
        List<Task> Future_Regular_task = new List<Task>();
        List<Task> activityList = new List<Task>();
        //Integer currentHour = Datetime.now().hour();
        Boolean no_activities_found = false; 
        Boolean Past_Due_Tasks = false;       
        Set<Id> check_update_task = new Set<Id>();
        Integer assign_urgent = 0;
        //Integer assign_Today = 0;    
        //Integer assign_new_activities = 0;  
        Set<String> task_subject_exclude = getExcludedSubjects(envVarMultiValues); //from env variable map
		/*
		Set<String> task_subject_exclude = new Set<String>();
		String env = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
		for(GNE_CM_Queue_Task_Subject_Exclude__c envVar : GNE_CM_Queue_Task_Subject_Exclude__c.getAll().values()){
			if(envVar.Environment__c == env || envVar.Environment__c.toLowerCase() == 'all'){
				task_subject_exclude.add(envVar.value__c.toUpperCase());
		    }
		}
		*/
		
        Integer min_urgent_activities = Integer.valueOf(CustomSettingsHelper.taskQueueSelf().getQueueConfig().get(CustomSettingsHelper.CM_TASK_QUEUE_CONFIG).Request_Assignment_Num_Urgent_Queue_gne__c);
        Integer min_today_activities = Integer.valueOf(CustomSettingsHelper.taskQueueSelf().getQueueConfig().get(CustomSettingsHelper.CM_TASK_QUEUE_CONFIG).Request_Assignment_Num_Today_Queue_gne__c);
        //Integer target_max_activities = Integer.valueOf(CustomSettingsHelper.taskQueueSelf().getQueueConfig().get(CustomSettingsHelper.CM_TASK_QUEUE_CONFIG).Request_Assignment_Num_Today_Queue_gne__c);  
        Integer min_activities = Integer.valueOf(CustomSettingsHelper.taskQueueSelf().getQueueConfig().get(CustomSettingsHelper.CM_TASK_QUEUE_CONFIG).Request_Assignment_Minimum_Activities__c);      
        String queue_status = envVarMultiValues.get(GNE_CM_Task_Queue_Mgmt_Helper.QUEUE_BUILD_STATUS)[0].Value__c;
		/*
		String queue_status;
		for(GNE_CM_Queue_Build_Status__c envVar : GNE_CM_Queue_Build_Status__c.getAll().values()){
			if(envVar.Environment__c == env || envVar.Environment__c.toLowerCase() == 'all'){
				queue_status = envVar.value__c;
				break;
		    }
		}
        */
        
        Integer target_min_activities = Integer.valueOf(CustomSettingsHelper.taskQueueSelf().getQueueConfig().get(CustomSettingsHelper.CM_TASK_QUEUE_CONFIG).Target_Number_Activities_Asgmt_Group_gne__c);
        Integer target_max_activities = Integer.valueOf(CustomSettingsHelper.taskQueueSelf().getQueueConfig().get(CustomSettingsHelper.CM_TASK_QUEUE_CONFIG).Max_Number_Activities_Asgmt_Group_gne__c);
        Set<Id> excludedUsers = GNE_CM_Task_Queue_Mgmt_Helper.getExcludedUsers();
        Boolean urgent_today_flag = true;       
        List<Task> task_remove = new List<Task>();
        Integer Time_Zone_Number;       
        
        //Check for other activities in the system      
        for(GNE_CM_TimeZone_Mapping_gne__c t : [Select CM_TimeZone_StartTime_gne__c, CM_TimeZone_Number_gne__c, CM_TimeZone_EndTime_gne__c From GNE_CM_TimeZone_Mapping_gne__c])
        {                                              
            if(t.CM_TimeZone_StartTime_gne__c <= currentHour && t.CM_TimeZone_EndTime_gne__c > currentHour)
            {               
                validTimeZone.add(Integer.valueOf(t.CM_TimeZone_Number_gne__c)); 
                system.debug('TZ START*************** ' + t.CM_TimeZone_StartTime_gne__c + ' END TIME  ********************* ' + t.CM_TimeZone_EndTime_gne__c);               
            }
            //allTimeZones.add(Integer.valueOf(t.CM_TimeZone_Number_gne__c));                                    
        }
        system.debug('VALID TIME ZONES *************** ' + validTimeZone);
        //system.debug('ALL TIME ZONES *************** ' + allTimeZones);
        system.debug('CURRENT HOUR ********************* ' + currentHour);
        
        List<String> allSubjectProducts = GNE_CM_Task_Queue_Mgmt_Helper.getAllSubjectProducts();
                
        try
        {
            system.debug('POINT 1 *************************');
            //List<String> queueNames = new List<String>{URGENT_QUEUE, TODAY_QUEUE}; 
            
            // Urgent tasks in valid time zones
            //DY PSF-508 start
            urgentList = [SELECT id,Subject,What.Name,who.Name,OwnerId,Owner.Name, ActivityDate, CM_Queue_Name_gne__c, CM_Queue_TimeZone_Number_gne__c 
                        FROM Task WHERE OwnerId =: GenericUserId  and CM_Queue_Name_gne__c = :URGENT_QUEUE
                        and ((Subject Not IN :task_subject_exclude) OR (Product_gne__c IN :allSubjectProducts))
                        AND CM_Queue_TimeZone_Number_gne__c IN :validTimeZone
                        AND CreatedById NOT IN : excludedUsers
                        and isClosed = false
                        AND ActivityDate <= today 
                        order by  ActivityDate, CM_Queue_TimeZone_Number_gne__c limit 1000];
            system.debug('urgent List VTZ *************************' + urgentList);
            
            // if no urgent tasks found for valid time zones, tasks are picked irrespective of time zone (i.e. all time zones are considered)
            if(urgentList.size() == 0)
            {
                urgentList = [SELECT id,Subject,What.Name,who.Name,OwnerId,Owner.Name, ActivityDate, CM_Queue_Name_gne__c, CM_Queue_TimeZone_Number_gne__c 
                            FROM Task WHERE OwnerId =: GenericUserId  and CM_Queue_Name_gne__c = :URGENT_QUEUE
                            and ((Subject Not IN :task_subject_exclude) OR (Product_gne__c IN :allSubjectProducts))
                            AND CreatedById NOT IN : excludedUsers
                            and isClosed = false
                            AND ActivityDate <= today 
                            order by  ActivityDate, CM_Queue_TimeZone_Number_gne__c limit 1000];
                system.debug('urgent List ATZ *************************' + urgentList);
            }
            ////DY PSF-508 end
            // Today tasks in valid time zones
            todayList = [SELECT id,Subject,What.Name,who.Name,OwnerId,Owner.Name, ActivityDate, CM_Queue_Name_gne__c, CM_Queue_TimeZone_Number_gne__c 
                        FROM Task WHERE OwnerId =: GenericUserId  and CM_Queue_Name_gne__c = :TODAY_QUEUE
                        and ((Subject Not IN :task_subject_exclude) OR (Product_gne__c IN :allSubjectProducts))
                        AND CM_Queue_TimeZone_Number_gne__c IN :validTimeZone
                        AND CreatedById NOT IN : excludedUsers
                        and isClosed = false
                        and ActivityDate = today
                        order by  ActivityDate, CM_Queue_TimeZone_Number_gne__c limit 1000];
            system.debug('Today List VTZ *************************' + todayList);
            
            // if no today tasks found in valid time zones, then all time zones are considered
            if(todayList.size() == 0)
            {               
                todayList = [SELECT id,Subject,What.Name,who.Name,OwnerId,Owner.Name, ActivityDate, CM_Queue_Name_gne__c, CM_Queue_TimeZone_Number_gne__c 
                            FROM Task WHERE OwnerId =: GenericUserId  and CM_Queue_Name_gne__c = :TODAY_QUEUE
                            and ((Subject Not IN :task_subject_exclude) OR (Product_gne__c IN :allSubjectProducts))
                            AND CreatedById NOT IN : excludedUsers
                            and isClosed = false
                            and ActivityDate = today
                            order by ActivityDate, CM_Queue_TimeZone_Number_gne__c limit 1000];
                system.debug('Today List ATZ *************************' + todayList);
            }
        }
        catch(Exception e)
        {
            
            Error_Log_gne__c error = new Error_Log_gne__c(Object_Name__c = 'GNE_CM_Request_Assignment_Helper', 
                                                        Error_Level_gne__c = 'Low',
                                                        Snippet_Name__c = 'Urgent_Today Tasks', 
                                                        Code_Type__c = 'Apex Class', 
                                                        Error_Description__c = GlobalUtils.getExceptionDescription(e), 
                                                        User_Name__c = UserInfo.getUserName());                                         
            insert error;
            urgentList = new List<Task>();
        }                       
        
        // assigning urgent tasks if found
        for(Integer i=0; i<urgentList.size(); i++)
        {
            if(assign_urgent < min_urgent_activities)
            {
                urgentList[i].OwnerId = currentUserId;
                update_result.add(urgentList[i]);                                             
                check_update_task.add(urgentList[i].Id);
                assign_urgent++;
                system.debug('Task ID **************** ' + urgentList[i].Id);
            }
            else
            {
                break;
            }
        }
        //Regular Q will be processed only if the queue building was successful
        system.debug('QUEUE BUILD STATUS ************** ' + queue_status);
        Integer numberOfDaysInTheFuture = Integer.valueOf(CustomSettingsHelper.taskQueueSelf().getQueueConfig().get(CustomSettingsHelper.CM_TASK_QUEUE_CONFIG).Queue_Next_N_Days_gne__c);
        Date nDaysInFuture = system.today().addDays(numberOfDaysInTheFuture);
        if(queue_status == SUCCESS_STATE)   
        {
            system.debug('POINT 4 *************************');
            system.debug('target_min_activities  *************************' +target_min_activities);
            try
            {
                Regular_Task_list_SQ_VTZ = [SELECT CM_Queue_Group_Assignment_Number_gne__c FROM Task
                                            WHERE OwnerId =: GenericUserId and CM_Queue_Name_gne__c =: REGULAR_QUEUE
                                            AND CM_Queue_TimeZone_Number_gne__c IN :validTimeZone
                                            AND CreatedById NOT IN : excludedUsers  
                                            and ActivityDate <: nDaysInFuture                                     
                                            order by CM_Queue_Group_Due_Date_gne__c, CM_Queue_Group_Assignment_Number_gne__c limit 1];
                system.debug('Regular Task List Count VTZ ****************  ' + Regular_Task_list_SQ_VTZ);
                
                if(Regular_Task_list_SQ_VTZ.size() > 0)
                {                   
                    //Enhancement 1 to bring act b/w 15-20
                    Regular_Task_List = [SELECT id,Subject,What.Name,who.Name,OwnerId,Owner.Name, ActivityDate, CM_Queue_Name_gne__c, CM_Queue_Group_Due_Date_gne__c, CM_Queue_TimeZone_Number_gne__c, CM_Queue_Group_Assignment_Number_gne__c 
                                        FROM Task WHERE CM_Queue_Group_Assignment_Number_gne__c = :Regular_Task_list_SQ_VTZ[0].CM_Queue_Group_Assignment_Number_gne__c
                                        and isClosed = false
                                        and OwnerId =: GenericUserId and CM_Queue_Name_gne__c =: REGULAR_QUEUE
                                        and ActivityDate <: nDaysInFuture
                                        AND CreatedById NOT IN : excludedUsers limit 1000];
                    
                    system.debug('Regular_Task_List ATZ *************************' + Regular_Task_List);
                    
                }
                else 
                {   
                    Regular_Task_list_SQ_ATZ = [SELECT CM_Queue_Group_Assignment_Number_gne__c FROM Task
                                                WHERE OwnerId =: GenericUserId and CM_Queue_Name_gne__c =: REGULAR_QUEUE
                                                AND CreatedById NOT IN : excludedUsers
                                                and ActivityDate <: nDaysInFuture
                                                order by CM_Queue_Group_Due_Date_gne__c, CM_Queue_Group_Assignment_Number_gne__c limit 1];
                    if(Regular_Task_list_SQ_ATZ.size() > 0)
                    {
                        system.debug('Regular Task List Count 2 ***************  ' + Regular_Task_list_SQ_ATZ);
                        Regular_Task_List = [SELECT id,Subject,What.Name,who.Name,OwnerId,Owner.Name, ActivityDate, CM_Queue_Name_gne__c, CM_Queue_Group_Due_Date_gne__c, CM_Queue_TimeZone_Number_gne__c, CM_Queue_Group_Assignment_Number_gne__c 
                                            FROM Task WHERE CM_Queue_Group_Assignment_Number_gne__c =: Regular_Task_list_SQ_ATZ[0].CM_Queue_Group_Assignment_Number_gne__c
                                            and isClosed = false
                                            and OwnerId =: GenericUserId and CM_Queue_Name_gne__c =: REGULAR_QUEUE
                                            and ActivityDate <: nDaysInFuture
                                            AND CreatedById NOT IN : excludedUsers limit 1000];
                        
                        system.debug('Regular_Task_List W/O VALID TIME ZONE COND *************************' + Regular_Task_List);
                        
                    }
                }
            }
            catch(Exception e)
            {
                Error_Log_gne__c error = new Error_Log_gne__c(Object_Name__c = 'GNE_CM_Request_Assignment_Helper', 
                                                            Error_Level_gne__c = 'Low',
                                                            Snippet_Name__c = 'Regular Tasks', 
                                                            Code_Type__c = 'Apex Class', 
                                                            Error_Description__c = GlobalUtils.getExceptionDescription(e), 
                                                            User_Name__c = UserInfo.getUserName());                                         
                insert error;            
                Regular_Task_List = new List<Task>();
            }
            
            for(Integer r=0; r<Regular_Task_List.size(); r++)
            {       
                system.debug('POINT 5 *************************');      
                if(Regular_Task_List[r].CM_Queue_Group_Due_Date_gne__c < System.today())
                {
                    Past_Due_Tasks = true;
                    break;
                }
            }
            system.debug('Past_Due_Regular_task exist? ****************  ' + Past_Due_Tasks);
        } // End of Q build success check loop
        
        //If urgent and today are there and no past due then only assign urgent and today. Section 3.2.4.
        if(Past_Due_Tasks == false && todayList.size() > 0 && urgentList.size() > 0)
        {
            addTasksFromTodayQueue(todayList, update_result, check_update_task, min_today_activities, currentUserId);
        }
        // if past due exist then assign from Regular Q               
        else if(Past_Due_Tasks == true)
        {
            addTasksFromRegularQueue(Regular_Task_List, update_result, validTimeZone, genericUserId, currentUserId, check_update_task, excludedUsers, target_max_activities, target_min_activities, queue_status);
        }
        // If only today and NO urgent and NO past due in regular then assign from regular and today Section 3.2.3
        else if(Past_Due_Tasks == false && todayList.size() > 0 && urgentList.size() == 0)
        {
            addTasksFromTodayQueue(todayList, update_result, check_update_task, min_today_activities, currentUserId);
            addTasksFromRegularQueue(Regular_Task_List, update_result, validTimeZone, genericUserId, currentUserId, check_update_task, excludedUsers, target_max_activities, target_min_activities, queue_status);
        }
        else if(Past_Due_Tasks == false && todayList.size() == 0 && urgentList.size() > 0)
        {
            addTasksFromRegularQueue(Regular_Task_List, update_result, validTimeZone, genericUserId, currentUserId, check_update_task, excludedUsers, target_max_activities, target_min_activities, queue_status);
        }
        
        // if no tasks in urgent, Today or Regular Qs
        if(todayList.size() == 0 && urgentList.size() == 0 && Regular_Task_List.size() == 0)
        {
            no_activities_found = true;
        }
        // this part executes when either no tasks found in any Q or the queue building process failed, it then assigns 15 oldest tasks
        if(queue_status != SUCCESS_STATE || no_activities_found) //SUCCESS_STATE
        {
            Set<String> validRecordTypes = new Set<String>{GNE_CM_Task_Queue_Mgmt_Helper.GATCF_RECORD_TYPE, 
                                                            GNE_CM_Task_Queue_Mgmt_Helper.GES_RECORD_TYPE};
            activityList = [SELECT id,Subject,What.Name,who.Name,OwnerId,Owner.Name, ActivityDate, CM_Queue_Name_gne__c, CM_Queue_TimeZone_Number_gne__c 
                            FROM Task WHERE OwnerId =: GenericUserId  
                            and ((Subject Not IN :task_subject_exclude) OR (Product_gne__c IN :allSubjectProducts))
                            AND CM_Case_Record_Type_Name_gne__c IN : validRecordTypes
                            and CM_Queue_TimeZone_Number_gne__c IN :validTimeZone
                            AND isClosed = false
                            and Id NOT IN :check_update_task
                            AND CreatedById NOT IN : excludedUsers
                            ORDER BY activityDate, CM_Queue_TimeZone_Number_gne__c LIMIT :target_min_activities];  
            //ORDER BY activityDate LIMIT :target_min_activities];          
            system.debug('activityList VTZ *************************' + activityList);
            
            if(activityList.size() == 0)
            {
                activityList = [SELECT id,Subject,What.Name,who.Name,OwnerId,Owner.Name, ActivityDate, CM_Queue_Name_gne__c, CM_Queue_TimeZone_Number_gne__c 
                                FROM Task WHERE OwnerId =: GenericUserId  
                                and ((Subject Not IN :task_subject_exclude) OR (Product_gne__c IN :allSubjectProducts))
                                AND CM_Case_Record_Type_Name_gne__c IN : validRecordTypes
                                AND isClosed = false
                                and Id NOT IN :check_update_task
                                AND CreatedById NOT IN : excludedUsers
                                ORDER BY activityDate, CM_Queue_TimeZone_Number_gne__c LIMIT :target_min_activities];  
                //ORDER BY activityDate LIMIT :target_min_activities];          
                system.debug('activityList ATZ *************************' + activityList);
            }
            
            for(Integer p=0; p<activityList.size(); p++)
            {
                activityList[p].OwnerId = currentUserId;                  
                update_result.add(activityList[p]);                 
            }
            system.debug('UPDATE LIST COUNT  *************************' + update_result.size());
        }
        return update_result;
    }
    
    private static void addTasksFromTodayQueue(List<Task> todayList, List<Task> update_result, Set<Id> check_update_task, Integer min_today_activities, Id currentUserId)
    {
        Integer assign_Today = 0;
        for(Integer j=0; j<todayList.size(); j++)
        {
            if(assign_Today < min_today_activities)
            {
                todayList[j].OwnerId = currentUserId;
                update_result.add(todayList[j]);                      
                check_update_task.add(todayList[j].Id);
                system.debug('Task ID **************** ' + todayList[j].Id);
                assign_Today++;
            }
        }
    }
    
    private static void addTasksFromRegularQueue(List<Task> Regular_Task_List, List<Task> update_result, Set<Integer> validTimeZone, Id genericUserId, Id currentUserId, Set<Id> check_update_task, Set<Id> excludedUsers, Integer target_max_activities, Integer target_min_activities, String queue_status)
    {
        List<Task> result = new List<Task>();
        Integer assign_new_activities = 0;
        system.debug('POINT 6 *************************');
        for(Integer l=0; l<Regular_Task_List.size(); l++)
        {
            system.debug('POINT 7 *************************');
            Regular_Task_List[l].OwnerId = currentUserId;
            result.add(Regular_Task_List[l]);                           
            check_update_task.add(Regular_Task_List[l].Id);
            assign_new_activities++;                
        }
        // After assigning oldest group, number of new tasks assigned is still less than the minimum tasks assigned,
        // then the next oldes group from regular would be assigned
        if(assign_new_activities < target_min_activities && queue_status == SUCCESS_STATE)
        {
            assignMoreWorkAssignments(update_result, validTimeZone, genericUserId, currentUserId, check_update_task, excludedUsers, assign_new_activities, target_max_activities, target_min_activities, result);
        }
        else
        {
            for (Integer k=0; k<result.size(); k++)
            {
                update_result.add(result[k]);
            }
        }
    }
    
    private static void assignMoreWorkAssignments(List<Task> update_result, Set<Integer> validTimeZone, Id genericUserId, Id currentUserId, Set<Id> check_update_task, Set<Id> excludedUsers, Integer assign_new_activities, Integer target_max_activities, Integer target_min_activities, List<Task> result)
    {
        Decimal groupNumberToRemove;
        Decimal groupNumber;
        Integer numberOfDaysInTheFuture = Integer.valueOf(CustomSettingsHelper.taskQueueSelf().getQueueConfig().get(CustomSettingsHelper.CM_TASK_QUEUE_CONFIG).Queue_Next_N_Days_gne__c);
        Date nDaysInFuture = system.today().addDays(numberOfDaysInTheFuture);       
        
        List<Task> Regular_Task_List_Assign = [SELECT CM_Queue_Group_Assignment_Number_gne__c FROM Task
                                            WHERE isClosed = false AND OwnerId =: GenericUserId and CM_Queue_Name_gne__c =: REGULAR_QUEUE
                                            AND CM_Queue_TimeZone_Number_gne__c IN :validTimeZone
                                            and Id NOT IN :check_update_task
                                            AND CreatedById NOT IN : excludedUsers 
                                            and ActivityDate <: nDaysInFuture                                      
                                            order by CM_Queue_Group_Due_Date_gne__c, CM_Queue_Group_Assignment_Number_gne__c limit 1000];
        
        system.debug('Regular_Task_List_Assign..................' + Regular_Task_List_Assign);
        
        for(Integer l=0; l<Regular_Task_List_Assign.size(); l++)
        {
            if(assign_new_activities < target_max_activities && 
                (assign_new_activities != target_min_activities || groupNumber == Regular_Task_List_Assign[l].CM_Queue_Group_Assignment_Number_gne__c))
            {
                system.debug('POINT 7 After*************************');
                Regular_Task_List_Assign[l].OwnerId = currentUserId;
                result.add(Regular_Task_List_Assign[l]);                            
                check_update_task.add(Regular_Task_List_Assign[l].Id);
                system.debug('Task ID **************** ' + Regular_Task_List_Assign[l].Id);
                assign_new_activities++;
                groupNumber = Regular_Task_List_Assign[l].CM_Queue_Group_Assignment_Number_gne__c;
            }
            else if(Regular_Task_List_Assign[l].CM_Queue_Group_Assignment_Number_gne__c == groupNumber)
            {
                system.debug('POINT 8 *************************');
                groupNumberToRemove = Regular_Task_List_Assign[l].CM_Queue_Group_Assignment_Number_gne__c;
                break;
            }
        }
        
        system.debug('Activity list size before removal *************************' + result.size());
        for(Integer k=0; k<result.size(); k++)
        {           
            if(result[k].CM_Queue_Group_Assignment_Number_gne__c != groupNumberToRemove)
            {
                system.debug('RESULT SET**** ' + k);
                update_result.add(result[k]);               
                system.debug('Task ID **************** ' + result[k].Id);
                //system.debug('POINT 9 REMOVING ELEMENTS FROM LIST  check_update_task *************************' + check_update_task);
            }
            else
            {
                check_update_task.remove(result[k].Id);
                system.debug('POINT 9 REMOVING ELEMENTS FROM LIST  check_update_task *************************' + check_update_task);
            }
        }
        system.debug('Activity list size after removal *************************' + update_result.size());  
    }
    
    
    public static Boolean validateRequestTime(Integer startOffHour, Integer endOffHour, Integer currentHour)
    {
        system.debug('INSIDE CONDITION FOR TIME CHECK');
        Boolean result = false;
        if(startOffHour < endOffHour) //ex: 8-10
        {
            if(currentHour >= startOffHour && currentHour < endOffHour)
            {
                result = true;
            }
        }
        else if(startOffHour == endOffHour) //ex: 11
        {
            if(currentHour == startOffHour)
            {
                result = true;
            }
        }
        else //ex: 23-5
        {
            if(currentHour >= startOffHour || currentHour < endOffHour)
            {
                result = true;
            }
        }       
        return result;
    }
    
    private static Set<String> getExcludedSubjects(Map<String, List<Environment_Variables__c>> envVarMultiValues)
    {
        return getSetOfValuesFromEnvVariable(envVarMultiValues, GNE_CM_Task_Queue_Mgmt_Helper.QUEUE_TASK_SUBJECT_EXCLUDE);
    }
    
    public static Set<String> getValidProfiles(Map<String, List<Environment_Variables__c>> envVarMultiValues)
    {       
        return getSetOfValuesFromEnvVariable(envVarMultiValues, REQUEST_ASSIGNMENT_VALID_PROFILE);
    }
    
    public static Set<String> getNotCountSubjects(Map<String, List<Environment_Variables__c>> envVarMultiValues)
    {
        Set<String> ret = getSetOfValuesFromEnvVariable(envVarMultiValues, REQUEST_ASSIGNMENT_NOT_COUNT);
        ret.addAll(GNE_CM_Task_Queue_Mgmt_Helper.getNotCountPAESubjects());
        return ret;
    }
    
    private static Set<String> getSetOfValuesFromEnvVariable(Map<String, List<Environment_Variables__c>> envVarMultiValues, String envVarName)
    {
        Set<String> result = new Set<String>();      
        List<Environment_Variables__c> envVariables = envVarMultiValues.get(envVarName);
        if(envVariables != null)
        {
            for(Environment_Variables__c envVar : envVariables)
            {
                result.add(envVar.Value__c.toUpperCase());
            }
        }
        return result;
    }
}