// Based on AWS Cloudwatch "Stream to Amazon Elasticsearch Service" funcion v1.1.2
// Required stack parameters:
// * EnvVarElasticsearchEndpoint - Amazon Elasticsearch Service domain endpoint

var https = require('https');
var zlib = require('zlib');
var crypto = require('crypto');

var ENDPOINT = process.env.ELASTICSEARCH_URL;
var API_KEY = process.env.ELASTICSEARCH_API_KEY;

exports.handler = function(input, context) {
    // decode input from base64
    var zippedInput = new Buffer(input.awslogs.data, 'base64');

    // decompress the input
    zlib.gunzip(zippedInput, function(error, buffer) {
        if (error) { context.fail(error); return; }

        // parse the input from JSON
        var awslogsData = JSON.parse(buffer.toString('utf8'));

        // transform the input to Elasticsearch documents
        var elasticsearchBulkData = transform(awslogsData);

        // skip control messages
        if (!elasticsearchBulkData) {
            console.log('Received a control message');
            context.succeed('Control message handled successfully');
            return;
        }

        // post documents to the Amazon Elasticsearch Service
        post(elasticsearchBulkData, function(error, success, statusCode, failedItems) {
            console.log('Response: ' + JSON.stringify({
                "statusCode": statusCode
            }));

            if (error) {
                console.log('Error: ' + JSON.stringify(error, null, 2));

                if (failedItems && failedItems.length > 0) {
                    console.log("Failed Items: " +
                        JSON.stringify(failedItems, null, 2));
                }

                context.fail(JSON.stringify(error));
            } else {
                console.log('Success: ' + JSON.stringify(success));
                context.succeed('Success');
            }
        });
    });
};

function transform(payload) {
    if (payload.messageType === 'CONTROL_MESSAGE') {
        return null;
    }

    var bulkRequestBody = '';

    payload.logEvents.forEach(function(logEvent) {
        var timestamp = new Date(1 * logEvent.timestamp);

        // index name format: logs-YYYY.MM.DD
        var indexName = [
            'logs-' + timestamp.getUTCFullYear(),              // year
            ('0' + (timestamp.getUTCMonth() + 1)).slice(-2),  // month
            ('0' + timestamp.getUTCDate()).slice(-2)          // day
        ].join('.');

        var source = buildSource(logEvent.message);
        source['instance_id'] = payload.logStream;

        if ("epochTime" in source && !isNaN(parseFloat(source.epochTime)) && isFinite(source.epochTime)
            && Math.floor(Math.floor(source.epochTime) * 1000) === timestamp.getTime()) {
            // iff epochTime is present and numeric AND ALSO represents a time "in the same second" as timestamp (i.e.
            // timestamp could be considered a second-floored representation of epochTime) we replace timestamp with
            // epochTime in an attempt to rescue precision for applications (*cough* nginx) which aren't able to output
            // fractional seconds in their ISO timestamps.
            //
            // note how this comparison will also ignore epochTime if timestamp already appears to have fractional
            // second information.
            timestamp = new Date(source.epochTime * 1000);
        }

        source['@timestamp'] = timestamp.toISOString();

        var action = { "index": {} };
        action.index._index = indexName;
        action.index._type = payload.logGroup;
        action.index._id = logEvent.id;

        bulkRequestBody += [
            JSON.stringify(action),
            JSON.stringify(source),
        ].join('\n') + '\n';
    });
    return bulkRequestBody;
}


function buildSource(message) {
    var jsonSubString = extractJson(message);
    if (jsonSubString === null) {
        return {};
    }

    var source = JSON.parse(jsonSubString);

    ['time', 'user'].forEach(function (key) {
        delete source[key];
    });

    // Convert nested objects and arrays to strings to stop Kibana from rejecting records
    // for missing nested keys mappings
    Object.keys(source).forEach(function (key) {
      if (typeof source[key] === 'object' && source[key] !== null) {
        source[key] = JSON.stringify(source[key]);
      }
    });

    return source;
}

function extractJson(message) {
    var jsonStart = message.indexOf('{');
    if (jsonStart < 0) return null;
    var jsonSubString = message.substring(jsonStart);
    return isValidJson(jsonSubString) ? jsonSubString : null;
}

function isValidJson(message) {
    try {
        JSON.parse(message);
    } catch (e) { return false; }
    return true;
}

function isNumeric(n) {
    return !isNaN(parseFloat(n)) && isFinite(n);
}

function post(body, callback) {
    var requestParams = buildRequest(ENDPOINT, API_KEY, body);

    var request = https.request(requestParams, function(response) {
        var responseBody = '';
        response.on('data', function(chunk) {
            responseBody += chunk;
        });
        response.on('end', function() {
            var info = JSON.parse(responseBody);
            var failedItems;
            var success;

            if (response.statusCode >= 200 && response.statusCode < 299) {
                failedItems = info.items.filter(function(x) {
                    return x.index.status >= 300;
                });

                success = {
                    "attemptedItems": info.items.length,
                    "successfulItems": info.items.length - failedItems.length,
                    "failedItems": failedItems.length
                };
            }

            var error = response.statusCode !== 200 || info.errors === true ? {
                "statusCode": response.statusCode,
                "responseBody": responseBody
            } : null;

            callback(error, success, response.statusCode, failedItems);
        });
    }).on('error', function(e) {
        callback(e);
    });
    request.end(requestParams.body);
}

function buildRequest(endpoint, api_key, body) {
    return {
        host: endpoint,
        method: 'POST',
        path: '/_bulk',
        body: body,
        headers: {
            'Host': endpoint,
            'ApiKey': api_key,
            'Content-Type': 'application/json',
            'Content-Length': Buffer.byteLength(body),
        }
    };
}
