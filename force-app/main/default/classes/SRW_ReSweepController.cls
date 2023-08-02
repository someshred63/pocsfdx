public with sharing class SRW_ReSweepController {

	public String choosenDataMonth {get;set;}
	public String choosenForResweep {get;set;}
	public String historyDataMonth {get;set;}


	public List<SRW_ReSweep_File__c> lstHistoricDataMonths {get;set;}
	public List<ReSweepHistoryFile> lstHistoricFiles {get;set;}
	public List<SRW_Sales_Data_gne__c> saleData;

    
    private Set<String> uniqueDM = new Set<String>();
    private Set<String> uniqueTP = new Set<String>();
    private Set<String> uniqueADM = new Set<String>();
    private List<TPResweepWrapper> finalList = new List<TPResweepWrapper>();
    private Map<Id,SRW_DataMonths__c> mapDataMonths;
    private List<SRW_TP_Data_Months__c> openMonthNoSalesData;
    private String choosenForResweepName ;

	public SRW_ReSweepController() {

			lstHistoricDataMonths = [Select Id,Name,ReSweep_Date_gne__c ,Data_Month_gne__r.Data_Month_Cal_gne__c,Data_Month_gne__c,(SELECT Id, Name FROM Attachments) from SRW_ReSweep_File__c Order by ReSweep_Date_gne__c];
			
			lstHistoricFiles = new List<ReSweepHistoryFile>();
			for(SRW_ReSweep_File__c temp : lstHistoricDataMonths){

				ReSweepHistoryFile tempFile = new ReSweepHistoryFile();
					tempFile.DataMonthName = temp.Data_Month_gne__r.Data_Month_Cal_gne__c;
					tempFile.ReSweepDate = temp.ReSweep_Date_gne__c;
					if(!temp.Attachments.isEmpty()){
						tempFile.AttachmentId = temp.Attachments[0].Id;
						tempFile.AttachmentName = temp.Attachments[0].Name;
					}
				lstHistoricFiles.add(tempFile);

			}

			mapDataMonths = new Map<Id,SRW_DataMonths__c>([Select Id,
                               Name,
                               Data_Month_Cal_gne__c,
                               Sweep_Custom_Date_gne__c,
                               Sweep_Default_Date_gne__c,
                               Last_Sweep_Occurrence_Date_gne__c,
                               Sweep_Status_gne__c,
                               Real_Sweep_Date_gne__c,
                               Data_Year_gne__c,
                               Data_Month_Number_gne__c
                         from SRW_DataMonths__c
                         Order By Sweep_Default_Date_gne__c DESC]);

		    saleData = [Select Id,
		    				   Trading_Partner_gne__c,
		    				   Trading_Partner_gne__r.Trading_Partner_Name_gne__c,
		    				   TP_Data_Month_gne__r.Data_Month_Status_gne__c,
		    				   TP_Data_Month_gne__r.SRW_Data_Month_gne__c,
		    				   TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,
		    				   TP_Data_Month_gne__r.Reopen_Date_gne__c,
		    				   Sweep_Data_Month_gne__r.Data_Month_Cal_gne__c,
		    				   Sweep_Data_Month_gne__c
		    				   from SRW_Sales_Data_gne__c
		    				   where TP_Data_Month_gne__r.Data_Month_Status_gne__c = 'Resubmitted' 
		    				   	  OR TP_Data_Month_gne__r.Data_Month_Status_gne__c = 'Reopen'
		    				   	  Order By TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Sweep_Default_Date_gne__c DESC];
		    

		   openMonthNoSalesData = [Select Id,
				   						  Data_Month_Status_gne__c,
				   						  Trading_Partner_gne__c,
				   						  Trading_Partner_gne__r.Trading_Partner_Name_gne__c,
				   						  SRW_Data_Month_gne__c,
				   						  SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,
				   						  Reopen_Date_gne__c
				   						  from  SRW_TP_Data_Months__c
				   						  where Data_Month_Status_gne__c = 'Reopen'];


		    if(!saleData.isEmpty()) {
			    choosenDataMonth = saleData[0].TP_Data_Month_gne__r.SRW_Data_Month_gne__c;
			    choosenForResweep =  saleData[0].Sweep_Data_Month_gne__c;
			    choosenForResweepName = saleData[0].Sweep_Data_Month_gne__r.Data_Month_Cal_gne__c;
    	    }
    	    else if(!openMonthNoSalesData.isEmpty()) {
			    choosenDataMonth = openMonthNoSalesData[0].SRW_Data_Month_gne__c;
			    choosenForResweep =  openMonthNoSalesData[0].SRW_Data_Month_gne__c;
			    choosenForResweepName = openMonthNoSalesData[0].SRW_Data_Month_gne__r.Data_Month_Cal_gne__c;
    	    }

		    calculateTableRows();
	}

   	@RemoteAction
  	public static String checkReSweepStatus(String reSweepMonthId){
 
      String resweepStatus = SRW_Utils.getSettingByName('ReSweep Status');
      system.debug('MICK_LOKO RemoteAction reSweepMonthId :' + reSweepMonthId);
      system.debug('MICK_LOKO RemoteAction reSweepMonthId :' + resweepStatus);

      if((resweepStatus != '' || resweepStatus != null) && resweepStatus == reSweepMonthId) {
        return 'Not Ready';
      }
      else {
          return 'Ready';
      }
  	}
	public String getchoosenForResweepName(){
		
		if(choosenForResweep != null && mapDataMonths.containsKey(choosenForResweep)) {
			choosenForResweepName = mapDataMonths.get(choosenForResweep).Data_Month_Cal_gne__c;
		} else {
			choosenForResweepName = 'No open data month';
		}
		
		return choosenForResweepName;
	}
	 public List<SelectOption> getOpenDataMonthOptions(){
	 	system.debug('MICK_LOKO : methood getOpenDataMonthOptions');
	 	system.debug('MICK_LOKO getOpenDataMonthOptions: choosenDataMonth =  ' + choosenDataMonth);



	 	List<SelectOption> trOpenDataMonthOpt = new List<SelectOption>();
	 	uniqueDM.clear();

	 	if(!saleData.isEmpty() || !openMonthNoSalesData.isEmpty()){

		 	for(SRW_Sales_Data_gne__c temp : saleData) {

		 		if(!uniqueDM.contains(temp.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c)) {
		 			trOpenDataMonthOpt.add(new SelectOption(temp.TP_Data_Month_gne__r.SRW_Data_Month_gne__c , temp.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c));
		 			uniqueDM.add(temp.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c);
		 		}
	 		}	
	 	
		 	for(SRW_TP_Data_Months__c temp :openMonthNoSalesData){

	 		if(!uniqueDM.contains(temp.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c)){
	 			trOpenDataMonthOpt.add(new SelectOption(temp.SRW_Data_Month_gne__c, temp.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c));
	 			uniqueDM.add(temp.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c);
	 		}


	 		}


	 	} else {

	 		trOpenDataMonthOpt.add(new SelectOption('', 'No open DataMonth'));

	 	}

	 	system.debug('MICK_LOKO : methood getOpenDataMonthOptions trOpenDataMonthOpt '+ trOpenDataMonthOpt);


	 	return trOpenDataMonthOpt;
	 }

	 public List<SelectOption> getHistoryDataMonthOptions(){
	 	
	 	List<SelectOption> trHistoryDataMonthOpt = new List<SelectOption>();
	 	uniqueDM.clear();
	 	if(!lstHistoricDataMonths.isEmpty()){
		 	trHistoryDataMonthOpt.add(new SelectOption('all', 'All'));
			historyDataMonth = 'all';

		 	for(SRW_ReSweep_File__c temp : lstHistoricDataMonths) {

		 		
			 		if(!uniqueDM.contains(temp.Data_Month_gne__r.Data_Month_Cal_gne__c)) {
			 			trHistoryDataMonthOpt.add(new SelectOption(temp.Data_Month_gne__r.Data_Month_Cal_gne__c, temp.Data_Month_gne__r.Data_Month_Cal_gne__c));
			 			uniqueDM.add(temp.Data_Month_gne__r.Data_Month_Cal_gne__c);
			 		}
		 	}
	 	} else {
	 		trHistoryDataMonthOpt.add(new SelectOption('', 'No ReSweep Data'));
	 	}

	 	return trHistoryDataMonthOpt;
	 }

	 public List<TPResweepWrapper> getTradingPartnerResweep(){
	 	system.debug('MICK_LOKO : methood getTradingPartnerResweep');
	 	calculateTableRows();
	 	return finalList;

	 }

	public List<SelectOption> getAvailableForResweep(){
	 	system.debug('MICK_LOKO : methood getAvailableForResweep');
 		uniqueADM.clear();
 		List<SelectOption> availableForResweep = new List<SelectOption>();
        if(!finalList.isEmpty()) {
	 		for(TPResweepWrapper temp : finalList) {
		 		if(!uniqueADM.contains(temp.ActualSweepMonthId)) {
		 			availableForResweep.add(new SelectOption(temp.ActualSweepMonthId , temp.ActualSweepMonthName));
		 			uniqueADM.add(temp.ActualSweepMonthId);
		 		}
	 		}

        }else {

        	availableForResweep.add(new SelectOption('','No month to ReSweep'));

        }

        system.debug('MICK_LOKO : methood getAvailableForResweep : availableForResweep' + availableForResweep);

	 	return availableForResweep;
	}


	 public PageReference triggerReSweep(){

	 	//Set Real DataMonth for ReSweep
	 	SRW_DataMonths__c tempDM = mapDataMonths.get(choosenForResweep);
	 	system.debug('MICK_LOKO : methood triggerReSweep and choosenForResweep : ' + choosenForResweep);
	 	upsert new SRW_Settings__c( Name = 'Sweep Status',Value_gne__c = tempDM.Id) Name;
        SRW_SweepProcessBatch batchJob = new SRW_SweepProcessBatch(tempDM,false);
        Database.executeBatch(batchJob);    
      
        return null;
	 }


	 private Set<String> changeStringToSet(String param) {

	 	Set<String> returnSet = new Set<String>();

	 	if(param != null){
		 	param = param.remove('[');
		 	param = param.remove(']');

		 	for(String temp : param.split(',')){
					returnSet.add(temp.remove(' '));

		 	}

	 	}	
	 	system.debug('MICK_LOKO returnSet : ' + returnSet);
	 	return returnSet;

	 }
	 public PageReference calculateTableRows(){
	 	 system.debug('MICK_LOKO : methood calculateTableRows ');
	 	finalList.clear();
		uniqueTP.clear();

	 	Set<String> choosenDataMonthSet = changeStringToSet(choosenDataMonth);

	 	for(SRW_Sales_Data_gne__c tmp : saleData) {

	 			if(!uniqueTP.contains(tmp.Trading_Partner_gne__c + '-' + tmp.TP_Data_Month_gne__r.SRW_Data_Month_gne__c) && choosenDataMonthSet.contains(tmp.TP_Data_Month_gne__r.SRW_Data_Month_gne__c)) {

	 				TPResweepWrapper newElem = new TPResweepWrapper();
	 				newElem.TPName = tmp.Trading_Partner_gne__r.Trading_Partner_Name_gne__c;
	 				newElem.ReopenDate = tmp.TP_Data_Month_gne__r.Reopen_Date_gne__c;
	 				newElem.ActualSweepMonthName = tmp.Sweep_Data_Month_gne__r.Data_Month_Cal_gne__c;
	 				newElem.ActualSweepMonthId = tmp.Sweep_Data_Month_gne__c;
	 				newElem.Status = tmp.TP_Data_Month_gne__r.Data_Month_Status_gne__c;
	 				finalList.add(newElem);

	 				uniqueTP.add(tmp.Trading_Partner_gne__c + '-' + tmp.TP_Data_Month_gne__r.SRW_Data_Month_gne__c);	
	 			}

	 	}

	 	for(SRW_TP_Data_Months__c tmp: openMonthNoSalesData){

	 			if(!uniqueTP.contains(tmp.Trading_Partner_gne__c + '-' + tmp.SRW_Data_Month_gne__c) && choosenDataMonthSet.contains(tmp.SRW_Data_Month_gne__c)) {

	 				TPResweepWrapper newElem = new TPResweepWrapper();
	 				newElem.TPName = tmp.Trading_Partner_gne__r.Trading_Partner_Name_gne__c;
	 				newElem.ReopenDate = tmp.Reopen_Date_gne__c;
	 				newElem.ActualSweepMonthName = tmp.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c;
	 				newElem.ActualSweepMonthId = tmp.SRW_Data_Month_gne__c;
	 				newElem.Status = tmp.Data_Month_Status_gne__c;
	 				finalList.add(newElem);

	 				uniqueTP.add(tmp.Trading_Partner_gne__c + '-' + tmp.SRW_Data_Month_gne__c);	
	 			}
	 	}

	 	 system.debug('MICK_LOKO : methood calculateTableRows finalList : '+ finalList);

	 	return null;
	 }

	 public class TPResweepWrapper {

	 		public String TPName {get;set;}
	 		public Date ReopenDate {get;set;}
	 		public String ActualSweepMonthName {get;set;}
	 		public String ActualSweepMonthId {get;set;}
	 		public String Status {get;set;}

	 		public TPResweepWrapper(){}
	 }

	 public class ReSweepHistoryFile {

	 	public String DataMonthName {get;set;}
	 	public Datetime ReSweepDate {get;set;}
	 	public String AttachmentId  {get;set;}
	 	public String AttachmentName {get;set;}

	 	public ReSweepHistoryFile(){}
	 }
}