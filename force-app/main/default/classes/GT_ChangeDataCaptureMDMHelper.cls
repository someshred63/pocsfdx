/******************************************************************************
 *
 *               Confidentiality Information:
 *
 * This module is the confidential and proprietary information of
 * Veeva Systems, Inc.; it is not to be copied, reproduced, or transmitted
 * in any form, by any means, in whole or in part, nor is it to be used
 * for any purpose other than that for which it is expressly provided
 * without the written permission of Veeva Systems, Inc.
 *
 * Copyright (c) 2021 Veeva Systems, Inc.  All Rights Reserved.
 *
 *******************************************************************************/
/**
 * @description: This Apex helper class creates a platform event whenever the
 * Account/Address/Affiliation information is created/updated so that it can be synced with MDM.
 * The Type1 and Type 2 changes are maintained in the custom Metadata:GT_Field_Type__mdt
 * Other settings are stored in custom metadata: GT_Data_Change_Capture_MDM_Setting__c
 *
 */
public with sharing class GT_ChangeDataCaptureMDMHelper {
  public static final String EVENT_TYPE_CREATED = 'CREATED';
  public static final String EVENT_TYPE_UPDATED = 'UPDATED';
  public static final String EVENT_TYPE_DELETED = 'DELETED';
  public static final String EVENT_TYPE_CROSSWALK_UPDATE = 'CROSSWALK_UPDATE';
  public static final String EVENT_TYPE_CROSSWALK_DELETE = 'CROSSWALK_DELETE';

  private static final List<String> STANDARD_FIELDS = new List<String>{
    'Id',
    'Name',
    'RecordTypeId',
    'CreatedDate',
    'CreatedById',
    'LastModifiedDate',
    'LastModifiedById'
  };

  private static Map<String, Set<String>> UnverifiedRecordType = new Map<String, Set<String>>();

  private static Map<String, Set<String>> unverifiedFilter = new Map<String, Set<String>>();

  private static Map<String, String> nestedObjectMap = new Map<String, String>();
  private static Map<String, String> entityIdFieldMap = new Map<String, String>();
  private static Map<String, String> MDMIdFieldMap = new Map<String, String>();
  private static Map<String, String> relationTypeFieldMap = new Map<String, String>();
  private static GT_Data_Change_Capture_MDM_Setting__c orgsettings = GT_Data_Change_Capture_MDM_Setting__c.getOrgDefaults();

  static {
    UnverifiedRecordType = getUnverifiedObjMap(
      orgsettings.Unverified_Record_Type_Filter__c
    );
    unverifiedFilter = getUnverifiedObjMap(orgsettings.Unverified_Filter__c);

    nestedObjectMap = getMap(orgsettings.Nested_Objects__c);
    MDMIdFieldMap = getMap(orgsettings.MDMId_Field__c);
    entityIdFieldMap = getMap(orgsettings.Entity_Id_Field__c);
    relationTypeFieldMap = getMap(orgsettings.Relation_Type_Field__c);
  }

  public GT_ChangeDataCaptureMDMHelper() {
  }
  private static Map<String, Set<String>> getUnverifiedObjMap(String str) {
    Map<String, Set<String>> ObjMap = new Map<String, Set<String>>();
    List<String> Objs = splitStr(str, ';;');
    for (String s : Objs) {
      List<String> Obj = splitStr(s, '::');
      if (Obj.size() == 2) {
        List<String> val = splitStr(Obj[1], ';');

        ObjMap.put(Obj[0], new Set<String>(val));
      }
    }

    return ObjMap;
  }

  private static Map<String, String> getMap(String str) {
    Map<String, String> ObjMap = new Map<String, String>();
    List<String> Objs = splitStr(str, ';');
    for (String s : Objs) {
      List<String> Obj = splitStr(s, '::');
      if (Obj.size() == 2) {
        ObjMap.put(Obj[0], Obj[1]);
      }
    }
    return ObjMap;
  }

  private static List<String> splitStr(String str, String delimiter) {
    List<String> tmpList = new List<String>();
    if (String.isNotBlank(str)) {
      if (str.contains(delimiter)) {
        tmpList = str.split(delimiter);
      } else {
        tmpList.add(str);
      }
    }
    return tmpList;
  }

  @invocableMethod(label='MDMSync' description='Invoke MDM Sync')
  public static void MDMSyncAction(List<ActionRequest> requestList) {
    Map<String, List<ActionRequest>> reqmap = new Map<String, List<ActionRequest>>();
    List<Id> ids = new List<Id>();
    for (ActionRequest request : requestList) {
      if (request.newRecord == null && request.recordId != null) {
        Id id = Id.valueOf(request.recordId);
        ids.add(id);
        request.objectType = id.getSObjectType().getDescribe().getName();
      }
      String key = request.objectType + ':' + request.eventType;
      if (reqmap.get(key) == null) {
        reqmap.put(key, new List<ActionRequest>());
      }
      reqmap.get(key).add(request);
    }

    Map<Id, SObject> IdtoObj = GT_SObjectUtil.getRecords(Ids);

    for (String key : reqmap.keySet()) {
      List<String> str = key.split(':');
      String objectType = str[0];
      String eventType = str[1];
      List<ActionRequest> reqList = reqmap.get(key);

      List<SObject> newItems = new List<SObject>();
      Map<Id, SObject> oldItemsMap = new Map<Id, SObject>();
      for (ActionRequest req : reqList) {
        if (req.newRecord == null) {
          newItems.add(IdtoObj.get(req.recordId));
        } else {
          newItems.add(req.newRecord);
        }

        if (req.oldRecord != null) {
          oldItemsMap.put(req.newRecord.Id, req.oldRecord);
        }
      }
      createDataChangeEventForMDM(newItems, oldItemsMap, eventType, objectType);
    }
  }

  public class ActionRequest {
    @InvocableVariable(label='Old Record' required=false)
    public sObject oldRecord;

    @InvocableVariable(label='New Record' required=false)
    public sObject newRecord;

    @InvocableVariable(label='Record Id' required=false)
    public String recordId;

    @InvocableVariable(label='Event Type' required=true)
    public String eventType;

    @InvocableVariable(label='Object Type' required=false)
    public String objectType;
  }

  public static void createDataChangeEventForMDM(
    List<SObject> newItems,
    Map<Id, SObject> oldItemsMap,
    string eventType,
    String objectType
  ) {
    Boolean doNotSendUpdatesToMDM = FeatureManagement.checkPermission(
      'Do_not_send_updates_to_MDM'
    );
    if (doNotSendUpdatesToMDM) {
      system.debug(
        'This user has Do_not_send_updates_to_MDM enabled. So no changes will be triggered'
      );
      return;
    }
    System.debug('eventType-->'+eventType);
    SObjectType sobjType = Schema.getGlobalDescribe().get(objectType);
    Map<Id, Schema.RecordTypeInfo> sobjRTMapById = sobjType.getDescribe()
      .getRecordTypeInfosById();
    Set<String> objectFields = sobjType.getDescribe().fields.getMap().keySet();

    Map<String, List<GT_Field_Type__mdt>> mFieldSettings = getFieldSettings(
      objectType
    );
    List<GT_Data_Change_Capture_MDM__e> levents = new List<GT_Data_Change_Capture_MDM__e>();
    Map<Id, Map<String, List<Request>>> mParentToNestedObj = new Map<Id, Map<String, List<Request>>>();

    for (SObject sobj : newItems) {
      System.debug('sobj-->' + sobj);
      Schema.RecordTypeInfo rt = null;
      if (objectFields.contains('recordTypeId'.toLowerCase())) {
        rt = sobjRTMapById.get((Id) sobj.get('recordTypeId'));
      }

      SObject oldRecord = (oldItemsMap != null)
        ? oldItemsMap.get(sobj.Id)
        : null;

      //If the bypass is true, event will not be created
      //This is done to avoid sending the updates back to MDM if it was updated by MDM
      /*if (bypassProcess((Id) sobj.get('LastModifiedById'))) {
        continue;
      }*/
      List<String> fieldList = new List<String>();
      Request payloadReq = null;
      boolean unverifiedRecord = checkUnverifiedRecord(
        rt?.developername,
        sobj,
        objectType
      );
      boolean crosswalkUpdate = isCrosswalkUpdate(sobj, oldRecord, objectType);
      boolean crosswalkDelete = isCrosswalkDelete(
        eventType,
        sobj,
        oldRecord,
        objectType
      );
      /*if (eventType == EVENT_TYPE_DELETED && !crosswalkDelete) {
        System.debug(
          'record was deleted but the entity Id was null. So we dont care as we dont have to delete crosswalk '
        );
        continue;
      }*/
      System.debug('unverifiedRecord->' + unverifiedRecord);
      System.debug('isCrosswalkDelete->' + crosswalkDelete);
      if (unverifiedRecord || crosswalkUpdate) {
        fieldList = getAllFieldList(mFieldSettings.get(rt?.getDevelopername()));
        System.debug('fieldList->' + fieldList);
        fieldList = filterEmptyFields(sobj, fieldList);
      } else {
        if (eventType == EVENT_TYPE_CREATED) {
          fieldList = getAllFieldList(
            mFieldSettings.get(rt?.getDevelopername())
          );
          fieldList = filterEmptyFields(sobj, fieldList);
        } else {
          fieldList = getType2FieldList(
            mFieldSettings.get(rt?.getDevelopername())
          );
          List<String> mandatoryFields = getMandatoryFields(
            mFieldSettings.get(rt?.getDevelopername())
          );
          fieldList = getFieldsUpdated(
            sobj,
            oldRecord,
            fieldList,
            mandatoryFields
          );
        }
      }
      fieldList = filterObjectFields(objectFields, fieldList);
      System.debug('crosswalkDelete1-->'+crosswalkDelete);
      System.debug('crosswalkUpdate-->'+crosswalkUpdate);
      if (!crosswalkDelete && (fieldList == null || fieldList.isEmpty())) {
        System.debug('Field List is empty. No payload to create:');
        continue;
      }
      System.debug('crosswalkDelete-->'+crosswalkDelete);
      System.debug('crosswalkUpdate-->'+crosswalkUpdate);
      if (crosswalkDelete) {
        System.debug('crosswalkDelete-->');
        payloadReq = createPayLoadRequest(
          EVENT_TYPE_CROSSWALK_DELETE,
          objectType,
          oldRecord,
          fieldList,
          sobjRTMapById,
          null,
          objectFields
        );
      } else if (crosswalkUpdate) {
        payloadReq = createPayLoadRequest(
          EVENT_TYPE_CROSSWALK_UPDATE,
          objectType,
          sobj,
          fieldList,
          sobjRTMapById,
          null,
          objectFields
        );
      } else {
        payloadReq = createPayLoadRequest(
          eventType,
          objectType,
          sobj,
          fieldList,
          sobjRTMapById,
          null,
          objectFields
        );
      }

      if (nestedObjectMap.containsKey(objectType)) {
        String parentFieldName = nestedObjectMap.get(objectType);
        Id parentObjId = (Id) sobj.get(parentFieldName);
        if (mParentToNestedObj.get(parentObjId) == null) {
          mParentToNestedObj.put(
            parentObjId,
            new Map<String, List<Request>>{ objectType => new List<Request>() }
          );
        }
        mParentToNestedObj.get(parentObjId).get(objectType).add(payloadReq);
      } else {
        GT_Data_Change_Capture_MDM__e e = new GT_Data_Change_Capture_MDM__e(
          payload__c = serializeRequest(payloadReq)
        );
        levents.add(e);
      }
    }
    if (mParentToNestedObj.size() > 0) {
      levents = getNestedObjPayLoad(mParentToNestedObj);
    }
    if (levents.size() > 0) {
      publishEvents(levents);
    }
  }

  private static List<String> filterObjectFields(
    Set<String> objFields,
    List<String> fieldList
  ) {
    System.debug('objFields->' + objFields);
    System.debug('fieldList->' + fieldList);

    List<String> fields = new List<String>();
    for (String s : fieldList) {
      if (objFields.contains(s.toLowerCase())) {
        fields.add(s);
      } else {
        System.debug('field->' + s + ' not in object');
      }
    }
    return fields;
  }

  @TestVisible
  private static List<GT_Data_Change_Capture_MDM__e> getNestedObjPayLoad(
    Map<Id, Map<String, List<Request>>> mParentToNestedObj
  ) {
    List<GT_Data_Change_Capture_MDM__e> levents = new List<GT_Data_Change_Capture_MDM__e>();
    Set<Id> ids = mParentToNestedObj.keySet();
    if (ids.size() < 1) {
      return levents;
    }
    String objName = null;

    for (Id tmp : ids) {
      objName = tmp.getSObjectType().getDescribe().getName();
      break;
    }

    SObjectType sobjType = Schema.getGlobalDescribe().get(objName);
    Set<String> objectFields = sobjType.getDescribe().fields.getMap().keySet();
    Map<Id, Schema.RecordTypeInfo> sobjRTMapById = sobjType.getDescribe()
      .getRecordTypeInfosById();

    List<SObject> lobj = getParentObj(ids, objName);

    for (SObject sobj : lobj) {
      Map<String, List<Request>> nestedPayLoadRequest = mParentToNestedObj.get(
        (Id) sobj.get('Id')
      );
      Request payload = null;

      List<String> fields = STANDARD_FIELDS;
      if (entityIdFieldMap.get(objName) != null) {
        fields.add(entityIdFieldMap.get(objName));
      }
      if (MDMIdFieldMap.get(objName) != null) {
        fields.add(MDMIdFieldMap.get(objName));
      }
      for (String s : nestedPayLoadRequest.keySet()) {
        List<Request> lr = nestedPayLoadRequest.get(s);
        for (Request r : lr) {
          Map<String, List<Request>> m = new Map<string, List<Request>>();
          m.put(s, new List<Request>{ r });

          payload = createPayLoadRequest(
            EVENT_TYPE_UPDATED,
            objName,
            sobj,
            fields,
            sobjRTMapById,
            m,
            objectFields
          );

          GT_Data_Change_Capture_MDM__e e = new GT_Data_Change_Capture_MDM__e(
            payload__c = serializeRequest(payload)
          );
          levents.add(e);
        }
      }
    }

    return levents;
  }

  private static List<sObject> getParentObj(Set<Id> Ids, String objName) {
    Set<String> fieldList = new Set<String>(STANDARD_FIELDS);
    if (entityIdFieldMap.get(objName) != null) {
      fieldList.add(entityIdFieldMap.get(objName));
    }
    if (MDMIdFieldMap.get(objName) != null) {
      fieldList.add(MDMIdFieldMap.get(objName));
    }
    String fields = String.join(new List<String>(fieldList), ', ');
    return Database.query(
      'SELECT ' +
      fields +
      ' FROM ' +
      objName +
      ' WHERE Id in :Ids'
    );
  }

  private static void publishEvents(
    List<GT_Data_Change_Capture_MDM__e> levents
  ) {
    // Call method to publish events
    List<Database.SaveResult> results = EventBus.publish(levents);

    // Inspect publishing result for each event
    for (Database.SaveResult sr : results) {
      if (sr.isSuccess()) {
        System.debug('Successfully published event.');
      } else {
        for (Database.Error err : sr.getErrors()) {
          System.debug(
            'Error returned: ' +
            err.getStatusCode() +
            ' - ' +
            err.getMessage()
          );
        }
      }
    }
  }

  private static String serializeRequest(request req) {
    System.debug(JSON.serialize(req));
    return JSON.serialize(req);
  }

  private static Request createPayLoadRequest(
    string eventType,
    String objName,
    SObject sobj,
    List<String> fields,
    Map<Id, Schema.RecordTypeInfo> sobjRTMapById,
    Map<String, List<Request>> nestedAttributes,
    Set<String> objectFields
  ) {
    request req = new request();
    req.source = orgsettings.MDMSourceId__c;
    req.sourceId = UserInfo.getOrganizationId();
    req.recordTypeId = null;
    req.recordTypeName = null;
    if (objectFields.contains('RecordTypeId'.toLowerCase())) {
      req.recordTypeId = (String) sobj.get('RecordTypeId');
      req.recordTypeName = (sobjRTMapById.get(req.recordTypeId))
        ?.getDeveloperName();
    }

    req.eventType = eventType;
    req.ObjectName = objName;
    req.Id = sobj.Id;
    req.CreatedDate = (DateTime) sobj.get('CreatedDate');
    req.UpdatedDate = (DateTime) sobj.get('LastModifiedDate');
    if (MDMIdFieldMap.get(objName) != null) {
      System.debug('MDMIdFieldMap.get(objName)->' + MDMIdFieldMap.get(objName));
      System.debug('sobj->' + sobj);
      req.MDMID = (String) sobj.get(MDMIdFieldMap.get(objName));
    }
    if (entityIdFieldMap.get(objName) != null) {
      req.entityId = (String) sobj.get(entityIdFieldMap.get(objName));
    }
    System.debug('Obj->' + relationTypeFieldMap.get(objName));
    if (relationTypeFieldMap.get(objName) != null) {
      req.relationType = (String) sobj.get(relationTypeFieldMap.get(objName));
    }

    Map<String, String> mAttributes = new Map<String, String>();
    for (String f : fields) {
      if (sobj.get(f) != null) {
        mAttributes.put(f, String.valueOf(sobj.get(f)));
      } else {
        mAttributes.put(f, '');
      }
    }
    if (nestedAttributes != null) {
      req.nestedAttributes = nestedAttributes;
    }

    req.attributes = mAttributes;
    return req;
  }

  private static boolean isCrosswalkUpdate(
    sObject rec,
    sObject oldrec,
    String objName
  ) {
    if (entityIdFieldMap.get(objName) != null) {
      //Entity Id is not null
      if (rec.get(entityIdFieldMap.get(objName)) != null) {
        //If it is a new record or if it was old record but Entity Id was updated
        if (
          oldrec == null ||
          (oldrec.get(entityIdFieldMap.get(objName)) !=
          rec.get(entityIdFieldMap.get(objName)))
        ) {
          return true;
        }
      }
    }
    return false;
  }

  private static boolean isCrosswalkDelete(
    String eventType,
    sObject rec,
    sObject oldrec,
    String objName
  ) {
    System.debug('eventType-->'+eventType );
    if (eventType == EVENT_TYPE_DELETED) {
      /*if (entityIdFieldMap.get(objName) != null) {
        //Entity Id was not null
        if (
          oldrec != null &&
          oldrec.get(entityIdFieldMap.get(objName)) != null
        ) {
          return true;
        }
      } */
        return true;
      
    }

    return false;
  }
  private static List<String> getFieldsUpdated(
    sObject rec,
    sObject oldrec,
    List<String> fields,
    List<String> mandatoryFields
  ) {
    List<String> updatedFields = new List<String>();

    if (oldrec == null) {
      return fields;
    }

    for (String f : fields) {
      if (rec.get(f) != oldrec.get(f)) {
        updatedFields.add(f);
      }
    }
    if (mandatoryFields != null && !mandatoryFields.isEmpty()) {
      updatedFields.addAll(mandatoryFields);
    }

    return updatedFields;
  }

  private static List<String> filterEmptyFields(
    sObject rec,
    List<String> fields
  ) {
    List<String> updatedFields = new List<String>();

    for (String f : fields) {
      if (rec.get(f) != null) {
        updatedFields.add(f);
      }
    }

    return updatedFields;
  }

  private static boolean bypassProcess(Id userId) {
    GT_Data_Change_Capture_MDM_Setting__c settings = GT_Data_Change_Capture_MDM_Setting__c.getInstance(
      userId
    );
    if (settings.Bypass_Updates__c) {
      System.debug(
        'object is modified by:' +
        userId +
        ', Bypass updates is true'
      );
      return true;
    }
    return false;
  }

  private static boolean checkUnverifiedRecord(
    string recTypeName,
    sObject sobj,
    String objectName
  ) {
    boolean recordTypeMatch = false;
    boolean filterMatch = false;
    Set<String> lunverifiedRecordTypes = UnverifiedRecordType.get(objectName);
    Set<String> lunverifiedRecordFilters = unverifiedFilter.get(objectName);

    System.debug('lunverifiedRecordTypes:' + lunverifiedRecordTypes);

    if (lunverifiedRecordTypes != null && lunverifiedRecordTypes.size() > 0) {
      recordTypeMatch = lunverifiedRecordTypes.contains(recTypeName);
    } else {
      recordTypeMatch = true;
    }
    System.debug('recordTypeMatch->' + recordTypeMatch);
    if (
      lunverifiedRecordFilters != null &&
      lunverifiedRecordFilters.size() > 0
    ) {
      filterMatch = checkFilter(lunverifiedRecordFilters, sobj);
    } else {
      filterMatch = true;
    }
    System.debug('filterMatch->' + filterMatch);
    return (recordTypeMatch && filterMatch);
  }

  private static boolean checkFilter(
    set<string> unverifiedFilter,
    SObject sobj
  ) {
    boolean match = false;
    for (String f : unverifiedFilter) {
      System.debug('f->' + f);
      List<String> Obj = splitStr(f, ':');

      if (Obj.size() == 2) {
        System.debug('Obj[1]->' + Obj[1]);
        System.debug('Obj[0]->' + Obj[0]);
        if (Obj[1] == 'null') {
          System.debug(sobj.get(Obj[0]));
          if (sobj.get(Obj[0]) == null) {
            match = true;
          } else {
            match = false;
            break;
          }
        } else {
          if (string.valueOf(sobj.get(Obj[0])) == Obj[1]) {
            match = true;
          } else {
            match = false;
            break;
          }
        }
      }
    }
    System.debug(match);
    return match;
  }
  private static Map<String, List<GT_Field_Type__mdt>> getFieldSettings(
    string objName
  ) {
    Map<String, List<GT_Field_Type__mdt>> mRecTypeToFieldSettings = new Map<String, List<GT_Field_Type__mdt>>();
    GT_Field_Type__mdt[] fieldTypeSettings = [
      SELECT
        Field_Name__c,
        Object_Name__c,
        Record_Type__c,
        Type__c,
        Mandatory__c
      FROM GT_Field_Type__mdt
      WHERE Object_Name__c = :objName
    ];

    for (GT_Field_Type__mdt fs : fieldTypeSettings) {
      string recType = fs.Record_Type__c;
      if (String.isNotBlank(recType)) {
        if (recType.contains(';')) {
          List<String> tmp = recType.split(';');
          for (String s : tmp) {
            if (mRecTypeToFieldSettings.get(s) == null) {
              mRecTypeToFieldSettings.put(s, new List<GT_Field_Type__mdt>());
            }
            mRecTypeToFieldSettings.get(s).add(fs);
          }
        } else {
          if (mRecTypeToFieldSettings.get(recType) == null) {
            mRecTypeToFieldSettings.put(
              recType,
              new List<GT_Field_Type__mdt>()
            );
          }
          mRecTypeToFieldSettings.get(recType).add(fs);
        }
      } else {
        if (mRecTypeToFieldSettings.get(null) == null) {
          mRecTypeToFieldSettings.put(null, new List<GT_Field_Type__mdt>());
        }
        mRecTypeToFieldSettings.get(null).add(fs);
      }
    }
    return mRecTypeToFieldSettings;
  }
  private static List<String> getAllFieldList(
    List<GT_Field_Type__mdt> fieldTypeSettings
  ) {
    List<String> fields = new List<String>();
    if (fieldTypeSettings == null) {
      return fields;
    }
    for (GT_Field_Type__mdt fs : fieldTypeSettings) {
      fields.add(fs.Field_Name__c);
    }
    return fields;
  }

  private static List<String> getType2FieldList(
    List<GT_Field_Type__mdt> fieldTypeSettings
  ) {
    List<String> fields = new List<String>();
    if (fieldTypeSettings == null || fieldTypeSettings.isEmpty()) {
      return fields;
    }
    for (GT_Field_Type__mdt fs : fieldTypeSettings) {
      if (fs != null && fs.Type__c == 'Type2') {
        fields.add(fs.Field_Name__c);
      }
    }
    return fields;
  }

  private static List<String> getMandatoryFields(
    List<GT_Field_Type__mdt> fieldTypeSettings
  ) {
    List<String> fields = new List<String>();
    if (fieldTypeSettings == null || fieldTypeSettings.isEmpty()) {
      return fields;
    }
    for (GT_Field_Type__mdt fs : fieldTypeSettings) {
      if (fs != null && fs.Mandatory__c) {
        fields.add(fs.Field_Name__c);
      }
    }
    return fields;
  }

  public class request {
    public String source { get; set; }
    public String sourceId { get; set; }
    public string MDMID { get; set; }
    public string entityId { get; set; }
    public String eventType { get; set; }
    public String ObjectName { get; set; }
    public String id { get; set; }
    public String relationType { get; set; }
    public DateTime createdDate { get; set; }
    public DateTime updatedDate { get; set; }
    public String recordTypeId { get; set; }
    public String recordTypeName { get; set; }
    public Map<String, String> attributes { get; set; }
    public Map<String, List<Request>> nestedAttributes { get; set; }
  }
}