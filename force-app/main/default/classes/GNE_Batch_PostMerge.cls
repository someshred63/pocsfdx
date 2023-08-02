/*
* Class: GNE_Batch_PostMerge
* Author: Saama
* Date:   5May 2010
* Description: This Class run for an object 'Event_Attendee_vod__c','User_Preference_gne__c','Product_Metrics_vod__c','Affiliation_vod__c'.
* How to Run: 1. Check mode
GNE_Batch_PostMerge EAexecuteBatchable = new GNE_Batch_PostMerge('Product_Metrics_vod__c',true); 
      database.executebatch(EAexecuteBatchable,20);
      2. mergemode
        GNE_Batch_PostMerge EAexecuteBatchable = new GNE_Batch_PostMerge('Product_Metrics_vod__c',false); 
      database.executebatch(EAexecuteBatchable,20);               
* Requirement #2585 Merge Management (Post Merge).
*     -Revision-
      version 1.1 : Release: 1
*/
global class GNE_Batch_PostMerge implements Database.Batchable<SObject>, Database.Stateful  {

    String parentAccountId = null;
    String strWinnerRecordFieldName = null;
    String strQueryForUniqueSet = null;
    set<String> accountIdList = new Set<String>();    
    String ObjectName = null;
    boolean bCheckMode = false;
    GNE_ObjectMerge_Controller objController=null;
    List<Schema.SObjectField> fTokens = new List<Schema.SObjectField>();
    Schema.SObjectType schemaSObject=null;
    Map<String, Schema.SObjectField> fMap = new Map<String, Schema.SObjectField>();
    String strWhere='';
    String strSortBy='';
    String strUniqueSetFieldName='';
    String strUniqueSetFieldName1='';
    Set <String> UniqueFieldNameSet = new Set <String> ();
    Set <String> UniqueFieldNameSet1 = new Set <String> (); 
    String strUniqueCalcGNE='';
    
    Integer UniqueGroupCount  = 0;
    Integer RuntimeErrorCount = 0;

    public GNE_Batch_PostMerge (String ObjectName,boolean bCheckMode) { 
        this.ObjectName = ObjectName;
        this.bCheckMode = bCheckMode;
        objController = new GNE_ObjectMerge_Controller(objectName,objectName,bCheckMode);    
        schemaSObject = Schema.getGlobalDescribe().get(ObjectName) ;
        fMap = schemaSObject.getDescribe().fields.getMap() ;
        fTokens = fMap.values();
        System.debug('Object Name: --> ' + ObjectName + ' No. Of fields in this object: --> ' + fTokens.size());
    }  

    global Database.QueryLocator start(Database.batchableContext bc) {

        System.debug ('ObjectName: ' + ObjectName);
        String strFields = getSelectFields(ObjectName);
        System.debug('strFields --> ' +strFields);      
        
        /*
        //for testing
        List<String> lstId = new List<String> ();
        //lstId.add('0017000000QgYHv-a0070000009miys');
        //lstId.add('0017000000OYMCi-a0070000009miyk');      ba
        lstId.add('From:0017000000OYLUb_To:0017000000Sw3hm_Type:AFFILIATION_Role:SOI Reference'); 
        String mergeList = 'Select ' +  strFields + ' from ' + ObjectName + ' where UNIQUE_KEY_CALC_GNE__C in : lstId ';
        String mergeList1 = 'Select ' +  strFields + ' from ' + ObjectName + ' ';
        strQueryForUniqueSet = mergeList1;
        //end
        */
        
        String mergeList = 'Select ' +  strFields + ' from ' + ObjectName + ' ';
        strQueryForUniqueSet = mergeList;       
        
        strWhere='';
        strSortBy='';       
        
        GNE_Merge_BusinessRules_gne__c[] gneMergeList = 
            [select field_type_gne__c, field_name_gne__c,
                relatedlist_query_text_gne__c,
                exception_code_gne__c   
             from gne_merge_businessrules_gne__c  
             where     object_name_gne__c      = :ObjectName 
                   and active_gne__c           = true
                   order by field_type_gne__c, field_name_gne__c desc];

        for (GNE_Merge_BusinessRules_gne__c gneMerge : gneMergeList) {
            if ( gneMerge.field_type_gne__c.startsWith(PostMergeUtil.strWhereClause) ) {
                strWhere = gneMerge.field_name_gne__c;
            }
            else if ( gneMerge.field_type_gne__c.startsWith(PostMergeUtil.strWinnerRecordFieldName) ) {
                strWinnerRecordFieldName = gneMerge.field_name_gne__c;
            }
            else if ( gneMerge.field_type_gne__c.startsWith(PostMergeUtil.strSortBy) ) {
                strSortBy = PostMergeUtil.strOrderby + gneMerge.field_name_gne__c;
            }
            else if ( gneMerge.field_type_gne__c.startsWith(PostMergeUtil.strUniqueSetFieldName) ) {
                strUniqueSetFieldName = gneMerge.field_name_gne__c;
            }
        }
        System.debug ('strWhere: ' + strWhere);
        System.debug ('strUniqueSetFieldName: ' + strUniqueSetFieldName);
        System.debug ('strWinnerRecordFieldName: ' + strWinnerRecordFieldName);
        System.debug ('strSortBy: ' + strSortBy);
        
        String[] lstUniqueSetFieldName = new List<String> ();
        if(strUniqueSetFieldName != ''){
            lstUniqueSetFieldName = strUniqueSetFieldName.split(',');
            strUniqueSetFieldName = lstUniqueSetFieldName[0];
            strUniqueSetFieldName1 = lstUniqueSetFieldName[1];          
        }       
        String[] lstWhereClause = new List<String> ();      
        
        if(strWhere!=''){
            lstWhereClause = strWhere.split(',');
            strQueryForUniqueSet = strQueryForUniqueSet + lstWhereClause[0] + PostMergeUtil.strUniqueFieldNameSet + lstWhereClause[1] + PostMergeUtil.strUniqueFieldNameSet1 + strSortBy;
        }
        else{
            strQueryForUniqueSet = strQueryForUniqueSet + ' ' + strSortBy;
        }       
        System.debug ('strQueryForUniqueSet: ' + strQueryForUniqueSet);
        if(ObjectName == PostMergeUtil.strAffiliation){
            mergeList = mergeList + PostMergeUtil.strWhereClause1 + strSortBy;
        }
        else{
            mergeList = mergeList + ' ' + strSortBy;
        }
        
        System.debug ('mergeList: ' + mergeList);
        return Database.getQueryLocator ( mergeList );

    }
    /*
     * Call for getting fields name for the specific object to create dynamic query.
     * @param               
     * @return           
     */
    public String getSelectFields (String strObjectName) {
        String strSelectFields = null;
        Schema.DescribeFieldResult f=null;
        for( Integer i = 0 ; i < fTokens.size() ; i++ ){
            f = fTokens.get(i).getDescribe();
                if (strSelectFields==null){
                    strSelectFields= f.getName();
                }
                else{
                    strSelectFields=strSelectFields + ', ' + f.getName();
                }
            f = null;
        }
        return strSelectFields;
    }
    /*
     * Call for getting fields values for the specific record to create Field value pair to insert in Audit table (Post_merge_data_gne__c).
     * @param               
     * @return           
     */
    public String getFieldValues (SObject objectSObject) {
        String strFieldValues = 'Record Values: ';
        Schema.DescribeFieldResult f=null;
        for( Integer i = 0 ; i < fTokens.size() ; i++ ){
            f = fTokens.get(i).getDescribe() ;        
            if(f.getType() == DisplayType.DATETIME || f.getType() == DisplayType.DATE || f.getType() == DisplayType.Double || f.getType() == DisplayType.INTEGER){
            strFieldValues = strFieldValues + '(' + f.getName() + ',' + String.valueOf(objectSObject.get(f.getName())) + '),';
            }
            else if(f.getType() == DisplayType.BOOLEAN){
            strFieldValues = strFieldValues + '(' + f.getName() + ',' + Boolean.valueof(objectSObject.get(f.getName())) + '),';
            }
            else{
                strFieldValues = strFieldValues + '(' + f.getName() + ',' + (String)objectSObject.get(f.getName()) + '),';
                
                //for test
                if(f.getName() == PostMergeUtil.Unique_Field_Name){
                    strUniqueCalcGNE = (String)objectSObject.get(f.getName());
                }
                //end
            }        
        f = null;
        }
        return strFieldValues;
    }
    /*
     * Call for inserting data in Audit table (Post_merge_data_gne__c).
     * @param               
     * @return           
     */
    public void insertAuditTable (Set<String> objectIdSet, String winnerRecordId, String strErrorMessage,Map <String,SObject> mapObjectRecords) {
        List <Post_Merge_Data_gne__c> lstPostMergeData= new List <Post_Merge_Data_gne__c>();
        String strFieldValues = null;
    String strErrorId='';
    SObject objSObject = null;
    try{
        for (String tempObject : objectIdSet) {         
            Post_Merge_Data_gne__c objPostMergeData1 = new Post_Merge_Data_gne__c();
            objPostMergeData1.Action_Reason_gne__c = PostMergeUtil.strMergeRule;
            if(tempObject == winnerRecordId){
            objPostMergeData1.Action_Type_gne__c = PostMergeUtil.strUpdate;
            }
            else{
            objPostMergeData1.Action_Type_gne__c = PostMergeUtil.strDelete;
            }            
            objPostMergeData1.New_Object_Id_gne__c = winnerRecordId;
            objPostMergeData1.Object_Id_gne__c = tempObject;
            objPostMergeData1.Object_Type_gne__c = objectName;
            
            objPostMergeData1.External_Id_gne__c = objectName + '::' + winnerRecordId + '::' + tempObject;
            
            if(mapObjectRecords.containsKey(tempObject)){
                strFieldValues = getFieldValues(mapObjectRecords.get(tempObject));      
                objPostMergeData1.Field_Values_gne__c = strFieldValues;
                objPostMergeData1.Unique_Key_Calc_gne__c = strUniqueCalcGNE;
                strUniqueCalcGNE = '';              
            }
            If(!strErrorMessage.equalsIgnoreCase(PostMergeUtil.strErrorMsg)){
            objPostMergeData1.Error_Message_gne__c = strErrorMessage;
            }
            lstPostMergeData.add(objPostMergeData1);
        }
        insert lstPostMergeData;
    }catch (Exception e){
            parentAccountId = winnerRecordId;
            sendErrorEmail(e);
        }    
    }   
    /*
     * Call for selecting winner record out of list of duplicate records.
     * @param               
     * @return           
     */
    public String getWinnerRecordId(Map <String,SObject> mapObjectRecords,List<String> lstObjectId) {
        String strWinnerRecordStatus = '';
        SObject tempObject = null;
        String strWinnerId = '';

        List <SObject> lstSObjects= new List <SObject>();
        lstSObjects = mapObjectRecords.values();
        System.debug ('lstSObjects: ' + lstSObjects);
        
        for (String Id : lstObjectId){
            if(mapObjectRecords.containsKey(Id)){
                tempObject = mapObjectRecords.get(Id);
                System.debug ('Id: ' + (String)tempObject.get(PostMergeUtil.strId));
            }
            if(tempObject != null){
                if(strWinnerRecordStatus == ''){
                    if(tempObject.get(strWinnerRecordFieldName) != null){
                        strWinnerRecordStatus = (String)tempObject.get(strWinnerRecordFieldName);
                        strWinnerId = (String)tempObject.get(PostMergeUtil.strId);
                        if(strWinnerRecordStatus == PostMergeUtil.strActive)
                        break;
                    }
                    else{
                        strWinnerRecordStatus = PostMergeUtil.strNull;
                        strWinnerId = (String)tempObject.get(PostMergeUtil.strId);
                    }
                }
                else if(tempObject.get(strWinnerRecordFieldName) != null && strWinnerRecordStatus == PostMergeUtil.strNull){
                    strWinnerId = (String)tempObject.get(PostMergeUtil.strId);
                    strWinnerRecordStatus = (String)tempObject.get(strWinnerRecordFieldName);
                    if(strWinnerRecordStatus == PostMergeUtil.strActive)
                        break;
                }
                else if(tempObject.get(strWinnerRecordFieldName) != null && (strWinnerRecordStatus != PostMergeUtil.strActive || strWinnerRecordStatus == PostMergeUtil.strNull) && tempObject.get(strWinnerRecordFieldName) == PostMergeUtil.strActive){
                    strWinnerId = (String)tempObject.get(PostMergeUtil.strId);
                    strWinnerRecordStatus = (String)tempObject.get(strWinnerRecordFieldName);
                    if(strWinnerRecordStatus == PostMergeUtil.strActive)
                        break;
                }
            }
        }
        
        System.debug ('strWinnerId: ' + strWinnerId);
        return strWinnerId;
    }
    /*
     * Call for merging duplicate records. Winner record get updated and looser record get deleted.
     * @param               
     * @return           
     */
    public void callDoMerge(Set<String> objectIdSet, Map <String,SObject> mapObjectRecords,List<String> lstObjectId) {
        String strDCHUniqueKey='';
        String strErrorId='';
                
        try{
            System.debug ('lstObjectId: ' + lstObjectId);
            if(strWinnerRecordFieldName != null && strWinnerRecordFieldName != ''){
                parentAccountId = getWinnerRecordId(mapObjectRecords,lstObjectId);
            }
            
            GNE_Merge_DuplicateSet duplicateSet = new GNE_Merge_DuplicateSet();
            duplicateSet.initialize();
            duplicateSet.LoserIdSet     = objectIdSet;
            duplicateSet.winnerRecordId = parentAccountId;
            UniqueGroupCount++;
            strDCHUniqueKey= objController.doMerge(objectIdSet,parentAccountId,duplicateSet);
            insertAuditTable(objectIdSet,strDCHUniqueKey,PostMergeUtil.strErrorMsg,mapObjectRecords);
            duplicateSet =null;
        }catch (Exception e){
            insertAuditTable(objectIdSet,parentAccountId,e.getMessage(),mapObjectRecords);
            sendErrorEmail(e);
        }
    }
    /*
     * Call for setting Unique key set used in dynamic query.
     * @param               
     * @return           
     */
    public void setUniqueKeySet(List<SObject> objectList1) {
        Boolean isNull = false;
        Boolean isNull1 = false;
        for (SObject tempObject : objectList1) {
            if(tempObject.get(strUniqueSetFieldName) != null){
                if(UniqueFieldNameSet.isEmpty()){
                    UniqueFieldNameSet.add((String)tempObject.get(strUniqueSetFieldName));
                }
                else if (UniqueFieldNameSet.size() >0 && (!UniqueFieldNameSet.contains((String)tempObject.get(strUniqueSetFieldName)))) {
                    UniqueFieldNameSet.add((String)tempObject.get(strUniqueSetFieldName));
                }
            }
            else{
                isNull = true;
            }
            if(tempObject.get(strUniqueSetFieldName1) != null){
                if(UniqueFieldNameSet1.isEmpty()){
                    UniqueFieldNameSet1.add((String)tempObject.get(strUniqueSetFieldName1));
                }
                else if (UniqueFieldNameSet1.size() >0 && (!UniqueFieldNameSet1.contains((String)tempObject.get(strUniqueSetFieldName1)))) {
                    UniqueFieldNameSet1.add((String)tempObject.get(strUniqueSetFieldName1));
                }
            }
            else{
                isNull1 = true;
            }
        }
        if(isNull){
            UniqueFieldNameSet.add(null);
            UniqueFieldNameSet.add('');
        }
        if(isNull1){
            UniqueFieldNameSet1.add(null);
            UniqueFieldNameSet1.add('');
        }
    }
    global void execute(Database.BatchableContext BC, List<SObject> objectList1){
        
        Set <String> objectIdSet = new Set <String> ();
        Set <String> UniqueKeySet = new Set <String> ();
        Map <String,SObject> mapObjectRecords= new Map <String,SObject>();
        List<String> lstObjectId = new List<String> ();
        String strDCHUniqueKey=null;        
        try{
            setUniqueKeySet(objectList1);
            System.debug ('UniqueFieldNameSet: ' + UniqueFieldNameSet);
            System.debug ('UniqueFieldNameSet1: ' + UniqueFieldNameSet1);
            System.debug ('strQueryForUniqueSet: ' + strQueryForUniqueSet);
            Sobject[] objectList   = Database.query (strQueryForUniqueSet);         
            if(objectList != null && objectList.size() > 1){
                System.debug ('objectList.size(): ' + objectList.size());
                for (SObject tempObject : objectList) {
                    if(parentAccountId == null || UniqueKeySet.isEmpty()){
                        parentAccountId = (String)tempObject.get(PostMergeUtil.strId);
                        UniqueKeySet.add((String)tempObject.get(PostMergeUtil.Unique_Field_Name));
                        strDCHUniqueKey = (String)tempObject.get(PostMergeUtil.Unique_Field_Name);
                        objectIdSet.add((String)tempObject.get(PostMergeUtil.strId));
                        mapObjectRecords.put((String)tempObject.get(PostMergeUtil.strId),tempObject);
                        lstObjectId.add((String)tempObject.get(PostMergeUtil.strId));
                    }
                    else if (UniqueKeySet.size() >0 && UniqueKeySet.contains((String)tempObject.get(PostMergeUtil.Unique_Field_Name))) {
                        objectIdSet.add((String)tempObject.get(PostMergeUtil.strId));
                        mapObjectRecords.put((String)tempObject.get(PostMergeUtil.strId),tempObject);
                        lstObjectId.add((String)tempObject.get(PostMergeUtil.strId));
                    }
                    else
                    {
                        if(objectIdSet.size()>1){
                            callDoMerge(objectIdSet,mapObjectRecords,lstObjectId);       
                            objectIdSet.clear();
                            mapObjectRecords.clear();
                            lstObjectId.clear();
                        }
                        objectIdSet.clear();
                        mapObjectRecords.clear();
                        lstObjectId.clear();
                        parentAccountId = (String)tempObject.get(PostMergeUtil.strId);
                        strDCHUniqueKey = (String)tempObject.get(PostMergeUtil.Unique_Field_Name);
                        objectIdSet.add((String)tempObject.get(PostMergeUtil.strId));
                        mapObjectRecords.put((String)tempObject.get(PostMergeUtil.strId),tempObject);
                        lstObjectId.add((String)tempObject.get(PostMergeUtil.strId));
                        UniqueKeySet.clear();
                        UniqueKeySet.add((String)tempObject.get(PostMergeUtil.Unique_Field_Name));            
                    } 
                }
                if(objectIdSet.size()>1){
                    callDoMerge(objectIdSet,mapObjectRecords,lstObjectId);
                    objectIdSet.clear();
                    mapObjectRecords.clear();
                    lstObjectId.clear();
                    UniqueKeySet.clear();
                }
            }
            UniqueFieldNameSet.clear();
            UniqueFieldNameSet1.clear();
            objectIdSet.clear();
            mapObjectRecords.clear();
            lstObjectId.clear();
            UniqueKeySet.clear();
        } catch (Exception e){   
            sendErrorEmail(e);          
        }
        System.debug('End of execute:');

    }
    /*
     * Call for sending mail for run time exception/error.
     * @param               
     * @return           
     */
    void sendErrorEmail (Exception e) {       
      RuntimeErrorCount++;
        String className  = 'GNE_Batch_PostMerge(' + objectName + ')';
        GNE_Merge_Utility_ErrorLog.writeErrorLog(parentAccountId,objectName,className, e);
    }
    global void finish(Database.BatchableContext BC){

        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.    
        // Query the AsyncApexJob object to retrieve the current job's information.
        
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, ApexClass.Name, 
                              JobItemsProcessed, TotalJobItems, CreatedBy.Email,
                              CreatedDate, CompletedDate from AsyncApexJob where Id =:BC.getJobId()];
        User createdUser = a.CreatedBy;
        ApexClass batchApexClass = a.ApexClass;

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = System.Label.Post_Merge_RunTime_Error_Email_List_gne.split(',');
        mail.setToAddresses(toAddresses);
        mail.setSubject('Apex Job ' + + batchApexClass.Name + 
        ' status ' + a.Status);
        
        mail.setPlainTextBody
                            ('The batch Apex job ' + batchApexClass.Name + 
                            '(' + objectName + ') processed '    + a.TotalJobItems +
                            ' batches with ' + a.NumberOfErrors + ' failures.\n' + 
                            'Batch Job StartTime / CompletedTime ' + 
                            a.CreatedDate + '/' + a.CompletedDate +  '.\n\n' + 
                            'Total Unique Group Count(duplicate sets processed)/Runtime Error Count: ' + 
                            UniqueGroupCount + '/' + RuntimeErrorCount );

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    //@isTest
    static testMethod void testGNE_Batch_PostMerge(){

        //Test.StartTest();
        //check mode
        GNE_Batch_PostMerge EAexecuteBatchable = new GNE_Batch_PostMerge('User_Preference_gne__c',true);
        ID batchprocessid = Database.executeBatch(EAexecuteBatchable,20);
        
        //merge mode
        GNE_Batch_PostMerge EAexecuteBatchable1 = new GNE_Batch_PostMerge('User_Preference_gne__c',false);
        ID batchprocessid1 = Database.executeBatch(EAexecuteBatchable1,20);
        //Test.StopTest();
    }
}