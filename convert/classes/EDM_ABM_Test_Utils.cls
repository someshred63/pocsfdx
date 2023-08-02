@isTest
public with sharing class EDM_ABM_Test_Utils { 
    public class Triple {
        public String value1 {get; set;}
        public String value2 {get; set;}
        public Integer order {get; set;}
        public Boolean readOnly {get; set;}

        public Triple(String val1, String val2, Integer ord) {
            value1 = val1;
            value2 = val2;
            order = ord;
            readOnly = false;
        }
    }

    public static Triple makeReadOnlyTriple(String val1, String val2, Integer ord) {
        Triple tripl = new Triple(val1, val2, ord);
        tripl.readOnly = true;
        return tripl;
    }

    public class rlConf {
        public String attr {get; set;}
        public String obj {get; set;}
        public String label {get; set;}
        public Integer order {get; set;}

        public rlConf(String label, String obj, Integer ord, String attr) {
            this.label = label;
            this.obj = obj;
            this.order = ord;
            this.attr = attr;
        }
    }

    public static EDM_AABP_gne__c getTestAABP(String grp) {
        List<User> ableads = EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABLEAD);
        User selectedAbl;
        if (ableads.size() > 0) {
            selectedAbl = ableads[0];
        }

        List<User> absm = EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABS);
        User selectedAbs;
        if (absm.size() > 0) {
            selectedAbs = absm[0];
        }       
        EDM_AABP_gne__c aabp = getTestAABP(grp, selectedAbs, selectedAbl);

        return aabp;
    }

    public static EDM_AABP_gne__c getTestAABP(String grp, User abs, User abLead) {
        EDM_AABP_gne__c aabp = new EDM_AABP_gne__c();
        aabp.EDM_Group_gne__c = grp;
        aabp.EDM_Unit_gne__c = 'RA';
        aabp.EDM_Team_gne__c = 'Actemra';
        aabp.EDM_Plan_Year_gne__c = '2016';
        aabp.EDM_ABS_Manager_gne__c = abs.Id;
        aabp.EDM_AB_Lead_gne__c = abLead.Id;
        aabp.EDM_Vendor_Lead_gne__c = abLead.Id;
        aabp.EDM_Plan_Received_gne__c = Date.parse('05/07/2015');
        aabp.EDM_Final_Approval_Received_gne__c = Date.parse('05/07/2015');
        aabp.EDM_ABS_Manager_gne__c = UserInfo.getUserId();

        return aabp;
    }
    
    public static EDM_IABP_gne__c getTestIABP(String meetingApproach, Boolean isExeSum, String meetingDate, Id parentAABP) {
        EDM_IABP_gne__c iabp = new EDM_IABP_gne__c();
        iabp.EDM_Type_of_Event_gne__c = 'CAB';
        iabp.EDM_Executive_Summary_gne__c = isExeSum;
        iabp.EDM_Meeting_Approach_gne__c = meetingApproach;
        iabp.EDM_Estimated_Quarter_gne__c = 'Q1';
        iabp.EDM_Start_Date_gne__c = Date.parse(meetingDate);
        iabp.EDM_End_Date_gne__c = Date.parse(meetingDate);
        iabp.EDM_Meeting_Date_gne__c = Date.parse(meetingDate);
        iabp.EDM_IABP_Version_gne__c = 0;
        List<User> ablead = EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABLEAD);
        if (ablead.size() > 0) {
            iabp.EDM_Primary_AB_Lead_gne__c = ablead[0].Id;
        }
        iabp.EDM_Parent_AABP_gne__c = parentAABP;
        iabp.EDM_Strategic_Context_gne__c = 'Context';
        iabp.EDM_Advisor_Selection_Criteria_gne__c = 'Criteria';
        iabp.EDM_Advisor_Selection_Duties_gne__c = 'Duties';
        iabp.EDM_ABS_Manager_gne__c = UserInfo.getUserId();

        return iabp;
    }

    public static EDM_Session_gne__c getSession(Id parentIABP, Boolean isBreak) {
        EDM_Session_gne__c session = new EDM_Session_gne__c();
        session.EDM_Parent_IABP_gne__c = parentIABP;
        session.EDM_Is_Break_gne__c = isBreak;
        session.EDM_Title_gne__c = 'Session Test';
        session.EDM_Discussion_Start_Time_gne__c = '1:00 PM';
        if (!isBreak) {
            session.EDM_Discussion_End_Time_gne__c = '1:20 PM';
            session.EDM_Presentation_Start_Time_gne__c = '1:20 PM';
        }       
        session.EDM_Presentation_End_Time_gne__c = '1:40 PM';
        return session;
    }

    public static List<sObject> insertABMStructure() {
        List<sObject> AABPnIABP = new List<sObject>();
        EDM_AABP_gne__c aabp = getTestAABP('Commercial');
        insert aabp;
        EDM_IABP_gne__c iabp = getTestIABP('Face to Face', false, '04/04/2016', aabp.Id);
        insert iabp;
        EDM_Session_gne__c session = getSession(iabp.Id, false);
        insert session;

        AABPnIABP.add(aabp);
        AABPnIABP.add(iabp);
        return AABPnIABP;
    }

    public static List<User> getABSes() {
        return EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABS);
    }

    public static List<User> getABLs() {
        return EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABLEAD);
    }

    public static List<User> getApprovers() {
        return EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABAPPROVER);
    }

    public static void insertIABPConfig(){
        insertIABPConfig(null);
    }

    public static void insertIABPConfig(String recordTypeStr) {
        List<String> Roles = new List<String> { 'AB-Approver', 'AB-Reviewer', 'ABS-Manager', 'VDST-ABM', 'AB-Lead'};
        String Brand = null;
        String Appl = 'ABM';
        String AvMode = 'New;Edit;View';
        String RecordType = recordTypeStr;

        Savepoint sp = Database.setSavepoint(); 
        for (String Role : Roles) {
            try { 
                List<SFA2_Configuration_Object_gne__c> toInsertList = new List<SFA2_Configuration_Object_gne__c>();

                SFA2_Configuration_Object_gne__c confEventShareBtn = new SFA2_Configuration_Object_gne__c();
                confEventShareBtn.Name = 'EDM_IABP_gne__c_buttons';
                confEventShareBtn.Application_Type__c = Appl;
                confEventShareBtn.Brand_gne__c = Brand;
                confEventShareBtn.Role_gne__c = Role;
                confEventShareBtn.Record_Type_gne__c = RecordType;
                confEventShareBtn.Configuration_Type_gne__c = 'Page';
                confEventShareBtn.Is_Active_gne__c = true;
                confEventShareBtn.Object_Name_gne__c = 'EDM_IABP_gne__c';
                confEventShareBtn.Order_gne__c = 0;
                confEventShareBtn.OTR2_gne__c = false;
                confEventShareBtn.Section_Header_gne__c = null;
                toInsertList.add(confEventShareBtn);

                SFA2_Configuration_Object_gne__c confEventRl = new SFA2_Configuration_Object_gne__c();
                confEventRl.Name = 'EDM_IABP_gne__c_rl';
                confEventRl.Application_Type__c = Appl;
                confEventRl.Brand_gne__c = Brand;
                confEventRl.Role_gne__c = Role;
                confEventRl.Record_Type_gne__c = RecordType;
                confEventRl.Configuration_Type_gne__c = 'Page';
                confEventRl.Is_Active_gne__c = true;
                confEventRl.Object_Name_gne__c = 'EDM_IABP_gne__c';
                confEventRl.Order_gne__c = 0;
                confEventRl.OTR2_gne__c = false;
                confEventRl.Section_Header_gne__c = null;
                toInsertList.add(confEventRl);
                
                List<Triple> fTriplesC = new List<Triple>();
                fTriplesC.add(new Triple('Event Details', '', 0));
                fTriplesC.add(new Triple('Event Documentation Status', '', 1));
                fTriplesC.add(new Triple('Logistics Vendor', '', 2));
                fTriplesC.add(new Triple('Content Vendor', '', 3));
                fTriplesC.add(new Triple('Strategic Context', '', 4));
                fTriplesC.add(new Triple('Affiliated with Major Medical Meeting or Congress (optional)', '', 5));
                fTriplesC.add(new Triple('Advisory Board Objectives', '', 6));
                fTriplesC.add(new Triple('Advisor Selection Criteria', '', 7));
                fTriplesC.add(new Triple('Exception Request', '', 8));

                for(Triple trpl : fTriplesC) {
                    SFA2_Configuration_Object_gne__c confEventDetails = new SFA2_Configuration_Object_gne__c();
                    confEventDetails.Name = 'EDM_IABP_gne__c_detail';
                    confEventDetails.Application_Type__c = Appl;
                    confEventDetails.Brand_gne__c = Brand;
                    confEventDetails.Role_gne__c = Role;
                    confEventDetails.Record_Type_gne__c = RecordType;
                    confEventDetails.Configuration_Type_gne__c = 'Page';
                    confEventDetails.Is_Active_gne__c = true;
                    confEventDetails.Object_Name_gne__c = 'EDM_IABP_gne__c';
                    confEventDetails.Order_gne__c = trpl.order;
                    confEventDetails.OTR2_gne__c = false;
                    confEventDetails.Section_Header_gne__c = trpl.value1;
                    toInsertList.add(confEventDetails);
                }
                insert toInsertList;

                List<SFA2_Configuration_Object_Detail_gne__c> listDetail = new List<SFA2_Configuration_Object_Detail_gne__c>();

                for (SFA2_Configuration_Object_gne__c insertedConf : toInsertList) {
                    if (insertedConf.Name == 'EDM_IABP_gne__c_buttons') {
                        SFA2_Configuration_Object_Detail_gne__c shareBtn = new SFA2_Configuration_Object_Detail_gne__c();
                        shareBtn.Configuration_Object_ref_gne__c = insertedConf.Id;
                        shareBtn.API_Name_gne__c = 'EDM_Share';
                        shareBtn.Availability_Mode_gne__c = AvMode;
                        shareBtn.Attributes_gne__c = 'action=share;rerender=main-content;styleClass=button sfa-plh sfa-plh-title-bar;';
                        shareBtn.Is_Active_gne__c = true;
                        shareBtn.Label_gne__c = 'Share';
                        shareBtn.Order_gne__c = 0;
                        shareBtn.Type_gne__c = 'Button';
                        listDetail.add(shareBtn);
                    }

                    if (insertedConf.Name == 'EDM_IABP_gne__c_rl') {
                        List<rlConf> listRLs = new List<rlConf>();
                        listRLs.add(new rlConf('Advisory Board Objectives', 'EDM_Objective_gne__c', 0, 'fieldsCSV=EDM_Group_gne__c,EDM_Number_gne__c,EDM_Description_gne__c,EDM_Projected_Output_gne__c;parentFieldName=EDM_Parent_IABP_gne__c;orderByFieldName=EDM_Group_gne__c;'));
                        listRLs.add(new rlConf('Cross-Functional Attendees', 'EDM_Attendee_gne__c', 1, 'fieldsCSV=EDM_Role_gne__c,EDM_Purpose_gne__c;parentFieldName=EDM_Parent_IABP_gne__c;orderByFieldName=EDM_Role_gne__c;'));
                        listRLs.add(new rlConf('Agenda', 'EDM_Session_gne__c', 2, 'fieldsCSV=EDM_Title_gne__c,EDM_Discussion_Start_Time_gne__c,EDM_Discussion_End_Time_gne__c,EDM_Description_gne__c;parentFieldName=EDM_Parent_IABP_gne__c;orderByFieldName=EDM_Discussion_Start_Time_gne__c;'));
                        listRLs.add(new rlConf('Agenda (Advisory Board Questions)', 'EDM_Question_gne__c', 3, 'fieldsCSV=EDM_Value_gne__c,EDM_Estimated_Minutes_gne__c;parentFieldName=EDM_Parent_Exe_Summary_gne__c;'));
                        listRLs.add(new rlConf('Add Genentech and Partner Company Representatives', 'EDM_Attendee_gne__c(1)', 4, 'fieldsCSV=EDM_Name_gne__c,EDM_Role_gne__c,EDM_Purpose_gne__c;parentFieldName=EDM_Parent_IABP_gne__c;orderByFieldName=EDM_Name_gne__c;filter=EDM_System_Type_gne__c#\'Genentech\';'));
                        listRLs.add(new rlConf('Add Advisors', 'EDM_Attendee_gne__c(2)', 5, 'fieldsCSV=EDM_Name_gne__c,EDM_Role_gne__c,EDM_Type_gne__c,EDM_Clinical_Classification_gne__c,EDM_Business_Classification_gne__c,EDM_Exclusion_Status_gne__c;parentFieldName=EDM_Parent_IABP_gne__c;orderByFieldName=EDM_Type_gne__c;filter=EDM_System_Type_gne__c#\'Other\';'));
                        listRLs.add(new rlConf('Budget', 'EDM_Budget_gne__c', 6, 'fieldsCSV=EDM_Type_gne__c,EDM_Amount_gne__c;parentFieldName=EDM_Parent_IABP_gne__c;orderByFieldName=EDM_Type_gne__c;'));
                        listRLs.add(new rlConf('Event Documents', 'EDM_Attachment_gne__c(1)', 7, 'fieldsCSV=EDM_Type_gne__c,EDM_Description_gne__c,EDM_Link_gne__c;parentFieldName=EDM_Parent_IABP_gne__c;orderByFieldName=EDM_Type_gne__c;filter=EDM_System_Type_gne__c#\'Event Documents\';'));

                        for(rlConf rlCnf : listRLs) {
                            SFA2_Configuration_Object_Detail_gne__c eventFields = new SFA2_Configuration_Object_Detail_gne__c();
                            eventFields.Configuration_Object_ref_gne__c = insertedConf.Id;
                            eventFields.API_Name_gne__c = rlCnf.obj;
                            eventFields.Attributes_gne__c = rlCnf.attr;
                            eventFields.Availability_Mode_gne__c = AvMode;
                            eventFields.Is_Active_gne__c = true;
                            eventFields.Label_gne__c = rlCnf.label;
                            eventFields.Order_gne__c = rlCnf.order;
                            eventFields.Type_gne__c = 'Related List';
                            listDetail.add(eventFields);
                        }
                    }

                    if (insertedConf.Section_Header_gne__c == 'Event Details') {
                        
                        List<Triple> fTriples = new List<Triple>();
                        fTriples.add(new Triple('EDM_Event_Name_gne__c', 'Event ID', 0));
                        fTriples.add(new Triple('EDM_Year_gne__c', 'Year', 1));
                        fTriples.add(new Triple('EDM_Team_gne__c', 'Team(s)', 2));
                        fTriples.add(new Triple('EDM_Brand_gne__c', 'Brand/Indication', 3));
                        fTriples.add(new Triple('EDM_Type_of_Event_gne__c', 'Type of Event', 4));
                        fTriples.add(new Triple('EDM_Name_gne__c', 'Title', 5));
                        fTriples.add(new Triple('EDM_Optional_Detail_gne__c', 'Optional Detail', 6));
                        fTriples.add(new Triple('EDM_Start_Date_gne__c', 'Start Date', 7));
                        fTriples.add(new Triple('EDM_End_Date_gne__c', 'End Date', 8));
                        fTriples.add(new Triple('EDM_Meeting_Date_gne__c', 'Meeting Date', 9));
                        fTriples.add(new Triple('EDM_Meeting_Approach_gne__c', 'Meeting Approach', 10));
                        fTriples.add(new Triple('EDM_Joint_Approach_gne__c', 'Joint Approach', 11));
                        fTriples.add(new Triple('EDM_City_gne__c', 'City', 12));
                        fTriples.add(new Triple('EDM_State_gne__c', 'State/Province', 13));
                        fTriples.add(new Triple('EDM_Country_gne__c', 'Country', 14));
                        fTriples.add(new Triple('EDM_Venue_gne__c', 'Venue', 15));
                        fTriples.add(new Triple('EDM_Primary_AB_Lead_gne__c', 'Primary AB Lead', 16));
                        fTriples.add(new Triple('EDM_Secondary_AB_Lead_gne__c', 'Second AB Lead', 17));
                        fTriples.add(new Triple('EDM_Third_AB_Lead_gne__c', 'Third AB Lead', 18));
                        fTriples.add(new Triple('EDM_Admin_gne__c', 'Admin', 19));
                        fTriples.add(new Triple('EDM_Primary_Vendor_Lead_gne__c', 'Primary Vendor Lead', 20));
                        fTriples.add(new Triple('EDM_Second_Vendor_Lead_gne__c', 'Second Vendor Lead', 21));
                        fTriples.add(new Triple('EDM_Est_nr_of_Gne_Attendees_gne__c', 'Estimated nr of GNE Attendees',22));
                        fTriples.add(new Triple('EDM_Est_nr_of_Attendees_gne__c', 'Estimated nr of Attendees',23));
                        fTriples.add(new Triple('EDM_Actual_Nr_of_Advisors_gne__c', 'Actual nr of Advisors',24));
                        fTriples.add(new Triple('EDM_Actual_Nr_of_Gene_Reps_gne__c', 'Actual nr of GNE Attendees',25));


                        for(Triple trpl : fTriples) {
                            SFA2_Configuration_Object_Detail_gne__c eventFields = new SFA2_Configuration_Object_Detail_gne__c();
                            eventFields.Configuration_Object_ref_gne__c = insertedConf.Id;
                            eventFields.API_Name_gne__c = trpl.value1;
                            eventFields.Availability_Mode_gne__c = AvMode;
                            eventFields.Is_Active_gne__c = true;
                            eventFields.Label_gne__c = trpl.value2;
                            eventFields.Order_gne__c = trpl.order;
                            eventFields.Type_gne__c = 'Field';
                            eventFields.Is_Read_Only_gne__c = trpl.readOnly;
                            listDetail.add(eventFields);
                        }   

                    }
                    
                    if(insertedConf.Section_Header_gne__c == 'Event Documentation Status') {
                        List<Triple> fTriples = new List<Triple>();
                        fTriples.add(makeReadOnlyTriple('EDM_IABP_Submitted_gne__c', 'IABP Submitted', 0));
                        fTriples.add(makeReadOnlyTriple('EDM_IABP_Approved_gne__c', 'IABP Approved', 1));
                        fTriples.add(makeReadOnlyTriple('EDM_Approved_By_gne__c', 'Approved By', 2));
                        fTriples.add(makeReadOnlyTriple('EDM_IABP_Version_gne__c', 'IABP Version', 3));
                        fTriples.add(makeReadOnlyTriple('EDM_Version_Validated_gne__c', 'Version Validated', 4));
                        fTriples.add(makeReadOnlyTriple('EDM_ExeSum_Submitted_gne__c', 'ExeSum Submitted', 5));
                        fTriples.add(makeReadOnlyTriple('EDM_ExeSum_Finalized_gne__c', 'ExeSum Finalized', 6));
                        
                        for(Triple trpl : fTriples) {
                            SFA2_Configuration_Object_Detail_gne__c eventFields = new SFA2_Configuration_Object_Detail_gne__c();
                            eventFields.Configuration_Object_ref_gne__c = insertedConf.Id;
                            eventFields.API_Name_gne__c = trpl.value1;
                            eventFields.Availability_Mode_gne__c = AvMode;
                            eventFields.Is_Active_gne__c = true;
                            eventFields.Label_gne__c = trpl.value2;
                            eventFields.Order_gne__c = trpl.order;
                            eventFields.Type_gne__c = 'Field';
                            eventFields.Is_Read_Only_gne__c = true;
                            listDetail.add(eventFields);
                        }
                    }
                    
                    if(insertedConf.Section_Header_gne__c == 'Logistics Vendor') {
                        List<Triple> fTriples = new List<Triple>();
                        fTriples.add(new Triple('EDM_Log_Vendor_Company_Name_gne__c', 'Company Name', 0));
                        fTriples.add(new Triple('EDM_Log_Vendor_Contact_Name_gne__c', 'Contact', 1));
                        fTriples.add(new Triple('EDM_Log_Vendor_Contact_Email_gne__c', 'Contact Email', 2));
                        
                        for(Triple trpl : fTriples) {
                            SFA2_Configuration_Object_Detail_gne__c eventFields = new SFA2_Configuration_Object_Detail_gne__c();
                            eventFields.Configuration_Object_ref_gne__c = insertedConf.Id;
                            eventFields.API_Name_gne__c = trpl.value1;
                            eventFields.Availability_Mode_gne__c = AvMode;
                            eventFields.Is_Active_gne__c = true;
                            eventFields.Label_gne__c = trpl.value2;
                            eventFields.Order_gne__c = trpl.order;
                            eventFields.Type_gne__c = 'Field';
                            listDetail.add(eventFields);
                        }
                    }
                    
                    if(insertedConf.Section_Header_gne__c == 'Content Vendor') {
                        List<Triple> fTriples = new List<Triple>();
                        fTriples.add(new Triple('EDM_Cont_Vendor_Company_Name_gne__c', 'Company Name', 0));
                        fTriples.add(new Triple('EDM_Cont_Vendor_Contact_Name_gne__c', 'Contact', 1));
                        fTriples.add(new Triple('EDM_Cont_Vendor_Contact_Email_gne__c', 'Contact Email', 2));
                        
                        for(Triple trpl : fTriples) {
                            SFA2_Configuration_Object_Detail_gne__c eventFields = new SFA2_Configuration_Object_Detail_gne__c();
                            eventFields.Configuration_Object_ref_gne__c = insertedConf.Id;
                            eventFields.API_Name_gne__c = trpl.value1;
                            eventFields.Availability_Mode_gne__c = AvMode;
                            eventFields.Is_Active_gne__c = true;
                            eventFields.Label_gne__c = trpl.value2;
                            eventFields.Order_gne__c = trpl.order;
                            eventFields.Type_gne__c = 'Field';
                            listDetail.add(eventFields);
                        }
                    }

                    if(insertedConf.Section_Header_gne__c == 'Strategic Context') {
                        SFA2_Configuration_Object_Detail_gne__c eventFields = new SFA2_Configuration_Object_Detail_gne__c();
                        eventFields.Configuration_Object_ref_gne__c = insertedConf.Id;
                        eventFields.API_Name_gne__c = 'EDM_Strategic_Context_gne__c';
                        eventFields.Availability_Mode_gne__c = AvMode;
                        eventFields.Is_Active_gne__c = true;
                        eventFields.Label_gne__c = '';
                        eventFields.Order_gne__c = 0;
                        eventFields.Type_gne__c = 'Field';
                        listDetail.add(eventFields);
                    }
                    
                    if(insertedConf.Section_Header_gne__c == 'Affiliated with Major Medical Meeting or Congress (Optional)') {
                        SFA2_Configuration_Object_Detail_gne__c eventFields = new SFA2_Configuration_Object_Detail_gne__c();
                        eventFields.Configuration_Object_ref_gne__c = insertedConf.Id;
                        eventFields.API_Name_gne__c = 'EDM_Affiliated_w_Meeting_Congress_gne__c';
                        eventFields.Availability_Mode_gne__c = AvMode;
                        eventFields.Is_Active_gne__c = true;
                        eventFields.Label_gne__c = '';
                        eventFields.Order_gne__c = 0;
                        eventFields.Type_gne__c = 'Field';
                        listDetail.add(eventFields);
                    }
                        
                    
                    if(insertedConf.Section_Header_gne__c == 'Advisor Selection Criteria') {
                        List<Triple> fTriples = new List<Triple>();
                        fTriples.add(new Triple('EDM_Advisor_Selection_Criteria_gne__c', 'Advisor Selection Criteria', 0));
                        fTriples.add(new Triple('EDM_Advisor_Selection_Duties_gne__c', 'Advisor Duties', 1));
                        fTriples.add(new Triple('EDM_Moderator_Selection_Criteria_gne__c', 'Moderator Selection Criteria', 2));
                        fTriples.add(new Triple('EDM_Moderator_Selection_Duties_gne__c', 'Moderator Duties', 3));
                        fTriples.add(new Triple('EDM_Chair_Selection_Criteria_gne__c', 'Chair Selection Criteria', 4));
                        fTriples.add(new Triple('EDM_Chair_Selection_Duties_gne__c', 'Chair Duties', 5));
                        fTriples.add(new Triple('EDM_Cl_Expert_Selection_Criteria_gne__c', 'Clinical Expert Selection Criteria', 6));
                        fTriples.add(new Triple('EDM_Cl_Expert_Selection_Duties_gne__c', 'Clinical Expert Duties', 7));
                        
                        for(Triple trpl : fTriples) {
                            SFA2_Configuration_Object_Detail_gne__c eventFields = new SFA2_Configuration_Object_Detail_gne__c();
                            eventFields.Configuration_Object_ref_gne__c = insertedConf.Id;
                            eventFields.API_Name_gne__c = trpl.value1;
                            eventFields.Availability_Mode_gne__c = AvMode;
                            eventFields.Is_Active_gne__c = true;
                            eventFields.Label_gne__c = trpl.value2;
                            eventFields.Order_gne__c = trpl.order;
                            eventFields.Type_gne__c = 'Field';
                            listDetail.add(eventFields);
                        }
                    }
                    
                    if(insertedConf.Section_Header_gne__c == 'Exception Request') {
                        SFA2_Configuration_Object_Detail_gne__c eventFields = new SFA2_Configuration_Object_Detail_gne__c();
                        eventFields.Configuration_Object_ref_gne__c = insertedConf.Id;
                        eventFields.API_Name_gne__c = 'EDM_Exception_Type_gne__c';
                        eventFields.Availability_Mode_gne__c = AvMode;
                        eventFields.Is_Active_gne__c = true;
                        eventFields.Label_gne__c = 'Exception Type';
                        eventFields.Order_gne__c = 0;
                        eventFields.Type_gne__c = 'Field';
                        listDetail.add(eventFields);

                        SFA2_Configuration_Object_Detail_gne__c eventFields2 = new SFA2_Configuration_Object_Detail_gne__c();
                        eventFields2.Configuration_Object_ref_gne__c = insertedConf.Id;
                        eventFields2.API_Name_gne__c = 'EDM_Exception_Rationale_gne__c';
                        eventFields2.Availability_Mode_gne__c = AvMode;
                        eventFields2.Is_Active_gne__c = true;
                        eventFields2.Label_gne__c = 'Rationale';
                        eventFields2.Order_gne__c = 1;
                        eventFields2.Type_gne__c = 'Field';
                        listDetail.add(eventFields2);
                    }
                }
                insert listDetail;

            }
            catch (Exception ex) { 
                System.debug(ex.getMessage());
                Database.rollback(sp); 
            }
        }

    }

    public static Boolean userHasReadAccessToRecord(Id usrId, Id recordId) {
        List<UserRecordAccess> ura = [SELECT RecordId FROM UserRecordAccess WHERE UserId = :usrId AND RecordId = :recordId AND HasReadAccess = true];
        return ura.size() > 0;
    }
}