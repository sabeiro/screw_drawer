//Prepare S3 access and bucket names
var awssum = require('awssum');
var s3 = new awssum.load('amazon/s3').S3({
    accessKeyId: '...',
    secretAccessKey: '..',
});
var sourceBucket = 'old-bucket';
var destinationBucket = 'new-bucket';
var listObjectsDone = false;

//Set up our queue
var queue = async.queue(function(objectName, callback) {
    //This is the queue's `task` function
    //It copies `objectName` from `sourceBucket` to `destinationBucket`
    var options = {
        BucketName: destinationBucket,
        ObjectName: objectName,
        SourceBucket: sourceBucket,
        SourceObject: objectName
    };
    s3.CopyObject(options, function(err) {
        if (err) throw err;
        callback(); //Tell async that this queue item has been processed
    });
}, 20); //Only allow 20 copy requests at a time so we don't flood the network

//When the queue is emptied we want to check if we're done
queue.drain = function() {
    checkDone();
};

//Define the function that lists objects from the source bucket
//It gets the current `marker` as its argument
function listObjects(marker) {
    var options = {
        BucketName: sourceBucket,
        Marker: marker,
        MaxKeys: 1000
    };
    s3.ListObjects(options, function(err, data) {
        if (err) throw err;
        var result = data.Body.ListBucketResult;
        var contents = _.isArray(result.Contents) ? result.Contents : [result.Contents]; //AWS sends an array if multiple, and a single object if there was only one result
        _.each(contents, function(item) {
            var objectName = item.Key;
            marker = objectName; //Save the marker
            queue.push(objectName); //Push the object to our queue
        });
        if (result.IsTruncated == 'true') {
            //The result is truncated, i.e. we have to list once more, starting from the new marker
            listObjects(marker);
        } else {
            //Tell our routine that we don't need to wait for more objects from S3
            listObjectsDone = true;
            //Check if we're done (is the queue empty?)
            checkDone();
        }
    });
}

/*
This function gets called when:
a) `listObjects` didn't return a truncated result (because we were at the end of the bucket)
b) when the last task of the queue is finished
*/
function checkDone() {
    if (queue.length() == 0 && listObjectsDone) {
        console.log('Tada! All objects have been copied :)');
    }
}

//Start the routine by calling `listObjects` with `null` as the `marker`
listObjects(null);
