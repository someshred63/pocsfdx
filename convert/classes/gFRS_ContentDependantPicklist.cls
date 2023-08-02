/**
 *  Class used to list dependent picklist options when stored as GFRS Content
 **/
public with sharing class gFRS_ContentDependantPicklist {
    
    /** The list of content answers **/
    private Map<id,gFRS_DependentPicklistNode> answerMap;
    
    /**
     *  Constructor
     **/
    public gFRS_ContentDependantPicklist( String questionKey ){
        gFRS_DependentPicklistNode node = null;
        
        answerMap = new Map<id,gFRS_DependentPicklistNode>();
        
        //-- @TODO: add in filtering by current language type
        
        for( GFRS_Content_Translation__c firstTierTranslation : 
                [SELECT id, name, TextBlock__c, GFRS_Content__c
                 FROM GFRS_Content_Translation__c
                 WHERE GFRS_Content__r.Parent__r.Name = :questionKey
        ]){
            node = new gFRS_DependentPicklistNode( firstTierTranslation.GFRS_Content__c, firstTierTranslation.TextBlock__c );
            answerMap.put( firstTierTranslation.GFRS_Content__c, node );
        }
        
        Set<id> firstTierKeys = answerMap.keySet();
        
        for( GFRS_Content_Translation__c secondTierTranslation :
                [ SELECT id, name, TextBlock__c, GFRS_Content__r.Parent__c
                  FROM GFRS_Content_Translation__c
                  WHERE GFRS_Content__r.Parent__c in :firstTierKeys
                  ORDER BY gFRS_Content__r.Parent__r.Name, gFRS_Content__r.Name ]
        ){
            node = answerMap.get( secondTierTranslation.GFRS_Content__r.Parent__c );
            node.childAnswers.add( secondTierTranslation.TextBlock__c );
        }
    }
    
    /**
     *  Returns the set of master answers in JSON format
     **/
    public String getMasterAnswers() {
        List<String> lMasterAnswers = new List<String>();
        for (GFRS_DependentPicklistNode node : answerMap.values()) {
            lMasterAnswers.add(node.masterAnswer);
        }
        return JSON.serialize(lMasterAnswers);
    }
    
    /**
     *  Returns the map of Master Answers with Child Answers in JSON format
     **/
    public String getMasterAnswersWithChildAnswers() {
        Map<String, List<String> > mapMasterAnswerToChildAnswrs = new Map<String, List<String> >();
        for (gFRS_DependentPicklistNode node : answerMap.values() ) {
            if ( !mapMasterAnswerToChildAnswrs.containsKey(node.masterAnswer) ) {
                mapMasterAnswerToChildAnswrs.put(node.masterAnswer, new List<String>());
            }
        
            mapMasterAnswerToChildAnswrs.get(node.masterAnswer).addAll(node.childAnswers);
        }
        
        return JSON.serialize( mapMasterAnswerToChildAnswrs );
    }
    
    private class gFRS_DependentPicklistNode {
        
        /** the id of the question **/
        public Id masterId;
        public String masterAnswer;
        public String[] childAnswers;
        
        public gFRS_DependentPicklistNode( Id masterId, String masterAnswer ){
            this.masterId = masterId;
            this.masterAnswer = masterAnswer;
            this.childAnswers = new String[]{};
        }
    }
}