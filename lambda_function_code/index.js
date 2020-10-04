/*
 * This function is checking access to external and internal sites. However,
 * internal EC2 instance that is running Ńginx in private subnet has non-static
 * ip address. in real life scenario I should avoid hardcoding. To achieve it
 * I will have to:
 * 1 - read the ip address from the EC2 instance during this code runtime, or
 * 2 - set up the internal load balancer
 * 
 * As none of these is a part of the task specification I decided to 
 * follow the easiest way by hardcoding ip address of the instance 
 * into the Lambda function that proves the VPC is configured properly
 * and the Lambda function can access web pages placed externally and 
 * internally.
 */

const https = require('https')
const http = require('http')
let url_external = "https://docs.aws.amazon.com/lambda/latest/dg/welcome.html"
let url_internal = "http://10.0.129.161" // Change the ip addr according to
// the ip addr of your instance in the private subnet

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

  console.log("response from external site:", await promise_external)

  return promise_external
}