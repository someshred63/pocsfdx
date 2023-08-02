/************************************************************
*  @author: Kishore Chandolu
*  Date: 2013-01-19
*  Description: This is a controller class for GNE_SFA2_MedicalEvent_Layout page.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Medical_Event_Ctrl extends GNE_SFA2_DynamicVFLoader {   
    public GNE_SFA2_Medical_Event_Ctrl(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_MedicalEvent_Layout');
    }
    
    public PageReference edit(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_MedicalEvent_Edit_Create_Layout?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }
    public PageReference TakeSurveyClick(){
        pagereference pageref = new pagereference('/apex/GNE_SFA2_MedicalEvent_Survey_Layout?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }

    public override PageReference init() {
        PageReference result = super.init();

        modifyFields();       

        return result;
    }

    private void modifyFields() {
        //hide cancel fields for non cancelled status and change event created date time format     
        for (String detailKey : fieldSetMap.keySet()) {
            if (fieldSetHeadings.get(detailKey) == 'Information') {
                List<SFA2_Configuration_Object_Detail_gne__c> confDetails = fieldSetMap.get(detailKey);
                //cancel fields
                if (existStatusExtendedField(confDetails)) {
                    Boolean isStatusCancelled = ( ((String)myObject.get('Status_Extended_gne__c')).startsWithIgnoreCase('Cancelled') ||
                                                    ((String)myObject.get('Status_Extended_gne__c')).startsWithIgnoreCase('Canceled') );
                    if ( !isStatusCancelled ) {
                        List<Integer> confToRemove = new List<Integer>();                   
                        for (Integer i = confDetails.size() - 1; i >= 0; i--) {
                            if (confDetails[i].API_Name_gne__c == 'Canceled_By_gne__c' || confDetails[i].API_Name_gne__c == 'Cancelation_Reason_gne__c' || confDetails[i].API_Name_gne__c == 'Cancelation_Explanation_gne__c') {
                                confToRemove.add(i);
                                if (i - 1 >= 0 && confDetails[i - 1].API_Name_gne__c == 'Blank Space') {
                                    confToRemove.add(i-1);
                                }
                            }
                        } 
                        for (Integer i : confToRemove) {
                            confDetails.remove(i);
                        }
                    }
                }
                //event created date time field
                if (existEventCreatedDateTimeField(confDetails)) {
                     if (myObject.get('Event_Created_Date_Time_gne__c') != null) {
                        DateTime t = (DateTime)myObject.get('Event_Created_Date_Time_gne__c');
                        myObject.put('Event_Created_Date_Time_gne__c', DateTime.newInstance(t.dateGmt(), t.timeGmt()));
                    }
                } 
                break;   
            }
        }
        
    }

    private Boolean existStatusExtendedField(List<SFA2_Configuration_Object_Detail_gne__c> confDetails) {
        Boolean result = false;
        for (SFA2_Configuration_Object_Detail_gne__c d: confDetails) {
            if (d.API_Name_gne__c == 'Status_Extended_gne__c') {
                result = true;
                break;
            }
        }
        return result;
    }

    private Boolean existEventCreatedDateTimeField(List<SFA2_Configuration_Object_Detail_gne__c> confDetails) {
        Boolean result = false;
        for (SFA2_Configuration_Object_Detail_gne__c d: confDetails) {
            if (d.API_Name_gne__c == 'Event_Created_Date_Time_gne__c') {
                result = true;
                break;
            }
        }
        return result;
    }    

}