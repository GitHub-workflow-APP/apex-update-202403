public without sharing class UserModeCRUDPlayground {


    public List<Dialog__c> allDialogues {get; set;}
    public Dialog__c newDialog {get; set;}
    public Dialog__c toBeEditedDialog {get; set;}
    public String param1 {get; set;}
    public String messaggio {get; set;}
    public String myTable {get;set;}
    public String dialogId  {get;set;}
    public String dialogName  {get;set;}
    public String dialogMessage  {get;set;}
    public String dialogSecretField  {get;set;}
    public String dialogOwner  {get;set;}
    private MyLittleLogger logger;




    public UserModeCRUDPlayground() {
        System.debug('UserModeCRUDPlayground .ctor');
        logger = new MyLittleLogger();
        logger.log('UserModeCRUDPlayground', '.ctor');
        try{
            // allDialogues = [SELECT name, Message__c, secret_field__c, OwnerId FROM Dialog__c WITH user_mode];
            allDialogues = [SELECT name, Message__c, OwnerId FROM Dialog__c];
        }
        catch(Exception ex){
            logger.log(ex.getMessage());
        }

        try {
            myTable = '<table border=1><tr><td>Name</td><td>Message</td><td>Secret Field</td></tr>';
            for(Dialog__c c: [SELECT name, Message__c, secret_field__c, OwnerId FROM Dialog__c]) {
                myTable += '<tr><td>' + c.name + '</td><td>' + c.Message__c + '</td><td>' + c.secret_field__c + '</td></tr>';
            }
            myTable += '</table>';
        }        catch(Exception ex){
        }

        messaggio = logger.flush();
    }


    public void addDialogAsUser() {
        logger.reset();
        System.debug('addDialogAsUser called');
        logger.log('addDialogAsUser', 'called');
        
        try {
            Dialog__c newDialog = new Dialog__c();
            newDialog.name = dialogName;
            newDialog.Message__c = dialogMessage;
            if(dialogSecretField.length()>0)
                newDialog.secret_field__c = dialogSecretField;
            // insert as user newDialog;
            Database.insert(newDialog, AccessLevel.USER_MODE);
            logger.log('addDialogAsUser','Dialog added Database.insert AccessLevel.USER_MODE');

        } catch(Exception ex){
            logger.log('addDialogAsUser', ex.getMessage());
            System.debug(ex.getMessage());
        }

        messaggio = logger.flush();

    }

    public void addDialogAsSystem() {
        logger.reset();
        System.debug('addDialogAsSystem called');
        logger.log('addDialogAsSystem', 'called');
   
        try {
            Dialog__c newDialog = new Dialog__c();
            newDialog.name = dialogName;
            newDialog.Message__c = dialogMessage;
            if(dialogSecretField.length()>0)
                newDialog.secret_field__c = dialogSecretField;
            // insert as system newDialog;
            Database.insert(newDialog, AccessLevel.SYSTEM_MODE);
            logger.log('addDialogAsUser','Dialog added Database.insert AccessLevel.SYSTEM_MODE');
        } catch(Exception ex){
            logger.log('addDialogAsSystem', ex.getMessage());
            System.debug(ex.getMessage());
        }
        messaggio = logger.flush();

    }


    public void addDialog() {
        logger.reset();
        System.debug('addDialog called');
        logger.log('addDialog', 'called');

        try {
            Dialog__c newDialog = new Dialog__c();
            newDialog.name = dialogName;
            newDialog.Message__c = dialogMessage;
            if(dialogSecretField.length()>0){
                newDialog.secret_field__c = dialogSecretField;
            }


            
            // insert newDialog;

            logger.log('addDialogAsUser', 'strip with enforceRootObjectCRUD returned records: ' + Security.stripInaccessible(AccessType.READABLE, new List<Dialog__c>{newDialog}).getRecords().size());
            // Database.insert(Security.stripInaccessible(AccessType.CREATABLE, new List<Dialog__c>{newDialog}).getRecords());
            logger.log('addDialogAsUser','Dialog added Database.insert AccessType.CREATABLE');

        } catch(Exception ex){
            logger.log('addDialog Exception: ', ex.getMessage());
            System.debug(ex.getMessage());
        }
        messaggio = logger.flush();

    }


    public void addDialog2() {
        logger.reset();
        System.debug('addDialog2 called');
        logger.log('addDialog2', 'called');

        logger.log('Dialog__c is accessible = ' + Schema.SObjectType.Dialog__c.isAccessible());
        logger.log('Dialog__c.Name is accessible = ' + Schema.SObjectType.Dialog__c.fields.Name.isAccessible());
        logger.log('Dialog__c.Message__c is accessible = ' + Schema.SObjectType.Dialog__c.fields.Message__c.isAccessible());
        logger.log('Dialog__c.Secret_field__c is accessible = ' + Schema.SObjectType.Dialog__c.fields.Secret_field__c.isAccessible());
        logger.log('Dialog__c.Id is accessible = ' + Schema.SObjectType.Dialog__c.fields.Id.isAccessible());

        try {
            logger.log('addDialog2', 'applying stripInaccessible');
            Dialog__c newDialog = new Dialog__c();
            newDialog.name = dialogName;
            newDialog.Message__c = dialogMessage;
            if(dialogSecretField.length()>0){
                newDialog.secret_field__c = dialogSecretField;
            }
            
            
            List<Dialog__c> elementsToAdd = new List<Dialog__c>();
            elementsToAdd.add(newDialog);
            


            // elementsToAdd = Security.stripInaccessible(AccessType.CREATABLE, elementsToAdd).getRecords();
            elementsToAdd = Security.stripInaccessible(AccessType.UPDATABLE, elementsToAdd).getRecords();
            
            logger.log('stripApplied');
            insert elementsToAdd[0];

        } catch(Exception ex){
            logger.log('addDialog2 exception:', ex.getMessage());
            System.debug(ex.getMessage());
        }
        messaggio = logger.flush();

    }





    public void prepareEdit(){
        System.debug('prepareEdit. param1=' + param1);
        toBeEditedDialog = Database.query('SELECT name, Message__c, secret_field__c, OwnerId FROM Dialog__c where id = :param1');
        dialogId = toBeEditedDialog.id;
        dialogName = toBeEditedDialog.name;
        dialogMessage = toBeEditedDialog.Message__c;
        dialogSecretField = toBeEditedDialog.secret_field__c;
        dialogOwner = toBeEditedDialog.OwnerId;
    }


    public void updateDialog() {
        logger.reset();
        logger.log('updateDialog', 'dialogId=' + dialogId);
        System.debug('updateDialog called. dialogId=' + dialogId);

        Dialog__c d = new Dialog__c();
        d.Id = dialogId;
        d.Name = dialogName;
        d.Message__c = dialogMessage;
        d.secret_field__c = dialogSecretField;

        logger.log('updateDialog', 'stripInaccessible UPDATABLE=' + Security.stripInaccessible(AccessType.UPDATABLE, new List<Dialog__c>{d}).getRecords().size());
        logger.log('updateDialog', 'stripInaccessible READABLE=' + Security.stripInaccessible(AccessType.READABLE, new List<Dialog__c>{d}).getRecords().size());

        try{
            update Security.stripInaccessible(AccessType.UPDATABLE, new List<Dialog__c>{d}).getRecords();
            logger.log('updateDialog ','Update completed successfully');

        }catch(Exception ex){
            logger.log('updateDialog ex', ex.getMessage());
        }

        messaggio = logger.flush();


    }


    public void deleteDialog() {
        logger.reset();
        logger.log('deleteDialog', 'deleteDialog.ID=' + dialogId);
        System.debug('deleteDialog called. deleteDialog.ID=' + dialogId);

        Dialog__c delId = new Dialog__c();
        delId.Id = dialogId;
        delId.Name = dialogName;
        delId.Message__c = dialogMessage;
        delId.secret_field__c = dialogSecretField;
        
        List<Dialog__c> elementsToDelete = new List<Dialog__c>{delId};

        // elementsToAdd = Security.stripInaccessible(AccessType.CREATABLE, elementsToAdd).getRecords();
        try{
            elementsToDelete = Security.stripInaccessible(AccessType.READABLE, elementsToDelete).getRecords();
            logger.log('deleteDialog', 'READABLE Strip done');
            logger.log('deleteDialog', 'isDeletable:' + Schema.SObjectType.Dialog__c.isDeletable());

            if(Schema.SObjectType.Dialog__c.isDeletable()){
                logger.log('deleteDialog', 'inside isDeleatable check');
                    logger.log('deleteDialog', 'getDescribe().isDeletable(): ' + Dialog__c.sObjectType.getDescribe().isDeletable());
                    
                    delete as system delId;
                    
                    logger.log('deleteDialog', 'Delete done');
                }
                
                logger.log('deleteDialog', 'end of try');

        }catch(Exception ex){
            logger.log('deleteDialog exception:', ex.getMessage());
        }
        messaggio = logger.flush();

    }

    
    public void runMe() {
        // System.debug('Schema.SObjectType.Dialog__c.isAccessible()' + Schema.SObjectType.Dialog__c.isAccessible());
        // System.debug('Schema.SObjectType.Dialog__c.isDeletable()' + Schema.SObjectType.Dialog__c.isDeletable());

        logger.reset();
        Set<String> records = new Set<String>{ '4','1', '3' };
        List<Dialog__c> elems = [SELECT ID FROM DIALOG__c WHERE Name in :records];

        logger.log('runMe', 'Query returns elements = ' + elems.size());
        logger.log('runMe', 'is Dialog__c Accessible? : ' + Schema.SObjectType.Dialog__c.isAccessible());
        logger.log('runMe', 'is Dialog__c deletable? : ' + Schema.SObjectType.Dialog__c.isDeletable());

        try{


            delete as user [SELECT ID FROM DIALOG__c WHERE Name in :records WITH USER_MODE] ;
        }catch(Exception ex){
            logger.log('runMe ex', ex.getMessage());
        }
        messaggio = logger.flush();

    }



    private class MyLittleLogger {

        private String logMessage;

        public MyLittleLogger() {
            reset();
        }

        public void log(String orig, String msg){
            logMessage += '<tr><td>' + orig + '</td><td>' + msg + '</td></tr>';
        }

        public void log(String msg){
            logMessage += '<tr><td>-</td><td>' + msg + '</td></tr>';
        }

        public String flush(){
            logMessage += '</table>';

            return logMessage;
        }

        public void reset(){
            logMessage = '<table border=1><tr><th>Orig</th><th>Message</th></tr>';
        }
    }
}