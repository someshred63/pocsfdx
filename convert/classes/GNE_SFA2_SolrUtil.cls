public inherited sharing class GNE_SFA2_SolrUtil {

    public static final String SETTINGS_SEPARATOR = ',';
    private static final String SOLR_ENGINE_NAME = 'SOLR';

    public static Boolean useSolr(String searchMode) {
        String solrModeConfig = GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.SBCSolrMode);
        Set<String> solrSupportedModes = new Set<String>();
        if (!String.isBlank(solrModeConfig)) {
            solrSupportedModes.addAll(solrModeConfig.split(SETTINGS_SEPARATOR));
        }
        return isSolrDefaultSearchEngine() || (isCurrentUserSolrUser() && solrSupportedModes.contains(searchMode));
    }

    private static Boolean isSolrDefaultSearchEngine() {
        String sbcEngine = GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.SBCEngine);
        return String.isNotBlank(sbcEngine) && sbcEngine == SOLR_ENGINE_NAME;
    }

    private static Boolean isCurrentUserSolrUser() {
        String currentUserProfile = GNE_SFA2_Util.getCurrentUserProfileName();
        String sbcProfiles = GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.SBCSolrProfiles);
        if (String.isNotBlank(sbcProfiles)) {
            List<String> solrProfiles = sbcProfiles.split(SETTINGS_SEPARATOR);
            for (String solrProfile : solrProfiles) {
                if (currentUserProfile.startsWith(solrProfile)) {
                    return true;
                }
            }
        }
        return false;
    }

}