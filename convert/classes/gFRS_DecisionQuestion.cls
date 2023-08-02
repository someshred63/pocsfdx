/**
 *  Class used to find Decision questions and their answers.
 **/
public with sharing class gFRS_DecisionQuestion {
    
    //-- lookup constants
    
    //-- local variables
    
    /**
     *  The content translation of the question being asked
     **/
    public GFRS_Content_Translation__c contentQuestion { get; set; }
    
    /**
     *  The set of answers available for that question
     **/
    public GFRS_Content_Translation__c[] contentAnswers { get; set; }
    
    /** the selected translation answer **/
    public GFRS_Content_Translation__c selectedAnswer { get; set; }
    
    /** if internal decision tree should be used **/
    public Boolean isInternal {get; set;}
    
    /**
     *  The set of answers broken down by ids
     **/
    private Map<Id, GFRS_Content_Translation__c> answerMap;
    
    public gFRS_DecisionQuestion( id questionParent, Boolean isInternalTree ){
        //-- todo: add in filter for language
        this.isInternal = isInternalTree;
        String questionFilter = isInternalTree ? gFRS_Util.FILTER_INTERNAL_QUESTION : gFRS_Util.FILTER_QUESTION;
        String answerFilter = isInternalTree ? gFRS_Util.FILTER_INTERNAL_ANSWER : gFRS_Util.FILTER_ANSWER;
        //-- get both the questions and answers
        GFRS_Content_Translation__c[] questionsAndAnswers = [ select Id, GFRS_Content__r.Parent__r.Parent__c, GFRS_Content__c, GFRS_Content__r.Name, GFRS_Content__r.Filter__c, TextBlock__c, Language__c from GFRS_Content_Translation__c
            where 
                (GFRS_Content__r.Filter__c = :questionFilter and GFRS_Content__r.Parent__c = :questionParent) or
                ( GFRS_Content__r.Parent__r.Filter__c = :questionFilter and GFRS_Content__r.Parent__r.Parent__c = :questionParent )
            order by GFRS_Content__r.Filter__c, GFRS_Content__r.Name
        ];
        
        //-- reset the answers
        this.contentAnswers = new GFRS_Content_Translation__c[]{};
        
        System.debug( 'questionsAndAnswers:' + questionsAndAnswers );
        
        //-- for simplicity, assume there won't be thousands of responses
        for( GFRS_Content_Translation__c translation : questionsAndAnswers ){
            if( translation.GFRS_Content__r.Filter__c == questionFilter ){
                this.contentQuestion = translation;
            } else if( translation.GFRS_Content__r.Filter__c == answerFilter ){
                this.contentAnswers.add( translation );
            }
        }
        
        this.answerMap = new Map<id,GFRS_Content_Translation__c>( this.contentAnswers );
    }
    
    public SelectOption[] answerOptions {
        get {
            SelectOption[] options = new SelectOption[]{};
            
            for( GFRS_Content_Translation__c translation : this.contentAnswers ){
              if(translation.TextBlock__c != 'Donation to a Co-pay Assistance Foundation' && translation.TextBlock__c != 'Copay')
                options.add( new SelectOption( translation.id, translation.TextBlock__c ));
            }
            
            if( options.size() < 1 ){
                return( null );
            } else {
                return( options );
            }
        }
    }
    
     public SelectOption[] answerOptionscopay {
        get {
            SelectOption[] options = new SelectOption[]{};
            
            for( GFRS_Content_Translation__c translation : this.contentAnswers ){
            system.debug(translation +'===');
                if(translation.TextBlock__c == 'Donation to a Co-pay Assistance Foundation')
                options.add( new SelectOption( translation.id, translation.TextBlock__c ));
            }
            
            if( options.size() < 1 ){
                return( null );
            } else {
                return( options );
            }
        }
    }
    
    //-- getters / setters
    
    /**
     *  The id of the selected answer
     **/
    public Id selectedAnswerId {
        get {
            if( this.selectedAnswer != null ){
                return( this.selectedAnswer.id );
            } else {
                return( null );
            }
        }
        
        set {
            //System.debug( 'answerMap:' + this.answerMap );
            if( this.answerMap.containsKey( value )){
                this.selectedAnswer = this.answerMap.get( value );
            } else {
                this.selectedAnswer = null;
            }
        }
    }
}