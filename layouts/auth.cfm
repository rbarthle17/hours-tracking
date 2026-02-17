<cfoutput>
<!doctype html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<meta name="description" content="Hours Tracker - Login">

	<base href="#event.getHTMLBaseURL()#" />

	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossorigin="anonymous">
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">

	<title>Hours Tracker - Login</title>
</head>
<body class="bg-light d-flex align-items-center min-vh-100">

	<div class="container">
		<!--- Flash Messages --->
		<cfif flash.exists( "message" )>
			<div class="row justify-content-center">
				<div class="col-md-5">
					<div class="alert alert-#flash.exists( 'messageType' ) ? flash.get( 'messageType' ) : 'success'# alert-dismissible fade show" role="alert">
						#encodeForHTML( flash.get( "message" ) )#
						<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
					</div>
				</div>
			</div>
		</cfif>

		#view()#
	</div>

	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.min.js" integrity="sha384-cuYeSxntonz0PPNlHhBs68uyIAVpIIOZZ5JqeqvYYIcEL727kskC66kF92t6Xl2V" crossorigin="anonymous"></script>
</body>
</html>
</cfoutput>
