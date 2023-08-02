/************************************************************
*  @author: Kishore Chandolu
*  Date: 2013-02-07
*  Description: This is a controller class for GNE_SFA2_EventAttendee_Layout page.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_EventAttendee_Ctrl extends GNE_SFA2_DynamicVFLoader {   
    public GNE_SFA2_EventAttendee_Ctrl(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_EventAttendee_Layout');
    }
    
    public PageReference edit(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_EventAttende_Edit_Create_Layout?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }
     
    public override PageReference init() {
        PageReference result = super.init();

        modifyFields();       

        return result;
    } 

     private void modifyFields() {
        //change Participant Added date time format     
        for (String detailKey : fieldSetMap.keySet()) {
            if (fieldSetHeadings.get(detailKey) == 'Add Attendee') {
                List<SFA2_Configuration_Object_Detail_gne__c> confDetails = fieldSetMap.get(detailKey);
                if (existParticipantAddedDateTimeField(confDetails)) {
                     if (myObject.get('Participant_Added_Date_Time_gne__c') != null) {
                        DateTime t = (DateTime)myObject.get('Participant_Added_Date_Time_gne__c');
                        myObject.put('Participant_Added_Date_Time_gne__c', DateTime.newInstance(t.dateGmt(), t.timeGmt()));
                    }
                } 
                break;   
            }
        }
        
    }

    private Boolean existParticipantAddedDateTimeField(List<SFA2_Configuration_Object_Detail_gne__c> confDetails) {
        Boolean result = false;
        for (SFA2_Configuration_Object_Detail_gne__c d: confDetails) {
            if (d.API_Name_gne__c == 'Participant_Added_Date_Time_gne__c') {
                result = true;
                break;
            }
        }
        return result;
    }
}