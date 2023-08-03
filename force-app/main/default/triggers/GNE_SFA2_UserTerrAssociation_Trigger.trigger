trigger GNE_SFA2_UserTerrAssociation_Trigger on UserTerritory2Association (after insert, after delete) {
	
	if (!GNE_SFA2_Util.isAdminMode() && !GNE_SFA2_Util.isTriggerDisabled('GNE_SFA2_UserTerrAssociation_Trigger__c')) {
		if (Trigger.isInsert) {
			GNE_SFA2_UserTerrAssociation_Logic.addMembersToGroup(Trigger.new);
		} else if (Trigger.isDelete) {
			GNE_SFA2_UserTerrAssociation_Logic.removeMembersFromGroup(Trigger.old);
		} 
	}
}