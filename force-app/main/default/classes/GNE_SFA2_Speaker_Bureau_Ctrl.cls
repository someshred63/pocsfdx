/************************************************************
*  @author: Kishore Chandolu
*  Date: 2013-01-19
*  Description: This is a controller class for GNE_SFA2_Speaker_Bureau_Layout page.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Speaker_Bureau_Ctrl extends GNE_SFA2_DynamicVFLoader {

    public Boolean testBoolean {get;set;}
    public String curriculums {get;set;}
    //public String whereCondition {get;set;}

    private List<Curriculum_Speaker_Bureau_gne__c> existingCurr;
    private List<String> exIds;

    public List<String> monthNames {get; set;}
    public Map<String, String> plannedProgramMonthFieldName {get; set;}

    public GNE_SFA2_Speaker_Bureau_Ctrl(ApexPages.StandardController controller) {
        super(controller,'/apex/GNE_SFA2_SBureau_Layout');
        // we have to put all possible included pages into the map with "false" value to fix sf bug with maps on vf pages
        visualforceIncludesMap.put('GNE_SFA2_SBureau_Events', false);
        /*whereCondition='';
        existingCurr = new List<Curriculum_Speaker_Bureau_gne__c>([Select Event_Curriculum_gne__c 
                                                                   from Curriculum_Speaker_Bureau_gne__c 
                                                                   where Speaker_Bureau_gne__c=:myObject.Id]);
        exIds = new List<String>();
        if(existingCurr.size()>0){
            whereCondition = 'id not in (';
            Integer i=existingCurr.size();
            for(Curriculum_Speaker_Bureau_gne__c c : existingCurr){
                exIds.add(c.Event_Curriculum_gne__c);

                i--;
                whereCondition += '\'' + c.Event_Curriculum_gne__c + '\'';
                
                if(i>0){
                    whereCondition += ',';
                }
            }
            whereCondition += ') and Curriculum_Status_gne__c != \'Deleted\'';
        }
        System.debug('#WC#:'+whereCondition);*/

        //monthNames = new List<String> { 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December' }; 
        monthNames = new List<String> { 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' }; 
        plannedProgramMonthFieldName = new Map<String, String>();
        for (Integer month_number = 1; month_number <= 12; month_number++) {
            String month_number_str = month_number >= 10 ? String.valueOf(month_number) : '0' + String.valueOf(month_number);
            plannedProgramMonthFieldName.put(monthNames.get(month_number -1), 'Planned_Programs_' + month_number_str + '_gne__c');
        }
    }
    
    public PageReference edit() {
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_SBureau_Edit_Create_Layout?id=' + myObject.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference nominateClick() {
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_SBureau_Nominate_Layout?id=' + myObject.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public PageReference viewAllSpeakerBureauMemberships() {
        PageReference pageRef = new PageReference('/apex/GNE_SFA2_SBMembership?br_id=' + myObject.Id +
                                        '&parentObjectName=' + this.myObjectType +
                                        '&parentRecordType=' + this.recordTypeName);
        pageRef.setRedirect(true);
        return pageRef;
    }

    public void saveCurriculum(){
        System.debug('#-#-# IDS: '+curriculums);
        List<String> ids = new List<String>(curriculums.split(';'));    

        List<Event_Curriculum_gne__c> events = new List<Event_Curriculum_gne__c>([Select id,name from Event_Curriculum_gne__c where id in :ids and id not in :exIds]);

        List<Curriculum_Speaker_Bureau_gne__c> curr = new List<Curriculum_Speaker_Bureau_gne__c>();
        for(Event_Curriculum_gne__c e : events){
            Curriculum_Speaker_Bureau_gne__c curriculum = new Curriculum_Speaker_Bureau_gne__c();
            curriculum.Event_Curriculum_gne__c=e.id;
            curriculum.Speaker_Bureau_gne__c=myObject.Id;
            curr.add(curriculum);
        }

        insert curr;
    }

    public Boolean getIsPlannedProgramsAvailableForView() {
        Schema.DescribeFieldResult drField = Speaker_Bureau_gne__c.Planned_Programs_01_gne__c.getDescribe();

        return drField.isAccessible() && isAllPlannedProgramsFieldsInLayout();
    }

    private Boolean isAllPlannedProgramsFieldsInLayout() {
        for (String layoutId : fieldSetHeadings.keySet()) {
            if (fieldSetHeadings.get(layoutId) == 'Information') {
                return fieldSetMap.get(layoutId).size() - 13 ==  makeInformationSectionFieldsWithoutPlannedPrograms(fieldSetMap.get(layoutId)).size();
            }
        }
        return false;
    }

    public Map<String, List<SFA2_Configuration_Object_Detail_gne__c>> getFieldSetMapWithoutPlannedPrograms() {
        Map<String, List<SFA2_Configuration_Object_Detail_gne__c>> results = fieldSetMap.clone();

        for (String layoutId : fieldSetHeadings.keySet()) {
            if (fieldSetHeadings.get(layoutId) == 'Information') {
                results.put(layoutId, makeInformationSectionFieldsWithoutPlannedPrograms(results.get(layoutId)));
            }
        }

        return results;
    }

    private List<SFA2_Configuration_Object_Detail_gne__c> makeInformationSectionFieldsWithoutPlannedPrograms(List<SFA2_Configuration_Object_Detail_gne__c> informationSection) {
        List<SFA2_Configuration_Object_Detail_gne__c> newInformationSection = new List<SFA2_Configuration_Object_Detail_gne__c>();
        for (SFA2_Configuration_Object_Detail_gne__c field : informationSection) {
            if (!field.API_Name_gne__c.startsWithIgnoreCase('Planned_Programs')) {
                newInformationSection.add(field);
            }
        }

        return newInformationSection;
    }

    public String getWhereCondition() {
        String whereCondition = '';
        List<Curriculum_Speaker_Bureau_gne__c> existingCurr = [SELECT Event_Curriculum_gne__c FROM Curriculum_Speaker_Bureau_gne__c WHERE Speaker_Bureau_gne__c = :myObject.Id];
        exIds = new List<String>();
        if (existingCurr.size() > 0) {
            whereCondition = 'Id NOT IN (';
            Integer i = existingCurr.size();
            for(Curriculum_Speaker_Bureau_gne__c c : existingCurr) {
                exIds.add(c.Event_Curriculum_gne__c);

                i--;
                whereCondition += '\'' + c.Event_Curriculum_gne__c + '\'';
                
                if (i > 0) {
                    whereCondition += ',';
                }
            }
            whereCondition += ') AND Curriculum_Status_gne__c != \'Deleted\' AND Curriculum_External_Id_gne__c != null';
        }
        System.debug('#WC#: ' + whereCondition);
        return whereCondition;
    }
}