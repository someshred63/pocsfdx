public inherited sharing class GNE_SFA2_ReltioUtil {
	public static final String SETTINGS_SEPARATOR = ',';
    private static final String RELTIO_ENGINE_NAME = 'RELTIO';
    
    public static Boolean useReltio(String searchMode) {
        String reltioModeConfig = GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.SBCReltioMode);
        Set<String> reltioSupportedModes = new Set<String>();
        if (!String.isBlank(reltioModeConfig)) {
            reltioSupportedModes.addAll(reltioModeConfig.split(SETTINGS_SEPARATOR));
        }
        return isReltioDefaultSearchEngine() || (isCurrentUserReltioUser() && reltioSupportedModes.contains(searchMode));
    }
    
    private static Boolean isReltioDefaultSearchEngine() {
        String sbcEngine = GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.SBCEngine);
        return String.isNotBlank(sbcEngine) && sbcEngine == RELTIO_ENGINE_NAME;
    }
    
    private static Boolean isCurrentUserReltioUser() {
        String currentUserProfile = GNE_SFA2_Util.getCurrentUserProfileName();
        String sbcProfiles = GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.SBCReltioProfiles);
        if (String.isNotBlank(sbcProfiles)) {
            List<String> reltioProfiles = sbcProfiles.split(SETTINGS_SEPARATOR);
            for (String reltioProfile : reltioProfiles) {
                if (currentUserProfile.startsWith(reltioProfile)) {
                    return true;
                }
            }
        }
        return false;
    }
}