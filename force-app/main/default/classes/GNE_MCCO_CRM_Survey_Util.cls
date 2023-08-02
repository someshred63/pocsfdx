public virtual class GNE_MCCO_CRM_Survey_Util {

    public static Map<String, Set<Id>> getUsersTerrs() {
        Map<String, Set<Id>> result = new Map<String, Set<Id>>();
        Map<Id, Territory2> terrMap = getFieldIntelligenceTerritories();

        for (UserTerritory2Association ut : [SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE Territory2Id IN :terrMap.keySet()]) {

            if (result.containsKey(terrMap.get(ut.Territory2Id).Name)) {
                result.get(terrMap.get(ut.Territory2Id).Name).add(ut.UserId);
            } else {
                result.put(terrMap.get(ut.Territory2Id).Name, new Set<Id>{
                        ut.UserId
                });
            }

        }

        return result;
    }

    public static Map<Id, Territory2> getFieldIntelligenceTerritories() {
        Map<Id, Territory2> territory2Map = new Map<Id, Territory2>();
        List<GNE_Field_Intelligence_Territories__c> territories = GNE_Field_Intelligence_Territories__c.getAll().values();
        if (territories.size() > 0) {
            String query = 'SELECT Id, Name, External_id_gne__c FROM Territory2 WHERE (';
            for (GNE_Field_Intelligence_Territories__c territory : territories) {
                if (territory.Is_Active_gne__c) {
                    query += ' External_id_gne__c LIKE \'' + territory.Territory_Root_gne__c + '\' OR';
                }
            }
            query = query.removeEnd('OR');
            query += ') AND (NOT External_id_gne__c LIKE \'INACTIVE TERRITORIES%\') ORDER BY External_id_gne__c';
            List<Territory2> supportedTerritories = Database.query(query);
            for (Territory2 terr : supportedTerritories) {
                territory2Map.putAll(new Map<Id, Territory2>{
                        terr.Id => terr
                });
            }
        }

        return territory2Map;
    }

    private static Map<String, Set<Id>> getUsersTerritories(Map<Id, Territory2> terrMap) {
        Map<String, Set<Id>> result = new Map<String, Set<Id>>();
        for (UserTerritory2Association ut : [SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE Territory2Id IN :terrMap.keySet()]) {
            if (!result.containsKey(terrMap.get(ut.Territory2Id).Name)) {
                result.put(terrMap.get(ut.Territory2Id).Name, new Set<Id>{
                        ut.UserId
                });
            } else {
                result.get(terrMap.get(ut.Territory2Id).Name).add(ut.UserId);
            }
        }

        return result;
    }

    public static Map<String, Set<Id>> getTerritoryNameToUserId() {
        Map<String, Set<Id>> result = new Map<String, Set<Id>>();
        List<Territory2> territoriesList = new List<Territory2>();
        territoriesList.addAll(getTerritories());

        Map<Id, String> territoryIdToNameMap = new Map<Id, String>();

        for (Territory2 t : territoriesList) {
            territoryIdToNameMap.put(t.Id, t.Name);
        }

        for (UserTerritory2Association ut : [SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE Territory2Id IN :territoryIdToNameMap.keySet()]) {

            if (result.containsKey(territoryIdToNameMap.get(ut.Territory2Id))) {
                result.get(territoryIdToNameMap.get(ut.Territory2Id)).add(ut.UserId);
            } else {
                result.put(territoryIdToNameMap.get(ut.Territory2Id), new Set<Id>{
                        ut.UserId
                });
            }

        }

        return result;
    }

    public static List<Territory2> getTerritories() {
        return getTerritories(null);
    }

    public static List<Territory2> getTerritories(Id territoryId) {
        List<Territory2> result = new List<Territory2>();
        List<String> parentTerrs = new List<String>();
        if (String.isNotBlank(territoryId)) {
            for (Territory2 t : [SELECT External_Id_gne__c FROM Territory2 WHERE Id = :territoryId]) {
                if (String.isNotBlank(t.External_Id_gne__c)) {
                    parentTerrs.add(t.External_Id_gne__c);
                }
            }
        } else {
            for (GNE_Field_Intelligence_Territories__c ft : [SELECT Territory_Root_gne__c FROM GNE_Field_Intelligence_Territories__c WHERE Is_Active_gne__c = TRUE]) {
                if (String.isNotBlank(ft.Territory_Root_gne__c)) {
                    parentTerrs.add(ft.Territory_Root_gne__c);
                }
            }
        }

        if (!parentTerrs.isEmpty()) {
            result = [SELECT Id, Name, ParentTerritory2Id, External_Id_gne__c, Parent_External_Id_gne__c FROM Territory2 WHERE External_Id_gne__c LIKE :parentTerrs AND (NOT External_Id_gne__c LIKE 'INACTIVE TERRITORIES%') ORDER BY External_Id_gne__c];
        }
        return result;
    }

    public virtual class SurveyWrapper {

        public String Id { get; set; }
        public String Title { get; set; }
        public String Type { get; set; }
        public String AssignmentMode { get; set; }
        public Boolean ReadyToUse { get; set; }
        public Boolean Closed { get; set; }
        public String RequestedBy { get; set; }
        public String Notification { get; set; }
        public List<String> Territories { get; set; }
        public Set<String> AccountIds { get; set; }
        public List<SurveyElementWrapper> Elements { get; set; }

        public String getAccountIdsAsString() {
            String result = '';

            for (String s : this.AccountIds) {
                s.deleteWhitespace();
                if (s.length() == 18) {
                    result += s.substring(0, 15) + ';';
                } else {
                    result += s + ';';
                }
            }

            return result.removeEnd(';');
        }

        public String getTerritoryIdsAsString() {
            String result = '';

            for (String s : this.Territories) {
                s.deleteWhitespace();
                result += s + ';';
            }

            return result.removeEnd(';');
        }

        // Create Wrapper without answers
        public SurveyWrapper createWrapperFromObjects(GNE_MCCO_CRM_Survey__c survey, List<GNE_MCCO_CRM_Survey_Question__c> questions, List<GNE_MCCO_CRM_Survey_Group__c> groups, Boolean copyMode) {
            this.createSurveyFromObject(survey, copyMode);
            this.createElementsFromObjects(questions, groups, copyMode);
            return this;
        }

        // Create Wrapper with answers
        public SurveyWrapper createWrapperFromObjects(GNE_MCCO_CRM_Survey__c survey, List<GNE_MCCO_CRM_Survey_Question__c> questions, List<GNE_MCCO_CRM_Survey_Group__c> groups, List<GNE_MCCO_CRM_Field_Intelligence_Answer__c> answerList) {
            this.createSurveyFromObject(survey, true);
            this.createElementsFromObjects(questions, groups, answerList);
            return this;
        }

        private void createSurveyFromObject(GNE_MCCO_CRM_Survey__c survey, Boolean copyMode) {
            if (!copyMode) {
                this.Id = survey.Id;
            }
            this.Title = survey.Title_gne__c;
            this.Type = survey.Record_Type_gne__c;
            this.ReadyToUse = survey.Ready_To_Use_gne__c;
            this.AssignmentMode = survey.Assignment_Mode_gne__c;
            this.Closed = survey.Close_Survey_gne__c;
            this.RequestedBy = survey.Requested_By_gne__c;
            this.Notification = survey.Notification_gne__c;
            this.Territories = (!String.isEmpty(survey.Territories_gne__c)) ? survey.Territories_gne__c.split(';', 0) : new List<String>();
            this.AccountIds = this.createSetAccountIds(survey.Account_Ids_gne__c);
            if(copyMode) {
                this.Territories.clear();
                this.AccountIds.clear();
            }
        }

        private void createElementsFromObjects(List<GNE_MCCO_CRM_Survey_Question__c> questions, List<GNE_MCCO_CRM_Survey_Group__c> groups, Boolean copyMode) {
            List<SurveyElementWrapper> elements = new List<SurveyElementWrapper>();
            Map<String, List<SurveyElementWrapper>> elementsToGroupMap = new Map<String, List<SurveyElementWrapper>>();

            // Questions
            for (GNE_MCCO_CRM_Survey_Question__c question : questions) {

                SurveyElementWrapper element = new SurveyElementWrapper();
                if (!copyMode) {
                    element.Id = question.Id;
                }
                element.Type = question.Type_gne__c;
                element.Title = question.Question_gne__c;
                element.Help = question.Help_Text_gne__c;
                element.CondHelp = question.Conditional_Help_Text_gne__c;
                element.Required = question.Required_gne__c;
                element.Order = question.Order_gne__c;
                element.Values = (!String.isEmpty(question.Values_gne__c) && question.Type_gne__c != 'Conditional') ? question.Values_gne__c.split(';;;', 0) : new List<String>();
                element.CondValues = (!String.isEmpty(question.Values_gne__c) && question.Type_gne__c == 'Conditional') ? this.createConditionalValues(question.Values_gne__c) : new List<SurveyConditionalWrapper>();

                if (question.Group_gne__c != null) {
                    if (elementsToGroupMap.containsKey(question.Group_gne__c)) {
                        elementsToGroupMap.get(question.Group_gne__c).add(element);
                    } else {
                        List<SurveyElementWrapper> tmpList = new List<SurveyElementWrapper>();
                        tmpList.add(element);
                        elementsToGroupMap.put(question.Group_gne__c, tmpList);
                    }
                } else {
                    elements.add(element);
                }

            }

            // Groups
            for (GNE_MCCO_CRM_Survey_Group__c groupItem : groups) {

                if (elementsToGroupMap != null && elementsToGroupMap.containsKey(groupItem.Id)) {
                    elementsToGroupMap.get(groupItem.Id).sort();
                }

                SurveyElementWrapper element = new SurveyElementWrapper();

                if (!copyMode) {
                    element.Id = groupItem.Id;
                }
                element.Type = 'Group';
                element.Title = groupItem.Title_gne__c;
                element.Help = null;
                element.CondHelp = null;
                element.Required = null;
                element.Order = groupItem.Order_gne__c;
                if (elementsToGroupMap != null && elementsToGroupMap.containsKey(groupItem.Id)) {
                    element.Elements = elementsToGroupMap.get(groupItem.Id);
                }

                elements.add(element);

            }

            elements.sort();

            this.Elements = elements;

        }

        private void createElementsFromObjects(List<GNE_MCCO_CRM_Survey_Question__c> questions, List<GNE_MCCO_CRM_Survey_Group__c> groups, List<GNE_MCCO_CRM_Field_Intelligence_Answer__c> answerList) {
            List<SurveyElementWrapper> elements = new List<SurveyElementWrapper>();
            Map<String, List<SurveyElementWrapper>> elementsToGroupMap = new Map<String, List<SurveyElementWrapper>>();
            Map<Id, GNE_MCCO_CRM_Field_Intelligence_Answer__c> answerMap = new Map<Id, GNE_MCCO_CRM_Field_Intelligence_Answer__c>();

            Map<Id, Map<Decimal, Map<Id, SurveyAnswerWrapper>>> answerGroupMap = new Map<Id, Map<Decimal, Map<Id, SurveyAnswerWrapper>>>();

            for (GNE_MCCO_CRM_Field_Intelligence_Answer__c answer : answerList) {
                if (answer.MCCO_CRM_Survey_Group_gne__c == null) {
                    answerMap.put(answer.Survey_Question_gne__c, answer);
                } else {

                    SurveyAnswerWrapper surveyAnswer = new SurveyAnswerWrapper();

                    surveyAnswer.Id = answer.Id;
                    surveyAnswer.TextAnswer = answer.Answer_gne__c;
                    surveyAnswer.Conditional = answer.Conditional_Answer_gne__c;

                    if (!String.isEmpty(answer.Answer_gne__c)) {
                        surveyAnswer.PicklistAnswer = answer.Answer_gne__c.split(';;;');
                    } else {
                        surveyAnswer.PicklistAnswer = null;
                    }

                    Map<Id, SurveyAnswerWrapper> tmpMap1 = new Map<Id, SurveyAnswerWrapper>();
                    tmpMap1.put(answer.Survey_Question_gne__c, surveyAnswer);

                    Map<Decimal, Map<Id, SurveyAnswerWrapper>> tmpMap2 = new Map<Decimal, Map<Id, SurveyAnswerWrapper>>();
                    tmpMap2.put(answer.Group_Set_gne__c, tmpMap1);

                    if (answerGroupMap.containsKey(answer.MCCO_CRM_Survey_Group_gne__c)) {

                        if (answerGroupMap.get(answer.MCCO_CRM_Survey_Group_gne__c).containsKey(answer.Group_Set_gne__c)) {
                            Map<Id, SurveyAnswerWrapper> m = answerGroupMap.get(answer.MCCO_CRM_Survey_Group_gne__c).get(answer.Group_Set_gne__c);
                            m.put(answer.Survey_Question_gne__c, surveyAnswer);
                            answerGroupMap.get(answer.MCCO_CRM_Survey_Group_gne__c).put(answer.Group_Set_gne__c, m);
                        } else {
                            Map<Decimal, Map<Id, SurveyAnswerWrapper>> m = answerGroupMap.get(answer.MCCO_CRM_Survey_Group_gne__c);
                            m.put(answer.Group_Set_gne__c, tmpMap1);
                            answerGroupMap.put(answer.MCCO_CRM_Survey_Group_gne__c, m);
                        }

                    } else {

                        answerGroupMap.put(answer.MCCO_CRM_Survey_Group_gne__c, tmpMap2);
                    }
                }
            }

            // Questions
            for (GNE_MCCO_CRM_Survey_Question__c question : questions) {

                SurveyElementWrapper element = new SurveyElementWrapper();

                element.Id = question.Id;
                element.Type = question.Type_gne__c;
                element.Title = question.Question_gne__c;
                element.Help = question.Help_Text_gne__c;
                element.CondHelp = question.Conditional_Help_Text_gne__c;
                element.Required = question.Required_gne__c;
                element.Order = question.Order_gne__c;
                element.Values = (!String.isEmpty(question.Values_gne__c) && question.Type_gne__c != 'Conditional') ? question.Values_gne__c.split(';;;', 0) : new List<String>();
                element.CondValues = (!String.isEmpty(question.Values_gne__c) && question.Type_gne__c == 'Conditional') ? this.createConditionalValues(question.Values_gne__c) : new List<SurveyConditionalWrapper>();

                if (answerMap.containsKey(question.Id)) {
                    SurveyAnswerWrapper surveyAnswer = new SurveyAnswerWrapper();

                    surveyAnswer.Id = answerMap.get(question.Id).Id;
                    surveyAnswer.TextAnswer = answerMap.get(question.Id).Answer_gne__c;
                    surveyAnswer.Conditional = answerMap.get(question.Id).Conditional_Answer_gne__c;

                    if (!String.isEmpty(answerMap.get(question.Id).Answer_gne__c)) {
                        surveyAnswer.PicklistAnswer = answerMap.get(question.Id).Answer_gne__c.split(';;;');
                    } else {
                        surveyAnswer.PicklistAnswer = null;
                    }

                    element.Answer = surveyAnswer;
                }

                if (question.Group_gne__c != null) {
                    if (elementsToGroupMap.containsKey(question.Group_gne__c)) {
                        elementsToGroupMap.get(question.Group_gne__c).add(element);
                    } else {
                        List<SurveyElementWrapper> tmpList = new List<SurveyElementWrapper>();
                        tmpList.add(element);
                        elementsToGroupMap.put(question.Group_gne__c, tmpList);
                    }
                } else {
                    elements.add(element);
                }

            }

            // Groups
            for (GNE_MCCO_CRM_Survey_Group__c groupItem : groups) {

                elementsToGroupMap.get(groupItem.Id).sort();

                SurveyElementWrapper element = new SurveyElementWrapper();

                element.Id = groupItem.Id;
                element.Type = 'Group';
                element.Title = groupItem.Title_gne__c;
                element.Help = null;
                element.CondHelp = null;
                element.Required = null;
                element.Order = groupItem.Order_gne__c;
                element.Elements = elementsToGroupMap.get(groupItem.Id);

                if (answerGroupMap.containsKey(groupItem.Id)) {

                    element.GroupElements = answerGroupMap.get(groupItem.Id);
                    element.GroupElementsCount = answerGroupMap.get(groupItem.Id).keySet().size();
                    System.debug(answerGroupMap.get(groupItem.Id));

                }

                elements.add(element);

                System.debug(elementsToGroupMap.get(groupItem.Id));

            }

            elements.sort();

            this.Elements = elements;

        }

        private List<SurveyConditionalWrapper> createConditionalValues(String values) {
            List<SurveyConditionalWrapper> result = new List<SurveyConditionalWrapper>();

            for (String value : values.split(';;;', 0)) {
                SurveyConditionalWrapper condition = new SurveyConditionalWrapper();

                List<String> split = value.split('---', 0);

                condition.Value = split[0];
                condition.Condition = (split[1] == 'true') ? true : false;

                result.add(condition);
            }

            return result;
        }

        private Set<String> createSetAccountIds(String accountIds) {
            Set<String> result = new Set<String>();

            return result;
        }

    }

    public virtual class SurveyElementWrapper implements Comparable {

        public String Id { get; set; }
        public String Type { get; set; }
        public String Title { get; set; }
        public String Help { get; set; }
        public String CondHelp { get; set; }
        public Boolean Required { get; set; }
        public Decimal Order { get; set; }
        public List<String> Values { get; set; }
        public List<SurveyConditionalWrapper> CondValues { get; set; }
        public List<SurveyElementWrapper> Elements { get; set; }
        public SurveyAnswerWrapper Answer { get; set; }
        public Map<Decimal, Map<Id, SurveyAnswerWrapper>> GroupElements { get; set; }
        public Map<Decimal, Map<Id, List<String>>> GroupValues { get; set; }
        public Decimal GroupElementsCount { get; set; }

        public String getNormalType() {
            String result = '';
            if (this.Type == 'Free text') {
                result = 'text';
            } else if (this.Type == 'Conditional') {
                result = 'conditional';
            } else if (this.Type == 'Date') {
                result = 'date';
            } else if (this.Type == 'Multi select picklist') {
                result = 'multipicklist';
            } else if (this.Type == 'Simple picklist') {
                result = 'picklist';
            } else if (this.Type == 'Rank') {
                result = 'rank';
            }
            return result;
        }

        public String getValuesAsString() {
            String result = '';

            if (this.Type == 'Conditional') {
                if (this.CondValues.size() > 0) {
                    for (SurveyConditionalWrapper condition : this.CondValues) {
                        result += condition.Value + '---' + condition.Condition + ';;;';
                    }
                    result = result.removeEnd(';;;');
                }
            } else if (this.Type == 'Simple picklist' || this.Type == 'Multi select picklist' || this.Type == 'Rank') {
                if (this.Values.size() > 0) {
                    result = String.join(this.Values, ';;;');
                }
            }

            return result;
        }

        public Integer compareTo(Object compareTo) {
            SurveyElementWrapper wrapper = (SurveyElementWrapper) compareTo;
            if (this.Order == wrapper.Order) return 0;
            if (this.Order > wrapper.Order) return 1;
            return -1;
        }

    }

    public virtual class SurveyConditionalWrapper {

        public String Value { get; set; }
        public Boolean Condition { get; set; }

    }

    public virtual class SurveyAnswerWrapper {

        public String Id { get; set; }
        public String TextAnswer { get; set; }
        public String Conditional { get; set; }
        public List<String> PicklistAnswer { get; set; }

    }

    public virtual class FieldIntelligenceWrapper {

        public String Id { get; set; }
        public String QuestionId { get; set; }
        public String GroupId { get; set; }
        public String Answer { get; set; }
        public Integer GroupSet { get; set; }
        public String Type { get; set; }
        public List<String> PickList { get; set; }
        public String Conditional { get; set; }
        public List<FieldIntelligenceWrapper> Elements { get; set; }

    }

}