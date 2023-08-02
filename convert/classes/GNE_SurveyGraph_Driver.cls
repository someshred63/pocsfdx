public class GNE_SurveyGraph_Driver {

    public List<Questionnaire_gne__c> QuestWithQuestions;
    public Map<Id,String> questionIdTOTitle;
    public Map<Id,String> questionIdTOType;
    public Map<Id,Boolean> questionIdTOMulti;
    public List<graphData> questionData;
    public List<graphData> tmpQuestionData;
    public Map<Id,List<graphData>> dataToPresentByQuestion;
    public Map<Id,List<graphData>> TempdataToPresentByQuestion;
    public Map<Id,Map<String,String>> questionToLabels;
    public List<Id> sortingList;
    public List<repeterData> repeaterList;
    public List<repeterData> repeaterRawList;
    public String QuestId {get; set;}
    public Boolean ValidId { get; set;}
    
    private Id CurrentQuestionId;
    private Id LastQuestionId;
     
    class graphData {
        
        public String selectedValue { get; set;}
        public Integer numberOfAnswer { get; set;}
    }
    
    class repeterData {
        public Boolean pieChart { get; set;}
        public Boolean isLast { get; set;}
        public String jsonData { get; set;}
        public String questionTitle { get; set;}
        public Id questionId { get; set;}
        public Integer index { get; set;}
        public Integer totalNumberOfAnswers { get; set;}
        public Boolean putPageBreak { get { return !isLast && Math.mod(index,4)==0;}}
    }

    public GNE_SurveyGraph_Driver()
    {
        questionIdTOTitle = new Map<Id,String>();
        questionIdTOType  = new Map<Id,String>();
        questionIdTOMulti = new Map<Id,Boolean>();
        sortingList = new List<Id>();
        dataToPresentByQuestion = new Map<Id,List<graphData>>();
        questionToLabels = new Map<Id,Map<String,String>>();
        ValidId = false;
        
        QuestId = ApexPages.currentPage().getParameters().get('Id');
        system.debug('MICK :QuestId - > ' +QuestId);
        if(QuestId != null && QuestId != '') {
                
                QuestWithQuestions  = [Select (Select Name, Labels_gne__c, Title_gne__c, Type_gne__c, Values_gne__c,Multiple_Responses_gne__c From Questions__r  ORDER BY Position_gne__c) From Questionnaire_gne__c where Id = :QuestId];
                ValidId = true;
            
            String[] titles = new String[]{ 'No Opinion',  'Not sure', 'Completely Disagree'};
            integer counter = 0;
            for(Questionnaire_gne__c tmpQuest: QuestWithQuestions)
            {
                for(Question_gne__c tmpQ :tmpQuest.Questions__r)
                {
                    questionIdTOTitle.put(tmpQ.Id , tmpQ.Title_gne__c);
                    questionIdTOType.put(tmpQ.Id , tmpQ.Type_gne__c);
                    questionIdTOMulti.put(tmpQ.Id, tmpQ.Multiple_Responses_gne__c);
                    sortingList.add(tmpQ.Id);
                    
                    if(!questionToLabels.containsKey(tmpQ.Id))
                    { 
                        Map<String,String> labels = new Map<String,String>();
                        List<String> lab;
                        List<String> keys;
                        Integer i = 0;
                        if(tmpQ.Type_gne__c =='Labels and Values' && tmpQ.Labels_gne__c != null) {
                            lab = tmpQ.Labels_gne__c.split(',');
                            //keys = tmpQ.Values_gne__c.split(',');
                            
                            for(String tmp :lab)
                            {
                                labels.put( String.valueOf(i) ,lab[i] );
                                i++;
                            }
                            
                        }
                        else if (tmpQ.Type_gne__c == 'List of Values' && tmpQ.Values_gne__c != null){
                            lab = tmpQ.Values_gne__c.split(',');
                            for(String tmp :lab)
                            {
                                labels.put(tmp ,lab[i++] );
                            }
                        }
                        else if (tmpQ.Type_gne__c == 'Numeric' && tmpQ.Values_gne__c != null && tmpQ.Labels_gne__c != null){
                            system.debug('XX -> Question is Numeric ');
                            lab = tmpQ.Labels_gne__c.split(',');
                            keys = tmpQ.Values_gne__c.split(',');
                            system.debug('XX -> lab : ' + lab);
                            system.debug('XX -> keys : ' + keys);                           
                            for(String tmp :keys)
                            {
                                labels.put(tmp ,lab[i++] );
                            }
                        }
                        else if (tmpQ.Type_gne__c == 'Free Text' && tmpQ.Values_gne__c != null){
                            labels.put('Free Text Answer','Free Text Answers');

                        }
                        questionToLabels.put(tmpQ.Id ,labels);
                    }
                }
            }
        AggregateResult[] groupedResults;
        try{
        
            groupedResults  = [Select  Report_Value_gne__c, Question_gne__c, COUNT(Name) From Survey_Response_gne__c WHERE Question_gne__c IN :questionIdTOTitle.keySet() GROUP BY ROLLUP ( Question_gne__c ,Report_Value_gne__c)];
            
            for(AggregateResult resp : groupedResults){
                System.debug('grouped results: '+resp);
            }
        }
        
        catch (Exception e){
            
            
            
        }         
        
         for (AggregateResult ar : groupedResults)  {
            
            system.debug('XXX -> Question Id :' + ar.get('Question_gne__c'));
            system.debug('XXX -> QuestionType :' + questionIdTOType.get((ID) ar.get('Question_gne__c')));
            system.debug('XXX -> Question Multichoice  :' + questionIdTOMulti.get((ID) ar.get('Question_gne__c')));
            system.debug('XXX -> Question Title :' + questionIdTOTitle.get((ID) ar.get('Question_gne__c')));
            system.debug('XXX -> Selected Value:' + ar.get('Report_Value_gne__c'));
            system.debug('XXX -> Number :' + ar.get('expr0'));
            if(ar.get('Question_gne__c') != null)
            {
                graphData tmpData;  
                CurrentQuestionId = (ID) ar.get('Question_gne__c');
                 
                if(dataToPresentByQuestion.containsKey((ID) ar.get('Question_gne__c')))
                {
                    system.debug('XXX -> Adding data to dataToPresentByQuestion for question Id :' + ar.get('Question_gne__c'));
                    tmpQuestionData = dataToPresentByQuestion.get((ID) ar.get('Question_gne__c'));
                    tmpData = new graphData();
                    if(questionIdTOType.get((ID) ar.get('Question_gne__c')) == 'Free Text')
                    { // if question was Free Text take only first elem of aggregation as a count of answers
                        
                        if(CurrentQuestionId != LastQuestionId) {
                            LastQuestionId = (ID) ar.get('Question_gne__c');
                            tmpData.selectedValue = 'Free Text Answer' ;
                            tmpData.numberOfAnswer =(Integer) ar.get('expr0');
                            tmpQuestionData.add(tmpData);
                        }
                    }
                    else if(ar.get('Report_Value_gne__c') != null) {
                        tmpData.selectedValue = (String) ar.get('Report_Value_gne__c');
                        tmpData.numberOfAnswer =(Integer) ar.get('expr0');
                        tmpQuestionData.add(tmpData);
                    }
                  
                }
                else
                {
                    system.debug('XXX -> Adding new entry to dataToPresentByQuestion for question Id :' + ar.get('Question_gne__c'));
                    questionData = new List<graphData>();
                    tmpData = new graphData();
                    if(questionIdTOType.get((ID) ar.get('Question_gne__c')) == 'Free Text')
                    { // if question was Free Text take only first elem of aggregation as a count of answers
                        
                        if(CurrentQuestionId != LastQuestionId) {
                            LastQuestionId = (ID) ar.get('Question_gne__c');
                            tmpData.selectedValue = 'Free Text Answer' ;
                            tmpData.numberOfAnswer =(Integer) ar.get('expr0');
                            questionData.add(tmpData);
                        }
                    }
                    else if(ar.get('Report_Value_gne__c') != null) {
                        tmpData.selectedValue = (String)ar.get('Report_Value_gne__c');
                        tmpData.numberOfAnswer = (Integer)ar.get('expr0');
                        questionData.add(tmpData);
                        
                    }   
                    dataToPresentByQuestion.put((ID)ar.get('Question_gne__c') , questionData);
                }
            }
         }
        }
    else {
            
            ValidId = false;
        }
    System.debug('DATA for Report before clean : ' + dataToPresentByQuestion);
    //validate data before put it further
    TempdataToPresentByQuestion = new Map<Id,List<graphData>> ();
    
    for( Id tmp  :dataToPresentByQuestion.keySet()) {
         
         List<graphData> temp =  dataToPresentByQuestion.get(tmp);
         if(temp != null && temp.size() > 0)
             TempdataToPresentByQuestion.put(tmp ,temp);
    }
    dataToPresentByQuestion = TempdataToPresentByQuestion;
    System.debug('DATA for Report after clean : ' + dataToPresentByQuestion);      
    }
    
    public List<repeterData> getRepeaterData()
    {
        return getRepeaterData(true);
    }
    
    public List<repeterData> getRepeaterRawData()
    {
        return getRepeaterData(false);
    }
    
    public List<repeterData> getRepeaterData(Boolean chartMode)
    {
        repeaterList = new List<repeterData>();
        
        Integer idx=0;
        repeterData tmprep;
        for(Id sortedId : sortingList){
            for(Id tmpId : dataToPresentByQuestion.keySet())
            {
                if(sortedId == tmpId){
                    system.debug('xx repeater data tmpquestionId: ' + tmpId);
                    tmprep = new repeterData();
                    tmprep.questionId=tmpId;
                    tmprep.isLast = false;
                    tmprep.jsonData = buildQuestionStatisticsData(tmpId, tmprep, chartMode);
                    if(tmprep.jsonData==null) continue;
                    tmprep.questionTitle = questionIdTOTitle.get(tmpId);
                    if (chartMode) tmprep.pieChart = (questionIdTOType.get(tmpId) != 'Free Text' ? true:false);
                    tmprep.index=++idx;
                    repeaterList.add(tmprep);
                }
            }
        }
        
        if(tmprep!=null) tmprep.isLast=true;
        
        return repeaterList;
    }

    private List<graphData> getQuestionStatisticsData(Id questionId, boolean pieChartMode) {
        List<graphData> labelAndAmountList = new List<graphData>();
        
        List<Id> tmpQuestion = new List<Id>();
        Map<String,String> tmpLabels;
        Integer i;
        tmpLabels = questionToLabels.get(questionId);
          
        Pattern naPattern = Pattern.compile('(^|^.*\\W)(NA|N/A)($|\\W.*$)');
         
         for(graphData elem : dataToPresentByQuestion.get(questionId)){
         	
            String label;
            
            if(questionIdTOMulti.get(questionId) && elem.selectedValue.length() > 1)
            {
                String longLabel ='';
                
                for(String temp : elem.selectedValue.split(','))
                {   
                    longLabel += tmpLabels.get(temp);
                    if (longLabel > '')
                        longLabel += ',';
                }
                if(longLabel.endsWith(','))
                    longLabel = longLabel.substring(0, longLabel.lastIndexOf(','));
                    
                label=longLabel;
            }
            else
            {
                if(tmpLabels.containsKey(elem.selectedValue))
                    label=tmpLabels.get(elem.selectedValue);
                else
                    label=elem.selectedValue;
            }
            
            // SFA-149 BR-03: Exclude 'Not Assessed' and N/A Answers from PieChart.
            if(pieChartMode && label!=null && (label.toLowerCase().contains('not assessed') || naPattern.matcher(label).matches()))
            	continue;
            graphData newGraphData = new graphData();
            newGraphData.selectedValue=label;
            
            newGraphData.numberOfAnswer=elem.numberOfAnswer;
            
            labelAndAmountList.add(newGraphData);
        }
        
        return labelAndAmountList;
    }
    
    private String buildQuestionStatisticsData(Id questionId, repeterData repData, boolean pieChartMode)
    {
        List<graphData> graphDatas = getQuestionStatisticsData(questionId,pieChartMode);
        
        repData.totalNumberOfAnswers=0;
        
        GoogleViz gv = new GoogleViz();
        
        gv.cols = new list<GoogleViz.col> { 
           new GoogleViz.Col('col1','Selected Value','string'),
           new GoogleViz.Col('col2','Number of answer','number')
        };
        
        for (graphData gData : graphDatas) {
            
            GoogleViz.row r = new GoogleViz.row();
            
            r.cells.add (new GoogleViz.cell(gData.selectedValue));
            r.cells.add (new GoogleViz.cell(gData.numberOfAnswer)); 
            
            gv.addRow( r );
                
            repData.totalNumberOfAnswers+=gData.numberOfAnswer;
        }
        
        if(repData.totalNumberOfAnswers==0) return null;
        else return gv.toJsonString();
    }
    
    public String getQuestionTitle(Id questionId)
    {
        Integer i = 1;
        List<Id> tmpQuestion = new List<Id>();
        for(Id tmpId : questionToLabels.keySet())
        {
            tmpQuestion.add(tmpId);
        }
        return questionIdTOTitle.get(tmpQuestion[i]);
    }
    
    public List<graphData> getCurrentQuestionData() {
        String questionId = ApexPages.currentPage().getParameters().get('questionId');
        Boolean chartMode = Boolean.valueOf(ApexPages.currentPage().getParameters().get('chartMode'));
        return getQuestionStatisticsData(questionId,chartMode);
    }
    
    public String getCurrentQuestionHeader() {
        String questionId = ApexPages.currentPage().getParameters().get('questionId');
        return questionIdTOTitle.get(questionId);
    }
}