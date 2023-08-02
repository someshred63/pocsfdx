public with sharing class EMS_Speaker_Role_Ext extends EMS_DynamicVFLoader {
    public Component.Apex.PageBlockButtons getCustomButtonsForSpeakerRole() {
        return new Component.Apex.PageBlockButtons();
    } // To be removed

    public EMS_Speaker_Role_Ext(ApexPages.StandardController controller) {
        super(controller, '/apex/EMS_Speaker_Role_Layout');

        visualforceIncludesMap.put('EMS_Ariba_Payment_Queue', true);
    }
}