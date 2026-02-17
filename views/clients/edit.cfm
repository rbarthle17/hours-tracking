<cfoutput>
<div class="container py-4">
	<div class="row justify-content-center">
		<div class="col-md-8">
			<div class="d-flex justify-content-between align-items-center mb-4">
				<h1><i class="bi bi-pencil"></i> Edit Client</h1>
				<a href="#event.buildLink( 'clients' )#/#prc.client.id#" class="btn btn-outline-secondary">
					<i class="bi bi-arrow-left"></i> Back to Client
				</a>
			</div>

			<div class="card">
				<div class="card-body">
					<form method="POST" action="#event.buildLink( 'clients' )#/#prc.client.id#">
						<input type="hidden" name="_method" value="PUT">

						<div class="mb-3">
							<label for="name" class="form-label">Name <span class="text-danger">*</span></label>
							<input type="text" class="form-control" id="name" name="name"
								   value="#encodeForHTMLAttribute( prc.client.name )#" required autofocus>
						</div>

						<div class="mb-3">
							<label for="email" class="form-label">Email</label>
							<input type="email" class="form-control" id="email" name="email"
								   value="#encodeForHTMLAttribute( prc.client.email )#">
						</div>

						<div class="mb-3">
							<label for="phone" class="form-label">Phone</label>
							<input type="text" class="form-control" id="phone" name="phone"
								   value="#encodeForHTMLAttribute( prc.client.phone )#">
						</div>

						<div class="mb-3">
							<label for="address" class="form-label">Address</label>
							<textarea class="form-control" id="address" name="address" rows="3">#encodeForHTML( prc.client.address )#</textarea>
						</div>

						<div class="d-flex gap-2">
							<button type="submit" class="btn btn-primary">
								<i class="bi bi-check-lg"></i> Update Client
							</button>
							<a href="#event.buildLink( 'clients' )#/#prc.client.id#" class="btn btn-outline-secondary">Cancel</a>
						</div>
					</form>
				</div>
			</div>
		</div>
	</div>
</div>
</cfoutput>
