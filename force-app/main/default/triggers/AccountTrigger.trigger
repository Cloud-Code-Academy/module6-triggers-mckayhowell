/*
* Account trigger should do the following:
* 1. Set the account type to prospect.
* 2. Copy the shipping address to the billing address.
* 3. Set the account rating to hot.
* 4. Create a contact for each account inserted.
*/
trigger AccountTrigger on Account (before insert, after insert) {
    // BEFORE
    if(Trigger.isBefore){
        // INSERT
        if(Trigger.isInsert){
            for(Account a : Trigger.new){
                // Change the account type to 'Prospect' if there is no value in the type field
                if(String.isBlank(a.Type)){
                    a.Type = 'Prospect';
                }

                // Copy the shipping address to the billing address
                if(!String.isBlank(a.ShippingState)){
                    a.BillingStreet = a.ShippingStreet;
                    a.BillingCity = a.ShippingCity;
                    a.BillingState = a.ShippingState;
                    a.BillingPostalCode = a.ShippingPostalCode;
                    a.BillingCountry = a.ShippingCountry;
                }
                
                // Set the rating to 'Hot' if the Phone, Website, and Fax ALL have a value.
                if(!String.isBlank(a.Phone) && !String.isBlank(a.Website) && !String.isBlank(a.Fax)){
                    a.Rating = 'Hot';
                }
            }
        }
    }

    // AFTER
    if(Trigger.isAfter){
        // INSERT
        if(Trigger.isInsert){
            // Create a Contact related to the Account with default values
            List<Contact> newContacts = new List<Contact>();
            for(Account a : Trigger.new){
                Contact c = new Contact(
                                        LastName = 'DefaultContact',
                                        Email = 'default@email.com',
                                        AccountId = a.Id);
                newContacts.add(c);
            }
            insert newContacts;
        }
    }
}