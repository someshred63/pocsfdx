public class GNE_SFA2_SpeakerTraining_list_Ctlr extends GNE_SFA2_List_View_Base_Controller {

    public GNE_SFA2_List_View_Base_Controller thisController { get; set; }
     
    public GNE_SFA2_SpeakerTraining_list_Ctlr () {
        super('Speaker_Training_gne__c');
        thisController = this;
    }
}