public with sharing class EMS_Travel_Ext extends EMS_DynamicVFLoader {
    public EMS_Travel_Ext(ApexPages.StandardController controller) {
        super(controller, '/apex/EMS_Travel_Layout');
    }
}