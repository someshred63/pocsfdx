global with sharing class iPhone_StratTact_Webservice_gne {
    global class Response {
        Webservice List<Product_Strategy_vod__c> strategies;
        Webservice List<Product_Tactic_vod__c> tactics;
    }

    public static List<Product_Tactic_vod__c> activeProductTactics() {
        List<Product_Tactic_vod__c> tactics = new List<Product_Tactic_vod__c>();

        tactics =
            [
                Select
                Id,
                Name,
                Product_Strategy_vod__c
                From
                Product_Tactic_vod__c where product_strategy_vod__c != null and active_vod__c = true and Product_Strategy_vod__r.active_vod__c = true
            ];

        return tactics;
    }

    public static List<Product_Strategy_vod__c> activeProdStrategies() {
        List<Product_Strategy_vod__c> strats = new List<Product_Strategy_vod__c>();
        String query = 'SELECT Id, Name, Product_Plan_vod__r.Product_vod__c FROM Product_Strategy_vod__c WHERE active_vod__c = true AND Product_Plan_vod__r.active_vod__c = true';
        if(GNE_SFA2_Util.isFrmUser()) {
            if(GNE_SFA2_Util.getUserProfileName(UserInfo.getUserId()) == 'GNE-MCCO-FRM-RFRM' || GNE_SFA2_Util.getUserProfileName(UserInfo.getUserId()) == 'GNE-MCCO-FRM-RFRM-Manager'){
                query += ' AND Owner.Name IN (\'GNE-MCCO-FRM-Queue\', \'GNE-MCCO-FRM-RFRM\')';
            }
            else {
                query += ' AND Owner.Name = \'GNE-MCCO-FRM-Queue\'';
            }
        }
        
        strats = Database.query(query);

        return strats;
    }


    global without sharing class AllStratTactAcessor {

        public List<Product_Strategy_vod__c> allProductStrategies(List<Id> stratIds) {
            List<Product_Strategy_vod__c> strats = new List<Product_Strategy_vod__c>();
            strats =
                [
                    Select
                    Id,
                    Name,
                    Product_Plan_vod__r.Product_vod__c
                    From
                    Product_Strategy_vod__c where id in :stratIds
                ];
            return strats;
        }
        public List<Product_Tactic_vod__c> allProductTactics(List<Id> tactIds) {
            List<Product_Tactic_vod__c> tactics = new List<Product_Tactic_vod__c>();
            tactics =
                [
                    Select
                    Id,
                    Name,
                    Product_Strategy_vod__c
                    From
                    Product_Tactic_vod__c where id in :tactIds
                ];
            return tactics;
        }
    }


    Webservice static Response activeProductStrategiesAndTactics() {
        Response result = new Response();
        result.strategies = activeProdStrategies();
        result.tactics = activeProductTactics();
        return result;
    }

    Webservice static Response getProductStrategiesAndTactics(List<Id>stratIds, List<Id> tactIds) {
        Response result = new Response();
        AllStratTactAcessor accessor = new AllStratTactAcessor();
        result.strategies =  accessor.allProductStrategies(stratIds);
        result.tactics =  accessor.allProductTactics(tactIds);

        return result;
    }

    public static void testMe() {
        Response resp = activeProductStrategiesAndTactics();
        System.debug('--@@-@@-@@--: activeStrategies: ' + resp.strategies.size());

        for (Product_Strategy_vod__c strategy : resp.strategies) {
            System.debug('--@@-@@-@@--: Strategy:' + strategy.id);
        }
        for (Product_Tactic_vod__c tactics : resp.tactics) {
            System.debug('--@@-@@-@@--: Tactic:' + tactics.id);
        }
    }
}