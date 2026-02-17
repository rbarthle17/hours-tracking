<cfoutput>
<div class="row justify-content-center">
	<div class="col-md-5">
		<div class="card shadow-sm">
			<div class="card-body p-4">
				<div class="text-center mb-4">
					<i class="bi bi-clock-history fs-1 text-primary"></i>
					<h3 class="mt-2">Hours Tracker</h3>
					<p class="text-muted">Sign in to your account</p>
				</div>

				<form method="POST" action="#event.buildLink( 'auth.login' )#">
					<div class="mb-3">
						<label for="email" class="form-label">Email address</label>
						<input type="email"
							   class="form-control"
							   id="email"
							   name="email"
							   placeholder="you@example.com"
							   required
							   autofocus>
					</div>

					<div class="mb-4">
						<label for="password" class="form-label">Password</label>
						<input type="password"
							   class="form-control"
							   id="password"
							   name="password"
							   placeholder="Enter your password"
							   required>
					</div>

					<button type="submit" class="btn btn-primary w-100">
						<i class="bi bi-box-arrow-in-right"></i> Sign In
					</button>
				</form>
			</div>
		</div>
	</div>
</div>
</cfoutput>
