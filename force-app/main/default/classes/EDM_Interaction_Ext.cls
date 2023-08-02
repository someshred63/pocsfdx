public with sharing class EDM_Interaction_Ext {
	public EDM_Interaction_Ext(GNE_SFA2_Interaction_Controller controller) {}

	public Boolean getIsSBMUser() {
		String profileName = GNE_SFA2_Util.getCurrentUserProfileName();
		return profileName.startsWithIgnoreCase('GNE-MCCO')
			|| profileName.startsWithIgnoreCase('GNE-SFA-CC')
			|| profileName.startsWithIgnoreCase('GNE-SFA-OCC')
			|| profileName.startsWithIgnoreCase('GNE-TLS')
			|| profileName.startsWithIgnoreCase('GNE-SFA-PREP');
	}
}