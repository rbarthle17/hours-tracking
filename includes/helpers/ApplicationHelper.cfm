<cfscript>
/**
 * Format a numeric value as US currency
 */
function formatCurrency( required numeric amount ) {
	return dollarFormat( arguments.amount );
}

/**
 * Format a date value with a given mask
 */
function formatAppDate( required date value, string mask = "MMM dd, yyyy" ) {
	return dateFormat( arguments.value, arguments.mask );
}

/**
 * Generate a Bootstrap badge for a status value
 */
function statusBadge( required string status ) {
	var classes = {
		"active": "bg-success",
		"completed": "bg-secondary",
		"paused": "bg-warning text-dark",
		"draft": "bg-light text-dark border",
		"sent": "bg-info text-dark",
		"paid": "bg-success",
		"partial": "bg-warning text-dark",
		"overdue": "bg-danger",
		"open": "bg-primary",
		"in_progress": "bg-info text-dark",
		"done": "bg-success",
		"closed": "bg-secondary",
		"low": "bg-light text-dark border",
		"medium": "bg-warning text-dark",
		"high": "bg-danger"
	};
	var badgeClass = structKeyExists( classes, arguments.status ) ? classes[ arguments.status ] : "bg-secondary";
	var displayText = replace( uCase( arguments.status ), "_", " ", "all" );
	return '<span class="badge #badgeClass#">#displayText#</span>';
}

/**
 * Check if the current session user has the admin role
 */
function isAdmin() {
	return structKeyExists( session, "user" )
		&& structKeyExists( session.user, "role" )
		&& session.user.role == "admin";
}

/**
 * Check if a user is currently logged in
 */
function isLoggedIn() {
	return structKeyExists( session, "user" );
}
</cfscript>
