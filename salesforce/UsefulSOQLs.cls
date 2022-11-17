// Retrive all the Batch Jobs

SELECT ApexClass.Name,  Status, COUNT(Id) FROM AsyncApexJob WHERE JobType = 'BatchApex' Group BY ApexClass.Name,Status
