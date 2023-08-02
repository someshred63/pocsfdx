/************************************************************
*  @author: Kishore Chandolu
*  Date: 2013-01-19
*  Description: This is a controller extension for GNE_SFA2_SBureau_Edit_Create_Layout page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_SBureau_Edit_Create_Ctrl extends GNE_SFA2_Dynamic_VF_Edit_Create{

    public List<String> monthNames {get; set;}
    public Map<String, String> plannedProgramMonthFieldName {get; set;}
    public ParentObjectTemp__c parentObjTemp {get;set;}
    public Id parentObjId {get;set;}


    public GNE_SFA2_SBureau_Edit_Create_Ctrl(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_SpeakerBureau?sfdc.override=1');
        
        if(myObject == null){
                myObject = new Speaker_Bureau_gne__c();
        }
        if (myObject.Id == null) {
            myObject.put('OwnerId', UserInfo.getUserId());
            
        }
        else
        {
            parentObjId = myObject.Id;
        }

        //monthNames = new List<String> { 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December' }; 
        monthNames = new List<String> { 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' }; 
        
        plannedProgramMonthFieldName = new Map<String, String>();
        for (Integer month_number = 1; month_number <= 12; month_number++) {
            String month_number_str = month_number >= 10 ? String.valueOf(month_number) : '0' + String.valueOf(month_number);
            plannedProgramMonthFieldName.put(monthNames.get(month_number -1), 'Planned_Programs_' + month_number_str + '_gne__c');
        }

        if(parentObjId == null) {
            parentObjTemp = new ParentObjectTemp__c();
        }
    }

    public override Pagereference init()
    {
        if(parentObjTemp != null) {
            insert parentObjTemp;
            parentObjId = parentObjTemp.Id;
        }
        return super.init();
    }

    public override PageReference save() {
        PageReference pageRef = super.save();
        saveAttachments(myObject.Id);
        delete parentObjTemp;
        return pageRef;
    }

    public override PageReference cancel() {
        PageReference pageRef = super.cancel();
        List<Attachment> attToDelete = [SELECT Id FROM Attachment WHERE ParentId=:parentObjId];
        removeAttachments(attToDelete);
        delete parentObjTemp;
        return pageRef;
    }

    public PageReference refreshAttachmentsSection() {
        return null;
    }

    public Boolean getIsPlannedProgramsAvailableForEdit() {
        Schema.DescribeFieldResult drField = Speaker_Bureau_gne__c.Planned_Programs_01_gne__c.getDescribe();

        return drField.isUpdateable() && isAllPlannedProgramsFieldsInLayout();
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

    private void saveAttachments(Id parentId)
    {
        List<Attachment> attToDelete = [SELECT Id, Body, Name, Description FROM Attachment WHERE ParentId=:parentObjId];
        List<Attachment> attToUpsert = new List<Attachment>();
        for(Attachment att : attToDelete)
        {
            Attachment newAtt = new Attachment();
            newAtt.Name = att.Name;
            newAtt.Description = att.Description;
            newAtt.ParentId = parentId;
            newAtt.Body = att.Body;

            attToUpsert.add(newAtt);
        }
        try{
            upsert attToUpsert;
            removeAttachments(attToDelete);
        }
        catch(Exception e) {
            system.debug(e);
        }
    }

    private void removeAttachments(List<Attachment> attToDelete) {
        
        try {
            delete attToDelete;
        }
        catch(Exception e) {
            system.debug(e);
        }
    }
}