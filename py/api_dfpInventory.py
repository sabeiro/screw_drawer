import api_dfpLib as dfp

reload(dfp)

dAuth = dfp.dfpAuth()
values = [{'key': 'parent_ad_unit_id','value': {'xsi_type': 'NumberValue','value':dAuth.root_ad_unit_id}}]
filter_statement = {'query': 'WHERE PARENT_AD_UNIT_ID = :parent_ad_unit_id','values': values}
report_job = {
    'reportQuery': {
        'dimensions': ['DATE','AD_UNIT_NAME'],
        'adUnitView': 'HIERARCHICAL',
        'columns': ['AD_SERVER_IMPRESSIONS','AD_SERVER_CLICKS','DYNAMIC_ALLOCATION_INVENTORY_LEVEL_IMPRESSIONS','DYNAMIC_ALLOCATION_INVENTORY_LEVEL_CLICKS','TOTAL_INVENTORY_LEVEL_IMPRESSIONS','TOTAL_INVENTORY_LEVEL_CPM_AND_CPC_REVENUE'],
        'dateRangeType': 'LAST_WEEK',
        'statement': filter_statement
    }}
    
repF = dAuth.runRep(report_job)
print repF

