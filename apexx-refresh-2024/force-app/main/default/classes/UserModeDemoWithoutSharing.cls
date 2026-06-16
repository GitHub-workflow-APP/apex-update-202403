public without sharing class UserModeDemoWithoutSharing {

    public List<Dialog__c> allDialoguesUser {get; set;}
    public List<Dialog__c> allDialoguesSystem {get; set;}
    public List<Dialog__c> allDialoguesUndef {get; set;}
    public Dialog__c newDialog {get; set;}
    public Dialog__c toBeEditedDialog {get; set;}
    public String param1 {get; set;}
    public String messaggio {get; set;}
    




    public UserModeDemoWithoutSharing() {
        System.debug('UserModeDemoWithoutSharing .ctor');
        messaggio = 'UserModeDemoWithSharing .ctor';

        allDialoguesSystem = [SELECT name, Message__c, OwnerId FROM Dialog__c WITH SYSTEM_MODE];  // As System // CWE 284 or GOOD
        allDialoguesUser = [SELECT name, Message__c, OwnerId FROM Dialog__c WITH USER_MODE]; // <-- As User
        allDialoguesUndef = [SELECT name, Message__c, OwnerId FROM Dialog__c]; // CWE 284
        newDialog = new Dialog__c();
    }

    // This method is safeom from a with sharing perspective because of the @AuraEnabled annotation
    // @AuraEnabled()
    // public static List<Dialog__c> getMyDialogues() {
    //     List<Dialog__c> allDialoguesAuraEnabled = [SELECT name, Message__c, OwnerId FROM Dialog__c];
    //     if(allDialoguesAuraEnabled.size()>0)
    //     {
    //         return allDialoguesAuraEnabled;
    //     }
    //     return null;
    // }



    public void addDialogAsUser() {
        System.debug('addDialog called');
        messaggio = 'addDialogAsUser';


        try {
            insert as user newDialog;
            messaggio += ' - insert done';

        } catch(Exception ex) {
            messaggio += ' - exception happened ' + ex.getMessage();

        }
        return;
    }

    public void addDialogAsSystem() {
        System.debug('addDialog called');
        insert as system newDialog;             // CWE 274
        return;
    }

    public void addDialogUnspecified() {
        System.debug('addDialog called');
        insert newDialog;                       // CWE 274
    }

    public void prepareEditAsSystem(){
        System.debug('prepareEdit. param1=' + param1);
        // toBeEditedDialog = Database.query('SELECT name, Message__c, OwnerId FROM Dialog__c where id = :param1 WITH SYSTEM_MODE');
        toBeEditedDialog = [SELECT name, Message__c, OwnerId FROM Dialog__c where id = :param1 WITH SYSTEM_MODE]; // CWE 284
    }

    public void prepareEditAsUser(){
        System.debug('prepareEdit. param1=' + param1);
        toBeEditedDialog = Database.query('SELECT name, Message__c, OwnerId FROM Dialog__c where id = :param1 WITH USER_MODE');
    }


    public void updateDialogAsUser() {
        System.debug('updateDialog called. toBeEditedDialog.ID=' + toBeEditedDialog.id);
        update as user toBeEditedDialog; // FP as user is always good
    }

    public void updateDialogAsSystem() {
        System.debug('updateDialog called. toBeEditedDialog.ID=' + toBeEditedDialog.id);
        update as system toBeEditedDialog;  // CWE 274
    }

    public void updateDialogUnspecified() {
        System.debug('updateDialog called. toBeEditedDialog.ID=' + toBeEditedDialog.id);
        update toBeEditedDialog;            // CWE 274
    }
}