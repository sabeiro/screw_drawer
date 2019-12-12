
// Generate a refreshable OAuth2 credential.
Credential oAuth2Credential = new OfflineCredentials.Builder()
    .forApi(Api.DFP)
    .fromFile()
    .build()
    .generateCredential();

// Construct a DfpSession.
DfpSession session = new DfpSession.Builder()
    .fromFile()
    .withOAuth2Credential(oAuth2Credential)
    .build();

// Construct a DfpSession.
DfpSession session = new DfpSession.Builder()
    .fromFile()
    .withOAuth2Credential(oAuth2Credential)
    .build();

// Create a statement to select all ad units.
StatementBuilder statementBuilder = new StatementBuilder()
    .orderBy("id ASC")
    .limit(StatementBuilder.SUGGESTED_PAGE_LIMIT);

// Default for total result set size.
int totalResultSetSize = 0;

do {
    // Get ad units by statement.
    AdUnitPage page = inventoryService.getAdUnitsByStatement(statementBuilder.toStatement());

    if (page.getResults() != null) {
        totalResultSetSize = page.getTotalResultSetSize();
        int i = page.getStartIndex();
        for (AdUnit adUnit : page.getResults()) {
	    System.out.printf(
			      "%d) Ad unit with ID '%s' and name '%s' was found.%n", i++,
			      adUnit.getId(), adUnit.getName());
        }
    }

    statementBuilder.increaseOffsetBy(StatementBuilder.SUGGESTED_PAGE_LIMIT);
} while (statementBuilder.getOffset() < totalResultSetSize);

System.out.printf("Number of results found: %d%n", totalResultSetSize);

Report target = null;
ReportList reports;
String nextPageToken = null;

do {
    // Create and execute the reports list request.
    reports = reporting.reports().list(profileId).setPageToken(nextPageToken).execute();

    for (Report report : reports.getItems()) {
	if (isTargetReport(report)) {
	    target = report;
	    break;
	}
    }

    // Update the next page token.
    nextPageToken = reports.getNextPageToken();
} while (!reports.getItems().isEmpty() && !Strings.isNullOrEmpty(nextPageToken));
//run the report
File file = reporting.reports().run(profileId, reportId).execute();
//wait for the report to complete
BackOff backOff = new ExponentialBackOff.Builder()
    .setInitialIntervalMillis(10 * 1000)     // 10 second initial retry
    .setMaxIntervalMillis(10 * 60 * 1000)    // 10 minute maximum retry
    .setMaxElapsedTimeMillis(60 * 60 * 1000) // 1 hour total retry
    .build();

while (true) {
    File file = reporting.files().get(reportId, fileId).execute();

    // Check to see if the report has finished processing
    if ("REPORT_AVAILABLE".equals(file.getStatus())) {
	System.out.printf("File status is %s, processing finished.%n", file.getStatus());
	return file;
    }

    // If the file isn't available yet, wait before checking again.
    long retryInterval = backOff.nextBackOffMillis();
    if (retryInterval == BackOff.STOP) {
	System.out.println("File processing deadline exceeded.%n");
	return null;
    }
    System.out.printf("File status is %s, sleeping for %dms.%n", file.getStatus(), retryInterval);
    Thread.sleep(retryInterval);
}
File target = null;
FileList files;
String nextPageToken = null;

do {
    // Create and execute the files list request.
    files = reporting.reports().files().list(profileId, reportId).setPageToken(nextPageToken)
	.execute();

    for (File file : files.getItems()) {
	if (isTargetFile(file)) {
	    target = file;
	    break;
	}
    }

    // Update the next page token.
    nextPageToken = files.getNextPageToken();
} while (!files.getItems().isEmpty() && !Strings.isNullOrEmpty(nextPageToken));




File file = reporting.files().get(reportId, fileId).execute();
String browserUrl = file.getUrls().getBrowserUrl();


//https://www.googleapis.com/dfareporting/v2.7/reports/4758/files/4758?alt=media


