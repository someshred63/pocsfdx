public class GNE_SFA2_SBC_Config {
    public enum AccountModes {
        HCP, HCO
    }
    public enum SearchModes {
        NameAddress, License, MDMId
    }
    public enum ConfigItems {
        SBCMdmSiperianEndPoint, DefaultRecordOwner, DefaultIndividualRoleCode, SBCMdmSiperianServiceNS, SBCGoogleMapURL, SBCMdmSiperianPageSize, SBCMdmSiperianOtrPageSize, SBCMdmSiperianIDetailPageSize, SBCMdmSiperianError,
		SBCGeoCodeClientId, SBCGeoCodeKey, FRM_HCOOrgTypes, SBCSolrEndPoint, SBCEngine, SBCSolrToken, SBCSolrProfiles, SBCSolrMode, SBCSolrSupportedTeamCodes, SBCReltioMode, SBCReltioProfiles
    }

    private static Map<String, String> configItemsCache;
    private static List<String> hcpSortedRolesCache;
    private static Map<String, String> hcpRolesToProfTypesCache;
    private static Map<String, String> knownErrorCodesMap;

    public static String getConfigItem(String confName) {
        cacheConfigItems();
        return configItemsCache.get(confName.toUpperCase());
    }

    public static String getConfigItem(ConfigItems confItemTag) {
        cacheConfigItems();
        return configItemsCache.get(confItemTag.name().toUpperCase());
    }

    public static String getMdmKnowErrorName(Integer errorCode) {
        cacheConfigItems();
        return errorCode != null ? knownErrorCodesMap.get(String.valueOf(errorCode)) : null;
    }

    public static String getMdmKnowErrorMessage(Integer errorCode) {
        cacheConfigItems();
        String result = null;
        String errorName = getMdmKnowErrorName(errorCode);

        if (errorCode != null && errorName != null) {
            String cLabelName = 'GNE_SFA2_SBC_MdmError_' + errorName;
            List<ExternalString> cLabels = [SELECT Value FROM ExternalString WHERE Category = 'SBC' AND Name = :cLabelName LIMIT 1];
            result = cLabels.isEmpty() ? '' : cLabels[0].Value;
        }

        return result;
    }

    private static void cacheConfigItems() {
        if (configItemsCache == null) {
            configItemsCache = new Map<String, String>();
            knownErrorCodesMap = new Map<String, String>();

            Map<String, GNE_Foun_Misc_Config_Items_gne__c> configRecs = new Map<String, GNE_Foun_Misc_Config_Items_gne__c>();

            for (GNE_Foun_Misc_Config_Items_gne__c configRec : GNE_Foun_Misc_Config_Items_gne__c.getAll().values()) {
                String configName = configRec.Name.toUpperCase();
                String errorTag = ConfigItems.SBCMdmSiperianError.name().toUpperCase();

                if (configName.startsWithIgnoreCase(errorTag)) {
                    String errorCode = configName.replaceAll('^' + errorTag + ':(\\d+)$', '$1');
                    knownErrorCodesMap.put(errorCode, configRec.Configuration_Value_gne__c);
                } else {
                    configRecs.put(configName, configRec);
                }
            }

            for (ConfigItems configTag : ConfigItems.values()) {
                String configName = configTag.name().toUpperCase();
                GNE_Foun_Misc_Config_Items_gne__c configRec = configRecs.get(configName);

                if (configRec != null) {
                    configItemsCache.put(configName, configRec.Configuration_Value_gne__c);
                }
            }
        }
    }

    private static void cacheHcpRoleRanking() {
        if (hcpSortedRolesCache == null) {
            hcpSortedRolesCache = new List<String>();
            hcpRolesToProfTypesCache = new Map<String, String>();
            Map<String, GNE_Foun_Role_Ranking_gne__c> rrRecs = GNE_Foun_Role_Ranking_gne__c.getAll();
            Map<String, String> rankToNameMap = new Map<String, String>();

            for (GNE_Foun_Role_Ranking_gne__c rrRec : rrRecs.values()) {
                String rank = String.valueOf(rrRec.Role_Rank_gne__c.intValue());
                rank = '0'.repeat(10 - rank.length()) + rank + '_' + rrRec.Name;
                rankToNameMap.put(rank, rrRec.Name);
            }

            List<String> ranks = new List<String>(rankToNameMap.keySet());
            ranks.sort();

            for (String rank : ranks) {
                GNE_Foun_Role_Ranking_gne__c rrRec = rrRecs.get(rankToNameMap.get(rank));
                hcpRolesToProfTypesCache.put(rrRec.Name, rrRec.Account_Professional_Type_gne__c);
                hcpSortedRolesCache.add(rrRec.Name);
            }
        }
    }

    public static List<String> getHcpProfTypes() {
        cacheHcpRoleRanking();
        Set<String> profTypes = new Set<String>(hcpRolesToProfTypesCache.values());
        List<String> profTypesList = new List<String>(profTypes);
        profTypesList.sort();
        return profTypesList;
    }

    public static List<String> getHcpProfTypesSortedByRank(Set<String> roles) {
        cacheHcpRoleRanking();
        List<String> result = new List<String>();

        if (roles != null) {
            for (String role : hcpSortedRolesCache) {
                if (roles.contains(role)) {
                    result.add(hcpRolesToProfTypesCache.get(role));
                }
            }
        }

        if (result.isEmpty()) {
            result.add(hcpRolesToProfTypesCache.get(getHcpDefaultProfType()));
        }

        return result;
    }

    public static String getHcpDefaultProfType() {
        return getConfigItem(ConfigItems.DefaultIndividualRoleCode);
    }
}