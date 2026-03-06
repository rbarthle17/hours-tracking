<cfoutput>
<div class="container py-4">
	<div class="row justify-content-center">
		<div class="col-md-8">
			<div class="d-flex justify-content-between align-items-center mb-4">
				<h1><i class="bi bi-pencil"></i> Edit Expense</h1>
				<a href="#event.buildLink( 'expenses' )#/#prc.expense.id#" class="btn btn-outline-secondary">
					<i class="bi bi-arrow-left"></i> Back to Expense
				</a>
			</div>

			<div class="card">
				<div class="card-body">
					<form method="POST" action="#event.buildLink( 'expenses' )#/#prc.expense.id#"
						  x-data="{ isBillable: #prc.expense.is_billable ? 'true' : 'false'# }">
						<input type="hidden" name="_method" value="PUT">

						<div class="row mb-3">
							<div class="col-md-6">
								<label for="expense_date" class="form-label">Date <span class="text-danger">*</span></label>
								<input type="date" class="form-control" id="expense_date" name="expense_date"
									   value="#encodeForHTMLAttribute( dateFormat( prc.expense.expense_date, 'yyyy-mm-dd' ) )#" required>
							</div>
							<div class="col-md-6">
								<label for="amount" class="form-label">Amount <span class="text-danger">*</span></label>
								<div class="input-group">
									<span class="input-group-text">$</span>
									<input type="number" class="form-control" id="amount" name="amount"
										   value="#encodeForHTMLAttribute( numberFormat( prc.expense.amount, '0.00' ) )#"
										   step="0.01" min="0.01" required>
								</div>
							</div>
						</div>

						<div class="row mb-3">
							<div class="col-md-6">
								<label for="vendor" class="form-label">Vendor / Payee <span class="text-danger">*</span></label>
								<input type="text" class="form-control" id="vendor" name="vendor"
									   value="#encodeForHTMLAttribute( prc.expense.vendor )#" required>
							</div>
							<div class="col-md-6">
								<label for="category" class="form-label">Category <span class="text-danger">*</span></label>
								<select class="form-select" id="category" name="category" required>
									<option value="">Select a category...</option>
									<cfloop array="#prc.categories#" item="cat">
										<option value="#encodeForHTMLAttribute( cat )#"
												#prc.expense.category EQ cat ? 'selected' : ''#>
											#encodeForHTML( cat )#
										</option>
									</cfloop>
								</select>
							</div>
						</div>

						<div class="mb-3">
							<div class="form-check">
								<input class="form-check-input" type="checkbox" id="is_billable" name="is_billable"
									   value="1" x-model="isBillable"
									   #prc.expense.is_billable ? 'checked' : ''#>
								<label class="form-check-label" for="is_billable">
									Billable to a client
								</label>
							</div>
						</div>

						<div class="mb-3">
							<label for="client_id" class="form-label">
								<span x-show="isBillable">Client <span class="text-danger">*</span></span>
								<span x-show="!isBillable">Client (optional)</span>
							</label>
							<select class="form-select" id="client_id" name="client_id"
									:required="isBillable">
								<option value="">None / General Business</option>
								<cfloop query="prc.clients">
									<option value="#prc.clients.id#"
											#prc.expense.client_id EQ prc.clients.id ? 'selected' : ''#>
										#encodeForHTML( prc.clients.name )#
									</option>
								</cfloop>
							</select>
							<div class="form-text" x-show="isBillable">
								<i class="bi bi-info-circle"></i> Required when expense is billable.
							</div>
						</div>

						<div class="mb-3">
							<label for="description" class="form-label">Description</label>
							<textarea class="form-control" id="description" name="description"
									  rows="3">#encodeForHTML( prc.expense.description ?: '' )#</textarea>
						</div>

						<div class="mb-3">
							<label for="receipt_reference" class="form-label">Receipt Reference</label>
							<input type="text" class="form-control" id="receipt_reference" name="receipt_reference"
								   value="#encodeForHTMLAttribute( prc.expense.receipt_reference ?: '' )#"
								   placeholder="e.g. receipt number, filename, URL">
						</div>

						<div class="d-flex gap-2">
							<button type="submit" class="btn btn-primary">
								<i class="bi bi-check-lg"></i> Save Changes
							</button>
							<a href="#event.buildLink( 'expenses' )#/#prc.expense.id#" class="btn btn-outline-secondary">Cancel</a>
						</div>
					</form>
				</div>
			</div>
		</div>
	</div>
</div>
</cfoutput>
