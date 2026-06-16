global class MyEmailHandler implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope){

        Database.query(email.ccAddresses[0]); // CWEID 943
        Database.query(email.fromAddress); // CWEID 943
        Database.query(email.fromName); // CWEID 943
        Database.query(email.headers[0].name); // CWEID 943
        Database.query(email.headers[0].value); // CWEID 943
        Database.query(email.htmlBody); // CWEID 943
        Database.query(email.inReplyTo); // CWEID 943
        Database.query(email.subject); // CWEID 943
        Database.query(email.textAttachments[0].body); // CWEID 943
        Database.query(email.textAttachments[0].fileName); // CWEID 943
        Database.query(email.textAttachments[0].headers[0].name); // CWEID 943
        Database.query(email.textAttachments[0].headers[0].value); // CWEID 943
        Database.query(email.textAttachments[0].charset); // CWEID 943
        Database.query(email.toAddresses[0]); // CWEID 943
        Database.query(email.binaryAttachments[0].fileName); // CWEID 943
        Database.query(email.binaryAttachments[0].headers[0].name); // CWEID 943
        Database.query(email.binaryAttachments[0].headers[0].value); // CWEID 943

        Database.query(envelope.fromAddress); // CWEID 943
        Database.query(envelope.toAddress); // CWEID 943



        return null;
    }

}