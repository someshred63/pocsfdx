public with sharing class EMS_IHCP_Ext extends EMS_DynamicVFLoader {

    public EMS_IHCP_Ext(ApexPages.StandardController controller) {
        super(controller, '/apex/EMS_IHCP_Layout');
    }
}