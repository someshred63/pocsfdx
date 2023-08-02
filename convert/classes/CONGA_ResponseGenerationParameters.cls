public class CONGA_ResponseGenerationParameters{
        private String inputToken; 
        public  String outputToken;  
        public  Datetime inputTokenDateTime; 
    
        public CONGA_ResponseGenerationParameters(String inputToken){
            this.inputToken = inputToken; 
            this.outputToken = CONGA_Utils.encodeToTokenInBase64(Datetime.now().getTime(), firstSync() ? true : false);
            if (!firstSync()){
                String[] timestampAndToken = EncodingUtil.base64Decode(inputToken).toString().split(';');
                System.assertEquals(2, timestampAndToken.size(), 'wrong number of subtokens delimeted by ; in input string:' + inputToken); 
                this.inputTokenDateTime = Datetime.newInstance(Long.valueOf(timestampAndToken[0]));
                this.secondSync = Boolean.valueOf(timestampAndToken[1]);
            }   
        }
        
        public Boolean firstSync() {return this.inputToken == null || this.inputToken == ''; }
        public Boolean secondSync{public get;  private set; }
        public Boolean deltaSync{public get{ return(!firstSync() && !secondSync);}  }
}