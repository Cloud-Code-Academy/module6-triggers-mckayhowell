/*
* 1. Validate that the amount is greater than 5000.
* 2. Prevent the deletion of a closed won opportunity for a banking account.
* 3. Set the primary contact on the opportunity to the contact with the title of CEO.
*/
trigger OpportunityTrigger on Opportunity (before update, after update, before delete) {
    System.debug('OpportunityTrigger: ' + Trigger.operationType);

    // BEFORE
    if(Trigger.isBefore){
        // UPDATE
        if(Trigger.isUpdate){
            // Add the AccountId to a set for querying related Contacts
            Set<Id> acctIds = new Set<Id>();
            for(Opportunity o : Trigger.new){
                if(o.AccountId != null){
                    acctIds.add(o.AccountId);
                }
            }

            // Build a map between the AccountId and the associated CEO Contact
            Map<Id, Contact> acctIdToContactMap = new Map<Id, Contact>();
            for(Contact c : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :acctIds AND Title = 'CEO']){
                acctIdToContactMap.put(c.AccountId, c);
            }

            // Do the field validations and updates
            for(Opportunity o : Trigger.new){
                // Validate that the amount is greater than 5000
                if(o.Amount <= 5000){
                    o.addError('Opportunity amount must be greater than 5000');
                }

                // Set the primary contact as the CEO contact on the same account
                if(o.AccountId != null && acctIdToContactMap.containsKey(o.AccountId)){
                    o.Primary_Contact__c = acctIdToContactMap.get(o.AccountId).Id;
                }
            }
        }

        // DELETE
        if(Trigger.isDelete){
            // Add the AccountId to a set for querying additional fields
            Set<Id> acctIds = new Set<Id>();
            for(Opportunity o : Trigger.old){
                if(o.AccountId != null){
                    acctIds.add(o.AccountId);
                }
            }

            // Prevent the deletion of a closed won opportunity if the account industry is 'Banking'
            Map<Id, Account> acctMap = new Map<Id, Account>([SELECT Id, Industry FROM Account WHERE Id IN :acctIds]);
            for(Opportunity o : Trigger.old){
                if(o.StageName == 'Closed Won' && o.AccountId != null){
                    Account a = acctMap.get(o.AccountId);
                    if(a.Industry == 'Banking'){
                        o.addError('Cannot delete closed opportunity for a banking account that is won');
                    }
                }
            }
        }
    }
}