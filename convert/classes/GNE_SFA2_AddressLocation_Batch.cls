public with sharing class GNE_SFA2_AddressLocation_Batch implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts, GNE_Batch_Runner.Batchable {
  private Boolean initialLoad;
  private Boolean useGoogleDao;
  private Integer recordsLimit;
  private Boolean isFRMHCOMappingMode;
  private Metrics metrics = new Metrics();
  private Boolean googleApiDailyLimitExceeded;
  private static final Integer DEFAULT_RECORDS_LIMIT = 50000;

  public GNE_SFA2_AddressLocation_Batch(Boolean initialLoad, Boolean useGoogleDao, Integer recordsLimit, Boolean isFRMHCOMappingMode) {
    this.initialLoad = initialLoad;
    this.useGoogleDao = useGoogleDao;
    this.recordsLimit = recordsLimit != null ? recordsLimit : getRecordsLimit();
    this.isFRMHCOMappingMode = isFRMHCOMappingMode;
  }

  private Integer getRecordsLimit() {
    recordsLimit = DEFAULT_RECORDS_LIMIT;
    if (GNE_Foun_Misc_Config_Items_gne__c.getValues(GNE_SFA2_AddressLocation_Util.ADDRESS_LOC_BATCH_SIZE) != null) {
      try {
        recordsLimit = Integer.valueOf(GNE_Foun_Misc_Config_Items_gne__c.getValues(GNE_SFA2_AddressLocation_Util.ADDRESS_LOC_BATCH_SIZE).Configuration_Value_gne__c);
      } catch (TypeException e) {}
    }
    return recordsLimit;
  }

  public GNE_SFA2_AddressLocation_Batch(Boolean initialLoad, Boolean useGoogleDao, Boolean isFRMHCOMappingMode) {
    this(initialLoad, useGoogleDao, null, isFRMHCOMappingMode);
  }

  public GNE_SFA2_AddressLocation_Batch(Boolean initialLoad, Boolean useGoogleDao) {
    this(initialLoad, useGoogleDao, null, false);
  }

  public GNE_SFA2_AddressLocation_Batch(Boolean initialLoad) {
    this(initialLoad, true, null, false);
  }

  public GNE_SFA2_AddressLocation_Batch() {
    this(false, true, null, false);
  }

  public System.Type getBatchClass() {
    return GNE_SFA2_AddressLocation_Batch.class;
  }

  public String getBatchName() {
    return 'Calculate Address Location Batch';
  }

  public String getKeyForRecord(SObject sObj) {
    return sObj.Id;
  }

  public void processDatabaseErrors(List<SObject> sObjs, Map<String, List<Database.Error>> recToErrorsMap, String actionId, String actionDescription) {
  }

  public String getErrorEmailDescription(String actionId, SObject sObj, Database.Error err) {
    return err.getMessage();
  }

  public String getRecordDescription(SObject sObj) {
    Address_vod__c addr = (Address_vod__c)sObj;
    return String.format('{0}, {1}, {2} {3} (ID: {4})', new String[] {addr.Name, addr.City_vod__c, addr.State_vod__c, addr.Zip_vod__c, addr.Id});
  }

  public Database.QueryLocator start(Database.BatchableContext BC) {
    return GNE_Batch_Runner.doStart(this, BC);
  }

  public Database.QueryLocator intStart(Database.BatchableContext BC) {
    Boolean isStillMappingBatchRuning = [
                                          SELECT Id
                                          FROM AsyncApexJob
                                          WHERE ApexClass.Name = 'GNE_SFA2_HCPtoFRMHCOMappingBatch'
                                              AND Status IN ('Processing')
                                        ].size() > 0;

    Boolean isStillAddrLocationBatchRuning = [
          SELECT Id
          FROM AsyncApexJob
          WHERE ApexClass.Name = 'GNE_SFA2_AddressLocation_Batch'
                                 AND Status IN ('Processing')
        ].size() > 0;

    if (!isStillAddrLocationBatchRuning && !isStillMappingBatchRuning) {
      Set<Id> recordTypesIds = new Set<Id>();

      for (RecordTypeInfo rtInfo : Address_vod__c.sObjectType.getDescribe().getRecordTypeInfos()) {
        if (rtInfo.getName() == 'Company Maintained' || rtInfo.getName() == 'Rep Maintained') {
          recordTypesIds.add(rtInfo.getRecordTypeId());
        }
      }

      return this.initialLoad ?
             this.useGoogleDao && this.isFRMHCOMappingMode ?
             Database.getQueryLocator([
                                        SELECT Id, Latitude_vod__c, Longitude_vod__c, Location_gne__Latitude__s, Location_gne__Longitude__s,
                                        Name, City_vod__c, State_vod__c, Zip_vod__c, Force_Location_Update_gne__c
                                        FROM Address_vod__c
                                        WHERE RecordTypeId IN :recordTypesIds
                                        AND LastModifiedDate >= : DateTime.now().addMinutes(-10)
                                        AND Force_Location_Update_gne__c = true
                                        ORDER BY CreatedDate, Id
                                      ])
             : this.useGoogleDao ?
             Database.getQueryLocator([
                                        SELECT Id, Latitude_vod__c, Longitude_vod__c, Location_gne__Latitude__s, Location_gne__Longitude__s,
                                        Name, City_vod__c, State_vod__c, Zip_vod__c, Force_Location_Update_gne__c
                                        FROM Address_vod__c
                                        WHERE Location_gne__Latitude__s = null
                                            AND RecordTypeId IN :recordTypesIds
                                            ORDER BY CreatedDate, Id
                                        LIMIT :this.recordsLimit
                                      ])
             : Database.getQueryLocator([
                                          SELECT Id, Latitude_vod__c, Longitude_vod__c, Location_gne__Latitude__s, Location_gne__Longitude__s,
                                          Name, City_vod__c, State_vod__c, Zip_vod__c, Force_Location_Update_gne__c
                                          FROM Address_vod__c
                                          WHERE Location_gne__Latitude__s = null
                                              AND Latitude_vod__c <> null
                                              AND RecordTypeId IN :recordTypesIds
                                              ORDER BY CreatedDate, Id
                                        ])
             :
             Database.getQueryLocator([
                                        SELECT Id, Latitude_vod__c, Longitude_vod__c, Location_gne__Latitude__s, Location_gne__Longitude__s,
                                        Name, City_vod__c, State_vod__c, Zip_vod__c, Force_Location_Update_gne__c
                                        FROM Address_vod__c
                                        WHERE Force_Location_Update_gne__c = true
                                            AND RecordTypeId IN :recordTypesIds
                                            ORDER BY CreatedDate, Id
                                        LIMIT :this.recordsLimit
                                      ]);
    } else {
      System.abortJob(bc.getJobId());
      return Database.getQueryLocator([
                                 SELECT Id
                                 FROM Address_vod__c
                                 LIMIT 0
                               ]);
    }

  }

  public void execute(Database.BatchableContext BC, List<sObject> scope) {
    GNE_Batch_Runner.setIsStoreErrorsAndEmailsMode(true);

    try {
      intExecute(BC, scope);
    } catch (Exception ex) {
      GNE_Batch_Runner.handleException(this, ex);
    } finally {
      GNE_Batch_Runner.insertLogsAndSendEmails(this);

      if (this.useGoogleDao) {
        sleep(1000L);
      }
    }
  }

  public void intExecute(Database.BatchableContext BC, List<sObject> scope) {
    List<Address_vod__c> addrs = (List<Address_vod__c>)scope;
    List<Address_vod__c> addrsToUpdate = new List<Address_vod__c>();

    if (this.useGoogleDao && this.googleApiDailyLimitExceeded == true) {
      return ;
    }

    for (Address_vod__c addr : addrs) {
      metrics.increaseTotal();
      Boolean addrChanged = false;

      try {
        if (this.initialLoad && addr.Latitude_vod__c != null && addr.Longitude_vod__c != null) {
          addr.Location_gne__Latitude__s = addr.Latitude_vod__c;
          addr.Location_gne__Longitude__s = addr.Longitude_vod__c;
          addr.Force_Location_Update_gne__c = false;
          addrChanged = true;
        } else if (this.useGoogleDao) {
          addrChanged = addr.Force_Location_Update_gne__c;

          Double oldLat = addr.Location_gne__Latitude__s;
          Double oldLong = addr.Location_gne__Longitude__s;

          addr.Force_Location_Update_gne__c = true;
          GNE_SFA2_AddressLocation_Util.setAddressLocation(addr, false);

          Double newLat = addr.Location_gne__Latitude__s;
          Double newLong = addr.Location_gne__Longitude__s;

          addrChanged = addrChanged || oldLat != newLat || oldLong != newLong;
        }
      } catch (GNE_SFA2_GoogleGeoCode_DAO.GoogleGeoCodeServiceException ggcse) {
        handleException(ggcse, addr);
        metrics.increaseFailed();

        if (ggcse.isLimitExceeded()) {
          this.googleApiDailyLimitExceeded = true;
          break;
        }
      } catch (Exception ex) {
        handleException(ex, addr);
        metrics.increaseFailed();
      }

      if (addrChanged) {
        addrsToUpdate.add(addr);
        metrics.increaseUpdates();
      }
    }

    if (!addrsToUpdate.isEmpty()) {
      GNE_SFA2_Address_Trigger_Helper.setAddressTrig(true);
      GNE_Batch_Runner.executeDML(this, addrsToUpdate, GNE_Batch_Runner.DMLType.UPDATE_DML, null, 'Update Address Coordinates');
      GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
    }

    if (this.isFRMHCOMappingMode) {
      Set<Id> addrIds = new Set<Id>();
      for (Address_vod__c a : addrs) {
        addrIds.add(a.Id);
      }
      GNE_SFA2_HCPtoFRMHCOMappingEngine.autoMappingAfterUpdateAddressCoordinates(addrIds);
    }
  }

  private void sleep(Long milis) {
    Long start = System.now().getTime();

    while (System.now().getTime() < (start + milis)) {}
  }

  public void finish(Database.BatchableContext BC) {
    GNE_Batch_Runner.doFinish(this, BC);
  }

  public void intFinish(Database.BatchableContext BC) {
    GNE_Batch_Runner.sendEmailNotification(this, (this.initialLoad ? 'Initial Load ' : '') + 'Job Completed!', metrics.print());
  }

  public void handleException(Exception ex, Address_vod__c addr) {
    GNE_Batch_Runner.handleException(this, ex, addr);
  }

  private class Metrics {
    private Integer totalCount;
    private Integer updatesCount;
    private Integer errorsCount;

    private Metrics() {
      this.totalCount = 0;
      this.updatesCount = 0;
      this.errorsCount = 0;
    }

    private void increaseTotal() {
      totalCount++;
    }

    private void increaseUpdates() {
      updatesCount++;
    }

    private void increaseFailed() {
      errorsCount++;
    }

    private String print() {
      return String.format('Addresses Total/Updated/Failed: {0}/{1}/{2}', new String[] {
                             String.valueOf(totalCount), String.valueOf(updatesCount), String.valueOf(errorsCount)
                           });
    }
  }
}