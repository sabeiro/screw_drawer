var spawn = require("child_process").spawn;
var process = spawn('python',["path/to/script.py", arg1, arg2, ...]);
print(dataToSendBack)
sys.stdout.flush()
process.stdout.on('data', function (data){
// Do something with the data returned from python script
});
