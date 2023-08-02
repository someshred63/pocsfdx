public class EDM_IABP_AgendaSummary {
	public List<AgendaSummaryItem> items {get; private set;}
	private AgendaSummaryItem summaryItemForWholeEvent;
	private List<EDM_Session_gne__c> sessions;
	private String IABPGroup;

	public EDM_IABP_AgendaSummary(Id iabpId) {
		EDM_IABP_gne__c iabp = [SELECT 
				Id, EDM_Start_Date_gne__c, EDM_End_Date_gne__c, 
				EDM_Parent_AABP_gne__r.EDM_Group_gne__c, EDM_Joint_AABP_gne__c,
				(SELECT Id, EDM_Session_Date_gne__c, EDM_Is_Break_gne__c, EDM_No_Presentation_gne__c,
						EDM_Presentation_Start_Time_gne__c, EDM_Presentation_End_Time_gne__c,
						EDM_No_Discussion_gne__c, EDM_Discussion_Start_Time_gne__c, EDM_Discussion_End_Time_gne__c
					FROM EDM_Sessions__r)
			FROM EDM_IABP_gne__c WHERE Id = :iabpId LIMIT 1];
		this.sessions = iabp.EDM_Sessions__r;
		this.IABPGroup = EDM_IABP_Utils.getIABPGroup(iabp);
		initialize(iabp.EDM_Start_Date_gne__c, iabp.EDM_End_Date_gne__c);
	}

	public EDM_IABP_AgendaSummary(Date startDate, Date endDate, String IABPGroup, List<EDM_Session_gne__c> sessions) {
		this.sessions = sessions;
		this.IABPGroup = IABPGroup;
		initialize(startDate, endDate);
	}

	private void initialize(Date startDate, Date endDate) {
		items = calculateAgendaSummaryPerEachDay(startDate, endDate);

		summaryItemForWholeEvent = new AgendaSummaryItem(null, IABPGroup, sessions);
		items.add(summaryItemForWholeEvent);
	}

	private List<AgendaSummaryItem> calculateAgendaSummaryPerEachDay(Date startDate, Date endDate) {
		List<AgendaSummaryItem> results = new List<AgendaSummaryItem>();
		Date d = startDate;
		if (d != null) {
			do {
				AgendaSummaryItem item = new AgendaSummaryItem(d, IABPGroup, getSessionsFilteredByDate(d));
				if (item.getTotalMeetingTimeInMinutes() > 0) {
					results.add(item);
				}
				d = d.addDays(1);
			} while (d <= endDate);
		}

		return results;
	}

	private List<EDM_Session_gne__c> getSessionsFilteredByDate(Date d) {
		List<EDM_Session_gne__c> results = new List<EDM_Session_gne__c>();
		for (EDM_Session_gne__c session : sessions) {
			if (session.EDM_Session_Date_gne__c == d) {
				results.add(session);
			}
		}
		return results;
	}

	public Boolean meetHCOPolicyDiscussionTime() {
		if (IABPGroup == 'PD' || IABPgroup == 'gRED'
				|| summaryItemForWholeEvent.getTotalMeetingTimeInMinutes() == 0) {
			return true;
		}

		for (AgendaSummaryItem item : items) {
			if (Decimal.valueOf(item.getDiscussionTimePercentage()) < 65.0) {
				return false;
			}
		}
		return true;
	}

	public String getPresentationTime() {
		return summaryItemForWholeEvent.getPresentationTime();
	}

	public String getDiscussionTime() {
		return summaryItemForWholeEvent.getDiscussionTime();
	}

	public String getTotalMeetingTime() {
		return summaryItemForWholeEvent.getTotalMeetingTime();
	}

	public String getBreakTime() {
		return summaryItemForWholeEvent.getBreakTime();
	}

	public String getPresentationTimePercentage() {
		return summaryItemForWholeEvent.getPresentationTimePercentage();
	}

	public String getDiscussionTimePercentage() {
		return summaryItemForWholeEvent.getDiscussionTimePercentage();
	}

	public class AgendaSummaryItem {
		private Date sessionsDate;
		private String IABPGroup;
		private Integer presentationTimeInMinutes = 0;
		private Integer discussionTimeInMinutes = 0;
		private Integer totalTimeInMinutes = 0;

		private Integer breakTimeInMinutes = 0;
		
		public AgendaSummaryItem(Date sessionsDate, String IABPGroup, List<EDM_Session_gne__c> sessions) {
			this.sessionsDate = sessionsDate;
			this.IABPGroup = IABPGroup;
			for (EDM_Session_gne__c session : sessions) {
				Integer presentationTimeInMinutesPerSession = getPresentationTimeIntFor(session);
				Integer discussionTimeInMinutesPerSession = getDiscussionTimeIntFor(session);
				presentationTimeInMinutes += presentationTimeInMinutesPerSession;
				discussionTimeInMinutes += discussionTimeInMinutesPerSession;
				totalTimeInMinutes += presentationTimeInMinutesPerSession + discussionTimeInMinutesPerSession;

				breakTimeInMinutes += getBreakTimeIntFor(session);
			}
		}

		private Integer getPresentationTimeIntFor(EDM_Session_gne__c session) {
			return !session.EDM_Is_Break_gne__c && !session.EDM_No_Presentation_gne__c ? 
					Integer.valueOf(EDM_ABM_Utils.getTimeDifference(true, session.EDM_Presentation_Start_Time_gne__c, session.EDM_Presentation_End_Time_gne__c))
					: 0;
		}

		private Integer getDiscussionTimeIntFor(EDM_Session_gne__c session) {
			return !sessionWithOnlyPresentationTime(session) && !session.EDM_No_Discussion_gne__c ?
					Integer.valueOf(EDM_ABM_Utils.getTimeDifference(true, session.EDM_Discussion_Start_Time_gne__c, session.EDM_Discussion_End_Time_gne__c))
					: 0 ;
		}

		private Integer getBreakTimeIntFor(EDM_Session_gne__c session) {
			return session.EDM_Is_Break_gne__c ?
					Integer.valueOf(EDM_ABM_Utils.getTimeDifference(true, session.EDM_Presentation_Start_Time_gne__c, session.EDM_Presentation_End_Time_gne__c))
					: 0 ;
		}

		private Boolean sessionWithOnlyPresentationTime(EDM_Session_gne__c session) {
			return session.EDM_Is_Break_gne__c || IABPGroup == 'PD' || IABPgroup == 'gRED';
		}

		public String getSessionsDateFormated() {
			return sessionsDate != null ? sessionsDate.format() : 'All days';
		}

		public String getPresentationTime() {
			return EDM_ABM_Utils.getTimeInHoursMinutes(presentationTimeInMinutes);
		}

		public String getDiscussionTime() {
			return EDM_ABM_Utils.getTimeInHoursMinutes(discussionTimeInMinutes);
		}

		public String getTotalMeetingTime() {
			return EDM_ABM_Utils.getTimeInHoursMinutes(totalTimeInMinutes);
		}

		public Integer getTotalMeetingTimeInMinutes() {
			return totalTimeInMinutes;
		}

		public String getBreakTime() {
			return EDM_ABM_Utils.getTimeInHoursMinutes(breakTimeInMinutes);
		}

		public String getPresentationTimePercentage() {
			Long total = 0;
			if (totalTimeInMinutes > 0) {
				total = (presentationTimeInMinutes * 100.0 / totalTimeInMinutes).round();
			}

			return String.valueOf(total);
		}

		public String getDiscussionTimePercentage() {
			if (totalTimeInMinutes > 0) {
				return String.valueOf(100 - Integer.valueOf(getPresentationTimePercentage()));
			}
			return '0';
		}
	}
}