public with sharing class GNE_SFA2_PROSPECT_Event_Edit_Create_Ext extends GNE_SFA2_Dynamic_VF_Edit_Create { 

    public GNE_SFA2_PROSPECT_Event_Edit_Create_Ext(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_PROSPECT_Event_Layout');

        String locationId = ApexPages.currentPage().getParameters().get('objectId');
        String cloneFromId = ApexPages.currentPage().getParameters().get('cloneFrom');
        if(myObject == null){
            myObject = new CONGA_Event_gne__c();
        }
        if(availabilityMode == 'New'){
            myObject.put('OwnerId', UserInfo.getUserId());
            if(locationId != null && locationId !=''){
                myObject.put('Event_Location__c', locationId);
            }
            if(cloneFromId!= null && cloneFromId !=''){
                prepareClone(cloneFromId);
            }
        }
    }

    private void prepareClone(String cloneFromId){
        CONGA_Event_gne__c parentEvent;
        try{
            parentEvent = [SELECT
                            Name, BU__c, Description__c, End_Date__c, Event_Category__c, Event_Location__c, Global_Oncology__c, 
                            isActive__c, Key_Target_Audience__c, Start_Date__c
                          FROM CONGA_Event_gne__c
                          WHERE Id = :cloneFromId
                          LIMIT 1];
        } catch(Exception ex){
            system.debug('Parent Event not found: ' + ex);
        }
        if(parentEvent != null){
            myObject.put('Name', parentEvent.Name);
            myObject.put('BU__c', parentEvent.BU__c);
            myObject.put('Description__c', parentEvent.Description__c);
            myObject.put('End_Date__c', parentEvent.End_Date__c);
            myObject.put('Event_Category__c', parentEvent.Event_Category__c);
            myObject.put('Event_Location__c', parentEvent.Event_Location__c);
            myObject.put('Global_Oncology__c', parentEvent.Global_Oncology__c);
            myObject.put('isActive__c', parentEvent.isActive__c);
            myObject.put('Key_Target_Audience__c', parentEvent.Key_Target_Audience__c);
            myObject.put('Start_Date__c', parentEvent.Start_Date__c);
        }
    }
}