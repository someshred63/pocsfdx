public with sharing class EDM_Attendees_Documents_Ctr {
	public Integer ATTENDEE_LIMIT { get { return 100; } }
	public Integer GENE_REPS_LIMIT { get { return 100; } }
	public Integer ADVISORS_LIMIT { get { return 100; } }
	public Integer NONUSADVISORS_LIMIT { get { return 100; } }
	public Integer OTHER_LIMIT { get { return 100; } }
	public Integer EVENT_DOCS_LIMIT { get { return 100; } }

	public Integer RowToDel { get; set; }

	public List<EDM_IABP_Utils.AttendeesWrapper> GeneReps { get; set; }
	public List<EDM_IABP_Utils.AttendeesWrapper> Advisors { get; set; }
	public List<EDM_IABP_Utils.AttendeesWrapper> NonUSAdvisors { get; set; }
	public List<EDM_IABP_Utils.AttendeesWrapper> OtherAttendees { get; set; }
	public List<EDM_IABP_Utils.EventDocsWrapper> EventDocuments { get; set; }
	public List<EDM_IABP_Utils.SystemDocsWrapper> SystemDocumets { get; set; }
	public List<EDM_IABP_Utils.ABSCommentsDocsWrapper> ABSCommentsDocuments { get; set; }

	public String UserRole { get; set; }
	public String accountId { get; set; }
	public Boolean isABS { get; set; }
	public Boolean isVdstExternalPartner { get; set; }
	public String ShareComment { get; set; }
	public List<SelectOption> UsersToShareWith {
		get {
			List<SelectOption> selectOptions = new List<SelectOption>();
			List<User> availableUsers = EDM_ABM_Utils.getUsersToShareWith(UserRole);
			Set<Id> uSet = new Set<Id>();
			for (SelectOption so : UsersSharedWith) {
				uSet.add(so.getValue());
			}

			for (User u : availableUsers) {
				if (!uSet.contains(u.Id)) {
					selectOptions.add(new SelectOption(u.Id, u.Name));
				}
			}
			return selectOptions;
		}

		set;
	}
	public List<SelectOption> UsersSharedWith { get; set; }

	public EDM_IABP_gne__c parentIABP { get; set; }
	private EDM_IABP_gne__c exeSum;
	private List<EDM_Spend_gne__c> edmSpends;

	public Map<String, String> BlueTexts { get; set; }

	public Map<Id, Boolean> isBusinessClassificationPendingByAccount { get; private set; }
	public Map<Id, Boolean> isClinicalClassificationPendingByAccount { get; private set; }

	private Set<ID> iabpAndExeSumIds;
	private Boolean forceViewModeForExeSum = false;

	private AttendeeChangeReasonForSingleIABP addReasonHandler;
	public String reasonComment { get; set; }
	public EDM_IABP_gne__c currentIABP;

	public Map<Id, String> account2ExclusionCheckDateMap {get; private set;}
	public Map<String, AGS_EX_Exclusion_Check_gne__c> account2ExclusionStatusMap {get; set ;}

	public EDM_Attendees_Documents_Ctr() {
		String parentId = ApexPages.currentPage().getParameters().get('parentId');
		UserRole = EDM_ABM_Utils.getUserRole(UserInfo.getUserId());
		isABS = (UserRole == EDM_ABM_Utils.ABS);
		isVdstExternalPartner = EDM_ABM_Utils.isVdstExternalPartner(UserInfo.getUserId());
		UsersSharedWith = new List<SelectOption>();

		forceViewModeForExeSum = ApexPages.currentPage().getParameters().get('forceViewMode') == '1';

		BlueTexts = EDM_IABP_Utils.getBlueTexts('Documents', 'Both');

		if (!String.isBlank(parentId) && EDM_ABM_Utils.isValidId(parentId)) {
			List<EDM_IABP_gne__c> iabps = [SELECT Id, Name, EDM_Meeting_Approach_gne__c, EDM_Status_gne__c, EDM_Meeting_Date_gne__c, EDM_Start_Date_gne__c,
												EDM_End_Date_gne__c, EDM_Approval_Status_gne__c, EDM_Executive_Summary_gne__c, EDM_ExeSum_Status_gne__c, EDM_Explanation_of_Att_Changes_gne__c,
												EDM_Parent_IABP_gne__c, EDM_IABP_SendEmails_gne__c
											FROM EDM_IABP_gne__c WHERE Id = :parentId];

			if (iabps.size() > 0) {
				parentIABP = iabps[0];
				currentIABP = iabps[0];
				if (!parentIABP.EDM_Executive_Summary_gne__c) {
					List<EDM_IABP_gne__c> exeSums = [SELECT Id, Name, EDM_Meeting_Approach_gne__c, EDM_Status_gne__c, EDM_Meeting_Date_gne__c, EDM_Start_Date_gne__c,
												EDM_End_Date_gne__c, EDM_Approval_Status_gne__c, EDM_Executive_Summary_gne__c, EDM_ExeSum_Status_gne__c, EDM_Explanation_of_Att_Changes_gne__c,
												EDM_Parent_IABP_gne__c, EDM_IABP_SendEmails_gne__c
													FROM EDM_IABP_gne__c WHERE EDM_Parent_IABP_gne__c = :parentIABP.Id AND EDM_Historical_gne__c = false];
					if (exeSums.size() > 0) {
						exeSum = exeSums[0];
						parentIABP = exeSum;
					}
					else {
						exeSum = new EDM_IABP_gne__c();
					}
				}
				else {
					exeSum = parentIABP;
				}

				UsersSharedWith = EDM_ABM_Utils.populateSharedWith(parentIABP.Id, UserRole);

				iabpAndExeSumIds = new Set<ID> {parentIABP.Id, parentIABP.EDM_Parent_IABP_gne__c, exeSum.Id};

				GeneReps = EDM_IABP_Utils.populateGeneRepresentatives(parentIABP.Id);
				Advisors = EDM_IABP_Utils.populateAdvisors(parentIABP.Id);
				NonUSAdvisors = EDM_IABP_Utils.populateNonUSAdvisors(parentIABP.Id);
				OtherAttendees = EDM_IABP_Utils.populateOtherAttendees(parentIABP.Id);
				EventDocuments = EDM_IABP_Utils.populateEventDocuments(iabpAndExeSumIds);
				SystemDocumets = EDM_IABP_Utils.populateSystemDocuments(iabpAndExeSumIds);
				ABSCommentsDocuments = EDM_IABP_Utils.populateABSCommentsDocuments(parentIABP.Id);

				markAttendeesRO();

				setClassificationStatusesForAccounts();

				addReasonHandler = new AttendeeChangeReasonForSingleIABP(parentIABP);

				setExlusionCheckDate();
				setExclusionStatus();

				updateDateAdded(parentIABP.Id);
			}
			else {
				Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'Parent IABP not found. Did you come here from IABP page?'));
			}
		}
		else {
			Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'Parent IABP ID parameter is missing or incorrect. Did you come here from IABP page?'));
		}
	}

	public PageReference goBack() {
		PageReference pr;
		String retURL = System.currentPageReference().getParameters().get('retURL');
		String prevRetURL = System.currentPageReference().getParameters().get('prevRetURL');

		if (retURL == null) {
			if (parentIABP.EDM_Executive_Summary_gne__c) {
				String forceViewModeStr = forceViewModeForExeSum ? '&forceViewMode=1' : '';
				pr = new PageReference('/apex/EDM_ExeSum_Edit_Create?id=' + parentIABP.Id  + forceViewModeStr);
			}
			else if (isUserApprover()) {
				pr = new PageReference('/apex/EDM_IABP_Review_Layout?id=' + parentIABP.Id );
			}
			else if (getIsPageReadOnly()) {
				pr = new PageReference('/apex/EDM_IABP_View_Layout?id=' + parentIABP.Id );
			}
			else {
				pr = new PageReference('/apex/EDM_IABP_Edit_Create?id=' + parentIABP.Id );
			}

		}
		else {
			String forceViewModeStr = forceViewModeForExeSum ? '&forceViewMode=1' : '';
			if (prevRetURL != null) {
				pr = new PageReference(retURL + forceViewModeStr + '&retURL=' + prevRetURL);
			}
			else {
				pr = new PageReference(retURL + forceViewModeStr);
			}
		}
		pr.setRedirect(true);
		return pr;
	}

	public PageReference saveAndGoBack() {
		saveAD();
		if (!ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
			return goBack();
		}
		return null;
	}

	public PageReference cacheCommentSaveAndGoToSBC() {
		cacheComment();

		return saveAndGoToSBC();
	}

	public PageReference saveAndGoToSBC() {
		saveAD();
		if (!ApexPages.hasMessages(ApexPages.Severity.ERROR)) {
			return new PageReference('/apex/GNE_SFA2_SBC');
		}
		return null;
	}

	public PageReference cacheCommentAndGoToSBC() {
		cacheComment();

		return goToSBC();
	}

	private void cacheComment() {
		AttendeeChangeReason changeReasonToCache = new AttendeeChangeReason(parentIABP, reasonComment);
		AttendeeChangeReasonCache reasonCache = new AttendeeChangeReasonCache();
		reasonCache.putForIABPId(parentIABP.Id, changeReasonToCache);
	}

	public PageReference goToSBC() {
		return new PageReference('/apex/GNE_SFA2_SBC');
	}

	public PageReference shareIABP() {
		if (parentIABP != null && parentIABP.Id != null) {
			Set<Id> uIdList = new Set<Id>();
			for (SelectOption so : UsersSharedWith) {
				uIdList.add(so.getValue());
			}
			List<Id> uShareAdd = EDM_ABM_Utils.setSharing(parentIABP.Id, uIdList, UserRole);
			if (exeSum.Id != null) {
				EDM_ABM_Utils.setSharing(exeSum.Id, uIdList, UserRole);
			}
			EDM_ABM_Email_Notifications.onIABPShare(parentIABP, uShareAdd);
		}

		return null;
	}

	public PageReference saveAD() {
		SavePoint sp = Database.setSavepoint();
		try {
			List<EDM_Attendee_gne__c> toUps = new List<EDM_Attendee_gne__c>();
			//save reps
			toUps.addAll(EDM_IABP_Utils.unwrapAttendeesWrapper(GeneReps));

			//save attendees
			toUps.addAll(EDM_IABP_Utils.unwrapAttendeesWrapper(Advisors));

			//save NonUSAdvisors
			toUps.addAll(EDM_IABP_Utils.unwrapAttendeesWrapper(NonUSAdvisors));

			//save Other Attendees
			toUps.addAll(EDM_IABP_Utils.unwrapAttendeesWrapper(OtherAttendees));

            //save ABS Comments
            List<EDM_ABS_Comment_gne__c> absCommentToUps = new List<EDM_ABS_Comment_gne__c>();
            absCommentToUps.addAll(EDM_IABP_Utils.unwrapABSCommentWrapper(ABSCommentsDocuments));

			upsert toUps;
            upsert absCommentToUps;

			synchronizeAttendeesToIABPFromExeSum(toUps);
            synchronizeABSCommentsToIABPFromExeSum(absCommentToUps);

			if (parentIABP.EDM_Executive_Summary_gne__c) {
				addReasonHandler.save();
			}

			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Attendees and documents have been saved!'));

			GeneReps = EDM_IABP_Utils.populateGeneRepresentatives(parentIABP.Id);
			Advisors = EDM_IABP_Utils.populateAdvisors(parentIABP.Id);
			NonUSAdvisors = EDM_IABP_Utils.populateNonUSAdvisors(parentIABP.Id);
			OtherAttendees = EDM_IABP_Utils.populateOtherAttendees(parentIABP.Id);
            ABSCommentsDocuments = EDM_IABP_Utils.populateABSCommentsDocuments(parentIABP.Id);

			updateDateAdded(parentIABP.Id);
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Could not save Attendees! ' + ex.getMessage()));
			System.debug('Could not save Attendees: ' + ex.getMessage());
			Database.rollback(sp);
		}

		return null;
	}

	private void synchronizeAttendeesToIABPFromExeSum(List<EDM_Attendee_gne__c> attendeesOnExeSum) {
		if (parentIABP.EDM_Executive_Summary_gne__c) {
			Set<Id> existingIds = new Set<Id>();
			for (EDM_Attendee_gne__c attendeOnExeSum : attendeesOnExeSum) {
				if (attendeOnExeSum.Originate_from_ExeSum_gne__c) {
					existingIds.add(attendeOnExeSum.Id);
				}
			}

			List<EDM_Attendee_gne__c> attendeesOnIABP = [SELECT Id, Originate_from_ExeSum_gne__c, is_deleted_gne__c, EDM_Parent_Attendee_gne__c
									FROM EDM_Attendee_gne__c
									WHERE EDM_Parent_Attendee_gne__c = :existingIds];
			Map<Id, EDM_Attendee_gne__c> attendeesOnIABPByParentAttendee = new Map<Id, EDM_Attendee_gne__c>();
			for (EDM_Attendee_gne__c attendeeOnIABP : attendeesOnIABP) {
				attendeesOnIABPByParentAttendee.put(attendeeOnIABP.EDM_Parent_Attendee_gne__c, attendeeOnIABP);
			}

			for (EDM_Attendee_gne__c attendeOnExeSum : attendeesOnExeSum) {
				if (attendeOnExeSum.Originate_from_ExeSum_gne__c) {
					if (attendeesOnIABPByParentAttendee.containsKey(attendeOnExeSum.Id)) {
						synchronizeAttendeeFieldsToIABP(attendeesOnIABPByParentAttendee.get(attendeOnExeSum.Id), attendeOnExeSum);
					} else {
						attendeesOnIABPByParentAttendee.put(attendeOnExeSum.Id, makeCopyAttendeeToIABP(attendeOnExeSum));
					}
				}
			}

			upsert attendeesOnIABPByParentAttendee.values();
		}
	}

    private void synchronizeABSCommentsToIABPFromExeSum(List<EDM_ABS_Comment_gne__c> absCommentsOnExeSum) {
        if (parentIABP.EDM_Executive_Summary_gne__c) {
            Set<Id> existingIds = new Set<Id>();
            for (EDM_ABS_Comment_gne__c absCommentOnExeSum : absCommentsOnExeSum) {
				existingIds.add(absCommentOnExeSum.Id);
            }

            List<EDM_ABS_Comment_gne__c> absCommentsOnIABP = [SELECT Id, EDM_Parent_ABS_Comment_gne__c
            FROM EDM_ABS_Comment_gne__c
            WHERE EDM_Parent_ABS_Comment_gne__c = :existingIds];
            Map<Id, EDM_ABS_Comment_gne__c> absCommentsOnIABPByParentAttendee = new Map<Id, EDM_ABS_Comment_gne__c>();
            for (EDM_ABS_Comment_gne__c absCommentOnIABP : absCommentsOnIABP) {
                absCommentsOnIABPByParentAttendee.put(absCommentOnIABP.EDM_Parent_ABS_Comment_gne__c, absCommentOnIABP);
            }

            for (EDM_ABS_Comment_gne__c absCommentOnExeSum : absCommentsOnExeSum) {
                    if (absCommentsOnIABPByParentAttendee.containsKey(absCommentOnExeSum.Id)) {
                        synchronizeABSCommentFieldsToIABP(absCommentsOnIABPByParentAttendee.get(absCommentOnExeSum.Id), absCommentOnExeSum);
                    } else {
                        absCommentsOnIABPByParentAttendee.put(absCommentOnExeSum.Id, makeCopyABSCommentToIABP(absCommentOnExeSum));
                    }
            }

            upsert absCommentsOnIABPByParentAttendee.values();
        }
    }

	private EDM_Attendee_gne__c makeCopyAttendeeToIABP(EDM_Attendee_gne__c newAttendeeOnExeSum) {
		EDM_Attendee_gne__c newAttendee = newAttendeeOnExeSum.clone(false, true);
		newAttendee.EDM_Parent_IABP_gne__c = parentIABP.EDM_Parent_IABP_gne__c;
		newAttendee.EDM_Parent_Attendee_gne__c = newAttendeeOnExeSum.Id;
		return newAttendee;
	}

    private EDM_ABS_Comment_gne__c makeCopyABSCommentToIABP(EDM_ABS_Comment_gne__c newABSCommentOnExeSum) {
        EDM_ABS_Comment_gne__c newAbsComment = newABSCommentOnExeSum.clone(false, true);
        newAbsComment.EDM_Parent_IABP_gne__c = parentIABP.EDM_Parent_IABP_gne__c;
        newAbsComment.EDM_Parent_ABS_Comment_gne__c = newABSCommentOnExeSum.Id;
        return newAbsComment;
    }

	private void synchronizeAttendeeFieldsToIABP(EDM_Attendee_gne__c newAttendeeOnIABP, EDM_Attendee_gne__c newAttendeeOnExeSum) {
		newAttendeeOnIABP.EDM_First_Name_gne__c = newAttendeeOnExeSum.EDM_First_Name_gne__c;
		newAttendeeOnIABP.EDM_Last_Name_gne__c = newAttendeeOnExeSum.EDM_Last_Name_gne__c;
		newAttendeeOnIABP.EDM_Role_gne__c = newAttendeeOnExeSum.EDM_Role_gne__c;
		newAttendeeOnIABP.EDM_Purpose_gne__c = newAttendeeOnExeSum.EDM_Purpose_gne__c;
		newAttendeeOnIABP.EDM_Is_Cross_Functional_gne__c = newAttendeeOnExeSum.EDM_Is_Cross_Functional_gne__c;
		newAttendeeOnIABP.EDM_Company_gne__c = newAttendeeOnExeSum.EDM_Company_gne__c;
		newAttendeeOnIABP.EDM_Observer_gne__c = newAttendeeOnExeSum.EDM_Observer_gne__c;
	}

    private void synchronizeABSCommentFieldsToIABP(EDM_ABS_Comment_gne__c newABSCommentOnIABP, EDM_ABS_Comment_gne__c newABSCommentOnExeSum) {
        newABSCommentOnIABP.ABS_Comment_gne__c = newABSCommentOnExeSum.ABS_Comment_gne__c;
        newABSCommentOnIABP.EDM_Attachment_gne__c = newABSCommentOnExeSum.EDM_Attachment_gne__c;
    }

	public PageReference addGeneRep() {

		if (GeneReps.size() < GENE_REPS_LIMIT) {
			GeneReps.add(getNewAttendeesWrapper(GeneReps.size(), EDM_IABP_Utils.AttendeeSystemType.Genentech));
			if (parentIABP.EDM_Executive_Summary_gne__c) {
				addReasonHandler.addReason(ChangeActionType.Added, GeneReps[GeneReps.size() - 1].attendee, reasonComment);
			}
		}
		else {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'You cannot add more than ' + String.valueOf(GENE_REPS_LIMIT) + ' Representatives!'));
		}

		return null;
	}

	private EDM_IABP_Utils.AttendeesWrapper getNewAttendeesWrapper(Integer position, EDM_IABP_Utils.AttendeeSystemType attendeeSysType) {
		EDM_Attendee_gne__c newAttendee = new EDM_Attendee_gne__c(
				EDM_Parent_IABP_gne__c = parentIABP.Id,
				EDM_System_Type_gne__c = attendeeSysType.name(),
				EDM_ID_For_Comparator_gne__c = parentIABP.Name + '_' + EDM_ABM_Utils.getRandomID());
		if (parentIABP.EDM_Executive_Summary_gne__c) {
			newAttendee.Originate_from_ExeSum_gne__c = true;
		}

		return new EDM_IABP_Utils.AttendeesWrapper(position, newAttendee);
	}


	public PageReference delGeneRep() {
		return delAttendee(GeneReps);
	}

	private PageReference delAttendee(List<EDM_IABP_Utils.AttendeesWrapper> attendeesWrapper) {
		if (attendeesWrapper[RowToDel].attendee.Id != null) {
			if (parentIABP.EDM_Executive_Summary_gne__c && !attendeesWrapper[RowToDel].attendee.Originate_from_ExeSum_gne__c) { // cannot use condition based on dates (created vs end event date), because attendee rows are cloned after end of event date on ExeSum.
				addAttendeeChangesCommentForDeletion(attendeesWrapper[RowToDel].attendee);
				attendeesWrapper[RowToDel].attendee.is_deleted_gne__c = !attendeesWrapper[RowToDel].attendee.is_deleted_gne__c;
				update attendeesWrapper[RowToDel].attendee;
				synchronizeDeletedAttendeeOnIABP(attendeesWrapper[RowToDel].attendee);
			}
			else {
				addAttendeeChangesCommentForDeletion(attendeesWrapper[RowToDel].attendee);
				synchronizeDeletedAttendeeOnIABP(attendeesWrapper[RowToDel].attendee);
				delete attendeesWrapper[RowToDel].attendee;
				attendeesWrapper.remove(RowToDel);
			}

		} else {
			attendeesWrapper.remove(RowToDel);
		}

		Integer i = 0;
		for (EDM_IABP_Utils.AttendeesWrapper w : attendeesWrapper) {
			w.Count = i;
			i++;
		}

		return null;
	}

	private void addAttendeeChangesCommentForDeletion(EDM_Attendee_gne__c attendee) {
		if (parentIABP.EDM_Executive_Summary_gne__c) {
			ChangeActionType actionType = attendee.is_deleted_gne__c ? ChangeActionType.Undeleted : ChangeActionType.Deleted;
			AttendeeChangeReasonForSingleIABP delReasonHandler = new AttendeeChangeReasonForSingleIABP(parentIABP);
			delReasonHandler.addReason(actionType, attendee, reasonComment);
			delReasonHandler.save();
		}
	}

	private void synchronizeDeletedAttendeeOnIABP(EDM_Attendee_gne__c attendeOnExeSum) {
		List<EDM_Attendee_gne__c> attendeOnIABP;
		if (parentIABP.EDM_Executive_Summary_gne__c) {
			if (attendeOnExeSum.Originate_from_ExeSum_gne__c) {
				attendeOnIABP = getAttendeeByParentId(attendeOnExeSum.Id);
				if (!attendeOnIABP.isEmpty()) {
					delete attendeOnIABP;
				}
			} else {
				attendeOnIABP = getAttendeeById(attendeOnExeSum.EDM_Parent_Attendee_gne__c);
				if (!attendeOnIABP.isEmpty()) {
					attendeOnIABP.get(0).is_deleted_gne__c = attendeOnExeSum.is_deleted_gne__c;
					update attendeOnIABP;
				}
			}
		}
	}

	private List<EDM_Attendee_gne__c> getAttendeeById(Id attendeeId) {
		return [SELECT Id, Originate_from_ExeSum_gne__c, is_deleted_gne__c, EDM_Parent_Attendee_gne__c
								FROM EDM_Attendee_gne__c
								WHERE id = :attendeeId];
	}

	private List<EDM_Attendee_gne__c> getAttendeeByParentId(Id attendeeId) {
		return [SELECT Id, Originate_from_ExeSum_gne__c, is_deleted_gne__c, EDM_Parent_Attendee_gne__c
								FROM EDM_Attendee_gne__c
								WHERE EDM_Parent_Attendee_gne__c = :attendeeId];
	}

	public PageReference delAdvisor() {
		return delAttendee(Advisors);
	}

	public PageReference delNonUSAdvisor() {
		return delAttendee(NonUSAdvisors);
	}

	public PageReference addNonUSAdvisor() {
		if (NonUSAdvisors.size() < NONUSADVISORS_LIMIT) {
			EDM_IABP_Utils.AttendeesWrapper attendeeWrapper = getNewAttendeesWrapper(NonUSAdvisors.size(), EDM_IABP_Utils.AttendeeSystemType.NonUSAdvisor);
			attendeeWrapper.attendee.EDM_ID_For_Comparator_gne__c = parentIABP.Name + '_' + EDM_ABM_Utils.getRandomID();
			NonUSAdvisors.add(attendeeWrapper);
			if (parentIABP.EDM_Executive_Summary_gne__c) {
				addReasonHandler.addReason(ChangeActionType.Added, NonUSAdvisors[NonUSAdvisors.size() - 1].attendee, reasonComment);
			}
		}
		else {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'You cannot add more than ' + String.valueOf(NONUSADVISORS_LIMIT) + ' Non-US HCPs and Business Leader Advisers!'));
		}

		return null;
	}

	public PageReference addOther() {
		if (OtherAttendees.size() < OTHER_LIMIT) {
			EDM_IABP_Utils.AttendeesWrapper attendeeWrapper = getNewAttendeesWrapper(OtherAttendees.size(), EDM_IABP_Utils.AttendeeSystemType.Other);
			attendeeWrapper.attendee.EDM_ID_For_Comparator_gne__c = parentIABP.Name + '_' + EDM_ABM_Utils.getRandomID();
			OtherAttendees.add(attendeeWrapper);
			if (parentIABP.EDM_Executive_Summary_gne__c) {
				addReasonHandler.addReason(ChangeActionType.Added, OtherAttendees[OtherAttendees.size() - 1].attendee, reasonComment);
			}
		}
		else {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'You cannot add more than ' + String.valueOf(OTHER_LIMIT) + ' Other Attendees!'));
		}

		return null;
	}

	public PageReference delOther() {
		return delAttendee(OtherAttendees);
	}

	public PageReference delEventDoc() {
		try {
			EDM_ABM_Utils.deleteAttachement(EventDocuments[RowToDel].EventDoc.Id);
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Could not delete Attachment! ' + ex.getMessage()));
		}

		EventDocuments.clear();
		EventDocuments = EDM_IABP_Utils.populateEventDocuments(iabpAndExeSumIds);
		return null;
	}

	public PageReference delABSCommentDoc() {
		try {
			if(exeSum.Id != null) {
				EDM_ABS_Comment_gne__c commentOnIabp = [
						SELECT Id
						FROM EDM_ABS_Comment_gne__c
						WHERE EDM_Parent_ABS_Comment_gne__c =: ABSCommentsDocuments[RowToDel].ABSCommentDoc.Id LIMIT 1];
				delete commentOnIabp;

			}

			EDM_IABP_Utils.deleteABSComment(ABSCommentsDocuments[RowToDel].ABSCommentDoc.Id, ABSCommentsDocuments[RowToDel].ABSCommentDoc.EDM_Attachment_gne__c);
		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Could not delete ABS Comment! ' + ex.getMessage()));
		}

		ABSCommentsDocuments.clear();
		ABSCommentsDocuments = EDM_IABP_Utils.populateABSCommentsDocuments(parentIABP.Id);
		return null;
	}

	public PageReference retrieveAttachments() {
		EventDocuments.clear();
		EventDocuments = EDM_IABP_Utils.populateEventDocuments(iabpAndExeSumIds);
		ABSCommentsDocuments.clear();
		ABSCommentsDocuments = EDM_IABP_Utils.populateABSCommentsDocuments(parentIABP.Id);
		return null;
	}

	public Boolean getIsPageReadOnly() {
		if (parentIABP == null) { //valid parentID not provided
			return true;
		}

		if(!isABS && getIsUpdateAttendeesWithPTDStatus()) {
			return true;
		}

		if(getIsUpdateAttendeesWithSpendStatus()) {
			return false;
		} else if(edmSpends.size() == 1
			&& edmSpends[0].EDM_Spend_Status_gne__c == 'Save & Finalize'
			&& currentIABP.EDM_Status_gne__c != 'Executive Summary in Progress'
			&& currentIABP.EDM_Status_gne__c != 'Executive Summary in Review') {
			return true;
		}

		String editmode = System.currentPageReference().getParameters().get('editmode');
		if (editmode != null) {

			if (editmode == '0') return true;
			if (editmode == '1') return false;
		}

		if (parentIABP.EDM_Executive_Summary_gne__c) {
			return !EDM_ExeSum_Utils.isInEditMode(parentIABP) || forceViewModeForExeSum;
		} else if (exeSum.Id != null) { // ExeSum exists, but User opened IABP for View
			return true;
		} else {
			Boolean fromNotEditablePage = false;
			String retURL = System.currentPageReference().getParameters().get('retURL');
			if (String.isNotBlank(retURL)) {
				if (retURL.contains('EDM_IABP_View_Layout') || retURL.contains('EDM_IABP_Review_Layout')) {
					fromNotEditablePage = true;
				}
			}
			return parentIABP.EDM_Approval_Status_gne__c == 'Submitted' || fromNotEditablePage;
		}

		return false;
	}

    public Boolean getIsViewMode() {
		String editmode = System.currentPageReference().getParameters().get('editmode');
		if (editmode != null) {

			if (editmode == '0') return true;
			if (editmode == '1') return false;
		}

        if (parentIABP.EDM_Executive_Summary_gne__c) {
            return forceViewModeForExeSum;
        }
        return true;
    }

	public Boolean getCanAddGeneAttendees() {
		return !getIsPageReadOnly();
	}

	public Boolean getCanAddRows() {
		return !getIsPageReadOnly() && (EDM_ExeSum_Utils.isABPlanner() && !getEventOccured() || EDM_ExeSum_Utils.isAbsUser());
	}

	public Boolean getEventOccured() {
		if (parentIABP.EDM_Status_gne__c == 'Event Occurred'
			|| parentIABP.EDM_Status_gne__c == 'Executive Summary in Progress'
			|| parentIABP.EDM_Status_gne__c == 'Executive Summary in Review'
			|| parentIABP.EDM_Status_gne__c == 'PTD in Progress'
			|| parentIABP.EDM_Status_gne__c == 'PTD complete'
			|| parentIABP.EDM_Executive_Summary_gne__c == true) {
			return true;
		}
		else {
			return false;
		}
	}

	public Boolean getIsUpdateAttendeesWithPTDStatus(){
		if (System.currentPageReference().getParameters().get('eaction') == 'updateAttendees' ){
			if (currentIABP.EDM_Status_gne__c == 'PTD in Progress' ||currentIABP.EDM_Status_gne__c == 'PTD complete'){
				return true;
			}
		}
		return false;
	}

	public Boolean getIsExeSumFinalized() {
		return currentIABP.EDM_Status_gne__c == 'PTD in Progress' || currentIABP.EDM_Status_gne__c == 'PTD complete' ? true : false;
	}

	public Boolean getIsUpdateAttendeesWithSpendStatus(){
		edmSpends = new List<EDM_Spend_gne__c>();
		if (isABS && System.currentPageReference().getParameters().get('eaction') == 'updateAttendees'){
			String edmSpendStatus = '';
			edmSpends = EDM_Spend_Utils.retrieveEDMSpend(currentIABP.Id);
			if(edmSpends.size() > 0) {
				edmSpendStatus = edmSpends[0].EDM_Spend_Status_gne__c;
				if (edmSpendStatus != 'Save & Finalize') {
					return true;
				}
			} else if(edmSpends.size() == 0) {
				return true;
			}
		}

		return false;
	}

	private void markAttendeesRO() {
		markAttendeesRO(GeneReps);
		markAttendeesRO(Advisors);
		markAttendeesRO(NonUSAdvisors);
		markAttendeesRO(OtherAttendees);
	}

	private void markAttendeesRO(List<EDM_IABP_Utils.AttendeesWrapper> attendees) {
		Boolean isPageReadOnly = getIsPageReadOnly();
		for (EDM_IABP_Utils.AttendeesWrapper att : attendees) {
			att.ReadOnly = isPageReadOnly;
			if (parentIABP.EDM_Executive_Summary_gne__c && !att.attendee.Originate_from_ExeSum_gne__c && !getIsUpdateAttendeesWithSpendStatus()) {
				att.ReadOnly = true;
			}
		}
	}

	private void setClassificationStatusesForAccounts() {
		isBusinessClassificationPendingByAccount = new Map<Id, Boolean>();
		isClinicalClassificationPendingByAccount = new Map<Id, Boolean>();
		Set<Id> hcpIds = new Set<Id>();
		for (EDM_IABP_Utils.AttendeesWrapper advisor : Advisors) {
			hcpIds.add(advisor.attendee.EDM_Account_gne__c);
		}
		List<EDM_Classification_Request_gne__c> pendingRequests = [SELECT EDM_Account_gne__c, EDM_Status_gne__c, EDM_Type_of_Classification_gne__c
																	FROM EDM_Classification_Request_gne__c
																	WHERE EDM_Account_gne__c IN :hcpIds
																		AND EDM_Status_gne__c = 'Pending'];
		Set<Id> hcpsWithPendingBusinessClassification = new Set<Id>();
		Set<Id> hcpsWithPendingClinicalClassification = new Set<Id>();
		for (EDM_Classification_Request_gne__c pendingRequest : pendingRequests) {
			if (pendingRequest.EDM_Type_of_Classification_gne__c == 'Business') {
				hcpsWithPendingBusinessClassification.add(pendingRequest.EDM_Account_gne__c);
			}
			else if (pendingRequest.EDM_Type_of_Classification_gne__c == 'Clinical') {
				hcpsWithPendingClinicalClassification.add(pendingRequest.EDM_Account_gne__c);
			}
		}

		for (Id hcpId : hcpIds) {
			isBusinessClassificationPendingByAccount.put(hcpId, hcpsWithPendingBusinessClassification.contains(hcpId));
			isClinicalClassificationPendingByAccount.put(hcpId, hcpsWithPendingClinicalClassification.contains(hcpId));
		}
	}

	public PageReference redirectToClassification() {
		String accountId = Apexpages.currentPage().getParameters().get('accountId');
		String typeOfClassification = Apexpages.currentPage().getParameters().get('typeOfClassification');
		if (String.isBlank(accountId) || String.isBlank(typeOfClassification)) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Classification Request: Account ID or Type of classification is missing.'));
			return null;
		}
		saveAD();
		PageReference pr = Page.EDM_Classification_Request_Edit_Create;
		pr.getParameters().put('accountId', accountId);
		pr.getParameters().put('typeOfClassification', typeOfClassification);
		pr.getParameters().put('retUrl', '/apex/EDM_Attendees_Documents?parentId=' + parentIABP.Id);
		return pr;
	}

	public PageReference submitExclusionRequest() {
		saveAD();
		if (String.isBlank(accountId)) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Classification Request: Account ID is missing.'));
		}
		else {
			List<Account> accs = [SELECT Id, AGS_EX_Exclusion_Status_gne__c FROM Account WHERE Id = :accountId];
			if (accs.size() == 1) {
				AGS_EX_Exclusion_Utils.createRequest(accs[0]);
				Advisors = EDM_IABP_Utils.populateAdvisors(parentIABP.Id);
				setExlusionCheckDate();
				setExclusionStatus();
			}
			else {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Classification Request: Did not find Account with ID: ' + accountId));
			}

		}
		return null;
	}


	private Boolean isUserApprover() {
		if (UserRole == EDM_ABM_Utils.ABAPPROVER || UserRole == EDM_ABM_Utils.ABAPPROVER_NO_LIC) {
			return true;
		}
		else {
			return false;
		}
	}


	public Boolean getIsRegenerateDocumentsButtonVisible() {
		//TODO - add iabp status and check if document are missing
		return parentIABP.EDM_Status_gne__c == 'IABP Approved' && !getEventOccured();
	}

	public PageReference regenerateSystemDocuments() {
		EDM_ABM_Utils.deleteSystemGeneratedDocuments(parentIABP.Id);
		SystemDocumets = new List<EDM_IABP_Utils.SystemDocsWrapper>();
		EDM_IABP_DrawLoop.generate(parentIABP.Id);
		return null;
	}

	@RemoteAction
	public static Boolean isWaitingForDrawloopDocuments(ID iabpId) {
		return EDM_IABP_DrawLoop.getActualNumberOfSystemGeneratedDocuments(iabpId) < EDM_IABP_DrawLoop.getExpectedNumberOfSystemGeneratedDocuments(iabpId);
	}

	public PageReference refreshPageAfertWaitingForDrawloopDocuments() {
		SystemDocumets = EDM_IABP_Utils.populateSystemDocuments(iabpAndExeSumIds);
		return null;
	}


	public enum ChangeActionType { Deleted, Undeleted, Added }
	public class AttendeeChangeReason {
		public EDM_IABP_gne__c parentIABP { get; set; }
		public EDM_Attendee_gne__c attendee { get; set; }
		private ChangeActionType type;
		private String commentText;

		public AttendeeChangeReason(EDM_IABP_gne__c parentIABP, String commentText) {
			this(ChangeActionType.Added, parentIABP, null, commentText);
		}

		public AttendeeChangeReason(ChangeActionType type, EDM_IABP_gne__c parentIABP, EDM_Attendee_gne__c attendee, String commentText) {
			this.type = type;
			this.attendee = attendee;
			this.parentIABP = parentIABP;
			this.commentText = commentText;
		}

		public String getFormattedComment() {
			String currentUserName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
			String formattedDate = Datetime.now().format('MM/dd/yyyy hh:mm:ss a');
			String action = type.name();
			String attName = getAttendeeName();
			List<String> fillers = new List<String> {
				currentUserName,
				formattedDate,
				action,
				attName,
				commentText
			};

			return String.format('({0} - {1} - {2}: {3}) Comment: {4}', fillers);
		}

		private String getAttendeeName() {
			if (attendee != null) {
				if (attendee.EDM_Account_gne__c != null) {
					return attendee.EDM_Account_gne__r.FirstName + ' ' + attendee.EDM_Account_gne__r.LastName;
				}
				else {
					return attendee.EDM_First_Name_gne__c + ' ' + attendee.EDM_Last_Name_gne__c;
				}
			}
			else {
				return '';
			}
		}
	}

	public class AttendeeChangeReasonForSingleIABP {
		private List<AttendeeChangeReason> changeReasons;
		private EDM_IABP_gne__c parentIABP;

		public AttendeeChangeReasonForSingleIABP() {
			changeReasons = new List<AttendeeChangeReason>();
		}

		public AttendeeChangeReasonForSingleIABP(EDM_IABP_gne__c parentIABP) {
			this();
			this.parentIABP = parentIABP;
		}

		public void addReason(ChangeActionType type, EDM_Attendee_gne__c attendee, String commentText) {
			changeReasons.add(new AttendeeChangeReason(type, parentIABP, attendee, commentText));
		}

		public void save() {
			List<String> commentsToSave = new List<String>();
			for (AttendeeChangeReason item : changeReasons) {
				if (item.attendee.Id != null) {
					commentsToSave.add(item.getFormattedComment());
				}
			}

			if (parentIABP != null) {
				for (String item : commentsToSave) {
					parentIABP.EDM_Explanation_of_Att_Changes_gne__c = addCommentToFieldValue(parentIABP.EDM_Explanation_of_Att_Changes_gne__c, item);
				}
			}

			if (!commentsToSave.isEmpty()) {
				update parentIABP;
			}

			changeReasons.clear();
		}

		private String addCommentToFieldValue(String fieldValue, String commentToAdd) {
			fieldValue = setToEmptyStringIfNull(fieldValue);
			fieldValue = ('<p>' + commentToAdd + '</p>' + fieldValue);
			return fieldValue;
		}

		private String setToEmptyStringIfNull(String strToDenullify) {
			if (strToDenullify == null) {
				strToDenullify = '';
			}
			return strToDenullify;
		}
	}

	public class AttendeeChangeReasonCache {
		private final String cachePrefix = 'local.EDMCache.AttendeeChangeReason';

		public void putForIABPId(String iabpId, AttendeeChangeReason changeReasonToCache) {
			Cache.Session.put(cachePrefix + iabpId, changeReasonToCache);
		}

		public AttendeeChangeReason getForIABPIdAndRemove(String iabpId) {
			AttendeeChangeReason cachedChangeReason;
			String potentialCacheKey = cachePrefix + iabpId;
			if (Cache.Session.contains(potentialCacheKey) && Cache.Session.get(potentialCacheKey) != null) {
				cachedChangeReason = (AttendeeChangeReason)Cache.Session.get(potentialCacheKey);
				Cache.Session.remove(potentialCacheKey);
			}
			return cachedChangeReason;
		}
	}

	public List<SelectOption> getCountriesForNonUSAdvisors() {
		List<String> countries = EDM_IABP_Utils.getCountries();
		countries.sort();

		List<SelectOption> results = new List<SelectOption>();
		results.add(new SelectOption('', '--None--'));

		for (String country : countries) {
			results.add(new SelectOption(country, country));
		}
		return results;
	}

	public void setExlusionCheckDate() {
		account2ExclusionCheckDateMap = new Map<Id, String>();
		List<Id> accIds = new List<Id>();
		for (EDM_IABP_Utils.AttendeesWrapper att : Advisors) {
			accIds.add(att.attendee.EDM_Account_gne__c);			
		}

		List<AGS_EX_Exclusion_Request_gne__c> existingExclusionRequests = [SELECT Id, AGS_EX_Account_Name_gne__c,CreatedDate
                                                                                FROM AGS_EX_Exclusion_Request_gne__c
                                                                                WHERE
                                                                                (AGS_EX_Request_Status_gne__c = 'Pending' OR AGS_EX_Request_Status_gne__c = 'In Progress')
                                                                              AND AGS_EX_Account_Name_gne__c in :accIds];

		Map<Id, AGS_EX_Exclusion_Request_gne__c> account2ExclusionReqMap = new Map<Id, AGS_EX_Exclusion_Request_gne__c>();
		for (AGS_EX_Exclusion_Request_gne__c req : existingExclusionRequests) {
			if (!account2ExclusionReqMap.containsKey(req.AGS_EX_Account_Name_gne__c)) {
				account2ExclusionReqMap.put(req.AGS_EX_Account_Name_gne__c, req);
			}
		}

		Map<Id, Account> account2AccountMap = new Map<Id, Account>([SELECT id, AGS_EX_Exclusion_Status_gne__c, AGS_EX_Date_Checked_Exclusion_gne__c
                                      FROM Account
                                      WHERE id IN :accIds]);


		for (EDM_IABP_Utils.AttendeesWrapper att : Advisors) {
			Date excDate = null;
			if (account2AccountMap.get(att.attendee.EDM_Account_gne__c) != null) {
				excDate = account2AccountMap.get(att.attendee.EDM_Account_gne__c).AGS_EX_Date_Checked_Exclusion_gne__c;
			

				if (account2AccountMap.get(att.attendee.EDM_Account_gne__c).AGS_EX_Exclusion_Status_gne__c == 'Request Pending' ||
	                        account2AccountMap.get(att.attendee.EDM_Account_gne__c).AGS_EX_Exclusion_Status_gne__c == 'In Process') {

	                if(account2ExclusionReqMap.containsKey(att.attendee.EDM_Account_gne__c)) {
						DateTime dT = account2ExclusionReqMap.get(att.attendee.EDM_Account_gne__c).CreatedDate;
						excDate = Date.newInstance(dT.year(), dT.month(), dT.day());
	                }
	            } else if (account2AccountMap.get(att.attendee.EDM_Account_gne__c).AGS_EX_Exclusion_Status_gne__c == 'Not Checked') {
	            	excDate = null;
	            }
	        }
            if (excDate != null) {
            	account2ExclusionCheckDateMap.put(att.attendee.EDM_Account_gne__c, excDate.format());
            } else {
            	account2ExclusionCheckDateMap.put(att.attendee.EDM_Account_gne__c, '');
            }
        }
	}

	public void setExclusionStatus() {
		account2ExclusionStatusMap = new Map<String, AGS_EX_Exclusion_Check_gne__c>();
		List<Id> accIds = new List<Id>();
		for (EDM_IABP_Utils.AttendeesWrapper att : Advisors) {
			accIds.add(att.attendee.EDM_Account_gne__c);
		}

		List<AGS_EX_Exclusion_Request_gne__c> existingExclusionRequests = [SELECT Id, AGS_EX_Account_Name_gne__c,AGS_EX_Request_Status_gne__c, (SELECT AGS_EX_Status_gne__c, AGS_EX_Check_Date_gne__c FROM AGS_EX_Exclusion_Checks__r)
		FROM AGS_EX_Exclusion_Request_gne__c
		WHERE AGS_EX_Account_Name_gne__c in :accIds
		ORDER BY AGS_EX_Account_Name_gne__c, CreatedDate DESC];

		Map<Id, List<AGS_EX_Exclusion_Request_gne__c>> account2ExclusionReqMap = new Map<Id, List<AGS_EX_Exclusion_Request_gne__c>>();
		for (AGS_EX_Exclusion_Request_gne__c req : existingExclusionRequests) {
			if (!account2ExclusionReqMap.containsKey(req.AGS_EX_Account_Name_gne__c)) {
				List<AGS_EX_Exclusion_Request_gne__c> reqs = new List<AGS_EX_Exclusion_Request_gne__c>();
				reqs.add(req);
				account2ExclusionReqMap.put(req.AGS_EX_Account_Name_gne__c, reqs);
			} else {
				account2ExclusionReqMap.get(req.AGS_EX_Account_Name_gne__c).add(req);
			}
		}

		for(Id accId : account2ExclusionReqMap.keySet()) {
			List<AGS_EX_Exclusion_Request_gne__c> reqs = account2ExclusionReqMap.get(accId);
			if(reqs.size() > 1) {
				if(reqs[1].AGS_EX_Exclusion_Checks__r[0] != null) {
					account2ExclusionStatusMap.put(accId, reqs[1].AGS_EX_Exclusion_Checks__r[0]);
				}
			}
		}

		for (String accId : accIds) {
			if(!account2ExclusionStatusMap.containsKey(accId)) {
				account2ExclusionStatusMap.put(accId, new AGS_EX_Exclusion_Check_gne__c());
			}
		}
		system.debug('SP***:' + account2ExclusionStatusMap.keySet());

	}

	public void updateDateAdded(Id iabpId) {
		List<EDM_IABP_Utils.AttendeesWrapper> attendees = new List<EDM_IABP_Utils.AttendeesWrapper>();
		attendees.addAll(Advisors);
		attendees.addAll(GeneReps);
		attendees.addAll(NonUSAdvisors);
		attendees.addAll(OtherAttendees);		

		if (attendees.size() > 0) {	
			EDM_IABP_Review_Ext.mapDateAdded4Attendees(iabpId, attendees);					    
	    }
	}

}