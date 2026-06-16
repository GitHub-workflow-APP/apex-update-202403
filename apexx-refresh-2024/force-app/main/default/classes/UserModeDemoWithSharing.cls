public with sharing class UserModeDemoWithSharing {

    public List<Dialog__c> allDialoguesUser {get; set;}
    public List<Dialog__c> allDialoguesSystem {get; set;}
    public List<Dialog__c> allDialoguesUndef {get; set;}
    // public List<Dialog__c> allDialoguesAuraEnabled {get; set;}
    public Dialog__c newDialog {get; set;}
    public Dialog__c toBeEditedDialog {get; set;}
    public String param1 {get; set;}
    public String messaggio {get; set;}



    public UserModeDemoWithSharing() {
        System.debug('UserModeDemoWithSharing .ctor');
        messaggio = 'UserModeDemoWithSharing .ctor';
        allDialoguesSystem = [SELECT name, Message__c, OwnerId FROM Dialog__c WITH SYSTEM_MODE]; // CWE 284
        allDialoguesUser = [SELECT name, Message__c, OwnerId FROM Dialog__c WITH USER_MODE];
        allDialoguesUndef = [SELECT name, Message__c, OwnerId FROM Dialog__c]; // GOOD 
        newDialog = new Dialog__c();
    }

    // This method is not vulnerable because of the @AuraEnabled annotation. This method is like it is executed inside with 'with sharing'
    @AuraEnabled
    public static List<Dialog__c> getMyDialogues() {
        List<Dialog__c> allDialoguesAuraEnabled = [SELECT name, Message__c, OwnerId FROM Dialog__c WITH SYSTEM_MODE]; // CWE 284 because allows system access
        if(allDialoguesAuraEnabled.size()>0)
        {
            return allDialoguesAuraEnabled;
        }
        return null;
    }


    public void addDialogAsUser() {
        System.debug('addDialog called');
        insert as user newDialog;
    }

    public void addDialogAsSystem() {
        System.debug('addDialog called');
        insert as system newDialog; // CWE 284 or GOOD 
    }

    public void addDialogUnspecified() {
        System.debug('addDialog called');
        insert newDialog; // CWE 274 it can still be possible to add values to unwanted columns
    }

    public void prepareEditAsSystem(){
        System.debug('prepareEdit. param1=' + param1);
        toBeEditedDialog = Database.query('SELECT name, Message__c, OwnerId FROM Dialog__c where id = :param1 WITH SYSTEM_MODE');
    }

    public void prepareEditAsUser(){
        System.debug('prepareEdit. param1=' + param1);
        toBeEditedDialog = Database.query('SELECT name, Message__c, OwnerId FROM Dialog__c where id = :param1 WITH USER_MODE');
    }


    public void updateDialogAsUser() {
        System.debug('updateDialog called. toBeEditedDialog.ID=' + toBeEditedDialog.id);
        update as user toBeEditedDialog; // FP
    }

    public void updateDialogAsSystem() {
        System.debug('updateDialog called. toBeEditedDialog.ID=' + toBeEditedDialog.id);
        update as system toBeEditedDialog; // CWE 274 Keeping this CWE because we were not reporting it before and allow customers to adapt
    }

    public void updateDialogUnspecified() {
        System.debug('updateDialog called. toBeEditedDialog.ID=' + toBeEditedDialog.id);
        update toBeEditedDialog;           // CWE 274 Keeping this CWE because we were not reporting it before and allow customers to adapt
    }
}