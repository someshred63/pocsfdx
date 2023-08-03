/*
*@Author: Konrad Russa
*@Created: 30-10-2013
*/

trigger CFAR_Budget_CPS_PaymentsTrigger on CFAR_Budget_CPS_Payments_gne__c (after insert, after update, after delete) {
    if (CFAR_ConfigUtil.isTriggerEnabled(new List<String>{'CFAR_Budget_CPS_PaymentsTrigger','CFAR_Budget_CPS_Payments_gne__c'})){
        Set<String> trials = new Set<String>();
        Set<String> budgetContracts = new Set<String>();
        Set<String> paymentExp = new Set<String>();         
        
        if(!CFAR_Budget_Utils.hasAlreadyProcessedPayment()) {
            String cancelledStatus = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_CANCELLED_STATUS;
            if(!trigger.isdelete) {
                //DONE: ITERATION2 MultiContract
                budgetContracts = CFAR_Utils.fetchSet(trigger.new, 'Budget_Contract_ref_gne__c');
                map<Id, map<Integer, Decimal>> budgetContractPaidIds = new map<Id, map<Integer, Decimal>>();
                map<Id, map<integer, map<integer, decimal>>> budgetContractRefundedIds = new map<Id, map<integer, map<integer, decimal>>>();
                map<Id, Decimal> budgetContractPaymentsIds = new map<Id, Decimal>(); 

                trials = CFAR_Utils.fetchSet(trigger.new, 'frm_Trial_Id_gne__c');                     

                CFAR_PaymentForProjectionHelper paymentsForProjHelper = new CFAR_PaymentForProjectionHelper(trials);
                map<Id, map<Integer, Decimal>> trialPaidIds = paymentsForProjHelper.trialPaidIds;
                map<Id, map<integer, map<integer, decimal>>> trialRefundedIds = paymentsForProjHelper.trialRefundedIds;
                
                for(CFAR_Budget_CPS_Payments_gne__c cpsPayment : trigger.new) {
                        if(Trigger.isInsert || (Trigger.isUpdate && (cpsPayment.Invoice_Amount_gne__c != trigger.oldMap.get(cpsPayment.Id).Invoice_Amount_gne__c ||
                            cpsPayment.Payment_Status_ref_gne__c != trigger.oldMap.get(cpsPayment.Id).Payment_Status_ref_gne__c || cpsPayment.Withhold_Indicator_gne__c != trigger.oldMap.get(cpsPayment.Id).Withhold_Indicator_gne__c))) 
                        {
                            paymentExp.add(cpsPayment.Payment_Explanation_Text_gne__c);
                        } 
                        //There's no problem if given payment exp is added multiple times (it's added to set!)
                        if(Trigger.isUpdate && (cpsPayment.Payment_Explanation_Text_gne__c != trigger.oldMap.get(cpsPayment.Id).Payment_Explanation_Text_gne__c)) {
                            paymentExp.add(trigger.oldMap.get(cpsPayment.Id).Payment_Explanation_Text_gne__c);
                            paymentExp.add(cpsPayment.Payment_Explanation_Text_gne__c);                 
                        }
                }

                //DONE: ITERATION2 MultiContract
                List<CFAR_Budget_CPS_Payments_gne__c> completedListBudgetContract = [select Id, frm_sfdc_Completed_gne__c,
                Invoice_Amount_gne__c, Paid_On_gne__c, Payment_Status_ref_gne__c, Payment_Status_ref_gne__r.Name,
                Invoice_Submitted_Date_gne__c, Planned_Amount_gne__c, Budget_Contract_ref_gne__c
                from CFAR_Budget_CPS_Payments_gne__c where Budget_Contract_ref_gne__c in :budgetContracts
                and Payment_Status_ref_gne__r.Name != :cancelledStatus];

                for(CFAR_Budget_CPS_Payments_gne__c c : completedListBudgetContract) {
                    //Payment has been made section
                    Boolean notInStatus = c.Payment_Status_ref_gne__r.Name != Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS
                            && c.Payment_Status_ref_gne__r.Name != Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PLANNED_STATUS
                                && c.Payment_Status_ref_gne__r.Name != Label.CFAR_GSTARS_PAYMENT_SCHEDULE_UNPAID_STATUS;
                        
                    if((trigger.isInsert && notInStatus && c.Invoice_Submitted_Date_gne__c != null && c.Invoice_Amount_gne__c != null) 
                        || (trigger.isUpdate && notInStatus && c.Invoice_Submitted_Date_gne__c != null && c.Invoice_Amount_gne__c != null)) {
                        //DONE: ITERATION2 MultiContract
                        if(budgetContractPaidIds.containsKey(c.Budget_Contract_ref_gne__c)) {
                            //DONE: ITERATION2 MultiContract
                            if(budgetContractPaidIds.get(c.Budget_Contract_ref_gne__c).containsKey(c.Invoice_Submitted_Date_gne__c.year())) {
                                //DONE: ITERATION2 MultiContract
                                Decimal currentAmount = budgetContractPaidIds.get(c.Budget_Contract_ref_gne__c).get(c.Invoice_Submitted_Date_gne__c.year());
                                budgetContractPaidIds.get(c.Budget_Contract_ref_gne__c).put(c.Invoice_Submitted_Date_gne__c.year(),
                                            currentAmount + c.Invoice_Amount_gne__c);
                            } else {
                                //DONE: ITERATION2 MultiContract
                                budgetContractPaidIds.get(c.Budget_Contract_ref_gne__c).put(c.Invoice_Submitted_Date_gne__c.year(), c.Invoice_Amount_gne__c);
                            }
                        } else {
                            //DONE: ITERATION2 MultiContract
                            budgetContractPaidIds.put(c.Budget_Contract_ref_gne__c, 
                                new map<Integer, Decimal>{c.Invoice_Submitted_Date_gne__c.year() => c.Invoice_Amount_gne__c});
                        }
                    }
                    
                    //Refund section
                    Boolean afterUpdate = trigger.isUpdate && c.Invoice_Amount_gne__c != null
                        && c.Invoice_Submitted_Date_gne__c != null && c.Payment_Status_ref_gne__c != null 
                            && c.Payment_Status_ref_gne__r.Name == Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS;
                    
                    if((Trigger.isInsert && c.Payment_Status_ref_gne__r.Name == Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS 
                            && c.Invoice_Amount_gne__c != null && c.Invoice_Submitted_Date_gne__c != null)
                        || afterUpdate) {
                        Integer month = c.Invoice_Submitted_Date_gne__c.month();
                        Integer year = c.Invoice_Submitted_Date_gne__c.year();
                        //DONE: ITERATION2 MultiContract
                        if(budgetContractRefundedIds.containsKey(c.Budget_Contract_ref_gne__c)) {
                            //DONE: ITERATION2 MultiContract
                            if(budgetContractRefundedIds.get(c.Budget_Contract_ref_gne__c).containsKey(year)) {
                                //DONE: ITERATION2 MultiContract
                                map<integer, Decimal> currentAmount = budgetContractRefundedIds.get(c.Budget_Contract_ref_gne__c).get(year);
                                if(currentAmount.containsKey(month)) {
                                    Decimal amount = currentAmount.get(month);
                                    //DONE: ITERATION2 MultiContract
                                    budgetContractRefundedIds.get(c.Budget_Contract_ref_gne__c).get(year).put(month, amount + c.Invoice_Amount_gne__c);
                                } else {
                                    //DONE: ITERATION2 MultiContract
                                    budgetContractRefundedIds.get(c.Budget_Contract_ref_gne__c).get(year).put(month, c.Invoice_Amount_gne__c);
                                }
                            } else {
                                //DONE: ITERATION2 MultiContract
                                budgetContractRefundedIds.get(c.Budget_Contract_ref_gne__c).put(year, new map<Integer, decimal> {month => c.Invoice_Amount_gne__c});
                            }
                            
                        } else {
                            //DONE: ITERATION2 MultiContract
                            budgetContractRefundedIds.put(c.Budget_Contract_ref_gne__c, 
                                new map<integer, map<integer, decimal>> {year 
                                            => new map<integer, decimal>{ month => c.Invoice_Amount_gne__c}});
                        }
                    }
                    //DONE: ITERATION2 MultiContract
                    if(budgetContractPaymentsIds.containsKey(c.Budget_Contract_ref_gne__c)) {
                        //DONE: ITERATION2 MultiContract
                        Decimal currentAmount = budgetContractPaymentsIds.get(c.Budget_Contract_ref_gne__c);
                        if((c.Payment_Status_ref_gne__r.Name == Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PLANNED_STATUS 
                            ||  c.Payment_Status_ref_gne__r.Name == Label.CFAR_GSTARS_PAYMENT_SCHEDULE_UNPAID_STATUS) && c.Planned_Amount_gne__c != null) {
                            //DONE: ITERATION2 MultiContract
                            budgetContractPaymentsIds.put(c.Budget_Contract_ref_gne__c, currentAmount + c.Planned_Amount_gne__c);
                        } else if(c.Invoice_Amount_gne__c != null){
                            //DONE: ITERATION2 MultiContract
                            budgetContractPaymentsIds.put(c.Budget_Contract_ref_gne__c, currentAmount + c.Invoice_Amount_gne__c);
                        }
                        
                    } else {
                        if((c.Payment_Status_ref_gne__r.Name == Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PLANNED_STATUS 
                            ||  c.Payment_Status_ref_gne__r.Name == Label.CFAR_GSTARS_PAYMENT_SCHEDULE_UNPAID_STATUS) && c.Planned_Amount_gne__c != null) {
                            //DONE: ITERATION2 MultiContract
                            budgetContractPaymentsIds.put(c.Budget_Contract_ref_gne__c, c.Planned_Amount_gne__c);
                        } else if(c.Invoice_Amount_gne__c != null){
                            //DONE: ITERATION2 MultiContract
                            budgetContractPaymentsIds.put(c.Budget_Contract_ref_gne__c, c.Invoice_Amount_gne__c);                 
                        }
                    }
                }

                //DONE: ITERATION2 MultiContract
                List<CFAR_Budget_CPS_Projection_gne__c> projections = new List<CFAR_Budget_CPS_Projection_gne__c>([select Id, Quarter_1_gne__c,Quarter_2_gne__c,Quarter_3_gne__c,Quarter_4_gne__c,
                    January_gne__c, February_gne__c, March_gne__c, April_gne__c, May_gne__c, June_gne__c, July_gne__c, 
                    August_gne__c, September_gne__c, October_gne__c, November_gne__c, December_gne__c, 
                    CFAR_Trial_ref_gne__c, Year_gne__c, Total_Paid_gne__c, frm_Total_Amount_gne__c
                                         from CFAR_Budget_CPS_Projection_gne__c 
                                            where CFAR_Trial_ref_gne__c in :trials order by Year_gne__c]);
                                                                            
                //DONE: ITERATION2 MultiContract - need to search for all payments for Trial to calculate Projections
                Set<Id> trialsWithPayments = CFAR_Budget_Utils.hasPaymentsSubmitted(CFAR_Utils.setToIdSet(trials));
                
                for(CFAR_Budget_CPS_Projection_gne__c arg : projections) {
                    Integer year = Integer.valueOf(arg.Year_gne__c);
                    arg.Total_Paid_gne__c = 0;
                    //DONE: ITERATION2 MultiContract - Projection is related to Trial
                    if(trialPaidIds.containsKey(arg.CFAR_Trial_ref_gne__c)) {
                        if(trialPaidIds.get(arg.CFAR_Trial_ref_gne__c).containsKey(year)) {
                            Decimal totalPaidToAdd = (Decimal)trialPaidIds.get(arg.CFAR_Trial_ref_gne__c).get(year);
                            arg.Total_Paid_gne__c = totalPaidToAdd;
                            trialPaidIds.get(arg.CFAR_Trial_ref_gne__c).put(year, arg.Total_Paid_gne__c);
                        }
                    }
                    
                    if(trialsWithPayments.contains(arg.CFAR_Trial_ref_gne__c) && trialRefundedIds.containsKey(arg.CFAR_Trial_ref_gne__c)) {
                        if(trialRefundedIds.get(arg.CFAR_Trial_ref_gne__c).containsKey(year)) {
                            map<integer, decimal> monthAmount = trialRefundedIds.get(arg.CFAR_Trial_ref_gne__c).get(year);
                            for (Decimal paidMonth : monthAmount.values()) {
                                arg.Total_Paid_gne__c += paidMonth;
                            }
                        } 
                    }
                }
                
                if(!projections.isEmpty()) {
                    update projections;
                }
                
                    //DONE: ITERATION2
                    List<CFAR_Budget_Contract_gne__c> budgetContractsToChangeBudgetSection = [select Id, Year_to_Date_Paid_gne__c, Prior_Years_Paid_gne__c, Next_Payment_Due_gne__c, Total_Payments_gne__c, 
                            frm_Current_Amount_gne__c, Amount_Left_to_Project_gne__c from CFAR_Budget_Contract_gne__c where Id in :budgetContracts];      

                    String submitedStatus = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_SUBMITTED_STATUS;
                    String paidStatus = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS;
                    String refundStatus = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS;

                    //DONE: ITERATION2 MultiContract
                    Map<Id, AggregateResult> budgetContractNextPayments = new Map<Id, AggregateResult>([select Budget_Contract_ref_gne__c Id, min(Planned_Date_gne__c) nextPayment
                            from CFAR_Budget_CPS_Payments_gne__c where frm_sfdc_Completed_gne__c = false 
                                 and Payment_Status_ref_gne__r.Name != :submitedStatus
                                 and Payment_Status_ref_gne__r.Name != :paidStatus
                                 and Payment_Status_ref_gne__r.Name != :refundStatus
                                 and Payment_Status_ref_gne__r.Name != :cancelledStatus
                                 and Planned_Date_gne__c != null
                                 and Budget_Contract_ref_gne__c in :budgetContractPaidIds.keySet() group by Budget_Contract_ref_gne__c]);


                    Integer currentYear = System.now().year(); 
                for (CFAR_Budget_Contract_gne__c contract : budgetContractsToChangeBudgetSection) {
                    if (budgetContractPaidIds.containsKey(contract.Id)) {
                        Map<Integer, Decimal> m = budgetContractPaidIds.get(contract.Id);
                        if (m.containsKey(currentYear)) {
                            contract.Year_to_Date_Paid_gne__c = m.get(currentYear);
                        } else contract.Year_to_Date_Paid_gne__c = 0;
                        for (Integer year : m.keySet()) {
                            if (year < currentYear) {
                                contract.Prior_Years_Paid_gne__c = null;
                                break;
                            }
                        }
                        for (Integer year : m.keySet()) {
                            if (year < currentYear) {
                                contract.Prior_Years_Paid_gne__c = contract.Prior_Years_Paid_gne__c != null
                                                                ? contract.Prior_Years_Paid_gne__c + m.get(year)
                                                                : m.get(year);
                            }
                        }

                        if (budgetContractNextPayments.containsKey(contract.Id)) {
                            contract.Next_Payment_Due_gne__c = (Date) budgetContractNextPayments.get(contract.Id).get('nextPayment');
                        } else {
                            contract.Next_Payment_Due_gne__c = null;
                        }
                    } else {
                        contract.Year_to_Date_Paid_gne__c = 0;
                        contract.Prior_Years_Paid_gne__c = 0;
                    }
                    if (budgetContractRefundedIds.containsKey(contract.Id)) {
                        Map<integer, map<integer, decimal>> m = budgetContractRefundedIds.get(contract.Id);
                        Decimal curentYearAmount = 0;
                        if (m.containsKey(currentYear)) {
                            Map<integer, decimal> quarterAmountCurrentYear = m.get(currentYear);
                            for (integer i : quarterAmountCurrentYear.keySet()) {
                                curentYearAmount += quarterAmountCurrentYear.get(i);
                            }
                            contract.Year_to_Date_Paid_gne__c = contract.Year_to_Date_Paid_gne__c + curentYearAmount;
                        }
                    }
                    if (budgetContractPaymentsIds.containsKey(contract.Id)) {
                        contract.Total_Payments_gne__c = budgetContractPaymentsIds.get(contract.Id);
                    }
                }
                CFAR_Utils.setAlreadyProcessed();
                //DONE: ITERATION2
                    update budgetContractsToChangeBudgetSection;
                } else {
                    budgetContracts = CFAR_Utils.fetchSet(trigger.old, 'Budget_Contract_ref_gne__c');                   
            	CFAR_Budget_CPS_Payments_gne__c paymentToDel = new CFAR_Budget_CPS_Payments_gne__c();
                    for(CFAR_Budget_CPS_Payments_gne__c cpsPayment : trigger.old) {
                	paymentToDel = cpsPayment;
                    }
                List<CFAR_Budget_Contract_gne__c> budgetContractsToChangeBudgetSection = [select Id, Year_to_Date_Paid_gne__c, Prior_Years_Paid_gne__c, Next_Payment_Due_gne__c, Total_Payments_gne__c, 
                        frm_Current_Amount_gne__c, Amount_Left_to_Project_gne__c from CFAR_Budget_Contract_gne__c where Id in :budgetContracts];  

                String submitedStatus = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_SUBMITTED_STATUS;
                String paidStatus = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PAID_STATUS;
                String refundStatus = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_REFUND_STATUS;
                
                //projections
                CFAR_PaymentForProjectionHelper paymentsForProjHelper = new CFAR_PaymentForProjectionHelper(trials);
                map<Id, map<Integer, Decimal>> trialPaidIds = paymentsForProjHelper.trialPaidIds;
                map<Id, map<integer, map<integer, decimal>>> trialRefundedIds = paymentsForProjHelper.trialRefundedIds;
    			List<CFAR_Budget_CPS_Projection_gne__c> projections = new List<CFAR_Budget_CPS_Projection_gne__c>([select Id, Quarter_1_gne__c,Quarter_2_gne__c,Quarter_3_gne__c,Quarter_4_gne__c,
                    January_gne__c, February_gne__c, March_gne__c, April_gne__c, May_gne__c, June_gne__c, July_gne__c, 
                    August_gne__c, September_gne__c, October_gne__c, November_gne__c, December_gne__c, 
                    CFAR_Trial_ref_gne__c, Year_gne__c, Total_Paid_gne__c, frm_Total_Amount_gne__c
                                         from CFAR_Budget_CPS_Projection_gne__c 
                                            where CFAR_Trial_ref_gne__c in :trials order by Year_gne__c]);
                                                                            
                //DONE: ITERATION2 MultiContract - need to search for all payments for Trial to calculate Projections
                Set<Id> trialsWithPayments = CFAR_Budget_Utils.hasPaymentsSubmitted(CFAR_Utils.setToIdSet(trials));
                
                for(CFAR_Budget_CPS_Projection_gne__c arg : projections) {
                    Integer year = Integer.valueOf(arg.Year_gne__c);
                    arg.Total_Paid_gne__c = 0;
                    //DONE: ITERATION2 MultiContract - Projection is related to Trial
                    if(trialPaidIds.containsKey(arg.CFAR_Trial_ref_gne__c)) {
                        if(trialPaidIds.get(arg.CFAR_Trial_ref_gne__c).containsKey(year)) {
                            Decimal totalPaidToAdd = (Decimal)trialPaidIds.get(arg.CFAR_Trial_ref_gne__c).get(year);
                            arg.Total_Paid_gne__c = totalPaidToAdd;
                            trialPaidIds.get(arg.CFAR_Trial_ref_gne__c).put(year, arg.Total_Paid_gne__c);
                        }
                    }
                    
                    if(trialsWithPayments.contains(arg.CFAR_Trial_ref_gne__c) && trialRefundedIds.containsKey(arg.CFAR_Trial_ref_gne__c)) {
                        if(trialRefundedIds.get(arg.CFAR_Trial_ref_gne__c).containsKey(year)) {
                            map<integer, decimal> monthAmount = trialRefundedIds.get(arg.CFAR_Trial_ref_gne__c).get(year);
                            for (Decimal paidMonth : monthAmount.values()) {
                                arg.Total_Paid_gne__c += paidMonth;
                            }
                        }
                    }
                }
                
                if(!projections.isEmpty()) {
                    update projections;
                }
                

                
                
            	//budget contracts
                trials = CFAR_Utils.fetchSet(trigger.old, 'frm_Trial_Id_gne__c');
                Integer currentYear = System.now().year(); 
                for (CFAR_Budget_Contract_gne__c contract : budgetContractsToChangeBudgetSection) {
                    if(paymentToDel.Planned_Amount_gne__c != null) {
                    contract.Total_Payments_gne__c -= paymentToDel.Planned_Amount_gne__c;
                }
                }
                
                CFAR_Utils.setAlreadyProcessed();
                update budgetContractsToChangeBudgetSection;


                //renumerate Line #
                List<CFAR_Budget_CPS_Payments_gne__c> paymentsForTrial = [SELECT ID, Line_Num_gne__c FROM CFAR_Budget_CPS_Payments_gne__c
                    WHERE Budget_Contract_ref_gne__r.Team_Member_ref_gne__r.CFAR_Trial_ref_gne__c =: paymentToDel.frm_Trial_Id_gne__c
                    AND Budget_Contract_ref_gne__c =: paymentToDel.Budget_Contract_ref_gne__c
                    order by CreatedDate];
                Integer newLineNumber = 1;
                List<CFAR_Budget_CPS_Payments_gne__c> paymentsToUpdate = new List<CFAR_Budget_CPS_Payments_gne__c>();

                for(CFAR_Budget_CPS_Payments_gne__c payment : paymentsForTrial){
                    if(payment.Line_num_gne__c != newLineNumber){
                        payment.Line_num_gne__c = newLineNumber;
                        paymentsToUpdate.add(payment);
                    }
                    newLineNumber ++;
                }
                update paymentsToUpdate;

                }       
                // recount rate table
                if(!trials.isEmpty() && !paymentExp.isEmpty()) {
                    //DONE: ITERATION2 MultiContract
                List<CFAR_Rate_Table_gne__c> rateTables = [Select Id, Total_Amount_gne__c, Contract_Term_gne__c, Budget_Contract_ref_gne__c
                        FROM CFAR_Rate_Table_gne__c
                                                                WHERE Budget_Contract_ref_gne__c in :budgetContracts AND Contract_Term_gne__c in :paymentExp];

                    update rateTables;
                } 
            
            CFAR_Budget_Utils.setAlreadyProcessedPayment();
        }
    }
}