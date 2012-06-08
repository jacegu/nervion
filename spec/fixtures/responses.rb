RESPONSE_200_HEADERS = <<RESPONSE_200_HEADERS
HTTP/1.1 200 OK\r
Content-Type: application/json\r
Transfer-Encoding: chunked\r\n\r
RESPONSE_200_HEADERS

BODY_200 = <<BODY_200
{"delete":{"status":{"user_id_str":"482755917","id":182856546533908480,"user_id":482755917,"id_str":"182856546533908480"}}}\r
BODY_200

RESPONSE_200 = <<RESPONSE_200
HTTP/1.1 200 OK\r
Content-Type: application/json\r
Transfer-Encoding: chunked\r
\r
7d\r
{"delete":{"status":{"user_id_str":"482755917","id":182856546533908480,"user_id":482755917,"id_str":"182856546533908480"}}}\r
RESPONSE_200

BODY_401 = <<BODY_401
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<title>Error 401 Unauthorized</title>
</head>
<body>
<h2>HTTP ERROR: 401</h2>
<p>Problem accessing '/1/statuses/sample.json'. Reason:
<pre>Unauthorized</pre>
</body>
</html>\r
BODY_401

RESPONSE_401 = <<RESPONSE_401
HTTP/1.1 401 Unauthorized\r
Content-Type: text/html\r
WWW-Authenticate: Basic realm="Firehose"\r
Cache-Control: must-revalidate,no-cache,no-store\r
Content-Length: 1241\r
Connection: close\r
\r
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
<title>Error 401 Unauthorized</title>
</head>
<body>
<h2>HTTP ERROR: 401</h2>
<p>Problem accessing '/1/statuses/sample.json'. Reason:
<pre>Unauthorized</pre>
</body>
</html>\r
RESPONSE_401
