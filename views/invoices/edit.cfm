<cfoutput>
<div class="container py-4">
	<div class="row justify-content-center">
		<div class="col-md-8">
			<div class="d-flex justify-content-between align-items-center mb-4">
				<h1><i class="bi bi-pencil"></i> Edit Invoice #encodeForHTML( prc.invoice.invoice_number )#</h1>
				<a href="#event.buildLink( 'invoices' )#/#prc.invoice.id#" class="btn btn-outline-secondary">
					<i class="bi bi-arrow-left"></i> Back
				</a>
			</div>

			<div class="card">
				<div class="card-body">
					<form method="POST" action="#event.buildLink( 'invoices' )#/#prc.invoice.id#">
						<input type="hidden" name="_method" value="PUT">

						<div class="row mb-3">
							<div class="col-md-6">
								<label for="invoice_date" class="form-label">Invoice Date <span class="text-danger">*</span></label>
								<input type="date" class="form-control" id="invoice_date" name="invoice_date"
									   value="#dateFormat( prc.invoice.invoice_date, 'yyyy-mm-dd' )#" required>
							</div>
							<div class="col-md-6">
								<label for="due_date" class="form-label">Due Date <span class="text-danger">*</span></label>
								<input type="date" class="form-control" id="due_date" name="due_date"
									   value="#dateFormat( prc.invoice.due_date, 'yyyy-mm-dd' )#" required>
							</div>
						</div>

						<div class="mb-3">
							<label for="notes" class="form-label">Notes</label>
							<textarea class="form-control" id="notes" name="notes"
									  rows="3">#encodeForHTML( prc.invoice.notes ?: '' )#</textarea>
						</div>

						<div class="d-flex gap-2">
							<button type="submit" class="btn btn-primary">
								<i class="bi bi-check-lg"></i> Update Invoice
							</button>
							<a href="#event.buildLink( 'invoices' )#/#prc.invoice.id#" class="btn btn-outline-secondary">Cancel</a>
						</div>
					</form>
				</div>
			</div>
		</div>
	</div>
</div>
</cfoutput>
