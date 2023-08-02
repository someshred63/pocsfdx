global with sharing class GNE_SFA2_Account_Mappings_Tool_Ctrl {

    public String constructorDataJSON {get; private set;}
    public Boolean isToolMode {get; private set;}

    public GNE_SFA2_Account_Mappings_Tool_Ctrl() {
        constructorDataJSON = JSON.serialize(getConstructorData());
        isToolMode = !(new GNE_SFA2_HCPtoFRMHCOMappingEngine()).getUserTerritoriesZipCodes().isEmpty();
    }

    private Map<String, Object> getConstructorData() {
        Map<String, Object> result = new Map<String, Object>();
        result.put('accountMappingWrapper', (new GNE_SFA2_HCPtoFRMHCOMappingEngine()).getAccountMappingWrapper());
        result.put('sbcConfig', (new GNE_SFA2_HCPtoFRMHCOMappingEngine()).getSBCConfig());
        return result;
    }

    @RemoteAction
    global static GNE_SFA2_Base_Ctrl.DataWrapper createAccount(String inputDataWrapperInJSON) {
        return (new GNE_SFA2_HCPtoFRMHCOMappingEngine()).insertAccount(inputDataWrapperInJSON); 
    }

    @RemoteAction
    global static GNE_SFA2_Base_Ctrl.DataWrapper upsertAccountFromMdm(String inputDataWrapperInJSON) {
        return (new GNE_SFA2_HCPtoFRMHCOMappingEngine()).upsertAccount(inputDataWrapperInJSON); 
    }

    @RemoteAction
    global static GNE_SFA2_Base_Ctrl.DataWrapper sbcSearchAccounts(String searchDataWrapperInJSON) {
        return (new GNE_SFA2_HCPtoFRMHCOMappingEngine()).sbcSearchAccounts(searchDataWrapperInJSON); 
    }

    @RemoteAction
    global static GNE_SFA2_Base_Ctrl.DataWrapper searchMore(String searchDataWrapperInJSON) {
        return (new GNE_SFA2_HCPtoFRMHCOMappingEngine()).searchMore(searchDataWrapperInJSON); 
    }

    @RemoteAction
    global static GNE_SFA2_HCPtoFRMHCOMappingEngine.SaveMappingWrapper saveAccountMapping(Map<String, String> params) {
        return (new GNE_SFA2_HCPtoFRMHCOMappingEngine()).createAccountMapping(params);
    }

    @RemoteAction
    global static GNE_SFA2_HCPtoFRMHCOMappingEngine.HideMappingWrapper hideMapping(Id mappingId) {
        return (new GNE_SFA2_HCPtoFRMHCOMappingEngine()).hideMapping(mappingId);
    }

    @RemoteAction
    global static List<GNE_SFA2_HCPtoFRMHCOMappingEngine.AccountMappingWrapper> getFRMHCO(Map<String, String> params) {
        return (new GNE_SFA2_HCPtoFRMHCOMappingEngine()).getFRMHCO(params);
    }

    @RemoteAction
    global static GNE_SFA2_HCPtoFRMHCOMappingEngine.AccountMappingWrapper getNewHCP(Map<String, String> params) {
        return (new GNE_SFA2_HCPtoFRMHCOMappingEngine()).getNewHCP(params);
    }

    // USPS Address Validation Logic 

    @RemoteAction
    global static String addressValidate(Map<String, String> params) {
        return GNE_SFA2_USPSEngine.addressValidate(params);
    }

    @RemoteAction
    global static String cityStateLookup(Map<String, String> params) {
        return GNE_SFA2_USPSEngine.cityStateLookup(params);
    }

    @RemoteAction
    global static String zipCodeLookup(Map<String, String> params) {
        return GNE_SFA2_USPSEngine.zipCodeLookup(params);
    }
}