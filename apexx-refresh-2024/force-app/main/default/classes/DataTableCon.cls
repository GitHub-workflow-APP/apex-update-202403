public with sharing class DataTableCon {
    List<Account> accounts;

    public List<Account> getAccounts() {
        if(accounts == null)
            accounts = [SELECT name, owner.name FROM account LIMIT 10]; // CWE 274
        return accounts;
    }
}