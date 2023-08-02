public with sharing class GNE_SFA2_Questionnaires_Controller extends GNE_SFA2_List_View_Base_Controller {

    public GNE_SFA2_List_View_Base_Controller thisController { get; set; }
     
    public GNE_SFA2_Questionnaires_Controller () {
        super('Questionnaire_gne__c');
        thisController = this;
    }
    
    public PageReference newClick(){
    
    PageReference pg = Page.GNE_SFA2_Qstner_Edit_Create_Layout;
    pg.getParameters().put('retURL', '/apex/GNE_SFA2_Questionnaires');
    return pg;
    }
}