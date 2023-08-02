public class gFRS_LOA_Revision_DocumentPDF {
    
    public static void InsertDocument(String mySourceId ,LOA_Revision_Document__mdt loareviseInfo, String section1){
        Boolean Addendum=false;
        
        
        gFRS_Ltng_Application__c gfrsApp=[Select Id,Name,Owner_Full_Name__c,First_Name__c,Last_Name__c,Cara_Signature__c,Event_Program_Title__c,RecordType.Name,Organization__r.Organization_Name__c,Organization__r.City__c,Requested_Amount__c,Owner.Name
                                          ,Approved_Amount__c,Email_Address__c,Organization__r.Street__c,Organization__r.State__c,Organization__r.Zip_Code__c,Record_Type__c,
                                          Accountable_Employee_Role__c,Internal_Organization_Area__c,Benefits_Exchanged_for_Internal_Funding__c,Authorized_Signer__r.Name,DraftLOA__c,
                                          Program_Venue_City__c From gFRS_Ltng_Application__c Where Id=:mySourceId];
        
        list < LOAdocumentInfo__mdt > loaInfo = [SELECT Label,Paragraph1__c,Paragraph2__c,Paragraph3__c,Paragraph4__c,Paragraph5__c,Paragraph6__c,Paragraph7__c,Paragraph8__c,Paragraph9__c,Paragraph10__c,Paragraph11__c,Paragraph12__c,Paragraph13__c,Paragraph14__c,Paragraph15__c,
                                                 Paragraph16__c,Paragraph17__c,Paragraph18__c,Paragraph19__c,Paragraph20__c,Paragraph21__c,Paragraph22__c,Paragraph23__c,Paragraph24__c,Paragraph25__c,Paragraph26__c,Paragraph27__c,Paragraph28__c,Paragraph29__c,Paragraph30__c,
                                                 Paragraph31__c,Paragraph32__c,Paragraph33__c,Paragraph34__c,Paragraph35__c,Paragraph36__c,Paragraph37__c,Paragraph38__c,Paragraph39__c,Paragraph40__c,Paragraph41__c,Paragraph42__c,Paragraph43__c,Paragraph44__c,Paragraph45__c,
                                                 Paragraph46__c,Paragraph47__c,Paragraph48__c,Paragraph49__c,Paragraph50__c,Paragraph51__c,Paragraph52__c,Paragraph53__c,Paragraph54__c,Paragraphs__c,Addendum_Paragraph1__c,Addendum_Paragraph2__c,Addendum_Paragraph3__c,Addendum_Paragraph4__c,Addendum_Paragraph5__c,Payment__c,Independence__c  FROM LOAdocumentInfo__mdt where Label='Internal Funding Types' limit 1];
        
        List<gFRS_Ltng_Program__c> gfrsPrglst=[Select id, name,gFRS_Program_Type__c,gFRS_Start_Date__c,gFRS_End_Date__c,gFRS_Funding_type__c,gFRS_Venue_City__c From gFRS_Ltng_Program__c Where gFRS_Application__c=:mySourceId];
        
        String approvedAmount = '';
        if(gfrsApp.Approved_Amount__c != null){
            Decimal amount = gfrsApp.Approved_Amount__c;
            approvedAmount = amount.format().contains('.')?amount.format():(amount.format()+'.00');
                }
        
        Map<String, Schema.SObjectType> programMap = Schema.getGlobalDescribe();
        Schema.SObjectType prgSchema = programMap.get('gFRS_Ltng_Program__c');
        Map<String, Schema.SObjectField> prgMap = prgSchema.getDescribe().fields.getMap();
        
        DateTime todaysDate = System.today();
        String todaysDateStr = todaysDate.format('yyyy-MM-dd');
        if(section1.contains('Introduction1') && loareviseInfo.Alternative_Paragrap40__c!=null){           
            loaInfo[0].Payment__c = loareviseInfo.Alternative_Paragrap40__c;
        }else if(section1.contains('Introduction1') && loareviseInfo.Alternative_Paragrap40__c==null ){
            loaInfo[0].Payment__c = '';
        }if(section1.contains('Introduction2') && loareviseInfo.Alternative_Paragrap41__c!=null){           
            loaInfo[0].Independence__c = loareviseInfo.Alternative_Paragrap41__c;
        }else if(section1.contains('Introduction2') && loareviseInfo.Alternative_Paragrap41__c==null ){
            loaInfo[0].Independence__c = '';
        }
        if(section1.contains('Paragraph01') && loareviseInfo.Alternative_Paragrap1__c!=null){           
            loaInfo[0].Paragraph1__c = loareviseInfo.Alternative_Paragrap1__c;
        }else if(section1.contains('Paragraph01') && loareviseInfo.Alternative_Paragrap1__c==null ){
            loaInfo[0].Paragraph1__c = '';
        }
        if(section1.contains('Paragraph02') && loareviseInfo.Alternative_Paragrap2__c!=null){
            loaInfo[0].Paragraph2__c = loareviseInfo.Alternative_Paragrap2__c;
        }else if(section1.contains('Paragraph02') && loareviseInfo.Alternative_Paragrap2__c==null ){
            loaInfo[0].Paragraph2__c = '';
        }if(section1.contains('Paragraph03') && loareviseInfo.Alternative_Paragrap3__c!=null){
            loaInfo[0].Paragraph3__c = loareviseInfo.Alternative_Paragrap3__c;
        }else if(section1.contains('Paragraph03') && loareviseInfo.Alternative_Paragrap3__c==null ){
            loaInfo[0].Paragraph3__c = '';
        }if(section1.contains('Paragraph04') && loareviseInfo.Alternative_Paragrap4__c!=null){
            loaInfo[0].Paragraph4__c = loareviseInfo.Alternative_Paragrap4__c;
        }else if(section1.contains('Paragraph04') && loareviseInfo.Alternative_Paragrap4__c==null ){
            loaInfo[0].Paragraph4__c = '';
        } if(section1.contains('Paragraph05') && loareviseInfo.Alternative_Paragrap5__c!=null){
            loaInfo[0].Paragraph5__c = loareviseInfo.Alternative_Paragrap5__c;
        }else if(section1.contains('Paragraph05') && loareviseInfo.Alternative_Paragrap5__c==null ){
            loaInfo[0].Paragraph5__c = '';
        } if(section1.contains('Paragraph06') && loareviseInfo.Alternative_Paragrap6__c!=null){
            loaInfo[0].Paragraph6__c = loareviseInfo.Alternative_Paragrap6__c;
        }else if(section1.contains('Paragraph06') && loareviseInfo.Alternative_Paragrap6__c==null ){
            loaInfo[0].Paragraph6__c = '';
        } if(section1.contains('Paragraph07') && loareviseInfo.Alternative_Paragrap7__c!=null){
            loaInfo[0].Paragraph7__c = loareviseInfo.Alternative_Paragrap7__c;
        }else if(section1.contains('Paragraph07') && loareviseInfo.Alternative_Paragrap7__c==null ){
            loaInfo[0].Paragraph7__c = '';
        } if(section1.contains('Paragraph08') && loareviseInfo.Alternative_Paragrap8__c!=null){
            loaInfo[0].Paragraph8__c = loareviseInfo.Alternative_Paragrap8__c;
        }else if(section1.contains('Paragraph08') && loareviseInfo.Alternative_Paragrap8__c==null ){
            loaInfo[0].Paragraph8__c = '';
        }if(section1.contains('Paragraph09') && loareviseInfo.Alternative_Paragrap9__c!=null){
            loaInfo[0].Paragraph9__c = loareviseInfo.Alternative_Paragrap9__c;
        }else if(section1.contains('Paragraph09') && loareviseInfo.Alternative_Paragrap9__c==null ){
            loaInfo[0].Paragraph9__c = '';
        }if(section1.contains('Paragraph10') && loareviseInfo.Alternative_Paragrap10__c!=null){
            loaInfo[0].Paragraph10__c = loareviseInfo.Alternative_Paragrap10__c;
        }else if(section1.contains('Paragraph10') && loareviseInfo.Alternative_Paragrap10__c==null ){
            loaInfo[0].Paragraph10__c = '';
        }if(section1.contains('Paragraph11') && loareviseInfo.Alternative_Paragrap11__c!=null){
            loaInfo[0].Paragraph11__c = loareviseInfo.Alternative_Paragrap11__c;
        }else if(section1.contains('Paragraph11') && loareviseInfo.Alternative_Paragrap11__c==null ){
            loaInfo[0].Paragraph11__c = '';
        }if(section1.contains('Paragraph12') && loareviseInfo.Alternative_Paragrap12__c!=null){
            loaInfo[0].Paragraph12__c = loareviseInfo.Alternative_Paragrap12__c;
        }else if(section1.contains('Paragraph12') && loareviseInfo.Alternative_Paragrap12__c==null ){
            loaInfo[0].Paragraph12__c = '';
        }if(section1.contains('Paragraph13') && loareviseInfo.Alternative_Paragrap13__c!=null){
            loaInfo[0].Paragraph13__c = loareviseInfo.Alternative_Paragrap13__c;
        }else if(section1.contains('Paragraph13') && loareviseInfo.Alternative_Paragrap13__c==null ){
            loaInfo[0].Paragraph13__c = '';
        } if(section1.contains('Paragraph14') && loareviseInfo.Alternative_Paragrap14__c!=null){
            loaInfo[0].Paragraph14__c = loareviseInfo.Alternative_Paragrap14__c;
        }else if(section1.contains('Paragraph14') && loareviseInfo.Alternative_Paragrap14__c==null ){
            loaInfo[0].Paragraph14__c = '';
        }if(section1.contains('Paragraph15') && loareviseInfo.Alternative_Paragrap15__c!=null){
            loaInfo[0].Paragraph15__c = loareviseInfo.Alternative_Paragrap15__c;
        }else if(section1.contains('Paragraph15') && loareviseInfo.Alternative_Paragrap15__c==null ){
            loaInfo[0].Paragraph15__c = '';
        }if(section1.contains('Paragraph16') && loareviseInfo.Alternative_Paragrap16__c!=null){
            loaInfo[0].Paragraph16__c = loareviseInfo.Alternative_Paragrap16__c;
        }else if(section1.contains('Paragraph16') && loareviseInfo.Alternative_Paragrap16__c==null ){
            loaInfo[0].Paragraph16__c = '';
        }if(section1.contains('Paragraph17') && loareviseInfo.Alternative_Paragrap17__c!=null){
            loaInfo[0].Paragraph17__c = loareviseInfo.Alternative_Paragrap17__c;
        }else if(section1.contains('Paragraph17') && loareviseInfo.Alternative_Paragrap17__c==null ){
            loaInfo[0].Paragraph17__c = '';
        }if(section1.contains('Paragraph18') && loareviseInfo.Alternative_Paragrap18__c!=null){
            loaInfo[0].Paragraph18__c = loareviseInfo.Alternative_Paragrap18__c;
        }else if(section1.contains('Paragraph18') && loareviseInfo.Alternative_Paragrap18__c==null ){
            loaInfo[0].Paragraph18__c = '';
        }if(section1.contains('Paragraph19') && loareviseInfo.Alternative_Paragrap19__c!=null){
            loaInfo[0].Paragraph19__c = loareviseInfo.Alternative_Paragrap19__c;
        }else if(section1.contains('Paragraph19') && loareviseInfo.Alternative_Paragrap19__c==null ){
            loaInfo[0].Paragraph19__c = '';
        }if(section1.contains('Paragraph20') && loareviseInfo.Alternative_Paragrap20__c!=null){
            loaInfo[0].Paragraph20__c = loareviseInfo.Alternative_Paragrap20__c;
        }else if(section1.contains('Paragraph20') && loareviseInfo.Alternative_Paragrap20__c==null ){
            loaInfo[0].Paragraph20__c = '';
        }if(section1.contains('Paragraph21') && loareviseInfo.Alternative_Paragrap21__c!=null){
            loaInfo[0].Paragraph21__c = loareviseInfo.Alternative_Paragrap21__c;
        }else if(section1.contains('Paragraph21') && loareviseInfo.Alternative_Paragrap21__c==null ){
            loaInfo[0].Paragraph21__c = '';
        }if(section1.contains('Paragraph22') && loareviseInfo.Alternative_Paragrap22__c!=null){
            loaInfo[0].Paragraph22__c = loareviseInfo.Alternative_Paragrap22__c;
        }else if(section1.contains('Paragraph22') && loareviseInfo.Alternative_Paragrap22__c==null ){
            loaInfo[0].Paragraph22__c = '';
        }if(section1.contains('Paragraph23') && loareviseInfo.Alternative_Paragrap23__c!=null){
            loaInfo[0].Paragraph23__c = loareviseInfo.Alternative_Paragrap23__c;
        }else if(section1.contains('Paragraph23') && loareviseInfo.Alternative_Paragrap23__c==null ){
            loaInfo[0].Paragraph23__c = '';
        }if(section1.contains('Paragraph24') && loareviseInfo.Alternative_Paragrap24__c!=null){
            loaInfo[0].Paragraph24__c = loareviseInfo.Alternative_Paragrap24__c;
        }else if(section1.contains('Paragraph24') && loareviseInfo.Alternative_Paragrap24__c==null ){
            loaInfo[0].Paragraph24__c = '';
        }if(section1.contains('Paragraph25') && loareviseInfo.Alternative_Paragrap25__c!=null){
            loaInfo[0].Paragraph25__c = loareviseInfo.Alternative_Paragrap25__c;
        }else if(section1.contains('Paragraph25') && loareviseInfo.Alternative_Paragrap25__c==null ){
            loaInfo[0].Paragraph25__c = '';
        }if(section1.contains('Paragraph26') && loareviseInfo.Alternative_Paragrap26__c!=null){
            loaInfo[0].Paragraph26__c = loareviseInfo.Alternative_Paragrap26__c;
        }else if(section1.contains('Paragraph26') && loareviseInfo.Alternative_Paragrap26__c==null ){
            loaInfo[0].Paragraph26__c = '';
        }if(section1.contains('Paragraph27') && loareviseInfo.Alternative_Paragrap27__c!=null){
            loaInfo[0].Paragraph27__c = loareviseInfo.Alternative_Paragrap27__c;
        }else if(section1.contains('Paragraph27') && loareviseInfo.Alternative_Paragrap27__c==null ){
            loaInfo[0].Paragraph27__c = '';
        }if(section1.contains('Paragraph28') && loareviseInfo.Alternative_Paragrap28__c!=null){
            loaInfo[0].Paragraph28__c = loareviseInfo.Alternative_Paragrap28__c;
        }else if(section1.contains('Paragraph28') && loareviseInfo.Alternative_Paragrap28__c==null ){
            loaInfo[0].Paragraph28__c = '';
        }if(section1.contains('Paragraph29') && loareviseInfo.Alternative_Paragrap29__c!=null){
            loaInfo[0].Paragraph29__c = loareviseInfo.Alternative_Paragrap29__c;
        }else if(section1.contains('Paragraph29') && loareviseInfo.Alternative_Paragrap29__c==null ){
            loaInfo[0].Paragraph29__c = '';
        }if(section1.contains('Paragraph30') && loareviseInfo.Alternative_Paragrap30__c!=null){
            loaInfo[0].Paragraph30__c = loareviseInfo.Alternative_Paragrap30__c;
        }else if(section1.contains('Paragraph30') && loareviseInfo.Alternative_Paragrap30__c==null ){
            loaInfo[0].Paragraph30__c = '';
        }if(section1.contains('Paragraph31') && loareviseInfo.Alternative_Paragrap31__c!=null){
            loaInfo[0].Paragraph31__c = loareviseInfo.Alternative_Paragrap31__c;
        }else if(section1.contains('Paragraph31') && loareviseInfo.Alternative_Paragrap31__c==null ){
            loaInfo[0].Paragraph31__c = '';
        }if(section1.contains('Paragraph32') && loareviseInfo.Alternative_Paragrap32__c!=null){
            loaInfo[0].Paragraph32__c = loareviseInfo.Alternative_Paragrap32__c;
        }else if(section1.contains('Paragraph32') && loareviseInfo.Alternative_Paragrap32__c==null ){
            loaInfo[0].Paragraph32__c = '';
        }if(section1.contains('Paragraph33') && loareviseInfo.Alternative_Paragrap33__c!=null){
            loaInfo[0].Paragraph33__c = loareviseInfo.Alternative_Paragrap33__c;
        }else if(section1.contains('Paragraph33') && loareviseInfo.Alternative_Paragrap33__c==null ){
            loaInfo[0].Paragraph33__c = '';
        }if(section1.contains('Paragraph34') && loareviseInfo.Alternative_Paragrap34__c!=null){
            loaInfo[0].Paragraph34__c = loareviseInfo.Alternative_Paragrap34__c;
        }else if(section1.contains('Paragraph34') && loareviseInfo.Alternative_Paragrap34__c==null ){
            loaInfo[0].Paragraph34__c = '';
        }if(section1.contains('Paragraph35') && loareviseInfo.Alternative_Paragrap35__c!=null){
            loaInfo[0].Paragraph35__c = loareviseInfo.Alternative_Paragrap35__c;
        }else if(section1.contains('Paragraph35') && loareviseInfo.Alternative_Paragrap35__c==null ){
            loaInfo[0].Paragraph35__c = '';
        }if(section1.contains('Paragraph36') && loareviseInfo.Alternative_Paragrap36__c!=null){
            loaInfo[0].Paragraph36__c = loareviseInfo.Alternative_Paragrap36__c;
        }else if(section1.contains('Paragraph36') && loareviseInfo.Alternative_Paragrap36__c==null ){
            loaInfo[0].Paragraph36__c = '';
        }if(section1.contains('Paragraph37') && loareviseInfo.Alternative_Paragrap37__c!=null){
            loaInfo[0].Paragraph37__c = loareviseInfo.Alternative_Paragrap37__c;
        }else if(section1.contains('Paragraph37') && loareviseInfo.Alternative_Paragrap37__c==null ){
            loaInfo[0].Paragraph37__c = '';
        }if(section1.contains('Paragraph38') && loareviseInfo.Alternative_Paragrap38__c!=null){
            loaInfo[0].Paragraph38__c = loareviseInfo.Alternative_Paragrap38__c;
        }else if(section1.contains('Paragraph38') && loareviseInfo.Alternative_Paragrap38__c==null ){
            loaInfo[0].Paragraph38__c = '';
        }if(section1.contains('Paragraph39') && loareviseInfo.Alternative_Paragrap39__c!=null){
            loaInfo[0].Paragraph39__c = loareviseInfo.Alternative_Paragrap39__c;
        }else if(section1.contains('Paragraph39') && loareviseInfo.Alternative_Paragrap39__c==null ){
            loaInfo[0].Paragraph39__c = '';
        }if(section1.contains('Paragraph40') && loareviseInfo.Alternative_Paragrap40__c!=null){
            loaInfo[0].Paragraph40__c = loareviseInfo.Alternative_Paragrap40__c;
        }else if(section1.contains('Paragraph40') && loareviseInfo.Alternative_Paragrap40__c==null ){
            loaInfo[0].Paragraph40__c = '';
        }if(section1.contains('Paragraph41') && loareviseInfo.Alternative_Paragrap41__c!=null){
            loaInfo[0].Paragraph41__c = loareviseInfo.Alternative_Paragrap41__c;
        }else if(section1.contains('Paragraph41') && loareviseInfo.Alternative_Paragrap41__c==null ){
            loaInfo[0].Paragraph41__c = '';
        }if(section1.contains('Paragraph42') && loareviseInfo.Alternative_Paragrap42__c!=null){
            loaInfo[0].Paragraph42__c = loareviseInfo.Alternative_Paragrap42__c;
        }else if(section1.contains('Paragraph42') && loareviseInfo.Alternative_Paragrap42__c==null ){
            loaInfo[0].Paragraph42__c = '';
        }if(section1.contains('Paragraph43') && loareviseInfo.Alternative_Paragrap43__c!=null){
            loaInfo[0].Paragraph43__c = loareviseInfo.Alternative_Paragrap43__c;
        }else if(section1.contains('Paragraph43') && loareviseInfo.Alternative_Paragrap43__c==null ){
            loaInfo[0].Paragraph43__c = '';
        }if(section1.contains('Paragraph44') && loareviseInfo.Alternative_Paragrap44__c!=null){
            loaInfo[0].Paragraph44__c = loareviseInfo.Alternative_Paragrap44__c;
        }else if(section1.contains('Paragraph44') && loareviseInfo.Alternative_Paragrap44__c==null ){
            loaInfo[0].Paragraph44__c = '';
        }if(section1.contains('Paragraph45') && loareviseInfo.Alternative_Paragrap45__c!=null){
            loaInfo[0].Paragraph45__c = loareviseInfo.Alternative_Paragrap45__c;
        }else if(section1.contains('Paragraph45') && loareviseInfo.Alternative_Paragrap45__c==null ){
            loaInfo[0].Paragraph45__c = '';
        }if(section1.contains('Paragraph46') && loareviseInfo.Alternative_Paragrap46__c!=null){
            loaInfo[0].Paragraph46__c = loareviseInfo.Alternative_Paragrap46__c;
        }else if(section1.contains('Paragraph46') && loareviseInfo.Alternative_Paragrap46__c==null ){
            loaInfo[0].Paragraph46__c = '';
        }if(section1.contains('Paragraph47') && loareviseInfo.Alternative_Paragrap47__c!=null){
            loaInfo[0].Paragraph47__c = loareviseInfo.Alternative_Paragrap47__c;
        }else if(section1.contains('Paragraph47') && loareviseInfo.Alternative_Paragrap47__c==null ){
            loaInfo[0].Paragraph47__c = '';
        }if(section1.contains('Paragraph48') && loareviseInfo.Alternative_Paragrap48__c!=null){
            loaInfo[0].Paragraph48__c = loareviseInfo.Alternative_Paragrap48__c;
        }else if(section1.contains('Paragraph48') && loareviseInfo.Alternative_Paragrap48__c==null ){
            loaInfo[0].Paragraph48__c = '';
        }if(section1.contains('Paragraph49') && loareviseInfo.Alternative_Paragrap49__c!=null){
            loaInfo[0].Paragraph49__c = loareviseInfo.Alternative_Paragrap49__c;
        }else if(section1.contains('Paragraph49') && loareviseInfo.Alternative_Paragrap49__c==null ){
            loaInfo[0].Paragraph49__c = '';
        }if(section1.contains('Paragraph50') && loareviseInfo.Alternative_Paragrap50__c!=null){
            loaInfo[0].Paragraph50__c = loareviseInfo.Alternative_Paragrap50__c;
        }else if(section1.contains('Paragraph50') && loareviseInfo.Alternative_Paragrap50__c==null ){
            loaInfo[0].Paragraph50__c = '';
        }if(section1.contains('Paragraph51') && loareviseInfo.Alternative_Paragrap51__c!=null){
            loaInfo[0].Paragraph51__c = loareviseInfo.Alternative_Paragrap51__c;
        }else if(section1.contains('Paragraph51') && loareviseInfo.Alternative_Paragrap51__c==null ){
            loaInfo[0].Paragraph51__c = '';
        }if(section1.contains('Paragraph52') && loareviseInfo.Alternative_Paragrap52__c!=null){
            loaInfo[0].Paragraph52__c = loareviseInfo.Alternative_Paragrap52__c;
        }else if(section1.contains('Paragraph52') && loareviseInfo.Alternative_Paragrap52__c==null ){
            loaInfo[0].Paragraph52__c = '';
        }if(section1.contains('Paragraph53') && loareviseInfo.Alternative_Paragrap53__c!=null){
            loaInfo[0].Paragraph53__c = loareviseInfo.Alternative_Paragrap53__c;
        }else if(section1.contains('Paragraph53') && loareviseInfo.Alternative_Paragrap53__c==null ){
            loaInfo[0].Paragraph53__c = '';
        }if(section1.contains('Paragraph54') && loareviseInfo.Alternative_Paragrap54__c!=null){
            loaInfo[0].Paragraph54__c = loareviseInfo.Alternative_Paragrap54__c;
        }else if(section1.contains('Paragraph54') && loareviseInfo.Alternative_Paragrap54__c==null ){
            loaInfo[0].Paragraph54__c = '';
        }if(section1.contains('Section1') && loareviseInfo.Addendum_Paragraph1__c!=null){
            loaInfo[0].Addendum_Paragraph1__c = loareviseInfo.Addendum_Paragraph1__c;
             Addendum=true;
        }else if(section1.contains('Section1') && loareviseInfo.Addendum_Paragraph1__c==null ){
            loaInfo[0].Addendum_Paragraph1__c = '';
        }else if(!section1.contains('Section1')){
            loaInfo[0].Addendum_Paragraph1__c = '';
        }if(section1.contains('Section2') && loareviseInfo.Addendum_Paragraph2__c!=null){
            loaInfo[0].Addendum_Paragraph2__c = loareviseInfo.Addendum_Paragraph2__c;
            Addendum=true;
        }else if(section1.contains('Section2') && loareviseInfo.Addendum_Paragraph2__c==null ){
            loaInfo[0].Addendum_Paragraph2__c = '';
        }else if(!section1.contains('Section2')){
            loaInfo[0].Addendum_Paragraph2__c = '';
        }if(section1.contains('Section3') && loareviseInfo.Addendum_Paragraph3__c!=null){
            loaInfo[0].Addendum_Paragraph3__c = loareviseInfo.Addendum_Paragraph3__c;
            Addendum=true;
        }else if(section1.contains('Section3') && loareviseInfo.Addendum_Paragraph3__c==null ){
            loaInfo[0].Addendum_Paragraph3__c = '';
        }else if(!section1.contains('Section3')){
            loaInfo[0].Addendum_Paragraph3__c = '';
        }if(section1.contains('Section4') && loareviseInfo.Addendum_Paragraph4__c!=null){
            loaInfo[0].Addendum_Paragraph4__c = loareviseInfo.Addendum_Paragraph4__c;
            Addendum=true;
        }else if(section1.contains('Section4') && loareviseInfo.Addendum_Paragraph4__c==null ){
            loaInfo[0].Addendum_Paragraph4__c = '';
        }else if(!section1.contains('Section4')){
            loaInfo[0].Addendum_Paragraph4__c = '';
        }if(section1.contains('Section5') && loareviseInfo.Addendum_Paragraph5__c!=null){
            loaInfo[0].Addendum_Paragraph5__c = loareviseInfo.Addendum_Paragraph5__c;
            Addendum=true;
        }else if(section1.contains('Section5') && loareviseInfo.Addendum_Paragraph5__c==null ){
            loaInfo[0].Addendum_Paragraph5__c = '';
        }else if(!section1.contains('Section5')){
            loaInfo[0].Addendum_Paragraph5__c = '';
        }
        
        String FORM_HTML_START = '<HTML><BODY>';
        String FORM_HTML_BODY_HEADER='<div>'+            
            '<div style="color:#1e3e63;">'+
            '<h4 style="text-align: center; color: #005A95;font-size: 14px; font-weight: bold;">Letter of Agreement ("LOA")</h4>'+
            '</div>'+
            '<BR>'+
            '<div>';
        if(!section1.contains('Introduction1')){
          FORM_HTML_BODY_HEADER=FORM_HTML_BODY_HEADER+'<p style="color:#1e3e63;font-size: 12px;">This LOA will outline the Terms, Conditions and Purposes of the funding provided by Genentech USA, Inc. ("Genentech") to '+' '+gfrsApp.Organization__r.Organization_Name__c+' '+'("Recipient").</P>'+
            '<BR>'+
            '<p style="color:#1e3e63;font-size: 12px;">';
        }else{
            FORM_HTML_BODY_HEADER=FORM_HTML_BODY_HEADER+'<p style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Payment__c+'</P>'+
            '<BR>'+
            '<p style="color:#1e3e63;font-size: 12px;">';
        }
        FORM_HTML_BODY_HEADER = FORM_HTML_BODY_HEADER +
            
            '<SPAN>Address:</SPAN><SPAN> '+gfrsApp.Organization__r.Street__c+'</span><br/>'+
            '<SPAN>City: </SPAN><SPAN>'+gfrsApp.Organization__r.City__c+'</span><br/>'+
            '<SPAN>State: </SPAN><SPAN>'+gfrsApp.Organization__r.State__c+'</span><br/>'+
            '<span>Zip Code: </SPAN><SPAN>'+gfrsApp.Organization__r.Zip_Code__c+'</span><br/>'+
            '</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+
            '<span>Funding Type: </span><span> '+gfrsApp.Record_Type__c+' </span>'+'(“Funding Type”)'+'<br/>'+
            '<span>Program / Event /Membership Title: </span><span> '+gfrsApp.Event_Program_Title__c+' </span>'+'(the “Program”)'+'<br/>'+
            '<span>Request ID: </span><span> '+gfrsApp.Name +' </span><br/>'+
            
            //'<span>Program Start Date(s): </span><span> '+gfrsPrglst.gFRS_Start_Date__c.format() +' </span><br/>'+
            '</P>'+
            '</div>'+
            '<BR>'+
            '<div style="color:#1e3e63;font-size: 12px;">'+
            '<table style="border: 1px solid #1e3e63;">'+
            '<tr style="border: 1px solid black;font-weight: bold;">'+
            '<th style="border: 1px solid #000000;">'+prgMap.get('name').getDescribe().getLabel()+'</th>'+
            '<th style="border: 1px solid #000000;">'+prgMap.get('gFRS_Program_Type__c').getDescribe().getLabel()+'</th>'+
            '<th style="border: 1px solid #000000;">'+prgMap.get('gFRS_Start_Date__c').getDescribe().getLabel()+'</th>'+
            '<th style="border: 1px solid #000000;">'+prgMap.get('gFRS_End_Date__c').getDescribe().getLabel()+'</th>'+
            '</tr>';
        String statedata;
        Integer i=1;
        String Start_Date ='';
        String End_Date ='';
        for(gFRS_Ltng_Program__c gfrsProgram:gfrsPrglst){
            if(gfrsProgram.gFRS_Start_Date__c != NULL){
                Start_Date = gfrsProgram.gFRS_Start_Date__c.format();
            }
            if(gfrsProgram.gFRS_End_Date__c != NULL){
                End_Date = gfrsProgram.gFRS_End_Date__c.format();
            }
            statedata=statedata+
                '<tr style="border: 1px solid black;">'+
                '<td>'+gfrsProgram.name+'</td>'+
                '<td>'+gfrsProgram.gFRS_Program_Type__c+'</td>'+
                '<td>'+Start_Date+'</td>'+
                '<td>'+End_Date+'</td>'+
                '</tr>';
            i=i+1;
        }
        FORM_HTML_BODY_HEADER=FORM_HTML_BODY_HEADER+statedata+'</table>'+
            '</div>';
       String FORM_HTML_BODY=
            '<div>'+
            '<BR>'; 
        if(!section1.contains('Introduction2')){
            FORM_HTML_BODY=FORM_HTML_BODY+
                '<P style="color:#1e3e63;font-size: 12px;">Genentech wishes to provide funding in the amount of $'+approvedAmount+'(hereafter, the “Request Payment”). '+
                'for the Funding Type related to the above'+
                'referenced Program. By accepting the Request Payment, Recipient agrees to use the'+
                'funds solely in connection with the above Program and to comply with the terms and'+
                'conditions of this LOA. By accepting the Request Payment, Recipient certifies and'+
                'agrees to comply with the terms and conditions of this LOA.</P>';
        }else{
            FORM_HTML_BODY=FORM_HTML_BODY+
                '<p style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Independence__c+'</P>'+
                '<BR>'+
                '<p style="color:#1e3e63;font-size: 12px;">';
        }      
    
         FORM_HTML_BODY=FORM_HTML_BODY+'<div>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph1__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph2__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph3__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph4__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph5__c+'</P>'+
            '<BR>'+
            '</div>'+
            '<h4 style="color: #005A95;font-size: 12px; font-weight: bold;padding-bottom: 12px;"><span>I. </span> Disclosures and Acknowledgement of Support </h4>'+'<BR>'+
            '<div>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph6__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph7__c+'</P>'+
            '<BR>'+
            '</div>'+
            
            '<p><H4 style="color: #005A95;font-size: 12px; font-weight: bold;padding-bottom: 12px;"><span>II. </span> Use of the Genentech Logo</H4>'+'<BR>'+
            '</p>'+    
            '<div>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph8__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph9__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span>A.</span><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>'+loaInfo[0].Paragraph10__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span>B.</span><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>'+loaInfo[0].Paragraph11__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span>C.</span><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>'+loaInfo[0].Paragraph12__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span>D.</span><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>'+loaInfo[0].Paragraph13__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span>E.</span><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>'+loaInfo[0].Paragraph14__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;"><span>F.</span><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>'+loaInfo[0].Paragraph15__c+'</P>'+
            '<BR>'+    
            '<P style="color:#1e3e63;font-size: 12px;"><span>G.</span><span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span>'+loaInfo[0].Paragraph16__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph17__c+'</P>'+
            '<BR>'+
            '</div>'+
            
            '<p><H4 style="color: #005A95;font-size: 12px; font-weight: bold;padding-bottom: 12px;"><span>III. </span> Other </H4>'+'<BR>'+
            '</p>'+    
            '<div>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph18__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph19__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph20__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph21__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph22__c+'</P>'+
            '<BR>'+
            '</div>'+
            '<p><H4 style="color: #005A95;font-size: 12px; font-weight: bold;padding-bottom: 12px;"><span>IV. </span> Payment</H4>'+'<BR>'+
            '</p>'+    
            '<div>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph23__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph24__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph25__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph26__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Paragraph27__c+'</P>'+
            '<BR>'+
            '</div>'+
            '</li>'+
            '</ol>'+
            '</div>'+
            '<div>';
        
        if(gfrsApp.RecordType.Name == 'Field exhibits' || (gfrsApp.RecordType.Name == 'Commercial Sponsorship' && gfrsApp.Accountable_Employee_Role__c == 'Home Office' && gfrsApp.Benefits_Exchanged_for_Internal_Funding__c == 'Exhibit Only' && gfrsApp.Approved_Amount__c <= 25000) || (gFRSApp.RecordType.Name == 'Non-Commercial Sponsorship' && gFRSApp.Accountable_Employee_Role__c == 'Home Office' && gFRSApp.Benefits_Exchanged_for_Internal_Funding__c == 'Exhibit Only' && gFRSApp.Approved_Amount__c <= 25000)){
            // Nothing to do
            FORM_HTML_BODY_HEADER = FORM_HTML_BODY_HEADER +
                '<div>'+
                '<BR>'+
                '<P style="color:#1e3e63;font-size: 12px;">Genentech wishes to provide funding in the amount of $'+approvedAmount+' (hereafter, the “Request Payment”) for the Funding Type related to the above referenced Program.'+
                'By accepting the Request Payment, Recipient certifies and agrees to comply with the terms and conditions of this LOA.</P>'+
                '<BR>'+
                '</div>';
        } else {
            FORM_HTML_BODY_HEADER = FORM_HTML_BODY_HEADER +
                '<div>'+
                '<BR>'+
                '<P style="color:#1e3e63;font-size: 12px;">Genentech wishes to provide funding in the amount of $'+approvedAmount+' (hereafter, the “Request Payment”) for the Funding Type related to the above referenced Program.'+
                'By accepting the Request Payment, Recipient agrees to use the funds solely in connection with the above Program and to comply with the terms and conditions of this LOA.</P>'+
                '<BR>'+
                '</div>';
            FORM_HTML_BODY = FORM_HTML_BODY +
                '<h4 style="color: #005A95;font-size: 14px; font-weight: bold;padding-bottom: 12px;">Approved:</h4>'+
                '<BR>'+
                '<p style="color:#1e3e63;font-size: 12px;">GENENTECH USA, INC.</p>'+'<BR>'+
                '<p style="color:#1e3e63;font-size: 12px;">By</p>'+'<BR>'+
                '<p>'+gfrsApp.Cara_Signature__c+'</p>'+
                '<p style="color:#1e3e63;font-size: 12px;"><span>Name: </span><span>Cara Pellegrini </span></p>'+
                '<p style="color:#1e3e63;font-size: 12px;"><span>Title: </span><span>VP, Experience Operations</span></p>'+
                '<p style="color:#1e3e63;font-size: 12px;"><span>Date/Time: '+todaysDateStr+'</span><span> </span></p>'+
                '<BR>'+
                '<p style="color:#1e3e63;font-size: 12px;">I hereby acknowledge and agree with the terms and conditions set forth in this Agreement and represent and '+
                'warrant that I have authority to sign on behalf of '+gfrsApp.Organization__r.Organization_Name__c+'("Recipient").</p>'+
                '<BR>'+
                '<p style="color:#1e3e63;font-size: 12px;">By:</P>'+
                '<p style="color:#1e3e63;font-size: 12px;"><span>Name: </span><span></span></p>'+
                '<p style="color:#1e3e63;font-size: 12px;"><span>Date/Time: </span><span> </span></p>'+
                //'<p style="color:#1e3e63;font-size: 12px;"><span>IP Address: </span><span> </span></p>'+
                '</div>'+
                '</div>';
        }
        if(Addendum){
            FORM_HTML_BODY=FORM_HTML_BODY+
                '<BR>'+
                '<BR>'+
                '<p><H4 style="color: #005A95;font-size: 12px; font-weight: bold;padding-bottom: 12px;text-align: center;">Addendum</H4>'+'<BR>'+
                '</p>';
        }
        FORM_HTML_BODY=FORM_HTML_BODY+'<div>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Addendum_Paragraph1__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Addendum_Paragraph2__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Addendum_Paragraph3__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Addendum_Paragraph4__c+'</P>'+
            '<BR>'+
            '<P style="color:#1e3e63;font-size: 12px;">'+loaInfo[0].Addendum_Paragraph5__c+'</P>'+
            '<BR>'+
            '</div>';
        
        String FORM_HTML_END = '</BODY></HTML>';
        
        String pdfContent=FORM_HTML_START+FORM_HTML_BODY_HEADER+FORM_HTML_BODY+FORM_HTML_END;
        Attachment attachmentPDF = new Attachment(); 
        attachmentPDF.OwnerId = UserInfo.getUserId();
        attachmentPDF.parentId = mySourceId;
        attachmentPDF.Name ='LOA Revisions' + '.pdf';
        attachmentPDF.body = Blob.toPDF(pdfContent); //This creates the PDF content
        insert attachmentPDF;
        
        //Insert ContentVersion
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = attachmentPDF.Name;//File name with extention
        cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = attachmentPDF.OwnerId;//Owner of the file
        cVersion.Title = attachmentPDF.Name;//Name of the file
        cVersion.VersionData = attachmentPDF.Body;//File content
        Insert cVersion;
        
        //After saved the Content Verison, get the ContentDocumentId
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        
        //Insert ContentDocumentLink
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = attachmentPDF.ParentId;//Add attachment parentId
        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
        Insert cDocLink;
        
        Delete attachmentPDF;
        gFRS_Ltng_Application__c gfrs = new gFRS_Ltng_Application__c();
        gfrs.LOA_RevisionsId__c = conDocument;
        gfrs.id = mySourceId;
        update gfrs;
        
    }
}