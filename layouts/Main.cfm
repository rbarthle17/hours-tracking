<cfoutput>
<!doctype html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<meta name="description" content="Hours Tracking - Contractor Management">
	<meta name="author" content="Rob">

	<base href="#event.getHTMLBaseURL()#" />

	<!--- CSS: Bootstrap 5 + Bootstrap Icons --->
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-rbsA2VBKQhggwzxH7pPCaAqO46MgnOM80zW1RWuH61DGLwZJEdK2Kadq2F9CUG65" crossorigin="anonymous">
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css">

	<style>
		.nav-link.active { font-weight: 600; }
	</style>

	<title>Hours Tracker</title>
</head>
<body class="d-flex flex-column min-vh-100">

	<!--- Top Navigation --->
	<header>
		<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
			<div class="container-fluid">

				<a class="navbar-brand" href="#event.buildLink( '' )#">
					<i class="bi bi-clock-history"></i> <strong>Hours Tracker</strong>
				</a>

				<button
					class="navbar-toggler"
					type="button"
					data-bs-toggle="collapse"
					data-bs-target="##navbarMain"
					aria-controls="navbarMain"
					aria-expanded="false"
					aria-label="Toggle navigation"
				>
					<span class="navbar-toggler-icon"></span>
				</button>

				<div class="collapse navbar-collapse" id="navbarMain">
					<cfif structKeyExists( session, "user" )>
						<ul class="navbar-nav me-auto mb-2 mb-lg-0">
							<li class="nav-item">
								<a class="nav-link #event.getCurrentHandler() eq 'Main' ? 'active' : ''#"
								   href="#event.buildLink( '' )#">
									<i class="bi bi-speedometer2"></i> Dashboard
								</a>
							</li>
							<li class="nav-item">
								<a class="nav-link #event.getCurrentHandler() eq 'Clients' ? 'active' : ''#"
								   href="#event.buildLink( 'clients' )#">
									<i class="bi bi-people"></i> Clients
								</a>
							</li>
							<li class="nav-item">
								<a class="nav-link #event.getCurrentHandler() eq 'Contracts' ? 'active' : ''#"
								   href="#event.buildLink( 'contracts' )#">
									<i class="bi bi-file-earmark-text"></i> Contracts
								</a>
							</li>
							<li class="nav-item">
								<a class="nav-link #event.getCurrentHandler() eq 'Tickets' ? 'active' : ''#"
								   href="#event.buildLink( 'tickets' )#">
									<i class="bi bi-kanban"></i> Tickets
								</a>
							</li>
							<li class="nav-item">
								<a class="nav-link #event.getCurrentHandler() eq 'TimeEntries' ? 'active' : ''#"
								   href="#event.buildLink( 'timeentries' )#">
									<i class="bi bi-hourglass-split"></i> Time Entries
								</a>
							</li>
							<li class="nav-item">
								<a class="nav-link #event.getCurrentHandler() eq 'Invoices' ? 'active' : ''#"
								   href="#event.buildLink( 'invoices' )#">
									<i class="bi bi-receipt"></i> Invoices
								</a>
							</li>
						</ul>

						<ul class="navbar-nav mb-2 mb-lg-0">
							<cfif isAdmin()>
								<li class="nav-item">
									<a class="nav-link #event.getCurrentHandler() eq 'Users' ? 'active' : ''#"
									   href="#event.buildLink( 'users' )#">
										<i class="bi bi-gear"></i> Users
									</a>
								</li>
							</cfif>
							<li class="nav-item">
								<span class="nav-link text-light">
									<i class="bi bi-person-circle"></i>
									#encodeForHTML( session.user.first_name )# #encodeForHTML( session.user.last_name )#
								</span>
							</li>
							<li class="nav-item">
								<a class="nav-link" href="#event.buildLink( 'auth.logout' )#">
									<i class="bi bi-box-arrow-right"></i> Logout
								</a>
							</li>
						</ul>
					</cfif>
				</div>

			</div>
		</nav>
	</header>

	<!--- Flash Messages --->
	<cfif flash.exists( "message" )>
		<div class="container mt-3">
			<div class="alert alert-#flash.exists( 'messageType' ) ? flash.get( 'messageType' ) : 'success'# alert-dismissible fade show" role="alert">
				#encodeForHTML( flash.get( "message" ) )#
				<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
			</div>
		</div>
	</cfif>

	<!--- Main Content --->
	<main class="flex-shrink-0 mb-5">
		#view()#
	</main>

	<!--- Footer --->
	<footer class="mt-auto border-top py-3 bg-light">
		<div class="container">
			<p class="text-muted mb-0 small">
				&copy; #year( now() )# Hours Tracker
			</p>
		</div>
	</footer>

	<!--- JavaScript: Bootstrap 5 + Alpine.js --->
	<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.6/dist/umd/popper.min.js" integrity="sha384-oBqDVmMz9ATKxIep9tiCxS/Z9fNfEXiDAYTujMAeBAsjFuCZSmKbSSUnQlmh/jp3" crossorigin="anonymous"></script>
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.min.js" integrity="sha384-cuYeSxntonz0PPNlHhBs68uyIAVpIIOZZ5JqeqvYYIcEL727kskC66kF92t6Xl2V" crossorigin="anonymous"></script>
	<script defer src="https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js"></script>
</body>
</html>
</cfoutput>
