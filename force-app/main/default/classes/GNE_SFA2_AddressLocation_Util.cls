public without sharing class GNE_SFA2_AddressLocation_Util {
    public static final String ADDRESS_LOC_BATCH_SIZE = 'AddrLocBatchSize';
    public static final String ADDRESS_LOC_SCHEDULE_TIME = 'AddrLocScheduleTime';
    public static final String DEFAULT_ADDRESS_LOC_SCHEDULE_TIME = '*;11:25';
    
    public static void setAddressLocation(List<Address_vod__c> addrs, Boolean allowFutureCall, Boolean allowFieldUpdates) {
        for(Address_vod__c addr : addrs) {
            if(allowFieldUpdates==true) {
                addr.Force_Location_Update_gne__c = true;
            }
        }
        
        Boolean canCallFutureMethod = allowFutureCall==true && !System.isBatch() && !System.isFuture()  && !System.isQueueable() && !System.isScheduled();
        
        if(canCallFutureMethod && addrs.size()<=(Limits.getLimitFutureCalls()-Limits.getFutureCalls())) { // single mode: try to update in future call, batch mode: leave it for scheduled batch process
            for(Address_vod__c addr : addrs) {
                setAddressLocationFutureCall(JSON.serialize(new Address_vod__c(
                 Id = addr.Id,
                 Name = addr.Name,
                 City_vod__c = addr.City_vod__c,
                 State_vod__c = addr.State_vod__c,
                 Zip_vod__c = addr.Zip_vod__c,
                 Force_Location_Update_gne__c = addr.Force_Location_Update_gne__c
                )));
            }
        } else {
            scheduleBatchJob();
        }
    }
    
    private static void scheduleBatchJob() {
        GNE_SFA2_Scheduler.scheduleJob(new GNE_SFA2_AddressLocation_Scheduler(), 'AddressLocationBatchUpdate', getScheduleTime());
    }
    
    private static String getScheduleTime(){
        String scheduleTime = DEFAULT_ADDRESS_LOC_SCHEDULE_TIME;
        if(GNE_Foun_Misc_Config_Items_gne__c.getValues(GNE_SFA2_AddressLocation_Util.ADDRESS_LOC_SCHEDULE_TIME) != null){
            scheduleTime = GNE_Foun_Misc_Config_Items_gne__c.getValues(GNE_SFA2_AddressLocation_Util.ADDRESS_LOC_SCHEDULE_TIME).Configuration_Value_gne__c;
        }
        return scheduleTime;
    }
    
    @Future(callout=true)
    public static void setAddressLocationFutureCall(String addrInJSON) {
        Address_vod__c addr = (Address_vod__c)JSON.deserialize(addrInJSON, Address_vod__c.class);

        try {
            setAddressLocation(addr, false);
            GNE_SFA2_Address_Trigger_Helper.setAddressTrig(true);
            Database.update(addr);
            GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
        } catch(System.CalloutException cex) {
            scheduleBatchJob();
        } catch(Exception ex) {
            handleFutureCallException(ex, addr);
        }
    }
    
    public static Boolean setAddressLocation(Address_vod__c addr) {
        return setAddressLocation(addr, true);    
    }
    
    public static Boolean setAddressLocation(Address_vod__c addr, Boolean safeMode) {
        if(addr.Force_Location_Update_gne__c==true) {
            List<Double> coords = getAddressCoords(addr, safeMode);
            
            if(coords!=null) {
                addr.Latitude_vod__c = addr.Location_gne__Latitude__s = coords[0];
                addr.Longitude_vod__c = addr.Location_gne__Longitude__s = coords[1];
            }
        }
      
        addr.Force_Location_Update_gne__c = false;
      
        return true;
    }
  
    private static List<Double> getAddressCoords(Address_vod__c addr, Boolean safeMode) {
        List<Double> result = null;
        GNE_SFA2_GoogleGeoCode_DAO.AddressCoords googleCoords = new GNE_SFA2_GoogleGeoCode_DAO().getAddressCoords(addr, safeMode);
    
        if(googleCoords!=null) {
            result = new List<Double>{googleCoords.latitude, googleCoords.longitude};
        } else if(String.isNotBlank(addr.Name)) {
            result = getAddressCoords(new Address_vod__c(City_vod__c = addr.City_vod__c, State_vod__c = addr.State_vod__c, Zip_vod__c = addr.Zip_vod__c), safeMode);
        }
    
        return result;
    }
  
    private static void handleFutureCallException(Exception ex, Address_vod__c addr) {
        GNE_SFA2_AddressLocation_Batch batch = new GNE_SFA2_AddressLocation_Batch();
        GNE_Batch_Runner.setIsStoreErrorsAndEmailsMode(true);
        batch.handleException(ex, addr);
        GNE_Batch_Runner.insertLogErrors(batch);
    }
}