/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Michael Kent
 */


public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
        // Create a new Account instance
        Account newAccount = new Account();
        // Set some fields on the Account
        newAccount.name = 'Test Account';
        newAccount.industry = 'Technology';
     // Insert the Account into the database
        Insert newAccount;

        // Return the Id of the newly created Account
        return newAccount.id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
        // Create a new Account and set the fields inline
        Account newAccount = new Account(name = name,industry = industry);
        // Insert the Account
        Insert newAccount;
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        // Create a new Contact instance
        Contact newContact = new Contact();
        // Set some fields on the Contact
        newContact.FirstName = 'Michael';
        newContact.LastName = 'Kent';
        newContact.Email = 'kentm122@outlook.com';
        // Set the AccountId field to the given accountId
        newContact.AccountId = accountId;
        // Insert the Contact into the database
        Insert newContact;
        // Return the Id of the newly created Contact
        return newContact.Id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        // Retrieve the Contact from the database
        // [SELECT Id FROM Contact WHERE Id = :contactId]
        Contact contactToUpdate = [SELECT Id FROM CONTACT WHERE ID = :contactId]; 
        // Update the Contact's last name
        contactToUpdate.LastName = newLastName;
        // Update the Contact in the database
        Update contactToUpdate;
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        // Retrieve the Opportunity from the database
        // [SELECT Id FROM Opportunity WHERE Id = :oppId]
        Opportunity oppToUpdate = [SELECT Id FROM OPPORTUNITY WHERE ID = :oppId];
        // Update the Opportunity's stage
        oppToUpdate.StageName = newStage;
        // Update the Opportunity in the database
        Update oppToUpdate;
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        // Query the account
        // [SELECT Id FROM Account WHERE Id = :accountId]
        Account accToUpdate = [SELECT Id FROM ACCOUNT WHERE Id = :accountId];
        // Update the Account with the given Id with the new name and industry
        accToUpdate.Name = newName;
        accToUpdate.Industry = newIndustry;
        // Update the Account in the database
        Update accToUpdate;
    }


    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {
        // Loop through each Opportunity in the list
            // Set the Opportunity's Stage to Qualification
            // Set the Opportunity's Close Date to 3 months from today
            // Set the Opportunity's Amount to 50000
            for(Opportunity currOpp : opportunities) {
                currOpp.StageName = 'Qualification';
                currOpp.CloseDate = date.today().addMonths(3);
                currOpp.Amount = 50000;
        }
        // Upsert the opportunities List so that records are either updated or created
        upsert opportunities;
    }
    /**
     * Question 8
     * Insert or updates opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {
        Account oppAccount;
        List<ACCOUNT> Accounts = [SELECT Id FROM ACCOUNT WHERE Name = :accountName LIMIT 1];
        if (Accounts.isEmpty()) {
            Account newAccount = new Account();
            newAccount.Name = accountName;
            Insert newAccount;
            oppAccount = newAccount;
        } else {
             oppAccount = Accounts[0];
        }
        Map<String, Opportunity> existingOppsMap = new Map<String, Opportunity>();
        List<Opportunity> existingOppsList = [SELECT Id, Name FROM Opportunity WHERE Name IN :oppNames];
        for(Opportunity currOpp : existingOppsList) {
            existingOppsMap.put(currOpp.Name, currOpp);
        }
        List<Opportunity> oppstoUpsert = new List<Opportunity>();
        for (String currName : oppNames) {
            Opportunity singleOpp;
            if (existingOppsMap.containsKey(currName)) {
                singleOpp = existingOppsMap.get(currName);
                SingleOpp.AccountId = oppAccount.Id;
            } else {
                singleOpp = new Opportunity();
                singleOpp.Name = currName;
                singleOpp.StageName = 'Qualification';
                singleOpp.CloseDate = date.today().addMonths(3);
                singleOpp.Amount = 50000;
                singleOpp.AccountId = oppAccount.Id;
            }
            oppstoUpsert.add(singleOpp);
        }
        
        upsert oppstoUpsert;
    }  
    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
	public static Account upsertAccount(String accountName) {
        Account accToUpdate;
		// Query for the Account
		List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName];

		// if the Account exists, update the description
        if (!accounts.isEmpty()) {
            accToUpdate = accounts[0];
            accToUpdate.Description = 'Updated Account';
        } else {
            // otherwise, create a new Account and set the description
            Account newAccount = new Account();
            newAccount.Name = accountName;
            newAccount.Description = 'New Account';
            accToUpdate = newAccount;
        }
		// Upsert the Account
        upsert accToUpdate;
		return accToUpdate;
	}

    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
        list<String> contactLastname = new List<String>();
		// Loop through each Contact
        for(Contact currContact : contactsToUpsert) {
            contactLastname.add(currContact.LastName);
        }
        // Query for Account Id based on Contact's lastname
        // Extract the Account Name from Contact's LastName
        map<String, Account> existingAccountsMap = new map<string, Account>();
        List<Account> existingAccountList = [SELECT Id, Name FROM Account WHERE Name IN :contactLastname];
        for (Account currAcc : existingAccountList) {
            existingAccountsMap.put(currAcc.Name, currAcc);
        }
       // Get the account based on the name or create one if it doesn't exist
        for (String currContact : contactLastname) {
            if (existingAccountsMap.get(currContact) == null) {
                Account newAccount = upsertAccount(currContact);
                existingAccountsMap.put(currContact, newAccount);
            }
        }
		// Link the Contact to its Account using the Account Id
        for(Contact currContact : contactsToUpsert) {
            currContact.AccountId = existingAccountsMap.get(currContact.LastName).Id;
        }
		// Upsert the Contacts
         upsert contactsToUpsert;
    }
    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {
        list<Lead> leadsToInsert = new List<Lead>();
        String firstName;
        String lastName;
        // Loop through each Lead name
        for (String currLead : leadNames) {
            list<String> splitName = currLead.split(' ',2);
            firstName = splitName[0];
            lastName = splitName[1];
            Lead newLead = new Lead();
            newlead.FirstName = firstName;
            newlead.LastName = lastName;
            newLead.Status = 'Open - Not Contacted';
            newLead.Company = 'My Company';
            leadsToInsert.add(newLead);
            
        }
        // Insert the Leads
        insert leadsToInsert;
        // Delete the Leads
        delete leadsToInsert;
    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        list<Case> newCasesList = new list<case>();
        for (Integer i = 0; i < numOfCases; i++) {
            Case newCase = new Case();
            newCase.accountId = accountId;
            newCase.subject = 'testcase' + i;
            newcase.Origin = 'Web';
            newCasesList.add(newCase);
        } 
        // Insert the cases
        insert newCasesList;
        // Delete the cases
        delete newCasesList;
    
    }
}