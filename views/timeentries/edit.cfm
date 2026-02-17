<cfoutput>
<div class="container py-4">
	<div class="row justify-content-center">
		<div class="col-md-8">
			<div class="d-flex justify-content-between align-items-center mb-4">
				<h1><i class="bi bi-pencil"></i> Edit Time Entry</h1>
				<a href="#event.buildLink( 'timeentries' )#/#prc.timeEntry.id#" class="btn btn-outline-secondary">
					<i class="bi bi-arrow-left"></i> Back
				</a>
			</div>

			<div class="card">
				<div class="card-body">
					<form method="POST" action="#event.buildLink( 'timeentries' )#/#prc.timeEntry.id#">
						<input type="hidden" name="_method" value="PUT">

						<div class="row mb-3">
							<div class="col-md-6">
								<label for="ticket_id" class="form-label">Ticket <span class="text-danger">*</span></label>
								<select class="form-select" id="ticket_id" name="ticket_id" required>
									<option value="">Select a ticket...</option>
									<cfset currentClient = "">
									<cfloop query="prc.tickets">
										<cfif prc.tickets.client_name NEQ currentClient>
											<cfif len( currentClient )></optgroup></cfif>
											<optgroup label="#encodeForHTMLAttribute( prc.tickets.client_name )#">
											<cfset currentClient = prc.tickets.client_name>
										</cfif>
										<option value="#prc.tickets.id#" #prc.timeEntry.ticket_id EQ prc.tickets.id ? 'selected' : ''#>
											#encodeForHTML( prc.tickets.title )#
										</option>
									</cfloop>
									<cfif len( currentClient )></optgroup></cfif>
								</select>
							</div>
							<div class="col-md-6">
								<label for="contract_id" class="form-label">Contract <span class="text-danger">*</span></label>
								<select class="form-select" id="contract_id" name="contract_id" required>
									<option value="">Select a contract...</option>
									<cfset currentClient = "">
									<cfloop query="prc.contracts">
										<cfif prc.contracts.client_name NEQ currentClient>
											<cfif len( currentClient )></optgroup></cfif>
											<optgroup label="#encodeForHTMLAttribute( prc.contracts.client_name )#">
											<cfset currentClient = prc.contracts.client_name>
										</cfif>
										<option value="#prc.contracts.id#" #prc.timeEntry.contract_id EQ prc.contracts.id ? 'selected' : ''#>
											#encodeForHTML( prc.contracts.name )# (#formatCurrency( prc.contracts.hourly_rate )#/hr)
										</option>
									</cfloop>
									<cfif len( currentClient )></optgroup></cfif>
								</select>
							</div>
						</div>

						<div class="row mb-3">
							<div class="col-md-6">
								<label for="entry_date" class="form-label">Date <span class="text-danger">*</span></label>
								<input type="date" class="form-control" id="entry_date" name="entry_date"
									   value="#dateFormat( prc.timeEntry.entry_date, 'yyyy-mm-dd' )#" required>
							</div>
							<div class="col-md-6">
								<label for="hours_worked" class="form-label">Hours <span class="text-danger">*</span></label>
								<input type="number" class="form-control" id="hours_worked" name="hours_worked"
									   value="#prc.timeEntry.hours_worked#"
									   step="0.25" min="0.25" max="24" required>
							</div>
						</div>

						<div class="mb-3">
							<label for="notes" class="form-label">Notes</label>
							<textarea class="form-control" id="notes" name="notes"
									  rows="3">#encodeForHTML( prc.timeEntry.notes ?: '' )#</textarea>
						</div>

						<div class="d-flex gap-2">
							<button type="submit" class="btn btn-primary">
								<i class="bi bi-check-lg"></i> Update Time Entry
							</button>
							<a href="#event.buildLink( 'timeentries' )#/#prc.timeEntry.id#" class="btn btn-outline-secondary">Cancel</a>
						</div>
					</form>
				</div>
			</div>
		</div>
	</div>
</div>
</cfoutput>
