public class GNE_SFA2_PROSPECT_MySponsors_Controller extends GNE_SFA2_List_View_Base_Controller {

    public GNE_SFA2_List_View_Base_Controller thisController { get; set; }
     
    public GNE_SFA2_PROSPECT_MySponsors_Controller () {
        super('CONGA_Sponsor_gne__c');
        thisController = this;
    }

    public PageReference newClick() {
        PageReference newEvent = Page.GNE_SFA2_PROSPECT_Sponsor_Edit_Create;
        newEvent.getParameters().put('retURL', '/apex/GNE_SFA2_PROSPECT_MySponsors');
        return newEvent;
    }
}