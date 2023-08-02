public with sharing class EMS_Sidebar_Controller {

    public String pageName { get; set; }
    public List<Note> notes {
        get {
            if (notes == null) {
                notes = new List<Note>();
                List<EMS_Sidebar_Configuration__c> sidebarNotes = [
                        SELECT Id, Page_Name__c, Section_Title__c, Section_Body__c, Start_Date__c, End_Date__c, Active__c, Position__c, (SELECT Datetime_gne__c, User_gne__c, Viewed_gne__c FROM EMS_Sidebar_Viewers__r WHERE User_gne__c = :UserInfo.getUserId() ORDER BY LastModifiedDate ASC)
                        FROM EMS_Sidebar_Configuration__c
                        WHERE (Page_Name__c = :pageName OR Page_Name__c = NULL)
                        AND Active__c = true
                        AND ((Start_Date__c <= TODAY OR Start_Date__c = NULL) AND (End_Date__c >= TODAY OR End_Date__c = NULL))
                        ORDER BY Position__c ASC
                ];

                for (EMS_Sidebar_Configuration__c sidebarNote :sidebarNotes) {
                    notes.add(new Note(sidebarNote));
                }
            }
            return notes;
        }
        set;
    }

    public EMS_Sidebar_Controller() {

    }

    public String getNotesJSON() {
        return JSON.serialize(notes);
    }

    public class Note {
        private List<EMS_Sidebar_Viewer__c> views {
            get {
                if (views == null) views = new List<EMS_Sidebar_Viewer__c>();
                return views;
            }
            set;
        }
        private Date startDate { get; set; }
        private Date endDate { get; set; }

        public String pageName { get; set; }
        public String title { get; set; }
        public String body { get; set; }
        public String noteID { get; set; }
        public Boolean active { get; set; }
        public Boolean viewed { get; set; }

        public Note(EMS_Sidebar_Configuration__c noteData) {
            this.pageName = noteData.Page_Name__c;
            this.title = noteData.Section_Title__c;
            this.body = noteData.Section_Body__c;
            this.noteID = noteData.Id;
            this.startDate = noteData.Start_Date__c;
            this.endDate = noteData.End_date__c;
            this.active = noteData.Active__c;

            this.viewed = false;
            for (EMS_Sidebar_Viewer__c view :noteData.EMS_Sidebar_Viewers__r) {
                views.add(view);

                if (view.Viewed_gne__c == true) {
                    this.viewed = true;
                }
            }
        }
    }

    @RemoteAction
    public static EMS_Remote_Response readNotes(String noteID) {
		EMS_Remote_Response response = new EMS_Remote_Response();
		
        EMS_Sidebar_Viewer__c view = new EMS_Sidebar_Viewer__c(
                Datetime_gne__c = DateTime.now(),
                User_gne__c = UserInfo.getUserId(),
                Viewed_gne__c = true,
                EMS_Sidebar_Configuration_gne__c = noteID
        );

        try {
            insert view;
            response.isSuccess = true;
        } catch (Exception e) {
            response.addError(e.getMessage());
            response.isSuccess = false;
        }
        return response;
    }

}