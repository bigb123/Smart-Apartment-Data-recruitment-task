// exports.handler =  async function(event, context) {
//     console.log("This lambda function seems to be working");
//     console.log("EVENT: \n" + JSON.stringify(event, null, 2))
//     return context.logStreamName
//   }

const https = require('https')
const http = require('http')
let url_external = "https://docs.aws.amazon.com/lambda/latest/dg/welcome.html"
let url_internal = "http://10.0.129.161"

exports.handler = async function(event) {
  const promise_internal = new Promise(function(resolve, reject) {
    http.get(url_internal, (res) => {
        resolve(res.statusCode)
      }).on('error', (e) => {
        reject(Error(e))
      })
    })
  
  console.log("response from internal site:", await promise_internal)

  const promise_external = new Promise(function(resolve, reject) {
    https.get(url_external, (res) => {
        resolve(res.statusCode)
      }).on('error', (e) => {
        reject(Error(e))
      })
    })

  console.log("response from internal site:", await promise_external)

  return promise_external
}