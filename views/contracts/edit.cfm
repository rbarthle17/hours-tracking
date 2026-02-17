<cfoutput>
<div class="container py-4">
	<div class="row justify-content-center">
		<div class="col-md-8">
			<div class="d-flex justify-content-between align-items-center mb-4">
				<h1><i class="bi bi-pencil"></i> Edit Contract</h1>
				<a href="#event.buildLink( 'contracts.show', { id: prc.contract.id } )#" class="btn btn-outline-secondary">
					<i class="bi bi-arrow-left"></i> Back to Contract
				</a>
			</div>

			<div class="card">
				<div class="card-body">
					<form method="POST" action="#event.buildLink( 'contracts', { id: prc.contract.id } )#">
						<input type="hidden" name="_method" value="PUT">

						<div class="mb-3">
							<label for="client_id" class="form-label">Client <span class="text-danger">*</span></label>
							<select class="form-select" id="client_id" name="client_id" required>
								<option value="">Select a client...</option>
								<cfloop query="prc.clients">
									<option value="#prc.clients.id#" #prc.contract.client_id EQ prc.clients.id ? 'selected' : ''#>
										#encodeForHTML( prc.clients.name )#
									</option>
								</cfloop>
							</select>
						</div>

						<div class="mb-3">
							<label for="name" class="form-label">Contract Name <span class="text-danger">*</span></label>
							<input type="text" class="form-control" id="name" name="name"
								   value="#encodeForHTMLAttribute( prc.contract.name )#" required>
						</div>

						<div class="row mb-3">
							<div class="col-md-4">
								<label for="hourly_rate" class="form-label">Hourly Rate <span class="text-danger">*</span></label>
								<div class="input-group">
									<span class="input-group-text">$</span>
									<input type="number" class="form-control" id="hourly_rate" name="hourly_rate"
										   step="0.01" min="0" value="#prc.contract.hourly_rate#" required>
								</div>
							</div>
							<div class="col-md-4">
								<label for="start_date" class="form-label">Start Date <span class="text-danger">*</span></label>
								<input type="date" class="form-control" id="start_date" name="start_date"
									   value="#dateFormat( prc.contract.start_date, 'yyyy-mm-dd' )#" required>
							</div>
							<div class="col-md-4">
								<label for="end_date" class="form-label">End Date</label>
								<input type="date" class="form-control" id="end_date" name="end_date"
									   value="#isDate( prc.contract.end_date ) ? dateFormat( prc.contract.end_date, 'yyyy-mm-dd' ) : ''#">
							</div>
						</div>

						<div class="mb-3">
							<label for="status" class="form-label">Status</label>
							<select class="form-select" id="status" name="status">
								<option value="active" #prc.contract.status EQ 'active' ? 'selected' : ''#>Active</option>
								<option value="paused" #prc.contract.status EQ 'paused' ? 'selected' : ''#>Paused</option>
								<option value="completed" #prc.contract.status EQ 'completed' ? 'selected' : ''#>Completed</option>
							</select>
						</div>

						<div class="d-flex gap-2">
							<button type="submit" class="btn btn-primary">
								<i class="bi bi-check-lg"></i> Update Contract
							</button>
							<a href="#event.buildLink( 'contracts.show', { id: prc.contract.id } )#" class="btn btn-outline-secondary">Cancel</a>
						</div>
					</form>
				</div>
			</div>
		</div>
	</div>
</div>
</cfoutput>
