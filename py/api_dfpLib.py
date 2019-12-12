import tempfile
import urlparse,urllib,urllib2,requests,cookielib
import base64
import json,gzip,zlib,sys,csv
import time
import StringIO
import os
from googleads import dfp
from googleads import errors


class dfpAuth():
    def __init__(self):
        credFile = os.environ['LAV_DIR'] + '/credenza/googleads.yaml'
        dfp_client = dfp.DfpClient.LoadFromStorage(credFile)
        network_service = dfp_client.GetService('NetworkService', version='v201702')
        self.report_downloader = dfp_client.GetDataDownloader(version='v201702')
        self.root_ad_unit_id = (network_service.getCurrentNetwork()['effectiveRootAdUnitId'])
        
    def runRep(self,report_job):
        try:
            report_job_id = self.report_downloader.WaitForReport(report_job)
        except errors.DfpReportError, e:
            print 'Failed to generate report. Error was: %s' % e

        report_file = tempfile.NamedTemporaryFile(suffix='.csv.gz', delete=False)
        self.report_downloader.DownloadReportToFile(report_job_id,'CSV_DUMP',report_file)
        report_file.close()
        content = gzip.GzipFile(report_file.name).read()
        cr = csv.reader(content.splitlines(), delimiter=',')
        cr_list = list(cr)
        campL = []
        for row in cr_list:
            campL.append(row)
        return campL





    


    
