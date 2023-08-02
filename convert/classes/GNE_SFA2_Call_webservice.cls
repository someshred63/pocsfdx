global with sharing class GNE_SFA2_Call_webservice {
    
    Webservice static Boolean isSFA2User(String userId) {
        return GNE_SFA2_Util.isSFA2UserForUI();
    }
        
}