public with sharing class EDM_ExeSum_Utils {

	public static Boolean isInEditMode(EDM_IABP_gne__c exeSum, Boolean forceViewMode) {
		if (forceViewMode) {
			return false;
		}
		return isInEditMode(exeSum);
	}

	public static Boolean isInEditMode(EDM_IABP_gne__c exeSum) {
		if ((IsInUpdateExeSumStage(exeSum) && isABPlanner()) ||
			(IsInReviewExeSumStage(exeSum) && isAbsUser())) {
			return true;
		}
		return false;
	}

	public static Boolean isInUpdateExeSumStage(EDM_IABP_gne__c exeSum) {
		return exeSum.EDM_ExeSum_Status_gne__c == null || exeSum.EDM_ExeSum_Status_gne__c == 'Not Started' ||
				exeSum.EDM_ExeSum_Status_gne__c == 'Started';
	}

	public static Boolean isInReviewExeSumStage(EDM_IABP_gne__c exeSum) {
		return exeSum.EDM_ExeSum_Status_gne__c == 'In Review';
	}

	public static Boolean isAbsUser() {
		return EDM_ABM_Utils.hasPermissionSet(EDM_ABM_Utils.ABS);
	}

	public static Boolean isABPlanner() {
		return EDM_ABM_Utils.hasPermissionSet(EDM_ABM_Utils.ABLEAD) || EDM_ABM_Utils.hasPermissionSet(EDM_ABM_Utils.VDST_ABM);
	}

	public static String getAttachAgendaParam(Id currentExeSumId, Id parentIabpId, String exeSumFinalAgendaSource) {
		if (exeSumFinalAgendaSource == 'ExeSum') {
			EDM_Attachment_gne__c finalAgenda = getFinalAgendaAttach(currentExeSumId);
			if (finalAgenda != null) {
				return '&ParentIds=' + finalAgenda.Id + getAttachIdParam(finalAgenda);
			}
		} else if (exeSumFinalAgendaSource == 'IABP') {
			List<EDM_Attachment_gne__c> agendaFromIABP = getAgendaFromIABP(parentIabpId);
			if (!agendaFromIABP.isEmpty()) {
				return '&ParentIds=' + agendaFromIABP.get(0).Id + getAttachIdParam(agendaFromIABP.get(0));
			}
		}
		return '';
	}

	public static EDM_Attachment_gne__c getFinalAgendaAttach(Id currentExeSumId) {
		List<EDM_Attachment_gne__c> finalAgendaAttachs = 
				[SELECT Id, Name, EDM_Link_gne__c FROM EDM_Attachment_gne__c WHERE EDM_Parent_IABP_gne__c = :currentExeSumId and EDM_System_Type_gne__c = 'Final Agenda'];

		return finalAgendaAttachs.isEmpty() ? new EDM_Attachment_gne__c() : finalAgendaAttachs.get(0);
	}

	public static List<EDM_Attachment_gne__c> getAgendaFromIABP(String parentIABPId) {
		return [SELECT Id 
				FROM EDM_Attachment_gne__c 
				WHERE EDM_Parent_IABP_gne__c = :parentIABPId and EDM_Type_gne__c = 'Agenda'
				ORDER BY CreatedDate DESC LIMIT 1];
	}

	private static String getAttachIdParam(EDM_Attachment_gne__c edmAttach) {
		List<Attachment> attachs = [SELECT Id FROM Attachment where parentId = :edmAttach.Id];
		if (!attachs.isEmpty()) {
			return '&AttachIds=' + attachs.get(0).Id;
		}

		return '';
	}

    public static Set<String> getPTDGroupsBasedOnObjectives(String parentIABPId) {
        Set<String> groupsSetTmp = new Set<String>();
        for(EDM_Objective_gne__c obj : [Select EDM_Group_gne__c From EDM_Objective_gne__c Where EDM_Parent_IABP_gne__c=:parentIABPId]) {
            if(String.isNotBlank(obj.EDM_Group_gne__c)) {
                if('CMG'.equalsIgnoreCase(obj.EDM_Group_gne__c)) {
                    groupsSetTmp.add('Commercial');
                    groupsSetTmp.add('Medical');
                } else if('PD'.equalsIgnoreCase(obj.EDM_Group_gne__c)) {
                } else if('gRED'.equalsIgnoreCase(obj.EDM_Group_gne__c)) {
                } else {
                    groupsSetTmp.add(obj.EDM_Group_gne__c);
                }
            }
        }
        return groupsSetTmp;
    }
}