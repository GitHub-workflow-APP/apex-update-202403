public without sharing class ManagePagghiazzi {

    public List<Pagghiazzu__c> getAllPagghiazzi(){
        return [SELECT name, color__c, owner.name FROM Pagghiazzu__c]; // CWE 284
    }
    
}