<cfoutput>
<div class="container py-4">
	<div class="d-flex justify-content-between align-items-center mb-4">
		<h1><i class="bi bi-plus-lg"></i> New Invoice</h1>
		<a href="#event.buildLink( 'invoices' )#" class="btn btn-outline-secondary">
			<i class="bi bi-arrow-left"></i> Back to Invoices
		</a>
	</div>

	<!--- Step 1: Select client --->
	<div class="card mb-4">
		<div class="card-header"><h5 class="mb-0">1. Select Client</h5></div>
		<div class="card-body">
			<form method="GET" action="#event.buildLink( 'invoices.new' )#" class="row g-2">
				<div class="col-auto">
					<select name="client_id" class="form-select" onchange="this.form.submit()">
						<option value="">Choose a client...</option>
						<cfloop query="prc.clients">
							<option value="#prc.clients.id#" #val( rc.client_id ?: 0 ) EQ prc.clients.id ? 'selected' : ''#>
								#encodeForHTML( prc.clients.name )#
							</option>
						</cfloop>
					</select>
				</div>
			</form>
		</div>
	</div>

	<!--- Step 2: Select time entries (shown when client is selected) --->
	<cfif val( rc.client_id ?: 0 ) GT 0>
		<cfif prc.uninvoiced.recordCount>
			<form method="POST" action="#event.buildLink( 'invoices' )#" x-data="invoiceForm()">
				<input type="hidden" name="client_id" value="#rc.client_id#">

				<div class="card mb-4">
					<div class="card-header d-flex justify-content-between align-items-center">
						<h5 class="mb-0">2. Select Time Entries</h5>
						<div>
							<button type="button" class="btn btn-sm btn-outline-secondary" @click="selectAll()">Select All</button>
							<button type="button" class="btn btn-sm btn-outline-secondary" @click="selectNone()">Clear</button>
						</div>
					</div>
					<div class="card-body p-0">
						<table class="table table-hover mb-0">
							<thead class="table-light">
								<tr>
									<th style="width: 40px;"></th>
									<th>Date</th>
									<th>Ticket</th>
									<th>Contract</th>
									<th class="text-end">Hours</th>
									<th class="text-end">Rate</th>
									<th class="text-end">Amount</th>
								</tr>
							</thead>
							<tbody>
								<cfloop query="prc.uninvoiced">
									<tr>
										<td>
											<input type="checkbox" class="form-check-input" name="time_entry_ids"
												   value="#prc.uninvoiced.id#"
												   x-model="selected"
												   data-hours="#prc.uninvoiced.hours_worked#"
												   data-rate="#prc.uninvoiced.hourly_rate#">
										</td>
										<td>#formatAppDate( prc.uninvoiced.entry_date )#</td>
										<td>#encodeForHTML( prc.uninvoiced.ticket_title )#</td>
										<td>#encodeForHTML( prc.uninvoiced.contract_name )#</td>
										<td class="text-end">#numberFormat( prc.uninvoiced.hours_worked, '0.00' )#</td>
										<td class="text-end">#formatCurrency( prc.uninvoiced.hourly_rate )#</td>
										<td class="text-end">#formatCurrency( prc.uninvoiced.hours_worked * prc.uninvoiced.hourly_rate )#</td>
									</tr>
								</cfloop>
							</tbody>
						</table>
					</div>
				</div>

				<div class="card mb-4">
					<div class="card-header"><h5 class="mb-0">3. Invoice Details</h5></div>
					<div class="card-body">
						<div class="row mb-3">
							<div class="col-md-4">
								<label for="invoice_date" class="form-label">Invoice Date <span class="text-danger">*</span></label>
								<input type="date" class="form-control" id="invoice_date" name="invoice_date"
									   value="#dateFormat( now(), 'yyyy-mm-dd' )#" required>
							</div>
							<div class="col-md-4">
								<label for="due_date" class="form-label">Due Date <span class="text-danger">*</span></label>
								<input type="date" class="form-control" id="due_date" name="due_date"
									   value="#dateFormat( dateAdd( 'd', 30, now() ), 'yyyy-mm-dd' )#" required>
							</div>
						</div>

						<div class="mb-3">
							<label for="notes" class="form-label">Notes</label>
							<textarea class="form-control" id="notes" name="notes" rows="2"></textarea>
						</div>

						<div class="d-flex justify-content-between align-items-center">
							<button type="submit" class="btn btn-primary">
								<i class="bi bi-check-lg"></i> Create Invoice
							</button>
							<span class="text-muted" x-show="getSelectedCount() > 0"
								  x-text="getSelectedCount() + ' entries selected'"></span>
						</div>
					</div>
				</div>
			</form>

			<script>
			function invoiceForm() {
				return {
					selected: [],
					selectAll() {
						this.selected = [...document.querySelectorAll('input[name="time_entry_ids"]')].map(el => el.value);
					},
					selectNone() {
						this.selected = [];
					},
					getSelectedCount() {
						return this.selected.length;
					}
				};
			}
			</script>
		<cfelse>
			<div class="card">
				<div class="card-body text-center text-muted py-4">
					<i class="bi bi-check-circle" style="font-size: 2rem;"></i>
					<p class="mt-2 mb-0">No uninvoiced time entries for this client. All caught up!</p>
				</div>
			</div>
		</cfif>
	</cfif>
</div>
</cfoutput>
