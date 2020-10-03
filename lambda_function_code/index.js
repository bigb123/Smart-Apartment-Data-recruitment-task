exports.handler =  async function(event, context) {
    console.log("This lambda function seems to be working");
    console.log("EVENT: \n" + JSON.stringify(event, null, 2))
    return context.logStreamName
  }