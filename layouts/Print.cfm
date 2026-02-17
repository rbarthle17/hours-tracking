<cfoutput>
<!doctype html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">

	<base href="#event.getHTMLBaseURL()#" />

	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossorigin="anonymous">

	<style>
		@media print {
			.no-print { display: none !important; }
			body { font-size: 12pt; }
		}
	</style>

	<title>Hours Tracker - Print</title>
</head>
<body>
	<div class="container py-4">
		#view()#
	</div>
</body>
</html>
</cfoutput>
