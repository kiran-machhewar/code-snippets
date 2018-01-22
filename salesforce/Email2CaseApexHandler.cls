/**
 * Created by kmachhewar on 12/5/17.
 */
global class Email2CaseApexHandler implements  Messaging.InboundEmailHandler {


    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope envelope){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();       

        try{
            if(!email.subject.contains('ref:')){
                //Create the text attachments
                Case theCase = new Case();
                theCase.RecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('<RECORD_TYPE_NAME>').getRecordTypeId();
                theCase.Subject       = email.Subject;
                theCase.description   = email.plainTextBody;
                theCase.Origin        = 'Email2Case';
                theCase.Priority      = 'High';
                theCase.Type          = null;

                List<Group> queues = [Select Id, DeveloperName FROM Group WHERE DeveloperName ='<QUEUE_DEVELOPER_NAME>' AND Type = 'Queue'];
                if(queues.size()>0){
                    theCase.OwnerId = queues[0].Id;
                }

                
                insert theCase;

                //Create the EmailMessage to view the html view of the email
                createEmailMessage(theCase.Id,email);


            }else if(email.subject.contains('ref:')){//communication to the existing email
                String reference = email.subject.split('ref:')[1];
                reference = reference.split('_')[2].split(':')[0];
                String caseIdPrefix = reference.substring(0,5);
                String caseIdSuffix = reference.substring(5,reference.length());
                List<String> zerosToBeAdded = new List<String>();
                for(Integer index =0;index < (15 - (caseIdPrefix.length() + caseIdSuffix.length()) );index++){
                    zerosToBeAdded.add('0');
                }
                String caseId = caseIdPrefix + String.join(zerosToBeAdded,'')+caseIdSuffix;
                //Create the EmailMessage to view the html view of the email
                createEmailMessage(caseId,email);

            }


        }catch(Exception ex){
            System.debug('Message-->'+ex.getMessage()+ ' \n'+ex.getStackTraceString() );
            System.debug('Failure');
        }
        return result;
    }

    /**
	* This method will create the EmailMessage so that user would be able to view the html version of email if needed
	*/
    private static void createEmailMessage(Id theCaseId, Messaging.inboundEmail email){
        EmailMessage newEmail  = new EmailMessage(
                FromAddress = email.fromaddress,
                FromName    = email.fromname,
                Subject     = email.subject,
                TextBody    = email.plainTextBody,
                HtmlBody    = email.htmlbody,
                Incoming    = true,
                MessageDate = System.now(),
                ParentId    = theCaseId
        );
        if ( email.ccAddresses!=null && email.ccAddresses.size() > 0){
            newEmail.CcAddress = String.join(email.ccAddresses,';');
        }

        insert newEmail;

        // Save attachments, if any
        List<Attachment> attachments = new List<Attachment>();

        if(email.textAttachments != null){
            for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments) {

                Attachment attachment = new Attachment();
                attachment.Name = tAttachment.fileName;
                attachment.Body = Blob.valueOf(tAttachment.body);
                attachment.ParentId = theCaseId;
                attachments.add(attachment);
            }
        }

        if(email.binaryAttachments != null){
            for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments) {

                Attachment attachment = new Attachment();
                attachment.Name = bAttachment.fileName;
                attachment.Body = bAttachment.body;
                attachment.ParentId = theCaseId;
                attachments.add(attachment);
            }
        }

        insert attachments;
    }

}
