public with sharing class EDM_IABP_Utils {

    public enum AttendeeSystemType { Advisor, Genentech, Other, NonUSAdvisor}

    public class EventDocsWrapper {
        public Integer Count { get; set; }
        public Boolean currentUserUploadedDoc { get; set; }
        public EDM_Attachment_gne__c EventDoc { get; set; }

        public EventDocsWrapper(Integer c, EDM_Attachment_gne__c at) {
            this.Count = c;
            this.currentUserUploadedDoc = at.createdById == UserInfo.getUserId() ? true : false;
            this.EventDoc = at;
        }
    }

    public class SystemDocsWrapper {
        public Integer Count { get; set; }
        public EDM_Attachment_gne__c SystemDoc { get; set; }

        public SystemDocsWrapper(Integer c, EDM_Attachment_gne__c at) {
            this.Count = c;
            this.SystemDoc = at;
        }
    }

    public class ABSCommentsDocsWrapper {
        public Integer Count { get; set; }
        public EDM_ABS_Comment_gne__c ABSCommentDoc { get; set; }
        public Boolean currentUserUploadedDoc { get; set; }

        public ABSCommentsDocsWrapper(Integer c, EDM_ABS_Comment_gne__c absComment) {
            this.Count = c;
            this.ABSCommentDoc = absComment;
            this.currentUserUploadedDoc = absComment.createdById == UserInfo.getUserId() ? true : false;
        }
    }

    public class BudgetWrapper {
        public Integer Count { get; set; }
        public EDM_Budget_gne__c BudgetItem { get; set; }

        public BudgetWrapper(Integer c, EDM_Budget_gne__c bi) {
            this.Count = c;
            this.BudgetItem = bi;
        }
    }

    public class AttendeesWrapper {
        public Integer Count { get; set; }
        public Boolean ReadOnly { get; set; }
        public EDM_Attendee_gne__c attendee { get; set; }

        public AttendeesWrapper(Integer c, EDM_Attendee_gne__c o) {
            this.Count = c;
            this.attendee = o;
        }

        public Date getDateAdded() {
            if (attendee.EDM_Date_Added_gne__c == null) {
                return null;
            }
            return Date.newInstance(attendee.EDM_Date_Added_gne__c.year(), attendee.EDM_Date_Added_gne__c.month(), attendee.EDM_Date_Added_gne__c.day());
        }
    }

    public class ABQuestionsWrapper {
        public Integer Count { get; set; }
        public EDM_Question_gne__c Question { get; set; }

        public ABQuestionsWrapper(Integer c, EDM_Question_gne__c q) {
            this.Count = c;
            this.Question = q;
            this.Question.EDM_Type_gne__c = 'Advisory Board';
        }
    }

    public class ABObjWrapper implements Comparable {


        public Integer Count { get; set; }
        public EDM_Objective_gne__c Objective { get; set; }
        public String Description { get; set; }

        public ABObjWrapper(Integer c, EDM_Objective_gne__c ob) {
            this.Count = c;
            this.Objective = ob;
        }

        public ABObjWrapper(Integer c, EDM_Objective_gne__c ob, String descr) {
            this(c, ob);
            this.Description = descr;
        }

        public Integer compareTo(Object compareTo) {
            ABObjWrapper compareToW = (ABObjWrapper)compareTo;

            if (Objective.EDM_Group_gne__c > compareToW.Objective.EDM_Group_gne__c) {
                return 1;
            }
            else if (Objective.EDM_Group_gne__c < compareToW.Objective.EDM_Group_gne__c) {
                return -1;
            }

            return Integer.valueOf(Objective.EDM_Number_gne__c - compareToW.Objective.EDM_Number_gne__c);
        }
    }

    public class AgendaWrapper implements Comparable {

        public Integer Count { get; set; }
        public EDM_Session_gne__c Session { get; set; }

        public AgendaWrapper(Integer c, EDM_Session_gne__c se) {
            this.Count = c;
            this.Session = se;
        }

        public Integer compareTo(Object compareTo) {
            AgendaWrapper compareToW = (AgendaWrapper)compareTo;

            if (Session.EDM_Session_Date_gne__c > compareToW.Session.EDM_Session_Date_gne__c) {
                return 1;
            } else if (Session.EDM_Session_Date_gne__c < compareToW.Session.EDM_Session_Date_gne__c) {
                return -1;
            }

            String ct1 = '';
            String ct2 = '';

            if (Session.EDM_No_Presentation_gne__c) {
                ct1 = Session.EDM_Discussion_Start_Time_gne__c.split(':|\\s')[2]
                        + Session.EDM_Discussion_Start_Time_gne__c.split(':|\\s')[0]
                        + Session.EDM_Discussion_Start_Time_gne__c.split(':|\\s')[1];


            }
            else {
                ct1 = Session.EDM_Presentation_Start_Time_gne__c.split(':|\\s')[2]
                        + Session.EDM_Presentation_Start_Time_gne__c.split(':|\\s')[0]
                        + Session.EDM_Presentation_Start_Time_gne__c.split(':|\\s')[1];

            }

            if (compareToW.Session.EDM_No_Presentation_gne__c) {
                ct2 = compareToW.Session.EDM_Discussion_Start_Time_gne__c.split(':|\\s')[2]
                        + compareToW.Session.EDM_Discussion_Start_Time_gne__c.split(':|\\s')[0]
                        + compareToW.Session.EDM_Discussion_Start_Time_gne__c.split(':|\\s')[1];
            }
            else {
                ct2 = compareToW.Session.EDM_Presentation_Start_Time_gne__c.split(':|\\s')[2]
                        + compareToW.Session.EDM_Presentation_Start_Time_gne__c.split(':|\\s')[0]
                        + compareToW.Session.EDM_Presentation_Start_Time_gne__c.split(':|\\s')[1];
            }
            ct1 = ct1.replace('M12', 'M00');
            ct2 = ct2.replace('M12', 'M00');
            Integer returnValue = 0;
            if (ct1 > ct2) {
                returnValue = 1;
            }
            else if (ct1 < ct2) {
                returnValue = -1;
            }

            return returnValue;
        }
    }

    public class TimeWrapper {
        public String Hour { get; set; }
        public String Minute { get; set; }
        public String Period { get; set; }

        public void setFromString(String timeStr) {
            String[] timeParts;
            if (timeStr != null) {
                timeParts = timeStr.split(':|\\s');
                Hour = timeParts[0];
                Minute = timeParts[1];
                Period = timeParts[2];
            } else {
                Hour = null;
                Minute = null;
                Period = null;
            }
        }

        public override String toString() {
            return Hour + ':' + Minute + ' ' + Period;
        }

    }

    public static List<BudgetWrapper> populateBudget(EDM_IABP_gne__c parentIABP) {
        Integer i = 0;
        Set<String> budgetTypes = new Set<String>();
        List<BudgetWrapper> wList = new List<BudgetWrapper>();
        List<EDM_Budget_gne__c> aList =  [SELECT id, Name, EDM_Amount_gne__c, EDM_Parent_IABP_gne__c, EDM_Type_gne__c, EDM_Is_Default_gne__c,EDM_Description_gne__c
        FROM EDM_Budget_gne__c
        WHERE EDM_Parent_IABP_gne__c = :parentIABP.Id
        ORDER BY EDM_Is_Default_gne__c DESC, CreatedDate];
        for (EDM_Budget_gne__c b : aList) {
            wList.add(new BudgetWrapper(i, b));
            budgetTypes.add(b.EDM_Type_gne__c);
        }

        if (!budgetTypes.contains('Advisor') && parentIABP.EDM_Status_gne__c == 'IABP Not Started') {
            wList.add(new BudgetWrapper(i, new EDM_Budget_gne__c( EDM_Type_gne__c = 'Advisor', EDM_Is_Default_gne__c = true )));
        }
        if (!budgetTypes.contains('Moderator') && parentIABP.EDM_Status_gne__c == 'IABP Not Started') {
            wList.add(new BudgetWrapper(i, new EDM_Budget_gne__c( EDM_Type_gne__c = 'Moderator', EDM_Is_Default_gne__c = true )));
        }
        if (!budgetTypes.contains('Chair') && parentIABP.EDM_Status_gne__c == 'IABP Not Started') {
            wList.add(new BudgetWrapper(i, new EDM_Budget_gne__c( EDM_Type_gne__c = 'Chair', EDM_Is_Default_gne__c = true )));
        }
        if (!budgetTypes.contains('Clinical Expert') && parentIABP.EDM_Status_gne__c == 'IABP Not Started') {
            wList.add(new BudgetWrapper(i, new EDM_Budget_gne__c( EDM_Type_gne__c = 'Clinical Expert', EDM_Is_Default_gne__c = true )));
        }
        if (!budgetTypes.contains('Room Rate') && parentIABP.EDM_Status_gne__c == 'IABP Not Started') {
            wList.add(new BudgetWrapper(i, new EDM_Budget_gne__c( EDM_Type_gne__c = 'Room Rate', EDM_Is_Default_gne__c = true )));
        }
        if (!budgetTypes.contains('Meal/Breakfast') && parentIABP.EDM_Status_gne__c == 'IABP Not Started') {
            wList.add(new BudgetWrapper(i, new EDM_Budget_gne__c( EDM_Type_gne__c = 'Meal/Breakfast', EDM_Is_Default_gne__c = true )));
        }
        if (!budgetTypes.contains('Meal/Break') && parentIABP.EDM_Status_gne__c == 'IABP Not Started') {
            wList.add(new BudgetWrapper(i, new EDM_Budget_gne__c( EDM_Type_gne__c = 'Meal/Break', EDM_Is_Default_gne__c = true )));
        }
        if (!budgetTypes.contains('Meal/Lunch') && parentIABP.EDM_Status_gne__c == 'IABP Not Started') {
            wList.add(new BudgetWrapper(i, new EDM_Budget_gne__c( EDM_Type_gne__c = 'Meal/Lunch', EDM_Is_Default_gne__c = true )));
        }
        if (!budgetTypes.contains('Meal/Dinner') && parentIABP.EDM_Status_gne__c == 'IABP Not Started') {
            wList.add(new BudgetWrapper(i, new EDM_Budget_gne__c( EDM_Type_gne__c = 'Meal/Dinner', EDM_Is_Default_gne__c = true )));
        }

        for (BudgetWrapper w : wList) {
            w.Count = i;
            i++;
        }

        return wList;
    }

    public static List<AttendeesWrapper> populateAdvisors(Id iabpId) {
        return populateAttendeesByType(iabpId, AttendeeSystemType.Advisor);
    }

    public static List<AttendeesWrapper> populateNonUSAdvisors(Id iabpId) {
        return populateAttendeesByType(iabpId, AttendeeSystemType.NonUSAdvisor);
    }

    public static List<AttendeesWrapper> populateGeneRepresentatives(Id iabpId) {
        return populateAttendeesByType(iabpId, AttendeeSystemType.Genentech);
    }

    public static List<AttendeesWrapper> populateOtherAttendees(Id iabpId) {
        return populateAttendeesByType(iabpId, AttendeeSystemType.Other);
    }

    public static List<AttendeesWrapper> populateAttendeesByType(Id iabpId, AttendeeSystemType attendeeSysType) {
        Integer i = 0;
        List<AttendeesWrapper> wList = new List<AttendeesWrapper>();
        List<EDM_Attendee_gne__c> aList =  [
                SELECT Id, Name, EDM_Account_gne__c, EDM_Account_gne__r.Specialties_gne__c, EDM_Account_gne__r.AGS_EX_Date_Checked_Exclusion_gne__c, EDM_Business_Classification_gne__c, EDM_Business_Classification_Role_gne__c,
                        EDM_Contact_gne__c, EDM_Exclusion_Status_gne__c, EDM_Name_gne__c, EDM_Parent_IABP_gne__c, EDM_Purpose_gne__c,
                        EDM_Role_gne__c, EDM_System_Type_gne__c, EDM_Type_gne__c, EDM_User_gne__c, Region_Code_gne__c, EDM_Last_Name_gne__c,
                        EDM_First_Name_gne__c, CreatedDate, is_deleted_gne__c, EDM_Company_gne__c, EDM_Observer_gne__c,
                        EDM_Account_gne__r.FirstName, EDM_Account_gne__r.LastName, EDM_Is_Cross_Functional_gne__c, EDM_Country_gne__c,
                        Originate_from_ExeSum_gne__c, EDM_Parent_Attendee_gne__c, LastModifiedDate,
                        EDM_Current_Business_Classification_gne__c, EDM_Current_Business_Class_Role_gne__c, EDM_Current_Clinical_Classification_gne__c,
                        EDM_Current_Exclusion_Status_gne__c, EDM_Current_Business_Classif_Date_gne__c,
                        EDM_Current_Clinical_Classif_Date_gne__c, EDM_Current_Exclusion_Checked_Date_gne__c,
                        EDM_Current_Exclusion_Checked_Date_Disp__c,
                        EDM_Current_Clinical_Specialties_gne__c,
                        EDM_Business_Classification_Date_gne__c,
                        EDM_Clinical_Classification_gne__c,
                        EDM_Clinical_Classification_Date_gne__c,
                        EDM_Exclusion_Checked_Date_Drawloop_gne__c,
                        EDM_Date_Added_gne__c,
                        EDM_Date_Added_Snapshot_gne__c,
            			EDM_ID_For_Comparator_gne__c, EDM_Credentials_gne__c
                FROM EDM_Attendee_gne__c
                WHERE EDM_Parent_IABP_gne__c = :iabpId
                AND EDM_System_Type_gne__c = :attendeeSysType.name()];
        for (EDM_Attendee_gne__c a : aList) {
            wList.add(new AttendeesWrapper(i, a));
            i++;
        }
        return wList;
    }

    public static List<EDM_Attendee_gne__c> unwrapAttendeesWrapper(List<AttendeesWrapper> attendeesWrapper) {
        List<EDM_Attendee_gne__c> results = new List<EDM_Attendee_gne__c>();
        for (AttendeesWrapper attendeeWrapper : attendeesWrapper) {
                results.add(attendeeWrapper.attendee);
        }

        return results;
    }

    public static List<EDM_ABS_Comment_gne__c> unwrapABSCommentWrapper(List<ABSCommentsDocsWrapper> absCommentWrapper) {
        List<EDM_ABS_Comment_gne__c> results = new List<EDM_ABS_Comment_gne__c>();
        for (ABSCommentsDocsWrapper absCommWrapper : absCommentWrapper) {
            results.add(absCommWrapper.ABSCommentDoc);
        }

        return results;
    }

    public static void updateAbsManagerFromParentAABP(Map<Id,EDM_AABP_gne__c> triggerNew) {
        List<EDM_IABP_gne__c> iabpsToUpdate = new List<EDM_IABP_gne__c>();
                List<EDM_IABP_gne__c> childIabps = [SELECT Id, EDM_ABS_Manager_gne__c, EDM_Parent_AABP_gne__c
                FROM EDM_IABP_gne__c
                WHERE EDM_Parent_AABP_gne__c IN :triggerNew.keySet()];

        for (EDM_IABP_gne__c iabp : childIabps) {
            Id parentAbsManager = triggerNew.get(iabp.EDM_Parent_AABP_gne__c).EDM_ABS_Manager_gne__c;
            if(iabp.EDM_ABS_Manager_gne__c != parentAbsManager) {
                iabp.EDM_ABS_Manager_gne__c = parentAbsManager;
                iabpsToUpdate.add(iabp);
            }
        }

        update iabpsToUpdate;
    }

    public static void updateAbsManagerFromParentAABP(Map<Id,EDM_AABP_gne__c> triggerNew, Map<Id,EDM_AABP_gne__c> triggerOld) {
        List<EDM_IABP_gne__c> iabpsToUpdate = new List<EDM_IABP_gne__c>();
        List<EDM_IABP_gne__c> childIabps = [SELECT Id, EDM_ABS_Manager_gne__c, EDM_Parent_AABP_gne__c
        FROM EDM_IABP_gne__c
        WHERE EDM_Parent_AABP_gne__c IN :triggerNew.keySet()];

        for (EDM_IABP_gne__c iabp : childIabps) {
            Id newParentAbsManager = triggerNew.get(iabp.EDM_Parent_AABP_gne__c).EDM_ABS_Manager_gne__c;
            Id oldParentAbsManager = triggerOld.get(iabp.EDM_Parent_AABP_gne__c).EDM_ABS_Manager_gne__c;
            if(iabp.EDM_ABS_Manager_gne__c == oldParentAbsManager) {
                iabp.EDM_ABS_Manager_gne__c = newParentAbsManager;
                iabpsToUpdate.add(iabp);
            }
        }

        update iabpsToUpdate;
    }


    public static List<AgendaWrapper> populateAgenda(Id iabpId) {
        List<AgendaWrapper> wList = new List<AgendaWrapper>();
        List<EDM_Session_gne__c> oList = [SELECT Id, Name, EDM_Description_gne__c, EDM_Discussion_End_Time_gne__c, EDM_Discussion_Start_Time_gne__c, EDM_Parent_IABP_gne__c,
                EDM_Presentation_End_Time_gne__c, EDM_Presentation_Start_Time_gne__c, EDM_Presenter_gne__c, EDM_Title_gne__c, EDM_Is_Break_gne__c,
                EDM_No_Presentation_gne__c, EDM_No_Discussion_gne__c,
                EDM_Session_Date_gne__c
        FROM EDM_Session_gne__c
        WHERE EDM_Parent_IABP_gne__c = :iabpId];
        for (EDM_Session_gne__c se : oList) {
            wList.add(new AgendaWrapper(0, se));
        }
        wList.sort();
        for (Integer i = 0; i < wList.size(); i++) {
            wList[i].Count = i;
        }
        return wList;
    }

    public static List<EDM_Session_gne__c> unwrapAgendaWrapper(List<AgendaWrapper> agendaWrapperList) {
        List<EDM_Session_gne__c> results = new List<EDM_Session_gne__c>();
        for (AgendaWrapper agendaWrapperItem : agendaWrapperList) {
            results.add(agendaWrapperItem.session);
        }

        return results;
    }

    public static List<ABQuestionsWrapper> poplateABQuestions(Id iabpId) {
        Integer i = 0;
        List<ABQuestionsWrapper> wList = new List<ABQuestionsWrapper>();
        List<EDM_Question_gne__c> qList = [SELECT EDM_Estimated_Minutes_gne__c, EDM_Parent_Exe_Summary_gne__c, EDM_Value_gne__c, EDM_Type_gne__c
        FROM EDM_Question_gne__c
        WHERE EDM_Parent_Exe_Summary_gne__c = :iabpId
        AND EDM_Type_gne__c = 'Advisory Board'];
        for (EDM_Question_gne__c q : qList) {
            wList.add(new ABQuestionsWrapper(i, q));
            i++;
        }
        return wList;
    }

    public static List<ABObjWrapper> populateABObjectives(Id iabpId) {
        Integer i = 0;
        List<ABObjWrapper> wList = new List<ABObjWrapper>();
        List<EDM_Objective_gne__c> oList = [SELECT Id, Name, EDM_Description_gne__c, EDM_Group_gne__c, EDM_Number_gne__c, EDM_Parent_IABP_gne__c,
                EDM_Projected_Output_gne__c, Region_Code_gne__c
        FROM EDM_Objective_gne__c
        WHERE EDM_Parent_IABP_gne__c = :iabpId
        ORDER BY EDM_Group_gne__c, EDM_Number_gne__c];
        for (EDM_Objective_gne__c ob : oList) {
            wList.add(new ABObjWrapper(i, ob, ob.EDM_Description_gne__c));
            i++;
        }

        return wList;
    }

    public static List<EventDocsWrapper> populateEventDocuments(Set<Id> ids) {
        Integer i = 0;

        ids.remove(null);

        List<EventDocsWrapper> wList = new List<EventDocsWrapper>();
        List<EDM_Attachment_gne__c> aList =  [SELECT Id, Name, CreatedDate,  EDM_ABS_Review_Status_gne__c, EDM_Complete_gne__c, EDM_Description_gne__c, EDM_Document_Name_gne__c,
                EDM_Due_Date_gne__c, EDM_Estimated_Quarter_gne__c, EDM_Link_gne__c, EDM_Parent_AABP_gne__c, EDM_Parent_IABP_gne__c,
                EDM_Pull_Through_Doc_gne__c, EDM_Responsible_Party_gne__c, EDM_System_Type_gne__c, EDM_Type_gne__c,
                EDM_Upload_Date_gne__c, EDM_Year_gne__c, Region_Code_gne__c, CreatedById
        FROM EDM_Attachment_gne__c
        WHERE EDM_Parent_IABP_gne__c = :ids
        AND EDM_System_Type_gne__c = 'Event Document'];
        for (EDM_Attachment_gne__c a : aList) {
            wList.add(new EventDocsWrapper(i, a));
            i++;
        }
        return wList;
    }

    public static List<SystemDocsWrapper> populateSystemDocuments(Set<Id> ids) {
        Integer i = 0;

        ids.remove(null);

        List<SystemDocsWrapper> wList = new List<SystemDocsWrapper>();
        List<EDM_Attachment_gne__c> aList =  [SELECT Id, Name, CreatedDate, EDM_ABS_Review_Status_gne__c, EDM_Complete_gne__c, EDM_Description_gne__c, EDM_Document_Name_gne__c,
                EDM_Due_Date_gne__c, EDM_Estimated_Quarter_gne__c, EDM_Link_gne__c, EDM_Parent_AABP_gne__c, EDM_Parent_IABP_gne__c,
                EDM_Pull_Through_Doc_gne__c, EDM_Responsible_Party_gne__c, EDM_System_Type_gne__c, EDM_Type_gne__c,
                EDM_Upload_Date_gne__c, EDM_Year_gne__c, Region_Code_gne__c
        FROM EDM_Attachment_gne__c
        WHERE EDM_Parent_IABP_gne__c in :ids
        AND EDM_System_Type_gne__c = 'System Generated'];
        for (EDM_Attachment_gne__c a : aList) {
            wList.add(new SystemDocsWrapper(i, a));
            i++;
        }
        return wList;
    }

    public static List<ABSCommentsDocsWrapper> populateABSCommentsDocuments(Id id) {
        Integer i = 0;

        List<ABSCommentsDocsWrapper> wList = new List<ABSCommentsDocsWrapper>();
        List<EDM_ABS_Comment_gne__c> aList =  [
                SELECT Id, CreatedDate, CreatedById, ABS_Comment_gne__c, EDM_Attachment_gne__c, EDM_Date_Added_gne__c
                FROM EDM_ABS_Comment_gne__c
                WHERE EDM_Parent_IABP_gne__c = :id
                ORDER BY CreatedDate ASC
        ];
        for (EDM_ABS_Comment_gne__c a : aList) {
            wList.add(new ABSCommentsDocsWrapper(i, a));
            i++;
        }
        return wList;
    }

    public static void deleteABSComment(Id absCommentId, String edmLink) {
        delete [SELECT Id FROM EDM_ABS_Comment_gne__c WHERE Id = :absCommentId];

        List<EDM_Attachment_gne__c> attToDelete = [
                SELECT Id
                FROM EDM_Attachment_gne__c
                WHERE EDM_Link_gne__c =: edmLink];
        if(attToDelete.size() > 0) {
            EDM_ABM_Utils.deleteAttachement(attToDelete[0].Id);
        }
    }

    public static String checkExceptionRules(EDM_IABP_gne__c iabp) {
        String noEx = '';
        String ex1 = 'Exception triggered: The estimated number of Genentech and Co-Promote Attendees cannot exceed the estimated number of external attendees (e.g., advisors).';
        String ex2 = 'Exception triggered: The actual number of Genentech and Co-Promote Attendees entered exceeds the actual number of external attendees (e.g., advisors) entered.';

        Integer external = getActualAdvisorsCountById(iabp.Id);

        Integer geneReps = [SELECT count() FROM EDM_Attendee_gne__c
        WHERE EDM_Parent_IABP_gne__c = :iabp.Id
        AND EDM_System_Type_gne__c = 'Genentech'
        AND EDM_Observer_gne__c = FALSE];

        if (iabp.EDM_Est_nr_of_Gne_Attendees_gne__c > iabp.EDM_Est_nr_of_Attendees_gne__c) {
            return ex1;
        } else if (geneReps > external) {
            return ex2;
        }

        return noEx;
    }

    public static List<EDM_AABP_gne__c> getJointAABPs(EDM_IABP_gne__c iabp) {
        if (iabp.EDM_Joint_AABP_gne__c != null && iabp.EDM_Joint_AABP_gne__c != '') {
            Set<String> jointIds = new Set<String>(iabp.EDM_Joint_AABP_gne__c.split(','));
            List<EDM_AABP_gne__c> aabps = [SELECT Id, EDM_Group_gne__c, EDM_Team_gne__c, EDM_Unit_gne__c,EDM_Plan_Year_gne__c,EDM_AB_Lead_gne__r.Name FROM EDM_AABP_gne__c WHERE Id IN :jointIds];
            return aabps;
        }
        else {
            return new List<EDM_AABP_gne__c>();
        }
    }

    public static List<String> getSortedTeams(EDM_IABP_gne__c iabp) {
        List<String> teams = new List<String>();

        EDM_AABP_gne__c parentAABP = [SELECT Id, EDM_Group_gne__c, EDM_Team_gne__c, EDM_Unit_gne__c FROM EDM_AABP_gne__c WHERE Id = :iabp.EDM_Parent_AABP_gne__c];
        teams.add(parentAABP.EDM_Group_gne__c + ' - ' + parentAABP.EDM_Unit_gne__c + ' - ' + parentAABP.EDM_Team_gne__c);

        for (EDM_AABP_gne__c aabp : getJointAABPs(iabp)) {
            teams.add(aabp.EDM_Group_gne__c + ' - ' + aabp.EDM_Unit_gne__c + ' - ' + aabp.EDM_Team_gne__c);
        }
        teams.sort();

        return teams;
    }

    public static List<String> getCountries() {
        List<String> results = new List<String> {
                'United States',
                'Canada'
        };
        List<String> countries = VDST_API.getCountryValues().values();
        countries.sort();
        for (String country : countries) {
            if (country != 'United States' && country != 'Canada' && country != null) {
                results.add(country);
            }
        }
        return results;
    }

    public static List<String> getUSStates() {
        List<String> states = new List<String>();
        states.add('Alabama');
        states.add('Alaska');
        states.add('Arizona');
        states.add('Arkansas');
        states.add('California');
        states.add('Colorado');
        states.add('Connecticut');
        states.add('Delaware');
        states.add('District of Columbia');
        states.add('Florida');
        states.add('Georgia');
        states.add('Hawaii');
        states.add('Idaho');
        states.add('Illinois');
        states.add('Indiana');
        states.add('Iowa');
        states.add('Kansas');
        states.add('Kentucky');
        states.add('Louisiana');
        states.add('Maine');
        states.add('Maryland');
        states.add('Massachusetts');
        states.add('Michigan');
        states.add('Minnesota');
        states.add('Mississippi');
        states.add('Missouri');
        states.add('Montana');
        states.add('Nebraska');
        states.add('Nevada');
        states.add('New Hampshire');
        states.add('New Jersey');
        states.add('New Mexico');
        states.add('New York');
        states.add('North Carolina');
        states.add('North Dakota');
        states.add('Ohio');
        states.add('Oklahoma');
        states.add('Oregon');
        states.add('Pennsylvania');
        states.add('Rhode Island');
        states.add('South Carolina');
        states.add('South Dakota');
        states.add('Tennessee');
        states.add('Texas');
        states.add('Utah');
        states.add('Vermont');
        states.add('Virginia');
        states.add('Washington');
        states.add('West Virginia');
        states.add('Wisconsin');
        states.add('Wyoming');
        return states;
    }

    public static List<String> getCanadianProvinces() {
        List<String> provinces = new List<String>();
        provinces.add('Alberta');
        provinces.add('British Columbia');
        provinces.add('Manitoba');
        provinces.add('New Brunswick');
        provinces.add('Newfoundland and Labrador');
        provinces.add('Northwest Territories');
        provinces.add('Nova Scotia');
        provinces.add('Nunavut');
        provinces.add('Ontario');
        provinces.add('Prince Edward Island');
        provinces.add('Quebec');
        provinces.add('Saskatchewan');
        provinces.add('Yukon');
        return provinces;
    }

    public static Map<String, String> getBlueTexts(String docType, String eType) {
        List<EDM_Blue_Text_gne__c> bts = [SELECT EDM_Parent_Section_gne__c, EDM_Value_gne__c FROM EDM_Blue_Text_gne__c
        WHERE EDM_Document_Type_gne__c = :docType
        AND (EDM_Event_Type_gne__c = :eType OR EDM_Event_Type_gne__c = 'Both')];
        Map<String, String> result = new Map<String, String>();
        for (EDM_Blue_Text_gne__c bt : bts) {
            String value =  bt.EDM_Value_gne__c != null ? bt.EDM_Value_gne__c.replace('\r\n', ' ') : '';
            value = value.replace('\n', ' ');
            value = value.replace('\r', ' ');
            value = value.replace('\'', '?');
            result.put(bt.EDM_Parent_Section_gne__c, value);
        }
        return result;
    }

    public static String saveSelectedBrands(List<SelectOption> selectedOpts) {
        String result = '';
        for (SelectOption so : selectedOpts) {
            result += so.getValue() + ';';
        }
        return result;
    }

    public static List<SelectOption> getSelectedBrands(String selected) {
        List<SelectOption> sList = new List<SelectOption>();

        if (!String.isBlank(selected)){
            List<String> opts = selected.split(';');

            for (String o : opts) {
                sList.add(new SelectOption(o, o));
            }
        }
        return sList;
    }

    public static String getIABPTitle(String status) {
        if (status == 'IABP Not Started') {
            return 'Update IABP';
        }
        if (status == 'IABP In Progress') {
            return 'Update IABP';
        }
        else if (status == 'IABP Under Review') {
            return 'Review IABP';
        }
        else if (status == 'IABP Submitted for Approval') {
            return 'Approve IABP';
        }
        else if (status == 'IABP Approved') {
            return 'Update Approved IABP';
        }
        else if (status == 'Revising Approved IABP') {
            return 'Review Approved IABP';
        }
        else if (status == 'Re-Reviewing Approved IABP') {
            return 'Review Approved IABP';
        }
        else if (status == 'Event Occurred') {
            return 'Event Occurred';
        }
        else if (status == 'Canceled') {
            return 'Canceled Event';
        }
        return 'IABP';
    }

    public static String getIABPGroup(EDM_IABP_gne__c iabp) {
        return getIABPGroup(iabp, iabp.EDM_Parent_AABP_gne__r.EDM_Group_gne__c);
    }

    private static String getIABPGroup(EDM_IABP_gne__c iabp, String parentGroup) {
        List<String> groups = new List<String>();
        List<String> jointGroups = new List<String>();
        String result;

        groups.add(parentGroup);

        List<EDM_AABP_gne__c> jointAABPs = EDM_ABM_Utils.getJointAABPs(iabp);
        if (jointAABPs != null) {
            for (EDM_AABP_gne__c aabp : jointAABPs) {
                jointGroups.add(aabp.EDM_Group_gne__c);
            }
        }

        groups.addAll(jointGroups);

        if (groups.size() == 1) {
            result = groups[0];
            if (groups[0] == 'Commercial') {
                result = 'C';
            }
            else if (groups[0] == 'Medical Affairs' || groups[0] == 'USMA') {
                result = 'M';
            }
            else if (groups[0] == 'Other') {
                result = 'O';
            }
            else if (groups[0] == 'PD') {
                result = 'PD';
            }
            else if (groups[0] == 'gRED') {
                result = 'gRED';
            }
            else {
                result = null;
            }
        }
        else {
            if (stringListContains(groups, 'Commercial')) {
                result = 'C';
            }
            else if (stringListContains(groups, 'Medical Affairs') || stringListContains(groups, 'USMA')) {
                result = 'M';
            }
            else if (stringListContains(groups, 'Other')) {
                result = 'O';
            }
            else {
                result = parentGroup;
            }
        }

        return result;
    }

    private static Boolean stringListContains(List<String> inputList, String stringToFind) {
        if (inputList != null && inputList.size() > 0) {
            for (String item : inputList) {
                if (item == stringToFind) {
                    return true;
                }
            }
        }
        return false;
    }

    public static String getIABPGroupForObjective(EDM_IABP_gne__c iabp) {
        Set<String> jointGroups = new Set<String>();
        String result;
        String parentGroup = iabp.EDM_Parent_AABP_gne__r.EDM_Group_gne__c;

        List<EDM_AABP_gne__c> jointAABPs = EDM_ABM_Utils.getJointAABPs(iabp);
        for (EDM_AABP_gne__c aabp : jointAABPs) {
            jointGroups.add(aabp.EDM_Group_gne__c);
        }
        jointGroups.add(parentGroup);

        Set<String> groups = prepareGroupNames(jointGroups);

        if (groups.size() == 1) {
            for(String grp : groups) {
                result = grp;
                break;
            }
        } else {
            result = 'Multiple;';
            for(String grp : groups) {
                result += grp + ';';
            }

            result = result.removeEnd(';');
        }
        return result;
    }

    private static  Set<String> prepareGroupNames(Set<String> groups) {
        Set<String> results = new Set<String>();
        Boolean otherAdded = false;
        for (String gr : groups) {
            if (gr == 'Medical Affairs' || gr == 'USMA') {
                results.add('Medical');
            } else if (gr == 'Commercial' || gr == 'gRED' || gr == 'PD') {
                results.add(gr);
            } else if (gr == 'Miscellaneous') {
                results.add('Other');
            } else if(gr == 'CMG'){
                results.addAll(new Set<String> {'Medical', 'Commercial', 'gRED', 'PD', 'CMG', 'Other'});
            }
        }

        return results;
    }

    public static String getTypeForDoc(EDM_IABP_gne__c iabp) {
        return getTypeForDoc(iabp, iabp.EDM_Parent_AABP_gne__r.EDM_Group_gne__c);
    }

    public static String getTypeForDoc(EDM_IABP_gne__c iabp, String parentGroup) {
        if (iabp.EDM_Executive_Summary_gne__c == true) {
            return iabp.EDM_Meeting_Approach_gne__c == 'iAdvise' ? 'iAdvise ExeSum' : 'ExeSum';
        }
        else if (iabp.EDM_Meeting_Approach_gne__c == 'iAdvise') {
            return 'iAdvise';
        }
        else {
            String iabpGroup = getIABPGroup(iabp, parentGroup);
            if (iabpGroup == 'gRED' || iabpGroup == 'PD') {
                return 'gRED PD';
            }
        }
        return 'IABP';
    }

    public static String getEventTitle(EDM_IABP_gne__c iabp, List<EDM_IABP_gne__c> newIABPs, EDM_AABP_gne__c parentAABP, List<EDM_IABP_gne__c> iabpsForAABP) {
        String title;

        if (newIABPs != null && newIABPs.size() > 0) {
            for (EDM_IABP_gne__c i : newIABPs) {
                if (i.EDM_Parent_AABP_gne__c == iabp.EDM_Parent_AABP_gne__c) {
                    iabpsForAABP.add(i);
                }
            }
        }
        String adhoc = iabp.EDM_Ad_Hoc_Event_gne__c ? '(Ad Hoc) ' : '';
        title = adhoc + iabp.EDM_Year_gne__c + ' '
                + parentAABP.EDM_Group_gne__c + ' '
                + parentAABP.EDM_Unit_gne__c + ' '
                + parentAABP.EDM_Team_gne__c + ' '
                + iabp.EDM_Type_of_Event_gne__c;

        List<String> allTitles = new List<String>();
        for (EDM_IABP_gne__c i : iabpsForAABP) {
            if (i.EDM_Event_Name_gne__c != null) {
                allTitles.add(i.EDM_Event_Name_gne__c);
            }
        }

        Integer maxTitleNumber = 0, titleNumber;
        for (String t : allTitles) {
            String[] titleParts = t.split('#');
            if (titleParts[0].trim() == title) {
                if (titleParts.size() == 1) {
                    titleNumber = 1;
                } else {
                    titleNumber = Integer.valueOf(titleParts[1]);
                }

                if (maxTitleNumber < titleNumber) {
                    maxTitleNumber = titleNumber;
                }
            }
        }

        if (maxTitleNumber > 0) {
            title += ' #' + (maxTitleNumber + 1);
        }

        return title;
    }

    public static String getAddress(Id accountId) {
        List<Address_vod__c> addressList = [
                SELECT Address_1_gne__c, City_vod__c, State_vod__c, Zip_vod__c
                FROM Address_vod__c
                WHERE Account_vod__c = :accountId
                ORDER BY Primary_vod__c DESC, GOLD_RECORD_gne__c DESC, LastModifiedDate DESC
                LIMIT 1];

        return addressList.isEmpty() ? null : addressList.get(0).Id;
    }

    public static void populateDefaultDuties(EDM_IABP_gne__c iabp, Map<String, String> blueTexts) {

        String val = '';

        val = blueTexts.get('Advisor Selection Duties');
        iabp.EDM_Advisor_Selection_Duties_gne__c = val;

        val = blueTexts.get('Chair Duties');
        iabp.EDM_Chair_Selection_Duties_gne__c = val;

        val = blueTexts.get('Clinical Expert Duties');
        iabp.EDM_Cl_Expert_Selection_Duties_gne__c = val;

        val = blueTexts.get('Moderator Duties');
        iabp.EDM_Moderator_Selection_Duties_gne__c = val;
    }

    public static List<SelectOption> getDownloadDocumentIds(Id aabpId, Id iabpId, Id exeSumId) {
        List<SelectOption> results = new List<SelectOption> {
                new SelectOption(aabpId, 'ABM Annual Plan & Event List')
        };

        for (EDM_IABP_gne__c snap : EDM_IABP_Utils.getValidatedOrApprovedSnapshots(iabpId)) {
            results.add(
                    new SelectOption(snap.Id, 'IABP Version: ' + snap.EDM_IABP_Version_gne__c +
                            (snap.EDM_Version_Validated_gne__c != null ? ', Validated ' + snap.EDM_Version_Validated_gne__c.format() : '') +
                            (snap.EDM_IABP_Approved_gne__c != null ? ', Approved ' + snap.EDM_IABP_Approved_gne__c.format() : '') +
                            (snap.EDM_Status_gne__c == 'Event Occurred' ? ', Meeting date version' : '')));
        }

        results.add(new SelectOption(iabpId, 'The current version of the IABP'));

        if (exeSumId != null) {
            results.add(new SelectOption(exeSumId, 'The current version of the ExeSum'));
        }

        return results;
    }

    private static List<EDM_IABP_gne__c> getValidatedOrApprovedSnapshots(Id iabpId) {
        List<EDM_IABP_gne__c> allSnaps = [SELECT Id, Name, EDM_IABP_Version_gne__c, EDM_Version_Validated_gne__c,
                EDM_IABP_Approved_gne__c, EDM_Status_gne__c
        FROM EDM_IABP_gne__c
        WHERE (EDM_History_Parent_IABP_gn__c = :iabpId)
        AND EDM_IABP_Version_gne__c > 0
        ORDER BY EDM_IABP_Version_gne__c, CreatedDate];

        List<EDM_IABP_gne__c> validatedOrApprovedSnapshots = new List<EDM_IABP_gne__c>();
        Set<Decimal> snapshotVersions = new Set<Decimal>();
        Map<Decimal, EDM_IABP_gne__c> version2iabp = new Map<Decimal, EDM_IABP_gne__c>();
        for (EDM_IABP_gne__c snap : allSnaps) {
            if(!snapshotVersions.contains(snap.EDM_IABP_Version_gne__c) || snap.EDM_Status_gne__c == 'Event Occurred') {
                version2iabp.put(snap.EDM_IABP_Version_gne__c, snap);
                snapshotVersions.add(snap.EDM_IABP_Version_gne__c);
            }
        }

        for(EDM_IABP_gne__c snap : version2iabp.values()) {
            validatedOrApprovedSnapshots.add(snap);
        }
        return validatedOrApprovedSnapshots;
    }

    public static void validateImgMarker(String iabpNameOrId, Boolean isExecutiveSummary) {
        List<EDM_IABP_gne__c> iabpsToFix;
        if(isExecutiveSummary){
            iabpsToFix = [SELECT Id, EDM_Executive_Summary_gne__c, (SELECT Id, EDM_Content_Description_gne__c, EDM_Session_Objectives_gne__c, EDM_Representative_AB_Questions_gne__c, EDM_Information_Gained_gne__c FROM EDM_Sessions__r)
            FROM EDM_IABP_gne__c WHERE Id =: iabpNameOrId];
        }
        else{
            iabpsToFix = [SELECT Id, EDM_Executive_Summary_gne__c, (SELECT Id, EDM_Content_Description_gne__c, EDM_Session_Objectives_gne__c, EDM_Representative_AB_Questions_gne__c, EDM_Information_Gained_gne__c FROM EDM_Sessions__r)
            FROM EDM_IABP_gne__c WHERE EDM_Drawloop_IABP_Name_gne__c =: iabpNameOrId];
        }

        List<EDM_Session_gne__c> sessionsToUpdate = new List<EDM_Session_gne__c>();
        for (EDM_IABP_gne__c iabp : iabpsToFix) {
            List<EDM_Session_gne__c> sessions = iabp.EDM_Sessions__r;
            for (EDM_Session_gne__c session : sessions) {
                String objective = session.EDM_Session_Objectives_gne__c;
                String repQuestion = session.EDM_Representative_AB_Questions_gne__c;
                String informationGained = session.EDM_Information_Gained_gne__c;
                String contentDescription = session.EDM_Content_Description_gne__c;
                String excludeImgMarkerRegex = '<img[^>]*>|<\\/img>|<p>.*Save<\\/span>.*<\\/p>';
                Boolean needUpdate = false;

                if (String.isNotBlank(objective) && (objective.contains('<img') || objective.contains('>Save</span>'))) {
                    objective = objective.replaceAll(excludeImgMarkerRegex, '');
                    session.EDM_Session_Objectives_gne__c = objective;
                    needUpdate = true;
                }
                if (String.isNotBlank(repQuestion) && (repQuestion.contains('<img') || repQuestion.contains('>Save</span>'))) {
                    repQuestion = repQuestion.replaceAll(excludeImgMarkerRegex, '');
                    session.EDM_Representative_AB_Questions_gne__c = repQuestion;
                    needUpdate = true;
                }
                if(String.isNotBlank(informationGained) && (informationGained.contains('<img') || informationGained.contains('>Save</span>'))) {
                    informationGained = informationGained.replaceAll(excludeImgMarkerRegex, '');
                    session.EDM_Information_Gained_gne__c = informationGained;
                    needUpdate = true;
                }
                if(String.isNotBlank(contentDescription) && (contentDescription.contains('<img') || contentDescription.contains('>Save</span>'))) {
                    contentDescription = contentDescription.replaceAll(excludeImgMarkerRegex, '');
                    session.EDM_Content_Description_gne__c = contentDescription;
                    needUpdate = true;
                }
                if (needUpdate) {
                    sessionsToUpdate.add(session);
                }
            }
        }

        if (sessionsToUpdate.size() > 0) {
            update sessionsToUpdate;
        }
    }

    public static Integer getActualAdvisorsCountById(Id iabpId) {
        Set<String> excludedRoles = new Set<String>{
                'Moderator', 'Chair', 'Patient Chair', 'Patient Moderator'
        };
        List<EDM_Attendee_gne__c> advList = [
                SELECT id, EDM_Role_gne__c
                FROM EDM_Attendee_gne__c
                WHERE EDM_Parent_IABP_gne__c = :iabpId
                AND EDM_System_Type_gne__c != 'Genentech' AND is_deleted_gne__c = FALSE
        ];
        Integer advCount = 0;
        for (EDM_Attendee_gne__c att : advList) {
            if (!excludedRoles.contains(att.EDM_Role_gne__c)) {
                advCount++;
            }
        }
        return advCount;
    }
}