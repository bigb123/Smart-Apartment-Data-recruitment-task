// exports.handler =  async function(event, context) {
//     console.log("This lambda function seems to be working");
//     console.log("EVENT: \n" + JSON.stringify(event, null, 2))
//     return context.logStreamName
//   }

const https = require('https')
let url = "https://docs.aws.amazon.com/lambda/latest/dg/welcome.html"

exports.handler = async function(event) {
  const promise = new Promise(function(resolve, reject) {
    https.get(url, (res) => {
        resolve(res.statusCode)
      }).on('error', (e) => {
        reject(Error(e))
      })
    })
  return promise
}