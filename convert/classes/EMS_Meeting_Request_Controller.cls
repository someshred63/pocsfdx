public with sharing class EMS_Meeting_Request_Controller {
    public EMS_Meeting_Request_gne__c meetingRequest { get; set; }
    private EMS_Event__c event { get; set; }

    public EMS_Meeting_Request_Controller(ApexPages.StandardController stdControler) {
        event = (EMS_Event__c) stdControler.getRecord();
        meetingRequest = new EMS_Meeting_Request_gne__c();
        try {
            if (event.Id != null) {
                meetingRequest = [
                        SELECT Number_of_Attendees_gne__c, Number_of_Rooms__c, Additional_Comments_gne__c, Business_Unit_gne__c, Catering_Requirements_gne__c,
                                Hotel_1_City_gne__c, Hotel_2_City_gne__c, Hotel_3_City_gne__c, Dates_From_gne__c, Dates_To_gne__c, EMS_Event_gne__c, Flip_Charts_gne__c,
                                Hotel_1_Name_gne__c, Hotel_2_Name_gne__c, Hotel_3_Name_gne__c, Internet_Access_gne__c, LCD_Projector_gne__c, Meals_gne__c, Microphone_gne__c,
                                Requestor_Name__c, Phone_Ext_gne__c, Screen_gne__c, Separate_Room_Required_gne__c
                        FROM EMS_Meeting_Request_gne__c
                        WHERE EMS_Event_gne__c = :event.Id
                        LIMIT 1
                ];
            }
        } catch (System.QueryException e) {
            meetingRequest.EMS_Event_gne__c = event.Id;
        }
    }

    public String meetingRequestJSON {
        get {
            return JSON.serializePretty(meetingRequest);
        }
    }

    public boolean getCanEdit() {
        return EMS_Access.isMeetingRequestEditable(event);
    }

    // Remote Actions
    @RemoteAction
    public static EMS_Remote_Response upsertMeetingRequest(EMS_Meeting_Request_gne__c meetingRequest) {
        EMS_Remote_Response response = new EMS_Remote_Response();
        response.isSuccess = false;
        try {
            upsert meetingRequest;
            response.isSuccess = true;
            response.responseObject = meetingRequest;
        } catch (System.DMLException e) {
            response.addError('An error has occured during Meeting Request saving: ');
            for (Integer i = 0; i < e.getNumDml(); i++) {
                response.addError(e.getDmlMessage(i));
            }
        } catch (System.Exception e) {
            response.addError('An error has occured during Meeting Request saving: ');
        }
        return response;
    }

    @RemoteAction
    public static List<EMS_Meeting_Room_gne__c> getExistingMeetingRooms(Id meetingRequestId) {
        return [
                SELECT Number_of_Persons_gne__c, Any_Special_Requirements_gne__c, Break_Out_Room_gne__c, Date_gne__c, EMS_Meeting_Request_gne__c, Main_Plenary_gne__c, Room_Layout_gne__c, Time_gne__c
                FROM EMS_Meeting_Room_gne__c
                WHERE EMS_Meeting_Request_gne__c = :meetingRequestId
                ORDER BY createdDate ASC
        ];
    }

    @RemoteAction
    public static EMS_Remote_Response deleteMeetingRoom(String meetingRoomId) {
        EMS_Remote_Response response = new EMS_Remote_Response();
        response.isSuccess = true;
        try {
            delete [SELECT Id FROM EMS_Meeting_Room_gne__c WHERE Id = :meetingRoomId];
        } catch (DmlException ex) {
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                response.addError(ex.getDmlMessage(i));
            }
            response.isSuccess = false;
        } catch (Exception ex) {
            response.isSuccess = false;
            response.addError(ex.getMessage());
        }
        return response;
    }

    @RemoteAction
    public static EMS_Remote_Response saveMeetingRoom(EMS_Meeting_Room_gne__c meetingRoom) {
        EMS_Remote_Response response = new EMS_Remote_Response();
        response.isSuccess = true;
        try {
            upsert meetingRoom;
            response.recordId = meetingRoom.Id;
        } catch (DmlException ex) {
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                response.addError(ex.getDmlMessage(i));
            }
            response.isSuccess = false;
        } catch (Exception ex) {
            response.isSuccess = false;
            response.addError(ex.getMessage());
        }
        return response;
    }

}