public class GNE_SFA_Canada_Surveys_Tab_Driver extends GNE_SFA2_List_View_Base_Controller{
  	public GNE_SFA2_List_View_Base_Controller thisController { get; set; }

	public GNE_SFA_Canada_Surveys_Tab_Driver() {
		super('Survey_gne__c');
        thisController = this;
	}
 
}